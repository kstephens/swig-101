#!/usr/bin/env ruby

require 'tommath-mpi'
require 'show'

a = MPI[2357111317]
b = MPI[1113171923]
c = MPI[]
d = MPI[]
e = MPI["12343456", 16]

def show!
  show_exprs "a", "b","c", "d", "e"
end

show!

c = a * b
d = c * b

show!
