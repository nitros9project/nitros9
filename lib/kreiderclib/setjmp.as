                    export    _setjmp
                    export    _longjmp
                    
                    section   code

_setjmp             ldx       2,s
                    ldd       ,s
                    std       2,x
                    sty       6,x
                    stu       4,x
                    sts       ,x
                    clra
                    clrb
                    rts
                    
_longjmp            ldx       2,s
                    ldy       6,x
                    ldu       4,x
                    ldd       4,s
                    bne       L001e
                    ldb       #1
L001e               lds       ,x
                    leas      2,s
                    jmp       [2,x]

                    endsect

