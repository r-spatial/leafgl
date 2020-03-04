#' removeGlPoints
#' @description Remove points from a map, identified by layerId;
#' @param map The map widget
#' @param layerId The layerId to remove
#' @export
removeGlPoints <- function(map, layerId) {
  leaflet::invokeMethod(map, NULL, "removeGlPoints", layerId)
}

#' removeGlPolylines
#' @description Remove lines from a map, identified by layerId;
#' @param map The map widget
#' @param layerId The layerId to remove
#' @export
removeGlPolylines <- function(map, layerId) {
  leaflet::invokeMethod(map, NULL, "removeGlPolylines", layerId)
}

#' removeGlPolygons
#' @description Remove polygons from a map, identified by layerId;
#' @param map The map widget
#' @param layerId The layerId to remove
#' @export
removeGlPolygons <- function(map, layerId) {
  leaflet::invokeMethod(map, NULL, "removeGlPolygons", layerId)
}

#' clearGlLayers
#' @description Clear all Glify features
#' @param map The map widget
#' @export
clearGlLayers <- function(map) {
  leaflet::invokeMethod(map, NULL, "clearGlLayers")
}

