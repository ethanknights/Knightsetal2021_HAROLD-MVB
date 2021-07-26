%Purpose:
%Create first level models for aa SMT waveletdespiked & then smoothed data

clear
load('CCIDList.mat','CCIDList','age','fNs','trialInfo');

destDir_root = 'data';
destDirs = {'firstLevelModel','firstLevelModel_smooth'};

nSubs = length(CCIDList);

%% Specify 1st-level
for s = 1:nSubs
  
  fN_dataDir = fNs(:,1);
  fN_confoundMats = fNs(:,7);
  
  for i = 1:2 %i=1 is firstLevelModel, i=2 is firstLevelModel_smooth
    
    destDir = fullfile(destDir_root,destDirs{i});
    mkdir(destDir)
    
    CCID = CCIDList{s};
    subDir = fullfile(destDir,CCID)
    
    source_subDir = fileparts(fN_dataDir{s}) %just take directory with smotohed/unsmoothed
    
    %Force spm stat overwrite
    if exist(subDir,'dir')
      rmdir(subDir,'s');
    end
    mkdir(subDir);
    
    
    %Load confoundMat file
    fN_confounds = sprintf('data/confoundMat/%s/confoundRegressors.mat',CCID);
    
    %% Specify 1st-level
    matlabbatch = [];
    
    if i == 1 %not smoothed - data/firstLevelModel
      matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',source_subDir,'^mswauf.*\.nii$'));
    elseif  i == 2 %smoothed - data/firstLevelModel_smoothed
      matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList',source_subDir,'^smswauf.*\.nii$'));
    end
    matlabbatch{1}.spm.stats.fmri_spec.dir = {subDir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.97; %to match aa (was 2)
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 32; %to match aa in .xBF.T (was 16); numel(slices)
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 16; %to match aa in .xBF.T0 (was 8); (round(SPM.xBF.T*0.5); 0.5 = halfway through volume aa_engine/aas_firstlevel_model_prepare.m)
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(fN_confounds);
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1]; %informed bf (time & dispersion derivatives)
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1; %2 = model interactions in spm_batch
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.2; %to match aa SMT
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    
    %Events
    for con = 1:size(trialInfo.onsetLabels,2)
      matlabbatch{1}.spm.stats.fmri_spec.sess.cond(con).name = trialInfo.onsetLabels{con};
      matlabbatch{1}.spm.stats.fmri_spec.sess.cond(con).onset = [trialInfo.onset{s,con}];
      matlabbatch{1}.spm.stats.fmri_spec.sess.cond(con).duration = [trialInfo.durations{s,con}]; %0s as in aa_firstLevelmodel
      matlabbatch{1}.spm.stats.fmri_spec.sess.cond(con).tmod = 0;
      matlabbatch{1}.spm.stats.fmri_spec.sess.cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
      matlabbatch{1}.spm.stats.fmri_spec.sess.cond(con).orth = 1;
    end
    
    spm_jobman('run',matlabbatch);
    
    
    %% The new to-be-estimated SPM.mat
    fN_SPM = fullfile(subDir,'SPM.mat');
    
    %% Estimate 1st-level
    matlabbatch = [];
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fN_SPM};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
    
    spm_jobman('run',matlabbatch);
    
    %% Contrasts
    matlabbatch = [];
    matlabbatch{1}.spm.stats.con.spmmat = {fN_SPM};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'All Action > Baseline';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 ... %audvis1200
      1 0 0 ... %audvis600
      1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    
    %Not interested in these, but maybe useful later
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'All Stimulation > Baseline (include catch)';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [1 0 0 ... %audvis1200
      1 0 0 ... %audvis600
      1 0 0 ... %audvis300
      1 0 0 ... %catch (aud)
      1 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'AudVid1200 > Baseline';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [1 0 0 ... %audvis1200
      0 0 0 ... %audvis600
      0 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'AudVid600 > Baseline';
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 ... %audvis1200
      1 0 0 ... %audvis600
      0 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'AudVis300 > Baseline';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 ... %audvis1200
      0 0 0 ... %audvis600
      1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 'High > Low';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [1 0 0 ... %audvis1200
      0 0 0 ... %audvis600
      -1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'Med > Low';
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 ... %audvis1200
      1 0 0 ... %audvis600
      -1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'Med > Low';
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 ... %audvis1200
      1 0 0 ... %audvis600
      -1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.name = 'Low > High';
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.weights = [-1 0 0 ... %audvis1200
      0 0 0 ... %audvis600
      1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{9}.tcon.name = 'Low > Med';
    matlabbatch{1}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 ... %audvis1200
      -1 0 0 ... %audvis600
      1 0 0 ... %audvis300
      0 0 0 ... %catch (aud)
      0 0 0     %catch (vis)
      ];
    matlabbatch{1}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
    
    
    %F contrasts here? (for fairer treatment of de/activation)
    %High vs Low etc
    
    
    %OLD SIMPLE CONTRASTS WITH NO BASIS FNCTION DERIVATIVES
    %     matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'All > baseline';
    %     matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 1 1 0 0]; %aa_contrasts only had 3, like these
    %     matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    %
    %     %Not interested in these, but maybe later
    %     matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'All > baseline (include catch)';
    %     matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [1 1 1 1 1];
    %     matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.delete = 1;
    
    spm_jobman('run',matlabbatch);
    
  end
end
