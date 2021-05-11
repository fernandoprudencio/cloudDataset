rm(list = ls())

library(tidyverse)

cloud38 <- readRDS("data/rds/38-cloud.rds")
cloud95 <- readRDS("data/rds/95-cloud.rds")
cloudBaeten <- readRDS("data/rds/BaetensHagolle.rds")
cloudBiome8 <- readRDS("data/rds/biome8.rds")
cloudCatalog <- readRDS("data/rds/cloudCatalog.rds")
cloudHollstein <- readRDS("data/rds/s2_hollstein.rds")
cloudSparcs <- readRDS("data/rds/sparcs.rds")
cloudIrish <- readRDS("data/rds/irish.rds")

df <- cloudIrish
mutate_all(df, ~replace(., is.na(.), 0)) %>%
  dplyr::select(-id) %>%
  apply(MARGIN = 2, FUN = function(x) sum(x, na.rm = T))
