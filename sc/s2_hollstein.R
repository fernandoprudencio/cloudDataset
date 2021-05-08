#' @author  Fernando Prudencio

rm(list = ls())

library(reticulate)
library(tidyverse)
library(raster)
library(janitor)
library(magrittr)
library(rhdf5)

# install.packages("BiocManager")
# BiocManager::install("rhdf5")

# Load dataset
dataset <- h5dump("data/s2_hollstein/20170710_s2_manual_classification_data.h5")

# Build table
df <-
  t(
    table(dataset$classes) %>% as.matrix()
  ) %>%
  as_tibble() %>%
  "names<-"(
    c(
      "cloud", "cirrus", "snow",
      "shadow", "water", "clear_sky"
    )
  ) %>%
  mutate(
    total_pixels =
      rowSums(
        across(where(is.numeric)),
        na.rm = T
      )
  )

# Save table ----
saveRDS(
  mutate_all(df, ~replace(., is.na(.), 0)),
  file = "data/rds/s2_hollstein.rds"
)