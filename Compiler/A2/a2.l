%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"

void yyerror(char *);
struct node* new_node(char* str);

%}

%%
"/*"([^*]|\*+[^*/])*\*+"/"   { }
"/"["/"]+.*                  { }
"if"                        { yylval.root = new_node("if"); return IF;  }
"else"                      { yylval.root = new_node(yytext); return ELSE; }
"for"                       { yylval.root = new_node(yytext); return FOR; }
"int"                       { yylval.root = new_node(yytext); return INT; }
"float"                    { yylval.root = new_node(yytext); return FLT; }
"void"                      { yylval.root = new_node(yytext); return VOID; }
"while"                     { yylval.root = new_node(yytext); return WHILE; }
"continue"                  { yylval.root = new_node(yytext); return CONTINUE; }
"break"                     { yylval.root = new_node(yytext); return BREAK; }
"return"                     {yylval.root = new_node(yytext);  return RETURN; }
"+"                         {yylval.root = new_node(yytext); return ADD;}
"-"                         {yylval.root = new_node(yytext); return SUB;}
"*"                         {yylval.root = new_node(yytext); return STAR;}
"/"                         {yylval.root = new_node(yytext); return DIV;}
"%"                         {yylval.root = new_node(yytext); return PERCNT;}
"||"                        {yylval.root = new_node(yytext); return OR;}
"&"                         {yylval.root = new_node(yytext); return AMPRESAND;}
"&&"                        {yylval.root = new_node(yytext); return AND;}
"="                         {yylval.root = new_node(yytext); return EQL;}
"=="|"!="                   {yylval.root = new_node(yytext); return EQLTY;}
"!"                         {yylval.root = new_node(yytext); return NOT;}
"<"|">"|">="|"<="           {yylval.root = new_node(yytext); return RELOP;} 
","         {yylval.root = new_node(yytext); return COMA;}
";"         {yylval.root = new_node(yytext); return SMCOL;}
"}"         {yylval.root = new_node(yytext); return RCB;}
"{"         {yylval.root = new_node(yytext); return LCB;}
"["         {yylval.root = new_node(yytext); return LB;}
"]"         {yylval.root = new_node(yytext); return RB;}
"("         {yylval.root = new_node(yytext); return LP;}
")"         {yylval.root = new_node(yytext); return RP;}
[0-9]+                          {yylval.root = new_node(yytext); return INTEGER;}
([0-9]*[.])?[0-9]+              {yylval.root = new_node(yytext); return FLOAT; }                        
[_A-Za-z][_A-Za-z0-9]*          { yylval.root = new_node(yytext); return IDENT;} 
[ \t\n]                         {}
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