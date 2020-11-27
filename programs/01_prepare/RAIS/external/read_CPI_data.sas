ods listing;
options validvarname=any;

libname here ".";

PROC IMPORT OUT=CPI FILE="./BRACPIALLAINMEI" dbms=xlsx REPLACE;
 range="FRED Graph$A11:B50";
RUN;

proc contents data=CPI;
run;

proc print data=CPI;
run;

data here.brazil_cpi_vector(keep = cpi1980-cpi2018);
  length cpi1980-cpi2018 6.4;
  array cpi{1980:2018} cpi1980-cpi2018;
  if _n_ = 1 then do;
    b = 0;
    do while (b = 0);
      set CPI end = lastobs;
      format BRACPIALLAINMEI BEST32.;
      cpi(year(observation_date)) = BRACPIALLAINMEI/100;
      if lastobs then b = 1;
    end;
  end;
  output;
  stop;
run;

proc print data = here.brazil_cpi_vector;
run;