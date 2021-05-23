function noisySkull = addNoiseToSkull(mediumSpeed, skullMask, skullSpeed, noiseMagnitude)
%addNoiseToSkull Add noise to skull
%   Assumes you already have a skull mask
%   mediumSpeed = matrix of sound speeds (medium.sound_speed)
%
%   Note: This function currently only changes the speed of sound. Ideally,
%   it would change both the speed of sound and density in unison, since
%   the two are correlated.

% Check inputs
if ~islogical(skullMask)
    error('skullMask must be of type logical');
elseif ~isscalar(skullSpeed)
    error('skullSpeed must be scalar')
elseif ~isscalar(noiseMagnitude)
    error('noiseMagnitude must be scalar')
end

% Produce noise volume
rng('default'); % Set randn seed, to keep reproducible *(See Note)
noiseVolume = (skullSpeed .* noiseMagnitude) .* randn(size(skullMask)); 
% Restrict noise to skull
skullNoise  = skullMask .* noiseVolume;
% Add that noise to the original matrix
noisySkull  = mediumSpeed + skullNoise;

% *Note: rng('default') will only make keep noise (noiseVolume) the same
% for a specific volume size. Also, different skull masks will encompass
% different parts of the noiseVolume, so repoducibilty only exists within
% subject (and scale, cropping, etc.)
end