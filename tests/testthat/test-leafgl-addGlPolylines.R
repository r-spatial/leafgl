context("test-leafgl-addGlPolylines")

test_that("addGlPolylines works", {
  library(leaflet)
  library(leafgl)
  library(sf)

  storms = st_as_sf(atlStorms2005)

  m = leaflet() %>%
    addGlPolylines(data = suppressWarnings(st_cast(storms, "LINESTRING")),
                   group = "pls", digits = 5)

  expect_is(m, "leaflet")
})
