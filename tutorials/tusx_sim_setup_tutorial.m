% tusx_sim_setup_tutorial

% File of binary skull mask
skullMask_filename = fullfile('assets', 'visibleHuman_headCT_mask1300.nii.gz');
%   (This tutorial uses a skull mask created from the Visible Human Project
%   head CT)

% Ultrasound Transducer Location
%
%   1. Set the location of ultrasound transducer using the 'scalpLocation'
%   parameter. Location is designated in NIfTI voxel coordinates.
%
%   2. Set the angle of the trasnducer by designating a NIfTI voxel
%   coordinate to aim at: 'ctxTarget'. In this example, we've chosen an
%   arbitrary voxel within the brain such that the transducer will aim
%   towards the skull at a 45-degree angle on the coronal plane.
scalpLocation = [165 200 425]; % A NIfTI voxel coordinate above left parietal bone
ctxTarget = [195 200 395]; % A NIfTI voxel coordinate 45 degrees

% Ultrasound transducer parameters
transducer.focalLength_m = 0.03;    % [m]
transducer.freq_MHz = 0.5;          % [MHz]
transducer.source_mag_Pa = 0.66e6;  % [Pa]

% % Upscaling
%   Choose how much to scale the volume by
scale = 2; % Integer to scale up by
%   Note: Scale is only 2 here for speed and because this volume has a
%   smaller than average voxel width (0.5 mm)

% % Trimming
%   Trim to save resources
trimSize = 512; % Scalar or 3-element vector (integers)
%   Desired final volume size after trimming of volume.
%   Scalar: Volume will be cube with given trimSize.
%   Vector: Volume size will be trimmed to match trimSize.
%   Note: It is strongly suggested that elements of trimSize be powers of 2
%   (e.g. 128, 256, 512), due to k-Wave's computational method of solving
%   acoustic simulations.

% % Reorientation
%   Set whether to reorient the volume to reduce the effect of aliasing
reorientToGrid = true; % Boolean (default: false)
%   If set to true, volume will be rotated in 3D space and interpolated
%   such that the trajectory defined by the two NIfTI "target" and
%   "scalpLocation" is aligned orthogonally to the computational grid
%
%   This is especially helpful when at a significant angle to the
%   orthogonal grid of the volume (as our 45-degree angle ultrasound
%   trajectory is here)

% % Mask smoothing
%   Set whether to perform additional smoothing step
initialSmooth = true;
%   If set to true, an initial smoothing of the skull mask will be
%   performed before doing any other processing. Uses morphological image
%   processing (morphological close followed by morphological open)
%
%   In this example, including this step will remove some of the small
%   'noise' of small, noncontiguous stray voxels that were left behind by
%   process used to make this skull volume.

%
CFLnumber = 0.3;

% Acoustic properties
%   Skull
skull = struct;
skull.density       = 1732; % [kg/m^3]
skull.speed         = 2850; % [m/s]
skull.alphaCoeff    = 8.83; % [dB/(MHz^y cm)]

%   AlphaPower
alphaPower = 1.43;

% % Run tusx_sim_setup
%   This is TUSX's central function.
[kgrid, medium, source, sensor, input_args, infoStruct, grids] =...
    tusx_sim_setup(skullMask_filename, scalpLocation, ctxTarget, scale, alphaPower,...
    'CFLnumber', CFLnumber, 'skull', skull,...
    'reorientToGrid', reorientToGrid, 'trimSize', trimSize,...
    'initialSmooth', initialSmooth);

% % Feed TUSX outputs into k-Wave
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, sensor, input_args{:});

%% Visualize

% Convert vector to volume
p_max = unmaskSensorData(kgrid, sensor, sensor_data.p_max);

% Open volume in volumeViewer
volumeViewer(p_max);

% If simulation results look "off", try increasing the spatial resolution
% of the simulation by increasing the scale.

% Improvements could be made to this tutorial, if requested.