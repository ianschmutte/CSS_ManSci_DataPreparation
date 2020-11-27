capture log close
log using "02.02.build_WMS_flow_microdata.log", replace

pause on
set more off
set linesize 120                                                                                                        

// Paths to different folders
do "../lib/header.do"

*-----------------------------------------------------------------
* MAKE WMS LINKED TO RAIS MICRODATA
*-----------------------------------------------------------------
use ${wmsvars} using "${inpath}/wmsunique", clear
gen mis_competition = competition==.
replace competition =1 if mis_competition==1
egen fa_mean = mean(firmage)
replace firmage = fa_mean if firmage==.
egen degree_mean = mean(degree_t)
replace degree_t = degree_mean if degree_t==.
drop fa_mean degree_mean

/*Make alternative competition variable*/
gen     compet_cat=1 if competition == 0
replace compet_cat=2 if competition >=1 & competition < 5
replace compet_cat=3 if competition >=5 & competition < .

/*make alternative ownership categories*/
egen own_grp = group(ownership)
gen own_cat = 7
replace own_cat = 1 if own_grp >=4 & own_grp <=7
replace own_cat = 2 if own_grp == 9 | own_grp==10|own_grp==11
replace own_cat = 3 if own_grp == 8 |own_grp==12
replace own_cat = 4 if own_grp == 14
replace own_cat = 5 if own_grp ==13
replace own_cat = 6 if own_grp == 16 |own_grp == 17

** rescale and deal with obs missing out of union, sub in mean var to not miss data
replace union=union/100
egen union_mean=mean(union)
replace union=union_mean if union==.
drop union_mean

gen sic2=substr(string(sic),1,2)


gen lemp=ln(emp_firm)
gen lfirmage = ln(firmage)

drop if cnpj == ""

*------------------------------
* BUILD MANAGEMENT VARIABLES AND STANDARDIZE AKM MEASURES
*------------------------------
* Build overall scores in raw numbers
egen management=rmean(lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10 talent1 talent2 talent3 talent4 talent5 talent6)
egen operations=rmean(lean1 lean2)
egen monitor=rmean(perf1 perf2 perf3 perf4 perf5)
egen target=rmean(perf6 perf7 perf8 perf9 perf10)
egen people=rmean(talent1 talent2 talent3 talent4 talent5 talent6)
* Building z-scores

* Step 1: standardize each question
foreach var in lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10 talent1 talent2 talent3 talent4 talent5 talent6{
egen z`var'=std(`var') 
}

* Step 2: build indices
egen zmanagement=rmean(zlean1 zlean2 zperf1 zperf2 zperf3 zperf4 zperf5 zperf6 zperf7 zperf8 zperf9 zperf10 ztalent1 ztalent2 ztalent3 ztalent4 ztalent5 ztalent6) 
egen zoperations=rmean(zlean1 zlean2)
egen zmonitor=rmean(zperf1 zperf2 zperf3 zperf4 zperf5)
egen ztarget=rmean(zperf6 zperf7 zperf8 zperf9 zperf10)
egen zpeople=rmean(ztalent1 ztalent2 ztalent3 ztalent4 ztalent5 ztalent6)

* Step 3: standardize the indices

foreach var in zmanagement zoperations zmonitor ztarget zpeople {
egen z`var'=std(`var') 
}

drop zmanagement zoperations zmonitor ztarget zpeople

rename zzmanagement zmanagement
rename zzoperations zoperations
rename zzmonitor zmonitor
rename zztarget ztarget
rename zzpeople zpeople

drop zlean1 zlean2 zperf1 zperf2 zperf3 zperf4 zperf5 zperf6 zperf7 zperf8 zperf9 zperf10 ztalent1 ztalent2 ztalent3 ztalent4 ztalent5 ztalent6

label define struc 0 "Unstructured Management" 1 "Structured Management"
gen formal=(management>=3)
label values formal struc

