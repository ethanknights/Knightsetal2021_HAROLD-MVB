%Purpose:
%HAROLD Free Selection Task -
%Performs preprocessing, defines ROI based on voxelwise univariate group GPLM
%And extracts univariate response

clear

spmDir = '/imaging/henson/users/ek03/toolbox/SPM12_v7219';
if any(ismember(regexp(path,pathsep,'Split'),spmDir)); else; addpath(spmDir);
  spm('Defaults','fMRI'); spm_jobman('initcfg'); end 

% delete(gcp('nocreate')) %removes a previously active pool
% NumWorkers = 24;
% P = cbupool(NumWorkers);
% P.SubmitArguments = sprintf('--ntasks=%d --mem-per-cpu=4G --time=72:00:00',NumWorkers);
% parpool(P,NumWorkers)



%==================================
%% Preliminaries
%==================================


%% Symlinks to aa_norm_write_dartel_masked/rp's + CCIDList
done_setupDirs = 1;
if ~done_setupDirs
  setupDirs
end
%New Output:
%data/aa_norm_write_dartel_masked
%data/aa_rp
%CCIDList.mat %includes onsets

done_preprocess_compSignal_AND_smooth = 1;
if ~done_preprocess_compSignal_AND_smooth
  preprocess_compSignal
  preprocess_smooth
end
%data/compSignal
%data/confoundMat
%data/aa_norm_write_dartel/CC110033/smswaufMR10033_CC110033-0006.nii

%% Create first-level model + contrasts (action > baseline)
done_firstLevelModels = 1;
if ~done_firstLevelModels
  firstLevelModels
end
%New Output:
%data/firstLevelModel_smooth
%data/firstLevelModel_waveletdespike


%% Create second-level model (smoothed data) + contrasts (action > baseline, age +)
done_groupGLM = 1;
if ~done_groupGLM
  groupGLM
end
%New Output:
%data/groupModel_smooth


% %% Create ROIs with smoothed data groupGLM
done_createROI = 1;
if ~done_createROI
  %  fprintf('Do this manually!:\n\n edit createROI \n\n')
  !cp /imaging/ek03/projects/HAROLD/SMT/pp/PreCG_*.nii ./
end

% %% Also create spheres in ventricle (marsbar)
% done_createROIVentricle = 1;
% if ~done_createROIVentricle
%   marsbar_roi_sphere(pwd,5,[-8,-8,21],'Ventricle_L_5mm.nii','delete Mat'); %LH
%   marsbar_roi_sphere(pwd,5,[8,-8,21], 'Ventricle_R_5mm.nii','delete Mat');  %RH
% end



%==================================
%% Ready now
%==================================

%% Extract data from ROIs (not smoothed data)
%% Perform MVPA %!! not in this experiment !!
done_extractROI = 0;
done_MVPA = 0; %!! not in this experiment !!
if ~done_extractROI || ~done_MVPA
  
  %-Setup-%
  nCond = 4;
  %method = {'LSA','LSS'};
  method = 'LSS';
  
  roifN = { ...
    'PreCG_L_70.nii',      ...
    'PreCG_R_70.nii',      ...
    'PreCG_L_35.nii',      ... 35+35 = 70 for ordy
    'PreCG_R_35.nii',      ... 35+35 = 70 for ordy
    'PreCG_L_70&PreCG_R_70.nii',      ... for MVPA
    'PreCG_L_140.nii',                ... for MVPA: enlarge contralateral
    'PreCG_L_35&PreCG_R_35.nii',      ... for MVPA: constrict bilateral
    'SMA_L_70.nii',      ...
    'SMA_R_70.nii'
    };
  roiName = cellfun(@(x) x(1:end-4), roifN, 'Uniform', 0);  %cut '.nii'
  
  for r = 8:length(roiName)
    
    %--ROI Extraction--%
    fprintf('Processing roi # %s\n%s\n\n',num2str(r),roifN{r})
    
    if done_extractROI == 0
      extractROI_fMRI_multitrial_GLMs_singleROI(roifN{r},roiName{r},nCond,method);
    end
    
    
    %--MVPA--%
    fprintf('classify4Way\n')
    if ~exist(sprintf('decAcc_ROI-%s_.mat',roiName{r}))
      in = sprintf('singleTrial-beta_ROI-%s_method-%s.mat',roiName{r},method)
      out = sprintf('decAcc_classify-4Way_ROI-%s_method-%s.mat',roiName{r},method)
      %classify_run(in,out,fullfile('data','MVPA_matlab')); %default cross validation cifcoec
      
      classify_run2(in,out,fullfile('data','MVPA_matlab_leave1RunOut')); %manual leave-1-(artificial)-run-out (4 folds as 8 too many or no trials on some labels)
    end
    
    %         in = sprintf('singleTrial-beta_ROI-%s_method-%s.mat',roiName{r},method);
    %         out = sprintf('singleTrial-beta_classify-4Way_ROI-%s_method-%s.csv',roiName{r},method);
    %         writeOutBetacsv(in,out,fullfile('data','MVPA_python'))
  end
end


return










%==========================================================================
%POSTPROCESSING
%==========================================================================
load('CCIDList.mat','CCIDList','age','fNs','trialInfo');
cd data/singleTrialBetas
%------------ ROI Univariate Activation -------------%
%beta{1}:
% {'AudVid1200'}
% {'AudVid600'}
% {'AudVid300'}
% {'AudOnly'}: Catch
% {'VidOnly'}: Catch

