********************************************************************
* memtest - memory block map ghosting test
*
* Takes the kernel's own block map (F$GBlkMp: the 256-entry map krnp2
* builds at boot, NotRAM gaps and all) and proves that every block the
* map calls RAM is real, distinct memory: no block is a ghost (alias)
* of another, and nothing the map calls RAM fails to hold what is
* written to it. This is the check that the 1 MB windows ($A0-$BF,
* $D0-$EF) and the FLASHDIS blocks ($40-$9F on rc16 cores with the
* max-RAM kernel) are wired to their own SRAM and not folded back onto
* the first 512K or onto each other.
*
* Method (three passes over the map, every block reached through
* F$MapBlk one at a time and released with F$ClrBlk):
*   1. every FREE block: an 8-byte mark carrying its own block number
*      is written at three offsets ($0000, $0FF0, $1CF0 - all below
*      $1D00, so a block that lands in slot 7 is still safe) and read
*      straight back. A mismatch = the map calls it RAM but it is not.
*   2. every block the map knows - free, in use or NotRAM, the I/O
*      pages $C0-$CF excepted (reads there pop FIFOs) - is read at the
*      first mark offset. A mark with SOMEONE ELSE'S block number =
*      this block ghosts that one. A free block's mark turning up in
*      an in-use or NotRAM block is reported the same way.
*   3. every free block: the marks are wiped again.
* Only free blocks are ever written; in-use and NotRAM blocks are only
* read. Blocks are written in ascending order, so a ghost pair reports
* the LOWER block as showing the higher one's number.
*
* The summary sets the map's allotment (what krnp2 handed out) beside
* what was found: blocks that held their mark, ghosts, failures.
* Every printed line stays under 70 columns.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/14  Claude
* Created (user: "write a full memory map ghosting test program").

                    nam       memtest
                    ttl       memory block map ghosting test

                    ifp1
                    use       defsfile
                    endc

SIGOFF1             equ       $0000               mark offsets inside a block
SIGOFF2             equ       $0FF0
SIGOFF3             equ       $1CF0               below $1D00: safe even in slot 7
IOFIRST             equ       $C0                 sectored I/O pages: never read
IOLAST              equ       $CF

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
map                 rmb       256                 the kernel's block map, one byte a block
blksiz              rmb       2                   bytes per block (F$GBlkMp)
mapsiz              rmb       2                   blocks in the map
cur                 rmb       2                   block being handled (a word: X for F$MapBlk)
other               rmb       1                   the block number a foreign mark carries
dig                 rmb       1                   dec16 scratch
dflag               rmb       1
dcnt                rmb       1
nram                rmb       2                   blocks the map calls RAM (free + in use)
nfree               rmb       2
ninuse              rmb       2
nnotram             rmb       2
nwrok               rmb       2                   free blocks that held their mark
nwrbad              rmb       2                   free blocks that did not
nghost              rmb       2                   blocks showing another block's mark
nintact             rmb       2                   free blocks still carrying their own mark in pass 2
sig                 rmb       8                   the mark being written / compared
line                rmb       80
stack               rmb       300
size                equ       .

name                fcs       /memtest/
                    fcb       edition

hexch               fcc       /0123456789ABCDEF/
sigtag              fcc       /WBMT/              the four fixed bytes of a mark

* ---- the mark ------------------------------------------------------
* block B's mark: 'W','B','M','T', B, ~B, B*3+1, B^$5A - built at sig,u for cur
mksig               leax      sig,u
                    ldb       #'W
                    stb       ,x+
                    ldb       #'B
                    stb       ,x+
                    ldb       #'M
                    stb       ,x+
                    ldb       #'T
                    stb       ,x+
                    ldb       cur+1,u
                    stb       ,x+
                    comb
                    stb       ,x+
                    ldb       cur+1,u
                    lda       #3
                    mul
                    incb
                    stb       ,x+
                    ldb       cur+1,u
                    eorb      #$5A
                    stb       ,x
                    rts

* copy the mark to Y+D
putsig              leay      d,y
                    leax      sig,u
                    ldb       #8
put@                lda       ,x+
                    sta       ,y+
                    decb
                    bne       put@
                    rts

* compare the mark with Y+D: Z set when equal
cmpsig              leay      d,y
                    leax      sig,u
                    ldb       #8
