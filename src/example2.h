#ifdef SWIG
%module example2
%{
#include "example2.h"
%}
#endif

#include <vector>

class polynomial {
 public:
  std::vector<double> coeffs;
  void add_coeff(double c);
  double evaluate(double x);
};

