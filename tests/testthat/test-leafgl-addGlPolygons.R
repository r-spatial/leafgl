context("test-leafgl-addGlPolygons")

test_that("addGlPolygons works", {
  library(leaflet)
  library(leafgl)
  library(sf)

  gadm = st_as_sf(gadmCHE)
  single_poly <- suppressWarnings(st_cast(gadm, "POLYGON"))

  m = leaflet() %>%
    addGlPolygons(data = single_poly,
                  group = "pls", digits = 5)
  expect_is(m, "leaflet")

  # Group = NULL #######
  m = leaflet() %>%
    addGlPolygons(data = single_poly, group = NULL, digits = 5)
  expect_is(m, "leaflet")

  m = leaflet() %>%
    addGlPolygons(data = single_poly, group = NULL, src = TRUE, digits = 5)
  expect_is(m, "leaflet")

  ## Multi #########
  expect_error(
    leaflet() %>%
      addGlPolygons(data = gadm, digits = 5))
  expect_error(
    leaflet() %>%
      addGlPolygons(data = gadm, src = TRUE, digits = 5))

  ## Spatial Data #########
  skip_if_not_installed("sp")
  spatialdf <- as(single_poly, "Spatial")
  m = leaflet() %>%
    addGlPolygons(data = spatialdf, digits = 5)
  expect_is(m, "leaflet")

  m = leaflet() %>%
    addGlPolygons(data = spatialdf, src = TRUE, digits = 5)
  expect_is(m, "leaflet")
})
