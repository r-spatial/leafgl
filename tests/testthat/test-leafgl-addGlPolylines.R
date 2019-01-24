context("test-leafgl-addGlPolylines")

test_that("addGlPolylines works", {
  library(mapview)
  library(leaflet)
  library(leafgl)
  library(sf)

  m = mapview()@map %>%
    addGlPolylines(data = suppressWarnings(st_cast(trails, "LINESTRING")),
                   group = "pls", digits = 5)

  expect_is(m, "leaflet")
})
