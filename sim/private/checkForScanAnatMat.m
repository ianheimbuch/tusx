function [alreadyConverted, scanAnatMat] = checkForScanAnatMat(maskfile)
% This function could use more error checking:
%   Checking that grid sizes match
%       all(size(nifti.scanAnat.Xgrid) == imageSize(maskfile))
%   That structure has the expected field/struct (.scanAnat)
[filepath,name,~] = fileparts_gz(maskfile);
scanAnatMat = fullfile(filepath, strcat(name,'.mat'));
try
    alreadyConverted = isfile(scanAnatMat);
catch % isFile introduced in R2017b
    existKey = exist(scanAnatMat,'file');
    switch existKey
        case 0 % Does not exist
            alreadyConverted = false;
        case 2 % Is a file
            alreadyConverted = true;
        otherwise
            alreadyConverted = false;
    end
end
end