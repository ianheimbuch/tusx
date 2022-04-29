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
%   towards the skull.
scalpLocation = [145 200 440]; % A NIfTI voxel coordinate above left parietal bone
ctxTarget = [185 200 380]; % A NIfTI voxel coordinate (~33 degree angle)
%   For your own data, if you had a brain target you were interested in,
%   you could choose voxel coordinate as 'ctxTarget'.

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
trimSize = 256; % Scalar or 3-element vector (integers)
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

% % CPU or GPU
%   Set whether to run k-Wave on an NVIDIA GPU or not
runOnGPU = true;
%   Running k-Wave on a CUDA-capable GPU is IMMENSELY faster than running
%   on a CPU. If you have an NVIDIA GPU, consider running it on your GPU.
%       Example (tutorial at 2x scale):
%           GPU: RTX 3070 Ti:   ~7.5 min
%           CPU: i7-6700K:      ~106 min

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
    'initialSmooth', initialSmooth, 'runOnGPU', runOnGPU);

%% Visualize positioning
% Create a label volume with skull and ultrasound transducer
skullAndTransducer = viewTransducerPlacement_labels(medium.density, source.p_mask);

% Open label volume in Volume Viewer app
volumeViewer(skullAndTransducer, 'VolumeType', 'Labels')

%% Feed TUSX outputs into k-Wave
sensor_data = kspaceFirstOrder3D(kgrid, medium, source, sensor, input_args{:});

%% Visualize

% Convert vector to volume
if runOnGPU
    % Gather results from GPU back to CPU normal workspace
    sensor_data.p_max   = gather(sensor_data.p_max);
    sensor_data.p_rms   = gather(sensor_data.p_rms);
    sensor_data.p_final = gather(sensor_data.p_final);
end

% Reshape sensor data back into 3D volume
p_max = unmaskSensorData(kgrid, sensor, sensor_data.p_max);

% Render volume in figure window
labelvolshow(skullAndTransducer, p_max, 'VolumeThreshold', 0.075);

% If simulation results look "off", try increasing the spatial resolution
% of the simulation by increasing the scale.

% The tutorial can be expanded, if requested.