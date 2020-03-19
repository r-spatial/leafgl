LeafletWidget.methods.addGlifyPolylines = function(data, cols, popup, opacity, group, weight, layerId) {

  var map = this;

  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, feature) { return cols[index]; };
  }

  var wght;
  if (weight.length === undefined) {
    wght = weight;
  } else {
    wght = function(index, feature) { return weight[index]; };
  }

  var click_event = function(e, feature, addpopup, content) {
    if (map.hasLayer(lineslayer.glLayer)) {
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(map.id + "_shape_click", {
          group: Object.values(lineslayer.glLayer._eventParents)[0].groupname,
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

  var pop;
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

  var lineslayer = L.glify.lines({
    map: map,
    click: pop,
    latitudeKey: 1,
    longitudeKey: 0,
    data: data,
    color: clrs,
    opacity: opacity,
    className: group,
    weight: wght
  });

  map.layerManager.addLayer(lineslayer.glLayer, "glify", layerId, group);
};


LeafletWidget.methods.removeGlPolylines = function(layerId) {
  this.layerManager.removeLayer("glify", layerId);
};

