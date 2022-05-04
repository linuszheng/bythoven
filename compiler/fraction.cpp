#include <string>
#include <numeric>
#include <vector>

#include "fraction.h"

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

std::vector<int> split_note(Fraction total) {
    auto it = std::find_if(NOTE_DENOMINATORS.begin(), NOTE_DENOMINATORS.end(),
                           [total](int denom) { return total.get_denominator() == denom; });

    if (it == NOTE_DENOMINATORS.end()) {
        // TODO: make a proper exception
        throw 1;
    }

    return {static_cast<int>(it - NOTE_DENOMINATORS.begin())};
}
