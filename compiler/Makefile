B=build
CXX=g++
CXXFLAGS=-Werror -Wall -O2 -std=c++17

all: $B/compiler

$B/compiler: compiler.cpp compiler.h
	@mkdir -p $B
	${CXX} ${CXXFLAGS} compiler.cpp -o $B/compiler

clean:
	rm -rf $B
