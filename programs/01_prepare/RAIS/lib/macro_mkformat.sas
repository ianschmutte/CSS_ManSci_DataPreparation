/*
Creates a macro named &fmtname. from a dataset called fmtdata. 
startvar is the key variable
lablevar is the variable containing the label

NOTE: If it is a character format, make sure the first character in fmtname is the dollar-sign ($)
*/


%macro mkformat(fmtdata,startvar,labelvar,fmtname);
    data control(keep=fmtname start label);
    set &fmtdata.(keep=&startvar. &labelvar.);
    retain fmtname "&fmtname.";
    rename &startvar.=start;  
    rename &labelvar.=label;
    run;

    proc sort data=control nodupkey;
    by start;
    run;

    proc format cntlin=control;
    run;
%mend;

