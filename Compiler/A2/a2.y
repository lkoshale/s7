%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <limits.h>
    void yyerror(char *);
    int yylex(void);

    typedef struct node{
        char val[100];
        struct node* edge[1000];
        int len;
    } Node;

    Node* new_node(char* str);
    void add_child(Node* root,Node* child);
    void print_tree(Node* root);

%}

%union {
    struct node* root;
}

%token<root> LP RP LB RB LCB RCB IDENT INTEGER FLOAT COMA SMCOL
%token<root> FLT INT VOID IF ELSE FOR WHILE CONTINUE BREAK RETURN 
%token<root> ADD SUB DIV PERCNT STAR OR AND AMPRESAND EQL EQLTY NOT RELOP



%type<root> Pexpr integerLit floatLit identifier
%type<root> unaryop arg_list args expr
%type<root> assign_stmt continue_stmt break_stmt return_stmt if_stmt local_decl local_decls
%type<root> compound_stmt while_stmt stmt stmt_list param param_list params fun_decl type_spec
%type<root> var_decl decl dec_list program


%%



program : dec_list              { $$=new_node("program");add_child($$,$1);print_tree($$);}
        ;

dec_list : decl                 { $$=new_node("dec_list");add_child($$,$1);}
        | dec_list decl         { $$=new_node("dec_list");add_child($$,$1);add_child($$,$2);}
        ;

decl : var_decl                 { $$=new_node("decl");add_child($$,$1);}
    | fun_decl                   { $$=new_node("decl");add_child($$,$1);}        
    ;

var_decl :  type_spec identifier SMCOL                                  { $$=new_node("var_decl");add_child($$,$1);add_child($$,$2);add_child($$,$3);}
        |   type_spec identifier COMA var_decl                          { $$=new_node("var_decl");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);}
        |   type_spec identifier LB integerLit RB SMCOL                 { $$=new_node("var_decl");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);add_child($$,$6);}
        |   type_spec identifier LB integerLit RB COMA var_decl         { $$=new_node("var_decl");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);add_child($$,$6);add_child($$,$7);}
        ;

type_spec : VOID            { $$=new_node("type_spec");add_child($$,$1);}
        | INT               { $$=new_node("type_spec");add_child($$,$1);}
        | FLOAT             { $$=new_node("type_spec");add_child($$,$1);}
        | VOID STAR         { $$=new_node("type_spec");add_child($$,$1);add_child($$,$2);}
        | INT STAR          { $$=new_node("type_spec");add_child($$,$1);add_child($$,$2);}
        | FLOAT STAR        { $$=new_node("type_spec");add_child($$,$1);add_child($$,$2);}
        ;

fun_decl : type_spec identifier LP params RP compound_stmt  { $$=new_node("fun_decl");add_child($$,$1); add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);add_child($$,$6);}
        ;

params : /* expr */                     {$$=NULL;}
        | param_list                    { $$=new_node("params");add_child($$,$1);}
        ;

param_list : param_list COMA param          { $$=new_node("param_list");add_child($$,$1); add_child($$,$2);add_child($$,$3);}
            | param                         { $$=new_node("param_list");add_child($$,$1);}
            ;

param : type_spec identifier                { $$=new_node("param");add_child($$,$1);add_child($$,$2);}
     | type_spec identifier LB RB           { $$=new_node("param");add_child($$,$1);add_child($$,$2);}
     ;

stmt_list :  stmt_list stmt                 { $$=new_node("stmt_list");add_child($$,$1);add_child($$,$2);}
          | stmt                            { $$=new_node("stmt_list");add_child($$,$1);}
          ;

stmt : assign_stmt                          { $$=new_node("stmt");add_child($$,$1);}  
    | compound_stmt                         { $$=new_node("stmt");add_child($$,$1);}
    | if_stmt                               { $$=new_node("stmt");add_child($$,$1);}
    | while_stmt                            { $$=new_node("stmt");add_child($$,$1);}
    | return_stmt                           { $$=new_node("stmt");add_child($$,$1);}
    | break_stmt                            { $$=new_node("stmt");add_child($$,$1);}
    | continue_stmt                         { $$=new_node("stmt");add_child($$,$1);}
    ;

while_stmt : WHILE LP expr RP stmt                  { $$=new_node("while_stmt");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);}  
            ;

compound_stmt : LCB  local_decls stmt_list RCB      { $$=new_node("compound_stmt");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);}  
                ;

