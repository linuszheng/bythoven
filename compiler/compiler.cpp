#include <array>
#include <cstdint>
#include <iomanip>
#include <ios>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

void compile_file(std::string file_name);
std::array<std::uint8_t, 2> process_token(std::istream &cin, std::string token);
std::array<std::uint8_t, 2> process_note(std::string token);
std::array<std::uint8_t, 2> process_end();

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
                for (auto byte : process_token(std::cin, token)) {
                    output_bytes.push_back(byte);
                }
            }
        } catch (...) {
            // TODO: have a specific error for parsing
            std::cerr << "error on line " << line_number << std::endl;
            return;
        }
    }

    std::ios old_config(nullptr);
    old_config.copyfmt(std::cout);

    std::cout << "@0" << std::endl;

    std::cout << std::hex << std::setfill('0');
    for (auto byte : output_bytes) {
        std::cout << std::setw(2) << static_cast<uint16_t>(byte) << std::endl;
    }

    std::cout.copyfmt(old_config);
}

std::array<std::uint8_t, 2> process_token(std::istream &cin, std::string token) {
    if (token == "end") {
        return process_end();
    } else {
        return process_note(token);
    }
}

std::array<std::uint8_t, 2> process_end() {
    return {0x00, 0x00};
}

std::array<std::uint8_t, 2> process_note(std::string token) {
    std::vector<std::vector<std::string>> notes = {
        { "A" },
        { "A#", "Bb" },
        { "B" },
        { "B#", "Cb" },
        { "C" },
        { "C#", "Db" },
        { "D" },
        { "D#", "Eb" },
        { "E" },
        { "E#", "Fb" },
        { "F" },
        { "F#", "Gb" },
        { "G" },
        { "G#", "Ab" }
    };

    auto check = [&token](const auto &options) { 
        return any_of(options.begin(), options.end(), [&token](const std::string &s) { 
            return s == token; 
        }); 
    };

    auto it = std::find_if(notes.begin(), notes.end(), check);

    if (it == notes.end()) {
        throw 0;
    }

    std::uint16_t instr = 0;
    instr += (it - notes.begin()); // bits 3-0 represent the note
    instr += 0b00 << 4;            // bits 6-4 represent the octave
    instr += 1 << 15;              // bit 15 is 1 if it is a note

    std::uint16_t eight_bits = 1 << 8;
    return {static_cast<uint8_t>(instr % eight_bits), static_cast<uint8_t>(instr >> 8)}; 
}
