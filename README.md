# leaflet.glify

An R package for fast web gl rendering of features on leaflet maps

-----

### Installation

Currently not on CRAN, github only:

```r
devtools::install_github("tim-salabim/leaflet.glify")
```

### Example usage

#### 1 Mio. points on a map

This will render 1 Mio. points on a standard leaflet map. It will be fast and
will be very performant/responsive.

```r
library(mapview)
library(leaflet)
library(leaflet.glify)
library(sf)

n = 1e6

df1 = data.frame(id = 1:n,
                 x = rnorm(n, 10, 3),
                 y = rnorm(n, 49, 1.8))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

options(viewer = NULL) # view in browser

system.time({
  m = leaflet() %>%
    addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    addGlifyPoints(data = pts) %>%
    addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6)
})

m
```
![](https://raw.githubusercontent.com/tim-salabim/leaflet.glify/master/inst/pts_blue.png)

#### Colouring points by value mapping

For this we use `library(colourvalues)` because it is very fast.

```r
library(mapview)
library(leaflet)
library(leaflet.glify)
library(sf)
library(colourvalues)

n = 1e6

df1 = data.frame(id = 1:n,
                 x = rnorm(n, 10, 3),
                 y = rnorm(n, 49, 1.8))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

cols = colour_values_rgb(pts$id, include_alpha = FALSE) / 255

options(viewer = NULL)

system.time({
  m = leaflet() %>%
    addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    addGlifyPoints(data = pts, color = cols) %>%
    addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6)
})

m
```
![](https://raw.githubusercontent.com/tim-salabim/leaflet.glify/master/inst/pts_viridis.png)

## Contact ##

Please file Pull requests, bug reports and feature requests at https://github.com/tim-salabim/leaflet.glify/issues
