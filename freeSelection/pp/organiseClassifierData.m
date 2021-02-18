function [dataOut] = organiseClassifierData(data)

%Format for matlab SVM
%stacks conditions from separate cells & append labels to a single cell array, per sub
%Built for all subjects


load 'subInfo.mat'; CCID = CCID(goodSubs);

for s = 1:length(CCID)
    
    %gather labels
    for c = 1:length(data{1,s}) %nConds
        labels{s}{c} = ones(size(data{1,s}{1,c},1),1)*c;
    end
    assert(size(cell2mat(labels{1,s}'),1) == size(cell2mat(data{s}'),1)) 
    
    %append labels
%     d{s} = cell2mat(data{1,s}') %vertcat data for all conditions
%     l{s} = cell2mat(labels{1,s}'); %vertcat labels
      dataOut{s} = [cell2mat(data{1,s}'),cell2mat(labels{1,s}')];
      
end
end