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
    json_data <- json_parser(data, ...)
  } else if (json_parser == "yyjsonr") {
    json_data <- yyjsonr::write_json_str(data, ...)
    class(json_data) <- "json"
  } else {
    json_data <- jsonify::to_json(data, ...)
  }
  return(json_data)
}
geojson_funccall <- function() {
  json_parser <- getOption("leafgl_geojson_parser", "geojsonsf")  # Default to geojsonsf
  if (is.function(json_parser)) {
    json_parser
  } else if (json_parser == "yyjsonr") {
    yyson_geojson_str
  } else {
    geojsonsf::sf_geojson
  }
}
yyson_geojson_str <- function(x, ...) {
  dt <- yyjsonr::write_geojson_str(x, ...)
  class(dt) <- "json"
  dt
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
