#' @examples
#' library(leaflet)
#' library(leafgl)
#' library(sf)
#'
#' gadm = st_as_sf(gadmCHE)
#' gadm = st_cast(gadm, "POLYGON")
#' cols = grey.colors(nrow(gadm))
#'
#' leaflet() %>%
#'   addProviderTiles(provider = providers$CartoDB.DarkMatter) %>%
#'   addGlPolygons(data = gadm, color = cols, popup = TRUE)
#'
#' @describeIn addGlPoints Add Polygons to a leaflet map using Leaflet.glify
#' @aliases addGlPolygons
#' @export addGlPolygons
addGlPolygons = function(map,
                         data,
                         color = cbind(0, 0.2, 1),
                         fillColor = color,
                         fillOpacity = 0.8,
                         group = "glpolygons",
                         popup = NULL,
                         label = NULL,
                         layerId = NULL,
                         src = FALSE,
                         pane = "overlayPane",
                         stroke = TRUE,
                         popupOptions = NULL,
                         labelOptions = NULL,
                         contextMenu = NULL,
                         ...) {

  # check data ##########
  if (missing(labelOptions)) labelOptions <- labelOptions()
  if (missing(popupOptions)) popupOptions <- popupOptions()

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POLYGON", "sfc_MULTIPOLYGON")))
  if (inherits(sf::st_geometry(data), "sfc_MULTIPOLYGON"))
    stop("Can only handle POLYGONs, please cast your MULTIPOLYGON to POLYGON using sf::st_cast",
         call. = FALSE)

  if (!is.null(layerId) && inherits(layerId, "formula"))
    layerId <- evalFormula(layerId, data)

  ## currently leaflet.glify only supports single (fill)opacity!
  fillOpacity = fillOpacity[1]

  # call SRC function ##############
  if (isTRUE(src)) {
    m = addGlPolygonsSrc(
      map = map
      , data = data
      , color = color
      , fillColor = fillColor
      , fillOpacity = fillOpacity
      , group = group
      , popup = popup
      , label = label
      , layerId = layerId
      , pane = pane
      , stroke = stroke
      , popupOptions = popupOptions
      , labelOptions = labelOptions
      , ...
    )
    return(m)
  }

  # get Bounds and ... #################
  dotopts = list(...)
  bounds = as.numeric(sf::st_bbox(data))

  # fillColor ###########
  if (inherits(fillColor[1], "character") && startsWith(fillColor[1], "#")) {
    cols <- color
    cols <- if(length(cols) == 1) {list(cols)} else { cols }
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
    cols = yyson_json_str(fillColor, digits = 3)
  }

  # label / popup ###########
  labels <- leaflet::evalFormula(label, data)
  if (is.null(popup)) {
    # geom = sf::st_transform(sf::st_geometry(data), crs = 4326)
    geom = sf::st_geometry(data)
    data = sf::st_sf(id = 1:length(geom), geometry = geom)
  } else if (isTRUE(popup)) {
    ## Don't do anything. Pass all columns to JS
  } else {
    htmldeps <- htmltools::htmlDependencies(popup)
    if (length(htmldeps) != 0) {
      map$dependencies = c(
        map$dependencies,
        htmldeps
      )
    }
    popup = yyson_json_str(makePopup(popup, data))
    geom = sf::st_geometry(data)
    data = sf::st_sf(id = 1:length(geom), geometry = geom)
  }

  # data ###########
  if (length(dotopts) == 0) {
    geojsonsf_args = NULL
  } else {
    geojsonsf_args = try(
      match.arg(
        names(dotopts)
        , names(as.list(args(yyjsonr::opts_write_json)))
        , several.ok = TRUE
      )
      , silent = TRUE
    )
    if (inherits(geojsonsf_args, "try-error")) geojsonsf_args = NULL
    if (identical(geojsonsf_args, "sf")) geojsonsf_args = NULL
  }
  data = do.call(yyson_geojson_str, c(list(data), "json_opts" = list(dotopts[geojsonsf_args])))

  # dependencies
  map$dependencies = c(map$dependencies, glifyDependencies())

  # invoke leaflet method and zoom to bounds ###########
  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPolygons'
    , data
    , cols
    , popup
    , labels
    , fillOpacity
    , group
    , layerId
    , dotopts
    , pane
    , stroke
    , popupOptions
    , labelOptions
    , contextMenu
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )
}



