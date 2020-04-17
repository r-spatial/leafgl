#' add polylines to a leaflet map using Leaflet.glify
#'
#' @details
#'   MULTILINESTRINGs are currently not supported! Make sure you cast your data
#'   to LINETSRING first (e.g. using \code{sf::st_cast(data, "LINESTRING")}.
#'
#' @examples
#' if (interactive()) {
#' library(mapview)
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#' library(colourvalues)
#'
#' trls = st_cast(trails, "LINESTRING")
#' trls = st_transform(trls, 4326)
#'
#' cols = colour_values_rgb(trls$district, include_alpha = FALSE) / 255
#'
#' options(viewer = NULL)
#'
#' leaflet() %>%
#'   addProviderTiles(provider = providers$CartoDB.Positron) %>%
#'   addGlPolylines(data = trls, color = cols, popup = "FGN", opacity = 1) %>%
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
                          weight = 1,
                          layerId = NULL,
                          ...) {

  ## currently leaflet.glify only supports single (fill)opacity!
  opacity = opacity[1]

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_LINESTRING", "sfc_MULTILINESTRING")))
  if (inherits(sf::st_geometry(data), "sfc_MULTILINESTRING"))
    stop("Can only handle LINESTRINGs, please cast your MULTILINESTRING to LINESTRING using sf::st_cast",
         call. = FALSE)

  bounds = as.numeric(sf::st_bbox(data))

  # color
  args <- list(...)
  palette = "viridis"
  if ("palette" %in% names(args)) {
    palette <- args$palette
    args$palette = NULL
  }
  color <- makeColorMatrix(color, data, palette = palette)
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  # cols = jsonlite::toJSON(color)
  cols = jsonify::to_json(color, digits = 3)

  # data
  if (is.null(popup)) {
    # geom = sf::st_transform(sf::st_geometry(data), crs = 4326)
    geom = sf::st_geometry(data)
    data = sf::st_sf(id = 1:length(geom), geometry = geom)
  } else if (isTRUE(popup)) {
    data = data[, popup]
  } else {
    htmldeps <- htmltools::htmlDependencies(popup)
    if (length(htmldeps) != 0) {
      map$dependencies = c(
        map$dependencies,
        htmldeps
      )
    }
    popup = makePopup(popup, data)
    popup = jsonify::to_json(popup)
    geom = sf::st_geometry(data)
    data = sf::st_sf(id = 1:length(geom), geometry = geom)
  }
  if (length(args) == 0) {
    geojsonsf_args = NULL
  } else {
    geojsonsf_args = match.arg(
      names(args)
      , names(as.list(args(geojsonsf::sf_geojson)))
      , several.ok = TRUE
    )
  }
  data = do.call(geojsonsf::sf_geojson, c(list(data), args[geojsonsf_args]))
  # data = geojsonsf::sf_geojson(data, ...)

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependencies()
  )

  # weight is about double the weight of svg, so / 2

  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPolylines'
    , data
    , cols
    , popup
    , opacity
    , group
    , weight
    , layerId
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )


}




