#pragma once
#include <vector>

#define POLYNOMIAL_VERSION "2.0.2"

namespace mathlib {
  template < typename R >
  class polynomial {
  public:
    std::vector< R > coeffs;
    R evaluate(const R &x) const;
  };
}
