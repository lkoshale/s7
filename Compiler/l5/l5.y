%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <limits.h>
    void yyerror(char *);
    int yylex(void);

    typedef struct term_{
        char* term[100];
        int size;
    }Terms;

    typedef struct data{
        char Nterm[100];
        struct term_* prod[100];
        int size;
    } Production;

    Production* array[100];
    int array_len = 0;

    /*function decl*/
    void add_term(Terms* t, char* str);
    void print();
    void remove_left_rec();


%}

%union{
    char str[100];
    struct term_* val;
    struct data* pr;
}

%token<str>  TERM NTERM SMCOL COL ESP BAR

%type<str> production_end rule_star start
%type<val> production
%type<pr> production_star rule


%%

start : rule_star                   {printf("%s\n","parsed sucessfully" ); print(); remove_left_rec();}

rule_star :  rule                               { array[array_len]=$1; array_len++; }
          | rule_star rule                 { array[array_len]=$2; array_len++; }
          ;

rule : NTERM COL production production_star SMCOL       { strcpy($4->Nterm,$1); $4->prod[$4->size]=$3; $4->size++; $$=$4; }
     | NTERM COL production SMCOL                       { Production* p=(Production*)malloc(sizeof(Production));strcpy(p->Nterm,$1); p->size=0; p->prod[p->size]=$3; p->size++; $$=p; }
    ;

production_star : BAR production                       { Production* p=(Production*)malloc(sizeof(Production)); p->size=0; p->prod[p->size]=$2; p->size++; $$=p;}
                 | production_star BAR production       { $1->prod[$1->size]=$3; $1->size++; $$=$1; }
                ;


production : production_end                     { Terms* t=(Terms*)malloc(sizeof(Terms)); t->size=0; add_term(t,$1); $$=t; }
            | production production_end         { add_term($1,$2); $$=$1;}
            ;


production_end : ESP
           | NTERM
           | TERM
           ;


%%

void yyerror(char *s) {
    printf("%s\n","Invalid Input");
    exit(0);
}

void add_term(Terms* t, char* str){
    t->term[t->size]=(char*)malloc(sizeof(char)*strlen(str));
    strcpy(t->term[t->size],str);
    t->size++;
}

void print(){
    int i;
    printf("%d\n",array_len);
    for(i=0;i<array_len;i++){
        printf("%s\n",array[i]->Nterm );
    }
}

// if p1 -> p2 alpha
int exists(Production* p1, Production* p2){
    
    int i=0;
    for(i=0;i<p1->size;i++){
        if(strcmp(p1->prod[i]->term[0],p2->Nterm)==0)
            return 1;
    }
    return 0;
}

void remove_left_rec(){
    int i,j;
    for( i=0;i<array_len;i++){
        
        for(j=0;j<i-1;j++){
            if(exists(array[i],array[j])==1){
                printf("recursion\n");
            }

        }

    }
}


int main(){

    yyparse();
    return 0;
}