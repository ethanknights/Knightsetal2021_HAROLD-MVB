%Run Group Second Level Analysis for:
%Action > Baseline [1 0] from individual subj contrasts: action > baseline (no catch) [1 1 1 0 0]
%Age covariate [0 1]

clear
load('CCIDList.mat','CCIDList','age','fNs','trialInfo');

destDir_root = 'data';
kernelSize = 8; %8 | 10 %value refers to the smoothing of the RSFA scale smooth (i.e. all are 10mm, then this value too)

sourceDirs = {'firstLevelModel','firstLevelModel_smooth'}; 
destDirs = {'groupModel',['groupModel_smooth_',num2str(kernelSize),'mm']};

nSubs = length(CCIDList);


for i = 2%1:2 %i=1 is wds, i=2 is smooth - DONT really need this for wds
  
  destDir = fullfile(destDir_root,destDirs{i});
  mkdir(destDir)
  
  
  %% Specify 2nd-level
  sourceDir = sourceDirs{i};
  
  fN = {};
  for s = 1:nSubs
    CCID = CCIDList{s};
    fN{s} = fullfile(destDir_root,sourceDir,CCID,['final_','s',num2str(kernelSize),'mm_con_0001_RSFAScaled.nii,1']); %all>baseline (no catch) [1 1 1 0 0]
  end
  
  %% remove missing (due to RSFA images missing)
  for s = 1:nSubs; CCID = CCIDList{s}; idxMissing(s) = exist(fN{s}(1:end-2),'file'); end
  fN(find(~idxMissing)) = [];
  age(find(~idxMissing)) = [];
  nSubs = length(fN);
  
  matlabbatch = [];
  matlabbatch{1}.spm.stats.factorial_design.dir = {destDir};
  matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = fN'; %all subs All > Baseline
  matlabbatch{1}.spm.stats.factorial_design.cov.c = age(1:nSubs);
  matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'age';
  matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
  matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
  matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
  matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
  matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
  matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
  matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
  matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
  matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
  spm_jobman('run',matlabbatch);
  
  
  %% Estimate 2nd-level
  fN = fullfile(destDir,'SPM.mat');
  
  matlabbatch = [];
  matlabbatch{1}.spm.stats.fmri_est.spmmat = {fN};
  matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
  matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
  spm_jobman('run',matlabbatch);
  
  %% Contrasts
  matlabbatch = [];
  matlabbatch{1}.spm.stats.con.spmmat = {fN};
  
  matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'All > baseline';
  matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0];
  matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
  
  matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Effect of Age +';
  matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1];
  matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
  
  matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'Effect of Age -';
  matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 -1];
  matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
  
  matlabbatch{1}.spm.stats.con.delete = 1;
  
  spm_jobman('run',matlabbatch);
  
end
