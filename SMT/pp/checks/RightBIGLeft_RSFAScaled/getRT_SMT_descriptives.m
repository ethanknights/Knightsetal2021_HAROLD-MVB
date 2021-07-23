function [RT_mean,RT_stdev,RT_idx_toExclude] = getRT_SMT_descriptives(CCIDList)


DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
     'tmpD',  'cc700-scored/MRI/release001/data/<CCID>/*_scored.txt'
    };
DAT = CCQuery_CheckFiles(DAT);
DAT = CCQuery_LoadData(DAT);
tmpD = DAT.Data.tmpD.Data;
tmpH = DAT.Data.tmpD.Headers';

%--- Convert cells to numbers ---%
%drop cells columns 
tmpD = tmpD(:,3:end); %radiographer
tmpH = tmpH(3:end);   %radiographer
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


%--- Get all relevant data (regardless of exclusion criteria) ---%
idx = [];
idx(1) = contain(tmpH,'Ntrials'); 
idx(2) = contain(tmpH,'mRT'); %mean RT
idx(3) = contain(tmpH,'stdRT'); %RT Variability
idx(4) = contain(tmpH,'Nmissing'); %No response
idx(5) = contain(tmpH,'PctCorrect'); %No response as percentage

appendD = nan(length(tmpD),5);
for s = 1:length(tmpD)
  for i = 1:length(idx)
    appendD(s,i) = tmpD(s,idx(i)); 
  end
end

appendD(:,6) = appendD(:,5) < 0.9; % > 10 percent no responses

% %--- List some descriptives ---%
% %How many subs from SMT task have RT?
% check = unique(appendD(:,1)); %all did 120 trials or NaN
% expectTrials = 120;
% fprintf('SMT & SRT N = %d\n', ...
%   sum(appendD(:,1) == expectTrials));
% %How many subs were dropped SRT because > 10 percent no responses?
% appendD(:,6) = appendD(:,5) < 0.9;
% fprintf('SRT dropped becasue of > 10% no responses N = %d \n', ...
%   sum(appendD(:,6)));



%Tidy output
RT_mean = appendD(:,2);
RT_stdev = appendD(:,3);
RT_idx_toExclude = appendD(:,6);

end