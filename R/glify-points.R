#' add points to a leaflet map using Leaflet.glify
#'
#' @description
#'   Leaflet.glify is a web gl renderer plugin for leaflet. See
#'   \url{https://github.com/robertleeplummerjr/Leaflet.glify} for details
#'   and documentation.
#'
#' @param map a leaflet map to add points/polygons to.
#' @param data sf/sp point/polygon data to add to the map.
#' @param color Object representing the color. Can be of class integer, character with
#'   color names, HEX codes or random characters, factor, matrix, data.frame, list, json or formula.
#'   See the examples or \link{makeColorMatrix} for more information.
#' @param opacity feature opacity. Numeric between 0 and 1.
#'   Note: expect funny results if you set this to < 1.
#' @param radius point size in pixels.
#' @param group a group name for the feature layer.
#' @param popup Object representing the popup. Can be of type character with column names,
#'   formula, logical, data.frame or matrix, Spatial, list or JSON. If the lenght does not
#'   match the number of rows in the dataset, the popup vector is repeated to match the dimension.
#' @param layerId the layer id
#' @param weight line width/thicknes in pixels for \code{addGlPolylines}.
#' @param ... Passed to \code{\link{to_json}{jsonify}} for the data coordinates
#'
#' @describeIn addGlPoints add points to a leaflet map using Leaflet.glify
#' @examples
#' if (interactive()) {
#' library(mapview)
#' library(leaflet)
#' library(leafgl)
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
#'     addGlPoints(data = pts, color = cols, popup = "id") %>%
#'     setView(lng = 10.5, lat = 49.5, zoom = 9)
#' })
#'
#' m
#' }
#'
#' @export addGlPoints
addGlPoints = function(map,
                       data,
                       color = cbind(0, 0.2, 1),
                       opacity = 1,
                       radius = 10,
                       group = "glpoints",
                       popup = NULL,
                       layerId = NULL,
                       ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))

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

  # color = jsonlite::toJSON(color)
  color = jsonify::to_json(color)

  # popup
  if (!is.null(popup)) {
    htmldeps <- htmltools::htmlDependencies(popup)
    if (length(htmldeps) != 0) {
      map$dependencies = c(
        map$dependencies,
        htmldeps
      )
    }
    popup = makePopup(popup, data)
    # popup = jsonlite::toJSON(data[[popup]])
    popup = jsonify::to_json(popup)
  } else {
    popup = NULL
  }

  # data
  # data = sf::st_transform(data, 4326)
  crds = sf::st_coordinates(data)[, c(2, 1)]
  # convert data to json
  # data = jsonlite::toJSON(crds, digits = 7)
  if (length(args) == 0) {
    jsonify_args = NULL
  } else {
    jsonify_args = match.arg(
      names(args)
      , names(as.list(args(jsonify::to_json)))
      , several.ok = TRUE
    )
  }
  data = do.call(jsonify::to_json, c(list(crds), args[jsonify_args]))

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependencies()
  )


  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPoints'
    , data
    , color
    , popup
    , opacity
    , radius
    , group
    , layerId
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )


}


### via src
addGlPointsSrc = function(map,
                          data,
                          color = cbind(0, 0.2, 1),
                          opacity = 1,
                          weight = 10,
                          group = "glpoints",
                          popup = NULL,
                          layerId = NULL,
                          ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))

  # temp directories
  dir_data = tempfile(pattern = "glify_points_dat")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_points_col")
  dir.create(dir_color)
  dir_popup = tempfile(pattern = "glify_points_pop")
  dir.create(dir_popup)

  # data
  data = sf::st_transform(data, 4326)
  crds = sf::st_coordinates(data)[, c(2, 1)]

  fl_data = paste0(dir_data, "/", group, "_data.json")
  pre = paste0('var data = data || {}; data["', group, '"] = ')
  writeLines(pre, fl_data)
  cat('[', jsonify::to_json(crds), '];',
      file = fl_data, sep = "", append = TRUE)

  # color
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  fl_color = paste0(dir_color, "/", group, "_color.json")
  pre = paste0('var col = col || {}; col["', group, '"] = ')
  writeLines(pre, fl_color)
  cat('[', jsonify::to_json(color), '];',
      file = fl_color, append = TRUE)

  # popup
  if (!is.null(popup)) {
    fl_popup = paste0(dir_popup, "/", group, "_popup.json")
    pre = paste0('var popup = popup || {}; popup["', group, '"] = ')
    writeLines(pre, fl_popup)
    cat('[', jsonify::to_json(data[[popup]]), '];',
        file = fl_popup, append = TRUE)
  } else {
    popup = NULL
  }

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependenciesSrc(),
    glifyDataAttachmentSrc(fl_data, group),
    glifyColorAttachmentSrc(fl_color, group)
  )

  if (!is.null(popup)) {
    map$dependencies = c(
      map$dependencies,
      glifyPopupAttachmentSrc(fl_popup, group)
    )
  }

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPointsSrc',
                        group, opacity, weight, layerId)

}


