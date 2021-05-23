function voxWidth = voxelWidth_cube(nifti)
%VOXELWIDTH_CUBE Returns voxel width, if voxel is a cube
%   Requires Image Processing Toolbox

% If input is a string/char, assume it's a file name
if ischar(nifti) || isstring(nifti)
    T1wInfo = niftiinfo(T1wFile);
else % If not, assume it's an already imported by niftiinfo()
    T1wInfo = nifti;
end

if ~strcmpi(T1wInfo.SpaceUnits, 'Millimeter')
    error('SpaceUnits not millimeters. Function assumes millimeters');
end

dims = T1wInfo.PixelDimensions;

% % Voxels must be cubes (with current version)
% Find biggest difference in voxel dimensions
dimsDiscrepancy = max(max(dims - dims'));

% Check if it's a cube, by making sure biggest difference in voxel
% dimension is less than a hundredth of a millimeter
if dimsDiscrepancy < 0.01
    voxWidth = round(mean(dims(1:3)),2); % mm, rounded to nearest hundredth
else
    error('Voxels must be cubes (with current version)');
end
end

