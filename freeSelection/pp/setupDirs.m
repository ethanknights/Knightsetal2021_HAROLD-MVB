%Purpose:
%Setup this directory -
%Create symlinks to AA preprocessed data in this directory
%This includes smoothed (for defining ROIs) and not smoothed (for analysis)
%Also save CCIDList.mat for later

%% Grab preprocessed data filenames from aa
DAT = [];
DAT.SelectFirstFile = 1; % sow e dont get '_wds.nii' for norm_write_dartel_masked
DAT.SessionList = {
%  'norm_write_dartel' '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_norm_write_dartel_00001/<CCID>/SMT/swauf*.nii'
'norm_write_dartel_masked'  '/imaging/camcan/sandbox/ek03/aa_cc280_fingerTapping/data_fMRI/aamod_waveletdespike_00001/sub-<CCID>/FreeSelection/mswa*.nii'
'rp',                       '/imaging/camcan/sandbox/ek03/aa_cc280_fingerTapping/data_fMRI/aamod_realign_00001/sub-<CCID>/FreeSelection/rp*.txt'
'mask1',                    '/imaging/camcan/sandbox/ek03/aa_cc280_fingerTapping/data_fMRI/aamod_mask_fromsegment_00001/sub-<CCID>/structurals/S_rswc1*.nii'
'mask2',                    '/imaging/camcan/sandbox/ek03/aa_cc280_fingerTapping/data_fMRI/aamod_mask_fromsegment_00001/sub-<CCID>/structurals/S_rswc2*.nii'
'mask3',                    '/imaging/camcan/sandbox/ek03/aa_cc280_fingerTapping/data_fMRI/aamod_mask_fromsegment_00001/sub-<CCID>/structurals/S_rswc3*.nii'
};
DAT = CCQuery_CheckFiles(DAT);
% assert(all(DAT.FileCheck(:,1) == DAT.FileCheck(:,2)),'careful some subs missing smoothed/or wds') %shouldnt happen!
% assert(all(DAT.FileCheck(:,1) == DAT.FileCheck(:,3)),'careful some subs missing smoothed/or wds') %shouldnt happen!
% assert(all(DAT.FileCheck(:,1) == DAT.FileCheck(:,4)),'careful some subs missing smoothed/or wds') %shouldnt happen!
% assert(all(DAT.FileCheck(:,1) == DAT.FileCheck(:,5)),'careful some subs missing smoothed/or wds') %shouldnt happen!


%% Store the List of CCIDs & Age
CCIDList = DAT.SubCCIDc(DAT.FileCheck(:,1))';
I = LoadSubIDs;
age = I.Age(DAT.FileCheck(:,1));


%% per pp stage (wds/smoothed), sym link each subs data
%using FileCheck(:,1) so we only get the task data subs
fNs(:,1) = DAT.FileNames.norm_write_dartel_masked(DAT.FileCheck(:,1));
fNs(:,2) = DAT.FileNames.rp(DAT.FileCheck(:,1));
fNs(:,3) = DAT.FileNames.mask1(DAT.FileCheck(:,1));
fNs(:,4) = DAT.FileNames.mask2(DAT.FileCheck(:,1));
fNs(:,5) = DAT.FileNames.mask3(DAT.FileCheck(:,1));

destDir_root = 'data';
mkdir(destDir_root);
destDirs = {'aa_norm_write_dartel_masked','aa_rp','aa_mask_fromsegment1','aa_mask_fromsegment2','aa_mask_fromsegment3'};

for i = 1:size(fNs,2)
  
  destDir = fullfile(destDir_root,destDirs{i});
  mkdir(destDir)
  for s = 1:length(CCIDList)
    
    CCID = CCIDList{s};
    
    subDir = fullfile(destDir,CCID)
    if ~exist(subDir,'dir')
      mkdir(subDir)
      cmdStr = sprintf('cp -sf %s %s',fNs{s,i},subDir)
      system(cmdStr);
    end
  end
  
end


%% Store fNs from this dir
DAT = [];
DAT.SessionList = {
  'norm_write_dartel_masked',     'data/aa_norm_write_dartel_masked/<CCID>/msw*.nii'
  'rp',                           'data/aa_rp/<CCID>/rp*.txt'
  'mask1', 'data/aa_mask_fromsegment1/<CCID>/S_rswc1*.nii'
  'mask2', 'data/aa_mask_fromsegment2/<CCID>/S_rswc2*.nii'
  'mask3', 'data/aa_mask_fromsegment3/<CCID>/S_rswc3*.nii'
  };
DAT = CCQuery_CheckFiles(DAT);

fNs(:,1) = DAT.FileNames.norm_write_dartel_masked(DAT.FileCheck(:,1));
fNs(:,2) = DAT.FileNames.rp(DAT.FileCheck(:,1));
fNs(:,3) = DAT.FileNames.mask1(DAT.FileCheck(:,1));
fNs(:,4) = DAT.FileNames.mask2(DAT.FileCheck(:,1));
fNs(:,5) = DAT.FileNames.mask3(DAT.FileCheck(:,1));


%% Grab onsets information 
load('subInfo.mat'); %I extracted before from camcan/cc280-scored/CCID/*.resp (resp = rawdata)
%see info4Fingers.m

trialInfo.resp = trialInfo.resp(goodSubs); %cut to 87 (i.e. nReps(5,:) == 240
trialInfo.idx4Fingers = trialInfo.idx4Fingers(:,goodSubs);
trialInfo.nReps4Fingers = trialInfo.nReps4Fingers(:,goodSubs);
trialInfo.onset = trialInfo.onset(:,goodSubs);

%give extra fields to match SMT (bit more basic, but not used by code)
trialInfo.onsetLabels = {'Index','Middle','Ring','Little'};
trialInfo.durations = zeros(size(trialInfo.onset));


%% Save 'CCIDList' with ages and filenames, to make life simple later
save('CCIDList.mat','CCIDList','age','fNs','trialInfo');

