function trimmed = trimToEven(mStruct)
% trimToEven(mStruct)
% Trims mask structures down to be even dimension lengths
%   Removes last dimension spot, when necessary
%   Intended for use after scaling
%
% .affines is passed on unchanged since trimming is done on upper limits

lengths = size(mStruct.mask);
remainders = mod(lengths, 2); % Divide by two, to see if odd/even

% Trim mask
%   If remainder was 0: Will remain unchanged
%   If was odd: One slice will be removed from UPPER ends
mStruct.mask = mStruct.mask(1:(end - remainders(1)), 1:(end - remainders(2)),...
    1:(end - remainders(3)));

% Update size
mStruct.size = size(mStruct.mask);

% Trim grids
mStruct.grids.Xscaled = mStruct.grids.Xscaled(1:(end - remainders(1)),...
    1:(end - remainders(2)), 1:(end - remainders(3)));
mStruct.grids.Yscaled = mStruct.grids.Yscaled(1:(end - remainders(1)),...
    1:(end - remainders(2)), 1:(end - remainders(3)));
mStruct.grids.Zscaled = mStruct.grids.Zscaled(1:(end - remainders(1)),...
    1:(end - remainders(2)), 1:(end - remainders(3)));

% Trim ticks
if isfield(mStruct, 'ticks') % Do only if 'ticks' is already a field
mStruct.ticks.Xscaled = mStruct.ticks.Xscaled(1:(end - remainders(1)));
mStruct.ticks.Yscaled = mStruct.ticks.Yscaled(1:(end - remainders(2)));
mStruct.ticks.Zscaled = mStruct.ticks.Zscaled(1:(end - remainders(3)));
end

trimmed = mStruct;
end