#!/usr/bin/env python3
"""Tri-database deduplication pipeline (WoS > Scopus > PubMed).

Inputs (place in ./raw/, not redistributed for licensing reasons):
  savedrecs.txt        WoS Plain Text full record export
  pubmed.csv           PubMed CSV summary export
  scopus.csv           Scopus CSV full export
Outputs: data/corpus_unique_tridatabase.csv and results/tables/T0-T8.
Retracted articles are excluded and must be listed in RETRACTED.
"""
import pandas as pd, re, unicodedata
from collections import Counter

RETRACTED = {"10.1177/02698811241234247", "10.3389/fnins.2023.1168911"}

def norm_doi(d):
    if pd.isna(d) or not str(d).strip(): return None
    return re.sub(r"^https?://(dx\.)?doi\.org/", "", str(d).strip().lower()) or None

def norm_title(t):
    if pd.isna(t): return None
    t = unicodedata.normalize("NFKD", str(t)).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]", "", t.lower()) or None

def parse_wos(path):
    multi = ["DE", "ID", "C1", "CR", "AU", "AF"]
    recs, cur, field = [], {}, None
    with open(path, encoding="utf-8-sig") as f:
        for line in f:
            line = line.rstrip("\n")
            if line.startswith("PT "):
                cur = {k: [] for k in multi}; cur["TI"] = ""
            tag = line[:2]
            if tag.strip() and tag != "  ": field = tag
            val = line[3:]
            if field in multi: cur[field].append(val.strip())
            elif field == "TI": cur["TI"] = (cur["TI"] + " " + val).strip()
            elif field in ("SO","PY","DT","DI","UT","TC","RP") and tag == field: cur[field] = val.strip()
            if line == "ER": recs.append(cur); cur = {}
    return pd.DataFrame(recs)

def main():
    wos = parse_wos("raw/savedrecs.txt")
    wos["d"] = wos["DI"].apply(norm_doi); wos["t"] = wos["TI"].apply(norm_title)
    wos = wos[~wos["d"].isin(RETRACTED)]
    wos = wos[~(wos["d"].duplicated() & wos["d"].notna())]
    wos = wos[~wos["t"].duplicated()].copy()

    sc = pd.read_csv("raw/scopus.csv", dtype=str)
    sc["d"] = sc["DOI"].apply(norm_doi); sc["t"] = sc["Title"].apply(norm_title)
    sc_u = sc[~(sc["d"].isin(set(wos["d"].dropna())) | sc["t"].isin(set(wos["t"].dropna())))].copy()

    seen_d = set(wos["d"].dropna()) | set(sc_u["d"].dropna())
    seen_t = set(wos["t"].dropna()) | set(sc_u["t"].dropna())
    pm = pd.read_csv("raw/pubmed.csv", dtype=str)
    pm["d"] = pm["DOI"].apply(norm_doi); pm["t"] = pm["Title"].apply(norm_title)
    pm_u = pm[~(pm["d"].isin(seen_d) | pm["t"].isin(seen_t))].copy()

    corpus = pd.concat([
        pd.DataFrame({"source": "WOS", "title": wos["TI"], "year": wos["PY"], "doi": wos["d"], "document_type": wos["DT"]}),
        pd.DataFrame({"source": "SCOPUS", "title": sc_u["Title"], "year": sc_u["Year"], "doi": sc_u["d"], "document_type": sc_u["Document Type"]}),
        pd.DataFrame({"source": "PUBMED", "title": pm_u["Title"], "year": pm_u["Publication Year"], "doi": pm_u["d"], "document_type": None}),
    ], ignore_index=True)
    corpus.to_csv("data/corpus_unique_tridatabase.csv", index=False)
    print(f"WoS {len(wos)} | Scopus unique {len(sc_u)} | PubMed unique {len(pm_u)} | Total {len(corpus)}")

if __name__ == "__main__":
    main()
