/********************
	DESCRIPTION: Merge WMS to RAIS
*********************/
%INCLUDE "../lib/header.sas";
options obs = max;


proc import datafile="&datain_path./wmslong_clean.dta" out=wms_list DBMS=DTA replace;
run;

proc contents data=wms_list;
run;

proc sort data = wms_list;
  by cnpj year;
run;


/* proc sort data=PREPARED.RAIS_with_AKM;
	by cnpj year;
run; */

%macro bigstep;
data INTERWRK.RAIS_WMS_merged(keep = PIS cnpj year EARN_AVG_MONTH_REAL log_wage state CNAE20_CLASS occ_mngr occ_labr 										occ_dir occ_prod occ_tech occ_supr occ_wms_mngr hire sep CAUSE_OF_SEP NUM_HOURS_CONTRACTED nohs somehs hs coll 										educ_best TENURE_MONTHS age_31Dec male race_white 										race_pardo race_preto race_other has_akm_pe akm_pe akm_fe )
     INTERWRK.RAIS_WMS_matched_plantyears(keep = cnpj year);
  merge PREPARED.RAIS_with_AKM (in=left)
        wms_list (in = right keep = cnpj year);
  by cnpj year;
  if right then do; /*only keep if there's a match to the WMS*/
    state = substr(muni,1,2);
	occ1 = substr(trim(left(OCCUP_CBO2002)),1,1);
	occ3 = substr(trim(left(OCCUP_CBO2002)),1,3);

	* director = occup in (121005, 121010, 122205);
	* 1210-05 / 1210-10 is the code for top level managers (diretor geral - "general director") and 1222-05;
		* - In CBO 
		* - Code 0 for military;
		* - code 1 includes senior managers
		* - Code 2 for scientists (and artists) -- basically high-skilled technicians;
		* - Code 3 for mid-level technical workers
		* - Code 4 for admin workers
		* - Code 5 for service
		* - Code 6/7/8 for production workers
		* - Code 9 for maintenance
		;
	occ_dir = occup in (121005, 121010, 122205);
	occ_mngr = occ1="1";  
	occ_wms_mngr = substr(occ3,1,2) in ("21", "39", "41");
	occ_labr = not occ_mngr;
	occ_prod = occ1 in ("4","5","6","7","8","9","0");
	occ_tech = occ1 in ("2","3");
	occ_supr = substr(occ3,3,1)="0"; 
	log_wage = log(EARN_AVG_MONTH_REAL) - log(NUM_HOURS_CONTRACTED*(30/7));
	wage = exp(log_wage);
	hire = 1;
	if TYPE_OF_HIRE = "0" or TYPE_OF_HIRE="00" then hire=0;
	sep = 1;
	if CAUSE_OF_SEP = "00" then sep = 0;
	nohs = 0; 
	somehs = 0;
	hs=0; 
	coll=0;
    if educ_best <6 then nohs = 1;
	if educ_best =6 then somehs = 1;
	else if educ_best in (7,8) then hs = 1;
	else if educ_best >8 then coll=1;
    output INTERWRK.RAIS_WMS_merged;
	if last.year then output INTERWRK.RAIS_WMS_matched_plantyears;
  end;
run;
%mend;

%bigstep;

proc contents data=INTERWRK.RAIS_WMS_merged;
run;

proc means data=INTERWRK.RAIS_WMS_merged nolabels;
	var _numeric_;
	class year;
run;


/*merge identifier for matched plant-years back to WMS and build dataset to be used in downstream analysis
*/
data wms_list;
  merge wms_list(in=WMS) INTERWRK.RAIS_WMS_matched_plantyears(in = RAIS);
  by cnpj year;
  if RAIS and cnpj ne "" then in_RAIS=1; else in_RAIS = 0;
  label in_RAIS = "This plant-year has data from RAIS";
  if WMS then output;
run;

proc means data=wms_list nolabels;
	var in_RAIS;
run;

proc export data = INTERWRK.RAIS_WMS_merged outfile="&wrk_path./RAIS_WMS_merged.dta" DBMS=DTA replace;
run;

proc export data = wms_list outfile="&wrk_path./wms_rais_matched_obs.dta" DBMS=DTA replace;
run;

/* variables we need from WMS
cnpj year firmage emp_firm ownership sic degree_t female_t family founder manager other private institution competition xsite lean1 lean2 perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 perf9 perf10 talent1 talent2 talent3 talent4 talent5 talent6 */