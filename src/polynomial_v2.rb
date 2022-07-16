#!/usr/bin/env ruby

require 'polynomial_v2_swig'
PV2 = Polynomial_v2_swig

pp POLYNOMIAL_VERSION: PV2::POLYNOMIAL_VERSION

# Instantiate polynomial<double> object:
poly        = PV2::PolynomialDoubleV2.new
poly.coeffs = PV2::VectorDoubleV2.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
pp poly.coeffs.to_a
pp poly.evaluate(1.2)

# Instantiate polynomial<int> object:
poly        = PV2::PolynomialIntV2.new
poly.coeffs = PV2::VectorIntV2.new([ 2, 3, 5, 7, 11, -13 ])
pp poly.coeffs.to_a
pp poly.evaluate(-2)

# Instantiate polynomial<rational<int>> object:
poly        = PV2::PolynomialRationalV2.new()
poly.coeffs = PV2::VectorRationalV2.new([ PV2::RationalV2.new(7, 11), PV2::RationalV2.new(11, 13), PV2::RationalV2.new(13,17) ])
pp poly.coeffs.to_a
pp poly.evaluate(PV2::RationalV2.new(5, 7))
