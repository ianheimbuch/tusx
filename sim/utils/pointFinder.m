function [Location_ndgridGridPts] = pointFinder( SbjSpaceVoxelLocation, X_Grid, Y_Grid, Z_Grid)
%pointFinder function: Find ndgrid position of subject-specific voxel
%   Input: 
%       SbjSpaceVoxelLocation: Voxel location (in subject space) as 3-element array.
%       X_Grid: ndgrid of scaled/trimmed X coordinates
%       Y_Grid: ndgrid of scaled/trimmed Y coordinates
%       Z_Grid: ndgrid of scaled/trimmed Z coordinates
%   Output:
%       Location within 3D matrix (subscripted matrix indices)
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
[delta.min.sum, correctInd_alt] = min(delta.sum(:)); % Index Method 1

% Loop through deltas. Output warning if high delta
if delta.min.x > 1 || delta.min.y > 1 || delta.min.z > 1
    warning(strcat('Warning: pointFinder could not find a good match. ',...
        ' Absolute deltas between grids and target coordinates were: ',...
        num2str(delta.min.x),',', num2str(delta.min.y),',',num2str(delta.min.z)))
end

correctEl = delta.x == delta.min.x & delta.y == delta.min.y & delta.z == delta.min.z;

% Check correctEl is only choosing one array location:
if sum(correctEl(:)) < 1
    error('Element selection has failed. Less than one element selected.')
elseif sum(correctEl(:)) > 1
    error('Element selection has failed. More than one element selected.')
end

% % Return subscripted matrix indices!
%   Get linear index of the 1 true value in correctEl
correctInd = find(correctEl); % Index Method 2
% Get subscripts (coordinates for each dimension) from linear index
[pt.x, pt.y, pt.z] = ind2sub(size(X_Grid),correctInd);

% Check redundant index-finding methods match
%   Index Method 1 vs. Index Method 2
compareRedunantApproaches(correctInd, correctInd_alt);

Location_ndgridGridPts = [pt.x, pt.y, pt.z];
end

function compareRedunantApproaches(correctInd, correctInd_alt)
% Sanity check. Makes sure two possible indexing approaches result in
% matching answers
% (Error wrapper)
delta = abs(correctInd - correctInd_alt); % Abs diff between two indices
if delta >= 1 % If indices are not the same, ignoring rounding errors
    % Get name of main function (in case changed later)
    st = dbstack;
    fnName = st(2).name; % Name of function outside local function
    mess = ['Sanity check failed. Function ' fnName ' may be bugged'];
    error(mess)
end
end