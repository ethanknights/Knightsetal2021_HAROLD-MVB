function [MVB] = camcan_main_mvb_ui(SPM,conno,priors,matname,XYZmm)
% called in camcan_main_mvb_selectLOO_top: [MVB] = camcan_main_mvb_mask_ui(SPM,con,maskfiles,model,matfname,nvox,pflag, select_con);
%
% LEAVE ONE OUT MASK SINGLE ROI MVB DECODING
% pass a ready made world-space mask XYZmm of coordinates
%
% originally from spm_mvb_ui - multivariate Bayes (Bayesian decoding of a contrast)
% AM Dec 2016
% tidied March 2018
%
% fixes subdivisions at .5 and greedy search steps at 8
% might need more GSS for larger ROIs?
% ASSUMES VOX SIZ vsiz [3 3 3]
%
% Msk = full path of ROI mask file
% sel_con = contrast for top voxel selection
% conno = number of contrast in SPM.xCon
% priors = input 'sparse', 'smooth' etc
% matname = name for the MVB .mat
% nvoxels = no. of features to select from mask
%
% Sets up, evaluates and saves an MVB structure:
%
% MVB.contrast            % contrast structure
% MVB.name                % name
% MVB.c                   % contrast weight vector
% MVB.M                   % MVB model (see below)
% MVB.X                   % subspace of design matrix
% MVB.Y                   % multivariate response
% MVB.X0                  % null space of design
% MVB.XYZ                 % location of voxels (mm)
% MVB.V                   % serial correlation in response
% MVB.K                   % whitening matrix
% MVB.VOX                 % voxel scaling
% MVB.xyzmm               % centre of VOI (mm)
% MVB.Space               % VOI definition
% MVB.Sp_info             % parameters of VOI
% MVB.Ni                  % number of greedy search steps
% MVB.sg                  % size of reedy search split
% MVB.priors              % model (spatial prior)
% MVB.fSPM                % SPM analysis (.mat file)
%
% where MVB.M contains the following fields:
%
%                F: log-evidence [F(0), F(1),...]
%                G: covariance partition indices
%                h: covariance hyperparameters
%                U: ordered patterns
%               qE: conditional expectation of voxel weights
%               qC: conditional variance of voxel weights
%               Cp: prior covariance (ordered  pattern space)
%               cp: prior covariance (original pattern space)
%
%--------------------------------------------------------------------------
% This routine uses a multivariate Bayesian (MVB) scheme to decode or
% recognise brain states from neuroimages. It resolves the ill-posed
% many-to-one mapping, from voxel values or data features to a target
% variable, using a parametric empirical or hierarchical Bayesian model.
% This model is inverted using standard variational techniques, in this
% case expectation maximisation, to furnish the model evidence and the
% conditional density of the model's parameters. This allows one to compare
% different models or hypotheses about the mapping from functional or
% structural anatomy to perceptual and behavioural consequences (or their
% deficits). The aim of MVB is not to predict (because the outcomes are
% known) but to enable inference on different models of structure-function
% mappings; such as distributed and sparse representations. This allows one
% to optimise the model itself and produce predictions that outperform
% standard pattern classification approaches, like support vector machines.
% Technically, the model inversion and inference uses the same empirical
% Bayesian procedures developed for ill-posed inverse problems (e.g.,
% source reconstruction in EEG).
%
% CAUTION: MVB should not be used to establish a significant mapping
% between brain states and some classification or contrast vector. Its use
% is limited to comparison of different models under the assumption
% (hyperprior) that this mapping exists. To ensure the mapping exists, use
% CVA or compute the randomisation p-value (see spm_mvb_p)
%
% See: spm_mvb and
%
% Bayesian decoding of brain images.
% Friston K, Chu C, Mourao-Miranda J, Hulme O, Rees G, Penny W, Ashburner J.
% Neuroimage. 2008 Jan 1;39(1):181-205
%
% Multiple sparse priors for the M/EEG inverse problem.
% Friston K, Harrison L, Daunizeau J, Kiebel S, Phillips C, Trujillo-Barreto
% N, Henson R, Flandin G, Mattout J.
% Neuroimage. 2008 Feb 1;39(3):1104-20.
%
% Characterizing dynamic brain responses with fMRI: a multivariate approach.
% Friston KJ, Frith CD, Frackowiak RS, Turner R.
% Neuroimage. 1995 Jun;2(2):166-72.
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_mvb_ui.m 4770 2012-06-19 13:24:40Z guillaume $


%-Get figure handles and set title
%--------------------------------------------------------------------------
Finter     = spm_figure('FindWin','Interactive');
spm_results_ui('Clear');
spm_input('!DeleteInputObj');
header     = get(Finter,'Name');
Fmvb       = spm_figure('GetWin','MVB');
spm_clf(Fmvb);

