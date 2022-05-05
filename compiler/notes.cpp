#include <array>
#include <cstdint>
#include <iostream>
#include <string>
#include <vector>

#include "fraction.h"

const static std::array<std::vector<std::string>, 12> NOTES = {
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

constexpr static int MIN_OCTAVE = 2;
constexpr static int MAX_OCTAVE = 5;

// bit shifts for instruction
constexpr static int NOTE_SHIFT = 0;
constexpr static int OCTAVE_SHIFT = 4;
constexpr static int VOLUME_SHIFT = 6;
constexpr static int LENGTH_SHIFT = 8;
constexpr static int STYLE_SHIFT = 12;
constexpr static int OPCODE_SHIFT = 15;

static int get_note(std::string token);
static int get_octave(std::string token, std::istream &in);
static int get_volume(std::string token);
static int get_duration(std::istream &in);

int get_note(std::string token) {
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

int get_octave(std::string token, std::istream &in) {
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

int get_volume(std::string token) {
    // rest is just a note with 0 volume
    if (token == "rest") {
        return 0;
    }

    // default volume
    return 2;
}

int get_duration(std::istream &in) {
    Fraction length;
    in >> length;

    int note_idx = get_fraction_index(length);
    return note_idx;
}

std::array<std::uint8_t, 2> process_note(std::istream &in, std::string token) {
    int note = get_note(token);
    int octave = get_octave(token, in);
    int volume = get_volume(token);
    int length = get_duration(in);
    int style = 0;
    int opcode = 1;

    std::uint16_t instr = 0;
    instr += note << NOTE_SHIFT;
    instr += octave << OCTAVE_SHIFT;
    instr += volume << VOLUME_SHIFT;
    instr += length << LENGTH_SHIFT;
    instr += style << STYLE_SHIFT;
    instr += opcode << OPCODE_SHIFT;

    uint16_t eight_bits = 1 << 8;
    return std::array<uint8_t, 2>{static_cast<uint8_t>(instr % eight_bits), static_cast<uint8_t>(instr / eight_bits)};
}
