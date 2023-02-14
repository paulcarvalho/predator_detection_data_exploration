#-------------------------------------------------------------------------------------------
# Predator detection data exploration
#
# Author: Paul Carvalho
#-------------------------------------------------------------------------------------------

# Clear workspace
rm(list = ls())

# Libraries
library(RODBC)
library(tidyverse)

# Set working directory
setwd("C:/Users/pgcar/Google Drive/1 Work/1 NOAA UCSC AT/1 Projects/Predator detections")

# Set up driver info and database path
DRIVERINFO <- "Driver={Microsoft Access Driver (*.mdb, *.accdb)};"
MDBPATH <- "C:/Users/pgcar/Google Drive/1 Work/1 NOAA UCSC AT/1 Projects/Predator detections/2014-2016_Predator_Detections.accdb"
PATH <- paste0(DRIVERINFO, "DBQ=", MDBPATH)

# Establish connection
con <- odbcDriverConnect(PATH)

# Load data into R dataframe
predators <- sqlQuery(con,
                      "SELECT *
                      FROM Acoustic_tagged_Predators",
                      stringsAsFactors = FALSE)

detections <- sqlQuery(con,
                       "SELECT *
                       FROM predator_detections_final",
                       stringsAsFactors = FALSE)

deployments <- sqlQuery(con,
                        "SELECT *
                        FROM Deployments",
                        stringsAsFactors = FALSE)

locations <- sqlQuery(con,
                      "SELECT *
                      FROM Monitor_Locations",
                      stringsAsFactors = FALSE)

#-------------------------------------------------------------------------------------------
# PREDATORS TABLE
predators %>%
   filter(Species_code == "STB" | Species_code == "LMB") %>%
   select(Dates, Capture_site, Species_code, Length_mm, Weight_kg) %>%
   group_by(Species_code, Capture_site) %>%
   summarise(n = n()) %>%
   mutate(Species_code = as.factor(Species_code),
          Capture_site = factor(Capture_site, levels = c("A3","R3","C3","A2","R2","C2","A1","R1","C1"))) %>%
   ggplot(data = .) +
      geom_bar(aes(x = Capture_site, y = n), stat = 'identity') +
      facet_grid(Species_code ~ .)

#-------------------------------------------------------------------------------------------
# DETECTIONS
for(i in 1:length(detections)){
   if(length(which(predators$TagID1 == detections$Transmitter[i])) != 0){
      detections$TagSN[i] = predators$TagSN[which(predators$TagID1 == detections$Transmitter[i])]
   } else if(length(which(predators$TagID2 == detections$Transmitter[i])) != 0){
      detections$TagSN[i] = predators$TagSN[which(predators$TagID2 == detections$Transmitter[i])]
   } else if(length(which(predators$TagID3 == detections$Transmitter[i])) != 0){
      detections$TagSN[i] = predators$TagSN[which(predators$TagID3 == detections$Transmitter[i])]
   }
}
   

detections %>%
   mutate(TagSN = findTagSN(Transmitter))
            
   







