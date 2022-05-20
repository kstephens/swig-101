#!/usr/bin/env ruby

require 'tommath_swig'
include Tommath_swig

puts "MP_ITER = #{MP_ITER}"

a = Mp_int.new(); mp_set(a, 2357111317)    # <-- awkard!
b = Mp_int.new(1113171923)                 # <-- better!
c = Mp_int.new()
d = Mp_int.new()
e = Mp_int.new("12343456", 16)             # <-- yey!

mp_mul(a, b, c);
mp_mul(c, b, d);

puts({"a": a, "b": b, "c": c, "d": d, "e": e})
