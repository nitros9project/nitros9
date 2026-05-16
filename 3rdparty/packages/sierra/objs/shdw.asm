********************************************************************
* shdw - Sierra AGI screen rendering module
*
* Note the header shows a data size of 0 called from the sierra
* module and accesses data set up in that module.
*
* Much credit and thanks is give to Nick Sonneveld and the other NAGI
* folks. Following his sources made it so much easier to document what
* was happening in here.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/14  Paul W. Zibaila
* Disassembly of original distribution using a combination of disasm
* v1.6 and the os9tools disassembler Os9disasm.
* Annotated by /annotate-asm (Claude Code) 2026-05-12:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction
* Annotated by /annotate-asm (Claude Code) 2026-05-14:
*   - Renamed disassembled equates (Xffa9→GimeMmuReg, X01af→StateFlag, X0551→GivenPicDataPtr)
*   - Fixed module description (removed KQ3-specific title — module is game-generic)
*   - Added ====== section headers throughout code body

                    nam       shdw
                    ttl       program module

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size

size                equ       .

GimeMmuReg          equ       $FFA9     GIME task-1 MMU register (maps $2000–$3FFF)
StateFlag           equ       $01AE     Sierra state.flag byte (ego signal / water / invis)
GivenPicDataPtr     equ       $0551     given_pic_data pointer (set by pic_res.c)


* OS9 data area definitions

ShdwMmuBlock        equ       $001A     shdw MMU block data
LoadOffset          equ       $002E     Load offset
SierraPdBlk         equ       $0042     Sierra process descriptor block
Sierra2ndBlk        equ       $0043     Sierra 2nd 8K data block
DrawColor           equ       $005A     color
DrawMask            equ       $005B     sbuff_drawmask
FlagControl         equ       $005C     flag_control
PenStatus           equ       $006B     pen_status

* these look like gen purpose scratch vars

PosInitX            equ       $00A0
PosInitY            equ       $00A1
PosFinalX           equ       $00A2
PosFinalY           equ       $00A3
ScratchA2           equ       $00A4
ScratchA3           equ       $00A5
ScratchA4           equ       $00A6
ScratchA5           equ       $00A7
ScratchA6           equ       $00A8
ScratchA7           equ       $00A9
ScratchA8           equ       $00AA
ScratchA9           equ       $00AB
ScratchAA           equ       $00AC
ScratchAB           equ       $00AD
ScratchAC           equ       $00AE
ScratchAD           equ       $00AF
FillColorBl         equ       $00B0
MaskDl              equ       $00B1
OldBuff             equ       $00B2
TempBuff            equ       $00B4
PriHeight           equ       $00B5




* VIEW OBJECTS FLAGS

O_DRAWN             equ       $01       * 0  - object has been drawn
O_BLKIGNORE         equ       $02       * 1  - ignore blocks and condition lines
O_PRIFIXED          equ       $04       * 2  - fixes priority agi cannot change it based on position
O_HRZNIGNORE        equ       $08       * 3  - ignore horizon
O_UPDATE            equ       $10       * 4  - update every cycle
O_CYCLE             equ       $20       * 5  - the object cycles
O_ANIMATE           equ       $40       * 6  - animated
O_BLOCK             equ       $80       * 7  - resting on a block
O_WATER             equ       $100      * 8  - only allowed on water
O_OBJIGNORE         equ       $200      * 9  - ignore other objects when determining contacts
O_REPOS             equ       $400      * 10 - set whenever a obj is repositioned
*                                that way the interpeter doesn't check it's next movement for one cycle
O_LAND              equ       $800      * 11 - only allowed on land
O_SKIPUPDATE        equ       $1000     * 12 - does not update obj for one cycle
O_LOOPFIXED         equ       $2000     * 13 - agi cannot set the loop depending on direction
O_MOTIONLESS        equ       $4000     * 14 - no movement.
*                                if position is same as position in last cycle then this flag is set.
*                                follow/wander code can then create a new direction
*                                (ie, if it hits a wall or something)
O_UNUSED            equ       $8000

* Local Program Defines

PICBUFF_WIDTH       equ       160       ($A0)
PICBUFF_HEIGHT      equ       168       ($A8)

picb_size           equ       PICBUFF_WIDTH*PICBUFF_HEIGHT $6900
x_max               equ       PICBUFF_WIDTH-1 159 ($9F)
y_max               equ       PICBUFF_HEIGHT-1 167 ($A7)

gfx_picbuff         equ       $6040     screen buff low address
gbuffend            equ       gfx_picbuff+picb_size screen buff high address $C940

blit_end            equ       gfx_picbuff+$6860

cmd_start           equ       $F0       first command value


* ====== Module Header ======
name                equ       *
ShdwName            fcs       'shdw'
                    fcb       $00

* This module is linked to in sierra

* ====== Dispatch Table: Function Entry Vectors ======
start               equ       *
DispatchTable       lbra      PicBufUpdateRemap gfx_picbuff_update_remap
                    lbra      ObjChkControl obj_chk_control
                    lbra      RenderPic render_pic  (which calls pic_cmd_loop)
                    lbra      PicCmdLoop pic_cmd_loop
                    lbra      ObjBlit   obj_blit
                    lbra      ObjAddPicPri obj_add_pic_pri
                    lbra      BlitRestore blit_restore
                    lbra      BlitSave  blit_save
                    lbra      SbuffFill sbuff_fill
                    lbra      BlitListDraw blitlist_draw
                    lbra      BlitListErase blitlist_erase

                    fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       C$NULL

* ====== TwiddleMmu: Switch MMU Context for Sierra Data Block ======
* Twiddles with MMU
* accd is loaded by calling program
*
*  ShdwMmuBlock = shdw mem block data
*  SierraPdBlk = sierra process descriptor block
*  Sierra2ndBlk = Sierra 2nd 8K data block

TwiddleMmu          cmpa      ShdwMmuBlock compare to shdw mem block
                    beq       TwiddleMmuDone equal ?? no work to be done move on
                    orcc      #IntMasks turn off interupts
                    sta       ShdwMmuBlock store the value passed in by a
                    lda       SierraPdBlk get sierra process descriptor map block
                    sta       GimeMmuReg map it in to $2000-$3FFF
                    ldu       Sierra2ndBlk 2nd 8K data block in Sierra
                    lda       ShdwMmuBlock load my mem block value
                    sta       ,u        save my values at address held in Sierra2ndBlk
                    stb       $02,u     save block value byte 2
                    std       GimeMmuReg map it to task 1 block 2
                    andcc     #^IntMasks restore the interupts
TwiddleMmuDone      rts                 we done

LoadOffsetsFlag     fcb       $00       load offsets updated flag

* ====== Static Data Tables: BinaryList, CircleData, CircleList, CmdDispatchTable ======
* binary_list[] (pic_render.c)
BinaryList          fdb       $8000
                    fdb       $4000
                    fdb       $2000
                    fdb       $1000
                    fdb       $0800
                    fdb       $0400
                    fdb       $0200
                    fdb       $0100
                    fdb       $0080
                    fdb       $0040
                    fdb       $0020
                    fdb       $0010
                    fdb       $0008
                    fdb       $0004
                    fdb       $0002
                    fdb       $0001

* circle_data[] (pic_render.c)
CircleData          fdb       $8000
                    fdb       $4000
                    fdb       $e000
                    fdb       $4000
                    fdb       $7000
                    fdb       $f800
                    fdb       $f800
                    fdb       $f800
                    fdb       $7000
                    fdb       $3800
                    fdb       $7c00
                    fdb       $fe00
                    fdb       $fe00
                    fdb       $fe00
                    fdb       $7c00
                    fdb       $3800
                    fdb       $1c00
                    fdb       $7f00
                    fdb       $ff80
                    fdb       $ff80
                    fdb       $ff80
                    fdb       $ff80
                    fdb       $ff80
                    fdb       $7f00
                    fdb       $1c00
                    fdb       $0e00
                    fdb       $3f80
                    fdb       $7fc0
                    fdb       $7fc0
                    fdb       $ffe0
                    fdb       $ffe0
                    fdb       $ffe0
                    fdb       $7fc0
                    fdb       $7fc0
                    fdb       $3f80
                    fdb       $1f00
                    fdb       $0e00
                    fdb       $0f80
                    fdb       $3fe0
                    fdb       $7ff0
                    fdb       $7ff0
                    fdb       $fff8
                    fdb       $fff8
                    fdb       $fff8
                    fdb       $fff8
                    fdb       $fff8
                    fdb       $7ff0
                    fdb       $7ff0
                    fdb       $3fe0
                    fdb       $0f80
                    fdb       $07c0
                    fdb       $1ff0
                    fdb       $3ff8
                    fdb       $7ffc
                    fdb       $7ffc
                    fdb       $fffe
                    fdb       $fffe
                    fdb       $fffe
                    fdb       $fffe
                    fdb       $fffe
                    fdb       $7ffc
                    fdb       $7ffc
                    fdb       $3ff8
                    fdb       $1ff0
                    fdb       $07c0

* circle_list[] (pic_render.c)
* this data is different in the file
* { 0, 1, 4, 9, 16, 25, 37, 50 }
* These run like a set of numbers**2 {0,1,2,3,4,5,~6,~7}
* ah ha these are multiples 2*(0,1,2,3,4,5,~6,~7)**2)

CircleList          fcb       $00,$00   0
                    fcb       $00,$02   2
                    fcb       $00,$08   8
                    fcb       $00,$12   18
                    fcb       $00,$20   32
                    fcb       $00,$32   50
                    fcb       $00,$4a   74
                    fcb       $00,$64   100


* select case dispatch table for pic_cmd_loop()

CmdDispatchTable    fdb       EnablePicDraw enable_pic_draw()
                    fdb       DisablePicDraw disable_pic_draw()
                    fdb       EnablePriDraw enable_pri_draw()
                    fdb       DisablePriDraw disable_pri_draw()
                    fdb       DrawYCorner draw_y_corner()
                    fdb       DrawXCorner draw_x_corner()
                    fdb       AbsoluteLine absolute_line()
                    fdb       RelativeLine relative_line()
                    fdb       PicFill   pic_fill()
                    fdb       ReadPenStatus read_pen_status()
                    fdb       PlotWithPen plot_with_pen()


