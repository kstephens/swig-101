// Name of generated bindings:
%module polynomial_v2_swig

// Include C++ std lib interfaces:
%include "std_string.i"   // python __str__(), __repr__()
%include "std_vector.i"   // std::vector<T>

// Include C++ declarations as SWIG interface definitions:
%include "polynomial_v2.h"
%include "rational.i"     // python __eq__(), __add__(), etc.

// Prepend C++ code in generated bindings:
%{
#include "polynomial_v2.h"
#include "rational.h"
%}

%template(RationalV2)            mathlib::rational<int>;
%template(VectorDoubleV2)        std::vector<double>;
%template(VectorIntV2)           std::vector<int>;
%template(VectorRationalV2)      std::vector<mathlib::rational<int>>;
%template(PolynomialDoubleV2)    mathlib::polynomial<double>;
%template(PolynomialIntV2)       mathlib::polynomial<int>;
%template(PolynomialRationalV2)  mathlib::polynomial<mathlib::rational<int>>;

// std::complex<double>:
#if SWIGPYTHON || SWIGRUBY
%include "std_complex.i"  // std::complex<double>
%template(ComplexV2)             std::complex<double>;
%template(VectorComplexV2)       std::vector<std::complex<double>>;
%template(PolynomialComplexV2)   mathlib::polynomial<std::complex<double>>;
#endif
