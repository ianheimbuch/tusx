function [kgrid, medium, source, sensor, input_args, infoStruct, grids] = ...
    tusx_sim_setup(skullNifti, scalpLocation, ctxTarget, scale,...
    alphaPower, varargin)
%TUSX_SIM_SETUP Prepare simulation for k-Wave
%
%   tusx_sim_setup(skullNifti, scalpLocation, ctxTarget,
%       scale, alphaPower)
%   tusx_sim_setup(skullNifti, scalpLocation, ctxTarget,
%       scale, alphaPower, Name, Value)
%
%   Outputs: [sensor_data, kgrid, medium, source, infoStruct]
%   
%   Inputs:
%
%   skullNifti:     File path to NIfTI file
%   scalpLocation:  3-element array of NIfTI voxel coordinates (fslX, fslY,
%                   fslZ). Example: [104,6,122]
%   ctxTarget:      3-element array of NIfTI voxel coordinates (fslX, fslY,
%                   fslZ). Example: [105,34,116]
%   scale:          Integer to scale up by (upscale resolution via nearest
%                   neighbor interpolation)
%   alphaPower:     y of alpha coeff. Dictates if dispersion is simulated.
%                   If alpha_power == 1, runs without dispersion.
%                       NOTE: Errors may occur if alphaPower is too close
%                       to (but not exactly) 1. For instance, alphaPower ==
%                       1 will run well. alphaPower == 1.01 will cause
%                       errors. alphaPower == 1.1 may be safer bet if
%                       dispersion is desired.
%   
%   Optional Name-Value Pairs:
%
%   'runOnGPU': Boolean. Default: false.
%   'brainMaskNifti': Paired with a string or character
%                     Presence restricts k-Wave sensor grid to brain mask
%                     (significantly reducing memory usage / runtime)
%   'CFLnumber': Courant-Friedrichs-Lewy (CFL) number
%                Default: 0.3
%   'brain': Structure of acoustic values for brain
%   'skull': Structure of acoustic values for skull
%   'water': Structure of acoustic values for water
%            If set, entire acoustic medium is set to values of water (no
%            skull)
%   'transducer': Structure of values of transducer. Fields:
%                   .focalLength_m: Focal length of the transducer
%                   .freq_MHz: Acoustic frequency [Hertz] of the transducer
%                   .source_mag_Pa: Magnitude [Pascals] of a single grid
%                   point of the transducer.
%   'record': Cell array of character arrays. To be passed to
%             kspaceFirstOrder3D as sensor.record
%             Default: {'p_final', 'p_max', 'p_rms'}
%   'reorientToGrid': Boolean (default: false)
%                     If set to true, volume will be rotated in 3D space
%                     and interpolated such that the trajectory defined by
%                     the two NIfTI "target" and "scalpLocation" is aligned
%                     orthogonally to the computational grid
%   'trimSize': Scalar or 3-element vector (integers)
%               Desired final volume size after trimming of volume.
%               Scalar: Volume will be cube with given trimSize.
%               Vector: Volume size will be trimmed to match trimSize.
%               Note: It is strongly suggested that elements of trimSize be
%               powers of 2 (e.g. 128, 256, 512), due to k-Wave's
%               computational method of solving acoustic simulations.
%   'skullNoiseMag': If set, gaussian noise is added to skull sound speed
%   'smoothKernelWidth': If set by user: Performs 3D gaussian
%                        smoothing of acoustic medium volume. Width of
%                        convolution kernel for smoothing is set to value
%                        of 'smoothKernelWidth'
%   'initialSmooth': If set to true, an initial smoothing of the skull mask
%                    will be performed before doing any other processing.
%                    Uses morphological image processing (morphological
%                    close followed by morphological open)
%   'initialKernelRadius': Option to set radius of sphere used to perform
%                          initialSmooth process. Unit: Voxels (Default: 1,
%                          which is a safe bet since this is a first pass)
%
%   Structure format for brain, water, or skull
%       Both:
%       .density                [kg/m^3]
%       .speed                  [m/s]
%       And one or more of the following:
%       .alphaCoeff             [dB/(MHz^y cm)]
%       .attenConstant_Np_m     [Np / m]
%       .attenConstant_dB_cm    [dB / cm]
%
%   WARNING: Default acoustic values are for 0.5 MHz. Due to adjustable
%   alpha power, acoustic values are not guaranteed to properly adjust to
%   frequencies other than 0.5 MHz. Consider setting your own acoustic
%   values always.
%
%   Website: www.TUSX.org
%
%   Toolboxes:  Image Processing Toolbox
%               Paralel Processing Toolbox
%               k-Wave Toolbox (http://www.k-wave.org)
%                   Copyright (C) 2009-2017 Bradley Treeby
%   Add-ons:    Tools for NIfTI and ANALYZE image, v. 1.27 by Jimmy Shen
%
% Copyright 2021 Ian S. Heimbuch
%   Open Source License: BSD-3-Clause (see LICENSE.md)
arguments
    skullNifti              char
    scalpLocation   (1,3)           {mustBeNumeric}
    ctxTarget       (1,3)           {mustBeNumeric}
    scale           (1,1)           {mustBeInteger, mustBePositive}
    alphaPower      (1,1)           {mustBeNumeric} = 1
end
arguments (Repeating)
    varargin
end

kWaveCheck; % Check that k-Wave is on MATLAB's search path

% Parse inputs
%   transducerSpecs, brain, and skull: structures that specify respective
%   acoustic parameters have defaults but they can be replaced as pair-wise
%   optional inputs
%   o: structure of mostly boolean flag fields
%       runOnGPU, applySmoothing, restrictSensorToBrain, createSkullNoise,
%       isWater, isBrain
%       Optional: kernelWidth (numeric; set if applySmoothing == 1)
[brainMaskNifti, CFLnumber, transducerSpecs, brain, skull, water, o, p] =...
    parse_inputs(skullNifti, alphaPower, varargin{:});

% Set parallel or not
CPUorGPU = setParallel(o.runOnGPU);

% Skull processing:
%   Import, Trimming, Upscaling
[scaled, limits] = sim_setup_volumePrep(o, p, skullNifti,...
    scalpLocation, ctxTarget, scale);

% =========================================================================
% SIMULATION SETUP
% =========================================================================
    
% Check voxel unit. Convert to meters, if needed
spacing_m = getSpacing_m(scaled.voxelDimensions, scaled.voxelDimensions_unit);

% Set the properties of the propagation medium    
medium = sim_setup_medium(o, p, scaled.mask, brain, skull, water, alphaPower);

% Create object of class kWaveGrid:
%   Computational grid on which simulations will be done
kgrid = kWaveGrid(size(scaled.mask,1), spacing_m.dim1,...
                  size(scaled.mask,2), spacing_m.dim2,...
                  size(scaled.mask,3), spacing_m.dim3);

% Create the time array for k-Wave
kgrid.makeTime(medium.sound_speed, CFLnumber);

% Transducer placement
[source.p_mask, transd_ind, target_ind] = transducerPlacement(scalpLocation,...
    ctxTarget,...
    scaled.grids.Xscaled,...
    scaled.grids.Yscaled,...
    scaled.grids.Zscaled,...
    transducerSpecs.focalLength_m,...
    spacing_m.dim1);

% % Set pressure pattern (transducer output)
%   Define time-varying sinusoidal source/s
source = sim_setup_sourceTraces(source, kgrid, medium, transducerSpecs);

% Adjust the pressure traces to match the desired focal length
%   NOTE: Currently uses the radius of curvature of the makeBowl() function
%   for the focal length here. Ideally there would be two focal lengths:
%   the curvature of radius for makeBowl() (transducerSpecs.focalLength_m)
%   and a focal length for focus(). Here we would need the focal length for
%   focus().
%
%   If transducerSpecs.focalLength_m is used as the focal length here, that
%   means sim_setup_sourceFocus is slightly refining the offsets
%   of the pressure delays to more accurately matched the aliased curve
source.p = sim_setup_sourceFocus(source, kgrid,...
    transd_ind, target_ind, transducerSpecs.focalLength_m);

% % Set sensor
%   Create a sensor mask covering the entire computational domain
sensor = struct; % Initialize
if o.restrictSensorToBrain
    sensor.mask = setSensorToBrain(brainMaskNifti, skullNifti, scale, limits,...
        'reorientToGrid', o.reorientToGrid,...
        'scalp', scalpLocation, 'target', ctxTarget);
    checkSensorMediumMatch(sensor, medium);
else
    sensor.mask = true(size(source.p_mask));
end
%   Set the record mode capture the final wave-field and the statistics at
%   each sensor point 
sensor.record = p.Results.record;

% Choose perfectly matched layer (PML) to avoid large prime factors
PMLSize = pmlPicker3D(kgrid);

% Assign the k-Wave input options
input_args = {'DisplayMask', source.p_mask, 'PMLInside', false, ...
    'PlotPML', false, 'DataCast', CPUorGPU, 'PlotSim', false, ...
    'PMLSize', PMLSize};

% Set note on 'ticks', if not created
if ~isfield(scaled, 'ticks')
    scaled.ticks = 'n/a';
end

% % Save additional info
infoStruct = struct;
% Acoustic parameters
infoStruct.acoustic.brain           = brain;
infoStruct.acoustic.skull           = skull;
infoStruct.acoustic.transducerSpecs = transducerSpecs;
infoStruct.acoustic.water           = water;
infoStruct.acoustic.isWater         = o.isWater;
infoStruct.acoustic.isBrain         = o.isBrain;
% Locations in new matrix
infoStruct.matrixIndices.target     = target_ind;
infoStruct.matrixIndices.transducer = transd_ind;
% Vectors of matrix tics (post-scale/trim, voxel and scanAnat)
infoStruct.dimensions.ticks_vox                     = scaled.ticks;
infoStruct.dimensions.scale                         = scale;
infoStruct.original.limits_for_initial_subvolume    = limits;
infoStruct.original.niftiFile                       = skullNifti;
% Affine transformation matrices
infoStruct.affines = scaled.affines;
% kWave inputs
infoStruct.kWave.input_args = input_args;
infoStruct.kWave.CFLnumber  = CFLnumber;
% Input parameters
infoStruct.inputArguments.niftiFile     = skullNifti;
infoStruct.inputArguments.scalpLocation = scalpLocation;
infoStruct.inputArguments.ctxTarget     = ctxTarget;
infoStruct.inputArguments.scale         = scale;
infoStruct.inputArguments.alphaPower    = alphaPower;
infoStruct.inputArguments.CFLnumber     = CFLnumber;
infoStruct.inputArguments.parser        = p;
infoStruct.inputArguments.options       = o;
% Output grids
grids = struct;
grids.origNii.dim1 = scaled.grids.Xscaled;
grids.origNii.dim2 = scaled.grids.Yscaled;
grids.origNii.dim3 = scaled.grids.Zscaled;
end
%% Helper functions
function p = getDefaultParserObject
% Not using parse() to parse any required inputs at this time
p = inputParser;
default.brainMaskNifti      = ''; % Empty char array
default.runOnGPU            = false;
default.CFLnumber           = 0.3;
default.skullNoiseMag       = 0.1; % Skull noise magnitude
default.smoothKernelWidth   = 3;
default.brain               = getDefaultBrain;
default.skull               = getDefaultSkull;
default.transducer          = getDefaultTransducer;
default.water               = getDefaultWater;
default.record              = {'p_final', 'p_max', 'p_rms'};
default.reorientToGrid      = false;
default.trimSize            = 512;
default.initialSmooth       = false;
default.initialKernelRadius  = 1;
ischarORstring = @(x) ischar(x) || isstring(x);
isnumeric1or3 = @(x) isnumeric(x) & (length(x) == 1 | length(x) == 3);
addParameter(p, 'runOnGPU', default.runOnGPU, @islogical);
addParameter(p, 'brainMaskNifti', default.brainMaskNifti, ischarORstring);
addParameter(p, 'CFLnumber', default.CFLnumber, @isnumeric);
addParameter(p, 'skullNoiseMag', default.skullNoiseMag, @isscalar);
addParameter(p, 'smoothKernelWidth', default.smoothKernelWidth, @isscalar);
addParameter(p, 'brain', default.brain, @isstruct);
addParameter(p, 'skull', default.skull, @isstruct);
addParameter(p, 'transducer', default.transducer, @isstruct);
addParameter(p, 'water', default.water, @isstruct);
addParameter(p, 'record', default.record, @iscell);
addParameter(p, 'reorientToGrid', default.reorientToGrid, @islogical);
addParameter(p, 'trimSize', default.trimSize, isnumeric1or3);
addParameter(p, 'initialSmooth', default.initialSmooth, @islogical);
addParameter(p, 'initialKernelRadius', default.initialKernelRadius, @isscalar);
end

function [brainMaskNifti, CFLnumber, transducerSpecs, brain, skull, water, o, p]...
    = parse_inputs(skullNifti, alphaPower, varargin)
% Parse inputs
%   Not using parse() to parse any required inputs at this time
%       Using Arguments block for required inputs
p = getDefaultParserObject; % Contains inputParser object for this function
parse(p, varargin{:});      % Parse optional inputs

% % Consolidate boolean flags into a single struct
o = struct;

% Set runOnGPU based on whether included as an optional variable
o.runOnGPU = p.Results.runOnGPU;

% Set whether restrict sensor grid to the brain (for efficiency)
brainMaskNifti = p.Results.brainMaskNifti;
switch brainMaskNifti
    case ''
        restrictSensorToBrain = false;
    otherwise
        restrictSensorToBrain = true;
        % Check that the two niftis match
        if ~doNiftisMatchSpace(brainMaskNifti, skullNifti)
            error('skullNifti and brainMaskNifti files do not match')
        end
end

% Set CFL number (default is 0.3)
CFLnumber   = p.Results.CFLnumber;

% Set if should add noise to skull
%   Do if user provided a skull noise magnitude ('skullNoiseMag')
if any(strcmp(p.UsingDefaults, 'skullNoiseMag')) % If skullNoiseMag was NOT set
    createSkullNoise = false;
else
    createSkullNoise = true;
end

% Set if should smooth medium
%   Do if user provided a gaussian kernel width ('smoothKernelWidth')
if any(strcmp(p.UsingDefaults, 'smoothKernelWidth')) % If smoothKernelWidth was NOT set
    o.applySmoothing = false;
else % If smoothKernelWidth was set
    o.applySmoothing = true;
    o.kernelWidth = p.Results.smoothKernelWidth;
end

% Set transducer specifications
transducerSpecs = p.Results.transducer;

% Set brain and skull
brain = p.Results.brain;
skull = p.Results.skull;
% Set .alphaCoeff, in necessary
brain = addMissingAlpha(brain, transducerSpecs.freq_MHz, alphaPower);
skull = addMissingAlpha(skull, transducerSpecs.freq_MHz, alphaPower);

% Set if medium properties should be of water
if any(strcmp(p.UsingDefaults, 'water')) % If water was NOT set
    isWater = false;
    isBrain = true;
    water = 'not set';
else % If water was set
    isWater = true; % Medium will be set to all water
    isBrain = false;
    water = p.Results.water;
    water = addMissingAlpha(water, transducerSpecs.freq_MHz, alphaPower);
end

% Consolidate certain values into a single struct
o.restrictSensorToBrain = restrictSensorToBrain;
o.createSkullNoise = createSkullNoise;
o.isWater = isWater;
o.isBrain = isBrain;
o.reorientToGrid = p.Results.reorientToGrid;
o.initialSmooth = p.Results.initialSmooth;
o.initialKernelRadius = p.Results.initialKernelRadius;

% Give warning if trimSize is not a power of 2
if p.Results.trimSize ~= pow2(nextpow2(p.Results.trimSize))
    m1 = ['Given trimSize, [' num2str(p.Results.trimSize) ];
    m2 = '] is not a power of 2 (e.g. 256, 512). ';
    m3 = 'Seriously consider changing to next power of 2 found by ';
    m4 = 'the following: pow2(nextpow2(trimSize))';
    warning([m1 m2 m3 m4])
end

% Error if initialKernelRadius set but initialSmooth is not
if (o.initialKernelRadius == false) && ... % If initialSmooth == false and
        ~any(strcmp(p.UsingDefaults, 'initialKernelRadius')) % if kernal WAS set
    w1 = 'An initialKernelRadius value was provided, ';
    w2 = 'but initialSmooth was set to false.';
%     w3 = ' Initial smooth will NOT be run.';
    error([w1 w2]) % Could arguably be a warning, but it is at the start
end
end