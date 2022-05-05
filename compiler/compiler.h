#ifndef COMPILER_H
#define COMPILER_H

#include <array>
#include <cstdint>
#include <string>
#include <vector>

class Compiler {
private:
    // Constants for BPM
    constexpr static int MAX_BPM = 1 << 12;
    constexpr static int BPM_SHIFT = 0;
    constexpr static int BPM_OPCODE_SHIFT = 12;
    constexpr static int BPM_OPCODE = 0b0001;

    // Constants for notes
    const static std::array<std::vector<std::string>, 12> NOTES;
    constexpr static int MIN_OCTAVE = 2;
    constexpr static int MAX_OCTAVE = 5;

    constexpr static int NOTE_SHIFT = 0;
    constexpr static int NOTE_OCTAVE_SHIFT = 4;
    constexpr static int NOTE_VOLUME_SHIFT = 6;
    constexpr static int NOTE_LENGTH_SHIFT = 8;
    constexpr static int NOTE_STYLE_SHIFT = 12;
    constexpr static int NOTE_OPCODE_SHIFT = 15;

    // Helper methods
    int get_note(std::string token);
    int get_octave(std::string token, std::istream &in);
    int get_volume(std::string token);
    int get_duration(std::istream &in);

public:
    void compile_file(std::string file_name);
    std::array<std::uint8_t, 2> process_token(std::istream &in, std::string token);
    std::array<std::uint8_t, 2> process_end();
    std::array<std::uint8_t, 2> process_bpm(std::istream &in);
    std::array<std::uint8_t, 2> process_note(std::istream &in, std::string token);
};

#endif /* COMPILER_H */
