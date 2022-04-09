%module example2
%include std_vector.i
%template(VectorDouble) std::vector<double>;
%include "example2.h"
%{
#include "example2.h"
%}
