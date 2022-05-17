// Name of generated bindings:
%module polynomial_v2_swig

// Include C++ declarations as SWIG interface definitions:
%include "polynomial_v2.h"
%include "rational.h"

// Template instantiation:
%{
#include "polynomial_v2.h"
#include "rational.h"

template class mathlib::polynomial<int>;
template class mathlib::polynomial<double>;
template class mathlib::rational<int>;
template class mathlib::polynomial<mathlib::rational<int>>;
template class std::vector<mathlib::rational<int>>;
%}

%include "std_string.i"        // python __str__(), __repr__()
%template(RationalV2)            mathlib::rational<int>;

%include "std_vector.i"
%template(VectorDoubleV2)        std::vector<double>;
%template(VectorIntV2)           std::vector<int>;
%template(VectorRationalV2)      std::vector<mathlib::rational<int>>;

%template(PolynomialDoubleV2)    mathlib::polynomial<double>;
%template(PolynomialIntV2)       mathlib::polynomial<int>;
%template(PolynomialRationalV2)  mathlib::polynomial<mathlib::rational<int>>;

// Prepend C++ code in generated bindings:
%{
#include "polynomial_v2.h"
#include "rational.h"
%}
