#!/usr/bin/env tclsh

# Load SWIG bindings:
load target/tcl/example1_swig.so Example1_swig

# Use SWIG bindings:
puts "EXAMPLE1_VERSION = ${EXAMPLE1_VERSION}"
puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]
