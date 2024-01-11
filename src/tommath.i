%module tommath_swig
%include "stdint.i" // mp_digit typedef
// varargs NULL terminator up to 10 arguments:
%varargs(10, mp_int *ip = NULL) mp_init_multi;
%varargs(10, mp_int *ip = NULL) mp_clear_multi;
%{
#include "tommath.h"
%}
%include "libtommath/tommath.h"
%include "tommath.h"
