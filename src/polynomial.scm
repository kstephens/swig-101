#!/usr/bin/env guile
!#

(load-extension "target/guile/libpolynomial_swig.so" "SWIG_init")

(define p (new-Polynomial))
(Polynomial-coeffs-set p (new-VectorDouble '(2.0 3.0 5.0 7.0 11.0 -13.0)))

(write `(POLYNOMIAL-VERSION = ,(POLYNOMIAL-VERSION))) (newline)
(write (Polynomial-coeffs-get p)) (newline)
(write (Polynomial-evaluate p 2.0)) (newline)