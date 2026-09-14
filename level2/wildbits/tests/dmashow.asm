********************************************************************
* dmashow - TinyVicky II Hardware DMA Engine Visual Demonstration
*
* Visually demonstrates:
*  1. DMA CLUT Load: 1024 bytes palette loaded to VRAM ($183000) via DMA
*  2. 1D Linear DMA Fill: Instantly clearing 76,800 bytes (320x240)
*  3. 2D Rectangular DMA Fill: Cascading colorful windows with stride 320
*  4. Real-Time 2D DMA Animation: Smooth 40x40 bouncing box at 30 fps
*  5. Text Overlay: NitrOS-9 shell text floats directly over graphics
*  6. Clean Exit: Restores text mode after 10 seconds or on any keypress
********************************************************************

                    nam       dmashow
                    ttl       DMA Engine Visual Demo

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

* Explicit Hardware Register Equates
DMA_BASE_ADDR       equ       $FEC0
DMA_CTRL            equ       DMA_BASE_ADDR+DMA_CTRL_REG
DMA_STATUS          equ       DMA_BASE_ADDR+DMA_STATUS_REG
DMA_DATA_WRITE      equ       DMA_BASE_ADDR+DMA_DATA_2_WRITE
DMA_SRC_H           equ       DMA_BASE_ADDR+DMA_SOURCE_ADDR_H
DMA_SRC_M           equ       DMA_BASE_ADDR+DMA_SOURCE_ADDR_M
DMA_SRC_L           equ       DMA_BASE_ADDR+DMA_SOURCE_ADDR_L
DMA_DST_H           equ       DMA_BASE_ADDR+DMA_DEST_ADDR_H
DMA_DST_M           equ       DMA_BASE_ADDR+DMA_DEST_ADDR_M
DMA_DST_L           equ       DMA_BASE_ADDR+DMA_DEST_ADDR_L
DMA_SZ_1D_H         equ       DMA_BASE_ADDR+DMA_SIZE_1D_H
DMA_SZ_1D_M         equ       DMA_BASE_ADDR+DMA_SIZE_1D_M
DMA_SZ_1D_L         equ       DMA_BASE_ADDR+DMA_SIZE_1D_L
DMA_SZ_X_H          equ       DMA_BASE_ADDR+DMA_SIZE_X_H
DMA_SZ_X_L          equ       DMA_BASE_ADDR+DMA_SIZE_X_L
DMA_SZ_Y_H          equ       DMA_BASE_ADDR+DMA_SIZE_Y_H
DMA_SZ_Y_L          equ       DMA_BASE_ADDR+DMA_SIZE_Y_L
DMA_STRD_S_H        equ       DMA_BASE_ADDR+DMA_SRC_STRIDE_X_H
DMA_STRD_S_L        equ       DMA_BASE_ADDR+DMA_SRC_STRIDE_X_L
DMA_STRD_D_H        equ       DMA_BASE_ADDR+DMA_DST_STRIDE_Y_H
DMA_STRD_D_L        equ       DMA_BASE_ADDR+DMA_DST_STRIDE_Y_L

CLUT0_PHYS_ADDR     equ       $183000             Block $C1, offset $1000

                    mod       eom,name,tylg,atrv,start,size

                    ORG       0
bmblock             rmb       1                   physical starting block of bitmap 0
bm_phys_h           rmb       1                   24-bit physical base address of BM0
bm_phys_m           rmb       1
bm_phys_l           rmb       1
scratch_mmu         rmb       1
screen_no           rmb       2
screen_owned        rmb       1
old_master          rmb       1
old_layers          rmb       2
palette_mapped      rmb       2
pixel_hi            rmb       1
exit_status         rmb       1
abort_flag          rmb       1
box_x               rmb       2
box_y               rmb       2
box_dx              rmb       2
box_dy              rmb       2
frames_left         rmb       2
temp_buf            rmb       16
old_clut            rmb       1024
clut_buf            rmb       1024                1024-byte CLUT buffer
                    rmb       256                 stack
size                equ       .

name                fcs       /dmashow/
                    fcb       edition

start               equ       *
                    clr       <screen_owned
                    clr       <palette_mapped
                    clr       <palette_mapped+1
                    clr       <exit_status
                    clr       <abort_flag

* Set up Signal Intercept Handler (F$Icpt)
                    leax      SigHandler,pcr
                    os9       F$Icpt

