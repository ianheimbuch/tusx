function checkAffine_zerosInRow4(M)
% checkAffine_zerosInRow4 Aid in checking affine matrix orientation
%   Checks that there are zeros in first three elements of row 4. As in:
%       [ m11 m12 m13 m14 ]
%       [ m21 m22 m23 m24 ]
%       [ m31 m32 m33 m34 ]
%       [  0   0   0   1  ]
%   Errors out if not.
%
%   Note: Function does NOT guarantee that an affine matrix with no
%   translation component is oriented as expected. Example:
%       [1 2 3 0]
%       [1 2 3 0]
%       [1 2 3 0]
%       [0 0 0 1]
arguments
    M (4,4) double
end
row = M(4, 1:3);
if any(abs(row) > 1e-5) % If any are not zero (with some precision leeway)
    error('Affine matrix is either invalid or in an unexpected orientation');
end
end