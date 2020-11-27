/*2005*/
/*
  Make a format that converts CNAE95 (1.0) codes to CNAE2.0 codes.
  %macro mkformat(fmtdata,startvar,labelvar,fmtname);
*/
%mkformat(external.cnae20_xwalk10x20_preferred,cnae10,cnae20,$cnae10x20f);
/*produces format called $cnae10x20f */



data dbout.rais_match_uniq_&year. 
       (keep = pis plant_id year 
               &matchchars_keep_all.
                DAY_OF_SEP
       )
     rais_plant
       (keep = plant_id year 
               &plantchars_keep_all.
       )
     ;
  set dbout.rais_wp_uniq_&year. (rename = (OCCUP_CBO2002 = OCCUP_OLD));

  /*TYPE OF HIRE*/
  TYPE_OF_HIRE = TYPE_OF_HIRE_6;

  /*FIX LENGTH OF OCCUPATION VARIABLE*/
  length OCCUP_CBO2002 $6.;
  OCCUP_CBO2002 = trim(left(OCCUP_OLD));
   /*MISSING OCCUPATIONS SHOULD BE SET TO 0 (Military)*/
  if substr(OCCUP_CBO2002,1,2) in ("IG","RA","DE") then OCCUP_CBO2002 = "000000";

    /*recode CNAE95*/
  CNAE20_CLASS = put(CNAE95_CLASS,$cnae10x20f.);

  /*COMPUTE AGE ON DEC. 31 BASED ON DATE OF BIRTH*/
  edate = MDY(12,31,year);
  if DATE_OF_BIRTH ne . then AGE = yrdif(DATE_OF_BIRTH,edate,'AGE');
  else AGE = .;
  drop edate;

  label 
        OCCUP_CBO2002 = "Occupation classification per CBO 2002"
        CNAE20_CLASS = "Industry class (5 digit) according to CNAE 2.0"
  ;

  output rais_plant;
  output dbout.rais_match_uniq_&year.;

run;

/* proc datasets library = dbout;
  delete dbout.rais_wp_uniq_&year.;
run; */

/*****************************************************************************/
/*USE PROC FREQ to find modal values for plant-year characteristics*/

proc sort data = rais_plant out = dbout.rais_plant_uniq_&year.(keep = plant_id  year) nodupkey;
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
%catfreq(dbout.rais_plant_uniq_&year., plant_id);

proc print data = temp;
run;

/*check distribution of age variable*/
proc means data=dbout.rais_match_uniq_&year.;
  var age;
  title "Distribution of constructed AGE variable in &year.";
run;