* ====== AddLoadOffsets: Patch Command Dispatch Table on First Call ======
* This code adds the load offsets to the program offsets above
*
*  ScratchAB = loop counter
*
AddLoadOffsets      tst       LoadOffsetsFlag,pcr test if we've loaded the offsets already
                    bne       AddOffsetsDone done once leave
                    inc       LoadOffsetsFlag,pcr not done set the flag
                    lda       #$0b      set our index to 11
                    sta       ScratchAB stow it in mem since we are going to clobber b
                    leau      >CmdDispatchTable,pcr load table head address
AddOffsetLoop       ldd       LoadOffset get load offset set in sierra
                    addd      ,u        add the load offset
                    std       ,u++      and stow it back, bump pointer
                    dec       ScratchAB decrement the index
                    bne       AddOffsetLoop ain't done go again
AddOffsetsDone      rts                 we're out of here


* ====== RenderPic / PicCmdLoop: Main Picture Rendering Loop ======
* The interaction between render_pic and pic_cmd_loop is divided
* differently in the NAGI source pic_render.c

* render_pic()
* 4 = proirity and color = F, so the note says
* so the priority is MSnibble and the color is LSnibble

RenderPic           ldd       #$4f4f    load the color
                    pshs      d         push it on the stack for the pass
                    lbsr      SbuffFill call sbuff_fill routine
                    leas      $02,s     reset stack to value at entry
                    ldd       $02,s     pull the next word
                    pshs      d         push it on top of the stack
                    lbsr      PicCmdLoop call pic_cmd_loop()
                    leas      $02,s     once we return clean up stack again
                    rts                 return

* pic_cmd_loop() (pic_render.c)
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  PenStatus = pen_status

PicCmdLoop          pshs      y
                    bsr       AddLoadOffsets ensure load offset has been added to table address
                    lbsr      TableInit sbuff_fill()
                    clra                make a zero
                    sta       DrawMask  sbuff_drawmask
                    sta       PenStatus pen_status
                    coma                make the complement FF
                    sta       DrawColor store color

                    ldu       4,s       get the word passed in to us on the stack
                    ldd       5,u       pull out the required info for the mmu twiddle
                    lbsr      TwiddleMmu twiddle mmu

* pic_cmd_loop()  (pic_render.c) starts here
                    ldx       GivenPicDataPtr given_pic_data  set in pic_res.c
GetPicByte          lda       ,x+       pic_byte

ProcessPicByte      cmpa      #$ff      if it's FF were done
                    beq       PicCmdLoopRet so head out
                    suba      #cmd_start first valid cmd = F0 so subtract to get index
                    blo       GetPicByte less than F0 ignore it get next byte
                    cmpa      #$0a      check for top end
                    bhi       GetPicByte greater than FA ignore it get next byte
                    leau      >CmdDispatchTable,pcr load the addr of the dispatch table
                    asla                sign extend multiply by two for double byte offset
                    jsr       [a,u]     make the call
                    bra       ProcessPicByte loop again

PicCmdLoopRet       puls      y         done then fetch the y back
                    rts                 and return

* ====== Picture Draw Commands ($F0-$F3): Color and Priority Control ======
* Command $F0 change picture color and enable picture draw
*  enable_pic_draw() pic_render.c
*  differs slightly with pic_render.c
*  does't have colour_render()
*  and setting of colour_picpart
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a

EnablePicDraw       ldd       DrawColor pulls in color and sbuff_drawmask
                    anda      #$f0      and color with $F0
                    ora       ,x+       or that result with the pic_byte and bump to next
                    orb       #$0f      or the sbuff_drawmask with $0F
                    std       DrawColor store the updated values
                    lda       ,x+       return value ignored so this just bumps to next pic_byte
                    rts                 return to pic_cmd_loop


* Command $F1 Disable picture draw
*  disable_pic_draw()
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a

DisablePicDraw      ldd       DrawColor pulls in color and sbuff_drawmask
                    ora       #$0f      ors color with $0F (white ??)
                    andb      #$f0      ands draw mask with $F0
                    std       DrawColor store the updated values
                    lda       ,x+       return value ignored so this just bumps to next pic_byte
                    rts                 return to pic_cmd_loop

* Command $F2 Changes priority color and enables priority draw
*  enable_pri_draw() pic_render.c
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a

EnablePriDraw       ldd       DrawColor pulls in color and sbuff_drawmask
                    anda      #$0f      ands color with $0F
                    sta       DrawColor save color
                    lda       ,x+       loads pic_byte and bumps to next
                    asla                times 2 with sign extend
                    asla                again times 2
                    asla                and again times 2
                    asla                end result is multiply pic_byte by 16 ($10)
                    ora       DrawColor or that value with the modified color
                    orb       #$f0      or the sbuff_drawmask with $F0
                    std       DrawColor store the updated values
                    lda       ,x+       return value ignored so this just bumps to next pic_byte
                    rts                 return to pic_cmd_loop

* Command $F3 Disable priority draw
*  diasable_pri_draw() pic_render.c
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a


DisablePriDraw      ldd       DrawColor pulls in color and sbuff_drawmask
                    ora       #$f0      or the color with $F0
                    andb      #$0f      and the sbuff_drawmask with $0F
                    std       DrawColor store the updated values
                    lda       ,x+       return value ignored so this just bumps to next pic_byte
                    rts                 return to pic_cmd_loop

* ====== PlotWithPen / PlotWithPen2 ($FA): Splatter and Solid Pen Plotting ======
* Command $FA plot with pen
* Logic is pic_byte >= 0xF0 in c source.
* Emailed Nick Sonneveld 3/14/ 03
*
*  PenStatus = pen_status
*  ScratchA2 = pen_x position
*  ScratchA3 = pen_y position
*  ScratchA6 = texture_num
*
*  x contains pointer to given_pic_data known as the pic_byte
*  returns the next pic_byte in a

* plot_with_pen()  (pic_render.c)
PlotWithPen         lda       PenStatus pen_status
                    bita      #$20      and but don't change check for pen type solid or splater ($20)
                    beq       PlotWithPenCalc is splater
                    lda       ,x+       load pic_byte (acca) from pic_code and bump pointer
                    cmpa      #cmd_start test against $F0 if a is less than
*                      based on discussions with Nick this must have been a bug
*                      in the earlier versions of software...
*                      if it is less than $F0 it's just a picture byte
*                      fix next rev.
                    lbcc      CmdReturn branch to a return statement miles away (could be fixed)
                    sta       ScratchA6 save our pic_byte in texture_num
PlotWithPenCalc     lbsr      ReadXyPos call read_xy_postion
                    lblo      CmdReturn far off rts
                    std       ScratchA2 pen x/y position
                    fcb       $34,$10,$8D,$0B,$35,$10,$20,$DF
*      bsr   PlotWithPen2      call plot_with_pen2()
*      bra   PlotWithPen       go again ...
*                      yes there is no rts here in the c source either


* Command $F9 Change pen size and style
*  read_pen_status() pic_render.c
*
*  PenStatus = pen_status
*
*  x contains pointer to given_pic_data known as the pic_byte
*  returns the next pic_byte in a

ReadPenStatus       lda       ,x+       get pic_byte
                    sta       PenStatus save as pen_status
                    lda       ,x+       return value ignored so this just bumps to next pic_byte
                    rts                 return to pic_cmd_loop


* plot_with_pen2()
* called from plot with pen
*  Sets up circle_ptr
*
*  PenStatus = pen_status
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  ScratchA2 = pen_x position
*  ScratchA3 = pen_y position
*  ScratchA4 = pen_final_x
*  ScratchA5 = pen_final_y
*  ScratchA7 = pen.size
*  ScratchA8 = t
*  ScratchA9 = pensize x 2
*  ScratchAA =  "
*  ScratchAB = scratch var
*  ScratchAC = scratch var
*  ScratchAD = penwidth
*  FillColorBl =  "

PlotWithPen2        ldb       PenStatus pen_status
                    andb      #$07      mask to get pen size bits 0-2
                    stb       ScratchA7 pen.size ?? save for pen_status & $07

                    clra                clear a and condition codes
                    lslb                multiply by 2
                    std       ScratchA9 pen size x 2
                    leau      CircleList,pcr circle_list[]
                    ldd       b,u       d now holds one of the circle_list values
                    leau      CircleData,pcr circle_data[]
                    leau      d,u       use that to index to a circle_data item
*                      u now is circle_ptr

*  Set up x position
                    clra                zero a for double-byte x calc
                    ldb       ScratchA2 load pen_x position
                    lslb                multiply by two
                    rola                carry high bit of b into a
                    subb      ScratchA7 subtract the pen.size
                    bcc       PenXOk    outcome not less than zero move on
                    deca                borrow from high byte
                    bpl       PenXOk    if we still have pos must be 0 or >
                    ldd       #0000     clamp to zero
                    bra       PenXFinal use clamped zero value
PenXOk              std       ScratchAB store pen_x at scratch

                    ldd       #$013E    start with 320
                    subd      ScratchA9 subtract 2 x pen.size
                    cmpd      ScratchAB pen_x to calc
                    bls       PenXFinal if pen_x is greater keep temp calc
                    ldd       ScratchAB otherwise use pen_x

PenXFinal           lsra                divide by 2
                    rorb                complete 16-bit right shift of d
                    stb       ScratchA2 stow at pen_x
                    stb       ScratchA4 stow at pen_final_x

*  Set up y position
                    lda       ScratchA3 pen_y
                    suba      ScratchA7 pen.size
                    bcc       PenYOk    >= 0 Ok go stow it
                    clra                otherwise less than zero so set it to 0
                    bra       PenYStore go stow it
