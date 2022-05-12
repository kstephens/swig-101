#!/usr/bin/env python3.10

# Setup DLL search path:
import sys
sys.path.append('target/python')

# Import library bindings:
from polynomial_swig import Polynomial, VectorDouble, POLYNOMIAL_VERSION

# Instantiate object:
poly = Polynomial()
poly.coeffs = VectorDouble([ 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 ])

# Invoke methods:
print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})
print(list(poly.coeffs))
print(poly.evaluate(2.0))

