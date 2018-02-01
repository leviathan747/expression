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

%type<rval> real_expression
%type<rval> real_addition
%type<rval> real_multiplication
%type<rval> real_exponentiation
%type<rval> primary_real_expression

%start expression

%%

expression                    : integer_expression { printf( "%d\n", $1 ); } NULL_TERMINATOR
                              | real_expression { printf( "%f\n", $1 ); } NULL_TERMINATOR
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

real_expression               : real_addition { $$ = $1; }
                              ;

real_addition                 : real_multiplication PLUS real_multiplication     { $$ = $1 + $3; }
                              | integer_multiplication PLUS real_multiplication  { $$ = (double)$1 + $3; }
                              | real_multiplication PLUS integer_multiplication  { $$ = $1 + (double)$3; }
                              | real_multiplication MINUS real_multiplication    { $$ = $1 - $3; }
                              | integer_multiplication MINUS real_multiplication { $$ = (double)$1 - $3; }
                              | real_multiplication MINUS integer_multiplication { $$ = $1 - (double)$3; }
                              | real_multiplication                              { $$ = $1; }
                              ;

real_multiplication           : real_exponentiation TIMES real_exponentiation     { $$ = $1 * $3; }
                              | integer_exponentiation TIMES real_exponentiation  { $$ = (double)$1 * $3; }
                              | real_exponentiation TIMES integer_exponentiation  { $$ = $1 * (double)$3; }
                              | real_exponentiation DIVIDE real_exponentiation    { $$ = $1 / $3; }
                              | integer_exponentiation DIVIDE real_exponentiation { $$ = (double)$1 / $3; }
                              | real_exponentiation DIVIDE integer_exponentiation { $$ = $1 / (double)$3; }
                              | real_exponentiation                               { $$ = $1; }
                              ;

real_exponentiation           : primary_real_expression POWER primary_real_expression    { $$ = pow( $1, $3 ); }
                              | primary_integer_expression POWER primary_real_expression { $$ = pow( $1, $3 ); }
                              | primary_real_expression POWER primary_integer_expression { $$ = pow( $1, $3 ); }
                              | primary_real_expression                                  { $$ = $1; }
                              ;

primary_real_expression       : REAL                          { $$ = $1; }
                              | LPAREN real_expression RPAREN { $$ = $2; }
                              ;

%%

void expression_parse( char * input, int length ) {
  expression_set_buffer( input, length );
  yylineno = 1;
  yyparse();
  expression_clear_buffer();
}
