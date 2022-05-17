#!/usr/bin/env python3.10

import sys ; sys.path.append('target/python')

from polynomial_v2_swig import PolynomialDoubleV2, VectorDoubleV2, PolynomialRationalV2, VectorRationalV2, RationalV2, POLYNOMIAL_VERSION

print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})

poly = PolynomialDoubleV2()
poly.coeffs = VectorDoubleV2([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
print(list(poly.coeffs))
print(poly.evaluate(1.2))

poly = PolynomialRationalV2()
poly.coeffs = VectorRationalV2([ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13,17) ])
print(list(poly.coeffs))
print(poly.evaluate(RationalV2(5, 7)))

