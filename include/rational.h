#pragma once
#include <numeric> // gcd()
#include <sstream>
#include <iostream>

namespace mathlib {
  template <typename I>
  class rational {
  public:
    I n, d;
    void reduce() {
      if ( d < 0 ) {
        d = - d;
        n = - n;
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
    bool operator == (const rational<I> &y) const {
      return n == y.n && d == y.d;
    }
    std::string __str__() const {
      std::ostringstream os(std::ostringstream::out);
      os << n << "/" << d;
      return os.str();
    }
    std::string __repr__() const {
      std::ostringstream os(std::ostringstream::out);
      os << class_name() << "(" << n << "," << d << ")";
      return os.str();
    }
    static const std::string& class_name() {
      static const std::string
        pretty_function(__PRETTY_FUNCTION__),
        left_anchor(" &mathlib::"),
        right_anchor("::class_name()"),
        type_name_left(pretty_function.substr(pretty_function.find(left_anchor) + left_anchor.length())),
        type_name(type_name_left.substr(0, type_name_left.find(right_anchor)));
      return type_name;
    }
  };
  template <typename I>
  std::ostream& operator << (std::ostream& os, const rational<I> &r) {
    return os << r.n << "/" << r.d;
  }
}
