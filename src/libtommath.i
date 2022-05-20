%module libtommath_swig
#define mp_digit unsigned long long // HACK
 // missing sentinel in function call
%varargs(10, mp_int *ip = NULL) mp_init_multi;
%varargs(10, mp_int *ip = NULL) mp_clear_multi;
%{
#include "libtommath.h"
%}
%include "libtommath.h"
%include "tommath.h"

%extend mp_int {
  mp_int() {
    return mp_int_new(0);
  }
  mp_int(mp_digit n) {
    return mp_int_new(n);
  }
  ~mp_int() {
    mp_int_delete(self);
  }
}
