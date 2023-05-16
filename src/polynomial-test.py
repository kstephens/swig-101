#!/usr/bin/env python3.10

from polynomial_swig import *
import pytest

def test_empty_coeffs():
    p = Polynomial()
    assert p.evaluate(1.2) == 0.0
    assert p.evaluate(999) == 0.0

def test_one_coeff():
    p = Polynomial()
    p.coeffs = VectorDouble([ 2.3 ])
    assert p.evaluate(1.2) == 2.3
    assert p.evaluate(999) == 2.3

def test_more_than_one_coeff():
    p = Polynomial()
    p.coeffs = VectorDouble([ 3, 5.0, 7.0, 11.0 ])
    assert p.evaluate(2) == 129.0
    assert p.evaluate(-3.5) == -400.375
