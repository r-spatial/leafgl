LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, opacity, size) {

  var map = this;

    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }

    if (popup) {
        var pop = function (e, feature) {
          L.popup()
            .setLatLng(e.latlng)
            .setContent(feature.properties[[popup]].toString())
            .openOn(map);

          console.log(feature);
          console.log(e);
        };
    } else {
        var pop = null;
    }

    L.glify.shapes({
      map: map,
      click: pop,
      data: data,
      color: clrs,
      opacity: opacity,
      // className: "glify-pls"
    });

};
