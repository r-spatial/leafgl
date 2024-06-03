LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, label,
                                                  opacity, group, layerId, dotOptions, pane,
                                                  stroke, popupOptions, labelOptions) {

  var map = this;

  // colors
  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, feature) { return cols[index]; };
  }

  // click & hover function
  var click_event = function(e, feature, addpopup, popup) {
    if (map.hasLayer(shapeslayer.layer)) {
      var idx = data.features.findIndex(k => k==feature);
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(map.id + "_glify_click", {
          id: layerId ? layerId[idx] : idx+1,
          group: Object.values(shapeslayer.layer._eventParents)[0].groupname,
          lat: e.latlng.lat,
          lng: e.latlng.lng,
          data: feature.properties
        });
      }
      if (addpopup) {
        var content = popup === true ? json2table(feature.properties) : popup[idx].toString();

        L.popup(popupOptions)
          .setLatLng(e.latlng)
          .setContent(content)
          .openOn(map);
      }
    }
  };
  var clickFun = function (e, feature) {
    click_event(e, feature, popup !== null, popup);
  };

  let tooltip = new L.Tooltip(labelOptions);
  var hover_event = function(e, feature, addlabel, label) {
    if (map.hasLayer(shapeslayer.layer)) {
      var idx = data.features.findIndex(k => k==feature);
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(map.id + "_glify_mouseover", {
            id: layerId ? layerId[idx] : idx+1,
            group: Object.values(shapeslayer.layer._eventParents)[0].groupname,
            lat: e.latlng.lat,
            lng: e.latlng.lng,
            data: feature.properties
        });
      }
      if (addlabel) {
        var content = Array.isArray(label) ? (label[idx] ? label[idx].toString() : null) :
              typeof label === 'string' ? label : null;
        tooltip
          .setLatLng(e.latlng)
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
    className: group,
    border: stroke,
    pane: pane
  };

  // append dotOptions to layer arguments
  Object.entries(dotOptions).forEach(([key,value]) => { layerArgs[key] = value });

  // initialize Glify Layer
  var shapeslayer = L.glify.shapes(layerArgs);

  // add layer to map using leaflet's layerManager
  map.layerManager.addLayer(shapeslayer.layer, "glify", layerId, group);
};


LeafletWidget.methods.removeGlPolygons = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};



function json2table(json, cls) {
  var cols = Object.keys(json);
  var vals = Object.values(json);

  var tab = "";

  for (let i = 0; i < cols.length; i++) {
    tab += "<tr><th>" + cols[i] + "&emsp;</th>" +
    "<td align='right'>" + vals[i] + "&emsp;</td></tr>";
  }

  return "<table class=" + cls + ">" + tab + "</table>";

}
