* Daniela Scur scur@gmail.com
* Modified by Ian M. Schmutte schmutte@uga.edu
* 26 Feb 2020

    capture log close
    log using "./wms_prepare.log", replace

    pause on
    set more off
    set linesize 200

// Paths to different folders
global trunk "/projects/schmutte/MGMT/MGMT_source/data/programs/_dev_replication/"
local inpath ${trunk}/data/input/WMS
local outpath ${trunk}/data/prepared/
local tmppath ${trunk}/data/interwrk

*---------------------------------------------------------------------------------------*
* WMS Do file
* This file takes the raw data from the WMS and cleans it for multiple purposes
*---------------------------------------------------------------------------------------*

use "`inpath'/wms_br_raw.dta", clear
describe

*------------------------------------------------------------------------------------------
* Drop variables that were not included in 2008/2013, or are useless
*------------------------------------------------------------------------------------------

drop company_id listeningto time partm partnm delta_own_yn switchm switchnm childm childnm subisidm subisidnm hols age language mleave_m mleave_nm exporting percent_t pace_workmiss pace_taskmiss county hols_m hols_nm slopeceo slopepm CEO_PM aCEO_PM indgroup_id indgroup_name indgroupfounded ultimate_id ultimate_name own_status own_correction ceo_salary ref_ans_salary i_industrytenure i_told_age i_nationality i_nat_guess i_studied_abroad i_china i_attitude_china i_government i_attitude_government i_perceptions county account_id_20110210 account_id_20110331 postcode_p2 postcode_source year sic_acc2011 status_survey2011 sic_acc2014 sic_manual2014 status_survey2014 sic_accflag i_environment hols_m hols_nm ownership_3y lemp_firm ldegree_t zcentral4 zcentral5 zcentral6 zcentral7 zorg zorg2 zmanagement

*------------------------------
* Cleaning various variables
*------------------------------

* Clean family
cap drop family founder family_3y founder_3y

g family=.
replace family=1 if substr(ownership,1,6)=="Family"
replace family=0 if family!=1
g founder=.
replace founder=1 if substr(ownership,1,7)=="Founder"
replace founder=0 if founder!=1
g ff=1 if family==1 | founder==1
replace ff=0 if ff!=1


* Clean gender
replace i_sex=0 if i_sex==1
replace i_sex=1 if i_sex==2
lab define i_sex 0 Female 1 Male, replace

* Clean degree (in 2008, only coded yes/no, in 2013, coded which degree they had)
replace i_skills="Degree" if i_degree==1 
replace i_degree=1 if i_skills=="Doctoral Degree" | i_skills=="Graduate/Professional Degree" | i_skills=="Post-Graduate Degree"
replace i_degree=0 if i_skills=="Secondary" | i_skills=="Upper Secondary"

* Clean CEO
replace ceo="" if substr(ceo,1,2)=="4A"

* Clean outsourced (truncate at 10%)
replace outsourced=10 if outsourced>10

* Clean export
replace export=export*100 if export>0 & export<1
rename export export_share

g export=1 if export_share>0 & export_share!=.
replace export=0 if export!=1 & export_share!=.

g export25=1 if export_share>=25 & export_share!=.
replace export25=0 if export25!=1 & export_share!=.

g export50=1 if export_share>=50 & export_share!=.
replace export50=0 if export50!=1 & export_share!=.

* Clean region

