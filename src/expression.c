#include "expression.h"
#include <stdio.h>
#include <string.h>

int expression_parse_error = 0;

#define MAX_ARGS     256
#define MAX_ARG_LEN  256

int main( int argc, char ** argv ) {
  // concatenate arguments
  char args[ MAX_ARGS * ( MAX_ARG_LEN + 1 ) ];
  memset( args, 0, MAX_ARGS * MAX_ARG_LEN );
  for ( int i = 1; i < argc && i < MAX_ARGS + 1; i++ ) {
    strncat( args, argv[i], MAX_ARG_LEN - 1 );
    strcat( args, " " );
  }
  // parse the expression
  expression_parse( args, strnlen( args, MAX_ARGS * MAX_ARG_LEN ) );
  // exit
  return 0;
}
