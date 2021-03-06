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

library(ggplot2)      # For plotting
library(tidycensus)   # For downloading Census data
library(tmap)         # For creating tmap
library(tmaptools)    # For reading and processing spatial data related to tmap
library(dplyr)        # For data wrangling
library(sf)           # For reading, writing and working with spatial objects

setwd("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone")
options(width=150)


## load data
data_2004 <- read_csv("datasets/unc/data_2004_cleaned.csv")
data_2004 <- data_2004 %>% select(-X1)

data_2019 <- read_csv("datasets/unc/data_2019_cleaned.csv")
data_2019 <- data_2019 %>% select(-X1)


data_2004 <- data_2004 %>% mutate(year = 2004)

data_2019 <- data_2019 %>% mutate(year = 2019)


data_2004 <- data_2004 %>% mutate(joiner = paste(gsub(" ","_",newspaper_name),city,state,sep="_"))

data_2019 <- data_2019 %>% mutate(joiner = paste(gsub(" ","_",newspaper_name),city,state,sep="_"))


## tidy census ACS & geo data
#census_api_key("4ac849774033eecc6923fbb924493b9713de909f")

dat <- get_acs("county", table = "B01003", year = 2017, output="tidy",state=NULL,geometry=TRUE,shift_geo=TRUE, cache_table = TRUE) %>%
  rename ('2017' = estimate) %>% select (-moe)


## add fips codes to ACS data
fips <- fips_codes

fips <- fips %>% mutate (combined = paste0(county,", ",state_name))

dat_new <- left_join(dat, fips,by=c("NAME"="combined"))

dat_new <- dat_new %>% mutate(fips = paste0(state_code, county_code)) %>% rename(population="2017")


## get ready to merge newspaper and ACS county data

state_lookup <- read_csv("datasets/state_lookup.csv")

## prepare merge of (soon-to-be-summarized) 2019 newspaper data and ACS county data

data_2019_states <- left_join(data_2019, state_lookup, by=c("state"="Abbreviation"))

data_2019_states <- data_2019_states %>% mutate(county_join = if_else(State == 'Louisiana',paste0(county,", ",State),paste0(county," County, ",State)))

## prepare merge of (soon-to-be-summarized) 2004 newspaper data and ACS county data

data_2004_states <- left_join(data_2004, state_lookup, by=c("state"="Abbreviation"))

data_2004_states <- data_2004_states %>% mutate(county_join = if_else(State == 'Louisiana',paste0(county,", ",State),paste0(county," County, ",State)))


## summarise newspaper 2019 data

data_2019_state_papercount <- data_2019_states %>% group_by(State) %>% summarise(papercount = n())

data_2019_state_papercount %>% summary()

data_2019_summary <- data_2019_states %>% group_by(county_join) %>% summarise(county_newspaper_quantity_2019 = n(), 
                                                                              avg_circulation_2019 = mean(total_circulation))

## summarise newspaper 2004 data

data_2004_state_papercount <- data_2004_states %>% group_by(State) %>% summarise(papercount = n())

data_2004_summary <- data_2004_states %>% group_by(county_join) %>% summarise(county_newspaper_quantity_2004 = n(), 
                                                                              avg_circulation_2004 = mean(total_circulation))


############################################################################################################################



## merge summarized newspaper 2019 data and ACS county data

acs_news_2019 <- left_join(dat_new, data_2019_summary, by=c("NAME"="county_join"))

county_level_data <- left_join(acs_news_2019, data_2004_summary, by=c("NAME" = "county_join"))


## replace NAs in selected columns

county_level_data <- county_level_data %>% replace_na(list(
  county_newspaper_quantity_2019=0, avg_circulation_2019=0,
  county_newspaper_quantity_2004=0, avg_circulation_2004=0))


## calculate state-level metrics from acs_news_2019 dataframe

state_level_data <- county_level_data %>% group_by(state_name) %>% 
  summarise(avg_newspapers_per_county_by_state = mean(county_newspaper_quantity_2019), 
            total_newspapers_per_state = sum(county_newspaper_quantity_2019),
            state_counties_zero_papers = sum(if_else(county_newspaper_quantity_2019 == 0,1,0)),
            total_newspapers_per_state_2004 = sum(county_newspaper_quantity_2004),
            state_counties_zero_papers_2004 = sum(if_else(county_newspaper_quantity_2004 == 0,1,0)),
            state_population = sum(population)
  ) %>% 
  as.data.frame() %>% select(-geometry)

## make edits to state-level metrics


