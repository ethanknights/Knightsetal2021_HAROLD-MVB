
% generate some brain variables (you replace with real data)
% Ns = 1000;
% age = randn(Ns,1);
% LH  = randn(Ns,1);
% RH  = randn(Ns,1);
clear 

singleTrialBetaDir = '/imaging/ek03/MVB/SMT/pp/data/';

age = [];
load('CCIDList.mat','CCIDList','age')


LH = [];
fN = 'singleTrial-beta_ROI-PreCG_L_500_method-LSS.mat'
meanD = []; meanD_catch = []; meanD_all = [];
fN = fullfile(singleTrialBetaDir,'singleTrialBeta',fN);
load(fN,'beta');
for s = 1:length(beta)
    meanD(s) = mean(mean(cell2mat(beta{s}(1:3)'),2)); %total mean activation (no catch)
    meanD_catch(s) = mean(mean(cell2mat(beta{s}(4:5)'),2)); %total mean activation (catch no press supposedly)
    meanD_all(s) = mean(mean(cell2mat(beta{s}'),2)); %total mean activation (regardless condition)
end
meanD = meanD';
meanD_catch = meanD_catch';
meanD_all = meanD_all';
LH = meanD;


RH = [];
fN = 'singleTrial-beta_ROI-PreCG_R_500_method-LSS.mat'
meanD = []; meanD_catch = []; meanD_all = [];
fN = fullfile(singleTrialBetaDir,'singleTrialBeta',fN);
load(fN,'beta');
for s = 1:length(beta)
    meanD(s) = mean(mean(cell2mat(beta{s}(1:3)'),2)); %total mean activation (no catch)
    meanD_catch(s) = mean(mean(cell2mat(beta{s}(4:5)'),2)); %total mean activation (catch no press supposedly)
    meanD_all(s) = mean(mean(cell2mat(beta{s}'),2)); %total mean activation (regardless condition)
end
meanD = meanD';
meanD_catch = meanD_catch';
meanD_all = meanD_all';
RH = meanD;

[CRT_mean,CRT_median,CRT_stdev ...
 SRT_mean,SRT_median,SRT_stdev] = getRT_behav(CCIDList);


%GLM
B = [2 0];

X = [LH RH]; 

% Generate some behavioural data (replace with real data, eg RTvar or RTmean)
% y = X*B';
% y = y + randn(Ns,1)/10;

y = SRT_stdev;

%Drop subs with nan
idx = isnan(y); 
age(idx) = [];
X(idx,:) = [];
y(idx) = [];
nExcl = sum(idx);
Ns = length(LH) - nExcl;
fprintf('\nDropped %d subjects as missing behavioural data\n%d Subjects left\n',nExcl,Ns)

% LH predictor only
X1 = [X(:,1) ones(Ns,1)];
Bhat = pinv(X1) * y;
r1 = y - X1*Bhat; % residuals from model1      % scatter(X(:,1),r1)

% LH+RH predictors
X2 = [X(:,1) X(:,2) ones(Ns,1)];
Bhat = pinv(X2) * y;
r2 = y - X2*Bhat; % residuals from model2

[r1'*r1 r2'*r2]  % total error (always lower for r2, need to adjust for extra df)

[corr(age,r1), corr(age,r2)] % but does correlation with age go down?

% figure,hold on
% plot(age,r1,'ro')
% plot(age,r2,'bo');    xlabel('age');ylabel('residual')

% figure
% plot(age,abs(r1)-abs(r2),'go')


% Then run from line 10 with instead
B = [2 2]
% total error reduced for model 2, but similar correlation of residuals with age

% The run from line 10 with instead
RH = RH + age;
% total error reduced, but correlation with age also decreases? (ie, compensation)


% but although comparing residual correlation with age is similar to asking
% which model is best as a function of age (like for MVB), I think it might
% be simpler just to fit a single GLM with LH, RH, Age, and Age*RH and
% ask which terms are significant, ie explain additional variance, or in
% R:  lm(y ~ LH*Age + RH*Age, data=Data) and seeing whether any terms
% involving RH are significant?



 