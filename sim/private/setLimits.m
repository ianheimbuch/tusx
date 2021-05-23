function limits = setLimits(trimSize, nifti, varargin)
% setLimits: Set limits for tusx_sim_setup()
% limits = setLimits(trimSize, targetName, nifti, scale, scalpLocation,
%                    ctxTarget, reorientToGrid, origSize)
% limits = setLimits(targetName, nifti)
% limits = setLimits(targetName, nifti, scale, scalpLocation, ctxTarget)
%
%   targetName:
%       'fitTrajectory': Set function to center the trimming around the two
%       given coordinates: scalpLocation & ctxTarget
%   nifti: Structure that includes field .size, for use in setting limits
%
%   Optional
%   scale:          Integer
%   scalpLocation:  Voxel coordinates (1,3)
%   ctxTarget:      Voxel coordinates (1,3)
%   reorientToGrid: Boolean
%   origSize:       Size (integer)
%
% Helper function of tusx_sim_setup()
% Converts trm (struct) into vector needed for subvolume()
% Structure "nifti" is needed so know the size
arguments
    trimSize    (1,:) double {mustBeInteger} % Final volume size
    nifti             struct
end
arguments (Repeating)
    varargin
end
reoriented = varargin{4};
origSize = varargin{5};
if reoriented
    trm = setTrm_reoriented(trimSize, nifti, varargin{1:5});
else
    trm = setTrm(trimSize, nifti, varargin{1:3});
end
limits = [trm.dim1start trm.dim1end ...
          trm.dim2start trm.dim2end ...
          trm.dim3start trm.dim3end];
end

function trm = setTrm(trimSize, nifti, varargin)
% arguments
%     trimSize        (1,:) double {mustBeInteger} % Final volume size
%     nifti                 struct
%     scale           (1,1)       {mustBeInteger}
%     scalpLocation   (1,3)       {mustBeNumeric}
%     ctxTarget       (1,3)       {mustBeNumeric}
% end
arguments
    trimSize    (1,:) double {mustBeInteger} % Final volume size
    nifti             struct
end
arguments (Repeating)
    varargin
end
switch nargin
    case 2
        trm.dim1start  = NaN; % Do no trimming
        trm.dim1end    = NaN; % (Unable to do trimming without info)
        trm.dim2start  = NaN;
        trm.dim2end    = NaN;
        trm.dim3start  = NaN;
        trm.dim3end    = NaN;
    case 5
        scale       = varargin{1};
        scalpLocation = varargin{2};
        ctxTarget   = varargin{3};
        % widthTarget = setwidthTarget(nifti.size);
        widthTarget = trimSize; % Now set by tusx_sim_setup param (or default)
        dimWidth    = setDimWidth(widthTarget, scale); % For 512, dimWidth = 122
        dim2mid     = round(mean([scalpLocation(2) ctxTarget(2)]));
        trm = fitTrmToTrajectory(scale, scalpLocation, ctxTarget,...
            dimWidth, nifti.size);                    
    otherwise
        error('Invalid number of parameters');
end
end

function dimWidth = setDimWidth(widthTarget, scale, PMLsize)
% setDimWidth Determines how wide dimensions of volume should start as such
% that they will be the ideal width after scaling
%   Assumes PML is set to outside (PML default: 10)
%   Can take single element or vector (returns vector of same length as
%   widthTarget)
arguments
    widthTarget (1,:) double
    scale       (1,1) double {mustBeInteger}
    PMLsize     (1,1) double {mustBeInteger} = 10 % Per side
end
dimWidth = floor((widthTarget - (2 * PMLsize) - (scale - 1)) / scale);
end

function trm = fitTrmToTrajectory(scale, scalp_ind, target_ind,...
    dimWidth, volSize)
% fitTrmToTrajectory Fit without target label assumptions
% Set trim dimensions for any trajectory, making sure areas of interest are
% given space (target, scalp, area beyond scalp for transducer, etc)
%
% Returns indices to be trim points
arguments
    scale       (1,1) double {mustBeInteger}
    scalp_ind   (1,3) double {mustBeInteger}
    target_ind  (1,3) double {mustBeInteger}
    dimWidth    (1,:) double {mustBeInteger} % Width of each or all dimensions
    volSize     (1,3) double {mustBeInteger}
end
% Check dimWidth is a scalar or a 3-element vector
if all( size(dimWidth) == [1 1] )
    % Do nothing
elseif all( size(dimWidth) == size(volSize) )
    % Do nothing
else
    error('dimWidth must be single integer or length of vector volSize')
end
% Approach:
%   Find midpoint between the scalp and target voxels
%   Center aound midpoint
%   Shift to stay volume limits, if necessary

