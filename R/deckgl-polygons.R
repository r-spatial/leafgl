addDeckglPolygons = function(map,
                             data,
                             fillColor = "#0033ff",
                             fillOpacity = 0.8,
                             radius = 10,
                             group = "deckglpoints",
                             popup = NULL,
                             label = NULL,
                             layerId = NULL,
                             src = FALSE,
                             pane = "overlayPane",
                             ...) {

  dotopts = list(...)

  geom_colname = attr(data, which = "sf_colum")

  if (is.null(layerId)) layerId = group
  layerId = gsub("[[:punct:] ]", "_", layerId)
  radius_column = inherits(radius, "character") && radius %in% colnames(data)
  min_rad = ifelse(radius_column, min(data[[radius]], na.rm = TRUE), 10)
  max_rad = ifelse(radius_column, max(data[[radius]], na.rm = TRUE), 10)

  # if (isTRUE(src)) {
  #   m = addDECKglPointsSrc(
  #     map = map
  #     , data = data
  #     , fillColor = fillColor
  #     , fillOpacity = fillOpacity
  #     , radius = radius
  #     , group = group
  #     , popup = popup
  #     , layerId = layerId
  #     , pane = pane
  #     , ...
  #   )
  #   return(m)
  # }

  ## currently we only support single (fill)opacity!
  fillOpacity = fillOpacity[1]

  if (is.null(group)) group = deparse(substitute(data))
  if (inherits(data, "Spatial")) data <- sf::st_as_sf(data)
  # data = sf::st_cast(data, "POLYGON")
  stopifnot(inherits(sf::st_geometry(data), c("sfc_POLYGON", "sfc_MULTIPOLYGON")))

  bounds = as.numeric(sf::st_bbox(data))

  # fillColor
  args <- list(...)
  # palette = "viridis"
  # if ("palette" %in% names(args)) {
  #   palette <- args$palette
  #   args$palette = NULL
  # }
  # fillColor <- makeColorMatrix(fillColor, data, palette = palette)
  # if (ncol(fillColor) != 3) stop("only 3 column fillColor matrix supported so far")
  # fillColor = as.data.frame(fillColor, stringsAsFactors = FALSE)
  # colnames(fillColor) = c("r", "g", "b")

  # fillColor = jsonify::to_json(c(as.vector(col2rgb(fillColor)), fillOpacity * 255))

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
    popup = jsonify::to_json(popup)
  } else {
    popup = NULL
  }

  # data
  # data = sf::st_transform(data, 4326)
  # crds = sf::st_coordinates(data)[, c(2, 1)]
  # convert data to json
  # if (length(args) == 0) {
  #   jsonify_args = NULL
  # } else {
  #   jsonify_args = try(
  #     match.arg(
  #       names(args)
  #       , names(as.list(args(jsonify::to_json)))
  #       , several.ok = TRUE
  #     )
  #     , silent = TRUE
  #   )
  # }
  # if (inherits(jsonify_args, "try-error")) jsonify_args = NULL
  # data = do.call(jsonify::to_json, c(list(crds), args[jsonify_args]))

  # if (length(args) == 0) {
  #   yyjson_args = NULL
  # } else {
  #   yyjson_args = try(
  #     match.arg(
  #       names(args)
  #       , names(as.list(args(yyjsonr::write_json_str)))
  #       , several.ok = TRUE
  #     )
  #     , silent = TRUE
  #   )
  # }
  # if (inherits(yyjson_args, "try-error")) yyjson_args = NULL
  # data = do.call(yyjsonr::write_json_str, c(list(data), args[yyjson_args]))

  path_layer = tempfile()
  dir.create(path_layer)
  path_layer = paste0(path_layer, "/", layerId, "_layer.arrow")

  geom_col_name <- attr(data, "sf_column")
  geom_type <- geoarrow::infer_geoarrow_schema(data, coord_type = "INTERLEAVED")
  data_schema <- nanoarrow::infer_nanoarrow_schema(data)
  data_schema$children[[geom_col_name]] <- geom_type

  data_out = nanoarrow::as_nanoarrow_array_stream(
    data
    , schema = data_schema
  )

  nanoarrow::write_nanoarrow(data_out, path_layer)


  # dependencies
  map$dependencies = c(
    map$dependencies
    , arrowDependencies()
    , geoarrowjsDependencies()
    , deckglDependencies()
    , geoarrowDeckglLayersDependencies()
    , deckglLeafletDependencies()
    , deckglDataAttachmentSrc(path_layer, layerId)
    , deckglBindingDependencies()
    , chromajsDependencies()
  )


  map = leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addDeckglPolygons'
    , geom_colname
    , fillColor
    , popup
    , label
    , fillOpacity
    , radius
    , min_rad
    , max_rad
    , group
    , layerId
    , dotopts
    , pane
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )
}
