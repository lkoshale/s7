%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    void yyerror(char *);
    int yylex(void);   

    extern int line_no; 

%}

%union {
    int num;
    char string[100];
}


%token INT IDENT ADD MINUS STAR DIV LP RP SMCOL EQL  
%token NUM

%type<num> NUM expr
%type<string> IDENT

%left ADD MINUS
%left STAR
%left DIV
%right UNOP

%%

start : expr {printf("%d %d\n",$1,line_no);} 

expr : IDENT                                {$$=0;printf("%s\n",$1);}
    | NUM                                   {$$ = $1;}
    | expr ADD expr                         {$$ = $1 + $3;}
    | expr MINUS expr                       {$$ = $1 - $3;}
    | expr STAR expr                        { $$= $1*$3;}
    | expr DIV expr                         { $$= $1/$3;}
    | MINUS expr  %prec UNOP                {$$ = -$2;}
    | ADD expr     %prec UNOP               {$$=$2;}
    | LP expr RP                            {$$= $2;}
    ;
%%

void yyerror(char *s) {
    fprintf(stderr,"%s\n",s);
        printf("Invalid\n");
    exit(0);
}


int main(){
    yyparse();
    return 0;
}