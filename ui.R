library(leaflet)

choices <- c("Current Asthma", "Current Smoking", "Obesity")
levels <- c("City", "Census Tract")
tabPanel("Interactive map",
         div(class="outer",
             
             tags$head(
               # Include our custom CSS
               includeCSS("styles.css")
             ),
             
             # If not using custom CSS, set height of leafletOutput to a number instead of percent
             leafletOutput("map", width="100%", height="100%"),
             absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                           draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                           width = 330, height = "auto",
                           
                           h2("Asthma Data Explorer"),
                           
                           selectInput("geographicLevel", "Geographic Level", levels, selected = "City"),
                           selectInput("colorBy", "Color", choices, selected = "Current Asthma"),
                           selectInput("sizeBy", "Size", choices, selected = "Obesity"),
                           sliderInput("circlesize", "Circle Size",
                                       min = 0, max = 100,
                                       value = 50),
                           plotOutput("scatterplot", height = 250)
                           )))