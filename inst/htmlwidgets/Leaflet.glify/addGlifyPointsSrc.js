LeafletWidget.methods.addGlifyPointsSrc = function(group, opacity, size) {

  var map = this;

    var cols = col[group][0];
    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }
    var pointslayer = L.glify.points({
      map: map,
      click: function (e, point, xy) {
        //var idx = data[group][0].indexOf(point);
        var idx = data[group][0].findIndex(k => k==point);
        //set up a standalone popup (use a popup as a layer)
        if (map.hasLayer(pointslayer.glLayer)) {
          L.popup()
            .setLatLng(point)
            .setContent(popup[group][0][idx].toString())
            .openOn(map);
        }

        console.log(point);

      },
      data: data[group][0],
      color: clrs,
      opacity: opacity,
      size: size,
      className: group
    });

  map.layerManager.addLayer(pointslayer.glLayer, null, null, group);

};


LeafletWidget.methods.addGlifyPointsSrc2 = function(group, opacity, size) {

  var map = this;
  var grp1 = group + "_1";
  var grp2 = group + "_2";
  //data[grp1][0] = data[grp1][0].concat(data[grp2][0]);
    var cols = col[group][0];
    var clrs;
    if (cols.length === 1) {
      clrs = cols[0];
    } else {
      clrs = function(index, feature) { return cols[index]; };
    }
    var pointslayer = L.glify.points({
      map: map,
      click: function (e, point, xy) {
        //var idx = data[group][0].indexOf(point);
        var idx = data[group][0].findIndex(k => k==point);
        //set up a standalone popup (use a popup as a layer)
        if (map.hasLayer(pointslayer.glLayer)) {
          L.popup()
            .setLatLng(point)
            .setContent(popup[group][0][idx].toString())
            .openOn(map);
        }

        console.log(point);

      },
      data: data[grp1][0],
      color: clrs,
      opacity: opacity,
      size: size,
      className: group
    });

  map.layerManager.addLayer(pointslayer.glLayer, null, null, group);

  function add() {
        if (typeof data[grp2] === 'undefined') {
            setTimeout(function () {
                add();
            }, 0.1);
        } else {
            var pointslayer2 = L.glify.points({
              map: map,
              click: function (e, point, xy) {
                //var idx = data[group][0].indexOf(point);
                var idx = data[group][0].findIndex(k => k==point);
                //set up a standalone popup (use a popup as a layer)
                if (map.hasLayer(pointslayer.glLayer)) {
                  L.popup()
                    .setLatLng(point)
                    .setContent(popup[group][0][idx].toString())
                    .openOn(map);
                }

                console.log(point);

              },
              data: data[grp2][0],
              color: clrs,
              opacity: opacity,
              size: size,
              className: group
            });

           map.layerManager.addLayer(pointslayer2.glLayer, null, null, group);
        }
    }

   add();

};

