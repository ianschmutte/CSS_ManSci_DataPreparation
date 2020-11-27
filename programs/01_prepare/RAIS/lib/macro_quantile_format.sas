%macro quantile_format(raw,qvar,qfmt,qlist,verbose=1);
/*
Macro to generate format that assigns numeric values to the appropriate quantile.
arguments:
  raw: dataset with raw numeric data
  qvar: name of the variable to be summarized
  qfmt: name of the output format
  qlist: list of quantile cutpoints
  verbose: =1 if user wants more output
*/

/*Obtain quantiles*/
    proc univariate data=&raw. noprint; 
    var &qvar.;                                                         
    output out=out1 pctlpts= &qlist. pctlpre=P;               
    run;                                                                

                                                
/*Transpose to generate format dataset*/                                                                        
    proc transpose data=out1 out=out2 (rename=(col1=end));              
    run;                                                                
 
/*  Create the CNTLIN data set  */                                                                   
    data crfmt;                            
    set out2 end=last;
    if _N_=1 then hlo='L';                                                   
    start=lag(end);                                                 
    label=put(_N_,2.);                                         
    fmtname="&qfmt.";   
    eexcl='N';               
    if last then hlo = 'H';                                                                                   
    run;
                                                                                                                                   
                                                                    
/*  Create a format based on quantiles  */                           
    proc format cntlin=crfmt;                                           
    select &qfmt.;                                                     
    run;                                                                

/*reporting if desired*/
    %if &verbose.=1 %then %do;                                                                        
        ods noproctitle;                                                    
                                                                            
        proc print data=out1;                                               
        title 'PROC UNIVARIATE Results';                                 
        run;         

        proc print data=crfmt;                                              
        var fmtname start end label;                           
        title 'CNTLIN data set';                                         
        run;  
    %end;   
                                                                    
/* Example use of the format in a procedure step     */                               
/*
proc freq data=test;                                                
   tables xyz;                                                      
   format xyz &qfmt..;                                                
   title 'Quantile Counts';                                           
run;
*/
%mend;