LeafletWidget.methods.addGlifyPolylinesSrc = function(color, weight, opacity, group, layerId) {

  var map = this;

  // color
  var clrs;
  if (color === null) {
    clrs = function(index, feature) { return col[group][0][index]; };
  } else {
    clrs = color;
  }

  // radius
  var wght;
  if (weight === null) {
    wght = function(index, feature) { return wgt[group][0][index]; };
  } else {
    wght = weight;
  }

  var pop;
  if (typeof(popup) === "undefined") {
    pop = null;
  } else {
    pop = function (e, feature) {
      if (map.hasLayer(lineslayer.glLayer)) {
        var idx = data[group][0].features.findIndex(k => k==feature);
        L.popup()
          .setLatLng(e.latlng)
          .setContent(popup[group][0][idx].toString())
          .openOn(map);
      }
    };
  }

  var lineslayer = L.glify.lines({
    map: map,
    click: pop,
    latitudeKey: 1,
    longitudeKey: 0,
    data: data[group][0],
    color: clrs,
    opacity: opacity,
    weight: wght,
    className: group
  });

  map.layerManager.addLayer(lineslayer.glLayer, null, null, group);

};
