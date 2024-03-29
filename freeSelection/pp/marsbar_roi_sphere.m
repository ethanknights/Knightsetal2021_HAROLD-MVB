%% Use MarsBaR to make spherical ROIs
%from: http://jpeelle.net/mri/misc/marsbar_roi.html 
%
%Enable autodelete .mat files, and outname argument (newName) %Ethan Knights 15/01/2021

%% Set general options


function marsbar_roi_sphere(outDir,sphereRadius,coords,newName,deleteMatFlag)

outDir = outDir;
sphereRadius = sphereRadius; % mm

if ~iscell(newName)
  newName = {newName}; %stop headache later if just writing 1 roi at time
end
  


% coordinates are nvoxels rows by 3 columns for X,Y,Z
% coords = [1 2 3
%   4 5 6];


% (alternatively, or better, you could put these in a text file and read
% them in using the dlmread function)



%% Error checking: directory exists, MarsBaR is in path
if ~isdir(outDir)
  mkdir(outDir);
end

% if ~exist('marsbar')
%   error('MarsBaR is not installed or not in your matlab path.');
% end


%% Make rois
fprintf('\n');

for i=1:size(coords,1)
  thisCoord = coords(i,:);
  
  fprintf('Working on ROI %d/%d...', i, size(coords,1));
  
  roiLabel = sprintf('roiN-%d',i);
  
  sphereROI = maroi_sphere(struct('centre', thisCoord, 'radius', sphereRadius));
  
  outName = fullfile(outDir, sprintf('%dmmsphere_%s_roi', sphereRadius, roiLabel));
  
  % save MarsBaR ROI (.mat) file
  saveroi(sphereROI, [outName '.mat']);
  
  % save the Nifti (.nii) file
  save_as_image(sphereROI, [outName '.nii']);
  
  fprintf('done.\n');
  
  movefile([outName '.nii'],newName{i});
  
  if deleteMatFlag == 1
    delete([outName '.mat'])
  end

end





fprintf('\nAll done. %d ROIs written to %s.',size(coords,1),outDir)

end