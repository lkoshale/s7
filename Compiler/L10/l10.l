%{
    #include <stdio.h>
    #include "y.tab.h"
    extern void yyerror(char *);
%}

%%
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]       {}
"//"[^\n]*      {}
[0-9]+          {strcpy(yylval.str,yytext);return INTEGER_LITERAL; }
[0-9]+\.[0-9]*  {strcpy(yylval.str,yytext);return FLOAT_LITERAL; }
[0-9]*\.[0-9]+  {strcpy(yylval.str,yytext);return FLOAT_LITERAL; }
"\"%d\\n\"" {strcpy(yylval.str,yytext);return INT_FORMAT_STR;}
"\"%f\\n\"" {strcpy(yylval.str,yytext);return FLOAT_FORMAT_STR;}
";"   {return ';'; }
","   {return ','; }
"("   {return '('; }
")"   {return ')'; }
"{"   {return '{'; }
"}"   {return '}'; }
"="   {return '='; }
"+"   {return '+'; }
"*"   {return '*'; }
"/"   {return '/'; }
"%"   {return '%'; }
"printf" {return PRINTF; }
"int"       {return INT; }
"float"     {return FLOAT; }
"if"        {return IF; }
"return"    {return RETURN; }
">"         {return GT; }
"<"         {return LT; }
[a-zA-Z_][a-zA-Z0-9_]*  {strcpy(yylval.str,yytext);return IDENTIFIER; }
[ \n\t\v]   {}
. {}

%%
int yywrap(void) {
    return 1;
}