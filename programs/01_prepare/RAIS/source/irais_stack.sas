/********************
	irais_stack.sas
	Ian M. Schmutte
	2019-March-20
	DESCRIPTION: Make table indicating what years different variables are available
  depends on 04_codebook_run.sas
*********************/


%INCLUDE "../lib/header.sas";

/*create view with all years of data stacked together.*/
%macro stackup;
data FASTWRK2.irais_jobstack / view=FASTWRK2.irais_jobstack;
  set 
  %DO yr=2003 %TO 2017;
    IRAIS.rais_match_uniq_&yr.
  %END;
  ;
run;

data FASTWRK2.irais_plantstack / view=FASTWRK2.irais_plantstack;
  set 
  %DO yr=2003 %TO 2017;
    IRAIS.rais_plant_uniq_&yr.
  %END;
  ;
run;
%mend;

%stackup;