#!/usr/bin/env guile
!#

;; Load SWIG bindings:
(load-extension "target/guile/libexample1_swig.so" "SWIG_init")

;; Use SWIG bindings:
(write `(EXAMPLE1-VERSION = ,(EXAMPLE1-VERSION)))
(newline)
(write (cubic-poly 2.0 3.0 5.0 7.0 11.0))
(newline)
