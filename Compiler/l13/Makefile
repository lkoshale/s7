a.out: y.tab.c lex.yy.c
	gcc -O3 lex.yy.c y.tab.c -std=c11

y.tab.c: l13.y 
	yacc -d l13.y

lex.yy.c: l13.l y.tab.h
	lex l13.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out