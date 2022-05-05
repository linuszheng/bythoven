#include <iostream>
#include <string>

#include "compiler.h"

int main(int argc, char **argv) {
    if (argc <= 1) {
        std::cerr << "Usage: ./bythoven <file>" << std::endl;
        return 1;
    }

    std::string file_name(argv[1]);

    Compiler compiler;
    compiler.compile_file(file_name);

    return 0;
}

