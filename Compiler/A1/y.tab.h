/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IF = 258,
    ELSE = 259,
    FOR = 260,
    INT = 261,
    CHAR = 262,
    DOUBLE = 263,
    VOID = 264,
    WHILE = 265,
    CONTINUE = 266,
    BREAK = 267,
    RETURN = 268,
    LP = 269,
    RP = 270,
    LB = 271,
    RB = 272,
    LSB = 273,
    RSB = 274,
    DBQUOTE = 275,
    SNQUOTE = 276,
    RELOP = 277,
    LOGOP = 278,
    ASGNOP = 279,
    ADD = 280,
    MINUS = 281,
    DIV = 282,
    STAR = 283,
    PERCNT = 284,
    NOT = 285,
    AMPRESAND = 286,
    SMCOL = 287,
    IDENT = 288,
    NUM = 289,
    STRING = 290,
    CHARLITERAL = 291,
    COMA = 292,
    INCOP = 293
  };
#endif
/* Tokens.  */
#define IF 258
#define ELSE 259
#define FOR 260
#define INT 261
#define CHAR 262
#define DOUBLE 263
#define VOID 264
#define WHILE 265
#define CONTINUE 266
#define BREAK 267
#define RETURN 268
#define LP 269
#define RP 270
#define LB 271
#define RB 272
#define LSB 273
#define RSB 274
#define DBQUOTE 275
#define SNQUOTE 276
#define RELOP 277
#define LOGOP 278
#define ASGNOP 279
#define ADD 280
#define MINUS 281
#define DIV 282
#define STAR 283
#define PERCNT 284
#define NOT 285
#define AMPRESAND 286
#define SMCOL 287
#define IDENT 288
#define NUM 289
#define STRING 290
#define CHARLITERAL 291
#define COMA 292
#define INCOP 293

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
