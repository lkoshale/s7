%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

void yyerror(char *);

%}

%%

"#include"			{return INCLUDE;}	
"stdio.h"			{return STDIO;}
"<"					{return LT;}
">"					{return GT;}
"int"				{return INT_TYPE;}
"void"				{return VOID_TYPE;}
"main"				{return MAIN;}
"printf"			{return PRINTF;}
"return"			{return RETURN;}
"("					{return LP;}
")"					{return RP;}
"{"					{return LCB;}
"}"					{return RCB;}
"+"					{return ADD;}
"-"					{return MINUS;}
"*"					{return MUL;}
"/"					{return DIV;}
"="					{return EQ;}
";"					{return SMCOL;}
","					{return COMA;}
[0-9]+              { strcpy(yylval.str,yytext); return INT_LIT;} 
\"(\\.|[^"\\])*\"          		{ strcpy(yylval.str,yytext); return STRING_LIT;}
[_A-Za-z][_A-Za-z0-9]*			{ strcpy(yylval.str,yytext); return IDENT;}
[ \t\n]						{}
.							{yyerror("dot");}

%%
int yywrap(void) {
    return 1;       //return 0 for interactive parser
}