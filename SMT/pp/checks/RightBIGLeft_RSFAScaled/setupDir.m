clear

mkdir data
load('CCIDList.mat')

origDir = '/imaging/henson/users/ek03/projects/HAROLD/SMT';
origConDir = fullfile(origDir,'pp','data','firstLevelModel_smooth');

outDir = 'data/firstLevelModel_smooth';
mkdir(outDir);

conStr  = 'con_0001.nii'; %all action > baseline
RSFAStr = 'sd_wcm2f11_10_128_pmswaufMR*_wds.nii';

nSubs = length(CCIDList);

parfor s = 1:nSubs; CCID = CCIDList{s}; subDir = fullfile(outDir,CCID); mkdir(subDir);
  try
    %% copy Con images
    source = fullfile(origConDir,CCID,conStr);
    dest = fullfile(subDir,conStr);
    copyfile(source,dest);
    fN_con = dest;
    
    %% copy RSFA Images
    RSFA_Dir = '/imaging/camcan/sandbox/kt03/archived/2020TsvetanovPsyP/data/mri/release003/resting1/data_rsfa1_wavelet';
    fN_RSFA = rdir(fullfile(RSFA_Dir,CCID,RSFAStr));
    
    source2 = fN_RSFA.name;
    dest2 = [subDir,'/'];
    system(sprintf('/usr/bin/ln -s %s %s',source2,dest2));
    
    fN_RSFA = dir(fullfile(subDir,RSFAStr)); fN_RSFA = fN_RSFA.name;
    
    %% Smooth the RSFA image (10mm like con_0001.nii)
    kernelSize = 0;
    matlabbatch = [];
    matlabbatch{1}.spm.spatial.smooth.data = {fullfile(subDir,fN_RSFA)};
    matlabbatch{1}.spm.spatial.smooth.fwhm = [kernelSize,kernelSize,kernelSize]; %[8,8,8] etc.
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = ['s',num2str(kernelSize),'mm_'];
    spm_jobman('run',matlabbatch);
    
    fN_RSFAsmooth = sprintf('s%smm_%s',num2str(kernelSize),fN_RSFA); %newname
    
    %% RSFA Scale original Con Image (imcalc)
    fN_conRSFA = fullfile(subDir,[conStr(1:end-4),'_RSFAScaled.nii']); %newname
    
    matlabbatch = [];
    matlabbatch{1}.spm.util.imcalc.input = {
      fN_con; ...
      fullfile(subDir,fN_RSFAsmooth)
      };
    matlabbatch{1}.spm.util.imcalc.output = fN_conRSFA;
    matlabbatch{1}.spm.util.imcalc.outdir = {subDir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1./(1+i2)';  %'i1 ./ i2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    spm_jobman('run',matlabbatch);
    
    %% smooth resulting RSFAScaled image (i.e. smoothing a second time)
    kernelSize = 0; %0 | 8 | 10
    matlabbatch = [];
    matlabbatch{1}.spm.spatial.smooth.data = cellstr(spm_select('ExtFPList',subDir,'con_0001_RSFAScaled.nii'));
    matlabbatch{1}.spm.spatial.smooth.fwhm = [kernelSize,kernelSize,kernelSize]; %[8,8,8] etc.
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = ['final_','s',num2str(kernelSize),'mm_'];
    spm_jobman('run',matlabbatch);

    %% output action > baseline: data/firstLevelModel_smooth/CC110033/final_s10mm_con_0001_RSFAScaled.nii
    
    %%---------------------------
    %% For Additional Laterality Difference Map
    %%---------------------------
    fN = sprintf('final_s%smm_%s_RSFAScaled.nii',num2str(kernelSize),conStr(1:end-4));
    %% Flip it (to do R - L)
    matlabbatch = [];
    matlabbatch{1}.spm.util.reorient.srcfiles = {fullfile(subDir,fN)};
    matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
    matlabbatch{1}.spm.util.reorient.prefix = 'tmp_flipped_';
    spm_jobman('run',matlabbatch);
    
    %% do R - L (imcalc)
    matlabbatch = [];
    matlabbatch{1}.spm.util.imcalc.input = {
      fullfile(subDir,['tmp_flipped_',fN]); ...
      fullfile(subDir,[fN]) ...
      };
    matlabbatch{1}.spm.util.imcalc.output = ['s',num2str(kernelSize),'mm_','RightMINUSLeft_RSFAScaled'];
    matlabbatch{1}.spm.util.imcalc.outdir = {subDir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1 - i2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
    spm_jobman('run',matlabbatch);
 
    %% Flip output back (otherwise imcalc's iOutput assumes i1's orientation (where i1 was the R-flipped image))
    matlabbatch = [];
    matlabbatch{1}.spm.util.reorient.srcfiles = {fullfile(subDir,['s',num2str(kernelSize),'mm_','RightMINUSLeft_RSFAScaled.nii,1'])};
    matlabbatch{1}.spm.util.reorient.transform.transprm = [0 0 0 0 0 0 -1 1 1 0 0 0]; %L-R flip
    matlabbatch{1}.spm.util.reorient.prefix = 'final_';
    spm_jobman('run',matlabbatch);
    
    %% output right > left: data/firstLevelModel_smooth/CC110033/final_s8mm_RightMINUSLeft_RSFAScaled.nii
    
  catch
    fprintf('Failed to produce final image (probably mmissing RSFA image): \n%s/final_RightMINUSLeft.nii\n',subDir)
    %missing RSFA image ... 4 subs:  131   212   255   552 {'CC221585'}    {'CC320478'}    {'CC321504'}    {'CC620821'}
  end
  
  
end

