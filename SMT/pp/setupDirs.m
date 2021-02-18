%Purpose:
%Setup this directory -
%Create symlinks to AA preprocessed data in this directory. And then perform
%final couple of steps manually (rather tahn setting up aa pipeline).
%
%Specifically -
%
%From aa:
%Symlink aamod_norm_write_dartel_00001/CC110033/swaufMR10033_CC110033-0006.nii
%Symlink aamod_mask_fromsegment_00001/CC110033/structurals/S_rsmwc<1>msMR10033_CC110033-0003-00001-000192-01.nii
%Symlink aamod_realignunwarp_00001/ ...
%
%Manual steps:
%Should add wholebrain mask to aamod_norm_write_dartel (like aamod_wavelet_despiek does)first BUT WHAT FILE IN AA IS IT??
%Use aamod_norm_write_dartel to generate compSignal.mat
%Use aamod_norm_write_dartel to smooth for 

%This includes smoothed (for defining ROIs) and not smoothed (for analysis)
%Also save CCIDList.mat for later

%% Grab preprocessed data filenames from aa
DAT = [];
DAT.SelectFirstFile = 1; % sow e dont get '_wds.nii' for norm_write_dartel_masked
DAT.SessionList = {
%  'norm_write_dartel' '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_norm_write_dartel_00001/<CCID>/SMT/swauf*.nii'
'norm_write_dartel_masked' '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_waveletdespike_00001/<CCID>/SMT/mswauf*.nii'
'rp',    '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_realignunwarp_00001/<CCID>/SMT/rp*.txt'
'mask1', '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_mask_fromsegment_00001/<CCID>/structurals/S_rsmwc1*.nii'
'mask2', '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_mask_fromsegment_00001/<CCID>/structurals/S_rsmwc2*.nii'
'mask3', '/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_mask_fromsegment_00001/<CCID>/structurals/S_rsmwc3*.nii'
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
%using FileCheck(:,1) so we only get the smt data subs
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
  'norm_write_dartel_masked',     'data/aa_norm_write_dartel_masked/<CCID>/mswauf*.nii'
  'rp',                           'data/aa_rp/<CCID>/rp*.txt'
  'mask1', 'data/aa_mask_fromsegment1/<CCID>/S_rsmwc1*.nii'
  'mask2', 'data/aa_mask_fromsegment2/<CCID>/S_rsmwc2*.nii'
  'mask3', 'data/aa_mask_fromsegment3/<CCID>/S_rsmwc3*.nii'
  };
DAT = CCQuery_CheckFiles(DAT);

fNs(:,1) = DAT.FileNames.norm_write_dartel_masked(DAT.FileCheck(:,1));
fNs(:,2) = DAT.FileNames.rp(DAT.FileCheck(:,1));
fNs(:,3) = DAT.FileNames.mask1(DAT.FileCheck(:,1));
fNs(:,4) = DAT.FileNames.mask2(DAT.FileCheck(:,1));
fNs(:,5) = DAT.FileNames.mask3(DAT.FileCheck(:,1));

%% Grab onsets information (taken from aa release004)
conds = {'AudVid1200','AudVid600','AudVid300','AudOnly','VidOnly'};
onsdir = '/imaging/camcan/cc700-scored/MRI/release001/data';

for s = 1:length(CCIDList)
  
  CCID = CCIDList{s};
  
  disp(['SMT model for Subject: ' CCID])
  tons = {}; all_ons = [];
  for con = 1:length(conds)
    filename = fullfile(onsdir,CCID,sprintf('onsets_%s.txt',conds{con}));
    if ~exist(filename,'file')
      warning(sprintf('%s: no onset files',CCID))
      %continue % could remove this when running AA ourselves and replace with line below
      filename = fullfile(onsdir,CCIDList{1},sprintf('onsets_%s.txt',conds{con}));
    end
    tons = load(filename);
    all_ons = [all_ons; tons];
    tdurs = zeros(size(tons));  % Could load durations files in same directory, but all 0.3 at moment, so assuming events just as good
    
    %Store in explicit structure
    trialInfo.onset{s,con} = tons;
    trialInfo.onsetLabels{s,con} = conds{con};
    trialInfo.durations{s,con} = tdurs;
  
  end
end


%% Save 'CCIDList' with ages and filenames, to make life simple later
save('CCIDList.mat','CCIDList','age','fNs','trialInfo');