%-AMM Get contrast from input not xSPM: only the first line of F-contrast
%--------------------------------------------------------------------------
contrast   = SPM.xCon(conno).name;
c          = SPM.xCon(conno).c(:,1);

%-Get VOI name
%--------------------------------------------------------------------------
name = matname;

% -Assume vox size AMM
% -------------------------------------------------------------------------
vsiz = [3 3 3];

%-Specify search volume (the whole brain)
%--------------------------------------------------------------------------
Q          = ones(1,size(SPM.xVol.XYZ,2));
wholeXYZmm      = SPM.xVol.M(1:3,:)*[SPM.xVol.XYZ; Q];

% now match the selected mask voxels to index them within the whole brain
% and extract the data
% -------------------------------------------------------------------------
[xyzcheck, iw, im] = intersect(wholeXYZmm', XYZmm', 'rows');
% update XYZmm if not all voxels overlap
XYZmm = xyzcheck';
Y        = spm_get_data(SPM.xY.VY,SPM.xVol.XYZ(:,iw));

%% detrend? Rik suggestion to take out univariate mean effect
%Y = detrend(Y',0)';(ensure this is mean across voxels, not time, hence transpose twice)


% Check there are intracranial voxels
%--------------------------------------------------------------------------
if isempty(Y)
  spm('alert*',{'No voxels in this VOI';'Please use a larger volume'},...
    'Multivariate Bayes');
end

sg=.5;   % size of successive subdivisions

% MVB is now specified
%==========================================================================
spm('Pointer','Watch')

%-Get target and confounds
%--------------------------------------------------------------------------
X   = SPM.xX.X;
X0  = X*(speye(length(c)) - c*pinv(c));
try
  % accounting for multiple sessions
  %----------------------------------------------------------------------
  tmpX0  = [];
  for ii = 1:length(SPM.xX.K)
    tmp   = zeros(sum(SPM.nscan),size(SPM.xX.K(ii).X0,2));
    tmp(SPM.xX.K(ii).row,:) = SPM.xX.K(ii).X0;
    tmpX0 = [tmpX0 tmp];
  end
  X0 = [X0 tmpX0];
end
X   = X*c;

% serial correlations
%--------------------------------------------------------------------------
V   = SPM.xVi.V;

% AMM get vox scaling frmo contrast
VOX = SPM.xCon(conno).Vspm.mat;

% invert - crashes for smooth priors because prod(vox) is 0 0 0 bigno
% rather than vox size as help info says - see line 59 in spm_mvb_U
%==========================================================================
U        = spm_mvb_U(Y,priors,X0,XYZmm,vsiz);  % AMM VOX was xSPM.VOX, jut voxel size see above
Ni       = max(8,ceil(log(size(U,2))/log(1/sg)));  % greedy search steps vary with model
M        = spm_mvb(X,Y,X0,U,V,Ni,sg);
M.priors = priors;

% assemble results
%--------------------------------------------------------------------------
MVB.contrast = contrast;                    % contrast of interest
MVB.name     = name;                        % name
MVB.c        = c;                           % contrast weight vector
MVB.M        = M;                           % MVB model (see below)
MVB.X        = X;                           % subspace of design matrix
MVB.Y        = Y;                           % multivariate response
MVB.X0       = X0;                          % null space of design
MVB.XYZ      = XYZmm;                         % location of voxels (mm)
MVB.V        = V;                           % serial correlation in repeosne
MVB.K        = full(V)^(-1/2);              % whitening matrix
MVB.VOX      = VOX;                         % get voxel scaling from contrast struc
if exist('xyzmm','var')
  MVB.xyzmm = xyzmm;                      % centre of VOI (mm)
else
  MVB.xyzmm = [0 0 0];
end
MVB.Space    = XYZmm;                       % VOI definition
MVB.Sp_info  = matname;            % parameters of VOI
MVB.Ni       = Ni;                          % number of greedy search steps
MVB.sg       = sg;                          % size of reedy search split
MVB.priors   = priors;                      % model (spatial prior)
MVB.fSPM     = fullfile(SPM.swd,'SPM.mat'); % SPM analysis (.mat file)
MVB.iw           = iw;                        % sampled voxels for this model from mask

% display
%==========================================================================
if length(XYZmm)==length(MVB.M.qE)
  spm_mvb_display(MVB)
  Fmvb  = spm_figure('GetWin','MVB');
  saveas( Fmvb, matname, 'jpeg');
  
else
  warning('weird error: MVB.M does not include all voxels')
end

% save
%--------------------------------------------------------------------------
save(fullfile(SPM.swd,[matname]),'MVB', spm_get_defaults('mat.format'));


assignin('base','MVB',MVB)

%-Reset title
%--------------------------------------------------------------------------
set(Finter,'Name',header)
spm('Pointer','Arrow')
