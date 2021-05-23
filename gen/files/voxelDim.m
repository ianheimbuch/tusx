function [dimensions,TR,SpaceUnits] = voxelDim(fileName)
%VOXELDIM Return voxel dimensions of a nifti file
%   Input: filename of nifti file
%   Output:
%       voxelDimensions: X, Y, and Z dimensions in mm
%       TR: TR in seconds
try % Try with Image Processing Toolbox
    info = niftiinfo_gz(fileName);
    dimensions = info.PixelDimensions;
    TR = info.raw.pixdim(5);
    SpaceUnits = info.SpaceUnits;
catch % Else use load_untouch_header_only
    hdrInfo = load_untouch_header_only(fileName);
    dimensions = hdrInfo.dime.pixdim(2:4);
    TR = hdrInfo.dime.pixdim(5);
end
end

