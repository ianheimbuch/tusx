function voxelShiftArray = voxelShift(originalFile, croppedFile)
% voxelShift Voxel coordinate shift that is needed to account for removed
% slices
%   Uses scanner anatomical coordinates to calculate shift
%
%   voxelShiftArray = voxelShift(originalFile, croppedFile)
%
%   voxelShiftArray: Triplet of integers corresponding to the shift for X,
%   Y, and Z voxel coordinates
%   Example: If you want to fix a croppedFile's X_grid, Y_grid, and Z_grid
%   such that the scanner anatomical coordinates match originalFile's
%   voxel coordinates
%       shiftedX_grid = X_grid + voxelShiftArray(1)
%       shiftedY_grid = Y_grid + voxelShiftArray(2)
%       shiftedZ_grid = Z_grid + voxelShiftArray(3)
arguments
    originalFile (1,:) char % File path for unedited NIfTI volume
    croppedFile (1,:) char % File path for cropped NIfTI volume
end
orig.path = originalFile;
crop.path = croppedFile;

orig.mat = load_untouch_transform_mat(orig.path);
crop.mat = load_untouch_transform_mat(crop.path);

% Choose an example point in scanner anatomical space to use as a reference
% point betweeen the two:
scanAnatRef = chooseScanAnatRef(crop.mat);
scanAnatRefArray = [scanAnatRef; 1];    % Finds a reference since hardcoded
                                        % vox coord, like 0 0 0, might not
                                        % be in the smaller volume
tempOrig = inv(orig.mat)*scanAnatRefArray;
orig.voxAtScanAnatRef = tempOrig(1:3)';

tempCrop = inv(crop.mat)*scanAnatRefArray;
crop.voxAtScanAnatRef = tempCrop(1:3)';

voxelShiftArray = orig.voxAtScanAnatRef - crop.voxAtScanAnatRef;

% Check to make sure shift is an integer (reasonably close to integer)
threshold = 1/100;
differenceFromRound = abs(voxelShiftArray - round(voxelShiftArray));
if any(differenceFromRound > threshold)
    error('Error. Calculated voxel shift is not of integers');
end
voxelShiftArray = int64(voxelShiftArray);
end

function scanAnatRef = chooseScanAnatRef(cropMat)
% Return an scanner anatomical coordinate of the very first voxel (0 0 0)
% of the smaller (cropped) volume
temp = cropMat*[0; 0; 0; 1];
scanAnatRef = temp(1:3);
end