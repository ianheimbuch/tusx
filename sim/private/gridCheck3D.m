function gridCheck3D(dim1Grid,dim2Grid,dim3Grid)
%GRIDCHECK Checks 3D coordinate grid is oriented as one would expect
%   Returns error if not
%   Only check integer grids (which would not have been rotated)
%
%   Warning: This test case is NOT exhausted. It is quickly made as a
%   casual safeguard.

% length(unique(scaled.grids.Zscaled));
% size(scaled.grids.Zscaled);
if isinteger(dim1Grid)
    intGridCheck(dim1Grid, 1);
end
if isinteger(dim2Grid)
    intGridCheck(dim2Grid, 2);
end
if isinteger(dim3Grid)
    intGridCheck(dim3Grid, 3);
end
end

function intGridCheck(grid, dim)
    % Take example slice
    %   Correct dimension to slice along depends on the dimension
    switch dim
        case 1
            exSlice = squeeze(grid(1,:,:));
        case 2
            exSlice = squeeze(grid(:,1,:));
        case 3
            exSlice = squeeze(grid(:,:,1));
        otherwise
            error('Invalid dimension given. Must be 1, 2, or 3');
    end
    % Check that all values in that slice are the same
    if length(unique(exSlice)) > 1
        error('Grid is not correctly oriented')
    elseif size(grid,dim) ~= length(unique(grid))
        error('Grid is not correctly oriented');
    end
end