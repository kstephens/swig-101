%module libtommath_swig
#define mp_digit unsigned long long // HACK
 // missing sentinel in function call
%varargs(10, mp_int *ip = NULL) mp_init_multi;
%varargs(10, mp_int *ip = NULL) mp_clear_multi;
%{
#include "libtommath.h"
%}
%include "tommath.h"
%include "libtommath.h"
