#!/usr/bin/env python3.10

from polynomial_v2_swig import *

print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})

# polynomial<double>:
poly         = PolynomialDoubleV2()
poly.coeffs  = VectorDoubleV2([ 3.0, 5.0, 7.0, 11.0 ])
print(list(poly.coeffs))
print(poly.evaluate(2))

# polynomial<rational<int>>:
poly        = PolynomialRationalV2()
poly.coeffs = VectorRationalV2([ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13, 17) ])
print(list(poly.coeffs))
print(poly.evaluate(RationalV2(5, 7)))

# polynomial<complex<double>>:
poly        = PolynomialComplexV2()
poly.coeffs = VectorComplexV2([ complex(7.2, 11.3), complex(11.5, 13.7), complex(13.11, 17.13) ])
print(list(poly.coeffs))
print(poly.evaluate(complex(5.7, 7.11)))
