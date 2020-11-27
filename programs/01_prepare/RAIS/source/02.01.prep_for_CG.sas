/*
prep_for_CG.sas
Ian M. Schmutte
2020 Feb 20

Prepare data for CG
*/

%INCLUDE "../lib/header.sas";



/*sample construction*/
data INTERWRK.keepobs;
  set FASTWRK2.AKM_data_extract(keep=PIS PLANT_ID year EARN_AVG_MONTH_REAL NUM_HOURS_CONTRACTED age_31Dec male race_white race_pardo race_preto race_other to_akm rename = (year = year_str));
  year = input(year_str,4.);
  if to_akm = 1 and year < 2008  
    then output;
run;

/*construct variables */
%let akm_varlist = workernum plantnum year log_wage age_31Dec male race_white race_pardo race_preto race_other ;
data forexport(keep = &akm_varlist.); 
  /*load hash objects to assign numeric worker and plant index*/
  if _n_=1 then do;
    if 0 then
      set IRAIS.xwalk_pis_workernum
          IRAIS.xwalk_plantid_plantnum;
    declare hash wrkid(dataset: 'IRAIS.xwalk_pis_workernum',
               ordered: 'ascending');
    wrkid.definekey ("PIS");
    wrkid.definedata("workernum");
    wrkid.definedone();

    declare hash pltid(dataset: 'IRAIS.xwalk_plantid_plantnum',
               ordered: 'ascending');
    pltid.definekey ("plant_id");
    pltid.definedata("plantnum");
    pltid.definedone();
  end;
  
  retain &akm_varlist.;
  set INTERWRK.keepobs(keep=PIS PLANT_ID year EARN_AVG_MONTH_REAL NUM_HOURS_CONTRACTED age_31Dec male race_white race_pardo race_preto race_other);
  log_wage = log(EARN_AVG_MONTH_REAL) - log(NUM_HOURS_CONTRACTED*(30/7));
  rc1 = wrkid.find();
  rc2 = pltid.find();
  if (age_31Dec ~= . and male ~= . and race_white ~= .) then output;
run;

proc contents data=forexport;
run;

proc print data=forexport(obs=20);
run;

proc means data=forexport nolabels;
  var _numeric_;
  title "Summary for the sample used in AKM estimation";
run;

/*export variables for use in matlab*/
proc export data = forexport outfile = "&fast_path_1./CG_file.csv"
  dbms = csv replace;
run;
