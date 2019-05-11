## load libraries & settings
library(lubridate)
library(data.table)
library(ggrepel)
library(tidyverse)
library(bbplot)
library(highcharter)
library(mapview)
library(plotly)
library(geojsonio)
library(leaflet)
library(scales)
library(leaflet)
library(shinydashboard)
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(DT)


library(ggplot2)      # For plotting
library(tidycensus)   # For downloading Census data
library(tmap)         # For creating tmap
library(tmaptools)    # For reading and processing spatial data related to tmap
library(dplyr)        # For data wrangling
library(sf)           # For reading, writing and working with spatial objects


data <- read_rds("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/my_sf.rds")

state_stats <- read_rds("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/state_stats.rds")

states_all <- data %>% as.data.frame() %>% select(state_name) %>% drop_na() %>% distinct()

tiles <- geojson_read("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/datasets/tiles.topo.json", what = "sp")
tiles_sf <- st_as_sf(tiles)

tiles_new <- geojson_read("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/datasets/tiles_new.topo.json", what = "sp")
tiles_new_sf <- st_as_sf(tiles)