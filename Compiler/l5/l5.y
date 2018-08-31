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

    int new_non_term =0;

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

start : rule_star                   {printf("%s\n","parsed sucessfully" ); print(); remove_left_rec(); print();}

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

//print currnet grammar
void print(){
    int i;
    printf("%d\n",array_len);
    for(i=0;i<array_len;i++){
       Production* p = array[i];
       printf("%s : ",p->Nterm);
       int j,k;
      for(k=0;k<p->size;k++){
          Terms* t = p->prod[k];
          if(k>0)
             printf("|");
        
          for(j=0;j<t->size;j++){
            printf(" %s ",t->term[j]);
          }
         
      }
      printf(" ;\n");
    }
}

// if p1 -> p2 alpha
int exists(Production* p1, Production* p2){
    
    int i=0;

    for(i=0;i<p1->size;i++){
        // printf("%s %s\n",p1->Nterm,p2->Nterm);
        if(strcmp(p1->prod[i]->term[0],p2->Nterm)==0)
            return 1;
    }
    return 0;
}

void remove_rec(Production* p1,Production* p2){
    int i=0;
    for(i=0;i<p1->size;i++){
        //if contains
        if(strcmp(p1->prod[i]->term[0],p2->Nterm)==0){
            int j=0;
            Terms* term1 = p1->prod[i];
            char* remain_term[100];
            int rm_size=0;
            int j2=0;
            //save remaining terms
            for(j2=1;j2<term1->size;j2++){
                remain_term[j2-1]=term1->term[j2];
                rm_size++;
            }

            //for every prod in p2
            for(j=0;j<p2->size;j++){
                int k=0;
                Terms* term3;
                if(j==0){
                    term3 = p1->prod[i];
                    term3->size=0;
                }else{
                    //add new production
                    p1->prod[p1->size]=(Terms*)malloc(sizeof(Terms));
                    term3 = p1->prod[p1->size];
                    term3->size = 0;
                    p1->size++;
                }

                Terms* term2 = p2->prod[j];
                for(k=0;k< (term2->size);k++){
                    term3->term[k]=term2->term[k];
                    term3->size++;
                }
                
                for(k=0;k<rm_size;k++){
                    term3->term[term3->size]=remain_term[k];
                    term3->size++;
                }
            }
        }
    }


}

int check_left(Production* p){
    int i=0;
    for(i=0;i<p->size;i++){
        if(strcmp(p->Nterm,p->prod[i]->term[0])==0)
            return 1;
    }
    return 0;
}


void eliminate(int idx){
    
    Production* p = array[idx];

    if(check_left(p)==1){
        int i=0;
        Terms* non_left[100];
        int nl_size=0;

        //create new production
        char* np_name = (char*)malloc(sizeof(char)*50);
        sprintf(np_name,"Cs15b049%d",new_non_term);
        new_non_term++;

        Production* new_p = (Production*)malloc(sizeof(Production));
        strcpy(new_p->Nterm,np_name);
        new_p->size=0;

        Production* old_p = (Production*)malloc(sizeof(Production));
        strcpy(old_p->Nterm,p->Nterm);
        old_p->size=0;
        

        //add new prod to new_p right recur
        for(i=0;i<p->size;i++){
            Terms* t = p->prod[i];
            if(strcmp(p->Nterm,t->term[0])==0){
                int k=0;
                Terms* t2 = (Terms*)malloc(sizeof(Terms));
                t2->size=0;
                for(k=1;k<t->size;k++){
                    t2->term[t2->size]= t->term[k];
                    t2->size++;
                }

                t2->term[t2->size]= np_name;
                t2->size++;   

                new_p->prod[new_p->size]=t2;
                new_p->size++;
            }
            else{
                int k=0;
                Terms* t2 = (Terms*)malloc(sizeof(Terms));
                t2->size=0;
                for(k=0;k<t->size;k++){
                    t2->term[t2->size]= t->term[k];
                    t2->size++;
                }

                t2->term[t2->size]= np_name;
                t2->size++;   

                old_p->prod[old_p->size]=t2;
                old_p->size++;
            }
            
        }

        Terms* temp = (Terms*)malloc(sizeof(Terms));
        temp->size=0;
        char* eps = (char*)malloc(sizeof(char)*10);
        sprintf(eps,"$");
        temp->term[temp->size]=eps;
        temp->size++;

        new_p->prod[new_p->size]=temp;
        new_p->size++;
        
        array[idx]= old_p;
        array[array_len]= new_p;
        array_len++;
    }
    //end if    
}

void remove_left_rec(){
    int i,j;
    for( i=0;i<array_len;i++){
        
        for(j=0;j<i;j++){
            //multiple production can be in while    
            if(exists(array[i],array[j])>0){
                remove_rec(array[i],array[j]);
            }
        }

        eliminate(i);
    }
}


int main(){

    yyparse();
    return 0;
}

//TODO elimanate epsilon transition while rec and elminate