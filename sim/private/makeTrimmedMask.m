function trimmed = makeTrimmedMask(mStruct, limits)
% Trim mask structure (mStruct) to limits
% Consolidated multiple lines under "SKULL IMPORT and TRIMMING"
%   simulation3D_setup(): (trimming section)
%
% limits: Matlab subscript indices of extent of volume to be used
%
% makeTrimmedMask could maybe be turned into a public function if mask
% structure object becomes homologated into a class

% Trim
%   May have to cast grids to specific type (single/double instead of int)
trimmed = struct;
[trimmed.Xgrid, trimmed.Ygrid, trimmed.Zgrid, trimmed.mask] = ...
    subvolume_ndgrid(mStruct.Xgrid, mStruct.Ygrid, mStruct.Zgrid, mStruct.mask, limits);

%   Trim scanner anatomical grids
%       May turn into a helper function: trimScanAnat()
[~, ~, ~, trimmed.scanAnat.Xgrid] = subvolume_ndgrid(mStruct.Xgrid, mStruct.Ygrid, mStruct.Zgrid,...
    mStruct.scanAnat.Xgrid, limits);
[~, ~, ~, trimmed.scanAnat.Ygrid] = subvolume_ndgrid(mStruct.Xgrid, mStruct.Ygrid, mStruct.Zgrid,...
    mStruct.scanAnat.Ygrid, limits);
[~, ~, ~, trimmed.scanAnat.Zgrid] = subvolume_ndgrid(mStruct.Xgrid, mStruct.Ygrid, mStruct.Zgrid,...
    mStruct.scanAnat.Zgrid, limits);

% Other fields
trimmed.voxelDimensions = mStruct.voxelDimensions; % Same as before
trimmed.voxelDimensions_unit = mStruct.voxelDimensions_unit; % Same as before
trimmed.size = size(trimmed.mask); % Changed, since trimmed

% Correct .affines
trimmed.affines = shiftAffines(mStruct.affines, limits);

% Order fields to match original order
trimmed = orderfields(trimmed, mStruct);

% % Unit test (WIP)
% testGridRebuild(trimmed, mStruct, limits)
end

function trimmedAffines = shiftAffines(affines, limits)
% Alter .affines fields to account for trimming done
%   Only outputs new versions of fields:
%   .newNii2oldNii
%   .newNii2scanAnat
%   .oldNii2newNii
%   .scanAnat2newNii
%
%   (Any other fields are ignored; trimmedAffines does not inherit such
%   other fields, e.g. oldNii2scanAnat)

% Use lower limits for each dimension
%   -1 to account for fact that a limit of 1, in this case, means to not
%   remove anything (limits are inclusive)
%       i.e. a lower limit of 1 in subvolume(V, limits) is equivalent to
%       giving no limit for that edge (limit value of NA)
shift = calcShift(limits);

% Translation matrix for shift
shiftMat_negValues = eye(4);
shiftMat_negValues(1:3, 4) = shiftMat_negValues(1:3, 4) - shift';
%   Example: Trimming lower 10 voxels in all dimensions results in a matrix
%   newNii2trimNii of:
%       [ 1 0 0 -10 ]
%       [ 0 1 0 -10 ]
%       [ 0 0 1 -10 ]
%       [ 0 0 0  1  ]
%
%   Can then multiply this newNii2trimNii matrix to any *2newNii matrix to
%   get a *2trimNii matrix. Example:
%   oldNii2trimNii = newNii2trimNii * oldNii2newNii
%   scanAnat2trimNii = newNii2trimNii * scanAnat2newNii;
newNii2TrimNii = shiftMat_negValues;
trimNii2newNii = inv(newNii2TrimNii); % Same as shiftMat_posValues

% oldNii
oldNii2trimNii = newNii2TrimNii * affines.oldNii2newNii; % Name TBD
trimNii2oldNii = inv(oldNii2trimNii);

% scanAnat
scanAnat2trimNii = newNii2TrimNii * affines.scanAnat2newNii;
trimNii2scanAnat = inv(scanAnat2trimNii);

% Save, inhereting established naming structure
%   Internal trimNii values will become the new "newNii" for output
%       The "newNii" label will move again for scaled masks (in scaling step)
trimmedAffines = struct;

trimmedAffines.newNii2oldNii = trimNii2oldNii;
trimmedAffines.newNii2scanAnat = trimNii2scanAnat;

trimmedAffines.oldNii2newNii = oldNii2trimNii;
trimmedAffines.scanAnat2newNii = scanAnat2trimNii;
end

