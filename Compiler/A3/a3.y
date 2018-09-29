%token FLOAT_LITERAL INTEGER_LITERAL INT RETURN BREAK CONT VOID FLOAT WHILE IF PRINTF FORMAT
%token IDENTIFIER ELSE OR EQ NEQ LEQ GEQ AND
//%type 	program decl_list decl var_decl type_spec func_decl params param_list
//%type 	param stmt_list stmt while_stmt compound_stmt local_decls local_decl
//%type 	if_stmt return_stmt break_stmt continue_stmt assign_stmt expr Pexpr
//%type 	integerLit floatLit identifier arg_list args

%start program 

%{
	#include <stdio.h>
	#include <bits/stdc++.h>
	using namespace std;
	typedef struct node
	{
		int h1,h2,max_path,mainflag;
		char name[50];
		int size;
		struct node* child[10];
	}node;	
	int ifmax = 0,whmax =0,mainmax = 0;
	extern char* yytext;
	void DFS(node *root);
	node* root = NULL;
	node *mknode0(int s);
	node *mknode1(int s,node* c1);
	node *mknode2(int s,node *c1,node *c2);
	node *mknode3(int s,node *c1,node *c2,node *c3);
	node *mknode4(int s,node *c1,node *c2,node *c3,node *c4);
	node *mknode5(int s,node *c1,node *c2,node *c3,node *c4,node *c5);
	node *mknode6(int s,node *c1,node *c2,node *c3,node *c4,node *c5,node *c6);
	node *mknode7(int s,node *c1,node *c2,node *c3,node* c4,node *c5,node *c6,node *c7);
	void yyerror(string);
	int yylex(void);

	typedef struct SymbolTable{
		char* var[1000];
		int len;
	} Table;

	
	void genAssembly(node* root);

	int aveax=1;
	int avedx=1;
	int avebx=1;

	char REAX[10]= "%eax";
	char REDX[10]= "%edx";
	char REBX[10]= "%ebx";

	int labelNo = 2;


#define YYSTYPE struct node *
%}

%%

program:
	decl_list
	{
		$$ = mknode1(1,$1);
		root = $$;
		strcpy($$->name,"program");
	};

decl_list:
	decl_list decl
	{
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"decl_list");
	}
|	decl
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"decl_list");
	};

decl:
	var_decl
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"decl");
	}
|	func_decl
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"decl");
	};

var_decl:
	type_spec identifier ';'
	{
		$3 = mknode0(0);
		strcpy($3->name,";");
		$$ = mknode3(3,$1,$2,$3);
		strcpy($$->name,"var_decl");
	}
|	type_spec identifier ',' var_decl
	{
		$3 = mknode0(0);
		strcpy($3->name,";");
		$$ = mknode4(4,$1,$2,$3,$4);
		strcpy($$->name,"var_decl");
	}
|	type_spec identifier '[' integerLit ']' ';'
	{
		$3 = mknode0(0);
		strcpy($3->name,"[");
		$5 = mknode0(0);
		strcpy($5->name,"]");
		$6 = mknode0(0);
		strcpy($6->name,";");
		$$ = mknode6(6,$1,$2,$3,$4,$5,$6);
		strcpy($$->name,"var_decl");
	}
|	type_spec identifier '[' integerLit ']' ',' var_decl
	{
		$3 = mknode0(0);
		strcpy($3->name,"[");
		$5 = mknode0(0);
		strcpy($5->name,"]");
		$6 = mknode0(0);
		strcpy($6->name,",");
		$$ = mknode7(7,$1,$2,$3,$4,$5,$6,$7);
		strcpy($$->name,"var_decl");
	};

type_spec:
	VOID
	{
		$1 = mknode0(0);
		strcpy($1->name,"VOID");
		$$ = mknode1(1,$1);
		strcpy($$->name,"type_spec");
	}
|	INT
	{
		$1 = mknode0(0);
		strcpy($1->name,"INT");
		$$ = mknode1(1,$1);
		strcpy($$->name,"type_spec");
	}	
|	FLOAT
	{
		$1 = mknode0(0);
		strcpy($1->name,"FLOAT");
		$$ = mknode1(1,$1);
		strcpy($$->name,"type_spec");
	}
|	VOID '*'
	{
		$1 = mknode0(0);
		strcpy($1->name,"VOID");
		$2 = mknode0(0);
		strcpy($2->name,"*");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"type_spec");
	}
|	INT '*'
	{
		$1 = mknode0(0);
		strcpy($1->name,"INT");
		$2 = mknode0(0);
		strcpy($2->name,"*");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"type_spec");
	}
