function t1 = ...
    tusx_sim_t1Export(t1Nifti, scalpLocation, ctxTarget, scale, alphaPower, varargin)
%tusx_sim_t1Export Produces volume to match mask made in tusx_sim_setup()
%   This function mirrors initial steps done in simualtion3D_setup() in
%   which a skull mask volume is rotated and/or upscaled. Process here
%   allows one to produce produce a structural volume that matches
%   transformations done to the mask (thereby matching the simulated
%   pressure volume)
%
%   This function can (and should) take the exact same inputs as those
%   provided to tusx_sim_setup() for an image's respective simulation.
%
%   simulation3D_t1Export(t1Nifti, scalpLocation, ctxTarget,
%       scale, alphaPower)
%   
%   Output: t1
%       Structure with the following fields:
%           'grids'
%           'size'
%           'voxelDimensions'
%           'voxelDimensions_unit'
%           'affines'
%           'img'
%
%   t1Nifti:        File path to nifti file
%   target:         'CalcarineSulcus' or 'HandKnob'
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
%   runOnGPU:       (Optional; default: false) Boolean.
%   
%   Optional Name-Value Pairs:
%
%   'coerceImageToBinary': Boolean. Default: false
%                          Coersion to binary is avoided in
%                          simulation3D_t1Export by default so that
%                          structural image data stays intact. Setting this
%                          option would convert all inputs into a binary
%                          mask. As such, it is suggested this only be set
%                          to true if the input ('t1Nifti') is a binary
%                          mask
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
%   'transducer': Structure of values of transducer
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
%   'initialKernelRadius': Option to set radius of sphere used to perform
%                          initialSmooth process. Unit: Voxels (Default: 1,
%                          which is a safe bet since this is a first pass)
%
%   Toolboxes:  Image Processing Toolbox
%               Paralel Processing Toolbox
%               k-Wave Toolbox (http://www.k-wave.org)
%                   Copyright (C) 2009-2017 Bradley Treeby
%   Add-ons:    Tools for NIfTI and ANALYZE image, v. 1.27 by Jimmy Shen
%
%   Ian Heimbuch
arguments
    t1Nifti               char
    scalpLocation   (1,3)           {mustBeNumeric}
    ctxTarget       (1,3)           {mustBeNumeric}
    scale           (1,1)           {mustBeInteger, mustBePositive}
    alphaPower      (1,1)           {mustBeNumeric} = 1
end
arguments (Repeating)
    varargin
end
warning('This function, while public, has not been heavily vetted.')
% Parse inputs
%   transducerSpecs, brain, and skull: structures that specify respective
%   acoustic parameters have defaults but they can be replaced as pair-wise
%   optional inputs
%   o: structure of mostly boolean flag fields
%       runOnGPU, applySmoothing, restrictSensorToBrain, createSkullNoise,
%       isWater, isBrain
%       Optional: kernelWidth (numeric; set if applySmoothing == 1)
[~, ~, ~, ~, ~, ~, o, p] = parse_inputs(t1Nifti, alphaPower, varargin{:});

% Override input:
o.initialSmooth = false; % So structural image is not smoothed

t1 = sim_setup_volumePrep(o, p, t1Nifti,...
    scalpLocation, ctxTarget, scale, 'coerceImageToBinary', false);
%   coerceImageToBinary == false so T1 image data stays intact

% Rename t1.mask to t1.img
t1 = renameT1Field(t1);

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
addOptional(p, 'runOnGPU', default.runOnGPU, @islogical);
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

function t1 = renameT1Field(t1)
t1.img = t1.mask;
t1 = rmfield(t1, 'mask');
end

