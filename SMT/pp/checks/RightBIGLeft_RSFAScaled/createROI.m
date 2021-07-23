
cd data/groupModel_smooth/

%% SMA

%% First we will try with orthogonal contrast to the age effect (1 0)
%===================================
fN_L = 'SMA_L_70.nii';
fN_R = 'SMA_R_70.nii';

%-- L SMA 1 0 (action > baseline) --%
% %Go to -9 -6 54 (i.e. the x flip of the Age Pos SMA Peak See next Circular analysis below!) 
% Then rightClick- go to local maximum for coords:
% -6 -21 51 %Move spm cursor to these coords and run the correct vox:
spm2roi(70,hReg,xSPM,fN_L(1:end-4)) %no '.nii'

%- RIGHT (Mirror Flip)-%
matlabbatch = [];
matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN_L)};
matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
matlabbatch{1}.spm.util.reorient.prefix = 'tmp_';
spm_jobman('run',matlabbatch);
movefile(sprintf('tmp_%s',fN_L),sprintf('%s',fN_R)) %rename
    % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
    
    
%% Second we do circular analysis (age effect (0 1)
%===================================
fN_L = 'AgePos_SMA_L_45.nii';
fN_R = 'AgePos_SMA_R_45.nii';

%-- R SMA 0 1 (age positive) --%
% %9 -6 54 %Move spm cursor to these coords and run the correct vox:
spm2roi(45,hReg,xSPM,fN_R(1:end-4)) %no '.nii'

%- LEFT (Mirror Flip)-%
matlabbatch = [];
matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN_R)};
matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
matlabbatch{1}.spm.util.reorient.prefix = 'tmp_';
spm_jobman('run',matlabbatch);
movefile(sprintf('tmp_%s',fN_R),sprintf('%s',fN_L)) %rename
    % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));