* Acquire terminal ownership so keydrv_ps2 directs signals to us (sets V.LPRC)
                    clra                          path 0 (stdin)
                    ldy       #0                  0 bytes
                    os9       I$Read
                    lda       #1                  path 1 (stdout)
                    ldy       #0                  0 bytes
                    os9       I$Write

* ====================================================================
* Step 1: Allocate Bitmap 0 (320x240, 76,800 bytes)
* ====================================================================
                    lda       >TXT.Base
                    sta       <old_master
                    ldd       >VKY_LAYER_CTRL_0
                    std       <old_layers
                    ldy       #0
TryScreen           sty       <screen_no
                    ldx       #0
                    clra
                    ldb       #SS.AScrn
                    os9       I$SetStt
                    bcc       AllocOk
                    cmpb      #E$WADef
                    lbne      ExitErr
                    ldy       <screen_no
                    leay      1,y
                    cmpy      #3
                    blo       TryScreen
                    ldb       #E$WADef
                    lbra      ExitErr

AllocOk             inc       <screen_owned
                    tfr       x,d                 B = physical starting block
                    stb       <bmblock

* Compute 24-bit physical address: block * 8192 (block << 13)
                    tfr       b,a
                    lsra
                    lsra
                    lsra
                    sta       <bm_phys_h          phys 23:16 = block >> 3

                    tfr       b,a
                    asla
                    asla
                    asla
                    asla
                    asla
                    sta       <bm_phys_m          phys 15:8 = (block << 5) & $E0
                    clr       <bm_phys_l          phys 7:0 = $00

* ====================================================================
* Step 2: Build 256-Color Palette in clut_buf and DMA-copy to VRAM
* ====================================================================
* Save the internal CLUT through a real mapped CPU window.
                    pshs      u
                    ldx       #$C1
                    ldb       #1
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    lbcs      DmaError
                    stx       <palette_mapped
                    leax      $1000,x
                    leay      old_clut,u
                    lbsr      CopyClut
                    lbsr      InitClutBuf

* Populate the internal CLUT through the driver's mapped CPU copy.
                    ldx       #0
                    leay      clut_buf,u
                    clra
                    ldb       #SS.DfPal
                    os9       I$SetStt
                    lbcs      DmaError

* ====================================================================
* Step 3: Assign CLUT 0 to BM0 and place BM0 on Layer 0
* ====================================================================
                    ldx       #0                  clut #0
                    ldy       <screen_no          allocated bitmap
                    lda       #0
                    ldb       #SS.Palet
                    os9       I$SetStt

                    ldx       #0                  layer #0
                    ldy       <screen_no          allocated bitmap
                    lda       #0
                    ldb       #SS.PScrn
                    os9       I$SetStt

* ====================================================================
* Step 4: DEMO 1 - 1D Linear DMA Fill (Full Screen clear to dark slate)
* ====================================================================
* 76,800 bytes = $012C00
                    lda       <bm_phys_h
                    sta       >DMA_DST_H
                    lda       <bm_phys_m
                    sta       >DMA_DST_M
                    lda       <bm_phys_l
                    sta       >DMA_DST_L

                    lda       #24                 color index 24 (deep slate blue)
                    sta       >DMA_DATA_WRITE

                    lda       #$01                size = $012C00 (76,800 bytes)
                    sta       >DMA_SZ_1D_H
                    lda       #$2C
                    sta       >DMA_SZ_1D_M
                    clr       >DMA_SZ_1D_L

                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_Fill+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      DmaError

* ====================================================================
* Step 5: DEMO 2 - 2D Rectangular DMA Fill (Cascading Windows with Stride)
* ====================================================================
* Draw 5 overlapping colored rectangular windows across the 320-pitch canvas:
                    ldx       #20
                    ldy       #30
                    lda       #45                 Cyan
                    lbsr      DmaFillRect

                    ldx       #50
                    ldy       #50
                    lda       #95                 Green
                    lbsr      DmaFillRect

                    ldx       #80
                    ldy       #70
                    lda       #145                Gold
                    lbsr      DmaFillRect

                    ldx       #110
                    ldy       #90
                    lda       #175                Orange
                    lbsr      DmaFillRect

                    ldx       #140
                    ldy       #110
                    lda       #235                Magenta
                    lbsr      DmaFillRect

* ====================================================================
* Step 6: Turn on Graphics with Text Overlay
* ====================================================================
                    ldx       #FX_BM+FX_GRF+FX_OVR+FX_TXT
                    ldy       #FT_OMIT
                    lda       #0
                    ldb       #SS.DScrn
                    os9       I$SetStt

