library(mapview)
library(leaflet)
library(leafgl)
library(sf)
library(colourvalues)
library(data.table)

options(viewer = NULL)

n = 1e5
rad = sample(3:25, n, replace = TRUE)

df1 = data.frame(id = 1:n,
                 radius = rad,
                 x = rnorm(n, 10, 1),
                 y = rnorm(n, 49, 0.8))

pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
pts$pop = leafpop::popupTable(pts)

cols = colour_values(pts$id, include_alpha = FALSE, palette = "magma")
cols = sample(tolower(cols))


system.time({
  m1 = mapview()@map %>%
    # addTiles() %>%
    leafgl:::addGlPoints(
      data = pts
      , fillColor = cols
      , radius = pts$radius
      , popup = pts$pop
      , group = "pts"
      , digits = 5
    ) %>%
    leafem::addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
    mapview:::updateOverlayGroups(group = "pts")
})

m1

system.time({
  m2 = leaflet() %>%
    addTiles() %>%
    leafgl:::addGlPoints(
      data = pts
      , fillColor = cols
      , radius = pts$radius
      , popup = pts$pop
      , group = "pts"
      , digits = 5
      # , src = TRUE
    ) %>%
    leafem::addMouseCoordinates() %>%
    # setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
    mapview:::updateOverlayGroups(group = "pts")
})

m2

system.time({
  m = mapview()@map %>%
    addGlPoints(
      data = pts
      , color = cols
      , radius = pts$radius
      , popup = pts$pop
      , group = "pts"
      , digits = 5
    ) %>%
    leafem::addMouseCoordinates() %>%
    setView(lng = 10.5, lat = 49.5, zoom = 6) %>%
    mapview:::updateOverlayGroups(group = "pts")
})


# mapshot(m, "/home/timpanse/Desktop/test.html", selfcontained = FALSE)

### try 10 mio - partition into 4 chunks to avoid size overflow in the browser
# n = 1e7
#
# df1 = data.frame(id = 1:n,
#                  x = c(runif(n/4, -160, 0),
#                        runif(n/4, -160, 0),
#                        runif(n/4, 0, 160),
#                        runif(n/4, 0, 160)),
#                  y = c(runif(n/4, -80, 0),
#                        runif(n/4, 0, 80),
#                        runif(n/4, -80, 0),
#                        runif(n/4, 0, 80)))
#
# pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
#
# cols = colour_values_rgb(1:4, include_alpha = FALSE) / 255
#
# system.time({
#   pts_lst = lapply(
#     split(as.data.table(pts), (as.numeric(rownames(pts))-1) %/% 2.5e6),
#     st_as_sf
#   )
# })
# #   user  system elapsed
# # 42.298   0.050  42.344
#
# m = mapview()@map %>%
#   addMouseCoordinates() %>%
#   setView(lng = 0, lat = 0, zoom = 2)
#
#
# for (i in 1:4) {
#   print(i)
#   m = leafgl:::addGlPointsSrc2(map = m,
#                                         data = pts_lst[[i]],
#                                         weight = i * 5,
#                                         color = cols[i, , drop = FALSE],
#                                         group = as.character(i),
#                                         popup = "id")
# }
#
# options(viewer = NULL)
#
# m %>%
#   mapview:::updateOverlayGroups(group = as.character(1:4))
#
# mapshot(m, "/home/timpanse/Desktop/test.html", selfcontained = FALSE)
