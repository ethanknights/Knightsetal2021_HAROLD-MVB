function [decAcc,decAccBal,confMat] = balanceDecAcc_4Way(trueLabels,predLabels)

%NEEDS MATLAB2019a
%Based on: http://mvpa.blogspot.com/2015/12/balanced-accuracy-what-and-why.html 
%Note decAcc matches [~,validationAccuracy,~] = trainClassifier(x); EK 07/02/2020

cm = confusionchart(trueLabels,predLabels); %for extracting data

assert(size(cm.NormalizedValues,1) == 4); %ensure correct size is being used (2 way, 4 way)
    
    %%%% Regular accuracy %%%%
    %(sum correct decisions) / all decisions,
    decAcc = (cm.NormalizedValues(1,1) + cm.NormalizedValues(2,2) ...
            + cm.NormalizedValues(3,3) + cm.NormalizedValues(4,4)) ...
            / sum(sum(cm.NormalizedValues));


    %%%% Balanced accuracy (better measure for uneven trials) %%%%
    %(sum(correct decisions for a class / all poss decisions for that class)) / nClasses
    for i = 1:size(cm.NormalizedValues,1)
        tmp(i) = cm.NormalizedValues(i,i) / sum(cm.NormalizedValues(i,:));
    end
        decAccBal = (sum(tmp)) / i;
        
  %Store cm
  confMat = cm.NormalizedValues;
  
end