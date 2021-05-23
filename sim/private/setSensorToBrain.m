function sensorMask = setSensorToBrain(brainMaskNifti, skullNifti,...
    scale, limits, opt)
%setSensorToBrain Set sensor struct to only record values within given
% brain mask
%   Import brain mask 
%   Assure match with skull mask
%   Reorient to match (if necessary)
%   Trim, scaled to match
%       Run same functions as skull mask
%   
%   For simulation3D_setup()
%
%   Optional name-value pairs:
%       reorientToGrid: Logical
%       scalp:          Three-element vector
%       target:         Three-element vector
%
%       scalp and target are ignored unless reorientToGrid is set to true
arguments
    brainMaskNifti      (1,:) char
    skullNifti          (1,:) char
    scale               (1,1)           {mustBeInteger}
    limits              
    opt.reorientToGrid  (1,1) logical   {mustBeNumericOrLogical} = false
    opt.scalp           (3,1) double    {mustBeNumeric, mustBeReal}
    opt.target          (3,1) double    {mustBeNumeric, mustBeReal}
end
% Check original nifti volumes match
if ~doNiftisMatchSpace(brainMaskNifti, skullNifti)
    error('skullNifti and brainMaskNifti files do not match')
end
brainMask = loadAndAddNiftiInfo(brainMaskNifti);
% Rotation, if necessary
if opt.reorientToGrid
    brainMask = reorientToGrid(brainMask, opt.scalp, opt.target, brainMaskNifti);
end
% Do trimming, scaling, etc. to match what was done with skull volume
brainMask = makeTrimmedMask(brainMask, limits);
brainMask = scaleAndSmooth(brainMask, scale, brainMaskNifti,...
    false, opt.reorientToGrid); % isWater = false b/c always processes a brain mask
brainMask = trimToEven(brainMask);
sensorMask = brainMask.mask;
end