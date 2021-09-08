function kWaveCheck
% kWaveCheck Checks that k-Wave is on search path. Returns error if not
if ~kWaveInstalled
    m1 = 'k-Wave is not on the MATLAB search path.';
    m2 = 'k-Wave is an open source acoustics toolbox for MATLAB (k-wave.org). TUSX is dependent on k-Wave to function.';
    m3 = 'If you have already downloaded k-Wave, add it to the MATLAB search path.';
    m4 = 'If you have not downloaded k-Wave, k-Wave can be downloaded at www.k-wave.org';
    mess = strjoin({m1, m2, m3, m4}, '\n'); % Join with newlines between each
    error(mess);
end
end

function isOnPath = kWaveInstalled
result = exist('k-Wave.m','file');
switch result
    case 2 % File 'k-Wave.m' exists on search path
        isOnPath = true;
    otherwise
        isOnPath = false;
end
end