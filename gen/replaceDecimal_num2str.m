function newString = replaceDecimal_num2str(origNum)
% Repalces any decimal point in a string to the characters: pt
%   newString = replaceDecimal_num2str(origNum)
%
%   origNum: Value of a numerical type
%
%   Is a wrapper function for num2str() and strrep() [string replace]
%   Intended use case:
%       num2str() for alpha power, in prep for use in file names
%       Example: 1.1 -> '1pt1'
origNum = num2str(origNum);
newString = strrep(origNum,".","pt");
end