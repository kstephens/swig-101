#!/usr/bin/env tclsh

load target/tcl/polynomial_swig.so Polynomial_swig

Polynomial poly
VectorDouble c { 2.0 3.0 5.0 7.0 11.0 -13.0 }
poly configure -coeffs c

puts "POLYNOMIAL_VERSION = ${POLYNOMIAL_VERSION}"
puts [poly cget -coeffs]
puts [poly evaluate 2.0]

