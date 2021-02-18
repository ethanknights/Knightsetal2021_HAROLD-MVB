
cd data/groupModel_smooth/

%NOTE FOR FREESELECTION THE ROI IS PMd (not really precg)

%% First we will try with orthogonal contrast to the age effect (0 1)
%===================================
%% Choose Voxel Sizes here (500 (arbitrary large) or 70 (same size as ventricle):
fN_L = 'freeSelection_actionBIGBaseline_PreCG_L_70.nii';
fN_R = 'freeSelection_actionBIGBaseline_flipped_PreCG_R_70.nii';
% fN_L = 'PreCG_L_70.nii';
% fN_R = 'PreCG_R_70.nii';

%--LEFT PRECG 1 0 (all action > baseline) --%
% SMT PreCG = -36 -18 54 %Move spm cursor to these coords and run the correct vox:
% FreeSelection PreCG (local maxima to SMT PRECG) = -33 -15 54 THIS DOESNT WORK AS IT SELECTS PMd
% FreeSelection Peak of All > Baseline = -39 -30 42 (More like S2)
% spm2roi(500,hReg,xSPM,fN_L(1:end-4)) %no '.nii'
% spm2roi(70,hReg,xSPM,fN_L(1:end-4)) %no '.nii'


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

    
    
%===============================
%Supplementary Analysis - Second we stack cards in favour of HAROLD and
%test for compensation with a Ipsilateral Age effect ROI and mirror flip that
fN_R = 'AgeEffect_PreCG_R_500.nii';
fN_L = 'AgeEffect_PreCG_L_500.nii';
fN_R = 'AgeEffect_PreCG_R_70.nii';
fN_L = 'AgeEffect_PreCG_L_70.nii';

%-RIGHT-%
%39 -15 57
% spm2roi(500,hReg,xSPM,fN_R(1:end-4)) %no '.nii'
% spm2roi(70,hReg,xSPM,fN_R(1:end-4)) %no '.nii'


%-LEFT (MIRROR FLIP-%
matlabbatch = [];
matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN_R)};
matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip SAME FOR R-L
matlabbatch{1}.spm.util.reorient.prefix = 'right_';
spm_jobman('run',matlabbatch);
movefile(sprintf('right_%s',fN_R),sprintf('%s',fN_L)) %rename
     % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));

%Also copy them to analysis rootdir for simplifying paths
% !cp PreCG_L_500.nii /imaging/ek03/projects/HAROLD/SMT/pp/
% !cp PreCG_R_500.nii /imaging/ek03/projects/HAROLD/SMT/pp/ 
% !cp AgeEffect_PreCG_R_500.nii /imaging/ek03/projects/HAROLD/SMT/pp/
% !cp AgeEffect_PreCG_L_500.nii /imaging/ek03/projects/HAROLD/SMT/pp/

return

%Could try check roi is ok but this is misleading if e.g.
%comparing L/R for a single subject based on full timeseries (not events):
%Better check is the spm_check_reg above and the groups L vs R from
%extractROI_fMRI_multitrialGLM.m (see bottom of wrapper.m)
%
%But if you really want:
%ROI EXTRACTION (based on roi_extract.m)
% fN_R = 'PreCG_R_500.nii';
roifN = fN_L;
roifN = fN_R;

CCIDList = {'CC110033'};
s=1
CCID = CCIDList{s}

VY = spm_vol(cellstr(spm_select('ExtFPList',sprintf('/imaging/ek03/projects/HAROLD/SMT/pp/data/aa_waveletdespike/%s/',CCID),'mswau')));
VY = [VY{:}];
Yinv = inv(VY(1).mat); % Get inverse transform (assumes all data files are aligned)

[VM,mXYZmm] = spm_read_vols(spm_vol(roifN));

% Transform ROI XYZ in mm to voxel indices in data:
yXYZind = Yinv(1:3,1:3)*mXYZmm + repmat(Yinv(1:3,4),1,size(mXYZmm,2));

f = find(VM);
d = spm_get_data(VY,yXYZind(:,f));
mean(mean(d,2))

d_L = d;

d_R = d;

mean(mean(d_L,2)) 
mean(mean(d_R,2))
[mean(mean(d_L,2)),mean(mean(d_R,2))]

d = [d_L',d_R']'



%==================
%Create a 1000 vox roi using method 1 (aciton > baseline cotnralateral ROI and flip)
%===================================
% %First we will try with orthogonal contrast to the age effect (0 1)
fN_L = 'PreCG_L_250.nii';
fN_R = 'PreCG_R_250.nii';

%--LEFT PRECG 1 0 (all action > baseline) --%
% %-36 -18 54
% spm2roi(250,hReg,xSPM,fN_L(1:end-4)) %no '.nii'

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

    
    
    
    
    
    
    
    
    
    

%==================================================================
%OLD STUFF DONT DELETE FOR NOW

%Purpose: Create group ROI from blob at the current SPM12 results viewer position.
%Manually load results & nav to nearest maxima FWE
%Results file Contrast Age + in : data/groupGLM/SPM.mat

% dwd = 'data/groupGLM';
% cd(dwd)

