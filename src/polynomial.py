#!/usr/bin/env python3.10

# Setup DLL search path:
import sys ; sys.path.append('target/python')

# Import library bindings:
from polynomial_swig import *

# #define constants:
print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})

# Instantiate object:
poly = Polynomial()
poly.coeffs = VectorDouble([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])

# Invoke methods:
print(list(poly.coeffs))
print(poly.evaluate(1.2))

