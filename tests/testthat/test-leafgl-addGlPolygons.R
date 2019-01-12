context("test-leafgl-addGlPolygons")

test_that("addGlPolygons works", {
  library(mapview)
  library(leaflet)
  library(leafgl)
  library(sf)

  m = mapview()@map %>%
    addGlPolygons(data = suppressWarnings(st_cast(franconia, "POLYGON")),
                  group = "pls", digits = 5)

  expect_is(m, "leaflet")
})
