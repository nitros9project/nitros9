********************************************************************
* scrn - Wildbits (TinyVicky) screen module
*
* Derived from objs_lsl/scrn.asm (CoCo 3 original by Chris Iden,
* disassembly/documentation by Paul Zibaila & Robert Gault).
*
* Platform differences from CoCo 3:
*   - Display: TinyVicky bitmap, 8-bit indexed pixels (1 byte/pixel)
*   - Screen stride: 320 bytes/line (CoCo 3: 160 bytes/line)
*   - Pixel expansion: each AGI pixel -> 2 screen bytes (double-wide)
*   - Screen allocated by SS.AScrn in high RAM (8 x 8K blocks)
*   - Screen base: block# stored in u0047 (set by sierra.asm)
*   - Block access: F$MapBlk / F$ClrBlk (like CoCo3 $FFA9 switching)
*   - Color table: 4-bit color -> 8-bit CLUT index (identity 0-15)
*   - No GIME: picbuff at $6040 is directly accessible
*
* Memory layout (Sierra direct-page area, all new Wildbits vars):
*   u0047 ($0047) - BM0 start block# (word, low byte used; set by sierra.asm)
*   scr_cblk ($007E) - current mapped absolute block#
*   scr_row  ($007F) - row_delta temp storage
*   scr_map  ($0080) - 2 bytes: address of currently mapped 8K block
*   scr_end  ($0082) - 2 bytes: scr_map + $2000 (exclusive end of block)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2025/xx/xx  Wildbits port
* Adapted from objs_lsl/scrn.asm for TinyVicky 8-bit bitmap display.
* Rewrote screen blit/fill to use F$MapBlk block-at-a-time access.

                    nam       scrn
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

*  Sierra shared data-area equates

u0012               equ       $0012
u001C               equ       $001C
u001E               equ       $001E
u0024               equ       $0024
u002C               equ       $002C
u0030               equ       $0030
u0038               equ       $0038
u003E               equ       $003E
u0040               equ       $0040
u0041               equ       $0041
u0042               equ       $0042
u0043               equ       $0043
u0045               equ       $0045
u0046               equ       $0046
u0047               equ       $0047               Wildbits: BM0 start block#

* Block-mapping state (within the u005F rmb 163 free area)
scr_cblk            equ       $007E               current mapped absolute block#
scr_row             equ       $007F               row_delta temp
scr_map             equ       $0080               2 bytes: mapped block start address
scr_end             equ       $0082               2 bytes: scr_map + $2000 (end of block)
dst_cblk            equ       $0084               L0209: current mapped dest block#
dst_map             equ       $0085               2 bytes: mapped dest block start address
dst_end             equ       $0087               2 bytes: dst_map + $2000 (end of dest block)

u009E               equ       $009E
u009F               equ       $009F
u00A0               equ       $00A0               height counter
u00A1               equ       $00A1               width (AGI pixels)
u00A2               equ       $00A2               stride delta (word)
u00A3               equ       $00A3               stride delta low byte
u00A4               equ       $00A4
u00A5               equ       $00A5
u00A6               equ       $00A6
u00A7               equ       $00A7
u00A8               equ       $00A8
u00A9               equ       $00A9
u00AA               equ       $00AA
u00AB               equ       $00AB
u00AC               equ       $00AC
u00AD               equ       $00AD
u00C0               equ       $00C0
u00C6               equ       $00C6
u00CC               equ       $00CC
u00DE               equ       $00DE
u00E0               equ       $00E0
u00F6               equ       $00F6
u00F8               equ       $00F8
u00FC               equ       $00FC
u00FE               equ       $00FE
u00FF               equ       $00FF

X0100               equ       $0100               pic_visible
X024E               equ       $024E

* Wildbits screen constants
SCRN_WIDTH          equ       320                 8-bit pixels per line
SCRN_HEIGHT         equ       200                 total lines (AGI uses 168)
SCRN_BLOCKS         equ       8                   8K blocks for 320x200

u0000               rmb       0
size                equ       .
name                equ       *
                    fcs       /scrn/
                    fcb       $00

* Module entry: dispatch table
start               equ       *
                    lbra      L015A               blit picbuff to screen
                    lbra      L014C               relay blit call
                    lbra      L009C               screen clear
                    lbra      L00B3               clear + full blit
                    lbra      L00D2               draw border rectangle
                    lbra      L074C               text/cursor blit
                    lbra      L0209               scroll (stub)
                    lbra      L00C5               clear screen (color variant)
                    lbra      L0264               sprite dispatch
                    lbra      L02A7               sprite blit

L0030               fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'Wildbits version'
                    fcb       0

* Map block check stub (CoCo3 GIME equivalent, not used for screen on Wildbits)
* Preserved for dispatch table calls from L02A7.
L0071               cmpa      <u0012
                    beq       L008B
                    sta       <u0012
L008B               rts

