library(shiny)
library(leaflet)
library(mapview)
library(leafgl)
options(shiny.autoreload = TRUE)

## Data ################
lines = suppressWarnings(st_cast(trails, "LINESTRING"));
lines = st_transform(lines, 4326)

base_colors <- "#bc2323"
ptsdata <- breweries
ptsdata$id <- seq.int(length(ptsdata$brewery))
opacity_hex <- sprintf("%02X", floor(255 * scales::rescale(ptsdata$id, to = c(0.1, 1))))
colors_with_opacity_pts <- paste0(base_colors, opacity_hex)

shapes <- franconia
base_colors <- "#5353c1"
shapes <- st_cast(shapes, "POLYGON")
opacity_hex <- sprintf("%02X", floor(255 * scales::rescale(shapes$SHAPE_AREA, to = c(1, 0.2))))
colors_with_opacity_poly <- paste0(base_colors, opacity_hex)

## contextmenu_Template ################
contextmenu_Template_Shape <- JS('
   function(e, feature) {
   $.contextMenu({
      selector: "#context-menu-anchor_shape",
      className: "shape-title",
      callback: function(key, options) {
        Shiny.setInputValue("contextMenuAction", key, {priority: "event"});
      },
      items: {
        edit: {name: "Edit Shape", icon: "edit"},
        delete: {name: "Delete  Shape", icon: "delete"},
        quit: {name: "Quit", icon: "quit"}
      }
    });

    console.log("e"); console.log(e)
    console.log("feature"); console.log(feature)
    var evt = $.Event("contextmenu", {
      pageX: e.originalEvent.pageX,
      pageY: e.originalEvent.pageY,
      which: 3  // indicate right-click
    });
    $("#context-menu-anchor_shape").trigger(evt);
  }')

contextmenu_Template_Line <- JS('
   function(e, feature) {
   $.contextMenu({
      selector: "#context-menu-anchor_lines",
      className: "line-title",
      callback: function(key, options) {
        Shiny.setInputValue("contextMenuAction", key, {priority: "event"});
      },
      items: {
        edit: {name: "Edit Line", icon: "edit"},
        delete: {name: "Delete Line", icon: "delete"},
        quit: {name: "Quit", icon: "quit"}
      }
    });

    console.log("e"); console.log(e)
    console.log("feature"); console.log(feature)
    var evt = $.Event("contextmenu", {
      pageX: e.originalEvent.pageX,
      pageY: e.originalEvent.pageY,
      which: 3  // indicate right-click
    });
    $("#context-menu-anchor_lines").trigger(evt);
  }')

contextmenu_Template_Points <- JS('
   function(e, feature) {
   $.contextMenu({
      selector: "#context-menu-anchor_points",
      className: "point-title",
      callback: function(key, options) {
        Shiny.setInputValue("contextMenuAction", key, {priority: "event"});
      },
      items: {
        edit: {name: "Edit Point", icon: "edit"},
        delete: {name: "Delete  Point", icon: "delete"},
        zoomin: {name: "Zoom In", icon: "edit"},
        zoomout: {name: "Zoom Out", icon: "edit"},
        quit: {name: "Quit", icon: "quit"}
      }
    });

    console.log("e"); console.log(e)
    console.log("feature"); console.log(feature)
    var evt = $.Event("contextmenu", {
      pageX: e.originalEvent.pageX,
      pageY: e.originalEvent.pageY,
      which: 3  // indicate right-click
    });
    $("#context-menu-anchor_points").trigger(evt);
  }')




## UI ################
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet",
              href = "https://cdnjs.cloudflare.com/ajax/libs/jquery-contextmenu/2.7.1/jquery.contextMenu.min.css"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jquery-contextmenu/2.7.1/jquery.contextMenu.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jquery-contextmenu/2.7.1/jquery.ui.position.js")
    , tags$style("
    .line-title:before {
        content: 'Title for Lines';
    }
    .shape-title:before {
        content: 'Title for Shapes';
    }
    .point-title:before {
        content: 'Title for Points';
    }
    .line-title, .shape-title, .point-title {
        display: block;
        position: absolute;
        right: 0;
        background: #DDD;
        padding: 2px;
        font-size: 13px;
    }
    .line-title :first-child, .shape-title :first-child, .point-title :first-child {
        margin-top: 2px;
    }
    ")
  ),
  leafletOutput("map", height = 800)
  , tags$div(id = "context-menu-anchor_lines", style="display:none")
  , tags$div(id = "context-menu-anchor_points", style="display:none")
  , tags$div(id = "context-menu-anchor_shape", style="display:none")
)

## Server ################
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(provider = "CartoDB") %>%
      addGlPolygons(
        data = shapes
        , color = colors_with_opacity_poly
        , opacity = 0.3
        , popup = TRUE
        , contextMenu = contextmenu_Template_Shape
        , group = "polys"
        ) %>%
      addGlPolylines(
        data = lines
        , layerId = lines$realid
        , weight = 2
        , color = "#528b3f"
        , sensitivity = 0.001
        , sensitivityHover = 0.001
        , label = ~FKN
        , contextMenu = contextmenu_Template_Line
        , group = "lines"
      ) %>%
      addGlPoints(
        data = ptsdata
        , layerId = ~id
        , fillColor = colors_with_opacity_pts
        , radius = ptsdata$id/10
        , contextMenu = contextmenu_Template_Points
        , group = "points"
      ) %>%
      addLayersControl(overlayGroups = c("points", "lines", "polys"))

  })
  observeEvent(input$contextMenuAction, {
    action <- input$contextMenuAction
    print(paste("Context menu action chosen:", action))
    # Handle the action (e.g., open modal, update UI, etc.)
  })

}
shinyApp(ui, server)
