function voxCoor = scanAnat2vox(transformMat, scanAnatCoordinates)
%scanAnat2vox Find voxel coordinate from scanner anatomical cooridnate
%   scanAnat2vox(transformMat, voxelCoordinates)
%   transformMat: transform matrix gotten directly from the nifti header
%       Can get it via load_untouch_transform_mat()

% Check and transpose transformation matrix (if necessary)
if transformMat(end) ~= 1
    error('Improper transformation matrix');
elseif any(size(transformMat) ~= [4 4])
    error('Improper transformation matrix');
elseif any(transformMat(4,1:3) ~= 0)
    transformMat = transformMat'; % Try transposing first
    if any(transformMat(4,1:3) ~= 0)
        error('Improper transformation matrix');
    end
end

% Get inverse of the transform matrix.
%   Inverse of the transform matrix is how you go the other direction
%   (scanner anatomical to voxel coordinate)
inverseTransformMatrix = inv(transformMat);
voxCoor = vox2scanAnat(inverseTransformMatrix, scanAnatCoordinates);
end

