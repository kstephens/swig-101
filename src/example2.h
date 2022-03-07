#ifdef SWIG
%module example2
%include std_vector.i
%template(VectorDouble) std::vector<double>;
%{
#include "example2.h"
%}
#endif

#include <vector>

class Polynomial {
 public:
  std::vector<double> coeffs;
  double evaluate(double x);
};

