function [B, affines, imref] = gridRotation(V, target, scalp, nii, debug)
% GRIDROTATION Reorient volume to make trajectory orthogonal to grid
%   Rotates volume to make trajectory through two voxel cooridnates, target
%   & scale, orthogonal to grid
%
% Input:
%   V:      Mask volume
%   target: Voxel coordinate of in-brain target(NIfTI)
%   scalp:  Voxel coordinate of another line on trajectory (NIfTI)
%           This will typically be a point on/near the skull/scalp
%   nii:    File name of NIfTI for V
%
% Output:
%   B:      Rotated, interopolated volume
%   affines:Structure of affine transformation matrices
%           .oldNii2newNii:     
%           .scanAnat2newNii:   
%           .newNii2scanAnat:   
%
%   Affine matrices in structure 'affines' are oriented as:
%           [ m11 m12 m13 m14 ]
%           [ m21 m22 m23 m24 ]
%           [ m31 m32 m33 m34 ]
%           [  0   0   0   1  ]
arguments
    V       (:,:,:) double {mustBeNumericOrLogical, mustBeReal}
    target  (3,1)   double {mustBeNumeric, mustBeReal}
    scalp   (3,1)   double
    nii     (1,:)   char
end
arguments
    debug.skipSizeCheck (1,1) logical = false
    debug.interpMethod (1,:) char = 'linear' % Passed to imwarp
    debug.fillValue (1,1) double {mustBeNumeric} = 0 % Passed to imwarp ('FillValues')
end
% Load original NIfTI transformation matrix
niiT = load_niftiinfo_transform_mat(nii);
checkAffine_zerosInRow4(niiT); % Partial-check of niiT orientation
if debug.skipSizeCheck % If skipping (for debug)
    w1 = 'Skipping checkVolumeSizesMatch(). ';
    w2 = 'This should be done for debugging purposes only!';
    warning([w1 w2])
else % Normal use
    checkVolumeSizesMatch(V, nii); % Check size of V and nii match
end

% Do rotation/interpolation
[B, RB, tform, matBAb, matBAa, RA] = twoRot_imwarp(V, target, scalp,...
    debug.interpMethod, debug.fillValue);

% Get Matrix: Original nii cooridnates -> New nii coordinates
matBAa_offset = oldNii2newNii_getMat(matBAa, RB, RA);

% Scanner Anatomical to New Nii Coordinates
mat_scanAnat2newNii = scanAnat2newNii(matBAa_offset, niiT);

% New Nii Coordinates to Scanner Anatomical
mat_newNii2scanAnat = newNii2scanAnat(matBAa_offset, niiT);

% Save affine matrices to a structure
affines = struct;
affines.oldNii2newNii = matBAa_offset;
affines.newNii2oldNii = inv(matBAa_offset);
affines.scanAnat2newNii = mat_scanAnat2newNii;
affines.newNii2scanAnat = mat_newNii2scanAnat;
affines.oldNii2scanAnat = niiT;

% Save imref3d objects (for debug)
imref = struct;
imref.RA = RA;
imref.RB = RB;
end

function [B, RB, tform, matBAb, matBAa, RA] = twoRot_imwarp(V, target, scalp, method, fill)
% twoRot_imwarp Reorient volume to make trajectory orthogonal to grid
%   Rotates volume to make trajectory through two voxel cooridnates, target
%   & scale, orthogonal to grid
%
% Input:
%   V:      Mask volume
%   target: Voxel coordinate of in-brain target(NIfTI)
%   scalp:  Voxel coordinate of another line on trajectory (NIfTI)
%           This will typically be a point on/near the skull/scalp
%   
% Output:
%   B:      Rotated, interopolated volume
%   RB:     Spatial referencing information of the transformed image
%           (imref3d object output by imwarp)
%   tform:  affine3d object used to create volume B
%   matBAb: 4x4 affine transformation matrix used to warp V to B.
%           transpose(matBAb) == tform.T
%   matBAa: 4x4 affine transformation matrix that logs the ROTATION
%           component of volume rotation in terms of NIfTI voxel
%           coordinates. This matrix does NOT account for the
%           offset/translation caused by imwarp rotation
%   RA:     imref3d object used intermally of imwarp.
%           Needed for accounting for offset/translation caused by imwarp
%           rotation
%
%   matBAb and matBAa are oriented as:
%           [ m11 m12 m13 m14 ]
%           [ m21 m22 m23 m24 ]
%           [ m31 m32 m33 m34 ]
%           [  0   0   0   1  ]
%
%   Internally, calculates two individual rotation matrices, calculate
%   each successive matrix after the previous rotation is implemented. A
%   third matrix is not necessary.
%
%   Function multiplies transformation matrices against column vectors
%   (rather than row vectors).
arguments
    V       (:,:,:) double {mustBeNumericOrLogical, mustBeReal}
    target  (3,1)   double {mustBeNumeric, mustBeReal}
    scalp   (3,1)   double
    method  (1,:)   char = 'linear'
    fill    (1,1)   double {mustBeNumeric} = 0
