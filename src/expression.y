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

integer_addition              : integer_addition PLUS integer_addition  { $$ = $1 + $3; }
                              | integer_addition MINUS integer_addition { $$ = $1 - $3; }
                              | integer_multiplication                  { $$ = $1; }
                              ;

integer_multiplication        : integer_multiplication TIMES integer_multiplication  { $$ = $1 * $3; }
                              | integer_multiplication DIVIDE integer_multiplication { $$ = $1 / $3; }
                              | integer_multiplication MOD integer_multiplication    { $$ = $1 % $3; }
                              | integer_exponentiation                               { $$ = $1; }
                              ;

integer_exponentiation        : integer_exponentiation POWER integer_exponentiation { $$ = (int)pow( $1, $3 ); }
                              | primary_integer_expression                          { $$ = $1; }
                              ;

primary_integer_expression    : INTEGER                          { $$ = $1; }
                              | LPAREN integer_expression RPAREN { $$ = $2; }
                              ;

real_expression               : real_addition { $$ = $1; }
                              ;

real_addition                 : real_addition PLUS real_addition     { $$ = $1 + $3; }
                              | integer_addition PLUS real_addition  { $$ = (double)$1 + $3; }
                              | real_addition PLUS integer_addition  { $$ = $1 + (double)$3; }
                              | real_addition MINUS real_addition    { $$ = $1 - $3; }
                              | integer_addition MINUS real_addition { $$ = (double)$1 - $3; }
                              | real_addition MINUS integer_addition { $$ = $1 - (double)$3; }
                              | real_multiplication                  { $$ = $1; }
                              ;

real_multiplication           : real_multiplication TIMES real_multiplication     { $$ = $1 * $3; }
                              | integer_multiplication TIMES real_multiplication  { $$ = (double)$1 * $3; }
                              | real_multiplication TIMES integer_multiplication  { $$ = $1 * (double)$3; }
                              | real_multiplication DIVIDE real_multiplication    { $$ = $1 / $3; }
                              | integer_multiplication DIVIDE real_multiplication { $$ = (double)$1 / $3; }
                              | real_multiplication DIVIDE integer_multiplication { $$ = $1 / (double)$3; }
                              | real_exponentiation                               { $$ = $1; }
                              ;

real_exponentiation           : real_exponentiation POWER real_exponentiation    { $$ = pow( $1, $3 ); }
                              | integer_exponentiation POWER real_exponentiation { $$ = pow( $1, $3 ); }
                              | real_exponentiation POWER integer_exponentiation { $$ = pow( $1, $3 ); }
                              | primary_real_expression                          { $$ = $1; }
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
