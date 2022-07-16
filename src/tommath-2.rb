#!/usr/bin/env ruby

require 'tommath-mpi'

a = MPI[2357111317]
b = MPI[1113171923]
c = MPI[]
d = MPI[]
e = MPI["12343456", 16]

puts({a: a, b: b, c: c, d: d, e: e})

c = a * b
d = c * b

puts({a: a, b: b, c: c, d: d, e: e})
