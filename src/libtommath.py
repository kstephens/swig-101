#!/usr/bin/env python3.10

# Setup DLL search path:
import sys ; sys.path.append('target/python')

# Import library bindings:
import libtommath_swig as tommath
from libtommath_swig import mp_int, mp_init, mp_clear, mp_set, mp_mul, mp_int_to_charP

# Enums:
print({"MP_ITER": tommath.MP_ITER})

a = mp_int()
b = mp_int()
c = mp_int()
d = mp_int()

mp_init(a);
mp_init(b);
mp_init(c);
mp_init(d);

mp_set(a, 2357111317);
mp_set(b, 1113171923);
mp_mul(a, b, c);
mp_mul(c, b, d);

print({"a": mp_int_to_charP(a),
       "b": mp_int_to_charP(b),
       "c": mp_int_to_charP(c),
       "d": mp_int_to_charP(d)})

mp_clear(a);
mp_clear(b);
mp_clear(c);
mp_clear(d);
