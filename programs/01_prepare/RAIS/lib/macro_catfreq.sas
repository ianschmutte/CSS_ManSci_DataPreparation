/*
# MACRO catfreq
generates frequency distribution of a categorical variable within a dataset

## ARGUMENTS:

* datain: the input dataset
* catvar: a categorical variable for which the frequency of each level is to be counted
* countvar: a name for the variable holding the frequency count
* dataout: name for the dataset that will hold the frequency distribution

*/

%macro catfreq(datain, catvar, countvar = obscount, dataout = temp);

    proc freq data = &datain.(keep = &catvar.) noprint;
      tables &catvar. / out = temp;
    run;

    proc freq data = temp (rename = (count = &countvar.)) noprint;
      tables &countvar. / out = &dataout.;
    run;

%mend;