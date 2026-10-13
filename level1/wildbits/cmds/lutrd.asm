********************************************************************
* lutrd - graphics / text LUT read-back probe (2026-09-08)
*
* Maps VICKY pages into MMU slot 5 the way sprites and sprtest2 do (IRQs
* masked, the MLUT edit bits pointed at the active map) and reports:
*   1. LUT0 entries 0..3, the non-zero byte count of each graphics LUT
*   2. the marker slots LUT1 0..3 and LUT0 200..203 as found, then plants
*      5A A5 3C C3 in both (the NEXT run shows whether the RAM keeps them)
*   3. the LUT3 pattern test (write 00..FF step 11, read back, clear)
*   4. the master control register pair at TXT.Base as the CPU reads it
*   5. the SPRITES SEQUENCE replayed on LUT2 entries 0..3: page SPRITE_BLK
*      in the slot, a slot-register read, page FONT_BLK, then the sweep
*      exactly as sprites writes it (std for entry 0, sta per byte after),
*      read back through the same window - "sweep landed: yes/no"
*   6. the TEXT colour LUTs, FG ($1700) and BG ($1740) of page SPRITE_BLK,
*      16 entries x 4 bytes each, read AFTER the replayed sweep - readable
*      only on a core with the shadow read-back (rc13 roll 4 and later;
*      older cores show FF or junk there)
* Run: lutrd, sprites, lutrd.  Every printed line stays under 70 columns.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/08  Claude
* Created.
*   2      2026/09/08  Claude
* ldd reads, LUT0 64..67, per-LUT non-zero counts.
*   3      2026/09/08  Claude
* Persistence markers in LUT1 0..3 and LUT0 200..203, MCR read-back.
*   4      2026/09/08  Claude
* Text FG/BG LUT dump (needs the shadow read-back core) and the replayed
* sprites map-switch + sweep on LUT2 with its own landed/not verdict.

                    nam       lutrd
                    ttl       graphics / text LUT read-back probe

                    ifp1
                    use       defsfile
                    endc

MAPSLOT             equ       MMU_SLOT_5          slot register we borrow
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000 its CPU window
LUT0                equ       MAPADDR+GRPH_LUT0_OFF
LUT1                equ       MAPADDR+GRPH_LUT0_OFF+$400
LUT2                equ       MAPADDR+GRPH_LUT0_OFF+$800
LUT3                equ       MAPADDR+GRPH_LUT0_OFF+$C00 LUTn at +$400*n
LUT0M               equ       LUT0+800            LUT0 entry 200
TXTFG               equ       MAPADDR+TEXT_LUT_FG page SPRITE_BLK ($C0) +$1700
TXTBG               equ       MAPADDR+TEXT_LUT_BG                      +$1740
NB                  equ       16                  bytes per probe (4 entries)

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

                    org       0
saveffa0            rmb       1
saveslot            rmb       1
cnt                 rmb       1
scratch             rmb       1
bufp                rmb       2
endp                rmb       2                   CountNZ end address
mcr                 rmb       2                   MASTER_CTRL_REG_L/H as read
nz0                 rmb       2                   non-zero bytes in LUT0..3
nz1                 rmb       2
nz2                 rmb       2
nz3                 rmb       2
buf1                rmb       NB                  LUT0 0-3
buf6                rmb       NB                  LUT1 0-3 as found
buf7                rmb       NB                  LUT0 200-203 as found
buf3                rmb       NB                  LUT3 read back
buf8                rmb       NB                  LUT2 0-3 after the replayed sweep
fgbuf               rmb       64                  text FG LUT
bgbuf               rmb       64                  text BG LUT
line                rmb       80
stack               rmb       200
size                equ       .

name                fcs       /lutrd/
                    fcb       edition

hexch               fcc       /0123456789ABCDEF/
t0                  fcc       /lutrd ed.4: LUT read-back through slot 5 (FONT_BLK + SPRITE_BLK)/
                    fcb       C$CR
