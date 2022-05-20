#include "libtommath.h"

static void print(const char* n, mp_int *v) {
  printf("%s = ", n);
  mp_fwrite(v, 10, stdout);
  printf("\n");
}

int main(int argc, char **argv) {
  mp_int a, b, c, d;
#define DO(F) (void) F(a); (void) F(b); (void) F(c); (void) F(d)
#define INIT(N)   mp_init(&N);
  DO(INIT);
  
  (void) mp_set(&a, 2357111317);
  (void) mp_set(&b, 1113171923);
  (void) mp_mul(&a, &b, &c);
  (void) mp_mul(&c, &b, &d);

#define PRINT(N)  print(#N, &N);
  DO(PRINT);
#define CLEAR(N)  mp_clear(&N);
  DO(CLEAR);
  return 0;
}

