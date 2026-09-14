********************************************************************
* TLTest - TinyVicky Hardware Tilemap Test
*
* Demonstrates and tests the TinyVicky II hardware scrolling tilemap
* engine on Wildbits Jr2 (FNX6809 core).
*
* Allocates and initializes:
*  - Two 16x16 pixel tiles (tile 0 = empty/transparent, tile 1 = cyan box with
*    red border, tile 2 = red box with grey lattice).
*  - A 20x15 virtual tile matrix of 16-bit entries in system SRAM.
*  - Sets Tile Set 0 base address at $F180 (Page $C0 $1180).
*  - Configures Tilemap 0 (TL0) at $F100 (Page $C0 $1100) with 20x15 dimensions.
*  - Routes TL0 to Layer 0 via $FFC2 (bits 3:0 = 4).
*  - Enables graphics + text overlay + tilemap ($FFC0 = $17).
*  - Smoothly scrolls the playfield diagonally for ~5 seconds (or until key/ESC).
*  - Catches signals (ESC/abort) via F$Icpt for a clean, error-free shutdown.
*  - Restores all registers and exits cleanly to the NitrOS-9 shell.
********************************************************************

                    nam       tltest
                    ttl       TinyVicky Tilemap Test

                    ifp1
                    use       defsfile
                    endc

MAPSLOT             equ       MMU_SLOT_5          slot register we borrow ($A000)
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000

TILE_SIZE_PX        equ       16                  16x16 tiles
TILE_BYTES          equ       TILE_SIZE_PX*TILE_SIZE_PX
MAP_W               equ       20                  20 columns
MAP_H               equ       15                  15 rows
MAP_CELLS           equ       MAP_W*MAP_H
AUTO_FRAMES         equ       150                 ~5 seconds at ~30 fps

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

                    ORG       0
savecc              rmb       1
saveffa0            rmb       1
saveslot            rmb       1
savemcr             rmb       1
savelayer0          rmb       1
blk0                rmb       1                   physical block of our process memory
scroll_x            rmb       2
scroll_y            rmb       2
frames_left         rmb       2                   countdown to auto-exit
sig_flag            rmb       1                   signal received flag
scratch             rmb       1
* Tile pixel data: Tile 0 (empty), Tile 1 (256 bytes), Tile 2 (256 bytes)
savedregs           rmb       16
savedpal            rmb       1024
tile0_pix           rmb       TILE_BYTES
tile1_pix           rmb       TILE_BYTES
tile2_pix           rmb       TILE_BYTES
* Tilemap matrix (20x15 = 300 words = 600 bytes)
map_matrix          rmb       MAP_CELLS*2
                    rmb       256                 stack
size                equ       .

name                fcs       /tltest/
                    fcb       edition

start               equ       *
* ---- 0. Set up Signal Intercept Handler (F$Icpt) ----
                    clr       <sig_flag
                    leax      SigHandler,pcr      pointer to signal intercept handler
                    os9       F$Icpt              register handler (U already points to data area)

* Acquire terminal device ownership so keydrv_ps2 directs S$Abort to us (sets V.LPRC)
                    clra                          path 0 (stdin)
                    ldy       #0                  0 bytes
                    os9       I$Read
                    lda       #1                  path 1 (stdout)
                    ldy       #0                  0 bytes
                    os9       I$Write

* Set auto-exit countdown (~5 seconds at ~30 fps)
                    ldd       #AUTO_FRAMES
                    std       <frames_left

* Clear Tile 0 pixels (16x16 transparent: all 0)
                    leax      tile0_pix,u
                    ldb       #0
clr0@               clr       ,x+
                    decb
                    bne       clr0@

* ---- 1. Initialize Tile 1 pixels (16x16: Red border, Cyan interior) ----
                    leax      tile1_pix,u
                    clr       <scratch            scratch = row
row1@               clrb                          B = col
col1@               tst       <scratch            top edge?
                    beq       border1@
                    lda       <scratch
                    cmpa      #15                 bottom edge?
                    beq       border1@
                    tstb                          left edge?
                    beq       border1@
                    cmpb      #15                 right edge?
                    beq       border1@
                    lda       #$FF                cyan interior
                    bra       pix1_st@
border1@            lda       #$30                warm red border
pix1_st@            sta       ,x+
                    incb
                    cmpb      #16
                    bne       col1@
                    inc       <scratch
                    lda       <scratch
                    cmpa      #16
                    bne       row1@

