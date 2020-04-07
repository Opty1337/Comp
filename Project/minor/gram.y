%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "node.h"
#include "tabid.h"

int yylex();
int yyerror(char *s);
%}

%union {
    int i;      /* Integer */
    char c;     /* Character */
    char *s;    /* Symbol or Text Chain */
    Node *n;    /* Node Pointer */
};

%right ASSIGN
%left '|'
%left '&'
%nonassoc '~'
%left NE '='
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right '^'
%nonassoc ADDR UMINUS '?'
%nonassoc '(' ')' '[' ']'

%token <i> INT
%token <c> CHAR
%token <s> ID STR
%token PROGRAM MODULE END START
%token VOID CONST NUMBER ARRAY STRING FUNCTION PUBLIC FORWARD
%token IF THEN ELSE ELIF FI FOR UNTIL STEP DO DONE REPEAT STOP RETURN
%%
file        : program
            | module
            ;

program     : PROGRAM optdecls START body END
            ;

module      : MODULE optdecls END
            ;

optdecls    :
            | declseq
            ;

declseq     : declaration
            | declseq ';' declaration
            ;

declaration : qualifier optconst variabledef
            | function
            ;

qualifier   :
            | PUBLIC
            | FORWARD
            ;

optconst    :
            | CONST
            ;

variable    : ARRAY ID '[' INT ']'
            | NUMBER ID
            | STRING ID
            ;

variabledef : ARRAY ID '[' INT ']' arrassign
            | NUMBER ID numassign
            | STRING ID strassign
            ;

arrassign   :
            | ASSIGN intseq
            ;

intseq      : INT
            | intseq ',' INT
            ;

numassign   :
            | ASSIGN INT
            ;

strassign   :
            | ASSIGN literal literals
            | ASSIGN STR
            ;

literal     : STR
            | INT
            | CHAR
            ;

literals    : literal
            | literals literal
            ;

function    : FUNCTION qualifier functype ID optfuncargs funcbody
            ;

functype    : VOID
            | NUMBER
            | ARRAY
            | STRING
            ;

funcargs    : variable
            | funcargs ';' variable
            ;

optfuncargs :
            | funcargs
            ;

funcbody    : DONE
            | DO body
            ;

body        : varseq instrblock
            ;

varseq      :
            | varseq variable ';'
            ;

instrblock  : instrseq lastinstr
            ;

instrseq    :
            | instrseq instr
            ;

instr       : IF rvalue THEN instrblock instrelif instrelse FI
            | FOR rvalue UNTIL rvalue STEP rvalue DO instrblock DONE
            | rvalue rsugar
            | lvalue '#' rvalue ';'
            ;

instrelif   :
            | ELIF rvalue THEN instrblock
            ;

instrelse   :
            | ELSE instrblock
            ;

rsugar      : ';'
            | '!'
            ;

lastinstr   :
            | REPEAT
            | STOP
            | RETURN optrvalue
            ;

optrvalue   :
            | rvalue
            ;

lvalue      : ID
            | lvalue '[' rvalue ']'
            ;

rvalue      : lvalue
            | literals
            | '(' rvalue ')'
            | rvalue '(' rargs ')'
            | '?'
            | '&' lvalue %prec ADDR
            | '-' rvalue %prec UMINUS
            | rvalue '^' rvalue
            | rvalue '*' rvalue
            | rvalue '/' rvalue
            | rvalue '%' rvalue
            | rvalue '+' rvalue
            | rvalue '-' rvalue
            | rvalue '<' rvalue
            | rvalue '>' rvalue
            | rvalue LE rvalue
            | rvalue GE rvalue
            | rvalue NE rvalue
            | rvalue '=' rvalue
            | '~' rvalue
            | rvalue '&' rvalue
            | rvalue '|' rvalue
            | lvalue ASSIGN rvalue
            ;

rargs       : rvalue
            | rargs ',' rvalue
            ;
%%
char **yynames =
#if YYDEBUG > 0
    (char **)yyname;
#else
    NULL;
#endif
