* Disassembly by Os9disasm of gs2.r

                    section   code

* OS-9 system function equates

I$GetStt            equ       $8d

_gs_rdy             ldb       #1
                    lda       3,s
                    os9       I$GetStt
                    lblo      _os9err
                    clra
                    rts
_gs_eof             ldb       #6
                    bra       L0015
_gs_opt             ldb       #0
                    ldx       4,s
L0015               lda       3,s
                    os9       I$GetStt
                    bra       L0042
_gs_devn            ldb       #$0e
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
_gs_gfd             pshs      y
                    ldb       #$0f
                    lda       5,s
                    ldx       6,s
                    ldy       8,s
                    os9       I$GetStt
                    puls      y
L0042               lbra      _sysret

                    endsect

