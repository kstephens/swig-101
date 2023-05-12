#include <iostream>
#include <iomanip>
#include "polynomial.h"

int main(int argc, char **argv) {
  std::cout << "POLYNOMIAL_VERSION = \"" << POLYNOMIAL_VERSION << "\"\n";

  Polynomial p;

  p.coeffs = { 3, 5.0, 7.0, 11.0 };
  std::cout << std::setprecision(9) << p.evaluate(2) << "\n";

  p.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };
  std::cout << std::setprecision(9) << p.evaluate(1.2) << "\n";

  return 0;
}
