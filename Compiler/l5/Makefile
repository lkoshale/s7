a.out: y.tab.c lex.yy.c
	gcc -O3 lex.yy.c y.tab.c

y.tab.c: l5.y 
	yacc -d l5.y

lex.yy.c: l5.l y.tab.h
	lex l5.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out