PenYOk              sta       ScratchAB store pen_y at scratch

                    lda       #y_max    start with 167
                    suba      ScratchAA subtract 2 x pen.size
                    cmpa      ScratchAB compare to pen_y calced so far
                    bls       PenYStore if pen_y > calc use calc and save it
                    lda       ScratchAB otherwise use pen_y
PenYStore           sta       ScratchA3 pen_y
                    sta       ScratchA5 pen_final_y

                    lda       ScratchA6 texture_num
                    ora       #$01      ensure bit 0 set for t calculation
                    sta       ScratchA8 t ??

                    ldb       ScratchAA 2 x pen.size
                    incb                bump it by one
                    tfr       b,a       copy b into a
                    adda      ScratchA5 add value to pen_final_y
                    sta       ScratchA5 save new pen_final_y
                    lslb                shift b left (multiply by 2)

                    leax      BinaryList,pcr binary list[]
                    abx                 advance x to table entry at offset B
                    stx       ScratchAD pen width pointer

*   this looks like it should have been nested for loops
*   but not coded that way in pic_render.c

*  new y
PenYLoop            leax      BinaryList,pcr binary_list[]

*  new x
PenXLoop            lda       PenStatus pen_status
                    bita      #O_UPDATE and it with $10 but don't change
                    bne       PenStatusCheck not equal zero go on to next pen status test
                    ldd       ,u        otherwise  load data at circle_ptr
                    anda      ,x        and that with first element in binary_list
                    bne       PenStatusCheck if thats not zero go on to next pen status check

                    andb      $01,x     and the second bytes of data at circle_ptr
*                      and binary_list
                    beq       NextPenX  that outcome is equ zero head for next calcs

PenStatusCheck      lda       PenStatus pen_status
                    bita      #$20      anded with $20 but don't change
                    beq       PlotPoint equals zero set up and plot buffer
                    lda       ScratchA8 otherwise load t (texture_num | $01)
                    lsra                divide by 2
                    bcc       SaveTexture no remainder save that number as t
                    eora      #$b8      exclusive or t with $B8
SaveTexture         sta       ScratchA8 save new t
                    bita      #O_DRAWN  anded with 1 but don't change
                    bne       NextPenX  not equal zero don't plot
                    bita      #O_BLKIGNORE anded with 2 but don't change
                    beq       NextPenX  does equal zero don't plot

PlotPoint           pshs      u         save current u sbuff_plot uses it
                    ldd       ScratchA2 load pen_x/pen_y values
                    std       PosInitX  save at pos_init_x/y positions
                    lbsr      SbuffPlot head for sbuff_plot()
                    puls      u         retrieve u from before call

NextPenX            inc       ScratchA2 increment pen_x value

                    leax      $04,x     move four bytes in the binary_list
                    cmpx      ScratchAD comapre that value to pen_width
                    bls       PenXLoop  less or same go again

                    leau      $02,u     bump circle_ptr to next location in circle_data[]

                    lda       ScratchA4 load pen_final_x
                    sta       ScratchA2 store at pen_x
                    inc       ScratchA3 bump pen_y
                    lda       ScratchA3 pen_y
                    cmpa      ScratchA5 compare to pen_final_y
                    bne       PenYLoop  not equal go do the next row
                    rts                 all pen rows drawn return


* ====== Corner and Line Drawing Commands ($F4-$F7) ======
* Command $F5 Draw an X corner
* draw_x_corner()  pic_render.c
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y

DrawXCorner         lbsr      ReadXyPos call read_xy_pos
                    bcs       CmdReturn next subs rts
                    std       PosInitX  save pos_init_x/y positions
                    lbsr      SbuffPlot head for sbuff_plot()
                    bsr       DrawXEntry draw_corner(0)
                    rts                 corner drawn return


* Command $F4 Draw a Y corner
* draw_y_corner()  pic_render.c
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y

DrawYCorner         lbsr      ReadXyPos call read_xy_pos
                    bcs       CmdReturn return
                    std       PosInitX  save at pos_init_x/y positions
                    lbsr      SbuffPlot head for sbuff_plot()
                    bsr       DrawYEntry draw_corner(1)
CmdReturn           rts                 common return point for commands



* draw_corner(u8 type)  pic_render.c
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  PosFinalX = pos_final_x
*  PosFinalY = pos_final_y

draw_x
DrawXEntry          lbsr      GetXPos   get_x_pos()
                    bcs       CmdReturn prior subs return
                    sta       PosFinalX store as pos_final_x
                    ldb       PosInitY  load pos_init_y
                    stb       PosFinalY store as pos_final_y
                    lbsr      SbuffXLine call sbuff_xline()

draw_y
DrawYEntry          lbsr      GetYPos   get_y_pos
                    bcs       CmdReturn prior subs return
                    stb       PosFinalY save pos_final_y
                    lda       PosInitX  load pos_init_x
                    sta       PosFinalX save pos_final_x
                    lbsr      SbuffYLine sbuff_yline()
                    bra       DrawXEntry head for draw_x



* Command $F6 Absolute line
* absolute_line()
* This command is before Draw X corner in nagi source
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  PosFinalX = pos_final_x
*  PosFinalY = pos_final_y

AbsoluteLine        bsr       ReadXyPos call read_xy_pos
                    bcs       CmdReturn prior subs return
                    std       PosInitX  save at pos_init_x/y positions
                    lbsr      SbuffPlot head for sbuff_plot()
AbsLineLoop         bsr       ReadXyPos call read_xy_pos
                    bcs       CmdReturn prior subs return
                    std       PosFinalX save at pos_final_x/y and passed draw_line in d
                    lbsr      DrawLine  call draw_line()
                    bra       AbsLineLoop go again



* relative_line()
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  PosFinalX = pos_final_x
*  PosFinalY = pos_final_y

RelativeLine        bsr       ReadXyPos call read_xy_pos
                    bcs       CmdReturn prior subs return
                    std       PosInitX  save at pos_init_x/y positions
                    lbsr      SbuffPlot head for sbuff_plot()

* calc x
RelLineLoop         lda       ,x+       get next pic_byte
*                      and load it in pos_data in c source
                    cmpa      #cmd_start is that equal $F0 or greater
                    bcc       CmdReturn yep were done so return (we use prior subs return ??)
*                      that rascal in acca changes names again to x_step
*                      but it's still the same old data
                    anda      #$70      and that with $70
