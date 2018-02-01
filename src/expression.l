%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define YY_DECL int yylex()
#include "expression.h"
#include "expression.tab.h"
void yyerror( const char * s );
extern int expression_parse_error;
YY_BUFFER_STATE expression_buffer_state;
%}

%%

[ \t\f\n\r]+ ; // ignore all whitespace

"/" return DIVIDE;
"[" return LPAREN;
"-" return MINUS;
"+" return PLUS;
"^" return POWER;
"]" return RPAREN;
"x" return TIMES;
"%" return MOD;

\0\0* return NULL_TERMINATOR;

(0|-?[1-9][0-9]*)               { yylval.ival = atoi( yytext ); return INTEGER; }
-?([1-9][0-9]*|0)?\.[0-9][0-9]* { yylval.rval = atof( yytext ); return REAL; }

. {  printf( "0x%x, '%s'\n", yytext[0], yytext );  yyerror( "Unrecognized token" ); return UNRECOGNIZED_TOKEN; }

%%

void yyerror( const char * s ) {
  fprintf(stderr, "expression error: line %d: %s\n", yylineno, s);
  expression_parse_error = 1;
}

void expression_set_buffer( char * input, int length ) {
  char expression_input[length+2];
  memset( expression_input, 0, length + 2 );
  strncpy( expression_input, input, length );
  expression_buffer_state = yy_scan_bytes( expression_input, length + 2 );
}

void expression_clear_buffer() {
  yy_delete_buffer( expression_buffer_state );
}
