function smoothed = maskSmoother(mask,scale,smoothingParam)
%MASKSMOOTHER Smooths mask with imclose()
%   maskSmoother(mask, scale)
%   maskSmoother(mask, scale, smoothingParam)
%   smoothingParam: default is 5
arguments
    mask                    logical
    scale           (1,1)   double  {mustBeInteger, mustBePositive}
    smoothingParam  (1,1)   double  = 5
end
smoothFactor = scale * smoothingParam; % Input in strel() based on # px, so must scale
se = strel('sphere',smoothFactor);
smoothed = imclose(mask, se);
% Also smooth down a tiny bit to remove few sharp outliers jutting out
se2 = strel('sphere', scale * 1);
smoothed = imopen(smoothed, se2);
smoothed = logical(smoothed); % Cast bast to logical
end