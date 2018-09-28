%token FLOAT_LITERAL INTEGER_LITERAL INT RETURN BREAK CONT VOID FLOAT WHILE IF
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
	};

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
	if(root != NULL)
	{	
		DFS(root);
	}	
	else
	{
		return 0;
	}
	printf("%d\n%d\n%d\n%d\n",root->max_path,ifmax,whmax,mainmax);
	//printf("%d  %d  %d\n" , mifh,mwhh,mmh);	
	//printf("%d %d\n" , (root->child[0])->h1,(root->child[0])->h2);	
	return 0;
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