cmp@                lda       ,x+
                    cmpa      ,y+
                    bne       cmpx@
                    decb
                    bne       cmp@
cmpx@               rts

* zero 8 bytes at Y+D
zapsig              leay      d,y
                    ldb       #8
                    clra
zap@                sta       ,y+
                    decb
                    bne       zap@
                    rts

* ---- the map and the blocks --------------------------------------
* block cur's map byte: Z set = free RAM, N set = NotRAM
mapbyte             leax      map,u
                    ldb       cur+1,u
                    clra                          D = the block number, unsigned (b,x would be signed)
                    leax      d,x
                    tst       ,x
                    rts

* map block cur into our space: Y = its logical address; carry set on error. U kept.
mapblk              pshs      u
                    ldx       cur,u
                    ldb       #1
                    os9       F$MapBlk            U = the block's address
                    tfr       u,y
                    puls      u,pc                puls of U leaves CC alone

* release the block at Y. U kept.
unmap               pshs      u
                    tfr       y,u
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u,pc

* call the routine at X once for every block, cur = 0..mapsiz-1
walk                pshs      x
                    clr       cur,u
                    clr       cur+1,u
walk@               ldx       ,s
                    jsr       ,x
                    ldd       cur,u
                    addd      #1
                    std       cur,u
                    cmpd      mapsiz,u
                    blo       walk@
                    puls      x,pc

* ---- output --------------------------------------------------------
* print the CR-terminated line at X (Y = its length) on path 1: I$WritLn, so the CR
* is a line end (I$Write would only return the carriage)
puts                lda       #1
                    os9       I$WritLn
                    rts

* start a line: X = line,u
lbeg                leax      line,u
                    rts

* append Y for B bytes at X
copy                lda       ,y+
                    sta       ,x+
                    decb
                    bne       copy
                    rts

* append two hex digits of B at X
hexb                pshs      b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       hexn
                    puls      b
                    andb      #$0F
hexn                pshs      x
                    leax      hexch,pcr
                    lda       b,x
                    puls      x
                    sta       ,x+
                    rts

* append D in decimal (0-65535) at X, no leading zeros
dec16               pshs      y
                    pshs      a,b                 (the counter set-up below must not touch D)
                    leay      pow10,pcr
                    clr       dflag,u
                    lda       #4
                    sta       dcnt,u
                    puls      a,b
d1@                 clr       dig,u
d2@                 cmpd      ,y
                    blo       d3@
                    subd      ,y
                    inc       dig,u
                    bra       d2@
d3@                 tst       dig,u
                    bne       d4@
                    tst       dflag,u
                    beq       d5@                 a leading zero: skip it
d4@                 pshs      a,b
                    ldb       dig,u
                    addb      #'0
                    stb       ,x+
                    inc       dflag,u
                    puls      a,b
d5@                 leay      2,y
                    dec       dcnt,u
                    bne       d1@
                    addb      #'0                 the units (D < 10 here)
                    stb       ,x+
                    puls      y,pc
pow10               fdb       10000,1000,100,10

* end the line at X with CR and print it
flush               lda       #C$CR
                    sta       ,x+
                    tfr       x,d
                    subd      #line
                    pshs      u
                    subd      ,s++                length = X - (U + line)
                    tfr       d,y
                    leax      line,u
                    lbra      puts

* "block $xx" at the start of a line
blkline             lbsr      lbeg
                    leay      blkmsg,pcr
                    ldb       #blkmsgl
                    lbsr      copy
                    ldb       cur+1,u
                    lbra      hexb
blkmsg              fcc       /block $/
blkmsgl             equ       *-blkmsg

* ---- the passes (each called by walk with cur set) ----------------
* pass 1: write the mark into every free block and read it back
pass1               lbsr      mapbyte
                    bne       p1x@                only free blocks are written
                    lbsr      mksig
                    lbsr      mapblk
                    lbcs      maperr
                    pshs      y
                    ldd       #SIGOFF1
                    lbsr      putsig
                    ldy       ,s
                    ldd       #SIGOFF2
                    lbsr      putsig
                    ldy       ,s
                    ldd       #SIGOFF3
                    lbsr      putsig
                    ldy       ,s
                    ldd       #SIGOFF1
                    lbsr      cmpsig
                    bne       p1bad@
                    ldy       ,s
                    ldd       #SIGOFF2
                    lbsr      cmpsig
                    bne       p1bad@
                    ldy       ,s
                    ldd       #SIGOFF3
                    lbsr      cmpsig
                    bne       p1bad@
                    ldd       nwrok,u
                    addd      #1
                    std       nwrok,u
                    bra       p1done@
