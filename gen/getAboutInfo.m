function infoStr = getAboutInfo
% Create string array of general information about the function
dateStr = datestr(datetime);
os = computer('arch');
ver = version;
username = getUsername;

l1 = string(dateStr);
l2 = strcat("OS: ", os);
l3 = strcat("MATLAB Version: ", ver);
l4 = strcat("Username: ", username);

infoStr = vertcat(l1, l2, l3, l4);
end

function username = getUsername
if ispc
    username = getenv('username');
elseif isunix
    [~,username] = system('whoami'); 
else
    error('Unexpected computer')
end
username = strtrim(username);
end