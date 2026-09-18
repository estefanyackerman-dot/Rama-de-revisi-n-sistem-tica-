#!/usr/bin/env python3
"""Build two reproducible bibliometric corpora and VOSviewer network files.

The core corpus uses the three intended databases: Web of Science, Scopus and
PubMed. The extended corpus adds all attached RIS and PubMed exports available
in the Downloads directory. The script writes VOSviewer-compatible map/network
files plus auditable CSV summaries.
"""

from __future__ import annotations

import csv
import re
import unicodedata
from collections import Counter, defaultdict
from itertools import combinations
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS = Path(r"C:\Users\estef\Downloads")
OUT = ROOT / "results" / "vosviewer_dual"
RETRACTED = {"10.1177/02698811241234247", "10.3389/fnins.2023.1168911"}

SCOPUS_CSV = DOWNLOADS / "export_d288e58d-73a0-4753-bd55-252bb1b3bf8a_2026-09-06T035102.817750959.csv"
PUBMED_CSVS = [
    DOWNLOADS / "csv-psilocybTi-set.csv",
    DOWNLOADS / "pubmed.csv-psilocybTi-set.csv",
]
PUBMED_TXT = [DOWNLOADS / "pubmed-psilocybTi-set (5).txt"]
RIS_FILES = {
    "OVID": DOWNLOADS / "ris (3).ris",
}
WOS_RIS_FILES = [
    DOWNLOADS / "savedrecs (1).ris",
    DOWNLOADS / "savedrecs (2).ris",
]

COUNTRY_NAMES = [
    "United States", "United Kingdom", "Canada", "Australia", "Switzerland",
    "Germany", "Netherlands", "Brazil", "Poland", "Denmark", "Spain", "Italy",
    "Mexico", "France", "China", "Japan", "India", "Portugal", "Belgium",
]
STOPWORDS = {"the", "and", "of", "for", "with", "from", "therapy", "study"}


def norm(value: object) -> str:
    text = "" if value is None else str(value)
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return re.sub(r"\s+", " ", text).strip()


def norm_key(value: object) -> str:
    return re.sub(r"[^a-z0-9]", "", norm(value).lower())


def norm_doi(value: object) -> str:
    text = norm(value).lower()
    text = re.sub(r"^(https?://)?(dx\.)?doi\.org/", "", text)
    return text.strip().rstrip(".")


def split_values(value: object) -> list[str]:
    text = norm(value)
    if not text:
        return []
    return [x.strip() for x in re.split(r";|\||\n", text) if x.strip()]


def parse_ris(path: Path, source: str) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []
    record: dict[str, list[str]] = defaultdict(list)
    for raw in path.read_text(encoding="utf-8-sig", errors="replace").splitlines():
        if raw.startswith("TY  -"):
            record = defaultdict(list)
        if len(raw) >= 6 and raw[2:6] == "  - ":
            tag, value = raw[:2], raw[6:]
            record[tag].append(value.strip())
        if raw.startswith("ER  -"):
            records.append({
                "source": source,
                "title": " ".join(record.get("TI", record.get("T1", []))),
                "authors": "; ".join(record.get("AU", record.get("A1", []))),
                "keywords": "; ".join(record.get("KW", record.get("DE", []))),
                "abstract": " ".join(record.get("AB", [])),
                "journal": " ".join(record.get("T2", record.get("JA", []))),
                "year": (record.get("PY") or record.get("Y1") or [""])[0][:4],
                "doi": (record.get("DO") or [""])[0],
                "affiliations": "; ".join(record.get("AD", [])),
            })
    return records


