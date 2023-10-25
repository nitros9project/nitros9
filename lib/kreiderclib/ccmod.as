* Disassembly by Os9disasm of ccmod.r

                    section   bss

* Uninitialized data (class B)
B0000               rmb       1
B0001               rmb       2
* Initialized Data (class G)

                    endsect

                    section   code

ccumod              clr       B0000,y
                    leax      ccudiv,pcr
                    stx       B0001,y
                    bra       L0022
ccmod               leax      ccdiv,pcr
                    stx       B0001,y
                    clr       B0000,y
                    tst       2,s
                    bpl       L0022
                    inc       B0000,y
L0022               subd      #0
                    bne       L002d
                    puls      x
                    ldd       ,s++
                    jmp       ,x
L002d               ldx       2,s
                    pshs      x
                    jsr       [B0001,y]
                    ldd       ,s
                    std       2,s
                    tfr       x,d
                    tst       B0000,y
                    beq       L0045
                    nega
                    negb
                    sbca      #0
L0045               std       ,s++
                    rts

                    endsect

