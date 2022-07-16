#!/usr/bin/env python3.10

from polynomial_v2_swig import *

print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})

# Instantiate polynomial<double> object:
poly         = PolynomialDoubleV2()
poly.coeffs  = VectorDoubleV2([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
print(list(poly.coeffs))
print(poly.evaluate(1.2))

# Instantiate polynomial<int> object:
poly        = PolynomialIntV2()
poly.coeffs = VectorIntV2([ 2, 3, 5, 7, 11, -13 ])
print(list(poly.coeffs))
print(poly.evaluate(-2))

# Instantiate polynomial<rational<int>> object:
poly        = PolynomialRationalV2()
poly.coeffs = VectorRationalV2([ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13,17) ])
print(list(poly.coeffs))
print(poly.evaluate(RationalV2(5, 7)))
