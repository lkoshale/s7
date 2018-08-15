%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    void yyerror(char *);
    int yylex(void);

    int var_mul_assgn_lhs = 0;
    int var_mul_assgn_rhs = 0;

    
    int var_decl_val=0;
    int var_if_val=0;
    int var_else_val = 0;
    int var_while_val = 0;
    int var_for_val = 0;
    int var_fun_def_val = 0;
    int var_fun_call_val =0;
    
%}

%token IF ELSE FOR INT CHAR DOUBLE VOID 
%token WHILE CONTINUE BREAK RETURN 
%token LP RP LB RB LSB RSB DBQUOTE SNQUOTE
%token RELOP LOGOP ASGNOP 
%token ADD MINUS DIV STAR PERCNT NOT AMPRESAND SMCOL POW
%token GREATER LESSER COLON
%token IDENT NUM STRING CHARLITERAL 
%token COMA INCOP EQL MAIN ARGC ARGV

%left ADD MINUS
%left DIV STAR PERCNT
%right AMPRESAND NOT

%%

start : prog            {printf("Valid\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n",var_decl_val,var_if_val,var_else_val,var_while_val,var_for_val,var_fun_def_val,var_fun_call_val);}

prog : main                              
        | decl_fun_fun_decl_star  main         
        | main decl_fun_star                
        | decl_fun_fun_decl_star main decl_fun_star   
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

main : type  MAIN LSB RSB block_statement                                               {var_fun_def_val++;}
     | type MAIN LSB INT STAR IDENT COMA CHAR STAR IDENT LB RB RSB block_statement      { var_decl_val+=2;  var_fun_def_val++;}
     ;

function_decl : type variable_name LSB arg_decl RSB SMCOL
              ;

function : type variable_name LSB arg_decl RSB block_statement          {var_fun_def_val++;}
          ;

arg_decl_star :  COMA type variable_name                                {var_decl_val++;}
                | COMA type variable_name LB RB                         {var_decl_val++;}
                | arg_decl_star COMA  type variable_name                {var_decl_val++;}
                | arg_decl_star COMA type variable_name LB RB            {var_decl_val++;}
                ;

arg_decl : /*empty*/
        | type variable_name                                            {var_decl_val++;}
        | type variable_name LB RB                                      {var_decl_val++;}
        | type variable_name LB RB arg_decl_star                        {var_decl_val++;}
        | type variable_name arg_decl_star                              {var_decl_val++;}
        ;


declaration : declaration_type SMCOL
            | declaration_type multiple_decl_star SMCOL
            ;

declaration_type : type variable_name                           {var_decl_val++;}
            | type variable_name EQL expr                       {var_decl_val++;}
            | type variable_name LB expr RB                     {var_decl_val++;}
            ;

multiple_decl_star : multiple_decl
                | multiple_decl_star multiple_decl
              ;

multiple_decl : COMA variable_name                              {var_decl_val++;}
              | COMA variable_name EQL expr                     {var_decl_val++;}
              | COMA variable_name LB expr RB                   {var_decl_val++;}
              ;

type : INT 
     | CHAR
     | DOUBLE
     | VOID
     ;

statement : block_statement
         | declaration
         |  if_stmnt
         | WHILE LSB rel_expr_star RSB statement                {var_while_val++;}
         | variable_name assgn_op expr SMCOL
         | variable_name LB expr RB assgn_op expr SMCOL
         | FOR LSB for_expr RSB statement
         | function_call SMCOL                                  
         | multiple_assgn
         | RETURN expr SMCOL
         | RETURN SMCOL
         | BREAK SMCOL
         | CONTINUE SMCOL
         | variable_name INCOP SMCOL                     
          | INCOP variable_name SMCOL 
          | variable_name LB expr RB INCOP SMCOL
          | INCOP variable_name LB expr RB SMCOL
         ;

block_statement : LP multiple_statement RP
                | LP RP
                ;

if_stmnt : IF LSB rel_expr_star RSB statement                           {var_if_val++;}
         | IF LSB rel_expr_star RSB statement ELSE statement            {var_if_val++; var_else_val++;}
         ;

for_expr : for_first SMCOL for_second SMCOL for_third                   {var_for_val++;}
         ;

for_first : /*empty*/
         | variable_name EQL expr
         ;

for_second : /*empty*/
           | rel_expr
           ;

for_third : /*empty*/
        | expr
        ;

multiple_statement : statement 
                    | multiple_statement statement
                    ;

multiple_assgn : assgn_lhs LESSER MINUS assgn_rhs SMCOL     {if(var_mul_assgn_lhs!=var_mul_assgn_rhs){yyerror("multiple_assgn eror\n");} else{ var_mul_assgn_lhs=0; var_mul_assgn_rhs=0;} }
                ;

assgn_lhs : variable_name                               {var_mul_assgn_lhs++;}
                  | assgn_lhs COLON variable_name       {var_mul_assgn_lhs++;}
                  ;

assgn_rhs : expr                                        {var_mul_assgn_rhs++;}
          | assgn_rhs COLON expr                         {var_mul_assgn_rhs++;}
          ;


function_call : IDENT LSB arguments RSB                  {var_fun_call_val++;}
              ;

arguments : /*empty*/
        | expr
        | expr argument_rest
        ;

argument_rest : COMA expr
              | argument_rest COMA expr
              ;


rel_expr_star : rel_expr
              | rel_expr_m
              | rel_expr LOGOP rel_expr_star    
              | rel_expr_m LOGOP rel_expr_star
              ;

rel_expr : expr_ LOGOP expr_            
         | expr_ rel_op expr_           
         ;

rel_expr_m :  rel_expr LOGOP expr_
          | rel_expr rel_op expr_
         ;



expr : expr_
     ;

expr_ :  primary_expr binary_op primary_expr /*{fprintf(stderr,"%s","expr bin\n");}*/
        | expr_ binary_op primary_expr       /*{fprintf(stderr,"%s","pr bin\n");}*/
        | primary_expr                     /* {fprintf(stderr,"%s","pr\n");}*/
        ;


primary_expr : IDENT
             | NUM
             | STRING
             | IDENT LB expr RB 
             | LSB expr RSB
             | STAR primary_expr
             | MINUS primary_expr
             | NOT primary_expr
             | AMPRESAND primary_expr
             | inc_op 
             | function_call
             ;

inc_op : primary_expr INCOP
             | INCOP primary_expr
             ;

binary_op : ADD
          | MINUS
          | STAR
          | DIV
          | PERCNT
          | POW
          ;

assgn_op : ASGNOP
         | EQL
         ;

rel_op : RELOP
        | GREATER
        | LESSER
        ;

variable_name : IDENT
                | STAR variable_name
                ;

%%

void yyerror(char *s) {
       /* fprintf(stderr,"%s\n",s);*/
    printf("Invalid\n");
    exit(0);
}

int main(void) {
    yyparse();
    return 0;
}
