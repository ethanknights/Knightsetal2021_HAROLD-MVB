%Perform MVPA using leave-1-run-out cross validation.
%Runs are artificial (based on nChunks in time) as only 1 run acquired.

function classify_run2(fN,oN,outDir)

nRuns = 4;

load(fullfile('data','singleTrialBetas',fN),'beta');
load('subInfo.mat'); CCID = CCID(goodSubs);

[beta] = organiseClassifierData(beta);

if ~exist(outDir,'dir')
  mkdir(fullfile(outDir))
end

for s = 1:length(beta)
  disp(CCID{s})
  
  x = [];
  x = beta{s};
  
  %Generate run labels to cross validate over
  rng('default'); %set seed
  nTrialsPerRun = length(x) / nRuns;
  tmp = repmat([1:nRuns],[1,nTrialsPerRun])';
  runLabels = tmp(randperm(length(tmp)));
  
  %MVPA
  for currRun = 1:nRuns
    
    idx = runLabels == currRun; %this runLabel
    
    
    %defaults SVM from app
    template = templateSVM(...
      'KernelFunction', 'linear', ...
      'PolynomialOrder', [], ...
      'KernelScale', 'auto', ...
      'BoxConstraint', 1, ...
      'Standardize', true); %normalises x by column ie. normalise every voxel across time ie. trials
    
    
    %Train on all except this runLabel
    predictors = x(~idx,1:end-1);
    response = x(~idx,end);
    classificationSVM1 = fitcecoc(...
      predictors, ...
      response, ...
      'Learners', template, ...
      'Coding', 'onevsone', ...
      'ClassNames', [1; 2; 3; 4]);
    
    
    %Test on this runLabel
    predictors = x(idx,1:end-1);
    [validationPredictions,~] = predict(classificationSVM1,predictors); 
    
    
    %Get Accuracy
    response = x(idx,end); % [response,validationPredictions]
    [all_decAcc(s,currRun),all_decAccBal(s,currRun),all_confMat(:,:,s,currRun)] = ...
      balanceDecAcc_4Way(response,validationPredictions);
    
    
    
  end
  
  %Get summary measures (across runs aka folds)
  decAcc(s) = mean(all_decAcc(s,:));
  decAccBal(s) = mean(all_decAccBal(s,:));
  
  %Confusion matrix
  currConfMat = squeeze(all_confMat(:,:,s,:));
  confMat.raw(:,:,s) = sum(currConfMat,3);
  confMat.percent(:,:,s) = confMat.raw(:,:,s) .* 100/length(x);
  
  
end
save(fullfile(outDir,oN),'decAcc','decAccBal','confMat', ...
  'all_decAcc','all_decAccBal','all_confMat');

end