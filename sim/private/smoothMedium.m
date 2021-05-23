function medium = smoothMedium(medium, kernelWidth)
% smoothMedium Smooths density, sound_speed, & alpha_coeff matrices
%   Performs gaussian smoothing with square kernel of width 'kernelWidth'
%   grid points on each of the three non-scalar medium matrices
%   
%   Used on acoustic medium structure as used in k-Wave's
%   kspaceFirstOrder3D function (also used in tusx_sim_setup)
%
%   Currently private because it does not currently deal with all
%   potential medium fields
kernelWidth = round(kernelWidth); % Rounds to an integer
if kernelWidth < 0
    error('kernelWidth must be positive')
elseif 0 == rem(kernelWidth, 2) % Is even
    error('kernelWidth must be an odd integer')
end

% Save original values (for reference)
if ~isfield(medium, 'original')     % If not yet created,
    medium.original    = medium;    % Save original medium values
end
    
medium.density     = smooth3(medium.density,     'gaussian', kernelWidth);
medium.sound_speed = smooth3(medium.sound_speed, 'gaussian', kernelWidth);
medium.alpha_coeff = smooth3(medium.alpha_coeff, 'gaussian', kernelWidth);
end