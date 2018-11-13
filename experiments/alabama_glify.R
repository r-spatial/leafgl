library(sf)
library(mapview)
library(leaflet.glify)
library(leaflet)
library(data.table)

## download from https://usbuildingdata.blob.core.windows.net/usbuildings-v1-1/Alabama.zip
al = st_read("/home/timpanse/software/testing/data/buildings/Alabama.geojson")

## split into 5 chunks to avoid memory issues in the browser
al_lst = lapply(
  split(as.data.table(al), (as.numeric(rownames(al))-1) %/% 5e5),
  st_as_sf
)

## set up the map
m = mapview()@map %>%
  addMouseCoordinates() %>%
  setView(lng = -86.8, lat = 32.6, zoom = 7)

## add each tile embedded via <src=...>
for (i in 1:length(al_lst)) {
  print(i)
  m = leaflet.glify:::addGlifyPolygonsSrc(map = m,
                                          data = al_lst[[i]],
                                          color = cbind(0, 0, 0),
                                          opacity = 0.9,
                                          group = as.character(i))
}

## render in browser rather than viewer
options(viewer = NULL)

## add layer control to switch houses on and off
m %>%
  mapview:::updateOverlayGroups(group = as.character(1:length(al_lst)))
