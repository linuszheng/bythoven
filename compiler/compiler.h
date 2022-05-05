#include <array>
#include <cstdint>
#include <string>

void compile_file(std::string file_name);
std::array<std::uint8_t, 2> process_token(std::istream &in, std::string token);
std::array<std::uint8_t, 2> process_end();
std::array<std::uint8_t, 2> process_bpm(std::istream &in);

