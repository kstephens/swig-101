#!/usr/bin/env guile
!#

(load-extension "target/guile/libtommath_swig.so" "SWIG_init")

(write `(MP-ITER ,(MP-ITER))) (newline)

(define a (new-mp-int))
(mp-set a 2357111317);    # <-- awkward!
(define b (new-mp-int 1113171923));                 # <-- better!
(define c (new-mp-int))
(define d (new-mp-int))
(define e (new-mp-int "12343456" 16));             # <-- yey!

(define (show!)
(let ((r mp-int---str--))
  (write `(a ,(r a) b ,(r b) c ,(r c) d ,(r d) e ,(r e)))
  (newline)))

(show!)

(mp-mul a b c)
(mp-mul c b d)

(show!)

