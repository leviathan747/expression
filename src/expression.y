%{
#include "expression.h"
#include <string.h>
#include <stdio.h>
#include <math.h>
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

%token DIVIDE TIMES MINUS PLUS POWER LPAREN RPAREN
%token MOD NULL_TERMINATOR UNRECOGNIZED_TOKEN

%type<ival> integer_expression
%type<ival> integer_addition
%type<ival> integer_multiplication
%type<ival> integer_exponentiation
%type<ival> primary_integer_expression

%start expression

%%

expression                    : integer_expression { printf( "%d\n", $1 ); } NULL_TERMINATOR
                              /* | real_expression { printf( "%f\n", $1 ); } NULL_TERMINATOR */
                              ;

integer_expression            : integer_addition { $$ = $1; }
                              ;

integer_addition              : integer_multiplication PLUS integer_multiplication  { $$ = $1 + $3; }
                              | integer_multiplication MINUS integer_multiplication { $$ = $1 - $3; }
                              | integer_multiplication                              { $$ = $1; }
                              ;

integer_multiplication        : integer_exponentiation TIMES integer_exponentiation  { $$ = $1 * $3; }
                              | integer_exponentiation DIVIDE integer_exponentiation { $$ = $1 / $3; }
                              | integer_exponentiation MOD integer_exponentiation    { $$ = $1 % $3; }
                              | integer_exponentiation                               { $$ = $1; }
                              ;

integer_exponentiation        : primary_integer_expression POWER primary_integer_expression { $$ = (int)pow( $1, $3 ); }
                              | primary_integer_expression                                  { $$ = $1; }
                              ;

primary_integer_expression    : INTEGER                          { $$ = $1; }
                              | LPAREN integer_expression RPAREN { $$ = $2; }
                              ;

%%

void expression_parse( char * input, int length ) {
  expression_set_buffer( input, length );
  yylineno = 1;
  yyparse();
  expression_clear_buffer();
}