g macroreg=""
replace macroreg="NE" if region=="alagoas"
replace macroreg="N" if region=="amazonas"
replace macroreg="NE" if region=="bahia"
replace macroreg="NE" if substr(region,1,4)=="cear"
replace macroreg="SE" if substr(region,1,3)=="esp"
replace macroreg="CO" if substr(region,1,3)=="goi"
replace macroreg="NE" if substr(region,1,4)=="mara"
replace macroreg="CO" if region=="mato grosso"
replace macroreg="CO" if region=="mato grosso do sul"
replace macroreg="SE" if region=="minas gerais"
replace macroreg="S" if substr(region,1,5)=="paran"
replace macroreg="NE" if substr(region,1,4)=="para"
replace macroreg="N" if substr(region,1,3)=="par"
replace macroreg="NE" if region=="pernambuco"
replace macroreg="N" if substr(region,1,4)=="piau"
replace macroreg="SE" if region=="rio de janeiro"
replace macroreg="NE" if region=="rio grande do norte"
replace macroreg="S" if region=="rio grande do sul"
replace macroreg="N" if substr(region,1,4)=="rond"
replace macroreg="S" if region=="santa catarina"
replace macroreg="NE" if region=="sergipe"
replace macroreg="SE" if substr(region,5,5)=="paulo"
replace macroreg="CO" if region=="tocantins"

replace region="ceara" if substr(region,1,4)=="cear"
replace region="espirito santo" if substr(region,1,3)=="esp"
replace region="goias" if substr(region,1,3)=="goi"
replace region="maranhao" if substr(region,1,4)=="mara"
replace region="parana" if substr(region,1,5)=="paran"
replace region="paraiba" if substr(region,1,4)=="para"
replace region="para" if substr(region,1,3)=="par"
replace region="piaui" if substr(region,1,4)=="piau"
replace region="rondonia" if substr(region,1,4)=="rond"
replace region="sao paulo" if substr(region,5,5)=="paulo"

replace region=proper(region) 

*----- Respondent position

cap drop i_pos_clean
g i_pos_clean=""

replace i_pos_clean="DIRECTOR" if strpos(i_position,"DIRETOR")
replace i_pos_clean="DIRECTOR" if strpos(i_position,"DIRECTOR") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"DIRETIOR") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"DIRETRO") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"DIRETRO") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"PRESIDENTE") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"PROPRIET") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"CHEFE") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"SHAREHOLDER") & i_pos_clean==""
replace i_pos_clean="DIRECTOR" if strpos(i_position,"OWNER") & i_pos_clean==""

replace i_pos_clean="MANAGER" if strpos(i_position,"GERENT") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"GERERENTE") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"GERETE") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"GESTOR") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"MANAGER") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"MANGER") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"ADMINISTRA") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"ADMINSTRADOR") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"ADMISTRADOR") & i_pos_clean==""
replace i_pos_clean="MANAGER" if strpos(i_position,"GENERAL GERAL") & i_pos_clean==""

replace i_pos_clean="SUPERVISOR" if strpos(i_position,"SUPERVISOR") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"ENCARREGADO") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"SUPERINTENDENTE") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"RESPONSAVEL") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"LEADER") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"ASSISTANT") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"MARKETING") & i_pos_clean==""
replace i_pos_clean="SUPERVISOR" if strpos(i_position,"PURCHASE") & i_pos_clean==""

replace i_pos_clean="COORD" if strpos(i_position,"COORDENADOR") & i_pos_clean==""
replace i_pos_clean="COORD" if strpos(i_position,"CORDENADOR") & i_pos_clean==""
replace i_pos_clean="COORD" if strpos(i_position,"COORDINATOR") & i_pos_clean==""
replace i_pos_clean="COORD" if strpos(i_position,"PLANNER") & i_pos_clean==""
replace i_pos_clean="COORD" if strpos(i_position,"CONTROLLER") & i_pos_clean==""
replace i_pos_clean="COORD" if strpos(i_position,"CONTROLO") & i_pos_clean==""
replace i_pos_clean="COORD" if strpos(i_position,"CLASSIFICADOR") & i_pos_clean==""

replace i_pos_clean="ENG" if strpos(i_position,"ENGENHEIRO") & i_pos_clean==""
replace i_pos_clean="ENG" if strpos(i_position,"ENGINEER") & i_pos_clean==""
replace i_pos_clean="ENG" if strpos(i_position,"ENGINNER") & i_pos_clean==""

* Clean i_seniority based on title 
replace i_seniority=1 if i_pos_clean=="DIRECTOR"
replace i_seniority=2 if i_pos_clean=="MANAGER"
replace i_seniority=3 if i_pos_clean=="SUPERVISOR"
replace i_seniority=3 if i_pos_clean=="COORD"