*                      (where these values are derived from I haven't a clue, as of yet :-))
                    lsra                divide by 2
                    lsra                and again
                    lsra                once more
                    lsra                and finally another for a /16
                    ldb       -$01,x    get the original value
                    bpl       XStepOk   if original value not negative move on
                    nega                else it was so flip the sign of the computed value
XStepOk             adda      PosInitX  add pos_init_x position
                    cmpa      #x_max    compare to 159
                    bls       StorePosX if it's less or same move on
                    lda       #x_max    else cap it at 159
StorePosX           sta       PosFinalX store as pos_final_x

* calc y
*                      not quite the same as pic_render.c almost
*                      we've go the pic_byte ... er pos_data ... now called y_step
*                      in b so lets calc the y_step
                    andb      #$0f      and with $0F (not in pic_render.c)
                    bitb      #$08      and that with $08 but don't change
                    beq       AddYStep  if result = 0 move on
                    andb      #$07      else and it with $07
                    negb                and negate it
AddYStep            addb      PosInitY  add calced value to pos_init_y
                    cmpb      #y_max    compare to 167
                    bls       StorePosY less or same move on
                    ldb       #y_max    greater ? cap it
StorePosY           stb       PosFinalY pos_final_y

*                      passes pos_final_x/y in d
                    lbsr      DrawLine  call draw_line()

                    bra       RelLineLoop go again exit is conditinals inside loop

* ====== PicFill ($F8) / ReadXyPos / GetXPos / GetYPos: Fill and Coordinate Helpers ======
* Command $F8 Fill
* pic_fill()
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y

PicFill             bsr       ReadXyPos call read_xy_pos
                    bcs       CmdReturn returned a 1 head for prior subs return
                    std       PosInitX  save at pos_init_x/y position
                    lbsr      SbuffPicFill call sbuff_picfill()
                    bra       PicFill   loop till we get a 1 back from read_xy_pos

* read_xy_pos()
ReadXyPos           lbsr      GetXPos   go get x position
                    lblo      CmdReturn prior subs return
                    lbsr      GetYPos   go get the y position
                    rts                 return with x/y in d


* get_x_pos()
GetXPos             lda       ,x+       load pic_byte
                    cmpa      #cmd_start is it a command?
                    bhs       RetSetCC  if so set CC
                    cmpa      #x_max    compare to 159
                    bls       RetClearCC is it less or same clear CC and return
                    lda       #x_max    greater than load acca with 159
RetClearCC          andcc     #$fe      clear CC ad return
                    rts                 return carry clear = valid coord


RetSetCC            orcc      #1        returns a "1"
                    rts                 return carry set = command byte seen

* get_y_pos()
GetYPos             ldb       ,x+       load pic_byte
                    cmpb      #cmd_start is it a command
                    blo       YPosClamp nope less than command
                    lda       -$01,x    was a command load x back in acca
                    bra       RetSetCC  go set CC
YPosClamp           cmpb      #y_max    compare to 167
                    bls       YPosOk    is it less or same clear CC and return
                    ldb       #y_max    greater than load accb with 167
YPosOk              andcc     #$fe      clear CC and return
                    rts                 return carry clear = valid y coord


* ====== DrawLine: Bresenham Line Rasterizer ======
* draw_line()  pic_render.c
* while this is a void function() seems pos_final_x/y are passed in d
*
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  PosFinalX = pos_final_x
*  PosFinalY = pos_final_y
*  ScratchA2 = x_count
*  ScratchA3 = y_count
*  ScratchA4 = pos_x
*  ScratchA5 = pos_y
*  ScratchA6 = line_x_inc
*  ScratchA7 = line_y_inc
*  ScratchA8 = x_component
*  ScratchA9 = y_component
*  ScratchAA = largest_line
*  ScratchAB = counter

*  process straight lines
DrawLine            cmpb      PosInitY  compare pos_final_y with pos_init_y
                    lbeq      SbuffXLine if equal call sbuff_xline() and don't return here
                    cmpa      PosInitX  else compare with pos_init_x position
                    lbeq      SbuffYLine if equal call sbuff_yline() and don't return here

                    ldd       PosInitX  load pos_init_x/y positions
                    std       ScratchA4 store at pen_final ??? not in pic_render.c version

*  process y
                    lda       #$01      line_y_inc

                    ldb       PosFinalY load pos_final_y
                    subb      PosInitY  subtract pos_init_y
                    bcc       StoreLineYInc greater or equal zero don't negate
*                      less than zero
                    nega                flip the sign of line_y_inc
                    negb                flip the sign of y_component

StoreLineYInc       sta       ScratchA7 store line_y_inc
                    stb       ScratchA9 store y_component

* process x
                    lda       #$01      line_x_inc

                    ldb       PosFinalX load pos_final_x
                    subb      PosInitX  subtract pos_init_x
                    bcc       StoreLineXInc greater or equal zero don't negate
*                      less than zero
                    nega                flip the sign of line_x_inc
                    negb                flip the sign of x_component
StoreLineXInc       sta       ScratchA6 store line_x_inc
                    stb       ScratchA8 store x_component

* compare x/y components
                    cmpb      ScratchA9 compare y_component to x_component
                    blo       YLarger   if x_component is smaller move on


*  x >= y
*                      x_component is in b
                    stb       ScratchAB counter
                    stb       ScratchAA largest_line
                    lsrb                divide by 2
                    stb       ScratchA3 store y_count
                    clra                make a zero
                    sta       ScratchA2 store x_count
                    bra       LineDrawLoop move on

*  x < y
YLarger             lda       ScratchA9 load y_component
                    sta       ScratchAB stow as counter
                    sta       ScratchAA stow as largest line
                    lsra                divide by 2
                    sta       ScratchA2 store x_count
                    clrb                make a zero
                    stb       ScratchA3 store as y_count


* loops through the line and uses sbuff_plot to do the screen write
*                      y_count is in b
LineDrawLoop        addb      ScratchA9 add in the y_component
                    stb       ScratchA3 and stow back as y_count
                    cmpb      ScratchAA compare that with line_largest
                    blo       XCountUpdate if y_count >= line_largest is not the case branch
                    subb      ScratchAA subtract line_largest
                    stb       ScratchA3 store as y_count
                    ldb       ScratchA5 load pos_y
                    addb      ScratchA7 add line_y_inc
                    stb       ScratchA5 stow as pos_y

*                      x_count is in a
XCountUpdate        adda      ScratchA8 add in x_component
                    sta       ScratchA2 store as x_count
                    cmpa      ScratchAA compare that with line_largest
                    blo       PlotNextPoint if x_count >= line_largest is not the case branch
                    suba      ScratchAA subtract line_longest
                    sta       ScratchA2 store at x_count
                    lda       ScratchA4 load pos_x
                    adda      ScratchA6 add line_x_inc
                    sta       ScratchA4 stow as pos_x

PlotNextPoint       ldd       ScratchA4 load computed pos_x/y
                    std       PosInitX  store at pos_init_x/y positions
                    lbsr      SbuffPlot head for sbuff_plot()
                    ldd       ScratchA2 reload x/y_count
                    dec       ScratchAB decrement counter
                    bne       LineDrawLoop if counter not zero go again
                    rts                 line fully drawn return

***********************************************************************


* ====== Screen Buffer Utilities: SbuffFill, SbuffXLine, SbuffYLine, SbuffPlot, SbuffPicFill ======
* sbuff_fill() sbuf_util.c
* fill color is passed in s register

SbuffFill           pshs      x         save x as we use it for an index
                    ldu       #gbuffend address to write to
                    ldx       #picb_size $6900 bytes to write (26.25K)
*                      this would be picture buffer width x height
                    ldd       $04,s     since we pushed x pull our color input out of the stack
FillLoop            std       ,--u      store them and dec dest address
                    leax      -$02,x    dec counter
                    bne       FillLoop  loop till done
                    puls      x         fetch the x
                    rts                 return


* sbuff_xline()  sbuff_util.c
* gets called here with pos_final_x/y in accd
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  PosFinalX = pos_final_x
*  PosFinalY = pos_final_y
*  ScratchAC = x_orig

SbuffXLine          sta       ScratchAC stow as x_orig
                    cmpa      PosInitX  compare with pos_init_x position
                    bhs       XLineStart if pos_final_x same or greater branch

*                      otherwise init >  final so swap init and final
                    ldb       PosInitX  load pos_init_x position
                    stb       PosFinalX save pos_final_x position
                    sta       PosInitX  save pos_init_x position

XLineStart          bsr       SbuffPlot head for sbuff_plot() returns pointer in u

                    ldb       PosFinalX load pos_final_x
                    subb      PosInitX  subtract pos_init_x position
                    beq       XLineDone if they are the same move on
*                      b now holds the loop counter len
*                      u is the pointer returned from sbuff_plot
                    leau      $01,u     bump the pointer one byte right
XLineLoop           lda       ,u        get the the byte
                    ora       DrawMask  or it with sbuff_drawmmask
                    anda      DrawColor and it with the color
                    sta       ,u+       save it back and bump u to next byte
                    decb                decrememnt the loop counter
                    bne       XLineLoop done them all? Nope loop

XLineDone           lda       ScratchAC x_orig (pos_final_x)
                    sta       PosInitX  save at pos_init_x position
                    rts                 horizontal line drawn return


* sbuff_yline() sbuf_util.c
* gets called here with pos_final_x/y in accd
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y
*  PosFinalX = pos_final_x
*  PosFinalY = pos_final_y
*  ScratchAC = y_orig

SbuffYLine          stb       ScratchAC stow as y_orig
                    cmpb      PosInitY  compare with pos_init_y
                    bhs       YLineStart if pos_final same or greater branch

*                           otherwise init > final so swap 'em
                    lda       PosInitY  load pos_init_y
                    sta       PosFinalY stow as pos_final_y
                    stb       PosInitY  stow as pos_init_y

YLineStart          bsr       SbuffPlot head for sbuff_plot() returns pointer in u
                    ldb       PosFinalY load pos_final_y
                    subb      PosInitY  subtract pos_init_y
                    beq       YLineDone if they are the same move on
*                           b now holds the loop counter len
*                           u is the pointer returned from sbuff_plot
YLineLoop           leau      PICBUFF_WIDTH,u bump ptr one line up
                    lda       ,u        get the byte
                    ora       DrawMask  or it with sbuff_drawmmask
                    anda      DrawColor and it with the color
                    sta       ,u        save it back out
                    decb                decrement the loop counter
                    bne       YLineLoop done them all ? Nope loop

YLineDone           ldb       ScratchAC load y_orig
                    stb       PosInitY  save it as pos_init_y
                    rts                 vertical line drawn return


* sbuff_plot()  from sbuf_util.c
* according to agi.h PBUF_MULT(width) ((( (width)<<2) + (width))<<5)
* which next 3 lines equate to so the $A0 is from 2 x 5
* pointer is returned in index reg u
*
*  DrawColor = color
*  DrawMask = sbuff_drawmask
*  PosInitX = pos_init_x
*  PosInitY = pos_init_y

SbuffPlot           ldb       PosInitY  load pos_init_y
                    lda       #$A0      according to PBUF_MULT()
                    mul                 do the math
                    addb      PosInitX  add pos_init_x position
                    adca      #0000     this adds the carry bit in to a
                    addd      #gfx_picbuff add that to the start of the screen buf $6040
                    tfr       d,u       move this into u
                    lda       ,u        get the byte u points to
                    ora       DrawMask  or it with sbuff_drawmask
                    anda      DrawColor and it with the color
                    sta       ,u        and stow it back at the same place
                    rts                 return




* sbuff_picfill(u8 ypos, u8 xpos) sbuf_util.c
* DrawColor = color
* DrawMask = sbuff_drawmask
* PosInitX = pos_init_x
* PosInitY = pos_init_y
* PosFinalX = left
* PosFinalY = right
* ScratchA2 = old_direction
* ScratchA3 = direction
* ScratchA4 = old_initx
* ScratchA5 = old_inity
* ScratchA6 = old_left
* ScratchA7 = old_right
* ScratchA8 = stack_left
* ScratchA9 = stack_right
* ScratchAA = toggle
* ScratchAB = old_toggle
* FillColorBl = color_bl
* MaskDl = mask_dl
* OldBuff = old_buff (word)
* TempBuff = temp (buff)


colorbl             set       $4F
temp_stk            set       $E000

SbuffPicFill        pshs      x         save x
                    ldx       #temp_stk load addr to create a new stack
                    sts       ,--x      store current stack pointer there and decrement x
                    tfr       x,s       make that the stack
*                           s is now stack_ptr pointing to fill_stack

                    ldb       PosInitY  pos_init_y
                    lda       #$a0      set up PBUF_MULT
                    mul                 do the math
                    addb      PosInitX  add pos_init_x
                    adca      #0000     add in that carry bit
                    addd      #gfx_picbuff add the start of screen buffer $6040
                    tfr       d,u       move this to u
*                           u now is pointer to screen buffer b


                    ldb       DrawColor load color
                    lda       DrawMask  load sbuff_drawmask

*                           next 2 lines must have been a if (sbuff_drawmask > 0)
*                           not in the nagi source

                    lbeq      SbuffPicFillRet if sbuff_drawmask = 0 we're done
                    bpl       TestColorNibble if not negative branch to test color

                    cmpa      #cmd_start comp $F0 with sbuff_drawmask
                    bne       TestColorNibble not = go test color for $0F
                    andb      #$f0      and color with $F0
                    cmpb      #$40      compare that to $40 (input was $4x)
                    lbeq      SbuffPicFillRet if so were done
                    lda       #$f0      set up value for mask_dl
                    bra       SaveMaskDl go save it

TestColorNibble     andb      #$0f      and color with $0F
                    cmpb      #$0f      was it already $0F
                    lbeq      SbuffPicFillRet if so we're done
                    lda       #$0f      set up value for mask_dl

SaveMaskDl          sta       MaskDl    stow as mask_dl
                    anda      #colorbl  and that with $4F
                    sta       FillColorBl stow that as color_bl
                    lda       ,u        get byte at screen buffer
                    anda      MaskDl    and with mask_dl
                    cmpa      FillColorBl compare to color_bl
                    lbne      SbuffPicFillRet not equal were done

                    ldd       #$FFFF    push 7 $FF bytes on temp stack
                    pshs      a,b       and set stack_ptr accordingly
                    pshs      a,b       push two more FF bytes
                    pshs      a,b       push two more FF bytes
                    pshs      a         push final FF byte (7 total)

                    lda       #$a1      load a with 161
                    sta       PosFinalX stow it at left
                    clra                make a zero
                    sta       PosFinalY stow it at right
                    sta       ScratchAA stow it at toggle
                    inca                now we want a 1
                    sta       ScratchA3 stow it at direction

* fill a new line
FillNewLine         ldd       PosFinalX load left/right
                    std       ScratchA6 stow at old_left/right
                    lda       ScratchAA load toggle
                    sta       ScratchAB stow at old_toggle
                    ldb       PosInitX  load pos_init_x
                    stb       ScratchA4 store as old_initx
                    incb                accb now becomes counter
                    stu       OldBuff   stow current screen byte as old_buff

FillLeftLoop        lda       ,u        get the screen byte pointed to by u
                    ora       DrawMask  or it with sbuff_drawmmask
                    anda      DrawColor and that with the color
                    sta       ,u        stow that back
                    lda       ,-u       get the screen byte befor that one
                    anda      MaskDl    and that with mask_dl
                    cmpa      FillColorBl compare result with color_bl
                    bne       FillAdvance not equal move on
                    decb                otherwise decrement the counter
                    bne       FillLeftLoop if were not at zero go again

FillAdvance         leau      1,u       since cranked to zero bump the screen pointer by one
                    tfr       u,d       move that into d
                    subd      OldBuff   subtract old_buff
                    addb      PosInitX  add pos_init_x
                    stb       PosFinalX stow at left
                    lda       PosInitX  load pos_init_x
                    stb       PosInitX  store left at pos_init_x
                    stu       TempBuff  temp buff
                    ldu       OldBuff   load  old_buff
                    leau      1,u       bump to the next byte
                    nega                negate pos_init_x value
                    adda      #x_max    add that to 159 (subtract pos_init_x)
                    beq       ComputeRight that's the new counter and if zero move on

FillRightLoop       ldb       ,u        get that screen byte (color_old)
                    andb      MaskDl    and it with mask_dl
                    cmpb      FillColorBl check against color_bl
                    bne       ComputeRight not equal move on
                    ldb       ,u        load that byte again to do something with
                    orb       DrawMask  or it with sbuff_drawmmask
                    andb      DrawColor and it with color
                    stb       ,u+       stow it back and bump the pointer
                    deca                decrement the counter
                    bne       FillRightLoop if we haven't hit zero go again

ComputeRight        tfr       u,d       move the screen buff ptr to d
                    subd      TempBuff  subtract that saved old pointer
                    decb                sunbtract a 1
                    addb      PosFinalX add in the left
                    stb       PosFinalY store as the right
                    lda       ScratchA6 load old_left
                    cmpa      #$a1      compare to 161
                    beq       FillNextScan if it is move on

                    cmpb      ScratchA7 if the new right == old right
                    beq       EqualRightCheck then move on
                    bhi       UpdateOldRight not equal and right > old_right
*                           otherwise
                    stb       ScratchA4 stow right as old_initx
                    clr       ScratchAA clear toggle
                    bra       PushFillState head for next calc
*                           they were equal
EqualRightCheck     lda       PosFinalX load a with left
                    cmpa      ScratchA6 compare that to old_left
                    bne       UpdateOldRight move on
                    lda       #$01      set up a one
                    cmpa      ScratchAA compare toggle
                    beq       FillNextScan is a one ? go to locnext
                    sta       ScratchAA not one ? set it to 1
                    lda       PosFinalY load right
                    sta       ScratchA4 stow it as old_initx
                    bra       PushFillState head for the next calc
*                           right > old_right or left > old left
UpdateOldRight      clr       ScratchAA clear toggle
                    lda       ScratchA7 load old right
                    sta       ScratchA4 save as old_initx

*         push a bunch on our temp stack
PushFillState       ldy       ScratchA2 old_direction/direction
                    ldx       ScratchA4 old_initx/y
                    ldu       ScratchA6 old_left/right
                    lda       ScratchAB old_toggle
                    pshs      a,x,y,u   push them on the stack

locnext
FillNextScan        lda       ScratchA3 load direction
                    sta       ScratchA2 stow as old_direction
                    ldb       PosInitY  load pos_init_y
                    stb       ScratchA5 stow as old_inity

FillAdvanceDir      addb      ScratchA3 add direction to pos_init_y
                    stb       PosInitY  stow the updated pos_init_y
                    cmpb      #y_max    compare that to 167
                    bhi       FillTestDir greater than 167 go test direction

FillCalcAddr        ldb       PosInitY  load pos_init_y
                    lda       #$A0      according to PBUF_MULT
                    mul                 do the math
                    addb      PosInitX  add pos_init_x position
                    adca      #0000     this adds the carry bit into the answer
                    addd      #gfx_picbuff add that to the screen buff start addr $6040
                    tfr       d,u       move it into u
                    lda       ,u        get the byte pointed to
                    anda      MaskDl    and with mask_dl
                    cmpa      FillColorBl compare with color_bl
                    lbeq      FillNewLine if equal go fill a new line

                    lda       PosInitX  load pos_init_x
                    ldb       ScratchA3 load direction
                    cmpb      ScratchA2 compare to old_direction
                    beq       FillCheckRight go comapre pos_init_x and right
                    tst       ScratchAA test toggle
                    bne       FillCheckRight not zero go comapre pos_init_x and right
                    cmpa      ScratchA8 compare pos_init_x and stack_left
                    blo       FillCheckRight less than stack_left go comapre pos_init_x and right
                    cmpa      ScratchA9 compare it to stack_right
                    bhi       FillCheckRight greater than go comapre pos_init_x and right
                    lda       ScratchA9 load stack_right
                    cmpa      PosFinalY compare to right
                    bhs       FillTestDir greater or equal go check direction
                    inca                add one to stack_right
                    sta       PosInitX  stow as pos_init_x

FillCheckRight      cmpa      PosFinalY compare updated value to right
                    bhs       FillTestDir go check directions
                    inca                less than then increment by 1
                    sta       PosInitX  stow updated value pos_init_x
                    bra       FillCalcAddr loop for next byte

* test direction and toggle
FillTestDir         lda       ScratchA3 load direction
                    cmpa      ScratchA2 compare old_direction
                    bne       FillPopStack not equal go pull stacked values
                    tst       ScratchAA test toggle
                    bne       FillPopStack not zero go pull stack values
                    nega                negate direction
                    sta       ScratchA3 store back at direction
                    lda       PosFinalX load left
                    sta       PosInitX  stow as pos_init_x
                    ldb       ScratchA5 load old_inity
                    stb       PosInitY  stow at pos_init_y
                    bra       FillGetStackLR go grab off stack and move on

* directions not equal
FillPopStack        puls      a,x,y,u   grab the stuff off the stack
                    cmpa      #$FF      test toggle for $FF source has test of pos_init_y
                    beq       SbuffPicFillRet equal ? clean up stack and return
                    sty       ScratchA2 stow old_direction/direction
                    stx       PosInitX  stow pos_init_x/y
                    stu       PosFinalX stow left/right
                    sta       ScratchAA stow toggle

                    ldb       PosInitY  load pos_init_y
                    stb       ScratchA5 stow old_inity
FillGetStackLR      ldx       $05,s     gets left right  off stack
                    stx       ScratchA8 stow stack_left/right
                    bra       FillAdvanceDir always loop

SbuffPicFillRet     lds       ,s        reset stack
                    puls      x         retrieve our x
                    rts                 return


* ====== PicBufUpdateRemap: Nibble-Swap Pixel Buffer for CoCo3 Display ======
* this routine effective swaps postion of
* the two nibbles of the byte loaded
* and returns it to the screen
* it is the workhorse loop in gfx_picbuff_update gfx.c ???
* called via remap call in mnln

gfx_picbuff_update_remap
PicBufUpdateRemap   ldx       #gfx_picbuff starting low address of srceen mem
NibbleSwapLoop      lda       ,x        get the first byte  bit order 0,1,2,3,4,5,6,7
                    clrb                empty b
                    lsra                shift one bit from a
                    rorb                into b
                    lsra                shift second bit from a
                    rorb                rotate into b
                    lsra                and again
                    rorb                rotate into b
                    lsra                and finally once more
                    rorb                nibble swap complete in b
                    stb       ,x        were changing x anyway so use it for temp storage
                    ora       ,x        or that with acca so now bit order from orig
*                        is 4,5,6,7,0,1,2,3
                    sta       ,x+       put it back at x and go for the next one
                    cmpx      #gbuffend ending high address of screen mem
                    bcs       NibbleSwapLoop loop until entire buffer remapped
                    rts                 buffer remap complete return

*  our blit_struct is a bit different from the one in nagi
*
* struct blit_struct
* {
*	struct blit_struct *prev;	// 0-1
*	struct blit_struct *next;	// 2-3
*	struct view_struct *v;		// 4-5
*	s8 x;                       // 6
*	s8 y;                       // 7
*	s8 x_size;                  // 8
*	s8 y_size;                  // 9
*	u16 *buffer;                // A-B
*   u16 *view_data              // C-D info for mmu twiddler
*
* };


* ====== Blit List Operations: BlitListErase / BlitListDraw ======
* blitlist_draw(BLIT *b) obj_base.c
BlitListErase       leas      -$02,s    make room on the stack
                    ldx       $04,s     get the blit_struct pointer
                    ldu       $02,x     load u with pointer to next blit

BlitListEraseLoop   stu       ,s        stow it on the stack
                    beq       BlitListEraseDone if it's zero we're done
                    pshs      u         push the pointer on the stack
                    lbsr      BlitSave  call blit_save()
                    leas      $02,s     get the pointer back in s
                    ldu       ,s        put it in u
                    ldu       $04,u     get the pointer to view_struct
                    pshs      u         push that on the stack and
                    lbsr      ObjBlit   call obj_blit()
                    leas      $02,s     get the pointer back in s
                    ldu       ,s        put it in u
                    ldu       $02,u     get the pointer to the next one
                    bra       BlitListEraseLoop and go again

BlitListEraseDone   leas      $02,s     clean up stack and leave
                    rts                 blit list erase done return

* blitlist_erase(BLIT *b) obj_base.c
* nagi has a return blitlist_free at the end

BlitListDraw        leas      -$02,s    make room on the stack
                    ldx       $04,s     get the blit_struct pointer
                    ldu       ,x        load u with the prev pointer
                    beq       BlitListDrawDone if it's zero we're done
BlitListDrawLoop    stu       ,s        stow it on the stack
                    pshs      u         push the pointer
                    lbsr      BlitRestore call blit_restore()
                    leas      $02,s     get the pointer back in s
                    ldx       ,s        load x with the pointer
                    ldu       ,x        get the prev from that struct
                    bne       BlitListDrawLoop loop again

BlitListDrawDone    leas      $02,s     clean up stack and leave
                    rts                 blit list draw done return

* ====== Priority Table and TableInit: Object Priority Zone Data ======
* From obj_picbuff.c the pri_table[172]
* ours is only 168
pri_table
PriTableBase

* loops thru 48 bytes with a = 4
* bumps a by one load b with 12 this
* iterates thru ten sets of twelve bytes
* bumping acca by one as it goes.

* table_init()   obj_pic_buff.c
TableInit

                    fcb       $B6,$05,$EE lda $05EE (priority table address)
                    fcb       $81,$FF   cmpa #$FF
                    fcb       $26,$15   bne +21
                    fcb       $8E,$05,$EE ldx #$05EE (set x to table address)
                    ldb       #$30      load index 48
                    lda       #4        load acca = 4
TableInitLoop       sta       ,x+       save a in buffer
                    decb                dec the inner loop counter
                    bne       TableInitLoop go again if loop not finished
                    cmpa      #$0e      get here when inner loop is done
                    bcc       TableInitDone did we do 10 loops (e-4)
                    inca                nope bump data byte
                    ldb       #$0c      set new counter on loops 2-10
*                       to do 12 bytes and
                    bra       TableInitLoop have at it again
TableInitDone       rts                 priority table initialized return


* ====== ObjChkControl: Check Object Contacts with Priority Zones ======
* obj_chk_control(VIEW *x)  obj_picbuff.c
* our index reg x points to the view structure
* are 3 = x, 4 = y instead of 3-4 = x & 5-6 = y ???

* This routine is passed a pointer to a view_structure
* from agi.h in the nagi source
* struct view_struct
*{
*	u8 step_time;		// 0
*	u8 step_count;		// 1	// counts down until the next step
*	u8 num;				// 2

*	     s16 x;	        // 3-4  in nagi
*	     s16 y;         // 5-6  in nagi


*   u8 x;               // 3 in ours
*   u8 y:               // 4 the rest of the offsets hold true
*   u8 dummy1           // 5 who knows what these are
*   u8 dummy2           // 6 maybe just fillers


*	u8 view_cur;		// 7
*	u8 *view_data;		// 8-9
*
*	u8 loop_cur; 		// A
*	u8 loop_total;		// B
*	u8 *loop_data;		// C-D
*
*	u8 cel_cur;			// E
*	u8 cel_total;		// F
*	u8 *cel_data; 		// 10-11
*	u8 cel_prev_width;	// new ones added to prevent kq4 crashing
*	u8 cel_prev_height;
*	//u8 *cel_data_prev;// 12-13
*	BLIT *blit;			// 14-15
*
*	s16 x_prev;			// 16-17
*	s16 y_prev;			// 18-19
*	s16 x_size;			// 1A-1B
*	s16 y_size;			// 1C-1D
*	u8 step_size;		// 1E
*	u8 cycle_time; 		// 1F
*	u8 cycle_count;		// 20	// counts down till next cycle
*	u8 direction;		// 21
*	u8 motion;			// 22
*	u8 cycle;			// 23
*	u8 priority;		// 24
*	u16 flags;			// 25-26
*
*	//u8 unknown27;		// 27	// these variables depend on the motion
*	//u8 unknown28;		// 28	// type set by follow ego, move, obj.. stuff
*	//u8 unknown29;		// 29	// like that
*	//u8 unknown2A;		// 2A
*
*	union
*	{
*		struct	// move_ego move_obj
*		{
*			s16 x;			// 27
*			s16 y;			// 28
*			u8 step_size;	// 29	// original stepsize
*			u8 flag;		// 2A
*		} move;
*
*		struct	// follow_ego
*		{
*			u8 step_size;	// 27
*			u8 flag;		// 28
*			u8 count;		// 29
*		} follow;
*
*		// wander
*		u8 wander_count;	// 27
*
*		// reverse or end of loop
*		u8 loop_flag;		// 27
*	};
*};
*typedef struct view_struct VIEW;


*  ScratchA5 = flag_signal
*  ScratchA6 = flag_water
*  FlagControl = flag_control
*
*  StateFlag is location of state.flag
*  see agi.h for definition of state structure
ObjChkControl       pshs      y         save y

                    ldx       $04,s     sets up mmu info
                    ldd       $08,x     load view_data passed to mmu twiddler
                    lbsr      TwiddleMmu twiddle mmu

                    ldb       $04,x     load y
                    lda       $26,x     load flags
                    bita      #O_PRIFIXED and with $04 but don't change
                    bne       SkipPriCalc not zero move on
*                         it is zero then
                    fcb       $ce,$05,$ee load buffer address
*      leau  PriTableBase,pcr    load buffer address
                    clra                clear a since we will use d as an index
                    lda       d,u       fetch the data from pri_table
                    sta       $24,x     save as priority

SkipPriCalc         lda       #$A0      set up PBUF_MULT()
                    mul                 do the math
                    addb      $03,x     add in x
                    adca      #0000     add in the carry bit
                    addd      #gfx_picbuff add it to the start of the screen buff addr 6040
                    tfr       d,u       move the pointer pb to u

                    ldy       $10,x     load y with cel_data ptr
                    clra                make a zero
                    sta       ScratchA6 stow it at flag_water
                    sta       ScratchA5 stow it at flag_signal
                    inca                make a 1
                    sta       FlagControl stow it at flag_contro1
                    ldb       $24,x     load priority
                    cmpb      #$0F      compare it with 15
                    beq       CheckFinish If it equals 15 move on
*                         otherwise if not equal 15
                    sta       ScratchA6 stow that 1 at flag_water
                    ldb       ,y        cx  first byte of cel_data  (cel_width)

*  do while cx != 0

PriLoop             lda       ,u+       (pri) put byte at pb in acca and bump pointer
                    anda      #$F0      and that with $F0  (obstacle ??)
                    beq       ClearFlagControl if it equals 0 set flag_control =0 and check_finish

                    cmpa      #$30      compare pri to 48 (water ??)
                    beq       PriLoopNext not equal  move to end of loop
                    clr       ScratchA6 clear the water flag
                    cmpa      #$10      compare it with 16 (conditional ??)
                    beq       TestObserveBlocks if equal go test for observe blocks
                    cmpa      #$20      compare with 32
                    beq       StoreFlagSignal pri=$20 signal this object

PriLoopNext         decb                decrement cx
                    bne       PriLoop   not zero yet loop again

                    lda       $25,x     load flags in  acca
                    tst       ScratchA6 test flag_water
                    bne       TestHrznIgnore not zero next test
                    bita      #O_DRAWN  should be O_WATER Looks like a BUG in ours
                    beq       CheckFinish if it equals one head for check_finish
                    bra       ClearFlagControl clear that flag control first and leave
TestHrznIgnore      bita      #O_HRZNIGNORE should be O_LAND  Looks like a BUG in ours
                    beq       CheckFinish horizon-ignore clear go check finish

ClearFlagControl    clr       FlagControl clear flag_control
                    bra       CheckFinish head for check_finish

TestObserveBlocks   lda       $26,x     load flags in acca
                    bita      #O_BLKIGNORE and with $02 but don't change
                    beq       ClearFlagControl equals zero clear flag_control and go check_finish
                    bra       PriLoopNext then  head back in the loop

StoreFlagSignal     sta       ScratchA5 store acca at flag signal (obj_picbuff.c has =1)
                    bra       PriLoopNext continue with loop



CheckFinish         lda       $02,x     load num
                    bne       ObjChkDone if not zero were done head out

* flag signal test
                    lda       ScratchA5 load flag_signal
*                         operates on F03_EGOSIGNAL
                    beq       ResetSignalFlag if its zero go reset the signal
*                         otherwise set the flag
                    lda       StateFlag load the state.flag element
                    ora       #$10      set the bits
                    sta       StateFlag save it back
                    bra       TestWaterFlag go test the water flag
ResetSignalFlag     lda       StateFlag load the state.flag element
                    anda      #$ef      reset the bits
                    sta       StateFlag save it back

* flag_water test
TestWaterFlag       lda       ScratchA6 load flag_water
                    beq       ResetWaterFlag if zero go reset the flag
*                         otherwise set it
                    lda       StateFlag load the state.flag element
                    ora       #$80      set the bits
                    sta       StateFlag save it back
                    bra       ObjChkDone baby we're out of here
ResetWaterFlag      lda       StateFlag load the state.flag element
                    anda      #$7f      reset the bits
                    sta       StateFlag save it back

ObjChkDone          puls      y         retrieve our y and leave
                    rts                 object control check done return


* ====== ObjBlit: Render Object Cel to Screen Buffer ======
*  obj_blit(VIEW *v)   obj_blit.c
*  our index reg x points to the view structure
*  are 3 = x, 4 = y instead of 3-4 = x & 5-6 = y ???
*  ScratchA2 = cel_height
*  ScratchA7 = cel_trans
*  ScratchA8 = init (pb)
*  ScratchAC = cel_invis
*  ScratchAD = pb_pri
*  PosInitX = view_pri
*  PosInitY = col

ObjBlit             ldx       $02,s     pull our x pointer off the stack
                    ldd       $08,x     load d with view_data
                    lbsr      TwiddleMmu twiddle mmu

                    ldu       $10,x     u now is a pointer to cel_data
                    lda       $02,u     cel_data[$02] loaded
                    bita      #O_Block  are we testing against a block or does $80 mean something else here?
                    beq       ProcessCelData if zero skip next instruction

                    lbsr      ObjCelMirror otherwise call obj_cell_mirror

ProcessCelData      ldd       ,u++      load the first 2 bytes of cel_data and bump to next word
*                        cel_width is in acca we ignore
                    stb       ScratchA2 save as cel_height
*                        obj_blit.c has and $0F which is a divide by 16
*                        we do a multiply x 16 ???
                    lda       ,u+       cel_trans
                    asla                shift trans color left 4 bits
                    asla                shift trans color left step 2
                    asla                shift trans color left step 3
                    asla                now in upper nibble
                    sta       ScratchA7 save as cel_tran

                    lda       $24,x     priority
                    asla                shift left 4
                    asla                priority to upper nibble step 2
                    asla                priority to upper nibble step 3
                    asla                priority now in upper nibble
                    sta       PosInitX  view_pri

                    ldb       $04,x     load the y value
                    subb      ScratchA2 subtract the cel_height
                    incb                add 1
                    lda       #$a0      set up PBUF_MULT()
                    mul                 do the math
                    addb      $03,x     add in the x value
                    adca      #0000     add in the carry from multiply
                    addd      #gfx_picbuff add this to the start of the screen buff addr $6040
                    std       ScratchA8 pb pointer to the pic buffer
                    ldx       ScratchA8 load it in an index reg

                    lda       #$01      set cel_invis flag initially
                    sta       ScratchAC set cel_invis to 1 and save

                    bra       ChunkLoop start processing cel chunk data
BumpPbPtr           abx                 bump the pb pointer

ChunkLoop           lda       ,u+       get the next "chunk"
                    beq       NextCelRow if zero
                    ldb       -$01,u    not zero load the same byte in accb
                    anda      #$f0      and chunk with $F0 (col)
                    andb      #$0f      and chunk with $0F (chunk_len)
                    cmpa      ScratchA7 compare with cel_trans
                    beq       BumpPbPtr set up and go again color is trasnparent
                    lsra                shift right 4
                    lsra                extract color nibble step 2
                    lsra                extract color nibble step 3
                    lsra                color now in lower nibble
                    sta       PosInitY  save the color

ChunkInnerLoop      lda       ,x        get the byte pointed to by pb
                    anda      #$f0      get the priority portion
                    cmpa      #$20      compare to $20
                    bls       SavePbPri less or equal
                    cmpa      PosInitX  compare to view_pri
                    bhi       SkipChunkPixel pb_pri > view_pri
*                        otherwise
                    lda       PosInitX  load view_pri
StoreChunkColor     ora       PosInitY  or it with col
                    sta       ,x+       store that at pb and bump the pointer
                    clr       ScratchAC zero cel_invis
                    decb                decrement chunk_len
                    bne       ChunkInnerLoop not equal zero go again inner loop
                    bra       ChunkLoop go again outer loop

NextCelRow          dec       ScratchA2 decrement cel_height
                    beq       CelDone   equal zero move on out of cel_height loop
                    ldx       ScratchA8 load init
                    leax      >PICBUFF_WIDTH,x move 160 into screen
                    stx       ScratchA8 stow that back as init/pb
                    bra       ChunkLoop go again

SavePbPri           stx       ScratchAD save the pointer
                    clra                set up ch

SearchPriLoop       cmpx      #blit_end compare to gfx_picbuff+$6860
                    bhs       GotPriority not less than then branch out
*                             less than the end
                    leax      >PICBUFF_WIDTH,x bump the pointer by 160
                    lda       ,x        get that byte
                    anda      #$f0      and it with $F0
                    cmpa      #$20      test against $20
                    bls       SearchPriLoop less or equal go again

GotPriority         ldx       ScratchAD load pb_pri
                    cmpa      PosInitX  compare with view_pri
                    bhi       SkipChunkPixel pb_pri > view_pri
                    lda       ,x        make the next
                    anda      #$f0      pb_pri
                    bra       StoreChunkColor go or it with the color

SkipChunkPixel      leax      $01,x     bump the pb pointer
                    decb                decrement chunk_len
                    bne       ChunkInnerLoop not equal do middle loop again
                    bra       ChunkLoop go again

CelDone             ldx       $02,s     pull our view pointer back off the stack
                    lda       $02,x     get the num
                    bne       ObjBlitDone if not zero exit routine
                    lda       ScratchAC get the cel_invis value
                    beq       ResetInvisFlag reset the flag

* set the flag
                    lda       StateFlag load the state.flag
                    ora       #$40      set it
                    sta       StateFlag stow it back
                    bra       ObjBlitDone exit routine

* reset the flag
ResetInvisFlag      lda       StateFlag load state.flag
                    anda      #$bf      clear it
                    sta       StateFlag stow it
ObjBlitDone         rts                 object blit complete return


* ====== ObjCelMirror: Mirror a Cel Horizontally ======
* obj_cel_mirror(View *v) in obj_picbuff.c
* we use different values from those shown nagi files
* on entry
*    a contains cell_data[$02] in call from obj_blit()
*    x contains pointer to view data
*    u contains pointer to cel_data
*
*    saves and restores x,y,u regs on exit
*
*  PosFinalY = width
*  ScratchA2 = height_count
*  ScratchA7 = trans transparent color left shifted 4
*  ScratchAA = tran_size ??
*  ScratchAB = meat_size
*  MaskDl = loop_cur << 4
*  OldBuff = al


ObjCelMirror        anda      #$30      and that with $30  (nagi has $70)
                    lsra                shift right 4
                    lsra                extract mirror type bits step 2
                    lsra                extract mirror type bits step 3
                    lsra                mirror type now in lower nibble
                    cmpa      $0A,x     compare that with loop_cur
                    lbeq      ObjCelMirrorDone if equal we're done

                    pshs      x,y,u     save our view (x) what ever (y) and cel_data (u) pointers

                    lda       $0A,x     load loop_cur
                    asla                and shift it 4 left
                    asla                loop_cur to upper nibble step 2
                    asla                loop_cur to upper nibble step 3
                    asla                loop_cur now in upper nibble
                    sta       MaskDl    stow it as ??
                    lda       #$cf      load a with with $CF  (nagi has $8F)
                    anda      $02,u     and that with cel[2]
                    ora       MaskDl    or with loop_cur<<4
                    sta       $02,u     stow it back at cel[2]

                    ldy       #gbuffend point y to temp mirror buffer

                    ldd       ,u++      load d with width and hieght
                    std       PosFinalY stow that
                    lda       ,u+       load a with trans color
                    asla                and shift left 4
                    asla                trans color to upper nibble step 2
                    asla                trans color to upper nibble step 3
                    asla                trans color now in upper nibble
                    sta       ScratchA7 stow as trans
                    stu       OldBuff   stow u as al
MirrorRowLoop       clrb                make a zero
                    stb       ScratchAB stow it as meat_size

*                      nagi code has tran_size set to width and
*                      al&$0F subtracted from it.
*                      in this loop

ScanTransLoop       stb       ScratchAA and tran_size

                    lda       ,u+       load in the next cel_data byte
                    beq       MirrorEndOfRow if its a zero leave loop
                    ldb       -$01,u    otherwise fetch the same data into b
*                      at this point a & b both have the same data byte
                    anda      #$f0      and the a copy with $F0
                    andb      #$0f      and the b copy with $0F
                    cmpa      ScratchA7 compare byte&$F0 with trans
                    bne       MirrorNonTrans not equal branch out of loop
                    addb      ScratchAA otherwise add in tran_size
                    bra       ScanTransLoop and loop

MirrorNextByte      ldb       ,u+       load the nbext byte and bump the pointer
                    beq       MirrorRemaining if it was zero move on
                    andb      #$0f      otherwise and it with $0F
MirrorNonTrans      addb      ScratchAA add in tran_size
                    stb       ScratchAA save it as tran_size
                    inc       ScratchAB bump meat_size
                    bra       MirrorNextByte loop to the next byte

MirrorRemaining     lda       ScratchAA load tran_size
                    nega                negate it
                    adda      PosFinalY add in the width
                    beq       MirrorReverseCopy if that is zero move on

MirrorFillTrans     suba      #$0f      subtract 15 from it
                    bls       MirrorLastTrans less or same move on
                    sta       ScratchAA otherwise stow that back as tran_size
                    lda       ScratchA7 fetch trans
                    ora       #$0f      or it with 15
                    sta       ,y+       store it at buff (gbuffend) and bump pointer
                    lda       ScratchAA fetch tra_size
                    bra       MirrorFillTrans loop again

MirrorLastTrans     adda      #$0f      add 15 back into a (tran_size)
                    ora       ScratchA7 or that with trans
                    sta       ,y+       stow that at buff and bump the pointer

MirrorReverseCopy   leax      -$01,u    set x to the last cel_data byte processed
                    ldb       ScratchAB load b with the meat_size (the loop counter)
MirrorCopyLoop      lda       ,-x       copy from the cel_data end
                    sta       ,y+       to the buff front
                    decb                dec the counter
                    bne       MirrorCopyLoop not done loop again

MirrorEndOfRow      stb       ,y+       on entry b should always = 0 stow that at the next buff location
                    dec       ScratchA2 decrement the height_count
                    bne       MirrorRowLoop not zero go again

* now we are going to copy the backward temp buffer back to the cel
                    tfr       y,d       get the buff pointer in d
                    subd      #gbuffend subtract the starting value of the buffer
                    stb       TempBuff  save that as the buffer size
                    andb      #$fe      make it an even number
                    tfr       d,x       transfer that to x
                    ldu       OldBuff   al cel_data pointer
                    ldy       #gbuffend load y start of our temp buffer

MirrorWriteBack     ldd       ,y++      get a word
                    std       ,u++      stow a word
                    leax      -$02,x    dec the counter by a word
                    bne       MirrorWriteBack not zero go again
*                      so we've moved an even number of bytes
                    lda       TempBuff  load the actual byte count
                    lsra                divide by 2
                    bcc       MirrorDone no remainder (not odd) we're done
                    lda       ,y        otherwise move the last
                    sta       ,u        byte
MirrorDone          puls      x,y,u     retrieve our x,y,u values

ObjCelMirrorDone    rts                 and return to caller



* ====== ObjAddPicPri: Stamp Object Priority Box Onto Screen Buffer ======
* obj_add_pic_pri(VIEW *v)  obj_picbuff.c
* our index reg x points to the view structure
*
*  PosInitX = priority&$F0
*  ScratchA3 = pri_table[y]
*  ScratchA4 = pri_table[y]
*  ScratchA8 = pb (word)
*  ScratchA9 = "
*  PriHeight = pri_height/height

ObjAddPicPri        pshs      y         save the y
                    ldx       $04,s     get the the pointer to our view
                    ldd       $08,x     load d with view_data ?
                    lbsr      TwiddleMmu twiddle mmu

*                      set up d as pointer to pri_table value
                    clra                zero a
                    ldb       $04,x     load view y value
                    fcb       $CE,$05,$EE load pri_table address
*      leau  PriTableBase,pcr    load pri_table address
                    lda       d,u       fetch the pri_table y data
                    std       ScratchA3 stow it in a temp
                    ldb       $24,x     load priority
                    andb      #$0f      and that with $0F
                    bne       SkipPriAdjust if that equals zero move on
                    ora       $24,x     otherwise or the pri_table[y] with priority
                    sta       $24,x     stow that back as priority

SkipPriAdjust       pshs      x         push the pointer to the view on the stack
                    lbsr      ObjBlit   call obj_blit()
                    leas      $02,s     reset the stack
                    ldx       $04,s     get the pointer to our view
                    lda       $24,x     load priority
                    cmpa      #$3F      compare to $3F
                    lbhi      ObjAddPicPriDone if greater then nothing to do head out

                    fcb       $CE,$05,$EE load pri_table address
*      leau  PriTableBase,pcr    load pri_table address
                    ldb       ScratchA4 fetch pri_table[y] (cx)
                    clr       PriHeight clear pri_height
PriHeightLoop       clra                zero acca
                    inc       PriHeight bump pri_hieght
                    tstb                is pri_table[y]
                    beq       CalcPbPtr equal zero if so move on
                    decb                dec our counter cx
                    lda       d,u       load pri_table[cx]
                    cmpa      ScratchA3 compare to pri_table[y]
                    beq       PriHeightLoop if they are equal loop again

* set up and execute PBUF_MULT call
CalcPbPtr           ldb       $04,x     load the view->y in
                    lda       #$a0      from pbuf mult
                    mul                 do the math
                    addb      $03,x     add in the x value
                    adca      #0000     add in the carry
                    addd      #gfx_picbuff add in the base address $6040
                    tfr       d,u       move that to an index reg (pb)
                    stu       ScratchA8 stow it as pb

                    ldy       $10,x     load y with cel_data pointer
                    ldb       $01,y     get the second byte (height)
                    cmpb      PriHeight compare to pri_height
                    bhi       SetupPriNibble greater move on
                    stb       PriHeight otherwise save the largest as pri_height
SetupPriNibble      lda       $24,x     load the priority again
                    anda      #$f0      and it with $F0
                    sta       PosInitX  stow that for later use

* bottom line
                    ldb       ,y        load b with the first byte in cel_data (cx)
BottomLineLoop      lda       ,u        get the byte at our pic buff pb
                    anda      #$0f      and it with $0F
                    ora       PosInitX  or it with priority&F0
                    sta       ,u+       stow it back and bump the pointer
                    decb                dec the loop counter cx
                    bne       BottomLineLoop not zero go again

* it has a height
                    dec       PriHeight test "height" for > 1
                    beq       ObjAddPicPriDone wasn't head no more to do so head out
                    ldu       ScratchA8 reset u to our pb pic buff pointer

* the sides
                    ldb       ,y        get the first byte of cel_data
                    decb                subtract 1 (sideoff)
SidesLoop           leau      -$A0,u    decrement pb by 160
                    tfr       u,x       move that value into x
                    lda       ,u        get the data
                    anda      #$0f      and it with $0F
                    ora       PosInitX  or it priority&$F0
                    sta       ,u        stow it back
                    clra                zero a so we can use d as a pointer
                    lda       d,u       use "sideoff" as an index into pb
                    anda      #$0f      and that with $0F
                    ora       PosInitX  or that rascal with priority&$F0
                    abx                 add that value to our x pointer
                    sta       ,x        and store it there
                    dec       PriHeight dec the height
                    bne       SidesLoop greater than zero go again

* the top of the box

                    ldb       ,y        get the cel_data first byte in b
                    subb      #$02      subtract 2
                    leau      $01,u     bump the pb pointer
TopLineLoop         lda       ,u        grab the byte
                    anda      #$0f      and that with $0F
                    ora       PosInitX  or it with priority &$F0
                    sta       ,u+       stow it back and bump the pointer
                    decb                dec our counter
                    bne       TopLineLoop loop if not finished

ObjAddPicPriDone    puls      y         return the y value
                    rts                 return



* ====== BlitSave / BlitRestore: Save and Restore Screen Background Under Object ======
* blit_save(BLIT *b) obj_blit.c
*  our blit_struct is a bit different from the one in nagi
*
* PosFinalX = zeroed and never changed cause we use the next byte :-)
* PosFinalY = x_count (x_size)         when cmpx ha ha
* ScratchA2 = y_count (y_size)
* ScratchA8 = pic buffer start pic_cur
* ScratchAD = pic_cur + offset

