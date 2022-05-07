#include <exception>
#include <string>
#include "parse_exception.h"

ParseException::ParseException(std::string message) : message(message) {}

const char *ParseException::what() const noexcept {
    return message.c_str();
}
