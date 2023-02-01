

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
* Bindings are generated, compiled and linked.
* Bindings can be dynamically loaded or statically linked.
* Generated code is self-contained.
* Hinting improves integration and representation.
* Template-driven: users can create specialized generators.
* Consistency between target languages.

# Applications

* Use dynamic languages to test C/C++ code.
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



## example1.c



### C Header : example1.h

```c
#define EXAMPLE1_VERSION "1.2.3"                                               //  1 
/* Returns: c0 + c1*x + c2*x^2 + c3*x^3 */                                     //  2 
double cubic_poly(double x,                                                    //  3 
                  double c0,                                                   //  4 
                  double c1,                                                   //  5 
                  double c2,                                                   //  6 
                  double c3);                                                  //  7 
```



### C Library : example1.c

```c
#include "example1.h"                                                          //  1 
double cubic_poly(double x,                                                    //  2 
                  double c0,                                                   //  3 
                  double c1,                                                   //  4 
                  double c2,                                                   //  5 
                  double c3) {                                                 //  6 
  return c0 + c1 * x + c2 * x*x + c3 * x*x*x;                                  //  7 
}                                                                              //  8 
```



### C Main : example1-native.c

```c
#include <stdio.h>                                                             //  1 
#include "example1.h"                                                          //  2 
                                                                               //  3 
int main(int argc, char **argv) {                                              //  4 
  printf("EXAMPLE1_VERSION = %s\n", EXAMPLE1_VERSION);                         //  5 
  printf("%5.1f\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));                     //  6 
  return 0;                                                                    //  7 
}                                                                              //  8 
```


---

```
$ bin/run target/native/example1
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


### C SWIG Interface : example1.i

```c
%module example1_swig                                                          //  1 
%include "example1.h"                                                          //  2 
%{                                                                             //  3 
#include "example1.h"                                                          //  4 
%}                                                                             //  5 
```



### Python : example1.py

```python
# Setup search path:                                                           #   1 
import sys ; sys.path.append('target/python')                                  #   2 
                                                                               #   3 
# Load SWIG bindings:                                                          #   4 
import example1_swig as example1                                               #   5 
                                                                               #   6 
# Use SWIG bindings:                                                           #   7 
print("EXAMPLE1_VERSION = " + example1.EXAMPLE1_VERSION)                       #   8 
print(example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))                           #   9 
```


---

```
$ bin/run src/example1.py
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


### Clojure (Java) : example1.clj

```lisp
;; Load SWIG bindings:                                                         ;;  1 
(clojure.lang.RT/loadLibrary "example1_swig")                                  ;;  2 
(import 'example1_swig)                                                        ;;  3 
                                                                               ;;  4 
;; Use SWIG bindings:                                                          ;;  5 
(println (format "EXAMPLE1_VERSION = %s"                                       ;;  6 
               	 (example1_swig/EXAMPLE1_VERSION)))                            ;;  7 
(prn (example1_swig/cubic_poly 2.0 3.0 5.0 7.0 11.0))                          ;;  8 
```


---

```
$ bin/run src/example1.clj
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


### Ruby : example1.rb

```ruby
# Setup search path:                                                           #   1 
ENV["LD_LIBRARY_PATH"] = 'target/ruby'                                         #   2 
$:.unshift 'target/ruby'                                                       #   3 
                                                                               #   4 
# Load SWIG bindings:                                                          #   5 
require 'example1_swig'                                                        #   6 
include Example1_swig                                                          #   7 
                                                                               #   8 
# Use SWIG bindings:                                                           #   9 
puts "EXAMPLE1_VERSION = #{EXAMPLE1_VERSION}"                                  #  10 
puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)                                      #  11 
```


---

```
$ bin/run src/example1.rb
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


### Guile : example1.scm

```scheme
;; Load SWIG bindings:                                                         ;;  1 
(load-extension "target/guile/libexample1_swig.so" "SWIG_init")                ;;  2 
                                                                               ;;  3 
;; Use SWIG bindings:                                                          ;;  4 
(write `(EXAMPLE1-VERSION = ,(EXAMPLE1-VERSION)))                              ;;  5 
(newline)                                                                      ;;  6 
(write (cubic-poly 2.0 3.0 5.0 7.0 11.0))                                      ;;  7 
(newline)                                                                      ;;  8 
```


---

```
$ bin/run src/example1.scm
(EXAMPLE1-VERSION = "1.2.3")
129.0
```

---


### TCL : example1.tcl

```shell
# Load SWIG bindings:                                                          #   1 
load target/tcl/example1_swig.so Example1_swig                                 #   2 
                                                                               #   3 
# Use SWIG bindings:                                                           #   4 
puts "EXAMPLE1_VERSION = ${EXAMPLE1_VERSION}"                                  #   5 
puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]                                         #   6 
```


---

```
$ bin/run src/example1.tcl
EXAMPLE1_VERSION = 1.2.3
129.0
```

---



### Outputs - Recap





```
$ bin/run target/native/example1
EXAMPLE1_VERSION = 1.2.3
129.0
```

---



```
$ bin/run src/example1.py
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


```
$ bin/run src/example1.clj
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


```
$ bin/run src/example1.rb
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


```
$ bin/run src/example1.scm
(EXAMPLE1-VERSION = "1.2.3")
129.0
```

---


```
$ bin/run src/example1.tcl
EXAMPLE1_VERSION = 1.2.3
129.0
```

---


---



## polynomial.cc



### C++ Header : polynomial.h

```c++
#include <vector>                                                              //  1 
                                                                               //  2 
#define POLYNOMIAL_VERSION "1.2.1"                                             //  3 
                                                                               //  4 
class Polynomial {                                                             //  5 
public:                                                                        //  6 
  std::vector<double> coeffs;                                                  //  7 
  double evaluate(double x) const;                                             //  8 
};                                                                             //  9 
```



### C++ Library : polynomial.cc

```c++
#include "polynomial.h"                                                        //  1 
                                                                               //  2 
double Polynomial::evaluate(double x) const {                                  //  3 
  double result = 0, xx = 1;                                                   //  4 
  for ( auto c : this->coeffs ) {                                              //  5 
    result = result + c * xx;                                                  //  6 
    xx = xx * x;                                                               //  7 
  }                                                                            //  8 
  return result;                                                               //  9 
}                                                                              // 10 
```



### C++ Main : polynomial-native.cc

```c++
#include <iostream>                                                            //  1 
#include <iomanip>                                                             //  2 
#include "polynomial.h"                                                        //  3 
                                                                               //  4 
int main(int argc, char **argv) {                                              //  5 
  std::cout << "POLYNOMIAL_VERSION " << POLYNOMIAL_VERSION << "\n";            //  6 
                                                                               //  7 
  Polynomial p;                                                                //  8 
  p.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };                           //  9 
  std::cout << std::setprecision(9) << p.evaluate(1.2) << "\n";                // 10 
                                                                               // 11 
  return 0;                                                                    // 12 
}                                                                              // 13 
```


---

```
$ bin/run target/native/polynomial
POLYNOMIAL_VERSION 1.2.1
17.3020736
```

---


### C++ SWIG Interface : polynomial.i

```c++
// Name of generated bindings:                                                 //  1 
%module polynomial_swig                                                        //  2 
                                                                               //  3 
// Include std::vector<T> support:                                             //  4 
%include "std_vector.i"                                                        //  5 
                                                                               //  6 
// Template instantiation:                                                     //  7 
%template(VectorDouble) std::vector<double>;                                   //  8 
                                                                               //  9 
// Include C++ declarations as SWIG interface definitions:                     // 10 
%include "polynomial.h"                                                        // 11 
                                                                               // 12 
// Prepend C++ code in generated bindings:                                     // 13 
%{                                                                             // 14 
#include "polynomial.h"                                                        // 15 
%}                                                                             // 16 
```



### Python : polynomial.py

