library(leaflet)


tractdata <- readRDS("cdc500censustractasthmadata.rds")
citydata <- readRDS("cdc500cityasthmadata.rds")

function(input, output, session) {
  
  ## Interactive Map ###########################################
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4)
  })
  
  cityInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(citydata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(citydata,
           lat >= latRng[1] & lat <= latRng[2] &
             long >= lngRng[1] & long <= lngRng[2])
  })
  
  output$scatterplot <- renderPlot({
    xBy <- input$colorBy
    yBy <- input$sizeBy
    displaydata <- cityInBounds()
    # If no zipcodes are in view, don't plot
    if (nrow(displaydata) == 0)
      return(NULL)
    
    library(ggplot2)
    plot <- ggplot(displaydata[!is.na(displaydata[[xBy]]) & !is.na(displaydata[[yBy]]),], aes_(x=as.name(xBy),y=as.name(yBy))) + geom_point()
    print(plot)
  })
  
  
  observe({
    colorBy <- input$colorBy
    sizeBy <- input$sizeBy
    
    pal <- colorBin("viridis", citydata[[colorBy]], 7, pretty = FALSE)
    radius <- citydata[[sizeBy]] * input$circlesize * 10
    
    leafletProxy("map", data = citydata) %>%
      clearShapes() %>%
      addCircles(~long, ~lat, radius=radius, layerId=~UniqueID,
                 stroke=FALSE, fillOpacity=0.4, fillColor=pal(citydata[[colorBy]])) %>%
      addLegend("bottomleft", pal=pal, values=citydata[[colorBy]], title=colorBy,
                layerId="colorLegend")
  })
}