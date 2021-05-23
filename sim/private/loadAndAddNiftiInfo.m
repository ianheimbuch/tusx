function nifti = loadAndAddNiftiInfo(niftiFile, saveToDrive, overwrite, coerceToBinary)
%loadAndAddNiftiInfo Avoids creating gridded structure if file has already
%been created
% Helper function for simulation3D_setup()
%   Consolidated multiple lines under "SKULL IMPORT and TRIMMING"
%   Consolidation into function allows for running multiple times, such as
%   for skull mask and brain mask
arguments
    niftiFile (1,:) char
    saveToDrive (1,1) logical {mustBeNumericOrLogical} = false
    overwrite   (1,1) logical {mustBeNumericOrLogical} = false
    coerceToBinary (1,1) logical {mustBeNumericOrLogical} = true
end

% Load nifti image
nifti.mask = maskread_imgread(niftiFile, coerceToBinary);

% Note some additional info
nifti.voxelDimensions = voxelDim(niftiFile);
nifti.voxelDimensions_unit = 'millimeters';
nifti.size = size(nifti.mask);
        
% Create meshgrids for voxel coordinates
[nifti.Xgrid, nifti.Ygrid, nifti.Zgrid] = niftiGrid(niftiFile);

% % Create grids for scanner anatomical coordinates
nifti.scanAnat = niftiScanAnatGrid(niftiFile);

% Add original affine transformation matrix
nifti.affines.oldNii2scanAnat = load_niftiinfo_transform_mat(niftiFile);
% Add initial oldNii2newNii matrix (is changed later)
nifti.affines.oldNii2newNii = eye(4); % Identity matrix because is same
nifti.affines.newNii2oldNii = inv(nifti.affines.oldNii2newNii);
% Add initial scanAnat2newNii matrices (changed later)
nifti.affines.newNii2scanAnat = nifti.affines.oldNii2scanAnat; % Because same as oldNii
nifti.affines.scanAnat2newNii = inv(nifti.affines.newNii2scanAnat);

% Save .mat, if wanted
if saveToDrive
    saveNiftiMat(niftiFile, nifti, overwrite);
end
end