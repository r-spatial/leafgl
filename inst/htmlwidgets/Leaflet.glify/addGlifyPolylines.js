LeafletWidget.methods.addGlifyPolylines = function(data, cols, popup, opacity, group, weight, layerId) {

  var map = this;

    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }

    var wght;
    if (weight.length === undefined) {
      wght = weight;
    } else {
      wght = function(index, feature) { return weight[index]; };
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
            var idx = data.features.findIndex(k => k==feature);
            //set up a standalone popup (use a popup as a layer)
            if (map.hasLayer(lineslayer.glLayer)) {
              L.popup({ maxWidth: 2000 })
                .setLatLng(e.latlng)
                .setContent(popup[idx].toString())
                .openOn(map);
            }
          };
        }
    } else {
        pop = null;
    }

    var lineslayer = L.glify.lines({
      map: map,
      click: pop,
      latitudeKey: 1,
      longitudeKey: 0,
      data: data,
      color: clrs,
      opacity: opacity,
      className: group,
      weight: wght
    });

  map.layerManager.addLayer(lineslayer.glLayer, "glify", layerId, group);

};


LeafletWidget.methods.removeGlPolylines = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};

