clear

mkdir data

origDir = '/imaging/henson/users/ek03/projects/HAROLD/freeSelection';
load(fullfile(origDir,'pp','CCIDList.mat'))
oldConDir = fullfile(origDir,'pp','data','firstLevelModel_smooth');

outDir = 'data/firstLevelModel_smooth';
mkdir(outDir);

conStr = 'con_0001.nii'; %all action > baseline

nSubs = length(CCIDList);

parfor s = 1:nSubs; CCID = CCIDList{s};
  %% copy Con images
  subDir = fullfile(outDir,CCID);  mkdir(subDir);
  source = fullfile(oldConDir,CCID,conStr);
  dest = fullfile(subDir,conStr);
  copyfile(source,dest);
  
  %% Flip them
  fN = dest;
  matlabbatch = [];
  matlabbatch{1}.spm.util.reorient.srcfiles = {sprintf('%s,1',fN)};
  matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
  matlabbatch{1}.spm.util.reorient.prefix = 'flipped_';
  spm_jobman('run',matlabbatch);
  
  %% do R - L (imcalc)
  matlabbatch = [];
  matlabbatch{1}.spm.util.imcalc.input = {
                                        fullfile(subDir,['flipped_',conStr,',1'])
                                        fullfile(subDir,[conStr,',1',]) ...
                                        };
  matlabbatch{1}.spm.util.imcalc.output = 'RightMINUSLeft';
  matlabbatch{1}.spm.util.imcalc.outdir = {subDir};
  matlabbatch{1}.spm.util.imcalc.expression = 'i1 - i2';
  matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
  matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
  matlabbatch{1}.spm.util.imcalc.options.mask = 0;
  matlabbatch{1}.spm.util.imcalc.options.interp = 1;
  matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
  spm_jobman('run',matlabbatch);
end

