#!/usr/bin/env tclsh

load target/tcl/polynomial_v2_swig.so Polynomial_v2_swig

puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]

# Instantiate polynomial<double> object:
PolynomialDoubleV2 poly
VectorDoubleV2 c { 2.3 3.5 5.7 7.11 11.13 -13.17 }
poly configure -coeffs c
puts [poly cget -coeffs]
puts [poly evaluate 1.2]

# Instantiate polynomial<int> object:
PolynomialIntV2 poly
VectorIntV2 c { 2 3 5 7 11 -13 }
poly configure -coeffs c
puts [poly cget -coeffs]
puts [poly evaluate -2]

# Instantiate polynomial<rational<int>> object:
PolynomialRationalV2 poly
VectorRationalV2 c [list [new_RationalV2 7 11] [new_RationalV2 11 13] [new_RationalV2 13 17]]
poly configure -coeffs c
puts [poly cget -coeffs]
puts [RationalV2___repr__  [poly evaluate [new_RationalV2 5 7]]]
