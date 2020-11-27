/*
fixed_plantchars.sas
Ian M. Schmutte
2019-06-26

Record the modal plant characteristics over time in the data

*/

%INCLUDE "../../lib/header.sas";
%INCLUDE "../../lib/macro_listcount.sas";

%let plantchars_keep_all = 
CNAE20_CLASS
ESTAB_SIZE_DEC31
ESTAB_TYPE
LEGAL_NATURE_CONCLA2002
MUNI
;

%macro readtraits;
    data FASTWRK1.traits ;
    set
    %DO yr=2003 %TO 2017;
        DBOUT.rais_plant_uniq_&yr.(keep = plant_id &plantchars_keep_all.)
    %END;
    ;
    run;
%mend;
%readtraits;

proc sort data = FASTWRK1.traits out = DBOUT.rais_plant_uniq_modal_chars nodupkey;
  by plant_id;
run;

proc sort data = FASTWRK1.traits;
  by plant_id;
run;

%macro freqs(var);

  Proc Freq data=FASTWRK1.traits noprint;
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

  data DBOUT.rais_plant_uniq_modal_chars;
    merge DBOUT.rais_plant_uniq_modal_chars
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

proc contents data = DBOUT.rais_plant_uniq_modal_chars;
run;

proc print data = DBOUT.rais_plant_uniq_modal_chars(where = (substr(plant_id,1,6) ne "000000") obs = 1000);
run;