BlitSave            ldu       $02,s     get the pointer to the blit_struct
                    ldd       $0C,u     get the pointer to the view_data for mmu twiddler
                    lbsr      TwiddleMmu twiddle mmu

                    ldu       $02,s     get the pointer to the blit_struct data back in u
                    ldd       $08,u     load the x/y_size
                    std       PosFinalY stow that at x/y_count
                    clr       PosFinalX zero some adder
                    ldb       $07,u     get the y value
                    lda       #$a0      set up PBUF_MULT
                    mul                 do the math
                    addb      $06,u     add in x
                    adca      #0        add in the carry bit
                    addd      #gfx_picbuff add in pic buff base $6040

                    ldu       $0A,u     load u with with the buffer pointer blit_cur
BlitSaveLoop        std       ScratchA8 save the buffer start pointer pic_cur
                    addd      PosFinalX add in the offset x_size
                    std       ScratchAD stow that at pic_cur + offset
                    ldx       ScratchA8 load x with pic_cur
CopyPixelsLoop      ldd       ,x++      copy 2 bytes at a time
                    std       ,u++      to the buffer at blit_cur
                    cmpx      ScratchAD have we copied it all ??
                    blo       CopyPixelsLoop nope loop again

                    ldd       ScratchA8 load with pic buffer start
                    addd      #PICBUFF_WIDTH add 160
                    dec       ScratchA2 dec y_count
                    bne       BlitSaveLoop not zero loop again
                    rts                 blit save complete return


