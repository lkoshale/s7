%token INTEGER_LITERAL FLOAT_LITERAL IDENTIFIER SC PRINTF FORMAT_SPECIFIER
%token INT VOID FLOAT WHILE IF ELSE BREAK CONTINUE RETURN
%token COMMA PAREN_OPEN PAREN_CLOSE SQ_OPEN SQ_CLOSE CURLY_OPEN CURLY_CLOSE
%token OR EE NE LE LT GE GT AND PLUS MINUS INTO BY MOD NOT ASSGN UNAND SCANF SCAN_FORMAT
%{
	#define YYSTYPE struct node*
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <iostream>
    #include <climits>
    #include <bits/stdc++.h>
    #include <map>
    #include <utility>

    using namespace std;
    #include "y.tab.h"
    #define max(a,b) (a>b)?a:b
    void yyerror(string);
    int yylex(void);
    extern char* yytext;
    extern int LineNo;
    typedef struct node{
        bool asmd = false;
        string type;
        struct node* children[10];
        int noc;
        int line;
    }node;
    node* root;
    void getasm(node* root);
    node* mk0(string t);
    node* mk1(string t, node* one);
    node* mk2(string t, node* one, node* two);
    node* mk3(string t, node* one, node* two, node* three);
    node* mk4(string t, node* one, node* two, node* three, node* four);
    node* mk5(string t, node* one, node* two, node* three, node* four, node* five);
    node* mk6(string t, node* one, node* two, node* three, node* four, node* five, node* six);
    node* mk7(string t, node* one, node* two, node* three, node* four, node* five, node* six, node* seven);
    void freenodes(node* root);
    void printtree(node* root);
    string getlabel();
    unordered_map<string,unordered_map <string,int>> loc;
    unordered_map<string,int> temp;
    unordered_map<string,string> funlabel;
    string currfun;
    int nn = 0, variables=0;
    int top = 4;
    int ctr = 0;

    //value of var
    vector<string>Lvar;
    vector<int>Lval;
    vector<int>Lstate;

    //Line no and val
    map< int,int >ConstantFold; 

    //Line no .. var and its val
    map<int,vector< pair<string,int> > >CProp;

    //for if
    vector<int> if_smpl;

    //unused var index of Lvar
    vector<int> unused;

    //Line no max operand
    map<int,int> mstrengthR;

    set<int>removedLine;

    //fun
    void optimise(node* root);

    //output
    FILE* smmry = fopen("summary.txt","w");
    FILE* assm = fopen("assembly.s","w");

%}

%%

program:        decl_list 
                {
                    root = mk1("program", $1);
                };

decl_list:      decl_list decl        
                {
                    $$ = mk2("decl_list", $1, $2);
                }
                | decl                  
                {
                    $$ = mk1("decl_list", $1);
                }
                ;

decl:           var_decl                
                {
                    variables++;
                    loc["global"][$1->children[0]->children[0]->type] = top;
                    top += 4;
                    $$ = mk1("decl", $1);
                }
                | func_decl             
                {
                    currfun = $1->children[1]->children[0]->type;
                    loc[currfun] = temp;
                    temp.clear();
                    $$ = mk1("decl", $1);
                }
                ;

var_decl:       type_spec identifier SC 
                {
                    $3 = mk0(";");
                    $$ = mk3("var_decl", $1, $2, $3);
                }                                                    
                | type_spec identifier COMMA var_decl
                {
                    $3 = mk0(",");
                    $$ = mk4("var_decl", $1, $2, $3, $4);
                }
                | type_spec identifier SQ_OPEN integerLit SQ_CLOSE SC
                {
                    $3 = mk0("[");
                    $5 = mk0("]");
                    $6 = mk0(";");
                    $$ = mk6("var_decl", $1, $2, $3, $4, $5, $6);
                }
                | type_spec identifier SQ_OPEN integerLit SQ_CLOSE COMMA var_decl
                {
                    $3 = mk0("[");
                    $5 = mk0("]");
                    $6 = mk0(",");
                    $$ = mk7("var_decl", $1, $2, $3, $4, $5, $6,$7);
                }
                ;

type_spec:      VOID 
                {
                    $1 = mk0("void");
                    $$ = mk1("type_spec", $1);
                }
                | INT 
                {
                    $1 = mk0("int");
                    $$ = mk1("type_spec", $1);
                }
                ;

func_decl:      type_spec identifier PAREN_OPEN params PAREN_CLOSE compound_stmt
                {
                    $3 = mk0("(");
                    $5 = mk0(")");
                    $$ = mk6("func_decl", $1, $2, $3, $4, $5, $6);
                }
                ;

params:         param_list 
                {
                    $$ = mk1("params", $1);
                }
                | 
                {
                    $$ = mk1("params", mk0("epsilon"));
                }
                ;

param_list:     param_list COMMA param 
                {
                    $2 = mk0(",");
                    $$ = mk3("param_list", $1, $2, $3);
                }
                | param
                {
                    $$ = mk1("param_list", $1);
                }
                ;

param:          type_spec identifier 
                {
                    variables++;
                    temp[$2->children[0]->type] = top;
                    top+=4;
                    $$ = mk2("param", $1, $2);
                }
                | type_spec identifier SQ_OPEN SQ_CLOSE
                {
                    $3 = mk0("[");
                    $4 = mk0("]");
                    $$ = mk4("param", $1, $2, $3 , $4);
                }
                | type_spec SQ_OPEN SQ_CLOSE identifier
                {
                    $2 = mk0("[");
                    $3 = mk0("]");
                    $$ = mk4("param", $1, $2, $3 , $4);
                }
                ;

stmt_list:      stmt_list stmt 
                {
                    $$ = mk2("stmt_list", $1, $2);
                }
                | stmt
                {
                    $$ = mk1("stmt_list", $1);
                }
                ;

stmt:           assign_stmt 
                {
                    $$ = mk1("stmt", $1);
                }
                | compound_stmt 
                {
                    $$ = mk1("stmt", $1);
                }
                | if_stmt 
                {
                    $$ = mk1("stmt", $1);
                }
                | while_stmt
                {
                    $$ = mk1("stmt", $1);
                }
                | return_stmt 
                {
                    $$ = mk1("stmt", $1);
                }
                | break_stmt 
                {
                    $$ = mk1("stmt", $1);
                }
                | continue_stmt
                {
                    $$ = mk1("stmt", $1);
                }
                | print_stmt
                {
                    $$ = mk1("stmt", $1);
                }
                | scan_stmt
                {
                    $$ = mk1("stmt", $1);
                }
                ;

