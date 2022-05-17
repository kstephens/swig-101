#include <iostream>
#include <iomanip>
#include "polynomial_v2.h"
#include "rational.h"

using namespace mathlib;

int main(int argc, char **argv) {
  std::cout << "POLYNOMIAL_VERSION " << POLYNOMIAL_VERSION << "\n";

  polynomial<double> pd;
  pd.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };
  std::cout << std::setprecision(9) << pd.evaluate(1.2) << "\n";
  
  polynomial<int> pi;
  pi.coeffs = { 2, -3, 5 };
  std::cout << pi.evaluate(3) << "\n";

  typedef rational<int> R;
  polynomial<R> pr;
  pr.coeffs = { R(7,11), R(11,13), R(13,17) };
  std::cout << pr.evaluate(R(5,7)) << "\n";

  return 0;
}
