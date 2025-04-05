#' @title Add Data to a leaflet map using Leaflet.glify
#'
#' @description
#'   Leaflet.glify is a WebGL renderer plugin for leaflet. See
#'   \url{https://github.com/robertleeplummerjr/Leaflet.glify} for details
#'   and documentation.
#'
#' @inheritParams leaflet::addPolylines
#' @param data sf/sp point/polygon/line data to add to the map.
#' @param color Object representing the color. Can be of class integer, character with
#'   color names, HEX codes or random characters, factor, matrix, data.frame, list, json or formula.
#'   See the examples or \link{makeColorMatrix} for more information.
#' @param opacity feature opacity. Numeric between 0 and 1.
#'   Note: expect funny results if you set this to < 1.
#' @param radius point size in pixels.
#' @param popup Object representing the popup. Can be of type character with column names,
#'   formula, logical, data.frame or matrix, Spatial, list or JSON. If the length does not
#'   match the number of rows in the data, the popup vector is repeated to match the dimension.
#' @param weight line width/thickness in pixels for \code{addGlPolylines}.
#' @param src whether to pass data to the widget via file attachments.
#' @param pane A string which defines the pane of the layer. The default is \code{"overlayPane"}.
#' @param ... Used to pass additional named arguments to \code{\link[yyjsonr]{write_json_str}} or
#'   \code{\link[yyjsonr]{write_geojson_str}} & to pass additional arguments to the
#'   underlying JavaScript functions. Typical use-cases include setting \code{'digits'} to
#'   round the point coordinates or to pass a different \code{'fragmentShaderSource'} to
#'   control the shape of the points. Use
#'   \itemize{
#'      \item{\code{'point'} (default) to render circles with a thin black outline}
#'      \item{\code{'simpleCircle'} for circles without outline}
#'      \item{\code{'square'} for squares without outline}
#'   }
#'   Additional arguments could be \code{'sensitivity'}, \code{'sensitivityHover'} or
#'   \code{'vertexShaderSource'}. See a full list at the
#'   \href{https://github.com/robertleeplummerjr/Leaflet.glify}{Leaflet.glify}
#'   repository.
#'
#'
#' @note
#'   MULTILINESTRINGs and MULTIPOLYGONs are currently not supported!
#'   Make sure you cast your data to LINESTRING or POLYGON first using:
#'   \itemize{
#'      \item{\code{sf::st_cast(data, "LINESTRING")}}
#'      \item{\code{sf::st_cast(data, "POLYGON")}}
#'   }
#'
#' @section Shiny Inputs:
#'   The objects created with \code{leafgl} send input values to Shiny as the
#'   user interacts with them. These events follow the pattern
#'   \code{input$MAPID_glify_EVENTNAME}.
#'   The following events are available:
#'
#'   \itemize{
#'     \item \strong{Click Events:}
#'       \code{input$MAPID_glify_click}
#'     \item \strong{Mouseover Events:}
#'       \code{input$MAPID_glify_mouseover}
#'     \item \strong{Mouseout Events:}
#'       \code{input$MAPID_glify_mouseout}
#'   }
#'
#'
#'   Each event returns a list containing:
#'   \itemize{
#'     \item \code{lat}: Latitude of the object or mouse cursor
#'     \item \code{lng}: Longitude of the object or mouse cursor
#'     \item \code{id}: The layerId, if any
#'     \item \code{group}: The group name of the object
#'     \item \code{data}: The properties of the feature
#'   }
#'
#' @describeIn addGlPoints Add Points to a leaflet map using Leaflet.glify
#' @examples \donttest{
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#'
#' n = 1e5
#' df1 = data.frame(id = 1:n,
#'                  x = rnorm(n, 10, 1),
#'                  y = rnorm(n, 49, 0.8))
#' pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
#' cols = topo.colors(nrow(pts))
#'
#' leaflet() %>%
#'   addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'   addGlPoints(data = pts, fillColor = cols, popup = TRUE)
#' }
#' @export addGlPoints
addGlPoints = function(map,
                       data,
                       fillColor = "#0033ff",
                       fillOpacity = 0.8,
                       radius = 10,
                       group = "glpoints",
                       popup = NULL,
                       label = NULL,
                       layerId = NULL,
                       src = FALSE,
                       pane = "overlayPane",
                       popupOptions = NULL,
                       labelOptions = NULL,
                       ...) {

  # check data ##########
  if (missing(labelOptions)) labelOptions <- labelOptions()
  if (missing(popupOptions)) popupOptions <- popupOptions()

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))

  if (!is.null(layerId) && inherits(layerId, "formula"))
    layerId <- evalFormula(layerId, data)

  ## currently leaflet.glify only supports single (fill)opacity!
  fillOpacity = fillOpacity[1]

  # call SRC function ##############
  if (isTRUE(src)) {
    m = addGlPointsSrc(
      map = map
      , data = data
      , fillColor = fillColor
      , fillOpacity = fillOpacity
      , radius = radius
      , group = group
      , popup = popup
      , label = label
      , layerId = layerId
      , pane = pane
      , popupOptions = popupOptions
      , labelOptions = labelOptions
      , ...
    )
    return(m)
  }

  # get Bounds and ... #################
  dotopts = list(...)
  bounds = as.numeric(sf::st_bbox(data))

  # color ###########
  if (inherits(fillColor[1], "character") && startsWith(fillColor[1], "#")) {
    fillColor <- if(length(fillColor) == 1) {list(fillColor)} else { fillColor }
  } else {
    palette = "viridis"
    if ("palette" %in% names(dotopts)) {
      palette <- dotopts$palette
      dotopts$palette = NULL
    }
    fillColor <- makeColorMatrix(fillColor, data, palette = palette)
    if (ncol(fillColor) != 3) stop("only 3 column fillColor matrix supported so far")
    fillColor = as.data.frame(fillColor, stringsAsFactors = FALSE)
    colnames(fillColor) = c("r", "g", "b")
    fillColor = yyson_json_str(fillColor, digits = 3)
  }

  # label / popup ###########
  labels <- leaflet::evalFormula(label, data)
  if (!is.null(popup)) {
    htmldeps <- htmltools::htmlDependencies(popup)
    if (length(htmldeps) != 0) {
      map$dependencies = c(
        map$dependencies,
        htmldeps
      )
    }
    popup = yyson_json_str(makePopup(popup, data))
  } else {
    popup = NULL
  }

  # data ###########
  crds = sf::st_coordinates(data)[, c(2, 1)]
  if (length(dotopts) == 0) {
    jsonify_args = NULL
  } else {
    jsonify_args = try(
      match.arg(
        names(dotopts)
        , names(as.list(args(yyjsonr::opts_write_json)))
        , several.ok = TRUE
      )
      , silent = TRUE
    )
  }
  if (inherits(jsonify_args, "try-error")) jsonify_args = NULL
  data = do.call(yyson_json_str, c(list(crds), dotopts[jsonify_args]))
  class(data) <- "json"

  # dependencies
  map$dependencies = c(map$dependencies, glifyDependencies())

  # invoke leaflet method and zoom to bounds ###########
  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPoints'
    , data
    , fillColor
    , popup
    , labels
    , fillOpacity
    , radius
    , group
    , layerId
    , dotopts
    , pane
    , popupOptions
    , labelOptions
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
                          fillColor = "#0033ff",
                          fillOpacity = 1,
                          radius = 10,
                          group = "glpoints",
                          popup = NULL,
                          label = NULL,
                          layerId = NULL,
                          pane = "overlayPane",
                          popupOptions = NULL,
                          labelOptions = NULL,
                          ...) {

  # get Bounds and ... #################
  dotopts = list(...)
  bounds = as.numeric(sf::st_bbox(data))

  # temp directories ############
  dir_data = tempfile(pattern = "glify_points_dat")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_points_col")
  dir.create(dir_color)
  dir_popup = tempfile(pattern = "glify_points_pop")
  dir.create(dir_popup)
  dir_radius = tempfile(pattern = "glify_points_rad")
  dir.create(dir_radius)
  dir_labels = tempfile(pattern = "glify_polylines_labl")
  dir.create(dir_labels)

  # data ############
  # data = sf::st_transform(data, 4326)
  crds = sf::st_coordinates(data)[, c(2, 1)]

  fl_data = paste0(dir_data, "/", group, "_data.js")
  pre = paste0('var data = data || {}; data["', group, '"] = ')
  writeLines(pre, fl_data)
  jsonify_args = try(
    match.arg(
      names(dotopts)
      , names(as.list(args(yyjsonr::opts_write_json)))
      , several.ok = TRUE
    )
    , silent = TRUE
  )
  if (inherits(jsonify_args, "try-error")) jsonify_args = NULL
  if (identical(jsonify_args, "x")) jsonify_args = NULL
  cat('[', do.call(yyson_json_str, c(list(crds), dotopts[jsonify_args])), '];',
      file = fl_data, sep = "", append = TRUE)

  map$dependencies = c(
    map$dependencies,
    glifyDependencies(TRUE),
    glifyDataAttachmentSrc(fl_data, group)
  )

  # color ############
  palette = "viridis"
  if ("palette" %in% names(dotopts)) {
    palette <- dotopts$palette
    dotopts$palette = NULL
  }
  fillColor <- makeColorMatrix(fillColor, data, palette = palette)
  if (ncol(fillColor) != 3) stop("only 3 column fillColor matrix supported so far")
  fillColor = as.data.frame(fillColor, stringsAsFactors = FALSE)
  colnames(fillColor) = c("r", "g", "b")

  if (nrow(fillColor) > 1) {
    fl_color = paste0(dir_color, "/", group, "_color.js")
    pre = paste0('var col = col || {}; col["', group, '"] = ')
    writeLines(pre, fl_color)
    cat('[', yyson_json_str(fillColor, digits = 3), '];',
        file = fl_color, append = TRUE)

    map$dependencies = c(map$dependencies, glifyAttachmentSrc(fl_color, group, "col"))
    fillColor = NULL
  }

  # labels ############
  if (!is.null(label)) {
    fl_label = paste0(dir_labels, "/", group, "_label.js")
    pre = paste0('var labs = labs || {}; labs["', group, '"] = ')
    writeLines(pre, fl_label)
    cat('[', yyson_json_str(leaflet::evalFormula(label, data)), '];',
        file = fl_label, append = TRUE)

    map$dependencies = c(map$dependencies, glifyAttachmentSrc(fl_label, group, "lab"))
    label = NULL
  }

  # popup ############
  if (!is.null(popup)) {
    htmldeps <- htmltools::htmlDependencies(popup)
    if (length(htmldeps) != 0) {
      map$dependencies = c(
        map$dependencies,
        htmldeps
      )
    }
    fl_popup = paste0(dir_popup, "/", group, "_popup.js")
    pre = paste0('var pops = pops || {}; pops["', group, '"] = ')
    writeLines(pre, fl_popup)
    cat('[', yyson_json_str(makePopup(popup, data)), '];',
        file = fl_popup, append = TRUE)

    map$dependencies = c(map$dependencies, glifyAttachmentSrc(fl_popup, group, "pop"))
    popup = NULL
  }

  # radius ############
  if (length(unique(radius)) > 1) {
    fl_radius = paste0(dir_radius, "/", layerId, "_radius.js")
    pre = paste0('var rad = rad || {}; rad["', layerId, '"] = ')
    writeLines(pre, fl_radius)
    cat('[', yyson_json_str(radius), '];',
        file = fl_radius, append = TRUE)

    map$dependencies = c(map$dependencies, glifyAttachmentSrc(fl_radius, group, "rad"))
    radius = NULL
  }

  # invoke method ###########
  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPointsSrc'
    , fillColor
    , fillOpacity
    , radius
    , group
    , layerId
    , dotopts
    , pane
    , popupOptions
    , labelOptions
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )
}


