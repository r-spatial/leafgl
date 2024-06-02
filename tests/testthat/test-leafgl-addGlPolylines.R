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

  # Group = NULL #######
  m = leaflet() %>%
    addGlPolylines(data = storms, group = NULL, digits = 5)
  expect_is(m, "leaflet")

  m = leaflet() %>%
    addGlPolylines(data = storms, group = NULL, src = TRUE, digits = 5)
  expect_is(m, "leaflet")


  ## Spatial Data #########
  lines = atlStorms2005
  m = leaflet() %>%
    addGlPolylines(data = lines, digits = 5)
  expect_is(m, "leaflet")

  m = leaflet() %>%
    addGlPolylines(data = lines, src = TRUE, digits = 5)
  expect_is(m, "leaflet")


  ## Multi #########
  multi <- st_cast(storms, "MULTILINESTRING")
  expect_error(
    leaflet() %>%
      addGlPolylines(data = multi, digits = 5))
  expect_error(
    leaflet() %>%
      addGlPolylines(data = multi, src = TRUE, digits = 5))




  # m = leaflet() %>%
  #   addGlPolylines(data = storms, digits = 5,
  #                  popup = ~sprintf("Name: %s<br>%s", Name,
  #                                  shiny::actionButton("id", "Act")))
  # expect_is(m, "leaflet")
  # m$dependencies
  #
  # leaflet() %>%
  #   addPolylines(data = storms,
  #                  popup = ~sprintf("Name: %s<br>%s", Name,
  #                                   shiny::icon("cog")))



})
