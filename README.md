# swig-101

Introduction to [SWIG](http://www.swig.org/).

# HOW TO

## OSX

* Install macports
* sudo port install swig swig-ruby swig-python swig-java python3.8
* Install rbenv + ruby-build plugin
* rbenv install 2.3.0
* Install JVM 11.0.3
* Install clojure + clojure-tools

# Example 1

## C Library

``` C
double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  return c0 + c1*x + c2*x*x + c3*x*x*x;
}
```

## C Header / SWIG Interface Spec

``` C
#ifdef SWIG
%module example1
%{
#include "example1.h"
%}
#endif

double cubic_poly(double x, double c0, double c1, double c2, double c3);
```

## C Native

``` C
#include <stdio.h>
#include "example1.h"

int main(int argc, char **argv) {
  printf("%.15f\n", cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23));
  return 0;
}
```

# Calling through SWIG

## Ruby

``` Ruby
#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example1'

puts Example1.cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23)
```

## Python

``` Python
#!/usr/bin/env python3.8

import sys
sys.path.append('target/python')

import example1

print(example1.cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23))
```

## Clojure

``` Clojure
;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "example1")

(import 'example1)

(println (example1/cubic_poly 2.3, 3.5, 7.11, 13.17, 19.23))
```

# Build and Run

```
$ rbenv shell 2.3.0
$ gmake clean all

# Native Code:
$ target/bin/example1
323.493709999999908

# Ruby SWIG
$ bin/example1-ruby
323.4937099999999

$ bin/example1-python
323.4937099999999

$ bin/run-clj bin/example1-clojure
323.4937099999999
```
