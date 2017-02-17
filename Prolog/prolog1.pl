%%%% 808292 Habbash Nassim

% ---- Input control

is_term(A) :- var(A), !.
is_term(A) :- atomic(A), !.

is_term(A) :- A =.. [Name|List], 
	is_term(Name), foreach(member(L, List), is_term(L)).

is_wff(A) :- is_term(A).
is_wff(not(A)) :- is_wff(A).
is_wff(and(A, B)) :- is_wff(A), is_wff(B).
is_wff(or(A, B)) :- is_wff(A), is_wff(B).
is_wff(implies(A, B)) :- is_wff(A), is_wff(B).
is_wff(exist(A, B)) :- var(A), is_wff(B).
is_wff(every(A, B)) :- var(A), is_wff(B).

% ---- Rewrite rules for conversion of generic FOL formula to CNF

%% Implication in terms of or
rew(implies(A, B), Univars, F) :- rew(or(not(A), B), Univars, F).

%% Negation inwards
rew(not(not(A)), Univars, F) :- rew(A, Univars, F).
rew(not(and(A, B)), Univars, F) :- rew(or(not(A),not(B)), Univars, F).
rew(not(or(A, B)), Univars, F) :- rew(and(not(A), not(B)), Univars, F).
rew(not(implies(A, B)), Univars, F) :- 
	rew(implies(not(A), not(B)), Univars, F).
rew(not(every(X, B)), Univars, F) :- rew(exist(X, not(B)), Univars, F).
rew(not(exist(X, B)), Univars, F) :- rew(every(X, not(B)), Univars, F).

%% Standardize variables

%% Move quantifiers outwards 
rew(and(every(X, A), B), Univars, F) :-  rew(every(X, and(A, B)), Univars, F).
rew(and(B, every(X, A)), Univars, F) :-  rew(every(X, and(A, B)), Univars, F).

rew(and(exist(X, A), B), Univars, F) :-  rew(exist(X, and(A, B)), Univars, F).
rew(and(B, exist(X, A)), Univars, F) :-  rew(exist(X, and(A, B)), Univars, F).

rew(or(every(X, A), B), Univars, F) :-  rew(every(X, or(A, B)), Univars, F).
rew(or(B, every(X, A)), Univars, F) :-  rew(every(X, or(A, B)), Univars, F).

rew(or(exist(X, A), B), Univars, F) :-  rew(exist(X, or(A, B)), Univars, F).
rew(or(B, exist(X, A)), Univars, F) :-  rew(exist(X, or(A, B)), Univars, F).

%% Skolemize quantifiers
rew(every(X, B), Univars, F) :-  append(Univars, [X], NewUnivars), rew(B, NewUnivars, F).

rew(exist(X, B), [], F) :- skolem_function(X, SK),
	X = SK, rew(B, [], F).
rew(exist(X, B), Univars, F) :- skolem_function(Univars, SK),
	X = SK, rew(B, Univars, F).

%% Rewrite the internal nodes of the formula
rew(and(A, B), Univars, and(A1, B1)) :- rew(A, Univars, A1), 
	rew(B, Univars, B1).
rew(or(A, B), Univars, or(A1, B1)) :- rew(A, Univars, A1), 
	rew(B, Univars, B1).

%% Base case
rew(A, _, A). 

% Distributivity law
dist(or(and(X, Y), Z), and(or(X, Z), or(Y, Z))) :- !.
dist(or(Z, and(X, Y)), and(or(X, Z), or(Y, Z))) :- !.

% Binary AND/OR to n-ary


simplify(A, B) :- 	A=..[Name, Arg1, Arg2], subset([Name], [or, and]), 
							not(compound(Arg1)), not(compound(Arg2)), B = A, !.

simplify(A, B) :- 	A=..[Name, Arg1, Arg2], subset([Name], [or, and]), 
						   	Arg1=..[Name|_], not(compound(Arg2)),
							simplify(Arg1, C), C=..[_|ArgsC], 
							append(ArgsC, [Arg2], ArgsB),
							B =.. [Name|ArgsB], !.
simplify(A, B) :- 	A=..[Name, Arg1, Arg2], subset([Name], [or, and]), 
						   	not(compound(Arg1)), Arg2=..[Name|_], 
							simplify(Arg2, C), C=..[_|ArgsC],
							append([Arg1], ArgsC, ArgsB),
							B =.. [Name|ArgsB], !.

simplify(A, B) :- 	A=..[Name, Arg1, Arg2], subset([Name], [or, and]), 
						   	Arg1=..[Name|_], Arg2=..[Name|_],
							simplify(Arg1, C), simplify(Arg2, D),
							C=..[_|ArgsC], D=..[_|ArgsD],
							append(ArgsC, ArgsD, ArgsB),
							B =.. [Name|ArgsB], !.
simplify(A, B) :- 	A=..[Name, Arg1, Arg2], subset([Name], [or, and]), 
						   	Arg1=..[Name|_], Arg2=..[DifferentName|_],
							simplify(Arg1, C), 
							subset([DifferentName], [or, and]), simplify(Arg2, D),
							C=..[_|ArgsC], D=..[_|ArgsD],
							append(ArgsC, ArgsD, ArgsB),
							B =.. [Name|ArgsB], !.
simplify(A, B) :- 	A=..[Name, Arg1, Arg2], subset([Name], [or, and]), 
						   	Arg2=..[Name|_], Arg1=..[DifferentName|_],
							simplify(Arg2, C),
							subset([DifferentName], [or, and]), simplify(Arg1, D),
							C=..[_|ArgsC], D=..[_|ArgsD],
							append(ArgsC, ArgsD, ArgsB),
							B =.. [Name|ArgsB], !.


% Horn check

% CNF Converter

tocnf(FBF, FCNF) :- is_wff(FBF), rew(FBF, _, SFBF), dist(SFBF, CNFFBF), simplify(CNFFBF, FCNF, and).

% ----- Utilities
% Generate skolem constants or functions
skolem_variable(V, SK) :- var(V), gensym(skv, SK).
skolem_function([], SF) :- skolem_variable(_, SF), !.
skolem_function([A | ARGS], SF) :-
	gensym(skf, SF_op),
	SF =.. [SF_op, A | ARGS].