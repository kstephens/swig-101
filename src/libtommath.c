#include "libtommath.h"
#include <stdlib.h>

char* mp_int_to_charP(mp_int* self) {
  size_t size = 0, written = 0;
  int radix = 10;
  (void) mp_radix_size_overestimate(self, radix, &size); // TODO: error handing.
  char* buf = malloc(size + 1);
  (void) mp_to_radix(self, buf, size, &written, radix); // TODO: error handing.
  buf[written] = 0;
  return buf;
}

mp_int* swig_mp_int_new(mp_digit n) {
  mp_int* self = malloc(sizeof(*self));
  (void) mp_init(self); // TODO: error handing.
  mp_set(self, n);
  return self;
}

void swig_mp_int_delete(mp_int* self) {
  mp_clear(self);
  free(self);
}
