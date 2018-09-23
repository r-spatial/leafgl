library(mapview)
library(leaflet)
library(leaflet.glify)
library(sf)
library(colourvalues)
library(jsonlite)

n = 1e6

df1 = data.frame(id = 1:n,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

cols = colour_values_rgb(pts$id, include_alpha = FALSE) / 255

options(viewer = NULL)

system.time({
  m = leaflet() %>%
    addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    addGlifyPoints(data = pts) %>%
    addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6)
})

m