* ---- 2. Initialize Tile 2 pixels (16x16: Warm red lattice pattern) ----
                    leax      tile2_pix,u
                    clr       <scratch            scratch = row
row2@               clrb                          B = col
col2@               lda       <scratch
                    pshs      b
                    cmpa      ,s+                 row == col (main diagonal)?
                    beq       diag2@
                    lda       <scratch
                    pshs      b
                    adda      ,s+                 row + col == 15 (anti-diagonal)?
                    cmpa      #15
                    beq       diag2@
                    lda       #$30                warm red background
                    bra       pix2_st@
diag2@              lda       #$80                grey diagonal lattice
pix2_st@            sta       ,x+
                    incb
                    cmpb      #16
                    bne       col2@
                    inc       <scratch
                    lda       <scratch
                    cmpa      #16
                    bne       row2@

* ---- 3. Fill the 20x15 Tilemap Matrix ----
* Alternate Tile 1 and Tile 2 in a checkerboard pattern.
* Each entry: Byte 0 = tile index, Byte 1 = attribute (0 = TS0, LUT0).
                    leax      map_matrix,u
                    clr       <scratch            scratch = row
mrow@               clrb                          B = col
mcol@               lda       <scratch
                    pshs      b
                    adda      ,s+                 (row + col) & 1
                    anda      #1
                    bne       use_t2@
                    lda       #1                  Tile 1
                    bra       mst@
use_t2@             lda       #2                  Tile 2
mst@                sta       ,x+                 Byte 0: tile index
                    clr       ,x+                 Byte 1: attr (TS0, LUT0)
                    incb
                    cmpb      #MAP_W
                    bne       mcol@
                    inc       <scratch
                    lda       <scratch
                    cmpa      #MAP_H
                    bne       mrow@

* Initial scroll positions
                    ldd       #0
                    std       <scroll_x
                    std       <scroll_y

* ---- 4. Configure VICKY Page $C0 Registers ----
                    lbsr      MapVky
                    lda       >MMU_SLOT_0         physical block of process
                    sta       <blk0

* Save the tilemap and tileset records before changing them.
                    ldx       #MAPADDR+$1100
                    leay      savedregs,u
                    ldb       #12
save_tm             lda       ,x+
                    sta       ,y+
                    decb
                    bne       save_tm
                    ldx       #MAPADDR+$1180
                    ldb       #4
save_ts             lda       ,x+
                    sta       ,y+
                    decb
                    bne       save_ts
                    lda       #FONT_BLK
                    sta       >MAPSLOT
                    ldx       #MAPADDR+GRPH_LUT0_OFF
                    leay      savedpal,u
                    ldd       #1024
save_pal            pshs      d
                    lda       ,x+
                    sta       ,y+
                    puls      d
                    subd      #1
                    bne       save_pal

* Load graphics LUT0 with color ramp
                    lda       #FONT_BLK           Block $C1
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

* Window back to Page $C0 (Block $C0)
                    lda       #SPRITE_BLK         Block $C0
                    sta       >MAPSLOT

* RC16 tileset: configuration, address high, middle, low.
                    leax      tile0_pix,u
                    tfr       x,d
                    lbsr      PhysAddr
                    ldx       #MAPADDR+$1180
                    clr       ,x
                    sta       1,x
                    stb       2,x
                    lda       <scratch
                    sta       3,x
* RC16 tilemap: control, address H/M/L, big-endian sizes and positions.
                    leay      map_matrix,u
                    tfr       y,d
                    lbsr      PhysAddr
                    ldx       #MAPADDR+$1100
                    sta       1,x
                    stb       2,x
                    lda       <scratch
                    sta       3,x
                    ldd       #MAP_W
                    std       4,x
                    ldd       #MAP_H
                    std       6,x
                    clra
                    clrb
                    std       8,x
                    std       10,x
                    lda       #TILE_Enable
                    sta       ,x

                    lbsr      UnMap

* ---- 5. Configure VICKY Master Video Registers ----
                    ldy       #TXT.Base
                    lda       VKY_LAYER_CTRL_0
                    sta       <savelayer0
                    anda      #$F0                preserve Layer 1
                    ora       #$04                Layer 0 Source = 4 (Tilemap 0)
                    sta       VKY_LAYER_CTRL_0

                    lda       MASTER_CTRL_REG_L,y
                    sta       <savemcr
                    ora       #Mstr_Ctrl_Graph_Mode_En+Mstr_Ctrl_Text_Overlay+Mstr_Ctrl_TileMap_En
                    sta       MASTER_CTRL_REG_L,y

