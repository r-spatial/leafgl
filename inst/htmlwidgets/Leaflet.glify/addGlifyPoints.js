/* global LeafletWidget, L */
LeafletWidget.methods.addGlifyPoints = function(data, cols, popup, label, opacity, radius,
                                                group, layerId, dotOptions, pane,
                                                popupOptions, labelOptions) {

  const map = this;

  // colors
  let clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, point) { return cols[index]; };
  }

  // radius
  let rad;
  if (typeof(radius) === "number") {
    rad = radius;
  } else {
    rad = function(index, point) { return radius[index]; };
  }

  // click & hover function
  const clickFun = function(e, point) {
    click_event_pts(e, point, popup !== null, popup, popupOptions, pointslayer, layerId, data, map);
  };

  const tooltip = new L.Tooltip(labelOptions);
  const mouseoverFun = function(e, point) {
    hover_event_pts(e, point, label !== null, label, pointslayer, tooltip,
                    layerId, data, map);
  }

  // arguments for gl layer
  const layerArgs = {
    map: map,
    click: clickFun,
    hover: mouseoverFun,
    data: data,
    color: clrs,
    opacity: opacity,
    size: rad,
    className: group,
    pane: pane,
    hoverWait: 10,
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

