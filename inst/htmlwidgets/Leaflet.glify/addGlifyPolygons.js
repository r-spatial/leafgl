LeafletWidget.methods.addGlifyPolygons = function(data, cols, popup, label, opacity, group, layerId, pane) {

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
        var content = popup === true ? json2table(feature.properties) : popup[idx].toString();

        L.popup({ maxWidth: 2000 })
         .setLatLng(e.latlng)
         .setContent(content)
         .openOn(map);
         //.openPopup();
      }
    }
  };

  var pop = function (e, feature) {
    click_event(e, feature, popup !== null, popup);
  };

  // var label = "testtest";
  let tooltip = new L.Tooltip();

  var hover_event = function(e, feature, addlabel, label) {
    if (map.hasLayer(shapeslayer.layer)) {
      if (addlabel) {
        tooltip
         .setLatLng(e.latlng)
         .setContent(feature.properties[[label]].toString())
         .addTo(map);
      }
    }
  }

  var hvr = function(e, feature) {
    hover_event(e, feature, label !== null, label);
  }


  var shapeslayer = L.glify.shapes({
    map: map,
    click: pop,
    hover: hvr,
    data: data,
    color: clrs,
    opacity: opacity,
    className: group,
    border: true,
    pane: pane
  });

  map.layerManager.addLayer(shapeslayer.layer, "glify", layerId, group);
};
