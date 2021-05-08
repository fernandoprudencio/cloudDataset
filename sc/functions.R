buffer_poly <- function(id) {
  # load data from earth engine
  # img <- ee$Image(sprintf("LANDSAT/LC08/C01/T1_SR/%1s", id))
  # img <- ee$Image(sprintf("LANDSAT/LC08/C01/T1_TOA/%1s", id))
  id <- id1[1]
  img <- ee$Image(sprintf("LANDSAT/LC08/C01/T1/%1s", id))
  # get epsg
  epsg <-
    img$getInfo()$bands[[12]][[4]] %>%
    str_sub(-5, -1) %>%
    as.numeric() %>%
    sprintf(fmt = "+init=epsg:%1s")
  # get coordinates list of tile with buffer
  df.coord <-
    ee_as_sf(img$select("B1")$geometry()) %>%
    sf::st_transform(crs = epsg) %>%
    sf::st_buffer(-2750, singleSide = T) %>%#-2315
    st_coordinates() %>%
    as_tibble()
  st_write(df.coord, "data/vector/tile01_buffer.shp")
  # get maximum and minimum coordinates
  xmin <- dplyr::filter(df.coord, X == min(X)) %>% distinct(X, Y, .keep_all = TRUE)
  ymin <- dplyr::filter(df.coord, Y == min(Y)) %>% distinct(X, Y, .keep_all = TRUE)
  xmax <- dplyr::filter(df.coord, X == max(X)) %>% distinct(X, Y, .keep_all = TRUE)
  ymax <- dplyr::filter(df.coord, Y == max(Y)) %>% distinct(X, Y, .keep_all = TRUE)
  # build new polygon
  init_poly <-
    st_sf(
      geom = st_sfc(
        st_polygon(
          list(
            bind_rows(
              xmin, ymin, xmax, ymax, xmin
            ) %>%
              dplyr::select(-L1, -L2) %>%
              as.matrix()
          )
        )
      ),
      crs = epsg
    )
  # make a buffer to each side
  left <-
    st_sf(
      geom = st_sfc(
        st_linestring(
          st_coordinates(init_poly)[,1:2][4:5,]
        )
      ),
      crs = epsg
    ) %>%
    st_buffer(100, singleSide = T)
  right <-
    st_sf(
      geom = st_sfc(
        st_linestring(
          st_coordinates(init_poly)[,1:2][2:3,]
        )
      ),
      crs = epsg
    ) %>%
    st_buffer(400, singleSide = T)
  # build stretched polygon
  st_difference(init_poly, right) %>%
    st_difference(left) %>%
    st_write("data/vector/test_both24.shp") %>%
    return()
}