#' @examples
#' library(leaflet)
#' library(sf)
#'
#' storms = st_as_sf(atlStorms2005)
#' cols = heat.colors(nrow(storms))
#'
#' leaflet() %>%
#'   addProviderTiles(provider = providers$CartoDB.Positron) %>%
#'   addGlPolylines(data = storms, color = cols, popup = TRUE, opacity = 1)
#'
#' @describeIn addGlPoints Add Lines to a leaflet map using Leaflet.glify
#' @aliases addGlPolylines
#' @order 2
#' @export addGlPolylines
addGlPolylines = function(map,
                          data,
                          color = cbind(0, 0.2, 1),
                          opacity = 0.6,
                          group = "glpolylines",
                          popup = NULL,
                          label = NULL,
                          weight = 1,
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
  stopifnot(inherits(sf::st_geometry(data), c("sfc_LINESTRING", "sfc_MULTILINESTRING")))
  if (inherits(sf::st_geometry(data), "sfc_MULTILINESTRING"))
    stop("Can only handle LINESTRINGs, please cast your MULTILINESTRING to LINESTRING using sf::st_cast",
         call. = FALSE)

  if (!is.null(layerId) && inherits(layerId, "formula"))
    layerId <- evalFormula(layerId, data)

  ## currently leaflet.glify only supports single (fill)opacity!
  opacity = opacity[1]

  # call SRC function ##############
  if (isTRUE(src)) {
    m = addGlPolylinesSrc(
      map = map
      , data = data
      , color = color
      , opacity = opacity
      , group = group
      , popup = popup
      , label = label
      , weight = weight
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

  # color ########
  palette = "viridis"
  if ("palette" %in% names(dotopts)) {
    palette <- dotopts$palette
    dotopts$palette = NULL
  }
  color <- makeColorMatrix(color, data, palette = palette)
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")
  cols = jsonify::to_json(color, digits = 3)

  # label / popup ########
  labels <- leaflet::evalFormula(label, data)
  if (is.null(popup)) {
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
    popup = makePopup(popup, data)
    popup = jsonify::to_json(popup)
    geom = sf::st_geometry(data)
    data = sf::st_sf(id = 1:length(geom), geometry = geom)
  }

  # data ########
  if (length(dotopts) == 0) {
    geojsonsf_args = NULL
  } else {
    geojsonsf_args = try(
      match.arg(
        names(dotopts)
        , names(as.list(args(geojsonsf::sf_geojson)))
        , several.ok = TRUE
      )
      , silent = TRUE
    )
    if (inherits(geojsonsf_args, "try-error")) geojsonsf_args = NULL
    if (identical(geojsonsf_args, "sf")) geojsonsf_args = NULL
  }
  data = do.call(geojsonsf::sf_geojson, c(list(data), dotopts[geojsonsf_args]))

  # dependencies
  map$dependencies = c(map$dependencies, glifyDependencies())

  # invoke leaflet method and zoom to bounds ########
  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPolylines'
    , data
    , cols
    , popup
    , labels
    , opacity
    , group
    , weight
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
addGlPolylinesSrc = function(map,
                             data,
                             color = cbind(0, 0.2, 1),
                             opacity = 0.8,
                             group = "glpolygons",
                             popup = NULL,
                             label = NULL,
                             weight = 1,
                             layerId = NULL,
                             pane = "overlayPane",
                             popupOptions = NULL,
                             labelOptions = NULL,
                             ...) {

  # get Bounds and ... #################
  dotopts = list(...)
  bounds = as.numeric(sf::st_bbox(data))

  # temp directories ############
  dir_data = tempfile(pattern = "glify_polylines_dat")
  dir.create(dir_data)
  dir_color = tempfile(pattern = "glify_polylines_col")
  dir.create(dir_color)
  dir_weight = tempfile(pattern = "glify_polylines_wgt")
  dir.create(dir_weight)
  dir_popup = tempfile(pattern = "glify_polylines_pop")
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
  jsonify_args = try(
    match.arg(
      names(dotopts)
      , names(as.list(args(geojsonsf::sf_geojson)))
      , several.ok = TRUE
    )
    , silent = TRUE
  )
  if (inherits(jsonify_args, "try-error")) jsonify_args = NULL
  if (identical(jsonify_args, "sf")) jsonify_args = NULL
  cat('[', do.call(geojsonsf::sf_geojson, c(list(data), dotopts[jsonify_args])), '];',
      file = fl_data, sep = "", append = TRUE)

  map$dependencies = c(
    map$dependencies,
    glifyDependenciesSrc(),
    glifyDataAttachmentSrc(fl_data, group)
  )

  # color ############
  palette = "viridis"
  if ("palette" %in% names(dotopts)) {
    palette <- dotopts$palette
    dotopts$palette = NULL
  }
  color <- makeColorMatrix(color, data_orig, palette = palette)
  if (ncol(color) != 3) stop("only 3 column color matrix supported so far")
  color = as.data.frame(color, stringsAsFactors = FALSE)
  colnames(color) = c("r", "g", "b")
  if (nrow(color) > 1) {
    fl_color = paste0(dir_color, "/", group, "_color.js")
    pre = paste0('var col = col || {}; col["', group, '"] = ')
    writeLines(pre, fl_color)
    cat('[', jsonify::to_json(color), '];',
        file = fl_color, append = TRUE)

    map$dependencies = c(
      map$dependencies,
      glifyColorAttachmentSrc(fl_color, group)
    )
    color = NULL
  }

  # labels ############
  if (!is.null(label)) {
    labels <- leaflet::evalFormula(label, data_orig)
    fl_label = paste0(dir_labels, "/", group, "_label.js")
    pre = paste0('var labs = labs || {}; labs["', group, '"] = ')
    writeLines(pre, fl_label)
    cat('[', jsonify::to_json(labels), '];',
        file = fl_label, append = TRUE)

    map$dependencies = c(
      map$dependencies,
      glifyLabelAttachmentSrc(fl_label, group)
    )
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
    popup = makePopup(popup, data_orig)
    fl_popup = paste0(dir_popup, "/", group, "_popup.js")
    pre = paste0('var pops = pops || {}; pops["', group, '"] = ')
    writeLines(pre, fl_popup)
    cat('[', jsonify::to_json(popup), '];',
        file = fl_popup, append = TRUE)

    map$dependencies = c(
      map$dependencies,
      glifyPopupAttachmentSrc(fl_popup, group)
    )
    popup = NULL
  }

  # weight ############
  if (length(unique(weight)) > 1) {
    fl_weight = paste0(dir_weight, "/", group, "_weight.js")
    pre = paste0('var wgt = wgt || {}; wgt["', group, '"] = ')
    writeLines(pre, fl_weight)
    cat('[', jsonify::to_json(weight), '];',
        file = fl_weight, append = TRUE)

    map$dependencies = c(
      map$dependencies,
      glifyRadiusAttachmentSrc(fl_weight, group)
    )
    weight = NULL
  }

  # invoke method ###########
  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGlifyPolylinesSrc'
    , color
    , opacity
    , group
    , weight
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

