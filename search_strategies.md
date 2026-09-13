# Search strategies (PRISMA-S documentation)

All searches executed on 27 August 2026. No language limit; no full-text availability limit.

## Bibliometric arm (broad strategies; reviews eligible)

**Web of Science Core Collection** (advanced search)
```
(( TS=(psilocyb*) OR TS=("psilocybin therapy") OR TS=("psilocybin-assisted therapy") OR TS=("psilocybin assisted therapy") OR TI=(psilocybin OR psilocybe OR psilocibin) OR AB=(psilocybin OR psilocybe OR psilocibin) ) AND ( TS=(depress*) OR TS=(anxiety) OR TS=(dysthymia) OR TS=("depression and anxiety") OR TI=(depression OR depressive OR anxiety OR anxious) OR AB=(depression OR depressive OR anxiety OR anxious))) and 2022 or 2023 or 2024 or 2025 or 2026 (Publication Years) and Web of Science Core Collection (Database)
```
Refined: PY=2022-2026; Retrieved: 1,828.  y Web of Science Core Collection (Database)
LINK https://www.webofscience.com/wos/alldb/summary/4fb38d7a-7c35-4ec2-8903-4ad15ee16153-01c504d6de/relevance/1

**Scopus**
```
TITLE-ABS-KEY ( ( psilocybin OR psilocibin OR psilocybe OR "psilocybin therapy" OR "psilocybin-assisted therapy" OR "psilocybin assisted therapy" ) AND ( depress* OR dysthymi* OR anxi* OR "depressive disorder" OR "major depressive disorder" OR "treatment-resistant depression" ) ) AND ( LIMIT-TO ( DOCTYPE , "ar" ) OR LIMIT-TO ( DOCTYPE , "re" ) ) AND PUBYEAR > 2021 AND PUBYEAR < 2027
```
Retrieved: 1,045. Export: CSV, full record.

**PubMed** (bibliometric string)
```
Search: "psilocyb*"[Title/Abstract] OR (("psilocybin"[MeSH Terms] OR "psilocybe"[MeSH Terms])) AND ("depress*"[Title/Abstract] OR "anxiety*"[Title/Abstract] OR "depression"[MeSH Terms] OR "Depressive Disorder"[MeSH] OR "anxiety"[MeSH Terms] OR "Anxiety Disorders"[MeSH]) Filters: MEDLINE, from 2022 - 2027
```
Retrieved: 654. Export: CSV summary / MEDLINE.

## Meta-analytic arm (restrictive strategies; )

**PubMed**
```
 (((("psilocyb*"[Title/Abstract] OR (("psilocybin"[MeSH Terms] OR "psilocybe"[MeSH Terms]))) AND ("depress*"[Title/Abstract] OR "anxiety*"[Title/Abstract] OR "depression"[MeSH Terms] OR "Depressive Disorder"[MeSH] OR "anxiety"[MeSH Terms] OR "Anxiety Disorders"[MeSH])) AND ((randomized controlled trial[pt] OR "clinical trial, phase ii"[pt] OR "clinical trial, phase iii"[pt] OR "clinical trial, phase iv"[pt] OR randomi*[tiab]))) NOT (("systematic review"[Publication Type] OR "meta analysis"[Publication Type] OR "clinical trial, phase i"[Publication Type]))) AND ((medline[Filter]) AND (humans[Filter]) AND (2022:2026[pdat])) Filters: Humans, MEDLINE
```
102 RESULTADOS

**Cochrane CENTRAL** (Trials tab) EBM Reviews - Cochrane Central Register of Controlled Trials <May 2026> OVID

Buscar en todas las revistas de Ovid (Referencias + Abstracts + Revistas Suscritas) 143

EBM Reviews - Cochrane Central Register of Controlled Trials <July 2026> 245

APA PsycInfo <1806 to August 2026 Week 3> 287

