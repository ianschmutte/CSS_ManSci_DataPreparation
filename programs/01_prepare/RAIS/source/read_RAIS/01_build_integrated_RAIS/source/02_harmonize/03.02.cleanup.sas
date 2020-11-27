 /********************
	03.02.cleanup.sas
	Ian M. Schmutte

	2019-March-20

	DESCRIPTION: clean up after all files have been harmonized
*********************/

    /*header information*/
	%INCLUDE "./SASharmonizeHeader.sas";

%macro cleanraw;
  proc datasets library=INTERWRK;
    delete 
    %DO year = 2002 %TO 2017;
      rais&year._raw
    %END;
    ;
  run;


%mend;

%cleanraw;