```python
from polynomial_swig import *                                                  #   1 
                                                                               #   2 
print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})                              #   3 
                                                                               #   4 
# Instantiate object:                                                          #   5 
poly = Polynomial()                                                            #   6 
poly.coeffs = VectorDouble([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])             #   7 
                                                                               #   8 
# Invoke methods:                                                              #   9 
print(list(poly.coeffs))                                                       #  10 
print(poly.evaluate(1.2))                                                      #  11 
```


---

```
$ bin/run src/polynomial.py
{'POLYNOMIAL_VERSION': '1.2.1'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---

### Python : polynomial-test.py

```python
from polynomial_swig import *                                                  #   1 
import pytest                                                                  #   2 
                                                                               #   3 
def test_empty_coeffs():                                                       #   4 
    p = Polynomial()                                                           #   5 
    assert p.evaluate(1.2) == 0.0                                              #   6 
def test_one_coeff():                                                          #   7 
    p = Polynomial()                                                           #   8 
    p.coeffs = VectorDouble([ 2.3 ])                                           #   9 
    assert p.evaluate(1.2) == 2.3                                              #  10 
    assert p.evaluate(999) == 2.3                                              #  11 
```


---

```
$ bin/run src/polynomial-test.py

```

---


### Clojure (Java) : polynomial.clj

```lisp
(clojure.lang.RT/loadLibrary "polynomial_swig")                                ;;  1 
(import 'polynomial_swig)                                                      ;;  2 
                                                                               ;;  3 
(prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})               ;;  4 
                                                                               ;;  5 
;; Instantiate object:                                                         ;;  6 
(def p (Polynomial.))                                                          ;;  7 
(.setCoeffs p (VectorDouble. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))               ;;  8 
                                                                               ;;  9 
;; Invoke methods:                                                             ;; 10 
(prn (.getCoeffs p))                                                           ;; 11 
(prn (.evaluate p 1.2))                                                        ;; 12 
```


---

```
$ bin/run src/polynomial.clj
{:POLYNOMIAL_VERSION "1.2.1"}
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
```

---


### Ruby : polynomial.rb

```ruby
require 'polynomial_swig'                                                      #   1 
include Polynomial_swig                                                        #   2 
                                                                               #   3 
pp POLYNOMIAL_VERSION: POLYNOMIAL_VERSION                                      #   4 
                                                                               #   5 
# Instantiate object:                                                          #   6 
p = Polynomial.new                                                             #   7 
p.coeffs = VectorDouble.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])            #   8 
                                                                               #   9 
# Invoke methods:                                                              #  10 
pp p.coeffs.to_a                                                               #  11 
pp p.evaluate(1.2)                                                             #  12 
```


---

```
$ bin/run src/polynomial.rb
{:POLYNOMIAL_VERSION=>"1.2.1"}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---


### Guile : polynomial.scm

```scheme
(load-extension "target/guile/libpolynomial_swig.so" "SWIG_init")              ;;  1 
                                                                               ;;  2 
(write `(POLYNOMIAL-VERSION ,(POLYNOMIAL-VERSION))) (newline)                  ;;  3 
                                                                               ;;  4 
;; Instantiate object:                                                         ;;  5 
(define p (new-Polynomial))                                                    ;;  6 
(Polynomial-coeffs-set p (new-VectorDouble '(2.3 3.5 5.7 7.11 11.13 -13.17)))  ;;  7 
                                                                               ;;  8 
;; Invoke methods:                                                             ;;  9 
(write (Polynomial-coeffs-get p)) (newline)                                    ;; 10 
(write (Polynomial-evaluate p 1.2)) (newline)                                  ;; 11 
```


---

```
$ bin/run src/polynomial.scm
(POLYNOMIAL-VERSION "1.2.1")
#<swig-pointer std::vector< double > * 133608e70>
17.3020736
```

---


### TCL : polynomial.tcl

```shell
load target/tcl/polynomial_swig.so Polynomial_swig                             #   1 
                                                                               #   2 
puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]                             #   3 
                                                                               #   4 
# Instantiate object:                                                          #   5 
Polynomial poly                                                                #   6 
VectorDouble c { 2.3 3.5 5.7 7.11 11.13 -13.17 }                               #   7 
poly configure -coeffs c                                                       #   8 
                                                                               #   9 
# Invoke methods:                                                              #  10 
puts [poly cget -coeffs]                                                       #  11 
puts [poly evaluate 1.2]                                                       #  12 
```


---

```
$ bin/run src/polynomial.tcl
POLYNOMIAL_VERSION 1.2.1
_d0dd602101000000_p_std__vectorT_double_t
17.3020736
```

---


### Python Tests : polynomial-test.py

```python
from polynomial_swig import *                                                  #   1 
import pytest                                                                  #   2 
                                                                               #   3 
def test_empty_coeffs():                                                       #   4 
    p = Polynomial()                                                           #   5 
    assert p.evaluate(1.2) == 0.0                                              #   6 
def test_one_coeff():                                                          #   7 
    p = Polynomial()                                                           #   8 
    p.coeffs = VectorDouble([ 2.3 ])                                           #   9 
    assert p.evaluate(1.2) == 2.3                                              #  10 
    assert p.evaluate(999) == 2.3                                              #  11 
```


---

```
$ bin/run python3.10 -m pytest src/polynomial-test.py
============================= test session starts ==============================
platform darwin -- Python 3.10.9, pytest-7.1.2, pluggy-1.0.0
rootdir: .
plugins: cov-4.0.0
collected 2 items

src/polynomial-test.py ..                                                [100%]

============================== 2 passed in 0.00s ===============================
```

---


### Outputs - Recap





```
$ bin/run target/native/polynomial
POLYNOMIAL_VERSION 1.2.1
17.3020736
```

---



```
$ bin/run src/polynomial.py
{'POLYNOMIAL_VERSION': '1.2.1'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---

```
$ bin/run src/polynomial-test.py

```

---


```
$ bin/run src/polynomial.clj
{:POLYNOMIAL_VERSION "1.2.1"}
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
```

---


```
$ bin/run src/polynomial.rb
{:POLYNOMIAL_VERSION=>"1.2.1"}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---


```
$ bin/run src/polynomial.scm
(POLYNOMIAL-VERSION "1.2.1")
#<swig-pointer std::vector< double > * 133608e70>
17.3020736
```

---


```
$ bin/run src/polynomial.tcl
POLYNOMIAL_VERSION 1.2.1
_d0dd602101000000_p_std__vectorT_double_t
17.3020736
```

---


```
$ bin/run python3.10 -m pytest src/polynomial-test.py
============================= test session starts ==============================
platform darwin -- Python 3.10.9, pytest-7.1.2, pluggy-1.0.0
rootdir: .
plugins: cov-4.0.0
collected 2 items

src/polynomial-test.py ..                                                [100%]

============================== 2 passed in 0.00s ===============================
```

---

---



## polynomial_v2.cc



### C++ Header : polynomial_v2.h

```c++
#include <vector>                                                              //  1 
                                                                               //  2 
#define POLYNOMIAL_VERSION "2.0.2"                                             //  3 
                                                                               //  4 
namespace mathlib {                                                            //  5 
  template < typename R >                                                      //  6 
  class polynomial {                                                           //  7 
  public:                                                                      //  8 
    std::vector< R > coeffs;                                                   //  9 
    R evaluate(const R &x) const;                                              // 10 
  };                                                                           // 11 
}                                                                              // 12 
```



### C++ Library : polynomial_v2.cc

```c++
#include "polynomial_v2.h"                                                     //  1 
#include "rational.h"                                                          //  2 
                                                                               //  3 
namespace mathlib {                                                            //  4 
  template < typename R >                                                      //  5 
  R polynomial< R >::evaluate(const R &x) const {                              //  6 
    R result(0), xx(1);                                                        //  7 
    for ( const auto &c : this->coeffs ) {                                     //  8 
      result = result + c * xx;                                                //  9 
      xx = xx * x;                                                             // 10 
    }                                                                          // 11 
    return result;                                                             // 12 
  };                                                                           // 13 
                                                                               // 14 
  // Instantiate templates:                                                    // 15 
  template class polynomial<int>;                                              // 16 
  template class polynomial<double>;                                           // 17 
  template class polynomial<rational<int>>;                                    // 18 
}                                                                              // 19 
```



### C++ Main : polynomial_v2-native.cc

```c++
#include <iostream>                                                            //  1 
#include <iomanip>                                                             //  2 
#include "polynomial_v2.h"                                                     //  3 
#include "rational.h"                                                          //  4 
                                                                               //  5 
using namespace mathlib;                                                       //  6 
                                                                               //  7 
int main(int argc, char **argv) {                                              //  8 
  std::cout << "POLYNOMIAL_VERSION " << POLYNOMIAL_VERSION << "\n";            //  9 
                                                                               // 10 
  polynomial<double> pd;                                                       // 11 
  pd.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };                          // 12 
  std::cout << std::setprecision(9) << pd.evaluate(1.2) << "\n";               // 13 
                                                                               // 14 
  polynomial<int> pi;                                                          // 15 
  pi.coeffs = { 2, 3, 5, 7, 11, -13 };                                         // 16 
  std::cout << pi.evaluate(-2) << "\n";                                        // 17 
                                                                               // 18 
  typedef rational<int> R;                                                     // 19 
  polynomial<R> pr;                                                            // 20 
  pr.coeffs = { R(7,11), R(11,13), R(13,17) };                                 // 21 
  std::cout << pr.evaluate(R(5,7)) << "\n";                                    // 22 
                                                                               // 23 
  return 0;                                                                    // 24 
}                                                                              // 25 
```


---

```
$ bin/run target/native/polynomial_v2
POLYNOMIAL_VERSION 2.0.2
17.3020736
552
194273/119119
```

---


### C++ SWIG Interface : polynomial_v2.i

```c++
// Name of generated bindings:                                                 //  1 
%module polynomial_v2_swig                                                     //  2 
                                                                               //  3 
// Include C++ declarations as SWIG interface definitions:                     //  4 
%include "polynomial_v2.h"                                                     //  5 
%include "rational.h"                                                          //  6 
                                                                               //  7 
// Template instantiation:                                                     //  8 
%{                                                                             //  9 
#include "polynomial_v2.h"                                                     // 10 
#include "rational.h"                                                          // 11 
                                                                               // 12 
template class mathlib::polynomial<int>;                                       // 13 
template class mathlib::polynomial<double>;                                    // 14 
template class mathlib::rational<int>;                                         // 15 
template class mathlib::polynomial<mathlib::rational<int>>;                    // 16 
template class std::vector<mathlib::rational<int>>;                            // 17 
%}                                                                             // 18 
                                                                               // 19 
%include "std_string.i"        // python __str__(), __repr__()                 // 20 
%template(RationalV2)            mathlib::rational<int>;                       // 21 
                                                                               // 22 
%include "std_vector.i"                                                        // 23 
%template(VectorDoubleV2)        std::vector<double>;                          // 24 
%template(VectorIntV2)           std::vector<int>;                             // 25 
%template(VectorRationalV2)      std::vector<mathlib::rational<int>>;          // 26 
                                                                               // 27 
%template(PolynomialDoubleV2)    mathlib::polynomial<double>;                  // 28 
%template(PolynomialIntV2)       mathlib::polynomial<int>;                     // 29 
%template(PolynomialRationalV2)  mathlib::polynomial<mathlib::rational<int>>;  // 30 
                                                                               // 31 
// Prepend C++ code in generated bindings:                                     // 32 
%{                                                                             // 33 
#include "polynomial_v2.h"                                                     // 34 
#include "rational.h"                                                          // 35 
%}                                                                             // 36 
```



### Python : polynomial_v2.py

```python
from polynomial_v2_swig import *                                                             #   1 
                                                                                             #   2 
print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})                                            #   3 
                                                                                             #   4 
