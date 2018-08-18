%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

int line_no = 0;

%}

%%
"int"                       { return INT; }
";"                         { return SMCOL; }
"="                         {return EQL; }
"+"                         { return ADD; }
"-"                         { return MINUS; }
"/"                         { return DIV; }
"*"                         { return STAR; }
"("                         { return LP; }
")"                         { return RP; }
[0-9]+                      { yylval.num = atoi(yytext); return NUM; }
[_A-Za-z][_A-Za-z0-9]*       { strcpy(yylval.string,yytext); return IDENT; }
[\n]                        { line_no++;}
.                           {}


%%
int yywrap(void) {
    return 1;       //return 0 for interactive parser
}
/*
int main(){
    yylex();
}
*/