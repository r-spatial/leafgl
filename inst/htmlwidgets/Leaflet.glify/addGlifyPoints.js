LeafletWidget.methods.addGlifyPoints = function(data, cols, popup, opacity, size) {

  var map = this;
  //var data_fl = document.getElementById(data_var + '-1-attachment' ).href;
  //var color_fl = document.getElementById(color_var + '-1-attachment' ).href;
  //if (popup_var) var popup_fl = document.getElementById(popup_var + '-1-attachment' ).href;

  //wget([data_fl, color_fl, popup_fl], function(points, colors, popups) {
    //var cols = JSON.parse(colors);
    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, point) { return cols[index]; };
    }
    //var dat = JSON.parse(points);
    //if (popup_var) var pop = JSON.parse(popups);
    L.glify.points({
      map: map,
      click: function (e, point, xy) {
        var idx = data.indexOf(point);
        //set up a standalone popup (use a popup as a layer)
        L.popup()
            .setLatLng(point)
            .setContent(popup[idx].toString())
            .openOn(map);

        console.log(point);
      },
      data: data,
      color: clrs,
      opacity: opacity,
      size: size,
      // className: "test"
    });
    //map.layerManager.addLayer(test, null, null, "test");
  //});

};
