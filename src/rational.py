#!/usr/bin/env python3.10

from rational_swig import *

def P(x):
  print(f'{x} = {eval(x)!r}')

a = RationalInt(2, 3)
b = RationalInt(5, 6)

P("a")
P("b")
P("a + b")
P("a * b")
P("a > b")
