function mediumStruct = setSkullProperties(mediumStruct, maskMat, skullProp)
% setSkullProperties Applies skull acoustic parameters to voxels where
% skull is present
%   setSkullProperties(mediumStruct, maskMat)
%   mediumStruct:   Struct kWave uses for setting medium properties (called
%                   "medium" in kWave's example scripts)
%   maskMat:        Skull mask (logical matrix)
%   skullProp:      Acoustic properties of skull (structure)
%   Uses logical indexing
%
%   Used on acoustic medium structure as used in k-Wave's
%   kspaceFirstOrder3D function (also used in simulation3D_setup)
%
%   Currently private because it does not currently deal with all
%   potential medium fields
arguments
    mediumStruct struct
    maskMat {mustBeNumericOrLogical}
    skullProp struct
end

%   Assure mask used for indexing is of type logical
if ~islogical(maskMat)
    error('Matrix used for indexing of skull voxels is not of type logical');
end
%   Apply logical indexing to place skull to...
%       Apply acoustic parameters of skull where skull exists
mediumStruct.sound_speed(maskMat) = skullProp.speed; % "skull" [m/s]
mediumStruct.density(maskMat) = skullProp.density;     % "skull" [kg/m^3]
mediumStruct.alpha_coeff(maskMat) = skullProp.alphaCoeff;    % [dB/(MHz^y cm)]
end