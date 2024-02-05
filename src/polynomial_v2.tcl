#!/usr/bin/env tclsh

load target/tcl/polynomial_v2_swig.so Polynomial_v2_swig

puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]

# polynomial<double>:
PolynomialDoubleV2 poly
VectorDoubleV2 c { 3 5.0 7.0 11.0 }
poly configure -coeffs c
puts [poly cget -coeffs]
puts [poly evaluate 2]

# polynomial<int>:
PolynomialIntV2 poly
VectorIntV2 c { 2 3 5 7 11 -13 }
poly configure -coeffs c
puts [poly cget -coeffs]
puts [poly evaluate -2]

# polynomial<rational<int>>:
PolynomialRationalV2 poly
VectorRationalV2 c [list [new_RationalInt 7 11] [new_RationalInt 11 13] [new_RationalInt 13 17]]
poly configure -coeffs c
puts [poly cget -coeffs]
puts [RationalInt___repr__ [poly evaluate [new_RationalInt -5 7]]]
