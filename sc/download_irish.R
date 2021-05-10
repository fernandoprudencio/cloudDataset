rm(list = ls())

library(rvest)
library(tidyverse)

# biome_8 <- read_html("https://landsat.usgs.gov/landsat-8-cloud-cover-assessment-validation-data")
irish <- read_html("https://landsat.usgs.gov/landsat-7-cloud-cover-assessment-validation-data#Boreal")

tar_gz_irish <-
  irish  %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  '['(grepl("\\.tar.gz$", .))

dir.create("data/irish", showWarnings = FALSE)

# seq_along(tar_gz_irish)
for (index in 2:206) {
  download.file(tar_gz_irish[index], paste0("data/irish/", basename(tar_gz_irish))[index])
}
