#!/usr/bin/env ruby

require 'polynomial_swig'
include Polynomial_swig

pp POLYNOMIAL_VERSION: POLYNOMIAL_VERSION

# Instantiate object:
p = Polynomial.new
p.coeffs = VectorDouble.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])

# Invoke methods:
pp p.coeffs.to_a
pp p.evaluate(1.2)
