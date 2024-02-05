#!/usr/bin/env guile
!#

(load-extension "target/guile/libpolynomial_swig.so" "SWIG_init")

(display `(POLYNOMIAL-VERSION = ,(POLYNOMIAL-VERSION))) (newline)

(define p (new-Polynomial))

(Polynomial-coeffs-set p (new-VectorDouble '(3 5.0 7.0 11.0)))
(write (Polynomial-coeffs-get p)) (newline)
(write (Polynomial-evaluate p 2)) (newline)

(Polynomial-coeffs-set p (new-VectorDouble '(2.3 3.5 5.7 7.11 11.13 -13.17)))
(write (Polynomial-coeffs-get p)) (newline)
(write (Polynomial-evaluate p 1.2)) (newline)
