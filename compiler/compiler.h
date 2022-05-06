#ifndef COMPILER_H
#define COMPILER_H

#include <array>
#include <cstdint>
#include <string>
#include <vector>

class Compiler {
private:
    enum VolumeLevel {
        MUTE = 0,
        PIANO = 1,
        MEZZO_FORTE = 2,
        FORTISSIMO = 3
    };

    enum StyleType {
        NOTHING = 0,
        STACCATO = 1,
        NORMAL = 2,
        SUSTAIN = 3
    };

    std::vector<std::string> block_tokens;
    VolumeLevel cur_volume;
    StyleType cur_style;

    int next_instruction_address;
    std::vector<int> repeat_address;
    std::vector<int> repeat_count;
    int repeat_level;

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

    // Constants for repeating
    constexpr static int MIN_REPEAT_COUNT = 1;
    constexpr static int MAX_REPEAT_COUNT = 1 << 3;

    constexpr static int MAX_REPEAT_LEVEL = 1 << 3;

    constexpr static int REPEAT_HIGH_OPCODE = 0b0010;
    constexpr static int REPEAT_HIGH_OPCODE_SHIFT = 12;
    constexpr static int REPEAT_HIGH_ADDR_SHIFT = 0;

    constexpr static int REPEAT_LOW_OPCODE = 0b0011;
    constexpr static int REPEAT_LOW_OPCODE_SHIFT = 12;
    constexpr static int REPEAT_LOW_ADDR_SHIFT = 6;
    constexpr static int REPEAT_LOW_LEVEL_SHIFT = 3;
    constexpr static int REPEAT_LOW_COUNT_SHIFT = 0;

    // Helper methods
    int get_note(std::string token);
    int get_octave(std::string token, std::istream &in);
    int get_volume(std::string token);
    int get_style();
    int get_duration(std::istream &in);

    std::array<std::uint8_t, 2> split_instr(std::uint16_t instr);

public:
    Compiler();

    void compile_file(std::string file_name);
    std::vector<std::uint16_t> process_token(std::istream &in, std::string token);
    std::vector<std::uint16_t> process_end();
    std::vector<std::uint16_t> process_bpm(std::istream &in);
    std::vector<std::uint16_t> process_note(std::istream &in, std::string token);

    void set_volume(std::string token);
    void set_style(std::istream &in, std::string token);
    void set_repeat_block(std::istream &in);

    void read_open_brace(std::istream &in);
    std::vector<std::uint16_t> process_close_brace();
};

#endif /* COMPILER_H */
