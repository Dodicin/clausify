# clausify - Prolog

# Author: Habbash Nassim (808292)

# Description

This Prolog library is a set of predicates and functions designed to parse first order logic (FOL) formulas, convert them into conjunctive normal form (CNF) and check whether a formula is a Horn clause.

# Data structure

The formulas in this project will be represented following this conventions:

term ::= <constant> | <variable> | <function>
constant ::= <number> | <symbols starting with letters>
variable ::= <Prolog variables satisfying var/1>
function ::= <symbol>’(’ <term>[’,’ <term>]* ’)’
wff ::= <predicate> | <negation> | <conjunction> | <disjunction> | <implication>
| <universal> | <existential>
predicate ::= <Prolog symbol> | <symbol>’(’ <term>[’,’ <term>]* ’)’
negation ::= not’(’ <wff> ’)’
conjunction ::= and’(’ <wff> ’,’ <wff> ’)’
disjunction ::= or’(’ <wff> ’,’ <wff> ’)’
implication ::= implies’(’ <wff> ’,’ <wff> ’)’
universal ::= every’(’ <variable> ’,’ <wff> ’)’
existential ::= exist’(’ <variable> ’,’ <wff> ’)’

# Usage

The main predicates are:

* 'tocnf\2'. tocnf(?F, ?CNFF) takes any formula in input (?F), and if the formula is a well-formed formula, converts it into its CNF (?CNFF).

* 'is_horn\1' is_horn(?F) is true if ?F is a horn clause. That is, if ?F is a disjunction of literals with at most one positive. ?F could also be a conjunction of horn clauses: in that case, is_horn is true if every clause is a horn clause.

# Functionalities

Every function required in the project has been implemented.
This library makes extensive use of Prolog's pattern matching. That is, instead of manually comparing data structures inside predicates, most of the work is done via unification, avoiding excessive verbosity of the code.
Every function is recursive: a formula may well be seen as a tree. It's necessary for the predicates to work at every level of depth of the tree to successfully compute any operation on the formula.

# Predicates specifications

## Formula validity control

* 'is_term/1'. is_term(?term) is true if ?term is either a constant, a variable or a function. Note: the keywords [and, or, not, implies, every, exist] are protected and can't be used as name of a constant or variable.

* 'is_wff/1'. is_wff(?formula) is true if ?formula is a well-formed formula. That is, inductively: 
	** Every term is a formula
	** If PHI is a formula, not(PHI) is a formula
	** If PHI and PSI are formulas, and ° is a binary connective, then PHI°PSI is a formula.
	*** Note: The binary operators accepted by this library are: [and, or, not, implies, every, exist].
With such definition, only unary and binary operators are allowed in input. This function is recursive.

## Rewrite rules

* 'rew/3'. rew(?input, ?univars, ?output) is a set of predicates implementing conversion rules from ?input (generic FOL formula) to ?output (CNF of the formula). Said rules are:
	** Implications in terms of disjunctions
	** Move negation inwards (Negation normal form)
	** Skolemize quantifiers
	** Drop universal quantifiers
	** Distribute disjunctions inwards over conjunctions (delegated to 'dist/2')

?univars is utilized to store universal quantifiers encountered in a formula or subformula. It's necessary to keep track of universal quantifier to skolemize correctly existentially quantified variables dependant on the universal quantifier.

* 'dist/2'. dist(?input, ?output) is a predicate implementing the distribution law on ?input.

## Simplification

* 'simplify/2'. simplify(?input, ?output) is a set of predicates used to simplify binary operators to n-ary operators. Operator associativity in this project is defined on only conjunctions and disjunctions, but the function may be used to simplify whatever function with its arguments if necessary, editing the binding to the [and, or] operators.

* 'is_literal/1'. is_literal(?input) is true if ?input is a literal. A literal is a term or the negation of said term. It's used for the simplification: it's not possible to simplify a literal.

## Skolem generation

* 'skolem_function/2'. skolem_function(?univars, ?skolem) is a set of three predicates (including 'skolem_variable(?variable, ?skolem)') responsable for generating either skolem constants or skolem functions. It relies on whether ?univars is a list of variables or a single variable to determine if the parser/converter ('rew/3') is parsing a free existential quantifier (replacing it with a skolem constants) or an existential quantifier depending on a universally quantified variable (replacing it with a skolem function)