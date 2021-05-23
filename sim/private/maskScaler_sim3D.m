function [scaledMask, grids, ticks] = maskScaler_sim3D(scale, mask,...
    Xgrid, Ygrid, Zgrid, nv)
%MASKSCALER Scales (increases resolution) of 3D mask
%   Only can increase meshgrid size/resolution (scale must be >1)
%   Scale must be 1 (no scale), 2, 4, or 8 with this implementation
%       Because using this version of interp3():
%           interp3(V,k)
%               Simple interp at scale of 2, 4, 8, 16 etc.
%                   "scale" of 2: k = 1
%                   "scale" of 4: k = 2
%
% k:    Refinement factor, specified as a real, nonnegative, integer
% scalar. This value specifies the number of times to repeatedly divide
% the intervals of the refined grid in each dimension. This results
% in 2^k-1 interpolated points between sample values.
%
% Currently private due to use in a very particular way
arguments
    scale       (1,1)   int64
    mask        (:,:,:) {mustBeNumericOrLogical}
    Xgrid       (:,:,:) {mustBeNumeric}
    Ygrid       (:,:,:) {mustBeNumeric}
    Zgrid       (:,:,:) {mustBeNumeric}
end
arguments % Name-value pairs
    nv.outputGrids (1,1)   logical {mustBeNumericOrLogical} = false
    nv.reoriented  (1,1)   logical {mustBeNumericOrLogical} = false
    nv.coerceToBinary (1,1) logical {mustBeNumericOrLogical} = true
end
% % Scale mask
scale = round(scale);

% Check scale divisible by 2 (for current implementation)
%   and assign appropriate k (refinement factor)
switch scale
    case 1
        k = 0;
        scaledMask = mask;
        if ~nv.reoriented % If reoriented: Skip
            ticks = ticksScaler(k, Xgrid, Ygrid, Zgrid);
        end
        if nv.outputGrids
            grids.Xscaled = Xgrid;
            grids.Yscaled = Ygrid;
            grids.Zscaled = Zgrid;
        end
    case 2
        k = 1;
    case 4
        k = 2;
    case 8
        k = 3;
    otherwise
        error('Scale must be 1, 2, 4, or 8 with this implementation');
end

% % Scale mask
%   (Use nearest-neighbor interpolation)
scaledMask = interp3(single(mask), k, 'nearest');

if nv.coerceToBinary
    %   Convert back to logical (to save resources)
    thresh = graythresh(scaledMask);            % Global threshold
    scaledMask = imbinarize(scaledMask, thresh);% Same as imbinarize( ___ ,'global'))
end

% % Output axes ticks
if ~nv.reoriented % If reoriented: Skip
    ticks = ticksScaler(k, Xgrid, Ygrid, Zgrid);
end

% % Option to output scaled meshgrid (X,Y,Z)
grids = struct;
if nv.outputGrids
    [grids.Xscaled, grids.Yscaled, grids.Zscaled] = ...
        meshgridScaler_refineFactor(k, Xgrid, Ygrid, Zgrid);
end

% Check # of requested output arguments
%   Ticks (3rd output) is not made if volume was reoriented
if nargout > 2 && nv.reoriented % If > 2 arguments and is reoriented
    e1 = 'If name-value pair "reoriented" is set to true, only two output';
    e2 = ' arguments can be requested';
    error([e1 e2]);
end
end

function ticks = ticksScaler(k, Xgrid, Ygrid, Zgrid)
%TICKSSCALER Scales just X, Y, and Z ticks (so don't have to store entire
%   meshgrids, which can be huge

% interpn(V,k)
%   If want to interp just voxel coordinates (to store, instead of storing
%   huge meshgrids of the coordinates)
%   Simple interp at scale of 2, 4, 8, 16 etc.
Xticks = unique(Xgrid);
Yticks = unique(Ygrid);
Zticks = unique(Zgrid);

% Check if ticks are right size
if length(Xticks) ~= size(Xgrid, 1) ||...
   length(Yticks) ~= size(Ygrid, 2) ||...
   length(Zticks) ~= size(Zgrid, 3) 
    e1 = 'Length of calculated tick marks, [';
    e2 = [num2str(length(Xticks)) ' ' num2str(length(Yticks)) ' '];
    e3 = [num2str(length(Zticks)) '], do not match the size of the volume, ['];
    e4 = [num2str(size(Xgrid, 1)) ' ' num2str(size(Ygrid, 2)) ' '];
    e5 = [num2str(size(Zgrid, 3)) ']. '];
    e6 = 'This may be due to rotations applied to the volume';
    error([e1 e2 e3 e4 e5 e6]);
end

% To-do: (5/12/20)
%   See if ticks matter anywhere else. If not, remove use.
%   If are used: Replace use of ticks with other methods

% Scale up
ticks.Xscaled = interpn(single(Xticks), k, 'linear');
ticks.Yscaled = interpn(single(Yticks), k, 'linear');
ticks.Zscaled = interpn(single(Zticks), k, 'linear');
end

function [Xscaled, Yscaled, Zscaled] = meshgridScaler_refineFactor(refinementFactor,...
    Xgrid, Ygrid, Zgrid)
%MESHGRIDSCALER Scales (increases resolution) of meshgrid
%   Splits each gap in half k times (refinement factor)
%       So scale will be either 2, 4, 8, etc.
%       Done via this version of interp3():
%           interp3(V,k)
%               Simple interp at scale of 2, 4, 8, 16 etc.
%                   "scale" of 2: k = 1
%                   "scale" of 4: k = 2
refinementFactor = round(refinementFactor);

if refinementFactor == 0
    % Return unscaled
    Xscaled = Xgrid;
    Yscaled = Ygrid;
    Zscaled = Zgrid;
else
    % % Option to output scaled meshgrid (X,Y,Z)
    Xscaled = interp3(single(Xgrid), refinementFactor, 'linear');
    Yscaled = interp3(single(Ygrid), refinementFactor, 'linear');
    Zscaled = interp3(single(Zgrid), refinementFactor, 'linear');
end

end