# Replication of the bibliometric arm in R/bibliometrix
# Psilocybin and depression/anxiety, 2022-2026 (Web of Science Core Collection analytical corpus)
# Requires: raw/savedrecs.txt (Web of Science Core Collection Plain Text export, full record with cited references)

library(bibliometrix)
library(dplyr)

RETRACTED <- c("10.1177/02698811241234247", "10.3389/FNINS.2023.1168911")

M <- convert2df("raw/savedrecs.txt", dbsource = "wos", format = "plaintext")
M <- M %>% dplyr::filter(!(DI %in% RETRACTED))

res <- biblioAnalysis(M)
S <- summary(res, k = 20, pause = FALSE)

# Annual production and growth
prod <- as.data.frame(table(M$PY))
write.csv(prod, "results/tables/R_annual_production.csv", row.names = FALSE)

# Keyword co-occurrence network (author keywords, cleaned)
remove_terms <- c("PSILOCYBIN", "PSYCHEDELICS", "PSYCHEDELIC", "DEPRESSION", "ANXIETY")
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "author_keywords", sep = ";")
net <- networkPlot(NetMatrix, normalize = "association", n = 50,
                   Title = "Author keyword co-occurrence", type = "fruchterman",
                   remove.isolates = TRUE, labelsize = 0.7, edges.min = 3)

# Thematic map
Map <- thematicMap(M, field = "DE", n = 250, minfreq = 5, stemming = FALSE,
                   size = 0.5, n.labels = 3, repel = TRUE)
plot(Map$map)

# Country collaboration
M <- metaTagExtraction(M, Field = "AU_CO", sep = ";")
NetCo <- biblioNetwork(M, analysis = "collaboration", network = "countries", sep = ";")
networkPlot(NetCo, n = 25, Title = "Country collaboration", type = "circle", labelsize = 0.8)

# Export for VOSviewer (co-citation uses the CR field of the Plain Text export)
# In VOSviewer: Create > map based on bibliographic data > read Web of Science Core Collection file raw/savedrecs.txt
