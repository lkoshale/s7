
%{
	#include <stdio.h>
	#include <string.h>
	#include "y.tab.h"
	extern char text[1000];
%}

%%

"<html>"		{ fprintf(stderr,"%s\n" ,"opentag***");  return OHTML; }
"</html>" 		{  return CHTML; }
"<b"			{ return OB; }
"</b>"			{ return CB; }
"<i"			{ return OI; }
"</i>"			{ return CI; }
"<ul"			{ return OUL; }
"</ul>"			{ return  CUL; }
"<u"			{ fprintf(stderr,"%s\n" ,"***u***"); return OU; }
"</u>"			{ return CU; }
"<li"			{ return OLI; }
"</li>"			{ return CLI; }
"<table>"		{ return OTABLE; }
"</table>"		{ return CTABLE; }
"<tr>"			{ return OTR;}
"</tr>"			{ return CTR; }
"<td>"			{ return OTD; }
"</td>"			{ return CTD; }
">"				{ return CLOSE; }
"="				{fprintf(stderr,"%s\n" ,"***eq***");  return EQUAL; }
[A-Za-z]+			{ fprintf(stderr,"%s\n" ,"***ident***"); return IDENT; }
[0-9]+				{ return NUM;}
[ \t\n]+				{}
[_A-Za-z0-9 \t]+		{fprintf(stderr,"%s %s\n" ,"***text***",yytext); strcpy(text,yytext); return TEXT; }

%%

int yywrap(void){
	return 1;
}
