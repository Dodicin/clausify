# clausify - Lisp

# Description

This Lisp library is a set of functions designed to parse first order logic (FOL) formulas, convert them into conjunctive normal form (CNF) and check whether a formula is a Horn clause.

# Data structures

The formulas in this project will be represented following this conventions:

terms ::= <constant> | <variable> | <function>
constant ::= <number> | <symbols starting with a letter>
variable ::= <symbols starting with ?>
function ::= ’(’ <symbol> <terms>+ ’)’
wff ::= <predicate> | <negation> | <conjunction> | <disjunction> | <implication> | <universal> | <existential>
predicate ::= <symbol starting with a letter>| ’(’ <symbol> <terms>+ ’)’
negation ::= ’(’ not <wff> ’)’
conjunction ::= ’(’ and <wff> <wff> ’)’
disjunction ::= ’(’ or <wff> <wff> ’)’
implication ::= ’(’ implies <wff> <wff> ’)’
universal ::= ’(’ every <variable> <wff> ’)’
existential ::= ’(’ exist <variable> <wff> ’)’


# Usage

The main functions are:

* (tocnf f cnff). This function takes any formula in input, and if the formula is a well-formed formula, converts it into its CNF.

* (is-horn f). True if f is a horn clause. That is, if f is a disjunction of literals with at most one positive. f could also be a conjunction of horn clauses: in that case, is_horn is true if every clause is a horn clause.

# Functionalities

Every function required in the project has been implemented.
Every function is recursive: a formula may well be seen as a tree. It's necessary for the functions to work at every level of depth of the tree to successfully compute any operation on the formula.

# Functions specifications

## Formula validity control

* 'termp'. Syntax: termp term => generalized-boolean.
Returns true if term is either a constant, a variable or a function. Note: the keywords (and or not implies every exist) are protected and can't be used as name of a constant or variable.

* 'is-wff'. Syntax: is-wff formula => generalized-boolean.
Returns true if formula is a well-formed formula. That is, inductively: 
	** Every term is a formula
	** If PHI is a formula, not(PHI) is a formula
	** If PHI and PSI are formulas, and ° is a binary connective, then PHI°PSI is a formula.
	*** Note: The binary operators accepted by this library are: [and, or, not, implies, every, exist].
With such definition, only unary and binary operators are allowed in input. This function is recursive.

## Rewrite rules

* 'rew'. Syntax: rew formula &optional univars => conjunctive-normal-form-formula. 
rew is a set of functions implementing conversion rules from formula (generic FOL formula) to conjunctive-normal-form-formula (CNF of the formula). Said rules are:
	** Implications in terms of disjunctions ('rew-implication/2')
	** Move negation inwards ('rew-not/2')
	** Skolemize quantifiers ('rew-exist/2')
	** Drop universal quantifiers ('rew-every/2')
	** Distribute disjunctions inwards over conjunctions (delegated to 'dist/2')

univars is utilized to store universal quantifiers encountered in a formula or subformula. It's necessary to keep track of universal quantifier to skolemize correctly existentially quantified variables dependant on the universal quantifier.

* 'dist'. Syntax: dist formula => distributed-formula.
This function implements the distribution law on formula.

## Simplification

* 'simplify'. Syntax: simplify formula => simplified-formula.
This is a set of functions used to simplify binary operators to n-ary operators. Operator associativity in this project is defined on only conjunctions and disjunctions, but the function may be used to simplify whatever function with its arguments if necessary, editing the binding to the (and or) operators.

* 'is-literal'. Syntax: is-literal literal => generalized-boolean.
Returns true if literal is a literal. A literal is a term or the negation of said term. It's used for the simplification: it's not possible to simplify a literal.

## Skolem generation

* 'skolem_function'.  Syntax: is-literal literal => generalized-boolean. is a set of three functions (including 'skolem_variable') responsable for generating either skolem constants or skolem functions. It relies on whether ?univars is a list of variables or a single variable to determs if the parser/converter ('rew') is parsing a free existential quantifier (replacing it with a skolem constants) or an existential quantifier depending on a universally quantified variable (replacing it with a skolem function)