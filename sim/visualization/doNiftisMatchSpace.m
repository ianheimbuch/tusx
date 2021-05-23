function result = doNiftisMatchSpace(nii1, nii2)
%doNiftisMatchSpace Checks if two nifti files designated are of the same
%image and space. As in:
%   Match image size
%   Match voxel dimensions
%   Match scanner anatomical (transform matrix)

% Scanner anatomical grids are aligned
shift = voxelShift(nii1, nii2);
if any(shift ~= 0)
    result = false;
    return
end

% Image size
if ~all(imageSize(nii1) == imageSize(nii2))
    result = false;
    return
end

% Voxel dimensions
threshold = 1/20; % mm
if ~doDimsMatch(nii1, nii2, threshold)
    result = false;
    return
end

% If none of checks returned false:
result = true;
end

function TorF = doDimsMatch(nii1, nii2, threshold)
deltas = voxelDim(nii1) - voxelDim(nii2);
if any(deltas > threshold)
    TorF = false;
else
    TorF = true;
end
end