#!/usr/bin/env python3.10

import sys ; sys.path.append('target/python')

from polynomial_v2_swig import *

print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})

coeffs = [ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ]
poly         = PolynomialDoubleV2()
poly.coeffs  = VectorDoubleV2(coeffs)
print(list(poly.coeffs))
print(poly.evaluate(1.2))

coeffs = [ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13,17) ]
poly         = PolynomialRationalV2()
poly.coeffs  = VectorRationalV2(coeffs)
print(list(poly.coeffs))
print(poly.evaluate(RationalV2(5, 7)))
