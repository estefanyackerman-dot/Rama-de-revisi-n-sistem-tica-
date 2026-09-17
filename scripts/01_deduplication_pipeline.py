#!/usr/bin/env python3
"""Deduplicate the supplied Web of Science, Ovid and PubMed exports.

Input files are the exports currently in this project directory:
  savedrecs (3).ris       Web of Science RIS export
  ris (3).ris             Ovid RIS export
  csv-psilocybTi-set.csv  PubMed CSV export (the extension is misleading)

Records are kept in source-priority order (Web of Science, Ovid, PubMed).
DOIs are matched first; records without a DOI are matched by normalized title.
The result is written to data/corpus_unique_tridatabase.csv.
"""

from pathlib import Path
import re
import unicodedata

import pandas as pd


SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = SCRIPT_DIR.parent
# The script lives in scripts/, but the project inputs and generated data are
# stored alongside the repo root. Prefer the repo root when available, but keep a
# fallback to the script directory for standalone execution.
if (PROJECT_ROOT / "README.md").exists() or (PROJECT_ROOT / "data").exists():
    ROOT = PROJECT_ROOT
else:
    ROOT = SCRIPT_DIR

INPUTS = (
    ("WOS", ROOT / "savedrecs (3).ris"),
    ("OVID", ROOT / "ris (3).ris"),
    ("PUBMED", ROOT / "csv-psilocybTi-set.csv"),
)
RETRACTED = {"10.1177/02698811241234247", "10.3389/fnins.2023.1168911"}


def norm_doi(value):
    if pd.isna(value) or not str(value).strip():
        return None
    doi = str(value).strip().lower()
    doi = re.sub(r"^(?:https?://)?(?:dx\.)?doi\.org/", "", doi)
    doi = re.sub(r"^doi:\s*", "", doi)
    return doi.rstrip(" .;") or None


def norm_title(value):
    if pd.isna(value) or not str(value).strip():
        return None
    title = unicodedata.normalize("NFKD", str(value))
    title = title.encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]", "", title) or None


def parse_ris(path):
    """Parse the fields needed for deduplication from a RIS export."""
    records, current = [], {}
    with path.open(encoding="utf-8-sig", errors="replace") as handle:
        for raw_line in handle:
            line = raw_line.rstrip("\r\n")
            if line == "ER  -":
                if current:
                    records.append(current)
                current = {}
                continue
            match = re.match(r"^([A-Z0-9]{2})\s+-\s+(.*)$", line)
            if not match:
                continue
            tag, value = match.groups()
            if tag in {"TI", "T1"}:
                current["title"] = value
            elif tag == "DO":
                current["doi"] = value
            elif tag in {"PY", "Y1"}:
                current["year"] = value.split("/", 1)[0]
            elif tag in {"PT", "TY"}:
                current["document_type"] = value
    if current:
        records.append(current)
    return pd.DataFrame(records)


def parse_pubmed_csv(path):
    frame = pd.read_csv(path, dtype=str)
    required = {"Title", "DOI"}
    missing = required - set(frame.columns)
    if missing:
        raise ValueError(f"{path.name} is missing columns: {', '.join(sorted(missing))}")
    return pd.DataFrame(
        {
            "title": frame["Title"],
            "doi": frame["DOI"],
            "year": frame.get("Publication Year"),
            "document_type": None,
        }
    )


def load_source(source, path):
    if not path.exists():
        raise FileNotFoundError(f"Input file not found: {path}")
    if source == "PUBMED":
        return parse_pubmed_csv(path)
    return parse_ris(path)


def main():
    unique_records = []
    seen_dois, seen_titles = set(), set()
    source_counts = []
    total_identified = 0
    total_retracted = 0
    total_duplicates = 0

    for source, path in INPUTS:
        records = load_source(source, path)
        identified = len(records)
        records["doi"] = records["doi"].apply(norm_doi)
        records["title_key"] = records["title"].apply(norm_title)
        retracted = int(records["doi"].isin(RETRACTED).sum())
        records = records[~records["doi"].isin(RETRACTED)]

        keep = []
        for _, record in records.iterrows():
            doi, title = record["doi"], record["title_key"]
            duplicate = (doi and doi in seen_dois) or (title and title in seen_titles)
            if duplicate:
                continue
            keep.append(record)
            if doi:
                seen_dois.add(doi)
            if title:
                seen_titles.add(title)

        unique_count = len(keep)
        source_counts.append(
            {
                "source": source,
                "records_identified": identified,
                "retracted_records_removed": retracted,
                "duplicates_removed": len(records) - unique_count,
                "records_after_deduplication": unique_count,
            }
        )
        total_identified += identified
        total_retracted += retracted
        total_duplicates += len(records) - unique_count
        unique_records.extend(
            {
                "source": source,
                "title": record["title"],
                "year": record.get("year"),
                "doi": record["doi"],
                "document_type": record.get("document_type"),
            }
            for record in keep
        )

    output = ROOT / "data" / "corpus_unique_tridatabase.csv"
    output.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(unique_records).to_csv(output, index=False)

    pd.DataFrame(source_counts).to_csv(
        ROOT / "data" / "prisma_2020_source_counts.csv", index=False
    )
    corpus_frame = pd.DataFrame(unique_records)
    report = (
        corpus_frame.groupby("source", dropna=False)
        .agg(
            records=("title", "size"),
            missing_title=("title", lambda column: int(column.isna().sum())),
            missing_doi=("doi", lambda column: int(column.isna().sum())),
            year_min=("year", "min"),
            year_max=("year", "max"),
        )
        .reset_index()
    )
    report["doi_coverage_percent"] = (
        (1 - report["missing_doi"] / report["records"]) * 100
    ).round(2)
    report["title_coverage_percent"] = (
        (1 - report["missing_title"] / report["records"]) * 100
    ).round(2)
    report.to_csv(ROOT / "data" / "pandas_corpus_report.csv", index=False)

    corpus_frame["year"] = pd.to_numeric(corpus_frame["year"], errors="coerce")
    year_report = (
        corpus_frame.groupby(["year", "source"], dropna=False)
        .size()
        .reset_index(name="records")
        .sort_values(["year", "source"], na_position="last")
    )
    year_report.to_csv(ROOT / "data" / "pandas_year_report.csv", index=False)

    flow = pd.DataFrame(
        [
            {"prisma_stage": "Records identified from databases", "value": total_identified},
            {"prisma_stage": "Duplicate records removed", "value": total_duplicates},
            {"prisma_stage": "Retracted records removed", "value": total_retracted},
            {
                "prisma_stage": "Records screened after deduplication",
                "value": len(unique_records),
            },
            {"prisma_stage": "Records excluded during screening", "value": "NR"},
            {"prisma_stage": "Reports sought for retrieval", "value": "NR"},
            {"prisma_stage": "Reports not retrieved", "value": "NR"},
            {"prisma_stage": "Reports assessed for eligibility", "value": "NR"},
            {"prisma_stage": "Reports excluded with reasons", "value": "NR"},
            {"prisma_stage": "Studies included in review", "value": "NR"},
        ]
    )
    flow.to_csv(ROOT / "data" / "prisma_2020_flow_counts.csv", index=False)

    summary = " | ".join(
        f"{row['source']} unique {row['records_after_deduplication']}"
        for row in source_counts
    )
    print(f"{summary} | Total {len(unique_records)}")


if __name__ == "__main__":
    main()
