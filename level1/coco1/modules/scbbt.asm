********************************************************************
* scbbt - CoCo Bit-Banger Terminal Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   9      ????/??/??  ???
* Original Tandy L2 distribution version.
*
*  10      ????/??/??  ???
* Added baud delay table for NitrOS-9.
*
*  11      2003/12/15  Boisy G. Pitre
* Merged Level 1 and Level 2 sources for now.

                    nam       scbbt
                    ttl       CoCo Bit-Banger Terminal Driver

* Disassembled 98/08/23 20:58:36 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       9

                    mod       eom,name,tylg,atrv,start,size

                    fcb       UPDAT.

name                fcs       /scbbt/
                    fcb       edition

                    ifgt      Level-1

u0000               rmb       29
u001D               rmb       1
u001E               rmb       1
u001F               rmb       1
u0020               rmb       2
u0022               rmb       2
u0024               rmb       1
u0025               rmb       1
size                equ       .

* Baud Rate Delay Table
DelayTbl
                    ifeq      H6309
* 6809 delay values (1.89MHz)
                    fdb       $090C               110 baud
                    fdb       $034C               300 baud
                    fdb       $01A2               600 baud
                    fdb       $00CE               1200 baud
                    fdb       $0062               2400 baud
                    fdb       $002E               4800 baud
                    fdb       $0012               9600 baud
                    fdb       $0003               32000 baud
                    else
* 6309 native mode delay values (1.89MHz)
                    fdb       $090C               110 baud (Unchanged, unknown)
                    fdb       $03D0               300 baud
                    fdb       $01A2               600 baud (Unchanged, unknown)
                    fdb       $00F0               1200 baud
                    fdb       $0073               2400 baud
                    fdb       $0036               4800 baud
                    fdb       $0017               9600 baud
                    fdb       $0003               32000 baud (Unchanged, unknown)
                    endc

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                pshs      cc
                    orcc      #IntMasks
                    ldx       #PIA1Base
                    clr       $01,x
                    ldd       <IT.COL,y           get col/row bytes
                    std       <u0024,u
                    lda       #$FE
                    sta       ,x
                    lda       #$36
                    sta       $01,x
                    lda       ,x
                    ldd       <IT.PAR,y           get parity/baud
                    lbsr      L0148
                    puls      cc
                    clrb

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                rts

* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
Read                bsr       L00AC
                    bcs       L00C8
                    ldb       #$08
                    pshs      b,cc
                    tst       <u001E,u
                    beq       L0066
                    dec       $01,s
L0066               bra       L0077
L0068               lda       <PD.BAU,y
                    anda      #$0F
                    cmpa      #$07
                    beq       L0077
                    ldx       #$0001
                    os9       F$Sleep
L0077               pshs      y
                    ldy       #$FFFF
L007D               lda       >PIA1Base+2
                    leay      -$01,y
                    beq       L008B
                    lsra
                    bcs       L007D
                    puls      y
                    bra       L0090
L008B               puls      y
                    lsra
                    bcs       L0068
L0090               orcc      #IntMasks
                    clra
                    bsr       L00D5
L0095               bsr       L00CE
                    ldb       >PIA1Base+2
                    lsrb
                    rora
                    dec       $01,s
                    bne       L0095
                    bsr       L00D5
                    tst       <u001E,u
                    beq       L00A8
                    lsra
L00A8               puls      b,cc
                    clrb
                    rts
L00AC               pshs      a
                    lda       <PD.BAU,y
                    anda      #$0F
                    cmpa      #$08
                    bcc       L00C4
                    lsla
                    leax      >DelayTbl,pcr
                    ldd       a,x
                    std       <u0020,u
                    clrb
                    puls      pc,a
L00C4               ldb       #E$BMode
                    puls      a
L00C8               orcc      #Carry
                    rts
L00CB               stb       >PIA1Base
L00CE               pshs      b,a
                    ldd       <u0020,u
                    bra       L00DC
L00D5               pshs      b,a
                    ldd       <u0020,u
                    lsra
                    rorb
L00DC               subd      #$0001
                    bne       L00DC
                    puls      pc,b,a

* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               bsr       L00AC
                    bcs       L00C8
                    ldb       #$09
                    pshs      b,cc
                    orcc      #IntMasks
                    tst       <u001E,u
                    beq       L00F4
                    dec       $01,s
L00F4               andcc     #^Carry
L00F6               ldb       #$02
                    bcs       L00FB
                    clrb
L00FB               bsr       L00CB
                    lsra
                    dec       $01,s
                    bne       L00F6
                    ldb       <u001D,u
                    beq       L010B
                    andb      #$FE
                    bsr       L00CB
L010B               ldb       #$02
                    bsr       L00CB
                    tst       <u001F,u
                    beq       L0118
                    ldb       #$02
                    bsr       L00CB
L0118               puls      pc,b,cc

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             cmpa      #SS.EOF
                    bne       L0120
L011E               clrb
                    rts
L0120               ldx       PD.RGS,y
                    cmpa      #SS.ScSiz
                    beq       L0131
                    cmpa      #SS.ComSt
                    bne       L017E
                    ldd       <u0022,u
                    std       R$Y,x
                    bra       L011E
L0131               ldx       PD.RGS,y
                    clra
                    ldb       <u0024,u
                    std       R$X,x
                    ldb       <u0025,u
                    std       R$Y,x
                    bra       L011E

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat             cmpa      #SS.ComSt
                    bne       L017E
                    ldx       PD.RGS,y
                    ldd       R$Y,x
L0148               std       <u0022,u
                    clra
                    clrb
                    std       <u001D,u
                    sta       <u001F,u
                    ldd       <u0022,u
                    tstb
                    bpl       L015C
                    inc       <u001F,u
