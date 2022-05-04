B=build
CXX=g++
CXXFLAGS=-Werror -Wall -O2 -std=c++17

CXX_FILES=${wildcard *.cpp}
CXX_O_FILES=${addprefix $B/,${subst .cpp,.o,${CXX_FILES}}}

all: $B/compiler

$B/compiler: ${CXX_O_FILES}
	@mkdir -p $B
	${CXX} ${CXXFLAGS} ${CXX_O_FILES} -o $B/compiler 
		
${CXX_O_FILES}: $B/%.o: %.cpp
	@mkdir -p $B
	${CXX} ${CXXFLAGS} -c $*.cpp -o $@

clean:
	rm -rf $B