*cap drop lemp_firm
*g lemp_firm=ln(emp_firm)

*------------------------------
* BUILD MANAGEMENT VARIABLES
*------------------------------

cap drop management operations monitor target people
cap drop zmanagement

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

foreach var in zmanagement zoperations zmonitor ztarget zpeople{
egen z`var'=std(`var')
}

drop zmanagement zoperations zmonitor ztarget zpeople

rename zzmanagement zmanagement
rename zzoperations zoperations
rename zzmonitor zmonitor
rename zztarget ztarget
rename zzpeople zpeople

drop zlean1 zlean2 zperf1 zperf2 zperf3 zperf4 zperf5 zperf6 zperf7 zperf8 zperf9 zperf10 ztalent1 ztalent2 ztalent3 ztalent4 ztalent5 ztalent6


*---- CENTRALIZATION MEASURES

gen lcentral5=ln(1+central5)

cap drop central
egen central=rowmean(central4 central6 central7)

foreach var in central4 central6 central5 central7{
cap drop z`var'
egen z`var'=std(`var')
}

cap drop zorg zorg2
egen zorg=rowmean(zcentral*)
egen zzorg=std(zorg)
drop zorg
rename zzorg zorg

egen zorg2=rowmean(zcentral4 zcentral6 zcentral7) 
egen zzorg2=std(zorg2)
drop zorg2
rename zzorg2 zorg2


*------------------------------
* LABELS
*------------------------------

la var account_id 		"ID: BvD account ID (original)"
la var account_id_new 	"ID: BvD account ID (latest)"
la var cnpj 			"ID: CNPJ"
la var company_name 	"ID: Company name"
la var sic 				"ID: 3-digit SIC"
la var cty 				"ID: 2-digit country code"
la var country 			"ID: Country name"
la var region 			"ID: State"
la var postcode_p1 		"ID: Postcode (plant)"
la var postcode_hq 		"ID: Postcode (HQ)"
la var wave 			"ID: Year of WMS wave"
la var continent 		"ID: Continent"
la var tickersymbol 	"ID: Ticker symbol"
la var macroreg 		"ID: Macro-region"

* Management scores
la var management 		"MGMT: Overall management score"
la var operations 		"MGMT: Average of lean1 & lean2"
la var monitor 			"MGMT: Average of perf1 to perf5"
la var target 			"MGMT: Average of perf6 to perf10"
la var people 			"MGMT: Average of talent1 to talent6"
la var zmanagement 		"MGMT: Management z-score"
la var zoperations 		"MGMT: Operations z-score"
la var zmonitor 		"MGMT: Monitoring z-score"
la var ztarget 			"MGMT: Target z-score"
la var zpeople 			"MGMT: People z-score"
la var lean1 			"MGMT: Intro to lean"
la var lean2 			"MGMT: Rationale for lean"
la var perf1 			"MGMT: Process Documentation" 
la var perf2 			"MGMT: Performance Tracking" 
la var perf3 			"MGMT: Performance Review"
la var perf4 			"MGMT: Performance Dialogue"
la var perf5 			"MGMT: Consequence Management" 
la var perf6 			"MGMT: Type of Targets" 
la var perf7 			"MGMT: Interconnection of Goals" 
la var perf8 			"MGMT: Time Horizon" 
la var perf9 			"MGMT: Goals are Stretching" 
la var perf10 			"MGMT: Clarity of Goals and Measurement"
la var talent1 			"MGMT: Instilling a Talent Mindset"
la var talent2 			"MGMT: Building a High-Performance Culture" 
la var talent3 			"MGMT: Making Room for Talent" 
la var talent4 			"MGMT: Developing Talent" 
la var talent5 			"MGMT: Creating a Distinctive EVP" 
la var talent6 			"MGMT: Retaining Talent"

la var selfscore 		"MGMT: Manager self-score"
la var selfops 			"MGMT: Manager self-score (operations)"
la var selfpeople 		"MGMT: Manager self-score (people)"

