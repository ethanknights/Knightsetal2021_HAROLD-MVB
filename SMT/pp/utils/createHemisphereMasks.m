%% createHemisphereMasks for Left and then right, as to define SMA in only one hemisphere
%% Output is roi_l.nii and roi_r.nii
cd ../
mkdir data/masks_hemisphere
cd data/masks_hemisphere
!cp /imaging/henson/users/ek03/toolbox/SPM12_v7219/tpm/mask_ICV.nii ./
!cp mask_ICV.nii roi.nii

%% FSL METHOD
%% FROM: https://www.jiscmail.ac.uk/cgi-bin/webadmin?A3=ind1208&L=SPM&E=base64&P=74566&B=------_%3D_NextPart_001_01CD7021.6963CFB9&T=text%2Fhtml;%20charset=utf-8&pending=
%% image dims
!fslsize roi.nii
splitVal = num2str(floor(121/2)) %60 %not going to be perfect as odd X!

%% create mask (roi_l.nii & roi_r.nii)
!fslroi roi.nii roi_r.nii 0 60 0 145 0 121

!fslroi roi.nii roi_l.nii 60 60 0 145 0 121

!fslmaths roi_r.nii -mul 0 roi_null.nii

!fslmerge -x roi_r.nii roi_r.nii roi_null.nii

!fslmerge -x roi_l.nii roi_null.nii roi_l.nii

!gunzip *.gz

%% SPM METHOD
% fN = 'mask_ICV.nii';
% V = spm_vol(fN);
% y = spm_read_vols(V);
%%TBC


%%%%%%%%%% 2 
mkdir v2
cd v2

%% FSL METHOD
%splitVal = num2str(floor(121/2)) %60 %not going to be perfect as odd X!
%%Lets be stricter to prevent overlap: 57

%% create mask (roi_l.nii & roi_r.nii)
!fslroi roi.nii roi_r.nii 0 57 0 145 0 121

!fslroi roi.nii roi_l.nii 57 57 0 145 0 121

!fslmaths roi_r.nii -mul 0 roi_null.nii

!fslmerge -x roi_r.nii roi_r.nii roi_null.nii

!fslmerge -x roi_l.nii roi_null.nii roi_l.nii

!gunzip *.gz