LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, opacity, group, layerId, border, hover, hoverwait) {

  var map = this;

  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, feature) { return cols[index]; };
  }

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
        var content = popup === true ? '<pre>'+JSON.stringify(feature.properties,null,' ').replace(/[\{\}"]/g,'')+'</pre>' : popup[idx].toString();
        var pops = L.popup({ maxWidth: 2000 })
            .setLatLng(e.latlng)
            .setContent(content);

        map.layerManager.addLayer(pops, "popup");
      }
    }
  };
  var pop = function (e, feature) {
    click_event(e, feature, popup !== null, popup);
  };

  var hover_event = function(e, feature, addhover, hover) {
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
      if (addhover) {
        var content = hover === true ? '<pre>'+JSON.stringify(feature.properties,null,' ').replace(/[\{\}"]/g,'')+'</pre>' : hover[idx].toString();
        var pops = L.popup({ maxWidth: 2000 })
            .setLatLng(e.latlng)
            .setContent(content);

        map.layerManager.removeLayer("leafglpopups");
        map.layerManager.addLayer(pops, "popup", "leafglpopups");
      }
    }
  };
  var hov = function (e, feature) {
    hover_event(e, feature, hover !== null, hover);
  };

  var shapeslayer = L.glify.shapes({
    map: map,
    click: pop,
    hover: hov,
    hoverWait: hoverwait,
    data: data,
    color: clrs,
    opacity: opacity,
    border: border,
    className: group
  });

  map.layerManager.addLayer(shapeslayer.layer, "glify", layerId, group);
};


LeafletWidget.methods.removeGlPolygons = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};