p1bad@              ldd       nwrbad,u
                    addd      #1
                    std       nwrbad,u
                    lbsr      blkline
                    leay      noram,pcr
                    ldb       #noraml
                    lbsr      copy
                    lbsr      flush
p1done@             puls      y
                    lbsr      unmap
p1x@                rts
noram               fcc       / is in the map as RAM but holds nothing/
noraml              equ       *-noram

* pass 2: read the first mark slot of every block but the I/O pages
pass2               lda       cur+1,u
                    cmpa      #IOFIRST
                    blo       p2go@
                    cmpa      #IOLAST
                    bls       p2x@
p2go@               lbsr      mapblk
                    lbcs      maperr
                    pshs      y
                    leay      SIGOFF1,y
                    leax      sigtag,pcr
                    ldb       #4
p2tag@              lda       ,x+
                    cmpa      ,y+
                    bne       p2none@             no mark here
                    decb
                    bne       p2tag@
                    lda       ,y                  the block number the mark carries
                    coma
                    cmpa      1,y                 its complement must follow, or it is noise
                    bne       p2none@
                    lda       ,y
                    cmpa      cur+1,u
                    beq       p2own@              its own mark: as it should be
                    sta       other,u
                    ldd       nghost,u
                    addd      #1
                    std       nghost,u
                    lbsr      blkline
                    leay      mirrors,pcr
                    ldb       #mirrorsl
                    lbsr      copy
                    ldb       other,u
                    lbsr      hexb
                    lbsr      flush
                    bra       p2none@
p2own@              ldd       nintact,u
                    addd      #1
                    std       nintact,u
p2none@             puls      y
                    lbsr      unmap
p2x@                rts
mirrors             fcc       / shows the mark of block $/
mirrorsl            equ       *-mirrors

* pass 3: wipe the marks from every free block
pass3               lbsr      mapbyte
                    bne       p3x@
                    lbsr      mapblk
                    lbcs      maperr
                    pshs      y
                    ldd       #SIGOFF1
                    lbsr      zapsig
                    ldy       ,s
                    ldd       #SIGOFF2
                    lbsr      zapsig
                    ldy       ,s
                    ldd       #SIGOFF3
                    lbsr      zapsig
                    puls      y
                    lbsr      unmap
p3x@                rts

maperr              leax      maperrs,pcr
                    ldy       #maperrl
                    lbsr      puts
                    lbra      exit
maperrs             fcc       /F$MapBlk failed: no free slot in this process map/
                    fcb       C$CR
maperrl             equ       *-maperrs

* count the map: free / in use / NotRAM
count               leax      map,u
                    ldy       mapsiz,u
cnt@                lda       ,x+
                    beq       cfree@
                    bmi       cnot@
                    ldd       ninuse,u
                    addd      #1
                    std       ninuse,u
                    bra       cnext@
cfree@              ldd       nfree,u
                    addd      #1
                    std       nfree,u
                    bra       cnext@
cnot@               ldd       nnotram,u
                    addd      #1
                    std       nnotram,u
cnext@              leay      -1,y
                    bne       cnt@
                    ldd       nfree,u
                    addd      ninuse,u
                    std       nram,u
                    rts

* ---- main ----------------------------------------------------------
start               leax      map,u
                    os9       F$GBlkMp            D = block size, Y = blocks in the map
                    lbcs      exit
                    std       blksiz,u
                    sty       mapsiz,u
                    clra
                    clrb
                    std       nfree,u
                    std       ninuse,u
                    std       nnotram,u
                    std       nwrok,u
                    std       nwrbad,u
                    std       nghost,u
                    std       nintact,u
                    leax      t0,pcr
                    ldy       #t0l
                    lbsr      puts
                    lbsr      count
