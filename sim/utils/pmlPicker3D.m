function PMLSize = pmlPicker3D(kgrid)
% pmlPicker3D Chooses low prime factor PML sizes for exterior PMLs in
% k-Wave
%   Chooses a size of the perfectly matched layer (PML) to avoid large
%   prime factors.
%   This function is only applicable when 'PMLInside' == false

% Check input is a an object of class 'kWaveGrid'
if ~isa(kgrid,'kWaveGrid')
    error('Input must be of class kWaveGrid');
end

borderRange = [10:60]';
kgridSize   = [kgrid.Nx kgrid.Ny kgrid.Nz];
PMLSize     = nan(1,3);
for dim = 1:3
    dimLength = kgridSize(dim);
    % If dimLength + 2*10 is a factor of 2, then it can't get better. Move on
    if max(factor(dimLength + 2*10)) == 2
        PMLSize(dim) = 10;
        continue
    end
    
    % Length of dim will be original length + double the prospective
    % PMLSize (which occurs twice: one on each side of the dim)
    potentialLengths = dimLength + 2*borderRange;
    primeFlag = false(size(borderRange));   % Initialize column for isprime
    maxFactor = nan(size(borderRange));    % Initialize col. of largest factor
    for el = 1:numel(borderRange)
        sTemp = potentialLengths(el);
        primeFlag(el) = isprime(sTemp);
        maxFactor(el) = max(factor(sTemp));
    end
    % Make decision for this dim, based on results
    PMLSize(dim) = decidePML(borderRange, potentialLengths, maxFactor);
end

% This function will only change the PMLSize. This has the weakness of only
% being able to add in multiples of 2, since PML can only be specified as a
% single scalar per dimension (a PML of that size appears on each end of
% that dimension). Odd numbers tend to have higher max prime factors than
% even numbers (even numbers can't be prime)
% This weakness could be gotten around by altering the kgrid itself,
% whether by removing a single slice or adding a single slice of the same
% acoustic properties as the background. I did not implement this fix, as
% of July 9, 2019
end

function chosenPMLSize = decidePML(borderRange, potentialLengths, maxFactor)
% Internal function of pmlPicker3D. Makes decision of which PML size to go
% with. Decision is based on this function's internal algorithm and any
% provided weights, if applicable.
%   Max factor is squared in the scoring algorithm. This effectively
%   chooses small factors sizes irrespective to potentialLength size,
%   unless the mimimukm maxFactors are above ~15

% Set weight parameters
%   In the future, edits could be made to allow the inclusion of these as 
%   input parameters in the function itself
wS = 1; % Weight given for the dimension size's contribution to decision
wF = 1; % Weight given for max factor's contribution to decision

% Smallest max factor highly weighted by squaring
scores = (wS * potentialLengths) .* (wF * maxFactor.^2);
chosenPMLSize = borderRange(find(scores == min(scores),1));
end