end
% % Get matrix A (roll)
% For NIfTI coordinates
matAa = forNiiOrig_roll(target, scalp);
% For imwarp
matAb = forimwarp_roll(target, scalp);

% % Get composite matrix (BA; pitch after roll)
% For NIfTI coordinates
matBAa = forNiiOrig_pitchAfterRoll(target, scalp, matAa);
% For imwarp
matBAb = forimwarp_pitchAfterRoll(target, scalp, matAa, matAb);
tform = affine3d(matBAb');
[B, RB] = imwarp(V, tform, method, 'FillValues', fill);

% Get imwarp's internal RA (since doesn't output)
RA = imref3d(size(V)); % For comparison to RB later

% Check rotation matrices by making sure
%   1: Final matrix forms straight line up
%   2: Target and target's original anterior-adjacent voxel share same dim 1
matM = matBAa; % Feed matrix for original nifti cooridnates (for this use)
checkNiiOrig_comosite(matM, target, scalp)

% The order in composites matters
%   For column-matrix coordinate vectors:
%       If apply A and then B to vector v, multiplication order is B*A*v
%   For row-matrix coordinate vectors:
%       If apply C and then D to vector w, multiplication order is w*C*D
%   
%   Note: If C = A', D = B', and w = v':
%       B*A*v = (w*C*D)'

% Note: affine3d transform matrices use transposed orientation
%       affine3d also swaps X and Y
%   affine3d:
%    [x y z 1] = [u v w 1] * T
%
%    Where T has the form:
%
%    [a b c 0;...
%     d e f 0;...
%     g h i 0;...
%     j k l 1];
%
%   NIFTI:
%       [ x ]   [ m11 m12 m13 m14 ] [ i ]
%       [ y ] = [ m21 m22 m23 m24 ] [ j ]
%       [ z ]   [ m31 m32 m33 m34 ] [ k ]
%       [ 1 ]   [  0   0   0   1  ] [ 1 ]
end

function matA = forNiiOrig_roll(target, scalp)
% Works for original orientation nifti coordinates (but not imwarp)
%   Roll of the head (Anterior-Posterior cooridnates should not change)

