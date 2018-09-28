a.out: y.tab.c lex.yy.c
	g++ -O3 lex.yy.c y.tab.c -std=c++11
	

y.tab.c: a3.y 
	yacc -d a3.y

lex.yy.c: a3.l y.tab.h
	lex a3.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out

