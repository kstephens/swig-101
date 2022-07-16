#include "tommath.h"
#define _GNU_SOURCE
#include <stdlib.h>

char* swig_mp_int_to_charP(mp_int* self, int radix) {
  size_t size = 0, written = 0;
  (void) mp_radix_size(self, radix, &size);
  char* buf = malloc(size + 1);
  (void) mp_to_radix(self, buf, size, &written, radix);
  buf[written - 1] = 0;
  return buf;
}

char* swig_mp_int_rep(mp_int* self, int radix) {
  char *repr = 0, *str = swig_mp_int_to_charP(self, radix);
  if ( radix == 10 )
    asprintf(&repr, "mp_int(\"%s\")", str);
  else
    asprintf(&repr, "mp_int(\"%s\",%d)", str, radix);
  return free(str), repr;
}

mp_int* swig_charP_to_mp_int(const char* str, int radix) {
  mp_int* self = swig_mp_int_new(0);
  (void) mp_read_radix(self, str, radix);
  return self;
}

mp_int* swig_mp_int_new(mp_digit n) {
  mp_int* self = malloc(sizeof(*self));
  (void) mp_init(self);
  mp_set(self, n);
  return self;
}

void swig_mp_int_delete(mp_int* self) {
  mp_clear(self);
  free(self);
}
