%module polynomial
%include "std_vector.i"
%template(VectorDouble) std::vector<double>;
%include "polynomial.h"
%{
#include "polynomial.h"
%}
