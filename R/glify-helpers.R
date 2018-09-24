# helpers
glifyDependencies = function() {
  list(
    htmltools::htmlDependency(
      "addGlifyPoints",
      '0.0.1',
      system.file("htmlwidgets/Leaflet.glify", package = "leaflet.glify"),
      script = c(
        "addGlifyPoints.js",
        "addGlifyPolygons.js",
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
