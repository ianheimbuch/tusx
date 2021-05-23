function img = maskread_imgread(filename, coerceToBinary)
% maskread_imgread Loads nifti mask file to 3D matrix
%   Has option to not convert to logical (unlike maskread)
arguments
    filename char
    coerceToBinary (1,1) logical {mustBeNumericOrLogical} = true
end
try
    % niftiread() loads matching nifti voxel indices to matlab indices
    img = niftiread(filename);
    if isempty(img)
        % If load failed without error, use load_untouch_nii()
        nii = load_untouch_nii(filename);
        img = nii.img;
    end
catch
    % Try again, but with load_untouch_nii()
    nii = load_untouch_nii(filename);
    img = nii.img;
end

% Check if it was really a mask
if length(unique(img)) > 2
    warning('Loaded volume is not binary');
end

if coerceToBinary
    % Cast to logical
    thresh = graythresh(img);       % Global threshold
    img = imbinarize(img, thresh);  % Same as imbinarize( ___ ,'global'))
elseif length(unique(img)) < 2 % If object is binary, but coersion to binary wasn't requested
    % Cast to logical anyway
    thresh = graythresh(img);       % Global threshold
    img = imbinarize(img, thresh);  % Same as imbinarize( ___ ,'global'))
    warning('Image is binary. Converting to logical.');
end
end