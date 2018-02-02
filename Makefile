CC=gcc
CFLAGS=# -g
YFLAGS=# --verbose
EXECUTABLE="="

all: $(EXECUTABLE)

$(EXECUTABLE): parser lexer bin/expression.o bin/expression.tab.o bin/lex.yy.o
	$(CC) $(CFLAGS) bin/*.o -o $@

bin/expression.o: src/expression.c
	$(CC) $(CFLAGS) -Iinclude -Iinclude-gen -c src/expression.c -o bin/expression.o

bin/expression.tab.o: src-gen/expression.tab.c
	$(CC) $(CFLAGS) -Iinclude -Iinclude-gen -c src-gen/expression.tab.c -o bin/expression.tab.o

bin/lex.yy.o: src-gen/lex.yy.c
	$(CC) $(CFLAGS) -Iinclude -Iinclude-gen -c src-gen/lex.yy.c -o bin/lex.yy.o

parser: src/expression.y
	bison $(YFLAGS) --defines=include-gen/expression.tab.h -o src-gen/expression.tab.c src/expression.y

lexer: parser
	flex -o src-gen/lex.yy.c src/expression.l

clean:
	rm -f "=" bin/* src-gen/* include-gen/*

%.c: %.y
%.c: %.l
