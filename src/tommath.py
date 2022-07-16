#!/usr/bin/env python3.10

from tommath_swig import *

print({"MP_ITER": MP_ITER})

a = mp_int(); mp_set(a, 2357111317)    # <-- awkward!
b = mp_int(1113171923)                 # <-- better!
c = mp_int()
d = mp_int()
e = mp_int("12343456", 16)             # <-- yey!

print({"a": a, "b": b, "c": c, "d": d, "e": e})

mp_mul(a, b, c);
mp_mul(c, b, d);

print({"a": a, "b": b, "c": c, "d": d, "e": e})