|	FLOAT '*'
	{
		$1 = mknode0(0);
		strcpy($1->name,"FLOAT");
		$2 = mknode0(0);
		strcpy($2->name,"*");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"type_spec");
	};

func_decl:
	type_spec identifier '(' params ')' compound_stmt
	{
		$3 = mknode0(0);
		strcpy($3->name,"(");
		$5 = mknode0(0);
		strcpy($5->name,")");
		$$= mknode6(6,$1,$2,$3,$4,$5,$6);
		strcpy($$->name,"func_decl");
	};

params:
	param_list
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"params");
	}
|	{
		$$ = mknode0(1);
		strcpy($$->name,"params");
	};

param_list:
	param_list ',' param
	{
		$2 = mknode0(0);
		strcpy($2->name,",");
		$$ = mknode3(3,$1,$2,$3);
		strcpy($$->name,"param_list");
	}
|	param
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"param_list");
	};

param:
	type_spec identifier
	{
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"param");
	}
|	type_spec identifier '[' ']' 
	{
		$3 = mknode0(0);
		strcpy($3->name,"[");
		$4 = mknode0(0);
		strcpy($4->name,"]");
		$$ = mknode4(4,$1,$2,$3,$4);
		strcpy($$->name,"param");
	};

stmt_list:
	stmt_list stmt
	{
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"stmt_list");
	}
|	stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt_list");
	};

stmt:
	assign_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|	compound_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|	if_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|	while_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|	return_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|	break_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|	continue_stmt
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	}
|  print_stmt
   {
		$$ = mknode1(1,$1);
		strcpy($$->name,"stmt");
	};


print_stmt : PRINTF '(' format_spec ',' identifier ')' ';'
            {
                $1=mknode0(0);
                strcpy($1->name,"printf");
                $$=mknode2(2,$1,$5);
                strcpy($$->name,"print_stmt");
            }
        ;

format_spec : FORMAT 
            {
                $$=mknode0(0);
                strcpy($$->name,"format");
            }
            ;

while_stmt:
	WHILE '(' expr ')' stmt
	{
		$1 = mknode0(0);
		strcpy($1->name,"WHILE");
		$2 = mknode0(0);
		strcpy($2->name,"(");
		$4 = mknode0(0);
		strcpy($4->name,")");
		$$ = mknode5(5,$1,$2,$3,$4,$5);
		strcpy($$->name,"while_stmt");
	};

compound_stmt:
	'{' local_decls stmt_list '}'
	{
		$1 = mknode0(0);
		strcpy($1->name,"{");
		$4 = mknode0(0);
		strcpy($4->name,"}");
		$$ = mknode4(4,$1,$2,$3,$4);
		strcpy($$->name,"compound_stmt");
	};

local_decls:
	local_decls local_decl
	{
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"local_decls");
	}
|	{
		$$ = mknode0(1);
		strcpy($$->name,"local_decls");
	};

local_decl:
	type_spec identifier ';'
	{
		$3 = mknode0(0);
		strcpy($3->name,";");
		$$ = mknode3(3,$1,$2,$3);
		strcpy($$->name,"local_decl");
	}
|	type_spec identifier '[' expr ']' ';'
	{
		$3 = mknode0(0);
		strcpy($3->name,"[");
		$5 = mknode0(0);
		strcpy($5->name,"]");
		$6 = mknode0(0);
		strcpy($6->name,";");
		$$ = mknode6(6,$1,$2,$3,$4,$5,$6);
		strcpy($$->name,"local_decl");
	};

if_stmt:
	IF '(' expr ')' stmt
	{
		$1 = mknode0(0);
		strcpy($1->name,"IF");
		$2 = mknode0(0);
		strcpy($2->name,"(");
		$4 = mknode0(0);
		strcpy($4->name,")");
		$$ = mknode5(5,$1,$2,$3,$4,$5);
		strcpy($$->name,"if_stmt");
	}
|	IF '(' expr ')' stmt ELSE stmt
	{
		$1 = mknode0(0);
		strcpy($1->name,"IF");
		$2 = mknode0(0);
		strcpy($2->name,"(");
		$4 = mknode0(0);
		strcpy($4->name,")");
		$6 = mknode0(0);
		strcpy($6->name,"ELSE");
		$$ = mknode7(7,$1,$2,$3,$4,$5,$6,$7);
		strcpy($$->name,"if_stmt");
	};

return_stmt:
	RETURN ';'
	{
		$1 = mknode0(0);
		strcpy($1->name,"RETURN");
		$2 = mknode0(0);
		strcpy($2->name,";");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"return_stmt");
	}
