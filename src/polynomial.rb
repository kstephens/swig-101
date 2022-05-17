#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'polynomial_swig'
include Polynomial_swig

pp POLYNOMIAL_VERSION: POLYNOMIAL_VERSION

p = Polynomial.new
p.coeffs = VectorDouble.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])

pp p.coeffs.to_a
pp p.evaluate(1.2)