# Instantiate polynomial<double> object:                                                     #   5 
poly         = PolynomialDoubleV2()                                                          #   6 
poly.coeffs  = VectorDoubleV2([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])                        #   7 
print(list(poly.coeffs))                                                                     #   8 
print(poly.evaluate(1.2))                                                                    #   9 
                                                                                             #  10 
# Instantiate polynomial<int> object:                                                        #  11 
poly        = PolynomialIntV2()                                                              #  12 
poly.coeffs = VectorIntV2([ 2, 3, 5, 7, 11, -13 ])                                           #  13 
print(list(poly.coeffs))                                                                     #  14 
print(poly.evaluate(-2))                                                                     #  15 
                                                                                             #  16 
# Instantiate polynomial<rational<int>> object:                                              #  17 
poly        = PolynomialRationalV2()                                                         #  18 
poly.coeffs = VectorRationalV2([ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13,17) ]) #  19 
print(list(poly.coeffs))                                                                     #  20 
print(poly.evaluate(RationalV2(5, 7)))                                                       #  21 
```


---

```
$ bin/run src/polynomial_v2.py
{'POLYNOMIAL_VERSION': '2.0.2'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
[2, 3, 5, 7, 11, -13]
552
[rational(7,11), rational(11,13), rational(13,17)]
194273/119119
```

---


### Clojure (Java) : polynomial_v2.clj

```lisp
(clojure.lang.RT/loadLibrary "polynomial_v2_swig")                                                 ;;  1 
(import 'polynomial_v2_swig)                                                                       ;;  2 
                                                                                                   ;;  3 
(prn {:POLYNOMIAL_VERSION (polynomial_v2_swig/POLYNOMIAL_VERSION)})                                ;;  4 
                                                                                                   ;;  5 
;; Instantiate polynomial<double> object:                                                          ;;  6 
(def p1 (PolynomialDoubleV2.))                                                                     ;;  7 
(.setCoeffs p1 (VectorDoubleV2. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))                                ;;  8 
(prn (.getCoeffs p1))                                                                              ;;  9 
(prn (.evaluate p1 1.2))                                                                           ;; 10 
                                                                                                   ;; 11 
;; Instantiate polynomial<int> object:                                                             ;; 12 
(def p2 (PolynomialIntV2.))                                                                        ;; 13 
(.setCoeffs p2 (VectorIntV2. (map int [2 3 5 7 11 -13])))                                          ;; 14 
(prn (.getCoeffs p2))                                                                              ;; 15 
(prn (.evaluate p2 -2))                                                                            ;; 16 
                                                                                                   ;; 17 
;; Instantiate polynomial<rational<int>> object:                                                   ;; 18 
(def p3 (PolynomialRationalV2.))                                                                   ;; 19 
(.setCoeffs p3 (VectorRationalV2. [ (RationalV2. 7 11) (RationalV2. 11 13) (RationalV2. 13 17) ])) ;; 20 
(prn (mapv #(.__str__ %) (.getCoeffs p3)))                                                         ;; 21 
(prn (.__str__ (.evaluate p3 (RationalV2. 5, 7))))                                                 ;; 22 
```



### Ruby : polynomial_v2.rb

```ruby
require 'polynomial_v2_swig'                                                                                                     #   1 
PV2 = Polynomial_v2_swig                                                                                                         #   2 
                                                                                                                                 #   3 
pp POLYNOMIAL_VERSION: PV2::POLYNOMIAL_VERSION                                                                                   #   4 
                                                                                                                                 #   5 
# Instantiate polynomial<double> object:                                                                                         #   6 
poly        = PV2::PolynomialDoubleV2.new                                                                                        #   7 
poly.coeffs = PV2::VectorDoubleV2.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])                                                    #   8 
pp poly.coeffs.to_a                                                                                                              #   9 
pp poly.evaluate(1.2)                                                                                                            #  10 
                                                                                                                                 #  11 
# Instantiate polynomial<int> object:                                                                                            #  12 
poly        = PV2::PolynomialIntV2.new                                                                                           #  13 
poly.coeffs = PV2::VectorIntV2.new([ 2, 3, 5, 7, 11, -13 ])                                                                      #  14 
pp poly.coeffs.to_a                                                                                                              #  15 
pp poly.evaluate(-2)                                                                                                             #  16 
                                                                                                                                 #  17 
# Instantiate polynomial<rational<int>> object:                                                                                  #  18 
poly        = PV2::PolynomialRationalV2.new()                                                                                    #  19 
poly.coeffs = PV2::VectorRationalV2.new([ PV2::RationalV2.new(7, 11), PV2::RationalV2.new(11, 13), PV2::RationalV2.new(13,17) ]) #  20 
pp poly.coeffs.to_a                                                                                                              #  21 
pp poly.evaluate(PV2::RationalV2.new(5, 7))                                                                                      #  22 
```


---

```
$ bin/run src/polynomial_v2.rb
{:POLYNOMIAL_VERSION=>"2.0.2"}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
[2, 3, 5, 7, 11, -13]
552
[rational(7,11), rational(11,13), rational(13,17)]
rational(194273,119119)
```

---





### Outputs - Recap





```
$ bin/run target/native/polynomial_v2
POLYNOMIAL_VERSION 2.0.2
17.3020736
552
194273/119119
```

---



```
$ bin/run src/polynomial_v2.py
{'POLYNOMIAL_VERSION': '2.0.2'}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
[2, 3, 5, 7, 11, -13]
552
[rational(7,11), rational(11,13), rational(13,17)]
194273/119119
```

---



```
$ bin/run src/polynomial_v2.rb
{:POLYNOMIAL_VERSION=>"2.0.2"}
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
[2, 3, 5, 7, 11, -13]
552
[rational(7,11), rational(11,13), rational(13,17)]
rational(194273,119119)
```

---




---



## tommath.c



### C Header : tommath.h

```c
// swig <-> mp_int helpers                                                     //  1 
                                                                               //  2 
#include <stddef.h>                                                            //  3 
#include <stdint.h>                                                            //  4 
#include "bool.h"                                                              //  5 
#include "libtommath/tommath.h"                                                //  6 
                                                                               //  7 
// Convert mp_int <-> string:                                                  //  8 
char*    swig_mp_int_to_charP(mp_int* self, int radix);                        //  9 
mp_int*  swig_charP_to_mp_int(const char* str, int radix);                     // 10 
char*    swig_mp_int_rep(mp_int* self, int radix);                             // 11 
                                                                               // 12 
#if SWIG                                                                       // 13 
// This extends generated classes with two                                     // 14 
// methods which behave as Python's methods.                                   // 15 
// Also for Ruby and other language targets.                                   // 16 
%extend mp_int {                                                               // 17 
  char* __str__(int radix = 10) {                                              // 18 
    return swig_mp_int_to_charP(self, radix);                                  // 19 
  }                                                                            // 20 
  char* __repr__(int radix = 10) {                                             // 21 
    return swig_mp_int_rep(self, radix);                                       // 22 
  }                                                                            // 23 
}                                                                              // 24 
#endif                                                                         // 25 
                                                                               // 26 
// tommath `mp_int` internal memory is managed by:                             // 27 
//                                                                             // 28 
// * mp_init(mp_int*)                                                          // 29 
// * mp_clear(mp_int*)                                                         // 30 
//                                                                             // 31 
// tommath expects these functions to be called                                // 32 
// before and after using a mp_int value, respectively.                        // 33 
mp_int*  swig_mp_int_new(mp_digit n);                                          // 34 
void     swig_mp_int_delete(mp_int* self);                                     // 35 
                                                                               // 36 
#if SWIG                                                                       // 37 
// SWIG wraps `struct mp_int` values with pointers                             // 38 
// allocated with `malloc(sizeof(mp_int))`.                                    // 39 
// `%extend mp_int` defines constructors and destructors for `mp_int`.         // 40 
%extend mp_int {                                                               // 41 
  mp_int(mp_digit n = 0) {                                                     // 42 
    return swig_mp_int_new(n);                                                 // 43 
  }                                                                            // 44 
  mp_int(const char *str, int radix = 10) {                                    // 45 
    return swig_charP_to_mp_int(str, radix);                                   // 46 
  }                                                                            // 47 
  ~mp_int() {                                                                  // 48 
    swig_mp_int_delete(self);                                                  // 49 
  }                                                                            // 50 
}                                                                              // 51 
#endif                                                                         // 52 
```



### C Library : tommath.c

```c
#include "tommath.h"                                                           //  1 
#define _GNU_SOURCE                                                            //  2 
#include <stdlib.h>                                                            //  3 
                                                                               //  4 
char* swig_mp_int_to_charP(mp_int* self, int radix) {                          //  5 
  size_t size = 0, written = 0;                                                //  6 
  (void) mp_radix_size(self, radix, &size);                                    //  7 
  char* buf = malloc(size + 1);                                                //  8 
  (void) mp_to_radix(self, buf, size, &written, radix);                        //  9 
  buf[written - 1] = 0;                                                        // 10 
  return buf;                                                                  // 11 
}                                                                              // 12 
                                                                               // 13 
char* swig_mp_int_rep(mp_int* self, int radix) {                               // 14 
  char *repr = 0, *str = swig_mp_int_to_charP(self, radix);                    // 15 
  if ( radix == 10 )                                                           // 16 
    asprintf(&repr, "mp_int(\"%s\")", str);                                    // 17 
  else                                                                         // 18 
    asprintf(&repr, "mp_int(\"%s\",%d)", str, radix);                          // 19 
  return free(str), repr;                                                      // 20 
}                                                                              // 21 
                                                                               // 22 
mp_int* swig_charP_to_mp_int(const char* str, int radix) {                     // 23 
  mp_int* self = swig_mp_int_new(0);                                           // 24 
  (void) mp_read_radix(self, str, radix);                                      // 25 
  return self;                                                                 // 26 
}                                                                              // 27 
                                                                               // 28 
mp_int* swig_mp_int_new(mp_digit n) {                                          // 29 
  mp_int* self = malloc(sizeof(*self));                                        // 30 
  (void) mp_init(self);                                                        // 31 
  mp_set(self, n);                                                             // 32 
  return self;                                                                 // 33 
}                                                                              // 34 
                                                                               // 35 
void swig_mp_int_delete(mp_int* self) {                                        // 36 
  mp_clear(self);                                                              // 37 
  free(self);                                                                  // 38 
}                                                                              // 39 
```



### C Main : tommath-native.c

```c
#include "libtommath/tommath.h"                                                          //  1 
                                                                                         //  2 
int main(int argc, char **argv) {                                                        //  3 
  printf("MP_ITER %d\n", MP_ITER);                                                       //  4 
                                                                                         //  5 
  mp_int a, b, c, d, e;                                                                  //  6 
                                                                                         //  7 
  (void) mp_init_multi(&a, &b, &c, &d, &e, NULL);                                        //  8 
                                                                                         //  9 
  (void) mp_set(&a, 2357111317);                                                         // 10 
  (void) mp_set(&b, 1113171923);                                                         // 11 
  (void) mp_read_radix(&e, "12343456", 16);                                              // 12 
                                                                                         // 13 
  (void) mp_mul(&a, &b, &c);                                                             // 14 
  (void) mp_mul(&c, &b, &d);                                                             // 15 
                                                                                         // 16 
#define P(N) printf("%s = ", #N); (void) mp_fwrite(&N, 10, stdout); fputc('\n', stdout); // 17 
  P(a); P(b); P(c); P(d); P(e);                                                          // 18 
  mp_clear_multi(&a, &b, &c, &d, &e, NULL);                                              // 19 
                                                                                         // 20 
  return 0;                                                                              // 21 
}                                                                                        // 22 
```


---

```
$ bin/run target/native/tommath
MP_ITER -4
a = 2357111317
b = 1113171923
c = 2623870137469952591
d = 2920818566629701480442302493
e = 305411158
```

---


### C SWIG Interface : tommath.i

```c
%module tommath_swig                                                           //  1 
%include "stdint.i" // mp_digit typedef                                        //  2 
 // "missing sentinel in function call"                                        //  3 
%varargs(10, mp_int *ip = NULL) mp_init_multi;                                 //  4 
%varargs(10, mp_int *ip = NULL) mp_clear_multi;                                //  5 
//%rename(bool)  _bool;                                                        //  6 
//%rename(true)  _true;                                                        //  7 
//%rename(false) _false;                                                       //  8 
//%ignore bool;                                                                //  9 
//%ignore true;                                                                // 10 
//%ignore false;                                                               // 11 
%{                                                                             // 12 
#include "tommath.h"                                                           // 13 
%}                                                                             // 14 
%include "libtommath/tommath.h"                                                // 15 
%include "tommath.h"                                                           // 16 
```



### Python : tommath.py

```python
from tommath_swig import *                                                     #   1 
                                                                               #   2 
print({"MP_ITER": MP_ITER})                                                    #   3 
                                                                               #   4 
a = mp_int(); mp_set(a, 2357111317)    # <-- awkward!                          #   5 
b = mp_int(1113171923)                 # <-- better!                           #   6 
c = mp_int()                                                                   #   7 
d = mp_int()                                                                   #   8 
e = mp_int("12343456", 16)             # <-- yey!                              #   9 
                                                                               #  10 
print({"a": a, "b": b, "c": c, "d": d, "e": e})                                #  11 
                                                                               #  12 
mp_mul(a, b, c);                                                               #  13 
mp_mul(c, b, d);                                                               #  14 
                                                                               #  15 
print({"a": a, "b": b, "c": c, "d": d, "e": e})                                #  16 
```


---

```
$ bin/run src/tommath.py
{'MP_ITER': -4}
{'a': mp_int("2357111317"), 'b': mp_int("1113171923"), 'c': mp_int("0"), 'd': mp_int("0"), 'e': mp_int("305411158")}
{'a': mp_int("2357111317"), 'b': mp_int("1113171923"), 'c': mp_int("2623870137469952591"), 'd': mp_int("2920818566629701480442302493"), 'e': mp_int("305411158")}
```

---



### Ruby : tommath-1.rb

```ruby
require 'tommath_swig'                                                         #   1 
include Tommath_swig                                                           #   2 
                                                                               #   3 
puts "MP_ITER = #{MP_ITER}"                                                    #   4 
                                                                               #   5 
a = Mp_int.new(); mp_set(a, 2357111317)    # <-- awkward!                      #   6 
b = Mp_int.new(1113171923)                 # <-- better!                       #   7 
c = Mp_int.new()                                                               #   8 
d = Mp_int.new()                                                               #   9 
e = Mp_int.new("12343456", 16)             # <-- yey!                          #  10 
                                                                               #  11 
puts({"a": a, "b": b, "c": c, "d": d, "e": e})                                 #  12 
                                                                               #  13 
mp_mul(a, b, c);                                                               #  14 
mp_mul(c, b, d);                                                               #  15 
                                                                               #  16 
puts({"a": a, "b": b, "c": c, "d": d, "e": e})                                 #  17 
```


---

```
$ bin/run src/tommath-1.rb
MP_ITER = -4
{:a=>mp_int("2357111317"), :b=>mp_int("1113171923"), :c=>mp_int("0"), :d=>mp_int("0"), :e=>mp_int("305411158")}
{:a=>mp_int("2357111317"), :b=>mp_int("1113171923"), :c=>mp_int("2623870137469952591"), :d=>mp_int("2920818566629701480442302493"), :e=>mp_int("305411158")}
```

---

### Ruby : tommath-2.rb

```ruby
require 'tommath-mpi'                                                          #   1 
                                                                               #   2 
a = MPI[2357111317]                                                            #   3 
b = MPI[1113171923]                                                            #   4 
c = MPI[]                                                                      #   5 
d = MPI[]                                                                      #   6 
e = MPI["12343456", 16]                                                        #   7 
                                                                               #   8 
puts({a: a, b: b, c: c, d: d, e: e})                                           #   9 
                                                                               #  10 
c = a * b                                                                      #  11 
d = c * b                                                                      #  12 
                                                                               #  13 
puts({a: a, b: b, c: c, d: d, e: e})                                           #  14 
```


---

```
$ bin/run src/tommath-2.rb
{:a=>MPI["2357111317"], :b=>MPI["1113171923"], :c=>MPI["0"], :d=>MPI["0"], :e=>MPI["305411158"]}
{:a=>MPI["2357111317"], :b=>MPI["1113171923"], :c=>MPI["2623870137469952591"], :d=>MPI["2920818566629701480442302493"], :e=>MPI["305411158"]}
```

---

### Ruby : tommath-mpi.rb

```ruby
require 'tommath_swig'                                                         #   1 
                                                                               #   2 
#########################################################                      #   3 
# Sugar:                                                                       #   4 
                                                                               #   5 
module Tommath_swig                                                            #   6 
  class Mp_int                                                                 #   7 
    # Constructor:                                                             #   8 
    def self.[] val = 0, radix = 10                                            #   9 
      case val                                                                 #  10 
      when self                                                                #  11 
        val                                                                    #  12 
      when Integer                                                             #  13 
        inst = new                                                             #  14 
        Tommath_swig.mp_set(inst, val)                                         #  15 
        inst                                                                   #  16 
      when String                                                              #  17 
        Tommath_swig.swig_charP_to_mp_int(val, radix)                          #  18 
      when nil                                                                 #  19 
        self[0]                                                                #  20 
      else                                                                     #  21 
        raise TypeError, "#{val.inspect} #{radix.inspect}"                     #  22 
      end                                                                      #  23 
    end                                                                        #  24 
                                                                               #  25 
    def to_s radix = 10                                                        #  26 
      Tommath_swig.swig_mp_int_to_charP(self, radix)                           #  27 
    end                                                                        #  28 
                                                                               #  29 
    def inspect                                                                #  30 
      "MPI[#{to_s.inspect}]"                                                   #  31 
    end                                                                        #  32 
                                                                               #  33 
    def -@                                                                     #  34 
      result = MPI.new                                                         #  35 
      Tommath_swig.mp_neg(self, result)                                        #  36 
      result                                                                   #  37 
    end                                                                        #  38 
    def + other                                                                #  39 
      result = MPI.new                                                         #  40 
      Tommath_swig.mp_add(self, MPI[other], result)                            #  41 
      result                                                                   #  42 
    end                                                                        #  43 
    def - other                                                                #  44 
      result = MPI.new                                                         #  45 
      Tommath_swig.mp_sub(self, MPI[other], result)                            #  46 
      result                                                                   #  47 
    end                                                                        #  48 
    def * other                                                                #  49 
      result = MPI.new                                                         #  50 
      Tommath_swig.mp_mul(self, MPI[other], result)                            #  51 
      result                                                                   #  52 
    end                                                                        #  53 
    def / other                                                                #  54 
      result = MPI.new                                                         #  55 
      remainder = MPI.new                                                      #  56 
      Tommath_swig.mp_div(self, MPI[other], result, remainder)                 #  57 
      result                                                                   #  58 
    end                                                                        #  59 
  end                                                                          #  60 
  MPI = Mp_int                                                                 #  61 
end                                                                            #  62 
MPI = Tommath_swig::MPI                                                        #  63 
```



### Guile : tommath.scm

```scheme
(load-extension "target/guile/libtommath_swig.so" "SWIG_init")                 ;;  1 
                                                                               ;;  2 
(write `(MP-ITER ,(MP-ITER))) (newline)                                        ;;  3 
                                                                               ;;  4 
(define a (new-mp-int))                                                        ;;  5 
(mp-set a 2357111317);    # <-- awkward!                                       ;;  6 
(define b (new-mp-int 1113171923));                 # <-- better!              ;;  7 
(define c (new-mp-int))                                                        ;;  8 
(define d (new-mp-int))                                                        ;;  9 
(define e (new-mp-int "12343456" 16));             # <-- yey!                  ;; 10 
                                                                               ;; 11 
(define (show!)                                                                ;; 12 
  (let ((r mp-int---str--))                                                    ;; 13 
    (write `(a ,(r a) b ,(r b) c ,(r c) d ,(r d) e ,(r e)))                    ;; 14 
    (newline)))                                                                ;; 15 
                                                                               ;; 16 
