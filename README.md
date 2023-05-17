

# SWIG-101

Introduction to [SWIG](http://www.swig.org/).

# References

* https://www.swig.org/
* https://www.swig.org/papers/PyTutorial98/PyTutorial98.pdf
* https://github.com/swig/swig
* https://github.com/kstephens/swig-101
* https://github.com/kstephens/swig/tree/postgresql

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
* C/C++ pointers, references, `const` declarations
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
* PostgreSQL (proof-of-concept)
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

### References

* https://github.com/libffi/libffi
* https://www.chiark.greenend.org.uk/doc/libffi-dev/html/

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
* PostgreSQL



## mathlib.c



### C Header : mathlib.h

```c
#define MATHLIB_VERSION "1.2.3"                                                //  1 
/* Returns: c0 + c1*x + c2*x^2 + c3*x^3 */                                    
double cubic_poly(double x,                                                    //  3 
                  double c0,                                                   //  4 
                  double c1,                                                   //  5 
                  double c2,                                                   //  6 
                  double c3);                                                  //  7 
```



### C Library : mathlib.c

```c
#include "mathlib.h"                                                           //  1 
double cubic_poly(double x,                                                    //  2 
                  double c0,                                                   //  3 
                  double c1,                                                   //  4 
                  double c2,                                                   //  5 
                  double c3) {                                                 //  6 
  return c0 + c1 * x + c2 * x*x + c3 * x*x*x;                                  //  7 
}                                                                              //  8 
```



### C Main : mathlib-native.c

```c
#include <stdio.h>                                                             //  1 
#include "mathlib.h"                                                           //  2 
                                                                              
int main(int argc, char **argv) {                                              //  4 
  printf("MATHLIB_VERSION = %s\n", MATHLIB_VERSION);                           //  5 
  printf("%5.1f\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));                     //  6 
  return 0;                                                                    //  7 
}                                                                              //  8 
```


---

```
$ bin/run target/native/mathlib
MATHLIB_VERSION = 1.2.3
129.0
```

---


### C SWIG Interface : mathlib.i

```c
%module mathlib_swig                                                           //  1 
%include "mathlib.h"                                                           //  2 
%{                                                                             //  3 
#include "mathlib.h"                                                           //  4 
%}                                                                             //  5 
```



### Python : mathlib.py

```python
# Setup search path:                                                          
import sys ; sys.path.append('target/python')                                  #   2 
                                                                              
# Load SWIG bindings:                                                         
import mathlib_swig as mathlib                                                 #   5 
                                                                              
# Use SWIG bindings:                                                          
print(f'MATHLIB_VERSION = {mathlib.MATHLIB_VERSION}')                          #   8 
print(mathlib.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))                            #   9 
```


---

```
$ bin/run src/mathlib.py
MATHLIB_VERSION = 1.2.3
129.0
```

---


### Clojure (Java) : mathlib.clj

```lisp
;; Load SWIG bindings:                                                        
(clojure.lang.RT/loadLibrary "mathlib_swig")                                   ;;  2 
(import 'mathlib_swig)                                                         ;;  3 
                                                                              
;; Use SWIG bindings:                                                         
(println (format "MATHLIB_VERSION = \"%s\""                                    ;;  6 
               	 (mathlib_swig/MATHLIB_VERSION)))                              ;;  7 
(prn (mathlib_swig/cubic_poly 2.0 3.0 5.0 7.0 11.0))                           ;;  8 
```


---

```
$ bin/run src/mathlib.clj
MATHLIB_VERSION = "1.2.3"
129.0
```

---


### Ruby : mathlib.rb

```ruby
# Setup search path:                                                          
ENV["LD_LIBRARY_PATH"] = 'target/ruby'                                         #   2 
$:.unshift 'target/ruby'                                                       #   3 
                                                                              
# Load SWIG bindings:                                                         
require 'mathlib_swig'                                                         #   6 
include Mathlib_swig                                                           #   7 
                                                                              
# Use SWIG bindings:                                                          
puts "MATHLIB_VERSION = #{MATHLIB_VERSION.inspect}"                            #  10 
puts cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)                                      #  11 
```


---

```
$ bin/run src/mathlib.rb
MATHLIB_VERSION = "1.2.3"
129.0
```

---


### Guile : mathlib.scm

```scheme
;; Load SWIG bindings:                                                        
(load-extension "target/guile/libmathlib_swig.so" "SWIG_init")                 ;;  2 
                                                                              
;; Use SWIG bindings:                                                         
(write `(MATHLIB-VERSION = ,(MATHLIB-VERSION)))                                ;;  5 
(newline)                                                                      ;;  6 
(write (cubic-poly 2.0 3.0 5.0 7.0 11.0))                                      ;;  7 
(newline)                                                                      ;;  8 
```


---

```
$ bin/run src/mathlib.scm
(MATHLIB-VERSION = "1.2.3")
129.0
```

---


### TCL : mathlib.tcl

```shell
# Load SWIG bindings:                                                         
load target/tcl/mathlib_swig.so Mathlib_swig                                   #   2 
                                                                              
# Use SWIG bindings:                                                          
puts "MATHLIB_VERSION = ${MATHLIB_VERSION}"                                    #   5 
puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]                                         #   6 
```


---

```
$ bin/run src/mathlib.tcl
MATHLIB_VERSION = 1.2.3
129.0
```

---


### PostgreSQL : mathlib-1.psql

```sql
-- Load the extension:                                                        
CREATE EXTENSION mathlib_swig;                                                 --  2 
-- Call the functions:                                                        
SELECT MATHLIB_VERSION();                                                      --  4 
SELECT cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0);                                   --  5 
```


---

```
$ bin/run src/mathlib-1.psql
 mathlib_version
-----------------
 1.2.3
(1 row)

 cubic_poly
------------
        129
(1 row)
```

---

### PostgreSQL : mathlib-2.psql

```sql
-- Load the extension:                                                        
CREATE EXTENSION mathlib_swig;                                                 --  2 
-- Create some coefficient and parameter tables:                              
CREATE TABLE coefficients (                                                    --  4 
  c_id SERIAL PRIMARY KEY,                                                     --  5 
  c0 FLOAT8,                                                                   --  6 
  c1 FLOAT8,                                                                   --  7 
  c2 FLOAT8,                                                                   --  8 
  c3 FLOAT8                                                                    --  9 
);                                                                             -- 10 
CREATE TABLE parameters (                                                      -- 11 
  x_id SERIAL PRIMARY KEY,                                                     -- 12 
  x FLOAT8                                                                     -- 13 
);                                                                             -- 14 
-- Create some coefficient and parameter data:                                
INSERT INTO coefficients                                                       -- 16 
  ( c0  ,  c1 ,    c2 ,   c3 ) VALUES                                          -- 17 
  ( 3.00, 5.00,   7.00, 11.00),                                                -- 18 
  ( 2.30, 5.70,  11.13, 17.23),                                                -- 19 
  (-5.20, 1.20, -99.00, 12.34);                                                -- 20 
INSERT INTO parameters                                                         -- 21 
  (x) VALUES                                                                   -- 22 
  ( 2),                                                                        -- 23 
  (-3.7),                                                                      -- 24 
  ( 3.1415926);                                                                -- 25 
-- Apply cubic_poly to parameters and coefficients:                           
SELECT *, cubic_poly(x, c0, c1, c2, c3)                                        -- 27 
FROM   parameters, coefficients;                                               -- 28 
```


---

```
$ bin/run src/mathlib-2.psql
 x_id |     x     | c_id |  c0  | c1  |  c2   |  c3   |     cubic_poly
------+-----------+------+------+-----+-------+-------+---------------------
    1 |         2 |    1 |    3 |   5 |     7 |    11 |                 129
    1 |         2 |    2 |  2.3 | 5.7 | 11.13 | 17.23 |              196.06
    1 |         2 |    3 | -5.2 | 1.2 |   -99 | 12.34 | -300.08000000000004
    2 |      -3.7 |    1 |    3 |   5 |     7 |    11 | -476.85300000000007
    2 |      -3.7 |    2 |  2.3 | 5.7 | 11.13 | 17.23 |  -739.1714900000002
    2 |      -3.7 |    3 | -5.2 | 1.2 |   -99 | 12.34 | -1990.0080200000002
    3 | 3.1415926 |    1 |    3 |   5 |     7 |    11 |   428.8642174798897
    3 | 3.1415926 |    2 |  2.3 | 5.7 | 11.13 | 17.23 |   664.2938909186964
    3 | 3.1415926 |    3 | -5.2 | 1.2 |   -99 | 12.34 |  -595.9034565984515
(9 rows)
```

---



### Outputs - Recap





```
$ bin/run target/native/mathlib
MATHLIB_VERSION = 1.2.3
129.0
```

---



```
$ bin/run src/mathlib.py
MATHLIB_VERSION = 1.2.3
129.0
```

---


```
$ bin/run src/mathlib.clj
MATHLIB_VERSION = "1.2.3"
129.0
```

---


```
$ bin/run src/mathlib.rb
MATHLIB_VERSION = "1.2.3"
129.0
```

---


```
$ bin/run src/mathlib.scm
(MATHLIB-VERSION = "1.2.3")
129.0
```

---


```
$ bin/run src/mathlib.tcl
MATHLIB_VERSION = 1.2.3
129.0
```

---


```
$ bin/run src/mathlib-1.psql
 mathlib_version
-----------------
 1.2.3
(1 row)

 cubic_poly
------------
        129
(1 row)
```

---

```
$ bin/run src/mathlib-2.psql
 x_id |     x     | c_id |  c0  | c1  |  c2   |  c3   |     cubic_poly
------+-----------+------+------+-----+-------+-------+---------------------
    1 |         2 |    1 |    3 |   5 |     7 |    11 |                 129
    1 |         2 |    2 |  2.3 | 5.7 | 11.13 | 17.23 |              196.06
    1 |         2 |    3 | -5.2 | 1.2 |   -99 | 12.34 | -300.08000000000004
    2 |      -3.7 |    1 |    3 |   5 |     7 |    11 | -476.85300000000007
    2 |      -3.7 |    2 |  2.3 | 5.7 | 11.13 | 17.23 |  -739.1714900000002
    2 |      -3.7 |    3 | -5.2 | 1.2 |   -99 | 12.34 | -1990.0080200000002
    3 | 3.1415926 |    1 |    3 |   5 |     7 |    11 |   428.8642174798897
    3 | 3.1415926 |    2 |  2.3 | 5.7 | 11.13 | 17.23 |   664.2938909186964
    3 | 3.1415926 |    3 | -5.2 | 1.2 |   -99 | 12.34 |  -595.9034565984515
(9 rows)
```

---


---



## polynomial.cc



### C++ Header : polynomial.h

```c++
#include <vector>                                                              //  1 
                                                                              
#define POLYNOMIAL_VERSION "1.2.1"                                             //  3 
                                                                              
class Polynomial {                                                             //  5 
public:                                                                        //  6 
  std::vector<double> coeffs;                                                  //  7 
  double evaluate(double x) const;                                             //  8 
};                                                                             //  9 
```



### C++ Library : polynomial.cc

```c++
#include "polynomial.h"                                                        //  1 
                                                                              
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
                                                                              
int main(int argc, char **argv) {                                              //  5 
  std::cout << "POLYNOMIAL_VERSION = \"" << POLYNOMIAL_VERSION << "\"\n";      //  6 
                                                                              
  Polynomial p;                                                                //  8 
                                                                              
  p.coeffs = { 3, 5.0, 7.0, 11.0 };                                            // 10 
  std::cout << std::setprecision(9) << p.evaluate(2) << "\n";                  // 11 
                                                                              
  p.coeffs = { 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 };                           // 13 
  std::cout << std::setprecision(9) << p.evaluate(1.2) << "\n";                // 14 
                                                                              
  return 0;                                                                    // 16 
}                                                                              // 17 
```


---

```
$ bin/run target/native/polynomial
POLYNOMIAL_VERSION = "1.2.1"
129
17.3020736
```

---


### C++ SWIG Interface : polynomial.i

```c++
// Name of generated bindings:                                                
%module polynomial_swig                                                        //  2 
                                                                              
// Include std::vector<T> support:                                            
%include "std_vector.i"                                                        //  5 
                                                                              
// Template instantiation:                                                    
%template(VectorDouble) std::vector<double>;                                   //  8 
                                                                              
// Include C++ declarations as SWIG interface definitions:                    
%include "polynomial.h"                                                        // 11 
                                                                              
// Prepend C++ code in generated bindings:                                    
%{                                                                             // 14 
#include "polynomial.h"                                                        // 15 
%}                                                                             // 16 
```



### Python : polynomial.py

```python
from polynomial_swig import *                                                  #   1 
                                                                              
print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})                              #   3 
                                                                              
poly = Polynomial()                                                            #   5 
                                                                              
poly.coeffs = VectorDouble([ 3, 5.0, 7.0, 11.0 ])                              #   7 
print(list(poly.coeffs))                                                       #   8 
print(poly.evaluate(2))                                                        #   9 
                                                                              
poly.coeffs = VectorDouble([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])             #  11 
print(list(poly.coeffs))                                                       #  12 
print(poly.evaluate(1.2))                                                      #  13 
```


---

```
$ bin/run src/polynomial.py
{'POLYNOMIAL_VERSION': '1.2.1'}
[3.0, 5.0, 7.0, 11.0]
129.0
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---

### Python : polynomial-test.py

