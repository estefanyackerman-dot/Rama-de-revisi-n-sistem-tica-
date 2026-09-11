# =====================================================================
# REVISION DE TITULO NORMALIZADO Y ABSTRACT
# Psilocibina y depresion/ansiedad, 2022-2026
# Repositorio: psilocybin-bibliometrics-2026
#
# Proposito: para cada registro del corpus unico
# (corpus_unique_tridatabase.csv) localizar su registro crudo de origen
# (WoS, PubMed u Ovid) y revisar:
#   1. Cobertura de abstract (AB): faltantes, vacios, muy cortos
#   2. Calidad de la normalizacion de titulo: vacios, muy cortos,
#      caracteres no alfanumericos residuales, encoding sospechoso
#   3. Duplicados y casi-duplicados de titulo normalizado dentro del
#      corpus unico (senal de que la deduplicacion pudo fallar)
#   4. Discrepancia entre el titulo del corpus y el titulo del crudo
#      emparejado (mala atribucion doi/title_n)
#
# El script NO modifica corpus_unique_tridatabase.csv; solo genera
# reportes en results/review/ para que cada hallazgo se declare o se
# corrija manualmente.
#
# ENTRADA: al ejecutar se abre un selector de archivos, en este orden:
#   1) Corpus unico: corpus_unique_tridatabase.csv
#   2) WoS: Plain Text, full record con cited references (multi-archivo)
#   3) PubMed: formato MEDLINE (.txt o .nbib)
#   4) Ovid: exportacion RIS (.ris o .txt)
# Si una base no aplica, presionar Cancelar en su ventana.
# =====================================================================

# ---- 0. Paquetes ------------------------------------------------------
paquetes <- c("bibliometrix", "dplyr", "stringr", "readr", "stringdist")
faltan <- paquetes[!paquetes %in% rownames(installed.packages())]
if (length(faltan) > 0) install.packages(faltan)
invisible(lapply(paquetes, library, character.only = TRUE))
cat("Directorio de trabajo (aqui se guardaran los resultados):", getwd(), "\n")

seleccionar <- function(mensaje, multi = FALSE) {
  cat(">>", mensaje, "(Cancelar para omitir)\n")
  archivos <- tryCatch({
    if (.Platform$OS.type == "windows") {
      utils::choose.files(caption = mensaje, multi = multi)
    } else if (requireNamespace("tcltk", quietly = TRUE)) {
      tcltk::tk_choose.files(caption = mensaje, multi = multi)
    } else {
      file.choose()
    }
  }, error = function(e) character(0))
  archivos <- archivos[nzchar(archivos)]
  if (length(archivos) == 0) cat("   (omitido)\n") else
    cat("   Seleccionado:", paste(basename(archivos), collapse = ", "), "\n")
  archivos
}

# Uso directo de los archivos entregados para esta revisión.
# Rutas relativas al directorio de trabajo del repositorio, para evitar
# dependencias de una ruta absoluta de usuario/maquina.
ARCH_CORPUS <- file.path("data", "corpus_unique_tridatabase.csv")
ARCH_WOS    <- character(0)
ARCH_PUBMED <- file.path("csv-psilocybTi-set.csv")
ARCH_OVID   <- file.path("savedrecs (3).ris")

if (!file.exists(ARCH_CORPUS)) {
  stop("Se requiere corpus_unique_tridatabase.csv para continuar. Se esperaba en:",
       ARCH_CORPUS)
}

dir.create("results/review", recursive = TRUE, showWarnings = FALSE)

# ---- 1. Normalizacion (idéntica al script de verificacion) ----------
norm_doi <- function(x) {
  x <- tolower(trimws(as.character(x)))
  x <- gsub("^https?://(dx\\.)?doi\\.org/", "", x)
  x <- gsub("^doi:\\s*", "", x)
  x[x %in% c("", "na", "null")] <- NA_character_
  x
}
norm_title <- function(x) {
  x <- tolower(as.character(x))
  x <- gsub("[^a-z0-9]+", " ", x)
  x <- gsub("\\s+", " ", trimws(x))
  x[x == ""] <- NA_character_
  x
}

