% MVB analysis for CamCAN EmoMem LOO mask generation
% saves a mat file with the selected voxel information for that subject and
% selection contrast and nvox and ROI
% AM Nov 2016
% tidied March 2018
%
%%Ethan 2021:
%This version just saves selXYZmm for each pair of regions for a subject & 
%combines them for to make a bilateral ROI. No LOO - just grabbing
%features (voxels) using XYZmm from spm_real_vol (based on indices from 
%spm_sample_vol i.e. as original code did). 
%Also writes myROI*.nii to check.


clear

%-- Setup paths / variables --%
mvbDir = '/imaging/ek03/projects/HAROLD/SMT/MVB';
if any(ismember(regexp(path,pathsep,'Split'),mvbDir)); else; addpath(mvbDir); end

load('CCIDList.mat','CCIDList')
mvbDir = pwd;
betaDir = 'data';

select_con = 1; %all big baseline

% list of ROIs to create LOO feature masks for
% % roinames = {'PreCG_L_70','PreCG_R_70'}; %hardcoded!
% % % #features (voxels)
% % allnvox = 70*ones(1,numel(roinames)); %to assert mask has expected nvoxels
%%
roinames = {'PreCG_L_140','PreCG_R_70'}; %only doing for L_140 really..
% #features (voxels)
allnvox = 140*ones(1,numel(roinames)); %to assert mask has expected nvoxels


% nomenclature for output
%con=[13];  % target contrast (not used here)

for sub=1:length(CCIDList)
  
  selXYZmm = [];
  
  CCID = CCIDList{sub}
  
  wkdir = fullfile(mvbDir,betaDir,CCID);
  
  cd(wkdir)
  
  % define ROI mask
  for region=1:length(roinames)
    
    maskfile = sprintf('%s/%s.nii',mvbDir,roinames{region});
    
    Msk=roinames{region};
    fname=sprintf('%s_%s',CCID, Msk);
    
    % --------------------------------------------------
    % now loop through all OTHER subjects and make mask out of their con images
    
%     othersubs=[1:length(CCIDList)];
%     othersubs(sub)=[];
    
%     allStat = {};
%     allStatorig = {};
%     allXYZmm = {};
%     allXYZmmorig = {};
%     allOverlapStat = {};
%     allOverlapXYZ = {};
    
%     for os=1:length(othersubs)
%       
%       otherCCID = CCIDList{othersubs(os)}
%       
%       odir = fullfile(mvbDir,betaDir,otherCCID);
%       cd(odir);
      
      % define contrast for mask creation
       load('SPM.mat','SPM')
%       [SPM] = parload('SPM.mat')
      contrast   = SPM.xCon(select_con).name;
      c          = SPM.xCon(select_con).c(:,1);
           
      %-Specify search volume (the whole brain)
      %--------------------------------------------------------------------------
      Q          = ones(1,size(SPM.xVol.XYZ,2));
      XYZmm      = SPM.xVol.M(1:3,:)*[SPM.xVol.XYZ; Q];
      
      %-Specify mask volume
      %--------------------------------------------------------------------------
      D     = spm_vol(maskfile);
      str   = sprintf('image mask: %s',spm_str_manip(Msk,'a30'));
      XYZ   = D.mat \ [XYZmm; Q];  % get whole brain values (back to voxel space)
      j     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);
      XYZmm      = XYZmm(:,j);  % XYZ in world space, indexed by mask j's
      %THe rest is for gathering stats, and intersecting with other subs
%       Q     = Q(1:length(j));
%       allXYZmm{ os } = XYZmm';
%       allXYZorig{ os } = XYZmm';
      
      %-Find values within the mask from select_con stat image (actually often F)
      %--------------------------------------------------------------------------
%       T     =  spm_vol(SPM.xCon(select_con).Vspm.fname);    % or don't need to re-map?
%       XYZt      = T.mat \ [XYZmm; Q];   % in t image's voxel space (=SPM.xVol space)
%       TinMsk   = spm_sample_vol(T, XYZt(1,:), XYZt(2,:), XYZt(3,:),0);
%       allStatorig{os} = TinMsk;
      
