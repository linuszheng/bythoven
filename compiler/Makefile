B = build
CC = g++
CFLAGS = -Werror -Wall -O2 -std=c++17

all: $B/compiler

$B/compiler:
	@mkdir -p $B
	${CC} ${CFLAGS} compiler.cpp -o $B/compiler

clean:
	rm -rf $B
