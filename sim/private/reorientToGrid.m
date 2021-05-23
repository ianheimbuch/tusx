function [new, affines] = reorientToGrid(nifti, scalp, target, mask_filename, options)
%reorientToGrid Wrapper function for simulation3D_setup
%   Wrapper of gridRotation()
%
% Input:
%   nifti:  nifti structure from simulation3D_setup
%   scalp:  from simulation3D_setup
%   target: from simulation3D_setup
%
%   Optional:
%       interpMethod: Interpolation method that will be used for rotated
%       volumes. 
%
% Output:
%   new:    Structure of same format as 'nifti' structure from input
%   Fields:
%   .Xgrid, .Ygrid., .Zgrid: By-voxel coordinates of ORIGINAL NIfTI voxel
%   indices coordinates. Included so that may still reference location
%   based on original NIfTI index found with original NIfTI volume
arguments
    nifti struct
    scalp (1,3) {mustBeInteger}
    target (1,3) {mustBeInteger}
    mask_filename (1,:) char
    options.interpMethod (1,:) char = 'linear' % Passed to gridRotation -> imwarp
end
[B, affines] = gridRotation(nifti.mask, target, scalp, mask_filename,...
    'interpMethod', options.interpMethod);

% To-do: Rebuild nifti structure
new = struct;
new.mask = B;
new.voxelDimensions = nifti.voxelDimensions;
new.voxelDimensions_unit = nifti.voxelDimensions_unit;
new.size = size(new.mask);

% Build grid: OLD Nii Coordinates
%   Step 1: Make ndgrids with NEW Nii Coordinates (per voxel)
indexOrigin = getNiftiIndexOrigin(mask_filename); % From NIfTI file
imageLimits = new.size - 1 + indexOrigin; % -1 to account for inclusion/exclusion
[Xgrid, Ygrid, Zgrid] = ndgrid(...
    indexOrigin:imageLimits(1),...
    indexOrigin:imageLimits(2),...
    indexOrigin:imageLimits(3));
%   Step 2: Apply transformation matrix to NEW Nii Coordinates
% Consolidate ndgrids into single 3xN matrix
newNii = [Xgrid(:)'; Ygrid(:)'; Zgrid(:)'; ones(size(Xgrid(:)'))];
% Matrix multiplication to get old NII coordinates
oldNii = affines.newNii2oldNii * newNii; % Matrix multiplication
% Reshape
new.Xgrid = reshape( oldNii(1,:), new.size );
new.Ygrid = reshape( oldNii(2,:), new.size );
new.Zgrid = reshape( oldNii(3,:), new.size );

% Build grid: Scanner Anatomical
sa = affines.newNii2scanAnat * newNii; % Matrix multiplication
scanAnat = struct;
scanAnat.Xgrid = reshape( sa(1,:), new.size ); % Reshape back to 3D matrix
scanAnat.Ygrid = reshape( sa(2,:), new.size );
scanAnat.Zgrid = reshape( sa(3,:), new.size );

new.scanAnat = scanAnat;
new.affines = affines; % Include affine matrices as a field
end