# ---- 2. Lectura de crudos con titulo + abstract ----------------------
leer_wos <- function() {
  if (length(ARCH_WOS) == 0) return(NULL)
  M <- convert2df(ARCH_WOS, dbsource = "wos", format = "plaintext")
  data.frame(source = "WOS", title = M$TI,
             abstract = if ("AB" %in% names(M)) M$AB else NA_character_,
             doi = norm_doi(M$DI), stringsAsFactors = FALSE)
}
leer_pubmed <- function() {
  if (length(ARCH_PUBMED) == 0 || !file.exists(ARCH_PUBMED)) return(NULL)
  M <- tryCatch(read.csv(ARCH_PUBMED, stringsAsFactors = FALSE, check.names = FALSE),
                error = function(e) NULL)
  if (is.null(M) || nrow(M) == 0) return(NULL)
  fields <- names(M)
  data.frame(source = "PUBMED",
             title = if ("Title" %in% fields) M$Title else NA_character_,
             abstract = if ("Abstract" %in% fields) M$Abstract else NA_character_,
             doi = norm_doi(if ("DOI" %in% fields) M$DOI else NA_character_),
             stringsAsFactors = FALSE)
}
leer_ovid <- function() {
  if (length(ARCH_OVID) == 0 || !file.exists(ARCH_OVID)) return(NULL)
  lineas <- readLines(ARCH_OVID, warn = FALSE, encoding = "UTF-8")
  registros <- split(lineas, cumsum(grepl("^TY\\s+-", lineas)))
  registros <- registros[names(registros) != "0"]
  extraer <- function(reg, tags) {
    for (tg in tags) {
      hit <- grep(paste0("^", tg, "\\s+-\\s*"), reg, value = TRUE)
      if (length(hit) > 0) {
        idx <- which(grepl(paste0("^", tg, "\\s+-\\s*"), reg))[1]
        valor <- sub(paste0("^", tg, "\\s+-\\s*"), "", reg[idx])
        # Ovid puede partir abstracts largos en varias lineas "AB  - ..."
        # continuas sin nueva etiqueta; se concatenan lineas siguientes
        # que no comienzan con "XX  - "
        j <- idx + 1
        while (j <= length(reg) && !grepl("^[A-Z0-9]{2}\\s+-\\s*", reg[j])) {
          valor <- paste(valor, trimws(reg[j]))
          j <- j + 1
        }
        return(trimws(valor))
      }
    }
    NA_character_
  }
  out <- lapply(registros, function(r) data.frame(
    source   = "OVID",
    title    = extraer(r, c("TI", "T1")),
    abstract = extraer(r, c("AB", "N2")),
    doi      = norm_doi(extraer(r, c("DO", "DI"))),
    stringsAsFactors = FALSE))
  do.call(rbind, out)
}

# ---- 2b. Prioridad de fuente para el emparejamiento de registros crudos
# Regla: en caso de conflicto entre bases, se conserva primero el registro
# de Ovid, luego WOS y finalmente PubMed.
fuente_prioridad <- c("OVID" = 1, "WOS" = 2, "PUBMED" = 3)

crudo <- bind_rows(leer_wos(), leer_pubmed(), leer_ovid()) %>%
  mutate(
    title_n = norm_title(title),
    title = ifelse(is.na(title) | trimws(title) == "", NA_character_, title),
    abstract = ifelse(is.na(abstract) | trimws(abstract) == "", NA_character_, abstract),
    prioridad = ifelse(source %in% names(fuente_prioridad),
                       fuente_prioridad[source], NA_integer_)
  ) %>%
  arrange(prioridad, title_n)

if (nrow(crudo) == 0) stop("No se leyo ningun crudo; no hay abstract con que cruzar.")

# ante duplicados de doi/title_n en los crudos (antes de deduplicar),
# se toma el primer registro con prioridad de fuente para el cruce;
# el script de verificacion es la fuente de verdad para la deduplicacion
crudo_por_doi <- crudo %>%
  distinct(doi, .keep_all = TRUE)