% Find midpoint (round down)
%   It may actually be better to not use the midpoint to get best view of
%   ultrasound. In the future, may want to improve by biasing it towards
%   the target locations somehow - IH (5/9/20)
%       Could add an optional 'bias' parameter, shifting the center along a
%       line between the two points (0.0 centered on scalp, 1.0 centered on
%       target; default of 0.5)
ctr_ind = setCenter_toTrajectory(scalp_ind, target_ind); % Set center of trim
% Set trm limits based on dimWidth
%   Find how radius to stretch out from center point
radius = (dimWidth - 1)/2; % -1 to include center point
negRadius = floor(radius); % Floor and ceiling account for odd radius values
posRadius = ceil(radius);  % Arbitrarily chose +1 longer side for higher side 
%   Find limits
starts = ctr_ind - negRadius;   % (1,3) vector for dim 1, 2, 3
ends = ctr_ind + posRadius;     % (1,3) vector for dim 1, 2, 3

% Check limits don't fall outside volume size
%   Why does it matter? If it does, then that's when you add PML
%       Account for those cases with a NaN? (or a 1 or size of that dim)?
if any(starts < 1) || any(ends > volSize)
    [starts, ends] = shiftToFit(volSize, starts, ends); % Adjust if so
end

% Consolidate into expected structure format
trm = struct;
trm.dim1start  = starts(1); % Do not use NaN for this use
trm.dim1end    = ends(1); % (all limits must be set)
trm.dim2start  = starts(2);   
trm.dim2end    = ends(2);   
trm.dim3start  = starts(3);   
trm.dim3end    = ends(3);
trm.starts     = starts;
trm.ends       = ends;

% Final checks:
%   Check indices for both scalp and target are still within limits
if any(scalp_ind < starts | target_ind < starts |...
        scalp_ind > ends | target_ind > ends)
    err1 = 'Indices of referenced voxels do not fall with calculated limits. ';
    err2 = ['Indices: [' num2str(scalp_ind) '] [' num2str(target_ind) ']. '];
    err3 = ['Lower limits: [' num2str(starts) '] Upper Limits: [' num2str(ends) ']'];
    error([err1 err2 err3]);
end
%   Check final limits match dimWidth
newSize = (ends - starts) + 1;
if ~all(newSize == dimWidth)
    error('Size of volume set by new limits does not match necessary width');
end
end

function trm = fitTrmToTrajectory_reorient(scale, scalp_ind, target_ind,...
    dimWidth, volSize)
% fitTrmToTrajectory_reorient
% Set trim dimensions for any trajectory, making sure areas of interest are
% given space (target, scalp, area beyond scalp for transducer, etc)
%
% Returns indices to be trim points
%
% NOTE: This approach currently only be implemented with reoriented volumes
arguments
    scale       (1,1) double {mustBeInteger}
    scalp_ind   (1,3) double {mustBeInteger}
    target_ind  (1,3) double {mustBeInteger}
    dimWidth    (1,:) double {mustBeInteger} % Width of each or all dimensions
    volSize     (1,3) double {mustBeInteger}
end
% Check dimWidth is a scalar or a 3-element vector
if all( size(dimWidth) == [1 1] )
    % Do nothing
elseif all( size(dimWidth) == size(volSize) )
    % Do nothing
else
    error('dimWidth must be single integer or length of vector volSize')
end
% New approach:
%   Put scalp_ind near edge

% %   Find midpoint between the scalp and target voxels
% %   Center aound midpoint

%   Shift to stay volume limits, if necessary

% Find midpoint (round down)
%   Midpoint used to center 2/3 dimensions
ctr_ind = setCenter_toTrajectory(scalp_ind, target_ind); % Set center of trim
% Set trm limits based on dimWidth
%   Find how radius to stretch out from center point
radius = (dimWidth - 1)/2; % -1 to include center point
negRadius = floor(radius); % Floor and ceiling account for odd radius values
posRadius = ceil(radius);  % Arbitrarily chose +1 longer side for higher side 
%   Find limits
starts = ctr_ind - negRadius;   % (1,3) vector for dim 1, 2, 3
ends = ctr_ind + posRadius;     % (1,3) vector for dim 1, 2, 3
%   Shift start & end so transducer is toward the edge (1/3 dimensions)
[starts, ends] = shiftTransducerToEdge(starts, ends, scalp_ind, target_ind, dimWidth);

% Check limits don't fall outside volume size
%   Why does it matter? If it does, then that's when you add PML
%       Account for those cases with a NaN? (or a 1 or size of that dim)?
if any(starts < 1) || any(ends > volSize)
    [starts, ends] = shiftToFit(volSize, starts, ends); % Adjust if so
end

% Consolidate into expected structure format
trm = struct;
trm.dim1start  = starts(1); % Do not use NaN for this use
trm.dim1end    = ends(1); % (all limits must be set)
trm.dim2start  = starts(2);   
trm.dim2end    = ends(2);   
trm.dim3start  = starts(3);   
trm.dim3end    = ends(3);
trm.starts     = starts;
trm.ends       = ends;

% Final checks:
%   Check indices for both scalp and target are still within limits
if any(scalp_ind < starts | target_ind < starts |...
        scalp_ind > ends | target_ind > ends)
    err1 = 'Indices of referenced voxels do not fall with calculated limits. ';
    err2 = ['Indices: [' num2str(scalp_ind) '] [' num2str(target_ind) ']. '];
    err3 = ['Lower limits: [' num2str(starts) '] Upper Limits: [' num2str(ends) ']'];
    error([err1 err2 err3]);