* Survey controls
la var analyst 			"SVY: Analyst (interviewer) name"
la var duration 		"SVY: Interview duration"
la var i_knowledge 		"SVY: Interviewee knowledge of firm"
la var i_willing 		"SVY: Interviewee willingness"
la var i_impatience 	"SVY: Interviewee impatience"
la var reliability 		"SVY: Reliability score (knowledge+willing)"
la var i_attitude_en 	"SVY: Attitude towards environment"
la var rescheduled 		"SVY: # times interviewed rescheduled"
la var i_seniority 		"SVY: Mgr seniority (analyst coded)"
la var i_age 			"SVY: Mgr age (guess)"
la var date 			"SVY: Survey date"
la var dd 				"SVY: Day of interview"
la var mm 				"SVY: Month of interview"
la var yy 				"SVY: Year of interview"
la var dow 				"SVY: Day of week of interview"
la var hour 			"SVY: Hour of interview"
la var minute 			"SVY: Minute of interview"
la var nearesthour 		"SVY: Nearest hour of interview"

* Manager (interviewee) characteristics/controls
la var i_position 		"MGR: Verbatim position in the company"
la var i_pos_clean 		"MGR: Position (clean)"
la var i_posttenure 	"MGR: Tenure in post"
la var i_comptenure 	"MGR: Tenure in company"
la var i_skills 		"MGR: Manager eduation level"
la var i_degree 		"MGR: =1 if mgr has degree"
la var i_sex 			"MGR: =1 if mgr is male"

la var i_grad_course 	"MGR: Undergrad course type"
la var i_postgrad_course "MGR: Graduate course type"
la var i_doctoral_course "MGR: Doctoral course type"
la var i_grad_yr 		"MGR: Year graduated (undergrad)"
la var i_postgrad_yr 	"MGR: Year graduated (graudate)"
la var i_doctoral_yr 	"MGR: Year graduated (doctoral)"

* Organization
la var span 			"ORG: span of control"
la var central 			"ORG: Average of centralization measure"
la var central4 		"ORG: Hiring autonomy"
la var central5 		"ORG: Max capital investment (US$)"
la var central6 		"ORG: Marketing autonomy"
la var central7 		"ORG: New product intro autonomy"
la var levels2ceo 		"ORG: Layers btw CEO-shopfloor"
la var levels2pm 		"ORG: Layers btw PM-shopfloor"
la var levels_ceopm 	"ORG: Layers btw CEO-PM"
la var deltalevels 		"ORG: Changed layers in past 3 years"
la var numberlevels 	"ORG: # levels changed in past 3 years"
la var lcentral5 		"ORG: Ln of max k investment"
la var zcentral4 		"ORG: z-score of hiring autonomy"
la var zcentral5 		"ORG: z-score of max k investment"
la var zcentral6 		"ORG: z-score of marketing autonomy"
la var zcentral7 		"ORG: z-score of new products autonomy"
la var zorg 			"ORG: z-score of all centralization measures"
la var zorg2 			"ORG: z-score of central 4,6,7"

* Ownership 
la var ownership 		"OWN: Who knows the firm"
la var other_ownership 	"OWN: Who owns the firm (if other)"
la var ownership_pre 	"OWN: Who owned the firm previously"
la var other_ownership3yrs "OWN: Who owned the firm 3yrs ago (if other)"
la var ownership_year 	"OWN: Year when ownership changed"
la var generation 		"OWN: Generation of family firm"
la var n_family_manag 	"OWN: # family members in management"
la var ceo 				"OWN: Who is the CEO (relative to family)"
la var family 			"OWN: =1 if family firm"
la var founder 		 	"OWN: =1 if founder firm"
la var ff 				"OWN: =1 if founder or family firm"
la var changed_ownership_3y "OWN: Has ownership changed in the past 3 yrs?"
la var delta_own 		"OWN: Changed ownership in the last 3 years (from what)"

