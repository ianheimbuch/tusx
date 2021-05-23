function mmGrid = niftiScanAnatGrid(niftiFile)
% niftiScanAnatGrid Creates grid of scanner anatomical coordinates
%   mmGrid = niftiScanAnatGrid(niftiFile)
%
%   Uses transform matrix stored in nifti header
%       Note on transform matrix:
%           Transform matrix is same as the nifti header
%           This function does NOT use SPM's spm_vol().mat, which returns a
%           slight different matrix

% Get grids of voxel coordinates
vox = struct;
[vox.Xgrid, vox.Ygrid, vox.Zgrid] = niftiGrid(niftiFile);

% Get transformation matrix
try
    tMat = load_niftiinfo_transform_mat(niftiFile);
catch
    try
        tMat = load_untouch_transform_mat(niftiFile);
    catch
        error('Failed to load transform matrix from nifti file');
    end
end

voxArray = [vox.Xgrid(:)';... % Make wide array with each coordinate triple
            vox.Ygrid(:)';... % as a column.
            vox.Zgrid(:)';...
            ones(size(vox.Xgrid(:)'))]; % Bottom row is ones
voxArray = double(voxArray);
scanArray = tMat * voxArray; % Apply transformation matrix to wide array

gridSize = size(vox.Xgrid);

% Consolidate into struct
mmGrid = struct;
mmGrid.Xgrid = reshape(scanArray(1,:), gridSize); % Reshape into 3D matrix
mmGrid.Ygrid = reshape(scanArray(2,:), gridSize);
mmGrid.Zgrid = reshape(scanArray(3,:), gridSize);
end