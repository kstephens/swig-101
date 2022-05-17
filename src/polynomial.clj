;; -*- clojure -*-

;; Load Java bindings dynamic library:
(clojure.lang.RT/loadLibrary "polynomial_swig")

;; Import Java namespace:
(import 'polynomial_swig)

;; #define constants:
(prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})

;; Instantiate object:
(def p (Polynomial.))
(.setCoeffs p (VectorDouble. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))

;; Invoke methods:
(prn (.getCoeffs p))
(prn (.evaluate p 1.2))
