%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%give more ram to prolog
:- initialization  set_prolog_flag(stack_limit, 10_147_483_648).

% print a board
print_board([]).
print_board([Row|Rows]) :-
    print_row(Row),
    nl,
    print_board(Rows).
print_row([]).
print_row([Cell|Cells]) :-
    write(Cell),
    write(' '), 
    print_row(Cells).    

% print a list of boards
print_boards([]).
print_boards([Board|Rest]):-
    print_board(Board),
    nl,
    write('Press a key to continue'),nl,nl,
    get_single_char(_),
    print_boards(Rest).

% connect L1 and L2
connect([], L2, L2).
connect([H|T], L2, [H|T2]):-
    connect(T, L2, T2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Locate X, Y coordinations of an object (represented by the cell value of the object) in a board.
% The first cell in the first row of the board has value of the object.
% CV is the cell value of the object.
% Row is the first row which contains the cell value of the object. 
at_xy(Board, CV, X, Y, Row):-
    is_member(CV,Row),
    index(X, Board, Row),
    index(Y, Row, CV),!.

% check if no obstacle for an object to escape
% test: no_obstacles([1, 4, 0, 2, 2, 0, 5, 0], 2, 3).
% test: no_obstacles([1, 4, 0, 2, 2, 0, 0, 0], 2, 3). 
% Row contains the object, CV value of the object, X position of the object in Row
no_obstacles([],_,_).
no_obstacles([_|T], CV, X):-
    X>=0,
	X1 is X-1,
    no_obstacles(T, CV, X1).
no_obstacles([CV|T], CV, -1):-
    no_obstacles(T, CV, -1).
no_obstacles([0|T], CV, -1):-
    no_obstacles(T, CV, -1).

% check if the object can escape
% test: board(Board), escapee(E), can_escape(Board, E).
can_escape(Board, [CV,_,_]):-
	at_xy(Board, CV, _, X, Row),
    no_obstacles(Row,CV,X).

%%%%%%%%%%%%%%%%%%%%%%%%-HORIZONTAL MOVE

% Given a status row Row, generate all possible status rows (SLRows) that are the result 
% by moving the object (represented value CV) at position X, length L 
% to the left with all possible distances.
shift_left_many(Row, _, X, _, []):-
    LeftPos is X-1, 
    \+index(LeftPos, Row, 0),!.
shift_left_many(Row, CV, X, L, [NewRow|SLRows]):-
    LeftPos is X-1, 
    index(LeftPos, Row, 0),
    replace_at_index(Row,LeftPos,CV,NewR),
    LastPos is X+L-1, 
    replace_at_index(NewR,LastPos,0,NewRow),
    shift_left_many(NewRow, CV, LeftPos, L, SLRows).

% Given a status row Row, generate all possible status rows (SRRows) that are the result 
% by moving the object (represented value CV) at position X, length L 
% to the right with all possible distances.
shift_right_many(Row, _, X, L, []):-
    RightPos is X+L, 
    \+index(RightPos, Row, 0),!.
shift_right_many(Row, CV, X, L, [NewRow|SRRows]):-
    RightPos is X+L, 
    index(RightPos, Row, 0),
    replace_at_index(Row,RightPos,CV,NewR),
    replace_at_index(NewR,X,0,NewRow),
    NewPos is X+1,
    shift_right_many(NewRow, CV, NewPos, L, SRRows).

% Update row at index Y in the given board (Board) with each row in ShiftRows
% to generate all possible next boards.
gen_Hshift_boards(_, [], _, []).
gen_Hshift_boards(Board, [Row|ShiftRows], Y, [B|NextBoards]):-
    replace_at_index(Board,Y,Row,B),
    gen_Hshift_boards(Board, ShiftRows, Y, NextBoards).

% Given an input board (Board), generate all next boards (NextBoards) by moving horizontally the object (Object)
% test: board(B), escapee(O), next_Hshift_boards(B, O, NextBoards), print_boards(NextBoards).
next_Hshift_boards(Board, Object, NextBoards):-
    Object=[CV,L,0],
    at_xy(Board, CV, X, Y, Row),
    shift_left_many(Row, CV, Y, L, SLRows), 
    shift_right_many(Row, CV, Y, L, SRRows),
    connect(SLRows,SRRows,ShiftRows),
    gen_Hshift_boards(Board, ShiftRows, X, NextBoards).

%%%%%%%%%%%%%%%%%%%%%%%%-VERTICAL MOVE

% get the column at index X in the board
% test: board(B), print_board(B), get_column_at(B, 6, Column). Column is the column at index 6 of the board B
get_column_at([], _, []).
get_column_at([Row|Rows], X, [H|T]):-
    index(X, Row, H),
    get_column_at(Rows, X, T).

% update column at index X in the board with input column Column.
% test: board(B), print_board(B), set_column_at(B, [1, 0, 0, 3, 3, 3, 0, 1], 6, B1), print_board(B1).
set_column_at([], [], _, []).
set_column_at([Row|Rows], [H|T], X, [NewR|UpdatedBoard]):-
    replace_at_index(Row, X, H, NewR),
    set_column_at(Rows, T, X, UpdatedBoard).

% Update column at index X in the given board (Board) with each column in ShiftColumns
% to generate all possible next boards.
gen_Vshift_boards(_, [], _, []).
gen_Vshift_boards(Board, [Shift|ShiftColumns], X, [NextBoard|NextBoards]):-
    set_column_at(Board, Shift, X, NextBoard),
    gen_Vshift_boards(Board, ShiftColumns, X, NextBoards).

% Given an input board (Board), generate all next boards (NextBoards) by moving vertically the object (Object)
next_Vshift_boards(Board, Object, NextBoards):-
    Object=[CV,L,1],
    at_xy(Board, CV, X, Y, _),
    get_column_at(Board, Y, Column),
    shift_left_many(Column, CV, X, L, SUCols), 
    shift_right_many(Column, CV, X, L, SDCols),
    connect(SUCols,SDCols,ShiftColumns),
    gen_Vshift_boards(Board, ShiftColumns, Y, NextBoards).


%%%%%%%%%%%%%%%%%%%%%%%%-NEXT BOARDS FROM THE CURRENT BOARD

% get all next boards from the current board by moving Object
% test: board(B), escapee(O), next_boards(B, O, NextBoards), print_boards(NextBoards).
next_boards(Board, Object, NextBoards):-
    Object=[_,_,0],
    next_Hshift_boards(Board, Object, NextBoards).
next_boards(Board, Object, NextBoards):-
    Object=[_,_,1],
    next_Vshift_boards(Board, Object, NextBoards).

% get all next boards from the current board
next_boards_manyObjs(_, [], []).
next_boards_manyObjs(Board, [O|Rest], AllNextBoards ):-
    next_boards(Board, O, NextBoards),
    next_boards_manyObjs(Board, Rest, Next),
    connect(NextBoards,Next,AllNextBoards).


%%%%%%%%%%%%%%%%%%%%%%%%-DFS FOR FINDING A SOLUTION

% 1. Board is the current Board, a node in the context of tree traverse
% 2. Objs is the list of all objects, including Escapee
% 3. E is the object to be escaped, Escapee
% 4. Stack is a list of remaining boards to be traversed in Depth-First order, 
% each board/node paired with its parent node [ANode, ItsParentNode]
% 5. Path is the path from root to the parent of the current node Node
% 6. Solution is the path from root to the current node Node

%case when all possible positions explored and solution dosen't exist
dfs(_, _, _, _,_ ,_,N,N):-
    write('Not possible to solve this configuartion'),nl,!.

%case when Escapee can escape in the next move
dfs(Board, _, E, Stack ,Stack,B,_,_):-
   \+can_escape(Board,E),
    solution_in_stack(E,Stack,B).

%case when Escapee cannot escape in the next move we add another move following the dfs algorithm
dfs(Board, Objs, E, Stack,FinalStack ,Solution,D,K):-
    D \= K,
   \+can_escape(Board,E),
   \+solution_in_stack(E,Stack,_),
	add_to_stack(Stack,Objs,NewStack),
    optimize_stack(NewStack,NewStackO),
    list_length(NewStackO,N),
    write('Positions explored: '),write(N),nl,
    dfs(Board, Objs, E, NewStackO,FinalStack ,Solution,K,N).

%If the solution is not found in all the moves, generate a new child node
add_to_stack([],_,[]).
add_to_stack([[B|Parents]|Rest],Objs,NewStack):-
    next_boards_manyObjs(B,Objs,NextBoards),
    connect_nodes([B|Parents],NextBoards,Stack),
    add_to_stack(Rest,Objs,NewStack1),
    connect(Stack,NewStack1,NewStack).

%add the child node to the path
connect_nodes(_,[],[]).
connect_nodes(Parents,[N|Nodes],[L|Rest]):-
    connect([N],Parents,L),
    connect_nodes(Parents,Nodes,Rest).

%check if the first node contains the solution
solution_in_stack(_,[],_):-fail.
solution_in_stack(Escapee,[[B|_]|_],B):-
   can_escape(B,Escapee),
   nl,write('Game Solved'),nl,!.
solution_in_stack(Escapee,[[B|_]|Rest],Solution):-
   \+can_escape(B,Escapee),
   solution_in_stack(Escapee,Rest,Solution).																
 
% test: board(B), escapee(E), obstacles(Obs), connect([E], Obs, Objects), find_solution(B, Objects, E, Solution).
find_solution(Board, Objects, Escapee, Solution):-
    next_boards_manyObjs(Board,Objects,NextBoards),
    connect_nodes([Board],NextBoards,Stack),
    dfs(Board, Objects, Escapee, Stack,FS, FinalBoard,0,1),
    is_member(S,FS),S=[FinalBoard|_],
    reverselist(S,Solution).
   

%%%%%%%%%%%%%%%%%%%%%%%%-RUN WITH A CONFIGURATION FILE

% consult the input confiuration file, find a solution via find_solution predicate and print the solution
% test: run('path_to_configuration_file').
run(Filename):-
    consult(Filename),
    board(B), escapee(E), obstacles(Obs), 
    connect([E], Obs, Objects), 
    find_solution(B, Objects, E, Solution),
    write('Total moves: '),list_length(Solution,N),
    Moves is N-1, write(Moves),nl,nl,
    write('Initial Board:'),nl,nl,
    print_boards(Solution).

%%%%% Helper predicates 

%element is a member in a list
is_member(X, [X|_]).        
is_member(X, [_|Tail]) :-   
  is_member(X, Tail). 

%% gets the index of an element in a list
index(0, [Elem|_], Elem).
index(Index, [_|Tail], Elem) :-
    index(Index1, Tail, Elem),
    Index is Index1 + 1.

%% replaces an element in a list at index Index
replace_at_index(List, Index, NewElem, Result) :-
    replace_at_index_helper(List, Index, NewElem, 0, Result).
replace_at_index_helper([_|T], Index, NewElem, Index, [NewElem|T]).
replace_at_index_helper([H|T], Index, NewElem, Acc, [H|Result]) :-
    Index \= Acc,
    NewAcc is Acc + 1,
    replace_at_index_helper(T, Index, NewElem, NewAcc, Result).

% reverse a list (to help print boards from root to solution)
reverselist(List, Rev) :-
    reverselist(List, [], Rev),!.
reverselist([], Rev, Rev).
reverselist([H|T], Acc, Rev) :-
    reverselist(T, [H|Acc], Rev).

% gets the length of a list
list_length([],0).
list_length([_|T],N):- list_length(T,N1), N is N1+1.

%optimize_stack, if node reached twice remove it from stack
optimize_stack([],[]).
optimize_stack([H|T],[H2|T2]):-
    H=[Child|_], is_member([Child|_],T),
    optimize_stack(T,[H2|T2]).
optimize_stack([H|T],[H|T2]):-
    H=[Child|_], \+is_member([Child|_],T),
    optimize_stack(T,T2).


