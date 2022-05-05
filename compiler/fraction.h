#ifndef FRACTION_H
#define FRACTION_H

#include <iostream>
#include <array>
#include <string>
#include <vector>

constexpr std::array<int, 16> NOTE_DENOMINATORS = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 16, 24, 32, 64};

class Fraction {
private:
    int numerator;
    int denominator;

public:
    Fraction();
    Fraction(int numerator, int denominator);
    bool operator==(Fraction other) const;
    bool operator<(Fraction other) const;
    int get_numerator() const;
    int get_denominator() const;
    friend std::istream &operator>>(std::istream &in, Fraction &fraction);
};

int get_fraction_index(Fraction total);

#endif /* FRACTION_H */
