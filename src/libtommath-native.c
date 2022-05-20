#include "libtommath.h"

static void print(const char* n, mp_int *v) {
  printf("%s = ", n);
  mp_fwrite(v, 10, stdout);
  printf("\n");
}

int main(int argc, char **argv) {
  mp_int a, b, c, d;
  mp_init_multi(&a, &b, &c, &d, NULL);
  
  (void) mp_set(&a, 2357111317);
  (void) mp_set(&b, 1113171923);
  (void) mp_mul(&a, &b, &c);
  (void) mp_mul(&c, &b, &d);

#define P(N) print(#N, &N);
  P(a); P(b); P(c); P(d); 
  mp_clear_multi(&a, &b, &c, &d, NULL);
  return 0;
}

