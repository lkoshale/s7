%{ 
 	#include <stdlib.h>
    	#include "y.tab.h"
	void yyerror(char *);
%}


%% 

\/\/.*		;
\/\*([^\*]|\n|\*[^\/])*\*\/  ;
int		{return INT;}
return		{return RETURN;}
break		{return BREAK;}
continue	{return CONT;}
void		{return VOID;}
float		{return FLOAT;}
while		{return WHILE;}
if		{return IF;}
else		{return ELSE;}
"||"		{return OR;}
"=="		{return EQ;}
"!="		{return NEQ;}
"<="		{return LEQ;}
">="		{return GEQ;}
"&&"		{return AND;}
;|,|\[|\]|\*|\(|\)|\=|\{|\}	{return *yytext;}
\<|\>|\+|\-|\/|\%|\!|\&		{return *yytext;}
[_a-zA-Z][_a-zA-Z0-9]* 	{return IDENTIFIER;}
[0-9]+ 			{return INTEGER_LITERAL;}
([0-9]+\.[0-9]*|[0-9]*\.[0-9]+) return FLOAT_LITERAL;
[' '|\n|\t|\r]	;
.	;		

%% 

int yywrap(void) {
    return 1;
}
