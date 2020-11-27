/*2017*/
data dbout.rais_match_uniq_&year. 
       (keep = pis plant_id year 
               &matchchars_keep_all.
                LEAVE_1_CAUSE
                LEAVE_1_END_DAY
                LEAVE_1_END_MON
                LEAVE_1_INI_DAY
                LEAVE_1_INI_MON
                LEAVE_2_CAUSE
                LEAVE_2_END_DAY
                LEAVE_2_END_MON
                LEAVE_2_INI_DAY
                LEAVE_2_INI_MON
                LEAVE_3_CAUSE
                LEAVE_3_END_DAY
                LEAVE_3_END_MON
                LEAVE_3_INI_DAY
                LEAVE_3_INI_MON
                &monthly_pay. NOV_PAY
                DAY_OF_SEP
       )
     rais_plant
       (keep = plant_id year 
               &plantchars_keep_all.
       )
     ;
  set dbout.rais_wp_uniq_&year.;

  /*RACE RECODE*/
  RACE = RACE_V2006;

  /*EDUCATION RECODE*/
  if EDUC_v2005 in ("10","11") then EDUC = "9";
  else EDUC = substr(EDUC_v2005,2,1);

  /*Pool OCCUPATIONS in Military to 000000 for consistency across years*/
  if substr(OCCUP_CBO2002,1,1) = "0" then OCCUP_CBO2002 = "000000";



  label 
        EDUC = "Education degree (pre-2006; 9 categories)"
        RACE = "Worker race"
  ;

  output rais_plant;
  output dbout.rais_match_uniq_&year.;

run;

/* proc datasets library = dbout;
  delete dbout.rais_wp_uniq_&year.;
run; */

/*****************************************************************************/
/*USE PROC FREQ to find modal values for plant-year characteristics*/

proc sort data = rais_plant out = dbout.rais_plant_uniq_&year.(keep = plant_id year) nodupkey;
  by plant_id;
run;

proc sort data = rais_plant;
  by plant_id;
run;

%macro freqs(var);

  Proc Freq data=rais_plant noprint;
    by plant_id;
    tables &var./ out=out1;
  run;

  Proc sort data=out1;
    by plant_id count;
  run;

  Data out1 (keep = plant_id &var.);
    set out1;
    by plant_id;
    if last.plant_id then output;
  run;

  data dbout.rais_plant_uniq_&year.;
    merge dbout.rais_plant_uniq_&year.
          out1;
    by plant_id;
  run;

%mend;

%macro allfreqs;
  %listcount(&plantchars_keep_all.,c);
  %DO v = 1 %TO &c.;
    %let key = %scan(&plantchars_keep_all,&v.);
    %freqs(&key.);
  %END;
%mend;
%allfreqs;
/*****************************************************************************/

proc contents data = dbout.rais_match_uniq_&year.;
run;

proc contents data = dbout.rais_plant_uniq_&year.;
run;

/*ASSERT one record per plant*/
/* proc sort data = dbout.rais_plant_uniq_&year.(keep = plant_id) out = temp;
  by plant_id;
run;

data temp;
  set temp;
  by plant_id;
  retain count;
  if first.plant_id then count = 0;
  count = count + 1;
  if last.plant_id then output;
run;

proc freq data = temp noprint;
  tables count / out = temp;
run; */

%catfreq(dbout.rais_plant_uniq_&year., plant_id);

proc print data = temp;
run;