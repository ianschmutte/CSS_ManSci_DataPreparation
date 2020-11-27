% /********************
% 	CG_est_twfe_test.m
% 	Ian M. Schmutte
% 	2019 Aug 10
% 	DESCRIPTION: Decomposition of wage heterogeneity into worker and plant effects. 
% *********************/

try; 
	disp(fix(clock));
	CG_MATLAB_HEADER; %define file paths
	addpath ./AKM_MATLAB/;

%load data
	load([ss_path1,'/CG_file.mat']); %loads 'data' 
	wid_orig_all = data(:,1);
	pid_orig_all = data(:,2);
	rmn_orig = [wid_orig_all pid_orig_all];

	% workernum plantnum year log_wage age_31Dec male race_white race_pardo race_preto race_other
	
	nobs = size(data,1);
	w = data(:,4);
	year = data(:,3);
	age = data(:,5)/10; %in years rescaled down by a factor of 10
	male = data(:,6);
	white = data(:,7);
	pardo = data(:,8);
	preto = data(:,9);
	

	%relabel the matches, workerid, plantid
	[~,~,wid]=unique(rmn_orig(:,1));
	[~,~,pid]=unique(rmn_orig(:,2));
	rmn = [wid pid];
	clear rmn_orig wid pid;
	save([ss_path1,'/rmn_tmp.mat'],'rmn','-v7.3');
    
	clear wid pid data 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Grouping
	adj_rmn    = sparse(rmn(:,1),rmn(:,2),ones(nobs,1)); %adjacency matrix representation of the realized mobility network
    % adj_rmn    = sparse(adj_rmn>0);
	disp('Finding connected components output');
	disp(fix(clock));
    components = find_components(adj_rmn);
    % When it's done:
    save([ss_path2,'/components.mat'],'components','-v7.3');
	disp('components.mat saved');
	disp(fix(clock));

	clear adj_rmn components;
	
