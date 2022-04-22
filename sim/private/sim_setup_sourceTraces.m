function source = sim_setup_sourceTraces(source, kgrid, medium, transducerSpecs)
% sim_setup_sourceTraces Helper function for tusx_sim_setup
%   Creates sinusoidal pressure traces for each point within source.p_mask
arguments
    source          struct
    kgrid           kWaveGrid
    medium          struct
    transducerSpecs struct
end
% % Set pressure pattern (transducer output)
%   Define time-varying sinusoidal source/s
source_freq_MHz = transducerSpecs.freq_MHz; % [MHz]
source_freq_Hz = source_freq_MHz * 1e6;    % [Hz] Convert MHz to Hz
source_mag = transducerSpecs.source_mag_Pa; % [Pa]
source.p = source_mag * sin(2 * pi * source_freq_Hz * kgrid.t_array);

%   Filter the source to remove high frequencies not supported by the grid
source.p = filterTimeSeries(kgrid, medium, source.p);
end