local_decls : /*empty*/                             { $$=NULL;}
            | local_decls local_decl                { $$=new_node("local_decls");add_child($$,$1);add_child($$,$2);}  
            ;

local_decl : type_spec identifier SMCOL             { $$=new_node("local_decl");add_child($$,$1);add_child($$,$2);add_child($$,$3);}  
            | type_spec identifier LB expr RB       { $$=new_node("local_decl");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);}  
            ;

if_stmt : IF LP expr RP stmt               { $$=new_node("if_stmt");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);}  
        | IF LP expr RP stmt ELSE stmt     { $$=new_node("if_stmt");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);add_child($$,$5);add_child($$,$6);add_child($$,$7);}   
        ;

return_stmt : RETURN SMCOL              {$$=new_node("return_stmt");add_child($$,$1);add_child($$,$2);}  
            | RETURN expr SMCOL         {$$=new_node("return_stmt");add_child($$,$1);add_child($$,$2);add_child($$,$3);}  
            ;

break_stmt : BREAK SMCOL                    {$$=new_node("break");add_child($$,$1);add_child($$,$2);}  

continue_stmt : CONTINUE SMCOL              {$$=new_node("continue_stmt");add_child($$,$1);add_child($$,$2);}  
                ;

assign_stmt : identifier EQL expr SMCOL             {$$=new_node("assign_stmt"); add_child($2,$1); add_child($2,$3);add_child($$,$2);add_child($$,$4);}
            | identifier LB expr RB EQL expr SMCOL  {$$=new_node("assign_stmt"); add_child($5,$1); add_child($5,$2);add_child($5,$3); add_child($5,$4);add_child($5,$6); add_child($$,$5);add_child($$,$7);}
            ;


expr : Pexpr OR Pexpr                   {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr EQLTY Pexpr                {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr RELOP Pexpr                {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr AND Pexpr                  {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr ADD Pexpr                  {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr SUB Pexpr                  {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr STAR Pexpr                 {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr DIV Pexpr                   {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}
     | Pexpr PERCNT Pexpr               {$$=new_node("expr"); add_child($2,$1); add_child($2,$3);add_child($$,$2);}  
     | unaryop Pexpr                    {$$=new_node("expr");add_child($$,$1);add_child($$,$2);}  
     | Pexpr                            {$$=new_node("expr");add_child($$,$1);}              
     | identifier LP args RP            {$$=new_node("expr");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);}  
     | identifier LB expr RB            {$$=new_node("expr");add_child($$,$1);add_child($$,$2);add_child($$,$3);add_child($$,$4);}  
     ;


Pexpr : integerLit          {$$=new_node("Pexpr");add_child($$,$1);}  
        | floatLit           {$$=new_node("Pexpr");add_child($$,$1);}  
        | identifier         {$$=new_node("Pexpr");add_child($$,$1);}  
        | LP expr RP        {$$=new_node("Pexpr");add_child($$,$1);add_child($$,$2);add_child($$,$3);}  
        ;

/*self made node*/
unaryop : NOT
        | SUB
        | ADD
        | STAR
        | AMPRESAND
        ;

arg_list : expr                     {$$=new_node("arg_list");add_child($$,$1);}  
         | arg_list COMA expr       {$$=new_node("arg_list");add_child($$,$1);add_child($$,$2);add_child($$,$3);}  
         ;

args : /*empty*/        { $$=NULL;}
     | arg_list         {$$=new_node("args");add_child($$,$1);}  
     ;

integerLit :INTEGER   {$$=new_node("integerLit");add_child($$,$1);}  
            ;

floatLit : FLOAT     {$$=new_node("floatLit");add_child($$,$1);}
            ;

identifier : IDENT     {$$=new_node("identifier");add_child($$,$1);}
            ;


%%

void yyerror(char *s) {
    printf("%s\n","Invalid Input");
    exit(0);
}

void add_child(Node* root,Node* child){
    if(root!=NULL && child!=NULL){
        root->edge[root->len]=child;
        root->len++;
    }
  
}


Node* new_node(char* str){
    Node* temp = (Node*)malloc(sizeof(Node));
    if(temp!=NULL){
        strcpy(temp->val,str);
        temp->len =0;
    }
    return temp;
}

void print_tree(Node* root){
    if(root!=NULL){
        printf(" %s ->",root->val);
        for(int i=0;i<root->len;i++){
            printf(" %s ",root->edge[i]->val);
        }
        printf("\n");
        for(int i=0;i<root->len;i++){
            print_tree(root->edge[i]);
        }
    }
}

int main(){

    yyparse();
    return 0;
}