function [newAffines] = scaleAffines(affines, scale)
%scaleAffines Scale affine transformation matrices
%   Private function for scaleAndSmooth (of simulation3D_setup)
if scale == 1
    newAffines = affines; % No change to affine matrices
else
    scaleAffine = getScaleAffine(scale);
    newAffines = getNewAffines(affines, scaleAffine);
end
end

function scaleAffine = getScaleAffine(scale)
% Example: If scale if 4, then scaleAffine is:
%   [ 4 0 0 0]
%   [ 0 4 0 0]
%   [ 0 0 4 0]
%   [ 0 0 0 1]
scaleComponent = eye(3) * double(scale);
scaleAffine = eye(4);
scaleAffine(1:3, 1:3) = scaleComponent;
end

function newAffines = getNewAffines(affines, scaleAffine)
% Multiply either scaleAffine or inv(scaleAffine) against four affine
% fields
newNii2scaleNii = scaleAffine;
% oldNii
oldNii2scaleNii = newNii2scaleNii * affines.oldNii2newNii;
scaleNii2oldNii = inv(oldNii2scaleNii);
% scanAnat
scanAnat2scaleNii = newNii2scaleNii * affines.scanAnat2newNii;
scaleNii2scanAnat = inv(scanAnat2scaleNii);

% Save, inhereting established naming structure
%   Internal scaleNii label will become the new "newNii" for output
newAffines.newNii2oldNii    = scaleNii2oldNii;
newAffines.newNii2scanAnat  = scaleNii2scanAnat;
newAffines.oldNii2newNii    = oldNii2scaleNii;
newAffines.scanAnat2newNii  = scanAnat2scaleNii;

%   Testing (if scale = 2)
% Ground truths
%   If scale = 2
%       newNii 0 0 0 == scaleNii 0 0 0
%       NewNii 10 10 10 == scaleNii 20 20 20
%       Testing scanAnat:
%           See if NewNii 10 10 10 and scaleNii 20 20 20 result in same
%           scanAnat
%       Testing oldNii:
%           See if newNii 10 10 10 and scaleNii 20 20 20 result in same
%           oldNii
% test.gt10_scanAnat  = affines.newNii2scanAnat * [10; 10; 10; 1];
% test.gt10_oldNii    = affines.newNii2oldNii * [10; 10; 10; 1];
% test.newNii2scaleNii    = newNii2scaleNii * [10; 10; 10; 1];
% test.scaleNii2scanAnat  = scaleNii2scanAnat * [20; 20; 20; 1];
% test.scaleNii2oldNii    = scaleNii2oldNii * [20; 20; 20; 1];
end