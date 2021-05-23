function source_p = sim_setup_sourceFocus(source, kgrid,...
    transd_ind, target_ind, focus_m, speedSound)
% sim_setup_sourceFocus Helper function for tusx_sim_setup()
%   Adjusts the pressure traces to match the desired focal length using the
%   k-Wave function focus()
%   Output:
%       source_p: Adjusted form of source.p
%
%   If focus_m is the same as the radius of curvature of a spherical cap
%   voxel mask in source.p_mask, that means sim_setup_sourceFocus
%   is slightly refining the offsets of the pressure delays to more
%   accurately matched the aliased curvature of source.p_mask
arguments
    source struct
    kgrid kWaveGrid
    transd_ind (1,3) double
    target_ind (1,3) double
    focus_m    (1,1) double % Focal length for focus() [meters]
    speedSound (1,1) double = 1482 % Speed of sound used for calculations [m/s]
                            % Default is the speed of sound in water, since
                            % that's more than likely what its calibrated to
end
% Set focus using kgrid grids and focal point

% Coordinate of transducer location
transd_kgrid = [kgrid.x_vec(transd_ind(1)) ...
    kgrid.y_vec(transd_ind(2)) ...
    kgrid.z_vec(transd_ind(3)) ];

% Coordinate of second point on trajectory (aka 'target')
target_kgrid = [kgrid.x_vec(target_ind(1)) ...
    kgrid.y_vec(target_ind(2)) ...
    kgrid.z_vec(target_ind(3)) ];

% Coodinate of focal point on that trajectory
focus_position = focusPosition(transd_kgrid, target_kgrid, focus_m);
%   Adjust focus
%       source_p is adjusted form of source.p
source_p = focus(kgrid, source.p, source.p_mask, focus_position, speedSound);
end