* Firm characteristics
la var emp_firm 		"FIRM: # employees (firm)"
la var emp_plant 		"FIRM: # employees (plant)"
la var onsite 			"FIRM: Is HQ on site?"
la var xsite1 			"FIRM: # production sites (total)"
la var xsite2 			"FIRM: # production sites (abroad)"
la var mne_yn 			"FIRM: =1 if multinational"
la var mne_cty 			"FIRM: MNE home country"
la var mne_d 			"FIRM: =1 if domestic MNE"
la var mne_f 			"FIRM: =1 if foreign MNE"
la var firmage 			"FIRM: firm age"
la var firmfounded 		"FIRM: firm foundation date"

la var plantage 		"FIRM: Plant age"
la var competition 		"FIRM: # competitors (reported/perceived)"

la var outsourced 		"FIRM: % production outsourced"
la var export_share 	"FIRM: % production exported"
la var export 			"FIRM: =1 if firm exports"
la var export25 		"FIRM: =1 if firm exports >25% output"
la var export50 		"FIRM: =1 if firm exports >50% output"

* Worker/pay variables

la var percent_m 		"WORK: % mgrs in the firm"
la var percent_nm 		"WORK: % non-mgrs in the firm"
la var degree_m 		"WORK: % mgrs with college degree"
la var degree_nm 		"WORK: % non-mgrs with college degree"
la var degree_t 		"WORK: % all workers with degree"
la var stem_m 			"WORK: % mgrs with STEM degree"
la var stem_nm 			"WORK: % non-mgrs with STEM degree"
la var female_m 		"WORK: % female, mgrs"
la var female_nm 		"WORK: % female, non-mgrs"
la var female_t 		"WORK: % female, total"
la var mng_left12mnths 	"WORK: % mgr turnover (past 12 mo)"
la var union 			"WORK: % union members"
la var bonus1 			"WORK: Mgr refused to answer"
la var bonus2 			"WORK: bonus as % of total salary"
la var bonus5 			"WORK: salary bump (%) when promotion is given"
la var bonus3 			"WORK: % bonus based on individual perf"
la var bonus4 			"WORK: % bonus based on team perf"
la var bonus6 			"WORK: % bonus based on comp perf"
la var hours_m 			"WORK: Avg hrs worked, mgrs"
la var hours_nm 		"WORK: Avg hrs worked, non-mgrs"
la var hours_t 			"WORK: Avg hrs worked, total"
la var paceofwork 		"WORK: Who sets the pace of work"
la var paceoftask 		"WORK: Who sets the tasks"

* Orbis variables
la var employees 		"ORBIS: # employees"
la var sales 			"ORBIS: Sales (000 $)"
la var sic4 			"ORBIS: SIC 4-digit"
la var roce 			"ORBIS: ROCE (estm)"
la var roce_bvd 		"ORBIS: ROCE (BvD)"
la var ebit 			"ORBIS: EBIT (000 $)"
la var ppent 			"ORBIS: Tangible fixed assets (000 $)"
la var materials 		"ORBIS: Materials (000 $)"
la var wages 			"ORBIS: Wage bill (000 $)"
la var q 				"ORBIS: Tobin's Q (estm)"


global id "account_id account_id_new company_name cnpj sic cty country region postcode_p1 postcode_hq wave continent tickersymbol macroreg"
global mgmt "management operations monitor target people zmanagement zoperations zmonitor ztarget zpeople lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10 talent1 talent2 talent3 talent4 talent5 talent6 selfscore selfops selfpeople"
global firm "emp_firm emp_plant onsite xsite1 xsite2 mne_yn mne_cty mne_d mne_f firmfounded firmage plantage competition outsourced export_share export export25 export50"
global mgr "i_position i_pos_clean i_posttenure i_comptenure i_skills i_degree i_sex i_grad_course i_grad_yr i_postgrad_course i_postgrad_yr i_doctoral_course i_doctoral_yr"
global own "ownership other_ownership ownership_pre other_ownership3yrs ownership_year generation n_family_manag ceo family founder ff changed_ownership_3y delta_own"
global org "span central central4 central5 central6 central7 lcentral5 zorg zorg2 zcentral4 zcentral5 zcentral6 zcentral7 levels2ceo levels2pm levels_ceopm deltalevels numberlevels"
global svyctrls "analyst duration i_knowledge i_willing i_impatience reliability i_attitude_en rescheduled i_seniority i_age date dd mm yy dow hour minute nearesthour"
global workf "union percent_m percent_nm degree_m degree_nm degree_t stem_m stem_nm female_m female_nm female_t mng_left12mnths bonus1 bonus2 bonus3 bonus4 bonus5 bonus6 hours_m hours_nm hours_t paceofwork paceoftask"
global orbis "employees sales sic4 roce roce_bvd ebit ppent materials wages q"
global wlb "wfh_yn_m wfh_yn_nm wfh_days_m wfh_days_nm"
global wb "lb_doingbizrank lb_hireindex lb_hoursindex lb_redindex lb_employindex lb_redcosts"
global imf "ngdpdpc pppgdp ngdpdpc2008"

