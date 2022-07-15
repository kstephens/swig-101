#include "polynomial.h"

double Polynomial::evaluate(double x) const {
  double result = 0, xx = 1;
  for ( auto c : this->coeffs ) {
    result = result + c * xx;
    xx = xx * x;
  }
  return result;
}

