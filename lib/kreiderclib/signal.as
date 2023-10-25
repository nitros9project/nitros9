* Disassembly by Os9disasm of signal.r

* OS-9 system function equates

F$Exit              equ       $06
F$Icpt              equ       $09

                    section   bss

* Uninitialized data (class B)
B0000               rmb       60
B003c               rmb       1
* Initialized Data (class G)

                    endsect

                    section   code

_sigint             ldd       2,s
                    tstb
                    beq       L000c
                    tsta
                    bne       L000c
                    bsr       L003c
                    bne       L0010
L000c               ldd       #-1
                    rts
L0010               ldd       1,x
                    pshs      d
                    ldd       6,s
                    std       1,x
                    bne       L001e
                    clr       ,x
L001c               puls      d,pc
L001e               ldb       5,s
                    stb       ,x
                    tst       B003c,y
                    bne       L001c
                    exg       y,u
                    leax      >L006a,pcr
                    os9       F$Icpt
                    exg       y,u
                    puls      d
                    bcs       L000c
                    inc       B003c,y
                    rts
L003c               clr       ,-s
                    clr       ,-s
                    leax      B003c,y
                    pshs      x
                    leax      B0000,y
L004a               cmpx      ,s
                    beq       L0065
                    cmpb      ,x
                    bne       L0057
                    leas      4,s
                    andcc     #251
                    rts
L0057               lda       ,x
                    ora       2,s
                    ora       3,s
                    bne       L0061
                    stx       2,s
L0061               leax      3,x
                    bra       L004a
L0065               ldx       2,s
                    leas      4,s
                    rts
L006a               leay      ,u
                    bsr       L003c
                    beq       L0076
                    pshs      x
                    ldx       1,x
                    bne       L0081
L0076               os9       F$Exit
                    cmpx      #1
                    bne       L0081
                    leas      2,s
                    rti
L0081               clra
                    pshs      d
                    jsr       ,x
                    puls      d,x
                    clra
                    clrb
                    sta       ,x
                    std       1,x
                    rti

                    endsect

