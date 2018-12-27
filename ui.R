library(leaflet)

tabPanel("Interactive map",
         div(class="outer",
             
             tags$head(
               # Include our custom CSS
               includeCSS("styles.css")
             ),
             
             # If not using custom CSS, set height of leafletOutput to a number instead of percent
             leafletOutput("map", width="100%", height="100%")))