L015C               bitb      #$40
                    bne       L017A
                    bitb      #$20
                    beq       L0167
                    inc       <u001E,u
L0167               bita      #$20
                    beq       L0179
                    bita      #$80
                    beq       L017A
                    inc       <u001D,u
                    bita      #$40
                    bne       L0179
                    inc       <u001D,u
L0179               rts
L017A               comb
                    ldb       #E$BMode
                    rts
L017E               comb
                    ldb       #E$UnkSvc
                    rts

                    else

                    rmb       V.SCF
u001D               rmb       1
u001E               rmb       1
u001F               rmb       1
BaudCnt             rmb       2                   baud rate counter
u0022               rmb       2
u0024               rmb       1
u0025               rmb       1
size                equ       .

BaudTbl             fdb       $0482               110 baud
                    fdb       $01A2               300 baud
                    fdb       $00CD               600 baud
                    fdb       $0063               1200 baud
                    fdb       $002D               2400 baud
                    fdb       $0013               4800 baud
                    fdb       $0005               9600 baud

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                pshs      cc
                    orcc      #IntMasks
                    ldx       #PIA1Base
                    clr       $01,x
                    ldd       <IT.COL,y           get col/row bytes
                    std       <u0024,u
                    lda       #$FE
                    sta       ,x
                    lda       #$36
                    sta       $01,x
                    lda       ,x
                    ldd       <IT.PAR,y           get parity/baud
                    lbsr      L014D
                    puls      cc
                    clrb

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                rts

* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
Read                bsr       L00B1
                    bcs       L00CD
                    ldb       #$08
                    pshs      b,cc
                    tst       <u001E,u
                    beq       L0066
                    dec       $01,s
L0066               bra       L006E
L0068               ldx       #$0001
                    os9       F$Sleep
L006E               lda       >PIA1Base+2
                    lsra
                    pshs      x,a
                    lda       >$FF69
                    bpl       L0091
                    lda       >PIA1Base+3
                    bita      #$01
                    beq       L0091
                    bita      #$80
                    beq       L0091
                    orcc      #Entire
                    leax      <L0091,pcr
                    pshs      x
                    pshs      u,y,x,dp,b,a,cc
                    jmp       [D.SvcIRQ]
L0091               puls      x,a
                    bcs       L0068
                    orcc      #IntMasks
                    clra
                    bsr       L00DA
L009A               bsr       L00D3
                    ldb       >PIA1Base+2
                    lsrb
                    rora
                    dec       $01,s
                    bne       L009A
                    bsr       L00DA
                    tst       <u001E,u
                    beq       L00AD
                    lsra
L00AD               puls      b,cc
                    clrb
                    rts
L00B1               pshs      a
                    lda       <PD.BAU,y
                    anda      #$0F                mask out baud rate
                    cmpa      #B19200
                    bcc       L00C9
                    lsla
                    leax      >BaudTbl,pcr
                    ldd       a,x
                    std       <BaudCnt,u
                    clrb
                    puls      pc,a
L00C9               ldb       #E$BMode
                    puls      a
L00CD               orcc      #Carry
                    rts
L00D0               stb       >PIA1Base
L00D3               pshs      b,a
                    ldd       <BaudCnt,u
                    bra       L00E1
L00DA               pshs      b,a
                    ldd       <BaudCnt,u
                    lsra
                    rorb
L00E1               subd      #$0001
                    bne       L00E1
                    puls      pc,b,a

* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write               bsr       L00B1
                    bcs       L00CD
                    ldb       #$09
                    pshs      b,cc
                    orcc      #IntMasks
                    tst       <u001E,u
                    beq       L00F9
                    dec       $01,s
L00F9               andcc     #^Carry
L00FB               ldb       #$02
                    bcs       L0100
                    clrb
L0100               bsr       L00D0
                    lsra
                    dec       $01,s
                    bne       L00FB
                    ldb       <u001D,u
                    beq       L0110
                    andb      #$FE
                    bsr       L00D0
L0110               ldb       #$02
                    bsr       L00D0
                    tst       <u001F,u
                    beq       L011D
                    ldb       #$02
                    bsr       L00D0
L011D               puls      pc,b,cc

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             cmpa      #SS.EOF
                    bne       L0125
L0123               clrb
                    rts
L0125               ldx       PD.RGS,y
                    cmpa      #SS.ScSiz
                    beq       L0136
                    cmpa      #SS.ComSt
                    bne       L0183
                    ldd       <u0022,u
                    std       R$Y,x
                    bra       L0123
L0136               ldx       PD.RGS,y
                    clra
                    ldb       <u0024,u
                    std       R$X,x
                    ldb       <u0025,u
                    std       R$Y,x
                    bra       L0123

* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat             cmpa      #SS.ComSt
                    bne       L0183
                    ldx       PD.RGS,y
                    ldd       R$Y,x
L014D               std       <u0022,u
                    clra
                    clrb
                    std       <u001D,u
                    sta       <u001F,u
                    ldd       <u0022,u
                    tstb
                    bpl       L0161
                    inc       <u001F,u
L0161               bitb      #$40
                    bne       L017F
                    bitb      #$20
                    beq       L016C
                    inc       <u001E,u
L016C               bita      #$20
                    beq       L017E
                    bita      #$80
                    beq       L017F
                    inc       <u001D,u
                    bita      #$40
                    bne       L017E
                    inc       <u001D,u
L017E               rts
L017F               comb
                    ldb       <E$BMode
                    rts
L0183               comb
                    ldb       #E$UnkSvc
                    rts

                    endc

                    emod
eom                 equ       *
                    end

