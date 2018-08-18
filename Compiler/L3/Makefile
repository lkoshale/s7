a.out: y.tab.c lex.yy.c
	gcc -O3 lex.yy.c y.tab.c

y.tab.c: l3.y 
	yacc -d l3.y

lex.yy.c: l3.l y.tab.h
	lex l3.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out