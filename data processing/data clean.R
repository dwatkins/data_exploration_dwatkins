library(tidyverse)
library(purrr)

csv_list_trendfiles <- list.files(path = 'data/Lab3_Rawdata', pattern = 'trends_up_to_', full.names = TRUE)
trends_data <- csv_list_trendfiles %>%
  map_df(read_csv)