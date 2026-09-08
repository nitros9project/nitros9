********************************************************************
* Sprites - the sprite engine test: up to 128 bouncing 8x8 sprites, each in its own colour
*
* Mirrors sprtest2 (direct MLUT programming with IRQs masked around
* every mapped access, records written through the SPRITE_BLK window,
* the graphics LUT through FONT_BLK) but drives every record the core
* has: SpriteMax = 128 in Sprite_State_Machine.v, 8 bytes each from
* SPRITE_REC_OFF.  Size 8x8 = both SPRITE_SIZE bits.  Sprite n is a
* solid 8x8 of colour index n+1 (index 0 is transparent) through a
* 128-colour RGB-cube sweep in graphics LUT1 (LUT0 is the shell palette); the 8 KB of bitmaps live in an 8K-aligned
* window of the data area, whose physical block number the
* MLUT slot register gives us (edit = active, as MapSpr sets).  Each
* record's pixel address is block*8192 + n*64.
*
* Edition 2: the bitmaps live in the program's own data area (an 8K-aligned
* window inside a 16 KB raw area), not in memory requested with F$SRqMem:
* that is a system-state call on Level 2 and a user program gets E$UnkSvc
* (208) for it.
*
* Positions start on a 16 x 8 grid; the velocity comes from the sprite
* number (dx = 1..4 from bits 1:0, leftwards for odd numbers, dy = 1..4
* from bits 3:2, upwards when bit 1 is set), so the paths diverge at
* once.  ~30 fps until a key is pressed, then the screen is restored.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/07  Claude
* Created from sprtest2 edition 2.
*   2      2026/09/08  Claude
* Bitmap block moved into the data area (F$SRqMem gave error 208 on Level 2).
*   3      2026/09/08  Claude
* Optional count on the command line (sprites 40 = 40 sprites, default
* 128) to bracket the core's sprites-per-scanline limit.
*   4      2026/09/08  Claude
* Renamed sprtest128 -> sprites: the sprite engine test going forward.
*   5      2026/09/08  Claude
* Saves graphics LUT0 entries 0..128 before the colour sweep and puts them
* back on exit; until now the shell background kept the demo's colours
* (user: it does not restore the color tables completely).
*   6      2026/09/08  Claude
* Reading the graphics LUT back through the FONT_BLK window returned zeros on
* the bench (Jr2, 2026-09-08), so edition 5 restored zeros: the shell palette
* came back black. The RTL does carry a read path (true dual-port LUT RAM,
* port A on the 25 MHz IO clock), so the reason is still open; until it is
* understood the LUTs are treated as write-only. The sweep now goes into
* LUT1 and the records select LUT1; LUT0 is never touched, so there is
* nothing to put back.
*   7      2026/09/08  Claude
* The per-frame position loop (PostAll) counted in B and then did ldd ,u,
* which loads B with the sprite's X low byte: the loop ran past record
* 127 into whatever follows the sprite records in page $C0 - the text
* colour LUTs at $1700-$177F (odd entries = record offsets 4-7 = X/Y)
* with garbage from past the state array. Every edition since sprtest128
* had it; it is what wrecked the text colours. Proven with lutrd ed.4 on
* the rc13 roll-4 core (text LUT read-back). Counter moved to scratch.
*   8      2026/09/08  Claude
* The colour sweep (blue 8n, green 255-n, red 2n) kept green above 127 for
* every entry, so only greens, cyans, yellows and pinks showed. Now the
* 128 entries span the RGB cube: 4 red x 8 green x 4 blue levels.

                    nam       sprites
                    ttl       128 bouncing sprites

                    ifp1
                    use       defsfile
                    endc

MAPSLOT             equ       MMU_SLOT_5          slot register we borrow
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000 its CPU window
GRPH_LUT1_OFF       equ       GRPH_LUT0_OFF+$400  graphics LUT1 (LUTn at +$400*n)

NSPR                equ       128                 every record the core has
SPRSIZE             equ       8                   sprite edge (SPRITE_SIZE0+SPRITE_SIZE1 = 8x8)
PIXBYTES            equ       SPRSIZE*SPRSIZE     bytes per bitmap
XMIN                equ       32                  visible left  (coordinate origin +32)
XMAX                equ       32+320-SPRSIZE      rightmost fully-visible X
YMIN                equ       32                  visible top
YMAX                equ       32+240-SPRSIZE      bottommost fully-visible Y

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       8

                    mod       eom,name,tylg,atrv,start,size

                    ORG       0
saveffa0            rmb       1
saveslot            rmb       1
savemcr             rmb       1
pixblk              rmb       1                   physical block of the bitmap block
pixbase             rmb       2                   its logical address (8K-aligned inside pixraw)
scratch             rmb       1
tmp                 rmb       1                   LUT sweep: n-1 = %0RRGGGBB
sprcnt                rmb       1                   sprites in use this run (1..NSPR)
* per-sprite state blocks: x(2), y(2), dx(1), dy(1)
st                  rmb       NSPR*6
* 16 KB raw area: the first 8K boundary inside it is where the 128 bitmaps go
pixraw              rmb       16384
                    rmb       200                 stack
