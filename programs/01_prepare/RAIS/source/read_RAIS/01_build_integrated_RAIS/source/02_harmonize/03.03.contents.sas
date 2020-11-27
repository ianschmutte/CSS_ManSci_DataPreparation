 /********************
	03.03.contents.sas
	Ian M. Schmutte

	2019-March-20

	DESCRIPTION: contents of all files
*********************/


    /*header information*/
	%INCLUDE "./SASharmonizeHeader.sas";

%macro contents;
  %DO year = 2003 %TO 2017;
    proc contents data=IRAIS.irais&year. out=tmpcontents&year;
    run;
  %END;

  data IRAIS.irais_contents;
    set
      %DO year = 2003 %TO 2017;
        tmpcontents&year
      %END;
      ;
  run;
%mend; 

%contents;



