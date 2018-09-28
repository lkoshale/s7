%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <limits.h>
    void yyerror(char *);
    int yylex(void);   

    extern int line_no; 

    char* var_name[1000];
    int var_val[1000];
    int size = 0;

    int check_var_decl(char* str);
    void add_var(char* str);
    void add_var_asgn(char* str, int val);
    void error(char* msg,int line);
    void assgn_var(char* str,int val);
    int get_val(char* str);

%}

%union {
    int num;
    char string[100];
}


%token INT IDENT ADD MINUS STAR DIV LP RP SMCOL EQL COMA
%token NUM

%type<num> NUM expr
%type<string> IDENT

%left ADD MINUS
%left STAR
%left DIV
%right UNOP

%%

start : statement_star 


statement_star : statement
                | statement_star statement

statement : IDENT EQL expr SMCOL                        {assgn_var($1,$3);}
            | expr SMCOL                                {printf("%d\n",$1);}
            | declaration                               
            ;

declaration : INT IDENT SMCOL                               { add_var($2); }
            | INT IDENT EQL expr SMCOL                      { add_var_asgn($2,$4);}
            | INT IDENT mul_decl SMCOL                      { add_var($2); }
            | INT IDENT EQL expr mul_decl SMCOL             { add_var_asgn($2,$4);}
            ;

mul_decl : COMA IDENT                                       { add_var($2); }
        | COMA IDENT EQL expr                               { add_var_asgn($2,$4);}
        | mul_decl COMA IDENT                               { add_var($3);}
        | mul_decl COMA IDENT EQL expr                      { add_var_asgn($3,$5);}
        ;

expr : IDENT                                {$$=get_val($1);}
    | NUM                                   {$$ = $1;}
    | expr ADD expr                         {$$ = $1 + $3;}
    | expr MINUS expr                       {$$ = $1 - $3;}
    | expr STAR expr                        { $$= $1*$3;}
    | expr DIV expr                         { if($3==0) error("Divide By Zero",line_no); $$= $1/$3; }
    | MINUS expr  %prec UNOP                {$$ = -$2;}
    | ADD expr     %prec UNOP               {$$=$2;}
    | LP expr RP                            {$$= $2;}
    ;
%%

void yyerror(char *s) {
        printf("%s\n","Invalid Input");
    exit(0);
}


int check_var_decl(char* str){
    int i=0;
    for(i=0;i<size;i++){
        if(strcmp(str,var_name[i])==0){
            return i;
        }
    }

    return -1;
}

void add_var(char* str){
    if(check_var_decl(str)>=0)
        error("Invalid Statement",line_no);
    else{
        char* cpsrt = (char*)malloc(sizeof(char)*(strlen(str)+1));
        strcpy(cpsrt,str);
        var_name[size] = cpsrt; 
        size++;
    }    
}

void add_var_asgn(char* str, int val){
    if(check_var_decl(str)>=0)
        error("Invalid Statement",line_no);
    else{
        char* cpsrt = (char*)malloc(sizeof(char)*(strlen(str)+1));
        strcpy(cpsrt,str);
        var_name[size] = cpsrt; 
        var_val[size] = val;
        size++;
    }
}

void assgn_var(char* str,int val){
    int idx = check_var_decl(str);
    if(idx ==-1)
        error("Invalid Statement",line_no);
    else{ 
        var_val[idx] = val;
    }
}


int get_val(char* str){
    int idx = check_var_decl(str);
    if(idx==-1){
        //not declared
        error("Invalid Statement",line_no);
    }
    else{
        if(var_val[idx]==INT_MIN){
            //not assigned
            error("Invalid Statement",line_no);
        }
        else{
            return var_val[idx];
        }
    }
}

void error(char* msg,int line){
    printf("%s %d\n",msg,line);
    exit(0);
}

int main(){

    int i =0;
    for(i=0;i<1000;i++){
        var_val[i]= INT_MIN;
    }

    yyparse();
    return 0;
}