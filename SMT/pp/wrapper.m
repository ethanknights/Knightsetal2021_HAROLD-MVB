%Purpose:
%HAROLD SMT Task -
%Performs preprocessing, defines ROI based on voxelwise univariate group GPLM
%And extracts univariate response to check for HAROLD effects

%Note:
%Voxelwise univariate effects (to define ROIs with contrasts) uses:
%- data/aa_norm_write_dartel_masked
%
%Extracting univariate responses for age regression (and MVB/MVPA) uses
%- data/aa_norm_write_dartel_masked 
%(i.e. from aa_release004/data_fMRI/aamod_wavelet_despiked, after 
%masking 'm*.nii' but before '_wds.nii')

clear

qSPM

%par(64)

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
%data/firstLevelModel
%data/firstLevelModel_smooth



%% Create second-level model (smoothed data) + contrasts (action > baseline, age +)
done_groupGLM = 1;
if ~done_groupGLM
  groupGLM
end
%New Output:
%data/groupModel_smooth


%% Create ROIs with smoothed data groupGLM
done_createROI = 1;
if ~done_createROI
  fprintf('Do this manually!:\n\n edit createROI \n\n')
end


%% Also create spheres in ventricle (marsbar) 
done_createROIVentricle = 1;
if ~done_createROIVentricle
  marsbar_roi_sphere(pwd,5,[-8,-8,21],'Ventricle_L_5mm.nii','delete Mat'); %LH
  marsbar_roi_sphere(pwd,5,[8,-8,21], 'Ventricle_R_5mm.nii','delete Mat'); %RH
end



%==================================
%% Ready now
%==================================

%% Extract data from ROIs (wds, not smoothed data)
%% Perform MVPA %!! not in this experiment !!
done_extractROI = 0;
done_MVPA = 1; %!! not in this experiment !!
if ~done_extractROI || ~done_MVPA
  
  %-Setup-%
  nCond = 5;
  %method = {'LSA','LSS'};
  method = 'LSS';
  %roiDir = 'data/groupModel_smooth';
  
  roifN = { ...
           'PreCG_L_70.nii',      ...
           'PreCG_R_70.nii',      ... 
           'PreCG_L_35.nii',      ... 35+35 = 70 for ordy
           'PreCG_R_35.nii',      ... 35+35 = 70 for ordy
           'Ventricle_L_5mm.nii',      ...
           'Ventricle_R_5mm.nii',      ...
           'SMA_L_70.nii',      ...
           'SMA_R_70.nii',      ... 
           };    
  roiName = cellfun(@(x) x(1:end-4), roifN, 'Uniform', 0);  %cut '.nii'  
  
  for r = 7:length(roiName)

    %--ROI Extraction--%
    fprintf('Processing roi # %s\n%s\n\n',num2str(r),roifN{r})
    
    if done_extractROI == 0
      extractROI_fMRI_multitrial_GLMs_singleROI(roifN{r},roiName{r},nCond,method);
    end

    %--MVPA--%
    %     fprintf('classify4Way\n')
    %     if ~exist(sprintf('decAcc_ROI-%s_.mat',roiName{r}))
    %         in = sprintf('singleTrial-beta_ROI-%s_method-%s.mat',roiName{r},method)
    %         out = sprintf('decAcc_classify-4Way_ROI-%s_method-%s.mat',roiName{r},method)
    %         classify_run(in,out);
    %     end
    %
    %     in = sprintf('singleTrial-beta_ROI-%s_method-%s.mat',roiName{r},method);
    %     out = sprintf('singleTrial-beta_classify-4Way_ROI-%s_method-%s.csv',roiName{r},method);
    %     writeOutBetacsv(in,out)
  end
end


return










%==========================================================================
%POSTPROCESSING
%==========================================================================

%------------ ROI Univariate Activation -------------%
%beta{1}:
% {'AudVid1200'}
% {'AudVid600'}
% {'AudVid300'}
% {'AudOnly'}: Catch
% {'VidOnly'}: Catch

