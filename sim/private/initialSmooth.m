function nifti = initialSmooth(nifti, smoothingParam)
% Do initial, minor smoothing
%   smoothingParam: Radius of spherical smoothing element [unit: voxels]
%       (default: 1, which works well since this is just an initial pass)
%   Private function for tusx_sim_setup()
arguments
    nifti                   struct
    smoothingParam  (1,1)   double  = 1 % Different from maskSmoother default
end
scale = 1; % No scaling has occured yet: this is the start of the pipeline
nifti.mask = maskSmoother(nifti.mask, scale, smoothingParam);
end