/* Make sure that the path below points to the current version of code */

%let trunk = /projects/schmutte/MGMT/MGMT_source/data/programs/_dev_replication/;


/* EDIT THIS PATH TO POINT TO DATA FROM THE IRAIS-research database */
%let irais_path = &trunk./data/input/RAIS/IRAIS-research;
%let idx_path = &trunk./data/input/RAIS/RAIS_index;


/*externals*/
%let external_path = &trunk./prepare/RAIS/external;

/*working path*/
%let wrk_path = &trunk./data/interwrk;     /*ideally a lot of space*/
%let fast_path_1 = &trunk./data/fastwork1; /*ideally fast*/  
%let fast_path_2 = &trunk./data/fastwork2; /*ideally fast*/   


/*output paths*/
%let prepared_path = &trunk./data/prepared;


******************************
**Libraries
******************************;
LIBNAME IRAIS     ("&irais_path.", "&idx_path.");
LIBNAME EXTERNAL "&external_path.";
LIBNAME INTERWRK  "&wrk_path.";
LIBNAME FASTWRK1  "&fast_path_1.";
LIBNAME FASTWRK2  "&fast_path_2.";
LIBNAME PREPARED  "&prepared_path.";


******************************
**Options
******************************;
options obs=MAX fullstimer symbolgen mprint LRECL=600 linesize=120;
ods listing; /*needed on shawshank for some mysterious reason*/