% close all
load('CCIDList.mat','CCIDList','age','fNs','trialInfo');
%-- Quick check 1 ROI --%
cd data/singleTrialBetas/

fN = 'singleTrial-beta_ROI-PreCG_L_70_method-LSS.mat'
fN = 'singleTrial-beta_ROI-PreCG_R_70_method-LSS.mat'

fN = 'singleTrial-beta_ROI-PreCG_L_35_method-LSS.mat'
fN = 'singleTrial-beta_ROI-PreCG_R_35_method-LSS.mat'
fN = 'singleTrial-beta_ROI-Ventricle_L_5mm_method-LSS.mat'
fN = 'singleTrial-beta_ROI-Ventricle_R_5mm_method-LSS.mat' 
 
meanD = [];
meanD_catch = [];
meanD_all = [];
% fN = fullfile(dwd,'singleTrialBeta',fN);
load(fN,'beta');
for s = 1:length(beta)
  meanD(s) = mean(mean(cell2mat(beta{s}(1:3)'),2)); %total mean activation (no catch)
  meanD_catch(s) = mean(mean(cell2mat(beta{s}(4:5)'),2)); %total mean activation (catch no press supposedly)
  meanD_all(s) = mean(mean(cell2mat(beta{s}'),2)); %total mean activation (regardless condition)
end
meanD = meanD';
meanD_catch = meanD_catch';
meanD_all = meanD_all';

%-Violin Plots of mean Activity-%
ylimits = [-2,2];

% figure('position',[600,600,600,600]) %Main Trials
% violinplot(meanD); ylim(ylimits); xticklabels({'Bimodal'});
% line([0,2],[0,0],'color','black','LineWidth',2,'LineStyle','--')
% title(fN)

figure('position',[600,600,600,600]) %Main + Catch Only
violinplot([meanD,meanD_catch]); ylim(ylimits); xticklabels({'Bimodal','Unimodal'});
line([0,3],[0,0],'color','black','LineWidth',2,'LineStyle','--');
line([1,2],[mean(meanD),mean(meanD_catch)],'color','black','LineWidth',2,'LineStyle','-');
title(fN)

% figure('position',[600,600,600,600]) %Main + Catch Only + All
% violinplot([meanD,meanD_catch,meanD_all]); ylim(ylimits); xticklabels({'Bimodal','Unimodal','All'});
% line([0,4],[0,0],'color','black','LineWidth',2,'LineStyle','--')
% title(fN)

%- Correlation with age -%
[mdl,pMdl,fMdl] = plotRegression(meanD,age,'MeanActivation','Age',nan,fN)


%-Check >1 ROI-%
meanD = [];
meanD_catch = [];
meanD_all = [];
for r = 1:length(roiName)
  fN = sprintf('data/singleTrialBetas/singleTrial-beta_ROI-%s_method-%s.mat',roiName{r},method);
  load(fN,'beta');
  for s = 1:length(beta)
    meanD(s,r) = mean(mean(cell2mat(beta{s}(1:3)'),2)); %total mean activation (no catch)
    meanD_catch(s,r) = mean(mean(cell2mat(beta{s}(4:5)'),2)); %total mean activation (catch no press supposedly)
    meanD_all(s,r) = mean(mean(cell2mat(beta{s}'),2)); %total mean activation (regardless condition)
  end
end
%-Violin Plots of mean Activity-%
ylimits = [-0.2,0.2];

figure('position',[600,600,600,600]) %Main Trials
violinplot(meanD); ylim(ylimits); xticklabels(roiName)
line([0,length(roiName)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')

figure('position',[600,600,600,600]) %Main + Catch Only
violinplot([meanD,meanD_catch]); ylim(ylimits); [nam] = figLabels(roiName,{'Main','Catch'}); xticklabels(nam)
line([0,length(nam)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')

figure('position',[600,600,600,600]) %Main + Catch Only + All
violinplot([meanD,meanD_catch,meanD_all]); ylim(ylimits); [nam] = figLabels(roiName,{'Main','Catch','All'}); xticklabels(nam)
line([0,length(nam)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')







