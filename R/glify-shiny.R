#' Use leafgl in shiny
#'
#' @inheritParams leaflet::leafletOutput
#' @importFrom leaflet leafletOutput
#' @importFrom htmltools tagList tags
#' @return A UI for rendering leafgl
#' @export
#'
#' @examples
#' \dontrun{
#' library(mapview)
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#'
#' n = 1e4
#' df1 = data.frame(id = 1:n,
#'     x = rnorm(n, 10, 3),
#'     y = rnorm(n, 49, 1.8))
#' pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
#'
#' m = leaflet() %>%
#'  addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'  addGlifyPoints(data = pts, group = "pts") %>%
#'  addMouseCoordinates() %>%
#'  setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
#'  addLayersControl(overlayGroups = "pts")
#'
#' ui <- fluidPage(
#'     leafglOutput("mymap")
#' )
#'
#' server <- function(input, output, session) {
#'     output$mymap <- renderLeaflet(m)
#' }
#'
#' shinyApp(ui, server)
#' }
#'

leafglOutput <- function(outputId, width = "100%", height = 400){
  tagList(
    leafletOutput(outputId = outputId, width = width, height = height),
    tags$script(glifyDependencies())
  )
}

# Just for consistency
#
#' Use leafgl in shiny
#'
#' @importFrom leaflet renderLeaflet
#'
#' @inheritParams leaflet::renderLeaflet
#'
#' @return A server function for rendering leafgl
#' @export
#'
#' @examples
#' \dontrun{
#' library(mapview)
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#' library(shiny)
#'
#' n = 1e4
#' df1 = data.frame(id = 1:n,
#'     x = rnorm(n, 10, 3),
#'     y = rnorm(n, 49, 1.8))
#' pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
#'
#' m = leaflet() %>%
#'  addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'  addGlPoints(data = pts, group = "pts") %>%
#'  addMouseCoordinates() %>%
#'  setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
#'  addLayersControl(overlayGroups = "pts")
#'
#' ui <- fluidPage(
#'     leafglOutput("mymap")
#' )
#'
#' server <- function(input, output, session) {
#'     output$mymap <- renderLeaflet(m)
#' }
#'
#' shinyApp(ui, server)
#' }
#'
renderLeafgl <- function(expr, env = parent.frame(), quoted = FALSE){
  renderLeaflet(expr = expr, env = env, quoted = quoted)
}

