a.out: y.tab.c lex.yy.c
	gcc -O3 lex.yy.c y.tab.c -std=c11

y.tab.c: l10.y 
	yacc -d l10.y

lex.yy.c: l10.l y.tab.h
	lex l10.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out
