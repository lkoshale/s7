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
"("                         { return LSB; }
")"                          { return RSB; }
"\""                         { return  DBQUOTE; }
"'"                           { return SNQUOTE; }    
">"|"<"|"=="|"<="|">="|"!="    {  return RELOP;   }
"&&"|"||"                     {  return LOGOP;   }
"="                             { return EQL; }
"+="|"-="|"*="|"/="|"%="    {  return ASGNOP;  }
"++"|"--"                       { return INCOP; }
"+"                           { return ADD; }     
"-"                           { return MINUS; }
"/"                           { return DIV; }
"*"                           { return STAR; }
"%"                           { return PERCNT; }
"!"                           { return NOT; }
"&"                           { return AMPRESAND; }
";"                           { return SMCOL; }
","                             { return COMA; }
"main"                        {return MAIN;}
[+-]?([0-9]*[.])?[0-9]+       {  return NUM; }                        
[_A-Za-z][_A-Za-z0-9]*        { return IDENT;} 
[ \t\n]                        {}
.                         { yyerror(" dot occured");}

%%

int yywrap(void) {
    return 1;       //return 0 for interactive parser
}

// main()
// {

//   printf("input:\n");
//   yylex();

// }