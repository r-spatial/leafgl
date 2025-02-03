deckglPointsOptions = function(
    radius = 10
    , group = "deckglpoints"
    , popup = NULL
    , label = NULL
    , layerId = NULL
    , src = FALSE
    , pane = "overlayPane"
    , ...
) {
  list(
    radius = radius
    , group = group
    , popup = popup
    , label = label
    , id = layerId
    , paneName = "overlayPane"
    , ...
  )
}

deckglBindingDependencies = function() {
  list(
    htmltools::htmlDependency(
      "deckgl-binding",
      '0.0.1',
      system.file("htmlwidgets/deckgl-binding", package = "leafgl")
      , script = c(
        "addDeckglPoints.js"
        , "addDeckglPolygons.js"
        , "addDeckglPolylines.js"
        # , "deck.gl-leaflet.js"
      )
    )
  )
}

# deckglLeafletDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "deckgl-leaflet",
#       '1.2.1',
#       system.file("htmlwidgets/deckgl-leaflet", package = "leafgl")
#       , script = c(
#         "deck.gl-leaflet.js"
#       )
#     )
#   )
# }

deckglLeafletDependencies = function() {
  list(
    htmltools::htmlDependency(
      "deck.gl-leaflet",
      '1.2.1',
      src = c(
        href = "https://cdn.jsdelivr.net/npm/deck.gl-leaflet@1.2.1/dist"
      )
      , script = "deck.gl-leaflet.min.js"
    )
  )
}

# deckglDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "deckgl",
#       '9.0.9',
#       system.file("htmlwidgets/deckgl", package = "leafgl")
#       , script = c(
#         "dist.min.js"
#       )
#     )
#   )
# }

deckglDependencies = function() {
  list(
    htmltools::htmlDependency(
      "deck.gl",
      '9.1.0',
      src = c(
        href = "https://cdn.jsdelivr.net/npm/deck.gl@9.1.0"
      )
      , script = "dist.min.js"
    )
  )
}

deckglDataAttachmentSrc = function(fn, layerId) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = layerId,
      version = '0.0.1',
      src = c(file = data_dir),
      attachment = data_file
    )
  )
}

# arrowDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "apache-arrow",
#       '16.1.0',
#       system.file("htmlwidgets/apache-arrow", package = "leafgl")
#       , script = c(
#         "Arrow.es2015.min.js"
#       )
#     )
#   )
# }

arrowDependencies = function() {
  list(
    htmltools::htmlDependency(
      "apache-arrow",
      '16.1.0',
      src = c(
        href = "https://cdn.jsdelivr.net/npm/apache-arrow@16.1.0"
      )
      , script = "Arrow.es2015.min.js"
    )
  )
}


# geoarrowDeckglLayersDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "geoarrow-deckgl-layers",
#       '0.3.0',
#       system.file("htmlwidgets/geoarrow-deckgl-layers", package = "leafgl")
#       , script = c(
#         "dist.umd.js"
#       )
#     )
#   )
# }

geoarrowDeckglLayersDependencies = function() {
  list(
    htmltools::htmlDependency(
      "geoarrow-deckgl-layers",
      '0.3.0-16',
      src = c(
        href = "https://cdn.jsdelivr.net/npm/@geoarrow/deck.gl-layers@0.3.0-beta.17/dist"
      )
      , script = "dist.umd.min.js"
    )
  )
}

# geoarrowDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "geoarrow-js",
#       '0.3.0',
#       system.file("htmlwidgets/geoarrow-js", package = "leafgl")
#       , script = c(
#         "geoarrow.umd.js"
#       )
#     )
#   )
# }

geoarrowjsDependencies = function() {
  list(
    htmltools::htmlDependency(
      "geoarrow-js",
      '0.3.0',
      src = c(
        href = "https://cdn.jsdelivr.net/npm/@geoarrow/geoarrow-js@0.3.1/dist"
      )
      , script = "geoarrow.umd.min.js"
    )
  )
}

chromajsDependencies = function() {
  list(
    htmltools::htmlDependency(
      "chromajs",
      '2.4.2',
      src = c(
        href = "https://cdn.jsdelivr.net/npm/chroma-js@2.4.2"
      )
      , script = "chroma.min.js"
    )
  )
}


# chromaJsDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "chromajs"
#       , '2.1.0'
#       , system.file("htmlwidgets/lib/chroma", package = "leafgl")
#       , script = c(
#         'chroma.min.js'
#       )
#     )
#   )
# }


# geoarrowDeckglDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "geoarrow-deckgl",
#       '0.3.0',
#       src = c(
#         href = "https://unpkg.com/@geoarrow/deck.gl-layers@0.3.0-beta.16/dist/"
#       )
#       , script = "dist.umd.js"
#     )
#   )
# }


# arrowDependencies = function() {
#   list(
#     htmltools::htmlDependency(
#       "apache-arrow",
#       '16.1.0',
#       src = c(
#         href = "https://cdn.jsdelivr.net/npm/apache-arrow@16.1.0/"
#       )
#       , script = "Arrow.es2015.min.js"
#     )
#   )
# }

