library(tidyverse)
library(readxl)
library(ggplot2)
library(janitor)
library(lubridate)
load("lookup_objects.rdata")


# calwatch - wqx submittal required?
# ------------------------------------------------------------------------------
make_activity_id <-
  function(location_id,
           date,
           activity_type,
           equipment_name,
           depth = NULL,
           time = NULL,
           equipment_comment = NULL) {
    YYYYMMDD <- gsub('/', '', date)
    activity <- ifelse(activity_type == "Sample-Routine", "SR", "FM")
    equipment <- case_when(
      equipment_name == "Probe/Sensor" ~ "PS",
      equipment_name == "Water Bottle" ~ "WB",
      TRUE ~ NA_character_
    )
    hhmm <- gsub(':', '', time)
    equipment_comment <- case_when(
      equipment_comment == "Hydrolab Surveyor DS5 Multiprobe" ~ "Hydro",
      equipment_comment == "AlgaeChek Ultra Fluorometer" ~ "Algae",
      TRUE ~ ""
    )
    depth <- ifelse(is.na(depth), "", depth)
    paste(location_id,
          YYYYMMDD,
          hhmm,
          activity,
          equipment,
          depth,
          equipment_comment,
          sep = ":")
  }
# ------------------------------------------------------------------------------

raw_alpha_lab <-
  list.files("data-raw/alpha-lab",
             full.names = T) %>% 
  map_df(~read_excel(.))

# file_path <-
#   "data-raw/alpha-lab/22G2998 FINAL EXCEL 09 Aug 22 1018.xls"
# 
# raw_alpha_lab <- read_excel(file_path) %>% glimpse

clean_alpha_lab <- raw_alpha_lab %>%
  clean_names() %>%
  # Are we using calwatch as project ID?
  mutate(
    "Project ID" = "CalWATCH",
    # No location ID or sampleIDin these alpha lab data
    "Monitoring Location ID" = NA,
    "Activity ID User Supplied (PARENTs)" = NA,
    "Activity Type" = "Sample-Routine",
    "Activity Media Name" = matrix,
    "Activity Start Date" = format(mdy_hms(sampdate), "%m/%d/%Y"),
    "Activity Start Time" = format(mdy_hms(sampdate), "%H:%M"),
    "Activity Start Time Zone" = "PST",
    # not depth or height
    "Activity Depth/Height Measure" = NA,
    "Activity Depth/Height Unit" = NA,
    "Sample Collection Method ID" = "BVR SWQAPP",
    "Sample Collection Method Context" = "CA_BVR",
    "Sample Collection Equipment Name" = "Water Bottle",
    "Sample Collection Equipment Comment" = NA,
    "Characteristic Name" = ifelse(analyte == "E. Coli", "Escherichia coli", analyte),
    "Characteristic Name User Supplied" = NA,
    "Method Speciation" = ifelse(analyte == "Nitrate as N", "as N", NA_character_),
    "Result Detection Condition" = case_when(
      result == "ND" ~ "Not Reported",
      result == "Absent" ~ "Not Present",
      result == "Present" ~ "Detected Not Quantified",
      TRUE ~ NA_character_),
    "Result Value" = ifelse(result == "Absent" | result == "ND" | result == "Present", NA_character_, result),
    "Result Unit" = ifelse(units == ".", NA_character_, units),
    "Result Measure Qualifier" = NA,
    "Result Sample Fraction" = "Total",
    "Result Status ID" = "Final",
    "ResultTemperatureBasis" = NA,
    "Statistical Base Code" = NA,
    "ResultTimeBasis" = NA,
    "Result Value Type" = ifelse(is.na(result), NA_character_, "Actual"),
    "Result Analytical Method ID" = ifelse(is.na(methodname), NA_character_, method_lookup[methodname]),
    "Activity ID (CHILD-subset)" = make_activity_id(
      location_id = `Monitoring Location ID`,
      date = `Activity Start Date`,
      time = `Activity Start Time`,
      activity_type = `Activity Type`,
      equipment_name = `Sample Collection Equipment Name`,
      depth = `Activity Depth/Height Measure`
    ),
    # Casnumber? Context APHA? 
    "Result Analytical Method Context" = method_context_lookup[methodname],
    "Analysis Start Date" = format(mdy_hms(anadate), "%m/%d/%Y"),
    "Result Detection/Quantitation Limit Type" = ifelse(dl == "NA", NA_character_, "Method Detection Level"),
    "Result Detection/Quantitation Limit Measure" = ifelse(dl == "NA", NA_character_, dl),
    "Result Detection/Quantitation Limit Unit" = ifelse(units == ".", NA_character_, units),
    "Result Comment" = NA
    
  ) %>%
  select(-c(0:48)) %>% 
  relocate("Activity ID (CHILD-subset)", .before = "Activity ID User Supplied (PARENTs)")

clean_alpha_lab <- clean_alpha_lab %>% 
  mutate("Result Analytical Method Context" = ifelse(is.na(clean_alpha_lab$`Result Analytical Method ID`), NA_character_, clean_alpha_lab$`Result Analytical Method Context`),
         "Result Unit" = ifelse(is.na(clean_alpha_lab$`Result Value`), NA_character_, clean_alpha_lab$`Result Unit`)) %>% 
  relocate("Result Analytical Method Context", .before = "Analysis Start Date")

write_csv(clean_alpha_lab, "data/alpha_lab_wqx.csv", na = "")
