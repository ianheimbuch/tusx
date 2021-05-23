function imgSize = imageSize(niiFile)
%IMAGESIZE Returns size (in voxels) of nifti file
%   Returns 3-element array of the number of voxels in each axis (X,Y,Z)
%   Uses the nifti header information
try
    info = niftiinfo(niiFile);
    imgSize = info.ImageSize;
catch
    hdr = load_untouch_header_only(niiFile);
    imgSize = hdr.dime.dim(2:4);
end
imgSize = int64(imgSize);
end

