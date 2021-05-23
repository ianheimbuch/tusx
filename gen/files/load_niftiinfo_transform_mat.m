function [transformMat,sform_code] = load_niftiinfo_transform_mat(niiFile)
%load_niftiinfo_transform_mat Load transform matrix from nifti header
%   [transformMat,sform_code] = load_niftiinfo_transform_mat(niiFile)
%
%   Load transform matrix from the nifti header
%   Uses niftiinfo()
%   Results in same matrix as niftiinfo().Transform.T'
%   Results in DIFFERENT matrix from SPM12's spm_vol()
%
%   sform_code: 1 means transform to scanner anatomical

temp = niftiinfo(niiFile);
transformMat    = temp.Transform.T';
sform_code      = temp.raw.sform_code;
end