%--LEFT PRECG 1 0 (all action > baseline) --%
% %First we will try with orthogonal contrast to the age effect (0 1)
% %-36 -18 54
% fN_L = 'PreCG_L_500.nii';
% spm2roi(500,hReg,xSPM,fN_L(1:end-4)) %no '.nii'
% 
% %--RIGHT PRECG Mirror Flip LEFT --%
% fN_R = 'PreCG_R_500.nii';
% 
% %- Flip with FSL -%
% copyfile(fN_L,fN_R)
% cmdStr = sprintf('fslswapdim %s -x y z %s',fN_R,fN_R)
% system(cmdStr); 
%     % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
% 
% 
% 
% %- Flip with FSL -%
% copyfile(fN_L,fN_R)
% cmdStr = sprintf('fslorient -swaporient %s',fN_R)
% system(cmdStr); 
%     % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
% 
% 
% 
% % %%%Right Motor cortex 
% %%Flip the L_MC 100vox
% matlabbatch = [];
% matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN_L)};
% matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
% matlabbatch{1}.spm.util.reorient.prefix = 'right_';
% spm_jobman('run',matlabbatch);
% movefile(sprintf('right_%s',fN_L),sprintf('%s',fN_R)) %rename
%     % spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
% 
% 
%         %%get roi XYZ coords
%         roifN = fN_L;
%         roifN = fN_R;
%          
%         V = spm_vol(roifN);
%         Y = spm_read_vols(V);
%         idx = find(Y>0);
%         [x,y,z] = ind2sub(size(Y),idx);
%         XYZ = [x y z]';
%         %get roi timeseries
%         scanfN = 'allBIGBaseline.nii';
%         d = spm_get_data(spm_vol(scanfN),XYZ);
%             %write nifti to check
%             writeNIFTI('myROI.nii',XYZ,'/imaging/ek03/MVB/FreeSelection/pp/data/statsGroupAllBIGBaseline/Mc_L_100vox.nii')
%             spm_check_registration('myROI.nii','/imaging/ek03/single_subj_T1.nii')
%             
% 
% 
% 
%     %-- 2 Checks that SPM recognises header flip --%
%     %-1. Visual Check-%
%     %spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
% 
%     %-2. SPM recognises flip (i.e. Different data & mean activity L > R-)%
%     data_VY = spm_vol('allBIGBaseline.nii'); %to get data from
%     
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(fN_L);
%     d_L = spm_get_data(VY,yXYZind(:,f));
%     
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(fN_R);
%     d_R = spm_get_data(VY,yXYZind(:,f));
%             
%     d=[d_L',d_R']'   
%     
%     
% %- Flip with FSL -%
% copyfile(sprintf('%s',fN_L),sprintf('%s',fN_R))
% cmdStr = sprintf('fslorient -swaporient %s',fN_R)
% system(cmdStr); 
%     %-- 2 Checks that SPM recognises header flip --%
%     %-1. Visual Check-%
%     %spm_check_registration(sprintf('%s',fN_L),sprintf('%s',fN_R));
% 
%     %-2. rewrite L&R images using spm_vol coords-%
%     %based roi_extract.m
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(sprintf('%s',fN_L));
%     VY = spm_vol('allBIGBaseline.nii')
%     d_L = spm_get_data(VY,yXYZind(:,f));
%     
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(sprintf('%s',fN_R));
%     VY = spm_vol('allBIGBaseline.nii')
%     d_R = spm_get_data(VY,yXYZind(:,f));
%             
%     d=[d_L',d_R']'   
%             
%     %-2. rewrite L&R images using spm_vol coords-%
%     %based roi_extract.m
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(sprintf('%s',fN_L));
%     coords_L = yXYZind(:,f);
% 
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(sprintf('%s',fN_R));
%     coords_R = yXYZind(:,f);
% 
%     writeROItoNII('test_L.nii',coords_L,sprintf('%s',fN_L))
%     writeROItoNII('test_R.nii',coords_R,sprintf('%s',fN_R))
%     
%     [VY,Yinv,VM,mXYZmm,yXYZind,f] = readROI(sprintf('test_R.nii'));
%     coords_R2 = yXYZind(:,f);
% 
% 
%     
% 
% 
% 
% 
% % roifN = 'data/groupGLM/PreCG_L_500.nii';
% % %Based on roi_extract.m
% % VY = spm_vol(roifN)
% % Yinv = inv(VY(1).mat); % Get inverse transform
% % 
% % [VM,mXYZmm] = spm_read_vols(spm_vol(roifN));
% % 
% % % Transform ROI XYZ in mm to voxel indices in data:
% % yXYZind = Yinv(1:3,1:3)*mXYZmm + repmat(Yinv(1:3,4),1,size(mXYZmm,2));
% % f = find(VM);
% % 
% % %Flip x sign for L to R
% % new_yXYZind = [];
% % tmp = yXYZind(:,f); %which row is x? min(tmp(1,:)) min(tmp(2,:)) min(tmp(3,:)) %must be 2!
% 
% 
% 
% 
% 
% 
% %RIGHT PRECG - HAROLD
% %39 -15 57 (with normal correction)
% spm2roi(500,hReg,xSPM,'PreCG_R_500')
% 
% %LEFT PRECG - MIRROR FLIP but use F Contrast with Lower threshold so its
% %active enough to create an ROI
% %-39 -15 57 
% spm2roi(500,hReg,xSPM,'PreCG_L_500')




