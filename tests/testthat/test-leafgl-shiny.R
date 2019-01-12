context("test-leafgl-shiny")

test_that("shiny works", {
  ui <- leafglOutput("mymap")
  expect_is(ui, "shiny.tag.list")
  expect_is(ui, "list")
  expect_length(ui, 2)
  srv <- renderLeafgl({""})
  expect_is(srv, "shiny.render.function")
  expect_is(srv, "function")
})
