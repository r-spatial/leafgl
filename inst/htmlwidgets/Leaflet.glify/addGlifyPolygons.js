LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, opacity, group, layerId) {

  var map = this;

  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, feature) { return cols[index]; };
  }

  var click_event = function(e, feature, addpopup, content) {
    if (map.hasLayer(shapeslayer.glLayer)) {
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(map.id + "_shape_click", {
          group: Object.values(shapeslayer.glLayer._eventParents)[0].groupname,
          lat: e.latlng.lat,
          lng: e.latlng.lng,
          data: feature.properties
        });
      }
      if (addpopup) {
        L.popup({ maxWidth: 2000 })
        .setLatLng(e.latlng)
        .setContent(content)
        .openOn(map);
      }
    }
  };

  if (popup) {
    if (popup === true) {
      pop = function (e, feature) {
        var popUp = '<pre>'+JSON.stringify(feature.properties,null,' ').replace(/[\{\}"]/g,'')+'</pre>';
        click_event(e, feature, true, popUp);
      };
    } else {
      pop = function (e, feature) {
        var idx = data.features.findIndex(k => k==feature);
        var popUp = popup[idx].toString();
        click_event(e, feature, true, popUp);
      };
    }
  } else {
    pop = function (e, feature) {
      click_event(e, feature, false, null);
    };
  }

  var shapeslayer = L.glify.shapes({
    map: map,
    click: pop,
    data: data,
    color: clrs,
    opacity: opacity,
    className: group
  });

  map.layerManager.addLayer(shapeslayer.glLayer, "glify", layerId, group);
};


LeafletWidget.methods.removeGlPolygons = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};