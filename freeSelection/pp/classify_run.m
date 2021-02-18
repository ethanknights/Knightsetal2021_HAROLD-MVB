%Perform MVPA (for a single run) using 8-fold (randomly assigned folds) 
%cross validation with fitcecoc's default parameters

function classify_run(fN,oN,outDir)

rng('default'); %set seed
  
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
        
    predictors = x(:,1:end-1);
    response = x(:,end);
    
    %defaults from app
    template = templateSVM(...
    'KernelFunction', 'linear', ...
    'PolynomialOrder', [], ...
    'KernelScale', 'auto', ...
    'BoxConstraint', 1, ...
    'Standardize', true);

    classificationSVM1 = fitcecoc(...
    predictors, ...
    response, ...
    'Learners', template, ...
    'Coding', 'onevsone', ...
    'ClassNames', [1; 2; 3; 4]);

    partitionedModel = crossval(classificationSVM1, 'KFold', 8);
    [validationPredictions, ~] = kfoldPredict(partitionedModel);
    
    [decAcc(s),decAccBal(s),confMat.raw(:,:,s)] = balanceDecAcc_4Way(x(:,end),validationPredictions);

end

save(fullfile(outDir,oN),'decAcc','decAccBal','confMat')

end