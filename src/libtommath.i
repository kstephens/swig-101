%module libtommath_swig
#define mp_digit unsigned int
%include "libtommath.h"
%include "tommath.h"

 // missing sentinel in function call
%ignore mp_init_multi;
%ignore mp_clear_multi;

%{
#include "libtommath.h"
%}

#if 0
%extend mp_int {
  mp_int() {
    mp_int* impl = malloc(sizeof(*impl));
    mp_init(impl);
    return impl;
  }
  
  void ~mp_int() {
    mp_clear($self);
    free($self);
  }
}
#endif