while_stmt:     WHILE PAREN_OPEN expr PAREN_CLOSE stmt
                {
                    $1 = mk0("while");
                    $2 = mk0("(");
                    $4 = mk0(")");
                    $$ = mk5("while_stmt", $1, $2, $3, $4, $5);
                }
                ;

print_stmt:     PRINTF PAREN_OPEN FORMAT_SPECIFIER COMMA identifier PAREN_CLOSE SC
                {
                    $$ = mk1("print_stmt",$5);
                }
                ;


scan_stmt:   SCANF  PAREN_OPEN SCAN_FORMAT COMMA UNAND identifier PAREN_CLOSE SC
            {
                    $$ = mk1("scan_stmt",$6);
            }
            ; 

compound_stmt:  CURLY_OPEN local_decls stmt_list CURLY_CLOSE
                {
                    $1 = mk0("{");
                    $4 = mk0("}");
                    $$ = mk4("compound_stmt", $1, $2, $3, $4);
                }
                ;

local_decls:    local_decls local_decl 
                {
                    $$ = mk2("local_decls", $1, $2);
                }
                |
                {
                    $$ = mk1("local_decls", mk0("epsilon"));
                }
                ;

local_decl:     type_spec identifier SC 
                {
                    variables++;
                    temp[$2->children[0]->type] = top;
                    top+=4;
                    $3 = mk0(";");
                    $$ = mk3("local_decl", $1, $2, $3);
                    
                    //add to array
                    Lvar.push_back($2->children[0]->type);
                    //cout<<"add "<<$2->children[0]->type<<"\n";

                }
                | type_spec identifier SQ_OPEN expr SQ_CLOSE SC
                {
                    $3 = mk0("[");
                    $5 = mk0("]");
                    $6 = mk0(";");
                    $$ = mk6("local_decl", $1, $2, $3, $4, $5, $6);
                }
                ;

if_stmt:        IF PAREN_OPEN expr PAREN_CLOSE stmt
                {
                    $1 = mk0("if");
                    $2 = mk0("(");
                    $4 = mk0(")");
                    $$ = mk5("if_stmt", $1, $2, $3, $4, $5);
                }
                | IF PAREN_OPEN expr PAREN_CLOSE stmt ELSE stmt
                {
                    $1 = mk0("if");
                    $2 = mk0("(");
                    $4 = mk0(")");
                    $6 = mk0("else");
                    $$ = mk7("if_stmt", $1, $2, $3, $4, $5, $6, $7);
                }
                ;

return_stmt:    RETURN SC 
                {
                    $1 = mk0("return");
                    $2 = mk0(";");
                    $$ = mk2("return_stmt", $1, $2);
                }
                | RETURN expr SC
                {
                    $1 = mk0("return");
                    $3 = mk0(";");
                    $$ = mk3("return_stmt", $1, $2, $3);
                }
                ;

break_stmt:     BREAK SC
                {
                    $1 = mk0("break");
                    $2 = mk0(";");
                    $$ = mk2("break_stmt", $1, $2);
                }
                ;

continue_stmt:  CONTINUE SC
                {
                    $1 = mk0("continue");
                    $2 = mk0(";");
                    $$ = mk2("continue_stmt", $1, $2);
                }
                ;

assign_stmt:    identifier ASSGN expr SC 
                {
                    $4 = mk0(";");
                    $$ = mk2("assign_stmt", mk2("=", $1, $3), $4);
                }
                | identifier SQ_OPEN expr SQ_CLOSE ASSGN expr SC
                {
                    $5 = mk5("=", $1, mk0("["), $3, mk0("]"), $6);
                    $$ = mk1("assign_stmt", $5);
                }
                ;

