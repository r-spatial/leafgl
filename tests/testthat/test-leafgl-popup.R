context("test-leafgl-popup")

library(leaflet)
library(jsonify)
library(mapview)

## POINTS #################################
test_that("popup-points-character", {
  ## Column Name Single ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = "state",
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), breweries91$state)
  rm(m)

  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = breweries91$state,
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), breweries91$state)
  rm(m)

  ## Column Names ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = c("state", "address"),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  # expect_identical(from_json(m$x$calls[[2]]$args[[3]]), breweries91$state)
  rm(m)

  ## Single Random Character ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = "Text 1",
                group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), rep("Text 1", nrow(breweries91)))
  rm(m)

  ## Multiple Random Characters - (wrong length) ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPoints(data = breweries91,
                                    popup = c("Text 1", "Text 2"),
                                    group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]),
                   rep(c("Text 1","Text 2"), nrow(breweries91))[1:nrow(breweries91)])
  rm(m)

  ## Multiple Random Character (same length) ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = rep("Text 1", nrow(breweries91)),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), rep("Text 1", nrow(breweries91)))
})

test_that("popup-points-table", {
  ## Data.frame ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = as.data.frame(breweries91),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Data.frame - wrong length ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = as.data.frame(breweries91)[1:4,],
                group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Matrix ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = as.matrix(as.data.frame(breweries91)),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-points-spatial", {
  ## SpatialPointsDataFrame ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = breweries91,
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Simple Feature ##############
  library(sf)
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = st_as_sf(breweries91),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

test_that("popup-points-formula", {
  ## Formula ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = ~sprintf("<b>State</b>: %s<br>
                                 <b>Address</b>: %s<br>
                                 <b>Brauerei</b>: %s,",
                                 state, address, brewery),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

test_that("popup-points-list", {
  ## List with length 1 ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = as.list(data.frame(city="Berlin",
                                           district=5029, stringsAsFactors = F)),
                group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## List with length >1 ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
        addGlPoints(data = breweries91,
                    popup=as.list(data.frame(city=c("Vienna","Berlin"),
                                             district=c(1010,40302),
                                             stringsAsFactors = F)),
                    group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))


  ## List with same length ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = as.list(as.data.frame(breweries91)),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-points-json", {
  ## JSON - 1 column ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = jsonify::to_json(as.list(as.data.frame(breweries91[,1]))),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = jsonify::to_json(as.data.frame(breweries91[,1])),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## JSON - multiple columns ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = jsonify::to_json(as.list(as.data.frame(breweries91[,1:5]))),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  m <- expect_warning(leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = jsonify::to_json(as.data.frame(breweries91[1,])),
                group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## JSON with same length ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = jsonify::to_json(as.list(as.data.frame(breweries91))),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-points-logical", {
  ## TRUE ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = TRUE,
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## FALSE #################
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = FALSE,
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_true(m$x$calls[[2]]$args[[3]] == "{}")

  ## NULL #################
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = NULL,
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(is.null(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-points-shiny.tag", {
  library(shiny)
  ## Shiny.Tag - icon - Length 1 ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = shiny::icon("car"),
                group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Shiny.Tag - icon - Length >1 ##############
  # m <- expect_warning(leaflet() %>% addTiles() %>%
  #                       addGlPoints(data = breweries91,
  #                                   popup = c(
  #                                     shiny::icon("car"),
  #                                     shiny::icon("wrench")
  #                                   ),
  #                                   group = "grp"))
  # expect_is(m, "leaflet")
  # expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-points-default", {
  ## POSIX* ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPoints(data = breweries91,
                                    popup = Sys.time(),
                                    group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## POSIX* - same length##############
  m <- leaflet() %>% addTiles() %>%
    addGlPoints(data = breweries91,
                popup = seq.POSIXt(Sys.time(), Sys.time()+1000,
                                   length.out = nrow(breweries91)),
                group = "grp")
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Date ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPoints(data = breweries91,
                                    popup = Sys.Date(),
                                    group = "grp"))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

## LINES #################################
trls = suppressWarnings(st_cast(trails, "LINESTRING"))
trls = st_transform(trls, 4326)

## TODO - not working in RStudio Pane /In Zomm Mode it works / Shiny?
test_that("popup-lines-character", {
  ## Column Name Single ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = "district",
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), trls$district)
  rm(m)

  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = trls$district,
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), trls$district)
  rm(m)


  ## Column Names ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = c("district", "FKN"),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  rm(m)

  ## Single Random Character ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPolylines(data = trls,
                                       popup = "Text 1",
                                       opacity = 1))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), rep("Text 1", nrow(trls)))
  rm(m)

  ## Multiple Random Characters - (wrong length) ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPolylines(data = trls,
                                    popup = c("Text 1", "Text 2"),
                                    opacity = 1))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]),
                   rep(c("Text 1","Text 2"), nrow(trls))[1:nrow(trls)])
  rm(m)

  ## Multiple Random Character (same length) ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = rep("Text 1", nrow(trls)),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), rep("Text 1", nrow(trls)))
})

