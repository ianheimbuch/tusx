function medium = setMediumToWater(medium, water)
% setMediumToWater Helper function to set entire "medium" array used in 
% k-wave to new values (e.g. water)
%   medium = setMediumToWater(medium, water) 
%   medium: k-wave struct of acoustic property values for all points of the 
%   simulation area 
%   water: A structure that contains the acoustic properties of 
%   interest. Must have following fields: 
%       .speed          [m/s] 
%       .density        [kg/m^3] 
%       .alphaCoeff     [dB/(MHz^y cm)] 
medium.sound_speed(:)   = water.speed; 
medium.density(:)       = water.density; 
medium.alpha_coeff(:)   = water.alphaCoeff; 
end