function [scaled, limits] = simulation3D_setup_volumePrep(o, p, skullNifti,...
    scalpLocation, ctxTarget, scale, options)
% simulation3D_setup_volumePrep Helper function for simulation3D_setup
%   Prepares image volume for use in simulation. Includes cropping,
%   reorientation, smoothing, and scaling.
arguments
    o                       struct
    p                       inputParser
    skullNifti      (1,:)   char
    scalpLocation   (1,3)           {mustBeNumeric}
    ctxTarget       (1,3)           {mustBeNumeric}
    scale           (1,1)           {mustBeInteger, mustBePositive}
    options.coerceImageToBinary (1,1) logical {mustBeNumericOrLogical} = true
end
% Private function for simulation3D_setup
%   Consolidated lines under sections:
%       SKULL IMPORT and Trimming
%       SKULL UPSCALING (INTERPOLATION)
nifti = loadAndAddNiftiInfo(skullNifti, false, false, options.coerceImageToBinary);
origSize = nifti.size; % For later reference

% Initial smoothing (optional)
if o.initialSmooth
    nifti = initialSmooth(nifti, o.initialKernelRadius);
end

% Rotate trajectory to align orthogonally with computational grid
if o.reorientToGrid % If name-value parameter set to true (default: false)
    nifti = reorientToGrid(nifti, scalpLocation, ctxTarget, skullNifti);
end

% Trim mask to save resources
%   Set trim parameters
limits = setLimits(p.Results.trimSize, nifti, scale, scalpLocation, ctxTarget, ...
    o.reorientToGrid, origSize);
% limits: Matrix indices limits used to trim volumes in next step
%   limits = [dim1_first dim1_last dim2_first dim2_last dim3_first dim3_last]

% Trim
%   May have to cast grids to specific type (single/double instead of int)
trimmed = makeTrimmedMask(nifti, limits); clearvars nifti;

% =========================================================================
% SKULL UPSCALING (INTERPOLATION)
% =========================================================================

scaled = scaleAndSmooth(trimmed, scale, skullNifti, o.isWater, o.reorientToGrid,...
    options.coerceImageToBinary);
disp('Upscaling and interpolation finished'); clearvars trimmed;

% Trim to even
%   Remove cap of elements at the end of any dimension that is an odd
%   length
%   Also trim any ticks, grids, etc. (if necessary)
%       Allows for padding to efficient, low-prime size by pmlPicker3D
scaled = trimToEven(scaled);
end