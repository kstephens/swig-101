#include <stddef.h>
#include <stdint.h>
#include "bool.h"
#include "libtommath/tommath.h"

/*********************************************************************
 * Convert mp_int <-> string
 */

char*    swig_mp_int_to_charP(mp_int* self, int radix);
mp_int*  swig_charP_to_mp_int(const char* str, int radix);

#if SWIG
%extend mp_int {
  char* __str__(int radix = 10) {
    return swig_mp_int_to_charP(self, radix);
  }
  char* __repr__(int radix = 10) {
    char *repr = 0, *str = swig_mp_int_to_charP(self, radix);
    if ( radix == 10 )
      asprintf(&repr, "mp_int(\"%s\")", str);
    else
      asprintf(&repr, "mp_int(\"%s\",%d)", str, radix);
    return free(str), repr;
  }
}
#endif

/*********************************************************************
 * Memory Management

tommath `mp_int` internal memory is managed by:

* mp_init(mp_int*)
* mp_clear(mp_int*)

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
  mp_int(mp_digit n = 0) {
    return swig_mp_int_new(n);
  }
  mp_int(const char *str, int radix = 10) {
    return swig_charP_to_mp_int(str, radix);
  }
  ~mp_int() {
    swig_mp_int_delete(self);
  }
}
#endif
