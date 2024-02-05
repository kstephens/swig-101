#!/usr/bin/env ruby

# Setup search path:
ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

# Load SWIG bindings:
require 'mathlib_swig'
include Mathlib_swig

# Use SWIG bindings:
puts "MATHLIB_VERSION = #{MATHLIB_VERSION.inspect}"
puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)

