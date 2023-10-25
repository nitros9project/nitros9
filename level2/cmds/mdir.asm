********************************************************************
* MDir - Show module information
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  7       ????/??/??
* Original Tandy/Microware version.
*
*  8       2003/01/14  Boisy Pitre
* Changed option to -e, optimized slightly. Could use greater optimization.
*
*  9       2003/08/24  Rodney Hamilton
* Corrected leading zero supression, more optimizations.
*
*  9r1     2005/04/19  Boisy G. Pitre
* Made column computation and use more efficient.

                    nam       MDir
                    ttl       Show module information

* Disassembled 98/09/11 11:57:27 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       9

                    mod       eom,name,tylg,atrv,start,size

ParamPtr            rmb       2
zflag               rmb       1                   supress leading zeros flag
bufptr              rmb       2                   current position in the line buffer
datebuf             rmb       3
timebuf             rmb       3
narrow              rmb       1
u000C               rmb       1                   name field width
u000D               rmb       1                   last starting column
linebuf             rmb       80
u005E               rmb       2                   ptr to module dir end
u0060               rmb       2                   ptr to module dir start
u0062               rmb       4096
u1062               rmb       64                  module name buffer
u10A2               rmb       13                  module stats ??
                    rmb       256                 stack area
size                equ       .

name                fcs       /MDir/
                    fcb       edition

header              fcs       "   Module Directory at "
header2             fcs       "Block Offset Size Typ Rev Attr  Use Module Name"
header3             fcs       "----- ------ ---- --- --- ---- ---- ------------"
sheader1            fcs       "Blk Ofst Size Ty Rv At Uc  Name"
sheader2            fcs       "___ ____ ____ __ __ __ __ ______"
lock                fcs       "Lock "
slock               fcs       "Lk"

start               pshs      u
                    leau      >u1062,u
L00D4               clr       ,-u
                    cmpu      ,s
                    bhi       L00D4
                    puls      u
                    clr       <zflag              clear leading zero supression
                    clr       <narrow             default to wide
*         ldd   #$0C30		wide column width=12/last start col=48
*         std   <u000C
                    stx       <ParamPtr           save args ptr
                    leax      linebuf,u
                    stx       <bufptr
                    lbsr      writeBUF
                    ldd       #$01*256+SS.ScSiz   standard output and get screen size
                    os9       I$GetStt            get it!
                    bcc       L00FF               branch if ok
*         cmpb  #E$UnkSvc	unknown service?
*         lbne  L0241		exit with error if not
*         bra   L010C		else ignore screen width test

L00FF               tfr       x,d
                    cmpb      #40                 compare against 51
                    bgt       higher              if greater or equal, go on
                    inc       <narrow             else set narrow flag
                    lda       #10
                    fcb       $8C
higher              lda       #12                 narrow column width=10/last start col=21
                    pshs      a
                    subb      ,s+
                    std       <u000C
L010C               leay      >header,pcr         point to main header
                    lbsr      copySTR
                    leax      datebuf,u           date/time buffer
                    os9       F$Time              get current date & time
                    leax      timebuf,u           only wanted the time
                    lbsr      L02B8               print TIME as HH:MM:SS
                    lbsr      writeBUF
                    leax      <u0062,u            buffer for module directory
                    pshs      u
                    os9       F$GModDr            get module directory
                    sty       <u005E              save local end ptr
                    stu       <u0060              save system start ptr
                    puls      u
                    leax      -MD$ESize,x
                    ldy       <ParamPtr
                    ldd       ,y+
                    andb      #$DF
                    cmpd      #$2D45              -e option?
                    bne       L018E
                    lbsr      writeBUF
L0149               leay      >header2,pcr
                    tst       <narrow
                    beq       L014D
                    leay      >sheader1,pcr
L014D               lbsr      copySTR
                    lbsr      writeBUF
L015D               leay      >header3,pcr
                    tst       <narrow
                    beq       L0161
                    leay      >sheader2,pcr
L0161               lbsr      copySTR
                    lbsr      writeBUF
                    leax      <u0062,u
                    lbra      L023A

* just print the module names, no E flag
L016D               lbsr      L0308
                    beq       L018E
                    lbsr      L02DE
                    lbsr      copySTR
L0178               lbsr      outSP
                    ldb       <bufptr+1
                    subb      #$0E
                    cmpb      <u000D
                    bhi       L018B
L0183               subb      <u000C
                    bhi       L0183
                    bne       L0178
                    bra       L018E

L018B               lbsr      writeBUF
L018E               leax      MD$ESize,x
                    cmpx      <u005E
                    bcs       L016D
                    lbsr      writeBUF            final/partial line
                    lbra      L0240               exit OK

* print extended info line for each module
L019A               lbsr      L0308
                    lbeq      L0238               skip if DAT image ptr==0
                    tfr       d,y
                    ldd       ,y
                    tst       <narrow
                    beq       L01B1
                    lbsr      outSP
                    lbsr      outb2HS             2-digit block number
                    bra       L01BE
L01B1               lbsr      out4HS              4-digit block number
                    lbsr      outSP
                    lbsr      outSP
* module offset
L01BE               ldd       MD$MPtr,x
                    bsr       out4HS              4-digit offset
                    tst       <narrow
                    bne       L01CA
                    lbsr      outSP
