#include <iostream>
#include "example2.h"

int main(int argc, char **argv) {
  polynomial p;
  p.coeffs.push_back(3.5);
  p.coeffs.push_back(7.11);
  p.coeffs.push_back(13.17);
  p.coeffs.push_back(19.23);
  std::cout.precision(16);
  std::cout << p.evaluate(2.3) << "\n";
  return 0;
}
