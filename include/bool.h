// Wierd workaround for C99 bool.
// #include <stdbool.h> // C99
#ifndef bool
#define bool   _Bool
#define true   1
#define false  0
#endif
