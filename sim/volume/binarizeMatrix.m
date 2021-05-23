function exMask = binarizeMatrix(densityMask)
%BinarizeMatrix Make 2-value 3D matrix into logical (0 and 1)
%   For use in visualization
densities = unique(densityMask); % Get skull, brain densities of binary mask

if length(densities) == 1
    exMask = logical(densityMask);
    exMask(:) = false;
elseif length(densities) == 2
    brain.density = min(densities); % Lower density option is brain
    skull.density = max(densities); % Higher density option is skull

    % Turn mask into logical
    %   by subtracting by lower of two values and dividing by the difference
    %   between the two.
    exMask = logical((densityMask - brain.density)/(skull.density-brain.density));
else
    error('Function assumes binary mask');
end
end