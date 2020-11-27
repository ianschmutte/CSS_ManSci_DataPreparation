/********************
	RAIS_harmonize_2015.sas
	Ian M. Schmutte

	2019-March-20

	DESCRIPTION: Enforce consistent variable formatting across years
*********************/
   
    /*header information*/
	%INCLUDE "./SASharmonizeHeader.sas";

%let year = 2015;

proc contents data=INTERWRK.rais&year._raw;
run;

%macro zeropad(var,leng);
	ell = length(trim(left(&var.)));
	if ell < &leng. then &var. = repeat('0',&leng.-ell-1)||&var.;
%mend;

data IRAIS.irais&year.(drop = SEX);
  set INTERWRK.rais&year._raw(drop = YEAR_OF_ARRIVAL);
  length GENDER $1.;
  GENDER = "F";
  if SEX = "01" then GENDER = "M";
  /*DAY_OF_SEP contains a bad character string for missings*/
  if substr(DAY_OF_SEP,1,1)="{" then DAY_OF_SEP = "00";
  %zeropad(CPF,11);
  %zeropad(CTPS,8);
run;

proc freq data = IRAIS.irais&year.;
  tables DAY_OF_SEP;
run;