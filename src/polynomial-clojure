;; -*- clojure -*-

;; Load Java bindings dynamic library:
(clojure.lang.RT/loadLibrary "polynomial_swig")

;; Import Java namespace:
(import 'polynomial_swig)

;; Instantiate object:
(def p (Polynomial.))
(.setCoeffs p (VectorDouble. [2.0 3.0 5.0 7.0 11.0 -13.0]))

;; Invoke methods:
(prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})
(prn (.getCoeffs p))
(prn (.evaluate p 2.0))
