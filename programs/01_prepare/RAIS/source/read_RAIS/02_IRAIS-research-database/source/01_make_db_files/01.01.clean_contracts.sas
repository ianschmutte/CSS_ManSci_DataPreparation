/*
clean_contracts.sas
Ian M. Schmutte
2019-04-15
*/

%INCLUDE "../../lib/header.sas";

%macro contract_cleanup(year);

/*redirect log and listing */
proc printto print = "./logs/01.01.clean_contracts_&year..lst" log = "./logs/01.01.clean_contracts_&year..log" new;
run;

/*Note: this sort eliminates the worker_linked_cei contracts*/
proc sort data=IRAIS.irais&year. (where=(worker_linked_cei="0")) out=rais_tmp;
  by pis plant_id hire_date;
run;


/*separate duplicated and unduplicated contracts*/
data rais_tmp (drop = best_annearn best_contract any_emp_jan1 any_emp_dec31)
     rais_tmp_dup (drop = best_annearn best_contract any_emp_jan1 any_emp_dec31)
     rais_tmp_dup_best (keep = pis plant_id best_contract any_emp_jan1 any_emp_dec31);
  set rais_tmp;
  by pis plant_id;
  retain contract_count best_annearn best_contract any_emp_jan1 any_emp_dec31;
  contract_duplicated = 0;
  if first.plant_id and last.plant_id then output rais_tmp;
  else do;
    contract_duplicated = 1;
    /*this block picks the best record among duplicated contracts*/
    if first.plant_id then do;
      best_contract = 1;
      contract_count = 0;
      best_annearn = 0;
      any_emp_dec31 = 0;
      /*this works because data are sorted by hire_date within PIS x CNPJ*/
      if year(hire_date) < &year. then any_emp_jan1 = 1;
      else any_emp_jan1 = 0; 
    end;
    contract_count = contract_count+1;
    output rais_tmp_dup; /*keep all records for the duplicated contracts*/

    /*compute earnings this year to select the dominant contract*/
    if year(hire_date) < &year. then mh = 0;
    else mh = month(hire_date);
    if month_of_sep = "00" or month_of_sep = "0" then ms = 12;
    else ms = input(month_of_sep,2.);
    annearn = earn_avg_month_nom * (ms - mh);
    if annearn > best_annearn then best_contract = contract_count;
    drop ms mh annearn;
    
    /*check if any employment on dec31*/
    if month_of_sep = "00" or month_of_sep = "0" then any_emp_dec31 = 1;
    
    label any_emp_dec31 = "Some record for this PISxCNPJxYEAR showed employmnt through Dec. 31"
          any_emp_jan1  = "Some record for this PISxCNPJxYEAR showed employment before Jan 1."
          contract_duplicated = "PIS x CNPJ was duplicated this year."
          ;
    if last.plant_id then output rais_tmp_dup_best;
  end;
run;

/*Get "best" record for each duplicated contract*/
data rais_tmp_dup;
  merge rais_tmp_dup (in = master)
        rais_tmp_dup_best (in = best rename=(best_contract = contract_count));
  by pis plant_id contract_count;
  /*only keep matches*/
  if master and best then output;
run;

data dbout.rais_wp_uniq_&year.;
  set rais_tmp rais_tmp_dup;
  if contract_duplicated = 0 then do;
    any_emp_dec31 = .;
    any_emp_jan1 = .;
  end;
run;

proc contents data = dbout.rais_wp_uniq_&year.;
run;


/*ASSERT: Should only be one observation per PIS X CNPJ*/
proc sort data=dbout.rais_wp_uniq_&year. (keep=pis plant_id contract_duplicated any_emp_dec31 any_emp_jan1) out=strip;
  by pis plant_id;
run;

data strip;
  set strip;
  by pis plant_id;
  retain count;
  if first.plant_id then count = 0;
  count = count + 1;
  if last.plant_id then output;
run;

proc freq data = strip;
  tables count ;
  title "Distribution of number of times a PIS x CNPJ is observed within year &year.. Should only be count=1.";
run;

proc freq data = strip;
  tables contract_duplicated contract_duplicated*(any_emp_dec31 any_emp_jan1) / list;
  title "Number of duplicated contracts. any_emp vars should only be observed for duplicated contracts";
run;

/*redirect output to default destination*/
proc printto;
run;

  /* proc datasets library = IRAIS;
    delete irais&year.;
  run; */



%mend;


%contract_cleanup(2017);
%contract_cleanup(2016);
%contract_cleanup(2015);
%contract_cleanup(2014);
%contract_cleanup(2013);
%contract_cleanup(2012);
%contract_cleanup(2011);
%contract_cleanup(2010);
%contract_cleanup(2009);
%contract_cleanup(2008);
%contract_cleanup(2007);
%contract_cleanup(2006);
%contract_cleanup(2005);
%contract_cleanup(2004);
%contract_cleanup(2003);