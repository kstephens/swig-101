

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

## Rewrite in Language X, Y and Z

* Does not leverage existing code, fixes, future improvements.
* Does not target multiple languages.
* Increased cost of ownership.
* Adoption barriers.
* Incongruent language idioms.

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



## polynomial.cc


### C++ Header : src/polynomial.h

```C++
  1   #include <vector>
  2   
  3   #define POLYNOMIAL_VERSION "1.2.1"
  4   
  5   class Polynomial {
  6   public:
  7     std::vector<double> coeffs;
  8     double evaluate(double x);
  9   };
```


### C++ Library : src/polynomial.cc

```C++
  1   #include "polynomial.h"
  2   
  3   double Polynomial::evaluate(double x) {
  4     double result = 0, xx = 1;
  5     for ( auto c : this->coeffs ) {
  6       result = result + c * xx;
  7       xx = xx * x;
  8     }
  9     return result;
 10   }
```


### C++ Main : src/polynomial-native.cc

```C++
  1   #include <iostream>
  2   #include <iomanip>
  3   #include "polynomial.h"
  4   
  5   int main(int argc, char **argv) {
  6     std::cout << "POLYNOMIAL_VERSION " << POLYNOMIAL_VERSION << "\n";
  7   
  8     Polynomial p;
  9     p.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };
 10     std::cout << std::setprecision(9) << p.evaluate(1.2) << "\n";
 11   
 12     return 0;
 13   }
```


----

```
$ target/native/polynomial
POLYNOMIAL_VERSION 1.2.1
17.3020736
```

----

### C++ SWIG Interface : src/polynomial.i