expr:           Pexpr OR Pexpr 
                {
                    $2 = mk2("||", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr EE Pexpr
                {
                   $2 = mk2("==", $1, $3);
                    $$ = mk1("expr", $2);
                } 
                | Pexpr NE Pexpr
                {
                    $2 = mk2("!=", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr LE Pexpr 
                {
                    $2 = mk2("<=", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr LT Pexpr 
                {
                    $2 = mk2("<", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr GE Pexpr 
                {
                    $2 = mk2(">=", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr GT Pexpr
                {
                    $2 = mk2(">", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr AND Pexpr
                {
                    $2 = mk2("&&", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr PLUS Pexpr 
                {
                    $2 = mk2("+", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr MINUS Pexpr
                {
                    $2 = mk2("-", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr INTO Pexpr 
                {
                    $2 = mk2("*", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr BY Pexpr 
                {
                   $2 = mk2("/", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | Pexpr MOD Pexpr
                {
                    $2 = mk2("%%", $1, $3);
                    $$ = mk1("expr", $2);
                }
                | NOT Pexpr 
                {
                    $1 = mk0("!");
                    $$ = mk2("expr", $1, $2);
                }
                | MINUS Pexpr
                {
                    $1 = mk0("-");
                    $$ = mk2("expr", $1, $2);
                } 
                | PLUS Pexpr 
                {
                    $1 = mk0("+");
                    $$ = mk2("expr", $1, $2);
                }
                | INTO Pexpr 
                {
                    $1 = mk0("*");
                    $$ = mk2("expr", $1, $2);
                }
                | UNAND Pexpr
                {
                    $1 = mk0("&");
                    $$ = mk2("expr", $1, $2);
                }
                | Pexpr
                {
                    $$ = mk1("expr", $1);
                }
                | identifier PAREN_OPEN args PAREN_CLOSE
                {
                    if(loc.find($1->children[0]->type)==loc.end())
                        yyerror("");
                    $2 = mk0("(");
                    $4 = mk0(")");
                    $$ = mk4("expr", $1, $2, $3, $4);
                }
                | identifier SQ_OPEN expr SQ_CLOSE
                {
                    $2 = mk0("[");
                    $4 = mk0("]");
                    $$ = mk4("expr", $1, $2, $3, $4);
                }
                ;

Pexpr:          integerLit
                {
                    $$ = mk1("Pexpr", $1);
                }
                | identifier 
                {
                    if(temp.find($1->children[0]->type)==temp.end() && loc["global"].find($1->children[0]->type)==loc["global"].end())
                        yyerror("");
                    $$ = mk1("Pexpr", $1);
                }
                | PAREN_OPEN expr PAREN_CLOSE 
                {
                    $1 = mk0("(");
                    $3 = mk0(")");
                    $$ = mk3("Pexpr", $1, $2, $3);
                }
                ;

integerLit:     INTEGER_LITERAL 
                {
                    $1 = mk0(string(yytext));
                    $$ = mk1("integerLit", $1);
                }
                ;


identifier:     IDENTIFIER 
                {
                    $1 = mk0(string(yytext));
                    $$ = mk1("IDENTIFIER", $1);
                }
                ;

args:           args_list 
                {
                    $$ = mk1("args", $1);
                }
                | 
                {
                    $$ = mk1("args", mk0("epsilon"));
                }
                ;

args_list:      args_list COMMA expr 
                {
                    $2 = mk0(",");
                    $$ = mk3("args_list", $1, $2, $3);
                }
                | expr
                {
                    $$ = mk1("args_list", $1);
                }
                ;
%%

void yyerror(string s) {
    printf("Invalid\n");
    exit(0);
}

int main(void) {
    loc["global"];
    yyparse();

    optimise(root);
    printf("\n\n\n\n");
    top = (int)(16 * (ceil(variables/4.0)));
    // cout << top << endl;
    // for(auto &it:loc) {
    //     cout << it.first << endl;
    //     for(auto &j:it.second)
    //     {
    //         cout <<"\t"<< j.first <<"->" << j.second << endl;
    //     }
    //     cout <<"===" << endl;
    // }
    fprintf(assm,".LC0:\n\t.string \"%%d\\n\"\n.LC1:\n\t.string \"%%d\"\n\t.text\n\t.globl main\n\t.type main, @function\n");
    fprintf(assm,"main:\n.LFB0:\n\t.cfi_startproc\n\tpushq %%rbp\n\t.cfi_def_cfa_offset 16\n\t.cfi_offset 6, -16\n\tmovq %%rsp, %%rbp\n\t.cfi_def_cfa_register 6\n\t");
    fprintf(assm,"subq $%d,%%rsp\n", top);
    getasm(root);
    fprintf(assm,"\tmovl $0, %%eax\n\tleave\n\t.cfi_def_cfa 7, 8\n\tret\n\t.cfi_endproc\n");
    //printtree(root);
    freenodes(root);
    fclose(assm);
    fclose(smmry);
    return 0;
    
}

int const_fold_exp(node* root);
bool rec_const_fold(node* root);
bool rec_prop_id(node* expr);
bool rec_const_prop(node* root);
void Lupdate(string var,int val);
int Lget(string var);
void insert_cprop(string var,int val,int line);
void init_Lval();
int static_compute(node* expr);
bool rec_if(node* root);
bool unused_var(node* root);
void rec_strengthR(node* root);
void add_deadcode(node* root);
void write_summary();

void optimise(node* root){

    for(int i=0;i<10;i++){
        init_Lval();
        bool v1 = rec_const_prop(root);
        init_Lval();
        bool v2 = rec_const_fold(root);
        init_Lval();
        bool v3 = rec_if(root);

        cout<<i<<"-"<<v1<<" "<<v3<<" "<<v2<<"\n";
        if( v1==false && v2 == false && v3==false)
            break;
    
    }

    rec_strengthR(root);
    unused_var(root);
    write_summary();

}

bool rec_const_prop(node* root){
    if(root==NULL)  
        return false;
    
    bool ans = false;

   // printf("inside reccons\n");

    if(root->type=="assign_stmt"){

       // printf("inside assgn\n");

        node* id = root->children[0]->children[0];
        node* epr = root->children[0]->children[1];
        
        if(epr->noc==1 && epr->children[0]->type=="Pexpr"){
            node* pexp = epr->children[0];
            if(pexp->noc ==1 ){
                if(pexp->children[0]->type =="integerLit"){
                    Lupdate(id->children[0]->type,stoi(pexp->children[0]->children[0]->type));
                }
                else if(pexp->children[0]->type == "IDENTIFIER"){
                    string var = pexp->children[0]->children[0]->type;
                    int val = Lget(var);
                    if(val!=INT_MAX){
                        node* v = mk0(to_string(val)); v->line = epr->line;
                        node* int_v = mk1("integerLit",v ); int_v->line = epr->line;
                        pexp->children[0]= int_v;
                        insert_cprop(var,val,epr->line);
                        ans = true;
                    }
                    
                }
            }
            else if(pexp->noc == 3){
               return rec_prop_id(pexp->children[1]);
            }
        }
        else{
            return rec_prop_id(epr);
        }
    }
    else if(root->type=="scan_stmt"){
     //   printf("inside scan %s\n",root->children[0]->children[0]->type.c_str());
        node* id = root->children[0];
        Lupdate(id->children[0]->type,INT_MAX);
      //  printf("scan passed\n");
    }
    else if(root->type=="expr"){
       // printf("inside exp\n");
        return rec_prop_id(root);
    }
    else if( root->type == "print_stmt"){
        node* id = root->children[0];
        
        if(id->type == "IDENTIFIER" ){
           
            string var = id->children[0]->type;
            int val = Lget(var);
            if(val!=INT_MAX){
                node* v = mk0(to_string(val)); v->line = root->line;
                node* int_v = mk1("integerLit",v ); int_v->line = root->line;
                root->children[0]= int_v;
                insert_cprop(var,val,root->line);
                ans = true;
            }
          //  cout<<"print "<<id->children[0]->type<<" "<<val<<" "<<root->line<<"\n";
        }
    }
    else{
        //printf("inside not childs\n");
        for(int i=0;i<root->noc;i++){
            bool v2 =rec_const_prop(root->children[i]) ;
            ans = ans || v2;
        }

    }

    return ans;
}

bool rec_prop_id(node* expr){
    if(expr == NULL){
        return false;
    }
    
    bool ans = false;
    //cout<<"rec " <<expr->noc<<" "<<expr->children[0]->type<<"\n";
    if(expr->noc==1 && expr->children[0]->type!="Pexpr"){
        node* pexp1 = expr->children[0]->children[0];
        node* pexp2 = expr->children[0]->children[1];

        //cout<<expr->children[0]->type<<" ";
        if(pexp1->noc==3){
            bool v2 = rec_prop_id(pexp1->children[1]);
            ans = ans || v2;
        }
        else if(pexp1->noc==1 && pexp1->children[0]->type == "IDENTIFIER"){
            string var = pexp1->children[0]->children[0]->type;
           // cout<<var<<"\n";
            int val = Lget(var);
            if(val!=INT_MAX){
                node* v = mk0(to_string(val)); v->line = expr->line;
                node* int_v = mk1("integerLit",v ); int_v->line = expr->line;
                pexp1->children[0]= int_v;
                ans = true;

                insert_cprop(var,val,expr->line);   
            }
        }
        
        if(pexp2->noc==3){
           //n cout<<"inside p2 "<<pexp2->children[1]->type<<"\n";
            bool v2 = rec_prop_id(pexp2->children[1]);
            ans = ans || v2;
        }
        else if(pexp2->noc==1 && pexp2->children[0]->type == "IDENTIFIER"){
            string var = pexp2->children[0]->children[0]->type;
            int val = Lget(var);
            if(val!=INT_MAX){

                node* v = mk0(to_string(val)); v->line = expr->line;
                node* int_v = mk1("integerLit",v ); int_v->line = expr->line;
                pexp2->children[0]= int_v;
                ans = true;
                insert_cprop(var,val,expr->line);
            }

        }

    }
    else if(expr->noc == 2){
        node* pexp = expr->children[1];
        
        if(pexp->noc==3){
            bool v2 = rec_prop_id(pexp->children[1]);
            ans = ans || v2;
        }
        else if(pexp->noc==1 && pexp->children[0]->type == "IDENTIFIER"){
            int val = Lget(pexp->children[0]->children[0]->type);
            if(val!=INT_MAX){
                node* v = mk0(to_string(val)); v->line = expr->line;
                node* int_v = mk1("integerLit",v ); int_v->line = expr->line;
                pexp->children[0]= int_v;
                ans = true;
                insert_cprop(pexp->children[0]->children[0]->type,val,expr->line);
            }
        }
    }

    return ans;
}

bool rec_if(node* root){
    bool ans = false;

    if(root == NULL)
        return false;
    
    node* stm = NULL ;
    if(root->type == "stmt_list" && root->noc == 1)
        stm = root->children[0];
    else if(root->type == "stmt_list" && root->noc == 2)
        stm = root->children[1];

    
    
    if(stm!=NULL && stm->type == "stmt" && stm->children[0]->type== "if_stmt"){
        //cout<<stm->type<<"\n";
        if(stm->children[0]->noc == 5){
            node* expr = stm->children[0]->children[2];
            node* istm = stm->children[0]->children[4];

            cout<<"Here "<<static_compute(expr)<<"\n";
            if(static_compute(expr)==1){
                // true if
            }
            else if(static_compute(expr)==0) {
                if_smpl.push_back(0);
                stm->children[0]->asmd = true;
                
                add_deadcode(stm->children[0]);
                ans = true;
            }
          //  cout<<istm->children[0]->asmd<<"\n";

        }
        else if(stm->children[0]->noc == 7 ){
            node* expr = stm->children[0]->children[2];
            node* istm =  stm->children[0]->children[4];
            node* elst = stm->children[0]->children[6];

            //int d = static_compute(expr);
           // cout<<"Here "<<d<<"\n";
            if( static_compute(expr) ==1 ){
                //keep if

                add_deadcode(elst);
                add_deadcode(expr);

                if(root->noc==1)
                    root->children[0] = istm;
                else if(root->noc==2)
                    root->children[1] = istm;

                if_smpl.push_back(1);
                
                ans = true;
            }else if(static_compute(expr)==0){
                //keep else
                add_deadcode(expr);
                add_deadcode(istm);

                if(root->noc==1)
                    root->children[0] = elst;
                else if(root->noc==2)
                    root->children[1] = elst;

                if_smpl.push_back(0);

                ans = true;
            }

        }
    }
    else if(root->type=="assign_stmt"){
        node* id = root->children[0]->children[0];
        node* epr = root->children[0]->children[1];
        
        if(epr->noc==1 && epr->children[0]->type=="Pexpr"){
            node* pexp = epr->children[0];
            if(pexp->noc ==1 ){
                if(pexp->children[0]->type =="integerLit"){
                    Lupdate(id->children[0]->type,stoi(pexp->children[0]->children[0]->type));
                }
            }
        }
    }
    else{
        
        for(int i=0;i<root->noc;i++){
            bool v2 = rec_if(root->children[i]);
            ans = ans || v2;
        }
    }

    return ans;
}

//for if 
int static_compute(node* expr){
    if(expr==NULL){
        // cout<<"null";
        return -1;
    }
        
    
    int ans = -1;

    //cout<<"inside st "<<expr->type<<"\n";

    if(expr->noc==1 && expr->children[0]->type=="Pexpr"){
        node* pexp = expr->children[0];
      //  cout<<"inside static pexpr\n";
        if(pexp->noc==1){
            if(pexp->children[0]->type == "IDENTIFIER"){
                int val = Lget(pexp->children[0]->children[0]->type);
                if( val != INT_MAX ){
                    if(val>0) return 1;
                    else return 0;
                }
            }
            else if( pexp->children[0]->type == "integerLit"){
                int val = stoi(pexp->children[0]->children[0]->type);
                if(val>0)
                    return 1;
                else
                    return 0;
            }

        }else if( pexp->noc == 3){
            return static_compute(pexp->children[1]);
        }

    }
    else if(expr->noc==1 && expr->children[0]->type!="Pexpr"){
            
            node* pexp1 = expr->children[0]->children[0];
            node* pexp2 = expr->children[0]->children[1];
            int val1,val2;
            if(pexp1->children[0]->type == "IDENTIFIER"){
                val1 = Lget(pexp1->children[0]->children[0]->type);
            }
            else if( pexp1->children[0]->type == "integerLit"){
                val1 = stoi(pexp1->children[0]->children[0]->type);
            }

            if(pexp2->children[0]->type == "IDENTIFIER"){
                val2 = Lget(pexp2->children[0]->children[0]->type);
            }
            else if( pexp2->children[0]->type == "integerLit"){
                val2 = stoi(pexp2->children[0]->children[0]->type);
            }

            //try to eval x logic y
            if(expr->children[0]->type=="&&"){
                return -1;
            }
            else if(expr->children[0]->type=="||"){    
                return -1;
            }
            else if(expr->children[0]->type==">"){
            //    cout<<val1<<" "<<val2<<"\n";
                if(val1 != INT_MAX && val2!=INT_MAX)
                    return val1>val2;
                else
                    return -1;
            }
            else if(expr->children[0]->type=="<"){
                if(val1 != INT_MAX && val2!=INT_MAX)
                    return val1 < val2;
                else
                    return -1;
            }
            else if(expr->children[0]->type==">="){
                if(val1 != INT_MAX && val2!=INT_MAX)
                    return val1>=val2;
                else
                    return -1;
            }
            else if(expr->children[0]->type=="<="){
                if(val1 != INT_MAX && val2!=INT_MAX)
                    return val1<=val2;
                else
                    return -1;
            }
            else if(expr->children[0]->type=="=="){
                if(val1 != INT_MAX && val2!=INT_MAX)
                    return val1==val2;
                else
                    return -1;
            }

    }

    return ans;

}

void insert_cprop(string var,int val,int line){
    pair<string,int> pr; pr.first = var; pr.second=val;
    map<int,vector< pair<string,int> > >::iterator it;
    it = CProp.find(line);
    if(it==CProp.end()){
        vector< pair<string,int> > vec;
        vec.push_back(pr);
        CProp.insert( pair<int,vector< pair<string,int> > >(line,vec));
    }
    else{
        bool found = false;
        for(int i=0;i<(*it).second.size();i++){
            pair<string,int> t = (*it).second[i];
            if(t.first == pr.first ){
                (*it).second[i].second = pr.second;
                found = true;
                break;
            }
        }
        if(found==false){
            (*it).second.push_back(pr);
        }
    }
}


//const fold for exp
bool rec_const_fold(node* root){
    if(root==NULL)
        return false;
    
    if(root->type== "expr"){
        int val = const_fold_exp(root);
        if(val != INT_MAX){
            map<int,int>::iterator itr;
            itr = ConstantFold.find(root->line);
            if(itr==ConstantFold.end())
                ConstantFold.insert(pair<int,int>(root->line,val));
            else
                itr->second = val;

            return true;
        }    
        else 
            return false;
    }
    else{
        bool ans=false;
        for(int i=0;i<root->noc;i++){
            bool v2 =rec_const_fold(root->children[i]) ;
            ans = ans || v2;
        }

        return ans;   
    }
        
}

//fold for exp
int const_fold_exp(node* root){
    int ans = INT_MAX;
    if(root->type == "expr" ){
        if( root->noc == 1 ){
            node* op = root->children[0];
            
            if( op->type=="+"){
                node* pexp1 = op->children[0];
                node* pexp2 = op->children[1]; 
                int lf = INT_MAX,rf =INT_MAX;
                if(pexp1->noc==3){
                    lf =  const_fold_exp(pexp1->children[1]);
                    if(lf!=INT_MAX){
                        ans = lf;
                        pexp1->children[0] = pexp1->children[1]->children[0]->children[0];
                        pexp1->noc=1;
                    }
                }

                if( pexp2->noc == 3){
                    rf =  const_fold_exp(pexp2->children[1]);
                    if(rf!= INT_MAX){
                        ans = rf;
                        pexp2->children[0] = pexp2->children[1]->children[0]->children[0];
                        pexp2->noc=1;
                    }
                }

               // printf("in expr %d %d\n",lf,rf);

                // if(lf!=INT_MAX && rf!=INT_MAX)
                //     cout<<pexp1->children[0]->type<<" "<< pexp2->children[0]->type<<"\n";

                if(pexp1->children[0]->type == "integerLit" && pexp2->children[0]->type== "integerLit" ){
                    int a = stoi(pexp1->children[0]->children[0]->type);
                    int b = stoi(pexp2->children[0]->children[0]->type);
                    int c = a + b;
                    int ln = root->line;
                    node* val = mk0(to_string(c)); val->line = ln;
                    node* node_int = mk1("integerLit",val ); node_int->line = ln;
                    node* pexp = mk1("Pexpr", node_int); pexp->line = ln;
                    root->children[0] = pexp;
                    ans = c;
                   // printf("in prop %d + %d = %d\n",a,b,c);
                }
            }
            else if(op->type=="-"){
                node* pexp1 = op->children[0];
                node* pexp2 = op->children[1]; 
                int lf = INT_MAX,rf =INT_MAX;
                if(pexp1->noc==3){
                    lf =  const_fold_exp(pexp1->children[1]);
                    if(lf!=INT_MAX){
                        ans = lf;
                        pexp1->children[0] = pexp1->children[1]->children[0]->children[0];
                        pexp1->noc=1;
                    }
                }

                if( pexp2->noc == 3){
                    rf =  const_fold_exp(pexp2->children[1]);
                    if(rf!= INT_MAX){
                        ans = rf;
                        pexp2->children[0] = pexp2->children[1]->children[0]->children[0];
                        pexp2->noc=1;
                    }
                }

                if(pexp1->children[0]->type == "integerLit" && pexp2->children[0]->type== "integerLit" ){
                    int a = stoi(pexp1->children[0]->children[0]->type);
                    int b = stoi(pexp2->children[0]->children[0]->type);
                    int c = a - b;
                    int ln = root->line;
                    node* val = mk0(to_string(c)); val->line = ln;
                    node* node_int = mk1("integerLit",val ); node_int->line = ln;
                    node* pexp = mk1("Pexpr", node_int); pexp->line = ln;
                    root->children[0] = pexp;
                    ans = c;
                }
            }
            else if(op->type=="*"){
                node* pexp1 = op->children[0];
                node* pexp2 = op->children[1]; 
                int lf = INT_MAX,rf =INT_MAX;
                if(pexp1->noc==3){
                    lf =  const_fold_exp(pexp1->children[1]);
                    if(lf!=INT_MAX){
                        ans = lf;
                        pexp1->children[0] = pexp1->children[1]->children[0]->children[0];
                        pexp1->noc=1;
                    }
                }

                if( pexp2->noc == 3){
                    rf =  const_fold_exp(pexp2->children[1]);
                    if(rf!= INT_MAX){
                        ans = rf;
                        pexp2->children[0] = pexp2->children[1]->children[0]->children[0];
                        pexp2->noc=1;
                    }
                }
                if(pexp1->children[0]->type == "integerLit" && pexp2->children[0]->type== "integerLit" ){
                    int a = stoi(pexp1->children[0]->children[0]->type);
                    int b = stoi(pexp2->children[0]->children[0]->type);
                    int c = a * b;
                    int ln = root->line;
                    node* val = mk0(to_string(c)); val->line = ln;
                    node* node_int = mk1("integerLit",val ); node_int->line = ln;
                    node* pexp = mk1("Pexpr", node_int); pexp->line = ln;
                    root->children[0] = pexp;
                    ans = c;
                }
            
            }
            else if(op->type=="Pexpr" && op->noc == 3){
                int rval = const_fold_exp(op->children[1]);
                if(rval!=INT_MAX){
                    op->children[0]= op->children[1]->children[0]->children[0];
                    op->noc = 1;
                }
                return rval;
            }
            return ans;
        }
    }
    return ans;
}


//after all optimisations
void unused_var_rec(node* root){
    if(root==NULL)
        return ;

    if(root->type=="assign_stmt"){
        node* id = root->children[0]->children[0];
        node* epr = root->children[0]->children[1];
        
        if(epr->noc==1 && epr->children[0]->type=="Pexpr"){
            node* pexp = epr->children[0];
            if(pexp->noc ==1 ){
                if(pexp->children[0]->type =="integerLit"){
                    Lupdate(id->children[0]->type,stoi(pexp->children[0]->children[0]->type));
                }
            }
        }
    }
    else if(root->type=="scan_stmt"){
        node* id = root->children[0];
        Lupdate(id->children[0]->type,INT_MAX);
      //  printf("scan passed\n");
    }
    else{
        for(int i=0;i<root->noc;i++){
            unused_var_rec(root->children[i]);
        }
    }
}

bool unused_var(node* root){
    bool ans = false;
    init_Lval();
    unused_var_rec(root);
    

    for(int i=0;i<Lvar.size();i++){
        if(Lstate[i]== -1){
            if(Lvar[i].size()!=0){
                unused.push_back(i);
                ans = true;
            }
        }
    }

    return ans;

}


void Lupdate( string var,int val){
  //  printf("inside Lupd\n");
    for(int i=0;i<Lvar.size();i++){
        if(Lvar[i]==var){
            if(val!=INT_MAX){
                Lval[i]=val;
                Lstate[i]=1;
            }else{
                Lstate[i]=0;        //scanf
            }
          //  printf("update %s %d\n",var.c_str(),val);
        }
    }
}

int Lget(string var){
    for(int i=0;i<Lvar.size();i++){
        if(Lvar[i]==var){
            if(Lstate[i]==1)
                return Lval[i];
            else    
                return INT_MAX;
        }
    }
}


void add_deadcode(node* root){
    if(root==NULL)
        return;
    
    removedLine.insert(root->line);
    for(int i=0;i<root->noc;i++)
        add_deadcode(root->children[i]);

}


void rm_dead_opt(){
   
    for(auto sitr = removedLine.begin();sitr!=removedLine.end();sitr++){
        map<int,int>::iterator cfit;
        cfit = ConstantFold.find(*sitr);
        if(cfit!= ConstantFold.end()){
            ConstantFold.erase(cfit);
        }

        map<int, vector< pair<string,int> > > ::iterator cpit;
        cpit = CProp.find(*sitr);
        if(cpit!=CProp.end()){
            CProp.erase(cpit);
        }

        //add strenth map
    }
}

void write_summary(){

    rm_dead_opt();

    fprintf(smmry,"unused-vars\n");
    for(int i=0;i<unused.size();i++){
        fprintf(smmry,"%s\n",Lvar[unused[i]].c_str());
    }
    fprintf(smmry,"\nif-simpl\n");
    for(int i=0;i<if_smpl.size();i++)
        fprintf(smmry,"%d\n",if_smpl[i]);
    
    fprintf(smmry,"\nstrength-reduction\n");
    for(auto it=mstrengthR.begin();it!=mstrengthR.end();it++){
        fprintf(smmry,"%d %d\n",it->first,it->second);
    }

    fprintf(smmry,"\nconstant-folding\n");
    for(auto it= ConstantFold.begin();it!=ConstantFold.end();it++){
        fprintf(smmry,"%d %d\n",it->first,it->second);
    }

    fprintf(smmry,"\nconstant-propagation\n");
    for(auto it= CProp.begin();it!=CProp.end();it++){
        
        fprintf(smmry,"%d ",it->first);
        for(int i =0;i< it->second.size();i++){
            pair<string,int> p = it->second[i];
            fprintf(smmry,"%s %d ",p.first.c_str(),p.second);
        }

        fprintf(smmry,"\n");
       
     }

     fprintf(smmry,"\ncse\n");
     //add here
}

int get_powr2(int val){
    int ans =-1;
    int p = 1;
    for(int i=0;i<=10;i++){
        if(p == val){
            ans = i;
            break;
        }
        p= 2*p;
    }
    return ans;
}

void insert_pow(int lineNo,int val){
    map<int,int>::iterator it;
    it = mstrengthR.find(lineNo);
    if( it== mstrengthR.end()){
        mstrengthR.insert( pair<int,int>(lineNo,val) );
    }
    else{
        if(val > it->second){
            it->second = val;
        }
    }
}


void rec_strengthR(node* root){
    if(root==NULL)
        return ;
    
    if(root->type=="expr" && root->noc ==1){
        if(root->children[0]->type=="*"){
            node* pexp1 = root->children[0]->children[0];
            node* pexp2 = root->children[0]->children[1];

            if(pexp1->noc==3){
                rec_strengthR(pexp1->children[1]);
            }
            
            if( pexp2->noc == 3){
                rec_strengthR(pexp2->children[1]);
            }

            if(pexp1->noc==1 and pexp2->noc==1){
                //cout<<pexp1->children[0]->children[0]->type<<" "<<pexp2->children[0]->children[0]->type<<"\n";
                if(pexp1->children[0]->type =="IDENTIFIER" && pexp2->children[0]->type== "integerLit"){
                    int val = get_powr2(stoi(pexp2->children[0]->children[0]->type));
                    if(val!=-1){
                        pexp2->children[0]->children[0]->type = to_string(val);
                        root->children[0]->type = "^^";
                        insert_pow(root->line,val);
                    }
                }
                else if(pexp1->children[0]->type == "integerLit" && pexp2->children[0]->type== "IDENTIFIER"){
                    int val = get_powr2(stoi(pexp1->children[0]->children[0]->type));
                    if(val!=-1){
                        pexp1->children[0]->children[0]->type = to_string(val);
                        root->children[0]->type = "^^";
                        insert_pow(root->line,val);
                    }
                }
            }
        }
        else{
            for(int i=0;i<root->noc;i++){
                rec_strengthR(root->children[i]);
            }
        }
    }
    else{
        for(int i=0;i<root->noc;i++){
            rec_strengthR(root->children[i]);
        }
    }

}




void getexp(node* root) {
    if(root == NULL)
        return;

    for(int i=0;i<root->noc;i++)
        getexp(root->children[i]);

    if(root->type == "IDENTIFIER" && !root->asmd) {
        fprintf(assm,"\tmovl -%d(%%rbp),%%ecx\n\tpushq %%rcx\n",loc[currfun][root->children[0]->type]);
        root->asmd = true;
    }
    //add for function call
    else if(root->type == "integerLit") {
        fprintf(assm,"\tmovl $%d,%%ecx\n\tpushq %%rcx\n",stoi(root->children[0]->type));
    }
    else if(root->type == "floatLit") {
        fprintf(assm,"\tmovl $%d,%%ecx\n\tpushq %%rcx\n",stoi(root->children[0]->type));
    }
    else if(root->type == "+" && root->noc == 2) {
        fprintf(assm,"\tpopq %%rbx\n\tpopq %%rcx\n\taddl %%ebx, %%ecx\n\tpushq %%rcx\n");
    }
    else if(root->type == "-" && root->noc == 2) {
        fprintf(assm,"\tpopq %%rbx\n\tpopq %%rcx\n\tsubl %%ebx, %%ecx\n\tpushq %%rcx\n");
    }
    else if(root->type == "*" && root->noc == 2) {
        fprintf(assm,"\tpopq %%rbx\n\tpopq %%rcx\n\timull %%ebx, %%ecx\n\tpushq %%rcx\n");
    }
    else if(root->type == "^^" && root->noc == 2) {
        node* pexp1 = root->children[0];
        node* pexp2 = root->children[1];
        if(pexp1->children[0]->type == "IDENTIFIER" && pexp2->children[0]->type == "integerLit" ){
            int powr = stoi(pexp2->children[0]->children[0]->type);
            fprintf(assm,"\tpopq %%rbx\n\tpopq %%rcx\n\tsall $%d, %%ecx\n\tpushq %%rcx\n",powr);
        }
        else if(pexp2->children[0]->type == "IDENTIFIER" && pexp1->children[0]->type == "integerLit" ){
            int powr = stoi(pexp1->children[0]->children[0]->type);
            fprintf(assm,"\tpopq %%rbx\n\tpopq %%rcx\n\tsall $%d, %%ebx\n\tpushq %%rcx\n",powr);
        }
    }
    else if(root->type == "/") {
        fprintf(assm,"\tpopq %%rcx\n\tpopq %%rax\n\tcltd\n\tidivl %%ecx\n\tpushq %%rax\n");
    }
    else if(root->type == "%%") {
        fprintf(assm,"\tpopq %%rcx\n\tpopq %%rax\n\tcltd\n\tidivl %%ecx\n\tpushq %%rdx\n");
    }
    else if(root->type == "||") {
        string l1 = getlabel();
        string l2 = getlabel();
        string l3 = getlabel();
        string out = "\tpopq %rax\n\tpopq %rbx\n\tcmpl $0,%eax\n\tjne "+l1+"\n\tcmpl $0,%ebx\n\tje "+l2+"\n"+l1+":\n\tmovl $1,%eax\n\tjmp "+l3+"\n"+l2+":\n\tmovl $0,%eax\n"+l3+":\n\tpushq %rax\n";
        fprintf(assm," %s ",out.c_str());
    }
    else if(root->type == "&&") {
        string l1 = getlabel();
        string l2 = getlabel();
        string out = "\tpopq %rax\n\tpopq %rbx\n\tcmpl $0,%ebx\n\tje "+l1+"\n\tcmpl $0,%eax\n\tje "+l1+"\n\tmovl $1,%eax\n\tjmp "+l2+"\n"+l1+":\n\tmovl $0,%eax\n"+l2+":\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == "==") {
        string out = "\tpopq %rax\n\tpopq %rbx\n\tcmpl %eax,%ebx\n\tsete %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == "!=") {
        string out = "\tpopq %rax\n\tpopq %rbx\n\tcmpl %eax,%ebx\n\tsetne %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == "<=") {
        string out ="\tpopq %rax\n\tpopq %rbx\n\tcmpl %eax,%ebx\n\tsetle %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == "<") {
        string out ="\tpopq %rax\n\tpopq %rbx\n\tcmpl %eax,%ebx\n\tsetl %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == ">=") {
        string out ="\tpopq %rax\n\tpopq %rbx\n\tcmpl %eax,%ebx\n\tsetge %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == ">") {
        string out = "\tpopq %rax\n\tpopq %rbx\n\tcmpl %eax,%ebx\n\tsetg %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == "expr" && root->children[0]->type == "!") {
        getasm(root->children[1]);
        string out ="\tpopq %rbx\n\tcmpl $0,%ebx\n\tsete %al\n\tmovzbl %al,%eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
    else if(root->type == "expr" && root->children[0]->type == "-" && root->children[0]->noc == 0) {
        getasm(root->children[1]);
        string out ="\tpopq %rax\n\tnegl %eax\n\tpushq %rax\n";
        fprintf(assm,"%s",out.c_str());
    }
}

void getasm(node* root) {
    if(root == NULL)
        return;

    if(root->type == "if_stmt" && root->asmd==true) {
        return;
    }


    if(root->type == "if_stmt" && !root->asmd) {
        root->asmd = true;
        if(root->noc == 5) {
            getexp(root->children[2]);
            string l1 = getlabel();
            string out= "\tpopq %rax\n\tcmpl $0, %eax\n\tje "+ l1+ "\n";
            fprintf(assm,"%s",out.c_str());
            getasm(root->children[4]);
            fprintf(assm,"%s:\n", l1.c_str());
        }
        else if(root->noc == 7) {
            getexp(root->children[2]);
            string l1 = getlabel();
            string l2 = getlabel();
            string out = "\tpopq %rax\n\tcmpl $0, %eax\n\tje "+ l1 + "\n";
            fprintf(assm,"%s",out.c_str());
            getasm(root->children[4]);
            fprintf(assm,"\tjmp %s\n%s:\n",l2.c_str(),l1.c_str());
            getasm(root->children[6]);
            fprintf(assm,"%s:\n",l2.c_str());
        }
    }
    else if(root->type == "while_stmt" && !root->asmd) {
        root->asmd = true;
        string l1 = getlabel();
        string l2 = getlabel();
        fprintf(assm,"%s:\n",l1.c_str());
        getexp(root->children[2]);
        string out = "\tpopq %rax\n\tcmpl $0, %eax\n\tje " + l2 + "\n";
        fprintf(assm,"%s",out.c_str());
        getasm(root->children[4]);
        fprintf(assm,"jmp %s\n%s:\n",l1.c_str(),l2.c_str());
    }
    // else if(root->type == "func_decl" && !root->asmd) {
    //     root->asmd = true;
    //     currfun = root->children[1]->children[0]->type;

    //     cout << currfun << ":\n";
    //     printf("\t.cfi_startproc\n\tpushq %%rbp\n\t.cfi_def_cfa_offset 16\n\t.cfi_offset 6, -16\n\tmovq %%rsp, %%rbp\n\t.cfi_def_cfa_register 6\n\t");
    //     getasm(root->children[3]);
    //     getasm(root->children[5]);
    //     printf("\t.cfi_def_cfa 7, 8\n\tret\n\t.cfi_endproc\n");
    // }

    for(int i=0;i<root->noc;i++)
        getasm(root->children[i]);

    if(root->type == "print_stmt" && !root->asmd) {
        root->asmd = true;
        if(root->children[0]->type== "IDENTIFIER"){
            int addr = loc[currfun][root->children[0]->children[0]->type];
            fprintf(assm,"\tmovl -%d(%%rbp), %%eax\n\tmovl %%eax, %%esi\n\tleaq    .LC0(%%rip), %%rdi\n\tmovl $0, %%eax\n\tcall printf@PLT\n",addr);      
        }
        else if(root->children[0]->type== "integerLit"){
            int val = stoi(root->children[0]->children[0]->type);
            fprintf(assm,"\tmovl $%d, %%eax\n\tmovl %%eax, %%esi\n\tleaq    .LC0(%%rip), %%rdi\n\tmovl $0, %%eax\n\tcall printf@PLT\n",val);      
        }
    }
    else if( root->type == "scan_stmt" && !root->asmd){
        root->asmd = true;
        int addr = loc[currfun][root->children[0]->children[0]->type];
        fprintf(assm,"\tleaq -%d(%%rbp), %%rax\n\tmovq %%rax, %%rsi\n\tmovl $.LC1, %%edi\n\tmovl $0, %%eax\n\t call scanf\n",addr);
    }
    else if(root->type == "=" && !root->asmd) {
        root->asmd = true;
        getexp(root->children[1]);
        //cout << exp;
        fprintf(assm,"\tpopq %%rbx\n\tmovl %%ebx, -%d(%%rbp)\n",loc[currfun][root->children[0]->children[0]->type]);
    }
    // else if(root->type == "return_stmt" && !root->asmd) {
    //     root->asmd = true;
    //     if(root->noc != 2) {
    //         getexp(root->children[1]);
    //     }
    // }
    // else if(root->type == "param" && !root->asmd) {
    //     root->asmd = true;
    //     printf("\tpopq %%rax\n\tmovl %%eax,-%d(rbp)\n",loc[currfun][root->children[1]->children[0]->type]);
    // }

}

node* mk0(string t) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->noc = 0;
    newnode->line = LineNo;
    return newnode;
}

node* mk1(string t, node* one) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->noc = 1;
    newnode->line = LineNo;
    return newnode;
}

node* mk2(string t, node* one, node* two) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->children[1] = two;
    newnode->noc = 2;
    newnode->line = LineNo;
    return newnode;
}

node* mk3(string t, node* one, node* two, node* three) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->children[1] = two;
    newnode->children[2] = three;
    newnode->noc = 3;
    newnode->line = LineNo;
    return newnode;
}

node* mk4(string t, node* one, node* two, node* three, node* four) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->children[1] = two;
    newnode->children[2] = three;
    newnode->children[3] = four;
    newnode->noc = 4;
    newnode->line = LineNo;
    return newnode;
}

node* mk5(string t, node* one, node* two, node* three, node* four, node* five) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->children[1] = two;
    newnode->children[2] = three;
    newnode->children[3] = four;
    newnode->children[4] = five;
    newnode->noc = 5;
    newnode->line = LineNo;
    return newnode;
}

node* mk6(string t, node* one, node* two, node* three, node* four, node* five, node* six) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->children[1] = two;
    newnode->children[2] = three;
    newnode->children[3] = four;
    newnode->children[4] = five;
    newnode->children[5] = six;
    newnode->noc = 6;
    newnode->line = LineNo;
    return newnode;
}

node* mk7(string t, node* one, node* two, node* three, node* four, node* five, node* six, node* seven) {
    node* newnode = new node;
    
    newnode->type = t;
    
    newnode->children[0] = one;
    newnode->children[1] = two;
    newnode->children[2] = three;
    newnode->children[3] = four;
    newnode->children[4] = five;
    newnode->children[5] = six;
    newnode->children[6] = seven;
    newnode->noc = 7;
    newnode->line = LineNo;
    return newnode;
}


void freenodes(node* root) {
    if(root->noc == 0) {
        free(root); 
        return;
    }
    int i;
    for(int i = 0; i < root->noc; i++)
        free(root->children[i]);
    free(root);
}

string getlabel() {
    return (".L" + to_string(ctr++)); 
}

void init_Lval(){

    if(Lval.size()==0 && Lstate.size()==0){

        for(int i=0;i<Lvar.size();i++){
            Lval.push_back(INT_MAX);
            Lstate.push_back(-1);
            //unint
        }
    }
    else{
        for(int i=0;i<Lvar.size();i++){
            Lval[i]=INT_MAX;
            Lstate[i] = -1;
            //unint
        }

    }
}


// void printtree(node* root) {
//     nn++;
//     printf("%s--->",root->type);
//     for(int i=0;i<root->noc;i++)
//         printf("(%i~~%s)    ",i,root->children[i]->type);
//     printf("\n\n\n");
//     for(int i=0;i<root->noc;i++)
//         printtree(root->children[i]);
// }
