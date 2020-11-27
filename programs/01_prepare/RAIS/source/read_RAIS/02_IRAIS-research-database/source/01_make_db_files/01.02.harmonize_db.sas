/*
harmonize_db.sas
Ian M. Schmutte
2019-04-15

Make database separating plant characteristics and match characteristics into distinct files with distinct keys.
Harmonize coding for common variables across years.


*/

%INCLUDE "../../lib/header.sas";
%INCLUDE "../../lib/macro_catfreq.sas";
%INCLUDE "../../lib/macro_mkformat.sas";
%INCLUDE "../../lib/macro_listcount.sas";
%INCLUDE "./01.02.auxiliary/macrovars.sas";

/*Check available memory and memory settings*/
data _null_; FREERAM_MB=input(getoption('xmrlmem'),20.)/1024/1024; put FREERAM_MB= 8.; run;
proc options group=memory; run;

/*
NOTES:
* Identical scripts for the following groups
  * 2015 and 2016
  * 2014, 2013, 2012, 2011
  * 2010 is "special" because it lacks CNAE 2.0 codes.
  * 2009, 2008, 2007
  * 2004, 2003
*/

/*redirect log and listing */

%LET year = 2017;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";

%LET year = 2016;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";

%LET year = 2015;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";

%LET year = 2014;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";

%LET year = 2013;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";

%LET year = 2012;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2013.sas";


%LET year = 2011;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2013.sas";  

%LET year = 2010;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";

%LET year = 2009;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_&year..sas";


%LET year = 2008;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2009.sas";

%LET year = 2007;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2009.sas";

%LET year = 2006;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2006.sas";

%LET year = 2005;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2005.sas";

%LET year = 2004;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2004.sas";

%LET year = 2003;
proc printto print = "./logs/harmonize_&year..lst" log = "./logs/harmonize_&year..log" new;
run;
%INCLUDE "./01.02.auxiliary/harmonize_2004.sas"; 




proc datasets library=dbout;
  delete 
    rais_wp_uniq_2003
    rais_wp_uniq_2004
    rais_wp_uniq_2005
    rais_wp_uniq_2006
    rais_wp_uniq_2007
    rais_wp_uniq_2008 
    rais_wp_uniq_2009 
    rais_wp_uniq_2010
    rais_wp_uniq_2011
    rais_wp_uniq_2012
    rais_wp_uniq_2013
    rais_wp_uniq_2014
    rais_wp_uniq_2015
    rais_wp_uniq_2016
    rais_wp_uniq_2017
    ;
run;