```C++
  1   // Name of generated bindings:
  2   %module polynomial_swig
  3   
  4   // Include std::vector<T> support:
  5   %include "std_vector.i"
  6   
  7   // Template instantiation:
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


### Python : src/polynomial.py

```Python
  1   # Setup DLL search path:
  2   import sys ; sys.path.append('target/python')
  3   
  4   # Import library bindings:
  5   from polynomial_swig import Polynomial, VectorDouble, POLYNOMIAL_VERSION
  6   
  7   # #define constants:
  8   print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})
  9   
 10   # Instantiate object:
 11   poly = Polynomial()
 12   poly.coeffs = VectorDouble([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
 13   
 14   # Invoke methods:
 15   print(list(poly.coeffs))
 16   print(poly.evaluate(1.2))
```


----

```
$ bin/run src/polynomial.py
{'POLYNOMIAL_VERSION': '1.2.1'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

----

### Clojure (Java) : src/polynomial.clj

```Lisp
  1   ;; Load Java bindings dynamic library:
  2   (clojure.lang.RT/loadLibrary "polynomial_swig")
  3   
  4   ;; Import Java namespace:
  5   (import 'polynomial_swig)
  6   
  7   ;; #define constants:
  8   (prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})
  9   
 10   ;; Instantiate object:
 11   (def p (Polynomial.))
 12   (.setCoeffs p (VectorDouble. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))
 13   
 14   ;; Invoke methods:
 15   (prn (.getCoeffs p))
 16   (prn (.evaluate p 1.2))
```


----

```
$ bin/run src/polynomial.clj
{:POLYNOMIAL_VERSION "1.2.1"}
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
```

----

### Ruby : src/polynomial.rb

```Ruby
  1   ENV["LD_LIBRARY_PATH"] = 'target/ruby'
  2   $:.unshift 'target/ruby'
  3   
  4   require 'polynomial_swig'
  5   include Polynomial_swig
  6   
  7   pp POLYNOMIAL_VERSION: POLYNOMIAL_VERSION
  8   
  9   p = Polynomial.new
 10   p.coeffs = VectorDouble.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
 11   
 12   pp p.coeffs.to_a
 13   pp p.evaluate(1.2)
```


----

```
$ bin/run src/polynomial.rb
{:POLYNOMIAL_VERSION=>"1.2.1"}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

----

### Guile : src/polynomial.scm

```Scheme
  1   (load-extension "target/guile/libpolynomial_swig.so" "SWIG_init")
  2   
  3   (write `(POLYNOMIAL-VERSION ,(POLYNOMIAL-VERSION))) (newline)
  4   
  5   (define p (new-Polynomial))
  6   (Polynomial-coeffs-set p (new-VectorDouble '(2.3 3.5 5.7 7.11 11.13 -13.17)))
  7   
  8   (write (Polynomial-coeffs-get p)) (newline)
  9   (write (Polynomial-evaluate p 1.2)) (newline)
```


----

```
$ bin/run src/polynomial.scm
(POLYNOMIAL-VERSION "1.2.1")
#<swig-pointer std::vector< double > * 7fa6ba604080>
17.3020736
```

----

### TCL : src/polynomial.tcl

```Bash
  1   load target/tcl/polynomial_swig.so Polynomial_swig
  2   
  3   puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]
  4   
  5   Polynomial poly
  6   VectorDouble c { 2.3 3.5 5.7 7.11 11.13 -13.17 }
  7   poly configure -coeffs c
  8   
  9   puts [poly cget -coeffs]
 10   puts [poly evaluate 1.2]
```


----

```
$ bin/run src/polynomial.tcl
POLYNOMIAL_VERSION 1.2.1
_f078000ef07f0000_p_std__vectorT_double_t
17.3020736
```

----

### Python Tests : src/polynomial-test.py

```Python
  1   import sys ; sys.path.append('target/python')
  2   
  3   from polynomial_swig import Polynomial, VectorDouble
  4   import pytest
  5   
  6   def test_empty_coeffs():
  7       p = Polynomial()
  8       assert p.evaluate(1.2) == 0.0
  9   def test_one_coeff():
 10       p = Polynomial()
 11       p.coeffs = VectorDouble([ 2.3 ])
 12       assert p.evaluate(1.2) == 2.3
 13       assert p.evaluate(999) == 2.3
```


----

```
$ python3.10 -m pytest src/polynomial-test.py
============================= test session starts ==============================
platform darwin -- Python 3.10.4, pytest-7.1.2, pluggy-1.0.0
rootdir: /Users/kstephens/src/dev/swig-101
collected 2 items

src/polynomial-test.py ..                                                [100%]

============================== 2 passed in 0.01s ===============================
```

----

### Output


```
$ target/native/polynomial
POLYNOMIAL_VERSION 1.2.1
17.3020736

```

----

```
$ bin/run src/polynomial.py
{'POLYNOMIAL_VERSION': '1.2.1'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736

```

----

```
$ bin/run src/polynomial.clj
{:POLYNOMIAL_VERSION "1.2.1"}
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736

```

----

```
$ bin/run src/polynomial.rb
{:POLYNOMIAL_VERSION=>"1.2.1"}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736

```

----

```
$ bin/run src/polynomial.scm
(POLYNOMIAL-VERSION "1.2.1")
#<swig-pointer std::vector< double > * 7fa6ba604080>
17.3020736

```

----

```
$ bin/run src/polynomial.tcl
POLYNOMIAL_VERSION 1.2.1
_f078000ef07f0000_p_std__vectorT_double_t
17.3020736

```

----

```
$ python3.10 -m pytest src/polynomial-test.py
============================= test session starts ==============================
platform darwin -- Python 3.10.4, pytest-7.1.2, pluggy-1.0.0
rootdir: /Users/kstephens/src/dev/swig-101
collected 2 items

src/polynomial-test.py ..                                                [100%]

============================== 2 passed in 0.01s ===============================

```

----


## polynomial_v2.cc


### C++ Header : src/polynomial_v2.h

```C++
  1   #include <vector>
  2   
  3   #define POLYNOMIAL_VERSION "2.0.2"
  4   
  5   namespace mathlib {
  6     template < typename R >
  7     class polynomial {
  8     public:
  9       std::vector< R > coeffs;
 10       R evaluate(const R &x) const;
 11     };
 12   }
```


### C++ Library : src/polynomial_v2.cc

```C++
  1   #include "polynomial_v2.h"
  2   #include "rational.h"
  3   
  4   namespace mathlib {
  5     template < typename R >
  6     R polynomial< R >::evaluate(const R &x) const {
  7       R result(0), xx(1);
  8       for ( const auto &c : this->coeffs ) {
  9         result = result + c * xx;
 10         xx = xx * x;
 11       }
 12       return result;
 13     };
 14   
 15     // Instantiate templates:
 16     template class polynomial<int>;
 17     template class polynomial<double>;
 18     template class polynomial<rational<int>>;
 19   }
```


### C++ Main : src/polynomial_v2-native.cc

```C++
  1   #include <iostream>
  2   #include <iomanip>
  3   #include "polynomial_v2.h"
  4   #include "rational.h"
  5   
  6   using namespace mathlib;
  7   
  8   int main(int argc, char **argv) {
  9     std::cout << "POLYNOMIAL_VERSION " << POLYNOMIAL_VERSION << "\n";
 10   
 11     polynomial<double> pd;
 12     pd.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };
 13     std::cout << std::setprecision(9) << pd.evaluate(1.2) << "\n";
 14   
 15     polynomial<int> pi;
 16     pi.coeffs = { 2, -3, 5 };
 17     std::cout << pi.evaluate(3) << "\n";
 18   
 19     typedef rational<int> R;
 20     polynomial<R> pr;
 21     pr.coeffs = { R(7,11), R(11,13), R(13,17) };
 22     std::cout << pr.evaluate(R(5,7)) << "\n";
 23   
 24     return 0;
 25   }
```


----

```
$ target/native/polynomial_v2
POLYNOMIAL_VERSION 2.0.2
17.3020736
38
194273/119119
```

----

### C++ SWIG Interface : src/polynomial_v2.i

```C++
  1   // Name of generated bindings:
  2   %module polynomial_v2_swig
  3   
  4   // Include C++ declarations as SWIG interface definitions:
  5   %include "polynomial_v2.h"
  6   %include "rational.h"
  7   
  8   // Template instantiation:
  9   %{
 10   #include "polynomial_v2.h"
 11   #include "rational.h"
 12   
 13   template class mathlib::polynomial<int>;
 14   template class mathlib::polynomial<double>;
 15   template class mathlib::rational<int>;
 16   template class mathlib::polynomial<mathlib::rational<int>>;
 17   template class std::vector<mathlib::rational<int>>;
 18   %}
 19   
 20   %include "std_string.i"        // python __str__(), __repr__()
 21   %template(RationalV2)            mathlib::rational<int>;
 22   
 23   %include "std_vector.i"
 24   %template(VectorDoubleV2)        std::vector<double>;
 25   %template(VectorIntV2)           std::vector<int>;
 26   %template(VectorRationalV2)      std::vector<mathlib::rational<int>>;
 27   
 28   %template(PolynomialDoubleV2)    mathlib::polynomial<double>;
 29   %template(PolynomialIntV2)       mathlib::polynomial<int>;
 30   %template(PolynomialRationalV2)  mathlib::polynomial<mathlib::rational<int>>;
 31   
 32   // Prepend C++ code in generated bindings:
 33   %{
 34   #include "polynomial_v2.h"
 35   #include "rational.h"
 36   %}
```


### Python : src/polynomial_v2.py

```Python
  1   import sys ; sys.path.append('target/python')
  2   
  3   from polynomial_v2_swig import PolynomialDoubleV2, VectorDoubleV2, PolynomialRationalV2, VectorRationalV2, RationalV2, POLYNOMIAL_VERSION
  4   
  5   print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})
  6   
  7   poly = PolynomialDoubleV2()
  8   poly.coeffs = VectorDoubleV2([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])
  9   print(list(poly.coeffs))
 10   print(poly.evaluate(1.2))
 11   
 12   poly = PolynomialRationalV2()
 13   poly.coeffs = VectorRationalV2([ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13,17) ])
 14   print(list(poly.coeffs))
 15   print(poly.evaluate(RationalV2(5, 7)))
```


----

```
$ bin/run src/polynomial_v2.py
{'POLYNOMIAL_VERSION': '2.0.2'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
[7/11, 11/13, 13/17]
194273/119119
```

----

### Clojure (Java) : src/polynomial_v2.clj

```Lisp
  1   (clojure.lang.RT/loadLibrary "polynomial_v2_swig")
  2   
  3   (import 'polynomial_v2_swig)
  4   
  5   (prn {:POLYNOMIAL_VERSION (polynomial_v2_swig/POLYNOMIAL_VERSION)})
  6   
  7   (def p (PolynomialDoubleV2.))
  8   (.setCoeffs p (VectorDoubleV2. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))
  9   (prn (.getCoeffs p))
 10   (prn (.evaluate p 1.2))
 11   
 12   (def p (PolynomialRationalV2.))
 13   (.setCoeffs p (VectorRationalV2. [ (RationalV2. 7 11) (RationalV2. 11 13) (RationalV2. 13 17) ]))
 14   (prn (mapv #(.__str__ %) (.getCoeffs p)))
 15   (prn (.__str__ (.evaluate p (RationalV2. 5, 7))))
```


----

```
$ bin/run src/polynomial_v2.clj
{:POLYNOMIAL_VERSION "2.0.2"}
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
["7/11" "11/13" "13/17"]
"194273/119119"
```

----

### Output


```
$ target/native/polynomial_v2
POLYNOMIAL_VERSION 2.0.2
17.3020736
38
194273/119119

```

----

```
$ bin/run src/polynomial_v2.py
{'POLYNOMIAL_VERSION': '2.0.2'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
[7/11, 11/13, 13/17]
194273/119119

```

----

```
$ bin/run src/polynomial_v2.clj
{:POLYNOMIAL_VERSION "2.0.2"}
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
["7/11" "11/13" "13/17"]
"194273/119119"

```

----


## example1.c


### C Header : src/example1.h

```C
  1   #define EXAMPLE1_VERSION "1.2.3"
  2   /* Returns: c0 + c1*x + c2*x^2 + c3*x^3 */
  3   double cubic_poly(double x,
  4                     double c0,
  5                     double c1,
  6                     double c2,
  7                     double c3);
```


### C Library : src/example1.c

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


### C Main : src/example1-native.c

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

----

### C SWIG Interface : src/example1.i

```C
  1   %module example1_swig
  2   %include "example1.h"
  3   %{
  4   #include "example1.h"
  5   %}
```


### Python : src/example1.py

```Python
  1   # Setup DLL search path:
  2   import sys ; sys.path.append('target/python')
  3   
  4   # Import library bindings:
  5   import example1_swig as example1
  6   
  7   # Use imported module:
  8   print("EXAMPLE1_VERSION = " + example1.EXAMPLE1_VERSION)
  9   print(example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))
```


----

```
$ bin/run src/example1.py
EXAMPLE1_VERSION = 1.2.3
129.0
```

----

### Clojure (Java) : src/example1.clj

```Lisp
  1   (clojure.lang.RT/loadLibrary "example1_swig")
  2   
  3   (import 'example1_swig)
  4   
  5   (println (format "EXAMPLE1_VERSION = %s" (example1_swig/EXAMPLE1_VERSION)))
  6   (prn (example1_swig/cubic_poly 2.0 3.0 5.0 7.0 11.0))
```


----

```
$ bin/run src/example1.clj
EXAMPLE1_VERSION = 1.2.3
129.0
```

----

### Ruby : src/example1.rb

```Ruby
  1   ENV["LD_LIBRARY_PATH"] = 'target/ruby'
  2   $:.unshift 'target/ruby'
  3   
  4   require 'example1_swig'
  5   include Example1_swig
  6   
  7   puts "EXAMPLE1_VERSION = #{EXAMPLE1_VERSION}"
  8   puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)
```


----

```
$ bin/run src/example1.rb
EXAMPLE1_VERSION = 1.2.3
129.0
```

----

### Guile : src/example1.scm

```Scheme
  1   (load-extension "target/guile/libexample1_swig.so" "SWIG_init")
  2   
  3   (write `(EXAMPLE1-VERSION = ,(EXAMPLE1-VERSION)))
  4   (newline)
  5   (write (cubic-poly 2.0 3.0 5.0 7.0 11.0))
  6   (newline)
```


----

```
$ bin/run src/example1.scm
(EXAMPLE1-VERSION = "1.2.3")
129.0
```

----

### TCL : src/example1.tcl

```Bash
  1   load target/tcl/example1_swig.so Example1_swig
  2   
  3   puts "EXAMPLE1_VERSION = ${EXAMPLE1_VERSION}"
  4   puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]
```


----

```
$ bin/run src/example1.tcl
EXAMPLE1_VERSION = 1.2.3
129.0
```

----

### Output


```
$ target/native/example1
EXAMPLE1_VERSION = 1.2.3
129.0

```

----

```
$ bin/run src/example1.py
EXAMPLE1_VERSION = 1.2.3
129.0

```

----

```
$ bin/run src/example1.clj
EXAMPLE1_VERSION = 1.2.3
129.0

```

----

```
$ bin/run src/example1.rb
EXAMPLE1_VERSION = 1.2.3
129.0

```

----

```
$ bin/run src/example1.scm
(EXAMPLE1-VERSION = "1.2.3")
129.0

```

----

```
$ bin/run src/example1.tcl
EXAMPLE1_VERSION = 1.2.3
129.0

```

----

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

# Example Workflows



## Workflow - polynomial.cc 

### Compile native code: 

``` 

# Compile native library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -c -o  \
  target/native/polynomial.o src/polynomial.cc 

# Compile and link native program: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -o  \
  target/native/polynomial src/polynomial-native.cc target/native/polynomial.o 

``` 

### Build python bindings 
``` 

# Generate python bindings: 
swig -addextern -I- -Isrc -python -c++ -outdir target/python/ -o  \
  target/python/polynomial_swig.cc src/polynomial.i 
# Code statistics: 
wc -l src/polynomial.h src/polynomial.i 
10 src/polynomial.h 
16 src/polynomial.i 
26 total 

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

### Build clojure bindings 
``` 

# Generate clojure bindings: 
swig -addextern -I- -Isrc -java -c++ -outdir target/clojure/ -o  \
  target/clojure/polynomial_swig.cc src/polynomial.i 
# Code statistics: 
wc -l src/polynomial.h src/polynomial.i 
10 src/polynomial.h 
16 src/polynomial.i 
26 total 

wc -l target/clojure/polynomial_swig.cc target/clojure/polynomial*.java 
660 target/clojure/polynomial_swig.cc 
11 target/clojure/polynomial_swig.java 
12 target/clojure/polynomial_swigConstants.java 
32 target/clojure/polynomial_swigJNI.java 
715 total 


# Compile clojure bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -I$JAVA_HOME/include/darwin -c  \
  -o target/clojure/polynomial_swig.cc.o target/clojure/polynomial_swig.cc 


# Link clojure dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/clojure//libpolynomial_swig.jnilib  \
  target/native/polynomial.o target/clojure/polynomial_swig.cc.o 

``` 

### Build ruby bindings 
``` 

# Generate ruby bindings: 
swig -addextern -I- -Isrc -ruby -c++ -outdir target/ruby/ -o  \
  target/ruby/polynomial_swig.cc src/polynomial.i 
# Code statistics: 
wc -l src/polynomial.h src/polynomial.i 
10 src/polynomial.h 
16 src/polynomial.i 
26 total 

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

### Build tcl bindings 
``` 

# Generate tcl bindings: 
swig -addextern -I- -Isrc -tcl -c++ -outdir target/tcl/ -o  \
  target/tcl/polynomial_swig.cc src/polynomial.i 
# Code statistics: 
wc -l src/polynomial.h src/polynomial.i 
10 src/polynomial.h 
16 src/polynomial.i 
26 total 

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

### Build guile bindings 
``` 

# Generate guile bindings: 
swig -addextern -I- -Isrc -guile -c++ -outdir target/guile/ -o  \
  target/guile/polynomial_swig.cc src/polynomial.i 
# Code statistics: 
wc -l src/polynomial.h src/polynomial.i 
10 src/polynomial.h 
16 src/polynomial.i 
26 total 

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




## Workflow - polynomial_v2.cc 

### Compile native code: 

``` 

# Compile native library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -c -o  \
  target/native/polynomial_v2.o src/polynomial_v2.cc 

# Compile and link native program: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -o  \
  target/native/polynomial_v2 src/polynomial_v2-native.cc  \
  target/native/polynomial_v2.o 

``` 

### Build python bindings 
``` 

# Generate python bindings: 
swig -addextern -I- -Isrc -python -c++ -outdir target/python/ -o  \
  target/python/polynomial_v2_swig.cc src/polynomial_v2.i 
# Code statistics: 
wc -l src/polynomial_v2.h src/polynomial_v2.i 
13 src/polynomial_v2.h 
36 src/polynomial_v2.i 
49 total 

wc -l target/python/polynomial_v2_swig.cc target/python/polynomial_v2_swig.py 
13181 target/python/polynomial_v2_swig.cc 
508 target/python/polynomial_v2_swig.py 
13689 total 


# Compile python bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$PYTHON_HOME/include/python3.10 -I$PYTHON_HOME/include/python3.10  \
  -Wno-unused-result -Wsign-compare -Wunreachable-code -fno-common -dynamic  \
  -DNDEBUG -g -fwrapv -O3 -Wall -pipe -Os -Wno-deprecated-declarations -c -o  \
  target/python/polynomial_v2_swig.cc.o target/python/polynomial_v2_swig.cc 


# Link python dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/python//_polynomial_v2_swig.so  \
  target/native/polynomial_v2.o target/python/polynomial_v2_swig.cc.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 

``` 

### Build clojure bindings 
``` 

# Generate clojure bindings: 
swig -addextern -I- -Isrc -java -c++ -outdir target/clojure/ -o  \
  target/clojure/polynomial_v2_swig.cc src/polynomial_v2.i 
src/rational.h:23: Warning 503: Can't wrap 'operator +' unless renamed to a  \
  valid identifier. 
src/rational.h:26: Warning 503: Can't wrap 'operator *' unless renamed to a  \
  valid identifier. 
src/rational.h:29: Warning 503: Can't wrap 'operator ==' unless renamed to a  \
  valid identifier. 
# Code statistics: 
wc -l src/polynomial_v2.h src/polynomial_v2.i 
13 src/polynomial_v2.h 
36 src/polynomial_v2.i 
49 total 

wc -l target/clojure/polynomial_v2_swig.cc target/clojure/polynomial_v2*.java 
1653 target/clojure/polynomial_v2_swig.cc 
11 target/clojure/polynomial_v2_swig.java 
12 target/clojure/polynomial_v2_swigConstants.java 
84 target/clojure/polynomial_v2_swigJNI.java 
1760 total 


# Compile clojure bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -I$JAVA_HOME/include/darwin -c  \
  -o target/clojure/polynomial_v2_swig.cc.o target/clojure/polynomial_v2_swig.cc 


# Link clojure dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/clojure//libpolynomial_v2_swig.jnilib  \
  target/native/polynomial_v2.o target/clojure/polynomial_v2_swig.cc.o 

``` 

### Build ruby bindings 
``` 

# Generate ruby bindings: 
swig -addextern -I- -Isrc -ruby -c++ -outdir target/ruby/ -o  \
  target/ruby/polynomial_v2_swig.cc src/polynomial_v2.i 
# Code statistics: 
wc -l src/polynomial_v2.h src/polynomial_v2.i 
13 src/polynomial_v2.h 
36 src/polynomial_v2.i 
49 total 

wc -l target/ruby/polynomial_v2_swig.cc 
14480 target/ruby/polynomial_v2_swig.cc 


# Compile ruby bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o  \
  target/ruby/polynomial_v2_swig.cc.o target/ruby/polynomial_v2_swig.cc 


# Link ruby dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/ruby//polynomial_v2_swig.bundle  \
  target/native/polynomial_v2.o target/ruby/polynomial_v2_swig.cc.o 

``` 

### Build tcl bindings 
``` 

# Generate tcl bindings: 
swig -addextern -I- -Isrc -tcl -c++ -outdir target/tcl/ -o  \
  target/tcl/polynomial_v2_swig.cc src/polynomial_v2.i 
src/rational.h:29: Warning 503: Can't wrap 'operator ==' unless renamed to a  \
  valid identifier. 
# Code statistics: 
wc -l src/polynomial_v2.h src/polynomial_v2.i 
13 src/polynomial_v2.h 
36 src/polynomial_v2.i 
49 total 

wc -l target/tcl/polynomial_v2_swig.cc 
4669 target/tcl/polynomial_v2_swig.cc 


# Compile tcl bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I/usr/include/tcl -c -o target/tcl/polynomial_v2_swig.cc.o  \
  target/tcl/polynomial_v2_swig.cc 


# Link tcl dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/tcl//polynomial_v2_swig.so  \
  target/native/polynomial_v2.o target/tcl/polynomial_v2_swig.cc.o 

``` 

### Build guile bindings 
``` 

# Generate guile bindings: 
swig -addextern -I- -Isrc -guile -c++ -outdir target/guile/ -o  \
  target/guile/polynomial_v2_swig.cc src/polynomial_v2.i 
src/rational.h:23: Warning 503: Can't wrap 'operator +' unless renamed to a  \
  valid identifier. 
src/rational.h:26: Warning 503: Can't wrap 'operator *' unless renamed to a  \
  valid identifier. 
src/rational.h:29: Warning 503: Can't wrap 'operator ==' unless renamed to a  \
  valid identifier. 
# Code statistics: 
wc -l src/polynomial_v2.h src/polynomial_v2.i 
13 src/polynomial_v2.h 
36 src/polynomial_v2.i 
49 total 

wc -l target/guile/polynomial_v2_swig.cc 
3961 target/guile/polynomial_v2_swig.cc 


# Compile guile bindings: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -D_THREAD_SAFE -c -o target/guile/polynomial_v2_swig.cc.o  \
  target/guile/polynomial_v2_swig.cc 


# Link guile dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/guile//libpolynomial_v2_swig.so  \
  target/native/polynomial_v2.o target/guile/polynomial_v2_swig.cc.o -lguile-2.2  \
  -lgc 

``` 




## Workflow - example1.c 

### Compile native code: 

``` 

# Compile native library: 
clang -g -Isrc -c -o target/native/example1.o src/example1.c 

# Compile and link native program: 
clang -g -Isrc -o target/native/example1 src/example1-native.c  \
  target/native/example1.o 

``` 

### Build python bindings 
``` 

# Generate python bindings: 
swig -addextern -I- -Isrc -python -outdir target/python/ -o  \
  target/python/example1_swig.c src/example1.i 
# Code statistics: 
wc -l src/example1.h src/example1.i 
7 src/example1.h 
5 src/example1.i 
12 total 

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

### Build clojure bindings 
``` 

# Generate clojure bindings: 
swig -addextern -I- -Isrc -java -outdir target/clojure/ -o  \
  target/clojure/example1_swig.c src/example1.i 
# Code statistics: 
wc -l src/example1.h src/example1.i 
7 src/example1.h 
5 src/example1.i 
12 total 

wc -l target/clojure/example1_swig.c target/clojure/example1*.java 
243 target/clojure/example1_swig.c 
15 target/clojure/example1_swig.java 
12 target/clojure/example1_swigConstants.java 
13 target/clojure/example1_swigJNI.java 
283 total 


# Compile clojure bindings: 
clang -g -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/linux  \
  -I$JAVA_HOME/include/darwin -c -o target/clojure/example1_swig.c.o  \
  target/clojure/example1_swig.c 


# Link clojure dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/clojure//libexample1_swig.jnilib target/native/example1.o  \
  target/clojure/example1_swig.c.o 

``` 

### Build ruby bindings 
``` 

# Generate ruby bindings: 
swig -addextern -I- -Isrc -ruby -outdir target/ruby/ -o  \
  target/ruby/example1_swig.c src/example1.i 
# Code statistics: 
wc -l src/example1.h src/example1.i 
7 src/example1.h 
5 src/example1.i 
12 total 

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

### Build tcl bindings 
``` 

# Generate tcl bindings: 
swig -addextern -I- -Isrc -tcl -outdir target/tcl/ -o  \
  target/tcl/example1_swig.c src/example1.i 
# Code statistics: 
wc -l src/example1.h src/example1.i 
7 src/example1.h 
5 src/example1.i 
12 total 

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

### Build guile bindings 
``` 

# Generate guile bindings: 
swig -addextern -I- -Isrc -guile -outdir target/guile/ -o  \
  target/guile/example1_swig.c src/example1.i 
# Code statistics: 
wc -l src/example1.h src/example1.i 
7 src/example1.h 
5 src/example1.i 
12 total 

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
* https://www.swig.org/papers/PyTutorial98/PyTutorial98.pdf

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
* `pip install pytest`
* Run `bin/build debian-prereq`

### OSX

* Install macports
* Run `bin/build macports-prereq`

## Build

```
$ rbenv shell 2.7.1
$ bin/build clean demo
```