* Print banner on overlaid text screen
                    leax      msg_header,pcr
                    lbsr      PrintStr

* ====================================================================
* Step 7: DEMO 3 - Real-Time 2D DMA Animation (Bouncing 40x40 Block)
* ====================================================================
                    ldd       #180
                    std       <box_x
                    ldd       #130
                    std       <box_y
                    ldd       #2
                    std       <box_dx
                    ldd       #1
                    std       <box_dy
                    ldd       #900                900 loops (30 seconds at 30 fps)
                    std       <frames_left

AnimLoop            lda       <abort_flag
                    bne       CleanExit

* Poll stdin for any keypress
                    clra                          path 0 (stdin)
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcc       CleanExit           key pressed!

* Erase old box at (box_x, box_y): 40x40 with background color 24
                    ldx       <box_x
                    ldy       <box_y
                    lda       #24
                    lbsr      DmaFillBox

* Update box_x
                    ldd       <box_x
                    addd      <box_dx
                    std       <box_x
                    cmpd      #10
                    bge       bx_hi
                    ldd       #2
                    std       <box_dx
                    bra       by_up
bx_hi               cmpd      #270
                    ble       by_up
                    ldd       #-2
                    std       <box_dx

* Update box_y
by_up               ldd       <box_y
                    addd      <box_dy
                    std       <box_y
                    cmpd      #20
                    bge       by_hi
                    ldd       #1
                    std       <box_dy
                    bra       draw_box
by_hi               cmpd      #190
                    ble       draw_box
                    ldd       #-1
                    std       <box_dy

* Draw new box at (box_x, box_y): 40x40 with bright red color 205
draw_box            ldx       <box_x
                    ldy       <box_y
                    lda       #205
                    lbsr      DmaFillBox

* Sleep 2 ticks (~30 fps frame pacing)
                    ldx       #2
                    os9       F$Sleep

                    ldd       <frames_left
                    subd      #1
                    std       <frames_left
                    bne       AnimLoop

* ====================================================================
* Clean Exit: Restore Text Mode, Flush Keys, and Free Screen RAM
* ====================================================================
CleanExit           ldx       #0                  de-register intercept
                    os9       F$Icpt

* Flush any pending keyboard input
FlushKeys           clra                          path 0
                    ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       DoneFlush
                    leax      <temp_buf,u
                    ldy       #1
                    os9       I$Read
                    bra       FlushKeys
DoneFlush

* Stop our graphics, restore the palette, then release only our bitmap.
                    lda       <old_master
                    anda      #$F7
                    sta       >TXT.Base
                    ldy       <palette_mapped
                    beq       NoClutRestore
                    leay      $1000,y
                    leax      old_clut,u
                    lbsr      CopyClut
                    pshs      u
                    ldu       <palette_mapped
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
NoClutRestore       tst       <screen_owned
                    beq       NoScreenFree
                    ldy       <screen_no
                    clra
                    ldb       #SS.FScrn
                    os9       I$SetStt
NoScreenFree        ldd       <old_layers
                    std       >VKY_LAYER_CTRL_0
                    lda       <old_master
                    sta       >TXT.Base

                    ldb       <exit_status
                    os9       F$Exit

DmaError            stb       <exit_status
                    lbra      CleanExit

ExitErr             stb       <exit_status
                    lbra      CleanExit

* --------------------------------------------------------------------
* DmaFillRect: Draw an 80x50 filled rectangle at (X, Y) with color A
* --------------------------------------------------------------------
DmaFillRect         pshs      a,x,y
                    sta       >DMA_DATA_WRITE

                    lbsr      CalcPixelPhys
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <temp_buf
                    sta       >DMA_DST_L

                    clr       >DMA_SZ_X_H
                    lda       #80                 Width = 80 pixels
                    sta       >DMA_SZ_X_L

                    clr       >DMA_SZ_Y_H
                    lda       #50                 Height = 50 rows
                    sta       >DMA_SZ_Y_L

                    lda       #1                  Destination Stride = 320 ($0140)
                    sta       >DMA_STRD_D_H
                    lda       #$40
                    sta       >DMA_STRD_D_L

                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_1D_2D+DMA_CTRL_Fill+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      DmaError

                    puls      a,x,y,pc

