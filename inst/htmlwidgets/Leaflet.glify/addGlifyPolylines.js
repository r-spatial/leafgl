LeafletWidget.methods.addGlifyPolylines = function(data, cols, popup, opacity, group) {

  var map = this;

    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }

    var pop;
    if (popup) {
        pop = function (e, feature) {
          if (map.hasLayer(lineslayer.glLayer)) {
            L.popup()
              .setLatLng(e.latlng)
              .setContent(feature.properties[[popup]].toString())
              .openOn(map);
          }

          console.log(feature);
          console.log(e);
        };
    } else {
        pop = null;
    }

    var lineslayer = L.glify.lines({
      map: map,
      latitudeKey: 1,
      longitudeKey: 0,
      click: pop,
      data: data,
      color: clrs,
      opacity: opacity,
      className: group
    });

  map.layerManager.addLayer(lineslayer.glLayer, null, null, group);

};
