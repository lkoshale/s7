%{
	#include <stdio.h>
	#include <stdlib.h>
	extern int yylex();
	void yyerror(char *s);


	char REAX[10]="%eax";
	char REBX[10]="%ebx";
	char RECX[10]="%ecx";
	char REDX[10]="%edx";

	int aveax=0,avebx=0,avecx=0,avedx=0;

	typedef struct code_ {
		char* code;
		char* reg;
		int type;
	}Code;

	typedef struct vtable{
		char* var[200];
		int type[200];
		int size;
	} VTable;

	VTable* global=(VTable*)malloc(sizeof(VTable));
	global->size=0;

	VTable* local;

	void addTable(VTable* tbl,char* var,int typ);

%}

%union{
 char str[200];
 int tp;
 struct code_* val;
}


%token INT FLOAT IF RETURN LT GT  STRING_LITERAL PRINTF 
%token ';' ',' '(' ')' '{' '}' '=' '+' '*' '/' '%'
%start program

%token<str> IDENTIFIER FLOAT_LITERAL INTEGER_LITERAL INT_FORMAT_STR FLOAT_FORMAT_STR
%type<str> identifier floatLit integerLit format_str

%type<tp> type_spec;

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
    : type_spec identifier ';'    { addTable(global,$2,$1); }
	;

type_spec
    : INT  					{ $$=1;}
	| FLOAT 				{ $$=2;}	
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


void addTable(VTable* tbl,char* var,int typ){
	if(tbl!=NULL){
		tbl->var[tbl->size]=(char*)malloc(sizeof(char)*(strlen(var)+5));
		strcpy(tbl->var[tbl->size],var);
		tbl->type[tbl->size]=typ;
		tbl->size+=1;
	}
}

