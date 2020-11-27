capture log close
log using "01.02.build_reference_distributions.log", replace

pause on
set more off
set linesize 120                                                                                                        

// Paths to different folders
do "../lib/header.do"

*-----------------------------------------------------------------
* MAKE DISTRIBUTIONS IN 2008 and 2013 DATA
*-----------------------------------------------------------------
use "${inpath}/RAIS_WAGES_0813.dta", clear
foreach yr in 2008 2013 {
    preserve
    keep if year==`yr'
    xtile pe_all_q10 = akm_pe , nq(10)
    xtile pe_all_q4 = akm_pe, nq(4)
    xtile wage_all_q5 = log_wage, nq(5)
    drop akm_pe log_wage
    save "${builtpath}/RAIS_quantiles_`yr'.dta", replace
    restore
}
clear

capture log close