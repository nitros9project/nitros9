                    export    __gs_rdy
                    export    __gs_eof
                    export    __gs_opt
                    export    __gs_devn
                    export    __gs_gfd
                    
                    section   code

__gs_rdy            ldb       #1
                    lda       3,s
                    os9       I$GetStt
                    lblo      _os9err
                    clra
                    rts
__gs_eof            ldb       #6
                    bra       L0015
                    
__gs_opt            ldb       #0
                    ldx       4,s
L0015               lda       3,s
                    os9       I$GetStt
                    bra       L0042
                    
__gs_devn           ldb       #$0e
                    ldx       4,s
                    lda       3,s
                    os9       I$GetStt
                    bcs       L0042
L0027               lda       ,x+
                    bpl       L0027
                    anda      #$7f
                    sta       -1,x
                    clr       ,x
                    rts
                    
__gs_gfd            pshs      y
                    ldb       #$0f
                    lda       5,s
                    ldx       6,s
                    ldy       8,s
                    os9       I$GetStt
                    puls      y
L0042               lbra      _sysret

                    endsect

