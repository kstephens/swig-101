# swig-101

Introduction to [SWIG](http://www.swig.org/).

# What is SWIG?

Swig is a C/C++ FFI binding generator.

# Target Languages

The examples below target these languages:

* Python
* Ruby
* TCL
* Guile Scheme
* Java (via Clojure)





# Example1


## C Header : src/example1.h

``` C
  1   double cubic_poly(double x, double c0, double c1, double c2, double c3);

```



## C Library : src/example1.c

``` C
  1   #include "example1.h"
  2   
  3   double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  4     return c0 + c1 * x + c2 * x*x + c3 * x*x*x;
  5   }

```



## C Main : src/example1-native.c

``` C
  1   #include <stdio.h>
  2   #include "example1.h"
  3   
  4   int main(int argc, char **argv) {
  5     printf("%5.1f\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));
  6     return 0;
  7   }

```


----

```
$ target/native/example1
129.0

```


## C SWIG Interface : src/example1.i

``` C
  1   %module example1
  2   %include "example1.h"
  3   %{
  4   #include "example1.h"
  5   %}

```



## Ruby : src/example1-ruby

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


## Python : src/example1-python

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


## TCL : src/example1-tcl

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


## Guile : src/example1-guile

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


## Clojure : src/example1-clojure

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
129.0

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


## CC Header : src/example2.h

``` CC
  1   #include <vector>
  2   
  3   class Polynomial {
  4    public:
  5     std::vector<double> coeffs;
  6     double evaluate(double x);
  7   };

```



## CC Library : src/example2.cc

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



## CC Main : src/example2-native.cc

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


## CC SWIG Interface : src/example2.i

``` CC
  1   %module example2
  2   %include std_vector.i
  3   %template(VectorDouble) std::vector<double>;
  4   %include "example2.h"
  5   %{
  6   #include "example2.h"
  7   %}

```



## Ruby : src/example2-ruby

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
 13   pp p.evaluate(2.0)

```


----

```
$ src/example2-ruby
[2.0, 3.0, 5.0, 7.0, 11.0, -13.0]
-156.0

```


## Python : src/example2-python

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


## TCL : src/example2-tcl

``` TCL
  1   #!/usr/bin/env tclsh
  2   
  3   load target/tcl/example2.so Example2
  4   
  5   Polynomial poly
  6   VectorDouble c { 2.0 3.0 5.0 7.0 11.0 -13.0 }
  7   poly configure -coeffs c
  8   
  9   puts [poly cget -coeffs]
 10   puts [poly evaluate 2.0]

```


----

```
$ src/example2-tcl
_30457076fe7f0000_p_std__vectorT_double_t
-156.0

```


## Guile : src/example2-guile

``` Guile
  1   #!/usr/bin/env guile
  2   !#
  3   
  4   (load-extension "target/guile/libexample2.so" "SWIG_init")
  5   
  6   (define p (new-Polynomial))
  7   (Polynomial-coeffs-set p (new-VectorDouble '(2.0 3.0 5.0 7.0 11.0 -13.0)))
  8   
  9   (write (Polynomial-coeffs-get p)) (newline)
 10   (write (Polynomial-evaluate p 2.0)) (newline)

```


----

```
$ src/example2-guile
#<swig-pointer std::vector< double > * 7fdd9ae040e0>
-156.0

```


## Clojure : src/example2-clojure

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
_b0d9c045cd7f0000_p_std__vectorT_double_t
-156.0

```



```
$ src/example2-guile
#<swig-pointer std::vector< double > * 7fbf8fe040e0>
-156.0

```



```
$ src/example2-clojure
[2.0 3.0 5.0 7.0 11.0 -13.0]
-156.0

```




# Workflow



1. Generate SWIG wrapper from interface file for target language.
2. Compile native library.
3. Compile SWIG wrapper.
4. Link native library and SWIG wrapper into dynamic library.
5. Load dynamic library into target language.

************************************************************************
* 
*                           
*                         
* +----------------+
* |  c/example1.i  +---+   1. swig -python c/example1.i \
* +----------------+   |           -o target/example1.c
*                      |
* +----------------+   |       +----------------------+
* |  c/example1.h  +---+------>|  target/example1.py  +--------+
* |----------------|           |----------------------|        |
* |  c/example1.c  |           |  target/example1.c   |        |
* +-+--------------+           +-+--------------------+        |
*   |                            |                             |
*   |  2. cc -c c/example.c      | 3. cc -c target/example1.c  |
*   v                            v                             |
* +----------------+           +----------------------+        |
* |  c/example1.о  |           |  target/example1.о   |        |
* +-+--------------+           +-+--------------------+        |
*   |                            |                             |
*   +----------------------------+                             |
*   |                                                          |
*   | 4. cc -dynamiclib -о target/_example1.so \               |
*   |      c/example1.о target/example1.о                      |
*   v                                                          |
* +----------------------+                                     |
* |  target/example1.sо  |                                     |
* +-+--------------------+                                     |
*   |                                                          |
*   +----------------------------------------------------------+
*   | 
*   | 5. python script.py
*   v                    
* +------------------------------+
* | script.py                    |
* |------------------------------|
* | import sys                   |
* | sys.path.append('target')    |
* | import example1              |
* | print(example1.f(2.0, 3.0))  |
* +------------------------------+
* 
************************************************************************




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
swig -addextern -I- -Isrc -python -o target/python/example1.c src/example1.i 

wc -l target/python/example1.c target/python/example1.py 
3604 target/python/example1.c 
64 target/python/example1.py 
3668 total 

grep -siH example1 target/python/example1.c target/python/example1.py 
target/python/example1.c: @(target):= _example1.so 
target/python/example1.c:# define SWIG_init PyInit__example1 
target/python/example1.c:# define SWIG_init init_example1 
target/python/example1.c:#define SWIG_name "_example1" 
target/python/example1.c:#include "example1.h" 
target/python/example1.py: from . import _example1 
target/python/example1.py: import _example1 
target/python/example1.py: return _example1.cubic_poly(x, c0, c1, c2, c3) 

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


## Build ruby SWIG wrapper 
``` 

# Generate ruby SWIG wrapper 
swig -addextern -I- -Isrc -ruby -o target/ruby/example1.c src/example1.i 

wc -l target/ruby/example1.c 
2219 target/ruby/example1.c 

grep -siH example1 target/ruby/example1.c 
target/ruby/example1.c:#define SWIG_init Init_example1 
target/ruby/example1.c:#define SWIG_name "Example1" 
target/ruby/example1.c:static VALUE mExample1; 
target/ruby/example1.c:#include "example1.h" 
target/ruby/example1.c:SWIGEXPORT void Init_example1(void) { 
target/ruby/example1.c: mExample1 = rb_define_module("Example1"); 
target/ruby/example1.c: rb_define_module_function(mExample1, "cubic_poly",  \
  _wrap_cubic_poly, -1); 

# Compile ruby SWIG wrapper: 
clang -g -Isrc -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o target/ruby/example1.o  \
  target/ruby/example1.c 

# Link ruby SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/ruby/example1.bundle target/native/example1.o target/ruby/example1.o 
``` 


## Build tcl SWIG wrapper 
``` 

# Generate tcl SWIG wrapper 
swig -addextern -I- -Isrc -tcl -o target/tcl/example1.c src/example1.i 

wc -l target/tcl/example1.c 
2124 target/tcl/example1.c 

grep -siH example1 target/tcl/example1.c 
target/tcl/example1.c:#define SWIG_init Example1_Init 
target/tcl/example1.c:#define SWIG_name "example1" 
target/tcl/example1.c:#include "example1.h" 
target/tcl/example1.c:SWIGEXPORT int Example1_SafeInit(Tcl_Interp *interp) { 

# Compile tcl SWIG wrapper: 
clang -g -Isrc -I/usr/include/tcl -c -o target/tcl/example1.o  \
  target/tcl/example1.c 

# Link tcl SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/tcl/example1.so target/native/example1.o target/tcl/example1.o 
``` 


## Build guile SWIG wrapper 
``` 

# Generate guile SWIG wrapper 
swig -addextern -I- -Isrc -guile -guile -o target/guile/example1.c  \
  src/example1.i 

wc -l target/guile/example1.c 
1588 target/guile/example1.c 

grep -siH example1 target/guile/example1.c 
target/guile/example1.c:#include "example1.h" 

# Compile guile SWIG wrapper: 
clang -g -Isrc -D_THREAD_SAFE -c -o target/guile/example1.o  \
  target/guile/example1.c 

# Link guile SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/guile/libexample1.so target/native/example1.o target/guile/example1.o  \
  -lguile-2.2 -lgc 
``` 


## Build java SWIG wrapper 
``` 

# Generate java SWIG wrapper 
swig -addextern -I- -Isrc -java -o target/java/example1.c src/example1.i 

wc -l target/java/example1.c target/java/example1*.java 
231 target/java/example1.c 
15 target/java/example1.java 
12 target/java/example1JNI.java 
258 total 

grep -siH example1 target/java/example1.c target/java/example1*.java 
target/java/example1.c:#include "example1.h" 
target/java/example1.c:SWIGEXPORT jdouble JNICALL  \
  Java_example1JNI_cubic_1poly(JNIEnv *jenv, jclass jcls, jdouble jarg1, jdouble  \
  jarg2, jdouble jarg3, jdouble jarg4, jdouble jarg5) { 
target/java/example1.java:public class example1 { 
target/java/example1.java: return example1JNI.cubic_poly(x, c0, c1, c2, c3); 
target/java/example1JNI.java:public class example1JNI { 

# Compile java SWIG wrapper: 
clang -g -Isrc -I$JAVA_HOME/include -I$JAVA_HOME/include/linux  \
  -I$JAVA_HOME/include/darwin -c -o target/java/example1.o  \
  target/java/example1.c 

# Link java SWIG wrapper dynamic library: 
clang -g -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/java/libexample1.jnilib target/native/example1.o target/java/example1.o 
``` 




# Build example2.cc 


## Build example2.cc Native Code 
``` 

# Compile native library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -c -o  \
  target/native/example2.o src/example2.cc 

# Compile and link native program: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -o  \
  target/native/example2 src/example2-native.cc target/native/example2.o 
``` 


## Build python SWIG wrapper 
``` 

# Generate python SWIG wrapper 
swig -addextern -I- -Isrc -c++ -python -o target/python/example2.cc  \
  src/example2.i 

wc -l target/python/example2.cc target/python/example2.py 
8362 target/python/example2.cc 
240 target/python/example2.py 
8602 total 

grep -siH example2 target/python/example2.cc target/python/example2.py 
target/python/example2.cc: @(target):= _example2.so 
target/python/example2.cc:# define SWIG_init PyInit__example2 
target/python/example2.cc:# define SWIG_init init_example2 
target/python/example2.cc:#define SWIG_name "_example2" 
target/python/example2.cc:#include "example2.h" 
target/python/example2.py: from . import _example2 
target/python/example2.py: import _example2 
target/python/example2.py: __swig_destroy__ = _example2.delete_SwigPyIterator 
target/python/example2.py: return _example2.SwigPyIterator_value(self) 
target/python/example2.py: return _example2.SwigPyIterator_incr(self, n) 
target/python/example2.py: return _example2.SwigPyIterator_decr(self, n) 
target/python/example2.py: return _example2.SwigPyIterator_distance(self, x) 
target/python/example2.py: return _example2.SwigPyIterator_equal(self, x) 
target/python/example2.py: return _example2.SwigPyIterator_copy(self) 
target/python/example2.py: return _example2.SwigPyIterator_next(self) 
target/python/example2.py: return _example2.SwigPyIterator___next__(self) 
target/python/example2.py: return _example2.SwigPyIterator_previous(self) 
target/python/example2.py: return _example2.SwigPyIterator_advance(self, n) 
target/python/example2.py: return _example2.SwigPyIterator___eq__(self, x) 
target/python/example2.py: return _example2.SwigPyIterator___ne__(self, x) 
target/python/example2.py: return _example2.SwigPyIterator___iadd__(self, n) 
target/python/example2.py: return _example2.SwigPyIterator___isub__(self, n) 
target/python/example2.py: return _example2.SwigPyIterator___add__(self, n) 
target/python/example2.py: return _example2.SwigPyIterator___sub__(self,  \
  *args) 
target/python/example2.py:# Register SwigPyIterator in _example2: 
 \
  target/python/example2.py:_example2.SwigPyIterator_swigregister(SwigPyIterator) 
target/python/example2.py: return _example2.VectorDouble_iterator(self) 
target/python/example2.py: return _example2.VectorDouble___nonzero__(self) 
target/python/example2.py: return _example2.VectorDouble___bool__(self) 
target/python/example2.py: return _example2.VectorDouble___len__(self) 
target/python/example2.py: return _example2.VectorDouble___getslice__(self, i,  \
  j) 
target/python/example2.py: return _example2.VectorDouble___setslice__(self,  \
  *args) 
target/python/example2.py: return _example2.VectorDouble___delslice__(self, i,  \
  j) 
target/python/example2.py: return _example2.VectorDouble___delitem__(self,  \
  *args) 
target/python/example2.py: return _example2.VectorDouble___getitem__(self,  \
  *args) 
target/python/example2.py: return _example2.VectorDouble___setitem__(self,  \
  *args) 
target/python/example2.py: return _example2.VectorDouble_pop(self) 
target/python/example2.py: return _example2.VectorDouble_append(self, x) 
target/python/example2.py: return _example2.VectorDouble_empty(self) 
target/python/example2.py: return _example2.VectorDouble_size(self) 
target/python/example2.py: return _example2.VectorDouble_swap(self, v) 
target/python/example2.py: return _example2.VectorDouble_begin(self) 
target/python/example2.py: return _example2.VectorDouble_end(self) 
target/python/example2.py: return _example2.VectorDouble_rbegin(self) 
target/python/example2.py: return _example2.VectorDouble_rend(self) 
target/python/example2.py: return _example2.VectorDouble_clear(self) 
target/python/example2.py: return _example2.VectorDouble_get_allocator(self) 
target/python/example2.py: return _example2.VectorDouble_pop_back(self) 
target/python/example2.py: return _example2.VectorDouble_erase(self, *args) 
target/python/example2.py: _example2.VectorDouble_swiginit(self,  \
  _example2.new_VectorDouble(*args)) 
target/python/example2.py: return _example2.VectorDouble_push_back(self, x) 
target/python/example2.py: return _example2.VectorDouble_front(self) 
target/python/example2.py: return _example2.VectorDouble_back(self) 
target/python/example2.py: return _example2.VectorDouble_assign(self, n, x) 
target/python/example2.py: return _example2.VectorDouble_resize(self, *args) 
target/python/example2.py: return _example2.VectorDouble_insert(self, *args) 
target/python/example2.py: return _example2.VectorDouble_reserve(self, n) 
target/python/example2.py: return _example2.VectorDouble_capacity(self) 
target/python/example2.py: __swig_destroy__ = _example2.delete_VectorDouble 
target/python/example2.py:# Register VectorDouble in _example2: 
target/python/example2.py:_example2.VectorDouble_swigregister(VectorDouble) 
target/python/example2.py: coeffs = property(_example2.Polynomial_coeffs_get,  \
  _example2.Polynomial_coeffs_set) 
target/python/example2.py: return _example2.Polynomial_evaluate(self, x) 
target/python/example2.py: _example2.Polynomial_swiginit(self,  \
  _example2.new_Polynomial()) 
target/python/example2.py: __swig_destroy__ = _example2.delete_Polynomial 
target/python/example2.py:# Register Polynomial in _example2: 
target/python/example2.py:_example2.Polynomial_swigregister(Polynomial) 

# Compile python SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$PYTHON_HOME/include/python3.10 -I$PYTHON_HOME/include/python3.10  \
  -Wno-unused-result -Wsign-compare -Wunreachable-code -fno-common -dynamic  \
  -DNDEBUG -g -fwrapv -O3 -Wall -pipe -Os -Wno-deprecated-declarations -c -o  \
  target/python/example2.o target/python/example2.cc 

# Link python SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/python/_example2.so  \
  target/native/example2.o target/python/example2.o  \
  -L$PYTHON_HOME/lib/python3.10/config-3.10-darwin -ldl -framework  \
  CoreFoundation 
``` 


## Build ruby SWIG wrapper 
``` 

# Generate ruby SWIG wrapper 
swig -addextern -I- -Isrc -c++ -ruby -o target/ruby/example2.cc src/example2.i 

wc -l target/ruby/example2.cc 
8490 target/ruby/example2.cc 

grep -siH example2 target/ruby/example2.cc 
target/ruby/example2.cc:#define SWIG_init Init_example2 
target/ruby/example2.cc:#define SWIG_name "Example2" 
target/ruby/example2.cc:static VALUE mExample2; 
target/ruby/example2.cc:#include "example2.h" 
target/ruby/example2.cc:SWIGEXPORT void Init_example2(void) { 
target/ruby/example2.cc: mExample2 = rb_define_module("Example2"); 
target/ruby/example2.cc: SwigClassGC_VALUE.klass =  \
  rb_define_class_under(mExample2, "GC_VALUE", rb_cObject); 
target/ruby/example2.cc: SwigClassConstIterator.klass =  \
  rb_define_class_under(mExample2, "ConstIterator", rb_cObject); 
target/ruby/example2.cc: SwigClassIterator.klass =  \
  rb_define_class_under(mExample2, "Iterator", ((swig_class *)  \
  SWIGTYPE_p_swig__ConstIterator->clientdata)->klass); 
target/ruby/example2.cc: SwigClassVectorDouble.klass =  \
  rb_define_class_under(mExample2, "VectorDouble", rb_cObject); 
target/ruby/example2.cc: SwigClassPolynomial.klass =  \
  rb_define_class_under(mExample2, "Polynomial", rb_cObject); 

# Compile ruby SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$RUBY_HOME/include/ruby-2.7.0  \
  -I$RUBY_HOME/include/ruby-2.7.0/x86_64-darwin19 -c -o target/ruby/example2.o  \
  target/ruby/example2.cc 

# Link ruby SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/ruby/example2.bundle  \
  target/native/example2.o target/ruby/example2.o 
``` 


## Build tcl SWIG wrapper 
``` 

# Generate tcl SWIG wrapper 
swig -addextern -I- -Isrc -c++ -tcl -o target/tcl/example2.cc src/example2.i 

wc -l target/tcl/example2.cc 
2936 target/tcl/example2.cc 

grep -siH example2 target/tcl/example2.cc 
target/tcl/example2.cc:#define SWIG_init Example2_Init 
target/tcl/example2.cc:#define SWIG_name "example2" 
target/tcl/example2.cc:#include "example2.h" 
target/tcl/example2.cc:SWIGEXPORT int Example2_SafeInit(Tcl_Interp *interp) { 

# Compile tcl SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I/usr/include/tcl -c -o target/tcl/example2.o target/tcl/example2.cc 

# Link tcl SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/tcl/example2.so  \
  target/native/example2.o target/tcl/example2.o 
``` 


## Build guile SWIG wrapper 
``` 

# Generate guile SWIG wrapper 
swig -addextern -I- -Isrc -guile -c++ -guile -o target/guile/example2.cc  \
  src/example2.i 

wc -l target/guile/example2.cc 
2250 target/guile/example2.cc 

grep -siH example2 target/guile/example2.cc 
target/guile/example2.cc:#include "example2.h" 

# Compile guile SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -D_THREAD_SAFE -c -o target/guile/example2.o target/guile/example2.cc 

# Link guile SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/guile/libexample2.so  \
  target/native/example2.o target/guile/example2.o -lguile-2.2 -lgc 
``` 


## Build java SWIG wrapper 
``` 

# Generate java SWIG wrapper 
swig -addextern -I- -Isrc -c++ -java -o target/java/example2.cc src/example2.i 

wc -l target/java/example2.cc target/java/example2*.java 
648 target/java/example2.cc 
11 target/java/example2.java 
31 target/java/example2JNI.java 
690 total 

grep -siH example2 target/java/example2.cc target/java/example2*.java 
target/java/example2.cc:#include "example2.h" 
target/java/example2.cc:SWIGEXPORT jlong JNICALL  \
  Java_example2JNI_new_1VectorDouble_1_1SWIG_10(JNIEnv *jenv, jclass jcls) { 
target/java/example2.cc:SWIGEXPORT jlong JNICALL  \
  Java_example2JNI_new_1VectorDouble_1_1SWIG_11(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_) { 
target/java/example2.cc:SWIGEXPORT jlong JNICALL  \
  Java_example2JNI_VectorDouble_1capacity(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_VectorDouble_1reserve(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_, jlong jarg2) { 
target/java/example2.cc:SWIGEXPORT jboolean JNICALL  \
  Java_example2JNI_VectorDouble_1isEmpty(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_VectorDouble_1clear(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_) { 
target/java/example2.cc:SWIGEXPORT jlong JNICALL  \
  Java_example2JNI_new_1VectorDouble_1_1SWIG_12(JNIEnv *jenv, jclass jcls, jint  \
  jarg1, jdouble jarg2) { 
target/java/example2.cc:SWIGEXPORT jint JNICALL  \
  Java_example2JNI_VectorDouble_1doSize(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_VectorDouble_1doAdd_1_1SWIG_10(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_, jdouble jarg2) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_VectorDouble_1doAdd_1_1SWIG_11(JNIEnv *jenv, jclass jcls,  \
  jlong jarg1, jobject jarg1_, jint jarg2, jdouble jarg3) { 
target/java/example2.cc:SWIGEXPORT jdouble JNICALL  \
  Java_example2JNI_VectorDouble_1doRemove(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_, jint jarg2) { 
target/java/example2.cc:SWIGEXPORT jdouble JNICALL  \
  Java_example2JNI_VectorDouble_1doGet(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_, jint jarg2) { 
target/java/example2.cc:SWIGEXPORT jdouble JNICALL  \
  Java_example2JNI_VectorDouble_1doSet(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_, jint jarg2, jdouble jarg3) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_VectorDouble_1doRemoveRange(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_, jint jarg2, jint jarg3) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_delete_1VectorDouble(JNIEnv *jenv, jclass jcls, jlong jarg1)  \
  { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_Polynomial_1coeffs_1set(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_, jlong jarg2, jobject jarg2_) { 
target/java/example2.cc:SWIGEXPORT jlong JNICALL  \
  Java_example2JNI_Polynomial_1coeffs_1get(JNIEnv *jenv, jclass jcls, jlong  \
  jarg1, jobject jarg1_) { 
target/java/example2.cc:SWIGEXPORT jdouble JNICALL  \
  Java_example2JNI_Polynomial_1evaluate(JNIEnv *jenv, jclass jcls, jlong jarg1,  \
  jobject jarg1_, jdouble jarg2) { 
target/java/example2.cc:SWIGEXPORT jlong JNICALL  \
  Java_example2JNI_new_1Polynomial(JNIEnv *jenv, jclass jcls) { 
target/java/example2.cc:SWIGEXPORT void JNICALL  \
  Java_example2JNI_delete_1Polynomial(JNIEnv *jenv, jclass jcls, jlong jarg1) { 
target/java/example2.java:public class example2 { 
target/java/example2JNI.java:public class example2JNI { 

# Compile java SWIG wrapper: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17  \
  -I$JAVA_HOME/include -I$JAVA_HOME/include/linux -I$JAVA_HOME/include/darwin -c  \
  -o target/java/example2.o target/java/example2.cc 

# Link java SWIG wrapper dynamic library: 
clang++ -g -Isrc -Wno-c++11-extensions -stdlib=libc++ -std=c++17 -dynamiclib  \
  -Wl,-undefined,dynamic_lookup -o target/java/libexample2.jnilib  \
  target/native/example2.o target/java/example2.o 
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
