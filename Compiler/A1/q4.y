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
%token COMA INCOP

%left ADD MINUS
%left DIV STAR PERCNT
%right AMPRESAND NOT

%%

start : expr
        | declaration
        | unary_op
        ;

declaration : type IDENT SMCOL
            | type IDENT multiple_decl SMCOL
            ;

multiple_decl : IDENT
              | COMA IDENT
              | COMA IDENT multiple_decl
              ;

type : INT 
     | CHAR
     | DOUBLE
     | VOID
     ;

statement : block_statement
         |  if_stmnt
         | WHILE LSB rel_expr RSB statement
         | IDENT ASGNOP expr SMCOL
         | FOR LSB for_expr RSB statement
         ;

block_statement : LP multiple_statement RP
                | LP RP
                ;

if_stmnt : IF LSB rel_expr RSB statement
         | IF LSB rel_expr RSB statement ELSE statement
         ;

for_expr : IDENT ASGNOP expr SMCOL rel_expr SMCOL expr
         ;

multiple_statement : statement 
                    | statement multiple_statement
                    ;

expr :  primary_expr binary_op primary_expr 
        | expr binary_op primary_expr
        | primary_expr
        | rel_expr       
        ;


rel_expr : primary_expr LOGOP primary_expr
         | primary_expr RELOP primary_expr
         | rel_expr LOGOP primary_expr
         | rel_expr RELOP primary_expr
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
             ;

unary_op : ADD
        | MINUS
        | NOT
        | AMPRESAND
        ;

binary_op : ADD
          | MINUS
          | STAR
          | DIV
          | PERCNT
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
