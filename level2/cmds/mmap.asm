********************************************************************
* MMap - Show memory block map
*
* $Id$
*
* From Kevin Darling, "Inside OS9 Level II"
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   ?      1988/??/??  Kevin Darling
* Original version.
*
*   4      1989/07/30  Ken Drexler
* Modified for other block sizes.

                    nam       MMap
                    ttl       Memory Block Utility

                    ifp1
                    use       defsfile
                    endc

Revs                set       ReEnt+0
Type                set       Prgrm+Objct
edition             set       4

                    mod       prglen,name,type,revs,MMap,datsiz

Name                fcs       /MMap/
                    fcb       edition

***************************************************
*
* Data
*
buffsiz             set       512

numflag             rmb       1                   flag for leading zeros
rowcnt              rmb       1                   no rows to print
free                rmb       1                   no free blocks
rowno               rmb       1                   row number
lcnt                rmb       1                   line length counter
outptr              rmb       2                   output pointer
out                 rmb       80                  output buffer
mapsiz              rmb       2                   size of map block
blksiz              rmb       2                   block size
buffer              rmb       buffsiz             map itself
stack               rmb       200
datsiz              equ       .

                    pag
***************************************************
*
*  Messages
*
header              fcc       /     0 1 2 3 4 5 6 7 8 9 A B C D E F/
                    fcb       C$CR
hdrlen              equ       *-header

hdr2                fcc       /  #  = = = = = = = = = = = = = = = =/
                    fcb       C$CR
hdrlen2             equ       *-hdr2

BlockMsg            fcc       /  Block Size: /
blklen              equ       *-Blockmsg

Freemsg             fcc       / Free Blocks: /
freelen             equ       *-Freemsg

RAMmsg              fcc       / KBytes Free: /
ramlen              equ       *-RAMmsg

**********************************************
*
MMap                lbsr      pcrtn               print line
                    leax      header,pcr          print headers
                    lda       #1
                    ldy       #hdrlen
                    os9       I$WritLn
                    leax      hdr2,pcr
                    ldy       #hdrlen2
                    os9       I$WritLn
                    leax      buffer,u            get block map to read
                    os9       F$GBlkMp
                    lbcs      error
                    std       blksiz              save block size
                    sty       mapsiz              save map size
                    clr       free
                    clr       rowno
                    ldd       mapsiz              compute number of rows
                    lsra                          at 16 per row
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    stb       rowcnt              save count
                    leax      out,u
                    stx       outptr
                    leax      buffer,u            point at map
                    pshs      x
                    bra       loop2

loop                dec       lcnt                count -= 1
                    bne       loop3               if more, skip line print

* print line, start next line
loop1               pshs      x                   save map pointer
                    lbsr      prline              print line
                    dec       rowcnt              done?
                    beq       exit                yes
loop2               lda       #16                 set line length count
                    sta       lcnt
                    lbsr      Space               1 space
                    lda       rowno               print row number
                    lbsr      Hex1
                    inc       rowno               row number += 1
                    lbsr      space2              2 spaces
                    puls      x

* Print one block status
loop3               ldb       ,x+                 get next block
                    beq       freeram
                    bmi       noram
                    bitb      #2                  module?
                    bne       module
                    lda       #'U                 must be ram in use
                    bra       put

freeram             lda       #'_                 not used
                    inc       free                count it
                    bra       put

module              lda       #'M                 module
                    bra       put

noram               lda       #'.                 not ram

* Print character in A and space
put                 equ       *
                    lbsr      print               put character in output buffer
                    lda       #C$SPAC             add space
                    lbsr      print

                    bra       loop

* Add summary messages
Exit                equ       *
                    leax      BlockMsg,pcr        print "Block Size"
                    ldy       #blklen
                    lbsr      Prstr
                    ldd       blksiz
                    clr       numflag             suppress zeros
                    bsr       outdec
                    lbsr      prline              print line
                    leax      freemsg,pcr         print "Free Blocks"
                    ldy       #freelen
                    lbsr      Prstr
                    ldb       free                get number of blocks
                    clra
                    clr       numflag             suppress zeros
                    bsr       outdec              print in decimal
                    bsr       prline
                    leax      rammsg,pcr          print "RAM Free"
                    ldy       #ramlen
                    lbsr      Prstr
                    ldb       free                get number of blocks
                    lda       blksiz              get #k/block
                    lsra                          by dividing msb by 4
                    lsra
                    mul
                    clr       numflag             suppress zeros
                    bsr       outdec              print in decimal
                    bsr       prline

bye                 clrb                          no errors

error               os9       F$Exit


**********************************************
*
* Subroutines
*
Pcrtn               pshs      a,x                 Output carriage return
                    lda       #C$CR
                    sta       out
                    leax      out,u               point at buffer
                    ldy       #1                  one char.
                    lda       #1
                    os9       I$WritLn
                    puls      a,x,pc


** Decimal output routine
*  IN:  D - number to output
*       X - destination buffer
* OUT:  X,Y,U preserved
*
Outdec              pshs      b,x,y,u
                    ldx       outptr              get pointer
                    leau      <dectbl,pcr
                    ldy       #5                  set counter

Outdec1             clr       ,s                  clear workspace

Outdec2             subd      ,u                  subtract power of ten
                    bcs       outdec3
                    inc       ,s
                    bra       outdec2

outdec3             addd      ,u++                add back one power
                    pshs      b                   save b
                    ldb       1,s
                    addb      #'0                 convert to ascii
                    cmpb      #'0                 zero?
                    bne       outdec4             no, print it
                    tst       numflag             suppress zero?
                    beq       outdec5             yes
outdec4             inc       numflag
                    stb       ,x+                 put in buffer
outdec5             puls      b                   restore b
                    leay      -1,y                counter -= 1
                    bne       outdec1
                    stx       outptr              update pointer
                    puls      b,x,y,u,pc

Dectbl              fdb       10000
                    fdb       1000
                    fdb       100
                    fdb       10
                    fdb       1


* Print Line
Prline              ldx       outptr              now print line
                    lda       #C$CR
                    sta       ,x                  terminate line
                    leax      out,u
                    ldy       #80
                    lda       #1
                    os9       I$Writln
                    bcs       error
                    leax      out,u               set pointer
                    stx       outptr
                    rts


* Print Spaces
Space2              bsr       Space

Space               lda       #C$SPAC
                    bra       Print

* Print Hexidecimal Digit in A
Hex1                tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       outhex
                    tfr       b,a
Outhex              anda      #$0f
                    cmpa      #$0a                0 - 9
                    bcs       outdig
                    adda      #$07                A - F
outdig              adda      #'0                 make ASCII
print               pshs      X
                    ldx       outptr
                    sta       ,X+
                    stx       outptr
                    puls      x,pc


* Print string to output buffer
*  IN:  X - string pointer
*       Y - string length
*
Prstr               equ       *
                    lda       ,x+                 get character
                    bsr       print               put in buffer
                    leay      -1,y
                    bne       Prstr
                    rts

                    emod
Prglen              equ       *
                    end
