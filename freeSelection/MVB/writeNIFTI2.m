function writeNIFTI2(ROIoN,mni,templateName)

% Suppose your n MNI coordinates are saved in a 3xn matrix called mni.
% (This is essential (not the name, but the format of 3xn), otherwise the
% steps below won't work).
%https://blogs.warwick.ac.uk/nichols/entry/spm2_gem_10/ 

%EK - Technically non-mni coords will work providing mask/vol are aligned.


% 1. Create an spm_vol handle to the image, that you determined the
%    coordinates from
% 
   Vin = spm_vol(templateName);
% 
% 2. Read the information in the image. (The data are not needed, this is
%    done purely for the purpose of setting up a matrix of voxel coordinates.
% 
    [Y,XYZ] = spm_read_vols(Vin);
% 
% 3. Setup a matrix of zeros in the dimensions of the input image
% 
   mask = zeros(Vin.dim(1:3));
% 
% 4. Now loop over all voxels in your mni variable and set the corresponding
%    location in the mask matrix to 1:

   for v = 1:size(mni,2)
      mask(find(XYZ(1,:)==mni(1,v)&XYZ(2,:)==mni(2,v)&XYZ(3,:)==mni(3,v))) = 1;
   end

% 5. Setup an spm_vol output file handle and change the filename
% 
   Vout = Vin;
   Vout.fname = ROIoN;
% 
% 6. Finally, write the new mask to the output file.
% 
   spm_write_vol(Vout,mask); 


   %spm_check_registration('/imaging/ek03/single_subj_T1.nii',ROIoN)
   
   
   