* --------------------------------------------------------------------
* DmaFillBox: Draw a 40x40 filled rectangle at (X, Y) with color A
* --------------------------------------------------------------------
DmaFillBox          pshs      a,x,y
                    sta       >DMA_DATA_WRITE

                    lbsr      CalcPixelPhys
                    sta       >DMA_DST_H
                    stb       >DMA_DST_M
                    lda       <temp_buf
                    sta       >DMA_DST_L

                    clr       >DMA_SZ_X_H
                    lda       #40                 Width = 40 pixels
                    sta       >DMA_SZ_X_L

                    clr       >DMA_SZ_Y_H
                    lda       #40                 Height = 40 rows
                    sta       >DMA_SZ_Y_L

                    lda       #1                  Destination Stride = 320 ($0140)
                    sta       >DMA_STRD_D_H
                    lda       #$40
                    sta       >DMA_STRD_D_L

                    lda       #DMA_CTRL_Start_Trf+DMA_CTRL_1D_2D+DMA_CTRL_Fill+DMA_CTRL_Enable
                    lbsr      DmaStartWait
                    lbcs      DmaError

                    puls      a,x,y,pc

* --------------------------------------------------------------------
* CalcPixelPhys: Calculate 24-bit physical address for (X, Y) on BM0
* Input: X = col (0..319), Y = row (0..239)
* Returns: A = Phys[23:16], B = Phys[15:8], temp_buf = Phys[7:0]
* Formula: Offset = Y * 320 + X = Y * 256 + Y * 64 + X
* --------------------------------------------------------------------
CalcPixelPhys       pshs      x,y
                    clr       <pixel_hi
                    tfr       y,d
                    lda       #64
                    mul
                    pshs      d
                    tfr       y,d
                    tfr       b,a
                    clrb
                    addd      ,s++
                    bcc       pixel_y_ok
                    inc       <pixel_hi
pixel_y_ok          pshs      x
                    addd      ,s++
                    bcc       pixel_x_ok
                    inc       <pixel_hi
pixel_x_ok          addd      <bm_phys_m
                    stb       <temp_buf
                    tfr       a,b
                    lda       <bm_phys_h
                    adca      <pixel_hi
                    puls      x,y,pc

* --------------------------------------------------------------------
* InitClutBuf: Build 256-color palette in clut_buf
* Entry: 4 bytes per color: [Blue, Green, Red, 0]
* --------------------------------------------------------------------
InitClutBuf         pshs      x,y
                    leax      clut_buf,u
                    clrb                          B = index (0..255)
ic_lp               stb       ,x                  Blue = index
                    pshs      b
                    lslb
                    stb       1,x                 Green = index * 2
                    puls      b
                    tfr       b,a
                    coma
                    sta       2,x                 Red = 255 - index
                    clr       3,x                 Alpha = 0
                    leax      4,x
                    incb
                    bne       ic_lp

* Explicit overrides for vibrant demo colors:
* Color 24 (Background): Deep Slate Blue (B=80, G=30, R=20)
                    leax      (24*4)+clut_buf,u
                    lda       #80
                    sta       ,x
                    lda       #30
                    sta       1,x
                    lda       #20
                    sta       2,x

* Color 45 (Window 1): Cyan (B=240, G=220, R=0)
                    leax      (45*4)+clut_buf,u
                    lda       #240
                    sta       ,x
                    lda       #220
                    sta       1,x
                    clr       2,x

* Color 95 (Window 2): Bright Green (B=50, G=240, R=40)
                    leax      (95*4)+clut_buf,u
                    lda       #50
                    sta       ,x
                    lda       #240
                    sta       1,x
                    lda       #40
                    sta       2,x

* Color 145 (Window 3): Gold/Yellow (B=20, G=215, R=255)
                    leax      (145*4)+clut_buf,u
                    lda       #20
                    sta       ,x
                    lda       #215
                    sta       1,x
                    lda       #255
                    sta       2,x

* Color 175 (Window 4): Orange (B=0, G=128, R=255)
                    leax      (175*4)+clut_buf,u
                    clr       ,x
                    lda       #128
                    sta       1,x
                    lda       #255
                    sta       2,x

* Color 205 (Box / Window 5): Vivid Red (B=30, G=30, R=250)
                    leax      (205*4)+clut_buf,u
                    lda       #30
                    sta       ,x
                    sta       1,x
                    lda       #250
                    sta       2,x

* Color 235 (Window 6): Magenta (B=220, G=30, R=240)
                    leax      (235*4)+clut_buf,u
                    lda       #220
                    sta       ,x
                    lda       #30
                    sta       1,x
                    lda       #240
                    sta       2,x

                    puls      x,y,pc

