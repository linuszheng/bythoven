#include <array>
#include <cstdint>
#include <iomanip>
#include <ios>
#include <iostream>
#include <fstream>
#include <optional>
#include <string>
#include <sstream>
#include <vector>

#include "compiler.h"
#include "notes.h"

int main(int argc, char **argv) {
    if (argc <= 1) {
        std::cerr << "Usage: ./compiler <file>" << std::endl;
        return 1;
    }

    std::string file_name(argv[1]);
    compile_file(file_name);

    return 0;
}

void compile_file(std::string file_name) {
    std::ifstream source(file_name);
    std::vector<std::uint8_t> output_bytes;

    std::string current_line, token;
    int line_number = 1;

    while (std::getline(source, current_line)) {
        std::stringstream ss(current_line);
        try {
            while (ss >> token) {
                for (auto byte : process_token(ss, token)) {
                    output_bytes.push_back(byte);
                }
            }
        } catch (...) {
            // TODO: have a specific error for parsing
            std::cerr << "error on line " << line_number << std::endl;
            return;
        }

        line_number++;
    }

    std::ios old_config(nullptr);
    old_config.copyfmt(std::cout);

    std::cout << std::hex << std::setfill('0');
    for (auto byte : output_bytes) {
        // casting here so it is not treated as an int
        std::cout << std::setw(2) << static_cast<uint16_t>(byte);
    }

    std::cout.copyfmt(old_config);
}

std::array<std::uint8_t, 2> process_token(std::istream &in, std::string token) {
    if (token == "end") {
        return process_end();
    } else {
        return process_note(in, token);
    }
}

std::array<std::uint8_t, 2> process_end() {
    return {0x00, 0x00};
}

