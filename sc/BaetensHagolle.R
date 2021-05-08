#' @author  Fernando Prudencio

rm(list = ls())

library(reticulate)
library(tidyverse)
library(raster)
library(janitor)
library(magrittr)

# List of raster
lst <-
  list.files(
    "data/BaetensHagolle",
    pattern = "\\classification_map.tif$",
    full.names = T,
    recursive = T
  )
# List of scene id
path <- "data/BaetensHagolle/SENTINEL_2_reference_cloud_masks_Baetens_Hagolle"
scene <-
  c(
    list.dirs(
      sprintf("%1s/Hollstein", path),
      recursive = F,
      full.names = F
    ),
    list.dirs(
      sprintf("%1s/Reference_dataset", path),
      recursive = F,
      full.names = F
    )
  )

# Build table ----
# create empty table
df <-
  tibble(
    total = numeric(),
    p0 = numeric(),
    p1 = numeric(),
    p2 = numeric(),
    p3 = numeric(),
    p4 = numeric(),
    p5 = numeric(),
    p6 = numeric(),
    p7 = numeric(),
    id = character()
  )
# fill table
for (i in seq_len(length(lst))) {
  cat(sprintf("scene = %1s\n", i))
  # load raster
  img <- raster(lst[i])
  name <- scene[i]
  # build table
  df %<>%
    bind_rows(
      t(
        data.frame(
          getValues(img) %>%
            table()
        )
      ) %>%
        as_tibble() %>%
        janitor::row_to_names(row_number = 1) %>%
        rename_all(~ sprintf("p%1s", .x)) %>%
        mutate_all(as.numeric) %>%
        mutate(total = rowSums(across(where(is.numeric)), na.rm = T)) %>%
        mutate(id = name)
    )
}
# renames colnames
names(df) <-
  c(
    "total_pixels", "no_data", "not_used", "low_clouds", "high_clouds",
    "clouds_shadows", "land", "water", "snow", "id"
  )

# Save table ----
saveRDS(
  mutate_all(df, ~replace(., is.na(.), 0)),
  file = "data/rds/BaetensHagolle.rds"
)