t0l                 equ       *-t0
t1                  fcc       /LUT0 0-3         : /
t1l                 equ       *-t1
t8                  fcc       /non-zero bytes of $400: LUT0 $/
t8l                 equ       *-t8
t8a                 fcc       / LUT1 $/
t8al                equ       *-t8a
t8b                 fcc       / LUT2 $/
t8bl                equ       *-t8b
t8c                 fcc       / LUT3 $/
t8cl                equ       *-t8c
t6                  fcc       /LUT1 0-3 found   : /
t6l                 equ       *-t6
t7                  fcc       /LUT0 200-203 fnd : /
t7l                 equ       *-t7
t9                  fcc       /marker 5A A5 3C C3 x4 now left in LUT1 0-3 and LUT0 200-203/
                    fcb       C$CR
t9l                 equ       *-t9
t3                  fcc       /LUT3 written     : /
t3l                 equ       *-t3
t4                  fcc       /LUT3 read back   : /
t4l                 equ       *-t4
v0                  fcc       /verdict: OK - LUT3 reads return what was written/
                    fcb       C$CR
v0l                 equ       *-v0
v1                  fcc       /verdict: ZEROS - every LUT3 byte read back as $00/
                    fcb       C$CR
v1l                 equ       *-v1
v2                  fcc       /verdict: STALE - LUT3 read-back is the pattern shifted by /
v2l                 equ       *-v2
v2b                 fcc       / byte(s)/
                    fcb       C$CR
v2bl                equ       *-v2b
v3                  fcc       /verdict: DIFF - LUT3 read-back differs from the pattern/
                    fcb       C$CR
v3l                 equ       *-v3
tm                  fcc       /MASTER_CTRL L H  : /
tml                 equ       *-tm
ts                  fcc       /LUT2 0-3 after the replayed sprites sweep (expect 00x4 08 FE 02 00 ..)/
                    fcb       C$CR
tsl                 equ       *-ts
ts2                 fcc       /LUT2 0-3 sweep   : /
ts2l                equ       *-ts2
s0                  fcc       /sweep landed in LUT2: YES/
                    fcb       C$CR
s0l                 equ       *-s0
s1                  fcc       /sweep landed in LUT2: NO - the writes went somewhere else/
                    fcb       C$CR
s1l                 equ       *-s1
tf0                 fcc       /text FG LUT 0-3  : /
tf0l                equ       *-tf0
tf1                 fcc       /text FG LUT 4-7  : /
tf1l                equ       *-tf1
tf2                 fcc       /text FG LUT 8-11 : /
tf2l                equ       *-tf2
tf3                 fcc       /text FG LUT 12-15: /
tf3l                equ       *-tf3
tb0                 fcc       /text BG LUT 0-3  : /
tb0l                equ       *-tb0
tb1                 fcc       /text BG LUT 4-7  : /
tb1l                equ       *-tb1
tb2                 fcc       /text BG LUT 8-11 : /
tb2l                equ       *-tb2
tb3                 fcc       /text BG LUT 12-15: /
tb3l                equ       *-tb3
t5                  fcc       /text LUTs need the shadow core (rc13 roll 4+); run: lutrd, sprites, lutrd/
                    fcb       C$CR
t5l                 equ       *-t5
pattern             fcb       $00,$11,$22,$33,$44,$55,$66,$77
                    fcb       $88,$99,$AA,$BB,$CC,$DD,$EE,$FF
marker              fcb       $5A,$A5,$3C,$C3,$5A,$A5,$3C,$C3
                    fcb       $5A,$A5,$3C,$C3,$5A,$A5,$3C,$C3
sweep               fcb       $00,$00,$00,$00,$08,$FE,$02,$00
                    fcb       $10,$FD,$04,$00,$18,$FC,$06,$00

* ---- the master control register pair, read like sprites does
start               ldy       #TXT.Base
                    ldd       MASTER_CTRL_REG_L,y
                    std       <mcr
* ---- the mapped work, all inside one IRQ-masked bracket
                    lbsr      MapFont
                    ldx       #LUT0
                    ldy       #buf1
                    lbsr      Read16