(show!)                                                                        ;; 17 
                                                                               ;; 18 
(mp-mul a b c)                                                                 ;; 19 
(mp-mul c b d)                                                                 ;; 20 
                                                                               ;; 21 
(show!)                                                                        ;; 22 
```


---

```
$ bin/run src/tommath.scm
(MP-ITER -4)
(a "2357111317" b "1113171923" c "0" d "0" e "305411158")
(a "2357111317" b "1113171923" c "2623870137469952591" d "2920818566629701480442302493" e "305411158")
```

---




### Outputs - Recap





```
$ bin/run target/native/tommath
MP_ITER -4
a = 2357111317
b = 1113171923
c = 2623870137469952591
d = 2920818566629701480442302493
e = 305411158
```

---



```
$ bin/run src/tommath.py
{'MP_ITER': -4}
{'a': mp_int("2357111317"), 'b': mp_int("1113171923"), 'c': mp_int("0"), 'd': mp_int("0"), 'e': mp_int("305411158")}
{'a': mp_int("2357111317"), 'b': mp_int("1113171923"), 'c': mp_int("2623870137469952591"), 'd': mp_int("2920818566629701480442302493"), 'e': mp_int("305411158")}
```

---



```
$ bin/run src/tommath-1.rb
MP_ITER = -4
{:a=>mp_int("2357111317"), :b=>mp_int("1113171923"), :c=>mp_int("0"), :d=>mp_int("0"), :e=>mp_int("305411158")}
{:a=>mp_int("2357111317"), :b=>mp_int("1113171923"), :c=>mp_int("2623870137469952591"), :d=>mp_int("2920818566629701480442302493"), :e=>mp_int("305411158")}
```

---

```
$ bin/run src/tommath-2.rb
{:a=>MPI["2357111317"], :b=>MPI["1113171923"], :c=>MPI["0"], :d=>MPI["0"], :e=>MPI["305411158"]}
{:a=>MPI["2357111317"], :b=>MPI["1113171923"], :c=>MPI["2623870137469952591"], :d=>MPI["2920818566629701480442302493"], :e=>MPI["305411158"]}
```

---


```
$ bin/run src/tommath.scm
(MP-ITER -4)
(a "2357111317" b "1113171923" c "0" d "0" e "305411158")
(a "2357111317" b "1113171923" c "2623870137469952591" d "2920818566629701480442302493" e "305411158")
```

---



---


# Workflow

1. Create interface files. (once)
2. Generate bindings from interface files. (many)
3. Compile bindings.
4. Link bindings and native library into a dynamic library.
5. Load dynamic library.

```

   +---------------------------------+ 
