%Purpose:
%Run aa to preprocess finger tapping data for MVB HAROLD project.
%Preprocessing should match that for cc700 SMT (in MVB I used):
%/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI_Smooth_SMT/aamod_firstlevel_contrasts_00001/
%/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI_Smooth_SMT/aamod_firstlevel_model_00002/CC110033/SMT/smswaufMR10033_CC110033-0006_wds.nii
%smswaufMR10033_CC110033-0006_wds.nii

function aa_release005

clear
close all

%==========================================
% Setup 
%==========================================

%--- Setup Subjects ---%
%All MVB Subjects
load('subInfo.mat')
CCIDList = CCID(goodSubs); %enough trials
%Select some for testing?
% runSubjects = CCIDList(1:2);
runSubjects = CCIDList;
CCIDList = runSubjects;
nSubs = length(CCIDList);


%--- Setup Paths ---%
restoredefaultpath
addpath('/imaging/camcan/QueryFunction/QueryFun_v1')
rootDir = pwd;
aa_path = fullfile(pwd,'automaticanalysis');
if any(ismember(regexp(path,pathsep,'Split'),aa_path))
else
  addpath(genpath(aa_path))
end 
aa_close
BIDSDir = fullfile(rootDir,'BIDS')


%--- Setup BIDS ---%
done_createBIDSDir = 1; %symlink relevant data to BIDS/
if ~done_createBIDSDir
  mkdir(BIDSDir)
  for s = 1:nSubs
    
    CCID = ['sub-',CCIDList{s}];
    
    subDir = fullfile(BIDSDir,CCID);
    mkdir(subDir)
    
    %Structurals
    mkdir(fullfile(subDir,'anat'))
    tmp_root = '/imaging/camcan/cc280/mri/pipeline/release004/BIDS';
    source =  fullfile(tmp_root,  CCID,'anat',[CCID,'_T1w.nii.gz']);
    dest =    fullfile(BIDSDir,   CCID,'anat',[CCID,'_T1w.nii.gz']);
    system(sprintf('ln -s %s %s',source,dest));
    source =  fullfile(tmp_root,  CCID,'anat',[CCID,'_T1w.json']);
    dest =    fullfile(BIDSDir,   CCID,'anat',[CCID,'_T1w.json']);
    system(sprintf('ln -s %s %s',source,dest));
    
    %Func
    mkdir(fullfile(subDir,'func'))
    tmp_root = '/imaging/camcan/sandbox/ek03/CC280_BIDS_MRI/create_task-SNG_FreeSelection/forBIDS_together_fMRI-SNG-FreeSelection/BIDS';
    source =  fullfile(tmp_root,  CCID,'func',[CCID,'_task-FreeSelection_bold.nii.gz']);
    dest =    fullfile(BIDSDir,   CCID,'func',[CCID,'_task-FreeSelection_bold.nii.gz']);
    system(sprintf('ln -s %s %s',source,dest));
    source =  fullfile(tmp_root,  CCID,'func',[CCID,'_task-FreeSelection_bold.json']);
    dest =    fullfile(BIDSDir,   CCID,'func',[CCID,'_task-FreeSelection_bold.json']);
    system(sprintf('ln -s %s %s',source,dest));
  end
end


%==========================================
% AA
%==========================================

%--- Initialise aa ---%
fprintf('initialising AA session\n');
aa_ver5


aap = [];
aap = aarecipe('aap_parameters_defaults_CBSU.xml','aa_freeSelection.xml');
%aap = aarecipe('aap_parameters_defaults_CBSU.xml','aa_freeSelection_quick.xml');

% aap.options.wheretoprocess = 'localsingle'; %qsub | matlab_pct
 aap.options.wheretoprocess = 'qsub'; %qsub | matlab_pct
% aap.options.wheretoprocess = 'matlab_pct'; %qsub | matlab_pct
if strcmp(aap.options.wheretoprocess,'qsub')
  aap.options.aaparallel.numberofworkers = 96;
  aap.options.aaparallel.memory = 8;
  aap.options.aaparallel.walltime = 72;
  aap.options.NIFTI4D = 1;
  aap.options.email = 'ethan.knights@mrc-cbu.cam.a.u';
  aap.options.aaworkerGUI = false;
  aap.options.maximumretry = 1;
end


%--- Study info ---%
aap.directory_conventions.rawdatadir = fullfile(rootDir,'BIDS');% The bids parser only supports a single rawdatadir. Pick the one that has bids in it.
aap.acq_details.root = ''; %so that output is stored in root(see analaysisid next)
aap.directory_conventions.analysisid = fullfile(rootDir,'data'); %for analysed data
%aap.directory_conventions.analysisid = fullfile(rootDir,'data_quick'); %for analysed data
aap = aas_processBIDS(aap); %aas_processBIDS(aap,[],{'anat','dwi'}); %not all modalities


%--- Settings ---%
aap.tasksettings.aamod_slicetiming.sliceorder= [32:-1:1];
%aap.tasksettings.aamod_slicetiming.autodetectSO = 1; % descending
aap.tasksettings.aamod_slicetiming.refslice = 16;

aap.tasksettings.aamod_norm_write_meanepi_dartel.vox = [3 3 3];
aap.tasksettings.aamod_norm_write_dartel.vox = [3 3 3];
aap.tasksettings.aamod_mask_fromsegment.threshold = 0.8;
aap.tasksettings.aamod_waveletdespike.maskingthreshold = 0.9;


aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','reference','meanepi');
aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','grey','normalised_grey');
aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','white','normalised_white');
aap = aas_renamestream(aap,'aamod_mask_fromsegment_00001','csf','normalised_csf');

%aap = aas_renamestream(aap,'aamod_norm_write_meanepi_dartel_00001','dartel_templatetomni_xfm','aamod_dartel_createtemplate_00001.dartel_templatetomni_xfm');


%%Analysis
aa_doprocessing(aap);

end