#include "expression.h"
#include "expression.tab.h"
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>

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

// allocates and initializes a new expression value for a real number
expression_t * new_real( double value ) {
  expression_t * new_expr = (expression_t *)malloc( sizeof(expression_t) );
  new_expr->type = REAL;
  new_expr->value.rval = value;
  return new_expr;
}

// allocates and initializes a new expression value for an integer
expression_t * new_integer( int value ) {
  expression_t * new_expr = (expression_t *)malloc( sizeof(expression_t) );
  new_expr->type = INTEGER;
  new_expr->value.ival = value;
  return new_expr;
}

// combine two expressions to form a new value. dispose the original expressions.
expression_t * combine_expressions( expression_t * op1, expression_t * op2, int opcode ) {
  if ( NULL != op1 && NULL != op2 ) {
    expression_t * new_expr = (expression_t *)malloc( sizeof(expression_t) );
    if ( REAL == op1->type || REAL == op2->type ) {  // if either operand is a real number, produce another real number
      new_expr->type = REAL;
      double value1 = REAL == op1->type ? op1->value.rval : (double)op1->value.ival;
      double value2 = REAL == op2->type ? op2->value.rval : (double)op2->value.ival;
      switch ( opcode ) {
        case PLUS:
          new_expr->value.rval = value1 + value2;
          break;
        case MINUS:
          new_expr->value.rval = value1 - value2;
          break;
        case TIMES:
          new_expr->value.rval = value1 * value2;
          break;
        case DIVIDE:
          new_expr->value.rval = value1 / value2;
          break;
        case POWER:
          new_expr->value.rval = pow( value1, value2 );
          break;
        default:
          new_expr->value.rval = 0;
          break;
      }
    }
    else {
      new_expr->type = INTEGER;
      switch ( opcode ) {
        case PLUS:
          new_expr->value.ival = op1->value.ival + op2->value.ival;
          break;
        case MINUS:
          new_expr->value.ival = op1->value.ival - op2->value.ival;
          break;
        case TIMES:
          new_expr->value.ival = op1->value.ival * op2->value.ival;
          break;
        case DIVIDE:
          new_expr->value.ival = op1->value.ival / op2->value.ival;
          break;
        case MOD:
          new_expr->value.ival = op1->value.ival % op2->value.ival;
          break;
        case POWER:
          new_expr->value.ival = (int)pow( op1->value.ival, op2->value.ival );
          break;
        default:
          break;
      }
    }
    dispose_expression( op1 );
    dispose_expression( op2 );
    return new_expr;
  }
  else return NULL;
}

// dispose an expression
void dispose_expression( expression_t * expr ) {
  if ( NULL != expr ) {
    free( expr );
  }
}

