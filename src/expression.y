%{
#include "expression.h"
#include <string.h>
#include <stdio.h>
extern int yylex();
extern int yylex_destroy(void);
extern int yyparse();
extern int yylineno;
extern FILE * yyin;
void yyerror( const char * s );
void expression_set_buffer( char *, int );
void expression_clear_buffer();
%}

%locations

%union {
  int    ival;
  double rval;
}

%token<ival> INTEGER
%token<rval> REAL

%token DIVIDE LPAREN MINUS PLUS POWER RPAREN TIMES
%token ABS REM NULL_TERMINATOR UNRECOGNIZED_TOKEN

%start expression

%%

expression                    : addition_expression NULL_TERMINATOR
                              ;

addition_expression           : INTEGER PLUS INTEGER
                                {
                                  printf( "%d\n", $1 + $3 );
                                }
                              ;

%%

void expression_parse( char * input, int length ) {
  expression_set_buffer( input, length );
  yylineno = 1;
  yyparse();
  expression_clear_buffer();
}
