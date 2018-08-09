%{
	// Example from http://epaperpress.com/lexandyacc/pry2.html
    #include <stdlib.h>
    #include "y.tab.h"
    void yyerror(char *);
    extern char mytext[];
%}

%%

\<[^\<\>]*>	{ printf("Lex: %s\n", yytext); strcpy(mytext, yytext); return TAG;}

[a-zA-Z_ \t]*	{ strcpy(mytext, yytext); return TEXT; }

\n	|
.	;
%%

int yywrap(void) {
    return 1;
}


