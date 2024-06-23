/* global LeafletWidget, L */
LeafletWidget.methods.addGlifyPolylines = function(data, cols, popup, label,
                                                   opacity, group, weight, layerId, dotOptions, pane,
                                                   popupOptions, labelOptions) {

  const map = this;

  // colors
  let clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, feature) { return cols[index]; };
  }

  // weight
  let wght;
  if (weight.length === undefined) {
    wght = weight;
  } else {
    wght = function(index, feature) { return weight[index]; };
  }

  // click & hover function
  const clickFun = function (e, feature) {
    click_event(e, feature, popup !== null, popup, popupOptions, lineslayer, layerId, data, map);
  };

  const tooltip = new L.Tooltip(labelOptions);
  const mouseoverFun = function(e, feature) {
    hover_event(e, feature, label !== null, label, lineslayer, tooltip,
                layerId, data, map);
  }

  // arguments for gl layer
  const layerArgs = {
    map: map,
    click: clickFun,
    hover: mouseoverFun,
    hoverOff: function(e, feature) {
      hoveroff_event(e, feature, lineslayer, tooltip, layerId, data, map);
    },
    latitudeKey: 1,
    longitudeKey: 0,
    data: data,
    color: clrs,
    opacity: opacity,
    className: group,
    weight: wght,
    pane: pane,
    hoverWait: 10,
    layerId: layerId
  };

  // append dotOptions to layer arguments
  Object.entries(dotOptions).forEach(([key,value]) => { layerArgs[key] = value });

  // initialize Glify Layer
  const lineslayer = L.glify.lines(layerArgs);

  // add layer to map using leaflet's layerManager
  map.layerManager.addLayer(lineslayer.layer, "glify", layerId, group);

  addGlifyEventListeners(map)
};


