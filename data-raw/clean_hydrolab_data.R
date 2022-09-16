library(tidyverse)
library(dplyr)
library(janitor)
library(lubridate)
library(hms)
load("lookup_objects.rdata")

# read data from csv into environment
raw_data <- read_csv('data-raw/FC1.csv', skip = 5, col_types = "c")
# View(raw_data)
glimpse(raw_data)

# ------------------------------------------------------------------------------
#Note: two locations M1 and BVCL6 are used in two projects (BVSHORE) 

regex_pattern <- "\\w+$"
location_id <- unlist(
  str_extract_all(
    read_csv('data-raw/FC1.csv', col_names = FALSE, n_max = 1),
    regex_pattern))
# -----------------------------------------------------------------------------
make_activity_id <- function(location_id, date, activity_type, equipment_name, depth = NULL, time = NULL) {
  YYYYMMDD <- gsub('/', '', date)
  activity <- ifelse(activity_type == "Sample-Routine", "SR", "FM")
  equipment <- ifelse(equipment_name == "Probe/Sensor", "PS", NA)
  hhmm <- gsub(':', '', time)
  equipment_comment <- case_when(
    equipment_name == "Hydrolab Surveyor DS5 Multiprobe" ~ "Hydro",
    equipment_name == "AlgaeChek Ultra Fluorometer" ~ "Algae", 
    TRUE ~ NA_character_)
  paste(location_id, YYYYMMDD, hhmm,activity, equipment, depth, equipment_comment, sep = ":")
}
# ------------------------------------------------------------------------------
formatted_for_wqx <- raw_data %>% 
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
  mutate("Project ID" = project_id_lookup[location_id],
         "Monitoring Location ID" = location_id,
         # "Activity ID (CHILD-subset)" = make_activity_id(location_id, date, activity_type, equipment_name, time = NULL), 
         "Activity ID User Supplied(PARENTs)" = "",
         "Activity Type" = "Field Msr/Obs",
         "Activity Media Name" = "Water",
         "Activity Start Date" = format(mdy(date), "%m/%d/%Y"),
         "Activity Start Time" = format(parse_date_time(time, c('HMS', 'HM')), "%H:%M"),
         "Activity Start Time Zone" = "PST",
         "Activity Depth/Height Measure" = as.numeric(depth10),
         "Activity Depth/Height Unit" = "m",
         "Sample Collection Method ID" = "BVR Tribal SWQAPP",
         "Sample Collection Method Context" = "CA_BVR",
         "Sample Collection Equipment Name" = "Probe/Sensor",
         "Sample Collection Equipment Comment" = "Hydrolab Surveyor DS5 Multiprobe 
",
         "Characteristic Name" = `Characteristic Name`,
         "Result Unit" = unit_lookup[`Characteristic Name`],
         "Characteristic Name User Supplied" = "",
         "Method Speciation" = "",
         "Result Detection Condition" = "",
         "Result Value" = `Result Value`,
         "Result Unit" = `Result Unit`,
         "Result Measure Qualifier" = "",
         "Result Sample Fraction" = "",
         "Result Status ID" = "Final",
         "ResultTemperatureBasis" = "",
         "Statistical Base Code" = "",
         "ResultTimeBasis" = "",
         "Result Value Type" = "Actual",
         "Activity ID (CHILD-subset)" = make_activity_id(location_id = `Monitoring Location ID`,
                                          date = `Activity Start Date`,
                                          time = `Activity Start Time`,
                                          activity_type = `Activity Type`,
                                          equipment_name = `Sample Collection Equipment Name`,
                                          depth = `Activity Depth/Height Measure`),
         "Result Analytical Method ID" = "",
         "Result Analytical Method Context" = "",
         "Analysis Start Date" = "",
         "Result Detection/Quantitation Limit Type" = "",
         "Result Detection/Quantitation Limit Measure" = "",
         "Result Detection/Quantitation Limit Unit" = "",
         "Result Comment" = ""
         
         ) %>% 
  select(-c(date, depth10, time)) %>% 
  relocate("Project ID",
           "Monitoring Location ID",
           "Activity ID (CHILD-subset)",
           "Activity ID User Supplied(PARENTs)",
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
           )

write_csv(formatted_for_wqx, "data/hydrolab_wqx.csv")

  
