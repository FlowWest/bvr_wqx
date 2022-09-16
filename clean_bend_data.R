library(dplyr)
library(janitor)
library(readxl)
library(stringr)
library(lubridate)
library(readr)
load("lookup_objects.rdata")

bend_raw <- read_excel("data-raw/BendHAB.xlsx", skip = 5) %>% 
  clean_names() %>% 
  mutate(sample_id = as.numeric(sample_id)) %>% 
  select(-x8)

first_df <- bend_raw[1:which(is.na(bend_raw$sample_id))[1] - 1, ]
second_df <- bend_raw[(which(is.na(bend_raw$sample_id))[2]) : (which(is.na(bend_raw$sample_id))[3] - 1), ] %>% 
  row_to_names(row_number = 1) %>%
  clean_names() %>% 
  rename(sample_id = na) %>% glimpse
bend_full_df <-   left_join(first_df, second_df)
bend_wqx <- bend_full_df %>% 
  mutate("Project ID" = "HAB",
         "Monitoring Location ID" = project_id_lookup[location],
         "Activity Type" = NA, 
         "Activity Media Name" = matrix,
         "Activity Start Date" = format(mdy_hm(date_collected), "%m/%d/%Y"),
         "Activity Start Time" = format(mdy_hm(date_collected), "%H:%M"),
         "Activity Start Time Zone" = "PST",
         "Activity Depth/Height Measure" = NA,
         "Activity Depth/Height Unit" = NA,
         "Sample Collection Method ID" = bg_id,
         "Sample Collection Method Context" = "CA_BVR",
         "Sample Collection Equipment Name" = NA,
         "Sample Collection Equipment COmment" = NA,
         "Characteristic Name" = target,
         "Characteristic Name User Supplied" = NA,
         "Method Speciation" = NA,
         "Result Detection Condition" = NA,
         "Result Value" = result,
         "Result Unit" = units,
         "Result Measure Qualifier" = NA,
         "Result Sample Fraction" = NA,
         "Result Status ID" = "Final",
         "ResultTemperatureBasis" = NA,
         "Statistical Base Code" = NA,
         "ResultTimeBasis" = NA,
         "Result Value Type" = "Actual",
         "Result Analytical Method ID" = method,
         "Result Analytical Method Context" = NA,
         "Analysis Start Date" = NA,
         "Result Detection/Quantitation Limit Type" = NA,
         "Result Detection/Quantitation Limit Measure" = quantitation_limit,
         "Result Detection/Quantitation Limit Unit" = units,
         "Result Comment" = notes
  ) %>% 
  select(-c(0:13))

write_csv(bend_wqx, "data/bend_wqx.csv", na = "")

         