```
((("psilocyb*".ab. or "psilocyb*".ti.) and (("depressi*".ab. or "depressi*".ti. or (depresive disorders or major depression or depression).hw.) or ("anxiety*".ab. or "anxiety*".ti. or (anxiety or Anxiety Disorders or anxious).hw.))) or ((("psilocybin" or "psilocybe") and ("depression" or "anxiety")).mh.)) not (("lsd therapy" or "ayahuasca" or "iboga" or "mdma" or "dmt" or "mescaline" or "peyote" or "dmt therapy" or "lysergic" or "lsd").kw. or ("systematic" or "meta-analysis").ti.)
```
•		limit  to yr="2022 -Current" HITS 675


**Web of Science Core Collection** (advanced search) 
```
Query #1 : ((TI=(psilocybin) OR TI=(psilocybe) OR TI=("psilocibin") OR AB=(psilocybin) OR AB=(psilocybe) OR AB=("psilocibin"))) AND (((TS=("depression and anxiety")) OR TS=(dysthymia)) OR (TI=("depression") OR TI=("depressive") OR TI=("anxiety") OR AB=("depression") OR AB=("depressive") OR AB=("anxiety")))
 
Query #2 : (((((TS=(MDMA ) OR TS=(parkinson)) OR TS=(cancer)) OR TS=(alcoholism)) OR TI=("systematic review") OR TI=(meta-analysis) OR TI=("metaanalysis")) OR DT=(Retraction OR Record Review)) OR TI=(post-traumatic stress disorder)

SEARCH: #1 NOT #2
```
Refined By: Publication Years: 2026 or 2025 or 2023 or 2024 or 2022.Document Types: Article. RESULTS: 278
https://www.webofscience.com/wos/woscc/summary/c6c6de22-2160-40ed-93e5-b5971e18b64d-01c73c5b4a/relevance/1

## Complementary search of preprints 

**medRxiv** medRxiv THE PREPRINT SERVER FOR HEALTH SCIENCES (complementary preprint source, includes medRxiv)
```
for term "psilocybin " and title "psilocybin or psilocibine or psiloc* and (depress* or anxiet* or anxious))" (match all words) and abstract or title "clinical trail" (match all words) and posted between "01 Jan, 2022 and 31 Dec, 2026"
```
"01 Jan, 2022 and 31 Dec, 2026" 135 Results


**Europe PMC** (complementary preprint source, includes medRxiv)
```
(( ( TITLE_ABS:psilocyb* OR TITLE_ABS:"psilocybin" OR TITLE_ABS:psilocybe* ) AND ( TITLE_ABS:depress* OR TITLE_ABS:anxiety OR TITLE_ABS:"depressive disorder" OR TITLE_ABS:"anxiety disorders" ) AND ( TITLE_ABS:randomi* OR TITLE_ABS:"randomized controlled trial" OR TITLE_ABS:"clinical trial" ) ) NOT ( TITLE_ABS:"systematic review" OR TITLE_ABS:"meta-analysis" ) OR ( TITLE_ABS:psilocyb* OR TITLE_ABS:psilocybe* OR TITLE_ABS:LSD OR TITLE_ABS:lysergic OR TITLE_ABS:ayahuasca OR TITLE_ABS:iboga* OR TITLE_ABS:MDMA OR TITLE_ABS:DMT OR TITLE_ABS:peyote OR TITLE_ABS:mescaline ) AND ( TITLE_ABS:depress* OR TITLE_ABS:anxiety OR TITLE_ABS:"depressive disorder" OR TITLE_ABS:"anxiety disorders" ) ) AND (SRC:PPR) AND (FIRST_PDATE:[2022 TO 2026])
```
RESULTS: 29





## Deduplication

Priority WoS > Scopus > PubMed; match by normalized DOI, then normalized title. Two retracted WoS articles excluded (10.1177/02698811241234247; 10.3389/fnins.2023.1168911). Flow numbers in `results/tables/T0_prisma_s_flow.csv`.
