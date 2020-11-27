/********************
	RAIS_readin_2008.sas
	Ian M. Schmutte
  2018 January 1
	DESCRIPTION: Read raw input files from original 2008 data
*********************/
   
/*header information*/
%INCLUDE "./SASReadInHeader.sas";
options validvarname=any;

%let states = AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO;

/* read-in macro */
%macro readin2008(st,file);
       filename raw pipe "7z e -so &raw_path./20171128_data/RAIS_anteriores/2008/&st.2008ID.7z 2>> error.log";
            data INTERWRK.&st.2008;
            %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
            infile raw delimiter = ';' MISSOVER DSD lrecl=32767 firstobs=2 ;
              informat MUNI	$6.	;
              informat CNAE95_CLASS	$5.	;
              informat EMP_ON_DEC31	$1.	;
              informat CONTRACT_TYPE	$2.	;
              informat CAUSE_OF_SEP	$2.	;
              informat MONTH_OF_SEP	$2.	;
              informat IND_VINC_ALVARA	$1.	;
              informat TYPE_OF_HIRE	$2.	;
              informat SALARY_TYPE	$2.	;
              informat OCCUP_CBO94	$9.	;
              informat EDUC_v2005	$2.	;
              informat SEX	$2.	;
              informat NATIONALITY	$2.	;
              informat RACE_v2006	$2.	;
              informat WORKER_DISABLED	$1.	;
              informat ESTAB_SIZE_DEC31	$2.	;
              informat LEGAL_NATURE_CONCLA2002	$4.	;
              informat WORKER_LINKED_CEI	$1.	;
              informat ESTAB_TYPE	$2.	;
              informat ESTAB_IN_PAT	$1.	;
              informat IND_SIMPLES	$1.	;
              informat HIRE_DATE	ddmmyy8.	;
              informat EARN_DEC_NOM	numx13.	;
              informat EARN_DEC_MW	numx9.	;
              informat EARN_AVG_MONTH_NOM	numx13.	;
              informat EARN_AVG_MONTH_MW	numx9.	;
              informat TENURE_MONTHS	numx6.	;
              informat NUM_HOURS_CONTRACTED	comma2.	;
              informat FINAL_PAY_YEAR	numx13.	;
              informat CONTRACT_SALARY	numx13.	;
              informat PIS	$11.	;
              informat DATE_OF_BIRTH	ddmmyy8.	;
              informat CTPS	$8.	;
              informat CPF	$11.	;
              informat CEI_CONTRACT_ESTAB	$11.	;
              informat PLANT_ID	$14.	;
              informat CNPJ_ROOT	$8.	;
              informat TIPO_ESTB_ID	$2.	;
              informat WORKER_NAME	$55.	;
              informat DAY_OF_SEP	$2.	;
              informat OCCUP_CBO2002	$10.	;
              %IF &st=SP %THEN informat CNAE20_CLASS_TMP $12.;
              %ELSE informat CNAE20_CLASS	$5.;	
              ;
              informat CNAE20_SUBCLASS	$7.	;
              informat TYPE_OF_DISABILITY	$2.	;
              informat LEAVE_1_CAUSE	$2.	;
              informat LEAVE_1_INI_DAY	$2.	;
              informat LEAVE_1_INI_MON	$2.	;
              informat LEAVE_1_END_DAY	$2.	;
              informat LEAVE_1_END_MON	$2.	;
              informat LEAVE_2_CAUSE	$2.	;
              informat LEAVE_2_INI_DAY	$2.	;
              informat LEAVE_2_INI_MON	$2.	;
              informat LEAVE_2_END_DAY	$2.	;
              informat LEAVE_2_END_MON	$2.	;
              informat LEAVE_3_CAUSE	$2.	;
              informat LEAVE_3_INI_DAY	$2.	;
              informat LEAVE_3_INI_MON	$2.	;
              informat LEAVE_3_END_DAY	$2.	;
              informat LEAVE_3_END_MON	$2.	;
              informat NUM_LEAVE_DAYS	comma3.	;



            format HIRE_DATE DDMMYYS10.;
            format DATE_OF_BIRTH DDMMYYS10.;
            format CNAE20_CLASS	$5.;

            input
              MUNI
              CNAE95_CLASS
              EMP_ON_DEC31
              CONTRACT_TYPE
              CAUSE_OF_SEP
              MONTH_OF_SEP
              IND_VINC_ALVARA
              TYPE_OF_HIRE
              SALARY_TYPE
              OCCUP_CBO94
              EDUC_v2005
              SEX
              NATIONALITY
              RACE_v2006
              WORKER_DISABLED
              ESTAB_SIZE_DEC31
              LEGAL_NATURE_CONCLA2002
              WORKER_LINKED_CEI
              ESTAB_TYPE
              ESTAB_IN_PAT
              IND_SIMPLES
              HIRE_DATE
              %IF &st=SP %THEN %DO;
                EARN_AVG_MONTH_MW
                EARN_AVG_MONTH_NOM
                EARN_DEC_MW
                EARN_DEC_NOM
              %END;
              %ELSE %DO;
                EARN_DEC_NOM
                EARN_DEC_MW
                EARN_AVG_MONTH_NOM
                EARN_AVG_MONTH_MW
              %END;
              TENURE_MONTHS
              NUM_HOURS_CONTRACTED
              FINAL_PAY_YEAR
              CONTRACT_SALARY
              PIS
              DATE_OF_BIRTH
              CTPS
              CPF
              CEI_CONTRACT_ESTAB
              PLANT_ID
              CNPJ_ROOT
              TIPO_ESTB_ID
              WORKER_NAME
              DAY_OF_SEP
              OCCUP_CBO2002
              %IF &st=SP %THEN CNAE20_CLASS_TMP ;
              %ELSE CNAE20_CLASS ;
              CNAE20_SUBCLASS
              TYPE_OF_DISABILITY
              LEAVE_1_CAUSE
              LEAVE_1_INI_DAY
              LEAVE_1_INI_MON
              LEAVE_1_END_DAY
              LEAVE_1_END_MON
              LEAVE_2_CAUSE
              LEAVE_2_INI_DAY
              LEAVE_2_INI_MON
              LEAVE_2_END_DAY
              LEAVE_2_END_MON
              LEAVE_3_CAUSE
              LEAVE_3_INI_DAY
              LEAVE_3_INI_MON
              LEAVE_3_END_DAY
              LEAVE_3_END_MON
              NUM_LEAVE_DAYS
            ;

          LABEL
            MUNI = "Establishment Municipality"	  
            CNAE95_CLASS = "Industry according to CNAE/95 (CNAE 1.0, rev.2002; 614 categories"
            EMP_ON_DEC31 = "Contract active on Dec. 31"          
            CONTRACT_TYPE	= "Type of employment contract"
            CAUSE_OF_SEP	= "Reason for contract termination"          
            MONTH_OF_SEP	= "Month of contract termination"          
            IND_VINC_ALVARA	= "Indicator that worker has Judicial Permit"      
            TYPE_OF_HIRE = "Type of contract initiation"	          
            SALARY_TYPE	= "Frequency of salary payment"                 
            EDUC_v2005 = "Education degree"	            
            SEX	= "Worker sex"                  
            NATIONALITY = "Worker nationality"          
            RACE_v2006 = "Worker race (2006 classifications)"            
            WORKER_DISABLED	= "Indicator that worker has a disability"      
            ESTAB_SIZE_DEC31 = "Estab. size category: contracts active on Dec. 31"      
            LEGAL_NATURE_CONCLA2002 = "Legal nature of establishment (CONCLA/2002)"
            WORKER_LINKED_CEI	= "Indicator: worker is linked to a linked CEI"    
            ESTAB_TYPE = "Establishment Type (CNPJ or CEI)"	            
            ESTAB_IN_PAT = "Estab. participates in PAT (food program)"	          
            IND_SIMPLES	= "Indicates estab. opted for SIMPLES"          
            HIRE_DATE	= "Date of contract initiation"            
            EARN_AVG_MONTH_NOM = "Average monthly pay (nominal)"	    
            EARN_AVG_MONTH_MW	= "Average monthly pay (in MW)"    
            EARN_DEC_NOM = "December pay (nominal)"	          
            EARN_DEC_MW	= "December pay (in MW)"          
            TENURE_MONTHS	= "Tenure in contract (in months)"        
            NUM_HOURS_CONTRACTED = "Number of weekly hours contracted"	  
            FINAL_PAY_YEAR = "Final pay of the year"	        
            CONTRACT_SALARY = "Contracted salary"	        
            PIS	= "Worker PIS code"                  
            DATE_OF_BIRTH	= "Worker date of birth"        
            CTPS = "CTPS code"	                  
            CPF	= "CPF code"                  
            CEI_CONTRACT_ESTAB = "CEI contract of the establishment"	    
            PLANT_ID = "Plant identifier (either CNPJ or CEI)"	              
            CNPJ_ROOT	= "Root CNPJ (first 8 digits?)"            
            TIPO_ESTB_ID = "Unknown"
            WORKER_NAME	= "Worker name"     
            DAY_OF_SEP = "Contract end date: day"	       
            OCCUP_CBO2002	= "Occupation classification per CBO 2002"        
            CNAE20_CLASS = "Industry class (5 digit) according to CNAE 2.0"	     
            CNAE20_SUBCLASS	= "Industry subclass (7 digit) according to CNAE 2.0"        
            TYPE_OF_DISABILITY = "Worker: type of disability"	    
            LEAVE_1_CAUSE	  = "First leave spell: cause"        
            LEAVE_1_INI_DAY = "First leave spell: start day"	      
            LEAVE_1_INI_MON = "First leave spell: start month"	      
            LEAVE_1_END_DAY = "First leave spell: end day"	      
            LEAVE_1_END_MON = "First leave spell: end month"	      
            LEAVE_2_CAUSE	  = "Second leave spell: cause"            
            LEAVE_2_INI_DAY	= "Second leave spell: start day"	      
            LEAVE_2_INI_MON	= "Second leave spell: start month"      
            LEAVE_2_END_DAY	= "Second leave spell: end day"	        
            LEAVE_2_END_MON	= "Second leave spell: end month"	      
            LEAVE_3_CAUSE	  = "Third leave spell: cause"            
            LEAVE_3_INI_DAY	= "Third leave spell: start day"	      
            LEAVE_3_INI_MON = "Third leave spell: start month"       
            LEAVE_3_END_DAY	= "Third leave spell: end day"	        
            LEAVE_3_END_MON	= "Third leave spell: end month"	      
            NUM_LEAVE_DAYS	= "Number of days of leave taken this year"                                     
            ;   

            /*IN 2008 SP has earnings variables out of order.
            In 2008 SP also has a prefix "CLASSE" in the CNAE20_CLASS field.
            This code reorders the earnings variables. 
            It also replaces the CNAE20_CLASS variable with the first 5 digits of CNAE20_SUBCLASS. 
            This code is for 2008 only*/
            %IF &st=SP %THEN %DO;
              CNAE20_CLASS = substr(CNAE20_CLASS_TMP,8,5);
              drop CNAE20_CLASS_TMP;
            %END;
            
            if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
              * create variables to track file of origin;
                FORMAT year $4. ;
                FORMAT form $2. ;
                year = "2008" ;
                form = "&file." ;
                LABEL
                  year = 'sample year'
                  form = 'data file of origin';

                /*2002 and 2008 only. There is a stray header row in the file for SP. This line drops that obs*/
                if SALARY_TYPE ne "TI" then output; 
            run;

  /*smell testing*/
  proc contents data=INTERWRK.&st.2008;
  run;

  proc print data=INTERWRK.&st.2008 (obs=50);
  run;

%mend;
/* run macro for all data in 2008 */

%macro runall_states;

  /* %let i=1 ;
  %do %while ("%scan(&states.,&i.)" ne "" ) ;
    %let state=%scan(&states.,&i.);
    %readin2008(&state.,&state.);
    %let i=%eval(&i.+1);
  %end; */

  data INTERWRK.RAIS2008_raw;
    set
      %let i=1 ;
        %do %while ("%scan(&states.,&i.)" ne "" ) ;
          %let state=%scan(&states.,&i.);
          INTERWRK.&state.2008
          %let i=%eval(&i.+1);
        %end;
        ;

  proc datasets library=INTERWRK;
       delete
         %let i=1 ;
          %do %while ("%scan(&states.,&i.)" ne "" ) ;
            %let state=%scan(&states.,&i.);
            &state.2008
            %let i=%eval(&i.+1);
          %end;
          ;
  run;

%mend;


%runall_states;

  proc contents data=INTERWRK.RAIS2008_raw;
  run;

  proc print data=INTERWRK.RAIS2008_raw (obs=100);
  run;

