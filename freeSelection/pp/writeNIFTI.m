function writeNIFTI(ROIoN,coords,templateName)

hdr = spm_vol(templateName);
img = spm_read_vols(hdr);
    
%strip data from template
for i = 1:size(img(:))
    img(i) = 0;
end

%paint coords
nVox = size(coords,2);
for i = 1:nVox
    y = coords(:,i);
    img(y(1),y(2),y(3)) = 1;
end

%rewrite .nii
hdr.fname = ROIoN;
spm_write_vol(hdr,img);
 
%spm_check_registration('/imaging/ek03/single_subj_T1.nii','myROI.nii','/imaging/ek03/MVB/FreeSelection/pp/data/statsGroupAllBIGBaseline/Mc_L_100vox.nii')

