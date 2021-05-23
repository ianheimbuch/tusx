function mmCoor = vox2scanAnat(transformMat, voxelCoordinates)
% vox2scanAnat Convert a single voxel-coordinate triplet to
%   scanner anatomical space mm coordinates
%   Checks tansform matrix, too
%   mmCoor = vox2scanAnat(transformMat, voxelCoordinates)
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
% Assure voxArray is a vertical (column) vector
if isrow(voxelCoordinates)
    voxelCoordinates = voxelCoordinates';
end

voxArray = double([voxelCoordinates; 1]);
result = transformMat * voxArray;
mmCoor = result(1:3)';
end