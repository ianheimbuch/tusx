function brain = getDefaultBrain
% Default acoustic values for brain
%   These are the values for everything that is not skull
%   Warning: Default values assume transducer frequency of 0.5 MHz
brain = struct;

brain.density = 1035;    % [kg/m^3]
brain.speed   = 1546.3;  % [m/s]
brain.attenConstant_Np_m = 2.76; % [Np / m] Currently from:
                                 %  itis.ethz.ch database for 0.5 MHz

brain.attenConstant_dB_cm = NptodB(brain.attenConstant_Np_m) / 100;
end