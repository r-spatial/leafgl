context("test-leafgl-addGlPolygons")

test_that("addGlPolygons works", {
  library(leaflet)
  library(leafgl)
  library(sf)

  gadm = st_as_sf(gadmCHE)

  m = leaflet() %>%
    addGlPolygons(data = suppressWarnings(st_cast(gadm, "POLYGON")),
                  group = "pls", digits = 5)

  expect_is(m, "leaflet")
})