state_level_data <- state_level_data %>% drop_na() %>% 
  mutate (avg_newspapers_per_county_by_state = round(avg_newspapers_per_county_by_state,2),
          total_newspapers_per_state = round(total_newspapers_per_state,0),
          state_counties_zero_papers = round(state_counties_zero_papers,0),
          total_newspapers_per_state_2004 = round(total_newspapers_per_state_2004,0),
          state_counties_zero_papers_2004 = round(state_counties_zero_papers_2004,0),
          change_in_newspapers = total_newspapers_per_state - total_newspapers_per_state_2004
          #,papers_per_capita = total_newspapers_per_state/population
  ) %>% 
  filter(state_name != "Alaska")



## bring state_level metrics into county_level SF dataframe

county_level_data <- county_level_data %>% left_join(state_level_data, by = c("state_name"="state_name"))

## create final SF dataframe

county_level_data %>% colnames()

county_sf <- county_level_data %>% select(GEOID, fips, geometry, state, state_name, state_code, county, county_code,
                                        population, state_population, county_newspaper_quantity_2019, 
                                        avg_circulation_2019, avg_newspapers_per_county_by_state, 
                                        total_newspapers_per_state, state_counties_zero_papers,
                                        county_newspaper_quantity_2004, avg_circulation_2004,
                                        total_newspapers_per_state_2004, state_counties_zero_papers_2004) %>%
  rename(abbr = state, county_population = population)


## mutate sf dataframe for write_rds prep

county_sf <- county_sf %>% mutate(county_papercount_group = case_when(
  county_newspaper_quantity_2019 == 0 ~ "red2",
  county_newspaper_quantity_2019 == 1 ~ "lightgoldenrod1",
  county_newspaper_quantity_2019 > 1 ~ "lightcyan"
)) %>% filter(state_name != "Alaska")

county_sf <- county_sf %>% mutate(
  change_in_papercount_county = county_newspaper_quantity_2019 - county_newspaper_quantity_2004
)

View(county_sf)


# acs_2019_sf %>% as.data.frame() %>% select(state_name) %>% drop_na() %>% distinct()

# acs_2019_sf <- acs_2019_sf %>% mutate(
#   total_circulation_per_county = county_newspaper_quantity_2019 * avg_circulation_2019,
#                                       news_readership_percentage = total_circulation_per_county/population)





########M#A#P#S#M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S##M#A#P#S####################################################################################################





## tile plot

tiles <- geojson_read("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/datasets/tiles.topo.json", what = "sp")
tiles_sf <- st_as_sf(tiles)
plot_ly(tiles_sf, split = ~name, text=~paste(name,":",round(tilegramValue,1)), hoveron="fills",hoverinfo="text", showlegend=FALSE)

## tmaps

tm_shape(acs_2019_sf) + tm_polygons("total_newspapers_per_state")

tm_shape(acs_2019_sf, projection = 2163) + 
  tm_polygons("county_newspaper_quantity_2019", style = "quantile", palette = "BuPu") + tm_legend(legend.position = c("left","bottom"))

mymap <- tm_shape(acs_2019_sf, projection = 2163) + 
  tm_borders() + 
  tm_fill(col = "county_papercount_group",
          id = "county",
          popup.vars = c("Pop.: " = "population",
                         "Newspapers: " = "county_newspaper_quantity_2019",
                         "Avg. Circulation: " = "avg_circulation_2019"
                         )) + 
  tm_style("albatross")

tmap_leaflet(mymap)

tennessee <- acs_2019_sf_new %>% filter (abbr == "TN")

tnmap <- tm_shape(tennessee, projection = 2163) + 
  tm_borders() + 
  tm_fill(col = "county_papercount_group",
          id = "county",
          popup.vars = c("Pop.: " = "population",
                         "Newspapers: " = "county_newspaper_quantity_2019",
                         "Avg. Circulation: " = "avg_circulation_2019")) + 
  tm_style("albatross")

tmap_leaflet(tnmap)




############WRITE DATA###############WRITE DATA##############WRITE DATA############WRITE DATA#############WRITE DATA#############




#write_rds(acs_2019_sf_new, "my_sf.rds")
#write_rds(county_sf, "C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/county_sf.rds")


#write_rds(state_level_stats_2019, "C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/state_stats_new.rds")
#write_rds(state_level_data, "C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone/state_level_data.rds")

## convert to tiles

#convert_to_tiles_new <- acs_2019_sf %>% as.data.frame() %>% select(state_code,total_newspapers_per_state) %>% distinct() %>% drop_na()
#write.csv(convert_to_tiles_new,"convert_to_tiles_new.csv")




county_sf %>% filter(state_name == "Tennessee")

acs_2019_sf %>% as.data.frame() %>% select(state_name) %>% drop_na() %>% distinct()

