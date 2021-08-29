#include "example2.h"

double polynomial::evaluate(double x) {
  double result = 0, xx = 1;
  for ( auto c : this->coeffs ) {
    result += c * xx;
    xx *= x;
  }
  return result;
}

