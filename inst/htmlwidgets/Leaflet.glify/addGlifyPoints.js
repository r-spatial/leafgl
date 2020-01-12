LeafletWidget.methods.addGlifyPoints = function(data, cols, popup, opacity, size, group) {

  var map = this;

  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, point) { return cols[index]; };
  }

/*
  var pop;
  if (popup) {
      if (popup === true) {
        pop = function (e, feature) {
          var popUp = '<pre>'+JSON.stringify(feature.properties,null,' ').replace(/[\{\}"]/g,'')+'</pre>';
          if (map.hasLayer(pointslayer.glLayer)) {
            L.popup({ maxWidth: 2000 })
              .setLatLng(e.latlng)
              .setContent(popUp)
              .openOn(map);
          }
        };
      } else {
        pop = function (e, feature) {
          if (map.hasLayer(pointslayer.glLayer)) {
            L.popup({ maxWidth: 2000 })
              .setLatLng(e.latlng)
              .setContent(feature.properties[[popup]].toString())
              .openOn(map);
          }
        };
      }
  } else {
      pop = null;
  }

  var pointslayer = L.glify.points({
    map: map,
    click: pop,
    data: data,
    color: clrs,
    opacity: opacity,
    size: size,
    className: group
  });

  map.layerManager.addLayer(pointslayer.glLayer, null, null, group);
*/

    //var dat = JSON.parse(points);
    //if (popup_var) var pop = JSON.parse(popups);
    var pointslayer = L.glify.points({
      map: map,
      click: function (e, point, xy) {
        var idx = data.findIndex(k => k==point);
        //set up a standalone popup (use a popup as a layer)
        if (map.hasLayer(pointslayer.glLayer)) {
          L.popup()
            .setLatLng(point)
            .setContent(popup[idx].toString())
            .openOn(map);
        }

      },
      data: data,
      color: clrs,
      opacity: opacity,
      size: size,
      className: group
    });

  map.layerManager.addLayer(pointslayer.glLayer, null, null, group);

  //});

};
