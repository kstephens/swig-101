#include "libtommath.h"
#include <stdlib.h>

char* mp_int_to_charP(mp_int* self) {
  size_t size = 0, written = 0;
  int radix = 10;
  mp_radix_size_overestimate(self, radix, &size); // TODO: error handing.
  char* buf = malloc(size + 1);
  mp_to_radix(self, buf, size, &written, radix);
  buf[written] = 0;
  return buf;
}
