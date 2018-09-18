a.out: y.tab.c lex.yy.c
	gcc -O3 lex.yy.c y.tab.c -std=c11

y.tab.c: l8.y 
	yacc -d l8.y

lex.yy.c: l8.l y.tab.h
	lex l8.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out