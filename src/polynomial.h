#include <vector>

#define POLYNOMIAL_VERSION "1.2.1"

class Polynomial {
public:
  std::vector<double> coeffs;
  double evaluate(double x) const;
};

