#include <stdbool.h> // C99
#ifndef bool
#define bool   _Bool
#define true   1
#define false  0
#endif
#include "tommath.h"

char*    mp_int_to_charP(mp_int* self);

/***********************************************

tommath mp_int memory management:

tommath `mp_int` internal memory is managed by:

* mp_init(mp_int*)   - initialize mp_int's internal memory.
* mp_clear(mp_int*)  - free mp_int's internal memory.

tommath expects these functions to be called
before and after using a mp_int value, respectively.

*/

mp_int*  swig_mp_int_new(mp_digit n);
void     swig_mp_int_delete(mp_int* self);

#if SWIG
/***********************************************

SWIG wraps `struct mp_int` values with pointer `malloc(sizeof(mp_int))`.

`%extend mp_int` defines constructors and destructors for `mp_int`.

*/
  
%extend mp_int {
  mp_int() {
    return swig_mp_int_new(0);
  }
  mp_int(mp_digit n) {
    return swig_mp_int_new(n);
  }
  ~mp_int() {
    swig_mp_int_delete(self);
  }
}
#endif
