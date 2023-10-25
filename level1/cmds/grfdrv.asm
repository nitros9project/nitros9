********************************************************************
* GrfDrv - Graphics module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*   2      2018/03/06  Various minor optimizations, and some 6309 optimizations

                    nam       GrfDrv
                    ttl       Graphics module

* Disassembled 02/04/05 23:44:21 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

* Stack offsets for LINE command
                    org       0
size                equ       .
LnPxMsk1            rmb       1                   (0) Pixel mask for byte from current Gfx Cursor X,Y coord of line
LnPxMsk2            rmb       1                   (1) Pixel mask for byte from caller specified X,Y coord
LnAddr1             rmb       2                   (2-3) Address on screen for user specified X,Y coord byte
LnCoords            rmb       2                   (4-5) Inited to $0000
LnXDir              rmb       1                   (6) X direction/offset (-1 or +1)
LnYDir              rmb       1                   (7) Y direction/offset (-32 or +32)
LnXDist             rmb       2                   (8-9) Distance between X coords
LnYDist             rmb       2                   ($A-$B) Distance between Y coords
LnX1                rmb       1                   ($C) User specified X coord for start of line
LnY1                rmb       1                   ($D) User specified Y coord for start of line
LnUnk3              rmb       1                   ($E) Unknown so far
LnStkSz             equ       .                   Size of Line temp stack

                    fcb       $07

name                fcs       /GrfDrv/
                    fcb       edition

* Dispatch table
start               bra       Term                Init will just exit w/o error
                    nop
                    bra       Write
                    nop
                    bra       GetStat
                    nop
                    bra       SetStat
                    nop
Term                clrb                          Exit without error
                    rts
* Shouldn't need to pad Term (last entry) with 3rd byte
*         NOP

GetStat
SetStat             comb                          No GetStat/SetStat calls in Grfdrv, exit with "Unknown Service" error
                    ldb       #E$UnkSvc
                    rts

Write               suba      #$15                Adjust code to 0 base, for lookup table
                    leax      <Table,pcr          Point to graphics code dispatch table
                    lsla                          * 2 since 2 bytes/entry
                    ldd       a,x                 Get offset
                    jmp       d,x                 Jump to routine

Table               fdb       Do15-Table          Set graphics cursor
                    fdb       Do16-Table          Draw Line
                    fdb       Do17-Table          Erase Line
                    fdb       Do18-Table          Set Point
                    fdb       Do19-Table          Erase Point
                    fdb       Do1A-Table          Draw Circle
                    fdb       Term-Table          $1b (Escape codes) are handled by VTIO and/or CoVDG
                    fdb       Do1C-Table          Erase Circle
                    fdb       Do1D-Table          Flood Fill
                    fdb       Term-Table          $1E handled elsewhere
                    fdb       Term-Table          $1F handled elsewhere

* Fix X/Y coords:
* - if Y > 191 then cap it at 191
* - adjust X coord if in 128x192 mode
* Entry: U=static mem ptr
*        <V.NChar,u = X,Y coords (1 byte each)
*        A=X coord
*        B=Y coord
FixXY               ldd       <V.NChar,u          get next 2 chars
                    cmpb      #192                Y greater than max?
                    blo       L0053               No, continue
                    ldb       #191                Truncate @ 191
L0053               tst       <V.Mode,u           which mode?
                    bmi       L0059               branch if 256x192
                    lsra                          else divide X by 2 (128)
L0059               std       <V.NChar,u          and save coords
                    rts

* $15 - set graphics cursor
Do15                leax      <SetGC,pcr          load X with return address
GChar2              ldb       #2                  need two parameters
                    lbra      GChar               Get the coords, then come back to SetGC routine

SetGC               bsr       FixXY               fix coords
                    std       <V.GCrsX,u          and save new gfx cursor pos
                    clrb
                    rts

* $17 - erase line
Do17                clr       <V.Msk1,u           clear color mask
* $16 - draw line
Do16                leax      <DrawLine,pcr       load X with return address
                    bra       GChar2              Get 2 more parameter bytes, then go to DrawLine

