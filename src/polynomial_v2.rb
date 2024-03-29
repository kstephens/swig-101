#!/usr/bin/env ruby

require 'polynomial_v2_swig'
PV2 = Polynomial_v2_swig

puts "POLYNOMIAL_VERSION = #{PV2::POLYNOMIAL_VERSION}"

# polynomial<double>:
poly        = PV2::PolynomialDoubleV2.new
poly.coeffs = PV2::VectorDoubleV2.new([ 3, 5.0, 7.0, 11.0 ])
pp poly.coeffs.to_a
pp poly.evaluate(2)

# polynomial<int>
poly        = PV2::PolynomialIntV2.new
poly.coeffs = PV2::VectorIntV2.new([ 2, 3, 5, 7, 11, -13 ])
pp poly.coeffs.to_a
pp poly.evaluate(-2)

# polynomial<rational<int>>:
poly        = PV2::PolynomialRationalV2.new()
poly.coeffs = PV2::VectorRationalV2.new([ PV2::RationalInt.new(7, 11), PV2::RationalInt.new(11, 13), PV2::RationalInt.new(13,17) ])
pp poly.coeffs.to_a
pp poly.evaluate(PV2::RationalInt.new(-5, 7))

# polynomial<complex<double>>
poly        = PV2::PolynomialComplexV2.new()
poly.coeffs = PV2::VectorComplexV2.new([ 7.2+11.3i, 11.5+13.7i, 13.11+17.13i ])
pp poly.coeffs.to_a
pp poly.evaluate(-5.7+7.11i)
