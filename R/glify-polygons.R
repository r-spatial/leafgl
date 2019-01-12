#' add polygons/polygons to a leaflet map using Leaflet.glify
#'
#' @details
#'   Multipolygons are currently not supported! Make sure you cast your data
#'   to polygons first (e.g. using \code{sf::st_cast(data, "POLYGON")}.
#'
#' @examples
#' \dontrun{
#' library(mapview)
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#' library(colourvalues)
#'
#' fran = st_cast(franconia, "POLYGON")
#'
#' cols = colour_values_rgb(fran$NUTS_ID, include_alpha = FALSE) / 255
#'
#' options(viewer = NULL)
#'
#' leaflet() %>%
#'   addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'   addGlPolygons(data = fran, color = cols) %>%
#'   addMouseCoordinates() %>%
#'   setView(lng = 10.5, lat = 49.5, zoom = 8)
#' }
#'
#' @describeIn addGlPoints add polygons to a leaflet map using Leaflet.glify
#' @aliases addGlPolygons
#' @export addGlPolygons
addGlPolygons = function(map,
                         data,
                         color = cbind(0, 0.2, 1),
                         opacity = 0.6,
                         group = "glpolygons",
                         popup = NULL,
                         ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POLYGON", "sfc_MULTIPOLYGON")))
  if (inherits(sf::st_geometry(data), "sfc_MULTIPOLYGON"))
    stop("Can only handle POLYGONs, please cast your MULTIPOLYGON to POLYGON using sf::st_cast")

  # data
  if (is.null(popup)) {
    geom = sf::st_transform(sf::st_geometry(data), crs = 4326)
    data = sf::st_sf(id = 1:length(geom), geometry = geom)
  } else {
    data = sf::st_transform(data[, popup], crs = 4326)
  }

  data = geojsonsf::sf_geojson(data, ...)

  # color
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  # cols = jsonlite::toJSON(color)
  cols = jsonify::to_json(color, digits = 3)

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependencies()
  )

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPolygons',
                        data, cols, popup, opacity, group)

}


### via src
addGlPolygonsSrc = function(map,
                            data,
                            color = cbind(0, 0.2, 1),
                            opacity = 0.6,
                            weight = 10,
                            group = "glpolygons",
                            popup = NULL,
                            ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POLYGON", "sfc_MULTIPOLYGON")))
  if (inherits(sf::st_geometry(data), "sfc_MULTIPOLYGON"))
    stop("Can only handle POLYGONs, please cast your MULTIPOLYGON to POLYGON using sf::st_cast")

  # temp directories
  dir_data = tempfile(pattern = "glify_polygons_dat")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_polygons_col")
  dir.create(dir_color)
  # dir_popup = tempfile(pattern = "glify_polygons_pop")
  # dir.create(dir_popup)

  # data
  geom = sf::st_transform(sf::st_geometry(data), crs = 4326)
  if (is.null(popup)) {
    data = sf::st_sf(id = 1:length(geom),
                     geometry = geom)
  } else {
    data = sf::st_transform(data[, popup], crs = 4326)
  }
  # crds = sf::st_coordinates(data)[, c(2, 1)]

  fl_data = paste0(dir_data, "/", group, "_data.json")
  pre = paste0('var data = data || {}; data["', group, '"] = ')
  writeLines(pre, fl_data)
  cat('[', geojsonsf::sf_geojson(data, ...), '];',
      file = fl_data, sep = "", append = TRUE)

  # color
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  fl_color = paste0(dir_color, "/", group, "_color.json")
  pre = paste0('var col = col || {}; col["', group, '"] = ')
  writeLines(pre, fl_color)
  cat('[', jsonlite::toJSON(color, digits = 3), '];',
      file = fl_color, append = TRUE)

  # popup
  # if (!is.null(popup)) {
  #   pop = jsonlite::toJSON(data[[popup]])
  #   fl_popup = paste0(dir_popup, "/", group, "_popup.json")
  #   popup_var = paste0(group, "pop")
  #   cat(pop, file = fl_popup, append = FALSE)
  # } else {
  #   popup_var = NULL
  # }

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependenciesSrc(),
    glifyDataAttachmentSrc(fl_data, group),
    glifyColorAttachmentSrc(fl_color, group)
  )

  # if (!is.null(popup)) {
  #   map$dependencies = c(
  #     map$dependencies,
  #     glifyPopupAttachment(fl_popup, group)
  #   )
  # }

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPolygonsSrc',
                        group, popup, opacity)

}


### via attachments
addGlPolygonsFl = function(map,
                           data,
                           color = cbind(0, 0.2, 1),
                           opacity = 0.6,
                           weight = 10,
                           group = "glpolygons",
                           popup = NULL,
                           ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POLYGON", "sfc_MULTIPOLYGON")))
  if (inherits(sf::st_geometry(data), "sfc_MULTIPOLYGON"))
    stop("Can only handle POLYGONs, please cast your MULTIPOLYGON to POLYGON using sf::st_cast")

  # temp directories
  dir_data = tempfile(pattern = "glify_polygons_dt")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_polygons_cl")
  dir.create(dir_color)
  # dir_popup = tempfile(pattern = "glify_polygons_pop")
  # dir.create(dir_popup)

  # data
  geom = sf::st_transform(sf::st_geometry(data), crs = 4326)
  if (is.null(popup)) {
    data = sf::st_sf(id = 1:length(geom),
                     geometry = geom)
  } else {
    data = sf::st_transform(data[, popup], crs = 4326)
  }
  # crds = sf::st_coordinates(data)[, c(2, 1)]

  fl_data = paste0(dir_data, "/", group, "_data.json")
  cat(geojsonsf::sf_geojson(data), file = fl_data, append = FALSE)
  data_var = paste0(group, "dt")

  # color
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  jsn = jsonlite::toJSON(color)
  fl_color = paste0(dir_color, "/", group, "_color.json")
  color_var = paste0(group, "cl")
  cat(jsn, file = fl_color, append = FALSE)

  # popup
  # if (!is.null(popup)) {
  #   pop = jsonlite::toJSON(data[[popup]])
  #   fl_popup = paste0(dir_popup, "/", group, "_popup.json")
  #   popup_var = paste0(group, "pop")
  #   cat(pop, file = fl_popup, append = FALSE)
  # } else {
  #   popup_var = NULL
  # }

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependencies(),
    glifyDataAttachment(fl_data, group),
    glifyColorAttachment(fl_color, group)
  )

  # if (!is.null(popup)) {
  #   map$dependencies = c(
  #     map$dependencies,
  #     glifyPopupAttachment(fl_popup, group)
  #   )
  # }

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPolygonsFl',
                        data_var, color_var, popup, opacity)

}
