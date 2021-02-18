function [stdw] = getMVBWeights(MVB)
%Lifted from STM/VSTM_camcan_weights_single.m


% get MVB details
%==========================================================================
M     = MVB.M;
XYZ   = MVB.XYZ;
VOX   = MVB.VOX;
X0    = MVB.X0;
X     = MVB.X;
Y     = MVB.Y;

% Conditional expectations of voxel weights at all
% voxels in pattern
%--------------------------------------------------------------------------
% and qC are the covariances

E=M.qE;
meanw=mean(E);
stdw=std(E);

end