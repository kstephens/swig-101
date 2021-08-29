# swig-101

Introduction to [SWIG](http://www.swig.org/).

# HOWTO

## OSX

* Install macports
* sudo port install swig swig-ruby swig-python swig-java python3.8
* Install rbenv + ruby-build plugin
* rbenv install 2.3.0
* Install JVM 11.0.3
* Install clojure + clojure-tools

## Build

```
$ rbenv shell 2.3.0
$ gmake clean all
```

# Examples



## Example1

### C Library

``` C
#include "example1.h"

double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  return c0 + c1 * x + c2 * x*x + c3 * x*x*x;
}
```

### C Header

``` C
#ifdef SWIG
%module example1
%{
#include "example1.h"
%}
#endif

double cubic_poly(double x, double c0, double c1, double c2, double c3);
```

### C Main

``` C
#include <stdio.h>
#include "example1.h"

int main(int argc, char **argv) {
  printf("%.14f\n", cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23));
  return 0;
}
```

### Ruby

``` Ruby
#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example1'

puts Example1.cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23)
```

### Python

``` Python
#!/usr/bin/env python3.8

import sys
sys.path.append('target/python')

import example1

print(example1.cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23))
```

### TCL

``` TCL
#!/usr/bin/env tclsh

load target/tcl/example1.so Example1

puts [cubic_poly 2.3 3.5 7.11 13.17 19.23]
```

### Guile

``` Guile
#!/usr/bin/env guile --no-auto-compile
!#

(load-extension "target/guile/libexample1.so" "SWIG_init")

(write (cubic-poly 2.3 3.5 7.11 13.17 19.23))
(newline)
```

### Clojure

``` Clojure
;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "example1")

(import 'example1)

(println (example1/cubic_poly 2.3, 3.5, 7.11, 13.17, 19.23))
```


### Output


#### C Main Output

```
$ target/native/example1
323.49370999999996
```


#### Ruby Output

```
$ src/example1-ruby
323.49370999999996
```


#### Python Output

```
$ src/example1-python
323.49370999999996
```


#### TCL Output

```
$ src/example1-tcl
323.49370999999996
```


#### Guile Output

```
$ src/example1-guile
323.49370999999996
```


#### Clojure Output

```
$ bin/run-clj src/example1-clojure
323.49370999999996
```


