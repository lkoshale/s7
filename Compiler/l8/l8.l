%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

void yyerror(char *);

%}

%%
"for"				{return FOR;}
","					{return COMA;}
";"					{return SMCOL;}
"("					{return LP;}
")"					{ return RP;}
"{"					{return LCB;}
"}"					{return RCB;}
"="					{return EQL;}
">"					{return GT;}
"<"					{return LT;}
"<="				{return LE;}
">="				{return GE;}
"++"				{return INC;}
"--"				{return DEC;}
"*="				{return STAREQ;}
"/="				{return DIVEQ;}
"int"				{return INT;}
"void"				{return VOID;}
"main"				{return MAIN;}
\"(\\.|[^"\\])*\"    	{return STRING_LIT;}
[0-9]+                        {return INT_LIT;}
[_A-Za-z][_A-Za-z0-9]*	      		{strcpy(yylval.str,yytext);return IDENT;}
[ \t\n]
.							{yyerror("dot");}

%%
int yywrap(void) {
    return 1;       //return 0 for interactive parser
}

