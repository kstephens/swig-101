;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "polynomial_swig")
(import 'polynomial_swig)

(prn {:POLYNOMIAL_VERSION (polynomial_swig/POLYNOMIAL_VERSION)})

(def p (Polynomial.))

;; Note: does not coerce java.lang.Long 3 to 3.0
(.setCoeffs p (VectorDouble. [ 3.0 5.0 7.0 11.0 ])) 
(prn (.getCoeffs p))
(prn (.evaluate p 2))

(.setCoeffs p (VectorDouble. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))
(prn (.getCoeffs p))
(prn (.evaluate p 1.2))