* ---- 6. Scrolling Animation Loop ----
MainLoop            equ       *
* Check if signal was caught
                    tst       <sig_flag
                    lbne      ExitClean

* Check auto-exit countdown (~5 seconds)
                    ldd       <frames_left
                    subd      #1
                    std       <frames_left
                    lble      ExitClean

* Poll stdin for keypress
                    clra
                    ldb       #SS.Ready
                    os9       I$GetStt
                    lbcc      EatKeyAndExit

* Update scroll coordinates
                    ldd       <scroll_x
                    addd      #1
                    cmpd      #MAP_W*TILE_SIZE_PX
                    blt       sx_ok@
                    clra
                    clrb
sx_ok@              std       <scroll_x

                    ldd       <scroll_y
                    addd      #1
                    cmpd      #MAP_H*TILE_SIZE_PX
                    blt       sy_ok@
                    clra
                    clrb
sy_ok@              std       <scroll_y

* RC16 scroll registers are big-endian.
                    lbsr      MapVky
                    ldx       #MAPADDR+$1100
                    ldd       <scroll_x
                    std       8,x
                    ldd       <scroll_y
                    std       10,x
                    lbsr      UnMap

                    ldx       #2                  ~30 fps pacing
                    os9       F$Sleep

                    lbra      MainLoop

EatKeyAndExit       equ       ExitClean

* ---- 7. Clean Exit: restore registers and quit with status 0 ----
ExitClean           equ       *
* Remove signal intercept routine
                    ldx       #0
                    os9       F$Icpt

* Flush any pending keys from stdin so nothing leaks to shell
flush@              clra
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       fl_done@
                    clra
                    leax      scratch,u
                    ldy       #1
                    os9       I$Read
                    bra       flush@
fl_done@

* Stop our tile fetches, then restore the original palette and records.
                    lbsr      MapVky
                    clr       >MAPADDR+$1100
                    lda       #FONT_BLK
                    sta       >MAPSLOT
                    leax      savedpal,u
                    ldy       #MAPADDR+GRPH_LUT0_OFF
                    ldd       #1024
restore_pal         pshs      d
                    lda       ,x+
                    sta       ,y+
                    puls      d
                    subd      #1
                    bne       restore_pal
                    lda       #SPRITE_BLK
                    sta       >MAPSLOT
                    leax      savedregs,u
                    ldy       #MAPADDR+$1100
                    ldb       #12
restore_tm          lda       ,x+
                    sta       ,y+
                    decb
                    bne       restore_tm
                    ldy       #MAPADDR+$1180
                    ldb       #4
restore_ts          lda       ,x+
                    sta       ,y+
                    decb
                    bne       restore_ts
                    lbsr      UnMap

* Restore Layer 0 and Master Control
                    lda       <savelayer0
                    sta       VKY_LAYER_CTRL_0
                    ldy       #TXT.Base
                    lda       <savemcr
                    sta       MASTER_CTRL_REG_L,y

                    clrb                          Status 0 = Success
                    os9       F$Exit

* ---- Signal Intercept Routine ----
* Called by OS-9 kernel when a signal (e.g. S$Abort / ESC) arrives.
* U = data area pointer, B = signal code.
SigHandler          stb       <sig_flag,u         record signal code
                    rti                           return to resume / wake up

* ---- PhysAddr: D = process logical address (slot 0).
* Returns A = phys 23:16, B = phys 15:8, scratch = phys 7:0.
PhysAddr            pshs      x,d
                    sta       <scratch
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    ldx       #MMU_SLOT_0
                    lda       a,x
                    sta       <blk0
                    lsra
                    lsra
                    lsra
                    pshs      a
                    lda       <blk0
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla
                    ldb       <scratch
                    andb      #$1F
                    pshs      b
                    ora       ,s+
                    tfr       a,b
                    lda       2,s
                    sta       <scratch
                    puls      a
                    leas      2,s
                    puls      x,pc

* ---- MapVky: map Block $C0 into MAPSLOT ($A000) with IRQs masked
MapVky              tfr       cc,a
                    sta       <savecc
                    orcc      #IntMasks
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
                    lda       #SPRITE_BLK         Block $C0
                    sta       >MAPSLOT
                    rts

* ---- UnMap: restore slot and MLUT control, unmask IRQs
UnMap               lda       <saveslot
                    sta       >MAPSLOT
                    lda       <saveffa0
                    sta       >MMU_MEM_CTRL
                    lda       <savecc
                    tfr       a,cc
                    rts

                    emod
eom                 equ       *
                    end
