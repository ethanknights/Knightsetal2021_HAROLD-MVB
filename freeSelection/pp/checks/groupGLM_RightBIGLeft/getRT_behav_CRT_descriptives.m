function [RT_mean,RT_stdev,RT_idx_toExclude] ...
            = getRT_behav_CRT_descriptives(CCIDList)


headers = {'CRT_PctCorr','CRT_mn','CRT_md','CRT_sd'};  %using all fingers

DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
     'tmpD',  '/cc700-scored/RTchoice/release001/data/RTchoice_<CCID>_scored.txt'
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
idx(1) = contain(tmpH,'Ntrials_all'); 
idx(2) = contain(tmpH,'RTmean_all'); %mean RT
idx(3) = contain(tmpH,'RTsd_all'); %RT Variability
idx(4) = contain(tmpH,'Nmissing_all'); %No response
idx(5) = contain(tmpH,'PctCorrect_all'); %No response as percentage

appendD = nan(size(tmpD,1),5);
for s = 1:size(tmpD,1)
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
RT_mean = appendD(:,2);
RT_stdev = appendD(:,3);
RT_idx_toExclude = appendD(:,6);

end