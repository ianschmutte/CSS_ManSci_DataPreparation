#!/bin/bash
sas irais_stack.sas
sas -memsize 100G -sortsize 95G 01.01.RAIS_data_extract.sas
sas -memsize 100G -sortsize 95G 02.01.prep_for_CG.sas
matlab -nosplash -nodisplay -r CG_load_data > CG_load_data.log 
matlab -nosplash -nodisplay -r CG_est_twfe > CG_est_twfe.log
sas -memsize 100G -sortsize 95G 03.01.post_CG.sas