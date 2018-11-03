%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <limits.h>
    #include <stdbool.h>
    void yyerror(char *);
    int yylex(void);
    
    typedef struct node_ {
        char name[100];
        struct node_* children[100];
        int size;
    } Node;

    char* main_var[100];
    int main_var_size = 0;

    Node* all_fun[100];
    int all_fun_size = 0;

    
    bool flag_main = false;
    void add_main_var(char* var);

    char* get_inline(char* fun);
    void gen_main(Node* sstar);
    bool check_var( char* var);
    

    Node* mk_node0(char* name);
    Node* mk_node1(char* name,Node* c1);
    Node* mk_node2(char* name,Node* c1,Node* c2);
    Node* mk_node3(char* name,Node* c1,Node* c2,Node* c3);

%}

%union{
    char str[100];
    struct  node_* node;
}

%token  INCLUDE STDIO  LT  GT  INT_TYPE  VOID_TYPE  MAIN PRINTF  RETURN  LP  RP
%token  LCB RCB ADD  MINUS MUL  DIV  EQ  SMCOL  COMA 
%token<str> IDENT STRING_LIT INT_LIT 

%type<node> param pexp exp stmt assgn_stmt return_stmt print_stmt stmt_star
%type<node> decl_stmt rest_decl function function_star 

%%


prog : header function_star main_fun
     ;

header : INCLUDE LT STDIO GT  
        ;

function_star : function
             | function_star function
             ;

function: INT_TYPE  IDENT LP INT_TYPE IDENT RP LCB stmt_star RCB     { Node* parm = mk_node0($5); $$ = mk_node2($2,parm,$8); all_fun[all_fun_size]=$$; all_fun_size++; }
        ;


main_fun : VOID_TYPE MAIN LP RP LCB {flag_main = true; }  stmt_star  RCB  { }
        ;

stmt_star : stmt                {$$=mk_node1("stmt_star",$1);}
          | stmt_star stmt      {$$=mk_node2("stmt_star",$1,$2);}
          ;


stmt : decl_stmt        { $$=mk_node1("stmt",$1); }
    | assgn_stmt        { $$=mk_node1("stmt",$1); }
    | print_stmt        { $$=mk_node1("stmt",$1); }
    | return_stmt       { $$=mk_node1("stmt",$1); }
    ;


decl_stmt : INT_TYPE IDENT SMCOL                    {Node* dec=mk_node0($2); $$=mk_node1("decl",dec);  if(flag_main){ add_main_var($2); }  }
          | INT_TYPE IDENT rest_decl SMCOL          {Node* dec=mk_node0($2); $$=mk_node2("decl",dec,$3);  if(flag_main){ add_main_var($2);}   }
          ;

rest_decl : COMA IDENT                          {Node* dec= mk_node0($2); $$=mk_node1("rest_decl",dec);    if(flag_main){ add_main_var($2); } }
         | rest_decl COMA IDENT                 {Node* dec= mk_node0($3); $$=mk_node2("rest_decl",$1,dec);   if(flag_main){ add_main_var($3); } }
         ;

assgn_stmt : IDENT EQ exp SMCOL                    { Node* id = mk_node0($1); $$=mk_node2("assgn_stmt",id,$3);  }
            | IDENT EQ IDENT LP param RP SMCOL     { Node* id = mk_node0($1); Node* fun=mk_node0($3); $$=mk_node3("assgn_stmt",id,fun,$5); }
           ;

print_stmt: PRINTF LP STRING_LIT COMA IDENT RP SMCOL       {Node* lit = mk_node0($3); Node* id=mk_node0($5); $$=mk_node2("print_stmt",lit,id);}
          | PRINTF LP STRING_LIT RP SMCOL                  {Node* lit = mk_node0($3); $$=mk_node1("print_stmt",lit);}
          ;

return_stmt : RETURN param SMCOL                    {$$=mk_node1("return_stmt",$2);}
            ;

