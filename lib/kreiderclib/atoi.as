                    export    _atoi
                    
                    section   code

;;; #include <math.h>
;;;
;;; int atoi(char *str)
;;;
;;; Convert a string to an integer.
;;;
;;; This function recognizes an optional number of spaces, an optional sign, and a series of digits. For example: "-2333".
;;;
;;; Overflow causes unpredictable results, and the function doesn't return any error.

_atoi               pshs      u
                    ldu       4,s
                    clra
                    clrb
                    pshs      d
                    pshs      b
L000a               ldb       ,u+
                    cmpb      #$20
                    beq       L000a
                    cmpb      #9
                    beq       L000a
                    cmpb      #$2d
                    bne       L001c
                    stb       ,s
                    bra       L0037
L001c               cmpb      #$2b
                    bne       L0039
                    bra       L0037
L0022               ldd       1,s
                    lslb
                    rola
                    lslb
                    rola
                    addd      1,s
                    lslb
                    rola
                    pshs      d
                    ldb       -1,u
                    clra
                    subb      #$30
                    addd      ,s++
                    std       1,s
L0037               ldb       ,u+
L0039               cmpb      #$30
                    bcs       L0041
                    cmpb      #$39
                    bls       L0022
L0041               tst       ,s+
                    puls      d
                    beq       L004b
                    nega
                    negb
                    sbca      #0
L004b               puls      u,pc

                    endsect

