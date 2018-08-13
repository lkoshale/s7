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
%token COMA INCOP EQL END_OF_FILE

%left ADD MINUS
%left DIV STAR PERCNT
%right AMPRESAND NOT

%%

st :  function_star {printf("mul\n");exit(0);}
    ;

start : expr            {printf("expr\n");exit(0);}
        | statement     {printf("statement\n");exit(0);}
        | declaration   {printf("declaration\n");exit(0);}
        | unary_op      {printf("unaryop\n");exit(0);}
        | END_OF_FILE  {printf("eof\n");exit(0);}
        ;

function_star : function  {printf("fn\n");} END_OF_FILE   
                | function_star {printf("fnstar\n");} function
                ;

function_decl : type IDENT LSB arg_decl_star RSB SMCOL
              ;

function : type IDENT LSB arg_decl RSB LP statement RP
        | type IDENT LSB arg_decl RSB LP RP
          ;

arg_decl_star :  COMA type IDENT
                | COMA type IDENT LB RB
                | arg_decl_star COMA  type IDENT 
                ;

arg_decl : %empty
        | type IDENT
        | type IDENT LB RB
        | type IDENT LB RB arg_decl_star
        | type IDENT arg_decl_star
        ;


declaration : declaration_type SMCOL
            | declaration_type multiple_decl_star SMCOL
            ;

declaration_type : type IDENT
            | type IDENT EQL primary_expr
            | type IDENT LB primary_expr RB
            ;

multiple_decl_star : multiple_decl
                | multiple_decl multiple_decl_star
              ;

multiple_decl : COMA IDENT
              | COMA IDENT EQL primary_expr
              | COMA IDENT LB primary_expr RB
              ;

type : INT 
     | CHAR
     | DOUBLE
     | VOID
     ;

statement : block_statement
         | declaration
         |  if_stmnt
         | WHILE LSB rel_expr RSB statement
         | IDENT assgn_op expr SMCOL
         | FOR LSB for_expr RSB statement
         ;

block_statement : LP multiple_statement RP
                | LP RP
                ;

if_stmnt : IF LSB rel_expr RSB statement
         | IF LSB rel_expr RSB statement ELSE statement
         ;

for_expr : IDENT EQL expr SMCOL rel_expr SMCOL expr  
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
         | rel_expr_star
         ;

rel_expr_star : rel_expr rel_expr_star 
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

assgn_op : ASGNOP
         | EQL
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
