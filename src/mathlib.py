#!/usr/bin/env python3.10

# Setup search path:
import sys ; sys.path.append('target/python')

# Load SWIG bindings:
import mathlib_swig as mathlib

# Use SWIG bindings:
print(f'MATHLIB_VERSION = {mathlib.MATHLIB_VERSION}')
print(mathlib.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))
