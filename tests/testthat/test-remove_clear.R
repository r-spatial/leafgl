context("test-leafgl-remove_clear")

library(leaflet)
library(sf)
library(jsonify)

n = 1e2
df1 = data.frame(id = 1:n, id2 = n:1,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))
pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

lines = suppressWarnings(st_cast(st_as_sf(atlStorms2005), "LINESTRING"))
lines = st_transform(lines, 4326)[1:100,]

polys <- suppressWarnings(st_cast(st_as_sf(gadmCHE), "POLYGON"))

test_that("remove / clear", {
  ## Remove Points ########
  m <- leaflet() %>%
    addGlPoints(data = pts,
                layerId = "ptsid") %>%
    removeGlPoints("ptsid")

  expect_true(m$x$calls[[length(m$x$calls)]]$method == "removeGlPoints")
  expect_true(m$x$calls[[length(m$x$calls)]]$args[[1]] == "ptsid")

  ## Remove Lines ########
  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   layerId = "lnsid") %>%
    removeGlPolylines("lnsid")

  expect_true(m$x$calls[[length(m$x$calls)]]$method == "removeGlPolylines")
  expect_true(m$x$calls[[length(m$x$calls)]]$args[[1]] == "lnsid")

  ## Remove Polygons ########
  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  layerId = "polyid") %>%
    removeGlPolygons("polyid")

  expect_true(m$x$calls[[length(m$x$calls)]]$method == "removeGlPolygons")
  expect_true(m$x$calls[[length(m$x$calls)]]$args[[1]] == "polyid")

  ## Clear Layers ########
  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  layerId = "polyid") %>%
    addGlPolylines(data = lines,
                   layerId = "lnsid") %>%
    addGlPoints(data = pts,
                layerId = "ptsid") %>%
    clearGlLayers()

  expect_true(m$x$calls[[length(m$x$calls)]]$method == "clearGlLayers")
  expect_identical(m$x$calls[[length(m$x$calls)]]$args, list())

})
