library(reshape2)
library(tidyr)
library(dplyr)

origCityData <- readRDS("C:\\Work\\DataScience\\origCityData.rds")
data <- subset(origCityData, select = c("UniqueID", "CityName","StateAbbr", "GeoLocation", "Year","Measure","Data_Value","PopulationCount","GeographicLevel", "Short_Question_Text", "Category", "DataValueTypeID"))
data$GeoLocation <- gsub("[ ()]", "", data$GeoLocation)
data <- data %>% separate(GeoLocation, c("lat", "long"), ",")
data$lat <- as.numeric(data$lat)
data$long <- as.numeric(data$long)

tractdata <- dcast(data[data$GeographicLevel=="Census Tract" & data$DataValueTypeID=="CrdPrv" & data$Short_Question_Text %in% c("Current Asthma","Current Smoking","Obesity"),], UniqueID+CityName+StateAbbr+lat+long+Year+PopulationCount+GeographicLevel~Short_Question_Text, value.var="Data_Value")
citydata <- dcast(data[data$GeographicLevel=="City" & data$DataValueTypeID=="CrdPrv" & data$Short_Question_Text %in% c("Current Asthma","Current Smoking","Obesity"),], UniqueID+CityName+StateAbbr+lat+long+Year+PopulationCount+GeographicLevel~Short_Question_Text, value.var="Data_Value")

saveRDS(tractdata,"C:\\Work\\DataScience\\asthmacdc500citiesshinyapp\\cdc500censustractasthmadata.rds")
saveRDS(citydata,"C:\\Work\\DataScience\\asthmacdc500citiesshinyapp\\cdc500cityasthmadata.rds")
