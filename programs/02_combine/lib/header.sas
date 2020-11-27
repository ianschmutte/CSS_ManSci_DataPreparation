/*Repository location*/
%let trunk = /projects/schmutte/MGMT/MGMT_source/data/programs/_dev_replication/;


/*working path*/
%let wrk_path = &trunk./data/interwrk;

%let fast_path_1 = &trunk./data/fastwork1;

%let fast_path_2 = &trunk./data/fastwork2;


/*input paths*/
%let datain_path = &trunk./data/prepared;

/*output paths*/
%let dataout_path = &trunk./data/built;


******************************
**Libraries
******************************;
LIBNAME PREPARED  "&datain_path.";
LIBNAME INTERWRK  "&wrk_path.";
LIBNAME FASTWRK1  "&fast_path_1.";
LIBNAME FASTWRK2  "&fast_path_2.";
LIBNAME BUILT     "&dataout_path.";


******************************
**Options
******************************;
options obs=MAX fullstimer symbolgen mprint LRECL=600 linesize=120;
ods listing; /*needed on shawshank for some mysterious reason*/