* --------------------------------------------------------------------
* GetPhysAddr: Convert logical address in X to 24-bit physical address
* Returns: A = Phys[23:16], B = Phys[15:8], temp_buf = Phys[7:0]
* --------------------------------------------------------------------
GetPhysAddr         pshs      x,y,cc
                    orcc      #IntMasks
                    lda       >MMU_MEM_CTRL
                    sta       <scratch_mmu
                    tfr       a,b
                    andb      #$03
                    lslb
                    lslb
                    lslb
                    lslb
                    anda      #$CF
                    pshs      b
                    ora       ,s+
                    sta       >MMU_MEM_CTRL

                    tfr       x,d
                    pshs      b
                    tfr       a,b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    andb      #$07
                    ldy       #MMU_SLOT_0
                    ldb       b,y

                    pshs      a,b
                    lda       <scratch_mmu
                    sta       >MMU_MEM_CTRL
                    puls      a,b

                    pshs      a
                    tfr       b,a
                    lsra
                    lsra
                    lsra
                    pshs      a

                    lslb
                    lslb
                    lslb
                    lslb
                    lslb
                    lda       1,s
                    anda      #$1F
                    pshs      a
                    orb       ,s+

                    lda       2,s
                    sta       <temp_buf

                    puls      a
                    leas      2,s
                    puls      x,y,cc,pc

* --------------------------------------------------------------------
* Signal Handler
* --------------------------------------------------------------------
SigHandler          inc       <abort_flag
                    rti

* --------------------------------------------------------------------
* Print Subroutines
* --------------------------------------------------------------------
PrintStr            pshs      a,y
ps_lp               lda       ,x+
                    beq       ps_done
                    lbsr      PrintChar
                    bra       ps_lp
ps_done             puls      a,y,pc

PrintChar           pshs      a,x,y
                    sta       <temp_buf
                    lda       #1                  stdout
                    leax      <temp_buf,u
                    ldy       #1
                    os9       I$Write
                    puls      a,x,y,pc

* --------------------------------------------------------------------
* Message Strings
* --------------------------------------------------------------------
msg_header          fcb       $0C                 Clear Screen
                    fcb       C$CR,$0A
                    fcc       "================================================================================"
                    fcb       C$CR,$0A
                    fcc       "         TINYVICKY II HARDWARE 1D / 2D DMA ENGINE DEMONSTRATION"
                    fcb       C$CR,$0A
                    fcc       "================================================================================"
                    fcb       C$CR,$0A
                    fcc       "  * 1D Linear DMA Fill : Instantly cleared 76.8 KB VRAM canvas ($180000)"
                    fcb       C$CR,$0A
                    fcc       "  * 2D Stride DMA Fill : 5 Cascading graphic windows rendered with stride 320"
                    fcb       C$CR,$0A
                    fcc       "  * 2D Real-Time Blit  : Smooth 40x40 hardware bouncing box @ 30 fps"
                    fcb       C$CR,$0A
                    fcc       "  * Text Overlay Mode  : NitrOS-9 console text floating directly over VRAM"
                    fcb       C$CR,$0A
                    fcb       C$CR,$0A
                    fcc       "  -> Press ESC, Space, or any key to exit (or auto-exits in 30 seconds)..."
                    fcb       C$CR,$0A,0

msg_clr             fcb       $0C,0               Clear screen on exit

* RC16 START is edge triggered. Clear it before every command.
DmaStartWait        pshs      x,y
                    anda      #$7F
                    sta       >DMA_CTRL
                    ora       #DMA_CTRL_Start_Trf
                    sta       >DMA_CTRL
                    ldy       #$0010
                    ldx       #0
dma_poll            lda       >DMA_STATUS
                    bita      #DMA_STATUS_TRF_IP
                    beq       dma_done
                    leax      -1,x
                    bne       dma_poll
                    leay      -1,y
                    bne       dma_poll
                    ldb       #E$NotRdy
                    orcc      #1
                    puls      x,y,pc
dma_done            clr       >DMA_CTRL
                    andcc     #$FE
                    puls      x,y,pc

CopyClut            pshs      d
                    ldd       #1024
CopyClutByte        pshs      d
                    lda       ,x+
                    sta       ,y+
                    puls      d
                    subd      #1
                    bne       CopyClutByte
                    puls      d,pc

                    emod
eom                 equ       *
                    end
