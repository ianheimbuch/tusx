function transducer = getDefaultTransducer
% Default values for transducer
transducer.focalLength_m = 0.03;                    % [m]
transducer.freq_MHz = 0.5;                          % [MHz]
transducer.freq_Hz = transducer.freq_MHz .* (1e6);  % [Hz]
transducer.source_mag_Pa = 0.66e6;                  % [Pa]
end