/*LABEL NEW VARIABLES*/
la var compet_cat       "MGMT: 3 category number of competitors (from BBCVW)"
la var own_cat  "MGMT: 6 categories of ownership (from BBCVW)"
la var zmanagement 		"Management score"
la var zoperations 		"Management score (operations)"
la var zmonitor 			"Management score (monitoring)"
la var ztarget 			"Management score (targets)"
la var zpeople 			"Management score (people)"
la var lemp         "Nat. log of firm employment (WMS)"
la var lfirmage     "Nat. log of firm age (WMS)"
la var sic2         "2-digit SIC code (WMS)"
la var region       "Brazilian region (WMS)"
la var management 		"MGMT: Overall management score"
la var operations 		"MGMT: Average of lean1 & lean2"
la var monitor 			"MGMT: Average of perf1 to perf5"
la var target 			"MGMT: Average of perf6 to perf10"
la var people 			"MGMT: Average of talent1 to talent6"
la var formal       "Management score >= 3"

save "${builtpath}/wmsunique_forAnalysis.dta", replace


/*LOAD RAIS_WMS_FLOWS DATA CREATE SOME VARS AND MERGE WMS VARS*/
merge 1:m cnpj using "${wrkpath}/RAIS_WMS_flows.dta", keep(match) nogen
save "${builtpath}/WMS_RAIS_flow_microdata.dta", replace


*------------------------------
* PLANT-LEVEL FLOW DATA TO REPLICATE TABLES 6 and 7
*------------------------------

use "${wrkpath}/RAIS_WMS_flows.dta", clear

* Determine managerial ability based on their measures
* top quartile of the within-firm distribution
* requires egenmore package ssc install egenmore

egen jole_mgr = xtile(akm_pe), by(cnpj) nq(4)
replace jole_mgr = jole_mgr == 4

/*augment manager list with other supervisors */
replace occ_mngr = 1 if occ_supr == 1
replace occ_labr = 0
replace occ_labr = 1 if occ_mngr == 0

gen occ_mngr_old = occ_mngr
replace occ_mngr_old = 1 if occ_wms_mngr ==1
gen occ_lab_old = 0
replace occ_lab_old = 1 if occ_mngr_old==0

/*standardize the worker effects relative to the WMS-attached stayer sample*/
egen std_pe = std(akm_pe)
replace akm_pe = std_pe
drop std_pe

* Making new pe variables
gen lw_mngr_jole     = log_wage if jole_mgr==4
gen pe_mngr_jole 	= akm_pe if jole_mgr==4
gen lw_lab_jole    = log_wage if jole_mgr!=4
gen pe_lab_jole   = akm_pe if jole_mgr!=4
gen lw_mngr        = log_wage if occ_mngr == 1
gen pe_mngr 		    = akm_pe if occ_mngr==1
gen lw_lab          = log_wage if occ_labr == 1
gen pe_lab 	    = akm_pe if occ_labr==1
gen lw_mngr_old  = log_wage if occ_mngr_old == 1
gen pe_mngr_old          = akm_pe if occ_mngr_old == 1
gen lw_lab_old  = log_wage if occ_lab_old == 1
gen pe_lab_old           = akm_pe if occ_lab_old == 1
gen mngr_share = occ_mngr
gen mngr_share_old = occ_mngr_old

gen AKM_coverage = has_akm_pe
g num_workers = AKM_coverage

gen female_share = 1-male
gen coll_share = coll
gen white_share = race_white

xtile ability_q10 = akm_pe, nq(10)
xtile ability_q4 = akm_pe, nq(4)

gen inflow_p90 = ability_q10 >= 10 & hire == 1 
gen inflow_p75 = ability_q4  >= 4 & hire == 1 
gen inflow_p50 = ability_q4  >= 3 & hire == 1 
gen inflow_p25 = ability_q4  >= 2 & hire == 1 
gen inflow_p10 = ability_q10 >= 2 & hire == 1 
gen inflow_tot = hire == 1 

gen pe_stayers = akm_pe*(hire==0 & sep==0)
gen pe_fires = akm_pe*(fire == 1)
gen age_fires = age*(fire==1)
gen coll_fires = coll*(fire==1)
gen fire_tot = fire

