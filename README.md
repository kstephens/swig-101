# swig-101

Introduction to [SWIG](http://www.swig.org/).

# HOWTO

## OSX

* Install macports
* sudo port install swig swig-ruby swig-python swig-java python3.8
* Install rbenv + ruby-build plugin
* rbenv install 2.3.0
* Install JVM 11.0.2
* Install clojure + clojure-tools

## Build

```
$ rbenv shell 2.3.0
$ gmake clean all
```





# Example1


## C Header

``` C
#ifdef SWIG
%module example1
%{
#include "example1.h"
%}
#endif

double cubic_poly(double x, double c0, double c1, double c2, double c3);
```


## C Library

``` C
#include "example1.h"

double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  return c0 + c1 * x + c2 * x*x + c3 * x*x*x;
}
```


## C Main

``` C
#include <stdio.h>
#include "example1.h"

int main(int argc, char **argv) {
  printf("%.14f\n", cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23));
  return 0;
}
```


Output:

```
$ target/native/example1
323.49370999999996
```

## Ruby

``` Ruby
#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example1'

puts Example1.cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23)
```


Output:

```
$ src/example1-ruby
323.49370999999996
```

## Python

``` Python
#!/usr/bin/env python3.8

import sys
sys.path.append('target/python')

import example1

print(example1.cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23))
```


Output:

```
$ src/example1-python
323.49370999999996
```

## TCL

``` TCL
#!/usr/bin/env tclsh

load target/tcl/example1.so Example1

puts [cubic_poly 2.3 3.5 7.11 13.17 19.23]
```


Output:

```
$ src/example1-tcl
323.49370999999996
```

## Guile

``` Guile
#!/usr/bin/env guile --no-auto-compile
!#

(load-extension "target/guile/libexample1.so" "SWIG_init")

(write (cubic-poly 2.3 3.5 7.11 13.17 19.23))
(newline)
```


Output:

```
$ src/example1-guile
323.49370999999996
```

## Clojure

``` Clojure
;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "example1")

(import 'example1)

(println (example1/cubic_poly 2.3, 3.5, 7.11, 13.17, 19.23))
```


Output:

```
$ bin/run-clj src/example1-clojure
323.49370999999996
```

## Output


### C Main Output

```
$ target/native/example1
323.49370999999996
```


### Ruby Output

```
$ src/example1-ruby
323.49370999999996
```


### Python Output

```
$ src/example1-python
323.49370999999996
```


### TCL Output

```
$ src/example1-tcl
323.49370999999996
```


### Guile Output

```
$ src/example1-guile
323.49370999999996
```


### Clojure Output

```
$ bin/run-clj src/example1-clojure
323.49370999999996
```




# Example2


## C Header

``` C
#ifdef SWIG
%module example2
%include std_vector.i
%template(VectorDouble) std::vector<double>;
%{
#include "example2.h"
%}
#endif

#include <vector>

class polynomial {
 public:
  std::vector<double> coeffs;
  double evaluate(double x);
};
```


## C Library

``` C
#include "example2.h"

double polynomial::evaluate(double x) {
  double result = 0, xx = 1;
  for ( auto c : this->coeffs ) {
    result += c * xx;
    xx *= x;
  }
  return result;
}
```


## C Main

``` C
#include <iostream>
#include "example2.h"

int main(int argc, char **argv) {
  polynomial p;
  p.coeffs.push_back(3.5);
  p.coeffs.push_back(7.11);
  p.coeffs.push_back(13.17);
  p.coeffs.push_back(19.23);
  std::cout.precision(17);
  std::cout << p.evaluate(2.3) << "\n";
  return 0;
}
```


Output:

```
$ target/native/example2
323.49370999999991
```

## Ruby

``` Ruby
#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example2'
include Example2

p = Polynomial.new
p.coeffs << 3.5
p.coeffs << 7.11
p.coeffs << 13.17
p.coeffs << 19.23

puts p.evaluate(2.3)

########################################
# Extend for convenience:

class Polynomial
  # Constructor:
  def self.[] elems
    elems.inject(new){|this, x| this.coeffs << x; this}
  end
  # Like a Proc:
  def to_proc
    lambda{|x| evaluate(x)}
  end
  alias :call :evaluate
  alias :[]   :evaluate
end

require 'pp'

p = Polynomial[ [3.5, 7.11, 13.17, 19.23] ]
pp p.coeffs.to_a

x = 0..5
pp x.zip(x.map(&p)).to_h
```


Output:

```
$ src/example2-ruby
323.4937099999999
[3.5, 7.11, 13.17, 19.23]
{0=>3.5, 1=>43.010000000000005, 2=>224.24, 3=>662.57, 4=>1473.38, 5=>2772.05}
```

## Python

``` Python
#!/usr/bin/env python3.8
```


Output:

```
$ src/example2-python
```

## TCL

``` TCL
#!/usr/bin/env tclsh
```


Output:

```
$ src/example2-tcl
```

## Guile

``` Guile
#!/usr/bin/env guile --no-auto-compile
!#
```


Output:

```
$ src/example2-guile
```

## Clojure

``` Clojure
;; -*- clojure -*-
```


Output:

```
$ bin/run-clj src/example2-clojure
```

## Output


### C Main Output

```
$ target/native/example2
323.49370999999991
```


### Ruby Output

```
$ src/example2-ruby
323.4937099999999
[3.5, 7.11, 13.17, 19.23]
{0=>3.5, 1=>43.010000000000005, 2=>224.24, 3=>662.57, 4=>1473.38, 5=>2772.05}
```


### Python Output

```
$ src/example2-python
```


### TCL Output

```
$ src/example2-tcl
```


### Guile Output

```
$ src/example2-guile
```


### Clojure Output

```
$ bin/run-clj src/example2-clojure
```



# Workflow

```

src/X.c  src/X.h
|        |
|        |\
|        | \
|        |  `--> $ swig -ruby src/X.h
|        |         |
 `-+----'           `--> ruby/X.c
   |                     |
   |                      \
   |                       \
    `--> $ cc src/X.c       |
           |                |
            `-- native/X.o  |
                |           \
                 `-----------`--> $ cc ruby/X.c native/X.o
                                    |
                                     `--> ruby/X.so
                                          |
$ ruby <---------------------------------'

```



 ## example1.c


 ### Compile native code

 ```
 clang -g -O3 -Isrc -c -o target/native/example1.o src/example1.c
 ```

 ### Compile native program

 ```
 clang -g -O3 -Isrc -o target/native/example1 src/example1-native.c  \
  target/native/example1.o
 ```

 ## Build ruby SWIG wrapper


 ### Generate ruby SWIG wrapper

 ```
 swig -addextern -I- -ruby -o target/ruby/example1.c src/example1.h
 wc -l target/ruby/example1.c
 2215 target/ruby/example1.c
 ```

 ### Compile ruby SWIG wrapper

 ```
 clang -g -O3 -Isrc -I$HOME/.rbenv/versions/2.3.0/include/ruby-2.3.0  \
  -I$HOME/.rbenv/versions/2.3.0/include/ruby-2.3.0/x86_64-darwin18 -c  \
  -o target/ruby/example1.o target/ruby/example1.c
 ```

 ### Link ruby SWIG wrapper dynamic library

 ```
 clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/ruby/example1.bundle target/native/example1.o target/ruby/example1.o
 ```

 ## Build python SWIG wrapper


 ### Generate python SWIG wrapper

 ```
 swig -addextern -I- -python -o target/python/example1.c src/example1.h
 wc -l target/python/example1.c
 3573 target/python/example1.c
 ```

 ### Compile python SWIG wrapper

 ```
 clang -g -O3 -Isrc  \
  -I/opt/local/Library/Frameworks/Python.framework/Versions/3.8/include/python3.8  \
  -Wno-deprecated-declarations -c -o target/python/example1.o  \
  target/python/example1.c
 ```

 ### Link python SWIG wrapper dynamic library

 ```
 clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/python/_example1.so target/native/example1.o target/python/example1.o
 ```

 ## Build tcl SWIG wrapper


 ### Generate tcl SWIG wrapper

 ```
 swig -addextern -I- -tcl -o target/tcl/example1.c src/example1.h
 wc -l target/tcl/example1.c
 2121 target/tcl/example1.c
 ```

 ### Compile tcl SWIG wrapper

 ```
 clang -g -O3 -Isrc -c -o target/tcl/example1.o target/tcl/example1.c
 ```

 ### Link tcl SWIG wrapper dynamic library

 ```
 clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/tcl/example1.so target/native/example1.o target/tcl/example1.o
 ```

 ## Build guile SWIG wrapper


 ### Generate guile SWIG wrapper

 ```
 swig -addextern -I- -scmstub -guile -o target/guile/example1.c src/example1.h
 wc -l target/guile/example1.c
 1583 target/guile/example1.c
 ```

 ### Compile guile SWIG wrapper

 ```
 clang -g -O3 -Isrc -I/opt/local/include/guile/2.2  \
  -I/opt/local/include/guile/2.2/libguile -c -o target/guile/example1.o  \
  target/guile/example1.c
 ```

 ### Link guile SWIG wrapper dynamic library

 ```
 clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/guile/libexample1.so target/native/example1.o target/guile/example1.o
 ```

 ## Build java SWIG wrapper


 ### Generate java SWIG wrapper

 ```
 swig -addextern -I- -java -o target/java/example1.c src/example1.h
 wc -l target/java/example1.c
 243 target/java/example1.c
 ```

 ### Compile java SWIG wrapper

 ```
 clang -g -O3 -Isrc  \
  -I/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/include  \
  -I/Library/Java/JavaVirtualMachines/jdk-11.0.2.jdk/Contents/Home/include/darwin  \
  -c -o target/java/example1.o target/java/example1.c
 ```

 ### Link java SWIG wrapper dynamic library

 ```
 clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/java/libexample1.jnilib target/native/example1.o target/java/example1.o
 ```
