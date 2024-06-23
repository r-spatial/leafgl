/* global LeafletWidget, L */
LeafletWidget.methods.addGlifyPolygonsSrc = function(cols, opacity, group,
                                                     layerId, dotOptions, pane, stroke,
                                                     popupOptions, labelOptions) {

  const map = this;

  // color
  let clrs;
  if (cols === null) {
    clrs = function(index, feature) { return col[group][0][index]; };
  } else {
    clrs = cols;
  }

  // click & hover function
  const clickFun = function (e, feature) {
    if (typeof pops !== 'undefined' && pops?.[group]?.[0]) {
      let popsrc = pops[group][0];
      popsrc = popsrc.length == 1 ? popsrc[0] : popsrc;
      click_event(e, feature, popsrc !== null, popsrc, popupOptions,
                  shapeslayer, layerId, data[group][0], map);
    }
  };

  const tooltip = new L.Tooltip(labelOptions);
  const mouseoverFun = function(e, feature) {
    if (typeof labs !== 'undefined' && labs?.[group]?.[0]) {
      let labsrc = labs[group][0];
      labsrc = labsrc.length == 1 ? labsrc[0] : labsrc;
      hover_event(e, feature, labsrc !== null, labsrc, shapeslayer, tooltip,
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
    className: group,
    border: stroke,
    pane: pane,
    hoverWait: 10,
    layerId: layerId
  };

  // append dotOptions to layer arguments
  Object.entries(dotOptions).forEach(([key,value]) => { layerArgs[key] = value });

  // initialize Glify Layer
  const shapeslayer = L.glify.shapes(layerArgs);

  // add layer to map using leaflet's layerManager
  map.layerManager.addLayer(shapeslayer.layer, "glify", layerId, group);

  addGlifyEventListeners(map)
};