end
%   Check final limits match dimWidth
newSize = (ends - starts) + 1;
if ~all(newSize == dimWidth)
    error('Size of volume set by new limits does not match necessary width');
end
end

function trm = setTrm_reoriented(trimSize, nifti, varargin)
% setTrm function but for reoriented grids/masks
%   Similar to setTrm but takes into accont that the X-, Y-, and Z-grids
%   are no longer orthogonal (they were rotated to match rotated mask
%   volume)
%
%   Function takes into account the rotation by finding the new indices
%   within the matrix that match the desired location on the head (which
%   has not been moved relative to the volume)
arguments
    trimSize    (1,:) double {mustBeInteger} % Final volume size
    nifti             struct
end
arguments (Repeating)
    varargin
end
% May need original volume size (pre-rotation)
switch nargin
    case 2
        err = ['Scale and trajectory information are necessary ',...
            'when volume has been reoriented'];
        error(err);
    case {5, 6, 7}
        scale       = varargin{1};
        scalpLocation = varargin{2};
        ctxTarget   = varargin{3};
        origSize    = varargin{5};
        % widthTarget = setwidthTarget(origSize, scale);
        widthTarget = trimSize; % Now set as tusx_sim_setup param (or default)
        dimWidth    = setDimWidth(widthTarget, scale); % For 512, scale 4: dimWidth = 122
        % Find current indices of points. Use them
        %   scalp_ind & target_ind
        scalp_ind   = closestPointFinder(scalpLocation,...
            nifti.Xgrid, nifti.Ygrid, nifti.Zgrid); % [grid points]
        target_ind  = closestPointFinder(ctxTarget,...
            nifti.Xgrid, nifti.Ygrid, nifti.Zgrid); % [grid points]
        % Should also be able to use MATLAB index version of transformation
        % matrices instead of closestPointFinder.
        %   If the two approaches don't match: Something's gone wrong
        
        % Find midpoint between the scalp and target voxels
        %   Center aound midpoint
        %   Shift to stay volume limits, if necessary
        trm = fitTrmToTrajectory_reorient(scale, scalp_ind, target_ind,...
                dimWidth, nifti.size);
    otherwise
        error('Invalid number of parameters');
end
end

function [newStarts, newEnds] = shiftToFit(volSize, starts, ends)
% shiftToFit Shift calculated limits to fit within volume limits
% Upper (check ends)
upperAdjust = volSize - ends; % Limits that are too large will be negative
% Only include those dimensions that need adjusting (upper)
upperAdjust(upperAdjust > 0) = 0; % Remove those that are fine

% Lower (check starts)
lowerAdjust = 1 - starts; % Limits that are too small will be positive
% Only include those dimensions that need adjusting (lower)
lowerAdjust(lowerAdjust < 0) = 0;

% Assure an upper and lower adjustment isn't required in the same dimension
%   (i.e. volume is smaller than limits)
if any(upperAdjust & lowerAdjust) % If adjustment needed in both directions
    e1 = 'The requested size of the trimmed volume, "trimSize", ';
    e2 = 'or its default value is too big for one or more dimensions of ';
    e3 = 'this volume, given the scale. Either decrease the size ';
    e4 = 'of trimSize or increase the scaling factor.';
    error([e1 e2 e3 e4])
end

% Adjust limits (starts & ends)
adjust = upperAdjust + lowerAdjust; % Consolidate
newStarts = starts + adjust;
newEnds = ends + adjust;
end

function ctr_ind = setCenter_toTrajectory(scalp_ind, target_ind, bias)
% Find index between the two indies
%   Could add an optional 'bias' parameter, shifting the center along a
%   line between the two points (0.0 centered on scalp, 1.0 centered on
%   target; default of 0.5)
arguments
    scalp_ind   (1,3) double {mustBeInteger}
    target_ind  (1,3) double {mustBeInteger}
    bias        (1,1) double = 0.5
end
ctr_ind = floor(mean([scalp_ind; target_ind]));
end

function [starts, ends] = shiftTransducerToEdge(starts, ends, scalp_ind, target_ind, dimWidth)
%   Shift start and end so transducer is towards the edge
%       Assuming the volume has been reoriented to be orthogonal to the
%       trajectory, scalp_ind and target_ind will share 2/3 coordinates.
%       Adjust the limits along the dimension of travel of the trajectory
[~, dimOfTravel] = max(scalp_ind - target_ind); % Dimension of travel (1,2,or 3)
if scalp_ind(dimOfTravel) > target_ind(dimOfTravel)
    newEdge_hi = scalp_ind(dimOfTravel) + 1; % Set edge to 1 away from transducer
    newEdge_lo = newEdge_hi - (dimWidth - 1);
elseif scalp_ind(dimOfTravel) < target_ind(dimOfTravel)
    newEdge_lo = scalp_ind(dimOfTravel) - 1; % Set edge to 1 away from transducer
    newEdge_hi = newEdge_lo + (dimWidth - 1);
else
    error('Cannot determine trajectory directory from given information.');
end
starts(dimOfTravel) = newEdge_lo;
ends(dimOfTravel) = newEdge_hi;
end