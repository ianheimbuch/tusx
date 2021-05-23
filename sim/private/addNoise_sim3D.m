function medium = addNoise_sim3D(medium, mask, skull, noiseMag)
% Wrapper function for addNoiseToSkull
%   Used in tusx_sim_setup()

% Save original values (for reference)
if ~isfield(medium, 'original')     % If not yet created,
    medium.original    = medium;    % Save original medium values
end

medium.sound_speed = addNoiseToSkull(medium.sound_speed, mask,...
    skull.speed, noiseMag);
end