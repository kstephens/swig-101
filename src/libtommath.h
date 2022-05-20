#include <stdbool.h> // C99
#define bool   _Bool
#define true   1
#define false  0
#include "tommath.h"

char*    mp_int_to_charP(mp_int* self);
mp_int*  mp_int_new(mp_digit n);
void     mp_int_delete(mp_int* self);
