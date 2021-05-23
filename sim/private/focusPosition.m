function C = focusPosition(A,B,dist_AC)
% focusPosition
%   On a line containing three points: A, B, and C (in that order)...
%   Given A, B, and the distance from A to C, this function returns C
%   
%   Example:
%       A = [1 2 3];
%       B = [4 7 9];
%       dist_AC = 30;
%
%       C = focusPosition(A, B, fist_AC)
%       C returned as [11.7571   19.9284   24.5141]
arguments
    A (1,3) double % coordinates of point A
    B (1,3) double % coordinates of point B
    dist_AC (1,1) double % distance between points A and C
end
direction = B-A;
normalized_direction = direction / norm(direction);
C = A + dist_AC.*normalized_direction;
end