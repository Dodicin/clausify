%%%% 808292 Habbash Nassim

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


% Rewrite rules for conversion
% rew(<input>, <universally quantified variables list>, <output>)

skolem_variable(V, SK) :- var(V), gensym(skv, SK).
skolem_function([], SF) :- skolem_var(_, SF).
skolem_function([A | ARGS], SF) :-
	gensym(skf, SF_op),
	SF =.. [SF_op, A | ARGS].

% Implication in terms of or
rew(implies(A, B), Univars, F) :- rew(or(not(A), B), Univars, F).

% Negation inwards
rew(not(not(A)), Univars, F) :- rew(A, Univars, F).
rew(not(and(A, B)), Univars, F) :- rew(or(not(A),not(B)), Univars, F).
rew(not(or(A, B)), Univars, F) :- rew(and(not(A), not(B)), Univars, F).
rew(not(implies(A, B)), Univars, F) :- 
	rew(implies(not(A), not(B)), Univars, F).
rew(not(every(X, B)), Univars, F) :- rew(exist(X, not(B)), Univars, F).
rew(not(exist(X, B)), Univars, F) :- rew(every(X, not(B)), Univars, F).

% Remove quantifiers
rew(every(X, B), Univars, F) :- \+ occurs(X, Univars), rew(B, [X|Univars], F).
rew(exist(X, B), Univars, F) :- \+ occurs(X, Univars), skolem_variable(X, SK), 
	X=..[SK|Univars], rew(B, Univars, F).

% Rewrite the internal nodes of the formula
rew(and(A, B), Univars, and(A1, B1)) :- rew(A, Univars, A1), 
	rew(B, Univars, B1).

rew(or(A, B), Univars, or(A1, B1)) :- rew(A, Univars, A1), 
	rew(B, Univars, B1).

rew(A, _, A). %Base case

% Distributivity law
%dist(or(A, and(B,C)), and()).

% Simplification
