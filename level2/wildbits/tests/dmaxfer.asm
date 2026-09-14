********************************************************************
* dmaxfer - DMA engine TRANSFER test over the 2 MB SRAM (TinyVKY_DMA_Controller, $FEC0)
*
* The SRAM is 1M x 16 = 2 MB = 256 blocks of 8 KB; absolute address = block x $2000, the
* same on the engine's address bus and in the kernel's block map (F$GBlkMp). The test walks
* every FREE block of that map by DMA and ends with the whole map on the screen, one
* character a block, four rows of 64 ($00-$3F .. $C0-$FF): '.' not RAM (flash, cartridge,
* the I/O pages $C0-$CF, undecoded), '#' in use (never written), 'o' free and DMA-filled,
* read back and wiped OK, 'X' free but the DMA fill did not come back right.
*
* RUN THIS ONE DELIBERATELY. Unlike tests/dma (the register probe) it
* starts real transfers, so the engine halts the CPU for each one and
* writes into SRAM through its own port, past the MMU. Everything it
* writes goes into blocks the kernel's map (F$GBlkMp) calls FREE - it
* never touches a block in use, NotRAM or the I/O pages - so a working
* engine leaves the system as it found it. A broken handshake is the
* one thing no software can recover from: the controller waits for
* the CPU to report itself stalled (BA and BS) with no timeout, and if
* that never comes the status bit stays $80 and the CPU is re-halted
* every vertical blank. The polls here time out and say so, but if
* the machine is dead after "start", the state machine is the reason.
*
* What is tested, in this order:
*   1. 1D BYTE FILL   the first free block A, 8192 bytes of $5A
*   2. 1D COPY        A is written by the CPU with a per-byte pattern
*                     (offset low ^ offset high ^ $C3), the engine copies
*                     A to the next free block B, B is read back
*   3. 2D COPY        16 rows of 64 bytes out of A, source stride 128,
*                     into B with stride 64 (a 1024-byte pack); B's
*                     first 1024 bytes are checked row by row
*   3b. 2D FILL       B wiped, then 16 rows of 64 bytes of $77 at stride 128
*                     (control: enable + fill + 2D); the rows must be $77 and
*                     the 64-byte gaps between them still 0 - Fran16's clears
*                     of anything narrower than the screen use this mode
*   4. 16-BIT FILL    A again, control bit 6 (double speed, word fill)
*                     with $A5 in FEC2 and $5A in FEC3; the byte order
*                     the engine used is reported, not judged
*   5. THE WALK       every free block of the map, lowest to highest:
*                     a 1D fill with the block's own number, read back
*                     through F$MapBlk at four offsets and the whole
*                     8192 bytes, then a fill of $00 to wipe it. This
*                     is what proves the engine reaches the whole 2 MB
*                     the kernel manages: the summary gives the first
*                     and last block reached and every failure.
* Every transfer: the registers loaded, control = enable(+mode) with
* start clear, then start set (the engine fires on the rising edge of
* bit 7 while bit 0 is set), the status polled until bit 7 drops, then
* control cleared so the next start is a fresh edge.
*
* Absolute address of block b = b x $2000: FEC5 = b >> 3, FEC6 = b << 5,
* FEC7 = 0. The 1D count is scattered (Count1D = {Ysize[7:0], Xsize}):
* FECF = count[23:16], FECC = count[15:8], FECD = count[7:0]; FECE is
* written 0 because it is a live 2D register.
*
* Reads of the address/size registers come back permuted (tests/dma),
* so nothing here reads them back; only the status byte is read.
* Every printed line stays under 70 columns.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/18  Claude
* Created (user: "write the dma transfer test").
*   2      2026/09/18  Claude
* The 2 MB SRAM named, the block map printed after the walk (user: "say that
* it's testing the 2MB SRAM and show what blocks, all on the same screen").
*   3      2026/09/22  Claude
* The logic-op steps (rc18: $FED4 DMA_OP - b2:0 op 0 copy 1 OR 2 AND 3 XOR
* 4 MASK, b3 NOT, b7 reads 1 = implemented): 6a-6h, each op in fill or copy
* form on block B, verified byte for byte; skipped with a note on a core
* whose $FED4 reads b7 = 0.

                    nam       dmaxfer
                    ttl       DMA engine transfer test

                    ifp1
                    use       defsfile
                    endc

* the write addresses, as the engine consumes them (tests/dma proved the map)
DMACTL              equ       $FEC0               b0 enable, b1 2D, b2 fill, b6 word fill/2x, b7 start
DMASTAT             equ       $FEC1               read: b7 = transfer in progress
DMAFILLB            equ       $FEC1               write: the 8-bit fill value
DMAFILLH            equ       $FEC2               16-bit fill, odd/high byte
DMAFILLL            equ       $FEC3               16-bit fill, even/low byte
DMASRCH             equ       $FEC5               source [23:16]
DMASRCM             equ       $FEC6               source [15:8]
DMASRCL             equ       $FEC7               source [7:0]
DMADSTH             equ       $FEC9               destination [23:16]
DMADSTM             equ       $FECA
DMADSTL             equ       $FECB
DMAXH               equ       $FECC               X size [15:8]  (1D: count [15:8])
DMAXL               equ       $FECD               X size [7:0]   (1D: count [7:0])
DMAYH               equ       $FECE               Y size [15:8]  (2D only, written 0 in 1D)
DMAYL               equ       $FECF               Y size [7:0]   (1D: count [23:16])
DMASSTH             equ       $FED0               source stride [15:8]
DMASSTL             equ       $FED1
DMADSTSH            equ       $FED2               destination stride [15:8]
DMADSTSL            equ       $FED3
DMAOP               equ       $FED4               rc18: b2:0 op, b3 NOT; b7 reads 1 = implemented
OP_OR               equ       $01
OP_AND              equ       $02
OP_XOR              equ       $03
OP_MASK             equ       $04
OP_NOT              equ       $08
OP_IMPL             equ       $80

CT_EN               equ       $01
CT_2D               equ       $02
CT_FILL             equ       $04
CT_WORD             equ       $40
CT_START            equ       $80
ST_BUSY             equ       $80

BLKSIZE             equ       $2000               8192 bytes a block
FILL1               equ       $5A
FB2D              equ       $77                 the 2D fill's byte
GAP2D               equ       128                 the 2D fill's destination stride
PATX                equ       $C3                 the copy pattern's constant
ROWS2D              equ       16
ROWLEN2D            equ       64
SSTRIDE2D           equ       128
DSTRIDE2D           equ       64
WORDH               equ       $A5                 the 16-bit fill, FEC2
WORDL               equ       $5A                 FEC3
IOFIRST             equ       $C0                 the I/O pages are never candidates
IOLAST              equ       $CF
POLLHI              equ       8                   the poll: 8 x 65536 laps, seconds on a 6809

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

                    org       0
map                 rmb       256                 the kernel's block map, one byte a block
res                 rmb       256                 the walk's result a block: 0 untested, 1 OK, 2 failed
blksiz              rmb       2
mapsiz              rmb       2
blka                rmb       2                   block A (word: X for F$MapBlk)
blkb                rmb       2                   block B
cur                 rmb       2                   the walk's block
fails               rmb       2                   walk failures
nwalk               rmb       2                   walk blocks tested
first               rmb       1                   first block reached
last                rmb       1                   last block reached
badblk              rmb       1                   the first failing block of the walk
badoff              rmb       2                   its first bad offset
badgot              rmb       1                   what was there
off                 rmb       2                   verify scratch
want                rmb       1
got                 rmb       1
row                 rmb       1
polls               rmb       1
dig                 rmb       1
dflag               rmb       1
dcnt                rmb       1
rowb                rmb       1                   vfy2df: the byte every row must be
line                rmb       80
stack               rmb       300
size                equ       .

name                fcs       /dmaxfer/
                    fcb       edition

hexch               fcc       /0123456789ABCDEF/

t0                  fcc       /dmaxfer ed.3: DMA over the 2 MB SRAM, 256 x 8K blocks (block x $2000)/
                    fcb       C$CR
t0l                 equ       *-t0
tmap                fcc       /map: no free blocks - nothing to test/
                    fcb       C$CR
tmapl               equ       *-tmap
tab                 fcc       /blocks: A=$/
tabl                equ       *-tab
tb                  fcc       / B=$/
tbl                 equ       *-tb
t1                  fcc       /1. 1D fill A with 5A     /
t1l                 equ       *-t1
t2                  fcc       /2. 1D copy A -> B        /
t2l                 equ       *-t2
t3                  fcc       /3. 2D copy 16x64 A -> B  /
t3l                 equ       *-t3
t4                  fcc       /4. 16-bit fill A5:5A     /
t4l                 equ       *-t4
t3b                 fcc       /3b. 2D fill 16x64 -> B    /
t3bl                equ       *-t3b
tok                 fcc       /OK/
                    fcb       C$CR
tokl                equ       *-tok
tbad                fcc       /BAD at $/
tbadl               equ       *-tbad
tgot                fcc       / got /
tgotl               equ       *-tgot
twant               fcc       / want /
twantl              equ       *-twant
tstuck              fcc       /DMA STUCK: status stays 80 - the engine never finished. Reset./
                    fcb       C$CR
tstuckl             equ       *-tstuck
tw4a                fcc       /   even bytes /
tw4al               equ       *-tw4a
tw4b                fcc       / odd bytes /
tw4bl               equ       *-tw4b
tw4c                fcc       / (FEC3 lands on even when A5 is odd)/
                    fcb       C$CR
tw4cl               equ       *-tw4c
t6                  fcc       /6. DMA_OP $FED4 b7: /
t6l                 equ       *-t6
t6y                 fcc       /implemented - the op steps follow/
                    fcb       C$CR
t6yl                equ       *-t6y
t6n                 fcc       /0 - no logic ops on this core, 6a-6h skipped/
                    fcb       C$CR
t6nl                equ       *-t6n
t6a                 fcc       /6a. OR  fill  0F|F0 -> FF /
t6al                equ       *-t6a
t6b                 fcc       /6b. AND fill  FF&0F -> 0F /
t6bl                equ       *-t6b
t6c                 fcc       /6c. XOR fill  AA^FF -> 55 /
t6cl                equ       *-t6c
t6d                 fcc       /6d. NOT copy  ~5A   -> A5 /
t6dl                equ       *-t6d
t6e                 fcc       |6e. MASK fill 30/12 -> 32 |
t6el                equ       *-t6e
t6f                 fcc       /6f. XOR copy  5A^FF -> A5 /
t6fl                equ       *-t6f
t6g                 fcc       /6g. NOR fill  0F|F0 -> 00 /
t6gl                equ       *-t6g
t6h                 fcc       /6h. OR 2D 16x64 77|88 -> FF/
t6hl                equ       *-t6h
t5                  fcc       /5. walk: every free block filled by DMA and read back .../
                    fcb       C$CR
t5l                 equ       *-t5
tw1                 fcc       /   blocks $/
tw1l                equ       *-tw1
tw2                 fcc       / to $/
tw2l                equ       *-tw2
tw3                 fcc       /: /
tw3l                equ       *-tw3
tw4                 fcc       / tested, /
tw4l                equ       *-tw4
tw5                 fcc       / failed/
                    fcb       C$CR
tw5l                equ       *-tw5
tw6                 fcc       /   first failure: block $/
tw6l                equ       *-tw6
tw7                 fcc       / offset $/
tw7l                equ       *-tw7
tmerr               fcc       /F$MapBlk failed: no free slot in this process map/
                    fcb       C$CR
tmerrl              equ       *-tmerr
tleg                fcc       |   . not RAM or I/O   # in use, not tested   o DMA ok   X DMA FAILED|
                    fcb       C$CR
tlegl               equ       *-tleg
tdone               fcc       /done. control register left at 00./
                    fcb       C$CR
tdonel              equ       *-tdone

* ---- main ----------------------------------------------------------
start               leax      map,u
                    os9       F$GBlkMp            D = block size, Y = blocks in the map
                    lbcs      exit
                    std       blksiz,u
                    sty       mapsiz,u
                    leax      t0,pcr
                    ldy       #t0l
                    lbsr      puts
                    leax      res,u
                    clra
                    clrb
rc@                 sta       ,x+
                    incb
                    bne       rc@                 256 result bytes cleared

* the two free blocks for the mode tests: the first two the map offers
                    clra
                    clrb
                    std       cur,u
                    lbsr      nextfree
                    lbcs      nofree
                    ldd       cur,u
                    std       blka,u
                    addd      #1
                    std       cur,u
                    lbsr      nextfree
                    lbcs      nofree
                    ldd       cur,u
                    std       blkb,u
                    lbsr      lbeg
                    leay      tab,pcr
                    ldb       #tabl
                    lbsr      copy
                    ldb       blka+1,u
                    lbsr      hexb
                    leay      tb,pcr
                    ldb       #tbl
                    lbsr      copy
                    ldb       blkb+1,u
                    lbsr      hexb
                    lbsr      flush

* ---- 1. 1D byte fill of A -------------------------------------------
                    lbsr      lbeg
                    leay      t1,pcr
                    ldb       #t1l
                    lbsr      copy
                    lbsr      flushnc             the label, no line end yet
                    ldb       blka+1,u
                    lda       #FILL1
                    lbsr      fill1d              DMA: 8192 x FILL1 into A
                    lbcs      stuck
                    ldx       blka,u
                    lbsr      mapblk              Y = A in our space
                    lbcs      maperr
                    lda       #FILL1
                    lbsr      vfyconst            the whole block = A?
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbsr      okbad

* ---- 2. 1D copy A -> B ------------------------------------------------
                    lbsr      lbeg
                    leay      t2,pcr
                    ldb       #t2l
                    lbsr      copy
                    lbsr      flushnc
                    ldx       blka,u
                    lbsr      mapblk
                    lbcs      maperr
                    lbsr      wrpat               the CPU writes the pattern into A
                    lbsr      unmap
                    ldb       blkb+1,u
                    lda       #0
                    lbsr      fill1d              B wiped first, so a no-op copy shows
                    lbcs      stuck
                    lda       blka+1,u
                    ldb       blkb+1,u
                    lbsr      copy1d              DMA: A -> B, 8192 bytes
                    lbcs      stuck
                    ldx       blkb,u
                    lbsr      mapblk
                    lbcs      maperr
                    lbsr      vfypat              B = the pattern?
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbsr      okbad

* ---- 3. 2D copy: 16 rows of 64 from A (stride 128) packed into B ---
                    lbsr      lbeg
                    leay      t3,pcr
                    ldb       #t3l
                    lbsr      copy
                    lbsr      flushnc
                    ldb       blkb+1,u
                    lda       #0
                    lbsr      fill1d              B wiped
                    lbcs      stuck
                    lda       blka+1,u
                    ldb       blkb+1,u
                    lbsr      copy2d              A (the pattern is still in it) -> B
                    lbcs      stuck
                    ldx       blkb,u
                    lbsr      mapblk
                    lbcs      maperr
                    lbsr      vfy2d
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbsr      okbad

* ---- 3b. 2D fill: 16 rows of 64 bytes of FB2D into B at stride GAP2D ---
                    lbsr      lbeg
                    leay      t3b,pcr
                    ldb       #t3bl
                    lbsr      copy
                    lbsr      flushnc
                    ldb       blkb+1,u
                    lda       #0
                    lbsr      fill1d              B wiped
                    lbcs      stuck
                    ldb       blkb+1,u
                    lda       #FB2D
                    lbsr      fill2d
                    lbcs      stuck
                    ldx       blkb,u
                    lbsr      mapblk
                    lbcs      maperr
                    lda       #FB2D
                    sta       rowb,u
                    lbsr      vfy2df
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbsr      okbad

* ---- 4. 16-bit fill of A ----------------------------------------------
                    lbsr      lbeg
                    leay      t4,pcr
                    ldb       #t4l
                    lbsr      copy
                    lbsr      flushnc
                    ldb       blka+1,u
                    lbsr      fillword            DMA: word fill A5:5A into A
                    lbcs      stuck
                    ldx       blka,u
                    lbsr      mapblk
                    lbcs      maperr
                    lbsr      vfyword             every even byte alike, every odd byte alike?
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbsr      okbad
                    lbsr      sayword             "   even bytes xx odd bytes yy"

* ---- 6. the logic ops (rc18) --------------------------------------------
                    lbsr      lbeg
                    leay      t6,pcr
                    ldb       #t6l
                    lbsr      copy
                    clr       >DMAOP
                    lda       >DMAOP
                    bmi       op6y@
                    leay      t6n,pcr
                    ldb       #t6nl
                    lbsr      copy
                    lbsr      flushln
                    lbra      step5
op6y@               leay      t6y,pcr
                    ldb       #t6yl
                    lbsr      copy
                    lbsr      flushln

* 6a. OR fill: B = 0F, then fill F0 with OR -> FF
                    leay      t6a,pcr
                    ldb       #t6al
                    lda       #$0F
                    lbsr      opprep              B = plain 0F, the label printed
                    lda       #OP_OR
                    ldb       #$F0
                    lbsr      opfill              fill F0 with the op
                    lda       #$FF
                    lbsr      opvfy

* 6b. AND fill: B = FF, fill 0F with AND -> 0F
                    leay      t6b,pcr
                    ldb       #t6bl
                    lda       #$FF
                    lbsr      opprep
                    lda       #OP_AND
                    ldb       #$0F
                    lbsr      opfill
                    lda       #$0F
                    lbsr      opvfy

* 6c. XOR fill: B = AA, fill FF with XOR -> 55
                    leay      t6c,pcr
                    ldb       #t6cl
                    lda       #$AA
                    lbsr      opprep
                    lda       #OP_XOR
                    ldb       #$FF
                    lbsr      opfill
                    lda       #$55
                    lbsr      opvfy

* 6d. NOT copy: A = 5A (plain), B = 00, copy A -> B with NOT -> A5
                    leay      t6d,pcr
                    ldb       #t6dl
                    lda       #0
                    lbsr      opprep
                    ldb       blka+1,u
                    lda       #$5A
                    lbsr      fill1d              A = 5A, plain
                    lbcs      stuck
                    lda       #OP_NOT
                    lbsr      opcopy              A -> B with the op
                    lda       #$A5
                    lbsr      opvfy

* 6e. MASK fill: B = 12, fill 30 with MASK -> 32 (the 0 nibble keeps B's)
                    leay      t6e,pcr
                    ldb       #t6el
                    lda       #$12
                    lbsr      opprep
                    lda       #OP_MASK
                    ldb       #$30
                    lbsr      opfill
                    lda       #$32
                    lbsr      opvfy

* 6f. XOR copy: A = 5A still, B = FF, copy with XOR -> A5
                    leay      t6f,pcr
                    ldb       #t6fl
                    lda       #$FF
                    lbsr      opprep
                    lda       #OP_XOR
                    lbsr      opcopy
                    lda       #$A5
                    lbsr      opvfy

* 6g. NOR fill: B = 0F, fill F0 with OR+NOT -> 00
                    leay      t6g,pcr
                    ldb       #t6gl
                    lda       #$0F
                    lbsr      opprep
                    lda       #OP_OR+OP_NOT
                    ldb       #$F0
                    lbsr      opfill
                    lda       #0
                    lbsr      opvfy

* 6h. OR 2D fill: B wiped, plain 2D 77 rows, then 2D 88 rows with OR -> FF rows, gaps 0
                    leay      t6h,pcr
                    ldb       #t6hl
                    lda       #0
                    lbsr      opprep              B = 00
                    ldb       blkb+1,u
                    lda       #FB2D
                    lbsr      fill2d              the 77 rows, plain
                    lbcs      stuck
                    lda       #OP_OR
                    sta       >DMAOP
                    ldb       blkb+1,u
                    lda       #$88
                    lbsr      fill2d
                    clr       >DMAOP
                    lbcs      stuck
                    ldx       blkb,u
                    lbsr      mapblk
                    lbcs      maperr
                    lda       #$FF
                    sta       rowb,u
                    lbsr      vfy2df
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbsr      okbad

* ---- 5. the walk over every free block ---------------------------------
step5               leax      t5,pcr
                    ldy       #t5l
                    lbsr      puts
                    clra
                    clrb
                    std       fails,u
                    std       nwalk,u
                    std       cur,u
                    lda       #$FF
                    sta       first,u
                    sta       badblk,u
walk@               lbsr      nextfree
                    lbcs      walkend
                    ldb       cur+1,u
                    lda       first,u
                    cmpa      #$FF
                    bne       w1@
                    stb       first,u
w1@                 stb       last,u
                    tfr       b,a                 the fill byte is the block number
                    lbsr      fill1d
                    lbcs      stuck
                    ldx       cur,u
                    lbsr      mapblk
                    lbcs      maperr
                    lda       cur+1,u
                    lbsr      vfyconst
                    pshs      cc
                    leax      res,u
                    ldb       cur+1,u
                    abx                           X = the block's result byte
                    lda       #1                  OK
                    puls      cc
                    bcc       w1a@
                    lda       #2                  failed
w1a@                sta       ,x
                    bcc       w2@
                    ldd       fails,u
                    addd      #1
                    std       fails,u
                    lda       badblk,u
                    cmpa      #$FF
                    bne       w2@                 the first failure only is kept
                    lda       cur+1,u
                    sta       badblk,u
                    ldd       off,u
                    std       badoff,u
                    lda       got,u
                    sta       badgot,u
w2@                 lbsr      unmap
                    ldb       cur+1,u
                    clra
                    lbsr      fill1d              wiped again
                    lbcs      stuck
                    ldd       nwalk,u
                    addd      #1
                    std       nwalk,u
                    ldd       cur,u
                    addd      #1
                    std       cur,u
                    lbra      walk@
* "   blocks $08 to $EF: 218 tested, 0 failed"
walkend             lbsr      lbeg
                    leay      tw1,pcr
                    ldb       #tw1l
                    lbsr      copy
                    ldb       first,u
                    lbsr      hexb
                    leay      tw2,pcr
                    ldb       #tw2l
                    lbsr      copy
                    ldb       last,u
                    lbsr      hexb
                    leay      tw3,pcr
                    ldb       #tw3l
                    lbsr      copy
                    ldd       nwalk,u
                    lbsr      dec16
                    leay      tw4,pcr
                    ldb       #tw4l
                    lbsr      copy
                    ldd       fails,u
                    lbsr      dec16
                    leay      tw5,pcr
                    ldb       #tw5l
                    lbsr      copy
                    lbsr      flush
* the whole map: four rows of 64 blocks, one character each
                    clra
                    lbsr      mapline
                    lda       #1
                    lbsr      mapline
                    lda       #2
                    lbsr      mapline
                    lda       #3
                    lbsr      mapline
                    leax      tleg,pcr
                    ldy       #tlegl
                    lbsr      puts
                    lda       badblk,u
                    cmpa      #$FF
                    beq       fin
* "   first failure: block $xx offset $xxxx got xx want xx"
                    lbsr      lbeg
                    leay      tw6,pcr
                    ldb       #tw6l
                    lbsr      copy
                    ldb       badblk,u
                    lbsr      hexb
                    leay      tw7,pcr
                    ldb       #tw7l
                    lbsr      copy
                    ldb       badoff,u
                    lbsr      hexb
                    ldb       badoff+1,u
                    lbsr      hexb
                    leay      tgot,pcr
                    ldb       #tgotl
                    lbsr      copy
                    ldb       badgot,u
                    lbsr      hexb
                    leay      twant,pcr
                    ldb       #twantl
                    lbsr      copy
                    ldb       badblk,u
                    lbsr      hexb
                    lbsr      flush

fin                 clr       >DMACTL
                    clr       >DMAOP
                    leax      tdone,pcr
                    ldy       #tdonel
                    lbsr      puts
                    clrb
exit                os9       F$Exit

nofree              leax      tmap,pcr
                    ldy       #tmapl
                    lbsr      puts
                    bra       fin
maperr              leax      tmerr,pcr
                    ldy       #tmerrl
                    lbsr      puts
                    bra       fin
stuck               leax      tstuck,pcr
                    ldy       #tstuckl
                    lbsr      puts
                    clr       >DMACTL
                    clr       >DMAOP
                    ldb       #1
                    os9       F$Exit

* ---- the engine ----------------------------------------------------
* setaddr: B = a block number -> A:B = the top two bytes of b x $2000
* (b >> 3 and b << 5); the low byte is always 0
blkhi               pshs      b
                    lsrb
                    lsrb
                    lsrb
                    tfr       b,a                 A = b >> 3
                    puls      b
                    aslb
                    aslb
                    aslb
                    aslb
                    aslb                          B = b << 5
                    rts

* srcblk / dstblk: B = block -> the source / destination registers
srcblk              bsr       blkhi
                    sta       >DMASRCH
                    stb       >DMASRCM
                    clr       >DMASRCL
                    rts
dstblk              bsr       blkhi
                    sta       >DMADSTH
                    stb       >DMADSTM
                    clr       >DMADSTL
                    rts

* count1d: D = a byte count (< 65536) -> the scattered 1D count
count1d             sta       >DMAXH
                    stb       >DMAXL
                    clr       >DMAYL              count [23:16]
                    clr       >DMAYH              a live 2D register: left clean
                    rts

* fire: A = the control bits (enable + mode). Writes them with start
* clear, then with start set (the rising edge fires), polls the status
* until bit 7 drops, clears control. Carry set = timed out.
fire                sta       >DMACTL
                    ora       #CT_START
                    sta       >DMACTL
                    lda       #POLLHI
                    sta       polls,u
                    ldx       #0
poll@               lda       >DMASTAT
                    bita      #ST_BUSY
                    beq       fired@
                    leax      -1,x
                    bne       poll@
                    dec       polls,u
                    bne       poll@
                    clr       >DMACTL
                    orcc      #Carry
                    rts
fired@              clr       >DMACTL
                    andcc     #^Carry
                    rts

* fill1d: B = block, A = the fill byte: 8192 bytes. Carry = timed out.
fill1d              pshs      a
                    bsr       dstblk
                    puls      a
                    sta       >DMAFILLB
                    ldd       #BLKSIZE
                    bsr       count1d
                    lda       #CT_EN+CT_FILL
                    bra       fire

* fillword: B = block: 8192 bytes of the word WORDH:WORDL (control b6)
fillword            bsr       dstblk
                    lda       #WORDH
                    sta       >DMAFILLH
                    lda       #WORDL
                    sta       >DMAFILLL
                    ldd       #BLKSIZE
                    bsr       count1d
                    lda       #CT_EN+CT_FILL+CT_WORD
                    bra       fire

* ---- the op steps' helpers (ed.3) ------------------------------------------
* opprep: Y = the label, B = its length, A = the byte B is filled with (plain) first.
* Prints the label (no line end) and does the plain fill; stuck exits.
opprep              pshs      a
                    lbsr      lbeg
                    lbsr      copy
                    lbsr      flushnc
                    puls      a
                    ldb       blkb+1,u
                    lbsr      fill1d
                    lbcs      stuck
                    rts
* opfill: A = the op, B = the fill byte: a 1D fill of B with the op on
opfill              sta       >DMAOP
                    tfr       b,a
                    ldb       blkb+1,u
                    lbsr      fill1d
                    clr       >DMAOP
                    lbcs      stuck
                    rts
* opcopy: A = the op: a 1D copy A -> B with the op on
opcopy              sta       >DMAOP
                    lda       blka+1,u
                    ldb       blkb+1,u
                    lbsr      copy1d
                    clr       >DMAOP
                    lbcs      stuck
                    rts
* opvfy: A = the byte every one of B's 8192 must be; OK / BAD printed
opvfy               pshs      a
                    ldx       blkb,u
                    lbsr      mapblk
                    lbcs      maperr
                    puls      a
                    lbsr      vfyconst
                    pshs      cc
                    lbsr      unmap
                    puls      cc
                    lbra      okbad

* copy1d: A = source block, B = destination block, 8192 bytes
copy1d              pshs      a
                    lbsr      dstblk
                    puls      b
                    lbsr      srcblk
                    ldd       #BLKSIZE
                    lbsr      count1d
                    lda       #CT_EN
                    lbra      fire

* fill2d: B = destination block, A = the byte: ROWS2D rows of ROWLEN2D bytes
* at destination stride GAP2D (control: enable + fill + 2D)
fill2d              pshs      a
                    lbsr      dstblk
                    puls      a
                    sta       >DMAFILLB
                    ldd       #ROWLEN2D
                    sta       >DMAXH
                    stb       >DMAXL
                    ldd       #ROWS2D
                    sta       >DMAYH
                    stb       >DMAYL
                    ldd       #GAP2D
                    sta       >DMASSTH
                    stb       >DMASSTL
                    sta       >DMADSTSH
                    stb       >DMADSTSL
                    lda       #CT_EN+CT_FILL+CT_2D
                    lbra      fire

* copy2d: A = source block, B = destination block: ROWS2D rows of
* ROWLEN2D bytes, source stride SSTRIDE2D, destination stride DSTRIDE2D
copy2d              pshs      a
                    lbsr      dstblk
                    puls      b
                    lbsr      srcblk
                    ldd       #ROWLEN2D
                    sta       >DMAXH
                    stb       >DMAXL
                    ldd       #ROWS2D
                    sta       >DMAYH
                    stb       >DMAYL
                    ldd       #SSTRIDE2D
                    sta       >DMASSTH
                    stb       >DMASSTL
                    ldd       #DSTRIDE2D
                    sta       >DMADSTSH
                    stb       >DMADSTSL
                    lda       #CT_EN+CT_2D
                    lbra      fire

* ---- the blocks in our space -----------------------------------------
* mapblk: X = block -> Y = its address here; carry set on error. U kept.
mapblk              pshs      u
                    ldb       #1
                    os9       F$MapBlk            U = the block's address
                    tfr       u,y
                    puls      u,pc

* unmap: the block at Y. U kept.
unmap               pshs      u
                    tfr       y,u
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u,pc

* wrpat: the copy pattern into the block at Y: byte[i] = i.l ^ i.h ^ PATX
wrpat               pshs      y
                    ldx       #0
wp@                 tfr       x,d
                    eora      #PATX
                    stb       want,u
                    eora      want,u
                    sta       ,y+
                    leax      1,x
                    cmpx      #BLKSIZE
                    bne       wp@
                    puls      y,pc

* vfyconst: A = the byte every one of the 8192 at Y must be.
* Carry set = a mismatch; off,u = its offset, got,u = the byte there.
vfyconst            sta       want,u
                    pshs      y
                    ldx       #0
vc@                 lda       ,y+
                    cmpa      want,u
                    bne       vcbad@
                    leax      1,x
                    cmpx      #BLKSIZE
                    bne       vc@
                    puls      y
                    andcc     #^Carry
                    rts
vcbad@              sta       got,u
                    stx       off,u
                    puls      y
                    orcc      #Carry
                    rts

* vfypat: the block at Y must hold the copy pattern
vfypat              pshs      y
                    ldx       #0
vp@                 tfr       x,d
                    eora      #PATX
                    stb       want,u
                    eora      want,u
                    sta       want,u
                    lda       ,y+
                    cmpa      want,u
                    bne       vpbad@
                    leax      1,x
                    cmpx      #BLKSIZE
                    bne       vp@
                    puls      y
                    andcc     #^Carry
                    rts
vpbad@              sta       got,u
                    stx       off,u
                    puls      y
                    orcc      #Carry
                    rts

* vfy2d: B's first ROWS2D x ROWLEN2D bytes at Y must be A's rows r*SSTRIDE2D..+ROWLEN2D
* of the copy pattern: byte (r*DSTRIDE2D + c) = pattern(r*SSTRIDE2D + c). row/dig = r/c.
vfy2d               pshs      y
                    clr       row,u
                    ldx       #0                  the destination offset, for the report
v2r@                clr       dig,u
v2c@                lda       row,u
                    ldb       #SSTRIDE2D
                    mul                           D = row x source stride
                    addb      dig,u               + the column
                    adca      #0                  D = the source offset
                    eora      #PATX
                    pshs      b
                    eora      ,s+                 the pattern byte there
                    sta       want,u
                    lda       ,y+
                    cmpa      want,u
                    bne       v2bad@
                    leax      1,x
                    inc       dig,u
                    lda       dig,u
                    cmpa      #ROWLEN2D
                    bne       v2c@
                    inc       row,u
                    lda       row,u
                    cmpa      #ROWS2D
                    bne       v2r@
                    puls      y
                    andcc     #^Carry
                    rts
v2bad@              sta       got,u
                    stx       off,u
                    puls      y
                    orcc      #Carry
                    rts

* vfy2df: ROWS2D rows at Y: the first ROWLEN2D bytes of each GAP2D-byte row are
* FB2D, the rest of the row 0. row = the row, dig = the column.
vfy2df              pshs      y
                    clr       row,u
                    ldx       #0
v2fr@               clr       dig,u
v2fc@               lda       rowb,u
                    ldb       dig,u
                    cmpb      #ROWLEN2D
                    blo       v2f1@
                    clra                          the gap: still 0
v2f1@               sta       want,u
                    lda       ,y+
                    cmpa      want,u
                    bne       v2fbad@
                    leax      1,x
                    inc       dig,u
                    lda       dig,u
                    cmpa      #GAP2D
                    bne       v2fc@
                    inc       row,u
                    lda       row,u
                    cmpa      #ROWS2D
                    bne       v2fr@
                    puls      y
                    andcc     #^Carry
                    rts
v2fbad@             sta       got,u
                    stx       off,u
                    puls      y
                    orcc      #Carry
                    rts

* vfyword: every even byte at Y must equal byte 0 and every odd byte
* byte 1, and the two must be WORDH/WORDL in one order or the other.
* off/got on a mismatch. want = the even byte, row = the odd byte kept for sayword.
vfyword             pshs      y
                    lda       ,y
                    sta       want,u
                    lda       1,y
                    sta       row,u
                    ldx       #0
vw@                 lda       ,y+
                    cmpa      want,u
                    bne       vwbad@
                    leax      1,x
                    lda       ,y+
                    cmpa      row,u
                    bne       vwbad@
                    leax      1,x
                    cmpx      #BLKSIZE
                    bne       vw@
                    lda       want,u
                    cmpa      #WORDH
                    bne       vw1@
                    lda       row,u
                    cmpa      #WORDL
                    beq       vwok@
                    bra       vwbad2@
vw1@                cmpa      #WORDL
                    bne       vwbad2@
                    lda       row,u
                    cmpa      #WORDH
                    bne       vwbad2@
vwok@               puls      y
                    andcc     #^Carry
                    rts
vwbad2@             ldx       #1                  the pair is not A5/5A either way: odd against even
                    lda       row,u
vwbad@              sta       got,u
                    stx       off,u
                    puls      y
                    orcc      #Carry
                    rts

* sayword: "   even bytes xx odd bytes yy (FEC3 lands on even when A5 is odd)"
sayword             lbsr      lbeg
                    leay      tw4a,pcr
                    ldb       #tw4al
                    lbsr      copy
                    ldb       want,u
                    lbsr      hexb
                    leay      tw4b,pcr
                    ldb       #tw4bl
                    lbsr      copy
                    ldb       row,u
                    lbsr      hexb
                    leay      tw4c,pcr
                    ldb       #tw4cl
                    lbsr      copy
                    lbra      flushln             tw4c carries the CR

* mapline: A = the row (0-3): "$r0-$rF " then the 64 blocks' characters, printed
mapline             pshs      a
                    lbsr      lbeg
                    lda       #'$
                    sta       ,x+
                    ldb       ,s
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb
                    lslb                          B = row x 64, the first block
                    stb       dig,u               the block being shown
                    lbsr      hexb
                    lda       #'-
                    sta       ,x+
                    lda       #'$
                    sta       ,x+
                    ldb       dig,u
                    addb      #63
                    lbsr      hexb
                    lda       #C$SPAC
                    sta       ,x+
                    lda       #64
                    sta       row,u               blocks left in the row
ml1@                ldb       dig,u
                    lbsr      blkchar
                    sta       ,x+
                    inc       dig,u
                    dec       row,u
                    bne       ml1@
                    lbsr      flush
                    puls      a,pc

* blkchar: B = a block -> A = its character: '.' not RAM or an I/O page, '#' in use,
* 'o' free and tested OK, 'X' free and failed, '?' free but never reached. Keeps B and X.
blkchar             pshs      b,x
                    cmpb      #IOFIRST
                    blo       bc1@
                    cmpb      #IOLAST
                    bhi       bc1@
                    lda       #'.
                    bra       bc9@
bc1@                leax      map,u
                    abx
                    lda       ,x                  the map byte: 0 free, bit 7 NotRAM, else in use
                    bmi       bc2@
                    beq       bc3@
                    lda       #'#
                    bra       bc9@
bc2@                lda       #'.
                    bra       bc9@
bc3@                leax      res,u
                    abx
                    lda       ,x
                    cmpa      #1
                    bne       bc4@
                    lda       #'o
                    bra       bc9@
bc4@                cmpa      #2
                    bne       bc5@
                    lda       #'X
                    bra       bc9@
bc5@                lda       #'?
bc9@                puls      b,x,pc

* nextfree: from cur,u upward, the next block the map calls free (0)
* that is not an I/O page; cur,u = it; carry set when none is left
nextfree            ldd       cur,u
nf@                 cmpd      mapsiz,u
                    bhs       nfnone@
                    cmpb      #IOFIRST
                    blo       nf1@
                    cmpb      #IOLAST
                    bls       nf2@
nf1@                leax      map,u
                    tst       d,x
                    beq       nfgot@
nf2@                addd      #1
                    bra       nf@
nfgot@              std       cur,u
                    andcc     #^Carry
                    rts
nfnone@             orcc      #Carry
                    rts

* ---- output ---------------------------------------------------------
* okbad: carry clear -> "OK"; set -> "BAD at $off got xx want xx"
okbad               bcs       ob1@
                    leax      tok,pcr
                    ldy       #tokl
                    bra       puts
ob1@                lbsr      lbeg
                    leay      tbad,pcr
                    ldb       #tbadl
                    lbsr      copy
                    ldb       off,u
                    lbsr      hexb
                    ldb       off+1,u
                    lbsr      hexb
                    leay      tgot,pcr
                    ldb       #tgotl
                    lbsr      copy
                    ldb       got,u
                    lbsr      hexb
                    leay      twant,pcr
                    ldb       #twantl
                    lbsr      copy
                    ldb       want,u
                    lbsr      hexb
                    lbra      flush

* puts: the CR-terminated line at X (Y = its length) on path 1
puts                lda       #1
                    os9       I$WritLn
                    rts

* lbeg: start a line, X = line,u
lbeg                leax      line,u
                    rts

* copy: B bytes from Y to X
copy                lda       ,y+
                    sta       ,x+
                    decb
                    bne       copy
                    rts

* hexb: B as two hex digits at X
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

* dec16: D in decimal at X, no leading zeros
dec16               pshs      y
                    pshs      a,b
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
                    beq       d5@
d4@                 pshs      a,b
                    ldb       dig,u
                    addb      #'0
                    stb       ,x+
                    inc       dflag,u
                    puls      a,b
d5@                 leay      2,y
                    dec       dcnt,u
                    bne       d1@
                    addb      #'0
                    stb       ,x+
                    puls      y,pc
pow10               fdb       10000,1000,100,10

* flush: end the line at X with a CR and print it (I$WritLn: the CR is a line end)
flush               lda       #C$CR
                    sta       ,x+
* flushln: the line at X already ends in a CR
flushln             bsr       linelen
                    lda       #1
                    os9       I$WritLn
                    rts
* flushnc: the line at X has no CR: I$Write, so the terminal stays on the line (a label)
flushnc             bsr       linelen
                    lda       #1
                    os9       I$Write
                    rts
* linelen: X = the end of the text in line,u -> Y = its length, X = line,u
linelen             tfr       x,d
                    subd      #line
                    pshs      u
                    subd      ,s++                length = X - (U + line)
                    tfr       d,y
                    leax      line,u
                    rts

                    emod
eom                 equ       *
                    end
