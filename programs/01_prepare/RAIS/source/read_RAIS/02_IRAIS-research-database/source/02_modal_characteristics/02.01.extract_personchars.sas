/*
extract_personchars.sas
Ian M. Schmutte
2019-06-26

Extract person-level traits for each job from the harmonized database
*/

%INCLUDE "../../lib/header.sas";

%macro readtraits;
data FASTWRK1.traits (keep = PIS year male educ age_31Dec2003 RACE);
  set
  %DO yr=2003 %TO 2017;
    DBOUT.rais_match_uniq_&yr.(keep=
                PIS year
                AGE
                EDUC
                GENDER
                RACE
                )
  %END;
  ;
  male = GENDER = "M";
  if GENDER not in ("F", "M") then male = .;
  educ = input(EDUC,2.);
  age_31Dec2003 = floor(age - (year - 2003));
  race = input(race,2.);
  if race not in (1, 2, 4, 6, 8) then race = .;
  label
    male = "=1 if GENDER = M. =0 otherwise"
    age_31Dec2003 = "age on Dec. 31 2003"
    ; 
run;
%mend;
%readtraits;

proc freq data = FASTWRK1.traits;
  tables male educ race;
run;

proc sort data = FASTWRK1.traits;
  by PIS year;
run;


/*BEST EDUCATION BY PERSON-YEAR*/
data DBOUT.educ_best (keep = PIS year educ_best);
  set FASTWRK1.traits (keep = PIS year educ);
  by PIS year;
  retain educ_best;
  if first.PIS then educ_best = 0;
  educ_best = max(educ_best, educ);
  if last.year then output;
  label educ_best = "Maximum education observed for this PIS up to this year";
run;


proc freq data = DBOUT.educ_best;
  tables educ_best*year;
run;


/*MODAL GENDER AND RACE*/
data FASTWRK2.race_gender_mode (keep = PIS male_mode race_mode);
  set FASTWRK1.traits (keep = PIS male race);
  array racearr{9} _temporary_;
  by PIS;
  retain malecount count;
  if first.PIS then do;
    do i = 1 to 9;
      racearr{i} = 0;
    end;
    malecount = 0;
    count = 0;
  end;
  if race in (1, 2 , 4, 6, 8) then racearr{race} = racearr{race} + 1;
  else racearr{9} = racearr{9} + 1;
  count = count + 1;
  malecount = sum(malecount,male);
  
  if last.PIS then do;
   /*MODAL RACE*/
    maxracecount = 0;
    /*find races observed most often (excluding missing)*/
    do i = 1 to 8;
      maxracecount = max(maxracecount, racearr{i});
    end;
    /*identify race most often observed. If multiple races observed the same number of times, flag all of them*/
    count = 0;
    do i = 1 to 8;
      if racearr{i} = maxracecount then racearr{i} = 1;
      else racearr{i} = 0;
      count = count + racearr{i};
    end;
    /*THE rest of the code deals with randomly breaking ties.*/
    p = 0;
    do i = 1 to 8;
      if racearr{i} ~= 0 then do;
        racearr{i} = p + racearr{i}/count;
        p = racearr{i};
      end;
    end;
    /*sample*/
    p = ranuni(0);
    race_mode = 0;
    i = 0;
    do while (race_mode = 0);
      i = i+1;
      if i lt 9 then do;
        if racearr{i} ne 0 then do;
          if p le racearr{i} then race_mode = i;
        end;
      end;
      else race_mode = 9;
    end;

  /*get modal gender*/
    sharemale = malecount / count;
    if sharemale > .5 then male_mode = 1;
    else if sharemale < .5 then male_mode = 0;
    else male_mode = ranuni(0) > .5;

    output;
  end;
run;



/*MODAL AGE IN 2003*/
proc means data = FASTWRK1.traits(keep = PIS age_31Dec2003) noprint;
  var age_31Dec2003;
  by PIS;
  output out = FASTWRK1.modal_age(keep = PIS age_31Dec2003_mode) mode(age_31Dec2003)=age_31Dec2003_mode;
run;


/*COMBINE INTO PIS-level OUTPUT FILE*/
data DBOUT.race_gender_age_best problems;
  merge FASTWRK2.race_gender_mode (in = rg keep = PIS male_mode race_mode)
        FASTWRK1.modal_age (in = age keep = PIS age_31Dec2003_mode);
  by PIS;
  if rg and age then output DBOUT.race_gender_age_best;
  else output problems;
  label
    male_mode = "Modal value of male indicator across all jobs"
    race_mode = "Modal race across all jobs"
    age_31Dec2003_mode = "Modal age on Dec.31 across all jobs"
    ;
run;

/*ASSERT: NO PROBLEMS*/
proc contents data = problems;
run;

proc contents data = DBOUT.race_gender_age_best;
run;

proc freq data = DBOUT.race_gender_age_best;
  tables male_mode race_mode age_31Dec2003_mode;
run;