size                equ       .

name                fcs       /sprites/
                    fcb       edition

start               equ       *
* Optional decimal count 1..128 on the command line (X = parameters, D = their length incl. CR)
                    pshs      x
                    ldb       #NSPR
                    stb       <sprcnt
                    cmpd      #1
                    bls       CountDone           nothing but the CR: default
                    puls      x
                    clrb
CountSkip           lda       ,x+
                    cmpa      #' '
                    beq       CountSkip
CountLoop           suba      #'0'
                    cmpa      #9
                    bhi       CountEnd
                    pshs      a
                    lda       #10
                    mul                           D = 10 * B
                    tsta
                    bne       CountBig            past 255
                    addb      ,s+
                    bcs       CountBig2
                    lda       ,x+
                    bra       CountLoop
CountBig            leas      1,s
CountBig2           ldb       #NSPR
                    bra       CountStore
CountEnd            tstb
                    beq       CountDone2          no digits: keep 128
                    cmpb      #NSPR
                    bls       CountStore
                    ldb       #NSPR
CountStore          stb       <sprcnt
                    bra       CountDone2
CountDone           puls      x
CountDone2          equ       *
* The 8K-aligned window for the 128 bitmaps, 64 bytes each, sprite n at n*64:
* first 8K boundary at or above pixraw (U = data area, DP = its page)
                    leax      pixraw+$1FFF,u
                    tfr       x,d
                    anda      #$E0                round down to the 8K block
                    clrb
                    std       <pixbase
* Fill it: sprite n is a solid 8x8 of index n+1
                    ldx       <pixbase
                    lda       #1
NextPix             ldb       #PIXBYTES
FillPix             sta       ,x+
                    decb
                    bne       FillPix
                    inca
                    cmpa      <sprcnt
                    bls       NextPix             (A counts 1..sprcnt)

* Initial positions on a 16 x 8 grid, velocities from the sprite number
                    ldx       #st
                    clrb                          B = sprite number
InitSt              pshs      b
                    andb      #15                 column 0..15
                    lda       #18
                    mul                           18 pixels apart
                    addd      #XMIN+4
                    std       ,x
                    ldb       ,s
                    lsrb
                    lsrb
                    lsrb
                    lsrb                          row 0..7
                    lda       #26
                    mul
                    addd      #YMIN+8
                    std       2,x
                    ldb       ,s
                    andb      #3
                    incb                          dx = 1..4
                    lda       ,s
                    anda      #1                  odd sprite: leftwards
                    beq       DxSet
                    negb
DxSet               stb       4,x
                    ldb       ,s
                    lsrb
                    lsrb
                    andb      #3
                    incb                          dy = 1..4
                    lda       ,s
                    anda      #2                  bit 1 set: upwards
                    beq       DySet
                    negb
DySet               stb       5,x
                    leax      6,x
                    puls      b
                    incb
                    cmpb      <sprcnt
                    blo       InitSt

* ---- One-time setup (single masked window) ----
                    lbsr      MapSpr              mask IRQs, edit=active, window on SPRITE_BLK
* The bitmap block's physical number: its slot is pixbase / $2000
                    lda       <pixbase
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          slot 0..7
                    ldx       #MMU_SLOT_0
                    lda       a,x                 the slot register (needs edit=active)
                    sta       <pixblk

* Load graphics LUT1: index 0 black, then 128 distinct colours that span
* the whole RGB cube (edition 8): n-1 = %0RRGGGBB gives 4 red levels
* (64,127,190,253) x 8 green levels (36..253) x 4 blue levels, so no two
* sprites share a colour and reds, blues and dark tones all appear.
* Edition 6: LUT1, not LUT0 - the shell's text palette is left alone.
                    lda       #FONT_BLK
                    sta       >MAPSLOT
                    ldx       #MAPADDR+GRPH_LUT1_OFF
                    ldd       #0
                    std       ,x
                    std       2,x
                    leax      4,x
                    lda       #1
                    sta       <scratch            n
LutLoop             lda       <scratch            n (1..128)
                    deca                          n-1 = %0RRGGGBB
                    sta       <tmp
                    anda      #3                  BB
                    bsr       Lvl4
                    sta       ,x                  Blue  = 64+63*BB
                    lda       <tmp
                    lsra
                    lsra
                    anda      #7                  GGG
                    ldb       #31
                    mul                           D = 31*GGG (max 217)
                    addb      #36
                    stb       1,x                 Green = 36+31*GGG
                    lda       <tmp
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          RR
                    bsr       Lvl4
                    sta       2,x                 Red   = 64+63*RR
                    clr       3,x                 Alpha
                    leax      4,x
                    inc       <scratch
                    lda       <scratch
                    cmpa      #NSPR+1
                    bne       LutLoop
                    bra       LutDone
