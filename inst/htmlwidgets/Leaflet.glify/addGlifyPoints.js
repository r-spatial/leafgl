LeafletWidget.methods.addGlifyPoints = function(data, cols, popup, label, opacity,
                                                radius, group, layerId, dotOptions, pane,
                                                popupOptions, labelOptions) {

  const map = this;

  // colors
  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, point) { return cols[index]; };
  }

  // radius
  var rad;
  if (typeof(radius) === "number") {
    rad = radius;
  } else {
    rad = function(index, point) { return radius[index]; };
  }

  // click & hover function
  let clickFun = (e, point, xy) => {
      //set up a standalone popup (use a popup as a layer)
      if (map.hasLayer(pointslayer.layer)) {
        var idx = data.findIndex(k => k==point);
        var content = popup ? popup[idx].toString() : null;
        if (HTMLWidgets.shinyMode) {
              Shiny.setInputValue(map.id + "_glify_click", {
                id: layerId ? layerId[idx] : idx+1,
                group: pointslayer.settings.className,
                lat: point[0],
                lng: point[1],
                data: content
              });
        }
        if (popup !== null) {
          L.popup(popupOptions)
            .setLatLng(point)
            .setContent(content)
            .openOn(map);
        }
      }
    };

  let tooltip = new L.Tooltip(labelOptions);
  var hover_event = function(e, point, addlabel, label) {
    var idx = data.findIndex(k => k==point);
      //set up a standalone label (use a label as a layer)
      if (map.hasLayer(pointslayer.layer)) {
        var content = Array.isArray(label) ? (label[idx] ? label[idx].toString() : null) :
              typeof label === 'string' ? label : null;
        if (HTMLWidgets.shinyMode) {
              Shiny.setInputValue(map.id + "_glify_mouseover", {
                id: layerId ? layerId[idx] : idx+1,
                group: pointslayer.settings.className,
                lat: point[0],
                lng: point[1],
                data: content
              });
        }
        if (label !== null) {
          tooltip
            .setLatLng(point)
            .setContent(content)
            .addTo(map);
        }
      }
  }
  var hvr = function(e, feature) {
    hover_event(e, feature, label !== null, label);
  }

  // arguments for gl layer
  var layerArgs = {
    map: map,
    click: clickFun,
    hover: hvr,
    data: data,
    color: clrs,
    opacity: opacity,
    size: rad,
    className: group,
    pane: pane
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
  var pointslayer = L.glify.points(layerArgs);

  // add layer to map using leaflet's layerManager
  map.layerManager.addLayer(pointslayer.layer, "glify", layerId, group);
};


LeafletWidget.methods.removeGlPoints = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};

LeafletWidget.methods.clearGlLayers = function() {
  this.layerManager.clearLayers("glify");
};