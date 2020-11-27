capture log close
log using "01.03.WMS_forAnalysis.log", replace

pause on
set more off
set linesize 120                                                                                                        

// Paths to different folders
do "../lib/header.do"

*-----------------------------------------------------------------
* MAKE WMS FILE WITH JUST VARIABLES WE NEED
*-----------------------------------------------------------------

local wms_vars ///
  account_id cnpj year ///
  lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10  ///
  talent1 talent2 talent3 talent4 talent5 talent6 ///
  family founder competition firmage sic emp_firm ///
  female_t degree_t ///
  xsite1 xsite2 mne_yn union ownership percent_m

use `wmsvars' using "${inpath}/wmslong_clean.dta", clear

use account_id cnpj year in_rais using "${wrkpath}/wms_rais_matched_obs.dta", clear
keep if cnpj ~= ""

merge 1:1 account_id year using "${inpath}/wmslong_clean.dta", keep(match using)
tab _merge

/*quick check to see if the in_RAIS variable makes sense*/
tab in_rais _merge
drop _merge
keep `wms_vars'

* Build overall scores in raw numbers
egen management=rmean(lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10 talent1 talent2 talent3 talent4 talent5 talent6)
egen operations=rmean(lean1 lean2)
egen monitor=rmean(perf1 perf2 perf3 perf4 perf5)
egen target=rmean(perf6 perf7 perf8 perf9 perf10)
egen people=rmean(talent1 talent2 talent3 talent4 talent5 talent6)

label define struc 0 "Unstructured Management" 1 "Structured Management"
gen formal=(management>=3)
label values formal struc



la var management 		"MGMT: Overall management score"
la var operations 		"MGMT: Average of lean1 & lean2"
la var monitor 			"MGMT: Average of perf1 to perf5"
la var target 			"MGMT: Average of perf6 to perf10"
la var people 			"MGMT: Average of talent1 to talent6"
la var formal       "Management score >= 3"

save "${builtpath}/wmslong_forAnalysis.dta", replace

cap log close