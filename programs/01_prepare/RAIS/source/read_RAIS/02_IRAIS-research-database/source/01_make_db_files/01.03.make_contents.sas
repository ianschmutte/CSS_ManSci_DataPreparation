/*
make_contents.sas
Ian M. Schmutte
2019-05-15

*/

%INCLUDE "../../lib/header.sas";

%macro contents;
  %DO year = 2003 %TO 2017;
    proc contents data=dbout.rais_match_uniq_&year. out=tmpcontents&year noprint;
    run;
  %END;

  data dbout.rais_match_uniq_contents;
    set
      %DO year = 2003 %TO 2017;
        tmpcontents&year
      %END;
      ;
  run;

  %DO year = 2003 %TO 2017;
    proc contents data=dbout.rais_plant_uniq_&year. out=tmpcontents&year noprint;
    run;
  %END;

  data dbout.rais_plant_uniq_contents;
    set
      %DO year = 2003 %TO 2017;
        tmpcontents&year
      %END;
      ;
  run;


%mend; 

%contents;


proc contents data=dbout.rais_match_uniq_contents; run;
proc print data=dbout.rais_match_uniq_contents; run;
proc contents data=dbout.rais_plant_uniq_contents; run;



data widecontents;
  set dbout.rais_match_uniq_contents;
  year = input(substr(trim(left(memname)),17,4),4.);
run;

proc sort data=widecontents out=widecontents;
  by name year;
run;

proc transpose data= widecontents out=widecontents prefix=yr_;
  by name;
  id year;
  var length;
run;

data widecontents;
  retain name yr_2003-yr_2017;
  set widecontents(keep=name  yr_2003-yr_2017);
run;

proc print data=widecontents;
title "Availability of match characteristics";
run;
/*****************************************************************************/
data widecontents;
  set dbout.rais_plant_uniq_contents;
  year = input(substr(trim(left(memname)),17,4),4.);
run;

proc sort data=widecontents out=widecontents;
  by name year;
run;

proc transpose data= widecontents out=widecontents prefix=yr_;
  by name;
  id year;
  var length;
run;

data widecontents;
  retain name yr_2003-yr_2017;
  set widecontents(keep=name  yr_2003-yr_2017);
run;

proc print data=widecontents;
title "Availability of plant characteristics";
run;