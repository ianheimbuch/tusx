function combinedMask = viewTransducerPlacement_labels(densityVol, sourceP_mask)
%VIEWTRANSDUCERPLACEMENT Make combined skull and transducer mask
%   For use in QC of transducer placement for TUSX
arguments
    densityVol (:,:,:)
    sourceP_mask(:,:,:) logical
end
densities = unique(densityVol); % Get skull, brain densities of binary mask

if length(densities) ~= 2
    error('Function assumes binary mask');
end

brain.density = min(densities); % Lower density option is brain
skull.density = max(densities); % Higher density option is skull

% Turn mask into logical
%   by subtracting by lower of two values and dividing by the difference
%   between the two.
skullMask = logical((densityVol - brain.density)/(skull.density-brain.density));

% Make combined label volume with both skull and transducer masks
combinedMask = zeros(size(skullMask), 'uint8');
combinedMask(skullMask) = 17; % 17 to match BrainSuite skull label
combinedMask(sourceP_mask) = 25; % 25 (no conflicts in BrainSuite)
end
