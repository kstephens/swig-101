;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "polynomial_v2_swig")
(import 'polynomial_v2_swig)

(prn {:POLYNOMIAL_VERSION (polynomial_v2_swig/POLYNOMIAL_VERSION)})

;; Instantiate polynomial<double> object:
(def p1 (PolynomialDoubleV2.))
(.setCoeffs p1 (VectorDoubleV2. [ 2.3 3.5 5.7 7.11 11.13 -13.17 ]))
(prn (.getCoeffs p1))
(prn (.evaluate p1 1.2))

;; Instantiate polynomial<int> object:
(def p2 (PolynomialIntV2.))
(.setCoeffs p2 (VectorIntV2. (map int [2 3 5 7 11 -13])))
(prn (.getCoeffs p2))
(prn (.evaluate p2 -2))

;; Instantiate polynomial<rational<int>> object:
(def p3 (PolynomialRationalV2.))
(.setCoeffs p3 (VectorRationalV2. [ (RationalV2. 7 11) (RationalV2. 11 13) (RationalV2. 13 17) ]))
(prn (mapv #(.__str__ %) (.getCoeffs p3)))
(prn (.__str__ (.evaluate p3 (RationalV2. 5, 7))))
