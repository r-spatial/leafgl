/* global LeafletWidget, L */
LeafletWidget.methods.addGlifyPointsSrc = function(cols, opacity, radius, group,
                                                   layerId, dotOptions, pane,
                                                   popupOptions, labelOptions) {

  const map = this;

  // color
  let clrs;
  if (cols === null) {
    clrs = function(index, feature) { return col[group][0][index]; };
  } else {
    clrs = cols;
  }

  // radius
  let rad;
  if (radius === null) {
    rad = function(index, point) { return rad[group][0][index]; };
  } else {
    rad = radius;
  }

  // click & hover function
  const clickFun = function(e, point) {
    if (typeof pops !== 'undefined' && pops?.[group]?.[0]) {
      let popsrc = pops[group][0];
      popsrc = popsrc.length == 1 ? popsrc[0] : popsrc;
      click_event_pts(e, point, popsrc !== null, popsrc, popupOptions,
                      pointslayer, layerId, data[group][0], map);
    }
  };

  const tooltip = new L.Tooltip(labelOptions);
  const mouseoverFun = function(e, point) {
    if (typeof labs !== 'undefined' && labs?.[group]?.[0]) {
      let labsrc = labs[group][0];
      labsrc = labsrc.length == 1 ? labsrc[0] : labsrc;
      hover_event_pts(e, point, labsrc !== null, labsrc, pointslayer, tooltip,
                      layerId, data[group][0], map);
    }
  }

  // arguments for gl layer
  const layerArgs = {
    map: map,
    click: clickFun,
    hover: mouseoverFun,
    data: data[group][0],
    color: clrs,
    opacity: opacity,
    size: rad,
    className: group,
    pane: pane,
    layerId: layerId
  };

  // extract correct fragmentShaderSource if provided via dotOptions
  if (dotOptions.fragmentShaderSource !== undefined && dotOptions.fragmentShaderSource !== null) {
    let fragmentShader = dotOptions.fragmentShaderSource;
    dotOptions.fragmentShaderSource = () => {
      return L.glify.shader.fragment[fragmentShader];
    };
  }

  // append dotOptions to layer arguments
  Object.entries(dotOptions).forEach(([key,value]) => { layerArgs[key] = value });

  // initialize Glify Layer
  const pointslayer = L.glify.points(layerArgs);

  // add layer to map using leaflet's layerManager
  map.layerManager.addLayer(pointslayer.layer, "glify", layerId, group);

  addGlifyEventListeners(map)
};


/*
LeafletWidget.methods.addGlifyPointsSrc2 = function(group, opacity, size, layerId) {

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
        if (map.hasLayer(pointslayer.layer)) {
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

  map.layerManager.addLayer(pointslayer.layer, "glify", layerId, group);

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
                if (map.hasLayer(pointslayer.layer)) {
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

           map.layerManager.addLayer(pointslayer2.layer, "glify", null, group);
        }
    }

   add();

};
*/