local depvarlist inflow_p10 inflow_p25 inflow_p50 inflow_p75 inflow_p90     


collapse (sum) `depvarlist' inflow_tot fire_tot (mean) pe_stayers pe_fires coll_fires age_fires AKM_coverage female_share coll_share white_share mngr_share* log_wage akm_pe akm_fe lw* pe_mngr* pe_lab*  (count) num_workers, by(cnpj year cnae20_class)

foreach num of numlist 10 25 50 75 90{
	replace inflow_p`num' = inflow_p`num'/inflow_tot
}

// gen AKM_coverage_hours = covered_hours/total_hours

merge m:1 cnpj using "${builtpath}/wmsunique_forAnalysis.dta", keep(match using)

/*detect missings; impute esp for pe_m*/

gen has_akm = AKM_coverage > 0 & AKM_coverage < .
gen mis_akm_pe = akm_pe == .
gen mis_lw_mngr = lw_mngr == .
gen mis_pe_mngr = pe_mngr == .
gen mis_lw_mngr_old = lw_mngr_old == .
gen mis_pe_mngr_old = pe_mngr_old == .
gen mis_lw_mngr_jole = lw_mngr_jole == .
gen mis_pe_mngr_jole = pe_mngr_jole == .
gen mis_lw_lab = lw_lab == .
gen mis_pe_lab = pe_lab == .
gen mis_lw_lab_jole = lw_lab_jole == .
gen mis_pe_lab_jole = pe_lab_jole == .
gen mis_lw_lab_old = lw_lab_old == .
gen mis_pe_lab_old = pe_lab_old == .

replace lw_mngr_jole = log_wage if mis_lw_mngr_jole==1
replace lw_lab_jole = log_wage if mis_lw_lab_jole
replace lw_mngr_old = log_wage if mis_lw_mngr_old == 1
replace lw_lab_old = log_wage if mis_lw_lab_old == 1
replace lw_mngr = lw_mngr_jole if mis_lw_mngr==1
replace lw_lab  = lw_lab_jole if mis_lw_lab==1
replace pe_mngr_jole = akm_pe if mis_pe_mngr_jole==1
replace pe_lab_jole = akm_pe if mis_pe_lab_jole
replace pe_mngr_old = akm_pe if mis_pe_mngr_old == 1
replace pe_lab_old = akm_pe if mis_pe_lab_old == 1
replace pe_mngr = pe_mngr_jole if mis_pe_mngr==1
replace pe_lab  = pe_lab_jole if mis_pe_lab==1


egen fe_mean = mean(akm_fe)
replace akm_fe = fe_mean if akm_fe==. & has_akm==1
drop  fe_mean

replace female_share = female_share*100
replace coll_share = coll_share*100
replace mngr_share = mngr_share*100
replace mngr_share_old = mngr_share_old*100
replace coll_fires = coll_fires*100



*------------------------------
* STANDARDIZE AKM MEASURES
*------------------------------

* Step 3: standardize the indices

foreach var in akm_pe akm_fe pe_mngr pe_lab pe_mngr_jole pe_lab_jole{
egen z`var'=std(`var') 
}

/*LABEL NEW VARIABLES*/

la var zakm_pe      "Mean employee quality"
la var zakm_fe      "Firm effect (in wages)"
la var zpe_mngr     "Mean manager quality (occ.-based)"
la var zpe_lab      "Mean non-manager quality (occ.-based"
la var zpe_mngr_jole "Mean manager quality (BBCVW measure)"
la var zpe_lab_jole "Mean non-manager quality (BBCVW measure)"

la var AKM_coverage "Share of workforce with AKM worker effect"
la var female_share "Female share of workforce"
la var coll_share   "Share of workforce with a college degree"
la var mngr_share   "Share of managers in total workforce"
la var num_workers  "Number of contracts active on Dec 31"


save "${builtpath}/WMS_RAIS_flow_plantdata.dta", replace

cap log close