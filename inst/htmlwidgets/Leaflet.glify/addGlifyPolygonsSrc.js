LeafletWidget.methods.addGlifyPolygonsSrc = function(group, popup_var, opacity) {

  var map = this;

    var cols = col[group][0];
    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }

    var pop;
    if (popup_var) {
        pop = function (e, feature) {
          if (map.hasLayer(shapeslayer.glLayer)) {
            L.popup()
              .setLatLng(e.latlng)
              .setContent(feature.properties[[popup_var]].toString())
              .openOn(map);
          }

          console.log(feature);
          console.log(e);
        };
    } else {
        pop = null;
    }

    var shapeslayer = L.glify.shapes({
      map: map,
      click: pop,
      data: data[group][0],
      color: clrs,
      opacity: opacity,
      className: group
    });

  map.layerManager.addLayer(shapeslayer.glLayer, null, null, group);


};