+--+           foo.h                 | 
|  +---------------------------------+ 
|  |  double f(int, double, char*);  | 
|  +---------------------------------+ 
|                  
|  +---------------------------------+ 
|  |            foo.i                | 
|  +---------------------------------+ 
|  |  %module foo_swig               | 
|  |  %include "foo.h"               | 
|  +-+-------------------------------+ 
|    |  
+--->|  2. swig -python foo.i    \
     |       -o bld/foo_swig.c
     v                               
   +-------------------+ 
+--+  bld/foo_swig.py  | 
|  |  bld/foo_swig.c   | 
|  +-+-----------------+ 
|    | 
|    |  3. cc -c bld/foo_swig.c 
|    |                       
|    v                       
|  +-------------------+  
|  |  bld/foo_swig.о   |  
|  +-+-----------------+  
|    | 
|    |  4. cc -dynamiclib         \ 
|    |       -о bld/_foo_swig.so  \ 
|    |       bld/foo_swig.о       \ 
|    |       -l foo 
|    v 
|  +-------------------+ 
|  |  bld/foo_swig.sо  | 
|  +-+-----------------+ 
|    | 
+--->|  5. python script.py 
     | 
     v 
   +------------------------------+ 
   |        script.py             | 
   +------------------------------+ 
   | import sys                   | 
   | sys.path.append('bld')       | 
   | import foo_swig as foo       | 
   | print(foo.f(2, 3.5, 'str'))  | 
   +------------------------------+ 

