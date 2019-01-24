# helpers
glifyDependencies = function() {
  list(
    htmltools::htmlDependency(
      "Leaflet.glify",
      '2.1.0',
      system.file("htmlwidgets/Leaflet.glify", package = "leafgl"),
      script = c(
        "addGlifyPoints.js",
        "addGlifyPolygons.js",
        "addGlifyPolylines.js",
        "glify.js",
        "src/js/canvasoverlay.js",
        "src/js/gl.js",
        "src/js/index.js",
        "src/js/map-matrix.js",
        "src/js/points.js",
        "src/js/shapes.js",
        "src/js/lines.js",
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

# helpers
glifyDependenciesFl = function() {
  list(
    htmltools::htmlDependency(
      "Leaflet.glify",
      '2.1.0',
      system.file("htmlwidgets/Leaflet.glify", package = "leafgl"),
      script = c(
        "addGlifyPoints.js",
        "addGlifyPolygonsFl.js",
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

# helpers
glifyDependenciesSrc = function() {
  list(
    htmltools::htmlDependency(
      "Leaflet.glify",
      '2.1.0',
      system.file("htmlwidgets/Leaflet.glify", package = "leafgl"),
      script = c(
        "addGlifyPoints.js",
        "addGlifyPolygonsSrc.js",
        "addGlifyPointsSrc.js",
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

glifyColorAttachmentSrc = function(fl_color, group) {
  data_dir <- dirname(fl_color)
  data_file <- basename(fl_color)
  list(
    htmltools::htmlDependency(
      name = paste0(group, "col"),
      version = 1,
      src = c(file = data_dir),
      script = list(data_file)
    )
  )
}

glifyPopupAttachmentSrc = function(fl_popup, group) {
  data_dir <- dirname(fl_popup)
  data_file <- basename(fl_popup)
  list(
    htmltools::htmlDependency(
      name = paste0(group, "pop"),
      version = 1,
      src = c(file = data_dir),
      script = list(data_file)
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
