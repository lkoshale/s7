%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	char text[1000];
%}

%token OHTML CHTML TEXT OB CB OU CU OI CI OUL CUL OLI CLI
%token OTABLE CTABLE OTR CTR OTD CTD IDENT NUM CLOSE EQUAL
%right OB OU OI
%left  CB CU CI

%%

html_doc : OHTML  body_doc CHTML			{printf("html parsed\n"); exit(0);}
	      | OHTML CHTML					{printf("html parsed\n"); exit(0);}
	      ;		


body_doc : html_expr					{printf("single tag\n");}
		   | html_expr body_doc
		   | list_expr
		   | table_dec
		   ;


html_expr : otag body_doc ctag  { printf("nested tags\n");}
			| text_expr
			;

list_expr : OUL list_dec CUL
			;
	
list_dec : list 
		  | list list_dec
		  ;

list : OLI html_expr CLI
	  | OLI CLI
	  ;

table_dec : OTABLE table_rows CTABLE
			;

table_rows : OTR table_cols CTR 
			| OTR table_cols CTR table_rows
			;

table_cols : OTD html_expr CTD
			| OTD html_expr CTD table_cols
			;

attr_dec : IDENT EQUAL IDENT
			| IDENT EQUAL NUM
			;

otag : otag_dec CLOSE
	 | otag_dec attr_dec CLOSE
	 ;

otag_dec : OB
	 | OU 
	 | OI  
	 | OUL
	 | OLI
	 ;

ctag : CB
	| CU
	| CI
	| CLI
	| CUL
	;

text_expr : TEXT
		  | IDENT
		  | NUM
		  ; 


%%

int yyerror (char const *s)
{
  fprintf (stderr, "%s\n", s);
}


int main(){

	yyparse();
	return 0;
}