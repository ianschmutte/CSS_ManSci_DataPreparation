% /********************
% 	Ian M. Schmutte
%   Load in data matrix
% *********************/

try; 
	CG_MATLAB_HEADER; %define file paths

    data = csvread([ss_path1,'/CG_file.csv'],1,0); %read in data matrix from .csv file
    save([ss_path1,'/CG_file.mat'],'data','-v7.3');
	
clear all;
catch err; 
    err.message
    err.cause
    err.stack
   exit(1);
end
exit;