order $id $mgmt $firm $own $org $mgr $workf $svyctrls $orbis $wlb $wb $imf


/*number of unique firms per year*/
preserve
* Some firms had multiple interviews in a single year (2008), keep the ones we consider high quality
* This applies to 5 observations
duplicates tag account_id wave, g(tag1)
g k=1 if tag1==1 & analyst=="Renata Lemos"
replace k=1 if tag1==1 & analyst=="Rui Trigo de Morais"
drop if tag==1 & k!=1
drop tag
sort account_id wave
duplicates tag account_id, g(tag)
keep account_id wave
sort account_id wave
gen one = 1
reshape wide one, i(account_id) j(wave)
replace one2008 = 0 if one2008==.
replace one2013 = 0 if one2013==.
tab one2008 one2013
restore

preserve
* Some firms had multiple interviews in a single year (2008), keep the ones we consider high quality
* This applies to 5 observations
duplicates tag account_id wave, g(tag1)
g k=1 if tag1==1 & analyst=="Renata Lemos"
replace k=1 if tag1==1 & analyst=="Rui Trigo de Morais"
drop if tag==1 & k!=1
drop tag
duplicates tag account_id, g(tag)
gen cnpj_nomiss = 1-missing(cnpj)
tab cnpj_nomiss wave
sort account_id wave
keep account_id wave cnpj cnpj_nomiss
sort account_id wave
reshape wide cnpj cnpj_nomiss, i(account_id) j(wave)
replace cnpj_nomiss2008 = -1 if cnpj_nomiss2008==.
replace cnpj_nomiss2013 = -1 if cnpj_nomiss2013==.
tab cnpj_nomiss2008 cnpj_nomiss2013
restore

duplicates tag account_id wave, g(tag1)
g k=1 if tag1==1 & analyst=="Renata Lemos"
replace k=1 if tag1==1 & analyst=="Rui Trigo de Morais"
drop if tag==1 & k!=1
drop tag
sort account_id wave

rename wave year

saveold "`outpath'/wmslong_clean.dta", replace v(12)

*------------------------------
* Collapse for unique firm ID
*------------------------------

* Drop if firms are missing CNPJ information (75 firms)
drop if cnpj==""

* Some firms had multiple interviews in a single year (2008), keep the ones we consider high quality
* This applies to 5 observations
cap drop k
rename year wave
duplicates tag account_id wave, g(tag1)
g k=1 if tag1==1 & analyst=="Renata Lemos"
replace k=1 if tag1==1 & analyst=="Rui Trigo de Morais"
drop if tag==1 & k!=1
drop tag

sort account_id wave
duplicates tag account_id, g(tag)

* Replace 2008 data with 2013 if 2008 is missing
foreach var of varlist _all {
cap noisily replace `var'=`var'[_n+1] if tag==1 & wave==2008 & `var'==.
cap noisily replace `var'=`var'[_n+1] if tag==1 & wave==2008 & `var'==""
}

* Keep all 2008 data and new 2013 data
drop if tag==1 & wave==2013

save "`outpath'/wmsunique.dta", replace

capture log close
 


  