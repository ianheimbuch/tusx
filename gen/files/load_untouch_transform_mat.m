function [transformMat,sform_code] = load_untouch_transform_mat(niiFile)
%load_untouch_transform_mat Load transform matrix from nifti header
%   [transformMat,sform_code] = load_untouch_transform_mat(niiFile)
%
%   Load transform matrix from the nifti header
%   Uses load_untouch_header_only()
%   Results in same matrix as niftiinfo().Transform.T'
%   Results in DIFFERENT matrix from SPM12's spm_vol()
%
%   sform_code: 1 means transform to scanner anatomical
hdr = load_untouch_header_only(niiFile);
h = hdr.hist;
transformMat = double([h.srow_x ; h.srow_y ; h.srow_z ; 0 0 0 1]);
sform_code = h.sform_code;
end