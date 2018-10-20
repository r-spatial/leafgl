library(mapview)
library(leaflet)
library(leaflet.glify)
library(sf)
library(colourvalues)

n = 1e6

df1 = data.frame(id = 1:n,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

system.time({
  cols = colour_values_rgb(pts$id, include_alpha = FALSE) / 255

  options(viewer = NULL)

  m = leaflet() %>%
    addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
    addGlifyPoints(data = pts, color = cols, popup = "id") %>%
    addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6)
})

m

### try 10 mio - partition into 5 chunks to avoid size overflow in the browser
n = 10e6

df1 = data.frame(id = 1:n,
                 x = runif(n, -180, 180),
                 y = runif(n, -85, 85))

st = seq(1, n, 2e6)
nd = st + 2e6 - 1

cols = colour_values_rgb(1:5, include_alpha = FALSE) / 255

pts_lst = lapply(seq(st), function(i) {
  print(i)
  tmp = df1[st[i]:nd[i], ]
  pts = st_as_sf(tmp, coords = c("x", "y"), crs = 4326)
  return(pts)
})

options(viewer = NULL)

m = leaflet() %>%
  addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
  addMouseCoordinates() %>%
  setView(lng = 0, lat = 0, zoom = 2)


for (i in 1:5) {
  print(i)
  m = addGlifyPoints(map = m,
                     data = pts_lst[[i]],
                     weight = 5,
                     color = cols[i, , drop = FALSE],
                     group = as.character(i))
}

options(viewer = NULL)

m