* "map: 256 blocks of 8K: 218 RAM (192 free, 26 in use), 38 not RAM"
                    lbsr      lbeg
                    leay      m1,pcr
                    ldb       #m1l
                    lbsr      copy
                    ldd       mapsiz,u
                    lbsr      dec16
                    leay      m2,pcr
                    ldb       #m2l
                    lbsr      copy
                    ldd       blksiz,u
                    lsra                          bytes -> K
                    rorb
                    lsra
                    rorb
                    tfr       a,b
                    clra
                    lbsr      dec16
                    leay      m3,pcr
                    ldb       #m3l
                    lbsr      copy
                    ldd       nram,u
                    lbsr      dec16
                    leay      m4,pcr
                    ldb       #m4l
                    lbsr      copy
                    ldd       nfree,u
                    lbsr      dec16
                    leay      m5,pcr
                    ldb       #m5l
                    lbsr      copy
                    ldd       ninuse,u
                    lbsr      dec16
                    leay      m6,pcr
                    ldb       #m6l
                    lbsr      copy
                    ldd       nnotram,u
                    lbsr      dec16
                    leay      m7,pcr
                    ldb       #m7l
                    lbsr      copy
                    lbsr      flush
* "krnp2 allots 1744K of RAM to the system"
                    lbsr      lbeg
                    leay      m8,pcr
                    ldb       #m8l
                    lbsr      copy
                    ldd       nram,u
                    lslb                          blocks * 8 = K
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lbsr      dec16
                    leay      m9,pcr
                    ldb       #m9l
                    lbsr      copy
                    lbsr      flush
* the three passes
                    leax      pass1,pcr
                    lbsr      walk
                    leax      pass2,pcr
                    lbsr      walk
                    leax      pass3,pcr
                    lbsr      walk
* "free blocks written and read back: 192 ok, 0 failed"
                    lbsr      lbeg
                    leay      m10,pcr
                    ldb       #m10l
                    lbsr      copy
                    ldd       nwrok,u
                    lbsr      dec16
                    leay      m11,pcr
                    ldb       #m11l
                    lbsr      copy
                    ldd       nwrbad,u
                    lbsr      dec16
                    leay      m12,pcr
                    ldb       #m12l
                    lbsr      copy
                    lbsr      flush
* "ghosts: 0  (free blocks still holding their own mark: 192)"
                    lbsr      lbeg
                    leay      m13,pcr
                    ldb       #m13l
                    lbsr      copy
                    ldd       nghost,u
                    lbsr      dec16
                    leay      m14,pcr
                    ldb       #m14l
                    lbsr      copy
                    ldd       nintact,u
                    lbsr      dec16
                    leay      m15,pcr
                    ldb       #m15l
                    lbsr      copy
                    lbsr      flush
* verdict
                    ldd       nghost,u
                    bne       bad@
                    ldd       nwrbad,u
                    bne       bad@
                    ldd       nintact,u
                    cmpd      nfree,u
                    bne       bad@
                    leax      good,pcr
                    ldy       #goodl
                    bra       say@
bad@                leax      badv,pcr
                    ldy       #badl
say@                lbsr      puts
exit                clrb
                    os9       F$Exit

t0                  fcc       /memtest ed.1: block map ghosting test/
                    fcb       C$CR
t0l                 equ       *-t0
m1                  fcc       /map: /
m1l                 equ       *-m1
m2                  fcc       / blocks of /
m2l                 equ       *-m2
m3                  fcc       /K: /
m3l                 equ       *-m3
m4                  fcc       / RAM (/
m4l                 equ       *-m4
m5                  fcc       / free, /
m5l                 equ       *-m5
m6                  fcc       / in use), /
m6l                 equ       *-m6
m7                  fcc       / not RAM/
m7l                 equ       *-m7
m8                  fcc       /krnp2 allots /
m8l                 equ       *-m8
m9                  fcc       /K of RAM to the system/
m9l                 equ       *-m9
m10                 fcc       /free blocks written and read back: /
m10l                equ       *-m10
m11                 fcc       / ok, /
m11l                equ       *-m11
m12                 fcc       / failed/
m12l                equ       *-m12
m13                 fcc       /ghosts: /
m13l                equ       *-m13
m14                 fcc       /  (free blocks still holding their own mark: /
m14l                equ       *-m14
m15                 fcc       /)/
m15l                equ       *-m15
good                fcc       /verdict: every RAM block in the map is real and distinct/
                    fcb       C$CR
goodl               equ       *-good
badv                fcc       /verdict: the map and the memory DISAGREE - see above/
                    fcb       C$CR
badl                equ       *-badv

                    emod
eom                 equ       *
                    end
