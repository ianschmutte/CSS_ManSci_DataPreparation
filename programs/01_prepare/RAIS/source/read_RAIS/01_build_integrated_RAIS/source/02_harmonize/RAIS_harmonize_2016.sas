/********************
	RAIS_harmonize_2016.sas
	Ian M. Schmutte

	2019-March-20

	DESCRIPTION: Enforce consistent variable formatting across years
*********************/
   
    /*header information*/
	%INCLUDE "./SASharmonizeHeader.sas";

%let year = 2016;

proc contents data=INTERWRK.rais&year._raw;
run;


data IRAIS.irais&year.(drop = SEX);
  set INTERWRK.rais&year._raw;
  length GENDER $1.;
  GENDER = "F";
  if SEX = "01" then GENDER = "M";
  /*DAY_OF_SEP contains a bad character string for missings*/
  if substr(DAY_OF_SEP,1,1)="{" then DAY_OF_SEP = "00";
run;

proc freq data = IRAIS.irais&year.;
  tables DAY_OF_SEP;
run;
