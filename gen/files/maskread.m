function mask = maskread(filename)
% maskread Loads nifti mask file to 3D matrix
try
    % niftiread() loads matching nifti voxel indices to matlab indices
    mask = niftiread(filename);
    if isempty(mask)
        % If load failed without error, use load_untouch_nii()
        nii = load_untouch_nii(filename);
        mask = nii.img;
    end
catch
    % Try again, but with load_untouch_nii()
    nii = load_untouch_nii(filename);
    mask = nii.img;
end

% Check if it was really a mask
if length(unique(mask)) > 2
    warning('Loaded volume is not binary. Likely not a mask. Forcing to binary.');
end

% Cast to logical
mask = logical(mask);
end