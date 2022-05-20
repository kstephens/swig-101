%module libtommath_swig
%include "stdint.i" // mp_digit typedef
 // "missing sentinel in function call"
%varargs(10, mp_int *ip = NULL) mp_init_multi;
%varargs(10, mp_int *ip = NULL) mp_clear_multi;
%{
#include "libtommath.h"
%}
%include "libtommath/tommath.h"
%include "libtommath.h"
