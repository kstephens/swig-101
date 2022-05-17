#pragma once
#include <numeric> // gcd()
#include <sstream>

namespace mathlib {
  template <typename I>
  class rational {
  public:
    I n, d;
    void reduce() {
      if ( n < 0 || d < 0 ) {
        n = - n; d = - d;
      }
      I c(std::gcd(n, d));
      n /= c; d /= c;
    }
   rational() : n(0), d(1) { }
   rational(const rational<I> &r) : n(r.n), d(r.d) { }
   rational(const I &n_) : n(n_), d(1) { }
   rational(const I &n_, const I &d_) : n(n_), d(d_) { reduce(); }
    rational<I>  operator +  (const rational<I> &y) const {
      return rational<I>(n * y.d + y.n * d, d * y.d);
    }
    rational<I>  operator *  (const rational<I> &y) const {
      return rational<I>(n * y.n, d * y.d);
    }
    int operator == (const rational<I> &y) const {
      return n == y.n && d == y.d; 
    }
    std::string __str__() const {
      std::ostringstream oss(std::ostringstream::out);
      oss << n << "/" << d;
      return oss.str();
    }
    std::string __repr__() const {
      return this->__str__();
    }
  };

  template <typename I>
  std::ostream& operator << (std::ostream& os, const rational<I> &r) {
    return os << r.n << "/" << r.d;
  }
}
