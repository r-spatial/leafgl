library(mapview)
library(leaflet)
library(leaflet.glify)
library(sf)
library(colourvalues)
library(data.table)

n = 5e6

df1 = data.frame(id = 1:n,
                 id2 = n:1,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

system.time({
  cols = colour_values_rgb(pts$id, include_alpha = FALSE) / 255

  options(viewer = NULL)

  m = mapview()@map %>%
    leaflet.glify:::addGlifyPointsSrc2(data = pts, group = "pts", popup = "id") %>%
    addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
    mapview:::updateOverlayGroups(group = "pts")
})

m

mapshot(m, "/home/timpanse/Desktop/test.html", selfcontained = FALSE)

### try 10 mio - partition into 4 chunks to avoid size overflow in the browser
n = 1e7

df1 = data.frame(id = 1:n,
                 x = c(runif(n/4, -160, 0),
                       runif(n/4, -160, 0),
                       runif(n/4, 0, 160),
                       runif(n/4, 0, 160)),
                 y = c(runif(n/4, -80, 0),
                       runif(n/4, 0, 80),
                       runif(n/4, -80, 0),
                       runif(n/4, 0, 80)))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)

cols = colour_values_rgb(1:4, include_alpha = FALSE) / 255

system.time({
  pts_lst = lapply(
    split(as.data.table(pts), (as.numeric(rownames(pts))-1) %/% 2.5e6),
    st_as_sf
  )
})
#   user  system elapsed
# 42.298   0.050  42.344

m = mapview()@map %>%
  addMouseCoordinates() %>%
  setView(lng = 0, lat = 0, zoom = 2)


for (i in 1:4) {
  print(i)
  m = leaflet.glify:::addGlifyPointsSrc(map = m,
                                        data = pts_lst[[i]],
                                        weight = i * 5,
                                        color = cols[i, , drop = FALSE],
                                        group = as.character(i),
                                        popup = "id")
}

options(viewer = NULL)

m %>%
  mapview:::updateOverlayGroups(group = as.character(1:4))
