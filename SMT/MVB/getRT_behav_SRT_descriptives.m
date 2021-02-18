function [SRT_mean,SRT_stdev,SRT_idx_toExclude] ...
            = getRT_behav_SRT_descriptives(CCIDList)

%---- SIMPLE RT ----%
headers = {'SRT_Acc','SRT_mn','SRT_md','SRT_sd'};  %using all fingers

DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
     'tmpD',  '/cc700-scored/RTsimple/release001/data/RTsimple_<CCID>_scored.txt'
    };
DAT = CCQuery_CheckFiles(DAT);
DAT = CCQuery_LoadData(DAT);
tmpD = DAT.Data.tmpD.Data;
tmpH = DAT.Data.tmpD.Headers'; 



%--- Convert cells to numbers ---%
%drop cells columns 
tmpD(:,end-1) = [];     %notes
tmpH(end-1) = [];       %notes

tmpD(cellfun(@isempty,tmpD)) = {'NaN'}; %fill empty cells with nan
%convert to num
tmpD = cellfun(@str2num,tmpD,'UniformOutput',false); 
tmpD = cell2mat(tmpD);


%--- Cut to CCIDList only ---%
for s = 1:length(CCIDList)
  CCID = CCIDList{s};
  if iscell(CCID)
    CCID = CCID{:};
  end
  
  idx = find(contains(DAT.SubCCIDc,CCID));
  tmpD2(s,:) = tmpD(idx,:);
end
tmpD = tmpD2;
clear tmpD2


idx = [];
idx(1) = contain(tmpH,'Ntrials'); 
idx(2) = contain(tmpH,'RTmean'); %mean RT
idx(3) = contain(tmpH,'RTsd'); %RT Variability
idx(4) = contain(tmpH,'Nmissing'); %No response
idx(5) = contain(tmpH,'PctCorrect'); %No response as percentage

appendD = nan(length(tmpD),5);
for s = 1:length(tmpD)
  for i = 1:length(idx)
    appendD(s,i) = tmpD(s,idx(i)); 
  end
end

appendD(:,6) = appendD(:,5) < 0.9; % > 10 percent no responses


% %List some descriptives
% check = unique(appendD(:,1)); %all subs did 50 trials
% %How many subs from SMTtask did SRT?
% expectTrials = 50;
% fprintf('SMT & SRT N = %d\n', ...
%   sum(appendD(:,1) == expectTrials));
% %How many subs were dropped SRT because > 10 percent no responses?
% appendD(:,6) = appendD(:,5) < 0.9;
% fprintf('SRT dropped becasue of > 10percent no responses N = %d \n', ...
%   sum(appendD(:,6)));



%Tidy output
SRT_mean = appendD(:,2);
SRT_stdev = appendD(:,3);
SRT_idx_toExclude = appendD(:,6);

end