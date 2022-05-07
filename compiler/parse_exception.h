#ifndef PARSE_EXCEPTION_H
#define PARSE_EXCEPTION_H

#include <exception>
#include <string>

// Exception for parsing 
class ParseException : public std::exception {
private:
    std::string message;

public:
    ParseException(std::string message);
    virtual const char *what() const noexcept;
};

#endif /* PARSE_EXCEPTION_H */
