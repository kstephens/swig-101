#!/usr/bin/env tclsh

load target/tcl/polynomial_swig.so Polynomial_swig

puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]

Polynomial poly

VectorDouble c { 3 5.0 7.0 11.0 }
poly configure -coeffs c
puts [poly cget -coeffs]
puts [poly evaluate 2]

VectorDouble c { 2.3 3.5 5.7 7.11 11.13 -13.17 }
poly configure -coeffs c
puts [poly cget -coeffs]
puts [poly evaluate 1.2]
