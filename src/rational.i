// Name of generated bindings:
%module rational_swig

// Include C++ std lib interfaces:
%include "std_string.i"   // python __str__(), __repr__()

// Include C++ declarations as SWIG interface definitions:
%include "rational.h"

// Prepend C++ code in generated bindings:
%{
#include "rational.h"
%}

// Enable access to operators:
%rename(__eq__)       mathlib::rational::operator==;
%rename(__ne__)       mathlib::rational::operator!=;
%rename(__gt__)       mathlib::rational::operator<;
%rename(__ge__)       mathlib::rational::operator<=;
%rename(__lt__)       mathlib::rational::operator>;
%rename(__le__)       mathlib::rational::operator>=;
%rename(__neg__)      mathlib::rational::operator-();
%rename(__add__)      mathlib::rational::operator+;
%rename(__sub__)      mathlib::rational::operator-;
%rename(__mul__)      mathlib::rational::operator*;
%rename(__truediv__)  mathlib::rational::operator/;

// Instantiate a template:
%template(RationalInt) mathlib::rational<int>;
