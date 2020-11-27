******************************
**Macro variables
******************************;
/*Make sure that the path below points to the current version of code and data*/

/*input data path*/
%let raw_path = /data/RawData/RAIS;

/*working path*/
%let wrk_path = /temporary/RAIS_RAW/;

%let fast_path_2 = /fastwork2/RAIS_RAW;

/*output path*/

%let out_path = /data/CleanData/RAIS/v2019March;



******************************
**Libraries
******************************;
LIBNAME RAIS_RAW  "&raw_path.";
LIBNAME INTERWRK  "&wrk_path.";
LIBNAME FASTWRK2  "&fast_path_2.";
LIBNAME IRAIS     "&out_path.";
LIBNAME HERE ".";

******************************
**Options
******************************;
options obs=MAX fullstimer symbolgen mprint LRECL=600 linesize=120;
ods listing; /*needed on shawshank for some mysterious reason*/





