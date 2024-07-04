                    export    chown
                    
                    section   code

chown               pshs      y,u
                    leas      -16,s
                    os9       F$ID
                    bcs       L002a
                    ldb       #$d6
                    cmpy      #0
                    orcc      #1
                    bne       L002a
                    bsr       L0032
                    bcs       L002a
                    pshs      a
                    ldd       25,s
                    std       1,x
                    puls      a
                    ldb       #$0f
                    os9       I$SetStt
                    bcs       L002a
                    os9       I$Close
L002a               leas      16,s
                    puls      y,u
                    lbra      _sysret
L0032               lda       #2
                    ldx       24,s
                    os9       I$Open
                    bcc       L003d
                    rts
L003d               leax      2,s
                    ldy       #$0010
                    ldb       #$0f
                    os9       I$GetStt
                    rts

                    endsect

