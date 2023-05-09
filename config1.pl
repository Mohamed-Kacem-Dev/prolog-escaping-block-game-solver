% 0 for emapty cell, 1 for wall, 2 for cells of the object to be escaped,
% other values for cells of the obstacles 
% each object only move along its spine/long-axis
board([
    [1,1,1,1,1,1,1,1],
    [1,0,0,7,8,0,0,1],
    [1,0,0,7,8,0,0,1],
    [1,2,2,7,8,9,0,0],
    [1,0,6,0,0,9,0,1],
    [1,5,6,3,3,9,0,1],
    [1,5,4,4,0,0,0,1],
    [1,1,1,1,1,1,1,1]
]).

% [CV, L, D] : [cell_value, length, 0-for_horizontal/1-for_vertical movement]
escapee([2,2,0]).
obstacles([[3,2,0],[4,2,0],[5,2,1],[6,2,1],[7,3,1],[8,3,1],[9,3,1]]).

