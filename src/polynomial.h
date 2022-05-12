#include <vector>
#define POLYNOMIAL_VERSION "2.3.5"
class Polynomial {
 public:
  std::vector<double> coeffs;
  double evaluate(double x);
};

