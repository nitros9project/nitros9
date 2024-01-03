;;; COMPARE
;;;
;;; Compares two characters.
;;;
;;; Other modules needed: TO_UPPER
;;;
;;; Entry:  A = The first comparison value.
;;;         B = The second comparison value.
;;;
;;; Exit:  CC = Zero bit set if the characters match.
;;;
;;; Set CASEMTCH = 0 for non-case comparison, or -1 for case comparison.
;;;
;;; All registers (except CC) are preserved.

                    section   .bss

CASEMTCH            rmb       1

                    endsect

                    section   .text

COMPARE:            pshs      d
                    tst       CASEMTCH            need to covert to upper?
                    bpl       no
                    lbsr      TO_UPPER
                    exg       a,b
                    lbsr      TO_UPPER
no                  pshs      a                   somewhere to compare it
                    cmpb      ,s+                 do compare, set zero
                    puls      d,pc                go home

                    endsect
