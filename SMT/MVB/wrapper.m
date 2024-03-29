%Purpose:
%Run MVB for Action vs Baseline in SMT Task

%==========================================================================
%  Dir Setup - Do Once
%==========================================================================
%-SPM betas-%
% mkdir data
% cd data
% !lndir.sh /imaging/henson/users/ek03/projects/HAROLD/SMT/pp/data/firstLevelModel ./
%-subInfo-%
% cd ../
% !cp /imaging/henson/users/ek03/projects/HAROLD/SMT/pp/CCIDList.mat ./
%
%-ROIs-%
% !cp /imaging/henson/users/ek03/projects/HAROLD/SMT/pp/*.nii ./
%
%
%-Restart analysis -%
% !rm -vvf data/CC*/MVB_*
% !rm -vvf data/CC*/*.ps

%==========================================================================
%  Paths/Var Setup
%==========================================================================

clear

qSPM % par(64)

load('CCIDList.mat','CCIDList')

done_createXYZ = 1;
done_MVB = 0;

%==========================================================================
% Setup ROIs
%==========================================================================
%--------- Roi pairs to work with (L/R)  ----------%
roifN = {'PreCG_L_70.nii',              ... %SMT Group ROI Action > Basesline
         'PreCG_R_70.nii',              ... %^^ L-R Flipped 
         'PreCG_L_35.nii',              ... %To control voxel size for ordy (35+35 = 70)
         'PreCG_R_35.nii',              ... %^^
           'SMA_L_70.nii',              ... %SMT Group ROI Action > Basesline (masked Left Hemi)
           'SMA_R_70.nii',              ...  %^^ L-R Flipped
           'SMA_L_35.nii',              ... %To control voxel size for ordy (35+35 = 70)
           'SMA_R_35.nii',              ... %To control voxel size for ordy (35+35 = 70)
};
roiName = cellfun(@(x) x(1:end-4), roifN, 'Uniform', 0);  %cut '.nii'
roiPairs = [1,2;3,4;5,6;7,8]; %[1,2;3,4]; %etc

if ~done_createXYZ
  camcan_main_mvb_makexyz
end

%==========================================================================
% Run MVB
%==========================================================================
conditions = {'Action-Baseline'}; %A name of contrast in a con image
contrasts = [1]; %the corresponding con image number
model = 'sparse';

if ~done_MVB
  for r = 3%:size(roiPairs,1) %rows
    for c = 1:length(contrasts)
    
    
      currROIs{1} = roiName{roiPairs(r,1)}; %LH
      currROIs{2} = roiName{roiPairs(r,2)}; %RH
      conditionName = conditions{c};
      con = contrasts(c);
    

      camcan_main_mvb_top(currROIs,conditionName,con,CCIDList,model);
          %tmp_controlVoxelSize_camcan_main_mvb_top(currROIs,conditionName,con,CCIDList,model);
    end
  end
end

return

%==========================================================================
% PostProcessing 
%==========================================================================
%  edit doPostProcessing.m


%% Check whose done
[a,b] = system('ls data/CC*/*PreCG*70*model-sparse.mat | wc -l'); fprintf('subs done: %d\n',floor(str2num(b)/3))
[a,b] = system('ls data/CC*/*PreCG*35*model-sparse.mat | wc -l'); fprintf('subs done: %d\n',floor(str2num(b)/3))
[a,b] = system('ls data/CC*/*SMA*70*model-sparse.mat | wc -l'); fprintf('subs done: %d\n',floor(str2num(b)/3))
[a,b] = system('ls data/CC*/*SMA*35*model-sparse.mat | wc -l'); fprintf('subs done: %d\n',floor(str2num(b)/3))
