function tf = sbjcmp(filename1,filename2,expression)
%SBJCMP Compare filenames to if they share same subject name
%   Compares two filenames using regexp. Function looks for the first
%   appearance of the regular expression in each. If they match, it returns
%   true. If false, it throws and error.
%
%   expression
%       Default: 'sbj\d\d' (sbj##: "sbj" followed by two digits) 
arguments
    filename1 (1,:) char
    filename2 (1,:) char
    expression (1,:) char = 'sbj\d\d'
end
[~,filename1] = fileparts_gz(filename1); % Get just file name
[~,filename2] = fileparts_gz(filename2);
[i_s1, i_e1] = regexp(filename1, expression); % Get indices of match
[i_s2, i_e2] = regexp(filename2, expression);
sbj1 = filename1(i_s1:i_e1); % Get result
sbj2 = filename2(i_s2:i_e2);

% Throws error if the two files are not of the same subject
if ~strcmpi(sbj1, sbj2)
    tf = false;
    error('Subject IDs do not match')
elseif strcmpi(sbj1, sbj2)
    tf = true;
end
end