|	RETURN expr ';'
	{
		$1 = mknode0(0);
		strcpy($1->name,"RETURN");
		$3 = mknode0(0);
		strcpy($3->name,";");
		$$ = mknode3(3,$1,$2,$3);
		strcpy($$->name,"return_stmt");
	};

break_stmt:
	BREAK ';'
	{
		$1 = mknode0(0);
		strcpy($1->name,"BREAK");
		$2 = mknode0(0);
		strcpy($2->name,";");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"break_stmt");
	};

continue_stmt:
	CONT ';'
	{
		$1 = mknode0(0);
		strcpy($1->name,"CONT");
		$2 = mknode0(0);
		strcpy($2->name,";");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"continue_stmt");
	};

assign_stmt:
	identifier '=' expr ';'
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"=");
		$4 = mknode0(0);
		strcpy($4->name,";");
		$$ = mknode2(2,$2,$4);
		strcpy($$->name,"assign_stmt");
	}
|	identifier '[' expr ']' '=' expr ';'
	{
		$2 = mknode0(0);
		strcpy($2->name,"[");
		$4 = mknode0(0);
		strcpy($4->name,"]");
		$7 = mknode0(0);
		strcpy($7->name,";");
		$5 = mknode5(5,$1,$2,$3,$4,$6);
		strcpy($5->name,"=");
		$$ = mknode2(2,$5,$7);
		strcpy($$->name,"assign_stmt");
	};

expr:
	Pexpr OR Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"OR");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr EQ Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"EQ");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr NEQ Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"NEQ");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr LEQ Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"LEQ");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '<' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"<");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr GEQ Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"GEQ");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '>' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,">");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr AND Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"AND");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '+' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"+");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '-' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"-");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '*' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"*");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '/' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"/");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr '%' Pexpr
	{
		$2 = mknode2(2,$1,$3);
		strcpy($2->name,"%");
		$$ = mknode1(1,$2);
		strcpy($$->name,"expr");
	}
|	'!' Pexpr
	{
		$1 = mknode0(0);
		strcpy($1->name,"!");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"expr");
	}
|	'-' Pexpr
	{
		$1 = mknode0(0);
		strcpy($1->name,"-");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"expr");
	}
|	'+' Pexpr
	{
		$1 = mknode0(0);
		strcpy($1->name,"+");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"expr");
	}
|	'*' Pexpr
	{
		$1 = mknode0(0);
		strcpy($1->name,"*");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"expr");
	}
|	'&' Pexpr
	{
		$1 = mknode0(0);
		strcpy($1->name,"&");
		$$ = mknode2(2,$1,$2);
		strcpy($$->name,"expr");
	}
|	Pexpr
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"expr");
	}
|	identifier '(' args ')'
	{
		$2 = mknode0(0);
		$4 = mknode0(0);
		strcpy($2->name,"(");
		strcpy($4->name,")");			
		$$ = mknode4(4,$1,$2,$3,$4);
		strcpy($$->name,"expr");
	}
|	identifier '[' expr ']'
	{
		$2 = mknode0(0);
		$4 = mknode0(0);
		strcpy($2->name,"[");
		strcpy($4->name,"]");
		$$ = mknode4(4,$1,$2,$3,$4);
		strcpy($$->name,"expr");
	};

Pexpr:
	integerLit
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"Pexpr");
	}
|	floatLit
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"Pexpr");
	}
|	identifier
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"Pexpr");
	}
|	'(' expr ')'
	{
		$1 = mknode0(0);
		$3 = mknode0(0);
		strcpy($1->name,"(");
		strcpy($3->name,")");
		$$ = mknode3(3,$1,$2,$3);
		strcpy($$->name,"Pexpr");
	};

integerLit:
	INTEGER_LITERAL
	{
		$1 = mknode0(0);
		strcpy($1->name,yytext);
		$$ = mknode1(1,$1);
		strcpy($$->name,"integerLit");	
	};

floatLit:
	FLOAT_LITERAL
	{
		$1 = mknode0(0);
		strcpy($1->name,yytext);
		$$ = mknode1(1,$1);
		strcpy($$->name,"floatLit");
	};

identifier:
	IDENTIFIER
	{
		$1 = mknode0(0);
		strcpy($1->name,yytext);
		$$ = mknode1(1,$1);
		strcpy($$->name,"identifier");
	};

arg_list:
	arg_list ',' expr
	{
		$2 = mknode0(0);
		strcpy($2->name,",");
		$$ = mknode3(3,$1,$2,$3);
		strcpy($$->name,"arg_list");
	}
|	expr
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"arg_list");
	};

