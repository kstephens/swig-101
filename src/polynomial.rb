#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'polynomial_swig'
include Polynomial_swig

p = Polynomial.new
p.coeffs = VectorDouble.new([2.0, 3.0, 5.0, 7.0, 11.0, -13.0])

pp POLYNOMIAL_VERSION: POLYNOMIAL_VERSION
pp p.coeffs.to_a
pp p.evaluate(2.0)
