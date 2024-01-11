#include "rational.h"
#include <iostream>

int main(int argc, char **argv) {
  mathlib::rational<int> a(2, 3), b(5, 6);
#define P(x) std::cout << #x << " = " << (x) << "\n"
  P(a);
  P(b);
  P(a + b);
  P(a * b);
  P(a > b);
  return 0;
}

