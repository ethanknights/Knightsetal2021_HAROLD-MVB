%% Purpose: Write 'data.csv' to RDir containing the full dataset 
%% i.e. unvivariate, behaviour & MVB (& MVPA for Free Selection Version)
%% Note - each analysis has a 'data.csv' in an different RDir/<subFolder>
%% e.g.
%% RDir/70-voxels_model-sparse
%% RDir/70-voxels_model-smooth  
%% RDir/70-voxels_model-sparse_controlVoxelSize
%%
%% flag_dropMVBSubjects = 1 (exclude subjects who fail MVB decoding from all analyses) | 0 (dont exclude these subjects at all, even in MVB)

clear

%% Ensure 'data.csv' saved to a sensible R/<subFolder> with appropriate data

flag_dropMVBSubjects = 0;

% %% 001 - RDir/70-voxels_model-sparse
% RDirSubFolder = '70voxel_model-sparse';
% ROINames = {'PreCG_L_70','PreCG_R_70','PreCG_L_70&PreCG_R_70'};
% model = 'sparse'; % 'sparse' | 'smooth'

%% 002 - RDir/70-voxels_model-sparse_controlVoxelSize-constrictBilateral
RDirSubFolder = '70voxel_model-sparse_controlVoxelSize-constrictBilateral';
ROINames = {'PreCG_L_70','PreCG_R_70','PreCG_L_35&PreCG_R_35'};
model = 'sparse'; % 'sparse' | 'smooth'
% 
%% 003 - RDir/70-voxels_model-sparse_controlVoxelSize-enlargeContralateral
% RDirSubFolder = '70voxel_model-sparse_controlVoxelSize-enlargeContralateral';
% ROINames = {'PreCG_L_140','PreCG_R_70','PreCG_L_70&PreCG_R_70'};
% model = 'sparse'; % 'sparse' | 'smooth'

% % % %% 004 - JUNK - TEST p VALUE FOR SHUFFLEDMVB WITH SMOOTH PRIOR -  coudlnt decode in anyone
% % % RDirSubFolder = 'junk';
% % % ROINames = {'PreCG_L_70','PreCG_R_70','PreCG_L_70&PreCG_R_70'};
% % % model = 'smooth'; % 'sparse' | 'smooth'

%Main code
%==========================================================================
RDir = fullfile('R',sprintf('dropMVBSubjects-%d',flag_dropMVBSubjects),RDirSubFolder,'csv');
mkdir(RDir)

univariateDir = fullfile('..','pp'); %for grabbing data 
load('CCIDList.mat','CCIDList','age');

%1 - Gather all main data (regardless of exclusion criteria)

%--- Age ---%
%zscore and then meancorrect to match Alexa:
agez = zscore(age);
age0z = agez - mean(agez);

%--- Gender ---%
I = LoadSubIDs;
for s = 1:length(CCIDList)
  idx = contain(CCIDList{s},I.SubCCIDc);
  genderC(s) = I.Genderc(idx);
  genderNum(s) = I.GenderNum(idx);
end
genderC = genderC';
genderNum = genderNum';

%--- get in-scanner RT ---%
[inScanner_RTmean,inScanner_RTsd,inScanner_RTidxToExclude] = getRT_FreeSelection_descriptives(CCIDList);


%--- get out-of-scanner RT ---%
[outScanner_RTmean,outScanner_RTsd,outScanner_RTidxToExclude] = getRT_behav_CRT_descriptives(CCIDList);


