capture log close
log using "02.02.build_WMS_linked_microdata.log", replace

pause on
set more off
set linesize 120                                                                                                        

// Paths to different folders
do "../lib/header.do"

*-----------------------------------------------------------------
* MAKE WMS LINKED TO RAIS MICRODATA
*-----------------------------------------------------------------
use "${builtpath}/wmslong_forAnalysis.dta", clear
label define manag 0 "Low Management Score" 1 "High Management Score"
qui: sum management, detail		
gen high_manag_p90=(management>r(p90) & management<.) // above 90th percentile
label values high_manag_p90 manag
keep if cnpj ~= ""

merge 1:m cnpj year using "${wrkpath}/RAIS_WMS_merged.dta", keep(match) nogen

/*standardize the worker effects relative to the WMS-attached stayer sample*/
egen std_pe = std(akm_pe)
replace akm_pe = std_pe
drop std_pe


save "${builtpath}/WMS_RAIS_linked_microdata.dta", replace

cap log close