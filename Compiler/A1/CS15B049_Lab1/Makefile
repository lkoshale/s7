a.out: y.tab.c lex.yy.c
	gcc -O3 lex.yy.c y.tab.c

y.tab.c: q4.y 
	yacc -d q4.y

lex.yy.c: q4.l y.tab.h
	lex q4.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out