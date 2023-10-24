* Disassembly by Os9disasm of open.r

                    section   code

* OS-9 system function equates

I$Open              equ       $84
I$Close             equ       $8f

open                ldx       2,s
                    lda       5,s
                    os9       I$Open
                    lblo      _os9err
                    tfr       a,b
                    clra
                    rts
close               lda       3,s
                    os9       I$Close
                    lbra      _sysret

                    endsect

