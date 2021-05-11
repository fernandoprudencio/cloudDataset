rm(list = ls())

library(raster)
library(tmap)
library(sf)

data("World")

# load vector
rgdal::ogrListLayers("data/vector/limits.gpkg")

crs <- "+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

sf_wc <-
  st_read(
    "data/vector/limits.gpkg",
    layer = "world_countries"
  ) %>%
  st_transform(crs)

tm_shape(shp = sf_wc) +
  tm_fill(col = "gray90") +
  tm_borders(col = "black", lwd = 0.7) +
  tm_graticules(alpha=0.8, lwd = 0.5, labels.size = 0.5) +
  tm_layout() +
  tmap_style(style = "natural") +
  tm_layout(
    scale = .8,
    bg.color = "white",
    frame = FALSE,
    frame.lwd = NA,
    panel.label.bg.color = NA,
    attr.outside = TRUE,
    main.title.size = 1.5,
    main.title = "Cloud DataSet Distribution",
    main.title.fontface = 2,
    main.title.position = 0.4,
    legend.title.size = 1,
    legend.title.fontface = 2,
    legend.text.size = 0.7,
    legend.frame = FALSE,
    legend.outside = TRUE,
    legend.position = c(0.10, 0.38),
    legend.bg.color = "white",
    legend.bg.alpha = 1
  ) +
  tm_credits(
    text = "Cloudsen12 team",
    size = 1,
    position = c(0.05,0)
  )

tmap_save(lst_tmap, "lst_tmap.svg", width = 1865, height = 1165)