### via src
addGlPolygonsSrc = function(map,
                            data,
                            color = cbind(0, 0.2, 1),
                            fillColor = color,
                            fillOpacity = 0.6,
                            group = "glpolygons",
                            popup = NULL,
                            label = NULL,
                            layerId = NULL,
                            pane = "overlayPane",
                            stroke = TRUE,
                            popupOptions = NULL,
                            labelOptions = NULL,
                            ...) {

  # get Bounds and ... #################
  dotopts = list(...)
  bounds = as.numeric(sf::st_bbox(data))

  # temp directories ############
  dir_data = tempfile(pattern = "glify_polygons_dat")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_polygons_col")
  dir.create(dir_color)
  dir_popup = tempfile(pattern = "glify_polygons_pop")
  dir.create(dir_popup)
  dir_labels = tempfile(pattern = "glify_polylines_labl")
  dir.create(dir_labels)

  # data ############
  data_orig <- data
  geom = sf::st_geometry(data)
  data = sf::st_sf(id = 1:length(geom), geometry = geom)

  fl_data = paste0(dir_data, "/", group, "_data.js")
  pre = paste0('var data = data || {}; data["', group, '"] = ')
  writeLines(pre, fl_data)
  if (length(dotopts) != 0) {
    jsonify_args = try(
      match.arg(
        names(dotopts)
        , names(as.list(args(yyjsonr::opts_write_json)))
        , several.ok = TRUE
      )
      , silent = TRUE
    )
    if (inherits(jsonify_args, "try-error")) jsonify_args = NULL
    if (identical(jsonify_args, "sf")) jsonify_args = NULL
    dotoptslist <- c("json_opts" = list(dotopts[jsonify_args]))
  } else {
    dotoptslist <- NULL
  }
  cat('[', do.call(yyson_geojson_str, c(list(data), dotoptslist)), '];',
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
  fillColor <- makeColorMatrix(fillColor, data_orig, palette = palette)
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
    cat('[', yyson_json_str(leaflet::evalFormula(label, data_orig)), '];',
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
    cat('[', yyson_json_str(makePopup(popup, data_orig)), '];',
        file = fl_popup, append = TRUE)

    map$dependencies = c(map$dependencies, glifyAttachmentSrc(fl_popup, group, "pop"))
    popup = NULL
  }

  # invoke method ###########
  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPolygonsSrc'
    , fillColor
    , fillOpacity
    , group
    , layerId
    , dotopts
    , pane
    , stroke
    , popupOptions
    , labelOptions
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )

}


# ### via attachments ############
# addGlPolygonsFl = function(map,
#                            data,
#                            color = cbind(0, 0.2, 1),
#                            opacity = 0.6,
#                            weight = 10,
#                            group = "glpolygons",
#                            popup = NULL,
#                            ...) {
#
#   if (is.null(group)) group = deparse(substitute(data))
#   if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
#   stopifnot(inherits(sf::st_geometry(data), c("sfc_POLYGON", "sfc_MULTIPOLYGON")))
#   if (inherits(sf::st_geometry(data), "sfc_MULTIPOLYGON"))
#     stop("Can only handle POLYGONs, please cast your MULTIPOLYGON to POLYGON using sf::st_cast")
#
#   # temp directories
#   dir_data = tempfile(pattern = "glify_polygons_dt")
#   dir.create(dir_data)
#   dir_color = tempfile(pattern = "glify_polygons_cl")
#   dir.create(dir_color)
#   # dir_popup = tempfile(pattern = "glify_polygons_pop")
#   # dir.create(dir_popup)
#
#   # data
#   geom = sf::st_transform(sf::st_geometry(data), crs = 4326)
#   if (is.null(popup)) {
#     data = sf::st_sf(id = 1:length(geom),
#                      geometry = geom)
#   } else {
#     data = sf::st_transform(data[, popup], crs = 4326)
#   }
#   # crds = sf::st_coordinates(data)[, c(2, 1)]
#
#   fl_data = paste0(dir_data, "/", group, "_data.json")
#   cat(geojsonsf::sf_geojson(data), file = fl_data, append = FALSE)
#   data_var = paste0(group, "dt")
#
#   # color
#   if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
#   color = as.data.frame(color, stringsAsFactors = FALSE)
#   colnames(color) = c("r", "g", "b")
#
#   jsn = jsonify::to_json(color)
#   fl_color = paste0(dir_color, "/", group, "_color.json")
#   color_var = paste0(group, "cl")
#   cat(jsn, file = fl_color, append = FALSE)
#
#   # popup
#   # if (!is.null(popup)) {
#   #   pop = jsonlite::toJSON(data[[popup]])
#   #   fl_popup = paste0(dir_popup, "/", group, "_popup.json")
#   #   popup_var = paste0(group, "pop")
#   #   cat(pop, file = fl_popup, append = FALSE)
#   # } else {
#   #   popup_var = NULL
#   # }
#
#   # dependencies
#   map$dependencies = c(
#     map$dependencies,
#     glifyDependencies(),
#     glifyDataAttachment(fl_data, group),
#     glifyColorAttachment(fl_color, group)
#   )
#
#   # if (!is.null(popup)) {
#   #   map$dependencies = c(
#   #     map$dependencies,
#   #     glifyPopupAttachment(fl_popup, group)
#   #   )
#   # }
#
#   leaflet::invokeMethod(map, leaflet::getMapData(map), 'addGlifyPolygonsFl',
#                         data_var, color_var, popup, opacity)
#
# }
