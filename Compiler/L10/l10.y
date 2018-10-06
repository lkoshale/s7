%{
	#include <stdio.h>
	#include <stdlib.h>
	extern int yylex();
	void yyerror(char *s);

	#define INT_T  100
	#define FLOAT_T 200


	char REAX[10]="%eax";
	char REBX[10]="%ebx";
	char REDX[10]="%edx";

	int aveax=0,avebx=0,avedx=0;

	typedef struct code_ {
		char* reg;
		int type;
	}Code;

	typedef struct vtable{
		char* var[200];
		int type[200];
		int size;
	} VTable;

	VTable* global=(VTable*)malloc(sizeof(VTable));
	global->size=0;

	VTable* local=NULL;

	void addTable(VTable* tbl,char* var,int typ);
	void regFree(char* reg);
	char* getReg();
	void createCode(char* reg, int typ);


	typedef struct pair{
		int typ;
		int rt;
	} Pair;

	Pair TableLookUp(char* id);




%}

%union{
 char str[200];
 int tp;
 struct code_* code;
}


%token INT FLOAT IF RETURN LT GT  STRING_LITERAL PRINTF 
%token ';' ',' '(' ')' '{' '}' '=' '+' '*' '/' '%'
%start program

%token<str> IDENTIFIER FLOAT_LITERAL INTEGER_LITERAL INT_FORMAT_STR FLOAT_FORMAT_STR
%type<str> identifier floatLit integerLit format_str

%type<tp> type_spec;

%type<code> Pexpr  expr

%%

program
    : decl_list 
    ;

decl_list
    : decl_list decl
    | decl
    ;

decl
    : var_decl
	| fun_decl
	;

var_decl
    : type_spec identifier ';'    
    { 
    	if(local==NULL) { addTable(global,$2,$1); }
    	else { addTable(local,$2,$1); }
    }
	;

type_spec
    : INT  					{ $$=INT_T;}
	| FLOAT 				{ $$=FLOAT_T;}	
	;

fun_decl
    : type_spec identifier '(' params ')' {local = (VTable*)malloc(sizeof(VTable));} compound_stmt 
	{



		local = NULL;
    }
    ;

params
    :
    | param_list
    ;

param_list
    : param_list ',' param
    | param
    ;

param
    : type_spec identifier
    ;

compound_stmt
    : '{' var_decls stmt_list '}'
	;

var_decls
	: 
	| var_decls var_decl
	;

stmt_list
    : stmt_list stmt
	| stmt
	;

stmt
    : assign_stmt
	| compound_stmt
	| if_stmt
	| return_stmt
	| print_stmt
	;

print_stmt	
	: PRINTF '(' format_str ',' identifier ')' ';'
	;

if_stmt
    : IF '(' expr ')' stmt
	;

return_stmt
    : RETURN expr ';'
	;

assign_stmt
	: identifier '=' expr ';'
	;