%design matrices

	year_inds = sparse((1:nobs)',year-ones(nobs,1)*2002,ones(nobs,1));
	age_profile = [(age-3).^2 (age-3).^3];
	X = sparse([ones(nobs,1) age_profile repmat(male,1,2).*age_profile repmat(white,1,2).*age_profile repmat(pardo,1,2).*age_profile repmat(preto,1,2).*age_profile  year_inds(:,2:end)]);
	save([ss_path1,'/X_tmp.mat'],'X','-v7.3');
	Xnum = size(X,2);
	year_fx_num = max(year)-min(year);
	D  = sparse((1:nobs)',rmn(:,1) ,ones(nobs,1));
	disp('D matrix generated');
	F = sparse((1:nobs)',rmn(:,2) ,ones(nobs,1)); 
	disp('F matrix generated');
	I = size(D,2);
	J = size(F,2);

	clear  year_inds white pardo preto other male age age_profile

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform PCG routine for TWFE
	disp('creating design matrices.');
	disp(fix(clock));
	XD = X'*D;
	XF = X'*F;
	XX = X'*X;
	Xw = X'*w;
	clear X;
	DD = D'*D;
	DF = D'*F;
	Dw = D'*w;
	clear D
	FF = F'*F;
	Fw = F'*w;
	clear F
    A = [XX  XD  XF; 
			   XD' DD  DF;
			   XF' DF' FF];
	save([ss_path1,'/A_tmp.mat'],'A','-v7.3')
	clear XD XF DD DF FF
	b = [Xw; Dw; Fw];
	save([ss_path1,'/b_tmp.mat'],'b','-v7.3')
	clear Xw Dw Fw
	disp('design matrices finished.');
	disp(fix(clock));
	clear F
	 
	% creating preconditioner
	U1 = sparse(chol(XX));
	clear XX
	U2 = spdiags(sqrt(spdiags(A(Xnum+1:Xnum+I,Xnum+1:Xnum+I))),0,I,I);
	U3 = spdiags(sqrt(spdiags(A(Xnum+I+1:end,Xnum+I+1:end))),0,J,J);
	U = blkdiag(U1,U2,U3);
	disp('created preconditioner U.');
	disp(fix(clock));
	clear  U1 U2 U3;

	%run estimation
	disp('Executing PCG routine');
	disp(fix(clock));
	tic
	options.pcg_tol = 1e-10;
	options.pcg_maxit =1000;                                            
	options.pcg_x0 =[];                                               %initial guess for pcg
	[output.x output.pcg_flag output.relres output.iter]   = pcg(A,b,options.pcg_tol,options.pcg_maxit,U',U,options.pcg_x0);
	toc
	disp(fix(clock));
	%diagnostics
	clear A b;
	fprintf('PCG Convergence Flag %3i,\n',output.pcg_flag);
	fprintf('PCG Num. Iter.: %3i,\n',output.iter);
	fprintf('PCG Relative Residual %4.8f,\n',output.pcg_flag);

	load([ss_path2,'/components.mat']);
		load([ss_path1,'/rmn_tmp.mat']);
    id_out=CGPost_identify_effects(output.x,Xnum,components,rmn);
    save([ss_path1,'/CG_output_identified.mat'],'id_out','-v7.3');
    clear components

%    load([ss_path1,'/CG_output_identified.mat']);

    load([ss_path1,'/X_tmp.mat']);
	fprintf('Number of observations: %d,\n',nobs);
	% fprintf('Num. Matches = %d \n',nummatch);
	fprintf('Num Workers = %d \n',I);
	fprintf('Num Plants = %d \n',J);
	disp('Mean of X variables');
	disp(full(mean(X)));
	disp('Mean of dependent variable')
	disp(mean(w));

    load([ss_path1,'/rmn_tmp.mat']);
	D  = sparse((1:nobs)',rmn(:,1) ,ones(nobs,1));
	F = sparse((1:nobs)',rmn(:,2) ,ones(nobs,1)); 
	yhat = [X D F]*output.x;
	resid = w-yhat;
	dof = nobs-J-I+1-Xnum;
	RMSE = sqrt(sum(resid.^2)/dof);
	TSS = sum((w-mean(w)).^2);
	R2 = 1-sum(resid.^2)/TSS;
	adjR2 = 1-sum(resid.^2)/TSS*(nobs-1)/dof;
	fprintf('Residual Sum %1.9f,\n',sum(resid));
	fprintf('RMSE %1.5f,\n',RMSE);
	fprintf('R2 %1.5f,\n',R2);
	fprintf('adjR2 %1.5f,\n',adjR2);
	disp('TWFE Result');
	disp(output.x(1:Xnum));

   pe     = D*id_out.theta;
   fe     = F*id_out.psi;
   Xb     = X(:,2:end)*id_out.beta;
   const  = id_out.alpha;

   yhat_id = const +Xb +pe + fe;
   r = w-yhat_id;

   clear X D F resid

%Output match-year dataset augmented with AKM effects and the adjusted wage based on stayers
	dataout = [wid_orig_all pid_orig_all year w Xb pe fe r];
			
	save([ss_path1,'/CG_HCfile_twfe.mat'],'dataout','-v7.3');

	mycell = {'workernum' 'plantnum' 'year' 'ln_wage' 'Xb' 'pe' 'fe' 'resid'};
	[nrows,ncols] = size(dataout);
	filename = [ss_path1,'/CG_HCfile_twfe.txt'];
	fid2 = fopen(filename, 'W');
	fprintf(fid2,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',mycell{1,:});
	for row = 1:nrows
		fprintf(fid2,'%d\t%d\t%d\t%1.8f\t%1.8f\t%1.8f\t%1.8f\t%1.8f\n',dataout(row,:));
	end
	fclose(fid2);
		

disp(fix(clock));


clear all;
catch err; 
    err.message
    err.cause
    err.stack
   exit(1);
end
exit;