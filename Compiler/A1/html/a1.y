%token TAG TEXT
%{
	// Example from http://epaperpress.com/lexandyacc/pry2.html
	#include <stdio.h>
    void yyerror(char *);
    int yylex(void);
    char mytext[26];
%}

%%
program: lines;

lines: oneline | oneline lines;

oneline: TAG oneline 
| TEXT oneline 
| TAG {
	printf("YACC: The tag is %s\n", mytext);
}
| TEXT {
	printf("YACC: The text is %s\n", mytext);
};

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}