function shift = calcShift(limits)
% Calculate the absolute shift (translation) of coordinates caused by
% trimming that occurred
lowerLimits = [limits(1) limits(3) limits(5)];
% Replace any lower limits of NaN with 1
%   a lower limit of 1 in subvolume(V, limits) is equivalent to giving no
%   limit for that edge (limit value of NA)
lowerLimits(isnan(lowerLimits)) = 1;
shift = lowerLimits - 1; % -1 for shift since limits indexes from 1
end

function testGridRebuild(new, old, limits)
% Trimmed grids should match with corresponding section of untrimmed grids
%   match to mStruct.Xgrid, mStruct.Ygrid, mStruct.Zgrid
%   Use trimmed.affines (aka new.affines)

% % Match to old nii coordinates

%   Step 1: Make ndgrids with NEW Nii Coordinates (per voxel)
% Subscript grids (i.e. new newNii grids)
[subsGrids.X, subsGrids.Y, subsGrids.Z] = ndgrid(...
    1:new.size(1), 1:new.size(2), 1:new.size(3));
%   Step 2: Apply transformation matrix to NEW Nii Coordinates
% Consolidate ndgrids into single (3+1)N matrix
subsMat = [subsGrids.X(:)'; subsGrids.Y(:)'; subsGrids.Z(:)'; ones(size(subsGrids.X(:)'))];
% Matrix multiplication to get old NII coordinates
test.oldNii.mat = new.affines.newNii2oldNii * subsMat;
% Reshape
test.oldNii.Xgrid = reshape( test.oldNii.mat(1,:), new.size);
test.oldNii.Ygrid = reshape( test.oldNii.mat(2,:), new.size);
test.oldNii.Zgrid = reshape( test.oldNii.mat(3,:), new.size);

% Deltas
test.oldNii.deltas.X = new.Xgrid - test.oldNii.Xgrid;
test.oldNii.deltas.Y = new.Ygrid - test.oldNii.Ygrid;
test.oldNii.deltas.Z = new.Zgrid - test.oldNii.Zgrid;

% % Scanner anatomical
% Matrix multiplication to get old NII coordinates
test.scanAnat.mat = new.affines.newNii2scanAnat * subsMat;
% Reshape
test.scanAnat.Xgrid = reshape( test.scanAnat.mat(1,:), new.size);
test.scanAnat.Ygrid = reshape( test.scanAnat.mat(2,:), new.size);
test.scanAnat.Zgrid = reshape( test.scanAnat.mat(3,:), new.size);

% Deltas
test.scanAnat.deltas.X = new.scanAnat.Xgrid - test.scanAnat.Xgrid;
test.scanAnat.deltas.Y = new.scanAnat.Ygrid - test.scanAnat.Ygrid;
test.scanAnat.deltas.Z = new.scanAnat.Zgrid - test.scanAnat.Zgrid;


% Build grid: OLD Nii Coordinates
%   Step 1: Make ndgrids with NEW Nii Coordinates (per voxel)

%   Step 2: Apply transformation matrix to NEW Nii Coordinates
% Consolidate ndgrids into single 3xN matrix

% Matrix multiplication to get old NII coordinates

% Reshape

%% Below copied from reorientTogrid:

% % Build grid: OLD Nii Coordinates
% %   Step 1: Make ndgrids with NEW Nii Coordinates (per voxel)
% indexOrigin = getNiftiIndexOrigin(mask_filename); % From NIfTI file
% imageLimits = new.size - 1 + indexOrigin; % -1 to account for inclusion/exclusion
% [Xgrid, Ygrid, Zgrid] = ndgrid(...
%     indexOrigin:imageLimits(1),...
%     indexOrigin:imageLimits(2),...
%     indexOrigin:imageLimits(3));
% %   Step 2: Apply transformation matrix to NEW Nii Coordinates
% % Consolidate ndgrids into single 3xN matrix
% newNii = [Xgrid(:)'; Ygrid(:)'; Zgrid(:)'; ones(size(Xgrid(:)'))];
% % Matrix multiplication to get old NII coordinates
% oldNii = affines.newNii2oldNii * newNii; % Matrix multiplication
% % Reshape
% new.Xgrid = reshape( oldNii(1,:), new.size );
% new.Ygrid = reshape( oldNii(2,:), new.size );
% new.Zgrid = reshape( oldNii(3,:), new.size );
% 
% % Build grid: Scanner Anatomical
% sa = affines.newNii2scanAnat * newNii; % Matrix multiplication
% scanAnat = struct;
% scanAnat.Xgrid = reshape( sa(1,:), new.size ); % Reshape back to 3D matrix
% scanAnat.Ygrid = reshape( sa(2,:), new.size );
% scanAnat.Zgrid = reshape( sa(3,:), new.size );

warning('Not completed; should not be in stable branch')
end