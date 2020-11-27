/**********************************
Macros to validate CPF, CNPJ, CEI, PIS codes.
Ian M. Schmutte
8 April 2019
schmutte@uga.edu

v1.0.0
**********************************/



%macro validate_pis(pis);
  array list_pis{10} _temporary_ (3 2 9 8 7 6 5 4 3 2);
  &pis._valid = 0; /*default*/
  &pis. = trim(left(&pis.)); /*imposes string formatting.. no leading spaces*/
  /*Check basic stuff*/
  if length(&pis.) = 11 and &pis. ne "00000000000" then do;
    sum = 0;
    cd1 = input(substr(&pis.,11,1),1.);
    do pos = 1 to 10;
      sum = sum + list_pis{pos}*input(substr(&pis.,pos,1),1.);
    end;
    if (mod(sum,11) in (0,1) and cd1 = 0) or (11 - mod(sum,11) = cd1) then &pis._valid=1;
  end;
%mend;

%macro validate_cpf(cpf);
  &cpf._valid = 0; /*default*/
  &cpf. = trim(left(&cpf.)); /*imposes string formatting.. no leading spaces*/
  /*Check basic stuff*/
  if length(&cpf.) = 11 and &cpf. ne "00000000000" then do;
    sum = 0;
    cd1 = input(substr(&cpf.,10,1),1.);
    do pos = 1 to 9;
      sum = sum + (11-pos)*input(substr(&cpf.,pos,1),1.);
    end;
    if (mod(sum,11) in (0,1) and cd1 = 0) or (11 - mod(sum,11) = cd1) then do;
      sum = 0;
      do pos = 1 to 10;
        sum = sum + (12-pos)*input(substr(&cpf.,pos,1),1.);
      end;
      cd2 = substr(&cpf.,11,1);
      if (mod(sum,11) in (0,1) and cd2 = 0) or (11 - mod(sum,11) = cd2) then &cpf._valid = 1;
    end;
  end;
%mend;


%macro validate_cei(cei);
  array list_cei{11} _temporary_ (7 4 1 8 5 2 1 6 3 7 4);
  &cei._valid = 0; /*default*/
  &cei. = trim(left(&cei.)); /*imposes string formatting.. no leading spaces*/
  /*Check basic stuff*/
  if length(&cei.) = 12 and &cei. ne "000000000000" then do;
    sum = 0;
    cd1 = input(substr(&cei.,12,1),1.);
    do pos = 1 to 11;
      sum = sum + list_cei{pos}*input(substr(&cei.,pos,1),1.);
    end;
    /*get ones position of the sum of the tens and ones position*/
    if sum ge 10 then sum = mod(mod(int(sum/10),10) + mod(sum,10),10);
    /*handle case where sum of tens and ones position was 10*/
    if sum = 0 and cd1 = 0 then &cei._valid = 1;
    else if cd1 = (10 - sum)  then &cei._valid = 1;
  end;
%mend;


%macro validate_cnpj(cnpj);
  array list_cnpj{13} _temporary_ (6 5 4 3 2 9 8 7 6 5 4 3 2);
  &cnpj._valid = 0; /*default*/
  &cnpj. = trim(left(&cnpj.)); /*imposes string formatting.. no leading spaces*/
  /*Check basic stuff*/
  if length(&cnpj.) = 14 and &cnpj. ne "00000000000000" then do;
    sum = 0;
    cd1 = input(substr(&cnpj.,13,1),1.);
    do pos = 2 to 13;
      sum = sum + list_cnpj{pos}*input(substr(&cnpj.,pos-1,1),1.);
    end;
    if (mod(sum,11) in (0,1) and cd1 = 0) or (11 - mod(sum,11) = cd1) then do;
      sum = 0;
      do pos = 1 to 13;
        sum = sum + list_cnpj{pos}*input(substr(&cnpj.,pos,1),1.);
      end;
      cd2 = input(substr(&cnpj.,14,1),1.);
      if (mod(sum,11) in (0,1) and cd2 = 0) or (11 - mod(sum,11) = cd2) then &cnpj._valid = 1;
    end;
  end;
%mend;