args:
	arg_list
	{
		$$ = mknode1(1,$1);
		strcpy($$->name,"args");
	}
|	{
		$$ = mknode0(1);
		strcpy($$->name,"args");
	};



%%

void yyerror(string s) {
    printf("Invalid Input\n");
	exit(0);
}

int main()
{
	//extern int yydebug;yydebug = 1;
	yyparse();
	// if(root != NULL)
	// {	
	// 	DFS(root);
	// }	
	// else
	// {
	// 	return 0;
	// }
	// printf("%d\n%d\n%d\n%d\n",root->max_path,ifmax,whmax,mainmax);
	//printf("%d  %d  %d\n" , mifh,mwhh,mmh);	
	//printf("%d %d\n" , (root->child[0])->h1,(root->child[0])->h2);

    
	genAssembly(root);
	return 0;
}

Table* createTable();
void genTable(node* root,Table* tbl);
void regFree(char* reg);
char* getReg();

typedef struct  code_ {
	char* code;
	char* reg;
} Code;

Code genFunction(node* root,Table* tbl);
Code genStmtList(node* root,Table* tbl);
Code genstmt(node* root,Table* tbl);
Code gotoFunc(node* root);
Code genExp(node* root,Table* tbl);
Code genPexp(node* root,Table* tbl);
char* genLabel();

int TableLookup(Table* tbl,char* id);
void genBottom();
void genTop();

void genAssembly(node* root){

	//printf("in gen ass\n");
	Table* tbl = createTable();


	genTop();
	
	Code cd= gotoFunc(root->child[0]);
	if(cd.code!=NULL)
		printf("\n%s\n",cd.code);

	genBottom();
}

int TableLookup(Table* tbl,char* id){
	for(int i=0;i<tbl->len;i++){
		if(strcmp(tbl->var[i],id)==0)
			return 4*(i+1);
	}
	return -1;
}

Code gotoFunc(node* root){
	Code cd;
	cd.code = NULL;
	if(root==NULL)
		return cd;
	
	// printf("inside goto %s %d\n",root->name,root->size);

	if(strcmp(root->name,"decl_list")==0){
		if(root->size==1){
			node* decl = root->child[0];
			// printf("inside decl\n");
			if(strcmp(decl->child[0]->name,"func_decl")==0 ){
				Table* tbl = createTable();
				genTable(decl->child[0],tbl);
				// printf("tablegen \n");
				return genFunction(decl->child[0],tbl);
			}
			
		}
		else if(root->size==2){
			
			Code cd1 = gotoFunc(root->child[0]);
			Code cd2;
			cd2.code = NULL;

			node* decl = root->child[1];
			if(strcmp(decl->child[0]->name,"func_decl")==0 ){
				Table* tbl = createTable();
				genTable(decl->child[0],tbl);
			    cd2 = genFunction(decl->child[0],tbl);
			}
			
			if(cd1.code!=NULL && cd2.code!=NULL){
				cd.code=(char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+100));
				sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
			}
			else if(cd2.code!=NULL){
				cd.code=(char*)malloc(sizeof(char)*(strlen(cd2.code)+100));
				sprintf(cd.code,"%s\n",cd2.code);
			}
				

		}

		return cd;
	}
}

//call when there iis fn call
Code genFunction(node* root,Table* tbl){
	Code cd;
	cd.code = NULL;
	if(root==NULL)
		return cd;
	

	if( strcmp(root->name,"func_decl")==0){

		 //printf("genfun \n");

		char* name = root->child[1]->child[0]->name;
		char* pre =(char*)malloc(sizeof(char)*(strlen(name)*3+1000));
		sprintf(pre,"\n.globl %s\n",name);
		sprintf(pre,"%s.type %s, @function\n",pre,name);
		sprintf(pre,"%s%s:\n.LFB%d:\n",pre,name,0);
		sprintf(pre,"%s.cfi_startproc\n pushq \t %%rbp\n .cfi_def_cfa_offset 16\n .cfi_offset 6, -16\n",pre);
		sprintf(pre,"%s movq\t%%rsp, %%rbp\n.cfi_def_cfa_register 6\n",pre);

		//allocate based on table
		int len = 16*( tbl->len/4 + 1);
		sprintf(pre,"%s subq $%d, %%rsp\n",pre,len);

		// printf("genfun pre %s\n",root->child[5]->child[2]->name);

		Code stmnts = genStmtList(root->child[5]->child[2],tbl);
		//code from statemnts

		//printf("genfun stmnt \n");

		if(stmnts.code!=NULL){
			
			cd.code = (char*)malloc(sizeof(char)*(strlen(stmnts.code)+strlen(pre)+100));
			sprintf(cd.code,"%s\n%s\n",pre,stmnts.code);
		}
		else{
			cd.code = (char*)malloc(sizeof(char)*(strlen(pre)+100));
			sprintf(cd.code,"%s\n",pre);
		}
		//end code
		sprintf(cd.code,"%sleave\n .cfi_def_cfa 7, 8\n ret\n .cfi_endproc\n",cd.code);

	}

	return cd;
}

