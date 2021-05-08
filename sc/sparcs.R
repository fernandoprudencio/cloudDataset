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
    "data/sparcs",
    pattern = "\\mask.png$",
    full.names = T,
    recursive = T
  )
# List of scene id
scene <- basename(lst) %>% str_sub(1, -5)

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
    "total_pixels", "Shadow", "Shadow_over_Water", "Water",
    "Snow", "Land", "Cloud", "Flooded", "id"
  )

# Save table ----
saveRDS(
  mutate_all(df, ~replace(., is.na(.), 0)),
  file = "data/rds/sparcs.rds"
)