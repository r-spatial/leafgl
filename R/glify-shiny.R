#' Use leafgl in shiny
#'
#' @param outputId output variable to read from
#' @param width,height the width and height of the map
#'
#' @details See \link[leaflet:map-shiny]{leaflet::leafletOutput} for details.
#'   \code{renderLeafgl} is only exported for consistency. You can just as well
#'   use \link[leaflet:map-shiny]{leaflet::renderLeaflet} (see example).
#'   \code{leafglOutput} on the other hand is needed as it will attach all
#'   necessary dependencies.
#'
#' @return A UI for rendering leafgl
#'
#' @importFrom leaflet leafletOutput
#' @importFrom htmltools tagList tags htmlDependencies
#' @rdname glify-shiny
#' @export
#'
#' @examples
#' if (interactive()) {
#' library(shiny)
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
#'  addGlPoints(data = pts, group = "pts") %>%
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
    leaflet::leafletOutput(outputId = outputId, width = width, height = height)
    , tags$script(glifyDependencies())
  )
}

# Just for consistency
#
#' @importFrom leaflet renderLeaflet
#'
#' @param expr An expression that generates an HTML widget
#' @param env The environment in which to evaluate expr.
#' @param quoted Is expr a quoted expression (with quote())?
#'   This is useful if you want to save an expression in a variable.
#'
#' @return A server function for rendering leafgl
#'
#' @rdname glify-shiny
#' @export
#'
renderLeafgl <- function(expr, env = parent.frame(), quoted = TRUE){
  leaflet::renderLeaflet(expr = expr, env = env, quoted = quoted)
}