DrawLine            bsr       FixXY               fix up coords for screen resolution
                    leas      -LnStkSz,s          make room on stack for line vars
                    std       LnX1,s              save caller supplied (and fixed up) X,Y
                    jsr       [<V.CnvVct,u]       get address given X/Y
                    stx       LnAddr1,s           save on stack
                    sta       LnPxMsk2,s          and it's pixel mask too
                    ldd       <V.GCrsX,u          get current graphics cursor
                    jsr       [<V.CnvVct,u]       get address given X/Y
                    sta       ,s                  Save pixel mask for point @ gfx cursor location
                    clra
                    clrb
                    std       LnCoords,s          Init to $0000
                    lda       #191                Y=0 on bottom, so flip Gfx Cursor Y coord around
                    suba      <V.GCrsY,u
                    sta       <V.GCrsY,u          Save flipped version
                    lda       #191                Now, do same for caller supplied Y coord
                    suba      <V.NChr2,u
                    sta       <V.NChr2,u          Save flipped version
                    lda       #-1                 Init X direction to -1
                    sta       LnXDir,s
                    clra                          D=Gfx cursor X position
                    ldb       <V.GCrsX,u
                    subb      <V.NChar,u          Subtract (as 16 bit) caller X coord
                    sbca      #$00
                    bpl       L00D6               If positive # (callers is left of gfx cursor), done
                    ifne      H6309
                    negd                          If negative, flip to positive
                    else
                    nega                          If negative, flip to positive
                    negb
                    sbca      #$00
                    endc
                    neg       LnXDir,s            Flip X direction to +1
L00D6               std       LnXDist,s           Save # pixels between X coords
                    bne       L00DF               Not vertical line (0 distance), skip ahead
                    ldd       #$FFFF              If vertical line, change 4,s to $FFFF (-1 / -1)
                    std       LnCoords,s
L00DF               lda       #-32                Init Y direction/increment to -32 (1 line on screen)
                    sta       LnYDir,s
                    clra
                    ldb       <V.GCrsY,u          D=Gfx cursor Y coord
                    subb      <V.NChr2,u          Subtract (as 16 bit) caller Y coord
                    sbca      #$00
                    bpl       L00F4               If positive # (callers is below gfx cursor), done
                    ifne      H6309
                    negd                          If negative, flip to positive
                    else
                    nega                          If negative, flip to positive
                    negb
                    sbca      #$00
                    endc
                    neg       LnYDir,s            Change Y direction/offset to +32
L00F4               std       LnYDist,s           Save # pixels between Y coords
                    bra       L0100               Skip into drawing loop

* Main line drawing loop
L00F8               sta       ,s                  Save new shifted pixel mask
                    ldd       LnCoords,s
                    subd      LnYDist,s           Subtract distance between Y coords
                    std       LnCoords,s          Save updated value
L0100               lda       ,s                  Get current pixel mask for Gfx Cursor X,Y coord
                    bsr       L0081               Draw point on screen
                    cmpx      LnAddr1,s           Are we still at same address on screen as we started?
                    bne       L010F               No, skip ahead
                    lda       ,s                  Get Gfx Cursor X,Y coord pixel mask back
                    cmpa      LnPxMsk2,s          Same as pixel mask for caller's X,Y coord?
                    beq       L0143               Yes, skip ahead
