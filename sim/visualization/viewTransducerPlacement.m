function combinedMask = viewTransducerPlacement(densityMask, sourceP_mask)
%VIEWTRANSDUCERPLACEMENT Make combined skull and transducer mask
%   For use in QC of transducer placement in simulation3D_batch pipeline
densities = unique(densityMask); % Get skull, brain densities of binary mask

if length(densities) ~= 2
    error('Function assumes binary mask');
end

brain.density = min(densities); % Lower density option is brain
skull.density = max(densities); % Higher density option is skull

% Turn mask into logical
%   by subtracting by lower of two values and dividing by the difference
%   between the two.
exMask = logical((densityMask - brain.density)/(skull.density-brain.density));

% Make combined mask of both skull and transducer masks
combinedMask = or(exMask, sourceP_mask);
end
