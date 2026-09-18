# Capítulo II. Marco teórico

El marco teórico está organizado como un capítulo de tesis y dividido en
archivos para facilitar la revisión, edición y ensamblaje:

1. `00_introduccion.md`
2. `01_fundamentos_conceptuales.md`
3. `02_bases_farmacologicas.md`
4. `03_evidencia_clinica.md`
5. `06_antecedentes_historicos.md`
6. `07_legislacion_y_regulacion.md`
7. `04_contexto_psicoterapeutico_regulatorio.md`
8. `05_integracion_metodologica.md`
9. `08_sintesis_capitular.md`

Las citas usan la sintaxis de Pandoc (`[@clave]`) y las claves se encuentran
en [`../ref.bib`](../ref.bib). La bibliografía fue consolidada a partir de las
exportaciones RIS de Zotero ubicadas en:

`../../.psilo/PRISMA_2020_unified_publication/references/zotero/`

## Ensamblaje con Pandoc

Desde la carpeta `1 Planeación`, ejecutar:

```powershell
pandoc "Marco teorico\00_introduccion.md" `
  "Marco teorico\01_fundamentos_conceptuales.md" `
  "Marco teorico\02_bases_farmacologicas.md" `
  "Marco teorico\03_evidencia_clinica.md" `
  "Marco teorico\04_contexto_psicoterapeutico_regulatorio.md" `
  "Marco teorico\06_antecedentes_historicos.md" `
  "Marco teorico\07_legislacion_y_regulacion.md" `
  "Marco teorico\05_integracion_metodologica.md" `
  "Marco teorico\08_sintesis_capitular.md" `
  --from markdown `
  --citeproc `
  --bibliography "ref.bib" `
  --csl "sage-vancouver-brackets.csl" `
  --metadata reference-section-title="Referencias" `
  -o "Marco teorico\marco_teorico.docx"
```

El archivo `sage-vancouver-brackets.csl` produce citas numéricas entre
corchetes, por ejemplo `[1]` o `[2,3]`, y organiza la lista final de
referencias conforme al estilo SAGE Vancouver. Para que una fuente aparezca
en la lista final debe estar citada en el texto con su clave BibTeX, por
ejemplo `[@goodwin2022]`.

También puede generarse una versión PDF o HTML:

```powershell
pandoc "Marco teorico\00_introduccion.md" `
  "Marco teorico\01_fundamentos_conceptuales.md" `
  "Marco teorico\02_bases_farmacologicas.md" `
  "Marco teorico\03_evidencia_clinica.md" `
  "Marco teorico\04_contexto_psicoterapeutico_regulatorio.md" `
  "Marco teorico\06_antecedentes_historicos.md" `
  "Marco teorico\07_legislacion_y_regulacion.md" `
  "Marco teorico\05_integracion_metodologica.md" `
  "Marco teorico\08_sintesis_capitular.md" `
  --from markdown `
  --citeproc `
  --bibliography "ref.bib" `
  --csl "sage-vancouver-brackets.csl" `
  --metadata reference-section-title="Referencias" `
  -o "Marco teorico\marco_teorico.html"
```

Las referencias deben verificarse en Zotero antes del envío: algunas
exportaciones RIS contienen registros incompletos o duplicados, y el artículo
de 2026 debe considerarse evidencia reciente sujeta a actualización.
