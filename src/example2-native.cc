#include <iostream>
#include "example2.h"

int main(int argc, char **argv) {
  polynomial p;
  p.coeffs.push_back(3.0);
  p.coeffs.push_back(5.0);
  p.coeffs.push_back(7.0);
  p.coeffs.push_back(11.0);
  p.coeffs.push_back(-13.0);
  std::cout << p.evaluate(2.0) << "\n";
  return 0;
}
