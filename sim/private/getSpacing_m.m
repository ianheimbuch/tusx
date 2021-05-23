function spacing_m = getSpacing_m(voxelDimensions, dimensionUnit)
% getSpacing_m Enable conversion to meters
%   Private function for tusx_sim_setup()
arguments
    voxelDimensions (1,3) double {mustBeNumeric}
    dimensionUnit   (1,:) char
end
switch dimensionUnit
    case {'millimeter','mm','millimeters'}
        correctionFactor = 1/1000;
    case {'centimeter','cm','centimeters'}
        correctionFactor = 1/100;
    case {'meter','m','meters'}
        correctionFactor = 1;
    otherwise
        error('Unexpected unit for voxel dimensions / grid spacing');
end

spacing_m.dim1 = voxelDimensions(1) * correctionFactor;
spacing_m.dim2 = voxelDimensions(2) * correctionFactor;
spacing_m.dim3 = voxelDimensions(3) * correctionFactor;
end