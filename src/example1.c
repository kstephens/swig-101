#include "example1.h"

double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  return c0 + (x * c1) + (x * x * c2) + (x * x * x * c3);
}

