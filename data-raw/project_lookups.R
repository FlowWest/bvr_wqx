project_id_lookup <- c(
  # CLM(Clear Lake),MS(Marina),HAB,BVSHORE(Big Valley shoreline sites: M1 or BVCL6),CS(Creek Sampling),SW(Storm Water)
  "M1" = "MS",
  "M2" = "MS",
  "M3" = "MS",
  "M4" = "MS",
  "HSP" = "SW",
  "BVSWD1" = "SW",
  "NBPRSC" = "SW",
  "RSTCC" = "SW",
  "BVCL1" = "SW",
  "BVRTC1" = "SW",
  "BVRTCC" = "SW",
  "BVSWDRV" = "SW",#not in cdx
  "RVSI1" = "SW",#not in cdx
  "RVSI2" = "SW",#not in cdx
  "BVCL2" = "CLM",	
  "BVCL3" = "CLM",	
  "BVCL5" = "CLM",	
  "BVCL6" = "CLM",	
  "BVCL11" = "CLM",	
  "BVCL12" = "CLM",	
  "BVCL13" = "CLM",	
  "BVCL14" = "CLM",	
  "BVCL15" = "CLM",	
  "BVCL16" = "CLM",	
  "BVCL17" = "CLM",	
  "BVCL18" = "CLM",	
  "BVCL19" = "CLM",	
  "BVCL20" = "CLM",
  "FC1" = "CS", 
  "FC2" = "CS",
  "FC3" = "CS",#not in cdx
  "MC1" = "CS",
  "MC2" = "CS",
  "TC1" = "CS",
  "AC1" = "CS",
  "AC2" = "CS",
  "AC3" = "CS",
  "AC4" = "CS",
  "MCC1" = "CS",
  "KC1" = "CS",
  "CC1" = "CS",
  "SC1" = "CS",
  "SC2" = "CS",#not in cdx
  "SHC2"= "CS",#not in cdx
  "CC2" = "CS",#not in cdx
  "SIEG01" = "CS",#not in cdx
  "COOP01" = "CS",#not in cdx
  "CLOV01" = "CS",#not in cdx
  "DRY01" = "CS",#not in cdx
  "COY01" = "CS",#not in cdx
  "SCOT01"= "CS",#not in cdx
  "AND01" = "CS",#not in cdx
  "NFORK01" = "CS",#not in cdx
  "LONG01" = "CS", #not in cdx
  "PUT01" = "CS", #not in cdx
  "MID01"= "CS", #not in cdx
  "KC5"= "CS", #not in cdx
  "AP01" = "HAB",
  "BP" = "HAB",
  "CLOAKS01" = "HAB",
  "CLV7" = "HAB",
  "CP" = "HAB",
  "ELEM01" = "HAB",
  "GH" = "HAB",
  "HB" = "HAB",
  "JB" = "HAB",
  "KEYS01" = "HAB",
  "KEYS03" = "HAB",
  "KP01" = "HAB",
  "LC01" = "HAB",
  "LPTNT" = "HAB",
  "LS" = "HAB",
  "LS2" = "HAB",
  "LUC01" = "HAB",
  "RED01" = "HAB",
  "RODS" = "HAB",
  "SBMMEL01" = "HAB",
  "SHADY01" = "HAB",
  "UBL" = "HAB",
  "CL-1" = "HAB",
  "CL-3" = "HAB",
  "CL-4" = "HAB",
  "CL-5" = "HAB",
  "LA-03" = "HAB",
  "NR-02" = "HAB",
  "OA-04" = "HAB",
  "UA-01" = "HAB",
  "UA-06" = "HAB",
  "UA-07" = "HAB",
  "UA-08" = "HAB",
  "PILLS01" = "HAB", #not in cdx
  "LAKEPILS01" = "HAB" #not in cdx
  )

unit_lookup <- c(
  "Temperature, water" = "deg C", 
  "Specific conductance" = "mS/cm", 
  "Resistivity" = "KOhm/cm", 
  "Salinity" = "ppt", 
  "Total dissolved solids" = "g/L", 
  "Dissolved oxygen saturation" = "%",
  "Dissolved oxygen (DO)" = "mg/L", 
  "pH" = "None", 
  "Turbidity" = "NTU")

method_lookup <- c(
  "SM9223B" = "9223-B",
  "EPA 300.0" = "300.0",
  "ELISA" = "520060",
  "QPCR" = "1611"
)

method_context_lookup <- c(
  "SM9223B" = "APHA",
  "EPA 300.0" = "USEPA",
  "ELISA" = "ABRAXIS LLC",
  "QPCR" = "USEPA"
)
save_objects <- function() {
  save(project_id_lookup, unit_lookup, method_lookup, method_context_lookup,
       file="lookup_objects.rdata")
  
}

save_objects()
