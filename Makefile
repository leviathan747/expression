CC=gcc
CFLAGS=-Wno-pointer-to-int-cast -Iinclude -Iinclude-gen # -g
SOURCES := $(shell ls src/*.c) src-gen/lex.yy.c src-gen/expression.tab.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE="="

all: src-gen/lex.yy.c src-gen/expression.tab.c include-gen/expression.tab.h $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(CFLAGS) $^ -o $@

.o:
	$(CC) $(CFLAGS) -c $< -o

src-gen/expression.tab.c include-gen/expression.tab.h: src/expression.y
	bison --defines=include-gen/expression.tab.h -o src-gen/expression.tab.c src/expression.y

src-gen/lex.yy.c: src/expression.l include-gen/expression.tab.h
	flex -o src-gen/lex.yy.c src/expression.l

clean:
	rm -f "=" bin/* src-gen/* include-gen/*