% % Get matrix A
%   Get angle A
delta = target - scalp;
radA  = atan(delta(1) / delta(3)); % Angle (radians)
%   Get matrix
%   What works for original orientation nifti coordinates (but not imwarp)
matA  = makehgtform('yrotate', -radA); % Don't know why must be neg (IH)
%   Check rotation (new dim 1 of scalp and target should be same
targetA = matA * [target; 1];   % Debug
scalpA  = matA * [scalp; 1];    % Could implement error check here
targetA(1) - scalpA(1);         %   Currently checked at composite
targetA    - scalpA;
end

function matA = forimwarp_roll(target, scalp)
% Works for imwarp (but not original orientation nifti cooridnates)
%   Roll of the head (Anterior-Posterior cooridnates should not change)

% % Get matrix A
%   Get angle A
delta = target - scalp;
radA  = atan(delta(1) / delta(3)); % Angle (radians)
%   Get matrix
%   What works for imwarp (but not orignal orientation nifti cooridnates)
matAxA  = makehgtform('xrotate', radA);
%   Check rotation (new dim 1 of scalp and target should be same
matA = matAxA;
% targetA = matA * [target; 1];
% scalpA  = matA * [scalp; 1];
% targetA(1) - scalpA(1)
% targetA    - scalpA
end

function matBAa = forNiiOrig_pitchAfterRoll(target, scalp, matAa)
% Works for original orientation nifti coordinates (but not imwarp)
%   Pitch of the head (Left-Right cooridnates should not change)
%   matAa: Matrix used for orig nifti reorientation

% % Get matrix B
%   Use updated coordinates
targetA = matAa * [target; 1];
scalpA  = matAa * [scalp; 1];
delta = targetA - scalpA;
radB  = atan(delta(2) / delta(3)); % Angle (radians)
%   Get matrix
matB  = makehgtform('xrotate', radB);
%   Check rotation (new dim 2 of scalp and target should be same)
targetB = matB * targetA;
scalpB  = matB * scalpA;
targetB(2) - scalpB(2); % Debug line

matBAa = matB * matAa;
end

function matBAb = forimwarp_pitchAfterRoll(target, scalp, matAa, matAb)
% Works for original orientation nifti coordinates (but not imwarp)
%   Pitch of the head (Left-Right cooridnates should not change)
%   matAa: Matrix used for orig nifti reorientation

% % Get matrix B
%   Use updated coordinates
targetA = matAa * [target; 1];
scalpA  = matAa * [scalp; 1];
delta = targetA - scalpA;
radB  = atan(delta(2) / delta(3)); % Angle (radians)
%   Get matrix
% matB  = makehgtform('yrotate', radB);
matB  = makehgtform('yrotate', -radB); % Do not know why must be negative (IH)
%   Get composite
matBAb = matB * matAb;
end

function checkNiiOrig_comosite(matM, target, scalp)
% Test to assure final composite matrix correctly orients original nifti
% cooridnates into orthogonal alignment
targetM = matM * [target; 1];
scalpM  = matM * [scalp; 1];
delta = abs(targetM - scalpM);
thresh0 = 1e-5; % Threshold around zero, to give wiggle room for calculation
if delta(1) > thresh0 || delta(2) > thresh0 % Should be zero (within wiggle)
    error('Orientation matrix for nifti coordinates did not align as expected');
end
end

function matBAa_offset = oldNii2newNii_getMat(matBAa, RB, RA)
% oldNii2newNii_getMat Find transformation matrix
%   Gets Matrix: Original nii cooridnates -> New nii coordinates
%
% Input:
%   matBAa: matrix that warps original nii cooridnates to new coordinates
%   following imwarp
%   RB: imref3d object from imwarp output
%   RA: imref3d object for imwarp input
%
% How to implement
%   targetBAa = matBAa_offset * targetCol; % New target voxel (nii coord)
%       matBAa_offset: Function output
%       targetCol: (4,1) column vector, where elements 1:3 are original
%       NIfTI coordinates
%       targetBAa: (4,1) column vector, where elements 1:3 are new NIfTI
%       cooridnates
arguments
    matBAa (4,4) double
    RB imref3d
    RA imref3d
end
% Get offsets caused by imwarp
%   Original imref3d world limits compared to new ones
imwarpOffset.d1 = RB.YWorldLimits(1) - RA.YWorldLimits(1);
imwarpOffset.d2 = RB.XWorldLimits(1) - RA.XWorldLimits(1);
imwarpOffset.d3 = RB.ZWorldLimits(1) - RA.ZWorldLimits(1);
imwarpOffset.v  = [imwarpOffset.d1; imwarpOffset.d2; imwarpOffset.d3];

% Consolidate offset into an affine matrix
%   Consolidate offset with affine matrix matBAa, which warps nii
%   cooridnates correctly to find indices
col4 = matBAa(:,4) - [imwarpOffset.v; 0];
matBAa_offset = matBAa;
matBAa_offset(:,4) = col4;

% How to implement
%   targetBAa = matBAa_offset * targetCol; % New target voxel (nii coord)
%   Equivalent to:
%   targetBAa = (matBAa * targetCol) - [imwarpOffset.v; 0];
end

function scanAnat2newNii = scanAnat2newNii(matBAa_offset, niiT)
% scanAnat2newNii Get scanner Anatomical to New Nii Coordinates matrix
%   matBAa_offset: Affine matrix that transforms original Nifti coordinates
%   into coordinates following imwarp
%       Takes into account both rotation and translation caused by
%       expansion of volume size
%       Example: Output from oldNii2newNii_getMat()
%   niiT: Original transform matrix from Nifti file
%
% How to implement:
%   newNii = scanAnat2newNii * saTarget;
%   (saTarget: Scanner anatomical coordinate of target)
%   (newNii: Voxel coordinate in NIfTI convention, as if were to then
%   export current volume back to a .nii file)
arguments
    matBAa_offset   (4,4) double
    niiT            (4,4) double
end
% Check orientation of affine matrices
checkAffine_zerosInRow4(matBAa_offset)
checkAffine_zerosInRow4(niiT)

scanAnat2newNii = matBAa_offset / niiT; % Matrix right division
%   Same as:    scanAnat2newNii = matBAa_offset * inv(niiT);
end

function newNii2scanAnat = newNii2scanAnat(matBAa_offset, niiT)
% newNii2scanAnat Get matrix: New NIfTI Cooridnates to Scanner Anatomical
%   matBAa_offset: Affine matrix that transforms original Nifti coordinates
%   into coordinates following imwarp
%       Takes into account both rotation and translation caused by
%       expansion of volume size
%       Example: Output from oldNii2newNii_getMat()
%   niiT: Original transform matrix from Nifti file
%
% How to implement:
%   scanAnat = newNii2scanAnat * newNii;
%   (newNii: Voxel coordinate in NIfTI convention, as if were to then
%   export current volume back to a .nii file)
%   (scanAnat: Scanner anatomical coordinate corresponding to New NIfTI
%   voxel coordinate newNii)
arguments
    matBAa_offset   (4,4) double
    niiT            (4,4) double
end
% Get the inverse of the scanAnat2newNii transform matrix
newNii2scanAnat = inv( scanAnat2newNii(matBAa_offset, niiT) );
end

function checkVolumeSizesMatch(V, nii)
% Check size of V and nii match
niiSize = imageSize(nii);
VSize   = int64( size(V) );
if any(niiSize ~= VSize)
    m1 = 'Size of volume V and NIfTI image located at ';
    m2 = 'given location nii do not match.';
    m3 = [' NIfTI location is: ' nii];
    mess = [m1 m2 m3];
    error(mess)
end
end