Code genStmtList(node* root,Table* tbl){
	Code cd;
	cd.code = NULL;
	if(root==NULL)
		return cd;


	if( strcmp(root->name,"stmt_list")==0){
		
		if(root->size==1){
			
			cd = genstmt(root->child[0],tbl);
		     //printf("genstmnt 1 %s\n",cd.code);
			return cd;
		}
		else if(root->size==2){
			 //printf("genstmnt 2 \n");
			Code st1 = genStmtList(root->child[0],tbl);
			Code st2 = genstmt(root->child[1],tbl);
			cd.code = (char*)malloc(sizeof(char)*(strlen(st1.code)+strlen(st2.code)+10));
			sprintf(cd.code,"%s\n%s",st1.code,st2.code);
			return cd;
		}
	}

	return cd;
}

Code genstmt(node* root,Table* tbl){
	Code cd;
	cd.code = NULL;
	if(root==NULL)
		return cd;

	if( strcmp(root->name,"stmt")==0){
		//only print stmnt
		if(strcmp(root->child[0]->name,"print_stmt")==0){
			// printf("print stmnt \n");

			char* id = root->child[0]->child[1]->child[0]->name;
			int lt = TableLookup(tbl,id);
			
			if(lt!=-1){
				cd.code = (char*)malloc(sizeof(char)*300);
				sprintf(cd.code,"movl\t -%d(%%rbp), %%eax\n",lt);
				sprintf(cd.code,"%smovl\t %%eax, %%esi\n",cd.code);
				sprintf(cd.code,"%smovl\t $.LC%d, %%edi\n",cd.code,0);
				sprintf(cd.code,"%smovl\t $0, %%eax\ncall\t printf\n",cd.code);	
			
				
			}

		}
		else if(strcmp(root->child[0]->name,"return_stmt")==0){
			//printf("inside return\n");
			if(root->child[0]->size==2){
				cd.code = (char*)malloc(sizeof(char)*100);
				sprintf(cd.code,"\nnop\n");
				aveax = 1;
				avedx = 1;
			}
			else if(root->child[0]->size==3){
				//get from expression
				//printf("inside 3 %s\n",root->child[0]->child[1]->name);
				Code cd1 = genExp(root->child[0]->child[1],tbl);
				cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+100));
				if(strcmp(cd1.reg,"%eax")==0){
					    cd = cd1;
						aveax =1;
						avedx =1;
						return cd;
				}
				else{
					//eax is need to move
					
					sprintf(cd.code,"%s\nmovl\t %s, %%eax\n",cd1.code,cd1.reg);
					aveax = 1;
					avedx = 1;
					return cd;
				}
				
			}
		}
	}

	// printf("print %s \n",cd.code);	
	return cd;
}