exp : pexp ADD pexp                 { Node* op = mk_node0("+"); $$=mk_node3("exp",$1,op,$3);}
    | pexp MINUS pexp               { Node* op = mk_node0("-"); $$=mk_node3("exp",$1,op,$3);}
    | pexp MUL pexp                 { Node* op = mk_node0("*"); $$=mk_node3("exp",$1,op,$3);}
    | pexp DIV pexp                 { Node* op = mk_node0("/"); $$=mk_node3("exp",$1,op,$3);}
    | pexp                          { $$=mk_node1("exp",$1);}
    | MINUS pexp                    { Node* op = mk_node0("-"); $$=mk_node2("exp",op,$2);}
    ;

pexp : IDENT            {Node* id = mk_node0($1); $$=mk_node1("pexpID",id);}
    | INT_LIT           {Node* id = mk_node0($1); $$=mk_node1("pexpINT",id);}
    ;

param : IDENT           {Node* id = mk_node0($1); $$=mk_node1("paramID",id);}
      | INT_LIT         {Node* id = mk_node0($1); $$=mk_node1("paramINT",id);}
      ;


%%

void yyerror(char *s) {
    printf("%s\n","Invalid Input");
    exit(0);
}



int main(){

    yyparse();

    return 0;
}


void rec_gen(Node* root){

    if(root==NULL)
        return;

    bool go_down = true;

    if(strcmp(root->name,"decl")==0 && root->size==1){
        printf("\tint %s;\n",root->children[0]->name );
        go_down = false;
    }
    else if(strcmp(root->name,"decl")==0 && root->size==2){
        printf("\tint %s",root->children[0]->name);
        go_down = false;
    }
    else if(strcmp(root->name,"rest_decl")==0 ){
        if(root->size==1)
            printf(",%s",root->children[0]->name);
        else if(root->size==2)
            printf(",%s;\n",root->children[1]->name);

        go_down = false;
    }
    else if(strcmp(root->name,"assgn_stmt")==0){
        if(root->size==2){
            printf("\t%s= ",root->children[0] );
        }else if(root->size==3){
            // inline function
            go_down=false;
            printf("inlinefn add\n");
        }
    }
    else if(strcmp(root->name,"print_stmt")==0){
        if(root->size==1)
            printf("\tprintf(%s,%s);\n",root->children[0]->name, root->children[1]->name);
        else if(root->size==2)
            printf("\tprintf(%s);\n",root->children[0]->name);

        go_down = false;
    }
    else if(strcmp(root->name,"return_stmt")==0){
        printf("\treturn %s;\n",root->children[0]->children[0]->name );
        go_down=false;
    }
    else if( strcmp(root->name,"exp")==0){
        if(root->size==3){
            printf(" %s %s %s ;\n",root->children[0]->children[0]->name,root->children[1]->name,root->children[2]->children[0]->name );
        }else if(root->size==2){
            printf("%s%s;\n",root->children[0]->name,root->children[1]->children[0]->name );
        }
        else if(root->size==1){
            printf("%s;\n",root->children[0]->children[0]->name );
        }

        go_down=false;
    }
 
    if(go_down){
        for(int i=0;i<root->size;i++){
            rec_gen(root->children[i]);
        }
    }

}

void gen_main(Node* sstar){
    printf("#include <stdio.h>\n");
    printf("void main(){\n");\

    rec_gen(sstar);
    printf("\n}\n");
}

void add_main_var(char* name){
    strcpy(main_var[main_var_size],name);
    main_var_size++;
}


Node* mk_node0(char* name){
    Node* temp = (Node*)malloc(sizeof(Node));
    if(temp!=NULL){
        strcpy(temp->name,name);
        temp->size = 0;

        return temp;
    }

    return NULL;
 }

 Node* mk_node1(char* name,Node* c1){
    Node* temp = mk_node0(name);
    if(temp!=NULL){

        temp->children[0]=c1;
        temp->size =1;
        return temp;
    }

    return NULL;
 }

 Node* mk_node2(char* name,Node* c1,Node* c2){
    Node* temp = mk_node0(name);
    if(temp!=NULL){

        temp->children[0]=c1;
        temp->children[1]=c2;
        temp->size =2;
        return temp;
    }

    return NULL;
 }

 Node* mk_node3(char* name,Node* c1,Node* c2,Node* c3){
    Node* temp = mk_node0(name);
    if(temp!=NULL){

        temp->children[0]=c1;
        temp->children[1]=c2;
        temp->children[2]=c3;
        temp->size =3;
        return temp;
    }

    return NULL;
 }