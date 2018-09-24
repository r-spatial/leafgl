#' add ponts to a leaflet map using Leaflet.glify
#'
#' @description
#'   Leaflet.glify is a web gl renderer plugin for leaflet. See
#'   \url{https://github.com/robertleeplummerjr/Leaflet.glify} for details
#'   and documentation. Currently not all functionality is implemented here.
#'
#' @param map a leaflet map to add points to.
#' @param data sf/sp point data to add to the map.
#' @param color a three-column rgb matrix with values between 0 and 1.
#' @param opacity point opacity. Numeric between 0 and 1.
#'   Note: expect funny results if you set this to < 1.
#' @param weight point size in pixels.
#' @param group a group name for the point layer.
#' @param popup the name of the column in data to be used for popups.
#' @param ... ignored.
#'
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




# helpers
glifyDependencies = function() {
  list(
    htmltools::htmlDependency(
      "addGlifyPoints",
      '0.0.1',
      system.file("htmlwidgets/Leaflet.glify", package = "leaflet.glify"),
      script = c(
        "addGlifyPoints.js",
        "glify.js",
        "src/js/canvasoverlay.js",
        "src/js/gl.js",
        "src/js/index.js",
        "src/js/map-matrix.js",
        "src/js/points.js",
        "src/js/shapes.js",
        "src/js/utils.js",
        "src/shader/fragment/dot.glsl",
        "src/shader/fragment/point.glsl",
        "src/shader/fragment/polygon.glsl",
        "src/shader/fragment/puck.glsl",
        "src/shader/fragment/simple-circle.glsl",
        "src/shader/fragment/aquare.glsl",
        "src/shader/vertex/default.glsl"
      )
    )
  )
}

glifyDataAttachment = function(fl_data, group) {
  data_dir <- dirname(fl_data)
  data_file <- basename(fl_data)
  list(
    htmltools::htmlDependency(
      name = paste0(group, "dt"),
      version = 1,
      src = c(file = data_dir),
      attachment = list(data_file)
    )
  )
}


glifyColorAttachment = function(fl_color, group) {
  data_dir <- dirname(fl_color)
  data_file <- basename(fl_color)
  list(
    htmltools::htmlDependency(
      name = paste0(group, "cl"),
      version = 1,
      src = c(file = data_dir),
      attachment = list(data_file)
    )
  )
}

glifyPopupAttachment = function(fl_popup, group) {
  data_dir <- dirname(fl_popup)
  data_file <- basename(fl_popup)
  list(
    htmltools::htmlDependency(
      name = paste0(group, "pop"),
      version = 1,
      src = c(file = data_dir),
      attachment = list(data_file)
    )
  )
}
