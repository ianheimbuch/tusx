function skull = getDefaultSkull
% Default acoustic values for skull
skull = struct;
skull.density = 1850;    % [kg/m^3]
skull.speed   = 3000;    % [m/s]
skull.attenConstant_Np_m = 53; % [Np / m] - 53 is from Connor 2005

skull.attenConstant_dB_cm = NptodB(skull.attenConstant_Np_m) / 100;
end