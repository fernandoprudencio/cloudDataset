#' @author  Fernando Prudencio

rm(list = ls())

library(reticulate)
library(tidyverse)
library(raster)
library(filesstrings)
library(janitor)
library(magrittr)
np <- import("numpy")

lst <- list.files("data/cloudCatalog/masks", full.names = T)

# Build table ----
# create empty table
df <-
  tibble(
    total = numeric(),
    p1 = numeric(),
    p2 = numeric(),
    p3 = numeric(),
    id = character()
  )
# fill table
for (i in 1:length(lst)) {
  print(i)
  # load raster
  img <- sum(brick(np$load(lst[i])) * c(1, 2, 3))
  name <- basename(lst[i]) %>% str_sub(1, -5)
  # build table
  df %<>%
    bind_rows(
      t(
        data.frame(
          getValues(img) %>%
            table()
        )
      ) %>%
        as_data_frame() %>%
        janitor::row_to_names(row_number = 1) %>%
        rename_all(~ sprintf("p%1s", .x)) %>%
        mutate_all(as.numeric) %>%
        mutate(total = rowSums(across(where(is.numeric)), na.rm = T)) %>% 
        mutate(id = name)
    )
}
# renames colnames
names(df) <- c("total_pixels", "Clear", "Cloud", "Cloud_Shadow", "id")

# Save table ----
saveRDS(
  mutate_all(df, ~replace(., is.na(.), 0)),
  file = "data/rds/cloudCatalog.rds"
)