library(leaflet)


tractdata <- readRDS("C:\\Work\\DataScience\\asthmacdc500citiesshinyapp\\cdc500censustractasthmadata.rds")
citydata <- readRDS("C:\\Work\\DataScience\\asthmacdc500citiesshinyapp\\cdc500cityasthmadata.rds")

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
  
  tractInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(tractdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(tractdata,
           lat >= latRng[1] & lat <= latRng[2] &
             long >= lngRng[1] & long <= lngRng[2])
  })
  
  output$scatterplot <- renderPlot({
    xBy <- input$colorBy
    yBy <- input$sizeBy
    if(input$geographicLevel=="City")
    {
      displaydata <- cityInBounds()
    }
    else
    {
      displaydata <- tractInBounds()
    }
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
    level <- input$geographicLevel
    if(level == "City"){
      data <- citydata
    }
    else
    {
      data <- tractInBounds()
    }
    
    pal <- colorBin("viridis", data[[colorBy]], 7, pretty = FALSE)
    radius <- data[[sizeBy]] * input$circlesize * 10
    
    leafletProxy("map", data = data) %>%
      clearShapes() %>%
      addCircles(~long, ~lat, radius=radius, layerId=~UniqueID,
                 stroke=FALSE, fillOpacity=0.4, fillColor=pal(data[[colorBy]])) %>%
      addLegend("bottomleft", pal=pal, values=data[[colorBy]], title=colorBy,
                layerId="colorLegend")
  })
}