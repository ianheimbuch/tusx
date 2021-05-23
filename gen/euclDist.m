function distance = euclDist(coor1, coor2)
% Euclidean distance between two coordinates
if iscolumn(coor1)
    coor1 = coor1';
end
if iscolumn(coor2)
    coor2 = coor2';
end
deltas = coor1 - coor2;
distance = sqrt( sum( deltas .^ 2 ));
end