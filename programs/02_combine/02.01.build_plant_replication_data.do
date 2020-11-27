capture log close
log using "02.01.build_plant_replication_data.log", replace

pause on
set more off
set linesize 120                                                                                                        

// Paths to different folders
do "../lib/header.do"

*-----------------------------------------------------------------
* MAKE PLANT-LEVEL RAIS FILE MERGED WITH WMS FOR REPEATED CROSS-SECTION ANALYSIS
*-----------------------------------------------------------------
use "${wrkpath}/RAIS_WMS_merged.dta", clear
drop if log_wage == .

/*For the cross-section analysis, use distribution of workers present on Dec 31*/
drop if sep == 1 

rename has_akm_pe AKM_coverage /*indicates whether this observation has an associated worker effect*/
/* gen covered_hours = has_akm_pe*spell_hours_pred */
/* gen total_hours = spell_hours_pred */

* Determine managerial ability based on their measures
* top quartile of the within-firm distribution
* requires egenmore package ssc install egenmore
egen jole_mgr = xtile(akm_pe), by(cnpj year) nq(4)

/*standardize the worker effects relative to the WMS-attached stayer sample*/
egen std_pe = std(akm_pe)
replace akm_pe = std_pe
drop std_pe

/*augment manager list with other supervisors */
replace occ_mngr = 1 if occ_supr == 1
replace occ_labr = 0
replace occ_labr = 1 if occ_mngr == 0

gen occ_mngr_old = occ_mngr
replace occ_mngr_old = 1 if occ_wms_mngr ==1
gen occ_lab_old = 0
replace occ_lab_old = 1 if occ_mngr_old==0

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

drop jole_mgr

g pe_10 = akm_pe
g pe_90 = akm_pe
g pe_sd = akm_pe
g w_90 = log_wage
g w_10 = log_wage
g w_sd = log_wage
g median_wage = exp(log_wage)
g num_workers = AKM_coverage

gen female_share = 1-male
gen coll_share = coll
gen white_share = race_white


collapse (median) median_wage (p10) w_10 pe_10 (p90) w_90 pe_90 (mean) AKM_coverage  mngr_share* female_share coll_share white_share log_wage akm_pe akm_fe pe_mngr* pe_lab* lw_* (sd) w_sd pe_sd (count) num_workers, by(cnpj year state cnae20_class)

g cv_pe = pe_sd / akm_pe
g cv_w =  w_sd / log_wage
replace pe_sd = 0 if pe_sd == .
replace w_sd = 0 if w_sd == .
replace cv_w = 0 if cv_w == .
replace cv_pe = 0 if cv_pe == .
g pe9010 = pe_90 - pe_10
g w9010 = w_90 - w_10

// gen AKM_coverage_hours = covered_hours/total_hours

merge 1:m cnpj year using "${builtpath}/wmslong_forAnalysis.dta", keep(match using)
gen in_rais = _merge==3
drop _merge

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

gen mis_competition = competition==.
replace competition =1 if mis_competition==1
egen fa_mean = mean(firmage)
replace firmage = fa_mean if firmage==.
egen degree_mean = mean(degree_t)
replace degree_t = degree_mean if degree_t==.
egen fe_mean = mean(akm_fe)
replace akm_fe = fe_mean if akm_fe==. & has_akm==1
drop fa_mean degree_mean fe_mean

/*Make alternative competition variable*/
gen     compet_cat=1 if competition == 0
replace compet_cat=2 if competition >=1 & competition < 5
replace compet_cat=3 if competition >=5 & competition < .

/*make alternative ownership categories*/
egen own_grp=group(ownership)
gen own_cat = .
replace own_cat = 1 if own_grp >=4  & own_grp <=7 // Family owned
replace own_cat = 2 if own_grp >= 9 & own_grp <=11 // Founder owned
replace own_cat = 3 if own_grp == 14 // Manager owned
replace own_cat = 4 if own_grp == 2 | own_grp==13 | own_grp==16 | own_grp==17 // Private (incl dispersed sh)
replace own_cat = 5 if own_grp ==1 | own_grp==3 | own_grp==8 | own_grp==15 // Institutional 
replace own_cat = 6 if own_grp == 12 // Mainly govt


** rescale and deal with obs missing out of union, sub in mean var to not miss data
replace union=union/100
egen union_mean=mean(union)
replace union=union_mean if union==.
drop union_mean

replace female_share = female_share*100
replace coll_share = coll_share*100
replace mngr_share = mngr_share*100
replace mngr_share_old = mngr_share_old*100

gen sic2=substr(string(sic),1,2)
gen region = real(substr(state,1,1))

gen lemp=ln(emp_firm)
gen lfirmage = ln(firmage)

*------------------------------
* BUILD MANAGEMENT VARIABLES AND STANDARDIZE AKM MEASURES
*------------------------------

* Building z-scores

* Step 1: standardize each question
foreach var in lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10 talent1 talent2 talent3 talent4 talent5 talent6{
egen z`var'=std(`var') if has_akm == 1
}

* Step 2: build indices
egen zmanagement=rmean(zlean1 zlean2 zperf1 zperf2 zperf3 zperf4 zperf5 zperf6 zperf7 zperf8 zperf9 zperf10 ztalent1 ztalent2 ztalent3 ztalent4 ztalent5 ztalent6) 
egen zoperations=rmean(zlean1 zlean2)
egen zmonitor=rmean(zperf1 zperf2 zperf3 zperf4 zperf5)
egen ztarget=rmean(zperf6 zperf7 zperf8 zperf9 zperf10)
egen zpeople=rmean(ztalent1 ztalent2 ztalent3 ztalent4 ztalent5 ztalent6)

* Step 3: standardize the indices

foreach var in zmanagement zoperations zmonitor ztarget zpeople akm_pe akm_fe pe_mngr pe_lab pe_mngr_jole pe_lab_jole pe_mngr_old pe_lab_old{
egen z`var'=std(`var') if has_akm==1
}

drop zmanagement zoperations zmonitor ztarget zpeople

rename zzmanagement zmanagement
rename zzoperations zoperations
rename zzmonitor zmonitor
rename zztarget ztarget
rename zzpeople zpeople



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
la var zakm_pe      "Mean employee quality"
la var zakm_fe      "Firm effect (in wages)"
la var zpe_mngr     "Mean manager quality (occ.-based)"
la var zpe_lab      "Mean non-manager quality (occ.-based"
la var zpe_mngr_jole "Mean manager quality (BBCVW measure)"
la var zpe_lab_jole "Mean non-manager quality (BBCVW measure)"
la var median_wage "Median wage (RAIS)"
la var w_10        "10th percentile wage (RAIS)"
la var w_90        "90th percentile wage (RAIS)"
la var pe_10       "10th percentile AKM worker effect (RAIS)"
la var pe_90       "90th percentile AKM worker effect (RAIS)"
la var w9010       "90-10 ln(Wages)"
la var pe9010      "90-10 ln(Employee quality)"
la var cv_w        "Coefficient of Variation in Log Wages"
la var cv_pe       "Coefficient of Variation in ln(Employee quality)"
la var AKM_coverage "Share of workforce with AKM worker effect"
la var female_share "Female share of workforce"
la var coll_share   "Share of workforce with a college degree"
la var mngr_share   "Share of managers in total workforce"
la var num_workers  "Number of contracts active on Dec 31"


save "${builtpath}/WMS_plantyear_with_RAIS.dta", replace

capture log close
