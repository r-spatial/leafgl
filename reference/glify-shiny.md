# Use leafgl in shiny

Use leafgl in shiny

## Usage

``` r
leafglOutput(outputId, width = "100%", height = 400)

renderLeafgl(expr, env = parent.frame(), quoted = TRUE)
```

## Arguments

- outputId:

  output variable to read from

- width, height:

  the width and height of the map

- expr:

  An expression that generates an HTML widget

- env:

  The environment in which to evaluate expr.

- quoted:

  Is expr a quoted expression (with quote())? This is useful if you want
  to save an expression in a variable.

## Value

A UI for rendering leafgl

A server function for rendering leafgl

## Details

See leaflet::leafletOutput for details. `renderLeafgl` is only exported
for consistency. You can just as well use leaflet::renderLeaflet (see
example). `leafglOutput` on the other hand is needed as it will attach
all necessary dependencies.

## Examples

``` r
if (interactive()) {
library(shiny)
library(leaflet)
library(leafgl)
library(sf)

n = 1e4
df1 = data.frame(id = 1:n,
    x = rnorm(n, 10, 3),
    y = rnorm(n, 49, 1.8))
pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

m = leaflet() %>%
 addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
 addGlPoints(data = pts, group = "pts") %>%
 setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
 addLayersControl(overlayGroups = "pts")

ui <- fluidPage(
    leafglOutput("mymap")
)

server <- function(input, output, session) {
    output$mymap <- renderLeaflet(m)
}

shinyApp(ui, server)
}
```