* non-zero counts, LUT0..3
                    ldx       #LUT0
                    lbsr      CountNZ
                    sty       <nz0
                    lbsr      CountNZ
                    sty       <nz1
                    lbsr      CountNZ
                    sty       <nz2
                    lbsr      CountNZ
                    sty       <nz3
* persistence: what the marker slots hold now, then plant the marker
                    ldx       #LUT1
                    ldy       #buf6
                    lbsr      Read16
                    ldx       #LUT0M
                    ldy       #buf7
                    lbsr      Read16
                    ldx       #LUT1
                    leay      marker,pcr
                    lbsr      Write16
                    ldx       #LUT0M
                    leay      marker,pcr
                    lbsr      Write16
* LUT3 pattern
                    ldx       #LUT3
                    leay      pattern,pcr
                    lbsr      Write16
                    ldx       #LUT3
                    ldy       #buf3
                    lbsr      Read16
                    ldx       #LUT3
                    ldb       #NB
ClrLoop             clr       ,x+
                    decb
                    bne       ClrLoop
* ---- the sprites sequence, replayed: SPRITE_BLK in the slot, a slot-register
* read (sprites fetches its bitmap block number that way), FONT_BLK back in,
* then the sweep as sprites writes it - into LUT2 entries 0..3
                    lda       #SPRITE_BLK
                    sta       >MAPSLOT
                    ldx       #MMU_SLOT_0
                    lda       5,x                 the slot 5 register (edit = active)
                    sta       <scratch
                    lda       #FONT_BLK
                    sta       >MAPSLOT
                    ldx       #LUT2
                    ldd       #0
                    std       ,x
                    std       2,x
                    leax      4,x
                    lda       #1
                    sta       <scratch            n
SwLoop              lda       <scratch
                    asla
                    asla
                    asla
                    sta       ,x                  Blue  = 8n
                    lda       <scratch
                    coma
                    sta       1,x                 Green = 255-n
                    lda       <scratch
                    asla
                    sta       2,x                 Red   = 2n
                    clr       3,x                 Alpha
                    leax      4,x
                    inc       <scratch
                    lda       <scratch
                    cmpa      #4
                    bne       SwLoop
                    ldx       #LUT2
                    ldy       #buf8
                    lbsr      Read16
* ---- the text LUTs, through the SPRITE_BLK page like sprites' record writes
                    lda       #SPRITE_BLK
                    sta       >MAPSLOT
                    ldx       #TXTFG
                    ldy       #fgbuf
                    lbsr      Read16
                    lbsr      Read16
                    lbsr      Read16
                    lbsr      Read16
                    ldx       #TXTBG
                    ldy       #bgbuf
                    lbsr      Read16
                    lbsr      Read16
                    lbsr      Read16
                    lbsr      Read16
                    lbsr      UnMap

* ---- report
                    leax      t0,pcr
                    ldy       #t0l
                    lbsr      PutLine
                    ldd       #buf1
                    std       <bufp
                    leax      t1,pcr
                    ldb       #t1l
                    lbsr      PutRow
* the counts line
                    ldy       #line
                    leax      t8,pcr
                    ldb       #t8l
                    lbsr      Copy
                    ldd       <nz0
                    lbsr      Hex4
                    leax      t8a,pcr
                    ldb       #t8al
                    lbsr      Copy
                    ldd       <nz1
                    lbsr      Hex4
                    leax      t8b,pcr
                    ldb       #t8bl
                    lbsr      Copy
                    ldd       <nz2
                    lbsr      Hex4
                    leax      t8c,pcr
                    ldb       #t8cl
                    lbsr      Copy
                    ldd       <nz3
                    lbsr      Hex4
                    lbsr      EndLine
* persistence rows
                    ldd       #buf6
                    std       <bufp
                    leax      t6,pcr
                    ldb       #t6l
                    lbsr      PutRow
                    ldd       #buf7
                    std       <bufp
                    leax      t7,pcr
                    ldb       #t7l
                    lbsr      PutRow
                    leax      t9,pcr
                    ldy       #t9l
                    lbsr      PutLine
