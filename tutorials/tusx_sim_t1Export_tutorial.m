% tusx_sim_t1Export example
%   Example script to help reate slice overlay figures in which the
%   pressures output by tusx_sim_setup() can be overlayed onto a matching
%   structural volume.
%
%   This example script uses workspace variable names used in
%   tusx_sim_setup_tutorial.m
%   If using one's own files fed into tusx_sim_setup_tutorial.m, one can
%   run this after tusx_sim_setup_tutorial, while supplying 'structuralFile'

% NIfTI file to overlay the pressure results on top of
%   NIfTI file should be the same voxel dimensions and volume dimensions as
%   the mask fed into tusx_sim_setup()
structuralFile = ''; % Path to structural NIfTI file

% Create structural volume that matches cropping, scaling, reorientation
% done to a volume from tusx_sim_setup that was given the same parameters
t1 = tusx_sim_t1Export(structuralFile, scalpLocation, ctxTarget, scale, alphaPower,...
    'CFLnumber', CFLnumber, 'skull', skull,...
    'reorientToGrid', reorientToGrid, 'trimSize', trimSize,...
    'initialSmooth', initialSmooth, 'runOnGPU', runOnGPU,...
    'transducer', transducer);

%% Create slice overlay figures
% Set where to slice the volume
matrixIndicesForSlices = infoStruct.matrixIndices.target; % Current location of 'ctxTarget'

% Create the slice figures
[f1, ax1] = overlaySingleSlice(p_max, t1.img, matrixIndicesForSlices, 'coronal');
[f2, ax2] = overlaySingleSlice(p_max, t1.img, infoStruct.matrixIndices.target, 'horizontal');
[f3, ax3] = overlaySingleSlice(p_max, t1.img, infoStruct.matrixIndices.target, 'sagittal');