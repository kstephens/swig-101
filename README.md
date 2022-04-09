# swig-101

Introduction to [SWIG](http://www.swig.org/).

# What is SWIG?

Swig is a FFI binding generator.

# Target Languages

The examples in this repo support these target languages:

* Python
* Ruby
* TCL
* Guile Scheme
* Java (via Clojure)

# HOW-TO

## Setup

* Install rbenv + ruby-build
* rbenv install 2.7.1
* Install JVM 11.0
* Install clojure + clojure-tools

### Debian (Ubuntu 18.04+)

* Install a Python 3.10 distribution with python3.10 in $PATH.
* Run `bin/build debian-prereq`

### OSX

* Install macports
* Run `bin/build macports-prereq`

## Build

```
$ rbenv shell 2.7.1
$ bin/build macports-prereq 
$ bin/build clean all
```





# Example1


## C Header -- src/example1.h

``` C
  1   #ifdef SWIG
  2   %module example1
  3   %{
  4   #include "example1.h"
  5   %}
  6   #endif
  7   
  8   double cubic_poly(double x, double c0, double c1, double c2, double c3);

```



## C Library -- src/example1.c

``` C
  1   #include "example1.h"
  2   
  3   double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  4     return c0 + c1 * x + c2 * x*x + c3 * x*x*x;
  5   }

```



## C Main -- src/example1-native.c

``` C
  1   #include <stdio.h>
  2   #include "example1.h"
  3   
  4   int main(int argc, char **argv) {
  5     printf("%5.2f\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));
  6     return 0;
  7   }

```


----

```
$ target/native/example1
129.00

```


## Ruby -- src/example1-ruby

``` Ruby
  1   #!/usr/bin/env ruby
  2   
  3   ENV["LD_LIBRARY_PATH"] = 'target/ruby'
  4   $:.unshift 'target/ruby'
  5   
  6   require 'example1'
  7   
  8   puts Example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)

```


----

```
$ src/example1-ruby
129.0

```


## Python -- src/example1-python

``` Python
  1   #!/usr/bin/env python3.10
  2   
  3   import sys
  4   sys.path.append('target/python')
  5   
  6   import example1
  7   
  8   print(example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))

```


----

```
$ src/example1-python
129.0

```


## TCL -- src/example1-tcl

``` TCL
  1   #!/usr/bin/env tclsh
  2   
  3   load target/tcl/example1.so Example1
  4   
  5   puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]

```


----

```
$ src/example1-tcl
129.0

```


## Guile -- src/example1-guile

``` Guile
  1   #!/usr/bin/env guile
  2   !#
  3   
  4   (load-extension "target/guile/libexample1.so" "SWIG_init")
  5   
  6   (write (cubic-poly 2.0 3.0 5.0 7.0 11.0))
  7   (newline)

```


----

```
$ src/example1-guile
129.0

```


## Clojure -- src/example1-clojure

``` Clojure
  1   ;; -*- clojure -*-
  2   
  3   (clojure.lang.RT/loadLibrary "example1")
  4   
  5   (import 'example1)
  6   
  7   (prn (example1/cubic_poly 2.0 3.0 5.0 7.0 11.0))

```


----

```
$ src/example1-clojure
129.0

```



## Output


```
$ target/native/example1
129.00

```



```
$ src/example1-ruby
129.0

```



```
$ src/example1-python
129.0

```



```
$ src/example1-tcl
129.0

```



```
$ src/example1-guile
129.0

```



```
$ src/example1-clojure
129.0

```




# Example2


## CC Header -- src/example2.h

``` CC
  1   #ifdef SWIG
  2   %module example2
  3   %include std_vector.i
  4   %template(VectorDouble) std::vector<double>;
  5   %{
  6   #include "example2.h"
  7   %}
  8   #endif
  9   
 10   #include <vector>
 11   
 12   class Polynomial {
 13    public:
 14     std::vector<double> coeffs;
 15     double evaluate(double x);
 16   };

```



## CC Library -- src/example2.cc

``` CC
  1   #include "example2.h"
  2   
  3   double Polynomial::evaluate(double x) {
  4     double result = 0, xx = 1;
  5     for ( auto c : this->coeffs ) {
  6       result += c * xx;
  7       xx *= x;
  8     }
  9     return result;
 10   }

```



## CC Main -- src/example2-native.cc

``` CC
  1   #include <iostream>
  2   #include "example2.h"
  3   
  4   int main(int argc, char **argv) {
  5     Polynomial p;
  6     p.coeffs = { 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 };
  7     std::cout << p.evaluate(2.0) << std::endl;
  8     return 0;
  9   }

```


----

```
$ target/native/example2
-156

```


## Ruby -- src/example2-ruby

``` Ruby
  1   #!/usr/bin/env ruby
  2   
  3   ENV["LD_LIBRARY_PATH"] = 'target/ruby'
  4   $:.unshift 'target/ruby'
  5   
  6   require 'example2'
  7   include Example2
  8   
  9   p = Polynomial.new
 10   p.coeffs = VectorDouble.new([2.0, 3.0, 5.0, 7.0, 11.0, -13.0])
 11   
 12   pp p.coeffs.to_a
 13   puts p.evaluate(2.0)

```


----

```
$ src/example2-ruby
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0

```


## Python -- src/example2-python

``` Python
  1   #!/usr/bin/env python3.10
  2   
  3   import sys
  4   sys.path.append('target/python')
  5   
  6   from example2 import Polynomial, VectorDouble
  7   
  8   poly = Polynomial()
  9   poly.coeffs = VectorDouble([ 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 ])
 10   
 11   print(list(poly.coeffs))
 12   print(poly.evaluate(2.0))

```


----

```
$ src/example2-python
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0

```


## TCL -- src/example2-tcl

``` TCL
  1   #!/usr/bin/env tclsh
  2   
  3   load target/tcl/example2.so Example2
  4   
  5   Polynomial poly
  6   VectorDouble c { 2.0 3.0 5.0 7.0 11.0 -13.0 }
  7   poly configure -coeffs c
  8   
  9   set coeffs [poly cget -coeffs]
 10   for {set i 0} {$i < [$coeffs size]} {incr i} {
 11       puts -nonewline [$coeffs get $i]
 12       puts -nonewline " "
 13   }
 14   puts ""
 15   puts [poly evaluate 2.0]

```


----

```
$ src/example2-tcl
2.0 3.0 5.0 7.0 11.0 -13.0 
-156.0

```


## Guile -- src/example2-guile

``` Guile
  1   #!/usr/bin/env guile --no-auto-compile
  2   !#

```


----

```
$ src/example2-guile

```


## Clojure -- src/example2-clojure

``` Clojure
  1   ;; -*- clojure -*-
  2   
  3   (clojure.lang.RT/loadLibrary "example2")
  4   
  5   (import 'example2)
  6   
  7   (def p (Polynomial.))
  8   (.setCoeffs p (VectorDouble. [2.0 3.0 5.0 7.0 11.0 -13.0]))
  9   
 10   (prn (.getCoeffs p))
 11   (prn (.evaluate p 2.0))

```


----

```
$ src/example2-clojure
[2.0 3.0 5.0 7.0 11.0 -13.0]
-156.0

```



## Output


```
$ target/native/example2
-156

```



```
$ src/example2-ruby
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0

```



```
$ src/example2-python
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0

```



```
$ src/example2-tcl
2.0 3.0 5.0 7.0 11.0 -13.0 
-156.0

```



```
$ src/example2-guile

```



```
$ src/example2-clojure
[2.0 3.0 5.0 7.0 11.0 -13.0]
-156.0

```




# Workflow



```
1. Compile native library.
2. Generate SWIG wrappers for target language.
3. Compile and link SWIG wrappers for target language with native library.
4. Load SWIG wrappers into target language.

************************************************************************
*            $ swig -python c/example1.h
* +----------------+         +----------------------+
* |  c/example1.h  +-------->|  python/example1.c   |
* |  c/example1.c  |         |  python/example1.py  |------.
* +-----+----------+         +-+--------------------+       |
*       | $ cc -c c/example.c  | $ cc -c python/example1.c  |
*       v                      v                            |
* +----------------+         +----------------------+       |
* |  c/example1.о  |         |  python/example1.о   |       |
* +-----+----------+         +--------+-------------+       |
*       |                             |                     |
*       +----------------------------'                      |
*       | $ cc -dynamiclib -о python/_example1.so \         |
*       |    c/example1.о \                                 |
*       |    python/example1.о                              |
*       v                                                   |
* +----------------------+                                  |
* |  python/example1.sо  |                                  |
* +-----+----------------+                                  |
*       | $ python -m python/example1.py scripy.py          |
*       v                                                   |
* +----------------------+                                  |
* |  script.py           |<--------------------------------'
* +----------------------+
*
************************************************************************

```



# Build example1.c 


## Build example1.c Native Code 
``` 

# Compile native library: 
clang -g -Isrc -c -o target/native/example1.o src/example1.c 

# Compile and link native program: 
clang -g -Isrc -o target/native/example1 src/example1-native.c  \
  target/native/example1.o 
``` 


## Build python SWIG wrapper: 
``` 

# Generate python SWIG wrapper: 
swig -addextern -I- -py3 -python -o target/python/example1.c src/example1.h 

wc -l target/python/example1.c 
3573 target/python/example1.c 

grep -si example1 target/python/example1.c 
@(target):= _example1.so 
# define SWIG_init PyInit__example1 
# define SWIG_init init_example1 
#define SWIG_name "_example1" 
#include "example1.h" 

# Compile python SWIG wrapper: 
clang -g -Isrc -I$PYTHON_HOME/include/python3.10  \
  -I$PYTHON_HOME/include/python3.10 -Wno-unused-result -Wsign-compare  \
  -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -fwrapv -O3 -Wall -pipe  \
  -Os -Wno-deprecated-declarations -c -o target/python/example1.o  \
  target/python/example1.c 

# Link python SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/python/_example1.so target/native/example1.o target/python/example1.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 
``` 


## Build ruby SWIG wrapper: 
``` 

# Generate ruby SWIG wrapper: 
swig -addextern -I- -ruby -o target/ruby/example1.c src/example1.h 

wc -l target/ruby/example1.c 
2215 target/ruby/example1.c 

grep -si example1 target/ruby/example1.c 
#define SWIG_init Init_example1 
#define SWIG_name "Example1" 
static VALUE mExample1; 
#include "example1.h" 
SWIGEXPORT void Init_example1(void) { 
mExample1 = rb_define_module("Example1"); 
rb_define_module_function(mExample1, "cubic_poly", _wrap_cubic_poly, -1); 

# Compile ruby SWIG wrapper: 
clang -g -Isrc -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o target/ruby/example1.o  \
  target/ruby/example1.c 

# Link ruby SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/ruby/example1.bundle target/native/example1.o target/ruby/example1.o 
``` 


## Build tcl SWIG wrapper: 
``` 

# Generate tcl SWIG wrapper: 
swig -addextern -I- -tcl -o target/tcl/example1.c src/example1.h 

wc -l target/tcl/example1.c 
2121 target/tcl/example1.c 

grep -si example1 target/tcl/example1.c 
#define SWIG_init Example1_Init 
#define SWIG_name "example1" 
#include "example1.h" 
SWIGEXPORT int Example1_SafeInit(Tcl_Interp *interp) { 

# Compile tcl SWIG wrapper: 
clang -g -Isrc -I/usr/include/tcl -c -o target/tcl/example1.o  \
  target/tcl/example1.c 

# Link tcl SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/tcl/example1.so target/native/example1.o target/tcl/example1.o 
``` 


## Build guile SWIG wrapper: 
``` 

# Generate guile SWIG wrapper: 
swig -addextern -I- -scmstub -guile -o target/guile/example1.c src/example1.h 

wc -l target/guile/example1.c 
1583 target/guile/example1.c 

grep -si example1 target/guile/example1.c 
#include "example1.h" 

# Compile guile SWIG wrapper: 
clang -g -Isrc -D_THREAD_SAFE -c -o target/guile/example1.o  \
  target/guile/example1.c 

# Link guile SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/guile/libexample1.so target/native/example1.o target/guile/example1.o  \
  -lguile-2.2 -lgc 
``` 


## Build java SWIG wrapper: 
``` 

# Generate java SWIG wrapper: 
swig -addextern -I- -java -o target/java/example1.c src/example1.h 

wc -l target/java/example1.c 
243 target/java/example1.c 

grep -si example1 target/java/example1.c 
#include "example1.h" 
SWIGEXPORT jdouble JNICALL Java_example1JNI_cubic_1poly(JNIEnv *jenv, jclass  \
  jcls, jdouble jarg1, jdouble jarg2, jdouble jarg3, jdouble jarg4, jdouble  \
  jarg5) { 

# Compile java SWIG wrapper: 
clang -g -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/linux  \
  -I$JAVA_HOME/include/darwin -c -o target/java/example1.o  \
  target/java/example1.c 

# Link java SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/java/libexample1.jnilib target/native/example1.o target/java/example1.o 
``` 




