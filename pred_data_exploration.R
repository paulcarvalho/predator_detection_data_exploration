#-------------------------------------------------------------------------------------------
# Predator detection data exploration
#
# Author: Paul Carvalho
#-------------------------------------------------------------------------------------------

# Set up workspace ----
# Clear workspace
rm(list = ls())

# Libraries
library(DBI)
library(odbc)
library(dbplyr)
library(tidyverse)

# Set working directory
setwd("~/github/predator_detection_data_exploration")

# Pull data from access into R ----
# Set up driver info and database path
driverinfo <- "Driver={Microsoft Access Driver (*.mdb, *.accdb)};"
mdbpath    <- "C:/Users/pgcar/Documents/github/predator_detection_data_exploration/2014-2016_Predator_Detections.accdb"
path       <- paste0(driverinfo, "DBQ=", mdbpath)

# Establish connection
con <- dbConnect(odbc(), .connection_string = path)

# load data into R
tagged_predators <- tbl(con, "Acoustic_tagged_Predators") %>%
                    collect()

deployments <- tbl(con, "Deployments") %>%
               collect()

monitor_locs <- tbl(con, "Monitor_locations") %>%
                collect()

detections <- tbl(con, "predator_detections_final") %>%
              select(datetime_PST, Receiver, Transmitter, `Station Name`, Receiver_short) %>%
              collect()

# Merge data with detections ----
df <- detections %>%
   left_join(., deployments, by = c("Receiver_short" = "VR2SN")) %>%
   left_join(., monitor_locs, by = "Location") %>%
   filter((datetime_PST >= Start) & (datetime_PST <= Stop))
   