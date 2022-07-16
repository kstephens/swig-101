#!/usr/bin/env ruby

# Setup search path:
ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

# Load SWIG bindings:
require 'example1_swig'
include Example1_swig

# Use SWIG bindings:
puts "EXAMPLE1_VERSION = #{EXAMPLE1_VERSION}"
puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)

