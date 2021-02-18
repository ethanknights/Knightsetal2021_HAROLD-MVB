function info4Fingers
load('subInfo.mat');


%     % Legend (notes from Laura Hughes)
%     % Col 1: Pulsenumber
%     % Col 2: SOA
%     % Col 3: Trial onset 
%     % Col 4: Cue onset (i.e the dots appear on the hand)  
%     % Col 5: trial number
%     % Col 6: block  looks blank in yours, so perhaps not used
%     % Col 7: Cue type (see below)
%     % Col 8: Button Press (2,4,8,16  index:little)
%     % Col 9: Reaction time
%     % Col 10: accuracy (1=pressed button that was available, 0 inaccurate)
%     % Col 11: Trial type  (see below)
% 
%     % Colum 7: Cue Type
%     % Specified trials
%     % 1;%ind;
%     % 2;%midd;
%     % 3;%ring;
%     % 4;%little;
%     % Free (3) Choice trials
%     % 5;%1 2 3;   %fingers 1 2 3 available 
%     % 6;%1 3 4;  % etc
%     % 7;%1 2 4;
%     % 8;%2 3 4;
% 
%     % Column 11: Trial Type
%     % 1 choose repeat, 2 choose no repeat, 3 spec repeat, 4 spec no repeat
    
    %idx
    remap = [2,4,8,16];
    for s = 1:nSubs
        for c = 1:4
            trialInfo.idx4Fingers{c,s} = find(trialInfo.resp{s}(:,8) == remap(c));
        end
    end
            
    %nReps           
    for s = 1:nSubs
        for c = 1:4
            trialInfo.nReps4Fingers(c,s) = size(trialInfo.idx4Fingers{c,s}(:),1);
        end
        trialInfo.nReps4Fingers(5,s) = sum(trialInfo.nReps4Fingers(:,s));
    end
    
    %onsets
    nDummies=6;
    for s = 1:nSubs
        start = trialInfo.resp{s}(1,3) - (nDummies * TR*1000);
        for c = 1:4
            tmp = trialInfo.resp{s}(trialInfo.idx4Fingers{c,s},3)
            trialInfo.onset{c,s} = (tmp - start) / 1000;
        end
    end
    
    %idx subjects with <240 total reps (ie. no response trials) for exclusion later
    goodSubs = zeros(nSubs,1);
    goodSubs(find(trialInfo.nReps4Fingers(5,:) == 240)) = 1;
    goodSubs = logical(goodSubs); %sum(goodSubs) = 87
    
    clear remap nDummies start
    save('subInfo.mat')
end