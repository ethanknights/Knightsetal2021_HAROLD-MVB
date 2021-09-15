%% Start of DCM script for sensorimotor task
% Variables: 
% ROI Paths for left/right hemisphere in roifN{1} and roifN{2}  
% SPM in SPM
% Timeseries for left/right ROIs in d_L and d_R (maybe not needed though)
% age in age
%% Work-In-Progress!!

clear

load('CCIDList.mat','CCIDList','age') 

%% ROI paths (binary masks: 70 voxels)
roifN{1} = 'PreCG_L_70.nii';
roifN{2} = 'PreCG_R_70.nii';

%% Subject Loop
%for s = 1:length(CCIDList)
s=1; %1 subject for now
  CCID = CCIDList{s};
  
  %% load SPM
  fN = fullfile('data',CCID,'SPM.mat'); %symlinks
  load(fN,'SPM'); 
  SPM.swd = fullfile(pwd,'data',CCID); %Prevent risk of SPM functions overwriting the symlinked SPM destination
  
  
  %% If extract timeseries from SPM using voiExtract(?)
  %% If so, stop here.
  
 
  %% But incase not, and you need full roi timeseries - 
  % this was the method we used in this project before (based on roi_extract.m) during: 
  % /imaging/ek03/projects/HAROLD/SMT/pp/extractROI_fMRI_multitrial_GLMs_singleROI.m
  % Since that script did NOT save the timeseries, run this bit again (put in function now):
  extractingDir = fullfile('..','pp','data','aa_norm_write_dartel_masked');
  [d_L] = getRoiTimeseries(roifN{1},extractingDir,CCID);
  [d_R] = getRoiTimeseries(roifN{2},extractingDir,CCID);

  
  
  


  
%end %subject loop

%=====
%End
%=====

function [d] = getRoiTimeseries(roifN,extractingDir,CCID)
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
    %writeNIFTI(sprintf('myROI_%s',roifN),yXYZind(:,f),roifN)
    %spm_check_registration(sprintf('myROI_%s',roifN),'/imaging/ek03/single_subj_T1.nii')

    %% remove voxels outside mask (due to smooth mask for unsmoothed data)
    S.d = S.d(:,find(var(S.d) > 0));
    
    d = S.d;
end