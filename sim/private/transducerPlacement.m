function [p_mask, piezo_ind, target_ind] = transducerPlacement(piezoCoor,targetCoor,...
    Xgrid,Ygrid,Zgrid,focalLength_m,gridSpacing_m)
%TRANSDUCERPLACEMENT
% Inputs:
%   piezoCoor:  Where transducer is placed.
%               3-element array of voxel coordinates
%               Note: This will be the back of the "bowl" of the curved
%               transducer. But this should be close enough to the front to
%               work for most cases
%   targetCoor: Where transducer is aiming at
%               3-element array of voxel coordinates
%   Xgrid:      ndgrid for x coordinates
%   Ygrid:      ndgrid for y coordinates
%   Zgrid:      ndgrid for z cooridnates
%   focalLength_m:  Focal length of the focused transducer (in meters)
%   gridSpacing_m:  Spacing between grid points (in meters)
%                   WARNING: Grid dimensions must be equal in all
%                   directions!!!
%
%   Note:       Width of transducer ('diameter' in the code) is currently
%               set to match the focalLength_m. This is could be changed in
%               the future with the addition of an optional 'diameter'
%               (i.e. aperture') parameter.
%
% Outputs:
%   p_mask:     Matrix wehre 'True' voxels denote where transducer exists
%               (logical matrix)
%   piezo_ind:  Matrix indices for transducer center
%               (3-element vector)
%   target_ind: Matrix indices target transducer is pointing at
%               (3-element vector)

% % Find subscripts for locations
%   Must re-find because it moved if volume was scaled or trimmed
piezo_ind   = closestPointFinder(piezoCoor, Xgrid, Ygrid, Zgrid); % [grid points]
target_ind  = closestPointFinder(targetCoor, Xgrid, Ygrid, Zgrid);% [grid points]

radius      = focalLength_m / gridSpacing_m;         % [grid points; m / grid point spacing]
diameter    = floor(focalLength_m / gridSpacing_m);  % [grid points; m / grid point spacing]
if mod(diameter,2)<1
    diameter = diameter - 1; % round down to odd
end

% Make bowl using subscripted matrix locations
%   makeBowl() wants XY the expected way. No swapping needed
p_mask = makeBowl(size(Xgrid), piezo_ind, radius, diameter, target_ind,...
'Binary', true); % Output will be of type logical
end

