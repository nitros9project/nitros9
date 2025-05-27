********************************************************************
* Parallel - Disto Parallel Printer driver
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*  12    ???

                    nam       Parallel
                    ttl       Disto Parallel Printer driver

* Disassembled 98/08/25 13:20:51 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       29
u001D               rmb       1
u001E               rmb       1
u001F               rmb       1
size                equ       .

                    fcb       UPDAT.

name                fcs       /Parallel/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

Read                comb
                    ldb       #E$BMode
                    rts

Write               ldb       >MPI.Slct
                    andb      #$33
                    pshs      b
                    ldb       #$33
                    stb       >MPI.Slct
                    tst       >$FF52
                    bmi       Nap
L003E               sta       >$FF52
                    sta       >$FF52
                    puls      b
                    stb       >MPI.Slct
                    clrb
                    rts

Nap                 ldx       #$0001
                    os9       F$Sleep
                    tst       >$FF52
                    bpl       L003E
                    bra       Nap

SetStat             comb
                    ldb       #E$UnkSvc
                    rts

GetStat             cmpa      #SS.ScSiz
                    bne       SetStat
                    ldx       PD.RGS,y
                    clra
                    ldb       <u001D,u
                    std       R$X,x
                    ldb       <u001E,u
                    std       R$Y,x
Term                clra
                    lbra      Write
                    lbra      Write
                    lbra      Write
                    clrb
                    rts

Init                ldd       <$2C,y
                    std       <u001D,u
                    lda       ,y
                    sta       <u001F,u
                    clrb
                    rts

                    emod
eom                 equ       *
                    end