* blit_restore(BLIT *b) obj_blit.c
* blit_save(BLIT *b) obj_blit.c
*  our blit_struct is a bit different from the one in nagi
*
* PosFinalX = zeroed and never changed cause we use the next byte :-)
* PosFinalY = x_count (x_size)         when cmpx ha ha
* ScratchA2 = y_count (y_size)
* ScratchA8 = pic buffer start pic_cur
* ScratchAD = pic_cur + offset

BlitRestore         ldu       $02,s     get the pointer to the blit structure
                    ldd       $0C,u     load view_data pointer for mmu twiddle
                    lbsr      TwiddleMmu twiddle mmu

                    ldu       $02,s     get the blit_structure back in u
                    ldd       $08,u     load x/y_size
                    std       PosFinalY stow them at x/y_count
                    clr       PosFinalX clear the byte prior to x_size
                    ldb       $07,u     get the y value
                    lda       #$a0      set up PBUF_MULT
                    mul                 do the math
                    addb      $06,u     add in the x value
                    adca      #0        add in the carry bit
                    addd      #gfx_picbuff add in the base address $6040

                    ldu       $0A,u     load u with buffer pointer blit_cur
BlitRestoreLoop     std       ScratchA8 save the screen start buffer pic_cur
                    addd      PosFinalX add in the x_size
                    std       ScratchAD stow at pic_cur + offset
                    ldx       ScratchA8 load x pic_cur pointer
CopyBackLoop        ldd       ,u++      grab em from the buffer
                    std       ,x++      and send them to the screen
                    cmpx      ScratchAD moved them all ??
                    blo       CopyBackLoop nope then keep on keeping on

                    ldd       ScratchA8 load the pic_cur pointer
                    addd      #PICBUFF_WIDTH add 160
                    dec       ScratchA2 dec the y count
                    bne       BlitRestoreLoop not zero move some more
                    rts                 blit restore complete return

                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcc       "shdw"
                    fcb       $00

                    emod
eom                 equ       *
                    end

