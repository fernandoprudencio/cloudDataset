#' @author  Fernando Prudencio

rm(list = ls())

library(tidyverse)
library(raster)
library(filesstrings)
library(janitor)
library(magrittr)

# Handling zipped files ----
# List ".tar.qz" files
# zip.list <- list.files(pattern = ".tar.gz", full.names = T)
# Unzip data
# sapply(
#   zip.list,
#   FUN =
#     function(x) {
#       print(x)
#       untar(x, exdir = basename(x) %>% str_sub(1, -8))
#     }
# )

# Find images and move it ----
# dir.create("biome8_fixedmask")
# dir.create("biome8_fixedmask/mtl")
list.img <- list.files(
  "data/biome8_fixedmask",
  all.files = T,
  pattern = ".img",
  recursive = T,
  full.names = T
)
# list.hdr <- list.files(
#   all.files = T,
#   pattern = ".hdr",
#   recursive = T,
#   full.names = T
# )
# list.mtl <- list.files(
#   all.files = T,
#   pattern = "MTL.txt",
#   recursive = T,
#   full.names = T
# )
# file.move(
#   c(list.mtl, list.img, list.hdr),
#   "biome8_fixedmask"
# )

# Build table ----
# create empty table
df <-
  tibble(
    p0 = numeric(),
    p64 = numeric(),
    p128 = numeric(),
    p192 = numeric(),
    p255 = numeric(),
    id = character(),
  )
# fill table
for (i in 1:length(list.img)) {
  print(i)
  # load raster
  img <- raster(list.img[i])
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
        mutate(id = names(img))
    )
}
# renames colnames
names(df) <-
  c(
    "background", "Cloud_Shadow", "Clear",
    "Thin_Cloud", "Cloud", "id"
  )

# Save table ----
saveRDS(
  mutate_all(df, ~replace(., is.na(.), 0)),
  file = "biome8.rds"
)