*******************************************************************
* SMap - Show System Memory Map
*
* $Id$
*
* From "Inside OS9 Level II", by Kevin Darling
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* Original version.

                    nam       SMap
                    ttl       Show System Memory Map

* Disassembled 02/05/12 22:05:11 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,msize

leadflag            rmb       1
decbuff             rmb       3                   decimal buffer (100, 10, 1s place)
free                rmb       1                   number of free 256 byte pages in system memory
row                 rmb       1
spc                 rmb       1
out                 rmb       3                   ONLY 2 BYTES USED
mapsiz              rmb       2                   NEVER USED
blksiz              rmb       2                   NEVER USED
blknum              rmb       1
buffer              rmb       256
stack               rmb       200
msize               equ       .

name                fcs       /SMap/
                    fcb       edition

H1                  fcc       "    0 1 2 3 4 5 6 7 8 9 A B C D E F"
CrRt                fcb       C$CR
H1L                 equ       *-H1
H2                  fcc       " #  = = = = = = = = = = = = = = = ="
*         fcb   C$CR
H2L                 equ       *-H2
SysDat              fcb       $00,$00,$00,$00

start               lbsr      WriteCR             Write a carriage return to standard out
                    leax      <H1,pcr             point to header 1
                    lda       #$01
                    ldy       #H1L
                    os9       I$WritLn            and write it to standard out
                    leax      <H2,pcr             same with header 2
                    ldy       #H2L
                    os9       I$Write

* Get SysMap pointer
                    leax      <SysDat,pcr
                    tfr       x,d
                    ldx       #D.SysMem           point to System Memory global
                    ldy       #$0002              get 2 byte pointer into system RAM
                    pshs      u                   save statics
                    leau      buffer,u            point to destination
                    os9       F$CpyMem            get it
                    puls      u                   restore statics
                    lbcs      error               branch if error

* Get SysMap
                    ldx       buffer,u            get pointer into system memory table in system space
                    ldy       #256                all 256 bytes
                    pshs      u                   save statics
                    leau      buffer,u            point to destination
                    os9       F$CpyMem            copy memory
                    puls      u                   restore statics
                    lbcs      error               branch if error

                    clr       <blknum
                    clr       <free               clear free counter
                    leax      buffer,u
                    lda       #$30
                    sta       <row
                    clr       ,-s                 save count
loop                lda       ,s
                    bita      #$0F
                    bne       loop2
                    pshs      x
                    lbsr      WriteCR
                    leax      spc,u
                    ldy       #$0004
                    lda       <row
                    cmpa      #':
                    bne       oknum
                    lda       #'A
                    sta       <row
oknum               sta       <out
                    inc       <row
                    ldd       #C$SPAC*256+C$SPAC
                    sta       <spc
                    std       <out+1
                    lda       #$01
                    os9       I$Write
                    puls      x

loop2               ldb       ,x+                 get next block
                    beq       unused
                    bmi       noram
                    ldb       #'U                 RAM-in-use
                    bra       put
noram               ldb       #'.                 not RAM
                    bra       put
unused              ldb       #'_                 not used
                    inc       <free               increment free page counter

put                 stb       <out
                    ldb       #C$SPAC
                    stb       <out+1
                    pshs      x
                    leax      out,u
                    ldy       #$0002
                    lda       #$01
                    os9       I$Write
                    puls      x
                    dec       ,s
                    lbhi      loop
                    puls      a

                    bsr       WriteCR
                    bsr       WriteCR
                    leax      >FreePgs,pcr
                    ldy       #FreePgsL
                    lda       #$01
                    os9       I$Write
                    ldb       <free
                    clra
                    lbsr      outdec
                    bsr       WriteCR

                    leax      >FreeRAM,pcr
                    ldy       #FreeRAML
                    lda       #$01
                    os9       I$Write
                    ldb       <free
                    clra
                    lsrb
                    lsrb
                    lbsr      outdec
                    bsr       WriteCR
                    clrb
error               os9       F$Exit

FreePgs             fcc       " Number of Free Pages: "
FreePgsL            equ       *-FreePgs
FreeRAM             fcc       "   RAM Free in KBytes: "
FreeRAML            equ       *-FreeRAM

WriteCR             pshs      x,a
                    leax      CrRt,pcr
                    ldy       #$0001
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,x,a

print               sta       <out
                    pshs      x
                    leax      out,u
                    ldy       #$0001
                    lda       #$01
                    os9       I$Write
                    puls      pc,x

outdec              leax      decbuff,u           D=number
                    clr       <leadflag
                    clr       ,x
                    clr       $01,x
                    clr       $02,x
hundred             inc       ,x
                    subd      #100
                    bcc       hundred
                    addd      #100
ten                 inc       $01,x
                    subd      #10
                    bcc       ten
                    addd      #10
                    incb
                    stb       $02,x
                    bsr       printled
                    bsr       printled

printnum            lda       ,x+
                    adda      #$2F                make ASCII
                    bra       print

printled            tst       <leadflag           print leading zero?
                    bne       printnum            ..yes
                    ldb       ,x                  is it zero?
                    inc       <leadflag
                    decb
                    bne       printnum            ..no, print zeroes
                    clr       <leadflag           else supress
                    lda       #C$SPAC
                    leax      1,x
                    bra       print

                    emod
eom                 equ       *
                    end
