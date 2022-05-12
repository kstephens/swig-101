

# SWIG-101

Introduction to [SWIG](http://www.swig.org/).

# What is SWIG?

SWIG is a foreign-function-interface (FFI) generator for native C/C++ libraries.
SWIG vastly reduces the development cost of using native libraries within dynamic languages.

# History

* SWIG was [created](https://www.swig.org/history.html) in 1995 at Los Alamos National Laboratory.
* Under active development.

# Benefits

* SWIG interface defintions are a superset of C/C++.
* Many C/C++ header files are also SWIG interface definition files.
* Can target multiple languages with little effort.
* Generated binding code is generated, compiled and linked.
* Bindings can be dynamically loaded or statically linked.
* Generated code is self-contained.
* Hinting for improved integration and representation.
* Template-driven: users can create specialized generators.
* Consistency between target languages.

# Applications

* Use dynamic language to test C/C++ code.
* Improve library adoption.
* Integration with other tools.

# Comprehensive Native Code Support

* C struct and union
* C/C++ Pointers, references, `const` declarations
* C/C++ function signatures and calls
* C++ classes
* C++ methods: static, virtual and operator overrides
* C++ templates
* `in`, `out`, `in-out` parameters
* C/C++ `#define` macros
* Memory Management

# Target Languages

SWIG can generate FFI bindings for multiple target languages from one set of interface files:

* Python
* Ruby
* Java
* Perl 5
* Tcl 8
* Lua
* D
* Go
* Guile Scheme
* Javascript
* Octave
* PHP 7
* R (aka GNU S)
* Scilab
* XML (machine-readable metadata)

# Alternatives

## Rewrite it in Language X

* Does not leverage existing work.
* Does not target multiple languages.
* Increased cost of ownership.
* Adoption barriers.

## Native Language APIs

* Every target language extension API is completely different.
* Some implementations of the same target language are different: e.g. JRuby and CRuby.
* Some are dynamic with associated performance costs.
* Few languages have well-defined APIs.  (JNI is a notable exception)
* Requires intimate knowledge:
  * rules
  * best-practices
  * manually wrapping data structure, function, class, method and associated runtime.
  * manual memory managment

## LibFFI

* Only supports dynamic function calls.
* Very low-level.
* Does not interpret C/C++ headers.
* Does not support C++.
* Requires specifing function signatures at [runtime](http://www.chiark.greenend.org.uk/doc/libffi-dev/html/Simple-Example.html).
* Does not provide any data structure functionality.
* Requires knowledge of CPU, compiler and OS calling conventions.
* Requires manual layout struct and union values accordingly.

# Case Study

Kind              |  Language     |  Files  |   Lines 
------------------|:-------------:|--------:|----------:
Native Library    | C/C++ Header  |      40 |    3505
SWIG Interfaces   | SWIG          |       9 |    2667
Python Bindings   | Python        |       1 |    8922
"                 | C++           |       1 |   35235
Java Bindings     | Java          |      55 |    6741
"                 | C++           |       1 |   17987

# Examples

The examples below target:

* Python
* Clojure via Java
* Ruby
* TCL
* Guile Scheme







# Polynomial


## C++ Header : src/polynomial.h

```C++
  1   #include <vector>
  2   #define POLYNOMIAL_VERSION "2.3.5"
  3   class Polynomial {
  4    public:
  5     std::vector<double> coeffs;
  6     double evaluate(double x);
  7   };
```



## C++ Library : src/polynomial.cc

```C++
  1   #include "polynomial.h"
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



## C++ Main : src/polynomial-native.cc

```C++
  1   #include <iostream>
  2   #include "polynomial.h"
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
$ target/native/polynomial
-156
```


## C++ SWIG Interface : src/polynomial.i

```C++
  1   // Name of generated bindings:
  2   %module polynomial_swig
  3   
  4   // Include std::vector<T> support:
  5   %include "std_vector.i"
  6   
  7   // Template instantation:
  8   %template(VectorDouble) std::vector<double>;
  9   
 10   // Include C++ declarations as SWIG interface definitions:
 11   %include "polynomial.h"
 12   
 13   // Prepend C++ code in generated bindings:
 14   %{
 15   #include "polynomial.h"
 16   %}
```



## Python : src/polynomial-python

```Python
  1   #!/usr/bin/env python3.10
  2   
  3   # Setup DLL search path:
  4   import sys
  5   sys.path.append('target/python')
  6   
  7   # Import library bindings:
  8   from polynomial_swig import Polynomial, VectorDouble, POLYNOMIAL_VERSION
  9   
 10   # Instantiate object:
 11   poly = Polynomial()
 12   poly.coeffs = VectorDouble([ 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 ])
 13   
 14   # Invoke methods:
 15   print("POLYNOMIAL_VERSION = " + POLYNOMIAL_VERSION)
 16   print(list(poly.coeffs))
 17   print(poly.evaluate(2.0))
```


----

```
$ src/polynomial-python
POLYNOMIAL_VERSION = 2.3.5
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0
```


## Clojure (Java) : src/polynomial-clojure

```Lisp
  1   ;; -*- clojure -*-
  2   
  3   ;; Load Java bindings dynamic library:
  4   (clojure.lang.RT/loadLibrary "polynomial_swig")
  5   
  6   ;; Import Java namespace:
  7   (import 'polynomial_swig)
  8   
  9   ;; Instantiate object:
 10   (def p (Polynomial.))
 11   (.setCoeffs p (VectorDouble. [2.0 3.0 5.0 7.0 11.0 -13.0]))
 12   
 13   ;; Invoke methods:
 14   (prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})
 15   (prn (.getCoeffs p))
 16   (prn (.evaluate p 2.0))
```


----

```
$ src/polynomial-clojure
{:POLYNOMIAL_VERSION "2.3.5"}
[2.0 3.0 5.0 7.0 11.0 -13.0]
-156.0
```


## Ruby : src/polynomial-ruby

```Ruby
  1   #!/usr/bin/env ruby
  2   
  3   ENV["LD_LIBRARY_PATH"] = 'target/ruby'
  4   $:.unshift 'target/ruby'
  5   
  6   require 'polynomial_swig'
  7   include Polynomial_swig
  8   
  9   p = Polynomial.new
 10   p.coeffs = VectorDouble.new([2.0, 3.0, 5.0, 7.0, 11.0, -13.0])
 11   
 12   puts "POLYNOMIAL_VERSION = #{POLYNOMIAL_VERSION}"
 13   pp p.coeffs.to_a
 14   pp p.evaluate(2.0)
```


----

```
$ src/polynomial-ruby
POLYNOMIAL_VERSION = 2.3.5
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0
```


## Guile : src/polynomial-guile

```Scheme
  1   #!/usr/bin/env guile
  2   !#
  3   
  4   (load-extension "target/guile/libpolynomial_swig.so" "SWIG_init")
  5   
  6   (define p (new-Polynomial))
  7   (Polynomial-coeffs-set p (new-VectorDouble '(2.0 3.0 5.0 7.0 11.0 -13.0)))
  8   
  9   (write `(POLYNOMIAL-VERSION = ,(POLYNOMIAL-VERSION))) (newline)
 10   (write (Polynomial-coeffs-get p)) (newline)
 11   (write (Polynomial-evaluate p 2.0)) (newline)
```


----

```
$ src/polynomial-guile
(POLYNOMIAL-VERSION = "2.3.5")
#<swig-pointer std::vector< double > * 7fba477040e0>
-156.0
```


## TCL : src/polynomial-tcl

```TCL
  1   #!/usr/bin/env tclsh
  2   
  3   load target/tcl/polynomial_swig.so Polynomial_swig
  4   
  5   Polynomial poly
  6   VectorDouble c { 2.0 3.0 5.0 7.0 11.0 -13.0 }
  7   poly configure -coeffs c
  8   
  9   puts "POLYNOMIAL_VERSION = ${POLYNOMIAL_VERSION}"
 10   puts [poly cget -coeffs]
 11   puts [poly evaluate 2.0]
```


----

```
$ src/polynomial-tcl
POLYNOMIAL_VERSION = 2.3.5
_8040e027907f0000_p_std__vectorT_double_t
-156.0
```



## Output


```
$ target/native/polynomial
-156
```



```
$ src/polynomial-python
POLYNOMIAL_VERSION = 2.3.5
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0
```



```
$ src/polynomial-clojure
{:POLYNOMIAL_VERSION "2.3.5"}
[2.0 3.0 5.0 7.0 11.0 -13.0]
-156.0
```



```
$ src/polynomial-ruby
POLYNOMIAL_VERSION = 2.3.5
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0
```



```
$ src/polynomial-guile
(POLYNOMIAL-VERSION = "2.3.5")
#<swig-pointer std::vector< double > * 7fd4d7c040f0>
-156.0
```



```
$ src/polynomial-tcl
POLYNOMIAL_VERSION = 2.3.5
_5061e00fa67f0000_p_std__vectorT_double_t
-156.0
```




# Example1


## C Header : src/example1.h

```C
  1   #define EXAMPLE1_VERSION "1.2.3"
  2   /* Returns: c0 + c1*x + c2*x^2 + c3*x^3 */
  3   double cubic_poly(double x,
  4                     double c0,
  5                     double c1,
  6                     double c2,
  7                     double c3);
```



## C Library : src/example1.c

```C
  1   #include "example1.h"
  2   double cubic_poly(double x,
  3                     double c0,
  4                     double c1,
  5                     double c2,
  6                     double c3) {
  7     return c0 + c1 * x + c2 * x*x + c3 * x*x*x;
  8   }
```



## C Main : src/example1-native.c

```C
  1   #include <stdio.h>
  2   #include "example1.h"
  3   
  4   int main(int argc, char **argv) {
  5     printf("EXAMPLE1_VERSION = %s\n", EXAMPLE1_VERSION);
  6     printf("%5.1f\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));
  7     return 0;
  8   }
```


----

```
$ target/native/example1
EXAMPLE1_VERSION = 1.2.3
129.0
```


## C SWIG Interface : src/example1.i

```C
  1   %module example1_swig
  2   %include "example1.h"
  3   %{
  4   #include "example1.h"
  5   %}
```



## Python : src/example1-python

```Python
  1   #!/usr/bin/env python3.10
  2   
  3   # Setup DLL search path:
  4   import sys
  5   sys.path.append('target/python')
  6   
  7   # Import library bindings:
  8   import example1_swig as example1
  9   
 10   # Use imported module:
 11   print("EXAMPLE1_VERSION = " + example1.EXAMPLE1_VERSION)
 12   print(example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))
```


----

```
$ src/example1-python
EXAMPLE1_VERSION = 1.2.3
129.0
```


## Clojure (Java) : src/example1-clojure

```Lisp
  1   ;; -*- clojure -*-
  2   
  3   (clojure.lang.RT/loadLibrary "example1_swig")
  4   
  5   (import 'example1_swig)
  6   
  7   (println (format "EXAMPLE1_VERSION = %s" (example1_swig/EXAMPLE1_VERSION)))
  8   (prn (example1_swig/cubic_poly 2.0 3.0 5.0 7.0 11.0))
```


----

```
$ src/example1-clojure
EXAMPLE1_VERSION = 1.2.3
129.0
```


## Ruby : src/example1-ruby

```Ruby
  1   #!/usr/bin/env ruby
  2   
  3   ENV["LD_LIBRARY_PATH"] = 'target/ruby'
  4   $:.unshift 'target/ruby'
  5   
  6   require 'example1_swig'
  7   include Example1_swig
  8   
  9   puts "EXAMPLE1_VERSION = #{EXAMPLE1_VERSION}"
 10   puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)
```


----

```
$ src/example1-ruby
EXAMPLE1_VERSION = 1.2.3
129.0
```


## Guile : src/example1-guile

```Scheme
  1   #!/usr/bin/env guile
  2   !#
  3   
  4   (load-extension "target/guile/libexample1_swig.so" "SWIG_init")
  5   
  6   (write `(EXAMPLE1-VERSION = ,(EXAMPLE1-VERSION)))
  7   (newline)
  8   (write (cubic-poly 2.0 3.0 5.0 7.0 11.0))
  9   (newline)
```


----

```
$ src/example1-guile
(EXAMPLE1-VERSION = "1.2.3")
129.0
```


## TCL : src/example1-tcl

```TCL
  1   #!/usr/bin/env tclsh
  2   
  3   load target/tcl/example1_swig.so Example1_swig
  4   
  5   puts "EXAMPLE1_VERSION = ${EXAMPLE1_VERSION}"
  6   puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]
```


----

```
$ src/example1-tcl
EXAMPLE1_VERSION = 1.2.3
129.0
```



## Output


```
$ target/native/example1
EXAMPLE1_VERSION = 1.2.3
129.0
```



```
$ src/example1-python
EXAMPLE1_VERSION = 1.2.3
129.0
```



```
$ src/example1-clojure
EXAMPLE1_VERSION = 1.2.3
129.0
```



```
$ src/example1-ruby
EXAMPLE1_VERSION = 1.2.3
129.0
```



```
$ src/example1-guile
(EXAMPLE1-VERSION = "1.2.3")
129.0
```



```
$ src/example1-tcl
EXAMPLE1_VERSION = 1.2.3
129.0
```




# Workflow



1. Create interface files. (once)
2. Generate bindings from interface files. (many)
3. Compile bindings.
4. Link bindings and native library into a dynamic library.
5. Load dynamic library.

```
   +---------------------------+
+--+           foo.h           |
|  +---------------------------+
|  | double f(double, double); |
|  +------------------+--------+
|                  
|  +---------------------------+ 
|  |            foo.i          | 
|  +---------------------------+ 
|  | %module foo_swig          | 
|  | %include "foo.h"          |
|  +-+-------------------------+ 
+----+  2. swig -python foo.i    \
     v       -o bld/foo_swig.c
   +-------------------+
+--+  bld/foo_swig.py  |
|  |  bld/foo_swig.c   |
|  +-+-----------------+
|    |  3. cc -c bld/foo_swig.c
|    v                       
|  +-------------------+  
|  |  bld/foo_swig.о   |  
|  +-+-----------------+  
|    |  4. cc -dynamiclib         \   
|    |       -о bld/_foo_swig.so  \   
|    |       bld/foo_swig.о       \
|    v       -l foo 
|  +-------------------+ 
|  |  bld/foo_swig.sо  | 
|  +-+-----------------+ 
+----+  5. python script.py
     v
   +--------------------------+
   |        scripy.py         |
   +--------------------------+
   | import sys               |
   | sys.path.append('bld')   |
   | import foo_swig as foo   |
   | print(foo.f(2.0, 3.0))   |
   +--------------------------+

```



# Build polynomial.cc 


## Build polynomial.cc Native Code 
``` 

# Compile native library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -c -o  \
  target/native/polynomial.o src/polynomial.cc 

# Compile and link native program: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -o  \
  target/native/polynomial src/polynomial-native.cc target/native/polynomial.o 
``` 


## Build python bindings 
``` 

# Generate python bindings 
swig -addextern -I- -Isrc -c++ -python -outdir target/python/ -o  \
  target/python/polynomial_swig.cc src/polynomial.i 

wc -l target/python/polynomial_swig.cc target/python/polynomial_swig.py 
8408 target/python/polynomial_swig.cc 
241 target/python/polynomial_swig.py 
8649 total 

# Compile python bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$PYTHON_HOME/include/python3.10 -I$PYTHON_HOME/include/python3.10  \
  -Wno-unused-result -Wsign-compare -Wunreachable-code -fno-common -dynamic  \
  -DNDEBUG -g -fwrapv -O3 -Wall -pipe -Os -Wno-deprecated-declarations -c -o  \
  target/python/polynomial_swig.cc.o target/python/polynomial_swig.cc 

# Link python dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/python//_polynomial_swig.so  \
  target/native/polynomial.o target/python/polynomial_swig.cc.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 
``` 


## Build java bindings 
``` 

# Generate java bindings 
swig -addextern -I- -Isrc -c++ -java -outdir target/java/ -o  \
  target/java/polynomial_swig.cc src/polynomial.i 

wc -l target/java/polynomial_swig.cc target/java/polynomial*.java 
660 target/java/polynomial_swig.cc 
11 target/java/polynomial_swig.java 
12 target/java/polynomial_swigConstants.java 
32 target/java/polynomial_swigJNI.java 
715 total 

# Compile java bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -I$JAVA_HOME/include/darwin -c  \
  -o target/java/polynomial_swig.cc.o target/java/polynomial_swig.cc 

# Link java dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/java//libpolynomial_swig.jnilib  \
  target/native/polynomial.o target/java/polynomial_swig.cc.o 
``` 


## Build ruby bindings 
``` 

# Generate ruby bindings 
swig -addextern -I- -Isrc -c++ -ruby -outdir target/ruby/ -o  \
  target/ruby/polynomial_swig.cc src/polynomial.i 

wc -l target/ruby/polynomial_swig.cc 
8528 target/ruby/polynomial_swig.cc 

# Compile ruby bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o  \
  target/ruby/polynomial_swig.cc.o target/ruby/polynomial_swig.cc 

# Link ruby dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/ruby//polynomial_swig.bundle  \
  target/native/polynomial.o target/ruby/polynomial_swig.cc.o 
``` 


## Build tcl bindings 
``` 

# Generate tcl bindings 
swig -addextern -I- -Isrc -c++ -tcl -outdir target/tcl/ -o  \
  target/tcl/polynomial_swig.cc src/polynomial.i 

wc -l target/tcl/polynomial_swig.cc 
2951 target/tcl/polynomial_swig.cc 

# Compile tcl bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I/usr/include/tcl -c -o target/tcl/polynomial_swig.cc.o  \
  target/tcl/polynomial_swig.cc 

# Link tcl dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/tcl//polynomial_swig.so  \
  target/native/polynomial.o target/tcl/polynomial_swig.cc.o 
``` 


## Build guile bindings 
``` 

# Generate guile bindings 
swig -addextern -I- -Isrc -guile -c++ -guile -outdir target/guile/ -o  \
  target/guile/polynomial_swig.cc src/polynomial.i 

wc -l target/guile/polynomial_swig.cc 
2267 target/guile/polynomial_swig.cc 

# Compile guile bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -D_THREAD_SAFE -c -o target/guile/polynomial_swig.cc.o  \
  target/guile/polynomial_swig.cc 

# Link guile dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/guile//libpolynomial_swig.so  \
  target/native/polynomial.o target/guile/polynomial_swig.cc.o -lguile-2.2 -lgc 
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


## Build python bindings 
``` 

# Generate python bindings 
swig -addextern -I- -Isrc -python -outdir target/python/ -o  \
  target/python/example1_swig.c src/example1.i 

wc -l target/python/example1_swig.c target/python/example1_swig.py 
3650 target/python/example1_swig.c 
65 target/python/example1_swig.py 
3715 total 

# Compile python bindings: 
clang -g -Isrc -I$PYTHON_HOME/include/python3.10  \
  -I$PYTHON_HOME/include/python3.10 -Wno-unused-result -Wsign-compare  \
  -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -fwrapv -O3 -Wall -pipe  \
  -Os -Wno-deprecated-declarations -c -o target/python/example1_swig.c.o  \
  target/python/example1_swig.c 

# Link python dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/python//_example1_swig.so target/native/example1.o  \
  target/python/example1_swig.c.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 
``` 


## Build java bindings 
``` 

# Generate java bindings 
swig -addextern -I- -Isrc -java -outdir target/java/ -o  \
  target/java/example1_swig.c src/example1.i 

wc -l target/java/example1_swig.c target/java/example1*.java 
243 target/java/example1_swig.c 
15 target/java/example1_swig.java 
12 target/java/example1_swigConstants.java 
13 target/java/example1_swigJNI.java 
283 total 

# Compile java bindings: 
clang -g -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/linux  \
  -I$JAVA_HOME/include/darwin -c -o target/java/example1_swig.c.o  \
  target/java/example1_swig.c 

# Link java dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/java//libexample1_swig.jnilib target/native/example1.o  \
  target/java/example1_swig.c.o 
``` 


## Build ruby bindings 
``` 

# Generate ruby bindings 
swig -addextern -I- -Isrc -ruby -outdir target/ruby/ -o  \
  target/ruby/example1_swig.c src/example1.i 

wc -l target/ruby/example1_swig.c 
2257 target/ruby/example1_swig.c 

# Compile ruby bindings: 
clang -g -Isrc -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o  \
  target/ruby/example1_swig.c.o target/ruby/example1_swig.c 

# Link ruby dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/ruby//example1_swig.bundle target/native/example1.o  \
  target/ruby/example1_swig.c.o 
``` 


## Build tcl bindings 
``` 

# Generate tcl bindings 
swig -addextern -I- -Isrc -tcl -outdir target/tcl/ -o  \
  target/tcl/example1_swig.c src/example1.i 

wc -l target/tcl/example1_swig.c 
2149 target/tcl/example1_swig.c 

# Compile tcl bindings: 
clang -g -Isrc -I/usr/include/tcl -c -o target/tcl/example1_swig.c.o  \
  target/tcl/example1_swig.c 

# Link tcl dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/tcl//example1_swig.so target/native/example1.o  \
  target/tcl/example1_swig.c.o 
``` 


## Build guile bindings 
``` 

# Generate guile bindings 
swig -addextern -I- -Isrc -guile -guile -outdir target/guile/ -o  \
  target/guile/example1_swig.c src/example1.i 

wc -l target/guile/example1_swig.c 
1605 target/guile/example1_swig.c 

# Compile guile bindings: 
clang -g -Isrc -D_THREAD_SAFE -c -o target/guile/example1_swig.c.o  \
  target/guile/example1_swig.c 

# Link guile dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/guile//libexample1_swig.so target/native/example1.o  \
  target/guile/example1_swig.c.o -lguile-2.2 -lgc 
``` 





# Links

* https://www.swig.org/
* https://github.com/swig/swig
* https://github.com/kstephens/swig-101
* https://github.com/libffi/libffi
* https://www.chiark.greenend.org.uk/doc/libffi-dev/html/

# HOW-TO

## Setup

* Install rbenv + ruby-build
* rbenv install 2.7.1
* Install JVM 11.0
* Install clojure + clojure-tools
* Build swig from source:

```
$ cd ..
$ git clone https://github.com/swig/swig.git
$ cd swig
$ ./autogen.sh && ./configure --prefix="$HOME/local" && make && make install
```

### Debian (Ubuntu 18.04+)

* Install a Python 3.10 distribution with python3.10 in $PATH.
* Run `bin/build debian-prereq`

### OSX

* Install macports
* Run `bin/build macports-prereq`

## Build

```
$ rbenv shell 2.7.1
$ bin/build clean demo
```
