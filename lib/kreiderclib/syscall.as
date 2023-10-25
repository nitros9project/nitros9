* Disassembly by Os9disasm of syscall.r

                    section   code

_os9                pshs      y,u
                    lda       7,s
                    ldb       #$39
                    pshs      d
                    ldd       #$103f
                    pshs      d
                    ldu       12,s
                    ldd       1,u
                    ldx       4,u
                    ldy       6,u
                    ldu       8,u
                    jsr       ,s
                    pshs      cc,u
                    ldu       15,s
                    leau      8,u
                    pshu      d,dp,x,y
                    puls      a,x
                    sta       ,-u
                    stx       8,u
                    leas      4,s
                    puls      y,u
                    bita      #1
                    beq       L0034
                    ldd       #-1
                    rts
L0034               clra
                    clrb
                    rts

                    endsect