crudo_por_titulo <- crudo %>% distinct(title_n, .keep_all = TRUE)

cat("Crudos leidos con abstract:", nrow(crudo), "registros\n")

# ---- 3. Corpus unico + normalizacion de titulo -----------------------
tri <- read_csv(ARCH_CORPUS, show_col_types = FALSE) %>%
  mutate(doi = norm_doi(doi), title_n = norm_title(title), fila = row_number())
if ("abstract" %in% names(tri)) {
  tri <- tri %>% mutate(abstract_corpus = abstract) %>% select(-abstract)
}

# ---- 4. Emparejamiento con crudo: DOI primero, titulo despues --------
por_doi <- tri %>% filter(!is.na(doi)) %>%
  left_join(crudo_por_doi %>% select(doi, title_crudo = title, abstract, source_crudo = source),
            by = "doi") %>%
  mutate(match_por = ifelse(!is.na(abstract), "doi", NA_character_))

sin_doi <- tri %>% filter(is.na(doi)) %>%
  left_join(crudo_por_titulo %>% select(title_n, title_crudo = title, abstract, source_crudo = source),
            by = "title_n") %>%
  mutate(match_por = ifelse(!is.na(abstract), "title_n", NA_character_))

emparejado <- bind_rows(por_doi, sin_doi) %>% arrange(fila)

cat(sprintf("Emparejados con crudo: %d de %d (%d por DOI, %d por titulo, %d sin match)\n",
            sum(!is.na(emparejado$abstract)), nrow(emparejado),
            sum(emparejado$match_por == "doi", na.rm = TRUE),
            sum(emparejado$match_por == "title_n", na.rm = TRUE),
            sum(is.na(emparejado$match_por))))

# ---- 5. Revision 1: cobertura de abstract ----------------------------
rev_abstract <- emparejado %>%
  mutate(
    estado_abstract = case_when(
      is.na(match_por)                         ~ "sin_crudo_emparejado",
      is.na(abstract) | trimws(abstract) == ""  ~ "abstract_vacio",
      nchar(trimws(abstract)) < 200              ~ "abstract_muy_corto",
      TRUE                                       ~ "ok"
    ),
    n_car_abstract = nchar(trimws(abstract))
  )
write.csv(rev_abstract %>% filter(estado_abstract != "ok") %>%
            select(source, title, year, doi, match_por, estado_abstract, n_car_abstract,
                   abstract, abstract_corpus),
          "results/review/R1_cobertura_abstract.csv", row.names = FALSE)
print(count(rev_abstract, estado_abstract))

# ---- 6. Revision 2: calidad de titulo normalizado --------------------
rev_titulo <- tri %>%
  mutate(
    n_car_titulo = nchar(title),
    problema_titulo = case_when(
      is.na(title_n)                                   ~ "titulo_normalizado_vacio",
      nchar(title_n) < 8                                ~ "titulo_normalizado_muy_corto",
      grepl("[^\\x00-\\x7F]", title)                     ~ "caracter_no_ascii_en_titulo_original",
      grepl("^\\s|\\s$", title)                          ~ "espacios_al_inicio_o_final",
      TRUE                                               ~ "ok"
    )
  )
write.csv(rev_titulo %>% filter(problema_titulo != "ok") %>%
            select(source, title, title_n, year, doi, problema_titulo, n_car_titulo),
          "results/review/R2_calidad_titulo.csv", row.names = FALSE)
print(count(rev_titulo, problema_titulo))

# ---- 7. Revision 3: duplicados y casi-duplicados de titulo_n --------
dup_exactos <- tri %>% filter(!is.na(title_n)) %>%
  add_count(title_n, name = "n_repeticiones") %>%
  filter(n_repeticiones > 1) %>%
  arrange(title_n)
write.csv(dup_exactos %>% select(source, title, title_n, year, doi, n_repeticiones),
          "results/review/R3_titulo_normalizado_duplicado_exacto.csv", row.names = FALSE)
