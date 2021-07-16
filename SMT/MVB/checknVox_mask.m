%% L 70 is generaly 68/70voxels
roiName = 'PreCG_L_70.mat';
expected = 70;

roiName = 'PreCG_R_70.mat';
expected = 70;

roiName = 'PreCG_L_70&PreCG_R_70.mat';
expected = 140;

%% 35 is ok
% roiName = 'PreCG_L_35.mat';
% expected = 35;
% 
% roiName = 'PreCG_R_35.mat';
% expected = 35;
% 
% roiName = 'PreCG_L_35&PreCG_R_35.mat';
% expected = 70;


%main code
load('CCIDList.mat')
for s = 1:length(CCIDList)
  
  load(fullfile('data',CCIDList{s},[CCIDList{s},'_',roiName]),'selXYZmm');
  nVox(s) = length(selXYZmm);
  
end
% disp(nVox);
idx = nVox ~= expected;
disp(find(idx));
disp(nVox(idx));

age(idx)