# ### via src ##############
# addGlPointsSrc2 = function(map,
#                            data,
#                            color = cbind(0, 0.2, 1),
#                            opacity = 1,
#                            weight = 10,
#                            group = "glpoints",
#                            popup = NULL,
#                            layerId = NULL,
#                            ...) {
#
#   if (is.null(group)) group = deparse(substitute(data))
#   if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
#   stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))
#
#   # temp directories
#   dir_data = tempfile(pattern = "glify_points_dat")
#   dir.create(dir_data)
#   dir_color = tempfile(pattern = "glify_points_col")
#   dir.create(dir_color)
#   dir_popup = tempfile(pattern = "glify_points_pop")
#   dir.create(dir_popup)
#
#   # data
#   data = sf::st_transform(data, 4326)
#   crds = sf::st_coordinates(data)[, c(2, 1)]
#
#   grp1 = paste0(group, "_1")
#   grp2 = paste0(group, "_2")
#
#   fl_data1 = paste0(dir_data, "/", grp1, "_data.json")
#   fl_data2 = paste0(dir_data, "/", grp2, "_data.json")
#   pre1 = paste0('var data = data || {}; data["', grp1, '"] = ')
#   writeLines(pre1, fl_data1)
#   cat('[', yyson_json_str(crds[1:100, ], ...), '];',
#       file = fl_data1, sep = "", append = TRUE)
#   pre2 = paste0('var data = data || {}; data["', grp2, '"] = ')
#   writeLines(pre2, fl_data2)
#   cat('[', yyson_json_str(crds[101:nrow(crds), ], ...), '];',
#       file = fl_data2, sep = "", append = TRUE)
#
#   # color
#   if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
#   color = as.data.frame(color, stringsAsFactors = FALSE)
#   colnames(color) = c("r", "g", "b")
#
#   fl_color = paste0(dir_color, "/", group, "_color.json")
#   pre = paste0('var col = col || {}; col["', group, '"] = ')
#   writeLines(pre, fl_color)
#   cat('[', yyson_json_str(color), '];',
#       file = fl_color, append = TRUE)
#
#   # popup
#   if (!is.null(popup)) {
#     fl_popup = paste0(dir_popup, "/", group, "_popup.json")
#     pre = paste0('var popup = popup || {}; popup["', group, '"] = ')
#     writeLines(pre, fl_popup)
#     cat('[', yyson_json_str(data[[popup]]), '];',
#         file = fl_popup, append = TRUE)
#   } else {
#     popup = NULL
#   }
#
#   # dependencies
#   map$dependencies = c(
#     map$dependencies,
#     glifyDependenciesSrc(TRUE),
#     glifyDataAttachmentSrc(fl_data1, grp1),
#     glifyDataAttachmentSrc(fl_data2, grp1, TRUE),
#     glifyAttachmentSrc(fl_color, group, "col")
#   )
#
#   if (!is.null(popup)) {
#     map$dependencies = c(map$dependencies, glifyAttachmentSrc(fl_color, group, "col"))
#   }
#
#   leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPointsSrc2',
#                         group, opacity, weight, layerId)
#
# }
#
#
#
# ### via attachments
# addGlPointsFl = function(map,
#                          data,
#                          color = cbind(0, 0.2, 1),
#                          opacity = 1,
#                          weight = 10,
#                          group = "glpoints",
#                          popup = NULL,
#                          layerId = NULL,
#                          ...) {
#
#   if (is.null(group)) group = deparse(substitute(data))
#   if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
#   stopifnot(inherits(sf::st_geometry(data), c("sfc_POINT", "sfc_MULTIPOINT")))
#
#   # temp directories
#   dir_data = tempfile(pattern = "glify_points_dt")
#   dir.create(dir_data)
#   dir_color = tempfile(pattern = "glify_points_cl")
#   dir.create(dir_color)
#   dir_popup = tempfile(pattern = "glify_points_pop")
#   dir.create(dir_popup)
#
#   # data
#   data = sf::st_transform(data, 4326)
#   crds = sf::st_coordinates(data)[, c(2, 1)]
#
#   fl_data = paste0(dir_data, "/", group, "_data.json")
#   cat(yyson_json_str(crds, digits = 7), file = fl_data, append = FALSE)
#   data_var = paste0(group, "dt")
#
#   # color
#   if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
#   color = as.data.frame(color, stringsAsFactors = FALSE)
#   colnames(color) = c("r", "g", "b")
#
#   jsn = yyson_json_str(color)
#   fl_color = paste0(dir_color, "/", group, "_color.json")
#   color_var = paste0(group, "cl")
#   cat(jsn, file = fl_color, append = FALSE)
#
#   # popup
#   if (!is.null(popup)) {
#     pop = yyson_json_str(data[[popup]])
#     fl_popup = paste0(dir_popup, "/", group, "_popup.json")
#     popup_var = paste0(group, "pop")
#     cat(pop, file = fl_popup, append = FALSE)
#   } else {
#     popup_var = NULL
#   }
#
#   # dependencies
#   map$dependencies = c(
#     map$dependencies,
#     glifyDependenciesFl(),
#     glifyDataAttachment(fl_data, group),
#     glifyColorAttachment(fl_color, group)
#   )
#
#   if (!is.null(popup)) {
#     map$dependencies = c(
#       map$dependencies,
#       glifyPopupAttachment(fl_popup, group)
#     )
#   }
#
#   leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPointsFl',
#                         data_var, color_var, popup_var, opacity, weight, layerId)
#
# }
