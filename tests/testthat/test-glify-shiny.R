context("test-glify-shiny")

test_that("shiny works", {
  ui <- glifyOutput("mymap")
  expect_is(ui, "shiny.tag.list")
  expect_is(ui, "list")
  expect_length(ui, 2)
  srv <- renderGlify({""})
  expect_is(srv, "shiny.render.function")
  expect_is(srv, "function")
})
