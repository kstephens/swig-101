# SWIG-101

Introduction to [SWIG](http://www.swig.org/).

# What is SWIG?

SWIG is a foreign-function-interface (FFI) generator for native C/C++ libraries.
SWIG vastly reduces the development cost of using native libraries within dynamic languages.

# History

* SWIG was [created](https://www.swig.org/history.html) in 1995 at Los Alamos National Laboratory.
* Still under active development.

# Benefits

SWIG:

* Parses SWIG interface definition files.
* SWIG interface defintions are a superset of C/C++.
* Many C/C++ header files can be used verbatim with minimal specification.
* Interface definitions can target multiple target languages with little additional effort.
* Generated FFI code is statically-generated, reducing runtime costs.
* FFI code can be dynamically loaded or statically linked.
* FFI code is self-contained.
* Hinting for improved integration and representation.
* Template driven, user's can write generator for multiple purposes.
* Use dynamic language to test C/C++ code.

# Native Code Support

Comprehensive support:

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

* Coders love greenfields.
* Waste of time.

## Native Language ABIs

* Every native language's ABI is entirely different.
* Some implementations of the same target language have different ABIs: e.g. JRuby and CRuby.
* Some are only dynamic with associate performance costs.
* Few languages have well-defined ABIs; Java JNI is a notable exception.
* Each ABI requires intimate knownlege of ABIs
 * rules
 * best-practices
 * manual data structure, function, class, method wrapping and registration
 * manual memory managment

## LibFFI

[Libffi](https://github.com/libffi/libffi) can invoke native C functions dynamically from a low-level function signature.

* libffi does not interpret C/C++ headers.
* C++ FFI is unsupported.
* Must specify function signatures at [runtime](http://www.chiark.greenend.org.uk/doc/libffi-dev/html/Simple-Example.html).
* Does not provide any data type serialization functionality.
* Must have knowledge of CPU, Compiler and OS calling conventions.
* Must manually layout struct and union values accordingly.

# Case Study

Kind              |  Language     |  Files  |   Lines 
------------------|:-------------:|--------:|----------:
Native C/C++      |               |         |  
                  | C/C++ Header  |      40 |    3505
SWIG Interfaces   |               |         |
                  | SWIG          |       9 |    2667
Generated Python  |               |         |
                  | Python        |       1 |    8922
                  | C++           |       1 |   35235
Generated Java    |               |         | 
                  | Java          |      55 |    6741
                  | C++           |       1 |   17987

# Examples

The examples below target:

* Python
* Clojure via Java
* Ruby
* TCL
* Guile Scheme





# Polynomial


## CC Header : src/polynomial.h

```CC
  1   #include <vector>
  2   #define POLYNOMIAL_VERSION "2.3.5"
  3   class Polynomial {
  4    public:
  5     std::vector<double> coeffs;
  6     double evaluate(double x);
  7   };

```



## CC Library : src/polynomial.cc

```CC
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



## CC Main : src/polynomial-native.cc

```CC
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


## CC SWIG Interface : src/polynomial.i

```CC
  1   %module polynomial_swig
  2   %include "std_vector.i"
  3   %template(VectorDouble) std::vector<double>;
  4   %include "polynomial.h"
  5   %{
  6   #include "polynomial.h"
  7   %}

```



## Python : src/polynomial-python

```Python
  1   #!/usr/bin/env python3.10
  2   
  3   # Setup DLL search path:
  4   #import sys
  5   #sys.path.append('target/python')
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
Traceback (most recent call last):
  File "/Users/kstephens/src/dev/swig-101/src/polynomial-python", line 8, in <module>
    from polynomial_swig import Polynomial, VectorDouble, POLYNOMIAL_VERSION
ModuleNotFoundError: No module named 'polynomial_swig'

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
 14   (println (format "POLYNOMIAL_VERSION = %s" (polynomial_swig/POLYNOMIAL_VERSION)))
 15   (prn (.getCoeffs p))
 16   (prn (.evaluate p 2.0))

```


----

```
$ src/polynomial-clojure
POLYNOMIAL_VERSION = 2.3.5
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
#<swig-pointer std::vector< double > * 7f83214040c0>
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
_904270cd8d7f0000_p_std__vectorT_double_t
-156.0

```



## Output


```
$ target/native/polynomial
-156


```



```
$ src/polynomial-python
Traceback (most recent call last):
  File "/Users/kstephens/src/dev/swig-101/src/polynomial-python", line 8, in <module>
    from polynomial_swig import Polynomial, VectorDouble, POLYNOMIAL_VERSION
ModuleNotFoundError: No module named 'polynomial_swig'


```



```
$ src/polynomial-clojure
POLYNOMIAL_VERSION = 2.3.5
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
#<swig-pointer std::vector< double > * 7fc5df604080>
-156.0


```



```
$ src/polynomial-tcl
POLYNOMIAL_VERSION = 2.3.5
_c0415074b27f0000_p_std__vectorT_double_t
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



1. Generate SWIG wrapper from interface file for target language.
2. Compile native library.
3. Compile SWIG wrapper.
4. Link native library and SWIG wrapper into a dynamic library.
5. Load dynamic library into target language.

************************************************************************
*                         
* +-------------+
* |  c/mylib.i  +---+   1. swig -python c/mylib.i \
* +-------------+   |           -o swig/mylib_swig.c
*                   |
* +-------------+   |       +----------------------+
* |  c/mylib.h  +---+------>|  swig/mylib_swig.py  +--------+
* |-------------|           |----------------------|        |
* |  c/mylib.c  |           |  swig/mylib_swig.c   |        |
* +-+-----------+           +-+--------------------+        |
*   |                         |                             |
*   |  2. cc -c c/mylib.c     | 3. cc -c swig/mylib_swig.c  |
*   v                         v                             |
* +-------------+           +----------------------+        |
* |  c/mylib.о  |           |  swig/mylib_swig.о   |        |
* +-+-----------+           +-+--------------------+        |
*   |                            |                          |
*   +----------------------------+                          |
*   |                                                       |
*   | 4. cc -dynamiclib -о swig/_mylib_swig.so \            |
*   |      c/mylib.о swig/mylib_swig.о                      |
*   v                                                       |
* +----------------------+                                  |
* |  swig/mylib_swig.sо  |                                  |
* +-+--------------------+                                  |
*   |                                                       |
*   +-------------------------------------------------------+
*   | 
*   | 5. python script.py
*   v                    
* +------------------------------+
* | script.py                    |
* |------------------------------|
* | import sys                   |
* | sys.path.append('python')    |
* | import mylib_swig as mylib   |
* | print(mylib.f(2.0, 3.0))     |
* +------------------------------+
* 
************************************************************************




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


## Build python SWIG wrapper 
``` 

# Generate python SWIG wrapper 
swig -addextern -I- -Isrc -c++ -python -outdir target/python/ -o  \
  target/python/polynomial_swig.cc src/polynomial.i 

wc -l target/python/polynomial_swig.cc target/python/polynomial_swig.py 
8408 target/python/polynomial_swig.cc 
241 target/python/polynomial_swig.py 
8649 total 

grep -siH polynomial target/python/polynomial_swig.cc  \
  target/python/polynomial_swig.py 
target/python/polynomial_swig.cc:#define SWIGTYPE_p_Polynomial swig_types[0] 
target/python/polynomial_swig.cc: @(target):= _polynomial_swig.so 
target/python/polynomial_swig.cc:# define SWIG_init PyInit__polynomial_swig 
target/python/polynomial_swig.cc:# define SWIG_init init_polynomial_swig 
target/python/polynomial_swig.cc:#define SWIG_name "_polynomial_swig" 
target/python/polynomial_swig.cc:#include "polynomial.h" 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *_wrap_Polynomial_coeffs_set(PyObject *self, PyObject *args) { 
target/python/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/python/polynomial_swig.cc: if (!SWIG_Python_UnpackTuple(args,  \
  "Polynomial_coeffs_set", 2, 2, swig_obj)) SWIG_fail; 
target/python/polynomial_swig.cc: res1 = SWIG_ConvertPtr(swig_obj[0],  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/python/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "Polynomial_coeffs_set" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/python/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/python/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res2), "in  \
  method '" "Polynomial_coeffs_set" "', argument " "2"" of type '" "std::vector<  \
  double,std::allocator< double > > *""'"); 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *_wrap_Polynomial_coeffs_get(PyObject *self, PyObject *args) { 
target/python/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/python/polynomial_swig.cc: res1 = SWIG_ConvertPtr(swig_obj[0],  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/python/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "Polynomial_coeffs_get" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/python/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *_wrap_Polynomial_evaluate(PyObject *self, PyObject *args) { 
target/python/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/python/polynomial_swig.cc: if (!SWIG_Python_UnpackTuple(args,  \
  "Polynomial_evaluate", 2, 2, swig_obj)) SWIG_fail; 
target/python/polynomial_swig.cc: res1 = SWIG_ConvertPtr(swig_obj[0],  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/python/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "Polynomial_evaluate" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/python/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/python/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(ecode2),  \
  "in method '" "Polynomial_evaluate" "', argument " "2"" of type '"  \
  "double""'"); 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *_wrap_new_Polynomial(PyObject *self, PyObject *args) { 
target/python/polynomial_swig.cc: Polynomial *result = 0 ; 
target/python/polynomial_swig.cc: if (!SWIG_Python_UnpackTuple(args,  \
  "new_Polynomial", 0, 0, 0)) SWIG_fail; 
target/python/polynomial_swig.cc: result = (Polynomial *)new Polynomial(); 
target/python/polynomial_swig.cc: resultobj =  \
  SWIG_NewPointerObj(SWIG_as_voidptr(result), SWIGTYPE_p_Polynomial,  \
  SWIG_POINTER_NEW | 0 ); 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *_wrap_delete_Polynomial(PyObject *self, PyObject *args) { 
target/python/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/python/polynomial_swig.cc: res1 = SWIG_ConvertPtr(swig_obj[0],  \
  &argp1,SWIGTYPE_p_Polynomial, SWIG_POINTER_DISOWN | 0 ); 
target/python/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "delete_Polynomial" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/python/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *Polynomial_swigregister(PyObject *SWIGUNUSEDPARM(self), PyObject *args) { 
target/python/polynomial_swig.cc:  \
  SWIG_TypeNewClientData(SWIGTYPE_p_Polynomial, SWIG_NewClientData(obj)); 
target/python/polynomial_swig.cc:SWIGINTERN PyObject  \
  *Polynomial_swiginit(PyObject *SWIGUNUSEDPARM(self), PyObject *args) { 
target/python/polynomial_swig.cc: { "Polynomial_coeffs_set",  \
  _wrap_Polynomial_coeffs_set, METH_VARARGS, NULL}, 
target/python/polynomial_swig.cc: { "Polynomial_coeffs_get",  \
  _wrap_Polynomial_coeffs_get, METH_O, NULL}, 
target/python/polynomial_swig.cc: { "Polynomial_evaluate",  \
  _wrap_Polynomial_evaluate, METH_VARARGS, NULL}, 
target/python/polynomial_swig.cc: { "new_Polynomial", _wrap_new_Polynomial,  \
  METH_NOARGS, NULL}, 
target/python/polynomial_swig.cc: { "delete_Polynomial",  \
  _wrap_delete_Polynomial, METH_O, NULL}, 
target/python/polynomial_swig.cc: { "Polynomial_swigregister",  \
  Polynomial_swigregister, METH_O, NULL}, 
target/python/polynomial_swig.cc: { "Polynomial_swiginit",  \
  Polynomial_swiginit, METH_VARARGS, NULL}, 
target/python/polynomial_swig.cc:static swig_type_info _swigt__p_Polynomial =  \
  {"_p_Polynomial", "Polynomial *", 0, 0, (void*)0, 0}; 
target/python/polynomial_swig.cc: &_swigt__p_Polynomial, 
target/python/polynomial_swig.cc:static swig_cast_info _swigc__p_Polynomial[]  \
  = { {&_swigt__p_Polynomial, 0, 0, 0},{0, 0, 0, 0}}; 
target/python/polynomial_swig.cc: _swigc__p_Polynomial, 
target/python/polynomial_swig.cc: SWIG_Python_SetConstant(d,  \
  "POLYNOMIAL_VERSION",SWIG_FromCharPtr("2.3.5")); 
target/python/polynomial_swig.py: from . import _polynomial_swig 
target/python/polynomial_swig.py: import _polynomial_swig 
target/python/polynomial_swig.py: __swig_destroy__ =  \
  _polynomial_swig.delete_SwigPyIterator 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_value(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_incr(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_decr(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_distance(self, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_equal(self, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_copy(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_next(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___next__(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_previous(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator_advance(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___eq__(self, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___ne__(self, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___iadd__(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___isub__(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___add__(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.SwigPyIterator___sub__(self, *args) 
target/python/polynomial_swig.py:# Register SwigPyIterator in  \
  _polynomial_swig: 
 \
  target/python/polynomial_swig.py:_polynomial_swig.SwigPyIterator_swigregister(SwigPyIterator) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_iterator(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___nonzero__(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___bool__(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___len__(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___getslice__(self, i, j) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___setslice__(self, *args) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___delslice__(self, i, j) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___delitem__(self, *args) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___getitem__(self, *args) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble___setitem__(self, *args) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_pop(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_append(self, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_empty(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_size(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_swap(self, v) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_begin(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_end(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_rbegin(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_rend(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_clear(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_get_allocator(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_pop_back(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_erase(self, *args) 
target/python/polynomial_swig.py: _polynomial_swig.VectorDouble_swiginit(self,  \
  _polynomial_swig.new_VectorDouble(*args)) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_push_back(self, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_front(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_back(self) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_assign(self, n, x) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_resize(self, *args) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_insert(self, *args) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_reserve(self, n) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.VectorDouble_capacity(self) 
target/python/polynomial_swig.py: __swig_destroy__ =  \
  _polynomial_swig.delete_VectorDouble 
target/python/polynomial_swig.py:# Register VectorDouble in _polynomial_swig: 
 \
  target/python/polynomial_swig.py:_polynomial_swig.VectorDouble_swigregister(VectorDouble) 
target/python/polynomial_swig.py:POLYNOMIAL_VERSION =  \
  _polynomial_swig.POLYNOMIAL_VERSION 
target/python/polynomial_swig.py:class Polynomial(object): 
target/python/polynomial_swig.py: coeffs =  \
  property(_polynomial_swig.Polynomial_coeffs_get,  \
  _polynomial_swig.Polynomial_coeffs_set) 
target/python/polynomial_swig.py: return  \
  _polynomial_swig.Polynomial_evaluate(self, x) 
target/python/polynomial_swig.py: _polynomial_swig.Polynomial_swiginit(self,  \
  _polynomial_swig.new_Polynomial()) 
target/python/polynomial_swig.py: __swig_destroy__ =  \
  _polynomial_swig.delete_Polynomial 
target/python/polynomial_swig.py:# Register Polynomial in _polynomial_swig: 
 \
  target/python/polynomial_swig.py:_polynomial_swig.Polynomial_swigregister(Polynomial) 

# Compile python SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$PYTHON_HOME/include/python3.10 -I$PYTHON_HOME/include/python3.10  \
  -Wno-unused-result -Wsign-compare -Wunreachable-code -fno-common -dynamic  \
  -DNDEBUG -g -fwrapv -O3 -Wall -pipe -Os -Wno-deprecated-declarations -c -o  \
  target/python/polynomial_swig.cc.o target/python/polynomial_swig.cc 

# Link python SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/python//_polynomial_swig.so  \
  target/native/polynomial.o target/python/polynomial_swig.cc.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 
``` 


## Build java SWIG wrapper 
``` 

# Generate java SWIG wrapper 
swig -addextern -I- -Isrc -c++ -java -outdir target/java/ -o  \
  target/java/polynomial_swig.cc src/polynomial.i 

wc -l target/java/polynomial_swig.cc target/java/polynomial*.java 
660 target/java/polynomial_swig.cc 
11 target/java/polynomial_swig.java 
12 target/java/polynomial_swigConstants.java 
32 target/java/polynomial_swigJNI.java 
715 total 

grep -siH polynomial target/java/polynomial_swig.cc  \
  target/java/polynomial*.java 
target/java/polynomial_swig.cc:#include "polynomial.h" 
target/java/polynomial_swig.cc:SWIGEXPORT jlong JNICALL  \
  Java_polynomial_1swigJNI_new_1VectorDouble_1_1SWIG_10(JNIEnv *jenv, jclass  \
  jcls) { 
target/java/polynomial_swig.cc:SWIGEXPORT jlong JNICALL  \
  Java_polynomial_1swigJNI_new_1VectorDouble_1_1SWIG_11(JNIEnv *jenv, jclass  \
  jcls, jlong jarg1, jobject jarg1_) { 
target/java/polynomial_swig.cc:SWIGEXPORT jlong JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1capacity(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1reserve(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_, jlong jarg2) { 
target/java/polynomial_swig.cc:SWIGEXPORT jboolean JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1isEmpty(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1clear(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_) { 
target/java/polynomial_swig.cc:SWIGEXPORT jlong JNICALL  \
  Java_polynomial_1swigJNI_new_1VectorDouble_1_1SWIG_12(JNIEnv *jenv, jclass  \
  jcls, jint jarg1, jdouble jarg2) { 
target/java/polynomial_swig.cc:SWIGEXPORT jint JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doSize(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doAdd_1_1SWIG_10(JNIEnv *jenv, jclass  \
  jcls, jlong jarg1, jobject jarg1_, jdouble jarg2) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doAdd_1_1SWIG_11(JNIEnv *jenv, jclass  \
  jcls, jlong jarg1, jobject jarg1_, jint jarg2, jdouble jarg3) { 
target/java/polynomial_swig.cc:SWIGEXPORT jdouble JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doRemove(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_, jint jarg2) { 
target/java/polynomial_swig.cc:SWIGEXPORT jdouble JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doGet(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_, jint jarg2) { 
target/java/polynomial_swig.cc:SWIGEXPORT jdouble JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doSet(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_, jint jarg2, jdouble jarg3) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_VectorDouble_1doRemoveRange(JNIEnv *jenv, jclass  \
  jcls, jlong jarg1, jobject jarg1_, jint jarg2, jint jarg3) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_delete_1VectorDouble(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1) { 
target/java/polynomial_swig.cc:SWIGEXPORT jstring JNICALL  \
  Java_polynomial_1swigJNI_POLYNOMIAL_1VERSION_1get(JNIEnv *jenv, jclass jcls) { 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_Polynomial_1coeffs_1set(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_, jlong jarg2, jobject jarg2_) { 
target/java/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/java/polynomial_swig.cc: arg1 = *(Polynomial **)&jarg1; 
target/java/polynomial_swig.cc:SWIGEXPORT jlong JNICALL  \
  Java_polynomial_1swigJNI_Polynomial_1coeffs_1get(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_) { 
target/java/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/java/polynomial_swig.cc: arg1 = *(Polynomial **)&jarg1; 
target/java/polynomial_swig.cc:SWIGEXPORT jdouble JNICALL  \
  Java_polynomial_1swigJNI_Polynomial_1evaluate(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_, jdouble jarg2) { 
target/java/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/java/polynomial_swig.cc: arg1 = *(Polynomial **)&jarg1; 
target/java/polynomial_swig.cc:SWIGEXPORT jlong JNICALL  \
  Java_polynomial_1swigJNI_new_1Polynomial(JNIEnv *jenv, jclass jcls) { 
target/java/polynomial_swig.cc: Polynomial *result = 0 ; 
target/java/polynomial_swig.cc: result = (Polynomial *)new Polynomial(); 
target/java/polynomial_swig.cc: *(Polynomial **)&jresult = result; 
target/java/polynomial_swig.cc:SWIGEXPORT void JNICALL  \
  Java_polynomial_1swigJNI_delete_1Polynomial(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1) { 
target/java/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/java/polynomial_swig.cc: arg1 = *(Polynomial **)&jarg1; 
target/java/polynomial_swig.java:public class polynomial_swig implements  \
  polynomial_swigConstants { 
target/java/polynomial_swigConstants.java:public interface  \
  polynomial_swigConstants { 
target/java/polynomial_swigConstants.java: public final static String  \
  POLYNOMIAL_VERSION = polynomial_swigJNI.POLYNOMIAL_VERSION_get(); 
target/java/polynomial_swigJNI.java:public class polynomial_swigJNI { 
target/java/polynomial_swigJNI.java: public final static native String  \
  POLYNOMIAL_VERSION_get(); 
target/java/polynomial_swigJNI.java: public final static native void  \
  Polynomial_coeffs_set(long jarg1, Polynomial jarg1_, long jarg2, VectorDouble  \
  jarg2_); 
target/java/polynomial_swigJNI.java: public final static native long  \
  Polynomial_coeffs_get(long jarg1, Polynomial jarg1_); 
target/java/polynomial_swigJNI.java: public final static native double  \
  Polynomial_evaluate(long jarg1, Polynomial jarg1_, double jarg2); 
target/java/polynomial_swigJNI.java: public final static native long  \
  new_Polynomial(); 
target/java/polynomial_swigJNI.java: public final static native void  \
  delete_Polynomial(long jarg1); 

# Compile java SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -I$JAVA_HOME/include/darwin -c  \
  -o target/java/polynomial_swig.cc.o target/java/polynomial_swig.cc 

# Link java SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/java//libpolynomial_swig.jnilib  \
  target/native/polynomial.o target/java/polynomial_swig.cc.o 
``` 


## Build ruby SWIG wrapper 
``` 

# Generate ruby SWIG wrapper 
swig -addextern -I- -Isrc -c++ -ruby -outdir target/ruby/ -o  \
  target/ruby/polynomial_swig.cc src/polynomial.i 

wc -l target/ruby/polynomial_swig.cc 
8528 target/ruby/polynomial_swig.cc 

grep -siH polynomial target/ruby/polynomial_swig.cc 
target/ruby/polynomial_swig.cc:#define SWIGTYPE_p_Polynomial swig_types[0] 
target/ruby/polynomial_swig.cc:#define SWIG_init Init_polynomial_swig 
target/ruby/polynomial_swig.cc:#define SWIG_name "Polynomial_swig" 
target/ruby/polynomial_swig.cc:static VALUE mPolynomial_swig; 
target/ruby/polynomial_swig.cc:#include "polynomial.h" 
target/ruby/polynomial_swig.cc:static swig_class SwigClassPolynomial; 
target/ruby/polynomial_swig.cc:_wrap_Polynomial_coeffs_set(int argc, VALUE  \
  *argv, VALUE self) { 
target/ruby/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/ruby/polynomial_swig.cc: res1 = SWIG_ConvertPtr(self,  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/ruby/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1),  \
  Ruby_Format_TypeError( "", "Polynomial *","coeffs", 1, self )); 
target/ruby/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/ruby/polynomial_swig.cc:_wrap_Polynomial_coeffs_get(int argc, VALUE  \
  *argv, VALUE self) { 
target/ruby/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/ruby/polynomial_swig.cc: res1 = SWIG_ConvertPtr(self,  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/ruby/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1),  \
  Ruby_Format_TypeError( "", "Polynomial *","coeffs", 1, self )); 
target/ruby/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/ruby/polynomial_swig.cc:_wrap_Polynomial_evaluate(int argc, VALUE  \
  *argv, VALUE self) { 
target/ruby/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/ruby/polynomial_swig.cc: res1 = SWIG_ConvertPtr(self,  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/ruby/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1),  \
  Ruby_Format_TypeError( "", "Polynomial *","evaluate", 1, self )); 
target/ruby/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial *  \
  >(argp1); 
target/ruby/polynomial_swig.cc:_wrap_Polynomial_allocate(VALUE self) 
target/ruby/polynomial_swig.cc:_wrap_Polynomial_allocate(int argc, VALUE  \
  *argv, VALUE self) 
target/ruby/polynomial_swig.cc: VALUE vresult = SWIG_NewClassInstance(self,  \
  SWIGTYPE_p_Polynomial); 
target/ruby/polynomial_swig.cc:_wrap_new_Polynomial(int argc, VALUE *argv,  \
  VALUE self) { 
target/ruby/polynomial_swig.cc: Polynomial *result = 0 ; 
target/ruby/polynomial_swig.cc: result = (Polynomial *)new Polynomial(); 
target/ruby/polynomial_swig.cc:free_Polynomial(void *self) { 
target/ruby/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *)self; 
target/ruby/polynomial_swig.cc:static swig_type_info _swigt__p_Polynomial =  \
  {"_p_Polynomial", "Polynomial *", 0, 0, (void*)0, 0}; 
target/ruby/polynomial_swig.cc: &_swigt__p_Polynomial, 
target/ruby/polynomial_swig.cc:static swig_cast_info _swigc__p_Polynomial[] =  \
  { {&_swigt__p_Polynomial, 0, 0, 0},{0, 0, 0, 0}}; 
target/ruby/polynomial_swig.cc: _swigc__p_Polynomial, 
target/ruby/polynomial_swig.cc:SWIGEXPORT void Init_polynomial_swig(void) { 
target/ruby/polynomial_swig.cc: mPolynomial_swig =  \
  rb_define_module("Polynomial_swig"); 
target/ruby/polynomial_swig.cc: SwigClassGC_VALUE.klass =  \
  rb_define_class_under(mPolynomial_swig, "GC_VALUE", rb_cObject); 
target/ruby/polynomial_swig.cc: SwigClassConstIterator.klass =  \
  rb_define_class_under(mPolynomial_swig, "ConstIterator", rb_cObject); 
target/ruby/polynomial_swig.cc: SwigClassIterator.klass =  \
  rb_define_class_under(mPolynomial_swig, "Iterator", ((swig_class *)  \
  SWIGTYPE_p_swig__ConstIterator->clientdata)->klass); 
target/ruby/polynomial_swig.cc: SwigClassVectorDouble.klass =  \
  rb_define_class_under(mPolynomial_swig, "VectorDouble", rb_cObject); 
target/ruby/polynomial_swig.cc: rb_define_const(mPolynomial_swig,  \
  "POLYNOMIAL_VERSION", SWIG_FromCharPtr("2.3.5")); 
target/ruby/polynomial_swig.cc: SwigClassPolynomial.klass =  \
  rb_define_class_under(mPolynomial_swig, "Polynomial", rb_cObject); 
target/ruby/polynomial_swig.cc: SWIG_TypeClientData(SWIGTYPE_p_Polynomial,  \
  (void *) &SwigClassPolynomial); 
target/ruby/polynomial_swig.cc:  \
  rb_define_alloc_func(SwigClassPolynomial.klass, _wrap_Polynomial_allocate); 
target/ruby/polynomial_swig.cc: rb_define_method(SwigClassPolynomial.klass,  \
  "initialize", VALUEFUNC(_wrap_new_Polynomial), -1); 
target/ruby/polynomial_swig.cc: rb_define_method(SwigClassPolynomial.klass,  \
  "coeffs=", VALUEFUNC(_wrap_Polynomial_coeffs_set), -1); 
target/ruby/polynomial_swig.cc: rb_define_method(SwigClassPolynomial.klass,  \
  "coeffs", VALUEFUNC(_wrap_Polynomial_coeffs_get), -1); 
target/ruby/polynomial_swig.cc: rb_define_method(SwigClassPolynomial.klass,  \
  "evaluate", VALUEFUNC(_wrap_Polynomial_evaluate), -1); 
target/ruby/polynomial_swig.cc: SwigClassPolynomial.mark = 0; 
target/ruby/polynomial_swig.cc: SwigClassPolynomial.destroy = (void (*)(void  \
  *)) free_Polynomial; 
target/ruby/polynomial_swig.cc: SwigClassPolynomial.trackObjects = 0; 

# Compile ruby SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o  \
  target/ruby/polynomial_swig.cc.o target/ruby/polynomial_swig.cc 

# Link ruby SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/ruby//polynomial_swig.bundle  \
  target/native/polynomial.o target/ruby/polynomial_swig.cc.o 
``` 


## Build tcl SWIG wrapper 
``` 

# Generate tcl SWIG wrapper 
swig -addextern -I- -Isrc -c++ -tcl -outdir target/tcl/ -o  \
  target/tcl/polynomial_swig.cc src/polynomial.i 

wc -l target/tcl/polynomial_swig.cc 
2951 target/tcl/polynomial_swig.cc 

grep -siH polynomial target/tcl/polynomial_swig.cc 
target/tcl/polynomial_swig.cc:#define SWIGTYPE_p_Polynomial swig_types[0] 
target/tcl/polynomial_swig.cc:#define SWIG_init Polynomial_swig_Init 
target/tcl/polynomial_swig.cc:#define SWIG_name "polynomial_swig" 
target/tcl/polynomial_swig.cc:#include "polynomial.h" 
target/tcl/polynomial_swig.cc:_wrap_Polynomial_coeffs_set(ClientData  \
  clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) { 
target/tcl/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/tcl/polynomial_swig.cc: if (SWIG_GetArgs(interp, objc,  \
  objv,"oo:Polynomial_coeffs_set self coeffs ",(void *)0,(void *)0) ==  \
  TCL_ERROR) SWIG_fail; 
target/tcl/polynomial_swig.cc: res1 = SWIG_ConvertPtr(objv[1],  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/tcl/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "Polynomial_coeffs_set" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/tcl/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial * >(argp1); 
target/tcl/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res2), "in  \
  method '" "Polynomial_coeffs_set" "', argument " "2"" of type '" "std::vector<  \
  double > *""'"); 
target/tcl/polynomial_swig.cc:_wrap_Polynomial_coeffs_get(ClientData  \
  clientData SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) { 
target/tcl/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/tcl/polynomial_swig.cc: if (SWIG_GetArgs(interp, objc,  \
  objv,"o:Polynomial_coeffs_get self ",(void *)0) == TCL_ERROR) SWIG_fail; 
target/tcl/polynomial_swig.cc: res1 = SWIG_ConvertPtr(objv[1],  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/tcl/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "Polynomial_coeffs_get" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/tcl/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial * >(argp1); 
target/tcl/polynomial_swig.cc:_wrap_Polynomial_evaluate(ClientData clientData  \
  SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) { 
target/tcl/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/tcl/polynomial_swig.cc: if (SWIG_GetArgs(interp, objc,  \
  objv,"oo:Polynomial_evaluate self x ",(void *)0,(void *)0) == TCL_ERROR)  \
  SWIG_fail; 
target/tcl/polynomial_swig.cc: res1 = SWIG_ConvertPtr(objv[1],  \
  &argp1,SWIGTYPE_p_Polynomial, 0 | 0 ); 
target/tcl/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "Polynomial_evaluate" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/tcl/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial * >(argp1); 
target/tcl/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(ecode2), "in  \
  method '" "Polynomial_evaluate" "', argument " "2"" of type '" "double""'"); 
target/tcl/polynomial_swig.cc:_wrap_new_Polynomial(ClientData clientData  \
  SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) { 
target/tcl/polynomial_swig.cc: Polynomial *result = 0 ; 
target/tcl/polynomial_swig.cc: if (SWIG_GetArgs(interp, objc,  \
  objv,":new_Polynomial ") == TCL_ERROR) SWIG_fail; 
target/tcl/polynomial_swig.cc: result = (Polynomial *)new Polynomial(); 
target/tcl/polynomial_swig.cc: Tcl_SetObjResult(interp, SWIG_NewInstanceObj(  \
  SWIG_as_voidptr(result), SWIGTYPE_p_Polynomial,0)); 
target/tcl/polynomial_swig.cc:_wrap_delete_Polynomial(ClientData clientData  \
  SWIGUNUSED, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) { 
target/tcl/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/tcl/polynomial_swig.cc: if (SWIG_GetArgs(interp, objc,  \
  objv,"o:delete_Polynomial self ",(void *)0) == TCL_ERROR) SWIG_fail; 
target/tcl/polynomial_swig.cc: res1 = SWIG_ConvertPtr(objv[1],  \
  &argp1,SWIGTYPE_p_Polynomial, SWIG_POINTER_DISOWN | 0 ); 
target/tcl/polynomial_swig.cc: SWIG_exception_fail(SWIG_ArgError(res1), "in  \
  method '" "delete_Polynomial" "', argument " "1"" of type '" "Polynomial  \
  *""'"); 
target/tcl/polynomial_swig.cc: arg1 = reinterpret_cast< Polynomial * >(argp1); 
target/tcl/polynomial_swig.cc:SWIGINTERN void swig_delete_Polynomial(void  \
  *obj) { 
target/tcl/polynomial_swig.cc:Polynomial *arg1 = (Polynomial *) obj; 
target/tcl/polynomial_swig.cc:static swig_method swig_Polynomial_methods[] = { 
target/tcl/polynomial_swig.cc: {"evaluate", _wrap_Polynomial_evaluate}, 
target/tcl/polynomial_swig.cc:static swig_attribute  \
  swig_Polynomial_attributes[] = { 
target/tcl/polynomial_swig.cc: { "-coeffs",_wrap_Polynomial_coeffs_get,  \
  _wrap_Polynomial_coeffs_set}, 
target/tcl/polynomial_swig.cc:static swig_class *swig_Polynomial_bases[] =  \
  {0}; 
target/tcl/polynomial_swig.cc:static const char * swig_Polynomial_base_names[]  \
  = {0}; 
target/tcl/polynomial_swig.cc:static swig_class _wrap_class_Polynomial = {  \
  "Polynomial", &SWIGTYPE_p_Polynomial,_wrap_new_Polynomial,  \
  swig_delete_Polynomial, swig_Polynomial_methods, swig_Polynomial_attributes,  \
  swig_Polynomial_bases,swig_Polynomial_base_names, &swig_module,  \
  SWIG_TCL_HASHTABLE_INIT }; 
target/tcl/polynomial_swig.cc: { SWIG_prefix "Polynomial_coeffs_set",  \
  (swig_wrapper_func) _wrap_Polynomial_coeffs_set, NULL}, 
target/tcl/polynomial_swig.cc: { SWIG_prefix "Polynomial_coeffs_get",  \
  (swig_wrapper_func) _wrap_Polynomial_coeffs_get, NULL}, 
target/tcl/polynomial_swig.cc: { SWIG_prefix "Polynomial_evaluate",  \
  (swig_wrapper_func) _wrap_Polynomial_evaluate, NULL}, 
target/tcl/polynomial_swig.cc: { SWIG_prefix "new_Polynomial",  \
  (swig_wrapper_func) _wrap_new_Polynomial, NULL}, 
target/tcl/polynomial_swig.cc: { SWIG_prefix "delete_Polynomial",  \
  (swig_wrapper_func) _wrap_delete_Polynomial, NULL}, 
target/tcl/polynomial_swig.cc: { SWIG_prefix "Polynomial", (swig_wrapper_func)  \
  SWIG_ObjectConstructor, (ClientData)&_wrap_class_Polynomial}, 
target/tcl/polynomial_swig.cc:static swig_type_info _swigt__p_Polynomial =  \
  {"_p_Polynomial", "Polynomial *", 0, 0, (void*)&_wrap_class_Polynomial, 0}; 
target/tcl/polynomial_swig.cc: &_swigt__p_Polynomial, 
target/tcl/polynomial_swig.cc:static swig_cast_info _swigc__p_Polynomial[] = {  \
  {&_swigt__p_Polynomial, 0, 0, 0},{0, 0, 0, 0}}; 
target/tcl/polynomial_swig.cc: _swigc__p_Polynomial, 
target/tcl/polynomial_swig.cc: SWIG_Tcl_SetConstantObj(interp,  \
  "POLYNOMIAL_VERSION", SWIG_FromCharPtr("2.3.5")); 
target/tcl/polynomial_swig.cc:SWIGEXPORT int  \
  Polynomial_swig_SafeInit(Tcl_Interp *interp) { 

# Compile tcl SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I/usr/include/tcl -c -o target/tcl/polynomial_swig.cc.o  \
  target/tcl/polynomial_swig.cc 

# Link tcl SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/tcl//polynomial_swig.so  \
  target/native/polynomial.o target/tcl/polynomial_swig.cc.o 
``` 


## Build guile SWIG wrapper 
``` 

# Generate guile SWIG wrapper 
swig -addextern -I- -Isrc -guile -c++ -guile -outdir target/guile/ -o  \
  target/guile/polynomial_swig.cc src/polynomial.i 

wc -l target/guile/polynomial_swig.cc 
2267 target/guile/polynomial_swig.cc 

grep -siH polynomial target/guile/polynomial_swig.cc 
target/guile/polynomial_swig.cc:static swig_guile_clientdata  \
  _swig_guile_clientdataPolynomial = { NULL, SCM_EOL }; 
target/guile/polynomial_swig.cc:#define SWIGTYPE_p_Polynomial swig_types[0] 
target/guile/polynomial_swig.cc:static char const  \
  *gswig_const_POLYNOMIAL_VERSION = (char const *)("2.3.5"); 
target/guile/polynomial_swig.cc:#include "polynomial.h" 
target/guile/polynomial_swig.cc:_wrap_POLYNOMIAL_VERSION(SCM s_0) 
target/guile/polynomial_swig.cc:#define FUNC_NAME "POLYNOMIAL-VERSION" 
target/guile/polynomial_swig.cc: gswig_result =  \
  SWIG_str02scm(gswig_const_POLYNOMIAL_VERSION); 
target/guile/polynomial_swig.cc:_wrap_Polynomial_coeffs_set (SCM s_0, SCM s_1) 
target/guile/polynomial_swig.cc:#define FUNC_NAME "Polynomial-coeffs-set" 
target/guile/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/guile/polynomial_swig.cc: arg1 = (Polynomial *)SWIG_MustGetPtr(s_0,  \
  SWIGTYPE_p_Polynomial, 1, 0); 
target/guile/polynomial_swig.cc:_wrap_Polynomial_coeffs_get (SCM s_0) 
target/guile/polynomial_swig.cc:#define FUNC_NAME "Polynomial-coeffs-get" 
target/guile/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/guile/polynomial_swig.cc: arg1 = (Polynomial *)SWIG_MustGetPtr(s_0,  \
  SWIGTYPE_p_Polynomial, 1, 0); 
target/guile/polynomial_swig.cc:_wrap_Polynomial_evaluate (SCM s_0, SCM s_1) 
target/guile/polynomial_swig.cc:#define FUNC_NAME "Polynomial-evaluate" 
target/guile/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/guile/polynomial_swig.cc: arg1 = (Polynomial *)SWIG_MustGetPtr(s_0,  \
  SWIGTYPE_p_Polynomial, 1, 0); 
target/guile/polynomial_swig.cc:_wrap_new_Polynomial () 
target/guile/polynomial_swig.cc:#define FUNC_NAME "new-Polynomial" 
target/guile/polynomial_swig.cc: Polynomial *result = 0 ; 
target/guile/polynomial_swig.cc: result = (Polynomial *)new Polynomial(); 
target/guile/polynomial_swig.cc: gswig_result = SWIG_NewPointerObj (result,  \
  SWIGTYPE_p_Polynomial, 1); 
target/guile/polynomial_swig.cc:_wrap_delete_Polynomial (SCM s_0) 
target/guile/polynomial_swig.cc:#define FUNC_NAME "delete-Polynomial" 
target/guile/polynomial_swig.cc: Polynomial *arg1 = (Polynomial *) 0 ; 
target/guile/polynomial_swig.cc: arg1 = (Polynomial *)SWIG_MustGetPtr(s_0,  \
  SWIGTYPE_p_Polynomial, 1, 0); 
target/guile/polynomial_swig.cc:static swig_type_info _swigt__p_Polynomial =  \
  {"_p_Polynomial", "Polynomial *", 0, 0, (void*)0, 0}; 
target/guile/polynomial_swig.cc: &_swigt__p_Polynomial, 
target/guile/polynomial_swig.cc:static swig_cast_info _swigc__p_Polynomial[] =  \
  { {&_swigt__p_Polynomial, 0, 0, 0},{0, 0, 0, 0}}; 
target/guile/polynomial_swig.cc: _swigc__p_Polynomial, 
target/guile/polynomial_swig.cc: scm_c_define_gsubr("POLYNOMIAL-VERSION", 0,  \
  0, 0, (swig_guile_proc) _wrap_POLYNOMIAL_VERSION); 
target/guile/polynomial_swig.cc: SWIG_TypeClientData(SWIGTYPE_p_Polynomial,  \
  (void *) &_swig_guile_clientdataPolynomial); 
target/guile/polynomial_swig.cc: scm_c_define_gsubr("Polynomial-coeffs-set",  \
  2, 0, 0, (swig_guile_proc) _wrap_Polynomial_coeffs_set); 
target/guile/polynomial_swig.cc: scm_c_define_gsubr("Polynomial-coeffs-get",  \
  1, 0, 0, (swig_guile_proc) _wrap_Polynomial_coeffs_get); 
target/guile/polynomial_swig.cc: scm_c_define_gsubr("Polynomial-evaluate", 2,  \
  0, 0, (swig_guile_proc) _wrap_Polynomial_evaluate); 
target/guile/polynomial_swig.cc: scm_c_define_gsubr("new-Polynomial", 0, 0, 0,  \
  (swig_guile_proc) _wrap_new_Polynomial); 
target/guile/polynomial_swig.cc: ((swig_guile_clientdata  \
  *)(SWIGTYPE_p_Polynomial->clientdata))->destroy = (guile_destructor)  \
  _wrap_delete_Polynomial; 
target/guile/polynomial_swig.cc: scm_c_define_gsubr("delete-Polynomial", 1, 0,  \
  0, (swig_guile_proc) _wrap_delete_Polynomial); 

# Compile guile SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -D_THREAD_SAFE -c -o target/guile/polynomial_swig.cc.o  \
  target/guile/polynomial_swig.cc 

# Link guile SWIG wrapper dynamic library: 
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


## Build python SWIG wrapper 
``` 

# Generate python SWIG wrapper 
swig -addextern -I- -Isrc -python -outdir target/python/ -o  \
  target/python/example1_swig.c src/example1.i 

wc -l target/python/example1_swig.c target/python/example1_swig.py 
3650 target/python/example1_swig.c 
65 target/python/example1_swig.py 
3715 total 

grep -siH example1 target/python/example1_swig.c  \
  target/python/example1_swig.py 
target/python/example1_swig.c: @(target):= _example1_swig.so 
target/python/example1_swig.c:# define SWIG_init PyInit__example1_swig 
target/python/example1_swig.c:# define SWIG_init init_example1_swig 
target/python/example1_swig.c:#define SWIG_name "_example1_swig" 
target/python/example1_swig.c:#include "example1.h" 
target/python/example1_swig.c: SWIG_Python_SetConstant(d,  \
  "EXAMPLE1_VERSION",SWIG_FromCharPtr("1.2.3")); 
target/python/example1_swig.py: from . import _example1_swig 
target/python/example1_swig.py: import _example1_swig 
target/python/example1_swig.py:EXAMPLE1_VERSION =  \
  _example1_swig.EXAMPLE1_VERSION 
target/python/example1_swig.py: return _example1_swig.cubic_poly(x, c0, c1,  \
  c2, c3) 

# Compile python SWIG wrapper: 
clang -g -Isrc -I$PYTHON_HOME/include/python3.10  \
  -I$PYTHON_HOME/include/python3.10 -Wno-unused-result -Wsign-compare  \
  -Wunreachable-code -fno-common -dynamic -DNDEBUG -g -fwrapv -O3 -Wall -pipe  \
  -Os -Wno-deprecated-declarations -c -o target/python/example1_swig.c.o  \
  target/python/example1_swig.c 

# Link python SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/python//_example1_swig.so target/native/example1.o  \
  target/python/example1_swig.c.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 
``` 


## Build java SWIG wrapper 
``` 

# Generate java SWIG wrapper 
swig -addextern -I- -Isrc -java -outdir target/java/ -o  \
  target/java/example1_swig.c src/example1.i 

wc -l target/java/example1_swig.c target/java/example1*.java 
243 target/java/example1_swig.c 
15 target/java/example1_swig.java 
12 target/java/example1_swigConstants.java 
13 target/java/example1_swigJNI.java 
283 total 

grep -siH example1 target/java/example1_swig.c target/java/example1*.java 
target/java/example1_swig.c:#include "example1.h" 
target/java/example1_swig.c:SWIGEXPORT jstring JNICALL  \
  Java_example1_1swigJNI_EXAMPLE1_1VERSION_1get(JNIEnv *jenv, jclass jcls) { 
target/java/example1_swig.c:SWIGEXPORT jdouble JNICALL  \
  Java_example1_1swigJNI_cubic_1poly(JNIEnv *jenv, jclass jcls, jdouble jarg1,  \
  jdouble jarg2, jdouble jarg3, jdouble jarg4, jdouble jarg5) { 
target/java/example1_swig.java:public class example1_swig implements  \
  example1_swigConstants { 
target/java/example1_swig.java: return example1_swigJNI.cubic_poly(x, c0, c1,  \
  c2, c3); 
target/java/example1_swigConstants.java:public interface  \
  example1_swigConstants { 
target/java/example1_swigConstants.java: public final static String  \
  EXAMPLE1_VERSION = example1_swigJNI.EXAMPLE1_VERSION_get(); 
target/java/example1_swigJNI.java:public class example1_swigJNI { 
target/java/example1_swigJNI.java: public final static native String  \
  EXAMPLE1_VERSION_get(); 

# Compile java SWIG wrapper: 
clang -g -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/linux  \
  -I$JAVA_HOME/include/darwin -c -o target/java/example1_swig.c.o  \
  target/java/example1_swig.c 

# Link java SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/java//libexample1_swig.jnilib target/native/example1.o  \
  target/java/example1_swig.c.o 
``` 


## Build ruby SWIG wrapper 
``` 

# Generate ruby SWIG wrapper 
swig -addextern -I- -Isrc -ruby -outdir target/ruby/ -o  \
  target/ruby/example1_swig.c src/example1.i 

wc -l target/ruby/example1_swig.c 
2257 target/ruby/example1_swig.c 

grep -siH example1 target/ruby/example1_swig.c 
target/ruby/example1_swig.c:#define SWIG_init Init_example1_swig 
target/ruby/example1_swig.c:#define SWIG_name "Example1_swig" 
target/ruby/example1_swig.c:static VALUE mExample1_swig; 
target/ruby/example1_swig.c:#include "example1.h" 
target/ruby/example1_swig.c:SWIGEXPORT void Init_example1_swig(void) { 
target/ruby/example1_swig.c: mExample1_swig =  \
  rb_define_module("Example1_swig"); 
target/ruby/example1_swig.c: rb_define_const(mExample1_swig,  \
  "EXAMPLE1_VERSION", SWIG_FromCharPtr("1.2.3")); 
target/ruby/example1_swig.c: rb_define_module_function(mExample1_swig,  \
  "cubic_poly", _wrap_cubic_poly, -1); 

# Compile ruby SWIG wrapper: 
clang -g -Isrc -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o  \
  target/ruby/example1_swig.c.o target/ruby/example1_swig.c 

# Link ruby SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/ruby//example1_swig.bundle target/native/example1.o  \
  target/ruby/example1_swig.c.o 
``` 


## Build tcl SWIG wrapper 
``` 

# Generate tcl SWIG wrapper 
swig -addextern -I- -Isrc -tcl -outdir target/tcl/ -o  \
  target/tcl/example1_swig.c src/example1.i 

wc -l target/tcl/example1_swig.c 
2149 target/tcl/example1_swig.c 

grep -siH example1 target/tcl/example1_swig.c 
target/tcl/example1_swig.c:#define SWIG_init Example1_swig_Init 
target/tcl/example1_swig.c:#define SWIG_name "example1_swig" 
target/tcl/example1_swig.c:#include "example1.h" 
target/tcl/example1_swig.c: SWIG_Tcl_SetConstantObj(interp,  \
  "EXAMPLE1_VERSION", SWIG_FromCharPtr("1.2.3")); 
target/tcl/example1_swig.c:SWIGEXPORT int Example1_swig_SafeInit(Tcl_Interp  \
  *interp) { 

# Compile tcl SWIG wrapper: 
clang -g -Isrc -I/usr/include/tcl -c -o target/tcl/example1_swig.c.o  \
  target/tcl/example1_swig.c 

# Link tcl SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/tcl//example1_swig.so target/native/example1.o  \
  target/tcl/example1_swig.c.o 
``` 


## Build guile SWIG wrapper 
``` 

# Generate guile SWIG wrapper 
swig -addextern -I- -Isrc -guile -guile -outdir target/guile/ -o  \
  target/guile/example1_swig.c src/example1.i 

wc -l target/guile/example1_swig.c 
1605 target/guile/example1_swig.c 

grep -siH example1 target/guile/example1_swig.c 
target/guile/example1_swig.c:static char const *gswig_const_EXAMPLE1_VERSION =  \
  (char const *)("1.2.3"); 
target/guile/example1_swig.c:#include "example1.h" 
target/guile/example1_swig.c:_wrap_EXAMPLE1_VERSION(SCM s_0) 
target/guile/example1_swig.c:#define FUNC_NAME "EXAMPLE1-VERSION" 
target/guile/example1_swig.c: gswig_result =  \
  SWIG_str02scm(gswig_const_EXAMPLE1_VERSION); 
target/guile/example1_swig.c: scm_c_define_gsubr("EXAMPLE1-VERSION", 0, 0, 0,  \
  (swig_guile_proc) _wrap_EXAMPLE1_VERSION); 

# Compile guile SWIG wrapper: 
clang -g -Isrc -D_THREAD_SAFE -c -o target/guile/example1_swig.c.o  \
  target/guile/example1_swig.c 

# Link guile SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/guile//libexample1_swig.so target/native/example1.o  \
  target/guile/example1_swig.c.o -lguile-2.2 -lgc 
``` 





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
$ bin/build clean demo
```