def parse_pubmed_txt(path: Path) -> list[dict[str, str]]:
    records: list[dict[str, str]] = []
    record: dict[str, list[str]] = defaultdict(list)
    current = ""
    for raw in path.read_text(encoding="utf-8-sig", errors="replace").splitlines() + [""]:
        if not raw.strip() and record:
            records.append({
                "source": "PUBMED",
                "title": " ".join(record.get("TI", [])),
                "authors": "; ".join(record.get("AU", [])),
                "keywords": "",
                "abstract": " ".join(record.get("AB", [])),
                "journal": " ".join(record.get("JT", [])),
                "year": next(iter(record.get("DP", [""])), "")[:4],
                "doi": next((x.split(" ")[0] for x in record.get("AID", []) if "[doi]" in x), ""),
                "affiliations": "; ".join(record.get("AD", [])),
            })
            record = defaultdict(list)
            current = ""
            continue
        if len(raw) >= 6 and raw[4] == "-" and raw[:4].strip():
            current = raw[:4]
            record[current].append(raw[6:].strip())
        elif raw.startswith("      ") and current:
            record[current][-1] += " " + raw.strip()
    return records


def read_csv_records(path: Path, source: str) -> list[dict[str, str]]:
    frame = pd.read_csv(path, dtype=str, keep_default_na=False, encoding_errors="replace")
    cols = {norm_key(c): c for c in frame.columns}
    def col(*names: str) -> str:
        for name in names:
            if norm_key(name) in cols:
                return cols[norm_key(name)]
        return ""
    result = []
    for _, row in frame.iterrows():
        result.append({
            "source": source,
            "title": row.get(col("Title", "TI"), ""),
            "authors": row.get(col("Authors", "AU"), ""),
            "keywords": row.get(col("Author Keywords", "Author keywords", "DE"), ""),
            "abstract": row.get(col("Abstract", "AB"), ""),
            "journal": row.get(col("Source title", "Journal/Book", "SO"), ""),
            "year": row.get(col("Year", "Publication Year", "PY"), ""),
            "doi": row.get(col("DOI", "DI"), ""),
            "affiliations": row.get(col("Affiliations", "C1"), ""),
        })
    return result


def canonicalize(records: list[dict[str, str]]) -> pd.DataFrame:
    seen: dict[str, dict[str, str]] = {}
    for record in records:
        record = {k: norm(v) for k, v in record.items()}
        record["doi"] = norm_doi(record["doi"])
        key = "doi:" + record["doi"] if record["doi"] else "title:" + norm_key(record["title"])
        if not key or key.endswith(":"):
            continue
        if record["doi"] in RETRACTED:
            continue
        if key in seen:
            seen[key]["source"] = ";".join(sorted(set(seen[key]["source"].split(";") + [record["source"]])))
            for field in ("authors", "keywords", "abstract", "affiliations"):
                if not seen[key][field] and record[field]:
                    seen[key][field] = record[field]
        else:
            seen[key] = record
    frame = pd.DataFrame(seen.values())
    if frame.empty:
        return frame
    frame["year"] = pd.to_numeric(frame["year"].str.extract(r"(\d{4})")[0], errors="coerce").astype("Int64")
    return frame.sort_values(["year", "title"], na_position="last").reset_index(drop=True)


def countries(text: str) -> list[str]:
    return [country for country in COUNTRY_NAMES if country.lower() in text.lower()]


def terms(frame: pd.DataFrame) -> list[list[str]]:
    output = []
    for value in frame["keywords"].fillna(""):
        values = [norm(x).lower() for x in re.split(r";|\||,", value) if norm(x)]
        output.append(sorted(set(values)))
    return output


def make_network(labels_by_doc: list[list[str]], minimum: int = 3) -> tuple[pd.DataFrame, pd.DataFrame]:
    counts = Counter(x for row in labels_by_doc for x in row if x and len(x) > 1)
    labels = [label for label, count in counts.most_common() if count >= minimum]
    allowed = set(labels)
    links = Counter()
    for row in labels_by_doc:
        row = sorted(set(x for x in row if x in allowed))
        for left, right in combinations(row, 2):
            links[(left, right)] += 1
    nodes = pd.DataFrame({"id": range(1, len(labels) + 1), "label": labels, "weight": [counts[x] for x in labels]})
    index = {label: idx for idx, label in zip(nodes["id"], nodes["label"])}
    edges = pd.DataFrame(
        [{"source": index[a], "target": index[b], "weight": weight} for (a, b), weight in links.items()],
        columns=["source", "target", "weight"],
    )
    return nodes, edges


