#!/usr/bin/env tclsh

# Load SWIG bindings:
load target/tcl/mathlib_swig.so Mathlib_swig

# Use SWIG bindings:
puts "MATHLIB_VERSION = ${MATHLIB_VERSION}"
puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]
