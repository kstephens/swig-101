;; -*- clojure -*-

(clojure.lang.RT/loadLibrary "example1_swig")

(import 'example1_swig)

(println (format "EXAMPLE1_VERSION = %s"
               	 (example1_swig/EXAMPLE1_VERSION)))
(prn (example1_swig/cubic_poly 2.0 3.0 5.0 7.0 11.0))

