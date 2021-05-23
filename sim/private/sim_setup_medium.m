function medium = sim_setup_medium(o, p, scaledMask, brain, skull, water, alphaPower)
% sim_setup_medium Helper function for tusx_sim_setup
%   Sets 'medium' struct needed for k-Wave
arguments
    o                       struct
    p                       inputParser
    scaledMask (:,:,:)      {mustBeNumericOrLogical}
    brain                   struct
    skull                   struct
    water
    alphaPower (1,1) double {mustBeNumeric}
end
medium.alpha_power = alphaPower;       % [y of alpha coeff]
if medium.alpha_power == 1
    medium.alpha_mode = 'no_dispersion'; % Necessary for power of 1
end

% % Implement medium properties:
% Make medium matrices that match size of the volume
%   'medium' struct must be initiated here regardless of whether a brain or
%   water simulation
medium.sound_speed = brain.speed * ones(size(scaledMask));     % [m/s]
medium.density = brain.density * ones(size(scaledMask));       % [kg/m^3]
medium.alpha_coeff = brain.alphaCoeff * ones(size(scaledMask));% [dB/(MHz^y cm)]

% % Set rest of medium properties
if o.isWater % If this is a water simulation...
    medium = setMediumToWater(medium, water); % Override medium properties
else
    % % SET SKULL PROPERTIES
    medium = setSkullProperties(medium, scaledMask, skull);

    % Add noise to skull's sound speed (if set)
    if o.createSkullNoise
        medium = addNoise_sim3D(medium, scaledMask, skull, p.Results.skullNoiseMag);
    end

    % Smooth medium properties (if set)
    if o.applySmoothing
        medium = smoothMedium(medium, o.kernelWidth);
    end
end
end