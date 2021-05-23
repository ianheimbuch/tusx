function water = getDefaultWater
% Get default water values
% % SET WATER
water.density = 998;     % [kg/m^3]
water.speed   = 1482;    % [m/s]
water.attenConstant_Np_m = 2.8800e-04; % [Np / m] - 2.8800e-04 is from Connor 2005, which used Duck 1990

water.attenConstant_dB_cm = NptodB(water.attenConstant_Np_m) / 100;
end