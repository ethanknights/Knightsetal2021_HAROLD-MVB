
cd data/groupModel_smooth/

%% First we will try with orthogonal contrast to the age effect (i.e. use action>baseline: 1 0)
%===================================
%% Choose Voxel Sizes here
fN_L = 'PreCG_L_70.nii';
fN_R = 'PreCG_R_70.nii';
fN_L = 'PreCG_L_35.nii';  %control MVB voxel sizes by halving bilateral ROI
fN_R = 'PreCG_R_35.nii';  %control MVB voxel sizes by halving bilateral ROI
fN_L = 'PreCG_L_140.nii'; %control MVB voxel sizes by doubling contralateral ROI

%--LEFT PRECG 1 0 (all action > baseline) --%
%% -36 -18 54   %Move spm cursor to these coords and run the correct vox:
% spm2roi(70,hReg,xSPM,fN_L(1:end-4)) %no '.nii'
% spm2roi(35,hReg,xSPM,fN_L(1:end-4)) %no '.nii'
% spm2roi(140,hReg,xSPM,fN_L(1:end-4)) %no '.nii'


%-RIGHT (Mirror Flip)-%
% %%%Right Motor cortex 
%%Flip the L_MC 100vox
matlabbatch = [];
matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN_L)};
matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
matlabbatch{1}.spm.util.reorient.prefix = 'right_';
spm_jobman('run',matlabbatch);
movefile(sprintf('right_%s',fN_L),sprintf('%s',fN_R)) %rename
    % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));

return


%% Repeat for other ROIs (SMA)
%% IMPORTANT: Mask SPM contrast by left hemisphere mask or voxels spill over & overlap RH!):
%% Create mask with: pp/utils/createHemisphereMask.m
%===================================
fN_L = 'SMA_L_70.nii';
fN_R = 'SMA_R_70.nii';
fN_L = 'SMA_L_35.nii';  %control MVB voxel sizes by halving bilateral ROI
fN_R = 'SMA_R_35.nii';  %control MVB voxel sizes by halving bilateral ROI
fN_L = 'SMA_L_140.nii'; %control MVB voxel sizes by doubling contralateral ROI

%--LEFT PRECG 1 0 (all action > baseline) --%
%% -6 0 57 (i.e. the localised peak closest to laterality analysis peak: 12	-3 	51)    %Move spm cursor to these coords and run the correct vox:
% spm2roi(70,hReg,xSPM,fN_L(1:end-4)) %no '.nii'
% spm2roi(35,hReg,xSPM,fN_L(1:end-4)) %no '.nii'
% spm2roi(140,hReg,xSPM,fN_L(1:end-4)) %no '.nii'


%-RIGHT (Mirror Flip)-%
matlabbatch = [];
matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN_L)};
matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
matlabbatch{1}.spm.util.reorient.prefix = 'right_';
spm_jobman('run',matlabbatch);
movefile(sprintf('right_%s',fN_L),sprintf('%s',fN_R)) %rename
    % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
