#include <array>
#include <algorithm>
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
#include "fraction.h"

const std::array<std::vector<std::string>, 12> Compiler::NOTES = {
    std::vector<std::string>{ "B#", "C" },
    std::vector<std::string>{ "C#", "Db" },
    std::vector<std::string>{ "D" },
    std::vector<std::string>{ "D#", "Eb" },
    std::vector<std::string>{ "E", "Fb" },
    std::vector<std::string>{ "F", "E#" },
    std::vector<std::string>{ "F#", "Gb" },
    std::vector<std::string>{ "G" },
    std::vector<std::string>{ "G#", "Ab" },
    std::vector<std::string>{ "A" },
    std::vector<std::string>{ "A#", "Bb" },
    std::vector<std::string>{ "B", "Cb" }
};

Compiler::Compiler() : cur_volume(MEZZO_FORTE) {}

void Compiler::compile_file(std::string file_name) {
    std::ifstream source(file_name);
    std::vector<std::uint8_t> output_bytes;

    std::string current_line, token;
    int line_number = 1;

    while (std::getline(source, current_line)) {
        std::stringstream ss(current_line);
        try {
            while (ss >> token) {
                auto data = process_token(ss, token);
                if (data) {
                    for (auto byte : *data) {
                        output_bytes.push_back(byte);
                    }
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

std::optional<std::array<std::uint8_t, 2>> Compiler::process_token(std::istream &in, std::string token) {
    if (token == "p" || token == "mf" || token == "ff") {
        set_volume(token);
        return {};
    } else if (token == "end") {
        return process_end();
    } else if (token == "bpm") {
        return process_bpm(in);
    } else {
        return process_note(in, token);
    }
}

std::array<std::uint8_t, 2> Compiler::process_end() {
    return {0x00, 0x00};
}

std::array<std::uint8_t, 2> Compiler::process_bpm(std::istream &in) {
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

int Compiler::get_note(std::string token) {
    // special case, the exact value does not matter
    if (token == "rest") {
        return 0;
    }

    auto check = [&token](const auto &options) { 
        return any_of(options.begin(), options.end(), [&token](const std::string &s) { 
            return s == token; 
        }); 
    };

    auto it = std::find_if(NOTES.begin(), NOTES.end(), check);

    if (it == NOTES.end()) {
        throw 0;
    }

    return it - NOTES.begin();
}

int Compiler::get_octave(std::string token, std::istream &in) {
    // no octave is given for a rest, so skip reading
    if (token == "rest") {
        return 0;
    }

    int octave;
    in >> octave;

    // TODO: use proper exceptions
    if (in.fail()) throw 1;
    if (octave < MIN_OCTAVE || octave > MAX_OCTAVE) throw 1;

    // normalize to 0 for storage
    return octave - MIN_OCTAVE;
}

int Compiler::get_volume(std::string token) {
    // rest is just a note with 0 volume
    if (token == "rest") {
        return 0;
    }

    return cur_volume;
}

int Compiler::get_duration(std::istream &in) {
    Fraction length;
    in >> length;

    int note_idx = get_fraction_index(length);
    return note_idx;
}

std::array<std::uint8_t, 2> Compiler::process_note(std::istream &in, std::string token) {
    int note = get_note(token);
    int octave = get_octave(token, in);
    int volume = get_volume(token);
    int length = get_duration(in);
    int style = 0;
    int opcode = 1;

    std::uint16_t instr = 0;
    instr += note << NOTE_SHIFT;
    instr += octave << NOTE_OCTAVE_SHIFT;
    instr += volume << NOTE_VOLUME_SHIFT;
    instr += length << NOTE_LENGTH_SHIFT;
    instr += style << NOTE_STYLE_SHIFT;
    instr += opcode << NOTE_OPCODE_SHIFT;

    uint16_t eight_bits = 1 << 8;
    return std::array<uint8_t, 2>{static_cast<uint8_t>(instr % eight_bits), static_cast<uint8_t>(instr / eight_bits)};
}

void Compiler::set_volume(std::string token) {
    if (token == "p") {
        cur_volume = PIANO;
    } else if (token == "mf") {
        cur_volume = MEZZO_FORTE;
    } else if (token == "ff") {
        cur_volume = FORTISSIMO;
    } else {
        // TODO: add actual error
        throw 1;
    }
}
