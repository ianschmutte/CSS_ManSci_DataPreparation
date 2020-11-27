/*harmonize all files*/

/* uncomment the following line and replace <email-address> if you want email notification when the code begins to execute */
/* x echo "Harmonizing started" | mail -s "IRAIS harmonizing start" <email-address>; */

%macro runall;
%DO year = 2003 %TO 2017;
  x nohup sas -memsize 100G RAIS_harmonize_&year..sas;
%END;
%mend;


%runall;
x nohup sas -memsize 100G 03.02.cleanup.sas;
x nohup sas -memsize 100G 03.03.contents.sas;

/* uncomment the following line and replace <email-address> if you want email notification when the code finshes executing */
/* x echo "Harmonizing done" | mail -s "IRAIS harmonizing done" <email-address>; */