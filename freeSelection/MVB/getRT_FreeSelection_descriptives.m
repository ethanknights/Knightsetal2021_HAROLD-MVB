function [RT_mean,RT_stdev,RT_idx_toExclude] = getRT_FreeSelection_descriptives(CCIDList)


DAT = [];
DAT.rootdir = '/imaging/camcan/';
DAT.SessionList = {
     'tmpD',  'sandbox/ek03/cc280-scored/FingerTapping/analysis_scripts/data/<CCID>/conditions.mat'
    };
DAT = CCQuery_CheckFiles(DAT);


appendD = nan(708,2);
for s = 1:length(appendD)
  try
    load(DAT.FileNames.tmpD{s},'names','RTs')
    
    appendD(s,1) = mean(cell2mat(RTs)');
    appendD(s,2) = std(cell2mat(RTs)');
    appendD(s,3) = length(names)-5; %nErrs
    appendD(s,4) = appendD(s,3) > 25; %more than 10percent
    
  catch
    %NOOP Skip subject (already NaN)
  end
end

%Cut to CCIDList only
for s = 1:length(CCIDList)
  
  CCID = CCIDList{s};
  
  if iscell(CCID)
    CCID = CCID{:};
  end
  
  idx = find(contains(DAT.SubCCIDc,CCID));
  RT_mean(s) = appendD(idx,1);
  RT_stdev(s) = appendD(idx,2);
  %nErr(s) = nErrs(idx);
  RT_idx_toExclude(s) = appendD(idx,4);
end


%Tidy output
RT_mean = RT_mean';
RT_stdev = RT_stdev';
% nErr = nErr';
RT_idx_toExclude = RT_idx_toExclude';




end