/* global LeafletWidget, L */
LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, label,
                                                  opacity, group, layerId, dotOptions, pane,
                                                  stroke, popupOptions, labelOptions) {

  const map = this;

  // colors
  let clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, feature) { return cols[index]; };
  }

  // click & hover function
  const clickFun = function (e, feature) {
    click_event(e, feature, popup !== null, popup, popupOptions, shapeslayer, layerId, data, map);
  };

  const tooltip = new L.Tooltip(labelOptions);
  const mouseoverFun = function(e, feature) {
    hover_event(e, feature, label !== null, label, shapeslayer, tooltip,
                layerId, data, map);
  }

  // arguments for gl layer
  const layerArgs = {
    map: map,
    click: clickFun,
    hover: mouseoverFun,
    hoverOff: function(e, feat) {
      tooltip.remove();
      //if (HTMLWidgets.shinyMode) {
      //  Shiny.setInputValue(map.id + "_glify_mouseover", null);
      //}
    },
    data: data,
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




