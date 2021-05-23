function scaled = scaleAndSmooth(trimmed, scale, niftiFile, isWater, reoriented, coerceToBinary)
%SCALEANDSMOOTH Scales and smooths mask structure in tusx_sim_setup
% Calls maskScaler_sim3d()
% Consolidated "SKULL UPSCALING (INTERPOLATION)" and "SKULL SMOOTHING
% (DILATION AND EROSION)"
%
% For tusxSimSetup()
%
%   coerceToBinary option added to allow structural images to be passed
%   through
arguments
    trimmed
    scale       (1,1) int64
    niftiFile         char
    isWater     (1,1) logical = false % Processing volume of water
    reoriented  (1,1) logical = false % Volume was reoriented (reorientToGrid)
    coerceToBinary (1,1) logical = true % Convert image volume into logical
end
% Scale
scaled = struct;
if reoriented
    % Don't save ticks (ticks are invalid if reoriented)
    [scaled.mask, scaled.grids] = maskScaler_sim3D(scale, trimmed.mask,...
        trimmed.Xgrid, trimmed.Ygrid, trimmed.Zgrid, 'outputGrids', true,...
        'reoriented', reoriented, 'coerceToBinary', coerceToBinary);
else
    [scaled.mask, scaled.grids, scaled.ticks] = maskScaler_sim3D(scale, trimmed.mask,...
        trimmed.Xgrid, trimmed.Ygrid, trimmed.Zgrid, 'outputGrids', true,...
        'reoriented', reoriented, 'coerceToBinary', coerceToBinary);
end
scaled.size = size(scaled.mask);
scaled.voxelDimensions = trimmed.voxelDimensions / double(scale);
scaled.voxelDimensions_unit = trimmed.voxelDimensions_unit;

% Scale affine transformation matrices
scaled.affines = scaleAffines(trimmed.affines, scale);

% Smooth
if isWater % Skip if is a water simulation (skull not used) for effic.
    disp('Water Simulation: Skull processing skipped')
elseif ~coerceToBinary
    disp('Coersion to binary was toggled off. Skull smoothing skipped')
else
    scaled.mask = maskSmoother(scaled.mask, scale);
end

% Check grid orientation
gridCheck3D(scaled.grids.Xscaled, scaled.grids.Yscaled, scaled.grids.Zscaled);
end