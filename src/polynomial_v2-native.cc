#include <iostream>
#include <iomanip>
#include "polynomial_v2.h"
#include "rational.h"
#include <complex>

using namespace mathlib;

int main(int argc, char **argv) {
  std::cout << "POLYNOMIAL_VERSION = " << POLYNOMIAL_VERSION << "\n";

  polynomial<double> pd;
  pd.coeffs = { 3, 5.0, 7.0, 11.0 };
  std::cout << pd.evaluate(2) << "\n";

  polynomial<int> pi;
  pi.coeffs = { 2, 3, 5, 7, 11, -13 };
  std::cout << pi.evaluate(-2) << "\n";

  typedef rational<int> R;
  polynomial<R> pr;
  pr.coeffs = { R(7, 11), R(11, 13), R(13, 17) };
  std::cout << pr.evaluate(R(-5, 7)) << "\n";

  typedef std::complex<double> C;
  polynomial<C> pc;
  pc.coeffs = { C(7.2, 11.3), C(11.5, 13.7), C(13.11, 17.13) };
  std::cout << pc.evaluate(C(-5.7, 7.11)) << "\n";

  return 0;
}
