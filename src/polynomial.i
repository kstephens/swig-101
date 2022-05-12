// Name of generated bindings:
%module polynomial_swig

// Include std::vector<T> support:
%include "std_vector.i"

// Template instantiation:
%template(VectorDouble) std::vector<double>;

// Include C++ declarations as SWIG interface definitions:
%include "polynomial.h"

// Prepend C++ code in generated bindings:
%{
#include "polynomial.h"
%}
