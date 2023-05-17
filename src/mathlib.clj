;; -*- clojure -*-

;; Load SWIG bindings:
(clojure.lang.RT/loadLibrary "mathlib_swig")
(import 'mathlib_swig)

;; Use SWIG bindings:
(println (format "MATHLIB_VERSION = \"%s\""
               	 (mathlib_swig/MATHLIB_VERSION)))
(prn (mathlib_swig/cubic_poly 2.0 3.0 5.0 7.0 11.0))