%--- univariate response ---%
hemiStr = {'L','R'};
for r = 1:2
  meanD = [];
  
  load(fullfile(univariateDir,'data','singleTrialBetas',sprintf('singleTrial-beta_ROI-%s_method-LSS.mat',ROINames{r})), ...
    'beta');
  for s = 1:length(beta)
    meanD(s) = mean(mean(cell2mat(beta{s}(1:3)'),2)); %total mean activation (no catch)
  end
  
  meanD = meanD';
  eval(sprintf('univariateMean_%s = meanD;',hemiStr{r}));
  
end

%zscore and then meancorrect for the RT ~ Activation * Age analysis:
%LH
univariateMean_L_z = zscore(univariateMean_L);
univariateMean_L_0z = univariateMean_L_z - mean(univariateMean_L_z);

%RH
univariateMean_R_z = zscore(univariateMean_R);
univariateMean_R_0z = univariateMean_R_z - mean(univariateMean_R_z);


%--- MVB decoding mapping: Bilateral ---%
groupFvals = [];
for s = 1:length(CCIDList)
  load(sprintf('data/%s/MVB_%s_con1_Action-Baseline_model-%s.mat',CCIDList{s},ROINames{3},model),'MVB');
  groupFvals(s) = MVB.Fvals;
end
groupFvals = groupFvals';
% mean(groupFvals) ; median(groupFvals)
% [H,P,CI,STATS] = ttest(groupFvals,3,'tail','right')
% [P,H] = signtest(groupFvals,3,'alpha',0.05,'tail','right') %Non-parametric
% figure('Position',[10 10 900 600]),hist(groupFvals,30);
idx_couldNotDecode = groupFvals < 3; %to exclude from boost analysis


%--- MVB: Get voxel weights' spread  ---%
for s = 1:length(CCIDList)
  
  CCID = CCIDList{s};
  
  for r = 1:length(ROINames)
    
    fN = sprintf('data/%s/MVB_%s_con1_Action-Baseline_model-%s.mat',CCID,ROINames{r},model);
    load(fN,'MVB');
    spread(s,r) = getMVBWeights(MVB);
    
  end
end
spread_LH = spread(:,1);
spread_RH = spread(:,2);
spread_Bi = spread(:,3);


%--- Boost Analysis ---%
%- Assign each subject as boost/equivalent/reduction for L vs L&R
%i.e. does a model including RH, boost decoding? -%

ordy = [];
for s = 1:length(CCIDList)
  CCID = CCIDList{s};
  
  fN = sprintf('data/%s/MVB_%s_con1_Action-Baseline_model-%s.mat',CCID,ROINames{1},model);
  load(fN,'MVB');
  F_L(s) = max(MVB.M.F(2:end) - MVB.M.F(1));
  
  fN = sprintf('data/%s/MVB_%s_con1_Action-Baseline_model-%s.mat',CCID,ROINames{3},model);
  load(fN,'MVB');
  F_Bi(s) = max(MVB.M.F(2:end) - MVB.M.F(1));
  
  F_diff(s) = F_Bi(s) - F_L(s);
  
  %Use same order as Alexa. i.e. Boost > equiv > reduction
  if F_diff(s) > 3
    ordy(s) = 2; % > 3: 2
  elseif F_diff(s) < -3
    ordy(s) = 0; % < -3: 0
  else
    ordy(s) = 1;  % == 3: 1
  end
end
ordy = ordy';


%% MVPA
MVPA_L_4way = [];
fN = fullfile(univariateDir,'data','MVPA_matlab_leave1RunOut',sprintf('decAcc_classify-4Way_ROI-%s_method-LSS.mat',ROINames{1}));
load(fN,'decAccBal','confMat');
MVPA_L_4way = decAccBal';
confMat_L_4way = confMat;

MVPA_R_4way = [];
fN = fullfile(univariateDir,'data','MVPA_matlab_leave1RunOut',sprintf('decAcc_classify-4Way_ROI-%s_method-LSS.mat',ROINames{2}));
load(fN,'decAccBal','confMat');
MVPA_R_4way = decAccBal';
confMat_R_4way = confMat;

MVPA_Bi_4way = [];
fN = fullfile(univariateDir,'data','MVPA_matlab_leave1RunOut',sprintf('decAcc_classify-4Way_ROI-%s_method-LSS.mat',ROINames{3}));
load(fN,'decAccBal','confMat');
MVPA_Bi_4way = decAccBal';
confMat_Bi_4way = confMat;

d = table(CCIDList,age,agez,age0z,genderC,genderNum, ...
inScanner_RTmean,inScanner_RTsd,inScanner_RTidxToExclude, ...
outScanner_RTmean,outScanner_RTsd,outScanner_RTidxToExclude, ...
univariateMean_L,univariateMean_R, ...
univariateMean_L_z,univariateMean_R_z, ...
univariateMean_L_0z,univariateMean_R_0z, ...
groupFvals,idx_couldNotDecode, ...
spread_LH,spread_RH,spread_Bi, ...
spread_LH,spread_RH,spread_Bi, ...
MVPA_L_4way,MVPA_R_4way,MVPA_Bi_4way, ...
ordy);


%2 - Exclude subjects and print some descriptives for methods
%Note we are removing subjects in the order of the analyses (e.g.
%a sub lost for RT in scanner, is now gone when we look at RT out of
%scanner and then for MVB

%% Note - still not updated confusionMatrices (but probly pointless)

%How many subs?
fprintf('all subs with SMT task %d' , height(d))


%Print starting sample age mean/sd/range and gender balance
fprintf('min age = %d, max age = %d, number of females = %d',...
   min(d.age),max(d.age),sum(d.genderNum == 2))
mean(d.age)
std(d.age)
height(d)
100/height(d) * sum(d.genderNum == 2)



%Who has no RT inscanner measure?
idx = isnan(d.inScanner_RTmean);
fprintf('\n%d dropped for no inscanner RT\n', sum(idx));
d(idx,:) = [];


%Who has no RT outscanner measure?
idx = isnan(d.outScanner_RTmean);
fprintf('\n%d dropped for no outscanner RT\n', sum(idx));
d(idx,:) = [];


%Who has > 10% no responses inscanner?
idx = logical(d.inScanner_RTidxToExclude);
fprintf('\n%d dropped for >10percent errors inscanner\n', sum(idx));
d(idx,:) = [];


%Who has > 10% no responses outscanner?
idx = logical(d.outScanner_RTidxToExclude);
fprintf('\n%d dropped for >10percent errors outscanner\n', sum(idx));
d(idx,:) = [];


%Get stats for MVB decoding (before we exclude those who fail):
groupFvals = d.groupFvals;
% mean(groupFvals) ; median(groupFvals)
[H,P,CI,STATS] = ttest(groupFvals,3,'tail','right')
% [P,H] = signtest(groupFvals,3,'alpha',0.05,'tail','right') %Non-parametric
% figure('Position',[10 10 900 600]),hist(groupFvals,30);
extrad = table(d.age,d.groupFvals); extrad.Properties.VariableNames = {'age','Log'};
writetable(extrad,fullfile(RDir,'extradata_ShuffledGroupFVals.csv'));


%Who has failed MVB decoding (bilateral model)?
if flag_dropMVBSubjects
  idx = logical(d.idx_couldNotDecode)
  fprintf('\n%d dropped for failed decoding\n', sum(idx));
  d(idx,:) = [];
end


%Print final sample age mean/sd/range and gender balance
fprintf('min age = %d, max age = %d, number of females = %d',...
   min(d.age),max(d.age),sum(d.genderNum == 2))
mean(d.age)
std(d.age)
height(d)
100/height(d) * sum(d.genderNum == 2)




%3 Write csv for R analysis
writetable(d,fullfile(RDir,'data.csv'));


