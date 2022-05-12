#include <iostream>
#include "polynomial.h"

int main(int argc, char **argv) {
  Polynomial p;
  p.coeffs = { 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 };
  std::cout << "POLYNOMIAL_VERSION = " << POLYNOMIAL_VERSION << std::endl;
  std::cout << p.evaluate(2.0) << std::endl;
  return 0;
}
