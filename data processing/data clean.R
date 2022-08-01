library(tidyverse)
library(purrr)
library(lubridate)

#read all trends_up_to data and put in one dataframe
csv_list_trendfiles <- list.files(path = 'data/Lab3_Rawdata', pattern = 'trends_up_to_', full.names = TRUE)
trends_data <- csv_list_trendfiles %>%
  map_df(read_csv)

#get the date data
trends_data$monthorweek <- trends_data$monthorweek %>% str_sub(start = 1, end = 10) %>% ymd() %>% floor_date('month') 


trends_data <- trends_data %>% group_by(schname, keyword) %>% mutate(index = (index - mean(index))/sd(index))

trends_data <- trends_data %>% group_by(schname, monthorweek) %>% summarize(index)

#read in scorecard data
scorecard_data <- read_csv("data/Lab3_Rawdata/Most+Recent+Cohorts+(Scorecard+Elements).csv")

#read in id name 
id_name_link <- read_csv("data/Lab3_Rawdata/id_name_link.csv")

#filter out schools listed more than once
id_name_link <- id_name_link %>% group_by(schname) %>% mutate(n = n()) %>% filter(n == 1)

#join id name to trends data 
trends_data <-inner_join(id_name_link, trends_data, by = "schname")

#rename UNITID to match unitid in trends data
scorecard_data <- scorecard_data %>% rename(unitid = UNITID)

#join scorecard data to trends_data
trends_data <- inner_join(trends_data, scorecard_data, by = "unitid")

#filter for predominantly bachelor's degree awarding institutions
trends_data <- trends_data %>% filter(PREDDEG == 3)

#remove na values for index
trends_data <- trends_data %>% filter(!is.na(index))

#create true/false (1/0) variable for if the scorecard exists
trends_data <- trends_data %>% mutate(scorecard_exist = ifelse(monthorweek >= "2015-09-01", 1, 0))

#move scorecard exist and median earnings from end to behind index
trends_data <- trends_data %>% relocate(c(scorecard_exist, `md_earn_wne_p10-REPORTED-EARNINGS`), .after = index)

#remove null and privacysuppresses values from median earnings
trends_data <- trends_data %>% subset(`md_earn_wne_p10-REPORTED-EARNINGS` != "PrivacySuppressed" & `md_earn_wne_p10-REPORTED-EARNINGS` != "NULL")

#convert median earnings to numeric
trends_data$`md_earn_wne_p10-REPORTED-EARNINGS` <- as.numeric(trends_data$`md_earn_wne_p10-REPORTED-EARNINGS`)
