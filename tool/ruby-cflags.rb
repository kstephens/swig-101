#!/usr/bin/env ruby
require 'rbconfig'
include RbConfig
puts "-I#{CONFIG['rubyhdrdir']} -I#{CONFIG['rubyarchhdrdir']}"