```python
from polynomial_swig import *                                                  #   1 
import pytest                                                                  #   2 
                                                                              
def test_empty_coeffs():                                                       #   4 
    p = Polynomial()                                                           #   5 
    assert p.evaluate(1.2) == 0.0                                              #   6 
    assert p.evaluate(999) == 0.0                                              #   7 
                                                                              
def test_one_coeff():                                                          #   9 
    p = Polynomial()                                                           #  10 
    p.coeffs = VectorDouble([ 2.3 ])                                           #  11 
    assert p.evaluate(1.2) == 2.3                                              #  12 
    assert p.evaluate(999) == 2.3                                              #  13 
                                                                              
def test_more_than_one_coeff():                                                #  15 
    p = Polynomial()                                                           #  16 
    p.coeffs = VectorDouble([ 3, 5.0, 7.0, 11.0 ])                             #  17 
    assert p.evaluate(2) == 129.0                                              #  18 
    assert p.evaluate(-3.5) == -400.375                                        #  19 
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
                                                                              
(prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})               ;;  4 
                                                                              
(def p (Polynomial.))                                                          ;;  6 
                                                                              
;; Note: does not coerce java.lang.Long 3 to 3.0                              
(.setCoeffs p (VectorDouble. [ 3.0 5.0 7.0 11.0 ]))                            ;;  9 
(prn (.getCoeffs p))                                                           ;; 10 
(prn (.evaluate p 2))                                                          ;; 11 
                                                                              
(.setCoeffs p (VectorDouble. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))               ;; 13 
(prn (.getCoeffs p))                                                           ;; 14 
(prn (.evaluate p 1.2))                                                        ;; 15 
```


---

```
$ bin/run src/polynomial.clj
{:POLYNOMIAL_VERSION "1.2.1"}
[3.0 5.0 7.0 11.0]
129.0
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
```

---


### Ruby : polynomial.rb

```ruby
require 'polynomial_swig'                                                      #   1 
include Polynomial_swig                                                        #   2 
                                                                              
pp POLYNOMIAL_VERSION: POLYNOMIAL_VERSION                                      #   4 
                                                                              
p = Polynomial.new                                                             #   6 
                                                                              
p.coeffs = VectorDouble.new([ 3, 5.0, 7.0, 11.0 ])                             #   8 
pp p.coeffs.to_a                                                               #   9 
pp p.evaluate(2)                                                               #  10 
                                                                              
p.coeffs = VectorDouble.new([ 2.3, 3.5, 5.7, 7.11, 11.13, -13.17 ])            #  12 
pp p.coeffs.to_a                                                               #  13 
pp p.evaluate(1.2)                                                             #  14 
```


---

```
$ bin/run src/polynomial.rb
{:POLYNOMIAL_VERSION=>"1.2.1"}
[3.0, 5.0, 7.0, 11.0]
129.0
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---


### Guile : polynomial.scm

```scheme
(load-extension "target/guile/libpolynomial_swig.so" "SWIG_init")              ;;  1 
                                                                              
