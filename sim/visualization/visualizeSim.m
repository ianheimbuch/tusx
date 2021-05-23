function combined = visualizeSim(simMat, maskMat)
% Combination of simulation (pressure) matrix and mask (brain or skull) for
% purupose of visualization
simMax      = max(simMat(:));
maskLevel   = simMax / 10; % Set intensity will add mask as
maskMat     = single(maskMat) .* maskLevel;
combined    = simMat + maskMat;
end

function markedMask = addSingleMark(mask, index, numericLabel)
% mask: 3D matrix mask
% index: Linear index
% numericLabel: unsigned integer label for voxel (e.g. 001, 002, etc.)
mask(index) = uint8(numericLabel);
markedMask = uint8(mask);
end

function markedMask = labelMask(labelVolume, index, numericLabel)
% labelVolume:  3D matrix mask
% index:        Linear index OR logical matrix of same size
% numericLabel: Unsigned integer label for voxel (e.g. 001, 002, etc.)
if ~isnumeric(numericLabel) % Check numericLabel is valid
    error('numeric label (3rd input) must be a numeric scalar');
end

if (length(index) > 1) && ~islogical(index)
    errorMessage = strcat('If indexing variable is a matrix (',...
        'and not a linear index) it must be of type logical');
    error(errorMessage);
end

labelVolume(index) = uint8(numericLabel);
markedMask = uint8(labelVolume);
end