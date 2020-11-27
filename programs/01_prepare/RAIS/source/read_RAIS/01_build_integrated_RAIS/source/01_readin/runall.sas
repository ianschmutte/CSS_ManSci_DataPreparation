%macro readin;
%DO year = 2002 %TO 2017;
  x nohup sas -memsize 100G RAIS_readin_&year..sas;
%END;
%mend;
%readin;