Code genExp(node* root,Table* tbl){
	Code cd;
	cd.code = NULL;
	if(root==NULL)
		return cd;

	if( strcmp(root->name,"expr")==0 ){
		
		if(root->size==2){

			if( strcmp(root->child[0]->name,"!")==0){
				Code cd1 = genPexp(root->child[1],tbl);
				if(cd1.code!=NULL){
					cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+200));
					sprintf(cd.code,"%s\n cmpl\t $0, %s\n sete\t %%al\n movzbl\t %%al, %s\n",cd1.code,cd1.reg,cd1.reg);	
					cd.reg = cd.reg;
					return cd;
				}
			}
			else if ( strcmp(root->child[0]->name,"-")==0){
				Code cd1 = genPexp(root->child[1],tbl);
				if(cd1.code!=NULL){
					cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+100));
					sprintf(cd.code,"%s\n negl %s\n",cd1.code,cd1.reg);	
					cd.reg = cd1.reg;
					return cd;
				}

			}
			else if( strcmp(root->child[0]->name,"+")==0){
				return genPexp(root->child[1],tbl);
			}
			else{
				//error
				return cd;
			}

		}
		else if(root->size==1){
			
			
			if(strcmp(root->child[0]->name,"Pexpr")==0){
				//genearte and return code of pexpr
				cd = genPexp(root->child[0],tbl);
				return cd;
			}
			else{
				node* op = root->child[0];
				if( strcmp(op->name,"+")==0){
					//printf("inside add\n");
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+50));	
						sprintf(cd.code,"%s\n%s",cd1.code,cd2.code);
						sprintf(cd.code,"%s\naddl\t %s, %s\n",cd.code,cd2.reg,cd1.reg);

						cd.reg = cd1.reg;
						//printf("inside add condn %s %s\n",cd1.reg,cd2.reg);
						regFree(cd2.reg);

						//printf("inside add condn return\n");
						return cd;
					}
				}
				else if( strcmp(op->name,"-")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+50));	
						sprintf(cd.code,"%s\n%s",cd1.code,cd2.code);
						sprintf(cd.code,"%s\nsubl\t %s, %s\n",cd.code,cd2.reg,cd1.reg);
						cd.reg = cd1.reg;
						regFree(cd2.reg);
						return cd;
					}
				}
				else if( strcmp(op->name,"*")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+50));	
						sprintf(cd.code,"%s\n%s",cd1.code,cd2.code);
						sprintf(cd.code,"%s\nimul\t %s, %s\n",cd.code,cd2.reg,cd1.reg);
						cd.reg = cd1.reg;
						regFree(cd2.reg);
						return cd;
					}
				}
				else if( strcmp(op->name,"/")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						//using ecx esi
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						int flag = 0;
						if(strcmp(cd1.reg,"%eax")!=0){
							if(aveax==1){
								flag = 2;
								sprintf(cd.code,"%s\nmovl\t %s, %%eax\n",cd.code,cd1.reg);
							}
							else{
								flag=1;
								sprintf(cd.code,"%s\n movl\t %%eax, %%ecx",cd.code);
								sprintf(cd.code,"%s\nmovl\t %s, %%eax\n",cd.code,cd1.reg);
							}
						}
						//use esi for 2nd op
						sprintf(cd.code,"%s movl\t %s,%%esi\ncltd\n",cd.code,cd2.reg);
						sprintf(cd.code,"%s\nidivl\t  %%esi\n",cd.code);
						
						if(flag==1){
							sprintf(cd.code,"%s\n movl\t %%eax, %s\n",cd.code,cd1.reg);
							sprintf(cd.code,"%s movl\t %%ecx, %%eax",cd.code); //move back
						}
						else if(flag==2){
							sprintf(cd.code,"%s\n movl\t %%eax, %s\n",cd.code,cd1.reg);
						}
						
						regFree(cd2.reg);
						cd.reg = cd1.reg;

						return cd;
					}
				}
				else if(  strcmp(op->name,"%")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);

						int flag = 0;
						if(strcmp(cd1.reg,"%eax")!=0){
							if(aveax==1){
								sprintf(cd.code,"%s\nmovl\t %s, %%eax\n",cd.code,cd1.reg);
							}
							else{
								flag=1;
								sprintf(cd.code,"%s\n movl\t %%eax, %%ecx",cd.code);
								sprintf(cd.code,"%s\nmovl\t %s, %%eax\n",cd.code,cd1.reg);
							}
						}
						//use esi for 2nd op
						sprintf(cd.code,"%s movl\t %s,%%esi\ncltd\n",cd.code,cd2.reg);
						sprintf(cd.code,"%s\nidivl\t  %%esi\n",cd.code);


						if(flag==1)
							sprintf(cd.code,"%s movl\t %%ecx, %%eax",cd.code); //move back
						
						if(strcmp(cd1.reg,"%edx")!=0)
							sprintf(cd.code,"%s\n movl\t %%edx, %s\n",cd.code,cd1.reg);

						regFree(cd2.reg);
						cd.reg = cd1.reg;			//alocate reg
						return cd;
					}
				}
				else if(  strcmp(op->name,"EQ")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t %s,%s\n sete %%al\n movzbl\t %%al, %s\n",cd.code,cd1.reg,cd2.reg,cd1.reg);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;
						
					}
				}
				else if(  strcmp(op->name,"NEQ")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t %s,%s\n setne %%al\n movzbl\t %%al, %s\n",cd.code,cd1.reg,cd2.reg,cd1.reg);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;
						
					}
				}
				else if(  strcmp(op->name,"LEQ")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t %s,%s\n setle %%al\n movzbl\t %%al, %s\n",cd.code,cd1.reg,cd2.reg,cd1.reg);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;
						
					}
				}
				else if(  strcmp(op->name,"<")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t %s,%s\n setl %%al\n movzbl\t %%al, %s\n",cd.code,cd1.reg,cd2.reg,cd1.reg);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
					
						return cd;
						
					}
				}
				else if(  strcmp(op->name,"GEQ")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					printf("In ge\n");
					if(cd1.code!=NULL && cd2.code!=NULL){
						printf("Inside ge\n");
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t %s,%s\n setge %%al\n movzbl\t %%al, %s\n",cd.code,cd1.reg,cd2.reg,cd1.reg);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;
						
					}
				}
				else if(  strcmp(op->name,">")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+200));	
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t %s,%s\n setg %%al\n movzbl\t %%al, %s\n",cd.code,cd1.reg,cd2.reg,cd1.reg);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;
						
					}
				}
				else if(  strcmp(op->name,"AND")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+300));	
						char* label1 = genLabel();
						char* label2 = genLabel();
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t $0, %s\n je\t %s\n",cd.code,cd1.reg,label1);
						sprintf(cd.code,"%s cmpl\t $0, %s\n je\t %s\n",cd.code,cd2.reg,label1);
						sprintf(cd.code,"%s movl\t $1, %s\n jmp\t %s\n",cd.code,cd1.reg,label2);
						sprintf(cd.code,"%s %s:\n \t movl\t $0, %s\n %s:\n",cd.code,label1,cd1.reg,label2);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;	
					}
				}
				else if(  strcmp(op->name,"OR")==0){
					Code cd1 = genPexp(op->child[0],tbl);
					Code cd2 = genPexp(op->child[1],tbl);
					
					if(cd1.code!=NULL && cd2.code!=NULL){
						cd.code = (char*)malloc(sizeof(char)*(strlen(cd1.code)+strlen(cd2.code)+400));	
						char* label1 = genLabel();
						char* label2 = genLabel();
						char* label3 = genLabel();
						sprintf(cd.code,"%s\n%s\n",cd1.code,cd2.code);
						sprintf(cd.code,"%s cmpl\t $0, %s\n jne\t %s\n",cd.code,cd1.reg,label1);
						sprintf(cd.code,"%s cmpl\t $0, %s\n je\t %s\n",cd.code,cd2.reg,label2);
						sprintf(cd.code,"%s %s:\n movl \t $1, %s\n jmp\t %s\n",cd.code,label1,cd1.reg,label3);
						sprintf(cd.code,"%s %s:\n movl\t $0, %s\n %s:\n",cd.code,label2,cd1.reg,label3);
						regFree(cd2.reg);
						cd.reg = cd1.reg;
						return cd;	
					}
				}

			}

		}
		else if(root->size==4){
			//error
		}

	}

}


