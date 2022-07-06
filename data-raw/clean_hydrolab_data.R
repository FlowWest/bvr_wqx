library(tidyverse)
library(dplyr)
library(janitor)
library(lubridate)
library(hms)

# read data from csv into environment
raw_data <- read_csv('data-raw/FC1.csv', skip = 5, col_types = "c")
# View(raw_data)
glimpse(raw_data)


# -----------------------------------------------------------------------------
regex_pattern <- "\\w+$"
location_id <- unlist(
  str_extract_all(
    read_csv('data-raw/FC1.csv', col_names = FALSE, n_max = 1),
    regex_pattern))

unit_lookup <- tibble("Characteristic Name" = c("Temperature, water", "Specific conductance", "Resistivity", "Salinity", "Totla dissolved solids", "Dissolved oxygen saturation","Dissolved oxygen (DO)", "pH", "Turbidity"),
                      "Result Unit" = c("deg C", "mS/cm", "KOhm/cm", "ppt", "g/L", "%", "mg/L", "None","NTU"))

make_activity_id <- function(location_id, date, activity_type, equipment_name, time = NULL) {
  YYYYMMDD <- gsub('/', '', date)
  activity <- ifelse(activity_type == "Sample-Routine", "SR", "FM")
  equipment <- ifelse(equipment_name == "Probe/Sensor", "PS", NA)
  hhmm <- gsub(':', '', time)
  paste(location_id, YYYYMMDD, hhmm,activity, equipment, sep = ":")
}

cleaned_data <- raw_data %>% 
  select(-c(3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29)) %>% 
  filter(!row_number() %in% c(1,3)) %>% 
  clean_names() %>%
  select(-c("ibv_svr4", "chl", "pcy")) %>%
  rename("Temperature, water" = "temp",
         "Specific conductance" = "sp_cond",
         "Resistivity" = "res",
         "Salinity" = "sal",
         "Total dissolved solids" = "tds",
         "Dissolved oxygen saturation" = "do_percent",
         "Dissolved oxygen (DO)" = "do",
         "pH" = "p_h",
         "Turbidity" = "turb") %>% 
    pivot_longer(!c(date, time, depth10), names_to = "Characteristic Name", "values_to" = "Result Value") %>%  
  left_join(unit_lookup) %>%
  mutate("Project ID" = NA,
         "Monitoring Location ID" = location_id,
         # "Activity ID (CHILD-subset)" = make_activity_id(location_id, date, activity_type, equipment_name, time = NULL), 
         "Activity ID User Supplied(PARENTs)" = NA,
         "Activity Type" = "Field Msr/Obs",
         "Activity Media Name" = "Water",
         "Activity Start Date" = format(mdy(date), "%m/%d/%Y"),
         "Activity Start Time" = format(hm(time), "%I%M"),
         "Activity Start Time Zone" = "PST",
         "Activity Depth/Height Measure" = depth10,
         "Activity Depth/Height Unit" = "m",
         "Sample Collection Method ID" = "BVR Tribal SWQAPP",
         "Sample Collection Method Context" = "CA_BVR",
         "Sample Collection Equipment Name" = "Probe/Sensor",
         "Sample Collection Equipment Comment" = "Hydrolab® Surveyor DS5 Multiprobe 
",
         "Characteristic Name" = `Characteristic Name`,
         "Characteristic Name User Supplied" = NA,
         "Method Speciation" = NA,
         "Result Detection Condition" = NA,
         "Result Value" = `Result Value`,
         "Result Unit" = `Result Unit`,
         "Result Measure Qualifier" = NA,
         "Result Sample Fraction" = NA,
         "Result Status ID" = "Final",
         "ResultTemperatureBasis" = NA,
         "Statistical Base Code" = NA,
         "ResultTimeBasis" = NA,
         "Result Value Type" = "Actual",
         "Activity ID" = make_activity_id(location_id = `Monitoring Location ID`,
                                          date = `Activity Start Date`,
                                          time = `Activity Start Time`,
                                          activity_type = `Activity Type`,
                                          equipment_name = `Sample Collection Equipment Name`),
         "Result Analytical Method ID" = NA,
         "Result Analytical Method Context" = NA,
         "Analysis Start Date" = NA,
         "Result Detection/Quantitation Limit Type" = NA,
         "Result Detection/Quantitation Limit Measure" = NA,
         "Result Detection/Quantitation Limit Unit" = NA,
         "Result Comment" = NA
         
         ) %>% 
  select(-c(date, depth10, time)) %>% 
  glimpse
  # rename("Activity Start Date") )
  
