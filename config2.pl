% 0 for emapty cell, 1 for wall, 2 for cells of the object to be escaped,
% other values for cells of the obstacles 
% each object only move along its spine/long-axis
board([
    [1,1,1,1,1,1,1,1],
    [1,0,6,6,0,0,0,1],
    [1,0,0,0,0,0,3,1],
    [1,0,2,2,2,0,3,0],
    [1,0,0,0,0,0,3,1],
    [1,0,0,0,4,4,4,1],
    [1,5,5,5,5,5,5,1],
    [1,1,1,1,1,1,1,1]
]).
% [CV, L, D] : [cell_value, length, 0-for_horizontal/1-for_vertical movement]
escapee([2,3,0]).
obstacles([[3,3,1],[4,3,0],[5,6,0],[6,2,0]]).