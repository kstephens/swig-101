#include <iostream>
#include "example2.h"

int main(int argc, char **argv) {
  Polynomial p;
  p.coeffs = { 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 };
  std::cout << p.evaluate(2.0) << std::endl;
  return 0;
}