* LUT3 rows
                    leax      pattern,pcr
                    stx       <bufp
                    leax      t3,pcr
                    ldb       #t3l
                    lbsr      PutRow
                    ldd       #buf3
                    std       <bufp
                    leax      t4,pcr
                    ldb       #t4l
                    lbsr      PutRow

* ---- verdict on the LUT3 pattern
                    clrb
                    lbsr      ChkShift            exact match?
                    beq       VerOK
                    ldx       #buf3
                    ldb       #NB
ZeroLoop            lda       ,x+
                    bne       NotZero
                    decb
                    bne       ZeroLoop
                    leax      v1,pcr
                    ldy       #v1l
                    bra       VerOut
NotZero             ldb       #1
ShiftLoop           pshs      b
                    lbsr      ChkShift
                    puls      b
                    beq       VerStale
                    incb
                    cmpb      #4
                    bne       ShiftLoop
                    leax      v3,pcr
                    ldy       #v3l
                    bra       VerOut
VerOK               leax      v0,pcr
                    ldy       #v0l
VerOut              lbsr      PutLine
                    bra       McrLine
VerStale            ldy       #line
                    leax      v2,pcr
                    ldb       #v2l
                    pshs      b
                    lbsr      Copy
                    puls      b
                    addb      #$30                ASCII digit
                    stb       ,y+
                    leax      v2b,pcr
                    ldb       #v2bl
                    lbsr      Copy
                    lbsr      EndLine
* ---- the MCR pair
McrLine             ldy       #line
                    leax      tm,pcr
                    ldb       #tml
                    lbsr      Copy
                    lda       <mcr
                    lbsr      Hex2
                    lda       #C$SPAC
                    sta       ,y+
                    lda       <mcr+1
                    lbsr      Hex2
                    lbsr      EndLine
* ---- the replayed sweep
                    leax      ts,pcr
                    ldy       #tsl
                    lbsr      PutLine
                    ldd       #buf8
                    std       <bufp
                    leax      ts2,pcr
                    ldb       #ts2l
                    lbsr      PutRow
                    ldx       #buf8
                    leay      sweep,pcr
                    ldb       #NB
SwCmp               lda       ,x+
                    cmpa      ,y+
                    bne       SwNo
                    decb
                    bne       SwCmp
                    leax      s0,pcr
                    ldy       #s0l
                    bra       SwOut
SwNo                leax      s1,pcr
                    ldy       #s1l
SwOut               lbsr      PutLine
* ---- the text LUTs, 8 rows
                    ldd       #fgbuf
                    std       <bufp
                    leax      tf0,pcr
                    ldb       #tf0l
                    lbsr      PutRow
                    ldd       #fgbuf+16
                    std       <bufp
                    leax      tf1,pcr
                    ldb       #tf1l
                    lbsr      PutRow
                    ldd       #fgbuf+32
                    std       <bufp
                    leax      tf2,pcr
                    ldb       #tf2l
                    lbsr      PutRow
                    ldd       #fgbuf+48
                    std       <bufp
                    leax      tf3,pcr
                    ldb       #tf3l
                    lbsr      PutRow
                    ldd       #bgbuf
                    std       <bufp
                    leax      tb0,pcr
                    ldb       #tb0l
                    lbsr      PutRow
                    ldd       #bgbuf+16
                    std       <bufp
                    leax      tb1,pcr
                    ldb       #tb1l
                    lbsr      PutRow
                    ldd       #bgbuf+32
                    std       <bufp
                    leax      tb2,pcr
                    ldb       #tb2l
                    lbsr      PutRow
                    ldd       #bgbuf+48
                    std       <bufp
                    leax      tb3,pcr
                    ldb       #tb3l
                    lbsr      PutRow
                    leax      t5,pcr
                    ldy       #t5l
                    lbsr      PutLine
                    clrb
                    os9       F$Exit

