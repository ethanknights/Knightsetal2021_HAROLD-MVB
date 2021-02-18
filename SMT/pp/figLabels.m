function [newNames] = figLabels(roiName,trialLabel)

%Created with:
% trialLabel = {'Bimodal','Unimodal'};
% roiName = {'PreCG_L_500', ...
%            'PreCG_R_500', ...
%            'Ventricle_L_5mm', ...
%            'Ventricle_R_5mm' ...
%            };

nROIs = length(roiName);
nTrialTypes = length(trialLabel); %number to switch labels at

j = 1; %roiName counter
k = 1; %trialLabel counter


for i = 1:nROIs * nTrialTypes

    newNames{i} = sprintf('%s %s',roiName{j}, trialLabel{k})
    
    j=j+1;
    if j > nROIs
        j=1;
        k=k+1;
    end
end

end