LeafletWidget.methods.addGlifyPolylines = function(data, cols, popup, opacity, group, weight) {

  var map = this;

    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }

    var pop;
    if (popup) {
        if (popup === true) {
          pop = function (e, feature) {
            var popUp = '<pre>'+JSON.stringify(feature.properties,null,' ').replace(/[\{\}"]/g,'')+'</pre>';
            if (map.hasLayer(lineslayer.glLayer)) {
              L.popup({ maxWidth: 2000 })
                .setLatLng(e.latlng)
                .setContent(popUp)
                .openOn(map);
            }
          };
        } else {
          pop = function (e, feature) {
            if (map.hasLayer(lineslayer.glLayer)) {
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


    var lineslayer = L.glify.lines({
      map: map,
      latitudeKey: 1,
      longitudeKey: 0,
      click: pop,
      data: data,
      color: clrs,
      opacity: opacity,
      className: group,
      weight: weight
    });

  map.layerManager.addLayer(lineslayer.glLayer, null, null, group);

};
