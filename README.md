# Psilocybin for Depressive and Anxiety Disorders (2022–2026): Hybrid Bibliometric Analysis and Systematic Review 

Randomized controlled trials focus on working-age outpatients. This repository documents the progress of the systematic review. The complete bibliometric section—including search documentation, deduplication process, derived corpus, tables, and figures—is available on Zenodo: https://doi.org/10.5281/zenodo.21893380 

CITATION: Aranda-Rosas, A. E., Lozano-Garcia, L. J., Martinez-Robles, S., Gonzalez-Ballesteros, E., & Trejo-Rodriguez, M. A. (2026). Psilocybin for depressive and anxiety disorders (2022–2026): bibliometric arm of a hybrid bibliometric and meta-analytic study (Version v1.00) [Computer software]. Zenodo

**Companion protocol:** `/workspaces/SIST.REV.BIBLIOMETRICO/docs/2 Protocolo/PROTOCOL 2.0.docx` (PRISMA-P structure, PRISMA-S search documentation). The meta-analysis component is registered in PROSPERO [CRD420261493650] on September 2, 2026, at 00:44 UTC, version 1.2, and the file is available in this same repository. 

## Search summary 

All searches conducted on September 5, 2026, will be updated in two months; a strategy for WOS has also been added. The protocol and the files in this repository include searches for preprints in **medRxiv** and **Europe PMC** .

Duplication prioritization: WOS > Scopus > PubMed; matches are first sought by normalized DOI and then by normalized title. 

Full search strategies for every database are in `/workspaces/SIST.REV.BIBLIOMETRICO/docs/search_strategies.md` and in the protocol.

## Repository structure

```
SIST.REV.BIBLIOMETRICO-main
    │   CITATION.cff
    │   LICENSE
    │   README.md
    │
    ├───data
    │   ├───processed
    │   │       tridata
    │   │
    │   └───raw
    │       │   ris
    │       │
    │       └───3 Estrategia de búsqueda
    │           │   search_strategies.md
    │           │
    │           ├───Bibliometric arm
    │           │       pubmed.csv-psilocybTi-set.csv
    │           │       savedrecs (1) WOS 5SEPT.ris
    │           │       savedrecs (2) WOS 5SEPT.ris
    │           │
    │           └───SYST.REV
    │                   csv-psilocybTi-set.csv
    │                   ris (3).ris
    │
    ├───docs
    │   │   datos
    │   │   search_strategies.md
    │   │
    │   ├───1 Planeación
    │   │       PROTOCOLO PSILO-FIRMADO.pdf
    │   │
    │   └───2 Protocolo
    │           prospero 3108.pdf
    │           PROTOCOL 2.0.docx
    │           Protocol_Psilocybin_Depression_Anxiety_v2.0 - Spanish (Mexico).docx
    │
    ├───results
    │   └───EVIDENCIAS
    │       ├───10 Revisión final
    │       │       CALENDARIO 4 SEPT .png
    │       │       CHEK
    │       │       LINK PARA EL CHEKLIST
    │       │
    │       ├───4 Búsqueda bibliográfica
    │       │       aarchivosdenusquedas
    │       │
    │       ├───5 Selección de estudios
    │       │       plantillas
    │       │
    │       ├───6 Extracción de datos
    │       │       DIAGRAMA DE FLUJO PRISMA 2020
    │       │
    │       ├───7 Evaluación de calidad
    │       │       intro final
    │       │       metodologia
    │       │
    │       ├───8 Síntesis
    │       │       resultados
    │       │
    │       └───9 Redacción
    │               borrador y resumen
    │
    └───scripts
            scripts de R o Python para limpiar datos, eliminar duplicados o generar gráficos
```
## Raw database exports

Raw exports from Web of Science, Scopus, and PubMed are not redistributed in this repository because their licenses do not permit the public redistribution of the complete records. They are fully reproducible by following the documented strategies and dates, and are available through the corresponding author for verification; a command was executed to hide these files and continue with the planned workflow. 

## Key Descriptive Findings from the Bibliometric Analysis

Annual production grew at a compound rate of 27.3 percent (2022 to 2025); 2026 is partial at the search date. Leading countries: USA, United Kingdom, Canada, Australia, Switzerland. The most frequent non-generic author keywords (lsd, ketamine, mdma, psychedelic-assisted therapy, psychotherapy) locate the corpus within the comparative psychedelic therapeutics literature.

## Reproducibility

Python 3.12 with pandas and matplotlib for the executed pipeline; R (>= 4.3) with bibliometrix for replication and network analyses. See scripts for details.
Excel and Zotero were used for the systematic review.

## License and citation

Code under MIT license; documents and derived data under CC-BY 4.0. Cite using `CITATION.cff` or the Zenodo DOI of this deposit.
