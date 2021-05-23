function [Xgrid, Ygrid, Zgrid] = niftiGrid(filename)
%niftiGrid Produces grids (ndgrid) for nifti volume
%   Dependencies:   Image Processing Toolbox
%   
%   This function uses ndgrid()
%       ndgrid() does not swap axes, like meshgrid() does
indexOrigin = getNiftiIndexOrigin(filename);
% Assure indexOrigin is 0 or 1
if ~(indexOrigin == 0 || indexOrigin == 1)
    error('indexOrigin is not equal to 0 or 1. That is probably wrong.');
end

imgSize = imageSize(filename);
imageLimits = imgSize - 1 + indexOrigin; % -1 to account for inclusion/exclusion

[Xgrid, Ygrid, Zgrid] = ndgrid(...
    indexOrigin:imageLimits(1),...
    indexOrigin:imageLimits(2),...
    indexOrigin:imageLimits(3));

Xgrid = cast(Xgrid,'int16'); % Cast to int to save resources
Ygrid = cast(Ygrid,'int16');
Zgrid = cast(Zgrid,'int16');
end
