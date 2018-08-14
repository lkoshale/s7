%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    void yyerror(char *);
    int yylex(void);
    
%}

%token IF ELSE FOR INT CHAR DOUBLE VOID 
%token WHILE CONTINUE BREAK RETURN 
%token LP RP LB RB LSB RSB DBQUOTE SNQUOTE
%token RELOP LOGOP ASGNOP 
%token ADD MINUS DIV STAR PERCNT NOT AMPRESAND SMCOL
%token IDENT NUM STRING CHARLITERAL 
%token COMA INCOP EQL MAIN ARGC ARGV

%left ADD MINUS
%left DIV STAR PERCNT
%right AMPRESAND NOT

%%

prog : main                              {printf("main\n");}
        | decl_fun_fun_decl_star  main         {printf("decl main\n");}
        | main decl_fun_star                 {printf("fn main\n");}
        | decl_fun_fun_decl_star main decl_fun_star   {printf("decl fn main\n");} 
        | expr
        ;

decl_fun_star : decl_fun
            | decl_fun_star decl_fun
            ;

decl_fun : declaration
        | function
        ;


decl_fun_fun_decl_star : decl_fun_fun_decl
                        | decl_fun_fun_decl_star decl_fun_fun_decl
                        ;

decl_fun_fun_decl : declaration
                    | function
                    | function_decl
                    ;

main : type  MAIN LSB RSB block_statement
     | type MAIN LSB INT STAR IDENT COMA CHAR STAR IDENT LB RB RSB block_statement
     ;

function_decl : type variable_name LSB arg_decl RSB SMCOL
              ;

function : type variable_name LSB arg_decl RSB block_statement
          ;

arg_decl_star :  COMA type variable_name
                | COMA type variable_name LB RB
                | arg_decl_star COMA  type variable_name 
                | arg_decl_star COMA type variable_name LB RB 
                ;

arg_decl : /*empty*/
        | type variable_name
        | type variable_name LB RB
        | type variable_name LB RB arg_decl_star
        | type variable_name arg_decl_star
        ;


declaration : declaration_type SMCOL
            | declaration_type multiple_decl_star SMCOL
            ;

declaration_type : type variable_name
            | type variable_name EQL expr
            | type variable_name LB expr RB
            ;

multiple_decl_star : multiple_decl
                | multiple_decl_star multiple_decl
              ;

multiple_decl : COMA variable_name
              | COMA variable_name EQL expr
              | COMA variable_name LB expr RB
              ;

type : INT 
     | CHAR
     | DOUBLE
     | VOID
     ;

statement : block_statement
         | declaration
         |  if_stmnt
         | WHILE LSB rel_expr_star RSB statement
         | variable_name assgn_op expr SMCOL
         | variable_name LB expr RB assgn_op expr SMCOL
         | FOR LSB for_expr RSB statement
         | function_call
         | RETURN expr SMCOL
         | BREAK SMCOL
         | CONTINUE SMCOL
         ;

block_statement : LP multiple_statement RP
                | LP RP
                ;

if_stmnt : IF LSB rel_expr_star RSB statement
         | IF LSB rel_expr_star RSB statement ELSE statement
         ;

for_expr : variable_name EQL expr SMCOL rel_expr SMCOL expr  
         ;

multiple_statement : statement 
                    | multiple_statement statement
                    ;


function_call : IDENT LSB arguments RSB SMCOL
              ;

arguments : expr
        | expr argument_rest
        ;

argument_rest : COMA expr
              | argument_rest COMA expr
              ;


rel_expr_star : rel_expr
              | rel_expr_m
              | rel_expr rel_expr_star
              | rel_expr_m rel_expr_star
              ;

rel_expr : primary_expr LOGOP primary_expr
         | primary_expr RELOP primary_expr
         ;

rel_expr_m :  rel_expr LOGOP primary_expr
          | rel_expr RELOP primary_expr
         ;

expr :  primary_expr binary_op primary_expr 
        | expr binary_op primary_expr
        | primary_expr
        | rel_expr       
        ;



primary_expr : IDENT
             | NUM
             | STRING
             | LSB expr RSB
             | STAR primary_expr
             | MINUS primary_expr
             | NOT primary_expr
             | AMPRESAND primary_expr
             | primary_expr INCOP
             | INCOP primary_expr


binary_op : ADD
          | MINUS
          | STAR
          | DIV
          | PERCNT
          ;

assgn_op : ASGNOP
         | EQL
         ;

variable_name : IDENT
                | STAR IDENT
                ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
    printf("Error : %s \n",s);
    exit(0);
}

int main(void) {
    yyparse();
    return 0;
}
