%Perform smoothing to the aa_mod_norm_dartel_masked

clear
load('CCIDList.mat','CCIDList','age','fNs','trialInfo');

destDir_root = 'data';
destDirs = {'firstLevelModel_waveletdespike','firstLevelModel_smooth'};

nSubs = length(CCIDList);

% outDir_root = 'data';
% outDir = fullfile(outDir_root,'smoothed');


%% create confoundRegressors.mat (saving in file means they have correct names)
fN_epi = fNs(:,1);

nVol = 261;
parfor s=1:nSubs
  
  CCID = CCIDList{s};
%   subDir = fullfile(outDir,CCID);
%   mkdir(subDir)
  
  fN = fN_epi{s};
  
  matlabbatch = [];
  x = [];
  for i = 1:nVol
    x{i} = sprintf('%s,%d',fN,i); %Hack-otherwise spm_select sytanx
        %%matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',source_subDir,'^mswauf.*\.nii$'));
  end
  x = x.';
  
  matlabbatch{1}.spm.spatial.smooth.data = x;
  matlabbatch{1}.spm.spatial.smooth.fwhm = [10 10 10];
  matlabbatch{1}.spm.spatial.smooth.dtype = 0;
  matlabbatch{1}.spm.spatial.smooth.im = 0;
  matlabbatch{1}.spm.spatial.smooth.prefix = 's';
  
  spm_jobman('run',matlabbatch);
  
  [fold,fil] = fileparts(fN);
  fNs{s,8} = fullfile(fold,['s',fil]);
  
end


save('CCIDList.mat','CCIDList','age','fNs','trialInfo');

