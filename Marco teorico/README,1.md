# Psilocibina para los trastornos depresivos y de ansiedad (2022-2026)

Repositorio de trabajo para un estudio híbrido que combina un análisis
bibliométrico amplio con una revisión sistemática de ensayos clínicos sobre
psilocibina, depresión y ansiedad en adultos.

> **Estado al 12 de septiembre de 2026:** el brazo bibliométrico está
> documentado y cuenta con un corpus deduplicado. El brazo metaanalítico todavía se
> encuentra en proceso de cribado; aún no deben interpretarse los datos como
> evidencia metaanalítica de eficacia o seguridad.

## Manuscrito

El manuscrito actualizado se encuentra en
[`borrador y resumen.md`](./borrador%20y%20resumen.md). Incluye:

- resumen estructurado e introducción;
- objetivos y pregunta PICO(S);
- métodos conforme a PRISMA-P, PRISMA-S y PRISMA 2020;
- resultados auditables de identificación y deduplicación;
- discusión, limitaciones y conclusiones provisionales;
- disponibilidad de datos y declaraciones.

## Resultados disponibles

Las búsquedas del 5 de septiembre de 2026 produjeron el siguiente corpus
bibliométrico actualizado:

| Fuente registrada | Registros identificados | Retractados eliminados | Duplicados eliminados | Registros conservados |
| --- | ---: | ---: | ---: | ---: |
| Web of Science | 1,837 | 0 | -- | 1,837 |
| Scopus | 1,053 | 0 | -- | 1,053 |
| PubMed | 932 | 0 | -- | 932 |
| **Corpus tri-base deduplicado** | **3,822 registros-fuente** | **0** | **1,694 coincidencias** | **2,128** |

El corpus ampliado con todas las exportaciones adjuntas contiene 2,283
documentos únicos. El año 2026 es parcial. El archivo de flujo PRISMA todavía
mantiene como `NR` los conteos de
exclusiones durante el cribado, textos completos recuperados, exclusiones con
motivos y estudios clínicos incluidos.

> **Nota sobre las fuentes:** el archivo de estrategias describe Scopus para
> el brazo bibliométrico, mientras que las tablas y el pipeline disponibles
> usan la etiqueta `OVID`. La identidad exacta de esa exportación debe
> verificarse y armonizarse antes de la publicación.

## Pregunta clínica

La revisión clínica evalúa adultos de 18 a 65 años con depresión y/o ansiedad,
tratados con psilocibina sintética o procedente de hongos, con o sin
psicoterapia asistida. Se consideran placebo, tratamiento habitual,
comparadores activos y diseños pre-post elegibles.

Los resultados previstos incluyen:

- gravedad de depresión y ansiedad mediante escalas validadas;
- respuesta y remisión;
- funcionamiento y calidad de vida;
- eventos adversos, tolerabilidad y abandonos.

Se excluyen, entre otros, estudios en animales, participantes sanos, fase 1,
cuidados paliativos, cáncer, Parkinson, demencia y combinaciones con otros
psicodélicos cuando no sea posible aislar el efecto de la psilocibina.

## Registro y documentación metodológica

- **Registro:** PROSPERO `CRD420261493650`, registrado el 2 de septiembre de
  2026, versión 1.2.
- **Fecha documentada de búsqueda:** 5 de septiembre de 2026.
- **Fuentes bibliométricas:** Web of Science Core Collection, Scopus y PubMed.
- **Fuentes metaanalíticas:** Web of Science Core Collection, PubMed, bases
  de Ovid, Cochrane CENTRAL y APA PsycInfo, complementadas con Europe PMC y
  medRxiv.
- **Estrategias completas:** [`search_strategies.md`](./search_strategies.md).
- **Pipeline de deduplicación:**
  [`scripts/01_deduplication_pipeline.py`](./scripts/01_deduplication_pipeline.py).

La deduplicación prioriza Web of Science sobre Ovid/Scopus y PubMed, mediante
DOI normalizado y, cuando no existe DOI, título normalizado.

## Datos y resultados reproducibles

- [`data/corpus_unique_tridatabase.csv`](./data/corpus_unique_tridatabase.csv):
  corpus único derivado.
- [`data/prisma_2020_source_counts.csv`](./data/prisma_2020_source_counts.csv):
  conteos por fuente.
- [`data/prisma_2020_flow_counts.csv`](./data/prisma_2020_flow_counts.csv):
  flujo PRISMA disponible.
- [`data/pandas_corpus_report.csv`](./data/pandas_corpus_report.csv):
  cobertura de títulos, DOI y años.
- [`data/pandas_year_report.csv`](./data/pandas_year_report.csv):
  registros por año y fuente.
- [`results/vosviewer_dual`](../results/vosviewer_dual):
  análisis actualizado con búsquedas del 5 de septiembre de 2026. Incluye el
  corpus tri-base WoS–Scopus–PubMed y el corpus ampliado con todas las fuentes
  adjuntas, además de archivos de red compatibles con VOSviewer.

El pipeline se ejecutó con Python 3.12 y pandas. Los análisis bibliométricos
adicionales pueden reproducirse con R y bibliometrix. Las exportaciones
completas de Web of Science, Scopus y PubMed no se redistribuyen cuando las
licencias de las bases lo impiden.

## Hallazgos bibliométricos descriptivos

El análisis actualizado contiene 2,128 documentos únicos en el corpus
WoS–Scopus–PubMed y 2,283 en el corpus ampliado. En el corpus tri-base, la
producción anual fue de 288 documentos en 2022, 398 en 2023, 415 en 2024, 573
en 2025 y 454 en 2026. El análisis previo de 11 de agosto queda como versión
histórica y no debe mezclarse con estos conteos.

Estos hallazgos describen la literatura recuperada y no equivalen a una
estimación del efecto terapéutico de la psilocibina.

## Zenodo y citación

La sección bibliométrica se identifica en el proyecto con el DOI
`10.5281/zenodo.21893380`. Los metadatos de versión también consignan
`10.5281/zenodo.22655408`; esta discrepancia debe resolverse antes de fijar la
citación definitiva.

La información de citación adicional está en [`citation.cff`](./citation.cff).
El código se distribuye bajo MIT y los documentos y datos derivados bajo
CC-BY 4.0, conforme a la documentación del proyecto.
