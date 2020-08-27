context("test-leafgl-color_utils")
library(leaflet)
library(sf)
library(jsonify)

n = 1e2
df1 = data.frame(id = 1:n, id2 = n:1,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))
pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

lines = suppressWarnings(st_cast(st_as_sf(atlStorms2005), "LINESTRING"));

polys <- suppressWarnings(st_cast(st_as_sf(gadmCHE), "POLYGON"))


test_that("Character as color", {
  ## Character - Color Name ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = "red",
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = "red",
                src = TRUE,
                group = "pts")
  expect_is(m, "leaflet")
  expect_identical(m$x$calls[[1]]$method, "addGlifyPointsSrc")
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = st_sfc(st_geometry(pts)),
                fillColor = "red",
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
                fillColor = "id",
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = "Name",
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = "NUTS_ID",
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Character - HEX-Code ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = "#36ba01",
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

  ## Character - Character Column Name with Palette #############
  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = "FGN",
                   palette = "rainbow",
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
                fillColor = ~id,
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = ~id,
                palette = "rainbow",
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = ~id,
                palette = "rainbow",
                group = "pts",
                src = TRUE)
  expect_is(m, "leaflet")
  expect_null(m$x$calls[[1]]$args[[1]])
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = ~Name,
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = ~Name,
                   palette = "rainbow",
                   group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   color = ~Name,
                   palette = "rainbow",
                   group = "lns",
                   src = TRUE);
  expect_is(m, "leaflet")
  expect_null(m$x$calls[[1]]$args[[1]])
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = ~NAME_1,
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = ~NAME_1,
                  palette = "rainbow",
                  group = "lns");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPolygons(data = polys,
                  color = ~NAME_1,
                  palette = "rainbow",
                  group = "lns",
                  src = TRUE)
  expect_is(m, "leaflet")
  expect_null(m$x$calls[[1]]$args[[1]])

})

test_that("Tables as color", {
  ## Matrix with nrow = 1 ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = cbind(180,1,10),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = cbind("180","1","10"),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = cbind(0.12, 0.9, 0.01),
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
                fillColor = matrix(sample(1:255, nrow(pts)*3, TRUE), ncol = 3),
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
                fillColor = data.frame(cbind(180,1,10)),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = data.frame(matrix(sample(1:255, nrow(pts)*3, TRUE), ncol = 3)),
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
                fillColor = 120L,
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
                fillColor = 30.43,
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
                fillColor = as.factor(130),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = as.factor(c("asd")),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = as.factor(c("asd","bdc","fds")),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


  m <- leaflet() %>%
    addGlPolylines(data = lines,
                   fillColor = as.factor(130),
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
                fillColor = list(1,2),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = list(100),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = list(matrix(sample(1:255, nrow(pts)*3, replace = T), ncol = 3)),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = lapply(1:nrow(pts), function(x) matrix(sample(1:255, 3), ncol = 3)),
                group = "pts")
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = list(c(100,200), cbind(2,1)),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)


})

test_that("JSON as color", {
  ## JSON with same dimensions ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = jsonify::to_json(list(matrix(sample(1:255, nrow(pts)*3, replace = T), ncol = 3))),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## JSON with 1 color ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = jsonify::to_json(data.frame(r = 54, g = 186, b = 1)),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## JSON with wrong dimension - Warning ###################
  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = jsonify::to_json(data.frame(r = c(54, 123),
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
                fillColor = as.POSIXlt(Sys.time(), "America/New_York"),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## POSIXct ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = Sys.time(),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Date ###################
  m <- leaflet() %>%
    addGlPoints(data = pts,
                fillColor = Sys.Date(),
                group = "pts");
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)
})

test_that("Warnings / Errors", {
  ## TODO Not showing anything
  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = matrix(33:98, ncol = 3, byrow = F),
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = data.frame(matrix(33:98, ncol = 3, byrow = F)),
                group = "pts"));
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Warnings ###################
  m <- expect_warning(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = 1:33,
                group = "pts"))
  expect_is(m, "leaflet")
  expect_is(m$x$calls[[1]]$args[[2]], "json")
  expect_true(validate_json(m$x$calls[[1]]$args[[2]]))
  rm(m)

  ## Errors + Warnings ###################
  expect_warning(expect_error(leaflet() %>%
    addGlPoints(data = pts,
                fillColor = cbind("asf","fasd", "fasd"),
                group = "pts")))

})

