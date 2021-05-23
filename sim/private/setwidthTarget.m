function widthTarget = setwidthTarget(volSize, scale)
% setwidthTarget Set final width target
%   Goal: Final lengths of powers of 2
%   Considers: Original volume size, so know how big volume should be
%
% Ideally, this would be:
%   Set by volume dimensions
%   Three separate width targets: one per dimension
%   (In progress implementing, 5/11/20)
%
%   volSize: Original volume size if reoriented. Current volume size if not
%   reoriented
arguments
    volSize (1,3) double {mustBeInteger}
    scale   (1,1) double {mustBeInteger}
end

% All three sizes
% (also works for single-elements; must change how other functions use it
% if start to output vector (or change parameter input to single element)
%   Find next power of two
pow2hi = nextpow2(volSize);
%   Find lower power of two
pow2lo = pow2hi - 1;
%   Compare distance between to decide which to go for
toHi = pow2(pow2hi) - volSize; % How far from higher power of two
toLo = pow2(pow2lo) - volSize; % How far from lower power of two

% Take into consideration PML? (10 per side minimum)
%   Take into account how setDimWidth() considers PML

widthTarget = pow2(pow2hi); % WIP: Would output higher power of 2s without considering low

% Stay with hardcode, for now (5/12/20)
% widthTarget = 512;
widthTarget = max(widthTarget);
end