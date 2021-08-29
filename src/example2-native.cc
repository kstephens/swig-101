#include <iostream>
#include "example2.h"

int main(int argc, char **argv) {
  polynomial p;
  p.add_coeff(3.5);
  p.add_coeff(7.11);
  p.add_coeff(13.17);
  p.add_coeff(19.23);
  std::cout.precision(17);
  std::cout << p.evaluate(2.3) << "\n";
  return 0;
}