```



# Workflow Examples


                                                                              
## Workflow - example1.c                                                      
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
clang -g -Isrc -c -o target/native/example1.o src/example1.c                  
                                                                              
# Compile and link native program:                                            
clang -g -Isrc -o target/native/example1 src/example1-native.c                  \
  target/native/example1.o                                                    
                                                                              
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -addextern -I- -Isrc -python -outdir target/python/ -o                     \
  target/python/example1_swig.c src/example1.i                                
                                                                              
# Source code statistics:                                                     
wc -l src/example1.h src/example1.i                                           
7 src/example1.h                                                              
5 src/example1.i                                                              
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/example1_swig.c target/python/example1_swig.py            
3650 target/python/example1_swig.c                                            
65 target/python/example1_swig.py                                             
3715 total                                                                    
                                                                              
# Compile python bindings:                                                    
clang -g -Isrc -Wno-sentinel -Wno-unused-result -Wsign-compare                  \
  -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -fwrapv -O3 -Wall -c -o   \
  target/python/example1_swig.c.o target/python/example1_swig.c               
                                                                              
# Link python dynamic library:                                                
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/python/_example1_swig.so target/native/example1.o                      \
  target/python/example1_swig.c.o -Lpython3.10/config-3.10-darwin -ldl        
                                                                              
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -addextern -I- -Isrc -java -outdir target/clojure/ -o                      \
  target/clojure/example1_swig.c src/example1.i                               
                                                                              
# Source code statistics:                                                     
wc -l src/example1.h src/example1.i                                           
7 src/example1.h                                                              
5 src/example1.i                                                              
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/example1_swig.c target/clojure/example1*.java            
243 target/clojure/example1_swig.c                                            
15 target/clojure/example1_swig.java                                          
12 target/clojure/example1_swigConstants.java                                 
13 target/clojure/example1_swigJNI.java                                       
283 total                                                                     
                                                                              
# Compile clojure bindings:                                                   
clang -g -Isrc -Wno-sentinel -c -o target/clojure/example1_swig.c.o             \
  target/clojure/example1_swig.c                                              
                                                                              
# Link clojure dynamic library:                                               
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/clojure/libexample1_swig.jnilib target/native/example1.o               \
  target/clojure/example1_swig.c.o                                            
                                                                              
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -addextern -I- -Isrc -ruby -outdir target/ruby/ -o                         \
  target/ruby/example1_swig.c src/example1.i                                  
                                                                              
# Source code statistics:                                                     
wc -l src/example1.h src/example1.i                                           
7 src/example1.h                                                              
5 src/example1.i                                                              
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/example1_swig.c                                             
2257 target/ruby/example1_swig.c                                              
                                                                              
# Compile ruby bindings:                                                      
clang -g -Isrc -Wno-sentinel /arm64-darwin21 -c -o                              \
  target/ruby/example1_swig.c.o target/ruby/example1_swig.c                   
                                                                              
# Link ruby dynamic library:                                                  
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/ruby/example1_swig.bundle target/native/example1.o                     \
  target/ruby/example1_swig.c.o                                               
                                                                              
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -addextern -I- -Isrc -tcl -outdir target/tcl/ -o                           \
  target/tcl/example1_swig.c src/example1.i                                   
                                                                              
# Source code statistics:                                                     
wc -l src/example1.h src/example1.i                                           
7 src/example1.h                                                              
5 src/example1.i                                                              
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/example1_swig.c                                              
2149 target/tcl/example1_swig.c                                               
                                                                              
# Compile tcl bindings:                                                       
clang -g -Isrc -Wno-sentinel -Itcl -c -o target/tcl/example1_swig.c.o           \
  target/tcl/example1_swig.c                                                  
                                                                              
# Link tcl dynamic library:                                                   
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/tcl/example1_swig.so target/native/example1.o                          \
  target/tcl/example1_swig.c.o                                                
                                                                              
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -addextern -I- -Isrc -guile -outdir target/guile/ -o                       \
  target/guile/example1_swig.c src/example1.i                                 
                                                                              
# Source code statistics:                                                     
wc -l src/example1.h src/example1.i                                           
7 src/example1.h                                                              
5 src/example1.i                                                              
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/example1_swig.c                                            
1605 target/guile/example1_swig.c                                             
                                                                              
# Compile guile bindings:                                                     
clang -g -Isrc -Wno-sentinel -D_THREAD_SAFE -I$GUILE_HOMEguile/3.0              \
  -I/opt/homebrew/opt/gmp -c -o target/guile/example1_swig.c.o                  \
  target/guile/example1_swig.c                                                
                                                                              
# Link guile dynamic library:                                                 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/guile/libexample1_swig.so target/native/example1.o                     \
  target/guile/example1_swig.c.o -L$GUILE_HOME/lib -lguile-3.0 -lgc -lpthread 
                                                                              
                                                                              
```                                                                           
                                                                              

