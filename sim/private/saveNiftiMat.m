function saveNiftiMat(niftiFile, nifti, overwrite)
% saveNiftiMat Save .mat 'nifti' struct
%   Does not save if file already exists unless 'overwrite' is set to true
%   (helper function for simulation3D_setup)
arguments
    niftiFile (1,:) char
    nifti           struct
    overwrite (1,1) logical {mustBeNumericOrLogical} = false
end
% Look for already converted/saved output.
[alreadyConverted, putativeMatFile] = checkForScanAnatMat(niftiFile);

% If it doesn't already exist, save it (or if overwrite == true)
if ~alreadyConverted || overwrite
    % Save to file
    save(putativeMatFile, 'nifti');
end
end