%{
	#include <stdio.h>
  #include "y.tab.h"
  void yyerror(char *);

%}


%%
"/*"([^*]|\*+[^*/])*\*+"/"   { }
"/"["/"]+.*                  { }
"'"(.|\\.)"'"               { return CHARLITERAL;}
\"(\\.|[^"\\])*\"           { return STRING; }
"if"                        { return IF; }
"else"                      { return ELSE; }
"for"                       { return FOR; }
"int"                       { return INT; }
"double"                    { return DOUBLE; }
"void"                      { return VOID; }
"char"                      { return CHAR; }
"while"                     { return WHILE; }
"continue"                  { return CONTINUE; }
"break"                     { return BREAK; }
"return"                     { return RETURN; }
"["                         { return LB; }
"]"                          { return RB; }
"{"                          { return LP; }
"}"                         { return RP; }
"("                         { return LCB; }
")"                          { return RCB; }
"\""                         { return  DBQUOTE; }
"'"                           { return SNQUOTE; }    
">"|"<"|"=="|"<="|">="|"!="    {  return RELOP;   }
"&&" | "||"                     {  return LOGOP;   }
"="|"+="|"-="|"*="|"/="|"%="    {  return ASGNOP;  }
"+"                           { return ADD; }     
"-"                           { return MINUS; }
"/"                           { return DIV; }
"*"                           { return STAR; }
"%"                           { return PERCNT; }
"!"                           { return NOT; }
"&"                           { return AMPRESAND; }
";"                           { return SMCOL; }
[0-9]+                        { return NUMBER; }                        
[_A-Za-z][_A-Za-z0-9]*        { return IDENT;} 
.                         { yyerror(" dot occured");}

%%

int yywrap(){
return 0;
}

main()
{

  printf("input:\n");
  yylex();

}