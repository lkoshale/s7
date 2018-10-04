%{
	#include <stdio.h>
	#include <stdlib.h>
	extern int yylex();
	void yyerror(char *s);

	typedef struct code_ {
		char* code;
		char* reg;
		int type;
	}Code;

	typedef struct vtable{
		char* var;
		int* type;
		int size;
	} VTable;

	typedef struct ftable{
		char* name;
		char* argtype;
		int argsize;
	}FTable;

%}

%union{
 char str[200];
 struct code_* val;
}


%token INT FLOAT IF RETURN LT GT INTEGER_LITERAL FLOAT_LITERAL STRING_LITERAL PRINTF INT_FORMAT_STR FLOAT_FORMAT_STR
%token ';' ',' '(' ')' '{' '}' '=' '+' '*' '/' '%'
%start program

%token<str> IDENTIFIER

%type<Code> 

%%

program
    : decl_list 
    ;

decl_list
    : decl_list decl
    | decl
    ;

decl
    : var_decl
	| fun_decl
	;

var_decl
    : type_spec identifier ';'
	;

type_spec
    : INT 
	| FLOAT
	;

fun_decl
    : type_spec identifier '(' params ')' compound_stmt
    ;

params
    :
    | param_list
    ;

param_list
    : param_list ',' param
    | param
    ;

param
    : type_spec identifier
    ;

compound_stmt
    : '{' var_decls stmt_list '}'
	;

var_decls
	: 
	| var_decls var_decl
	;

stmt_list
    : stmt_list stmt
	| stmt
	;

stmt
    : assign_stmt
	| compound_stmt
	| if_stmt
	| return_stmt
	| print_stmt
	;

print_stmt	
	: PRINTF '(' format_str ',' identifier ')' ';'
	;

if_stmt
    : IF '(' expr ')' stmt
	;

return_stmt
    : RETURN expr ';'
	;

assign_stmt
	: identifier '=' expr ';'
	;

expr 
	: Pexpr LT Pexpr
	| Pexpr GT Pexpr
	| Pexpr '+' Pexpr
	| Pexpr '*' Pexpr
	| Pexpr '/' Pexpr
	| Pexpr '%' Pexpr
	| Pexpr
	| identifier '(' args ')'
	;

Pexpr
	: integerLit
	| floatLit
	| identifier
	| '(' expr ')'
	;

integerLit
	: INTEGER_LITERAL
	;

floatLit
	: FLOAT_LITERAL
	;

identifier
	: IDENTIFIER
	;

arg_list
	: arg_list ',' expr
    | expr
    ;

args: 
    | arg_list
    ;

format_str
	: INT_FORMAT_STR
	| FLOAT_FORMAT_STR
	;
%%

void yyerror(char *s) {
   fprintf(stderr,"-->%s\n", s);
   exit(1);
}

int main(void) {
    yyparse();
    return 0;
}

