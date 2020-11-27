/*
RAIS_plant_list
Ian M. Schmutte
2020 May 1

list all plants in RAIS including plant size class and industry information

*/

%INCLUDE "../lib/header.sas";

data INTERWRK.RAIS_plants (drop = year_str CNAE20_CLASS MUNI CAUSE_OF_SEP);
  set FASTWRK2.AKM_data_extract(keep=PLANT_ID year EARN_AVG_MONTH_REAL NUM_HOURS_CONTRACTED age_31Dec male race_white
    CNAE20_CLASS MUNI ESTAB_SIZE_DEC31 CAUSE_OF_SEP
    rename = (year = year_str)
  );
  year = input(year_str,4.);
  ind2 = substr(CNAE20_CLASS, 1, 2);
  region = substr(MUNI,1,1);
  emp = 0;
  if CAUSE_OF_SEP = "00" then emp = 1;
  if year = 2008 or year = 2013 then output;
run;

proc sort data = INTERWRK.RAIS_plants(keep = PLANT_ID year ind2 region ESTAB_SIZE_DEC31) out=plantlist nodupkey;
  by PLANT_ID year;
run;

proc sort data = INTERWRK.RAIS_plants(drop = ind2 region ESTAB_SIZE_DEC31) out=wrkchars;
  by PLANT_ID year;
run;

proc means data = wrkchars noprint;
  var EARN_AVG_MONTH_REAL NUM_HOURS_CONTRACTED age_31Dec male race_white emp;
  by PLANT_ID year;
  output out=wrkmeans mean= sum(emp)=Emp_Dec31;
run;

data PREPARED.RAIS_plant_list (drop=plant_id emp);
  merge plantlist (in=master) wrkmeans (in=chars);
  by PLANT_ID year;
  cnpj = substr(plant_id,1,2)||"."||substr(plant_id,3,3)||"."||substr(plant_id,6,3)||"/"||substr(plant_id,9,4)||"-"||substr(plant_id,13,2);
run; 

proc contents data=PREPARED.RAIS_plant_list; run;
proc print data=PREPARED.RAIS_plant_list(obs=50); run;
proc means data=PREPARED.RAIS_plant_list nolabels;
  var _numeric_;
run;

proc export data = PREPARED.RAIS_plant_list outfile="&prepared_path./RAIS_plant_list.dta" DBMS=DTA replace;
run;