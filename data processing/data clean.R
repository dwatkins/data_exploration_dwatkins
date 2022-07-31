library(tidyverse)
library(purrr)
library(lubridate)

#read all trends_up_to data and put in one dataframe
csv_list_trendfiles <- list.files(path = 'data/Lab3_Rawdata', pattern = 'trends_up_to_', full.names = TRUE)
trends_data <- csv_list_trendfiles %>%
  map_df(read_csv)

#get the date data
trends_data$monthorweek <- trends_data$monthorweek %>% str_sub(start = 1, end = 10) %>% ymd()
