a.out: y.tab.c lex.yy.c
	g++ -std=c++11 lex.yy.c y.tab.c
	@echo "Run the program as ./a.out <input.txt"

y.tab.c: A4.y 
	yacc -d A4.y

lex.yy.c: A4.l y.tab.h
	lex A4.l

clean:
	@rm lex.yy.c y.tab.h y.tab.c a.out
