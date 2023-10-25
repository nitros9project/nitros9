* Disassembly by Os9disasm of case.r

                    section   code

toupper             clra
                    ldb       3,s
                    leax      _chcodes,y
                    lda       d,x
                    anda      #4
                    beq       L0022
                    andb      #$df
                    clra
                    rts
tolower             clra
                    ldb       3,s
                    leax      _chcodes,y
                    lda       d,x
                    anda      #2
                    beq       L0022
                    orb       #$20
                    clra
                    rts
L0022               ldd       2,s
                    rts

                    endsect

