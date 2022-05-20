#!/usr/bin/env python3.10

import tommath_swig
from tommath_swig import mp_int, mp_init, mp_clear, mp_set, mp_mul

print({"MP_ITER": tommath_swig.MP_ITER})

a = mp_int(); mp_set(a, 2357111317)    # <-- awkard!
b = mp_int(1113171923)                 # <-- better!
c = mp_int()
d = mp_int()
e = mp_int("12343456", 16)             # <-- yey!

mp_mul(a, b, c);
mp_mul(c, b, d);

print({"a": a, "b": b, "c": c, "d": d, "e": e})

