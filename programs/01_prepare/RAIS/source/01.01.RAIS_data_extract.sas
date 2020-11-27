/*
AKM_data_extract
Ian M. Schmutte
2019-06-26

Extract data for AKM

First, we select workers based on demographic traits.
Next, select all jobs for those workers that meet additional restrictions on firm and job characteristics
Finally identify dominant jobs
*/

%INCLUDE "../lib/header.sas";

/*Load macros to validate worker and plant ids*/
%INCLUDE "../lib/br_id_validation_macros.sas";

/*SELECT WORKERS*/
%macro selectworkers;
data INTERWRK.selected_workers;
  set IRAIS.race_gender_age_best;
run;

proc sort data = INTERWRK.selected_workers;
  by PIS;
run;

proc contents data = INTERWRK.selected_workers;
run;

%mend;
/* %selectworkers; */


%macro selectjobs;
data FASTWRK1.select_jobs(keep= PIS year PLANT_ID
								CNAE20_CLASS MUNI ESTAB_SIZE_DEC31 ESTAB_TYPE	
                PIS_valid PLANT_ID_valid
                                age_31Dec
                                race_white race_pardo race_preto race_other
                                male
                                EARN_AVG_MONTH_REAL
                                NUM_HOURS_CONTRACTED
                                TYPE_OF_HIRE
                                HIRE_DATE 
                                CAUSE_OF_SEP 
                                MONTH_OF_SEP
                                OCCUP_CBO2002 
                                TENURE_MONTHS
                                SPELL_TENURE SPELL_EARN_PRED SPELL_HOURS_PRED
                                CONTRACT_TYPE
                                to_akm
                      				 );
	array cpi{2003:2017} _temporary_;
	b=0;
	if _n_=1 then do;
		do until (b=1);
			set EXTERNAL.brazil_cpi_vector;
			array cpi_temp{2003:2017} cpi2003--cpi2017;
			do yr = 2003 to 2017;
				cpi{yr} = cpi_temp{yr};
			end;
			b=1;
		end;
		if 0 then set IRAIS.race_gender_age_best
					  fastwrk2.irais_plantstack;
         	
         	declare hash pltchars(dataset: 'fastwrk2.irais_plantstack',
         							ordered: 'no');
         	pltchars.definekey ("plant_id", "year");
         	pltchars.definedata("CNAE20_CLASS","MUNI","ESTAB_SIZE_DEC31","ESTAB_TYPE");
         	pltchars.definedone();

         	declare hash wrkchars(dataset: 'IRAIS.race_gender_age_best',
         							ordered: 'ascending');
         	wrkchars.definekey ("PIS");
         	wrkchars.definedata("age_31Dec2003_mode");
         	wrkchars.definedone();   		
	end;
	set %DO yr=2003 %TO 2017;
        IRAIS.rais_match_uniq_&yr.(keep=PIS PLANT_ID YEAR CONTRACT_TYPE HIRE_DATE
                                     EARN_AVG_MONTH_NOM NUM_HOURS_CONTRACTED
                                     GENDER RACE
                                     TYPE_OF_HIRE CAUSE_OF_SEP MONTH_OF_SEP OCCUP_CBO2002 TENURE_MONTHS
                                     )
      %END;
      ;

  rc1 = wrkchars.find();
  /* only keep processing if worker was found */
	if rc1 = 0 then do;
        rc2 = pltchars.find();
        /*only keep processing if plant was found*/
        if rc2 = 0 then do;
            age_31Dec = input(year,4.)-2003 + age_31Dec2003_mode;

            /*MAKE EARNINGS REAL (2015 REAIS)*/
            EARN_AVG_MONTH_REAL = EARN_AVG_MONTH_NOM/cpi{input(year,4.)};

            /*COMPUTE TENURE IN JOB THIS YEAR ALONG WITH PREDICTED EARNINGS THIS YEAR*/
            if TYPE_OF_HIRE="0" or TYPE_OF_HIRE="00" then month_start = 0;
            else month_start = month(HIRE_DATE);
            month_sepr = 12;
            if month_of_sep ne "00" then month_sepr = input(month_of_sep,2.);
            spell_tenure = max(month_sepr-month_start,0); /*measured as fraction of full year at weekly contracted hours*/
            spell_earn_pred = spell_tenure*EARN_AVG_MONTH_REAL;
            spell_hours_pred = spell_tenure*(30/7)*NUM_HOURS_CONTRACTED; /*predicted annual hours this job*/

            male = GENDER = "M";
            race_white = RACE = "02";
            race_pardo = RACE = "08";
            race_preto = RACE = "04";
            race_other = race_white + race_pardo + race_preto = 0;


            label EARN_AVG_MONTH_REAL = 'Inflation Adjusted Monthly Earnings - 2015 Reais'
                spell_tenure = 'months worked this job this year'
                spell_earn_pred = 'predicted earnings this year = spell_tenure*earn_avg_month_real'
                spell_hours_pred = 'predicted hours this year'
                age_31Dec = 'Age on Dec. 31 based on modal date of birth reported for this PIS'
                ;

            /*Select observations with valid identifiers/key variables. Note we impose plant size >0 workers (stock)*/
            /*validate PIS and PLANT_ID*/
            %validate_pis(PIS);
            %validate_cnpj(PLANT_ID);
            to_akm = 0;
            if (PIS_valid = 1 
                and PLANT_ID_valid = 1
                and input(ESTAB_SIZE_DEC31,2.) > 0 
                and EARN_AVG_MONTH_REAL gt 0
                and age_31Dec ge 20
                and age_31Dec le 60) 
            then to_akm = 1;
            output;
        end;
    end;    
run;

proc contents data = FASTWRK1.select_jobs;
run;

proc print data = FASTWRK1.select_jobs (obs=20);
run;

proc freq data = FASTWRK1.select_jobs;
  tables PIS_valid PLANT_ID_valid ESTAB_SIZE_DEC31;
run;

proc means data = FASTWRK1.select_jobs;
  var age_31Dec TENURE_MONTHS NUM_HOURS_CONTRACTED;
run;

proc univariate data= FASTWRK1.select_jobs;
  var EARN_AVG_MONTH_REAL ;
run;



%mend;
%selectjobs;



/*NOW GET DOMINANT JOBS
  Within each year we want to choose the job with highest predicted earnings among all "longest" jobs. This is accomplished with a simple sort
*/

proc sort data = FASTWRK1.select_jobs;
  by PIS year spell_tenure spell_earn_pred;
run;

/*assign dominant jobs and attach education*/
data FASTWRK2.AKM_data_extract;
  merge FASTWRK1.select_jobs(drop = SPELL_EARN_PRED SPELL_TENURE in = left)
        IRAIS.educ_best(keep = pis year educ_best in = right);
  by PIS year;
  dom_job = 0;
  if last.year then dom_job = 1;
  label dom_job = 'Among jobs with the highest tenure, the job with highest earnings this year';
  to_akm = to_akm*dom_job;
  if left then output;
run;

proc contents data = FASTWRK2.AKM_data_extract;
run;

proc UNIVARIATE data = FASTWRK2.AKM_data_extract(where=(to_akm=1));
  var EARN_AVG_MONTH_REAL;
run;

proc means data = FASTWRK2.AKM_data_extract(where=(to_akm=1));
  var age_31Dec educ_best;
  class year;
run;