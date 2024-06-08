/* global LeafletWidget, Shiny, L */


// Remove elements by `layerId`
LeafletWidget.methods.removeGlPolylines = function(layerId) {
  let insts = L.glify.linesInstances;
  for(i in insts){
    let layId = insts[i].settings.layerId;
    if (layId) {
      let idx = layId.findIndex(k => k==layerId);
      if (idx !== -1) {
        insts[i].remove(idx);
        insts[i].settings.layerId.splice(idx, 1);
      }
    }
  }
};
LeafletWidget.methods.removeGlPolygons = function(layerId) {
  let insts = L.glify.shapesInstances;
  for (i in insts) {
    let layId = insts[i].settings.layerId;
    if (layId) {
      let idx = layId.findIndex(k => k==layerId);
      if (idx !== -1) {
        insts[i].remove(idx);
        insts[i].settings.layerId.splice(idx, 1);
      }
    }
  }
};
LeafletWidget.methods.removeGlPoints = function(layerId) {
  let insts = L.glify.pointsInstances;
  for(i in insts){
    let layId = insts[i].settings.layerId;
    if (layId) {
      let idx = layId.findIndex(k => k==layerId);
      if (idx !== -1) {
        insts[i].remove(idx);
        insts[i].settings.layerId.splice(idx, 1);
      }
    }
  }
};

// Remove all Glify elements or by Group
LeafletWidget.methods.clearGlLayers = function() {
  let arr = L.glify.shapesInstances;
  for( let i = 0; i < arr.length; i++){
    arr[i].settings.map.off("mousemove");
    arr[i].remove();
  }
  arr.splice(0, arr.length)

  arr = L.glify.linesInstances;
  for( let i = 0; i < arr.length; i++){
    arr[i].settings.map.off("mousemove");
    arr[i].remove();
  }
  arr.splice(0, arr.length)

  arr = L.glify.pointsInstances;
  for( let i = 0; i < arr.length; i++){
    arr[i].settings.map.off("mousemove");
    arr[i].remove();
  }
  arr.splice(0, arr.length)

  this.layerManager.clearLayers("glify");
};
LeafletWidget.methods.clearGlGroup = function(group) {
  const formats = ['linesInstances', 'pointsInstances', 'shapesInstances'];
  $.each(asArray(group), (j, v) => {
    formats.forEach(format => {
      let arr = L.glify[format];
      for( let i = 0; i < arr.length; i++){
        if ( arr[i].settings.className === group) {
          arr[i].settings.map.off("mousemove");
          arr[i].remove();
          arr.splice(i, 1);
        }
      }
    });
    this.layerManager.clearGroup(v);
  });
};


// Workaround to set 'active' to TRUE / FALSE, when a layer is shown/hidden via the layerControl
function addGlifyEventListeners (map) {
  if (!map.hasEventListeners("overlayadd")) {
    map.on("overlayadd", function(e) {
      let leafid = Object.keys(e.layer._layers)[0]; // L.stamp(e.layer) is not the same;
      let glifylayer = this.layerManager._byCategory.glify[leafid]
      if (glifylayer) {
        let glifyinstance = L.glify.instances.find(e => e.layer._leaflet_id == leafid);
        if (glifyinstance) {
          glifyinstance.active = true;
        }
      }
    });
  }
  if (!map.hasEventListeners("overlayremove")) {
    map.on("overlayremove", function(e) {
      let leafid = Object.keys(e.layer._layers)[0]; // L.stamp(e.layer) is not the same;
      let glifylayer = this.layerManager._byCategory.glify[leafid]
      if (glifylayer) {
        let glifyinstance = L.glify.instances.find(e => e.layer._leaflet_id == leafid);
        if (glifyinstance) {
          glifyinstance.active = false;
        }
      }
    });
  }
};

// Adapt Leaflet hide/showGroup methods, to set active = TRUE/FALSE for Glify objects.
var origHideFun = LeafletWidget.methods.hideGroup;
LeafletWidget.methods.hideGroup = function(group) {
  const map = this;
  $.each(asArray(group), (i, g) => {
    // Set Glify Instances to false
    L.glify.instances.forEach(e => {
      if (e.settings.className === g) {
          e.active = false;
      }
    });
    // Remove Layer from Leaflet
    origHideFun.call(this, group)
  });
};

var origShowFun = LeafletWidget.methods.showGroup;
LeafletWidget.methods.showGroup = function(group) {
  const map = this;
  $.each(asArray(group), (i, g) => {
    // Set Glify Instances to true
    L.glify.instances.forEach(e => {
      if (e.settings.className === g) {
          e.active = true;
      }
    });
    // Add Layer to Leaflet
    origShowFun.call(this, group)
  });
};


// Helper Functions
function click_event_pts(e, point, addpopup, popup, popupOptions, layer, layerId, data, map) {
  if (map.hasLayer(layer.layer)) {
    var idx = data.findIndex(k => k==point);
    var content = popup ? popup[idx].toString() : null;
    if (HTMLWidgets.shinyMode) {
          Shiny.setInputValue(map.id + "_glify_click", {
            id: layerId ? layerId[idx] : idx+1,
            group: layer.settings.className,
            lat: point[0],
            lng: point[1],
            data: content
          });
    }
    if (addpopup) {
      L.popup(popupOptions)
        .setLatLng(point)
        .setContent(content)
        .openOn(map);
    }
  }
};
function hover_event_pts(e, point, addlabel, label, layer, tooltip, layerId, data, map) {
  if (map.hasLayer(layer.layer)) {
    var idx = data.findIndex(k => k==point);
    var content = Array.isArray(label) ? (label[idx] ? label[idx].toString() : null) :
          typeof label === 'string' ? label : null;
    if (HTMLWidgets.shinyMode) {
          Shiny.setInputValue(map.id + "_glify_mouseover", {
            id: layerId ? layerId[idx] : idx+1,
            group: layer.settings.className,
            lat: point[0],
            lng: point[1],
            data: content
          });
    }
    if (addlabel) {
      tooltip
        .setLatLng(point)
        .setContent(content)
        .addTo(map);
    }
  }
}
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
function asArray(value) {
  if (value instanceof Array)
    return value;
  else
    return [value];
}
