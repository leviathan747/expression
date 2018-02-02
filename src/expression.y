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
  int            ival;
  double         rval;
  expression_t * exprval;
}

%token<ival> INTEGER
%token<rval> REAL

%token DIVIDE TIMES MINUS PLUS POWER LPAREN RPAREN
%token MOD NULL_TERMINATOR UNRECOGNIZED_TOKEN

%type<exprval> expression
%type<exprval> addition
%type<exprval> multiplication
%type<exprval> exponentiation
%type<exprval> primary_expression

%start evaluation

%%

evaluation                    : expression NULL_TERMINATOR
                                {
                                  if ( NULL != $1 ) {
                                    if ( REAL == $1->type ) printf( "%f\n", $1->value.rval );
                                    else if ( INTEGER == $1->type ) printf( "%d\n", $1->value.ival );
                                    dispose_expression( $1 );
                                  }

                                }
                              | NULL_TERMINATOR /* empty */
                              ;

expression                    : addition
                              ;


addition                      : addition PLUS multiplication              { $$ = combine_expressions( $1, $3, PLUS ); }
                              | addition MINUS multiplication             { $$ = combine_expressions( $1, $3, MINUS ); }
                              | multiplication                            { $$ = $1; }
                              ;

multiplication                : multiplication TIMES exponentiation       { $$ = combine_expressions( $1, $3, TIMES ); }
                              | multiplication DIVIDE exponentiation      { $$ = combine_expressions( $1, $3, DIVIDE ); }
                              | multiplication MOD exponentiation         { $$ = combine_expressions( $1, $3, MOD ); }
                              | exponentiation                            { $$ = $1; }
                              ;

exponentiation                : exponentiation POWER primary_expression   { $$ = combine_expressions( $1, $3, POWER ); }
                              | primary_expression                        { $$ = $1; }
                              ;

primary_expression            : INTEGER                                   { $$ = new_integer( $1 ); }
                              | REAL                                      { $$ = new_real( $1 ); }
                              | LPAREN expression RPAREN                  { $$ = $2; }
                              ;

%%

void expression_parse( char * input, int length ) {
  expression_set_buffer( input, length );
  yylineno = 1;
  yyparse();
  expression_clear_buffer();
}
