function [startingPoint,cropSize,forFSLROI] = cropNiftiToMatch(niftiToCrop,templateNifti)
%CROPNIFTITOMATCH Crops nifti to match cropped template
%   [startingPoint,cropSize,forFSLROI] = cropNiftiToMatch(niftiToCrop, templateNifti)
%
%   Use case: If you manually cropped a mask file, and you want to trim the
arguments
    niftiToCrop (1,:) char % File path for unedited NIfTI volume
    templateNifti (1,:) char % File path for cropped NIfTI volume
end
% Account for removed voxels
%   Get voxel coordinate to account for shift (where crop will start)
%   Determined by lining up scanner anatomical coordinates
startingPoint = voxelShift(niftiToCrop, templateNifti);
if any(startingPoint < 0)
    error('Volume to crop is not wholly contained within template volume');
end

cropSize = imageSize(templateNifti); % Image size: template nifti

% Put into single 1x6 matrix: [Voxel_dim1 Size_dim1 Voxel_dim2...]
%   Format needed for FSL function: fslroi
forFSLROI = stitch(startingPoint, cropSize);
end

function output = stitch(vector1, vector2)
% STITCH Stitches two equally sized vectors together
%   Example:
%       vector1 = [11 33 55];
%       vector2 = [22 44 66];
%       
%       output  = [11 22 33 44 55 66];

% Transpose to column vectors
if iscolumn(vector1)
    vector1 = vector1';
end
if iscolumn(vector2)
    vector2 = vector2';
end

temp = vertcat(vector1, vector2);
output = temp(:);

% Output as row vector
if iscolumn(output)
    output = output';
end
end