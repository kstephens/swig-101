#!/usr/bin/env ruby

require 'tommath_swig'

# Syntactic Sugar:
module Tommath_swig
  class Mp_int
    # Constructor:
    def self.[] val = 0, radix = 10
      case val
      when self
        val
      when Integer
        inst = new
        Tommath_swig.mp_set(inst, val)
        inst
      when String
        Tommath_swig.swig_charP_to_mp_int(val, radix)
      when nil
        self[0]
      else
        raise TypeError, "#{val.inspect} #{radix.inspect}"
      end
    end

    def to_s radix = 10
      Tommath_swig.swig_mp_int_to_charP(self, radix)
    end

    def inspect
      "MPI[#{to_s.inspect}]"
    end

    def -@
      result = MPI.new
      Tommath_swig.mp_neg(self, result)
      result
    end
    def + other
      result = MPI.new
      Tommath_swig.mp_add(self, MPI[other], result)
      result
    end
    def - other
      result = MPI.new
      Tommath_swig.mp_sub(self, MPI[other], result)
      result
    end
    def * other
      result = MPI.new
      Tommath_swig.mp_mul(self, MPI[other], result)
      result
    end
    def / other
      result = MPI.new
      remainder = MPI.new
      Tommath_swig.mp_div(self, MPI[other], result, remainder)
      result
    end
  end
  MPI = Mp_int
end
MPI = Tommath_swig::MPI