* Sierra 4-bit color -> 8-bit CLUT index table (identity mapping).
* CoCo3: $00,$11,$22,...,$FF  (nibble-pair 4-bit packed)
* Wildbits: $00,$01,...,$0F   (single-byte CLUT index 0-15)
L008C               fcb       $00,$01,$02,$03,$04,$05,$06,$07
                    fcb       $08,$09,$0A,$0B,$0C,$0D,$0E,$0F

*--------------------------------------------------------------------
* L009C - Clear the Wildbits screen bitmap.
*
* Maps each of SCRN_BLOCKS 8K blocks in turn and zeroes them.
*
* entry:
*   (D -> fill value, but Wildbits clears to 0 unconditionally)
*   x -> preserved
* exit:
*   x -> preserved
*--------------------------------------------------------------------
L009C               pshs      x,y
                    ldb       <u0047              BM0 start block#
                    clra
                    tfr       d,x                 X = first block#
                    lda       #SCRN_BLOCKS        block count
                    pshs      a                   save on stack
L009C_blk           ldb       #1
                    os9       F$MapBlk            map 1 block; U = mapped address
                    bcs       L009C_err
                    pshs      u                   save start for F$ClrBlk
                    ldy       #$2000              8192 bytes
L009C_clr           clr       ,u+
                    leay      -1,y
                    bne       L009C_clr
                    puls      u                   restore for F$ClrBlk
                    ldb       #1
                    os9       F$ClrBlk
                    leax      1,x                 next block
                    dec       ,s
                    bne       L009C_blk
L009C_err           leas      1,s
                    puls      x,y
                    rts

* Fill screen with 0
L00AD               ldd       #$0000
                    bsr       L009C
                    rts

L00B3               bsr       L00AD
                    ldd       #$A8A0
                    pshs      b,a
                    ldd       #$00A7
                    pshs      b,a
                    lbsr      L015A
                    leas      $04,s
                    rts

L00C5               lda       >$024D
                    tfr       a,b
                    bsr       L009C
                    ldd       #$0000
                    std       <u0040
                    rts

L00D2               ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      b,a
                    lda       #$01
                    ldb       $07,s
                    subb      #$02
                    pshs      b,a
                    ldd       $06,s
                    inca
                    decb
                    pshs      b,a
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      b,a
                    lda       $06,s
                    suba      #$04
                    ldb       #$01
                    pshs      b,a
                    ldd       $06,s
                    adda      $09,s
                    suba      #$02
                    subb      #$02
                    pshs      b,a
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      b,a
                    lda       #$01
                    ldb       $07,s
                    subb      #$02
                    pshs      b,a
                    ldd       $06,s
                    inca
                    subb      $08,s
                    addb      #$02
                    pshs      b,a
                    lbsr      L01D4
                    leas      $06,s
                    clra
                    ldb       $06,s
                    pshs      b,a
                    lda       $06,s
                    suba      #$04
                    ldb       #$01
                    pshs      b,a
                    ldd       $06,s
                    inca
                    subb      #$02
                    pshs      b,a
                    lbsr      L01D4
                    leas      $06,s
                    rts

L014C               ldd       $04,s
                    pshs      b,a
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L015A
                    leas      $04,s
                    rts

*--------------------------------------------------------------------
* L015A - Blit AGI picture buffer region to Wildbits screen.
*
* Stack layout on entry (after lbsr L015A):
*   2,s / 3,s  -> A = top_row,   B = bottom_row
*   4,s / 5,s  -> A = height,    B = width (AGI pixels, max 160)
*
* Wildbits: screen is in 8K blocks starting at block# u0047.
* Uses F$MapBlk / F$ClrBlk to access each block.
* Each AGI pixel (4-bit color from picbuff) expands to 2 screen bytes
* (same CLUT index written twice for double-wide pixels).
*
* TODO: partial-width blits (width < 160) may have incorrect stride
* delta handling when stride advance crosses a block boundary.
*--------------------------------------------------------------------
L015A               pshs      y

