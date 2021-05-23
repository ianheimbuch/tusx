function checkSensorMediumMatch(sensor, medium)
% CHECKSENSORMEDIUMMATCH Internal test function for tusx_sim_setup
%   Returns error if grid fields of sensor and medium structs do not match
%   sizes
%       Could occur if trimming processes failed

% If any dimensions do not match
if any( size(sensor.mask) ~= size(medium.density) )
    message = strcat('Matrices in sensor and medium structures do not match in size',...
        'This may have occurred due to failed importing or trimming of masks');
    error(message)
end
end