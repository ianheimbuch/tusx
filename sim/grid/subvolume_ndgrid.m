function [new1grid, new2grid, new3grid, newV] = subvolume_ndgrid(dim1grid, dim2grid, dim3grid, V, ndLimits)
%SUBVOLUME_NDGRID Wrapper of subvolume() for ndgrid-type space (nd space)
%   
%   Subvolume:
%   [NX, NY, NZ, NV] = SUBVOLUME(X,Y,Z,V,LIMITS)
%
%   [Nx,Ny,Nz,Nv] = subvolume(V,limits) assumes the arrays X, Y, and Z are defined as
% 
%       [X,Y,Z] = meshgrid(1:N,1:M,1:P) 
arguments
    dim1grid (:,:,:) {mustBeNumeric}
    dim2grid (:,:,:) {mustBeNumeric}
    dim3grid (:,:,:) {mustBeNumeric}
    V        (:,:,:) {mustBeNumericOrLogical}
    ndLimits (1,6)   {mustBeNumeric}
end
% Swap X and Y limits (for subvolume format)
LIMITS = [ndLimits(3:4) ndLimits(1:2) ndLimits(5:6)];
X = dim2grid; % X for subvolume is 2nd matrix dimension
Y = dim1grid; % Y for subvolume is 1st matrix dimension
Z = dim3grid;
% [NX, NY, NZ, NV] = subvolume(X,Y,Z,V,LIMITS);
%   Use of subvolume with meshgrids is broken if volume has been reoriented
%   Instead do subvolume three times with simpler syntax: subvolume(V, limits)
[~, ~, ~, NX] = subvolume(X,LIMITS);
[~, ~, ~, NY] = subvolume(Y,LIMITS);
[~, ~, ~, NZ] = subvolume(Z,LIMITS);
[~, ~, ~, NV] = subvolume(V,LIMITS);
new2grid = NX;
new1grid = NY;
new3grid = NZ;
newV     = NV;
end

