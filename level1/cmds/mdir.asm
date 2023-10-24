********************************************************************
* Mdir - Show module directory
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
*
*   6      2003/01/14  Boisy G. Pitre
* Changed option to -e, optimized slightly.
*
*   7      2003/08/25  Rodney V. Hamilton
* Fixed leading zero supression, more optimizations.

                    nam       Mdir
                    ttl       Show module directory

* Disassembled 02/04/05 12:49:18 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       7
stdout              set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
mdstart             rmb       2
mdend               rmb       2
parmptr             rmb       2
zflag               rmb       1                   supress leading zeros flag
bufptr              rmb       1
u0008               rmb       1
datebuf             rmb       3
timebuf             rmb       3
u000F               rmb       1                   name field width
u0010               rmb       1                   last starting column
narrow              rmb       1
buffer              rmb       80
                    rmb       450                 stack & parameters
size                equ       .

name                fcs       /Mdir/
                    fcb       edition

tophead             fcb       C$LF
                    fcs       "  Module directory at "
ltitle              fcb       C$LF
                    fcc       "Addr Size Typ Rev Attr Use Module name"
                    fcb       C$LF
                    fcc       "---- ---- --- --- ---- --- ------------"
                    fcb       C$CR
stitle              fcb       C$LF
                    fcc       "Addr Size Ty Rv At Uc   Name"
                    fcb       C$LF
                    fcc       "---- ---- -- -- -- -- ---------"
                    fcb       C$CR

start               stx       <parmptr
                    clr       <zflag
                    clr       <narrow             assume wide output
                    lda       #stdout             standard output
                    ldb       #SS.ScSiz           we need screen size
                    os9       I$GetStt            get it
                    bcc       L00D2               branch if we got it
                    cmpb      #E$UnkSvc           not a known service request error?
                    lbne      Exit                if not, exit
                    bra       Do80
L00D2               cmpx      #80                 80 columns?
                    blt       Chk51               branch if less than
Do80                ldd       #$0C30
                    bra       SetSize
Chk51               cmpx      #51                 51 columns?
                    blt       Do32
Do51                ldd       #$0C28
                    bra       SetSize
Do32                inc       <narrow
                    ldd       #$0A15
SetSize
                    std       <u000F
                    leay      >tophead,pcr
                    leax      <buffer,u
                    stx       <bufptr
                    lbsr      copySTR
                    leax      datebuf,u
                    os9       F$Time
                    leax      timebuf,u
                    lbsr      L0224
                    lbsr      writeBUF
                    ldx       >D.ModDir           MUST use ext addr for page 0
                    stx       <mdstart
                    ldd       >D.ModDir+2
                    std       <mdend
                    leax      -MD$ESize,x
* Check for 'E' given as argument
                    ldy       <parmptr
                    ldd       ,y+
                    andb      #$DF
                    cmpd      #$2D45              -E ?
                    bne       L015D
                    leax      >ltitle,pcr
                    tst       <narrow
                    beq       L012B
                    leax      >stitle,pcr
L012B               ldy       #80                 max. length to write
                    lda       #stdout
                    os9       I$WritLn
                    ldx       <mdstart
                    bra       L01B9
loop                ldy       MD$MPtr,x
                    beq       L015D               skip if unused slot
                    ldd       M$Name,y
                    leay      d,y
                    lbsr      copySTR
L0141               lbsr      outSP
                    ldb       <u0008
                    subb      #$12
                    cmpb      <u0010
                    bhi       L0154
L014C               subb      <u000F
                    bhi       L014C
                    bne       L0141
                    bra       L015D
L0154               lbsr      writeBUF
L015D               leax      MD$ESize,x
                    cmpx      <mdend
                    bcs       loop
                    lbsr      writeBUF
                    bra       ExitOk
*
* A module entry is 2 two byte pointers.
* If the first pointer is $0000, then the slot is unused
L0168               ldy       MD$MPtr,x           ptr=0?
                    beq       gotonxt             yes, skip unused slot
                    ldd       MD$MPtr,x           address (faster than tfr)
                    bsr       out4HS
                    ldd       M$Size,y            size
                    bsr       out4HS
                    tst       <narrow
                    bne       L0181
                    bsr       outSP
L0181               lda       M$Type,y            type/lang
                    bsr       out2HS
                    tst       <narrow
                    bne       L018B
                    bsr       outSP
L018B               lda       M$Revs,y            revision
                    anda      #RevsMask
                    bsr       out2HS
                    ldb       M$Revs,y            attributes
                    lda       #'r
                    bsr       L01FE               bit 7 (ReEnt)
                    tst       <narrow
                    bne       L01A7
                    lda       #'w                 bit 6 (ModProt:1=writable)
                    bsr       L01FE
                    lda       #'3                 bit 5 (ModNat:6309 Native mode)
                    bsr       L01FE
                    lda       #'?                 bit 4 undefined
                    bsr       L01FE
L01A7               bsr       outSP
                    bsr       outSP
                    lda       MD$Link,x           user count
                    bsr       out2HS
                    ldd       M$Name,y
                    leay      d,y                 module name
                    bsr       copySTR
                    bsr       writeBUF
gotonxt             leax      MD$ESize,x
L01B9               cmpx      <mdend
                    bcs       L0168

ExitOk              clrb
Exit                os9       F$Exit

out4HS              inc       <zflag              supress leading zeros
                    inc       <zflag
                    bsr       Byt2Hex
                    dec       <zflag
                    tfr       b,a
out2HS              bsr       Byt2Hex
                    bra       outSP

Byt2Hex             inc       <zflag              supress leading zero
                    pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L01DB
                    puls      a
                    anda      #$0F                is this a zero?
L01DB               bne       L01E8               no, print it
                    tst       <zflag              still supressing zeros?
                    bgt       outZSP              yes, count it and print space
L01E8               clr       <zflag              nonzero, print all the rest
                    adda      #'0
                    cmpa      #'9
                    bls       ApndA
                    adda      #$07                Make it A-F
                    bra       ApndA

outZSP              dec       <zflag              countdown to last digit
outSP               lda       #C$SPAC             append a space
*
* append a char (in reg a) to buffer
*
ApndA               pshs      x
                    ldx       <bufptr
                    sta       ,x+
                    stx       <bufptr
                    puls      pc,x
*
* process attribute flag bit
*
L01FE               rolb
                    bcs       ApndA
                    lda       #'.
                    bra       ApndA
*
* Copy an FCS string to buffer
*
copySTR             lda       ,y
                    anda      #$7F
                    bsr       ApndA
                    lda       ,y+
                    bpl       copySTR
                    rts
*
* Append a CR to buffer and write it
*
writeBUF            pshs      y,x,a
                    lda       #C$CR
                    bsr       ApndA
                    leax      <buffer,u
                    stx       <bufptr
                    ldy       #80
                    lda       #stdout
                    os9       I$WritLn
                    puls      pc,y,x,a

* Write the time to the buffer as HH:MM:SS
L0224               bsr       Byt2ASC
                    bsr       Colon
Colon               lda       #':
                    bsr       ApndA
Byt2ASC             ldb       ,x+
Hundreds            subb      #100
                    bcc       Hundreds
* code to print 100's digit removed - max timefield value is 59
Tens                lda       #'9+1
TensLoop            deca
                    addb      #10
                    bcc       TensLoop
                    bsr       ApndA
                    tfr       b,a
                    adda      #'0
                    bra       ApndA

                    emod
eom                 equ       *
                    end
