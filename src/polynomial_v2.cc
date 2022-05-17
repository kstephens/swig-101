#include "polynomial_v2.h"
#include "rational.h"

namespace mathlib {
  template < typename R >
  R polynomial< R >::evaluate(const R &x) const {
    R result(0), xx(1);
    for ( const auto &c : this->coeffs ) {
      result = result + c * xx;
      xx = xx * x;
    }
    return result;
  };

  // Instantiate templates:
  template class polynomial<int>;
  template class polynomial<double>;
  template class polynomial<rational<int>>;
}