---


                                                                              
## Workflow - polynomial.cc                                                   
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -c -o                         \
  target/native/polynomial.o src/polynomial.cc                                
                                                                              
# Compile and link native program:                                            
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -o target/native/polynomial   \
  src/polynomial-native.cc target/native/polynomial.o                         
                                                                              
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -addextern -I- -Isrc -python -c++ -outdir target/python/ -o                \
  target/python/polynomial_swig.cc src/polynomial.i                           
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/polynomial_swig.cc target/python/polynomial_swig.py       
8408 target/python/polynomial_swig.cc                                         
241 target/python/polynomial_swig.py                                          
8649 total                                                                    
                                                                              
# Compile python bindings:                                                    
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel                 \
  -Wno-unused-result -Wsign-compare -Wunreachable-code -fno-common -dynamic     \
  -DNDEBUG -g -fwrapv -O3 -Wall -c -o target/python/polynomial_swig.cc.o        \
  target/python/polynomial_swig.cc                                            
                                                                              
# Link python dynamic library:                                                
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/python/_polynomial_swig.so            \
  target/native/polynomial.o target/python/polynomial_swig.cc.o                 \
  -Lpython3.10/config-3.10-darwin -ldl                                        
                                                                              
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -addextern -I- -Isrc -java -c++ -outdir target/clojure/ -o                 \
  target/clojure/polynomial_swig.cc src/polynomial.i                          
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/polynomial_swig.cc target/clojure/polynomial*.java       
660 target/clojure/polynomial_swig.cc                                         
11 target/clojure/polynomial_swig.java                                        
12 target/clojure/polynomial_swigConstants.java                               
32 target/clojure/polynomial_swigJNI.java                                     
715 total                                                                     
                                                                              
# Compile clojure bindings:                                                   
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel -c -o           \
  target/clojure/polynomial_swig.cc.o target/clojure/polynomial_swig.cc       
                                                                              
# Link clojure dynamic library:                                               
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/clojure/libpolynomial_swig.jnilib     \
  target/native/polynomial.o target/clojure/polynomial_swig.cc.o              
                                                                              
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -addextern -I- -Isrc -ruby -c++ -outdir target/ruby/ -o                    \
  target/ruby/polynomial_swig.cc src/polynomial.i                             
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/polynomial_swig.cc                                          
8528 target/ruby/polynomial_swig.cc                                           
                                                                              
# Compile ruby bindings:                                                      
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel                 \
  /arm64-darwin21 -c -o target/ruby/polynomial_swig.cc.o                        \
  target/ruby/polynomial_swig.cc                                              
                                                                              
# Link ruby dynamic library:                                                  
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/ruby/polynomial_swig.bundle           \
  target/native/polynomial.o target/ruby/polynomial_swig.cc.o                 
                                                                              
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -addextern -I- -Isrc -tcl -c++ -outdir target/tcl/ -o                      \
  target/tcl/polynomial_swig.cc src/polynomial.i                              
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/polynomial_swig.cc                                           
2951 target/tcl/polynomial_swig.cc                                            
                                                                              
# Compile tcl bindings:                                                       
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel -Itcl -c -o     \
  target/tcl/polynomial_swig.cc.o target/tcl/polynomial_swig.cc               
                                                                              
# Link tcl dynamic library:                                                   
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/tcl/polynomial_swig.so                \
  target/native/polynomial.o target/tcl/polynomial_swig.cc.o                  
                                                                              
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -addextern -I- -Isrc -guile -c++ -outdir target/guile/ -o                  \
  target/guile/polynomial_swig.cc src/polynomial.i                            
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/polynomial_swig.cc                                         
2267 target/guile/polynomial_swig.cc                                          
                                                                              
# Compile guile bindings:                                                     
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel -D_THREAD_SAFE  \
  -I$GUILE_HOMEguile/3.0 -I/opt/homebrew/opt/gmp -c -o                          \
  target/guile/polynomial_swig.cc.o target/guile/polynomial_swig.cc           
                                                                              
# Link guile dynamic library:                                                 
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/guile/libpolynomial_swig.so           \
  target/native/polynomial.o target/guile/polynomial_swig.cc.o                  \
  -L$GUILE_HOME/lib -lguile-3.0 -lgc -lpthread                                
                                                                              
                                                                              
