#ifdef SWIG
%module example1
%{
#include "example1.h"
%}
#endif

double cubic_poly(double x, double c0, double c1, double c2, double c3);
