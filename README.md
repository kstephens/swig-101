# swig-101

Introduction to [SWIG](http://www.swig.org/).

# HOWTO

## OSX

* Install macports
* Install rbenv + ruby-build plugin
* rbenv install 2.7.1
* Install JVM 11.0
* Install clojure + clojure-tools

## Build

```
$ rbenv shell 2.7.1
$ bin/build macports-prereq 
$ bin/build clean all
```





# Example1


## C Header -- src/example1.h

``` C
#ifdef SWIG
%module example1
%{
#include "example1.h"
%}
#endif

double cubic_poly(double x, double c0, double c1, double c2, double c3);

```



## C Library -- src/example1.c

``` C
#include "example1.h"

double cubic_poly(double x, double c0, double c1, double c2, double c3) {
  return c0 + c1 * x + c2 * x*x + c3 * x*x*x;
}

```



## C Main -- src/example1-native.c

``` C
#include <stdio.h>
#include "example1.h"

int main(int argc, char **argv) {
  printf("%5.2f\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));
  return 0;
}

```


----

```
$ target/native/example1
129.00

```


## Ruby -- src/example1-ruby

``` Ruby
#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example1'

puts Example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0)

```


----

```
$ src/example1-ruby
129.0

```


## Python -- src/example1-python

``` Python
#!/usr/bin/env python3.10

import sys
sys.path.append('target/python')

import example1

print(example1.cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0))

```


----

```
$ src/example1-python
129.0

```


## TCL -- src/example1-tcl

``` TCL
#!/usr/bin/env tclsh

load target/tcl/example1.so Example1

puts [cubic_poly 2.0 3.0 5.0 7.0 11.0]

```


----

```
$ src/example1-tcl
129.0

```


## Guile -- src/example1-guile

``` Guile
#!/usr/bin/env guile --no-auto-compile
!#

(load-extension "target/guile/libexample1.so" "SWIG_init")

(write (cubic-poly 2.0 3.0 5.0 7.0 11.0))
(newline)

```


----

```
$ src/example1-guile
129.0

```


## Clojure -- src/example1-clojure

``` Clojure
;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "example1")

(import 'example1)

(println (example1/cubic_poly 2.0 3.0 5.0 7.0 11.0))

```


----

```
$ bin/run-clj src/example1-clojure
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
$ bin/run-clj src/example1-clojure
129.0

```




# Example2


## CC Header -- src/example2.h

``` CC
#ifdef SWIG
%module example2
%include std_vector.i
%template(VectorDouble) std::vector<double>;
%{
#include "example2.h"
%}
#endif

#include <vector>

class Polynomial {
 public:
  std::vector<double> coeffs;
  double evaluate(double x);
};

```



## CC Library -- src/example2.cc

``` CC
#include "example2.h"

double Polynomial::evaluate(double x) {
  double result = 0, xx = 1;
  for ( auto c : this->coeffs ) {
    result += c * xx;
    xx *= x;
  }
  return result;
}

```



## CC Main -- src/example2-native.cc

``` CC
#include <iostream>
#include "example2.h"

int main(int argc, char **argv) {
  Polynomial p;
  p.coeffs = { 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 };
  std::cout << p.evaluate(2.0) << std::endl;
  return 0;
}

```


----

```
$ target/native/example2
-156

```


## Ruby -- src/example2-ruby

``` Ruby
#!/usr/bin/env ruby

ENV["LD_LIBRARY_PATH"] = 'target/ruby'
$:.unshift 'target/ruby'

require 'example2'
include Example2

p = Polynomial.new
p.coeffs << 3.0
p.coeffs << 5.0
p.coeffs << 7.0
p.coeffs << 11.0
p.coeffs << -13.0

puts p.evaluate(2.0)

########################################
# Extend for convenience:

class Polynomial
  # Constructor:
  def self.[] elems
    elems.inject(new){|this, x| this.coeffs << x; this}
  end
  # Proc-like:
  def to_proc
    lambda{|x| evaluate(x)}
  end
  alias :call :evaluate
  alias :[]   :evaluate
end

require 'pp'

p = Polynomial[ [3.0, 5.0, 7.0, 11.0, -13.0] ]
pp p.coeffs.to_a

x = 0..5
pp x.zip(x.map(&p)).to_h

```


----

```
$ src/example2-ruby
-79.0
[3.0, 5.0, 7.0, 11.0, -13.0]
{0=>3.0, 1=>13.0, 2=>-79.0, 3=>-675.0, 4=>-2489.0, 5=>-6547.0}

```


## Python -- src/example2-python

``` Python
#!/usr/bin/env python3.10

import sys
sys.path.append('target/python')

from example2 import Polynomial, VectorDouble

poly = Polynomial()
poly.coeffs = VectorDouble([ 2.0, 3.0, 5.0, 7.0, 11.0, -13.0 ])
print(poly.evaluate(2.0))

```


----

```
$ src/example2-python
-156.0

```


## TCL -- src/example2-tcl

``` TCL
#!/usr/bin/env tclsh

load target/tcl/example2.so Example2

Polynomial poly
VectorDouble c { 2.0 3.0 5.0 7.0 11.0 -13.0 }
poly configure -coeffs c
puts [poly evaluate 2.0]

```


----

```
$ src/example2-tcl
-156.0

```


## Guile -- src/example2-guile

``` Guile
#!/usr/bin/env guile --no-auto-compile
!#

```


----

```
$ src/example2-guile

```


## Clojure -- src/example2-clojure

``` Clojure
;; -*- clojure -*-

```


----

```
$ bin/run-clj src/example2-clojure

```



## Output


```
$ target/native/example2
-156

```



```
$ src/example2-ruby
-79.0
[3.0, 5.0, 7.0, 11.0, -13.0]
{0=>3.0, 1=>13.0, 2=>-79.0, 3=>-675.0, 4=>-2489.0, 5=>-6547.0}

```



```
$ src/example2-python
-156.0

```



```
$ src/example2-tcl
-156.0

```



```
$ src/example2-guile

```



```
$ bin/run-clj src/example2-clojure

```




# Workflow



* Compile native library
* Generate SWIG wrappers for target language
* Compile and link SWIG wrappers for target language with native library
* Load SWIG wrappers into target language



# Build example1.c 


## Build example1.c Native Code 
``` 

# Compile native library: 
clang -g -O3 -Isrc -c -o target/native/example1.o src/example1.c 

# Compile and link native program: 
clang -g -O3 -Isrc -o target/native/example1 src/example1-native.c  \
  target/native/example1.o
``` 


## Build python SWIG wrapper 
``` 

# Generate python SWIG wrapper: 
swig -addextern -I- -py3 -python -o target/python/example1.c src/example1.h 

wc -l target/python/example1.c 
3573 target/python/example1.c 

# Compile python SWIG wrapper: 
clang -g -O3 -Isrc  \
  -I/opt/local/Library/Frameworks/Python.framework/Versions/3.10/include/python3.10 \
  -I/opt/local/Library/Frameworks/Python.framework/Versions/3.10/include/python3.10 \
  -Wno-unused-result-Wsign-compare -Wunreachable-code -fno-common -dynamic  \
  -DNDEBUG-g -fwrapv -O3 -Wall -pipe -Os  \
  -isysroot/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk \
  -Wno-deprecated-declarations-c -o target/python/example1.o  \
  target/python/example1.c

# Link python SWIG wrapper dynamic library: 
clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/python/_example1.sotarget/native/example1.o target/python/example1.o  \
  -L/opt/local/Library/Frameworks/Python.framework/Versions/3.10/lib/python3.10/config-3.10-darwin \
  -ldl-framework CoreFoundation 
``` 


## Build ruby SWIG wrapper 
``` 

# Generate ruby SWIG wrapper: 
swig -addextern -I- -ruby -o target/ruby/example1.c src/example1.h 

wc -l target/ruby/example1.c 
2215 target/ruby/example1.c 

# Compile ruby SWIG wrapper: 
clang -g -O3 -Isrc -I/Users/kstephens/.rbenv/versions/2.7.1/include/ruby-2.7.0  \
  -I/Users/kstephens/.rbenv/versions/2.7.1/include/ruby-2.7.0/x86_64-darwin19-c  \
  -otarget/ruby/example1.o target/ruby/example1.c 

# Link ruby SWIG wrapper dynamic library: 
clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/ruby/example1.bundletarget/native/example1.o target/ruby/example1.o 
``` 


## Build tcl SWIG wrapper 
``` 

# Generate tcl SWIG wrapper: 
swig -addextern -I- -tcl -o target/tcl/example1.c src/example1.h 

wc -l target/tcl/example1.c 
2121 target/tcl/example1.c 

# Compile tcl SWIG wrapper: 
clang -g -O3 -Isrc -I/usr/include/tcl -c -o target/tcl/example1.o  \
  target/tcl/example1.c

# Link tcl SWIG wrapper dynamic library: 
clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/tcl/example1.sotarget/native/example1.o target/tcl/example1.o 
``` 


## Build guile SWIG wrapper 
``` 

# Generate guile SWIG wrapper: 
swig -addextern -I- -scmstub -guile -o target/guile/example1.c src/example1.h 

wc -l target/guile/example1.c 
1583 target/guile/example1.c 

# Compile guile SWIG wrapper: 
clang -g -O3 -Isrc -D_THREAD_SAFE guile/2.2 -c -o target/guile/example1.o  \
  target/guile/example1.c

# Link guile SWIG wrapper dynamic library: 
clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/guile/libexample1.sotarget/native/example1.o target/guile/example1.o  \
  -lguile-2.2-lgc 
``` 


## Build java SWIG wrapper 
``` 

# Generate java SWIG wrapper: 
swig -addextern -I- -java -o target/java/example1.c src/example1.h 

wc -l target/java/example1.c 
243 target/java/example1.c 

# Compile java SWIG wrapper: 
clang -g -O3 -Isrc  \
  -I/Library/Java/JavaVirtualMachines/jdk1.8.0.jdk/Contents/Home/include \
  -I/Library/Java/JavaVirtualMachines/jdk1.8.0.jdk/Contents/Home/include/linux \
  -I/Library/Java/JavaVirtualMachines/jdk1.8.0.jdk/Contents/Home/include/darwin \
  -c-o target/java/example1.o target/java/example1.c 

# Link java SWIG wrapper dynamic library: 
clang -g -O3 -Isrc -dynamiclib -Wl,-undefined,dynamic_lookup -o  \
  target/java/libexample1.jnilibtarget/native/example1.o target/java/example1.o 
``` 




