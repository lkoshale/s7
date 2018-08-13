%{
	#include <stdio.h>	
	
%}

var  [_A-Za-z][_A-Za-z0-9]*

%%

{var}  printf("varilable is %s",yytext);
"<"|">"   printf("less\n");
.      printf(" all \n");

%%

int yywrap(){
return 0;
}

main()
{

  printf("input:\n");
  yylex();

}
