#' add points/polygons to a leaflet map using Leaflet.glify
#'
#' @description
#'   Leaflet.glify is a web gl renderer plugin for leaflet. See
#'   \url{https://github.com/robertleeplummerjr/Leaflet.glify} for details
#'   and documentation. Currently not all functionality is implemented here.
#'
#' @param map a leaflet map to add points/polygons to.
#' @param data sf/sp point/polygon data to add to the map.
#' @param color a three-column rgb matrix with values between 0 and 1.
#' @param opacity feature opacity. Numeric between 0 and 1.
#'   Note: expect funny results if you set this to < 1.
#' @param weight point size in pixels.
#' @param group a group name for the feature layer.
#' @param popup the name of the column in data to be used for popups.
#' @param ... ignored.
#'
#' @describeIn addGlifyPoints add points to a leaflet map using Leaflet.glify
#' @examples
#' \dontrun{
#' library(mapview)
#' library(leaflet)
#' library(leaflet.glify)
#' library(sf)
#' library(colourvalues)
#' library(jsonlite)
#'
#' n = 1e6
#'
#' df1 = data.frame(id = 1:n,
#'                  x = rnorm(n, 10, 1),
#'                  y = rnorm(n, 49, 0.8))
#' pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
#'
#' cols = colour_values_rgb(pts$id, include_alpha = FALSE) / 255
#'
#' options(viewer = NULL)
#'
#' system.time({
#'   m = leaflet() %>%
#'     addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'     addGlifyPoints(data = pts, color = cols, popup = "id") %>%
#'     addMouseCoordinates() %>%
#'     setView(lng = 10.5, lat = 49.5, zoom = 9)
#' })
#'
#' m
#' }
#'
#' @export
addGlifyPoints = function(map,
                          data,
                          color = cbind(0, 0.2, 1),
                          opacity = 1,
                          weight = 10,
                          group = "glpoints",
                          popup = NULL,
                          ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))

  # temp directories
  dir_data = tempfile(pattern = "glify_points_dt")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_points_cl")
  dir.create(dir_color)
  dir_popup = tempfile(pattern = "glify_points_pop")
  dir.create(dir_popup)

  # data
  data = sf::st_transform(data, 4326)
  crds = sf::st_coordinates(data)[, c(2, 1)]

  fl_data = paste0(dir_data, "/", group, "_data.json")
  cat(jsonlite::toJSON(crds, digits = 7), file = fl_data, append = FALSE)
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
  if (!is.null(popup)) {
    pop = jsonlite::toJSON(data[[popup]])
    fl_popup = paste0(dir_popup, "/", group, "_popup.json")
    popup_var = paste0(group, "pop")
    cat(pop, file = fl_popup, append = FALSE)
  } else {
    popup_var = NULL
  }

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependencies(),
    glifyDataAttachment(fl_data, group),
    glifyColorAttachment(fl_color, group)
  )

  if (!is.null(popup)) {
    map$dependencies = c(
      map$dependencies,
      glifyPopupAttachment(fl_popup, group)
    )
  }

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPoints',
                        data_var, color_var, popup_var, opacity, weight)

}
