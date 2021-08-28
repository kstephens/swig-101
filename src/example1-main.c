#include <stdio.h>
#include "example1.h"

int main(int argc, char **argv) {
  printf("%.14f\n", cubic_poly(2.3, 3.5, 7.11, 13.17, 19.23));
  return 0;
}
