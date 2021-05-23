function nifti = makeOrLoadNiftiMat(niftiFile, niftiStruct, saveToDrive)
% % Create grids for scanner anatomical coordinates
%   Either loads existing .mat or makes it
%   (helper function for simulation3D_setup)
arguments
    niftiFile   (1,:)   char
    niftiStruct         struct
    saveToDrive (1,1)   logical {mustBeNumericOrLogical} = false
end
% Look for already converted/saved output.
[alreadyConverted, putativeMatFile] = checkForScanAnatMat(niftiFile);

% If it doesn't already exist, make it and save it
if ~alreadyConverted
    % Rename, in prep for save
    nifti = niftiStruct;
    % Make scanner anatomical grids
    nifti.scanAnat = niftiScanAnatGrid(niftiFile);
    % Save to file
    if saveToDrive
        save(putativeMatFile, 'nifti');
    end
elseif alreadyConverted
    % Load the previously made 'nifti' variable from the MAT file
    load(putativeMatFile,'nifti');

    % Check that the files match
    areEqualSized = all(size(nifti.scanAnat.Xgrid) == size(niftiStruct.mask));
    if ~areEqualSized
        error('Loaded nifti.scanAnat does not match size of nifti.mask');
    end

    clearvars oldNifti; % Remove temp variable, since no longer needed
end
end