(write `(POLYNOMIAL-VERSION ,(POLYNOMIAL-VERSION))) (newline)                  ;;  3 
                                                                              
(define p (new-Polynomial))                                                    ;;  5 
                                                                              
(Polynomial-coeffs-set p (new-VectorDouble '(3 5.0 7.0 11.0)))                 ;;  7 
(write (Polynomial-coeffs-get p)) (newline)                                    ;;  8 
(write (Polynomial-evaluate p 2)) (newline)                                    ;;  9 
                                                                              
(Polynomial-coeffs-set p (new-VectorDouble '(2.3 3.5 5.7 7.11 11.13 -13.17)))  ;; 11 
(write (Polynomial-coeffs-get p)) (newline)                                    ;; 12 
(write (Polynomial-evaluate p 1.2)) (newline)                                  ;; 13 
```


---

```
$ bin/run src/polynomial.scm
(POLYNOMIAL-VERSION "1.2.1")
#<swig-pointer std::vector< double > * 7fe6d1004160>
129.0
#<swig-pointer std::vector< double > * 7fe6d1004160>
17.3020736
```

---


### TCL : polynomial.tcl

```shell
load target/tcl/polynomial_swig.so Polynomial_swig                             #   1 
                                                                              
puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]                             #   3 
                                                                              
Polynomial poly                                                                #   5 
                                                                              
VectorDouble c { 3 5.0 7.0 11.0 }                                              #   7 
poly configure -coeffs c                                                       #   8 
puts [poly cget -coeffs]                                                       #   9 
puts [poly evaluate 2]                                                         #  10 
                                                                              
VectorDouble c { 2.3 3.5 5.7 7.11 11.13 -13.17 }                               #  12 
poly configure -coeffs c                                                       #  13 
puts [poly cget -coeffs]                                                       #  14 
puts [poly evaluate 1.2]                                                       #  15 
```


---

```
$ bin/run src/polynomial.tcl
POLYNOMIAL_VERSION 1.2.1
_60a67025f77f0000_p_std__vectorT_double_t
129.0
_60a67025f77f0000_p_std__vectorT_double_t
17.3020736
```

---



### Python Tests : polynomial-test.py

```python
from polynomial_swig import *                                                  #   1 
import pytest                                                                  #   2 
                                                                              
def test_empty_coeffs():                                                       #   4 
    p = Polynomial()                                                           #   5 
    assert p.evaluate(1.2) == 0.0                                              #   6 
    assert p.evaluate(999) == 0.0                                              #   7 
                                                                              
def test_one_coeff():                                                          #   9 
    p = Polynomial()                                                           #  10 
    p.coeffs = VectorDouble([ 2.3 ])                                           #  11 
    assert p.evaluate(1.2) == 2.3                                              #  12 
    assert p.evaluate(999) == 2.3                                              #  13 
                                                                              
def test_more_than_one_coeff():                                                #  15 
    p = Polynomial()                                                           #  16 
    p.coeffs = VectorDouble([ 3, 5.0, 7.0, 11.0 ])                             #  17 
    assert p.evaluate(2) == 129.0                                              #  18 
    assert p.evaluate(-3.5) == -400.375                                        #  19 
```


---

```
$ bin/run python3.10 -m pytest src/polynomial-test.py
============================= test session starts ==============================
platform darwin -- Python 3.10.11, pytest-7.1.2, pluggy-1.0.0
rootdir: .
collected 3 items

src/polynomial-test.py ...                                               [100%]

============================== 3 passed in 0.01s ===============================
```

---


### Outputs - Recap





```
$ bin/run target/native/polynomial
POLYNOMIAL_VERSION = "1.2.1"
129
17.3020736
```

---



```
$ bin/run src/polynomial.py
{'POLYNOMIAL_VERSION': '1.2.1'}
[3.0, 5.0, 7.0, 11.0]
129.0
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
[3.0 5.0 7.0 11.0]
129.0
[2.3 3.5 5.7 7.11 11.13 -13.17]
17.3020736
```

---


```
$ bin/run src/polynomial.rb
{:POLYNOMIAL_VERSION=>"1.2.1"}
[3.0, 5.0, 7.0, 11.0]
129.0
[2.3, 3.5, 5.7, 7.11, 11.13, -13.17]
17.3020736
```

---


```
$ bin/run src/polynomial.scm
(POLYNOMIAL-VERSION "1.2.1")
#<swig-pointer std::vector< double > * 7fe6d1004160>
129.0
#<swig-pointer std::vector< double > * 7fe6d1004160>
17.3020736
```

---


```
$ bin/run src/polynomial.tcl
POLYNOMIAL_VERSION 1.2.1
_60a67025f77f0000_p_std__vectorT_double_t
129.0
_60a67025f77f0000_p_std__vectorT_double_t
17.3020736
```

---



```
$ bin/run python3.10 -m pytest src/polynomial-test.py
============================= test session starts ==============================
platform darwin -- Python 3.10.11, pytest-7.1.2, pluggy-1.0.0
rootdir: .
collected 3 items

src/polynomial-test.py ...                                               [100%]

============================== 3 passed in 0.01s ===============================
```

---

---



## polynomial_v2.cc



### C++ Header : polynomial_v2.h

```c++
#include <vector>                                                              //  1 
                                                                              
#define POLYNOMIAL_VERSION "2.0.2"                                             //  3 
                                                                              
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
#include <complex>                                                             //  3 
                                                                              
namespace mathlib {                                                            //  5 
  template < typename R >                                                      //  6 
  R polynomial< R >::evaluate(const R &x) const {                              //  7 
    R result(0), xx(1);                                                        //  8 
    for ( const auto &c : this->coeffs ) {                                     //  9 
      result = result + c * xx;                                                // 10 
      xx = xx * x;                                                             // 11 
    }                                                                          // 12 
    return result;                                                             // 13 
  };                                                                           // 14 
                                                                              
  // Instantiate templates:                                                   
  template class polynomial<int>;                                              // 17 
  template class polynomial<double>;                                           // 18 
  template class polynomial<rational<int>>;                                    // 19 
  template class polynomial<std::complex<double>>;                             // 20 
}                                                                              // 21 
```



### C++ Main : polynomial_v2-native.cc

```c++
#include <iostream>                                                            //  1 
#include <iomanip>                                                             //  2 
#include "polynomial_v2.h"                                                     //  3 
#include "rational.h"                                                          //  4 
#include <complex>                                                             //  5 
                                                                              
using namespace mathlib;                                                       //  7 
                                                                              
int main(int argc, char **argv) {                                              //  9 
  std::cout << "POLYNOMIAL_VERSION = " << POLYNOMIAL_VERSION << "\n";          // 10 
                                                                              
  polynomial<double> pd;                                                       // 12 
  pd.coeffs = { 3, 5.0, 7.0, 11.0 };                                           // 13 
  std::cout << pd.evaluate(2) << "\n";                                         // 14 
                                                                              
  polynomial<int> pi;                                                          // 16 
  pi.coeffs = { 2, 3, 5, 7, 11, -13 };                                         // 17 
  std::cout << pi.evaluate(-2) << "\n";                                        // 18 
                                                                              
  typedef rational<int> R;                                                     // 20 
  polynomial<R> pr;                                                            // 21 
  pr.coeffs = { R(7, 11), R(11, 13), R(13, 17) };                              // 22 
  std::cout << pr.evaluate(R(-5, 7)) << "\n";                                  // 23 
                                                                              
  typedef std::complex<double> C;                                              // 25 
  polynomial<C> pc;                                                            // 26 
  pc.coeffs = { C(7.2, 11.3), C(11.5, 13.7), C(13.11, 17.13) };                // 27 
  std::cout << pc.evaluate(C(-5.7, 7.11)) << "\n";                             // 28 
                                                                              
  return 0;                                                                    // 30 
}                                                                              // 31 
```


---

```
$ bin/run target/native/polynomial_v2
POLYNOMIAL_VERSION = 2.0.2
129
552
50283/119119
(995.904,-1357.05)
```

---


### C++ SWIG Interface : polynomial_v2.i

```c++
// Name of generated bindings:                                                
%module polynomial_v2_swig                                                     //  2 
                                                                              
// Include C++ std lib interfaces:                                            
%include "std_string.i"   // python __str__(), __repr__()                      //  5 
%include "std_vector.i"   // std::vector<T>                                    //  6 
                                                                              
// Include C++ declarations as SWIG interface definitions:                    
%include "polynomial_v2.h"                                                     //  9 
%include "rational.h"                                                          // 10 
                                                                              
// Prepend C++ code in generated bindings:                                    
%{                                                                             // 13 
#include "polynomial_v2.h"                                                     // 14 
#include "rational.h"                                                          // 15 
%}                                                                             // 16 
                                                                              
%template(RationalV2)            mathlib::rational<int>;                       // 18 
%template(VectorDoubleV2)        std::vector<double>;                          // 19 
%template(VectorIntV2)           std::vector<int>;                             // 20 
%template(VectorRationalV2)      std::vector<mathlib::rational<int>>;          // 21 
%template(PolynomialDoubleV2)    mathlib::polynomial<double>;                  // 22 
%template(PolynomialIntV2)       mathlib::polynomial<int>;                     // 23 
%template(PolynomialRationalV2)  mathlib::polynomial<mathlib::rational<int>>;  // 24 
                                                                              
// std::complex<double>:                                                      
#if SWIGPYTHON || SWIGRUBY                                                     // 27 
%include "std_complex.i"  // std::complex<double>                              // 28 
%template(ComplexV2)             std::complex<double>;                         // 29 
%template(VectorComplexV2)       std::vector<std::complex<double>>;            // 30 
%template(PolynomialComplexV2)   mathlib::polynomial<std::complex<double>>;    // 31 
#endif                                                                         // 32 
```



### Python : polynomial_v2.py

```python
from polynomial_v2_swig import *                                                                  #   1 
                                                                                                 
print({"POLYNOMIAL_VERSION": POLYNOMIAL_VERSION})                                                 #   3 
                                                                                                 
# polynomial<double>:                                                                            
poly         = PolynomialDoubleV2()                                                               #   6 
poly.coeffs  = VectorDoubleV2([ 3.0, 5.0, 7.0, 11.0 ])                                            #   7 
print(list(poly.coeffs))                                                                          #   8 
print(poly.evaluate(2))                                                                           #   9 
                                                                                                 
# polynomial<rational<int>>:                                                                     
poly        = PolynomialRationalV2()                                                              #  12 
poly.coeffs = VectorRationalV2([ RationalV2(7, 11), RationalV2(11, 13), RationalV2(13, 17) ])     #  13 
print(list(poly.coeffs))                                                                          #  14 
print(poly.evaluate(RationalV2(-5, 7)))                                                           #  15 
                                                                                                 
# polynomial<complex<double>>:                                                                   
poly        = PolynomialComplexV2()                                                               #  18 
poly.coeffs = VectorComplexV2([ complex(7.2, 11.3), complex(11.5, 13.7), complex(13.11, 17.13) ]) #  19 
print(list(poly.coeffs))                                                                          #  20 
print(poly.evaluate(complex(-5.7, 7.11)))                                                         #  21 
```


---

```
$ bin/run src/polynomial_v2.py
{'POLYNOMIAL_VERSION': '2.0.2'}
[3.0, 5.0, 7.0, 11.0]
129.0
[rational<int>(7,11), rational<int>(11,13), rational<int>(13,17)]
50283/119119
[(7.2+11.3j), (11.5+13.7j), (13.11+17.13j)]
(995.9038889999997-1357.0467130000002j)
```

---


### Clojure (Java) : polynomial_v2.clj

```lisp
(clojure.lang.RT/loadLibrary "polynomial_v2_swig")                                                 ;;  1 
(import 'polynomial_v2_swig)                                                                       ;;  2 
                                                                                                  
(prn {:POLYNOMIAL_VERSION (polynomial_v2_swig/POLYNOMIAL_VERSION)})                                ;;  4 
                                                                                                  
;; polynomial<double>:                                                                            
(def p1 (PolynomialDoubleV2.))                                                                     ;;  7 
(.setCoeffs p1 (VectorDoubleV2. [ 3.0 5.0 7.0 11.0 ]))                                             ;;  8 
(prn (.getCoeffs p1))                                                                              ;;  9 
(prn (.evaluate p1 2))                                                                             ;; 10 
                                                                                                  
;; polynomial<int> object:                                                                        
(def p2 (PolynomialIntV2.))                                                                        ;; 13 
(.setCoeffs p2 (VectorIntV2. (map int [2 3 5 7 11 -13])))                                          ;; 14 
(prn (.getCoeffs p2))                                                                              ;; 15 
(prn (.evaluate p2 -2))                                                                            ;; 16 
                                                                                                  
;; polynomial<rational<int>>:                                                                     
(def p3 (PolynomialRationalV2.))                                                                   ;; 19 
(.setCoeffs p3 (VectorRationalV2. [ (RationalV2. 7 11) (RationalV2. 11 13) (RationalV2. 13 17) ])) ;; 20 
(prn (mapv #(.__str__ %) (.getCoeffs p3)))                                                         ;; 21 
(prn (.__str__ (.evaluate p3 (RationalV2. -5, 7))))                                                ;; 22 
```


---

```
$ bin/run src/polynomial_v2.clj
{:POLYNOMIAL_VERSION "2.0.2"}
[3.0 5.0 7.0 11.0]
129.0
[2 3 5 7 11 -13]
552
["7/11" "11/13" "13/17"]
"50283/119119"
```

---


### Ruby : polynomial_v2.rb

```ruby
require 'polynomial_v2_swig'                                                                                                     #   1 
PV2 = Polynomial_v2_swig                                                                                                         #   2 
                                                                                                                                
pp POLYNOMIAL_VERSION: PV2::POLYNOMIAL_VERSION                                                                                   #   4 
                                                                                                                                
# polynomial<double>:                                                                                                           
poly        = PV2::PolynomialDoubleV2.new                                                                                        #   7 
poly.coeffs = PV2::VectorDoubleV2.new([ 3, 5.0, 7.0, 11.0 ])                                                                     #   8 
pp poly.coeffs.to_a                                                                                                              #   9 
pp poly.evaluate(2)                                                                                                              #  10 
                                                                                                                                
# polynomial<int>                                                                                                               
poly        = PV2::PolynomialIntV2.new                                                                                           #  13 
poly.coeffs = PV2::VectorIntV2.new([ 2, 3, 5, 7, 11, -13 ])                                                                      #  14 
pp poly.coeffs.to_a                                                                                                              #  15 
pp poly.evaluate(-2)                                                                                                             #  16 
                                                                                                                                
# polynomial<rational<int>>:                                                                                                    
poly        = PV2::PolynomialRationalV2.new()                                                                                    #  19 
poly.coeffs = PV2::VectorRationalV2.new([ PV2::RationalV2.new(7, 11), PV2::RationalV2.new(11, 13), PV2::RationalV2.new(13,17) ]) #  20 
pp poly.coeffs.to_a                                                                                                              #  21 
pp poly.evaluate(PV2::RationalV2.new(-5, 7))                                                                                     #  22 
                                                                                                                                
# polynomial<complex<double>>                                                                                                   
poly        = PV2::PolynomialComplexV2.new()                                                                                     #  25 
poly.coeffs = PV2::VectorComplexV2.new([ 7.2+11.3i, 11.5+13.7i, 13.11+17.13i ])                                                  #  26 
pp poly.coeffs.to_a                                                                                                              #  27 
pp poly.evaluate(-5.7+7.11i)                                                                                                     #  28 
```


---

```
$ bin/run src/polynomial_v2.rb
{:POLYNOMIAL_VERSION=>"2.0.2"}
[3.0, 5.0, 7.0, 11.0]
129.0
[2, 3, 5, 7, 11, -13]
552
[rational<int>(7,11), rational<int>(11,13), rational<int>(13,17)]
rational<int>(50283,119119)
[(7.2+11.3i), (11.5+13.7i), (13.11+17.13i)]
(995.9038889999997-1357.0467130000002i)
```

---



### TCL : polynomial_v2.tcl

```shell
load target/tcl/polynomial_v2_swig.so Polynomial_v2_swig                                      #   1 
                                                                                             
puts [list POLYNOMIAL_VERSION $POLYNOMIAL_VERSION]                                            #   3 
                                                                                             
# polynomial<double>:                                                                        
PolynomialDoubleV2 poly                                                                       #   6 
VectorDoubleV2 c { 3 5.0 7.0 11.0 }                                                           #   7 
poly configure -coeffs c                                                                      #   8 
puts [poly cget -coeffs]                                                                      #   9 
puts [poly evaluate 2]                                                                        #  10 
                                                                                             
# polynomial<int>:                                                                           
PolynomialIntV2 poly                                                                          #  13 
VectorIntV2 c { 2 3 5 7 11 -13 }                                                              #  14 
poly configure -coeffs c                                                                      #  15 
puts [poly cget -coeffs]                                                                      #  16 
puts [poly evaluate -2]                                                                       #  17 
                                                                                             
# polynomial<rational<int>>:                                                                 
PolynomialRationalV2 poly                                                                     #  20 
VectorRationalV2 c [list [new_RationalV2 7 11] [new_RationalV2 11 13] [new_RationalV2 13 17]] #  21 
poly configure -coeffs c                                                                      #  22 
puts [poly cget -coeffs]                                                                      #  23 
puts [RationalV2___repr__ [poly evaluate [new_RationalV2 -5 7]]]                              #  24 
```


---

```
$ bin/run src/polynomial_v2.tcl
POLYNOMIAL_VERSION 2.0.2
_904200d1b87f0000_p_std__vectorT_double_t
129.0
_c04400d1b87f0000_p_std__vectorT_int_t
552
_004100d1b87f0000_p_std__vectorT_mathlib__rationalT_int_t_t
rational<int>(50283,119119)
```

---




### Outputs - Recap





```
$ bin/run target/native/polynomial_v2
POLYNOMIAL_VERSION = 2.0.2
129
552
50283/119119
(995.904,-1357.05)
```

---



```
$ bin/run src/polynomial_v2.py
{'POLYNOMIAL_VERSION': '2.0.2'}
[3.0, 5.0, 7.0, 11.0]
129.0
[rational<int>(7,11), rational<int>(11,13), rational<int>(13,17)]
50283/119119
[(7.2+11.3j), (11.5+13.7j), (13.11+17.13j)]
(995.9038889999997-1357.0467130000002j)
```

---


```
$ bin/run src/polynomial_v2.clj
{:POLYNOMIAL_VERSION "2.0.2"}
[3.0 5.0 7.0 11.0]
129.0
[2 3 5 7 11 -13]
552
["7/11" "11/13" "13/17"]
"50283/119119"
```

---


```
$ bin/run src/polynomial_v2.rb
{:POLYNOMIAL_VERSION=>"2.0.2"}
[3.0, 5.0, 7.0, 11.0]
129.0
[2, 3, 5, 7, 11, -13]
552
[rational<int>(7,11), rational<int>(11,13), rational<int>(13,17)]
rational<int>(50283,119119)
[(7.2+11.3i), (11.5+13.7i), (13.11+17.13i)]
(995.9038889999997-1357.0467130000002i)
```

---



```
$ bin/run src/polynomial_v2.tcl
POLYNOMIAL_VERSION 2.0.2
_904200d1b87f0000_p_std__vectorT_double_t
129.0
_c04400d1b87f0000_p_std__vectorT_int_t
552
_004100d1b87f0000_p_std__vectorT_mathlib__rationalT_int_t_t
rational<int>(50283,119119)
```

---



---



## tommath.c



### C Header : tommath.h

```c
// swig <-> mp_int helpers                                                    
                                                                              
#include <stddef.h>                                                            //  3 
#include <stdint.h>                                                            //  4 
#include "bool.h"                                                              //  5 
#include "libtommath/tommath.h"                                                //  6 
                                                                              
// Convert mp_int <-> string:                                                 
char*    swig_mp_int_to_charP(mp_int* self, int radix);                        //  9 
mp_int*  swig_charP_to_mp_int(const char* str, int radix);                     // 10 
char*    swig_mp_int_repr(mp_int* self, int radix);                            // 11 
                                                                              
#if SWIG                                                                       // 13 
// This extends generated classes with two                                    
// methods which behave as Python's methods.                                  
// Also for Ruby and other language targets.                                  
%extend mp_int {                                                               // 17 
  char* __str__(int radix = 10) {                                              // 18 
    return swig_mp_int_to_charP(self, radix);                                  // 19 
  }                                                                            // 20 
  char* __repr__(int radix = 10) {                                             // 21 
    return swig_mp_int_repr(self, radix);                                      // 22 
  }                                                                            // 23 
}                                                                              // 24 
#endif                                                                         // 25 
                                                                              
// tommath `mp_int` internal memory is managed by:                            
//                                                                            
// * mp_init(mp_int*)                                                         
// * mp_clear(mp_int*)                                                        
//                                                                            
// tommath expects these functions to be called                               
// before and after using a mp_int value, respectively.                       
mp_int*  swig_mp_int_new(mp_digit n);                                          // 34 
void     swig_mp_int_delete(mp_int* self);                                     // 35 
                                                                              
#if SWIG                                                                       // 37 
// SWIG wraps `struct mp_int` values with pointers                            
// allocated with `malloc(sizeof(mp_int))`.                                   
// `%extend mp_int` defines constructors and destructors for `mp_int`.        
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
                                                                              
char* swig_mp_int_to_charP(mp_int* self, int radix) {                          //  5 
  size_t size = 0, written = 0;                                                //  6 
  (void) mp_radix_size(self, radix, &size);                                    //  7 
  char* buf = malloc(size + 1);                                                //  8 
  (void) mp_to_radix(self, buf, size, &written, radix);                        //  9 
  buf[written - 1] = 0;                                                        // 10 
  return buf;                                                                  // 11 
}                                                                              // 12 
                                                                              
char* swig_mp_int_repr(mp_int* self, int radix) {                              // 14 
  char *repr = 0, *str = swig_mp_int_to_charP(self, radix);                    // 15 
  if ( radix == 10 )                                                           // 16 
    asprintf(&repr, "mp_int(\"%s\")", str);                                    // 17 
  else                                                                         // 18 
    asprintf(&repr, "mp_int(\"%s\",%d)", str, radix);                          // 19 
  return free(str), repr;                                                      // 20 
}                                                                              // 21 
                                                                              
mp_int* swig_charP_to_mp_int(const char* str, int radix) {                     // 23 
  mp_int* self = swig_mp_int_new(0);                                           // 24 
  (void) mp_read_radix(self, str, radix);                                      // 25 
  return self;                                                                 // 26 
}                                                                              // 27 
                                                                              
mp_int* swig_mp_int_new(mp_digit n) {                                          // 29 
  mp_int* self = malloc(sizeof(*self));                                        // 30 
  (void) mp_init(self);                                                        // 31 
  mp_set(self, n);                                                             // 32 
  return self;                                                                 // 33 
}                                                                              // 34 
                                                                              
void swig_mp_int_delete(mp_int* self) {                                        // 36 
  mp_clear(self);                                                              // 37 
  free(self);                                                                  // 38 
}                                                                              // 39 
```



### C Main : tommath-native.c

```c
#include "libtommath/tommath.h"                                                          //  1 
                                                                                        
int main(int argc, char **argv) {                                                        //  3 
  printf("MP_ITER = %d\n", MP_ITER);                                                     //  4 
                                                                                        
  mp_int a, b, c, d, e;                                                                  //  6 
                                                                                        
  (void) mp_init_multi(&a, &b, &c, &d, &e, NULL);                                        //  8 
                                                                                        
  (void) mp_set(&a, 2357111317);                                                         // 10 
  (void) mp_set(&b, 1113171923);                                                         // 11 
  (void) mp_read_radix(&e, "12343456", 16);                                              // 12 
                                                                                        
  (void) mp_mul(&a, &b, &c);                                                             // 14 
  (void) mp_mul(&c, &b, &d);                                                             // 15 
                                                                                        
#define P(N) printf("%s = ", #N); (void) mp_fwrite(&N, 10, stdout); fputc('\n', stdout); // 17 
  P(a); P(b); P(c); P(d); P(e);                                                          // 18 
  mp_clear_multi(&a, &b, &c, &d, &e, NULL);                                              // 19 
                                                                                        
  return 0;                                                                              // 21 
}                                                                                        // 22 
```


---

```
$ bin/run target/native/tommath
MP_ITER = -4
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
 // "missing sentinel in function call"                                       
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
                                                                              
print({"MP_ITER": MP_ITER})                                                    #   3 
                                                                              
a = mp_int(); mp_set(a, 2357111317)    # <-- awkward!                          #   5 
b = mp_int(1113171923)                 # <-- better!                           #   6 
c = mp_int()                                                                   #   7 
d = mp_int()                                                                   #   8 
e = mp_int("12343456", 16)             # <-- yey!                              #   9 
                                                                              
print({"a": a, "b": b, "c": c, "d": d, "e": e})                                #  11 
                                                                              
mp_mul(a, b, c)                                                                #  13 
mp_mul(c, b, d)                                                                #  14 
                                                                              
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
                                                                              
puts "MP_ITER = #{MP_ITER}"                                                    #   4 
                                                                              
a = Mp_int.new(); mp_set(a, 2357111317)    # <-- awkward!                      #   6 
b = Mp_int.new(1113171923)                 # <-- better!                       #   7 
c = Mp_int.new()                                                               #   8 
d = Mp_int.new()                                                               #   9 
e = Mp_int.new("12343456", 16)             # <-- yey!                          #  10 
                                                                              
puts({"a": a, "b": b, "c": c, "d": d, "e": e})                                 #  12 
                                                                              
mp_mul(a, b, c);                                                               #  14 
mp_mul(c, b, d);                                                               #  15 
                                                                              
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
                                                                              
a = MPI[2357111317]                                                            #   3 
b = MPI[1113171923]                                                            #   4 
c = MPI[]                                                                      #   5 
d = MPI[]                                                                      #   6 
e = MPI["12343456", 16]                                                        #   7 
                                                                              
puts({a: a, b: b, c: c, d: d, e: e})                                           #   9 
                                                                              
c = a * b                                                                      #  11 
d = c * b                                                                      #  12 
                                                                              
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
                                                                              
#########################################################                     
# Sugar:                                                                      
                                                                              
module Tommath_swig                                                            #   6 
  class Mp_int                                                                 #   7 
    # Constructor:                                                            
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
                                                                              
    def to_s radix = 10                                                        #  26 
      Tommath_swig.swig_mp_int_to_charP(self, radix)                           #  27 
    end                                                                        #  28 
                                                                              
    def inspect                                                                #  30 
      "MPI[#{to_s.inspect}]"                                                   #  31 
    end                                                                        #  32 
                                                                              
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
                                                                              
(write `(MP-ITER ,(MP-ITER))) (newline)                                        ;;  3 
                                                                              
