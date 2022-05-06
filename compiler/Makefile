B=build
CXX=g++
CXXFLAGS=-Werror -Wall -O2 -std=c++17

CXX_FILES=${wildcard *.cpp}
CXX_O_FILES=${addprefix $B/,${subst .cpp,.o,${CXX_FILES}}}

all: $B/bythoven

$B/bythoven: ${CXX_O_FILES} Makefile
	@mkdir -p $B
	${CXX} ${CXXFLAGS} ${CXX_O_FILES} -o $B/bythoven

${CXX_O_FILES}: $B/%.o: %.cpp Makefile
	@mkdir -p $B
	${CXX} ${CXXFLAGS} -c $*.cpp -o $@

clean:
	rm -rf $B
