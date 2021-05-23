function indexOrigin = getNiftiIndexOrigin(filename)
%getNiftiIndexOrigin Find whether NIfTI file indices start at 0 or 1
try
    info = niftiinfo(filename);
    indexOrigin = info.SliceStart; % 0 or 1. Most nifti should be 0-based indexing
catch % If SliceStart doesn't exist (so errors), try load_untouch_nii()
    try
        hdr = load_untouch_header_only(filename);
        indexOrigin = hdr.dime.slice_start;
    catch % If that doesn't work, assume it's 0-based indexing
        indexOrigin = 0;
    end
end
end