cat("Titulos normalizados EXACTAMENTE duplicados en el corpus unico:",
    n_distinct(dup_exactos$title_n), "grupos /", nrow(dup_exactos), "registros\n")
cat("(si el corpus ya fue deduplicado, este numero debe ser 0; si no lo es,\n")
cat(" declarar por que sobrevivieron al paso 2 de deduplicacion)\n")

# Casi-duplicados: distancia de Levenshtein normalizada muy baja entre
# titulos distintos (umbral conservador; solo para revision manual,
# NO se elimina nada automaticamente)
titulos_unicos <- tri %>% filter(!is.na(title_n)) %>% distinct(title_n, .keep_all = TRUE)
if (nrow(titulos_unicos) > 1 && nrow(titulos_unicos) <= 4000) {
  d <- stringdistmatrix(titulos_unicos$title_n, titulos_unicos$title_n,
                         method = "lv", useNames = "strings")
  d[lower.tri(d, diag = TRUE)] <- NA
  pares <- which(!is.na(d), arr.ind = TRUE)
  if (nrow(pares) > 0) {
    casi_dup <- data.frame(
      titulo_1 = titulos_unicos$title[pares[, 1]],
      titulo_2 = titulos_unicos$title[pares[, 2]],
      doi_1    = titulos_unicos$doi[pares[, 1]],
      doi_2    = titulos_unicos$doi[pares[, 2]],
      distancia_levenshtein = d[pares],
      largo_min = pmin(nchar(titulos_unicos$title_n[pares[, 1]]),
                        nchar(titulos_unicos$title_n[pares[, 2]]))) %>%
      mutate(distancia_relativa = distancia_levenshtein / largo_min) %>%
      # umbral: <=3 caracteres de diferencia O <=5% de diferencia relativa
      filter(distancia_levenshtein <= 3 | distancia_relativa <= 0.05) %>%
      arrange(distancia_relativa)
    write.csv(casi_dup, "results/review/R3b_titulo_normalizado_casi_duplicado.csv",
              row.names = FALSE)
    cat("Pares de titulos CASI-duplicados (revision manual, umbral <=3 car. o <=5%):",
        nrow(casi_dup), "\n")
  } else {
    cat("No se encontraron pares casi-duplicados por debajo del umbral.\n")
  }
} else if (nrow(titulos_unicos) > 4000) {
  cat("AVISO: corpus con mas de 4000 titulos unicos; se omite la matriz de\n")
  cat("distancias completa por costo computacional (revisar R3 y ejecutar\n")
  cat("la comparacion de casi-duplicados en bloques si se requiere).\n")
}

# ---- 8. Revision 4: discrepancia titulo corpus vs. titulo crudo -----
# Cuando el emparejamiento fue por DOI, el titulo del crudo deberia ser
# practicamente igual al del corpus; una gran distancia sugiere DOI mal
# escrito, version distinta del articulo (corrigendum/preprint) o
# atribucion incorrecta.
rev_discrepancia <- emparejado %>%
  filter(match_por == "doi", !is.na(title_crudo)) %>%
  mutate(
    title_n_crudo = norm_title(title_crudo),
    dist = mapply(function(a, b) if (is.na(a) || is.na(b)) NA_integer_
                   else stringdist(a, b, method = "lv"), title_n, title_n_crudo),
    largo_min = pmin(nchar(title_n), nchar(title_n_crudo)),
    dist_relativa = dist / largo_min
  ) %>%
  filter(dist_relativa > 0.15) %>%
  select(source, title_corpus = title, title_crudo, doi, dist, dist_relativa) %>%
  arrange(desc(dist_relativa))
write.csv(rev_discrepancia, "results/review/R4_discrepancia_titulo_corpus_vs_crudo.csv",
          row.names = FALSE)
cat("Registros con titulo del corpus MUY distinto del titulo del crudo\n")
cat("emparejado por el mismo DOI (posible mala atribucion):", nrow(rev_discrepancia), "\n")

cat("\nListo. Revisar results/review/ (R1 a R4). Ninguna fila reportada debe\n")
cat("quedar sin declarar o corregir antes de dar el corpus por verificado.\n")
