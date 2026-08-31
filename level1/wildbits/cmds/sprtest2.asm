********************************************************************
* SprTest2 - two bouncing 16x16 sprites
*
* Everything is addressed through wildbits.d equates: the VICKY pages
* (SPRITE_BLK/FONT_BLK), the record layout (SPRITE_REC_OFF, SPR_*),
* the control bits (SPRITE_Ctrl_Enable/SPRITE_SIZE*), the graphics
* LUT (GRPH_LUT0_OFF), the MLUT (MMU_MEM_CTRL/MMU_SLOT_*), and the
* master control (TXT.Base/MASTER_CTRL_REG_L/Mstr_Ctrl_*). Note the
* big-endian payoff: one STD at a SPR_X_H / SPR_Y_H offset writes a
* whole coordinate.
*
* Method: direct MLUT programming with IRQs masked around every mapped
* access (the kernel restores the slot registers from its map images
* on task switches; see sprtest). Two 16x16 sprites bounce inside the
* visible area at ~30fps until a key is pressed, then the screen is
* restored.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/08/31  Claude
* Created.

                    nam       sprtest2
                    ttl       Two bouncing sprites

                    ifp1
                    use       defsfile
                    endc

MAPSLOT             equ       MMU_SLOT_5          slot register we borrow
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000 its CPU window

SPRSIZE             equ       16                  sprite edge (SPRITE_SIZE1 = 16x16)
XMIN                equ       32                  visible left  (coordinate origin +32)
XMAX                equ       32+320-SPRSIZE      rightmost fully-visible X
YMIN                equ       32                  visible top
YMAX                equ       32+240-SPRSIZE      bottommost fully-visible Y

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    ORG       0
saveffa0            rmb       1
saveslot            rmb       1
savemcr             rmb       1
blk0                rmb       1
* per-sprite state blocks: x(2), y(2), dx(1), dy(1)
st1                 rmb       6
st2                 rmb       6
scratch             rmb       1
pix1                rmb       SPRSIZE*SPRSIZE     sprite 1 pixels (solid index)
pix2                rmb       SPRSIZE*SPRSIZE     sprite 2 pixels (solid index)
                    rmb       200                 stack
size                equ       .

name                fcs       /sprtest2/
                    fcb       edition

start               equ       *
* Fill the two pixel buffers with distinct solid indices (through the
* ramp LUT below: $FF = cyan, $30 = warm red).
                    ldx       #pix1
                    ldy       #SPRSIZE*SPRSIZE
                    lda       #$FF
f1@                 sta       ,x+
                    leay      -1,y
                    bne       f1@
                    ldx       #pix2
                    ldy       #SPRSIZE*SPRSIZE
                    lda       #$30
f2@                 sta       ,x+
                    leay      -1,y
                    bne       f2@

* Initial positions and velocities
                    ldd       #100
                    std       st1
                    ldd       #60
                    std       st1+2
                    lda       #2
                    sta       st1+4               dx = +2
                    lda       #3
                    sta       st1+5               dy = +3
                    ldd       #250
                    std       st2
                    ldd       #200
                    std       st2+2
                    lda       #-3
                    sta       st2+4               dx = -3
                    lda       #-2
                    sta       st2+5               dy = -2

* ---- One-time setup (single masked window) ----
                    lbsr      MapSpr              mask IRQs, edit=active, window on SPRITE_BLK
                    lda       >MMU_SLOT_0         our data block (needs edit=active)
                    sta       <blk0

* Load graphics LUT0 with a ramp so any index has a color
                    lda       #FONT_BLK
                    sta       >MAPSLOT
                    ldx       #MAPADDR+GRPH_LUT0_OFF
                    clrb
lut@                stb       ,x                  Blue  = index
                    stb       1,x                 Green = index
                    tfr       b,a
                    coma
                    sta       2,x                 Red   = 255-index
                    clr       3,x                 Alpha
                    leax      4,x
                    incb
                    bne       lut@

* Back to the sprite page: clear ALL 128 records first
                    lda       #SPRITE_BLK
                    sta       >MAPSLOT
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldd       #0
                    ldy       #128*SPR_REC_SIZE/2
clr@                std       ,x++
                    leay      -1,y
                    bne       clr@

* Write both records: enabled, 16x16, LUT0, depth 0
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldd       #pix1
                    lbsr      InitRec             record 0 <- pix1, st1 position
                    ldd       st1
                    std       SPR_X_H,x
                    ldd       st1+2
                    std       SPR_Y_H,x
                    leax      SPR_REC_SIZE,x
                    ldd       #pix2
                    lbsr      InitRec             record 1 <- pix2, st2 position
                    ldd       st2
                    std       SPR_X_H,x
                    ldd       st2+2
                    std       SPR_Y_H,x
                    lbsr      UnMap

* Sprite layer on (graphics + text overlay), saving the old MCR
                    ldy       #TXT.Base
                    lda       MASTER_CTRL_REG_L,y
                    sta       <savemcr
                    ora       #Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_Sprite_En
                    sta       MASTER_CTRL_REG_L,y

* ---- Animation loop: bounce, post positions, sleep, poll a key ----
MainLoop            ldx       #st1
                    lbsr      Bounce
                    ldx       #st2
                    lbsr      Bounce

                    lbsr      MapSpr
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    ldd       st1
                    std       SPR_X_H,x           big-endian: one STD per coordinate
                    ldd       st1+2
                    std       SPR_Y_H,x
                    ldd       st2
                    std       SPR_X_H+SPR_REC_SIZE,x
                    ldd       st2+2
                    std       SPR_Y_H+SPR_REC_SIZE,x
                    lbsr      UnMap

                    ldx       #2                  ~30fps
                    os9       F$Sleep

                    clra                          stdin
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       MainLoop            nothing typed: keep bouncing

* Key pressed: consume it, hide our sprites, restore the screen
                    clra
                    ldx       #scratch
                    ldy       #1
                    os9       I$Read
                    lbsr      MapSpr
                    ldx       #MAPADDR+SPRITE_REC_OFF
                    clr       SPR_CTRL,x
                    clr       SPR_CTRL+SPR_REC_SIZE,x
                    lbsr      UnMap
                    ldy       #TXT.Base
                    lda       <savemcr
                    sta       MASTER_CTRL_REG_L,y
                    clrb
                    os9       F$Exit

* ---- InitRec: X -> record, D = pixel buffer logical offset (slot 0).
* Writes ctrl + physical pixel address; preserves X.
InitRec             pshs      d
                    lda       #SPRITE_Ctrl_Enable+SPRITE_SIZE1  16x16, LUT0, depth 0
                    sta       SPR_CTRL,x
                    lda       <blk0
                    lsra
                    lsra
                    lsra
                    sta       SPR_ADDY_H,x        phys 23:16 = block >> 3
                    lda       <blk0
                    asla
                    asla
                    asla
                    asla
                    asla
                    ora       ,s                  | (offset >> 8)
                    sta       SPR_ADDY_M,x        phys 15:8
                    lda       1,s
                    sta       SPR_ADDY_L,x        phys 7:0
                    puls      d,pc

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
