#include <stdio.h>
#include "example1.h"

int main(int argc, char **argv) {
  printf("%g\n", cubic_poly(2.0, 3.0, 5.0, 7.0, 11.0));
  return 0;
}
