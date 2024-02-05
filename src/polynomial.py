#!/usr/bin/env python3.10

from polynomial_swig import *

print(f'POLYNOMIAL_VERSION = {POLYNOMIAL_VERSION}')

poly = Polynomial()

poly.coeffs = VectorDouble([ 3, 5.0, 7.0, 11.0 ])
print(list(poly.coeffs))
print(poly.evaluate(2))

poly.coeffs = VectorDouble([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
print(list(poly.coeffs))
print(poly.evaluate(1.2))