```                                                                           
                                                                              

---


                                                                              
## Workflow - polynomial_v2.cc                                                
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -c -o                         \
  target/native/polynomial_v2.o src/polynomial_v2.cc                          
                                                                              
# Compile and link native program:                                            
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -o                            \
  target/native/polynomial_v2 src/polynomial_v2-native.cc                       \
  target/native/polynomial_v2.o                                               
                                                                              
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -addextern -I- -Isrc -python -c++ -outdir target/python/ -o                \
  target/python/polynomial_v2_swig.cc src/polynomial_v2.i                     
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
36 src/polynomial_v2.i                                                        
49 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/polynomial_v2_swig.cc target/python/polynomial_v2_swig.py 
13181 target/python/polynomial_v2_swig.cc                                     
508 target/python/polynomial_v2_swig.py                                       
13689 total                                                                   
                                                                              
# Compile python bindings:                                                    
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel                 \
  -Wno-unused-result -Wsign-compare -Wunreachable-code -fno-common -dynamic     \
  -DNDEBUG -g -fwrapv -O3 -Wall -c -o target/python/polynomial_v2_swig.cc.o     \
  target/python/polynomial_v2_swig.cc                                         
                                                                              
# Link python dynamic library:                                                
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/python/_polynomial_v2_swig.so         \
  target/native/polynomial_v2.o target/python/polynomial_v2_swig.cc.o           \
  -Lpython3.10/config-3.10-darwin -ldl                                        
                                                                              
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -addextern -I- -Isrc -java -c++ -outdir target/clojure/ -o                 \
  target/clojure/polynomial_v2_swig.cc src/polynomial_v2.i                    
include/rational.h:23: Warning 503: Can't wrap 'operator +' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:26: Warning 503: Can't wrap 'operator *' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:29: Warning 503: Can't wrap 'operator ==' unless renamed to  \
  a valid identifier.                                                         
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
36 src/polynomial_v2.i                                                        
49 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/polynomial_v2_swig.cc target/clojure/polynomial_v2*.java 
1653 target/clojure/polynomial_v2_swig.cc                                     
11 target/clojure/polynomial_v2_swig.java                                     
12 target/clojure/polynomial_v2_swigConstants.java                            
84 target/clojure/polynomial_v2_swigJNI.java                                  
1760 total                                                                    
                                                                              
# Compile clojure bindings:                                                   
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel -c -o           \
  target/clojure/polynomial_v2_swig.cc.o target/clojure/polynomial_v2_swig.cc 
                                                                              
# Link clojure dynamic library:                                               
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/clojure/libpolynomial_v2_swig.jnilib  \
  target/native/polynomial_v2.o target/clojure/polynomial_v2_swig.cc.o        
                                                                              
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -addextern -I- -Isrc -ruby -c++ -outdir target/ruby/ -o                    \
  target/ruby/polynomial_v2_swig.cc src/polynomial_v2.i                       
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
36 src/polynomial_v2.i                                                        
49 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/polynomial_v2_swig.cc                                       
14480 target/ruby/polynomial_v2_swig.cc                                       
                                                                              
# Compile ruby bindings:                                                      
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel                 \
  /arm64-darwin21 -c -o target/ruby/polynomial_v2_swig.cc.o                     \
  target/ruby/polynomial_v2_swig.cc                                           
                                                                              
# Link ruby dynamic library:                                                  
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/ruby/polynomial_v2_swig.bundle        \
  target/native/polynomial_v2.o target/ruby/polynomial_v2_swig.cc.o           
                                                                              
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -addextern -I- -Isrc -tcl -c++ -outdir target/tcl/ -o                      \
  target/tcl/polynomial_v2_swig.cc src/polynomial_v2.i                        
include/rational.h:29: Warning 503: Can't wrap 'operator ==' unless renamed to  \
  a valid identifier.                                                         
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
36 src/polynomial_v2.i                                                        
49 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/polynomial_v2_swig.cc                                        
4669 target/tcl/polynomial_v2_swig.cc                                         
                                                                              
# Compile tcl bindings:                                                       
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel -Itcl -c -o     \
  target/tcl/polynomial_v2_swig.cc.o target/tcl/polynomial_v2_swig.cc         
                                                                              
# Link tcl dynamic library:                                                   
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/tcl/polynomial_v2_swig.so             \
  target/native/polynomial_v2.o target/tcl/polynomial_v2_swig.cc.o            
                                                                              
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -addextern -I- -Isrc -guile -c++ -outdir target/guile/ -o                  \
  target/guile/polynomial_v2_swig.cc src/polynomial_v2.i                      
include/rational.h:23: Warning 503: Can't wrap 'operator +' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:26: Warning 503: Can't wrap 'operator *' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:29: Warning 503: Can't wrap 'operator ==' unless renamed to  \
  a valid identifier.                                                         
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
36 src/polynomial_v2.i                                                        
49 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/polynomial_v2_swig.cc                                      
3961 target/guile/polynomial_v2_swig.cc                                       
                                                                              
# Compile guile bindings:                                                     
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -Wno-sentinel -D_THREAD_SAFE  \
  -I$GUILE_HOMEguile/3.0 -I/opt/homebrew/opt/gmp -c -o                          \
  target/guile/polynomial_v2_swig.cc.o target/guile/polynomial_v2_swig.cc     
                                                                              
# Link guile dynamic library:                                                 
clang++ -g -Isrc -Wno-c++11-extensions -std=c++17 -dynamiclib                   \
  -Wl,-undefined,dynamic_lookup -o target/guile/libpolynomial_v2_swig.so        \
  target/native/polynomial_v2.o target/guile/polynomial_v2_swig.cc.o            \
  -L$GUILE_HOME/lib -lguile-3.0 -lgc -lpthread                                
                                                                              
                                                                              
```                                                                           
                                                                              

---


                                                                              
## Workflow - tommath.c                                                       
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
clang -g -Isrc -c -o target/native/tommath.o src/tommath.c                    
                                                                              
# Compile and link native program:                                            
clang -g -Isrc -o target/native/tommath src/tommath-native.c                    \
  target/native/tommath.o -ltommath                                           
                                                                              
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -addextern -I- -Isrc -python -outdir target/python/ -o                     \
  target/python/tommath_swig.c src/tommath.i                                  
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/tommath_swig.c target/python/tommath_swig.py              
9216 target/python/tommath_swig.c                                             
478 target/python/tommath_swig.py                                             
9694 total                                                                    
                                                                              
# Compile python bindings:                                                    
clang -g -Isrc -Wno-sentinel -Wno-unused-result -Wsign-compare                  \
  -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -fwrapv -O3 -Wall -c -o   \
  target/python/tommath_swig.c.o target/python/tommath_swig.c                 
                                                                              
# Link python dynamic library:                                                
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/python/_tommath_swig.so target/native/tommath.o                        \
  target/python/tommath_swig.c.o -Lpython3.10/config-3.10-darwin -ldl           \
  -ltommath                                                                   
                                                                              
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -addextern -I- -Isrc -java -outdir target/clojure/ -o                      \
  target/clojure/tommath_swig.c src/tommath.i                                 
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/tommath_swig.c target/clojure/tommath*.java              
3138 target/clojure/tommath_swig.c                                            
545 target/clojure/tommath_swig.java                                          
15 target/clojure/tommath_swigConstants.java                                  
178 target/clojure/tommath_swigJNI.java                                       
3876 total                                                                    
                                                                              
# Compile clojure bindings:                                                   
clang -g -Isrc -Wno-sentinel -c -o target/clojure/tommath_swig.c.o              \
  target/clojure/tommath_swig.c                                               
                                                                              
# Link clojure dynamic library:                                               
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/clojure/libtommath_swig.jnilib target/native/tommath.o                 \
  target/clojure/tommath_swig.c.o -ltommath                                   
                                                                              
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -addextern -I- -Isrc -ruby -outdir target/ruby/ -o                         \
  target/ruby/tommath_swig.c src/tommath.i                                    
local/include/libtommath/tommath.h:175: Warning 801: Wrong class name           \
  (corrected to `Mp_int')                                                     
local/include/libtommath/tommath.h:175: Warning 801: Wrong class name           \
  (corrected to `Mp_int')                                                     
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/tommath_swig.c                                              
7867 target/ruby/tommath_swig.c                                               
                                                                              
# Compile ruby bindings:                                                      
clang -g -Isrc -Wno-sentinel /arm64-darwin21 -c -o                              \
  target/ruby/tommath_swig.c.o target/ruby/tommath_swig.c                     
                                                                              
# Link ruby dynamic library:                                                  
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/ruby/tommath_swig.bundle target/native/tommath.o                       \
  target/ruby/tommath_swig.c.o -ltommath                                      
                                                                              
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -addextern -I- -Isrc -guile -outdir target/guile/ -o                       \
  target/guile/tommath_swig.c src/tommath.i                                   
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/tommath_swig.c                                             
6397 target/guile/tommath_swig.c                                              
                                                                              
# Compile guile bindings:                                                     
clang -g -Isrc -Wno-sentinel -D_THREAD_SAFE -I$GUILE_HOMEguile/3.0              \
  -I/opt/homebrew/opt/gmp -c -o target/guile/tommath_swig.c.o                   \
  target/guile/tommath_swig.c                                                 
                                                                              
# Link guile dynamic library:                                                 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o                     \
  target/guile/libtommath_swig.so target/native/tommath.o                       \
  target/guile/tommath_swig.c.o -L$GUILE_HOME/lib -lguile-3.0 -lgc -lpthread    \
  -ltommath                                                                   
                                                                              
                                                                              
```                                                                           
                                                                              

---



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
* rbenv install 2.7.6
* Install JVM 11.0
* Install Prerequisites below.
* Build local tools.

## Prerequisites

### Debian (Ubuntu 18.04+)

* Run `bin/build debian-prereq`
* Install a Python 3.10 distribution with python3.10 in $PATH.
* `python3.10 -m pip install pytest`

### OSX

* Install brew
* Run `bin/build brew-prereq`

### Local tools

```Shell
bin/build local-tools
```

## Build

```Shell
rbenv shell 2.7.6
bin/build clean demo
```