L010F               ldd       LnCoords,s
                    bpl       L011D               If >0, skip ahead
                    addd      LnXDist,s           Add to distance between X coords
                    std       LnCoords,s          Save overtop as new value
                    lda       LnYDir,s            Get Y direction/increment
                    leax      a,x                 Bump Y coord up or down as appropriate (SIGNED, so can't use abx)
                    bra       L0100               Draw next pixel

L011D               lda       ,s                  Get current pixel mask for Gfx Cursor X,Y coord
                    ldb       LnXDir,s            Get X direction/offset
                    bpl       L0133               If positive, skip ahead
                    lsla                          If negative, shift pixel mask left 1 bit
                    ldb       <V.Mode,u           Check video mode
                    bmi       L012A               If 256x192, that's all we need.
                    lsla                          4 color mode, shift 2nd time (2 bits/pixel)
L012A               bcc       L00F8               If we didn't hit the end of the byte, do next pixel in this byte
                    lda       <V.4A,u             Get mask for last pixel in a byte for current mode
                    leax      -1,x                Bump screen ptr to left by one
                    bra       L00F8               Back to the drawing loop

L0133               lsra                          Shift active pixel mask to right 1 bit
                    ldb       <V.Mode,u           Get graphics mode
                    bmi       L013A               If 2 color, we are done shifting
                    lsra                          4 color, shift 1 more (2 bits/pixel)
L013A               bcc       L00F8               Still more pixels in current byte, do next pixel
                    lda       <V.MCol,u           Get mask for first pixel in a byte for current mode
                    leax      1,x                 Bump screen ptr to right by one
                    bra       L00F8               Back to drawing loop

L0143               ldd       LnX1,s              Get destination X,Y coords from caller
                    std       <V.GCrsX,u          Save them as the new graphics cursor position
                    leas      LnStkSz,s           Eat temp Line stack
L014A               lda       <V.Msk2,u           Get full byte color mask for current foreground color?
                    sta       <V.Msk1,u           Save in another mask
                    clrb                          Return w/o error
                    rts

* $1C - erase circle
Do1C                clr       <V.Msk1,u           clear mask value
* $1A - draw circle
Do1A                leax      <Circle,pcr
                    ldb       #$01                require another param -- radius
GChar               stb       <V.NGChr,u          one more char
                    stx       <V.RTAdd,u          return address
                    clrb
                    rts

* $19 - erase point - moved here to (hopefully) allow bsr in Line
Do19                clr       <V.Msk1,u           Color mask to $00 (background color)
* $18 - set point
Do18                leax      <DrawPnt,pcr        Routine to come back to when we get our parameter bytes
                    lbra      GChar2              Go get 2 more bytes; then come back to DrawPnt

DrawPnt             lbsr      FixXY               fix coords
                    std       <V.GCrsX,u          save as new gfx cursor pos
                    bsr       DrwPt2
                    bra       L014A

* Draw a single point. Called by set point/erase point, and circle
* Entry: A=pixel X position to draw
*        B=pixel Y position to draw
DrwPt2              jsr       [<V.CnvVct,u]       Get offset into screen memory (X) & bit mask for pixel (A)
* Draw single point w/o needing conversion of address/mask. Called by Line and Flood Fill
L0081               tfr       a,b                 Duplicate pixel mask
                    ifne      H6309
                    comb                          Flip to keep background pixels
                    andb      ,x
                    anda      <V.Msk1,u           and pixel mask with color mask
                    orr       b,a                 Merge foreground pixel onto background
                    sta       ,x                  Save it to screen
                    else
                    comb                          Flip to keep background pixels
                    andb      ,x
                    stb       ,x
                    anda      <V.Msk1,u           and pixel mask with color mask
                    ora       ,x                  Merge foreground pixel onto background
                    sta       ,x                  Save it to screen
                    endc
                    rts

Circle              leas      -4,s                make room on stack
                    clra
                    ldb       <V.NChr2,u          get radius into D
                    std       ,s                  store on stack and make D=radius (both D and on stack)
                    addd      ,s
                    ifne      H6309
                    negd                          Invert sign of D
                    else
                    nega                          Invert sign of D
                    negb
                    sbca      #$00
                    endc
                    addd      #$0003              And add 3
                    std       2,s                 Save that
L0179               lda       ,s
                    cmpa      1,s
                    bhs       L01AB
                    ldb       1,s
                    bsr       L01B9
                    clra
                    ldb       2,s
                    bpl       L0193
                    ldb       ,s
                    lslb
                    rola
                    lslb
                    rola
                    addd      #$0006
                    bra       L01A3

L0193               dec       1,s
                    clra
                    ldb       ,s
                    subb      1,s
                    sbca      #$00
                    lslb                          Multiply D by 4
                    rola
                    lslb
                    rola
                    addd      #10                 And add 10
L01A3               addd      2,s
                    std       2,s
                    inc       ,s
                    bra       L0179

L01AB               lda       ,s
                    cmpa      1,s
                    bne       L01B5
                    ldb       1,s
                    bsr       L01B9
L01B5               leas      4,s                 Eat temp stack
                    lbra      L014A               Copy color mask 2 to color mask 1 & return w/o error

L01B9               leas      -8,s                Allocate another 8 byte temp stack
                    sta       ,s
                    clra
                    std       2,s
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    std       6,s
                    ldb       ,s
                    clra
                    std       ,s
                    ifne      H6309
                    negd
                    else
                    nega
                    negb
                    sbca      #$00
                    endc
                    std       4,s
                    ldx       6,s
                    bsr       L0202
                    ldd       4,s
                    ldx       2,s
                    bsr       L0202
                    ldd       ,s
                    ldx       2,s
                    bsr       L0202
                    ldd       ,s
                    ldx       6,s
                    bsr       L0202
                    ldd       2,s
                    ldx       ,s
                    bsr       L0202
                    ldd       2,s
                    ldx       4,s
                    bsr       L0202
                    ldd       6,s
                    ldx       4,s
                    bsr       L0202
                    ldd       6,s
                    ldx       ,s
                    bsr       L0202
                    leas      8,s                 Eat temp stack & return
                    rts

* Not sure on these, but I think:
* Entry: D=X coord of some sort
*        X=Y coord of some sort
L0202
                    ifne      H6309
                    tfr       d,w
                    else
                    pshs      d
                    endc
                    ldb       <V.GCrsY,u          Get Y coord of graphics cursor (center of circle)
                    abx
                    cmpx      #$0000              Off bottom of screen?
                    bmi       L0214               Yes, return
                    cmpx      #191                Off top of screen?
                    ble       L0216               No, go draw pixels
L0214
                    ifne      H6309
                    rts
                    else
                    puls      pc,d                Off screen vertically, return
                    endc

L0216               ldb       <V.GCrsX,u          Get X coord of graphics cursor (center of circle) into D
                    clra
                    tst       <V.Mode,u           Check graphics mode
                    bmi       L0221               2 color, skip ahead
                    lslb                          4 color, Shift left 1 bit
                    rola
L0221
                    ifne      H6309
                    addr      w,d                 Add to ?
                    else
                    addd      ,s++                Add to ?
                    endc
                    tsta                          If <256, continue
                    beq       L0227
                    rts                           Else return

L0227
                    ifne      H6309
                    tfr       b,e                 Save Y coord in E         (3 tfr's in native mode 2 cyc faster)
                    tfr       x,d                 Move low byte of X to B
                    tfr       e,a                 Move Y coord to A
                    else
                    pshs      b                   Save 8 bit version of value
                    tfr       x,d                 Move low byte of X to B
                    puls      a                   And restore value, this time as A
                    endc
                    tst       <V.Mode,u           Check graphics mode
                    lbmi      DrwPt2              If 2 color, draw pixel on screen & return from there
                    lsra                          4 color, shift 1 more first
                    lbra      DrwPt2

* $1D - flood fill
* Change by LCB - keep V.Mode in E, since it gets checked. A lot.
Do1D                clr       <V.FFFlag,u         Clear flag
                    leas      -7,s
                    lbsr      L03AB               Allocate 512 byte Flood fill stack, if not already allocated
                    lbcs      L0346               Not allocated, and couldn't get it, exit with error
                    ifne      H6309
                    lde       <V.Mode,u           Get gfx mode, so we can keep in E for faster checking
                    endc
                    lda       #-1                 $FF Set direction flag to -1 (X direction, I think)
                    sta       <V.4F,u
                    ldd       <V.GCrsX,u          Get graphics cursor X,Y coords
                    lbsr      L0351
                    lda       <V.4C,u
                    sta       <V.4D,u
                    ifne      H6309
                    tste                          which mode?
                    else
                    tst       <V.Mode,u           which mode?
                    endc
                    bpl       L0261               branch if 128x192
                    tsta
                    beq       L0267               Color 0 byte mask for 2 color
                    lda       #$FF                Color 1 byte mask for 2 color
                    bra       L0267

* 128x192 4 color pixel table - NOTE THIS IS DUPLICATED IN VTIO
Mode1Clr            fcb       $00,$55,$aa,$ff

* Entry: A=color # 0-3
L0261               leax      <Mode1Clr,pcr       Point to 4 color color mask table
                    lda       a,x                 Get mask for selected color
L0267               sta       <V.4E,u             Save copy of color mask
                    cmpa      <V.Msk1,u
                    lbeq      L0346
                    ldd       <V.GCrsX,u          Get gfx cursor cursory X,Y coords
L0274               suba      #$01
                    bcs       L027F               Wrapped negative, skip ahead
                    lbsr      L0351
                    beq       L0274
L027F               inca
                    std       1,s
L0282               lbsr      L0384
                    adda      #$01
                    bcs       L0290               Wrapped past 256, skip ahead
                    lbsr      L0351
                    bcs       L0290
                    beq       L0282
L0290               deca
                    ldx       1,s
                    lbsr      L03D3
                    neg       <V.4F,u             Flip X direction
                    lbsr      L03D3
L029C               lbsr      L03F9
                    lbcs      L0346
                    tst       <V.4F,u             Check current X direction
                    bpl       L02B3               If +1, go increment
                    subb      #$01                negative, so subtract 1
                    bcs       L029C               If wrapped, go back
                    std       3,s                 Save coords
                    tfr       x,d
                    decb
                    bra       L02BD

L02B3               incb                          Bump up Y coord
                    cmpb      #191                Off top of screen?
                    bhi       L029C               Yes, jump back
                    std       3,s
                    tfr       x,d
                    incb
L02BD               std       1,s
                    lbsr      L0351
                    bcs       L029C
L02C4               bne       L02D2
                    suba      #$01
                    bcc       L02CD
                    inca
                    bra       L02D6

L02CD               lbsr      L0351
                    bcc       L02C4
L02D2               adda      #$01
                    bcs       L029C               Wrapped over 255, go back
L02D6               cmpd      3,s
                    bhi       L029C
                    bsr       L0351
                    bcs       L029C
                    bne       L02D2
                    std       5,s
                    cmpd      1,s
                    bhs       L02FB
                    ldd       1,s
                    decb
                    cmpd      5,s
                    beq       L02FB
                    neg       <V.4F,u             ?? Maybe direction flag?
                    ldx       5,s
                    lbsr      L03D3
                    neg       <V.4F,u
L02FB               ldd       5,s
L02FD               std       1,s
L02FF               bsr       L0351
                    bcs       L030B
                    bne       L030B
                    bsr       L0384
                    adda      #$01
                    bcc       L02FF               Didn't wrap 255, loop again
L030B               deca
                    ldx       1,s
                    lbsr      L03D3
                    std       5,s
                    adda      #$01
                    bcs       L0326               Wrapped 255, skip ahead
L0317               cmpd      3,s
                    bhs       L0326
                    adda      #$01
                    bsr       L0351
                    bcs       L0326
                    bne       L0317
                    bra       L02FD

L0326               lda       3,s
                    inca
                    inca
                    sta       3,s
                    cmpa      #$02                High byte 0 or 1?
                    lblo      L029C               yes, go back (note - immediately calls L03F9, which immediately reloads D.
                    ldd       5,s
                    cmpd      3,s
                    lblo      L029C
                    neg       <V.4F,u
                    ldx       3,s
                    lbsr      L03D3
                    lbra      L029C

L0346               leas      7,s                 Eat temp stack
                    clrb                          Default to no error (carry clear
                    ldb       <V.FFFlag,u         Was there an error?
                    beq       L0350               No, exit
L034E               orcc      #Carry              Yes, flag carry
L0350               rts

* Entry: A=X coord (0-127 or 0-255 depending on mode)
*        B=Y coord (0-191)
* Exit: Carry set if pixel would have been off screen
*       Carry clear if on screen,
L0351               pshs      d
                    cmpb      #191
                    bhi       L0380               If past top of screen, exit with carry set
                    ifne      H6309
                    tste                          which mode?
                    else
                    tst       <V.Mode,u           which mode?
                    endc
                    bmi       L0360               2 color, skip ahead
                    cmpa      #127                4 color, check if we are past right side of screen
                    bhi       L0380               Yes, exit with carry set
L0360               jsr       [<V.CnvVct,u]       Coord on screen, get ptr to byte on screen for pixel into X (and pixel mask in A)
                    tfr       a,b                 Dupe pixel mask to B
                    andb      ,x                  Keep background screen contents
L0367               bita      #$01                Is far right pixel set in the mask?
                    bne       L0376               Yes, exit with carry clear and other flags set (zero, negative,etc.)
                    lsra                          No, shift pixel masks right 1 bit
                    lsrb
                    ifne      H6309
                    tste                          which mode?
                    else
                    tst       <V.Mode,u           which mode?
                    endc
                    bmi       L0367
                    lsra                          If 4 color, shift once more (2 bits/pixel) and check again
                    lsrb
                    bra       L0367

L0376               stb       <V.4C,u
                    cmpb      <V.4D,u
                    andcc     #^Carry             Force carry off, keep rest of bits from CMP
                    puls      pc,d

L0380               orcc      #Carry
                    puls      pc,d

L0384               pshs      d                   Save X,Y coords
                    jsr       [<V.CnvVct,u]       Figure out address on screen (and pixel mask)
                    bita      #%10000000          $80 - Left pixel in byte?
                    beq       L03A6               No, skip ahead
                    ldb       <V.4E,u
                    cmpb      ,x
                    bne       L03A6
                    ldb       <V.Msk1,u
                    stb       ,x
                    puls      d
                    ifne      H6309
                    tste                          2 color mode?
                    else
                    tst       <V.Mode,u           2 color mode?
                    endc
                    bmi       L03A3               Yes, skip ahead
                    adda      #$03
                    rts

L03A3               adda      #$07
                    rts

L03A6               lbsr      L0081               Draw pixel on screen
                    puls      pc,d

L03AB               ldx       <V.FFSTp,u          get top of flood fill stack
                    beq       L03B5               if zero, we need to allocate stack
                    stx       <V.FFSPt,u          else reset flood fill stack ptr & return
L03B3               clrb
                    rts

* Allocate Flood Fill Stack
L03B5               pshs      u                   save U for now
                    ldd       #$0200              get 512 bytes
                    os9       F$SRqMem            from system
                    bcc       AllocOk             branch if ok
                    puls      pc,u                else pull out with error

AllocOk             tfr       u,d                 move pointer to alloced mem to D
                    puls      u                   get stat pointer we saved earlier
                    std       <V.FFMem,u          save pointer to alloc'ed mem
                    addd      #512                point D to end of alloc'ed mem
                    std       <V.FFSTp,u          and save here as top of fill stack
                    std       <V.FFSPt,u          and here
                    clrb
                    rts

* Add FFill stack entry (4 bytes). Max of 128 entries allowed.
L03D3               pshs      d
                    ldd       <V.FFSPt,u          Get current FFill stack ptr
                    subd      #$0004              Add 4 bytes to it
                    cmpd      <V.FFMem,u          Have we filled all 512 bytes?
                    blo       L03F2               Yes, error out
                    std       <V.FFSPt,u          No, Save new FFill stack ptr
                    tfr       d,y                 Move new ptr to indexable register
                    lda       <V.4F,u             Get? (direction flag, maybe?)
                    sta       ,y                  Save on stack
                    stx       1,y                 Save (mem ptr on screen, I think?)
                    puls      d                   Get ?? back
                    sta       3,y                 Save A to FFill stack entry & return
                    rts

L03F2               ldb       #E$Write            $F5 Write Error if FFill stack overflows
                    stb       <V.FFFlag,u         Save error code
                    puls      pc,d

* Remove FFill stack entry (4 bytes)
L03F9               ldd       <V.FFSPt,u          Get current FFill stack ptr
                    cmpd      <V.FFSTp,u          Have we already emptied stack?
                    lbhs      L034E               Yes, stack empty, exit with carry set
                    tfr       d,y                 No, move to indexable register
                    addd      #$0004              Add 4 to it (eat 4 bytes from stack)
                    std       <V.FFSPt,u          Save as new FFill stack ptr
                    lda       ,y                  Get byte from original FFill stack position
                    sta       <V.4F,u             Save it
                    ldd       1,y
                    tfr       d,x
                    lda       3,y
                    andcc     #^Carry
                    rts

                    emod
eom                 equ       *
                    end