* ---- Read16: 16 bytes from X to Y with byte reads (X, Y advance)
Read16              ldb       #NB
Rd16Loop            lda       ,x+
                    sta       ,y+
                    decb
                    bne       Rd16Loop
                    rts

* ---- Write16: 16 bytes from Y to X with byte writes
Write16             ldb       #NB
Wr16Loop            lda       ,y+
                    sta       ,x+
                    decb
                    bne       Wr16Loop
                    rts

* ---- CountNZ: X -> 1024 bytes; Y = count of non-zero bytes; X advanced
CountNZ             ldy       #0
                    pshs      x
                    ldd       ,s
                    addd      #1024
                    std       <endp
                    puls      x
CnzLoop             lda       ,x+
                    beq       CnzNext
                    leay      1,y
CnzNext             cmpx      <endp
                    bne       CnzLoop
                    rts

* ---- ChkShift: B = n (0..3). Z set on return when buf3[n+i] == pattern[i]
* for every i < NB-n, Z clear otherwise.
ChkShift            ldx       #buf3
                    abx
                    lda       #NB
                    pshs      b
                    suba      ,s+
                    sta       <cnt
                    leay      pattern,pcr
CsLoop              lda       ,x+
                    cmpa      ,y+
                    bne       CsFail
                    dec       <cnt
                    bne       CsLoop
                    rts                           Z set: all matched
CsFail              andcc     #$FB                Z clear
                    rts

* ---- Copy: B bytes from X to Y (both advance)
Copy                stb       <cnt
CopyLoop            lda       ,x+
                    sta       ,y+
                    dec       <cnt
                    bne       CopyLoop
                    rts

* ---- PutRow: X -> label, B = label length, <bufp -> NB bytes; writes
* "label xx xx ... xx" as one CR-terminated line (19 + 47 = 66 columns)
PutRow              ldy       #line
                    lbsr      Copy
                    ldx       <bufp
                    lda       #NB
                    sta       <cnt
PrHex               lda       ,x+
                    bsr       Hex2
                    lda       #C$SPAC
                    sta       ,y+
                    dec       <cnt
                    bne       PrHex
                    leay      -1,y                drop the trailing space
* ---- EndLine: terminate the line at Y and write it
EndLine             lda       #C$CR
                    sta       ,y+
                    tfr       y,d
                    subd      #line
                    tfr       d,y
                    ldx       #line
* ---- PutLine: X -> text (CR included), Y = length
PutLine             lda       #1
                    os9       I$WritLn
                    rts

* ---- Hex4: D -> four ASCII hex digits at ,y (X preserved)
Hex4                pshs      b
                    bsr       Hex2
                    puls      a
* ---- Hex2: A -> two ASCII hex digits at ,y++ (X preserved)
Hex2                pshs      a,x
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       Nib
                    lda       ,s
                    anda      #$0F
                    bsr       Nib
                    puls      a,x,pc
Nib                 leax      hexch,pcr
                    lda       a,x
                    sta       ,y+
                    rts

* ---- MapFont: mask IRQs, point the MLUT EDIT bits at the ACTIVE map,
* save the work slot, window FONT_BLK. CC stays masked until UnMap.
MapFont             orcc      #IntMasks
                    lda       >MMU_MEM_CTRL
                    sta       <saveffa0
                    tfr       a,b
                    andb      #$03                active map
                    lslb
                    lslb
                    lslb
                    lslb
                    anda      #$CF                clear edit bits
                    pshs      b
                    ora       ,s+
                    sta       >MMU_MEM_CTRL       edit = active
                    lda       >MAPSLOT
                    sta       <saveslot
                    lda       #FONT_BLK
                    sta       >MAPSLOT
                    rts

* ---- UnMap: restore the slot and MLUT control, unmask IRQs.
UnMap               lda       <saveslot
                    sta       >MAPSLOT
                    lda       <saveffa0
                    sta       >MMU_MEM_CTRL
                    andcc     #^IntMasks
                    rts

                    emod
eom                 equ       *
                    end
