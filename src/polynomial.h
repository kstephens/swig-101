#include <vector>
#define POLYNOMIAL_VERSION "2.3.5"
class Polynomial {
 public:
  std::vector<double> coeffs;
  /* Returns: coeffs[0] + coeefs[1] * pow(x, 1) + coeefs[2] * pow(x, 2) ... */
  double evaluate(double x);
};

