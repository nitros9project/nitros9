********************************************************************
* Mfree - Show free memory
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* Original Tandy/Microware version.
*   3      2017/05/30  Neal Crook
* Original version misbehaved if final block in the map was free.
* That situation never occurs on coco, but it does occur on the mc09
* target. Inferred behaviour and added comments as a side-effect of
* debugging effort.

                    nam       Mfree
                    ttl       Show free memory

* Disassembled 98/09/11 12:07:32 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

freeblks            rmb       2
mapsiz              rmb       2
* pages per block (ie, MS byte of block size)
ppblk               rmb       1
* 0: print number with leading spaces. 1: print number with leading 0.
leadzero            rmb       1
* u0006,7,8 store a 24-bit block begin/end address.
u0006               rmb       1
u0007               rmb       1
u0008               rmb       1
bufstrt             rmb       2
bufcur              rmb       2
linebuf             rmb       80
mapbuf              rmb       1274
size                equ       .

name                fcs       /Mfree/
                    fcb       edition

Hdr                 fcs       " Blk Begin   End   Blks  Size"
                    fcs       " --- ------ ------ ---- ------"
Ftr                 fcs       "                   ==== ======"
                    fcs       "            Total: "

start               leax      linebuf,u           get line buffer address
                    stx       <bufstrt            and store it away
                    stx       <bufcur             current output position output buffer

                    lbsr      wrbuf               print CR
                    leay      <Hdr,pcr
                    lbsr      tobuf               1st line of header to output buffer
                    lbsr      wrbuf               ..print it
                    lbsr      tobuf               2nd line of header to output buffer
                    lbsr      wrbuf               ..print it

                    clr       <freeblks           total number of free blocks
                    clr       <freeblks+1
                    leax      <mapbuf,u
* In:  X = 1024-byte buffer
* Out: D = number of bytes per block
*      Y = system memory block map size
                    os9       F$GBlkMp
                    sty       <mapsiz             save map size
                    sta       <ppblk              save MS byte of bytes per block
                    ldy       #$0000              count of how many blocks we have inspected

* Main loop
* look for a free block (an entry of 0 in the block map)
loop                ldu       #$0000              number of free blocks in this sequence
L00AD               tst       ,x+                 is this block 0?
                    beq       L00BA               yes - found a free block
                    leay      $01,y               total number of blocks we have inspected
                    cmpy      <mapsiz             at the end of the map?
                    bne       L00AD               no, so carry on looking
                    bra       alldone             yes, and the last block was not free, so we're done.

* Block number in Y is the first free block of a sequence (tho maybe a sequence of 1)
L00BA               tfr       y,d
                    bsr       buf4hex             append start block, in hex, to output buffer
                    lda       <ppblk
                    pshs      y,a
                    clra
                    clrb
L00C4               addd      $01,s               multiply start block by block size to get
                    dec       ,s                  begin address
                    bne       L00C4
                    leas      $03,s
                    std       <u0006              2 MS bytes of block begin address
                    clr       <u0008              1 LS byte  of block begin address is 0
                    bsr       buf6hex             append block begin address in hex, to output buffer

* Look for the last free block in this sequence
L00D2               leau      $01,u
                    leay      $01,y
                    cmpy      <mapsiz
                    beq       last

                    tst       ,x+
                    beq       L00D2               haven't found it yet..
last                lda       <ppblk
                    pshs      y,a
                    clra
                    clrb
L00E5               addd      $01,s               multiply end block by block size to get
                    dec       ,s                  end address
                    bne       L00E5
                    leas      $03,s
                    subd      #$0001
                    std       <u0006              2 MS bytes of block end address
                    lda       #$FF
                    sta       <u0008              1 LS byte  of block end address is $FF
                    bsr       buf6hex             append block end address in hex, to output buffer
                    leax      -$01,x
                    tfr       u,d                 number of blocks in this sequence u->d
                    bsr       buf4hex             append number of blocks, in hex, to output buffer
                    lbsr      L0199               append size, in decimal, to output buffer

                    addd      <freeblks
                    std       <freeblks           total number of blocks
                    bsr       wrbuf               print this entry
                    cmpy      <mapsiz
                    bne       loop                loop for next entry