test_that("popup-lines-table", {
  ## Data.frame ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = as.data.frame(trls),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Data.frame - wrong length ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPolylines(data = trls,
                                       popup = as.data.frame(trls)[1:4,],
                                       opacity = 1))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Matrix ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = as.matrix(as.data.frame(trls)),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-lines-spatial", {
  ## SpatialLinesDataFrame ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = sf::as_Spatial(trls),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Simple Feature ##############
  library(sf)
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = trls,
                   opacity = 1)

  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

test_that("popup-lines-formula", {
  ## Formula ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = ~sprintf("<b>State</b>: %s<br>
                                 <b>Address</b>: %s<br>
                                 <b>Brauerei</b>: %s,",
                                    FGN, FKN, district),
                   opacity = 1)

  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

test_that("popup-lines-logical", {
  ## TRUE ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = TRUE,
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(m$x$calls[[2]]$args[[3]])

  ## FALSE #################
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = FALSE,
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_true(m$x$calls[[2]]$args[[3]] == "{}")

  ## NULL #################
  m <- leaflet() %>% addTiles() %>%
    addGlPolylines(data = trls,
                   popup = NULL,
                   opacity = 1)

  expect_is(m, "leaflet")
  expect_true(is.null(m$x$calls[[2]]$args[[3]]))
})

## POLYGONS #################################
fran = suppressWarnings(st_cast(franconia, "POLYGON"))

test_that("popup-polygon-character", {
  ## Column Name Single ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                  popup = "district",
                  opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), fran$district)
  rm(m)

  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                  popup = fran$district,
                  opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), fran$district)
  rm(m)


  ## Column Names ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = c("district", "NUTS_ID"),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  rm(m)

  ## Single Random Character ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPolygons(data = fran,
                                       popup = "Text 1",
                                       opacity = 1))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), rep("Text 1", nrow(fran)))
  rm(m)

  ## Multiple Random Characters - (wrong length) ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPolygons(data = fran,
                                       popup = c("Text 1", "Text 2"),
                                       opacity = 1))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]),
                   rep(c("Text 1","Text 2"), nrow(fran))[1:nrow(fran)])
  rm(m)

  ## Multiple Random Character (same length) ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = rep("Text 1", nrow(fran)),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_identical(from_json(m$x$calls[[2]]$args[[3]]), rep("Text 1", nrow(fran)))
})

test_that("popup-polygon-table", {
  ## Data.frame ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = as.data.frame(fran),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Data.frame - wrong length ##############
  m <- expect_warning(leaflet() %>% addTiles() %>%
                        addGlPolygons(data = fran,
                                       popup = as.data.frame(fran)[1:4,],
                                       opacity = 1))
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Matrix ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = as.matrix(as.data.frame(fran)),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

})

test_that("popup-polygon-spatial", {
  ## SpatialPolygonsDataFrame ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = sf::as_Spatial(fran),
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))

  ## Simple Feature ##############
  library(sf)
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = fran,
                   opacity = 1)

  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

test_that("popup-polygon-formula", {
  ## Formula ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = ~sprintf("<b>State</b>: %s<br>
                                 <b>Address</b>: %s<br>
                                 <b>Brauerei</b>: %s,",
                                    NUTS_ID, CNTR_CODE, district),
                   opacity = 1)

  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
})

test_that("popup-polygon-logical", {
  ## TRUE ##############
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = TRUE,
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(m$x$calls[[2]]$args[[3]])

  ## FALSE #################
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = FALSE,
                   opacity = 1)
  expect_is(m, "leaflet")
  expect_true(jsonify::validate_json(m$x$calls[[2]]$args[[3]]))
  expect_true(m$x$calls[[2]]$args[[3]] == "{}")

  ## NULL #################
  m <- leaflet() %>% addTiles() %>%
    addGlPolygons(data = fran,
                   popup = NULL,
                   opacity = 1)

  expect_is(m, "leaflet")
  expect_true(is.null(m$x$calls[[2]]$args[[3]]))
})


