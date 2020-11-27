/*
post_CG.sas
Ian M. Schmutte
2020 Feb 20

Read data from CG and merge back to original input
*/

%INCLUDE "../lib/header.sas";

%let indata = FASTWRK2.AKM_data_extract;

%macro build_data;
/*Import data from CG estimation*/
data WORK.CG_HCFILE_TWFE    ;
    %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
    infile "&fast_path_1./CG_HCfile_twfe.txt" delimiter='09'x MISSOVER DSD lrecl=32767 firstobs=2 ;
    informat workernum 9. ;
    informat plantnum 9. ;
    informat year  4. ;
    informat ln_wage best32. ;
    informat AKM_Xb best32. ;
    informat AKM_pe best32. ;
    informat AKM_fe best32. ;
    informat AKM_resid best32. ;
    format workernum 9.;
    format plantnum 9.;
    format year 4.;
    format ln_wage best12. ;
    format AKM_Xb best12. ;
    format AKM_pe best12. ;
    format AKM_fe best12. ;
    format AKM_resid best12. ;
    input
            workernum
            plantnum
            year
            ln_wage
            AKM_Xb
            AKM_pe
            AKM_fe
            AKM_resid
;
if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
label ln_wage = "Log hourly wage"
      AKM_Xb      = "Effect of time varying characteristics (from AKM model)"
      AKM_pe      = "Estimated person effect from AKM"
      AKM_fe      = "Estimated employer effect from AKM"
      AKM_resid   = "Predicted residual from AKM"
      ;
run;

proc contents data = CG_HCfile_twfe; run;

proc means data = CG_HCfile_twfe;
  var _numeric_;
run;


/*Reattach PIS and plant_id*/
data FASTWRK1.CG_HCfile_twfe (drop = rc1 rc2 workernum plantnum);
    if _n_=1 then do;
    if 0 then
      set IRAIS.xwalk_pis_workernum
          IRAIS.xwalk_plantid_plantnum;
    declare hash wrkid(dataset: 'IRAIS.xwalk_pis_workernum',
               ordered: 'ascending');
    wrkid.definekey ("workernum");
    wrkid.definedata("PIS");
    wrkid.definedone();

    declare hash pltid(dataset: 'IRAIS.xwalk_plantid_plantnum',
               ordered: 'ascending');
    pltid.definekey ("plantnum");
    pltid.definedata("plant_id");
    pltid.definedone();
  end;
  
  set CG_HCfile_twfe;
  rc1 = wrkid.find();
  rc2 = pltid.find();
  if rc1=0 and rc2=0 then output;
run;

/*make worker effect and plant effect files*/
proc sort data = FASTWRK1.CG_HCFILE_TWFE(keep = PIS AKM_pe) out=PREPARED.AKM_personfx nodupkey;
  by PIS;
run;

proc sort data = FASTWRK1.CG_HCFILE_TWFE(keep = PLANT_ID AKM_fe) out = PREPARED.AKM_plantfx nodupkey;
  by PLANT_ID; 
run;
%mend;

%build_data;



data PREPARED.RAIS_with_AKM (drop = rc1 rc2 plant_id year_str);
   if _n_=1 then do;
    if 0 then
      set PREPARED.AKM_personfx
          PREPARED.AKM_plantfx;
    declare hash wrkid(dataset: 'PREPARED.AKM_personfx',
               ordered: 'ascending');
    wrkid.definekey ("PIS");
    wrkid.definedata("AKM_pe");
    wrkid.definedone();

    declare hash pltid(dataset: 'PREPARED.AKM_plantfx',
               ordered: 'ascending');
    pltid.definekey ("PLANT_ID");
    pltid.definedata("AKM_fe");
    pltid.definedone();
  end;
  set FASTWRK2.AKM_data_extract(rename=(year=year_str));
  year = input(year_str,4.);
  rc1 = wrkid.find();
  rc2 = pltid.find();
  if rc1 ~= 0 then AKM_pe = .;
  if rc2 ~=0 then AKM_fe = .;
  has_akm_pe = AKM_pe ~=.;
  cnpj = substr(plant_id,1,2)||"."||substr(plant_id,3,3)||"."||substr(plant_id,6,3)||"/"||substr(plant_id,9,4)||"-"||substr(plant_id,13,2);
  log_wage = log(EARN_AVG_MONTH_REAL) - log(NUM_HOURS_CONTRACTED*(30/7));

  label has_akm_pe = "Worker matched to an estimated AKM person effect";
run;

proc contents data = PREPARED.RAIS_with_AKM;
run;

proc corr data = PREPARED.RAIS_with_AKM(where=(year=2008));
  var log_wage AKM_fe AKM_pe;
run;

proc means data = PREPARED.RAIS_with_AKM nolabels;
  var log_wage AKM_fe AKM_pe has_akm_pe to_AKM;
  class year;
run;

/*produce a dataset for year 2008 and 2013 with wages and AKM pe*/

data RAIS_WAGES_0813(keep = log_wage AKM_pe year);
  set PREPARED.RAIS_with_AKM(keep = log_wage AKM_pe year where=(year=2008 or year=2013));
  if log_wage ~=. then output;
run;

proc export data = RAIS_WAGES_0813 outfile="&prepared_path./RAIS_WAGES_0813.dta" DBMS=DTA replace;
run;