* All of the entries have been printed. Print the trailer and totals.
alldone             leay      >Ftr,pcr
                    bsr       tobuf               1st line of footer to output buffer
                    bsr       wrbuf               ..print it
                    bsr       tobuf               2nd line of footer to output buffer
                    ldd       <freeblks           get total number of blocks
                    bsr       buf4hex             append total number of blocks, in hex, to output buffer
                    bsr       L0199               append total size, in decimal, to output buffer
                    bsr       wrbuf               ..print it
* Successful exit
                    clrb
                    os9       F$Exit

* convert value in D to ASCII hex (4 chars). Append to output buffer, then append "SPACE" to output buffer
buf4hex             pshs      b,a
                    clr       <leadzero
                    bsr       L0145
                    tfr       b,a
                    bsr       L0145
                    lda       #C$SPAC             append a space
                    bsr       bufchr
                    puls      pc,b,a

* convert value in u0006,7,8 to ASCII hex (6 chars). Append to output buffer, then append "SPACE" to output buffer
buf6hex             clr       <leadzero
                    lda       <u0006
                    bsr       L0145
                    lda       <u0007
                    bsr       L0145
                    lda       <u0008
                    bsr       L0145
                    lda       #C$SPAC             append a space
                    bra       bufchr

* convert value in A to ASCII hex (2 chars). Append to output buffer.
L0145               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L014F
                    puls      a
L014F               anda      #$0F
                    tsta
                    beq       L0156
                    sta       <leadzero
L0156               tst       <leadzero
                    bne       L015C
                    lda       #$F0

* FALL THROUGH
* Convert digit to ASCII with leading spaces, add to output buffer
* A is a 0-9 or A-F or $F0.
* Add $30 converts 0-9 to ASCII "0" - "9"), $F0 to ASCII "SPACE"
* leaves A-F >$3A so a further 7 is added so $3A->$41 etc. (ASCII "A" - "F")
L015C               adda      #$30
                    cmpa      #$3A
                    bcs       bufchr
                    adda      #$07

* FALL THROUGH
* Store A at next position in output buffer.
bufchr              pshs      x
                    ldx       <bufcur
                    sta       ,x+
                    stx       <bufcur
                    puls      pc,x

* Append CR to the output buffer then print the output buffer
wrbuf               pshs      y,x,a
                    lda       #C$CR
                    bsr       bufchr
                    ldx       <bufstrt            address of data to write
                    stx       <bufcur             reset output buffer pointer, ready for next line.
                    ldy       #80                 maximum # of bytes - otherwise, stop at CR
                    lda       #$01                to STDOUT
                    os9       I$WritLn
                    puls      pc,y,x,a

* Append string at Y to output buffer. String is terminated by MSB=1
tobuf               lda       ,y
                    anda      #$7F
                    bsr       bufchr
                    tst       ,y+
                    bpl       tobuf
                    rts

DecTbl              fdb       10000,1000,100,10,1
                    fcb       $FF

* value in ?? is a number of blocks. Convert to bytes by multiplying by the page size.
* Convert to ASCII decimal, append to output buffer, append "k" to output buffer
L0199               pshs      y,x,b,a
                    lda       <ppblk
                    pshs      a
                    lda       $01,s
                    lsr       ,s
                    lsr       ,s
                    bra       L01A9

L01A7               lslb
                    rola
L01A9               lsr       ,s
                    bne       L01A7
                    leas      1,s
                    leax      <DecTbl,pcr
                    ldy       #$2F20
L01B6               leay      >256,y
                    subd      ,x
                    bcc       L01B6
                    addd      ,x++
                    pshs      b,a
                    tfr       y,d
                    tst       ,x
                    bmi       L01DE
                    ldy       #$2F30
                    cmpd      #'0*256+C$SPAC
                    bne       L01D8
                    ldy       #$2F20
                    lda       #C$SPAC
L01D8               bsr       bufchr
                    puls      b,a
                    bra       L01B6

L01DE               bsr       bufchr
                    lda       #'k
                    bsr       bufchr
                    leas      $02,s
                    puls      pc,y,x,b,a

                    emod
eom                 equ       *
                    end