%       % match voxels as most subs differ from most other
%       % this gives decreasing nvox with each subject, and final XYZ
%       % is voxels common to all
%       % -------------------------------------------------------------------------
%       if os>1
%         
%         % xx gets the common voxel coordinates between the two
%         [xx, ia, ib] =intersect(allXYZmm{os-1}, allXYZmm{os}, 'rows');
%         allXYZmm{os-1} = xx;
%         allXYZmm{os}   = xx;
%         allStat{os-1} = allStatorig{os-1}(ia);
%         allStat{os} = allStatorig{os}(ib);
%         
%       end
      
%    end   % other subjects loop
    
%     finXYZmm = allXYZmm{length(othersubs)};
    
    % now equalise the XYZ in all subs to the final one, common vox
    % -------------------------------------------------------------------------
%     for os = 1:(length(othersubs)-1)
%       
%       % as above
%       [xxx, iia, iib] = intersect(allXYZmm{os}, finXYZmm, 'rows');
%       allOverlapXYZ{os} = xxx;  % doesn't really need doing, but check
%       allOverlapStat{os} = allStat{os}(iia)';
%       
%     end   % second other subjects loop
    
%     % add last subject
%     os = length(othersubs);  % changed too
%     allOverlapStat{os} = allStat{os}';
%     allStatMat = cell2mat(allOverlapStat);
%     meanOverlapStat = mean( allStatMat, 2 );
%     [allstats, ind] = sort( abs( meanOverlapStat ), 'descend' );
%     %feat = ind( 1:nvox ); Missing this nvox?
%     feat = ind( 1:allnvox(region) );
    
    % confirm selected features for this subject
    % remembering to flip back to usual orientation
%     selXYZmm      = finXYZmm(allnvox,:)';  % using the nv top voxels
      
      selXYZmm = XYZmm; %i.e. use whole roi mask for this subject
      %i.e. dont drop voxels by stats or based on overlap with other subs
%       if length(selXYZmm) ~= allnvox(region)
%         warning('mask doesnt have expected nVoxels - %d voxels',length(selXYZmm))
%       end
      nVox = length(selXYZmm);
      
%     cd( wkdir );
%     save( fname, 'othersubs', 'sub', 'finXYZmm', 'selXYZmm', 'allStatMat', 'ind', 'nvox', 'allXYZorig', 'allStatorig' );
    save( fname, 'selXYZmm','nVox');
    
    %% write nifti to check
    writeNIFTI2(sprintf('myROI_%s.nii',fname),selXYZmm,'/imaging/ek03/projects/HAROLD/SMT/pp/data/aa_norm_write_dartel_masked/CC110033/mswaufMR10033_CC110033-0006.nii,1');
    %spm_check_registration(sprintf('myROI_%s.nii',fname),'/imaging/ek03/projects/HAROLD/SMT/pp/data/aa_norm_write_dartel_masked/CC110033/mswaufMR10033_CC110033-0006.nii,1')


    %% store both ROIs to combine
    cell_selXYZmm{region} = selXYZmm;
    cell_nVox(region) = nVox;

  end  % region loop
  
  %% combine
  
  %filename
  Msk = [roinames{1},'&',roinames{2}];
  fname=sprintf('%s_%s',CCID, Msk);
    
  %combine coords
  selXYZmm = [cell_selXYZmm{1},cell_selXYZmm{2}];
  
%   if length(selXYZmm) ~= sum(allnvox)
%     warning('mask doesnt have expected nVoxels - %d voxels',length(selXYZmm))
%   end
  nVox = sum(cell_nVox);
  
  %save
  save( fname, 'selXYZmm','nVox');
  
  %% write nifti to check
  writeNIFTI2(sprintf('myROI_%s.nii',fname),selXYZmm,'/imaging/ek03/projects/HAROLD/SMT/pp/data/aa_norm_write_dartel_masked/CC110033/mswaufMR10033_CC110033-0006.nii,1');
  %spm_check_registration(sprintf('myROI_%s.nii',fname),'/imaging/ek03/projects/HAROLD/SMT/pp/data/aa_norm_write_dartel_masked/CC110033/mswaufMR10033_CC110033-0006.nii,1')

  
end  % subject loop





