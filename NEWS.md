# leafgl dev-version

-   Added some @details for Shiny click and mouseover events and their corresponding input. [#77](https://github.com/r-spatial/leafgl/issues/77)
-   Use `@inheritParams leaflet::**` for identical function arguments
-   unified / simplified the dependency functions/calls

#### 🍬 miscellaneous

-   update upstream javascript dependency to 3.3.0. [#49](https://github.com/r-spatial/leafgl/issues/49)
    ⚠️If you previously used the workaround `L.glify.Shapes.instances.splice(0, 1)`, please remove it with this new version.
    

# leafgl 0.2.2 (2024-11-13)

-   Switched from `jsonify` and `geojsonsf` to `yyjsonr`
-   New method `clearGlGroup` removes a group from leaflet and the Leaflet.Glify instances.
-   The JavaScript methods of the `removeGl**` functions was rewritten to correctly remove an element identified by `layerId`
-   `clearGlLayers` now correctly removes all Leaflet.Glify instances
-   When showing/hiding Leaflet.Glify layers, they are set to active = TRUE/FALSE to make mouseevents work again. [#48](https://github.com/r-spatial/leafgl/issues/48) [#50](https://github.com/r-spatial/leafgl/issues/50)

#### 🐛 bug fixes

-   Increase precision of points, lines and shapes by translating them closer to the Pixel Origin. Thanks @RayLarone [#93](https://github.com/r-spatial/leafgl/issues/93)
-   src version now works also in shiny. [#71](https://github.com/r-spatial/leafgl/issues/71)
-   added `popupOptions` and `labelOptions`. [#83](https://github.com/r-spatial/leafgl/issues/83)
-   added `stroke` (default=TRUE) in `addGlPolygons` and `addGlPolygonsSrc` for drawing borders. [#3](https://github.com/r-spatial/leafgl/issues/3) [#68](https://github.com/r-spatial/leafgl/issues/68)
-   Labels work similar to `leaflet`. `leafgl` accepts a single string, a vector of strings or a formula. [#78](https://github.com/r-spatial/leafgl/issues/78)
-   The `...` arguments are now passed to all methods in the underlying library. This allows us to set additional arguments like `fragmentShaderSource`, `sensitivity` or `sensitivityHover`. [#81](https://github.com/r-spatial/leafgl/issues/81)

#### 💬 documentation etc

  * we now have pckgdown site - Thanks to @olivroy #102

#### 🍬 miscellaneous

  * remove obsolete .travis.yml

## leafgl 0.2.1

new features:

-   all methods can now have labels/tooltips. Currently only lines and polygons support passing of a column name, points need a predefined label vector.

miscallaneous:

  * all methods now have a pane argument to control layer ordering (thanks to @trafficonese). #67 #64

## leafgl 0.2.0

miscallaneous:

-   update upstream javascript dependency to 3.2.0

## leafgl 0.1.2

new features:

  * expose additional JavaScript arguments in addGlPoints via magic dots. #54 & #60

## leafgl 0.1.1

initial release.