* Lvl4: A = 0..3 -> 64 + 63*A (64, 127, 190, 253)
Lvl4                ldb       #63
                    mul
                    addb      #64
                    tfr       b,a
                    rts
LutDone             equ       *

* Back to the sprite page: clear ALL 128 records first
                    lda       #SPRITE_BLK
                    sta       >MAPSLOT
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldd       #0
                    ldy       #NSPR*SPR_REC_SIZE/2
ClrRec              std       ,x++
                    leay      -1,y
                    bne       ClrRec

* Write the records: enabled, 8x8, LUT1, depth 0, bitmap n, position n
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldu       #st
                    clr       <scratch            n
* SPRITE_LUT0 is bit 1 of the control byte = LUT select 1 (bits 2:1): LUT1
RecLoop             lda       #SPRITE_Ctrl_Enable+SPRITE_LUT0+SPRITE_SIZE0+SPRITE_SIZE1
                    sta       SPR_CTRL,x
                    lda       <pixblk
                    lsra
                    lsra
                    lsra
                    sta       SPR_ADDY_H,x        phys 23:16 = block >> 3
                    lda       <pixblk
                    asla
                    asla
                    asla
                    asla
                    asla                          block << 5
                    ldb       <scratch
                    lsrb
                    lsrb                          (n*64) >> 8 = n >> 2
                    pshs      b
                    ora       ,s+
                    sta       SPR_ADDY_M,x        phys 15:8
                    ldb       <scratch
                    andb      #3
                    aslb
                    aslb
                    aslb
                    aslb
                    aslb
                    aslb                          (n & 3) * 64
                    stb       SPR_ADDY_L,x        phys 7:0
                    ldd       ,u
                    std       SPR_X_H,x           big-endian: one STD per coordinate
                    ldd       2,u
                    std       SPR_Y_H,x
                    leax      SPR_REC_SIZE,x
                    leau      6,u
                    inc       <scratch
                    lda       <scratch
                    cmpa      <sprcnt
                    blo       RecLoop
                    lbsr      UnMap

* Sprite layer on (graphics + text overlay), saving the old MCR
                    ldy       #TXT.Base
                    lda       MASTER_CTRL_REG_L,y
                    sta       <savemcr
                    ora       #Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_Sprite_En
                    sta       MASTER_CTRL_REG_L,y

* ---- Animation loop: bounce all 128, post the positions, sleep, poll a key ----
MainLoop            ldx       #st
                    ldb       <sprcnt
BounceAll           pshs      b
                    lbsr      Bounce
                    leax      6,x
                    puls      b
                    decb
                    bne       BounceAll

                    lbsr      MapSpr
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldu       #st
                    lda       <sprcnt             records to post: kept in scratch - ldd ,u below clobbers B
                    sta       <scratch
PostAll             ldd       ,u
                    std       SPR_X_H,x
                    ldd       2,u
                    std       SPR_Y_H,x
                    leax      SPR_REC_SIZE,x
                    leau      6,u
                    dec       <scratch
                    bne       PostAll
                    lbsr      UnMap

                    ldx       #2                  ~30fps
                    os9       F$Sleep

                    clra                          stdin
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       MainLoop            nothing typed: keep bouncing

* Key pressed: consume it, hide every sprite, restore the screen
                    clra
                    ldx       #scratch
                    ldy       #1
                    os9       I$Read
                    lbsr      MapSpr
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldb       <sprcnt
HideAll             clr       SPR_CTRL,x
                    leax      SPR_REC_SIZE,x
                    decb
                    bne       HideAll
                    lbsr      UnMap
                    ldy       #TXT.Base
                    lda       <savemcr
                    sta       MASTER_CTRL_REG_L,y
                    clrb
ExitErr             os9       F$Exit

* ---- Bounce: X -> state {x(2), y(2), dx(1), dy(1)}: step and reflect.
Bounce              ldb       4,x                 dx
                    sex
                    addd      ,x
                    std       ,x
                    cmpd      #XMIN
                    ble       fx@
                    cmpd      #XMAX
                    blt       ny@
fx@                 neg       4,x                 reflect horizontally
ny@                 ldb       5,x                 dy
                    sex
                    addd      2,x
                    std       2,x
                    cmpd      #YMIN
                    ble       fy@
                    cmpd      #YMAX
                    blt       done@
fy@                 neg       5,x                 reflect vertically
done@               rts

* ---- MapSpr: mask IRQs, point the MLUT EDIT bits at the ACTIVE map,
* save the work slot, window SPRITE_BLK. CC stays masked until UnMap.
MapSpr              orcc      #IntMasks
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
                    lda       #SPRITE_BLK
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
