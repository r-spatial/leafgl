# dependencies
glifyDependencies = function(src = FALSE) {
  src <- ifelse(src, "Src", "")
  list(
    htmltools::htmlDependency(
      "Leaflet.glify",
      '3.2.0',
      system.file("htmlwidgets/Leaflet.glify", package = "leafgl"),
      script = c(
        "GlifyUtils.js"
        , paste0("addGlifyPoints", src, ".js")
        , paste0("addGlifyPolygons", src, ".js")
        , paste0("addGlifyPolylines", src, ".js")
        , "glify-browser.js"
      )
    )
  )
}

glifyDataAttachmentSrc = function(fl_data, group, async = FALSE) {
  data_dir <- dirname(fl_data)
  data_file <- basename(fl_data)
  if (async) {
    list(
      htmltools::htmlDependency(
        name = paste0("pts_2", "dat"),
        version = 1,
        src = "",
        head = paste0('<script src="lib/', paste0(group, 'dat-1/'), data_file, '" async></script>')
      )
    )
  } else {
    list(
      htmltools::htmlDependency(
        name = paste0(group, "dat"),
        version = 1,
        src = c(file = data_dir),
        script = list(data_file)
      )
    )
  }
}

glifyAttachmentSrc <- function(fl, group, type) {
  valid_types <- c("col", "pop", "lab", "rad")
  if (!type %in% valid_types) {
    stop("Invalid type. Valid types are: col, pop, lab, rad.")
  }
  data_dir <- dirname(fl)
  data_file <- basename(fl)
  list(
    htmltools::htmlDependency(
      name = paste0(group, type),
      version = 1,
      src = c(file = data_dir),
      script = list(data_file)
    )
  )
}


# helpers
json_funccall <- function() {
  json_parser <- getOption("leafgl_json_parser", "jsonify")  # Default to jsonify
  if (is.function(json_parser)) {
    json_parser
  } else if (json_parser == "yyjsonr") {
    yyjsonr::write_json_str
  } else {
    jsonify::to_json
  }
}
convert_to_json <- function(data, ...) {
  json_parser <- getOption("leafgl_json_parser", "jsonify")  # Default to jsonify
  if (is.function(json_parser)) {
    # print("I am using a custom JSON parser function")
    json_data <- json_parser(data, ...)
  } else if (json_parser == "yyjsonr") {
    # print("I am using yyjsonr")
    json_data <- yyjsonr::write_json_str(data, ...)
    class(json_data) <- "json"
  } else {
    # print("I am using jsonify")
    json_data <- jsonify::to_json(data, ...)
  }
  return(json_data)
}



## Not used ##########
# glifyDependenciesFl = function() {
#   list(
#     htmltools::htmlDependency(
#       "Leaflet.glify",
#       '2.2.0',
#       system.file("htmlwidgets/Leaflet.glify", package = "leafgl"),
#       script = c(
#         "GlifyUtils.js"
#         , "addGlifyPoints.js"
#         , "addGlifyPolygonsFl.js"
#         , "addGlifyPolylines.js"
#         , "glify-browser.js"
#       )
#     )
#   )
# }
# glifyDataAttachment = function(fl_data, group) {
#   data_dir <- dirname(fl_data)
#   data_file <- basename(fl_data)
#   list(
#     htmltools::htmlDependency(
#       name = paste0(group, "dt"),
#       version = 1,
#       src = c(file = data_dir),
#       attachment = list(data_file)
#     )
#   )
# }
# glifyColorAttachment = function(fl_color, group) {
#   data_dir <- dirname(fl_color)
#   data_file <- basename(fl_color)
#   list(
#     htmltools::htmlDependency(
#       name = paste0(group, "cl"),
#       version = 1,
#       src = c(file = data_dir),
#       attachment = list(data_file)
#     )
#   )
# }
# glifyPopupAttachment = function(fl_popup, group) {
#   data_dir <- dirname(fl_popup)
#   data_file <- basename(fl_popup)
#   list(
#     htmltools::htmlDependency(
#       name = paste0(group, "pop"),
#       version = 1,
#       src = c(file = data_dir),
#       attachment = list(data_file)
#     )
#   )
# }

## Not used as its not faster - Needs geometries to be the last column and be named geometry
# yyjsonr_2_geojson <- function(sfdata) {
#   geom_col <- attr(sfdata, "sf_column")
#   # Rename the geometry column to "geometry" if it's not already named "geometry"
#   colndat <- names(sfdata)
#   if (geom_col != "geometry") {
#     colndat[colndat == geom_col] <- "geometry"
#   }
#   # Move the geometry column to the last position if it's not already the last column
#   col_order <- setdiff(colndat, "geometry")
#   sfdata <- sfdata[, c(col_order, "geometry")]
#   json_data <- yyjsonr::write_json_str(sfdata, digits=4)
#   json_data <- gsub("]}]", "]}}]}", fixed = TRUE,
#                     paste0('{"type":"FeatureCollection","features":[{"type":"Feature","properties":',
#                            gsub('","geometry":', '"},"geometry":{"type":"Polygon","coordinates":',
#                                 substr(json_data, 2, nchar(json_data)), fixed = TRUE)))
#   class(json_data) <- "geojson"
#   json_data
# }