Code genPexp(node* root,Table* tbl){
	Code cd;
	cd.code = NULL;
	if(root==NULL)
		return cd;

	if( strcmp(root->name,"Pexpr")==0 ){
		if(root->size==1){
			cd.code = (char*)malloc(sizeof(char)*300);
			if(strcmp(root->child[0]->name,"integerLit") == 0){
				char* it = root->child[0]->child[0]->name;
					char* reg1 = getReg();
					sprintf(cd.code,"\nmovl\t $%s, %s\n",it,reg1);
					cd.reg = reg1;
					return cd;
			}
			else if(strcmp(root->child[0]->name,"identifier")==0){
				char* id = root->child[0]->child[0]->name;
				int rv = TableLookup(tbl,id);
				if(rv!=-1){
					char* reg1 = getReg();
					sprintf(cd.code,"\nmovl\t -%d(%%rbp), %s\n",rv,reg1);
					cd.reg = reg1;
					return cd;
				}
			}
			else{
				cd.reg = NULL;
				cd.code = NULL;
			}

		}
		else if(root->size==3){
			if(strcmp(root->child[1]->name,"expr")==0){
				cd = genExp(root->child[1],tbl);
				return cd;
			}
		}
	}


	return cd;
}


void genTable(node* root,Table* tbl){
	if(root==NULL)
		return;
	
	if( strcmp(root->name,"local_decl")==0 && root->size==3 ){
		char* val = root->child[1]->child[0]->name;
		tbl->var[tbl->len]=(char*)malloc(sizeof(char)*(strlen(val)+3));
		strcpy(tbl->var[tbl->len],val);
		tbl->len++;
		return;
	}

	for(int i=0;i<root->size;i++){
		genTable(root->child[i],tbl);
	}
}

char* getReg(){
	char* temp = NULL;
	if(aveax==1){
		temp = REAX;
		aveax = 0;
	}else if(avedx==1){
		temp = REDX;
		avedx = 0;
	}
	else if(avebx==1){
		temp = REBX;
		avebx = 0;
	}
	
	return temp;
}

