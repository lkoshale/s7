%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <limits.h>
    void yyerror(char *);
    int yylex(void);
    
    typedef struct array_{
      char* arr[100];
      int len;

    } array;

    array* create();
    array*  complexity(array* ans, char* declr ,char* expr , char* incop );

%}


%union{
  char str[1000];
  struct array_* comp;
  char* exprs[2];
}

%token SMCOL LP RP LCB RCB EQL GT LT LE GE INC DEC
%token STAREQ DIVEQ INT VOID MAIN INT_LIT STRING_LIT COMA FOR

%token<str> IDENT 
%type<comp> for_loop stmnt    for_loop_star
%type<exprs> exp  
%type<str> decl inc print_stmnt print_stmnt_star rel_op


%%

prog : global_star main 
      | main 
      ;


global_star : global
            | global_star global
            ;

global : INT IDENT SMCOL
      | INT IDENT rest SMCOL 
      ;

rest : COMA IDENT
      | rest COMA IDENT 
      ;

main : VOID MAIN LP RP LCB for_loop_star RCB
      | VOID MAIN LP RP LCB RCB
      ;

for_loop_star : for_loop
              | for_loop_star for_loop
              ;

for_loop : FOR LP decl SMCOL exp SMCOL inc RP LCB stmnt RCB  {$$=complexity($10,$3,$5[0],$7);}
          ;

decl : INT IDENT EQL INT_LIT   { strcpy($$,"-1");}
    | INT IDENT EQL IDENT       { strcpy($$,$4); }
    ;

exp : IDENT rel_op IDENT        { $$[0]= (char*)(malloc(sizeof(char)*(strlen($3)+4))); $$[1]= (char*)(malloc(sizeof(char)*5));  strcpy($$[0],$3); strcpy($$[1],$2); }
    | IDENT rel_op INT_LIT      { $$[0]= (char*)(malloc(sizeof(char)*(5))); $$[1]= (char*)(malloc(sizeof(char)*5));  strcpy($$[0],"-1"); strcpy($$[1],$2);}
    ;

inc : IDENT INC                 { strcpy($$,"1");}
    | IDENT DEC                 { strcpy($$,"2");}
    | IDENT STAREQ INT_LIT      { strcpy($$,"3");}
    | IDENT DIVEQ INT_LIT       { strcpy($$,"4");}
    ;

stmnt : print_stmnt_star              { $$=create();}
      | for_loop                      { $$=$1;}
      | for_loop print_stmnt_star     { $$=$1;}
      ;

print_stmnt_star : print_stmnt
                | print_stmnt_star  print_stmnt
                ;

print_stmnt : IDENT LP STRING_LIT RP SMCOL  
            ;

rel_op : LT    {strcpy($$,"<");}
        | GT   {strcpy($$,">");}
        | LE    {strcpy($$,"<=");}
        | GE    {strcpy($$,">=");}
        ;


%%

void yyerror(char *s) {
    printf("%s\n","Invalid Input");
    exit(0);
}


array* create(){
  array* temp = (array*)malloc(sizeof(array));
  
  if(temp==NULL)
      return NULL;
  
  temp->len = 0;

  return temp;
}


array*  complexity(array* ans, char* declr ,char* expr , char* incop ){
      //if O1 put nothing
      if(strcmp(declr,"-1")==0 && strcmp(expr,"-1")==0){
        // do nothing O1
        return ans ;
      }

      //start with global dec--** 
      if(strcmp(declr,"-1")!=0 && strcmp(expr,"-1")==0 ){
          if(strcmp(incop,"2")==0 ){
             ans->arr[ans->len] = (char*)malloc(sizeof(char)*(strlen(declr)+4));
             strcpy(ans->arr[ans->len],declr);
             ans->len++;
         }
         else if(strcmp(incop,"4")==0 ){
              ans->arr[ans->len] = (char*)malloc(sizeof(char)*(strlen(declr)+10));
              sprintf(ans->arr[ans->len],"log(%s)",declr);
              ans->len++;
         }

         return ans;
      }

      // if gloabl in exp start with const , global , inc++**
      if(  strcmp(declr,"-1")==0 && strcmp(expr,"-1")!=0  ){
         if(strcmp(incop,"1")==0 ){
             ans->arr[ans->len] = (char*)malloc(sizeof(char)*(strlen(expr)+4));
             strcpy(ans->arr[ans->len],expr);
             ans->len++;
         }
         else if(strcmp(incop,"3")==0 ){
              ans->arr[ans->len] = (char*)malloc(sizeof(char)*(strlen(expr)+10));
              sprintf(ans->arr[ans->len],"log(%s)",expr);
              ans->len++;
         }


         return ans;
         //else start with const var dec -- // not catching infinite loop
      }


      return ans;
 }


int main(){

    yyparse();
    return 0;
}