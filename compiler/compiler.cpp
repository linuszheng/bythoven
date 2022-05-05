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

constexpr static int MAX_BPM = 1 << 12;
constexpr static int BPM_SHIFT = 0;
constexpr static int BPM_OPCODE_SHIFT = 12;
constexpr static int BPM_OPCODE = 0b0001;

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
    } else if (token == "bpm") {
        return process_bpm(in);
    } else {
        return process_note(in, token);
    }
}

std::array<std::uint8_t, 2> process_end() {
    return {0x00, 0x00};
}

std::array<std::uint8_t, 2> process_bpm(std::istream &in) {
    int bpm;
    in >> bpm;

    // TODO: add a specific error
    if (in.fail()) throw 1;
    if (bpm < 0 || bpm >= MAX_BPM) throw 1;

    std::uint16_t instr = 0;
    instr += bpm << BPM_SHIFT;
    instr += BPM_OPCODE << BPM_OPCODE_SHIFT;

    uint16_t eight_bits = 1 << 8;
    return std::array<uint8_t, 2>{static_cast<uint8_t>(instr % eight_bits), static_cast<uint8_t>(instr / eight_bits)};
}
