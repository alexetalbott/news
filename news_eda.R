
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

## identify rows with missing values other than in owner_type
data_2004 %>% select(-owner_type) %>% filter_all(any_vars(is.na(.))) %>% View()         


# apply fixes to rows with missing values in rows other than owner_type
data_2004 <- 
  data_2004 %>% 
              mutate(
                # rename no-county Virginia counties by appending " city"
                county = if_else(
                  is.na(county), paste(data_2004$city," City"),county, missing = data_2004$county),
                city = if_else(
                  # fill in missing cities for DC
                  county == "District of Columbia", "District of Columbia", city)
              )


#make circulation numeric
data_2004 <- data_2004 %>% mutate(total_circulation = as.numeric(gsub(",","",total_circulation)))

#data_2004 %>% summarise(n=n_distinct(total_circulation), na = sum(is.na(total_circulation)), med = median(total_circulation, na.rm=TRUE))
#data_2004$total_circulation %>% str()

# replace NA in total_circulation with average
#data_2004 %>% mutate(total_circulation = replace(
#                                                  total_circulation, is.na(total_circulation),median(total_circulation,na.rm=TRUE)
#)) %>% select(-owner_type) %>% filter_all(any_vars(is.na(.))) %>% View()

data_2004 <- data_2004 %>% mutate(total_circulation = replace(
  total_circulation, is.na(total_circulation),median(total_circulation,na.rm=TRUE)
))


#data_2004 %>% select(-owner_type) %>% filter_all(any_vars(is.na(.))) %>% View()



# fix days published

data_2004 %>% group_by(days_published) %>% summarise(count=n())

data_2004 %>% mutate(days_published = replace(
                                              days_published, is.na(days_published), median(days_published, na.rm=TRUE)                    
)) %>% select(-owner_type) %>% filter_all(any_vars(is.na(.))) %>% View()

data_2004 <- data_2004 %>% mutate(days_published = replace(
  days_published, is.na(days_published), median(days_published, na.rm=TRUE)                    
))


data_2004 %>% filter_all(any_vars(is.na(.))) %>% View()


# fill missing owner_types (see bottom for more detailed clean-up)

data_2004 %>% group_by(owner_type) %>% summarise(n=n())

data_2004 <- data_2004 %>% mutate(owner_type = replace(owner_type, is.na(owner_type),"unknown"))

data_2004_new <- data_2004

write.csv(data_2004_new, 'data_2004_cleaned.csv')





















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

