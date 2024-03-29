clear

setupDir
groupGLM

%% -- Extract data from ROIs (wds, not smoothed data) -- %%
done_extractROI = 0;
if ~done_extractROI
  
  %-Setup-%
  nCond = 5;
  %method = {'LSA','LSS'};
  method = 'LSS';
  %roiDir = 'data/groupModel_smooth';
  
  roifN = { ...
           'SMA_L_70.nii',      ...
           'SMA_R_70.nii',      ...
           'AgePos_SMA_L_45.nii',      ...
           'AgePos_SMA_R_45.nii',      ...
           };
  roiName = cellfun(@(x) x(1:end-4), roifN, 'Uniform', 0);  %cut '.nii'
  for r = 1:length(roiName)

    %--ROI Extraction--%
    fprintf('Processing roi # %s\n%s\n\n',num2str(r),roifN{r})
    if done_extractROI == 0; extractROI_fMRI_multitrial_GLMs_singleROI(roifN{r},roiName{r},nCond,method); end

  end
end


return


%% Write to R/csv/data.csv
% doPostProcessing







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

fN = 'singleTrial-beta_ROI-SMA_L_70_method-LSS.mat'
fN = 'singleTrial-beta_ROI-SMA_R_70_method-LSS.mat'

fN = 'singleTrial-beta_ROI-AgePos_SMA_L_45_method-LSS.mat'
fN = 'singleTrial-beta_ROI-AgePos_SMA_R_45_method-LSS.mat'
 
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

figure('position',[600,600,600,600]) %Main + Catch Only
violinplot([meanD,meanD_catch]); ylim(ylimits); xticklabels({'Bimodal','Unimodal'});
line([0,3],[0,0],'color','black','LineWidth',2,'LineStyle','--');
line([1,2],[mean(meanD),mean(meanD_catch)],'color','black','LineWidth',2,'LineStyle','-');
title(fN)

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
ylimits = [-1,1];

figure('position',[600,600,600,600]) %Main Trials
violinplot(meanD); ylim(ylimits); xticklabels(roiName)
line([0,length(roiName)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')

figure('position',[600,600,600,600]) %Main + Catch Only
violinplot([meanD,meanD_catch]); ylim(ylimits); [nam] = figLabels(roiName,{'Main','Catch'}); xticklabels(nam)
line([0,length(nam)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')

figure('position',[600,600,600,600]) %Main + Catch Only + All
violinplot([meanD,meanD_catch,meanD_all]); ylim(ylimits); [nam] = figLabels(roiName,{'Main','Catch','All'}); xticklabels(nam)
line([0,length(nam)+1],[0,0],'color','black','LineWidth',2,'LineStyle','--')