def write_vos(name: str, network_name: str, nodes: pd.DataFrame, edges: pd.DataFrame) -> None:
    directory = OUT / name
    directory.mkdir(parents=True, exist_ok=True)
    nodes.to_csv(directory / f"{network_name}_map.txt", sep="\t", index=False)
    with (directory / f"{network_name}_network.net").open("w", encoding="utf-8") as handle:
        handle.write(f"*Vertices {len(nodes)}\n")
        for row in nodes.itertuples(index=False):
            handle.write(f'{row.id} "{str(row.label).replace(chr(34), chr(39))}"\n')
        handle.write("*Edges\n")
        for row in edges.itertuples(index=False):
            handle.write(f"{row.source} {row.target} {row.weight}\n")


def analyze(name: str, frame: pd.DataFrame) -> None:
    directory = OUT / name
    directory.mkdir(parents=True, exist_ok=True)
    frame.to_csv(directory / "corpus_deduplicated.csv", index=False)
    frame.groupby(["year"], dropna=False).size().reset_index(name="documents").to_csv(directory / "annual_production.csv", index=False)
    frame["source"].str.split(";").explode().value_counts().rename_axis("source").reset_index(name="documents").to_csv(directory / "source_counts.csv", index=False)
    for network_name, docs in {
        "author_keywords": terms(frame),
        "authors": [[norm(x).lower() for x in re.split(r";|,", value) if norm(x)] for value in frame["authors"].fillna("")],
        "countries": [countries(" ".join([a, b])) for a, b in zip(frame["affiliations"].fillna(""), frame["abstract"].fillna(""))],
    }.items():
        nodes, edges = make_network(docs, minimum=2 if network_name == "authors" else 3)
        write_vos(name, network_name, nodes, edges)
        nodes.to_csv(directory / f"{network_name}_top.csv", index=False)
    (directory / "README.txt").write_text(
        "Open the *_map.txt and *_network.net files in VOSviewer using Create map "
        "from network data. Node weight is document frequency and edge weight is "
        "co-occurrence frequency. The corpus is deduplicated by DOI, then title.\n",
        encoding="utf-8",
    )


def main() -> None:
    raw: list[dict[str, str]] = []
    raw += read_csv_records(SCOPUS_CSV, "SCOPUS")
    for path in PUBMED_CSVS:
        if path.exists():
            raw += read_csv_records(path, "PUBMED")
    for path in PUBMED_TXT:
        if path.exists():
            raw += parse_pubmed_txt(path)
    for path in WOS_RIS_FILES:
        raw += parse_ris(path, "WOS")
    for source, path in RIS_FILES.items():
        if path.exists():
            raw += parse_ris(path, source)
    all_frame = canonicalize(raw)
    core_frame = canonicalize([r for r in raw if r["source"] in {"SCOPUS", "PUBMED", "WOS"}])
    OUT.mkdir(parents=True, exist_ok=True)
    analyze("01_core_WOS_Scopus_PubMed", core_frame)
    analyze("02_all_attached_databases", all_frame)
    summary = pd.DataFrame([
        {"corpus": "core_WOS_Scopus_PubMed", "documents": len(core_frame), "sources": core_frame["source"].nunique() if not core_frame.empty else 0},
        {"corpus": "all_attached_databases", "documents": len(all_frame), "sources": all_frame["source"].nunique() if not all_frame.empty else 0},
    ])
    summary.to_csv(OUT / "corpus_summary.csv", index=False)
    print(summary.to_string(index=False))


if __name__ == "__main__":
    main()
