%%%% 808292 Habbash Nassim

is_term(A) :- var(A), !.
is_term(A) :- is_const(A), !.
is_term(A) :- is_funct(A), !.

is_const(A) :- number(A), !.
is_const(A) :- atom_chars(A, [H|_]), char_type(H, lower).


is_funct(A) :- term_to_atom(A, X), atom_chars(X, L), phrase(expr, L).


% DCG for parsing functions and predicates with n arity
expr -->  fsign, ['('], terms, [')'].
fsign --> {is_const(A)}, [A].
terms --> term.
terms --> expr.
terms --> terms, term.
term --> {is_term(T)}, [T].

function --> symbol, "(", termlist, ")".
termlist --> term | term, ",", termlist.
term    --> symbol | function.
symbol    --> [C], { char_type(C, alpha); var(C) }, symbolbody.
symbolbody --> [C], { char_type(C, alnum) ; C = '_' ; C = '-' }, symbolbody.
symbolbody --> [].


%% is_wff controls if the to-be-parsed formula is a well formed formula.

is_wff(not(A)) :- is_wff(A).
is_wff(and(A, B)) :- is_wff(A), is_wff(B).
is_wff(or(A, B)) :- is_wff(A), is_wff(B).
is_wff(implies(A, B)) :- is_wff(A), is_wff(B).
is_wff(every(A, B)) :- var(A), is_wff(B).
is_wff(exist(A, B)) :- var(A), is_wff(B).
