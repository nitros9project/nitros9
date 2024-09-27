;;; int abs(int i)
;;;
;;; Return the absolute value of an integer.
;;;
;;; Note: Applying abs() to the most negative integer generates a result which is the most negative integer.
;;; That is, abs(0x80000000) returns 0x80000000.

                    export    _abs
                    
                    section   code

_abs                ldd       2,s
                    bpl       ex@
                    nega
                    negb
                    sbca      #0
ex@                 rts

                    endsect

