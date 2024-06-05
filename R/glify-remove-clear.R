#' Remove Leaflet.Glify elements from a map
#'
#' Remove one or more features from a map, identified by `layerId`;
#' or, clear all features of the given group.
#'
#' @inheritParams leaflet::removeShape
#' @return the new `map` object
#'
#' @name remove
#' @export
removeGlPoints <- function(map, layerId) {
  leaflet::invokeMethod(map, NULL, "removeGlPoints", layerId)
}

#' @rdname remove
#' @export
removeGlPolylines <- function(map, layerId) {
  leaflet::invokeMethod(map, NULL, "removeGlPolylines", layerId)
}

#' @rdname remove
#' @export
removeGlPolygons <- function(map, layerId) {
  leaflet::invokeMethod(map, NULL, "removeGlPolygons", layerId)
}

#' @rdname remove
#' @export
clearGlLayers <- function(map) {
  leaflet::invokeMethod(map, NULL, "clearGlLayers")
}

#' @rdname remove
#' @export
clearGlGroup <- function(map, group) {
  leaflet::invokeMethod(map, NULL, "clearGlGroup", group)
}