void regFree(char* reg){
	if( strcmp(reg,"%eax")==0){
		aveax = 1;
	}
	else if( strcmp(reg,"%edx")==0){
		avedx = 1;
	}
	else if( strcmp(reg,"%ebx")==0){
		avebx = 1;
	}
}

char* genLabel(){
	char* temp = (char*)malloc(sizeof(char)*20);
	sprintf(temp,".L%d",labelNo);
	labelNo++;
	return temp;
}

void genTop(){
	printf(".file	\"t.c\"\n");
	printf(".section\t .rodata\n");
    printf(".LC0:\n.string	\"%%d\\n\" \n.text\n");

	//gen main

}


void genBottom(){
	printf(".LFE0:\n.size	main, .-main\n");
	printf(".ident	\"GCC: (Debian 4.9.2-10) 4.9.2\"");
	printf("\n.section	.note.GNU-stack,\"\",@progbits\n");

}

Table* createTable(){
	Table* temp = (Table*)malloc(sizeof(Table));
	if(temp!=NULL){
		temp->len=0;
	}
	return temp;
}


void DFS(node *root)
{
	//printf("%s\n" , root->name);
	root->h1 = 0;
	root->h2 = 0;
	root->max_path = 0;
	root->mainflag = 0;
	if(root->size == 0)
	{
		if(strcmp(root->name,"main") == 0)
		{
			root->mainflag = 1;
		}
		return;
	}
	int num = root->size;
	int i;
	for(i=0;i<num;i++)
	{
		DFS(root->child[i]);
		if((root->child[i])->mainflag == 1)
		{
			root->mainflag = 1;
		}
		int htemp = (root->child[i])->h1 + 1;
		int mptemp = (root->child[i])->max_path;
		if(htemp > root->h1)
		{
			root->h2 = root->h1;
			root->h1 = htemp;
		}
		else if(htemp >= root->h2)
		{
			root->h2 = htemp;
		}
		
		if(mptemp >= root->max_path)
		{
			root->max_path = mptemp;
		}
	}
	if(root->h1 + root->h2 > root->max_path)
	{
		root->max_path = root->h1 + root->h2;
	}

	if(strcmp(root->name,"if_stmt") == 0)
	{
		if(root->max_path > ifmax)
		{
			ifmax = root->max_path;
		}
	}
	if(strcmp(root->name,"while_stmt") == 0)
	{
		if(root->max_path > whmax)
		{
			whmax = root->max_path;
		}
	}
	if(strcmp(root->name,"func_decl") == 0 && root->mainflag == 1)
	{
		if(root->max_path > mainmax)
		{
			mainmax = root->max_path;
		}
	}
	return;
}



node *mknode7(int s,node *c1,node *c2,node *c3,node* c4,node *c5,node *c6,node *c7)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->child[1] = c2;
	nn->child[2] = c3;
	nn->child[3] = c4;
	nn->child[4] = c5;
	nn->child[5] = c6;
	nn->child[6] = c7;
	nn->size = 7;
	return nn;
}

node *mknode6(int s,node *c1,node *c2,node *c3,node* c4,node *c5,node *c6)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->child[1] = c2;
	nn->child[2] = c3;
	nn->child[3] = c4;
	nn->child[4] = c5;
	nn->child[5] = c6;
	nn->size = 6;
	return nn;
}

node *mknode5(int s,node *c1,node *c2,node *c3,node* c4,node *c5)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->child[1] = c2;
	nn->child[2] = c3;
	nn->child[3] = c4;
	nn->child[4] = c5;
	nn->size = 5;
	return nn;
}

node *mknode4(int s,node *c1,node *c2,node *c3,node* c4)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->child[1] = c2;
	nn->child[2] = c3;
	nn->child[3] = c4;
	nn->size = 4;
	return nn;
}

node *mknode3(int s,node *c1,node *c2,node *c3)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->child[1] = c2;
	nn->child[2] = c3;
	nn->size = 3;
	return nn;
}

node *mknode2(int s,node *c1,node *c2)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->child[1] = c2;
	nn->size = 2;
	return nn;
}

node *mknode1(int s,node *c1)
{
	node* nn = (node *)malloc(sizeof(node));
	nn->child[0] = c1;
	nn->size = 1;
	return nn;
}

node *mknode0(int s)
{
	node* nn = (node *)malloc(sizeof(node));
	if(s == 0)
	{
		nn->size = 0;
	}
	if(s == 1)
	{
		node* nnc = (node *)malloc(sizeof(node));
		nnc->size = 0;
		strcpy(nnc->name,"#EPS");
		nn->child[0] = nnc;
		nn->size = 1;
	}
	return nn;
}
