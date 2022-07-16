#!/usr/bin/env python3.10

# Setup search path:
import sys ; sys.path.append('target/python')

# Load SWIG bindings:
import example1_swig as example1

# Use SWIG bindings:
print("EXAMPLE1_VERSION = " + example1.EXAMPLE1_VERSION)
print(example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))