expr 
	: Pexpr LT Pexpr		
	{
		printf("\n cmpl\t %s, %s\n setl\t %%al\n movzbl\t %%al, %s\n",$3->reg,$1->reg,$1->reg);
		regFree($3->reg);
		$$=$1;

	}
	
	| Pexpr GT Pexpr 		
	{
		printf("\n cmpl\t %s, %s\n setg\t %%al\n movzbl\t %%al, %s\n",$3->reg,$1->reg,$1->reg);
		regFree($3->reg);
		$$=$1;

	}

	| Pexpr '+' Pexpr
	{
		printf("\naddl\t %s, %s\n",$3->reg,$1->reg);
		regFree($3->reg);
		$$=$1;
	}

	| Pexpr '*' Pexpr
	{
		printf("\nimul\t %s, %s\n",$3->reg,$1->reg);
		regFree($3->reg);
		$$=$1;
	}
	| Pexpr '/' Pexpr
	{
		int flag = 0;
		if( strcmp($1->reg,"%eax")!=0){
			if(aveax==1){
				flag =2;
				printf("\nmovl\t %s, %%eax\n",$1->reg);
			}
			else{
				flag=1;
				printf("\n movl\t %%eax,  %%ecx\n");
				printf("movl\t %s, %%eax\n",$1->reg);
			}
		}

		printf("\nmovl\t %s, %%esi\n cltd\n",$3->reg);
		printf("idivl\t %%esi\n");
		if(flag==1){
			printf("movl\t %%eax, %s\n",$1->reg);
			printf("movl\t %%ecx, %%eax\n");
		}
		else if(flag==2){
			printf("movl\t %%eax, %s\n",$1->reg);
		}

		regFree($3->reg);
		$$=$1;

	}
	| Pexpr '%' Pexpr
	{
		int flag = 0;
		if( strcmp($1->reg,"%eax")!=0){
			if(aveax==1){
				flag =2;
				printf("\nmovl\t %s, %%eax\n",$1->reg);
			}
			else{
				flag=1;
				printf("\n movl\t %%eax,  %%ecx\n");
				printf("movl\t %s, %%eax\n",$1->reg);
			}
		}

		printf("\nmovl\t %s, %%esi\n cltd\n",$3->reg);
		printf("idivl\t %%esi\n");		

		if(flag==1)
			printf("movl\t %%ecx, %%eax\n");

		if(strcmp($1->reg,"%edx")!=0)
				printf("movl\t %%edx, %s\n",$1->reg );

		regFree($3->reg);
		$$=$1;

	}
	| Pexpr									{$$=$1;}
	| identifier '(' args ')'
	{

	}
	;

Pexpr
	: integerLit                { char* reg1= getReg(); printf("\nmovl\t $%s, %s\n",$1,reg1);$$= createCode(reg1,INT_T); }
	| floatLit     				{ char* reg1= getReg(); printf("\nmovl\t $%s, %s\n",$1,reg1);$$= createCode(reg1,FLOAT_T); }
	| identifier   				
	{ 
		//table lookup
		char* reg1= getReg(); 
		Pair p = TableLookUp($1);
		if(p.rt>=0){
			printf("\nmovl\t -%d(%%rbp), %s\n",p.rt,reg1);
			$$= createCode(reg1,p.typ);
		}
		else if(p.rt=-2){
			printf("\nmovl\t %s(%%rip), %s\n",$1,reg1);
			$$= createCode(reg1,p.typ);
		}
		else{
			$$=NULL;
		}

	}  
	| '(' expr ')'				{$$=$2;}
	;

integerLit
	: INTEGER_LITERAL
	;

floatLit
	: FLOAT_LITERAL
	;

identifier
	: IDENTIFIER
	;

arg_list
	: arg_list ',' expr
    | expr
    ;

args: 
    | arg_list
    ;

format_str
	: INT_FORMAT_STR
	| FLOAT_FORMAT_STR
	;
%%

void yyerror(char *s) {
   fprintf(stderr,"-->%s\n", s);
   exit(1);
}

int main(void) {
    yyparse();
    return 0;
}


void addTable(VTable* tbl,char* var,int typ){
	if(tbl!=NULL){
		tbl->var[tbl->size]=(char*)malloc(sizeof(char)*(strlen(var)+5));
		strcpy(tbl->var[tbl->size],var);
		tbl->type[tbl->size]=typ;
		tbl->size+=1;
	}
}

void top(){
	printf(".file\t\"test.c\"\n.section\t.rodata\n");
	printf(".LC0:\n.string\t\"%%d\n\"\n");
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


void createCode(char* reg, int typ){
	Code* temp = (Code*)malloc(sizeof(code));
	if(temp!=NULL){
		temp->reg = reg;
		temp->type = typ;
	}
	return temp;
}

Pair TableLookUp(char* id){
	Pair p;
	if(local!=NULL){
		for(int i=0;i<local->size;i++){
			if(strcmp(id,local->var[i])==0){
				p.rt = 4*(i+1);
				p.typ = local->type[i];
				return p;
			}
		}
	}
	else if(global!=NULL){

		for(int i=0;i<global->size;i++){
			if(strcmp(id,global->var[i])==0){
				p.rt = -2;
				p.typ = global->type[i];
				return p;
			}
		}
	}

	p.rt= -1;
	p.typ = -1;
	return p;
}