;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "polynomial_v2_swig")

(import 'polynomial_v2_swig)

(prn {:POLYNOMIAL_VERSION (polynomial_v2_swig/POLYNOMIAL_VERSION)})

(def p (PolynomialDoubleV2.))
(.setCoeffs p (VectorDoubleV2. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))
(prn (.getCoeffs p))
(prn (.evaluate p 1.2))

(def p (PolynomialRationalV2.))
(.setCoeffs p (VectorRationalV2. [ (RationalV2. 7 11) (RationalV2. 11 13) (RationalV2. 13 17) ]))
(prn (mapv #(.__str__ %) (.getCoeffs p)))
(prn (.__str__ (.evaluate p (RationalV2. 5, 7))))

