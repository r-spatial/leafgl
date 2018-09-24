# leaflet.glify

An R package for fast web gl rendering of features on leaflet maps.
It's an R port of https://github.com/robertleeplummerjr/Leaflet.glify where 
more detailed information/documentation can be found. Also, if you like 
what you get here, make sure to star the original repo!

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

#### 100k polygons on a map

In reality, it only 97112 polygons... But who wants to be pedantic here?

This data was downloaded from https://download.geofabrik.de/europe/switzerland.html

```r
ch_lu = st_read("/media/timpanse/d8346522-ef28-4d63-9bf3-19fec6e13aab/bu_lenovo/software/testing/mapview/switzerland/landuse.shp")

ch_lu = ch_lu[, c(1, 3, 4)] # don't handle NAs so far

options(viewer = NULL)

cols = colour_values_rgb(ch_lu$type, include_alpha = FALSE) / 255

system.time({
  m = leaflet() %>%
    addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    leaflet.glify:::addGlifyPolygons(data = ch_lu, color = cols, popup = "type") %>%
    addMouseCoordinates() %>%
    setView(lng = 8.3, lat = 46.85, zoom = 9)
})

m
```

![](https://raw.githubusercontent.com/tim-salabim/leaflet.glify/master/inst/polys_ch.png)

## Contact ##

Please file Pull requests, bug reports and feature requests at https://github.com/tim-salabim/leaflet.glify/issues
