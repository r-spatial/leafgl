context("test-leafgl-color_utils")
library(mapview)
library(leaflet)
library(sf)
library(jsonify)

n = 1e2
df1 = data.frame(id = 1:n, id2 = n:1,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))
pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

lines = suppressWarnings(st_cast(trails, "LINESTRING"));
lines = st_transform(lines, 4326)
polys <- st_transform(st_buffer(st_transform(st_as_sf(breweries91[1,]), 3035), 50000), 4326)


test_that("Character as color", {
  ## Character - Color Name ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = "red",
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                color = "red",
                group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                   color = "red",
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Character - Column Name ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = "id",
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = "FKN",
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = "founded",
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Character - HEX-Code ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = "#36ba01",
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = "#36ba01",
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = "#36ba01",
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Character - Character Column Name #############
  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = "FGN",
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)
})

test_that("Formula as color", {
  ## Formula ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = ~id,
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = ~FKN,
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = ~zipcode,
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

})

test_that("Tables as color", {
  ## Matrix with nrow = 1 ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = cbind(180,1,10),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = cbind("180","1","10"),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = cbind(0.12, 0.9, 0.01),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = cbind(180,1,10),
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = cbind(180,1,10),
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


  ## Matrix with nrow = nrow(data) ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = matrix(sample(1:255, nrow(pts)*3, TRUE), ncol = 3),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = matrix(sample(1:255, nrow(lines)*3, TRUE), ncol = 3),
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = matrix(sample(1:255, nrow(polys)*3, TRUE), ncol = 3),
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## data.frame with nrow = 1 ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = data.frame(cbind(180,1,10)),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = data.frame(matrix(sample(1:255, nrow(pts)*3, TRUE), ncol = 3)),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

})

test_that("Numeric as color", {
  ## Integer ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = 120L,
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = 120L,
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = 120L,
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Numeric ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = 30.43,
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = 30.43,
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = 30.43,
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Factor ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = as.factor(130),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = as.factor(c("asd")),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                color = as.factor(c("asd","bdc","fds")),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = as.factor(130),
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = as.factor(130),
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

})

test_that("List as color", {
  ## List ###################
  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                color = list(1,2),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = list(100),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = list(matrix(sample(1:255, nrow(pts)*3, replace = T), ncol = 3)),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = lapply(1:nrow(pts), function(x) matrix(sample(1:255, 3), ncol = 3)),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = list(c(100,200), cbind(2,1)),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


})

test_that("JSON as color", {
  ## JSON with same dimensions ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = jsonify::to_json(list(matrix(sample(1:255, nrow(pts)*3, replace = T), ncol = 3))),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## JSON with 1 color ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = jsonlite::toJSON(data.frame(r = 54, g = 186, b = 1)),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## JSON with wrong dimension - Warning ###################
  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                color = jsonlite::toJSON(data.frame(r = c(54, 123),
                                                    g = c(1, 186),
                                                    b = c(1, 123))),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

})

test_that("Date/POSIX* as color", {
  ## POSIXlt ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = as.POSIXlt(Sys.time(), "America/New_York"),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## POSIXct ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = Sys.time(),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Date ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                color = Sys.Date(),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)
})

test_that("Warnings / Errors", {
  ## TODO Not showing anything
  # m <- leaflet() %>%
  #   addTiles() %>%
  #   addGlPoints(data = pts,
  #               color = matrix(1:33, ncol = 3, byrow = TRUE),
  #               group = "pts");m


  ## Warnings ###################

  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                color = 1:33,
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Errors ###################
  expect_error(leaflet() %>%
    addGlPoints(data = pts,
                color = cbind("asf","fasd", "fasd"),
                group = "pts"))

})

