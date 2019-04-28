library('tidyverse')
getwd()
setwd("C:/Users/Alex/Google Drive/312 Lutie/NSS/Capstone")
data_2004 <- read_csv("datasets/unc/news_2004.csv")
options(width=150)

data_2004 %>% head()

data_2004 <- data_2004 %>% mutate(frequency = as.factor(frequency), owner_type = as.factor(owner_type)) %>% head()


