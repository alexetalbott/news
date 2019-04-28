
## load libraries & settings
library('tidyverse')
library('bbplot')
setwd("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone")
options(width=150)

## load data
data_2004 <- read_csv("datasets/unc/news_2004.csv")
counties <- read_csv("datasets/census/2010_geo_pop_noBreakdown.csv") #county data is from 2010

## begin cleaning

#filter out empty rows
data_2004 <- data_2004 %>% filter_all(any_vars(complete.cases(.)))
counties <- counties %>% filter_all(any_vars(complete.cases(.)))

# fix column name
counties %>% mutate(urban_rural = gsub("\n","",urban_rural))

## rows with missing values other than in owner_type
data_2004 %>% select(-owner_type) %>% filter_all(any_vars(is.na(.))) %>% View()               


# apply fixes to rows with missing values in rows other than owner_type
data_2004 <- data_2004 %>% 
              mutate(
                city = if_else(
                # fill in missing cities for DC
                  county == "District of Columbia", "District of Columbia", city),
                # rename no-county Virginia counties by appending " city"
                county = if_else(
                  is.na(county), paste(county,"City"))
              ) %>%
  

  
# replace NA in total_circulation with average
# replace strings like "Thurs" in days_published with 1
# address duplicate newspaper_ids

# count duplicate (newspaper_id + owner_type)s
data_2004 %>% select(newspaper_id, owner_type) %>% distinct() %>% group_by(newspaper_id) %>% summarise(count = n()) %>% arrange(desc(count))


## get records of duplicate newspaper_ids with multiple owner types -- STILL NEED TO ADDRESS!
data_2004 %>% filter(newspaper_id %in% c(12557,14023)) %>% arrange(newspaper_id)  


## records where owner_type is N/A but identified in other rows

data_2004 %>% select(owner_type, owner_name) %>% distinct() %>% group_by(owner_name) %>% summarise(count = n()) %>% arrange(desc(count))

data_2004 %>% select(owner_type, owner_name) %>% 
  filter(owner_name %in% (c("Emmerich Enterprises","Enterprise NewsMedia","Shearman Corporation","Swift Newspapers"))) %>% 
  arrange(desc(owner_name)) %>%
  View()
  

## data transformations
data_2004 <- data_2004 %>% mutate(frequency = as.factor(frequency), owner_type = as.factor(owner_type))
