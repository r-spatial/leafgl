# Remove Leaflet.Glify elements from a map

Remove one or more features from a map, identified by \`layerId\`; or,
clear all features of the given group.

## Usage

``` r
removeGlPoints(map, layerId)

removeGlPolylines(map, layerId)

removeGlPolygons(map, layerId)

clearGlLayers(map)

clearGlGroup(map, group)
```

## Arguments

- map:

  a map widget object, possibly created from
  [`leaflet()`](https://rstudio.github.io/leaflet/reference/leaflet.html)
  but more likely from
  [`leafletProxy()`](https://rstudio.github.io/leaflet/reference/leafletProxy.html)

- layerId:

  character vector; the layer id(s) of the item to remove

- group:

  the name of the group whose members should be removed

## Value

the new \`map\` object