### via src
addGlPointsSrc2 = function(map,
                           data,
                           color = cbind(0, 0.2, 1),
                           opacity = 1,
                           weight = 10,
                           group = "glpoints",
                           popup = NULL,
                           layerId = NULL,
                           ...) {

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))

  # temp directories
  dir_data = tempfile(pattern = "glify_points_dat")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_points_col")
  dir.create(dir_color)
  dir_popup = tempfile(pattern = "glify_points_pop")
  dir.create(dir_popup)

  # data
  data = sf::st_transform(data, 4326)
  crds = sf::st_coordinates(data)[, c(2, 1)]

  grp1 = paste0(group, "_1")
  grp2 = paste0(group, "_2")

  fl_data1 = paste0(dir_data, "/", grp1, "_data.json")
  fl_data2 = paste0(dir_data, "/", grp2, "_data.json")
  pre1 = paste0('var data = data || {}; data["', grp1, '"] = ')
  writeLines(pre1, fl_data1)
  cat('[', jsonify::to_json(crds[1:100, ], ...), '];',
      file = fl_data1, sep = "", append = TRUE)
  pre2 = paste0('var data = data || {}; data["', grp2, '"] = ')
  writeLines(pre2, fl_data2)
  cat('[', jsonify::to_json(crds[101:nrow(crds), ], ...), '];',
      file = fl_data2, sep = "", append = TRUE)

  # color
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  fl_color = paste0(dir_color, "/", group, "_color.json")
  pre = paste0('var col = col || {}; col["', group, '"] = ')
  writeLines(pre, fl_color)
  cat('[', jsonify::to_json(color), '];',
      file = fl_color, append = TRUE)

  # popup
  if (!is.null(popup)) {
    fl_popup = paste0(dir_popup, "/", group, "_popup.json")
    pre = paste0('var popup = popup || {}; popup["', group, '"] = ')
    writeLines(pre, fl_popup)
    cat('[', jsonify::to_json(data[[popup]]), '];',
        file = fl_popup, append = TRUE)
  } else {
    popup = NULL
  }

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependenciesSrc(),
    glifyDataAttachmentSrc(fl_data1, grp1),
    glifyDataAttachmentSrc(fl_data2, grp1, TRUE),
    glifyColorAttachmentSrc(fl_color, group)
  )

  if (!is.null(popup)) {
    map$dependencies = c(
      map$dependencies,
      glifyPopupAttachmentSrc(fl_popup, group)
    )
  }

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPointsSrc2',
                        group, opacity, weight, layerId)

}



### via attachments
addGlPointsFl = function(map,
                         data,
                         color = cbind(0, 0.2, 1),
                         opacity = 1,
                         weight = 10,
                         group = "glpoints",
                         popup = NULL,
                         layerId = NULL,
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
  cat(jsonify::to_json(crds, digits = 7), file = fl_data, append = FALSE)
  data_var = paste0(group, "dt")

  # color
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")

  jsn = jsonify::to_json(color)
  fl_color = paste0(dir_color, "/", group, "_color.json")
  color_var = paste0(group, "cl")
  cat(jsn, file = fl_color, append = FALSE)

  # popup
  if (!is.null(popup)) {
    pop = jsonify::to_json(data[[popup]])
    fl_popup = paste0(dir_popup, "/", group, "_popup.json")
    popup_var = paste0(group, "pop")
    cat(pop, file = fl_popup, append = FALSE)
  } else {
    popup_var = NULL
  }

  # dependencies
  map$dependencies = c(
    map$dependencies,
    glifyDependenciesFl(),
    glifyDataAttachment(fl_data, group),
    glifyColorAttachment(fl_color, group)
  )

  if (!is.null(popup)) {
    map$dependencies = c(
      map$dependencies,
      glifyPopupAttachment(fl_popup, group)
    )
  }

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPointsFl',
                        data_var, color_var, popup_var, opacity, weight, layerId)

}