% close all

%-- Quick check 1 ROI --%
%fN = 'singleTrial-beta_ROI-PreCG_L_500_method-LSS.mat'
%fN = 'singleTrial-beta_ROI-PreCG_R_500_method-LSS.mat'
fN = 'singleTrial-beta_ROI-PreCG_L_70_method-LSS.mat'
fN = 'singleTrial-beta_ROI-PreCG_R_70_method-LSS.mat'
fN = 'singleTrial-beta_ROI-PreCG_L_35_method-LSS.mat'
fN = 'singleTrial-beta_ROI-PreCG_R_35_method-LSS.mat'
% fN = 'singleTrial-beta_ROI-Ventricle_L_6mm_method-LSS.mat'
% fN = 'singleTrial-beta_ROI-Ventricle_R_6mm_method-LSS.mat'
% fN = 'singleTrial-beta_ROI-AgeEffect_PreCG_L_5mm_method-LSS.mat'
% fN = 'singleTrial-beta_ROI-AgeEffect_PreCG_R_5mm_method-LSS.mat'
%fN = 'data/singleTrialBetas/singleTrial-beta_ROI-test_method-LSS.mat'
fN = 'singleTrial-beta_ROI-freeSelection_actionBIGBaseline_PreCG_L_70_method-LSS.mat'
fN = 'singleTrial-beta_ROI-freeSelection_actionBIGBaseline_flipped_PreCG_R_70_method-LSS.mat'

meanD = [];
% fN = fullfile(dwd,'singleTrialBeta',fN);
load(fN,'beta');
for s = 1:length(beta)
  meanD(s) = mean(mean(cell2mat(beta{s}'),2)); %total mean activation
end
meanD = meanD';

%-Violin Plots of mean Activity-%
ylimits = [-0.2,0.2];

figure('position',[600,600,600,600]) %Main Trials
violinplot(meanD); ylim(ylimits); xticklabels({'mean all fingers'});
line([0,2],[0,0],'color','black','LineWidth',2,'LineStyle','--')
title(fN)

%- Correlation with age -%
[mdl,pMdl,fMdl] = plotRegression(meanD,age,'MeanActivation','Age',nan,fN)


%-Check >1 ROI-%
meanD = [];
for r = 1:length(roiName)
  fN = sprintf('data/singleTrialBetas/singleTrial-beta_ROI-%s_method-%s.mat',roiName{r},method);
  load(fN,'beta');
  for s = 1:length(beta)
    meanD(s,r) = mean(mean(cell2mat(beta{s}'),2)); %total mean activation (no catch)
  end
end
%-Violin Plots of mean Activity-%
ylimits = [-0.2,0.2];

figure('position',[600,600,600,600]) %Main Trials
violinplot(meanD); ylim(ylimits); xticklabels(roiName)
line([0,length(roiName)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')





%%%%% MVPA - Quick Check %%%%%
load CCIDList.mat

cd data/MVPA_matlab
cd data/MVPA_matlab_leave1RunOut

fN = 'decAcc_classify-4Way_ROI-PreCG_L_70_method-LSS.mat';
fN = 'decAcc_classify-4Way_ROI-PreCG_R_70_method-LSS.mat';

fN = 'decAcc_classify-4Way_ROI-PreCG_L_35_method-LSS.mat';
fN = 'decAcc_classify-4Way_ROI-PreCG_R_35_method-LSS.mat';

load(fN)
mean(decAccBal)

[h,p,ci,stats] = ttest(decAccBal,0.25,'tail','right')
[p, h, stats] = signtest(decAccBal,0.25,'tail','right')
figure, violinplot(decAccBal); ylimits = [0,0.5]; ylim(ylimits);
line([0,2],[0.25,0.25], 'linestyle','--', 'color', 'black')

plotRegression(decAccBal',age);
line([0,100],[0.25,0.25], 'linestyle','--', 'color', 'black')

groupConfMat = sum(confMat.raw,3) .* 100/sum(sum(sum(confMat.raw,3)))
figure, imagesc(groupConfMat); colorbar
colorbar; colormap 'autumn'

%extra confusion matrix: split into 3 (rough!) age groups
tert_groupConfMat(:,:,1) = sum(confMat.raw(:,:,1:29),3) .* 100/sum(sum(sum(confMat.raw(:,:,1:29),3)))
tert_groupConfMat(:,:,2) = sum(confMat.raw(:,:,30:58),3) .* 100/sum(sum(sum(confMat.raw(:,:,30:50),3)))
tert_groupConfMat(:,:,3) = sum(confMat.raw(:,:,59:87),3) .* 100/sum(sum(sum(confMat.raw(:,:,59:87),3)))
figure
clims = [0 12]; 
p = subplot(1,3,1),imagesc(tert_groupConfMat(:,:,1),clims), title('YA'), p.TickLength = [0 0]; 
p = subplot(1,3,2),imagesc(tert_groupConfMat(:,:,2),clims), title('ML'), p.TickLength = [0 0];
p = subplot(1,3,3),imagesc(tert_groupConfMat(:,:,3),clims), title('OA'), p.TickLength = [0 0];
colorbar; colormap 'autumn'