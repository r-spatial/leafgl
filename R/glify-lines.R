#' add polylines to a leaflet map using Leaflet.glify
#'
#' @details
#'   MULTILINESTRINGs are currently not supported! Make sure you cast your data
#'   to LINETSRING first (e.g. using \code{sf::st_cast(data, "LINESTRING")}.
#'
#' @examples
#' \dontrun{
#' library(mapview)
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#' library(colourvalues)
#'
#' trls = st_cast(trails, "LINESTRING")
#'
#' cols = colour_values_rgb(trls$district, include_alpha = FALSE) / 255
#'
#' options(viewer = NULL)
#'
#' leaflet() %>%
#'   addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'   addGlPolylines(data = trls, color = cols, popup = "FGN", opacity = 1) %>%
#'   addMouseCoordinates() %>%
#'   setView(lng = 10.5, lat = 49.5, zoom = 8)
#' }
#'
#' @describeIn addGlPoints add polylines to a leaflet map using Leaflet.glify
#' @aliases addGlPolylines
#' @export addGlPolylines
addGlPolylines = function(map,
                          data,
                          color = cbind(0, 0.2, 1),
                          opacity = 0.6,
                          group = "glpolylines",
                          popup = NULL,
                          ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_LINESTRING", "sfc_MULTILINESTRING")))
  if (inherits(sf::st_geometry(data), "sfc_MULTILINESTRING"))
    stop("Can only handle LINESTRINGs, please cast your MULTILINESTRING to LINESTRING using sf::st_cast",
         call. = FALSE)

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

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPolylines',
                        data, cols, popup, opacity, group)

}