L01CA               lbsr      L02DE               read module's header info
                    leay      >u10A2,u
* module size
                    ldd       M$Size,y
                    bsr       out4HS              4-digit size
                    tst       <narrow
                    bne       L01DC
                    lbsr      outSP
* type/lang
L01DC               lda       M$Type,y
                    bsr       out2HS              2-digit type/lang
                    tst       <narrow
                    bne       L01E7
                    lbsr      outSP
* att/rev
L01E7               lda       M$Revs,y
                    anda      #RevsMask
                    bsr       out2HS              2-digit revision
                    ldb       M$Revs,y            upper half = attributes
                    lda       #'r
                    bsr       L0291               bit7: ReEnt (reentrant module)
                    tst       <narrow
                    bne       L0207
                    lda       #'w                 bit6: ModProt (writeable module)
                    bsr       L0291
                    lda       #'3                 bit5: ModNat (native mode 6309)
                    bsr       L0291
                    lda       #'?                 bit4 undefined
                    bsr       L0291
* user count
L0207               bsr       outSP
                    ldd       MD$Link,x           D=user count
                    cmpd      #$FFFF              if -1,
                    bne       L0223
L021B               leay      >lock,pcr           print "Lock"
                    tst       <narrow
                    bne       L021F
                    leay      >slock,pcr
L021F               bsr       copySTR
                    bra       L0230

L0223               tst       <narrow
                    beq       L022E
                    bsr       outSP
                    bsr       outb2HS             2-digit user count
                    bra       L0230

L022E               bsr       out4HS              4-digit user count
* module name
L0230               leay      >u1062,u            point to name buffer
                    bsr       copySTR
                    bsr       writeBUF
L0238               leax      MD$ESize,x          next entry
L023A               cmpx      <u005E              more to do?
                    lbcs      L019A               yes, continue
L0240               clrb
L0241               os9       F$Exit

* print regD as 4 hex digits plus space
out4HS              inc       <zflag              supress leading zeros
                    inc       <zflag
                    bsr       out2H               print MSB as 2 hex
                    dec       <zflag
* print regB as 2 hex digits plus space
outb2HS             tfr       b,a                 print LSB as 2 hex

* print regA as 2 hex digits plus space
out2HS              bsr       out2H
                    bra       outSP

out2H               inc       <zflag              supress leading zero
                    pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L026C               print MSdigit
                    puls      a                   print LSdigit
                    anda      #$0F                is this a zero?
L026C               bne       L027B               no, print it
                    tst       <zflag              still supressing zeros?
                    bgt       outZSP              yes, count it and print space
L027B               clr       <zflag              nonzero, print all the rest
                    adda      #'0
                    cmpa      #'9
                    bls       outCH
                    adda      #$07
                    bra       outCH

* process attribute flag bit
L0291               rolb
                    bcs       outCH
                    lda       #'.
                    bra       outCH

outZSP              dec       <zflag              count down to last digit
outSP               lda       #C$SPAC             append a SPACE to the line buffer

* Append character in regA to the line buffer
outCH               pshs      x
                    ldx       <bufptr
                    sta       ,x+
                    stx       <bufptr
                    puls      pc,x

* Copy an FCS string to the line buffer
L0296               bsr       outCH
copySTR             lda       ,y+
                    bpl       L0296
                    anda      #$7F
                    bra       outCH

* Append a CR and send entire line to stdout
writeBUF            pshs      y,x,a
                    lda       #C$CR
                    bsr       outCH
                    leax      linebuf,u
                    stx       <bufptr
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,y,x,a

* Print TIME as HH:MM:SS
L02B8               bsr       L02C0               print HH
                    bsr       L02BC               print :MM
*				print :SS and return
L02BC               lda       #':
                    bsr       outCH
L02C0               ldb       ,x+
L02C4               subb      #100
                    bcc       L02C4
* code to print 100's digit removed - max timefield value is 59
L02CF               lda       #'9+1
L02D1               deca
                    addb      #10
                    bcc       L02D1
                    bsr       outCH               tens digit
                    tfr       b,a
                    adda      #'0
                    bra       outCH               units digit

* copy module header & name to local buffers
L02DE               pshs      u,x
                    bsr       L0308               D=ptr to mdir entry
                    ldx       4,x                 X=MD$MPtr
                    ldy       #13
                    leau      >u10A2,u            buffer for module header data
                    os9       F$CpyMem            copy 13 bytes of module header
                    pshs      b,a                 save DAT image ptr
                    ldd       4,u                 name offset
                    leax      d,x                 X=name ptr
                    puls      b,a                 restore DAT image ptr
                    ldu       2,s
                    leau      >u1062,u            U=ptr to name buffer
                    ldy       #64
                    os9       F$CpyMem            copy 64 bytes of name data
                    tfr       u,y                 Y=ptr to name buf
                    puls      pc,u,x

* calculate local buffer address for current mdir entry (DAT image ptr)
L0308               ldd       ,x                  D=MD$MPDAT
                    beq       L0319               if 0, skip empty slot
                    pshs      y
                    leay      <u0062,u            Y=local MDIR buffer
                    pshs      y
                    subd      <u0060              D=offset (MD$MPDAT-mdstart)
                    addd      ,s++                D=ptr to local mdir entry
                    puls      y
L0319               rts

                    emod
eom                 equ       *
                    end
