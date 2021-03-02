function extractROI_fMRI_multitrial_GLMs_singleROI(roifN,roiName,nCond,method)


load('CCIDList.mat','CCIDList','age','fNs','trialInfo');
outDir_root = 'data';
extractingDir = fullfile(outDir_root,'aa_norm_write_dartel_masked');
AnySPMDirWithOnsets = fullfile(outDir_root,'firstLevelModel');

outDir = fullfile(outDir_root,'singleTrialBetas')
mkdir(outDir)

parfor s = 1:length(CCIDList)
  
  CCID = CCIDList{s};
  fprintf('Setting up extraction: sub-%s %s \nFrom ROI: %s\n',num2str(s),CCID,roifN)
  
  S = [];
  
  %         %SIMPLE ROI EXTRACTION (IGNORES HEADER TRANSFORMATIONS)
  %         %%get roi XYZ coords
  %         Y = spm_read_vols(spm_vol(roifN));
  %         idx = find(Y>0);
  %         [x,y,z] = ind2sub(size(Y),idx);
  %         XYZ = [x y z]';
  %         %get roi timeseries
  %         scanfN = cellstr(spm_select('ExtFPList',sprintf('data/func/%s/',CCID{s}),'swarsub'));
  %         S.d = spm_get_data(spm_vol(scanfN),XYZ);
  %             %write nifti to check
  %             writeNIFTI('myROI.nii',XYZ,'/imaging/ek03/MVB/FreeSelection/pp/data/statsGroupAllBIGBaseline/Mc_L_100vox.nii')
  %             spm_check_registration('myROI.nii','/imaging/ek03/single_subj_T1.nii')
  
  %% get roi timeseries (based on roi_extract.m)
  VY = spm_vol(cellstr(spm_select('ExtFPList',fullfile(extractingDir,CCID),'^mswauf.*\.nii$')));
  VY = [VY{:}];
  Yinv = inv(VY(1).mat); %Get inverse transform (assumes all data files are aligned)
  
  [VM,mXYZmm] = spm_read_vols(spm_vol(roifN));
  
  %Transform ROI XYZ in mm to voxel indices in data:
  yXYZind = Yinv(1:3,1:3)*mXYZmm + repmat(Yinv(1:3,4),1,size(mXYZmm,2));
  
  f = find(VM);
  S.d = spm_get_data(VY,yXYZind(:,f));
          %write nifti to check:
          %writeNIFTI('myROI.nii',yXYZind(:,f),VY(1).fname)
          %spm_check_registration('myROI.nii','/imaging/ek03/single_subj_T1.nii')
          %check again when stealing a roi file header instead:
          %writeNIFTI('myROI.nii',yXYZind(:,f),'data/groupModel_smooth/PreCG_L_500.nii')
          %spm_check_registration('myROI.nii','/imaging/ek03/single_subj_T1.nii')
  
  %% remove voxels outside mask (due to smooth mask for unsmoothed data)
  S.d = S.d(:,find(var(S.d) > 0));
          
  %% get onsets
  SPMmat = load(fullfile(AnySPMDirWithOnsets,CCID,'SPM.mat'));
  allOns = {SPMmat.SPM.Sess.U.ons};
  %allDurs = {SPMmat.SPM.Sess.U.dur}; %all are 0..
  for c = 1:nCond
    S.events.ons{c} = allOns{c};
    S.events.dur{c}(1:length(S.events.ons{c})) = 0; %THIS HAS CHANGED!!
  end
  
  S.method = method;
  
  S.XC = SPMmat.SPM.xX.X(:,16:23); %confounds
  %S.coi = 1:3; %I'll ignore these catch trials when doing R
  
  %% get singletrial betas
  beta{s} = fMRI_multitrial_GLMs(S);
end

%Remove empty rows for badSubjects (so matrix matches age etc.)
% beta = beta(goodSubs);

oN = fullfile(outDir,sprintf('singleTrial-beta_ROI-%s_method-%s.mat',roiName,method))
save(oN,'beta');

end
