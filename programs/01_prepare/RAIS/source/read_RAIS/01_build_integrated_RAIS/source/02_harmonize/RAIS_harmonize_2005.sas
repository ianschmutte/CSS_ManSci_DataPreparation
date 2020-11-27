/********************
	RAIS_harmonize_2005.sas
	Ian M. Schmutte

	2019-March-20

	DESCRIPTION: Enforce consistent variable formatting across years
*********************/
   
    /*header information*/
	%INCLUDE "./SASharmonizeHeader.sas";

%let year = 2005;

proc contents data=INTERWRK.rais&year._raw;
run;

%macro zeropad(var,leng);
	ell = length(trim(left(&var.)));
	if ell < &leng. then &var. = repeat('0',&leng.-ell-1)||&var.;
%mend;

data IRAIS.irais&year.(drop = SEX TYPE_OF_HIRE es);
  set INTERWRK.rais&year._raw;
  length GENDER $1.;
  GENDER = "F";
  if SEX = "MA" then GENDER = "M";

  /*TYPE OF HIRE HAS ONLY 6 categories instead of 15*/
  TYPE_OF_HIRE_6 = TYPE_OF_HIRE;
  label TYPE_OF_HIRE_6 = "Type of contract initiation (6 categories)";


  /*CODES FOR ESTAB SIZE ARE OFF BY ONE IN THIS YEAR*/
  es = input(ESTAB_SIZE_DEC31,?? 1.);
  es = es + 1;
  if es = 10 then ESTAB_SIZE_DEC31 = "10";
  else if es = . then ESTAB_SIZE_DEC31 = "  ";
  else ESTAB_SIZE_DEC31 = "0"||put(es,$1.);

  /*OCCUPATION CODES HAVE DIFFICULT NON-NUMERIC CODING*/
  if substr(trim(left(OCCUP_CBO94)),1,2) = "IG" then OCCUP_CBO94 = substr(trim(left(OCCUP_CBO94)),1,5);
  else OCCUP_CBO94 = substr(OCCUP_CBO94,5,5);
  if substr(trim(left(OCCUP_CBO2002)),1,2) = "IG" then OCCUP_CBO2002 = substr(trim(left(OCCUP_CBO94)),1,6);
  else OCCUP_CBO2002 = substr(OCCUP_CBO2002,5,6);



  %zeropad(PIS,11);
  %zeropad(PLANT_ID,14);
  %zeropad(CPF,11);
  %zeropad(CTPS,8);
    %zeropad(CEI_CONTRACT_ESTAB,11);
    %zeropad(SALARY_TYPE,2);
    %zeropad(EDUC,2);
    %zeropad(RACE,2);
    %zeropad(ESTAB_TYPE,2);
run;