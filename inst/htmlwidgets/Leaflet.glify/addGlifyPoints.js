LeafletWidget.methods.addGlifyPoints = function(data_var, color_var, opacity, size) {

  var map = this;
  var data_fl = document.getElementById(data_var + '-1-attachment' ).href;
  var color_fl = document.getElementById(color_var + '-1-attachment' ).href;

  wget([data_fl, color_fl], function(points, colors) {
    var cols = JSON.parse(colors);
    var dat = JSON.parse(points);
    L.glify.points({
      map: map,
      click: function (e, point, xy) {
        //set up a standalone popup (use a popup as a layer)
        L.popup()
            .setLatLng(point)
            .setContent("lon:" + point[L.glify.longitudeKey] + ', lat:' + point[L.glify.latitudeKey])
            .openOn(map);

        console.log(point);
      },
      data: dat,
      color: function(index, point) {
        return cols[index];
      },
      opacity: opacity,
      size: size
    });
  });

  function wget(urls, fn) {
    var results = [],
      complete = 0,
      total = urls.length;

    urls.forEach(function(url, i) {
      var request = new XMLHttpRequest();
      request.open('GET', url, true);
      request.onload = function () {
        if (request.status < 200 && request.status > 400) return;
        results[i] = request.responseText;
        complete++;
        if (complete === total) fn.apply(null, results);
      };
      request.send();
    });
  }
};
