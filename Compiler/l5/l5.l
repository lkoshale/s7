%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

void yyerror(char *);

%}

%%

[a-z]								{ strcpy(yylval.str ,yytext );return TERM;}
[A-Z][a-zA-z0-9]*					{ strcpy(yylval.str ,yytext );return NTERM;}
"$"									{ strcpy(yylval.str ,yytext );return ESP;}
":"									{ strcpy(yylval.str ,yytext );return COL;}
";"									{ strcpy(yylval.str ,yytext );return SMCOL;}
"|"									{ strcpy(yylval.str ,yytext ); return BAR;}
[ \t\n]								{}
.									{yyerror("dot");}

%%
int yywrap(void) {
    return 1;       //return 0 for interactive parser
}


/*
int main(){
    yylex();
}
*/