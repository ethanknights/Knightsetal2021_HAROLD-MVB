function [xCells,runlabels] = split8Runs(allX);

nRuns = 8;
nRepeats = length(allX) / nRuns;

tmp = repmat([1:nRuns],[1,nRepeats])';

runLabels = tmp(randperm(length(tmp))); 

for runs = 1:nRuns
  xCells{runs} = allX(runLabels == runs,:)
end



end