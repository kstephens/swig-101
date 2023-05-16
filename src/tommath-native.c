#include "libtommath/tommath.h"

int main(int argc, char **argv) {
  printf("MP_ITER = %d\n", MP_ITER);

  mp_int a, b, c, d, e;

  (void) mp_init_multi(&a, &b, &c, &d, &e, NULL);

  (void) mp_set(&a, 2357111317);
  (void) mp_set(&b, 1113171923);
  (void) mp_read_radix(&e, "12343456", 16);

  (void) mp_mul(&a, &b, &c);
  (void) mp_mul(&c, &b, &d);

#define P(N) printf("%s = ", #N); (void) mp_fwrite(&N, 10, stdout); fputc('\n', stdout);
  P(a); P(b); P(c); P(d); P(e);
  mp_clear_multi(&a, &b, &c, &d, &e, NULL);

  return 0;
}

