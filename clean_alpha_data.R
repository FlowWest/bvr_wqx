library(tidyverse)
library(readxl)
library(ggplot2)
library(janitor)
library(lubridate)

# calwatch - wqx submittal required?

make_activity_id <- function(
    location_id, date, activity_type, equipment_name, time = NULL
) {
  YYYYMMDD <- gsub("/", NA, date)
  activity <- ifelse(activity_type == "Sample-Routine", "SR", "FM")
  equipment <- ifelse(equipment_name == "Probe/Sensor", "PS", NA)
  hhmm <- gsub(":", NA, time)
  paste(location_id, YYYYMMDD, hhmm, activity, equipment, sep = ":")
}

#Reading all of the files in the folder
file_path <- "data-raw/22G2998 FINAL EXCEL 09 Aug 22 1018.xls"

raw_alpha_lab <- read_excel(file_path) %>% glimpse

clean_alpha_lab <- raw_alpha_lab %>% 
  clean_names() %>% 
  mutate("Project ID" = project,
         "Activity Media Name" = matrix,
         "Activity Start Date" = format(mdy_hms(sampdate), "%m/%d/%Y"),
         "Activity Start Time" = format(mdy_hms(sampdate), "%H:%M"),
         "Characteristic Name" = analyte,
         "Result Value" = ifelse(result == "Absent", NA_character_, result),
         "Result Unit" = ifelse(units == ".", NA_character_, units),
         "Result Analytical Method ID" = methodcode)

alpha_lab_wqx <- clean_alpha_lab %>% 
  mutate("Monitoring Location ID" = NA,
         "Activity ID User Supplied" = NA,
         "Activity Type" = NA,
         "Activity Start Time Zone" = "PST",
         "Activity Depth/Height Measure" = NA,
         "Activity Depth/Height Unit" = NA,
         "Sample Collection Method ID" = NA,
         "Sample Collection Method Context" = NA,
         "Sample Collection Equipment Name" = NA,
         "Sample Collection Equipment Comment" = NA,
         "Characteristic Name User Supplied" = NA,
         "Method Speciation" = NA,
         "Result Detection Condition" = NA,
         "Result Measure Qualifier" = NA,
         "Result Sample Fraction" = NA,
         "Result Status ID" = "Final",
         "ResultTemperatureBasis" = NA,
         "Statistical Base Code" = NA,
         "ResultTimeBasis" = NA,
         "Result Value Type" = "Actual",
         # "Activity ID (CHILD-subset)" = make_activity_id(location_id = `Monitoring Location ID`,
                                                         # date = `Activity Start Date`,
                                                         # time = `Activity Start Time`,
                                                         # activity_type = `Activity Type`,
                                                         # equipment_name = `Sample Collection Equipment Name`,
                                                         # depth = `Activity Depth/Height Measure`),
         "Result Analytical Method ID" = NA,
         "Result Analytical Method Context" = NA,
         "Analysis Start Date" = NA,
         "Result Detection/Quantitation Limit Type" = NA,
         "Result Detection/Quantitation Limit Measure" = NA,
         "Result Detection/Quantitation Limit Unit" = NA,
         "Result Comment" = NA
         
  ) %>% 
  select(-c(0:48)) %>% 
  relocate("Project ID",
           "Monitoring Location ID",
           # "Activity ID (CHILD-subset)",
           # "Activity ID User Supplied(PARENTs)",
           "Activity Type",
           "Activity Media Name",
           "Activity Start Date",
           "Activity Start Time",
           "Activity Start Time Zone",
           "Activity Depth/Height Measure",
           "Activity Depth/Height Unit",
           "Sample Collection Method ID",
           "Sample Collection Method Context",
           "Sample Collection Equipment Name",
           "Sample Collection Equipment Comment",
           "Characteristic Name",
           "Characteristic Name User Supplied",
           "Method Speciation",
           "Result Detection Condition",
           "Result Value",
           "Result Unit",
           "Result Measure Qualifier",
           "Result Sample Fraction",
           "Result Status ID",
           "ResultTemperatureBasis",
           "Statistical Base Code",
           "ResultTimeBasis",
           "Result Value Type",
           "Result Analytical Method ID",
           "Result Analytical Method Context",
           "Analysis Start Date",
           "Result Detection/Quantitation Limit Measure",
           "Result Detection/Quantitation Limit Unit",
           "Result Comment"
  ) %>% glimpse

write_csv(alpha_lab_wqx, "data/alpha_lab_wqx.csv", na = "")
