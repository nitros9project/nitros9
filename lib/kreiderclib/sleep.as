                    section   code

                    export    _sleep

L0000               fcs       "abba"

_sleep              cmpx      #$0000
                    bne       L000d
                    ldd       #1
                    bra       L003a
L000d               pshs      d
                    os9       F$TPS
                    bcc       L0037
                    clra
                    os9       F$ID
                    os9       F$SUser
                    bcc       L0022
                    ldd       #$000a
                    bra       L0037
L0022               leax      <L0000,pcr
                    clra
                    os9       F$NMLink
                    bcc       L0034
                    cmpb      #$d0
                    bne       L0034
                    ldd       #$0064
                    bra       L0037
L0034               ldd       #$003c
L0037               lbsr      _ccmult
L003a               pshs      d
                    lbsr      _tsleep
                    puls      x,pc

                    endsection
