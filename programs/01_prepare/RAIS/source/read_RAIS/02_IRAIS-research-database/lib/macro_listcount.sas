/* Macro return a macro variable with the number of items in a list */

%macro listcount(list,letter);
	%global &letter.;
	%let c=1;
		%do %until (%bquote(%scan(&list,&c))=);
    		%let c=%eval(&c+1);
	%end;
	%let &letter.=%eval(&c-1);
%mend listcount;