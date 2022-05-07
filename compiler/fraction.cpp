#include <string>
#include <numeric>
#include <vector>
#include <algorithm>

#include "fraction.h"
#include "parse_exception.h"

Fraction::Fraction() : Fraction(0, 1) {}

Fraction::Fraction(int numerator, int denominator) : numerator(numerator), denominator(denominator) {
    int gcd = std::gcd(numerator, denominator);
    numerator /= gcd;
    denominator /= gcd;
}

bool Fraction::operator==(Fraction other) const {
    return numerator * other.denominator == denominator * other.numerator;
}

bool Fraction::operator<(Fraction other) const {
    return numerator * other.denominator < denominator * other.numerator;
}

int Fraction::get_numerator() const {
    return numerator;
}

int Fraction::get_denominator() const {
    return denominator;
}

std::istream &operator>>(std::istream &in, Fraction &fraction) {
    // TODO: make a proper exception
    in >> fraction.numerator;
    if (in.fail()) throw 1;

    char slash;
    in >> slash;
    if (slash != '/') throw 1;

    in >> fraction.denominator;
    if (in.fail()) throw 1;

    return in;
}

int get_fraction_index(Fraction total) {
    auto it = std::find_if(NOTE_DENOMINATORS.begin(), NOTE_DENOMINATORS.end(),
                           [total](int denom) { return total.get_denominator() == denom; });

    if (total.get_numerator() != 1 || it == NOTE_DENOMINATORS.end()) {
        throw ParseException("invalid note length");
    }

    return static_cast<int>(it - NOTE_DENOMINATORS.begin());
}
