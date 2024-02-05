#!/usr/bin/env ruby
require 'tommath_swig'
include Tommath_swig
require 'show'

puts "MP_ITER = #{MP_ITER}"

a = Mp_int.new(); mp_set(a, 2357111317)    # <-- awkward!
b = Mp_int.new(1113171923)                 # <-- better!
c = Mp_int.new()
d = Mp_int.new()
e = Mp_int.new("12343456", 16)             # <-- yey!

def show!
  show_exprs "a", "b","c", "d", "e"
end

show!

mp_mul(a, b, c);
mp_mul(c, b, d);

show!

