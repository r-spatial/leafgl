context("test-leafgl-addGlPoints")

test_that("addGlPoints works", {
  library(mapview)
  library(leaflet)
  library(leafgl)
  library(sf)

  n = 1e3
  df1 = data.frame(id = 1:n,
                   id2 = n:1,
                   x = rnorm(n, 10, 1),
                   y = rnorm(n, 49, 0.8))
  pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

  m = mapview()@map %>%
    addGlPoints(data = pts, group = "pts", digits = 5)

  expect_is(m, "leaflet")
})
