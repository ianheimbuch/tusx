function img = t1read(filename)
% t1read
%   Conversion of maskread()
%   Wrapper to deal with variable existence of Image Processing Toolbox
try
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
if length(unique(img)) == 2
    warning('Loaded volume is binary. Likely a mask.');
end

end