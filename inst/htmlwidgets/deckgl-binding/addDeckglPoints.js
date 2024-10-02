LeafletWidget.methods.addDeckglPoints = function(geom_column_name, cols, popup, label, opacity, radius, min_rad, max_rad, group, layerId, dotOptions, pane) {

  let gaDeckLayers = window["@geoarrow/deck"]["gl-layers"];

  const map = this;
  //var data = JSON.parse(data);
  let getFillColor = cols;
  let getLineColor = [0, 0, 0];
  let getLineWidth = 1;

/*
  function getTooltip({object}) {
    if (label !== null) {
      if (object !== undefined && object[label] !== null) {
        return object && { html: object[label] };
      }
      return;
    }
    return;
  }

  function rescale(value, to_min, to_max, from_min, from_max) {
    if (value === undefined) {
      value = from_min;
    }
    return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min;
  }

  if (typeof(radius) === "string") {
    var data_has_radius_column = Object.keys(data[0]).includes(radius);
    var radius_column_is_numeric = typeof(data[0][radius]) === "number";

    if (!data_has_radius_column || !radius_column_is_numeric) {
      console.warn("Warning: radius string not found in data or not returning numeric, setting radius to 10px");
    }
  }

  function getRadius(data) {
    if (typeof(radius) === "string") {
      if (!data_has_radius_column || !radius_column_is_numeric) {
        return 10;
      }
      return rescale(data[radius], 2, 15, min_rad, max_rad);
    }
    if (typeof(radius) === "number") {
      return radius;
    }
    return 10;
  }

  const tooltip = document.createElement('div');
  tooltip.style.position = 'absolute';
  tooltip.style.zIndex = 1;
  tooltip.style.pointerEvents = 'none';
  //tooltip.classList.add("leaflet-popup-content-wrapper", "leaflet-popup-content");
  //tooltip.className += "leaflet-popup-content";
  document.body.append(tooltip);

  function updateTooltip({object, x, y}) {
    if (object) {
      tooltip.style.display = 'block';
      tooltip.style.left = `${x}px`;
      tooltip.style.top = `${y}px`;
      tooltip.innerText = object[label];
    } else {
      tooltip.style.display = 'none';
    }
  }

  let opts = {
    id: layerId,
    data: data,
    radiusUnits: "pixels",
    radiusMinPixels: 1,
    lineWidthUnits: "pixels",
    stroked: true,
    pickable: true
  };

  opts = {
    ...opts,
    getRadius: getRadius,
    getPosition: d => d[geom_column_name],
    getFillColor: getFillColor,
    getLineColor: getLineColor,
    getLineWidth: getLineWidth
  };
*/

  var data_fl = document.getElementById(layerId + '-1-attachment');

/*
  function getArrowTable(attachment) {
    var ipc_table = Arrow.tableFromIPC(fetch(attachment.href));
    return ipc_table;
  }

  var arrow_table;
  getArrowTable(data_fl).then(d => { arrow_table = d; });

  console.log(arrow_table);
*/

  fetch(data_fl.href)
    .then(result => Arrow.tableFromIPC(result))
    .then(arrow_table => {
      var geoArrowScatter = new gaDeckLayers.GeoArrowScatterplotLayer({
        id: "scatterplot",
        data: arrow_table,
        /// Geometry column
        getPosition: arrow_table.getChild(geom_column_name),
        /// Column of type FixedSizeList[3] or FixedSizeList[4], with child type Uint8
        getFillColor: [0, 0, 0], //table.getChild("colors"),
        radiusUnits: "pixels",
        getRadius: 3
      });

      /*
      let opts = {
        id: layerId,
        //data: data,
        radiusUnits: "pixels",
        radiusMinPixels: 1,
        lineWidthUnits: "pixels",
        stroked: true,
        pickable: true
      };
      var deckScatter = new deck.ScatterplotLayer(opts);
      */

      var decklayer = new DeckGlLeaflet.LeafletLayer({
        views: [
          new deck.MapView({
            repeat: true
          })
        ],
        layers: [geoArrowScatter],
        //onClick: updateTooltip, //({ object }) => object && console.log(object),
        //getTooltip: getTooltip //({ object }) => object && { html: object[label] },
      });
      //decklayer = decklayer.bindTooltip("hello").openTooltip();
      //map.addLayer(decklayer);
      map.layerManager.addLayer(decklayer, "deckgl", layerId, group);
    });

};



  /* colors
  var clrs;
  if (cols.length === 1) {
    clrs = cols[0];
  } else {
    clrs = function(index, point) { return cols[index]; };
  }

  // radius
  var rad;
  if (typeof(radius) === "number") {
    rad = radius;
  } else {
    rad = function(index, point) { return radius[index]; };
  }

  // click function
  let clickFun = (e, point, xy) => {
      var idx = data.findIndex(k => k==point);
      //set up a standalone popup (use a popup as a layer)
      if (map.hasLayer(pointslayer.layer)) {
        var content = popup ? popup[idx].toString() : null;
        if (HTMLWidgets.shinyMode) {
              Shiny.setInputValue(map.id + "_glify_click", {
                id: layerId ? layerId[idx] : idx+1,
                group: pointslayer.settings.className,
                lat: point[0],
                lng: point[1],
                data: content
              });
        }
        if (popup !== null) {
          L.popup()
            .setLatLng(point)
            .setContent(content)
            .openOn(map);
        }
      }
    };

  let tooltip = new L.Tooltip();

  var hover_event = function(e, point, addlabel, label) {
    var idx = data.findIndex(k => k==point);
      //set up a standalone label (use a label as a layer)
      if (map.hasLayer(pointslayer.layer)) {
        var content = label ? label[idx].toString() : null;
        if (label !== null) {
          tooltip
            .setLatLng(point)
            .setContent(content)
            .addTo(map);
        }
      }
  }

  var hvr = function(e, feature) {
    hover_event(e, feature, label !== null, label);
  }

  // arguments for gl layer
  var pointsArgs = {
    map: map,
    click: clickFun,
    hover: hvr,
    data: data,
    color: clrs,
    opacity: opacity,
    size: rad,
    className: group,
    pane: pane
  };

  // extract correct fragmentShaderSource if provided via dotOptions
  if (dotOptions.fragmentShaderSource !== undefined && dotOptions.fragmentShaderSource !== null) {
    let fragmentShader = dotOptions.fragmentShaderSource;
    dotOptions.fragmentShaderSource = () => {
      return L.glify.shader.fragment[fragmentShader];
    };
  }

  // append dotOptions to layer arguments
  Object.entries(dotOptions).forEach(([key,value]) => { pointsArgs[key] = value });

  // initialze layer
  var pointslayer = L.glify.points(pointsArgs);

  // add layer to map using RStudio leaflet's layerManager
  */
