%Perofrmin compSignal and smoothing to the aa_mod_norm_dartel_masked

clear
load('CCIDList.mat','CCIDList','age','fNs','trialInfo');

destDir_root = 'data';

nSubs = length(CCIDList);

outDir_root = 'data';
nVols = 296;

%% create confoundRegressors.mat (saving in file means they have correct names)
fN_epi = fNs(:,1);
fN_rp = fNs(:,2);
%fN_compSignal = fNs(:,4);
fN_GM = fNs(:,3);
fN_WM = fNs(:,4);
fN_CSF = fNs(:,5);

for s=1:nSubs
  
  CCID = CCIDList{s};
%   subDir = fullfile(destDir_root,confoundDir,CCID);
%   mkdir(subDir)
  
  confoundRegressors = [];
  
  rp = [];
  rp = load(fN_rp{s});
  assert(size(rp,1) == nVols & size(rp,2) == 6, sprintf('rp file is weird look: %s',fN_rp{s}));
  
  %% First we run aamod_compSignal
  % Load the segmented masks!
  V = spm_vol(fN_GM(s)); V=V{:};
  mGM = spm_read_vols(V);
  V = spm_vol(fN_WM(s)); V=V{:};
  mWM = spm_read_vols(V);
  V = spm_vol(fN_CSF(s)); V=V{:};
  mCSF = spm_read_vols(V);
  
  
  % Record the number of voxels in each compartment
  nG = sum(mGM(:)>0);
  nW = sum(mWM(:)>0);
  nC = sum(mCSF(:)>0);
  
  W2Gdist = 1; %xml default:  <W2Gdist>1</W2Gdist> and reported in/imaging/camcan/cc700/mri/pipeline/release004/data_fMRI/aamod_compSignal_00001/CC110033/aap_parameters_aamod_compSignal_00001.mat aap.taslist.currenttask.settings
  mWM = rmNearVox(mWM, mGM,W2Gdist);
  
  compTC = zeros(numel(V), 3);
  V = spm_vol(fN_epi{s});
  for e =  1:numel(V)
    Y = spm_read_vols(V(e));
    % Now average the data from each compartment
    compTC(e,1) = mean(Y(mGM>0));
    compTC(e,2) = mean(Y(mWM>0));
    compTC(e,3) = mean(Y(mCSF>0));
  end
  outDir = fullfile(outDir_root,'compSignal')
  mkdir(outDir)
  subDir = fullfile(outDir,CCID)
  mkdir(subDir)
  oN = fullfile(subDir,'compSignal.mat')
  save(oN, 'compTC');
  
  fNs{s,6} = oN;
  
  %% finally make confoundMat.mat (motion regressors & WM/CSF tissue signal)
  R = [rp,compTC(:,2),compTC(:,3)];
  names = {'x','y','z','r','p','j','WM','CSF'};
  
  outDir = fullfile(outDir_root,'confoundMat')
  mkdir(outDir)
  subDir = fullfile(outDir,CCID)
  mkdir(subDir)
  oN = fullfile(subDir,'confoundRegressors.mat')
  save(oN, 'R','names');
  
  fN{s,7} = oN;
  
end


save('CCIDList.mat','CCIDList','age','fNs','trialInfo');