(define a (new-mp-int))                                                        ;;  5 
(mp-set a 2357111317)                   ;; <-- awkward!                        ;;  6 
(define b (new-mp-int 1113171923))      ;; <-- better!                         ;;  7 
(define c (new-mp-int))                                                        ;;  8 
(define d (new-mp-int))                                                        ;;  9 
(define e (new-mp-int "12343456" 16))   ;; <-- yey!                            ;; 10 
                                                                              
(define (show!)                                                                ;; 12 
  (newline)                                                                    ;; 13 
  (let ((r (lambda (n-v)                                                       ;; 14 
        (write (car n-v)) (display " => ")                                     ;; 15 
        (display (mp-int---str-- (cadr n-v))) (newline))))                     ;; 16 
    (for-each r `((a ,a) (b ,b) (c ,c) (d ,d) (e ,e)))))                       ;; 17 
                                                                              
(show!)                                                                        ;; 19 
                                                                              
(mp-mul a b c)                                                                 ;; 21 
(mp-mul c b d)                                                                 ;; 22 
                                                                              
(show!)                                                                        ;; 24 
```


---

```
$ bin/run src/tommath.scm
(MP-ITER -4)

a => 2357111317
b => 1113171923
c => 0
d => 0
e => 305411158

a => 2357111317
b => 1113171923
c => 2623870137469952591
d => 2920818566629701480442302493
e => 305411158
```

---





### Outputs - Recap





```
$ bin/run target/native/tommath
MP_ITER = -4
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

a => 2357111317
b => 1113171923
c => 0
d => 0
e => 305411158

a => 2357111317
b => 1113171923
c => 2623870137469952591
d => 2920818566629701480442302493
e => 305411158
```

---




---



## black_scholes.c



### C Header : black_scholes.h

```c
// black_scholes.c is ~ 100 lines                                                                                                           
double black_scholes_normal(double zz);                                                                                                      //  2 
double black_scholes_call(double strike_price, double asset_price, double standard_deviation, double risk_free_rate, double days_to_expiry); //  3 
double black_scholes_put(double strike_price, double asset_price, double standard_deviation, double risk_free_rate, double days_to_expiry);  //  4 
```



### C Library : black_scholes.c

```c
#include <math.h>                                                                                            //  1 
                                                                                                            
double black_scholes_normal(double zz)                                                                       //  3 
{                                                                                                            //  4 
    //cdf of 0 is 0.5                                                                                       
    if (zz == 0)                                                                                             //  6 
        return 0.5;                                                                                          //  7 
                                                                                                            
    double z = zz;  //zz is input variable,  use z for calculations                                          //  9 
                                                                                                            
    if (zz < 0)                                                                                              // 11 
        z = -zz;  //change negative values to positive                                                       // 12 
                                                                                                            
    //set constants                                                                                         
    double p = 0.2316419;                                                                                    // 15 
    double b1 = 0.31938153;                                                                                  // 16 
    double b2 = -0.356563782;                                                                                // 17 
    double b3 = 1.781477937;                                                                                 // 18 
    double b4 = -1.821255978;                                                                                // 19 
    double b5 = 1.330274428;                                                                                 // 20 
                                                                                                            
    //CALCULATIONS                                                                                          
    double f = 1 / sqrt(2 * M_PI);                                                                           // 23 
    double ff = exp(-pow(z, 2) / 2) * f;                                                                     // 24 
    double s1 = b1 / (1 + p * z);                                                                            // 25 
    double s2 = b2 / pow((1 + p * z), 2);                                                                    // 26 
    double s3 = b3 / pow((1 + p * z), 3);                                                                    // 27 
    double s4 = b4 / pow((1 + p * z), 4);                                                                    // 28 
    double s5 = b5 / pow((1 + p * z), 5);                                                                    // 29 
                                                                                                            
    //sz is the right-tail approximation                                                                    
    double  sz = ff * (s1 + s2 + s3 + s4 + s5);                                                              // 32 
                                                                                                            
    double rz;                                                                                               // 34 
    //cdf of negative input is right-tail of input's absolute value                                         
    if (zz < 0)                                                                                              // 36 
        rz = sz;                                                                                             // 37 
                                                                                                            
    //cdf of positive input is one minus right-tail                                                         
    if (zz > 0)                                                                                              // 40 
        rz = (1 - sz);                                                                                       // 41 
                                                                                                            
    return rz;                                                                                               // 43 
}                                                                                                            // 44 
                                                                                                            
double black_scholes_call_or_put(double strike, double s, double sd, double r, double days, int call_or_put) // 46 
{                                                                                                            // 47 
    double ls = log(s);                                                                                      // 48 
    double lx = log(strike);                                                                                 // 49 
    double t = days / 365;                                                                                   // 50 
    double sd2 = pow(sd, 2);                                                                                 // 51 
    double n = (ls - lx + r * t + sd2 * t / 2);                                                              // 52 
    double sqrtT = sqrt(days / 365);                                                                         // 53 
    double d = sd * sqrtT;                                                                                   // 54 
    double d1 = n / d;                                                                                       // 55 
    double d2 = d1 - sd * sqrtT;                                                                             // 56 
    double nd1 = black_scholes_normal(d1);                                                                   // 57 
    double nd2 = black_scholes_normal(d2);                                                                   // 58 
    if ( call_or_put )                                                                                       // 59 
        return s * nd1 - strike * exp(-r * t) * nd2;                                                         // 60 
    else                                                                                                     // 61 
        return strike * exp(-r * t) * (1 - nd2) - s * (1 - nd1);                                             // 62 
}                                                                                                            // 63 
                                                                                                            
double black_scholes_call(double strike, double s, double sd, double r, double days)                         // 65 
{                                                                                                            // 66 
    return black_scholes_call_or_put(strike, s, sd, r, days, 1);                                             // 67 
}                                                                                                            // 68 
                                                                                                            
double black_scholes_put(double strike, double s, double sd, double r, double days)                          // 70 
{                                                                                                            // 71 
    return black_scholes_call_or_put(strike, s, sd, r, days, 0);                                             // 72 
}                                                                                                            // 73 
```



### C Main : black_scholes-native.c

```c
#include <stdio.h>                                                                     //  1 
#include "black_scholes.h"                                                             //  2 
                                                                                      
int main(int argc, char **argv) {                                                      //  4 
  double data[][5] = {                                                                 //  5 
    // strike_price, asset_price, standard_deviation, risk_free_rate,  days_to_expiry:
    // vary expiry:                                                                   
    { 1.50, 2.00, 0.5,  2.25, 30.0 },                                                  //  8 
    { 1.50, 2.00, 0.5,  2.25, 15.0 },                                                  //  9 
    { 1.50, 2.00, 0.5,  2.25, 10.0 },                                                  // 10 
    { 1.50, 2.00, 0.5,  2.25,  5.0 },                                                  // 11 
    { 1.50, 2.00, 0.5,  2.25,  2.0 },                                                  // 12 
     // vary strike:.0                                                                
    { 0.50, 2.00, 0.25, 2.25, 15.0 },                                                  // 14 
    { 1.00, 2.00, 0.25, 2.25, 15.0 },                                                  // 15 
    { 1.50, 2.00, 0.25, 2.25, 15.0 },                                                  // 16 
    { 2.00, 2.00, 0.25, 2.25, 15.0 },                                                  // 17 
    { 2.50, 2.00, 0.25, 2.25, 15.0 },                                                  // 18 
    { 3.00, 2.00, 0.25, 2.25, 15.0 },                                                  // 19 
    { 3.50, 2.00, 0.25, 2.25, 15.0 },                                                  // 20 
  };                                                                                   // 21 
  for ( int i = 0; i < sizeof(data) / sizeof(data[0]); i ++ ) {                        // 22 
    double *r = data[i];                                                               // 23 
    double c = black_scholes_call (r[0], r[1], r[2], r[3], r[4]);                      // 24 
    double p = black_scholes_put  (r[0], r[1], r[2], r[3], r[4]);                      // 25 
    printf("inputs: [ %5.2f, %5.2f, %5.2f, %5.2f, %5.2f ], call: %6.3f, put: %6.3f\n", // 26 
      r[0], r[1], r[2], r[3], r[4], c, p);                                             // 27 
  }                                                                                    // 28 
  return 0;                                                                            // 29 
}                                                                                      // 30 
```


---

```
$ bin/run target/native/black_scholes
inputs: [  1.50,  2.00,  0.50,  2.25, 30.00 ], call:  0.753, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 10.00 ], call:  0.590, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  5.00 ], call:  0.546, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  2.00 ], call:  0.518, put:  0.000
inputs: [  0.50,  2.00,  0.25,  2.25, 15.00 ], call:  1.544, put:  0.000
inputs: [  1.00,  2.00,  0.25,  2.25, 15.00 ], call:  1.088, put:  0.000
inputs: [  1.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  2.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.178, put:  0.001
inputs: [  2.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.279
inputs: [  3.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.735
inputs: [  3.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  1.191
```

---


### C SWIG Interface : black_scholes.i

```c
%module black_scholes_swig                                                     //  1 
%include "black_scholes.h"                                                     //  2 
%{                                                                             //  3 
#include "black_scholes.h"                                                     //  4 
%}                                                                             //  5 
```



### Python : black_scholes.py

```python
import sys ; sys.path.append('target/python')                                         #   1 
import black_scholes_swig as bs                                                       #   2 
                                                                                     
data = [                                                                              #   4 
    # strike_price, asset_price, standard_deviation, risk_free_rate,  days_to_expiry:
    # vary expiry:                                                                   
    [ 1.50, 2.00, 0.5,  2.25, 30.0 ],                                                 #   7 
    [ 1.50, 2.00, 0.5,  2.25, 15.0 ],                                                 #   8 
    [ 1.50, 2.00, 0.5,  2.25, 10.0 ],                                                 #   9 
    [ 1.50, 2.00, 0.5,  2.25,  5.0 ],                                                 #  10 
    [ 1.50, 2.00, 0.5,  2.25,  2.0 ],                                                 #  11 
    # vary strike:                                                                   
    [ 0.50, 2.00, 0.25, 2.25, 15.0 ],                                                 #  13 
    [ 1.00, 2.00, 0.25, 2.25, 15.0 ],                                                 #  14 
    [ 1.50, 2.00, 0.25, 2.25, 15.0 ],                                                 #  15 
    [ 2.00, 2.00, 0.25, 2.25, 15.0 ],                                                 #  16 
    [ 2.50, 2.00, 0.25, 2.25, 15.0 ],                                                 #  17 
    [ 3.00, 2.00, 0.25, 2.25, 15.0 ],                                                 #  18 
    [ 3.50, 2.00, 0.25, 2.25, 15.0 ],                                                 #  19 
]                                                                                     #  20 
for r in data:                                                                        #  21 
    c = bs.black_scholes_call (*r)                                                    #  22 
    p = bs.black_scholes_put  (*r)                                                    #  23 
    print("inputs: [ %5.2f, %5.2f, %5.2f, %5.2f, %5.2f ], call: %6.3f, put: %6.3f" %  #  24 
            (*r, c, p))                                                               #  25 
```


---

```
$ bin/run src/black_scholes.py
inputs: [  1.50,  2.00,  0.50,  2.25, 30.00 ], call:  0.753, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 10.00 ], call:  0.590, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  5.00 ], call:  0.546, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  2.00 ], call:  0.518, put:  0.000
inputs: [  0.50,  2.00,  0.25,  2.25, 15.00 ], call:  1.544, put:  0.000
inputs: [  1.00,  2.00,  0.25,  2.25, 15.00 ], call:  1.088, put:  0.000
inputs: [  1.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  2.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.178, put:  0.001
inputs: [  2.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.279
inputs: [  3.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.735
inputs: [  3.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  1.191
```

---






### PostgreSQL : black_scholes-1.psql

```sql
-- Load the extension:                                                                                                   
CREATE EXTENSION black_scholes_swig;                                                                                      --  2 
                                                                                                                         
-- Create some sample input data:                                                                                        
CREATE TABLE bs_data (                                                                                                    --  5 
  id SERIAL PRIMARY KEY,                                                                                                  --  6 
  strike_price FLOAT8,                                                                                                    --  7 
  asset_price FLOAT8,                                                                                                     --  8 
  standard_deviation FLOAT8,                                                                                              --  9 
  risk_free_rate FLOAT8,                                                                                                  -- 10 
  days_to_expiry FLOAT8                                                                                                   -- 11 
);                                                                                                                        -- 12 
                                                                                                                         
INSERT INTO bs_data                                                                                                       -- 14 
  ( strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry )                                       -- 15 
VALUES                                                                                                                    -- 16 
  -- vary expiry:                                                                                                        
  ( 1.50, 2.00, 0.5,  2.25, 30 ),                                                                                         -- 18 
  ( 1.50, 2.00, 0.5,  2.25, 15 ),                                                                                         -- 19 
  ( 1.50, 2.00, 0.5,  2.25, 10 ),                                                                                         -- 20 
  ( 1.50, 2.00, 0.5,  2.25,  5 ),                                                                                         -- 21 
  ( 1.50, 2.00, 0.5,  2.25,  2 ),                                                                                         -- 22 
  --  vary strike:                                                                                                       
  ( 0.50, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 24 
  ( 1.00, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 25 
  ( 1.50, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 26 
  ( 2.00, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 27 
  ( 2.50, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 28 
  ( 3.00, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 29 
  ( 3.50, 2.00, 0.25, 2.25, 15 );                                                                                         -- 30 
                                                                                                                         
-- Apply Black-Scholes to data:                                                                                          
CREATE TABLE bs_eval                                                                                                      -- 33 
AS                                                                                                                        -- 34 
SELECT *                                                                                                                  -- 35 
  , truncf(black_scholes_call(strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry)) AS call_val -- 36 
  , truncf(black_scholes_put(strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry)) AS put_val   -- 37 
FROM bs_data;                                                                                                             -- 38 
SELECT * FROM bs_eval;                                                                                                    -- 39 
```


---

```
$ bin/run src/black_scholes-1.psql
 id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val
----+--------------+-------------+--------------------+----------------+----------------+----------+---------
  1 |          1.5 |           2 |                0.5 |           2.25 |             30 |    0.753 |       0
  2 |          1.5 |           2 |                0.5 |           2.25 |             15 |    0.632 |       0
  3 |          1.5 |           2 |                0.5 |           2.25 |             10 |    0.589 |       0
  4 |          1.5 |           2 |                0.5 |           2.25 |              5 |    0.545 |       0
  5 |          1.5 |           2 |                0.5 |           2.25 |              2 |    0.518 |       0
  6 |          0.5 |           2 |               0.25 |           2.25 |             15 |    1.544 |       0
  7 |            1 |           2 |               0.25 |           2.25 |             15 |    1.088 |       0
  8 |          1.5 |           2 |               0.25 |           2.25 |             15 |    0.632 |       0
  9 |            2 |           2 |               0.25 |           2.25 |             15 |    0.177 |   0.001
 10 |          2.5 |           2 |               0.25 |           2.25 |             15 |        0 |   0.279
 11 |            3 |           2 |               0.25 |           2.25 |             15 |        0 |   0.735
 12 |          3.5 |           2 |               0.25 |           2.25 |             15 |        0 |    1.19
(12 rows)
```

---

### PostgreSQL : black_scholes-2.psql

```sql
-- Load the extension:                                                                                                   
CREATE EXTENSION black_scholes_swig;                                                                                      --  2 
                                                                                                                         
-- Create some sample input data:                                                                                        
CREATE TABLE bs_data (                                                                                                    --  5 
  id SERIAL PRIMARY KEY,                                                                                                  --  6 
  strike_price FLOAT8,                                                                                                    --  7 
  asset_price FLOAT8,                                                                                                     --  8 
  standard_deviation FLOAT8,                                                                                              --  9 
  risk_free_rate FLOAT8,                                                                                                  -- 10 
  days_to_expiry FLOAT8                                                                                                   -- 11 
);                                                                                                                        -- 12 
                                                                                                                         
INSERT INTO bs_data                                                                                                       -- 14 
  ( strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry )                                       -- 15 
VALUES                                                                                                                    -- 16 
  -- vary expiry:                                                                                                        
  ( 1.50, 2.00, 0.5,  2.25, 30 ),                                                                                         -- 18 
  ( 1.50, 2.00, 0.5,  2.25, 15 ),                                                                                         -- 19 
  ( 1.50, 2.00, 0.5,  2.25, 10 ),                                                                                         -- 20 
  ( 1.50, 2.00, 0.5,  2.25,  5 ),                                                                                         -- 21 
  ( 1.50, 2.00, 0.5,  2.25,  2 ),                                                                                         -- 22 
  --  vary strike:                                                                                                       
  ( 0.50, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 24 
  ( 1.00, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 25 
  ( 1.50, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 26 
  ( 2.00, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 27 
  ( 2.50, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 28 
  ( 3.00, 2.00, 0.25, 2.25, 15 ),                                                                                         -- 29 
  ( 3.50, 2.00, 0.25, 2.25, 15 );                                                                                         -- 30 
                                                                                                                         
-- Apply Black-Scholes to data:                                                                                          
CREATE TABLE bs_eval                                                                                                      -- 33 
AS                                                                                                                        -- 34 
SELECT *                                                                                                                  -- 35 
  , truncf(black_scholes_call(strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry)) AS call_val -- 36 
  , truncf(black_scholes_put(strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry)) AS put_val   -- 37 
FROM bs_data;                                                                                                             -- 38 
SELECT * FROM bs_eval;                                                                                                    -- 39 
-- Any profitable calls?                                                                                                 
SELECT * FROM bs_eval                                                                                                     -- 41 
WHERE call_val > asset_price OR put_val > asset_price;                                                                    -- 42 
-- Create some random scenarios:                                                                                         
CREATE TABLE bs_hypo_eval                                                                                                 -- 44 
AS                                                                                                                        -- 45 
WITH hd_rand AS (                                                                                                         -- 46 
  SELECT gs.*, bsd.id                                                                                                     -- 47 
  , strike_price -- random_offset(strike_price, 0.25) AS strike_price                                                     -- 48 
  , truncf(random_offset(asset_price, 0.25)) AS asset_price                                                               -- 49 
  , standard_deviation -- random_offset(standard_deviation, 0.25) AS standard_deviation                                   -- 50 
  , risk_free_rate -- random_offset(risk_free_rate, 0.25) AS risk_free_rate                                               -- 51 
  , trunc(random_offset(days_to_expiry, 0.25)) days_to_expiry                                                             -- 52 
  FROM bs_data as bsd, (SELECT generate_series(1, 100) as h_id) gs                                                        -- 53 
),                                                                                                                        -- 54 
hd_rand_eval AS (                                                                                                         -- 55 
SELECT *                                                                                                                  -- 56 
  , truncf(black_scholes_call(strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry)) AS call_val -- 57 
  , truncf(black_scholes_put(strike_price, asset_price, standard_deviation, risk_free_rate, days_to_expiry)) AS put_val   -- 58 
FROM hd_rand                                                                                                              -- 59 
)                                                                                                                         -- 60 
SELECT *                                                                                                                  -- 61 
  , truncf((call_val / asset_price - 1) * 100, 3) AS call_profit_pcnt                                                     -- 62 
  , truncf((put_val  / asset_price - 1) * 100, 3) AS put_profit_pcnt                                                      -- 63 
FROM hd_rand_eval;                                                                                                        -- 64 
-- Select the most profitable random calls:                                                                              
SELECT * FROM bs_hypo_eval                                                                                                -- 66 
WHERE call_val > asset_price                                                                                              -- 67 
ORDER BY call_profit_pcnt DESC                                                                                            -- 68 
LIMIT 10;                                                                                                                 -- 69 
-- Select the most profitable random puts:                                                                               
SELECT * FROM bs_hypo_eval                                                                                                -- 71 
WHERE put_val > asset_price                                                                                               -- 72 
ORDER BY put_profit_pcnt DESC                                                                                             -- 73 
LIMIT 10;                                                                                                                 -- 74 
```


---

```
$ bin/run src/black_scholes-2.psql
 id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val
----+--------------+-------------+--------------------+----------------+----------------+----------+---------
  1 |          1.5 |           2 |                0.5 |           2.25 |             30 |    0.753 |       0
  2 |          1.5 |           2 |                0.5 |           2.25 |             15 |    0.632 |       0
  3 |          1.5 |           2 |                0.5 |           2.25 |             10 |    0.589 |       0
  4 |          1.5 |           2 |                0.5 |           2.25 |              5 |    0.545 |       0
  5 |          1.5 |           2 |                0.5 |           2.25 |              2 |    0.518 |       0
  6 |          0.5 |           2 |               0.25 |           2.25 |             15 |    1.544 |       0
  7 |            1 |           2 |               0.25 |           2.25 |             15 |    1.088 |       0
  8 |          1.5 |           2 |               0.25 |           2.25 |             15 |    0.632 |       0
  9 |            2 |           2 |               0.25 |           2.25 |             15 |    0.177 |   0.001
 10 |          2.5 |           2 |               0.25 |           2.25 |             15 |        0 |   0.279
 11 |            3 |           2 |               0.25 |           2.25 |             15 |        0 |   0.735
 12 |          3.5 |           2 |               0.25 |           2.25 |             15 |        0 |    1.19
(12 rows)

 id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val
----+--------------+-------------+--------------------+----------------+----------------+----------+---------
(0 rows)

 h_id | id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val | call_profit_pcnt | put_profit_pcnt
------+----+--------------+-------------+--------------------+----------------+----------------+----------+---------+------------------+-----------------
   19 |  6 |          0.5 |       1.534 |               0.25 |           2.25 |             14 |    1.927 |       0 |           25.619 |            -100
   90 |  6 |          0.5 |       1.622 |               0.25 |           2.25 |             16 |        2 |       0 |           23.304 |            -100
   54 |  6 |          0.5 |       1.612 |               0.25 |           2.25 |             15 |    1.918 |       0 |           18.982 |            -100
   51 |  6 |          0.5 |       1.506 |               0.25 |           2.25 |             16 |     1.76 |       0 |           16.865 |            -100
   62 |  6 |          0.5 |       1.669 |               0.25 |           2.25 |             17 |    1.938 |       0 |           16.117 |            -100
   81 |  6 |          0.5 |       1.533 |               0.25 |           2.25 |             16 |    1.749 |       0 |            14.09 |            -100
   82 |  6 |          0.5 |       1.703 |               0.25 |           2.25 |             14 |    1.908 |       0 |           12.037 |            -100
    7 |  6 |          0.5 |       1.875 |               0.25 |           2.25 |             14 |    2.001 |       0 |            6.719 |            -100
   44 |  6 |          0.5 |       1.618 |               0.25 |           2.25 |             18 |    1.683 |       0 |            4.017 |            -100
   87 |  6 |          0.5 |       1.571 |               0.25 |           2.25 |             12 |    1.631 |       0 |            3.819 |            -100
(10 rows)

 h_id | id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val | call_profit_pcnt | put_profit_pcnt
------+----+--------------+-------------+--------------------+----------------+----------------+----------+---------+------------------+-----------------
   36 | 12 |          3.5 |       1.517 |               0.25 |           2.25 |             12 |        0 |   1.638 |             -100 |           7.976
(1 row)
```

---



### Outputs - Recap





```
$ bin/run target/native/black_scholes
inputs: [  1.50,  2.00,  0.50,  2.25, 30.00 ], call:  0.753, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 10.00 ], call:  0.590, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  5.00 ], call:  0.546, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  2.00 ], call:  0.518, put:  0.000
inputs: [  0.50,  2.00,  0.25,  2.25, 15.00 ], call:  1.544, put:  0.000
inputs: [  1.00,  2.00,  0.25,  2.25, 15.00 ], call:  1.088, put:  0.000
inputs: [  1.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  2.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.178, put:  0.001
inputs: [  2.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.279
inputs: [  3.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.735
inputs: [  3.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  1.191
```

---



```
$ bin/run src/black_scholes.py
inputs: [  1.50,  2.00,  0.50,  2.25, 30.00 ], call:  0.753, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25, 10.00 ], call:  0.590, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  5.00 ], call:  0.546, put:  0.000
inputs: [  1.50,  2.00,  0.50,  2.25,  2.00 ], call:  0.518, put:  0.000
inputs: [  0.50,  2.00,  0.25,  2.25, 15.00 ], call:  1.544, put:  0.000
inputs: [  1.00,  2.00,  0.25,  2.25, 15.00 ], call:  1.088, put:  0.000
inputs: [  1.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.632, put:  0.000
inputs: [  2.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.178, put:  0.001
inputs: [  2.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.279
inputs: [  3.00,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  0.735
inputs: [  3.50,  2.00,  0.25,  2.25, 15.00 ], call:  0.000, put:  1.191
```

---






```
$ bin/run src/black_scholes-1.psql
 id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val
----+--------------+-------------+--------------------+----------------+----------------+----------+---------
  1 |          1.5 |           2 |                0.5 |           2.25 |             30 |    0.753 |       0
  2 |          1.5 |           2 |                0.5 |           2.25 |             15 |    0.632 |       0
  3 |          1.5 |           2 |                0.5 |           2.25 |             10 |    0.589 |       0
  4 |          1.5 |           2 |                0.5 |           2.25 |              5 |    0.545 |       0
  5 |          1.5 |           2 |                0.5 |           2.25 |              2 |    0.518 |       0
  6 |          0.5 |           2 |               0.25 |           2.25 |             15 |    1.544 |       0
  7 |            1 |           2 |               0.25 |           2.25 |             15 |    1.088 |       0
  8 |          1.5 |           2 |               0.25 |           2.25 |             15 |    0.632 |       0
  9 |            2 |           2 |               0.25 |           2.25 |             15 |    0.177 |   0.001
 10 |          2.5 |           2 |               0.25 |           2.25 |             15 |        0 |   0.279
 11 |            3 |           2 |               0.25 |           2.25 |             15 |        0 |   0.735
 12 |          3.5 |           2 |               0.25 |           2.25 |             15 |        0 |    1.19
(12 rows)
```

---

```
$ bin/run src/black_scholes-2.psql
 id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val
----+--------------+-------------+--------------------+----------------+----------------+----------+---------
  1 |          1.5 |           2 |                0.5 |           2.25 |             30 |    0.753 |       0
  2 |          1.5 |           2 |                0.5 |           2.25 |             15 |    0.632 |       0
  3 |          1.5 |           2 |                0.5 |           2.25 |             10 |    0.589 |       0
  4 |          1.5 |           2 |                0.5 |           2.25 |              5 |    0.545 |       0
  5 |          1.5 |           2 |                0.5 |           2.25 |              2 |    0.518 |       0
  6 |          0.5 |           2 |               0.25 |           2.25 |             15 |    1.544 |       0
  7 |            1 |           2 |               0.25 |           2.25 |             15 |    1.088 |       0
  8 |          1.5 |           2 |               0.25 |           2.25 |             15 |    0.632 |       0
  9 |            2 |           2 |               0.25 |           2.25 |             15 |    0.177 |   0.001
 10 |          2.5 |           2 |               0.25 |           2.25 |             15 |        0 |   0.279
 11 |            3 |           2 |               0.25 |           2.25 |             15 |        0 |   0.735
 12 |          3.5 |           2 |               0.25 |           2.25 |             15 |        0 |    1.19
(12 rows)

 id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val
----+--------------+-------------+--------------------+----------------+----------------+----------+---------
(0 rows)

 h_id | id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val | call_profit_pcnt | put_profit_pcnt
------+----+--------------+-------------+--------------------+----------------+----------------+----------+---------+------------------+-----------------
   19 |  6 |          0.5 |       1.534 |               0.25 |           2.25 |             14 |    1.927 |       0 |           25.619 |            -100
   90 |  6 |          0.5 |       1.622 |               0.25 |           2.25 |             16 |        2 |       0 |           23.304 |            -100
   54 |  6 |          0.5 |       1.612 |               0.25 |           2.25 |             15 |    1.918 |       0 |           18.982 |            -100
   51 |  6 |          0.5 |       1.506 |               0.25 |           2.25 |             16 |     1.76 |       0 |           16.865 |            -100
   62 |  6 |          0.5 |       1.669 |               0.25 |           2.25 |             17 |    1.938 |       0 |           16.117 |            -100
   81 |  6 |          0.5 |       1.533 |               0.25 |           2.25 |             16 |    1.749 |       0 |            14.09 |            -100
   82 |  6 |          0.5 |       1.703 |               0.25 |           2.25 |             14 |    1.908 |       0 |           12.037 |            -100
    7 |  6 |          0.5 |       1.875 |               0.25 |           2.25 |             14 |    2.001 |       0 |            6.719 |            -100
   44 |  6 |          0.5 |       1.618 |               0.25 |           2.25 |             18 |    1.683 |       0 |            4.017 |            -100
   87 |  6 |          0.5 |       1.571 |               0.25 |           2.25 |             12 |    1.631 |       0 |            3.819 |            -100
(10 rows)

 h_id | id | strike_price | asset_price | standard_deviation | risk_free_rate | days_to_expiry | call_val | put_val | call_profit_pcnt | put_profit_pcnt
------+----+--------------+-------------+--------------------+----------------+----------------+----------+---------+------------------+-----------------
   36 | 12 |          3.5 |       1.517 |               0.25 |           2.25 |             12 |        0 |   1.638 |             -100 |           7.976
(1 row)
```

---


---


# Workflow

1. Create native library. (once)
2. Create SWIG interface files. (once)
3. Generate bindings from SWIG interface files. (many)
4. Compile bindings.
5. Link SWIG bindings and native library into a dynamic library.
6. Load dynamic library.

```
*
   +---------------------------------+
   |         1. foo.c                +--+
   +---------------------------------+  |
   |  double f(int, double, char*)   |  |
   |    { return ...; }              |  |
   +---------------------------------+  |
                                        |
   +---------------------------------+  |
+--+         1. foo.h                +--+
|  +---------------------------------+  |
|  |  double f(int, double, char*);  |  |
|  +-+-------------------------------+  |
|    |                                  |
|    |  1. cc foo.c              \  <---+
|    |       -о bld/libfоо.a
|    v
|  +-------------------+
|  |  bld/libfоо.a     +----------------+
|  +-------------------+                |
|                                       |
|  +---------------------------------+  |
|  |         2. foo.i                |  |
|  +---------------------------------+  |
|  |  %module foo_swig               |  |
|  |  %include "foo.h"               |  |
|  +-+-------------------------------+  |
|    |                                  |
+--->|  3. swig -python foo.i    \      |
     |       -o bld/foo_swig.c          |
     v                                  |
   +-------------------+                |
+--+  bld/foo_swig.py  |                |
|  |  bld/foo_swig.c   |                |
|  +-+-----------------+                |
|    |                                  |
|    |  4. cc -c bld/foo_swig.c         |
|    v                                  |
|  +-------------------+                |
|  |  bld/foo_swig.о   |                |
|  +-+-----------------+                |
|    |                                  |
|    |  5. cc -dynamiclib         \     |
|    |       -о bld/_foo_swig.so  \     |
|    |       bld/foo_swig.о       \     |
|    |       -l foo   <-----------------+
|    v
|  +-------------------+
|  |  bld/foo_swig.sо  |
|  +-+-----------------+
|    |
+--->|  6. python script.py
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
*
```



# Workflow Examples


## Workflow - mathlib.c                                                       
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
cc -Isrc -c -o target/native/mathlib.o src/mathlib.c                          
                                                                              
# Compile and link native program:                                            
cc -Isrc -o target/native/mathlib src/mathlib-native.c target/native/mathlib.o  \
  -L/opt/homebrew/lib                                                         
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -python -addextern -I- -Isrc -outdir target/python/ -o                     \
  target/python/mathlib_swig.c src/mathlib.i                                  
                                                                              
# Source code statistics:                                                     
wc -l src/mathlib.h src/mathlib.i                                             
7 src/mathlib.h                                                               
5 src/mathlib.i                                                               
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/mathlib_swig.c target/python/mathlib_swig.py              
3662 target/python/mathlib_swig.c                                             
65 target/python/mathlib_swig.py                                              
3727 total                                                                    
                                                                              
# Compile python bindings:                                                    
cc -Isrc                                                                                   \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -dynamic -c -o target/python/mathlib_swig.c.o target/python/mathlib_swig.c             
                                                                              
# Link python dynamic library:                                                
cc -dynamiclib -o target/python/_mathlib_swig.so target/native/mathlib.o                                  \
  target/python/mathlib_swig.c.o                                                                          \
  -L/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/lib/python3.10/config-3.10-darwin  \
  -ldl -framework CoreFoundation                                                                        
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -java -addextern -I- -Isrc -outdir target/clojure/ -o                      \
  target/clojure/mathlib_swig.c src/mathlib.i                                 
                                                                              
# Source code statistics:                                                     
wc -l src/mathlib.h src/mathlib.i                                             
7 src/mathlib.h                                                               
5 src/mathlib.i                                                               
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/mathlib_swig.c target/clojure/mathlib*.java              
239 target/clojure/mathlib_swig.c                                             
15 target/clojure/mathlib_swig.java                                           
12 target/clojure/mathlib_swigConstants.java                                  
13 target/clojure/mathlib_swigJNI.java                                        
279 total                                                                     
                                                                              
# Compile clojure bindings:                                                   
cc -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/$JAVA_ARCH -c -o             \
  target/clojure/mathlib_swig.c.o target/clojure/mathlib_swig.c               
                                                                              
# Link clojure dynamic library:                                               
cc -dynamiclib -o target/clojure/libmathlib_swig.jnilib                         \
  target/native/mathlib.o target/clojure/mathlib_swig.c.o -L/opt/homebrew/lib 
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -ruby -addextern -I- -Isrc -outdir target/ruby/ -o                         \
  target/ruby/mathlib_swig.c src/mathlib.i                                    
                                                                              
# Source code statistics:                                                     
wc -l src/mathlib.h src/mathlib.i                                             
7 src/mathlib.h                                                               
5 src/mathlib.i                                                               
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/mathlib_swig.c                                              
2282 target/ruby/mathlib_swig.c                                               
                                                                              
# Compile ruby bindings:                                                      
cc -Isrc -I$RUBY_HOME/include/ruby-2.7.0                                        \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o                         \
  target/ruby/mathlib_swig.c.o target/ruby/mathlib_swig.c                     
                                                                              
# Link ruby dynamic library:                                                  
cc -dynamiclib -o target/ruby/mathlib_swig.bundle target/native/mathlib.o       \
  target/ruby/mathlib_swig.c.o -L/opt/homebrew/lib                            
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -tcl -addextern -I- -Isrc -outdir target/tcl/ -o                           \
  target/tcl/mathlib_swig.c src/mathlib.i                                     
                                                                              
# Source code statistics:                                                     
wc -l src/mathlib.h src/mathlib.i                                             
7 src/mathlib.h                                                               
5 src/mathlib.i                                                               
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/mathlib_swig.c                                               
2178 target/tcl/mathlib_swig.c                                                
                                                                              
# Compile tcl bindings:                                                       
cc -Isrc -I$TCL_HOME/include -c -o target/tcl/mathlib_swig.c.o                  \
  target/tcl/mathlib_swig.c                                                   
                                                                              
# Link tcl dynamic library:                                                   
cc -dynamiclib -o target/tcl/mathlib_swig.so target/native/mathlib.o            \
  target/tcl/mathlib_swig.c.o -L/opt/homebrew/lib                             
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -guile -addextern -I- -Isrc -outdir target/guile/ -o                       \
  target/guile/mathlib_swig.c src/mathlib.i                                   
                                                                              
# Source code statistics:                                                     
wc -l src/mathlib.h src/mathlib.i                                             
7 src/mathlib.h                                                               
5 src/mathlib.i                                                               
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/mathlib_swig.c                                             
1631 target/guile/mathlib_swig.c                                              
                                                                              
# Compile guile bindings:                                                     
cc -Isrc -D_THREAD_SAFE -I$GUILE_HOME/include/guile/3.0 -I/opt/homebrewgmp      \
  -I/opt/homebrewgmp/include -I/opt/homebrewreadline/include                    \
  -I/opt/homebrewbdw-gc/include -c -o target/guile/mathlib_swig.c.o             \
  target/guile/mathlib_swig.c                                                 
                                                                              
# Link guile dynamic library:                                                 
cc -dynamiclib -o target/guile/libmathlib_swig.so target/native/mathlib.o       \
  target/guile/mathlib_swig.c.o -L$GUILE_HOME/lib -L/opt/homebrewbdw-gc/lib     \
  -lguile-3.0 -lgc -lpthread                                                  
                                                                              
```                                                                           
                                                                              
### Build postgresql Bindings                                                 
                                                                              
```                                                                           
# Generate postgresql bindings:                                               
swig -postgresql -extension-version 1.2.3 -addextern -I- -Isrc                  \
  -I$POSTGRESQL_INC_DIR -outdir target/postgresql/ -o                           \
  target/postgresql/mathlib_swig.c src/mathlib.i                              
                                                                              
# Source code statistics:                                                     
wc -l src/mathlib.h src/mathlib.i                                             
7 src/mathlib.h                                                               
5 src/mathlib.i                                                               
12 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/postgresql/mathlib_swig.c target/postgresql/mathlib_swig-*.sql     \
  target/postgresql/mathlib_swig.control target/postgresql/mathlib_swig.make  
1489 target/postgresql/mathlib_swig.c                                         
20 target/postgresql/mathlib_swig--1.2.3.sql                                  
8 target/postgresql/mathlib_swig.control                                      
13 target/postgresql/mathlib_swig.make                                        
1530 total                                                                    
                                                                              
# Compile postgresql bindings:                                                
cc -Isrc -I$POSTGRESQL_INC_DIR -c -o target/postgresql/mathlib_swig.c.o         \
  target/postgresql/mathlib_swig.c                                            
                                                                              
# Link postgresql dynamic library:                                            
cc -dynamiclib -o target/postgresql/mathlib_swig.so target/native/mathlib.o     \
  target/postgresql/mathlib_swig.c.o -L/opt/homebrew/lib                      
                                                                              
                                                                              
# Compile and install postgresql extension:                                   
$POSTGRESQL_LIB_DIR/pgxs/src/makefiles/../../config/install-sh -c -d            \
  '$POSTGRESQL_SHARE_DIR/extension'                                           
$POSTGRESQL_LIB_DIR/pgxs/src/makefiles/../../config/install-sh -c -d            \
  '$POSTGRESQL_SHARE_DIR/extension'                                           
$POSTGRESQL_LIB_DIR/pgxs/src/makefiles/../../config/install-sh -c -d            \
  '$POSTGRESQL_LIB_DIR'                                                       
install -c -m 644 ./mathlib_swig.control '$POSTGRESQL_SHARE_DIR/extension/'   
install -c -m 644 ./mathlib_swig--1.2.3.sql '$POSTGRESQL_SHARE_DIR/extension/'
install -c -m 755 mathlib_swig.so '$POSTGRESQL_LIB_DIR/'                      
                                                                              
```                                                                           
                                                                              

---


## Workflow - polynomial.cc                                                   
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
cc++ -std=c++17 -Isrc -c -o target/native/polynomial.o src/polynomial.cc      
                                                                              
# Compile and link native program:                                            
cc++ -std=c++17 -Isrc -o target/native/polynomial src/polynomial-native.cc      \
  target/native/polynomial.o -L/opt/homebrew/lib                              
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -c++ -python -addextern -I- -Isrc -outdir target/python/ -o                \
  target/python/polynomial_swig.cc src/polynomial.i                           
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/polynomial_swig.cc target/python/polynomial_swig.py       
8512 target/python/polynomial_swig.cc                                         
241 target/python/polynomial_swig.py                                          
8753 total                                                                    
                                                                              
# Compile python bindings:                                                    
cc++ -std=c++17 -Isrc                                                                      \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -dynamic -c -o target/python/polynomial_swig.cc.o                                        \
  target/python/polynomial_swig.cc                                                       
                                                                              
# Link python dynamic library:                                                
cc++ -dynamiclib -o target/python/_polynomial_swig.so                                                     \
  target/native/polynomial.o target/python/polynomial_swig.cc.o                                           \
  -L/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/lib/python3.10/config-3.10-darwin  \
  -ldl -framework CoreFoundation                                                                        
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -c++ -java -addextern -I- -Isrc -outdir target/clojure/ -o                 \
  target/clojure/polynomial_swig.cc src/polynomial.i                          
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/polynomial_swig.cc target/clojure/polynomial*.java       
680 target/clojure/polynomial_swig.cc                                         
11 target/clojure/polynomial_swig.java                                        
12 target/clojure/polynomial_swigConstants.java                               
32 target/clojure/polynomial_swigJNI.java                                     
735 total                                                                     
                                                                              
# Compile clojure bindings:                                                   
cc++ -std=c++17 -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/$JAVA_ARCH -c   \
  -o target/clojure/polynomial_swig.cc.o target/clojure/polynomial_swig.cc    
                                                                              
# Link clojure dynamic library:                                               
cc++ -dynamiclib -o target/clojure/libpolynomial_swig.jnilib                    \
  target/native/polynomial.o target/clojure/polynomial_swig.cc.o                \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -c++ -ruby -addextern -I- -Isrc -outdir target/ruby/ -o                    \
  target/ruby/polynomial_swig.cc src/polynomial.i                             
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/polynomial_swig.cc                                          
8577 target/ruby/polynomial_swig.cc                                           
                                                                              
# Compile ruby bindings:                                                      
cc++ -std=c++17 -Isrc -I$RUBY_HOME/include/ruby-2.7.0                           \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o                         \
  target/ruby/polynomial_swig.cc.o target/ruby/polynomial_swig.cc             
                                                                              
# Link ruby dynamic library:                                                  
cc++ -dynamiclib -o target/ruby/polynomial_swig.bundle                          \
  target/native/polynomial.o target/ruby/polynomial_swig.cc.o                   \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -c++ -tcl -addextern -I- -Isrc -outdir target/tcl/ -o                      \
  target/tcl/polynomial_swig.cc src/polynomial.i                              
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/polynomial_swig.cc                                           
3004 target/tcl/polynomial_swig.cc                                            
                                                                              
# Compile tcl bindings:                                                       
cc++ -std=c++17 -Isrc -I$TCL_HOME/include -c -o                                 \
  target/tcl/polynomial_swig.cc.o target/tcl/polynomial_swig.cc               
                                                                              
# Link tcl dynamic library:                                                   
cc++ -dynamiclib -o target/tcl/polynomial_swig.so target/native/polynomial.o    \
  target/tcl/polynomial_swig.cc.o -L/opt/homebrew/lib                         
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -c++ -guile -addextern -I- -Isrc -outdir target/guile/ -o                  \
  target/guile/polynomial_swig.cc src/polynomial.i                            
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial.h src/polynomial.i                                       
10 src/polynomial.h                                                           
16 src/polynomial.i                                                           
26 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/polynomial_swig.cc                                         
2317 target/guile/polynomial_swig.cc                                          
                                                                              
# Compile guile bindings:                                                     
cc++ -std=c++17 -Isrc -D_THREAD_SAFE -I$GUILE_HOME/include/guile/3.0            \
  -I/opt/homebrewgmp -I/opt/homebrewgmp/include                                 \
  -I/opt/homebrewreadline/include -I/opt/homebrewbdw-gc/include -c -o           \
  target/guile/polynomial_swig.cc.o target/guile/polynomial_swig.cc           
                                                                              
# Link guile dynamic library:                                                 
cc++ -dynamiclib -o target/guile/libpolynomial_swig.so                          \
  target/native/polynomial.o target/guile/polynomial_swig.cc.o                  \
  -L$GUILE_HOME/lib -L/opt/homebrewbdw-gc/lib -lguile-3.0 -lgc -lpthread      
                                                                              
```                                                                           
                                                                              

---


## Workflow - polynomial_v2.cc                                                
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
cc++ -std=c++17 -Isrc -c -o target/native/polynomial_v2.o src/polynomial_v2.cc
                                                                              
# Compile and link native program:                                            
cc++ -std=c++17 -Isrc -o target/native/polynomial_v2                            \
  src/polynomial_v2-native.cc target/native/polynomial_v2.o                     \
  -L/opt/homebrew/lib                                                         
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -c++ -python -addextern -I- -Isrc -outdir target/python/ -o                \
  target/python/polynomial_v2_swig.cc src/polynomial_v2.i                     
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
32 src/polynomial_v2.i                                                        
45 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/polynomial_v2_swig.cc target/python/polynomial_v2_swig.py 
15618 target/python/polynomial_v2_swig.cc                                     
631 target/python/polynomial_v2_swig.py                                       
16249 total                                                                   
                                                                              
# Compile python bindings:                                                    
cc++ -std=c++17 -Isrc                                                                      \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -dynamic -c -o target/python/polynomial_v2_swig.cc.o                                     \
  target/python/polynomial_v2_swig.cc                                                    
                                                                              
# Link python dynamic library:                                                
cc++ -dynamiclib -o target/python/_polynomial_v2_swig.so                                                  \
  target/native/polynomial_v2.o target/python/polynomial_v2_swig.cc.o                                     \
  -L/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/lib/python3.10/config-3.10-darwin  \
  -ldl -framework CoreFoundation                                                                        
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -c++ -java -addextern -I- -Isrc -outdir target/clojure/ -o                 \
  target/clojure/polynomial_v2_swig.cc src/polynomial_v2.i                    
include/rational.h:25: Warning 503: Can't wrap 'operator +' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:28: Warning 503: Can't wrap 'operator *' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:31: Warning 503: Can't wrap 'operator ==' unless renamed to  \
  a valid identifier.                                                         
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
32 src/polynomial_v2.i                                                        
45 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/polynomial_v2_swig.cc target/clojure/polynomial_v2*.java 
1675 target/clojure/polynomial_v2_swig.cc                                     
11 target/clojure/polynomial_v2_swig.java                                     
12 target/clojure/polynomial_v2_swigConstants.java                            
85 target/clojure/polynomial_v2_swigJNI.java                                  
1783 total                                                                    
                                                                              
# Compile clojure bindings:                                                   
cc++ -std=c++17 -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/$JAVA_ARCH -c   \
  -o target/clojure/polynomial_v2_swig.cc.o                                     \
  target/clojure/polynomial_v2_swig.cc                                        
                                                                              
# Link clojure dynamic library:                                               
cc++ -dynamiclib -o target/clojure/libpolynomial_v2_swig.jnilib                 \
  target/native/polynomial_v2.o target/clojure/polynomial_v2_swig.cc.o          \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -c++ -ruby -addextern -I- -Isrc -outdir target/ruby/ -o                    \
  target/ruby/polynomial_v2_swig.cc src/polynomial_v2.i                       
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
32 src/polynomial_v2.i                                                        
45 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/polynomial_v2_swig.cc                                       
17281 target/ruby/polynomial_v2_swig.cc                                       
                                                                              
# Compile ruby bindings:                                                      
cc++ -std=c++17 -Isrc -I$RUBY_HOME/include/ruby-2.7.0                           \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o                         \
  target/ruby/polynomial_v2_swig.cc.o target/ruby/polynomial_v2_swig.cc       
                                                                              
# Link ruby dynamic library:                                                  
cc++ -dynamiclib -o target/ruby/polynomial_v2_swig.bundle                       \
  target/native/polynomial_v2.o target/ruby/polynomial_v2_swig.cc.o             \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -c++ -tcl -addextern -I- -Isrc -outdir target/tcl/ -o                      \
  target/tcl/polynomial_v2_swig.cc src/polynomial_v2.i                        
include/rational.h:31: Warning 503: Can't wrap 'operator ==' unless renamed to  \
  a valid identifier.                                                         
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
32 src/polynomial_v2.i                                                        
45 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/polynomial_v2_swig.cc                                        
4726 target/tcl/polynomial_v2_swig.cc                                         
                                                                              
# Compile tcl bindings:                                                       
cc++ -std=c++17 -Isrc -I$TCL_HOME/include -c -o                                 \
  target/tcl/polynomial_v2_swig.cc.o target/tcl/polynomial_v2_swig.cc         
                                                                              
# Link tcl dynamic library:                                                   
cc++ -dynamiclib -o target/tcl/polynomial_v2_swig.so                            \
  target/native/polynomial_v2.o target/tcl/polynomial_v2_swig.cc.o              \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -c++ -guile -addextern -I- -Isrc -outdir target/guile/ -o                  \
  target/guile/polynomial_v2_swig.cc src/polynomial_v2.i                      
include/rational.h:25: Warning 503: Can't wrap 'operator +' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:28: Warning 503: Can't wrap 'operator *' unless renamed to   \
  a valid identifier.                                                         
include/rational.h:31: Warning 503: Can't wrap 'operator ==' unless renamed to  \
  a valid identifier.                                                         
                                                                              
# Source code statistics:                                                     
wc -l src/polynomial_v2.h src/polynomial_v2.i                                 
13 src/polynomial_v2.h                                                        
32 src/polynomial_v2.i                                                        
45 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/polynomial_v2_swig.cc                                      
4044 target/guile/polynomial_v2_swig.cc                                       
                                                                              
# Compile guile bindings:                                                     
cc++ -std=c++17 -Isrc -D_THREAD_SAFE -I$GUILE_HOME/include/guile/3.0            \
  -I/opt/homebrewgmp -I/opt/homebrewgmp/include                                 \
  -I/opt/homebrewreadline/include -I/opt/homebrewbdw-gc/include -c -o           \
  target/guile/polynomial_v2_swig.cc.o target/guile/polynomial_v2_swig.cc     
                                                                              
# Link guile dynamic library:                                                 
cc++ -dynamiclib -o target/guile/libpolynomial_v2_swig.so                       \
  target/native/polynomial_v2.o target/guile/polynomial_v2_swig.cc.o            \
  -L$GUILE_HOME/lib -L/opt/homebrewbdw-gc/lib -lguile-3.0 -lgc -lpthread      
                                                                              
```                                                                           
                                                                              

---


## Workflow - tommath.c                                                       
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
cc -Isrc -c -o target/native/tommath.o src/tommath.c                          
                                                                              
# Compile and link native program:                                            
cc -Isrc -o target/native/tommath src/tommath-native.c target/native/tommath.o  \
  -ltommath                                                                   
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -python -addextern -I- -Isrc -outdir target/python/ -o                     \
  target/python/tommath_swig.c src/tommath.i                                  
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/python/tommath_swig.c target/python/tommath_swig.py              
9365 target/python/tommath_swig.c                                             
478 target/python/tommath_swig.py                                             
9843 total                                                                    
                                                                              
# Compile python bindings:                                                    
cc -Isrc                                                                                   \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -dynamic -c -o target/python/tommath_swig.c.o target/python/tommath_swig.c             
                                                                              
# Link python dynamic library:                                                
cc -dynamiclib -o target/python/_tommath_swig.so target/native/tommath.o                                  \
  target/python/tommath_swig.c.o                                                                          \
  -L/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/lib/python3.10/config-3.10-darwin  \
  -ldl -ltommath                                                                                        
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -java -addextern -I- -Isrc -outdir target/clojure/ -o                      \
  target/clojure/tommath_swig.c src/tommath.i                                 
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/tommath_swig.c target/clojure/tommath*.java              
3134 target/clojure/tommath_swig.c                                            
545 target/clojure/tommath_swig.java                                          
15 target/clojure/tommath_swigConstants.java                                  
178 target/clojure/tommath_swigJNI.java                                       
3872 total                                                                    
                                                                              
# Compile clojure bindings:                                                   
cc -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/$JAVA_ARCH -c -o             \
  target/clojure/tommath_swig.c.o target/clojure/tommath_swig.c               
                                                                              
# Link clojure dynamic library:                                               
cc -dynamiclib -o target/clojure/libtommath_swig.jnilib                         \
  target/native/tommath.o target/clojure/tommath_swig.c.o -ltommath           
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -ruby -addextern -I- -Isrc -outdir target/ruby/ -o                         \
  target/ruby/tommath_swig.c src/tommath.i                                    
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/tommath_swig.c                                              
7892 target/ruby/tommath_swig.c                                               
                                                                              
# Compile ruby bindings:                                                      
cc -Isrc -I$RUBY_HOME/include/ruby-2.7.0                                        \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o                         \
  target/ruby/tommath_swig.c.o target/ruby/tommath_swig.c                     
                                                                              
# Link ruby dynamic library:                                                  
cc -dynamiclib -o target/ruby/tommath_swig.bundle target/native/tommath.o       \
  target/ruby/tommath_swig.c.o -ltommath                                      
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -guile -addextern -I- -Isrc -outdir target/guile/ -o                       \
  target/guile/tommath_swig.c src/tommath.i                                   
                                                                              
# Source code statistics:                                                     
wc -l src/tommath.h src/tommath.i                                             
52 src/tommath.h                                                              
16 src/tommath.i                                                              
68 total                                                                      
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/tommath_swig.c                                             
6423 target/guile/tommath_swig.c                                              
                                                                              
# Compile guile bindings:                                                     
cc -Isrc -D_THREAD_SAFE -I$GUILE_HOME/include/guile/3.0 -I/opt/homebrewgmp      \
  -I/opt/homebrewgmp/include -I/opt/homebrewreadline/include                    \
  -I/opt/homebrewbdw-gc/include -c -o target/guile/tommath_swig.c.o             \
  target/guile/tommath_swig.c                                                 
                                                                              
# Link guile dynamic library:                                                 
cc -dynamiclib -o target/guile/libtommath_swig.so target/native/tommath.o       \
  target/guile/tommath_swig.c.o -L$GUILE_HOME/lib -L/opt/homebrewbdw-gc/lib     \
  -lguile-3.0 -lgc -lpthread -ltommath                                        
                                                                              
```                                                                           
                                                                              

---


## Workflow - black_scholes.c                                                 
                                                                              
### Compile Native Code                                                       
                                                                              
```                                                                           
# Compile native library:                                                     
cc -Isrc -c -o target/native/black_scholes.o src/black_scholes.c              
                                                                              
# Compile and link native program:                                            
cc -Isrc -o target/native/black_scholes src/black_scholes-native.c              \
  target/native/black_scholes.o -L/opt/homebrew/lib                           
```                                                                           
                                                                              
### Build python Bindings                                                     
                                                                              
```                                                                           
# Generate python bindings:                                                   
swig -python -addextern -I- -Isrc -outdir target/python/ -o                     \
  target/python/black_scholes_swig.c src/black_scholes.i                      
                                                                              
# Source code statistics:                                                     
wc -l src/black_scholes.h src/black_scholes.i                                 
4 src/black_scholes.h                                                         
5 src/black_scholes.i                                                         
9 total                                                                       
                                                                              
# Generated code statistics:                                                  
wc -l target/python/black_scholes_swig.c target/python/black_scholes_swig.py  
3697 target/python/black_scholes_swig.c                                       
70 target/python/black_scholes_swig.py                                        
3767 total                                                                    
                                                                              
# Compile python bindings:                                                    
cc -Isrc                                                                                   \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -I/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/include/python3.10  \
  -dynamic -c -o target/python/black_scholes_swig.c.o                                      \
  target/python/black_scholes_swig.c                                                     
                                                                              
# Link python dynamic library:                                                
cc -dynamiclib -o target/python/_black_scholes_swig.so                                                    \
  target/native/black_scholes.o target/python/black_scholes_swig.c.o                                      \
  -L/opt/homebrewpython@3.10/Frameworks/Python.framework/Versions/3.10/lib/python3.10/config-3.10-darwin  \
  -ldl -framework CoreFoundation                                                                        
                                                                              
```                                                                           
                                                                              
### Build clojure Bindings                                                    
                                                                              
```                                                                           
# Generate clojure bindings:                                                  
swig -java -addextern -I- -Isrc -outdir target/clojure/ -o                      \
  target/clojure/black_scholes_swig.c src/black_scholes.i                     
                                                                              
# Source code statistics:                                                     
wc -l src/black_scholes.h src/black_scholes.i                                 
4 src/black_scholes.h                                                         
5 src/black_scholes.i                                                         
9 total                                                                       
                                                                              
# Generated code statistics:                                                  
wc -l target/clojure/black_scholes_swig.c target/clojure/black_scholes*.java  
263 target/clojure/black_scholes_swig.c                                       
23 target/clojure/black_scholes_swig.java                                     
14 target/clojure/black_scholes_swigJNI.java                                  
300 total                                                                     
                                                                              
# Compile clojure bindings:                                                   
cc -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/$JAVA_ARCH -c -o             \
  target/clojure/black_scholes_swig.c.o target/clojure/black_scholes_swig.c   
                                                                              
# Link clojure dynamic library:                                               
cc -dynamiclib -o target/clojure/libblack_scholes_swig.jnilib                   \
  target/native/black_scholes.o target/clojure/black_scholes_swig.c.o           \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build ruby Bindings                                                       
                                                                              
```                                                                           
# Generate ruby bindings:                                                     
swig -ruby -addextern -I- -Isrc -outdir target/ruby/ -o                         \
  target/ruby/black_scholes_swig.c src/black_scholes.i                        
                                                                              
# Source code statistics:                                                     
wc -l src/black_scholes.h src/black_scholes.i                                 
4 src/black_scholes.h                                                         
5 src/black_scholes.i                                                         
9 total                                                                       
                                                                              
# Generated code statistics:                                                  
wc -l target/ruby/black_scholes_swig.c                                        
2326 target/ruby/black_scholes_swig.c                                         
                                                                              
# Compile ruby bindings:                                                      
cc -Isrc -I$RUBY_HOME/include/ruby-2.7.0                                        \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o                         \
  target/ruby/black_scholes_swig.c.o target/ruby/black_scholes_swig.c         
                                                                              
# Link ruby dynamic library:                                                  
cc -dynamiclib -o target/ruby/black_scholes_swig.bundle                         \
  target/native/black_scholes.o target/ruby/black_scholes_swig.c.o              \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build tcl Bindings                                                        
                                                                              
```                                                                           
# Generate tcl bindings:                                                      
swig -tcl -addextern -I- -Isrc -outdir target/tcl/ -o                           \
  target/tcl/black_scholes_swig.c src/black_scholes.i                         
                                                                              
# Source code statistics:                                                     
wc -l src/black_scholes.h src/black_scholes.i                                 
4 src/black_scholes.h                                                         
5 src/black_scholes.i                                                         
9 total                                                                       
                                                                              
# Generated code statistics:                                                  
wc -l target/tcl/black_scholes_swig.c                                         
2229 target/tcl/black_scholes_swig.c                                          
                                                                              
# Compile tcl bindings:                                                       
cc -Isrc -I$TCL_HOME/include -c -o target/tcl/black_scholes_swig.c.o            \
  target/tcl/black_scholes_swig.c                                             
                                                                              
# Link tcl dynamic library:                                                   
cc -dynamiclib -o target/tcl/black_scholes_swig.so                              \
  target/native/black_scholes.o target/tcl/black_scholes_swig.c.o               \
  -L/opt/homebrew/lib                                                         
                                                                              
```                                                                           
                                                                              
### Build guile Bindings                                                      
                                                                              
```                                                                           
# Generate guile bindings:                                                    
swig -guile -addextern -I- -Isrc -outdir target/guile/ -o                       \
  target/guile/black_scholes_swig.c src/black_scholes.i                       
                                                                              
# Source code statistics:                                                     
wc -l src/black_scholes.h src/black_scholes.i                                 
4 src/black_scholes.h                                                         
5 src/black_scholes.i                                                         
9 total                                                                       
                                                                              
# Generated code statistics:                                                  
wc -l target/guile/black_scholes_swig.c                                       
1676 target/guile/black_scholes_swig.c                                        
                                                                              
# Compile guile bindings:                                                     
cc -Isrc -D_THREAD_SAFE -I$GUILE_HOME/include/guile/3.0 -I/opt/homebrewgmp      \
  -I/opt/homebrewgmp/include -I/opt/homebrewreadline/include                    \
  -I/opt/homebrewbdw-gc/include -c -o target/guile/black_scholes_swig.c.o       \
  target/guile/black_scholes_swig.c                                           
                                                                              
# Link guile dynamic library:                                                 
cc -dynamiclib -o target/guile/libblack_scholes_swig.so                         \
  target/native/black_scholes.o target/guile/black_scholes_swig.c.o             \
  -L$GUILE_HOME/lib -L/opt/homebrewbdw-gc/lib -lguile-3.0 -lgc -lpthread      
                                                                              
```                                                                           
                                                                              
### Build postgresql Bindings                                                 
                                                                              
```                                                                           
# Generate postgresql bindings:                                               
swig -postgresql -extension-version 1.2.3 -addextern -I- -Isrc                  \
  -I$POSTGRESQL_INC_DIR -outdir target/postgresql/ -o                           \
  target/postgresql/black_scholes_swig.c src/black_scholes.i                  
                                                                              
# Source code statistics:                                                     
wc -l src/black_scholes.h src/black_scholes.i                                 
4 src/black_scholes.h                                                         
5 src/black_scholes.i                                                         
9 total                                                                       
                                                                              
# Generated code statistics:                                                  
wc -l target/postgresql/black_scholes_swig.c                                    \
  target/postgresql/black_scholes_swig-*.sql                                    \
  target/postgresql/black_scholes_swig.control                                  \
  target/postgresql/black_scholes_swig.make                                   
1552 target/postgresql/black_scholes_swig.c                                   
33 target/postgresql/black_scholes_swig--1.2.3.sql                            
8 target/postgresql/black_scholes_swig.control                                
13 target/postgresql/black_scholes_swig.make                                  
1606 total                                                                    
                                                                              
# Compile postgresql bindings:                                                
cc -Isrc -I$POSTGRESQL_INC_DIR -c -o target/postgresql/black_scholes_swig.c.o   \
  target/postgresql/black_scholes_swig.c                                      
                                                                              
# Link postgresql dynamic library:                                            
cc -dynamiclib -o target/postgresql/black_scholes_swig.so                       \
  target/native/black_scholes.o target/postgresql/black_scholes_swig.c.o        \
  -L/opt/homebrew/lib                                                         
                                                                              
                                                                              
# Compile and install postgresql extension:                                   
$POSTGRESQL_LIB_DIR/pgxs/src/makefiles/../../config/install-sh -c -d            \
  '$POSTGRESQL_SHARE_DIR/extension'                                           
$POSTGRESQL_LIB_DIR/pgxs/src/makefiles/../../config/install-sh -c -d            \
  '$POSTGRESQL_SHARE_DIR/extension'                                           
$POSTGRESQL_LIB_DIR/pgxs/src/makefiles/../../config/install-sh -c -d            \
  '$POSTGRESQL_LIB_DIR'                                                       
install -c -m 644 ./black_scholes_swig.control                                  \
  '$POSTGRESQL_SHARE_DIR/extension/'                                          
install -c -m 644 ./black_scholes_swig--1.2.3.sql                               \
  '$POSTGRESQL_SHARE_DIR/extension/'                                          
install -c -m 755 black_scholes_swig.so '$POSTGRESQL_LIB_DIR/'                
                                                                              
```                                                                           
                                                                              

---



# HOW-TO

## Setup

* Install rbenv + ruby-build
* rbenv install 2.7.6 (or later)
* Install JVM 11.0 (or later)
* Install Prerequisites below.
* Build local tools (if needed).

## Prerequisites

### SWIG

SWIG 4.0 or later is required.

`bin/build swig` will build and install a suitable version into from source `./local/`.

### Debian (Ubuntu 18.04+)

* Run `bin/build debian-prereq`
* Install a Python 3.10 distribution with python3.10 in $PATH.
* `python3.10 -m pip install pytest`

### OSX

* Install brew
* Run `bin/build brew-prereq`

### Local tools

This will build and install the following tools into `./local/` from source:

* swigq
* libtommath
* clojure

```Shell
bin/build local-tools
```

### Guile

Guile 3.0 is required.  `bin/build guile` will build and install into `./local/` from source, however this can take **a very long time**.

```Shell
## Build

```Shell
rbenv shell 2.7.6
bin/build clean demo
```

### PostgreSQL

Create a private database:

```
$ createdb $USER
```

# Development

## Rebuild README.md

```bash
$ rm README.md
$ bin/build README.md
```
