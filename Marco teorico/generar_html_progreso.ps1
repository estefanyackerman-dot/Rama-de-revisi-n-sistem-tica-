<#
.SYNOPSIS
    Regenera plantillla_academica.html a partir de PLANTILLA ACADEMICA.md
    e inyecta el panel lateral de progreso del manuscrito.

.DESCRIPTION
    1) Ejecuta Pandoc sobre "PLANTILLA ACADEMICA.md" usando el bib/csl reales
       del proyecto (1 Planeación/ref.bib y sage-vancouver-brackets.csl) y el
       CSS de diseño (estilo_plantilla.css).
    2) Inyecta el <aside class="progress-sidebar"> con el estado de cada
       sección (editar el arreglo $Secciones abajo para actualizar estados).
    3) Envuelve el contenido en <div class="layout"> / <div class="content">.

.USO
    Ejecutar desde PowerShell, estando en cualquier carpeta:
        .\generar_html_progreso.ps1

    Editar el arreglo $Secciones para cambiar el estado (done/partial/pending)
    y las etiquetas de "pendiente" conforme avance el manuscrito.
#>

$ErrorActionPreference = "Stop"

$Carpeta   = Split-Path -Parent $MyInvocation.MyCommand.Path
$MdFuente  = Join-Path $Carpeta "PLANTILLA ACADEMICA.md"
$HtmlSalida = Join-Path $Carpeta "plantillla_academica.html"
$Bib       = Join-Path (Split-Path -Parent $Carpeta) "ref.bib"
$Csl       = Join-Path (Split-Path -Parent $Carpeta) "sage-vancouver-brackets.csl"
$Css       = "estilo_plantilla.css"

# --- 1) Definición del estado de cada sección (editar aquí cuando avance el manuscrito) ---
# estado: done | partial | pending
$Secciones = @(
    @{ id = "resumen";                                   texto = "Resumen";                        estado = "done" },
    @{ id = "introducción";                              texto = "1. Introducción";                 estado = "done" },
    @{ id = "marco-teórico";                             texto = "2. Marco teórico";                estado = "done" },
    @{ id = "pregunta-de-investigación";                 texto = "3. Pregunta de investigación";     estado = "done" },
    @{ id = "objetivos";                                 texto = "4. Objetivos";                     estado = "done" },
    @{ id = "métodos";                                   texto = "5. Métodos";                       estado = "partial"; badge = "Redes bibliométricas pendientes" },
    @{ id = "resultados";                                texto = "6. Resultados";                    estado = "partial"; badge = "Cribado clínico pendiente" },
    @{ id = "discusión";                                 texto = "7. Discusión";                     estado = "partial" },
    @{ id = "limitaciones";                              texto = "8. Limitaciones";                  estado = "done" },
    @{ id = "conclusiones";                              texto = "9. Conclusiones";                  estado = "partial" },
    @{ id = "disponibilidad-de-datos-y-materiales";      texto = "10. Disponibilidad de datos";      estado = "partial" },
    @{ id = "declaraciones";                             texto = "11. Declaraciones";                estado = "partial" },
    @{ id = "referencias";                               texto = "Referencias";                       estado = "done" }
)

# --- 2) Generar el HTML base con Pandoc ---
Write-Host "Generando HTML con Pandoc..." -ForegroundColor Cyan
& pandoc $MdFuente `
    --from=markdown+yaml_metadata_block `
    --to=html5 `
    --standalone `
    --toc --toc-depth=3 `
    --citeproc `
    --bibliography=$Bib `
    --csl=$Csl `
    --css=$Css `
    --metadata lang=es-MX `
    -o $HtmlSalida

if ($LASTEXITCODE -ne 0) {
    throw "Pandoc falló con código de salida $LASTEXITCODE"
}

# --- 3) Construir el HTML del sidebar de progreso ---
$done    = @($Secciones | Where-Object { $_.estado -eq "done" }).Count
$partial = @($Secciones | Where-Object { $_.estado -eq "partial" }).Count
$pending = @($Secciones | Where-Object { $_.estado -eq "pending" }).Count
$total   = $Secciones.Count
$pct     = [math]::Round((($done + 0.5 * $partial) / $total) * 100)

$items = ($Secciones | ForEach-Object {
    $badge = if ($_.badge) { "`n    <span class=`"badge-pending`">$($_.badge)</span>" } else { "" }
    "    <li><span class=`"status-dot $($_.estado)`"></span><a href=`"#$($_.id)`">$($_.texto)$badge</a></li>"
}) -join "`n"

$sidebar = @"
<div class="layout">
<aside class="progress-sidebar">
  <h2>Progreso de la plantilla</h2>
  <p class="subtitle">Estado por sección · actualizado $(Get-Date -Format 'yyyy-MM-dd')</p>

  <div class="progress-summary">
    <div class="progress-chip done"><span class="num">$done</span>completas</div>
    <div class="progress-chip partial"><span class="num">$partial</span>parciales</div>
    <div class="progress-chip pending"><span class="num">$pending</span>pendiente(s)</div>
  </div>

  <div class="progress-bar-track">
    <div class="progress-bar-fill" style="width: $pct%;"></div>
  </div>

  <ul class="progress-list">
$items
  </ul>

  <div class="legend">
    <div><span class="status-dot done"></span> Completa</div>
    <div><span class="status-dot partial"></span> Parcial / en curso</div>
    <div><span class="status-dot pending"></span> Pendiente</div>
  </div>
</aside>
<div class="content">
<header id="title-block-header">
"@

# --- 4) Inyectar sidebar tras <body> y cerrar el layout antes de </body> ---
$html = Get-Content $HtmlSalida -Raw
$patronApertura = [regex]::Escape("<body>") + '\s*' + [regex]::Escape('<header id="title-block-header">')
$patronCierre   = [regex]::Escape("</div>") + '\s*' + [regex]::Escape("</body>") + '\s*' + [regex]::Escape("</html>")

if ($html -notmatch $patronApertura) {
    throw "No se encontró el patrón de apertura <body><header...> en el HTML generado. Revisa la salida de Pandoc."
}
if ($html -notmatch $patronCierre) {
    throw "No se encontró el patrón de cierre </div></body></html> en el HTML generado. Revisa la salida de Pandoc."
}

$html = [regex]::Replace($html, $patronApertura, { param($m) $sidebar })
$html = [regex]::Replace($html, $patronCierre, { param($m) "</div>`r`n</div>`r`n</div>`r`n</body>`r`n</html>" })

Set-Content -Path $HtmlSalida -Value $html -Encoding UTF8 -NoNewline

Write-Host "HTML de progreso generado en: $HtmlSalida" -ForegroundColor Green
