/*Make sure that the path below points to the current version of code and data*/

%let trunk = /projects/schmutte/MakeRAIS/MakeRAIS_source/IRAIS-research-database;


/*input data path: Should be location where irais&yr..sas7bdat files live*/
%let irais_path = /data/CleanData/RAIS/v2019March;

/*externals*/
%let external_path = &trunk./analysis/external;

/*working paths*/
%let wrk_path = /temporary/IRAIS-research;      /*ideally a lot of space*/
%let fast_path_1 = /fastwork1/IRAIS-research;   /*ideally fast*/
%let fast_path_2 = /fastwork2/IRAIS-research;   /*ideally fast*/

/*output paths*/
%let tabout_trunk = &trunk./release;
%let dataout_path = /data/projects/IRAIS-research;

******************************
**Libraries
******************************;
LIBNAME IRAIS     "&irais_path.";
LIBNAME EXTERNAL "&external_path.";
LIBNAME INTERWRK  "&wrk_path.";
LIBNAME FASTWRK1  "&fast_path_1.";
LIBNAME FASTWRK2  "&fast_path_2.";
LIBNAME DBOUT     "&dataout_path.";

******************************
**Options
******************************;
options obs=MAX fullstimer symbolgen mprint LRECL=600 linesize=120;
ods listing; /*needed on shawshank for some mysterious reason*/