;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "polynomial_v2_swig")

(import 'polynomial_v2_swig)

(prn {:POLYNOMIAL_VERSION (polynomial_v2_swig/POLYNOMIAL_VERSION)})

(def p1 (PolynomialDoubleV2.))
(.setCoeffs p1 (VectorDoubleV2. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))
(prn (.getCoeffs p1))
(prn (.evaluate p1 1.2))

(def p2 (PolynomialRationalV2.))
(.setCoeffs p2 (VectorRationalV2. [ (RationalV2. 7 11) (RationalV2. 11 13) (RationalV2. 13 17) ]))
(prn (mapv #(.__str__ %) (.getCoeffs p2)))
(prn (.__str__ (.evaluate p2 (RationalV2. 5, 7))))
