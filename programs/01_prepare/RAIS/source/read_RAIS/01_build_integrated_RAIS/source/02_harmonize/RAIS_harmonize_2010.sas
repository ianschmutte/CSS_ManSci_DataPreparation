/********************
	RAIS_harmonize_2010.sas
	Ian M. Schmutte

	2019-March-20

	DESCRIPTION: Enforce consistent variable formatting across years
*********************/
   
    /*header information*/
	%INCLUDE "./SASharmonizeHeader.sas";

%let year = 2010;

proc contents data=INTERWRK.rais&year._raw;
run;

%macro zeropad(var,leng);
	ell = length(trim(left(&var.)));
	if ell < &leng. then &var. = repeat('0',&leng.-ell-1)||&var.;
%mend;

data IRAIS.irais&year.(drop = SEX es);
  set INTERWRK.rais&year._raw;
  length GENDER $1.;
  GENDER = "F";
  if SEX = "MA" then GENDER = "M";

  /*OCCUP is prefaced with string "CBO " before the numeric code*/
  OCCUP_CBO2002 = substr(OCCUP_CBO2002,5,6);

  /*CODE FOR MISSING / IGNORED DATA DIFFERS IN THIS YEAR*/
  if RACE_v2006 in ("IG","-1") then RACE_v2006 = "99";
  if LEAVE_1_CAUSE in ("IG","-1") then LEAVE_1_CAUSE = "99";
  if LEAVE_1_INI_DAY in ("IG","-1") then LEAVE_1_INI_DAY = "99";
  if LEAVE_1_INI_MON in ("IG","-1")  then LEAVE_1_INI_MON = "99";
  if LEAVE_1_END_DAY in ("IG","-1") then LEAVE_1_END_DAY = "99";
  if LEAVE_1_END_MON in ("IG","-1")  then LEAVE_1_END_MON = "99";
  if LEAVE_2_CAUSE in ("IG","-1")   then LEAVE_2_CAUSE = "99";
  if LEAVE_2_INI_DAY in ("IG","-1") then LEAVE_2_INI_DAY = "99";
  if LEAVE_2_INI_MON in ("IG","-1") then LEAVE_2_INI_MON = "99";
  if LEAVE_2_END_DAY in ("IG","-1") then LEAVE_2_END_DAY = "99";
  if LEAVE_2_END_MON in ("IG","-1") then LEAVE_2_END_MON = "99";
  if LEAVE_3_CAUSE in ("IG","-1")   then LEAVE_3_CAUSE = "99";
  if LEAVE_3_INI_DAY in ("IG","-1") then LEAVE_3_INI_DAY = "99";
  if LEAVE_3_INI_MON in ("IG","-1") then LEAVE_3_INI_MON = "99";
  if LEAVE_3_END_DAY in ("IG","-1") then LEAVE_3_END_DAY = "99";
  if LEAVE_3_END_MON in ("IG","-1") then LEAVE_3_END_MON = "99";
  
  if YEAR_OF_ARRIVAL in ("IG","-1") then YEAR_OF_ARRIVAL = "0000";

  /*CODES FOR ESTAB SIZE ARE OFF BY ONE IN THIS YEAR*/
  es = input(ESTAB_SIZE_DEC31,?? 1.);
  es = es + 1;
  if es = 10 then ESTAB_SIZE_DEC31 = "10";
  else if es = . then ESTAB_SIZE_DEC31 = "  ";
  else ESTAB_SIZE_DEC31 = "0"||put(es,$1.);

  /*MANY VARIABLES ARE MISSING LEADING ZERO*/
  %zeropad(RACE_v2006,2);
  %zeropad(PIS,11);
  %zeropad(PLANT_ID,14);
  %zeropad(CPF,11);
  %zeropad(CTPS,8);
  %zeropad(CEI_CONTRACT_ESTAB,11);
  %zeropad(SALARY_TYPE,2);
  %zeropad(EDUC_v2005,2);
  %zeropad(ESTAB_SIZE_DEC31,2);
  %zeropad(ESTAB_TYPE,2);
  %zeropad(TYPE_OF_DISABILITY,2);

  /*there is some error in readin where we have one observation whose entries are just the names of the variables. Drop this observation*/
  if RACE_v2006 ne "RA" then output;
run;

proc freq data = IRAIS.irais&year.;
  tables RACE_v2006 ESTAB_SIZE_DEC31;
run;