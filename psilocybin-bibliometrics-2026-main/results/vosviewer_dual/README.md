# Análisis bibliométrico actualizado: búsquedas del 5 de septiembre de 2026

Este directorio sustituye como análisis principal al corpus bibliométrico
histórico generado con búsquedas del 11 de agosto de 2026.

## Escenarios

| Escenario | Documentos únicos | Descripción |
| --- | ---: | --- |
| `01_core_WOS_Scopus_PubMed` | 2,128 | Web of Science Core Collection, Scopus y PubMed |
| `02_all_attached_databases` | 2,283 | Todas las exportaciones adjuntas, incluidas Ovid y archivos RIS complementarios |

El corpus tri-base contiene 3,822 registros-fuente antes de la deduplicación
entre fuentes. La deduplicación utiliza DOI normalizado y, en ausencia de DOI,
título normalizado. Los registros retractados declarados en el pipeline se
excluyen antes del análisis.

## Archivos de VOSviewer

Cada escenario contiene redes de:

- `author_keywords_network.net`: coocurrencia de palabras clave;
- `authors_network.net`: coautoría;
- `countries_network.net`: colaboración entre países;
- archivos `*_map.txt`: nodos y pesos;
- archivos `*_top.csv`: frecuencias de los nodos;
- `corpus_deduplicated.csv`: corpus analítico;
- `annual_production.csv`: producción anual;
- `source_counts.csv`: conteo por fuente.

En VOSviewer se debe elegir **Create a map based on network data** y cargar el
archivo `.net` correspondiente.
