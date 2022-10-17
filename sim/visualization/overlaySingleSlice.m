function [f, ax] = overlaySingleSlice(sensorVolume, structuralVolume, matrixIndices, plane)
arguments
    sensorVolume (:,:,:) % Reshaped 3D volume e.g. from sensor_data.p_max [Pascals]
    structuralVolume (:,:,:) % Matching volume created by tusx_sim_t1Export()
    matrixIndices (1,3) % Matrix indices to indicate where to slice volumes
    plane (1,:) char % 'coronal', 'horizontal', or 'sagittal'
end
%overlaySingleSlice

% Make figure (varies by plane direction)
switch plane
    case 'horizontal'
        ind = 3;
        
        %   Get single slice as array
        slice = getHorizontal(sensorVolume, matrixIndices(ind));
        slice_kPa = slice / 1000; % Convert Pa to kPa
        
        %   Get structural T1
        slice_t1  = getHorizontal(structuralVolume, matrixIndices(ind));
        
        % Reorient to standard MRI orientation
        slice_kPa = reorient(slice_kPa);
        slice_t1  = reorient(slice_t1);
    case 'coronal'
        ind = 2;
        
        %   Get single slice as array
        slice = getCoronal(sensorVolume, matrixIndices(ind));
        slice_kPa = slice / 1000; % Convert Pa to kPa
        
        %   Get structural T1
        slice_t1  = getCoronal(structuralVolume, matrixIndices(ind));
        
        % Reorient to standard MRI orientation
        slice_kPa = reorient(slice_kPa);
        slice_t1  = reorient(slice_t1);
    case 'sagittal'
        ind = 1;
        
        %   Get single slice as array
        slice = getSagittal(sensorVolume, matrixIndices(ind));
        slice_kPa = slice / 1000; % Convert Pa to kPa
        
        %   Get structural T1
        slice_t1  = getSagittal(structuralVolume, matrixIndices(ind));
        
        % Reorient to standard MRI orientation
        slice_kPa = reorient(slice_kPa);
        slice_t1  = reorient(slice_t1);
    otherwise
        error('Invalid parameter for plane')
end

[f, ax] = overlay_helper(slice_kPa, slice_t1, plane);
f.PaperPosition = [0 0 6 6]; % Set figure to be square (6 by 6 inches)
                             % Keeps it from warping, since data is 1 by 1
end

function [figHandle, ax1] = overlay_helper(slice_kPa, slice_t1, plane, clim)
arguments
    slice_kPa (:,:)
    slice_t1 (:,:)
    plane (1,:) char
    clim (1,2) = [min(slice_kPa,[],'all') max(slice_kPa,[],'all')]
end

switch plane
    case 'horizontal'
        titleMod = 'Horizontal';
    case 'coronal'
        titleMod = 'Coronal';
    case 'sagittal'
        titleMod = 'Sagittal';
    otherwise
        error('Invalid input for parameter: plane')
end
% clim: Colormap limits, [alphaThreshold slicesMax]
alphaThreshold  = clim(1);
alphaAll        = 0.5; % 0 to 1

% % Reorient to standard MRI orientation
% coronal_kPa = reorientCoronal(coronal_kPa);
% coronal_t1  = reorientCoronal(coronal_t1);

% Set transparency matrix for pressure image
coronal_thresh = slice_kPa > alphaThreshold;
coronal_alpha = single(coronal_thresh);
coronal_alpha(coronal_thresh) = alphaAll;

% Create figure
% subtitle = strcat(sbj, ", Trajectory #", num2str(row));
% thisTitle = {'Coronal Slice through Target Voxel'; subtitle};
figHandle = figure;
ax1 = axes;
imagesc(ax1, slice_t1);
pbaspect(ax1, [1 1 1]);
daspect(ax1, [1 1 1])
ax1.XTick = [];
ax1.YTick = [];
colormap(ax1, 'gray'); % Pressure data colormap
hold on;
ax2 = axes;
imagesc(ax2, slice_kPa, 'AlphaData', coronal_alpha); % Overlay skull mask
pbaspect(ax2, [1 1 1]);
daspect(ax2, [1 1 1]);
hold off;
colormap(ax2, 'jet');  % Skull mask colormap
c1 = colorbar(ax1, 'Location', 'eastoutside'); % Placeholder bar to align
c2 = colorbar(ax2, 'Location', 'eastoutside'); % Show colorbar
caxis(ax2, clim);               % Set colormap limits
ax2.Visible = 'off';            % Hide tick marks (except first axis' title)
ax2.Color = 'none';             % Hide white background (so can see T1)
figHandle.Children(3).Visible = 'off';  % Hide skull mask's colorbar (c2)
linkaxes([ax1 ax2]);
c2.Label.String = "kPa (peak-to-peak, max)";
title(ax1, titleMod);
end

function slice = reorient(slice)
% Reorient slice to standard MRI orientation
%   Works for coronal and horizontal slices
slice = flip(slice);
slice = rot90(slice);
end

function coronal = getCoronal(vol, APind)
% APind: index
coronal = squeeze(vol(:, APind, :));
end

function horizontal = getHorizontal(vol, DVind)
% DVind: index
horizontal = squeeze(vol(:, :, DVind));
end

function sagittal = getSagittal(vol, LRind)
% LRind: index
sagittal = squeeze(vol(LRind, :, :));
end