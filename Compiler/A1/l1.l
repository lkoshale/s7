%{
    #include <stdio.h>
    
%}


%%
"'"(.|\\.)"'"                     {printf("char");}
\"(\\.|[^"\\])*\"           {printf("string"); }
"/*"([^*]|\*+[^*/])*\*+"/"   {printf("multiline cmnt");}
"/"["/"]+.*             {printf("single comment");}
"'"                    {printf("double quotes");}
[_a-zA-Z][_a-zA-Z0-9]+  { printf("Identifier");}
"!"|"&"                  {printf("Uniry op");}
.                          {printf("dot");}

%%

int yywrap(void) {
    return 1;
}

int main(){
    yylex();

}