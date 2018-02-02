// global data
extern int expression_parse_error;

// parse function
void expression_parse( char * input, int length );

// expression node type
typedef struct {
  int type;
  union {
    int    ival;
    double rval;
  } value;
} expression_t;

// expression API
expression_t * new_real( double value );
expression_t * new_integer( int value );
expression_t * combine_expressions( expression_t * op1, expression_t * op2, int opcode );
void dispose_expression( expression_t * expr );
