function [Location_ndgridGridPts, linearInd] = closestPointFinder(...
    SbjSpaceVoxelLocation, X_Grid, Y_Grid, Z_Grid)
%closestPointFinder: Find ndgrid position of closest subject-specific voxel
%   Input: 
%       SbjSpaceVoxelLocation: Voxel location (in subject NIfTI voxel
%                              space) as 3-element array.
%       X_Grid: ndgrid of scaled/trimmed X coordinates
%       Y_Grid: ndgrid of scaled/trimmed Y coordinates
%       Z_Grid: ndgrid of scaled/trimmed Z coordinates
%   Output:
%       Location within 3D matrix (subscripted matrix indices)
%
%   "Closest" algorithm: The index with the smallest sum of the absolute
%   differences for each dimension
arguments
    SbjSpaceVoxelLocation (1,3) single {mustBeNumeric}
    X_Grid (:,:,:)
    Y_Grid (:,:,:)
    Z_Grid (:,:,:)
end
vox.x = SbjSpaceVoxelLocation(1); % Put into struct for ease of reading
vox.y = SbjSpaceVoxelLocation(2);
vox.z = SbjSpaceVoxelLocation(3);

% Get absolute deltas from target coordinates
delta.x = abs(single(X_Grid) - single(vox.x));
delta.y = abs(single(Y_Grid) - single(vox.y));
delta.z = abs(single(Z_Grid) - single(vox.z));

% Log smallest delta value for each dim
delta.min.x = min(delta.x(:));
delta.min.y = min(delta.y(:));
delta.min.z = min(delta.z(:));

% Sum delta matrices
%   So can find index with accurate point in all three grids
delta.sum = delta.x + delta.y + delta.z;
%   Log smallest delta value for summed
[delta.min.sum, linearInd] = min(delta.sum(:)); % Index Method 1

% Loop through deltas. Output warning if high delta
%   Threshold of 1 only works because function is meant for grids with
%   steps of 1 (voxel indices)
%       If function were to be used with grids of different step sizes,
%       threshold value would have to be changed to match grid step size
if delta.min.x > 1 || delta.min.y > 1 || delta.min.z > 1
    warning(strcat('Warning: pointFinder could not find a good match. ',...
        ' Absolute deltas between grids and target coordinates were: ',...
        num2str(delta.min.x),',', num2str(delta.min.y),',',num2str(delta.min.z)))
end

% % Return subscripted matrix indices!
% Get subscripts (coordinates for each dimension) from linear index
[pt.x, pt.y, pt.z] = ind2sub(size(X_Grid),linearInd);

Location_ndgridGridPts = [pt.x, pt.y, pt.z];
end