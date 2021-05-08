#' @author  Fernando Prudencio

rm(list = ls())

library(tidyverse)
library(raster)
library(janitor)
library(magrittr)
library(rgee)
library(sf)

# Initialize ee
ee_Initialize()

# Load data ----
# load list of scene
ls.files <-
  list.files(
    "data/95-Cloud/entire_scene_gts",
    pattern = "\\.TIF$", full.names = T
  )

# load list of metadata
ls.mtl <-
  list.files(
    "data/95-Cloud/metadata",
    pattern = "\\MTL.txt$", full.names = T
  )
# list of id by scene
id <-
  basename(ls.files) %>%
  str_sub(-34, -20) %>%
  sprintf(fmt = "LC08_%1s")

# Build table ----
# create empty table
df <-
  tibble(
    total = numeric(),
    p0 = numeric(),
    p1 = numeric()
  )
# fill table
for (i in seq_len(length(ls.files))) {
  cat(sprintf("scene = %1s\n", i))
  # load ee image object
  img <- ee$Image(sprintf("LANDSAT/LC08/C01/T1/%1s", id[i]))
  # get epsg
  epsg <-
    img$getInfo()$bands[[12]][[4]] %>%
    str_sub(-5, -1) %>%
    as.numeric() %>%
    sprintf(fmt = "+init=epsg:%1s")
  # get coordinates list of tile with buffer
  tile <-
    ee_as_sf(img$select("B1")$geometry()) %>%
    sf::st_transform(crs = epsg) %>%
    sf::st_buffer(-2750)
  # read metadata
  mtl <- read_lines(ls.mtl[i])
  # extract corners
  corners <-
    c(
      "CORNER_UL_PROJECTION_X_PRODUCT",
      "CORNER_UR_PROJECTION_X_PRODUCT",
      "CORNER_LL_PROJECTION_Y_PRODUCT",
      "CORNER_UL_PROJECTION_Y_PRODUCT"
    )
  # build georeferenced raster and masking
  img <-
    raster(
      raster(ls.files[i]) %>% as.matrix(),
      xmn = mtl[grep(mtl, pattern = corners[1])] %>% parse_number(),
      xmx = mtl[grep(mtl, pattern = corners[2])] %>% parse_number(),
      ymn = mtl[grep(mtl, pattern = corners[3])] %>% parse_number(),
      ymx = mtl[grep(mtl, pattern = corners[4])] %>% parse_number(),
      crs = st_crs(tile)$input
    ) %>%
    raster::mask(tile)
  # scena name
  name <- basename(ls.files[i]) %>% str_sub(1, -5)
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
names(df) <- c("total_pixels", "Cloud", "Clear", "id")

# Save table ----
saveRDS(
  mutate_all(df, ~replace(., is.na(.), 0)),
  file = "data/rds/95-cloud.rds"
)