* row_delta = top_row (= A from $04,s before pshs y -> now $06,s? No:
* $04,s after pshs y: we pushed 2 bytes (y), so $04,s = orig $02,s.
* Stack after pshs y:
*   0,s / 1,s  Y reg
*   2,s / 3,s  return addr
*   4,s / 5,s  A=top_row, B=bottom_row
*   6,s / 7,s  A=height,  B=width
* Compute row_delta = (bottom_row + 1) - height = top_row

                    ldd       $04,s               A=top_row, B=bottom_row
                    incb                          B = bottom_row + 1
                    subb      $06,s               B = row_delta = top_row
                    stb       <scr_row            save row_delta

* Picbuff source: x = $6040 + row_delta * 160
                    lda       #$A0
                    mul                           D = row_delta * 160
                    addd      #$6040
                    tfr       d,x                 X = picbuff source

* Screen byte offset = row_delta * 320 + u002C (col offset)
* row_delta * 320 = row_delta * 256 + row_delta * 64
                    lda       <scr_row            A = row_delta
                    ldb       #64
                    mul                           D = row_delta * 64
                    pshs      d
                    lda       <scr_row
                    clrb                          D = row_delta * 256
                    addd      ,s++                D = row_delta * 320
                    addd      <u002C              + column offset

* Compute initial absolute block# and intra-block offset.
* block# = u0047 + (D >> 13).  D < 168*320 = $D200, so A>>5 = D>>13.
                    pshs      d                   save screen_off
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = screen_off >> 13
                    adda      <u0047              + BM0 start block#
                    sta       <scr_cblk           initial block#

* Map first block
                    tfr       a,b                 B = block#
                    clra
                    tfr       d,x                 X = 0:block#
                    ldb       #1
                    os9       F$MapBlk            U = mapped address
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end            end = map + 8192

* Y = scr_map + intra_off;  intra_off = screen_off & $1FFF
                    puls      d                   D = screen_off
                    anda      #$1F                D & $1FFF (high 13 bits of offset)
                    addd      <scr_map
                    tfr       d,y                 Y = screen destination

* Height / width / stride-delta
                    ldd       $06,s               A=height, B=width
                    std       <u00A0              u00A0=height, u00A1=width
                    ldb       #$A0
                    subb      <u00A1              B = $A0 - width
                    lslb                          B = 2*($A0-width) screen stride delta
                    clra
                    std       <u00A2              u00A2/u00A3 = stride delta

* U = CLUT lookup table
                    leau      >L008C,pcr

*--------------------------------------------------------------------
* Outer loop: one row per iteration
*--------------------------------------------------------------------
L01A7               ldb       <u00A1              B = pixel width counter

*--------------------------------------------------------------------
* Inner loop: one AGI pixel (= 2 screen bytes) per iteration
*--------------------------------------------------------------------
L01A9               lda       ,x+                 read picbuff byte
                    anda      #$0F                keep 4-bit color index
                    lda       a,u                 CLUT lookup -> A = screen byte

* Write left pixel; remap if Y just crossed into next block
                    sta       ,y+
                    cmpy      <scr_end
                    beq       L01A9_remap_l
L01AC               sta       ,y+                 write right pixel
                    cmpy      <scr_end
                    beq       L01A9_remap_r
L01AE               decb
                    bne       L01A9

* End of row: advance by stride delta (0 for full-width blits)
                    dec       <u00A0
                    beq       L01D1               all rows done
                    ldd       <u00A2              stride delta (0 for full width)
                    beq       L01A7               zero: no advance needed
* Advance Y by stride delta with block-boundary check
                    tfr       y,d
                    addd      <u00A2
                    cmpd      <scr_end
                    bcs       L015A_stride_ok     Y_new < scr_end: no crossing
* Stride crossed into next block; intra = Y_new - scr_end
                    subd      <scr_end            D = bytes into new block
                    pshs      d                   save intra
                    pshs      u,x,b
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x                 X = new block#
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    puls      u,x,b
                    ldd       <scr_map
                    addd      ,s++                + intra
                    tfr       d,y
                    bra       L01A7
L015A_stride_ok     tfr       d,y
                    bra       L01A7

L01D1               ldu       <scr_map            unmap final block
                    ldb       #1
                    os9       F$ClrBlk
                    puls      y
                    rts

* Block boundary handlers (inlined for branch range)
L01A9_remap_l
* Left pixel write just hit scr_end.  Remap next block; Y = new start.
                    pshs      a,b,x,u             A=color, B=counter, X=picbuff, U=CLUT
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x                 X = new block#
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,y                 Y = start of new block
                    puls      a,b,x,u
                    bra       L01AC

L01A9_remap_r
* Right pixel write just hit scr_end.  Remap next block.
                    pshs      a,b,x,u
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,y
                    puls      a,b,x,u
                    lbra      L01AE

*--------------------------------------------------------------------
* L01D4 - Fill a rectangular screen region with a solid color.
*
* Stack on entry (no pshs at start):
*   0,s / 1,s  return addr
*   2,s / 3,s  A = row1,   B = ???
*   4,s / 5,s  A = height, B = width
*   6,s / 7,s  color word (B = color nibble)
*   7,s        color byte (low byte of color word)
*--------------------------------------------------------------------
L01D4               ldd       $02,s               A=row1, B=...
                    incb
                    subb      $04,s               B = row_delta
                    stb       <scr_row

* Screen byte offset = row_delta * 320 + u002C
                    lda       <scr_row
                    ldb       #64
                    mul
                    pshs      d
                    lda       <scr_row
                    clrb
                    addd      ,s++                D = row_delta * 320
                    addd      <u002C

* Initial block# and intra offset
                    pshs      d                   save screen_off
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = screen_off >> 13
                    adda      <u0047
                    sta       <scr_cblk

* Map first block
                    tfr       a,b                 B = block#
                    clra
                    tfr       d,x                 X = 0:block#
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end

                    puls      d                   D = screen_off
                    anda      #$1F
                    addd      <scr_map
                    tfr       d,x                 X = screen destination (use X for fill)

* Height / width / stride delta
                    ldd       $04,s               A=height, B=width
                    std       <u00A0
                    ldb       #$A0
                    subb      <u00A1
                    lslb
                    stb       <u00A2

* Color lookup
                    leau      >L008C,pcr
                    lda       $07,s               color nibble
                    anda      #$0F
                    lda       a,u                 CLUT index

* Outer fill loop
L01F8               ldb       <u00A1              width counter
L01FA               sta       ,x+                 left pixel
                    cmpx      <scr_end
                    beq       L01D4_remap_l
L01FB               sta       ,x+                 right pixel
                    cmpx      <scr_end
                    beq       L01D4_remap_r
L01FC               decb
                    bne       L01FA
                    dec       <u00A0
                    beq       L0208
                    ldb       <u00A2              stride delta
                    beq       L01F8
                    abx                           advance X (TODO: block crossing)
                    bra       L01F8

L0208               ldu       <scr_map
                    ldb       #1
                    os9       F$ClrBlk
                    rts

L01D4_remap_l
                    pshs      a,b
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x                 X = new block#
                    ldb       #1
                    os9       F$MapBlk            U = new mapped address
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,x                 X = start of new block
                    puls      a,b
                    bra       L01FB

L01D4_remap_r
                    pshs      a,b
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,x
                    puls      a,b
                    bra       L01FC

*--------------------------------------------------------------------
* L0209 - Scroll a character-grid region upward (Wildbits).
*
* Args pushed by caller (before lbsr), relative to SP on entry:
*   0,s/1,s = return addr
*   2,s/3,s = arg1: {hi=0, lo=y1}        top dest char row
*   4,s/5,s = arg2: {hi=x2, lo=x1}       right/left char columns
*   6,s/7,s = arg3: {hi=scroll_rows, lo=height_rows}
*
* Copies height_rows char rows of screen data upward by scroll_rows
* char rows.  Stride 320 bytes/row; col width (x2-x1+1)*16 bytes.
* Two concurrent F$MapBlk mappings (src + dst); unmapped per-row.
*--------------------------------------------------------------------
L0209               leas      -$04,s

                    ldd       $0A,s
                    std       $02,s              local[2/3] = arg3
                    ldd       $08,s
                    std       ,s                 local[0/1] = arg2

* dst_off = y1*2560 + x1*16
                    lda       $07,s              y1
                    ldb       #10
                    mul                          D = y1*10
                    tfr       b,a
                    clrb                         D = y1*2560
                    std       <u00A4             save temporarily
                    clra
                    ldb       $01,s              x1 = local[1]
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola                         D = x1*16
                    addd      <u00A4             dst_off = y1*2560 + x1*16
                    std       <u00A6

* src_off = dst_off + scroll_rows*2560
                    lda       $02,s              scroll_rows = local[2]
                    ldb       #10
                    mul
                    tfr       b,a
                    clrb                         D = scroll_rows*2560
                    addd      <u00A6
                    std       <u00A8             src_off

* byte_count per row = (x2-x1+1)*16
                    lda       ,s                 x2 = local[0]
                    suba      $01,s              x2 - x1
                    inca                         width in chars
                    ldb       #16
                    mul                          D = width*16 (max 640=$0280)
                    std       <u00AB             working byte count (A=hi, B=lo)
                    std       <u00AD             saved count for per-row reload

* pixel_rows = height_rows * 8
                    lda       $03,s              height_rows = local[3]
                    lsla
                    lsla
                    lsla                         pixel rows to copy
                    lbeq      L0261              zero rows: nothing to do
                    sta       <u00A0

L0209_row
* Map src block
                    ldd       <u00A8
                    std       <u00A4             save src_off (reuse u00A4 as temp)
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                         A = src block offset
                    adda      <u0047
                    sta       <scr_cblk
                    tfr       a,b
                    clra
                    tfr       d,x                X = block#
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    ldd       <u00A4             restore src_off
                    anda      #$1F
                    addd      <scr_map
                    tfr       d,x                X = src ptr

* Map dst block (save X first)
                    pshs      x
                    ldd       <u00A6
                    std       <u00A4             save dst_off
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                         A = dst block offset
                    adda      <u0047
                    sta       <dst_cblk
                    tfr       a,b
                    clra
                    tfr       d,x                X = block#
                    ldb       #1
                    os9       F$MapBlk
                    stu       <dst_map
                    tfr       u,d
                    addd      #$2000
                    std       <dst_end
                    ldd       <u00A4             restore dst_off
                    anda      #$1F
                    addd      <dst_map
                    tfr       d,y                Y = dst ptr
                    puls      x                  restore src ptr

* Reload byte count for this row
                    ldd       <u00AD
                    std       <u00AB

* Inner byte copy loop
L0209_inner         lda       ,x+
                    sta       ,y+
                    cmpx      <scr_end
                    beq       L0209_sremap
L0209_s1            cmpy      <dst_end
                    beq       L0209_dremap
L0209_d1            ldd       <u00AB
                    subd      #1
                    std       <u00AB
                    bne       L0209_inner

* Unmap both blocks for this row
                    ldu       <dst_map
                    ldb       #1
                    os9       F$ClrBlk
                    ldu       <scr_map
                    ldb       #1
                    os9       F$ClrBlk

* Advance src and dst offsets to next pixel row
                    ldd       <u00A6
                    addd      #320
                    std       <u00A6
                    ldd       <u00A8
                    addd      #320
                    std       <u00A8
                    dec       <u00A0
                    lbne      L0209_row

L0261               leas      $04,s
                    rts

* Src block boundary remap
L0209_sremap        pshs      y
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,x
                    puls      y
                    bra       L0209_s1

* Dst block boundary remap
L0209_dremap        pshs      x
                    ldb       <dst_cblk
                    incb
                    stb       <dst_cblk
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    stu       <dst_map
                    tfr       u,d
                    addd      #$2000
                    std       <dst_end
                    tfr       u,y
                    puls      x
                    bra       L0209_d1

L0264               leas      -$04,s
                    ldx       $06,s
                    ldu       ,x
L026A               stu       ,s
                    beq       L02A4
                    ldu       $04,u
                    stu       $02,s
                    pshs      u
                    lbsr      L02A7
                    leas      $02,s
                    ldu       $02,s
                    lda       $01,u
                    cmpa      ,u
                    bne       L029E
                    ldd       $03,u
                    cmpd      <$1A,u
                    bne       L0293
                    lda       <$25,u
                    ora       #$40
                    sta       <$25,u
                    bra       L029E
L0293               std       <$1A,u
                    lda       <$25,u
                    anda      #$BF
                    sta       <$25,u
L029E               ldu       ,s
                    ldu       ,u
                    bra       L026A
L02A4               leas      $04,s
                    rts

L02A7               lda       >$0100              pic_visible
                    lbeq      L034B
                    ldu       $02,s
                    ldd       $08,u
                    lbsr      L0071
                    ldx       <$10,u
                    ldd       ,x
                    std       <u00A2
                    ldd       <$14,u
                    lbsr      L0071
                    ldx       <$12,u
                    ldd       ,x
                    std       <u00A0
                    ldd       <$10,u
                    std       <$12,u
                    ldd       $08,u
                    std       <$14,u
                    lda       $04,u
                    ldb       <u00A3
                    cmpa      <$1B,u
                    bcs       L02E8
                    sta       <u00A5
                    stb       <u00A6
                    lda       <$1B,u
                    ldb       <u00A1
                    bra       L02F3
L02E8               ldb       <$1B,u
                    stb       <u00A5
                    ldb       <u00A1
                    stb       <u00A6
                    ldb       <u00A3
L02F3               stb       <u00AA
                    inca
                    suba      <u00AA
                    ldb       <u00A5
                    incb
                    subb      <u00A6
                    stb       <u00A9
                    cmpa      <u00A9
                    bcs       L0305
                    lda       <u00A9
L0305               nega
                    adda      <u00A5
                    inca
                    sta       <u00A6
                    lda       $03,u
                    ldb       <u00A2
                    cmpa      <$1A,u
                    bhi       L031F
                    sta       <u00A4
                    stb       <u00AB
                    lda       <$1A,u
                    ldb       <u00A0
                    bra       L032A
L031F               ldb       <$1A,u
                    stb       <u00A4
                    ldb       <u00A0
                    stb       <u00AB
                    ldb       <u00A2
L032A               stb       <u00AC
                    adda      <u00AC
                    sta       <u00A8
                    lda       <u00A4
                    adda      <u00AB
                    cmpa      <u00A8
                    bhi       L033A
                    lda       <u00A8
L033A               suba      <u00A4
                    sta       <u00A7
                    ldd       <u00A6
                    pshs      b,a
                    ldd       <u00A4
                    pshs      b,a
                    lbsr      L015A
                    leas      $04,s
L034B               rts

* Font/sprite bitmap data (1024 bytes, hardware-independent)

L034C               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $7E,$81,$A5,$81
                    fcb       $BD,$99,$81,$7E
                    fcb       $7E,$FF,$DB,$FF
                    fcb       $C3,$E7,$FF,$7E
                    fcb       $6C,$FE,$FE,$FE
                    fcb       $7C,$38,$10,$00
                    fcb       $10,$38,$7C,$FE
                    fcb       $7C,$38,$10,$00
                    fcb       $38,$7C,$38,$FE
                    fcb       $FE,$7C,$38,$7C
                    fcb       $10,$10,$38,$7C
                    fcb       $FE,$7C,$38,$7C
                    fcb       $00,$00,$18,$3C
                    fcb       $3C,$18,$00,$00
                    fcb       $FF,$FF,$E7,$C3
                    fcb       $C3,$E7,$FF,$FF
                    fcb       $00,$3C,$66,$42
                    fcb       $42,$66,$3C,$00
                    fcb       $FF,$C3,$99,$BD
                    fcb       $BD,$99,$C3,$FF
                    fcb       $0F,$07,$0F,$7D
                    fcb       $CC,$CC,$CC,$78
                    fcb       $3C,$66,$66,$66
                    fcb       $3C,$18,$7E,$18
                    fcb       $3F,$33,$3F,$30
                    fcb       $30,$70,$F0,$E0
                    fcb       $7F,$63,$7F,$63
                    fcb       $63,$67,$E6,$C0
                    fcb       $99,$5A,$3C,$E7
                    fcb       $E7,$3C,$5A,$99
                    fcb       $80,$E0,$F8,$FE
                    fcb       $F8,$E0,$80,$00
                    fcb       $02,$0E,$3E,$FE
                    fcb       $3E,$0E,$02,$00
                    fcb       $18,$3C,$7E,$18
                    fcb       $18,$7E,$3C,$18
                    fcb       $66,$66,$66,$66
                    fcb       $66,$00,$66,$00
                    fcb       $7F,$DB,$DB,$7B
                    fcb       $1B,$1B,$1B,$00
                    fcb       $3E,$63,$38,$6C
                    fcb       $6C,$38,$CC,$78
                    fcb       $00,$00,$00,$00
                    fcb       $7E,$7E,$7E,$00
                    fcb       $18,$3C,$7E,$18
                    fcb       $7E,$3C,$18,$FF
                    fcb       $18,$3C,$7E,$18
                    fcb       $18,$18,$18,$00
                    fcb       $18,$18,$18,$18
                    fcb       $7E,$3C,$18,$00
                    fcb       $00,$18,$0C,$FE
                    fcb       $0C,$18,$00,$00
                    fcb       $00,$30,$60,$FE
                    fcb       $60,$30,$00,$00
                    fcb       $00,$00,$C0,$C0
                    fcb       $C0,$FE,$00,$00
                    fcb       $00,$24,$66,$FF
                    fcb       $66,$24,$00,$00
                    fcb       $00,$18,$3C,$7E
                    fcb       $FF,$FF,$00,$00
                    fcb       $00,$FF,$FF,$7E
                    fcb       $3C,$18,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $30,$78,$78,$30
                    fcb       $30,$00,$30,$00
                    fcb       $6C,$6C,$6C,$00
                    fcb       $00,$00,$00,$00
                    fcb       $6C,$6C,$FE,$6C
                    fcb       $FE,$6C,$6C,$00
                    fcb       $30,$7C,$C0,$78
                    fcb       $0C,$F8,$30,$00
                    fcb       $00,$C6,$CC,$18
                    fcb       $30,$66,$C6,$00
                    fcb       $38,$6C,$38,$76
                    fcb       $DC,$CC,$76,$00
                    fcb       $60,$60,$C0,$00
                    fcb       $00,$00,$00,$00
                    fcb       $18,$30,$60,$60
                    fcb       $60,$30,$18,$00
                    fcb       $60,$30,$18,$18
                    fcb       $18,$30,$60,$00
                    fcb       $00,$66,$3C,$FF
                    fcb       $3C,$66,$00,$00
                    fcb       $00,$30,$30,$FC
                    fcb       $30,$30,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$30,$30,$60
                    fcb       $00,$00,$00,$FC
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$30,$30,$00
                    fcb       $06,$0C,$18,$30
                    fcb       $60,$C0,$80,$00
                    fcb       $7C,$C6,$CE,$DE
                    fcb       $F6,$E6,$7C,$00
                    fcb       $30,$70,$30,$30
                    fcb       $30,$30,$FC,$00
                    fcb       $78,$CC,$0C,$38
                    fcb       $60,$CC,$FC,$00
                    fcb       $78,$CC,$0C,$38
                    fcb       $0C,$CC,$78,$00
                    fcb       $1C,$3C,$6C,$CC
                    fcb       $FE,$0C,$1E,$00
                    fcb       $FC,$C0,$F8,$0C
                    fcb       $0C,$CC,$78,$00
                    fcb       $38,$60,$C0,$F8
                    fcb       $CC,$CC,$78,$00
                    fcb       $FC,$CC,$0C,$18
                    fcb       $30,$30,$30,$00
                    fcb       $78,$CC,$CC,$78
                    fcb       $CC,$CC,$78,$00
                    fcb       $78,$CC,$CC,$7C
                    fcb       $0C,$18,$70,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$00
                    fcb       $00,$30,$30,$60
                    fcb       $18,$30,$60,$C0
                    fcb       $60,$30,$18,$00
                    fcb       $00,$00,$FC,$00
                    fcb       $00,$FC,$00,$00
                    fcb       $60,$30,$18,$0C
                    fcb       $18,$30,$60,$00
                    fcb       $78,$CC,$0C,$18
                    fcb       $30,$00,$30,$00
                    fcb       $7C,$C6,$DE,$DE
                    fcb       $DE,$C0,$78,$00
                    fcb       $30,$78,$CC,$CC
                    fcb       $FC,$CC,$CC,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $66,$66,$FC,$00
                    fcb       $3C,$66,$C0,$C0
                    fcb       $C0,$66,$3C,$00
                    fcb       $F8,$6C,$66,$66
                    fcb       $66,$6C,$F8,$00
                    fcb       $FE,$62,$68,$78
                    fcb       $68,$62,$FE,$00
                    fcb       $FE,$62,$68,$78
                    fcb       $68,$60,$F0,$00
                    fcb       $3C,$66,$C0,$C0
                    fcb       $CE,$66,$3E,$00
                    fcb       $CC,$CC,$CC,$FC
                    fcb       $CC,$CC,$CC,$00
                    fcb       $78,$30,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $1E,$0C,$0C,$0C
                    fcb       $CC,$CC,$78,$00
                    fcb       $E6,$66,$6C,$78
                    fcb       $6C,$66,$E6,$00
                    fcb       $F0,$60,$60,$60
                    fcb       $62,$66,$FE,$00
                    fcb       $C6,$EE,$FE,$FE
                    fcb       $D6,$C6,$C6,$00
                    fcb       $C6,$E6,$F6,$DE
                    fcb       $CE,$C6,$C6,$00
                    fcb       $38,$6C,$C6,$C6
                    fcb       $C6,$6C,$38,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $60,$60,$F0,$00
                    fcb       $78,$CC,$CC,$CC
                    fcb       $DC,$78,$1C,$00
                    fcb       $FC,$66,$66,$7C
                    fcb       $6C,$66,$E6,$00
                    fcb       $78,$CC,$E0,$70
                    fcb       $1C,$CC,$78,$00
                    fcb       $FC,$B4,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $CC,$CC,$CC,$CC
                    fcb       $CC,$CC,$FC,$00
                    fcb       $CC,$CC,$CC,$CC
                    fcb       $CC,$78,$30,$00
                    fcb       $C6,$C6,$C6,$D6
                    fcb       $FE,$EE,$C6,$00
                    fcb       $C6,$C6,$6C,$38
                    fcb       $38,$6C,$C6,$00
                    fcb       $CC,$CC,$CC,$78
                    fcb       $30,$30,$78,$00
                    fcb       $FE,$C6,$8C,$18
                    fcb       $32,$66,$FE,$00
                    fcb       $78,$60,$60,$60
                    fcb       $60,$60,$78,$00
                    fcb       $C0,$60,$30,$18
                    fcb       $0C,$06,$02,$00
                    fcb       $78,$18,$18,$18
                    fcb       $18,$18,$78,$00
                    fcb       $10,$38,$6C,$C6
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$FF
                    fcb       $30,$30,$18,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$78,$0C
                    fcb       $7C,$CC,$76,$00
                    fcb       $E0,$60,$60,$7C
                    fcb       $66,$66,$DC,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $C0,$CC,$78,$00
                    fcb       $1C,$0C,$0C,$7C
                    fcb       $CC,$CC,$76,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $FC,$C0,$78,$00
                    fcb       $38,$6C,$60,$F0
                    fcb       $60,$60,$F0,$00
                    fcb       $00,$00,$76,$CC
                    fcb       $CC,$7C,$0C,$F8
                    fcb       $E0,$60,$6C,$76
                    fcb       $66,$66,$E6,$00
                    fcb       $30,$00,$70,$30
                    fcb       $30,$30,$78,$00
                    fcb       $0C,$00,$0C,$0C
                    fcb       $0C,$CC,$CC,$78
                    fcb       $E0,$60,$66,$6C
                    fcb       $78,$6C,$E6,$00
                    fcb       $70,$30,$30,$30
                    fcb       $30,$30,$78,$00
                    fcb       $00,$00,$CC,$FE
                    fcb       $FE,$D6,$C6,$00
                    fcb       $00,$00,$F8,$CC
                    fcb       $CC,$CC,$CC,$00
                    fcb       $00,$00,$78,$CC
                    fcb       $CC,$CC,$78,$00
                    fcb       $00,$00,$DC,$66
                    fcb       $66,$7C,$60,$F0
                    fcb       $00,$00,$76,$CC
                    fcb       $CC,$7C,$0C,$1E
                    fcb       $00,$00,$DC,$76
                    fcb       $66,$60,$F0,$00
                    fcb       $00,$00,$7C,$C0
                    fcb       $78,$0C,$F8,$00
                    fcb       $10,$30,$7C,$30
                    fcb       $30,$34,$18,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$CC,$76,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$78,$30,$00
                    fcb       $00,$00,$C6,$D6
                    fcb       $FE,$FE,$6C,$00
                    fcb       $00,$00,$C6,$6C
                    fcb       $38,$6C,$C6,$00
                    fcb       $00,$00,$CC,$CC
                    fcb       $CC,$7C,$0C,$F8
                    fcb       $00,$00,$FC,$98
                    fcb       $30,$64,$FC,$00
                    fcb       $1C,$30,$30,$E0
                    fcb       $30,$30,$1C,$00
                    fcb       $18,$18,$18,$00
                    fcb       $18,$18,$18,$00
                    fcb       $E0,$30,$30,$1C
                    fcb       $30,$30,$E0,$00
                    fcb       $76,$DC,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$10,$38,$6C
                    fcb       $C6,$C6,$FE,$00

*--------------------------------------------------------------------
* L074C - Draw text characters to Wildbits screen.
*
* u0040 = cursor row (0..24; each row is 8 pixels tall)
* u0041 = cursor col (0..39; each col is 16 screen bytes wide)
* bg CLUT index from $024D (low nibble); fg from $034C ($024D+$FF).
* Font: 8x8 bitmap at L034C, MSB=leftmost pixel.
* Each font pixel expands to 2 screen bytes (double-wide).
* Maps one block per font row via F$MapBlk; increments u0041 per char.
*--------------------------------------------------------------------
L074C               leas      -2,s
                    pshs      y
                    ldx       $06,s

                    lda       >$024D
                    anda      #$0F
                    sta       <u00A4              bg CLUT index
                    lda       >$034C
                    anda      #$0F
                    sta       <u00A5              fg CLUT index

* base_screen_off = u0040*2560 + u0041*16
                    lda       <u0040
                    ldb       #10
                    mul                           D = u0040*10 (A=0 for row<=25)
                    tfr       b,a
                    clrb                          D = u0040*2560
                    pshs      d
                    clra
                    ldb       <u0041
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola                          D = u0041*16
                    addd      ,s++
                    std       <u00A6              u00A6/A7 = base_screen_off

L074C_chr           tst       ,x
                    lbeq      L07B7
                    ldb       ,x+
                    stx       $06,s
                    leax      >L034C,pcr
                    lslb
                    abx
                    abx
                    abx
                    abx                           X = L034C + char*8

                    lda       #8
                    sta       <u00A0              8 font rows
                    ldd       <u00A6
                    std       <u00A8              current_screen_off = base

L074C_row           lda       ,x+                load font row byte
                    sta       <u00A1              save; pixel loop shifts B
                    pshs      x                   save font ptr (X reused by MapBlk)

                    ldd       <u00A8
                    pshs      d
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra                          A = block offset
                    adda      <u0047
                    sta       <scr_cblk
                    tfr       a,b
                    clra
                    tfr       d,x                 X = block#
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end

                    puls      d                   D = current_screen_off
                    anda      #$1F
                    addd      <scr_map
                    tfr       d,y                 Y = screen destination

                    ldb       <u00A1              font byte
                    ldx       #8                  pixel counter
L074C_pix           lslb                          font MSB -> carry
                    bcs       L074C_fg
                    lda       <u00A4              bg color
                    bra       L074C_wr
L074C_fg            lda       <u00A5              fg color
L074C_wr            sta       ,y+                 left pixel
                    cmpy      <scr_end
                    beq       L074C_remap1
L074C_wr2           sta       ,y+                 right pixel
                    cmpy      <scr_end
                    beq       L074C_remap2
L074C_wr3           leax      -1,x
                    bne       L074C_pix

                    ldu       <scr_map
                    ldb       #1
                    os9       F$ClrBlk

                    ldd       <u00A8
                    addd      #320
                    std       <u00A8
                    puls      x
                    dec       <u00A0
                    bne       L074C_row

                    inc       <u0041
                    ldd       <u00A6
                    addd      #16
                    std       <u00A6
                    ldx       $06,s
                    lbra      L074C_chr

L07B7               puls      y
                    leas      $02,s
                    rts

L074C_remap1        pshs      a,b,x
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,y
                    puls      a,b,x
                    bra       L074C_wr2

L074C_remap2        pshs      a,b,x
                    ldb       <scr_cblk
                    incb
                    stb       <scr_cblk
                    clra
                    tfr       d,x
                    ldb       #1
                    os9       F$MapBlk
                    stu       <scr_map
                    tfr       u,d
                    addd      #$2000
                    std       <scr_end
                    tfr       u,y
                    puls      a,b,x
                    bra       L074C_wr3
L07BC               fcb       0,0,0,0
                    fcb       0,0,0,0
L07C4               fcc       /scrn/
L07C8               fcb       0

                    emod
eom                 equ       *
                    end
