*----------------------------------------------------------------------------------*
* DO FILE TO CREATE SAMPLING FRAME TABLES

/*
Using the ORBIS universe and sampling frame, can you prepare some tables comparing:
- the RAIS firms that are in the ORBIS universe to those that are selected for the sampling frame 
- and then to those that are actually sampled? 
- That is, I think there are four types of firm:
i. In RAIS and in ORBIS universe, but not in frame
ii. In RAIS and in ORBIS universe and in sampling frame but not surveyed
iii. In RAIS and in ORBIS universe and surveyed

iv. not in RAIS or not in ORBIS universe (this isn't really possible as we wouldn't have possibly picked up these firms)

I want a comparison, based on the RAIS variables, across these three categories. 
If the randomization works, they should not be too different. 
For this analysis it probably makes sense to look at the 2008 and 2013 frames separately.
*/
*----------------------------------------------------------------------------------*


// Paths to different folders
do "../lib/header.do"

/* USE WMS DATA*/
tempfile wmstmp
foreach yr in 2008 2013{
    use "${inpath}/wmslong_clean.dta", clear
    keep if year==`yr'
    rename account_id company_id
    merge 1:1 company_id using "${trunk}/data/input/WMS/sf_br_final.dta"
    tab _merge
    gen wms_frame_match = 0
    replace wms_frame_match = 1 if _merge == 3
    drop _merge
    save `wmstmp', replace

    ** load RAIS universe summary file
    use "${inpath}/RAIS_plant_list", clear

    * do it for each year in turn, 2008 first
    keep if year==`yr'

    ** merge with WMS sampling frame
    merge 1:m cnpj using `wmstmp'

    lab define match 1 "RAIS only" 2 "Frame only" 3 "RAIS-Frame Match"
    lab val _merge match

    rename _merge rais_frame_match

    * recast plant size to match the information from WMS/Orbis so it isn't dropped
    rename estab_size_dec31 plantsz

    gen compare = 0

    replace compare = 1 if rais_frame_match == 1
    replace compare = 2 if (rais_frame_match == 3 & inframe`yr' == 0)
    replace compare = 3 if (rais_frame_match == 3 & (inframe`yr' == 1 | wms_frame_match == 1))
    replace compare = 4 if (rais_frame_match == 3 & wms_frame_match == 1)
    replace compare = 5 if (rais_frame_match == 2 & wms_frame_match == 1)

    lab define compare 0 "Other" 1 "RAIS w/o Orbis" 2 "+ Orbis w/o Frame" 3 "+Frame w/o WMS" ///
    4 " + WMS " 5 "WMS - RAIS", modify
    lab val compare compare

    * create a count variable for the table
    cap drop count
    g count=.
    bysort compare: replace count=_N
    replace count=. if compare==.
    lab var count "Estabs."

    label define ownl ///
    1 "Family owned" /// 
    2 "Founder owned" ///
    3 "Manager owned" ///
    4 "Nonfamily private owned" ///
    5 "Institutionally owned" ///
    6 "Government owned" 



    gen plantsznum = real(plantsz)
    label define plantsz ///
    1 "Zero"  ///
    2 "less than 5" ///
    3 "5 to 9" ///
    4 "10 to 19" ///
    5 "20 to 49" ///
    6 "50 to 99" ///
    7 "100 to 249" ///
    8 "250 to 499" ///
    9 "500 to 999" ///
    10  "1000 or more"

    gen regnum = real(region)
    label define region ///
    1 "North" ///
    2 "Northeast" ///
    3 "Southeast" ///
    4 "South" ///
    5 "Central-West" 
    


    /*make alternative ownership categories*/
    egen own_grp=group(ownership)
    gen own_cat = .
    replace own_cat = 1 if own_grp >=4  & own_grp <=7 // Family owned
    replace own_cat = 2 if own_grp >= 9 & own_grp <=11 // Founder owned
    replace own_cat = 3 if own_grp == 14 // Manager owned
    replace own_cat = 4 if own_grp == 2 | own_grp==13 | own_grp==16 | own_grp==17 // Private (incl dispersed sh)
    replace own_cat = 5 if own_grp ==1 | own_grp==3 | own_grp==8 | own_grp==15 // Institutional 
    replace own_cat = 6 if own_grp == 12 // Mainly govt



    label values own_cat ownl
    label values plantsznum plantsz
    label values regnum region

    tabulate own_cat, gen(ownerc)
    la var ownerc1 "Family owned" 
    la var ownerc2 "Founder owned"
    la var ownerc3 "Manager owned" 
    la var ownerc4 "Nonfamily private owned"
    la var ownerc5 "Institutionally owned"
    la var ownerc6 "Government ownership" 

    tabulate plantsznum, gen(plantc)
    la var plantc1 "Zero"  
    la var plantc2 "less than 5" 
    la var plantc3 "5 to 9"
    la var plantc4 "10 to 19" 
    la var plantc5 "20 to 49" 
    la var plantc6 "50 to 99" 
    la var plantc7 "100 to 249" 
    la var plantc8 "250 to 499" 
    la var plantc9 "500 to 999" 
    la var plantc10  "1000 or more"

    tabulate regnum, gen(regc)
    la var regc1 "North"
    la var regc2 "Northeast" 
    la var regc3 "Southeast" 
    la var regc4 "South" 
    la var regc5 "Central-West" 

    label var firmage "Firm age (years)"
    label var management "Management score "
    label var degree_t "\% of employees with college degree (WMS)"
    label var male "share of male employees (RAIS)"
    /* label var coll_share "\% of employees with college degree (RAIS)" */

    la var percent_m "\% of managers (WMS)"

    * label key variables
    lab var emp_dec31 "End of year emp. (RAIS)" 
    lab var age_31dec "Avg. worker age (RAIS)" 
    lab var earn_avg_month_real "Monthly earnings (2015 BRL)" 
    lab var race_white "Share white"
        


    local compvars1 emp_dec31 male age_31dec earn_avg_month_real race_white plantc? regc?
    local compvars2 management emp_plant firmage percent_m ownerc? 

    estpost tab compare if compare ~= 0
    esttab using ./frame_freqs_`yr'.tex , booktabs label replace noobs unstack nonote nonum compress nodepvars
    esttab  , label replace noobs unstack nonote nonum compress nodepvars

        
    estpost tabstat  `compvars1' if compare ~= 0 & compare <=4, by(compare) stat(mean n) columns(statistics)  notot
    esttab . using ./frame_compare_rais_`yr'.tex, booktabs label replace ///
            refcat(emp_dec31 "\textbf{General RAIS}" ///
            plantc1   "\textbf{Size class}" ///
            regc1     "\textbf{Region}" ///
        , nolabel) ///
        main(mean) unstack nonum noobs nonote onecell compress
    esttab . , label replace ///
            refcat(emp_dec31 "\textbf{General RAIS}" ///
            plantc1   "\textbf{Size class}" ///
            regc1     "\textbf{Region}" ///
        , nolabel) ///
        main(mean) unstack nonum noobs nonote onecell compress
        
    estpost tabstat  `compvars2' if compare >3, by(compare) stat(mean n) columns(statistics)   notot
    esttab . using ./frame_compare_wms_`yr'.tex , booktabs label replace ///
            refcat(management "\textbf{General WMS}" ///
            ownerc1 "\textbf{Ownership}" ///
        , nolabel) ///
        main(mean) unstack nonum nonote onecell

    esttab .  , label replace ///
            refcat(management "\textbf{General WMS}" ///
            ownerc1 "\textbf{Ownership}" ///
        , nolabel) ///
        main(mean) unstack nonum nonote onecell

}


log close		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
