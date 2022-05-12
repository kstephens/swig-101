#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example1_swig'
include Example1_swig

puts "EXAMPLE1_VERSION = #{EXAMPLE1_VERSION}"
puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)

