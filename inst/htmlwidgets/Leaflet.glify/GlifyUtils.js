/* global LeafletWidget, Shiny, L */

LeafletWidget.methods.removeGlPolylines = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};

LeafletWidget.methods.removeGlPolygons = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};

LeafletWidget.methods.removeGlPoints = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};


LeafletWidget.methods.clearGlLayers = function() {
  this.layerManager.clearLayers("glify");
};

function click_event(e, feature, addpopup, popup, popupOptions, layer, layerId, data, map) {
  if (map.hasLayer(layer.layer)) {
    const idx = data.features.findIndex(k => k==feature);
    if (HTMLWidgets.shinyMode) {
      Shiny.setInputValue(map.id + "_glify_click", {
        id: layerId ? layerId[idx] : idx+1,
        group: Object.values(layer.layer._eventParents)[0].groupname,
        lat: e.latlng.lat,
        lng: e.latlng.lng,
        data: feature.properties
      });
    }
    if (addpopup) {
      const content = popup === true ? json2table(feature.properties) : popup[idx].toString();

      L.popup(popupOptions)
        .setLatLng(e.latlng)
        .setContent(content)
        .openOn(map);
    }
  }
};

function hover_event(e, feature, addlabel, label, layer, tooltip, layerId, data, map) {
  if (map.hasLayer(layer.layer)) {
    const idx = data.features.findIndex(k => k==feature);
    if (HTMLWidgets.shinyMode) {
      Shiny.setInputValue(map.id + "_glify_mouseover", {
        id: layerId ? layerId[idx] : idx+1,
        group: Object.values(layer.layer._eventParents)[0].groupname,
        lat: e.latlng.lat,
        lng: e.latlng.lng,
        data: feature.properties
      });
    }
    if (addlabel) {
      const content = Array.isArray(label) ? (label[idx] ? label[idx].toString() : null) :
            typeof label === 'string' ? label : null;
      tooltip
        .setLatLng(e.latlng)
        .setContent(content)
        .addTo(map);
    }
  }
}


function json2table(json, cls) {
  const cols = Object.keys(json);
  const vals = Object.values(json);

  let tab = "";
  for (let i = 0; i < cols.length; i++) {
    tab += "<tr><th>" + cols[i] + "&emsp;</th>" +
      "<td align='right'>" + vals[i] + "&emsp;</td></tr>";
  }

  return "<table class=" + cls + ">" + tab + "</table>";
}
