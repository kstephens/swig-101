#include <stdio.h>
#include "black_scholes.h"

int main(int argc, char **argv) {
  double data[][5] = {
    // strike_price, asset_price, standard_deviation, risk_free_rate,  days_to_expiry:
    // vary expiry:
    { 1.50, 2.00, 0.5,  2.25, 30 },
    { 1.50, 2.00, 0.5,  2.25, 15 },
    { 1.50, 2.00, 0.5,  2.25, 10 },
    { 1.50, 2.00, 0.5,  2.25,  5 },
    { 1.50, 2.00, 0.5,  2.25,  2 },
     // vary strike:
    { 0.50, 2.00, 0.25, 2.25, 15 },
    { 1.00, 2.00, 0.25, 2.25, 15 },
    { 1.50, 2.00, 0.25, 2.25, 15 },
    { 2.00, 2.00, 0.25, 2.25, 15 },
    { 2.50, 2.00, 0.25, 2.25, 15 },
    { 3.00, 2.00, 0.25, 2.25, 15 },
    { 3.50, 2.00, 0.25, 2.25, 15 },
  };
  for ( int i = 0; i < sizeof(data) / sizeof(data[0]); i ++ ) {
    double *r = data[i];
    double c = black_scholes_call (r[0], r[1], r[2], r[3], r[4]);
    double p = black_scholes_put  (r[0], r[1], r[2], r[3], r[4]);
    printf("{ 'inputs': [ %6.3f, %6.3f, %6.3f, %6.3f, %6.3f ], 'call': %6.3f, 'put': %6.3f }\n",
      r[0], r[1], r[2], r[3], r[4], c, p);
  }
  return 0;
}