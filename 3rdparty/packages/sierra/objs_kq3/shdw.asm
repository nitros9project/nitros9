********************************************************************
* SHDW - Kings Quest III screen rendering module??
* $Id$
*
* Note the header shows a data size of 0 called from the sierra
* module and accesses data set up in that module.
*
* Much credit and thanks is give to Nick Sonneveld and the other NAGI
* folks. Following his sources made it so much easier to document what
* was happening in here.
*
* This source will assemble byte for byte to the original kq3 shdw module.
*
*        Header for : shdw
*        Module size: $A56  #2646
*        Module CRC : $E9E019 (Good)
*        Hdr parity : $74
*        Exec. off  : $0012  #18
*        Data size  : $0000  #0
*        Edition    : $00  #0
*        Ty/La At/Rv: $11 $81
*        Prog mod, 6809 Obj, re-ent, R/O
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/14  Paul W. Zibaila
* Disassembly of original distribution using a combination of disasm
* v1.6 and the os9tools disassembler Os9disasm.

                    nam       shdw
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
                    mod       eom,name,tylg,atrv,start,size

size                equ       .

Xffa9               equ       $FFA9               task 1 block 2
X01af               equ       $01AF               a state.flag byte
X0551               equ       $0551               given_pic_data


* OS9 data area definitions

u001a               equ       $001A               shdw MMU block data
u002e               equ       $002E               Load offset
u0042               equ       $0042               Sierra process descriptor block
u0043               equ       $0043               Sierra 2nd 8K data block
u005a               equ       $005A               color
u005b               equ       $005B               sbuff_drawmask
u005c               equ       $005C               flag_control
u006b               equ       $006B               pen_status

* these look like gen purpose scratch vars

u009e               equ       $009E
u009f               equ       $009F
u00a0               equ       $00A0
u00a1               equ       $00A1
u00a2               equ       $00A2
u00a3               equ       $00A3
u00a4               equ       $00A4
u00a5               equ       $00A5
u00a6               equ       $00A6
u00a7               equ       $00A7
u00a8               equ       $00A8
u00a9               equ       $00A9
u00aa               equ       $00AA
u00ab               equ       $00AB
u00ac               equ       $00AC
u00ad               equ       $00AD
u00ae               equ       $00AE
u00af               equ       $00AF
u00b0               equ       $00B0
u00b2               equ       $00B2
u00b3               equ       $00B3




* VIEW OBJECTS FLAGS

O_DRAWN             equ       $01                 * 0  - object has been drawn
O_BLKIGNORE         equ       $02                 * 1  - ignore blocks and condition lines
O_PRIFIXED          equ       $04                 * 2  - fixes priority agi cannot change it based on position
O_HRZNIGNORE        equ       $08                 * 3  - ignore horizon
O_UPDATE            equ       $10                 * 4  - update every cycle
O_CYCLE             equ       $20                 * 5  - the object cycles
O_ANIMATE           equ       $40                 * 6  - animated
O_BLOCK             equ       $80                 * 7  - resting on a block
O_WATER             equ       $100                * 8  - only allowed on water
O_OBJIGNORE         equ       $200                * 9  - ignore other objects when determining contacts
O_REPOS             equ       $400                * 10 - set whenever a obj is repositioned
*                                that way the interpeter doesn't check it's next movement for one cycle
O_LAND              equ       $800                * 11 - only allowed on land
O_SKIPUPDATE        equ       $1000               * 12 - does not update obj for one cycle
O_LOOPFIXED         equ       $2000               * 13 - agi cannot set the loop depending on direction
O_MOTIONLESS        equ       $4000               * 14 - no movement.
*                                if position is same as position in last cycle then this flag is set.
*                                follow/wander code can then create a new direction
*                                (ie, if it hits a wall or something)
O_UNUSED            equ       $8000

* Local Program Defines

PICBUFF_WIDTH       equ       160                 ($A0)
PICBUFF_HEIGHT      equ       168                 ($A8)

picb_size           equ       PICBUFF_WIDTH*PICBUFF_HEIGHT $6900
x_max               equ       PICBUFF_WIDTH-1     159 ($9F)
y_max               equ       PICBUFF_HEIGHT-1    167 ($A7)

gfx_picbuff         equ       $6040               screen buff low address
gbuffend            equ       gfx_picbuff+picb_size screen buff high address $C940

blit_end            equ       gfx_picbuff+$6860

cmd_start           equ       $F0                 first command value


name                equ       *
L000d               fcs       'shdw'
                    fcb       $00

* This module is linked to in sierra

start               equ       *
L0012               lbra      L05fb               gfx_picbuff_update_remap
                    lbra      L0713               obj_chk_control
                    lbra      L0175               render_pic  (which calls pic_cmd_loop)
                    lbra      L0189               pic_cmd_loop
                    lbra      L07be               obj_blit
                    lbra      L0927               obj_add_pic_pri
                    lbra      L0a0f               blit_restore
                    lbra      L09d8               blit_save
                    lbra      L040e               sbuff_fill
                    lbra      L063a               blitlist_draw
                    lbra      L0615               blitlist_erase

                    fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       C$NULL

* Twiddles with MMU
* accd is loaded by calling program
*
*  u001a = shdw mem block data
*  u0042 = sierra process descriptor block
*  u0043 = Sierra 2nd 8K data block

L0074               cmpa      u001a               compare to shdw mem block
                    beq       L008e               equal ?? no work to be done move on
                    orcc      #IntMasks           turn off interupts
                    sta       u001a               store the value passed in by a
                    lda       u0042               get sierra process descriptor map block
                    sta       Xffa9               map it in to $2000-$3FFF
                    ldu       u0043               2nd 8K data block in Sierra
                    lda       u001a               load my mem block value
                    sta       ,u                  save my values at address held in u0043
                    stb       $02,u
                    std       Xffa9               map it to task 1 block 2
                    andcc     #^IntMasks          restore the interupts
L008e               rts                           we done

L008f               fcb       $00                 load offsets updated flag

* binary_list[] (pic_render.c)
L0090               fdb       $8000
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
L00b0               fdb       $8000
                    fdb       $e000
                    fdb       $e000
                    fdb       $e000
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

L0132               fcb       $00,$00             0
                    fcb       $00,$02             2
                    fcb       $00,$08             8
                    fcb       $00,$12             18
                    fcb       $00,$20             32
                    fcb       $00,$32             50
                    fcb       $00,$4a             74
                    fcb       $00,$64             100


* select case dispatch table for pic_cmd_loop()

L0142               fdb       $01bc               enable_pic_draw()
                    fdb       $01c9               disable_pic_draw()
                    fdb       $01d4               enable_pri_draw()
                    fdb       $01e9               disable_pri_draw()
                    fdb       $02de               draw_y_corner()
                    fdb       $02d1               draw_x_corner()
                    fdb       $0309               absolute_line()
                    fdb       $031d               relative_line()
                    fdb       $0359               pic_fill()
                    fdb       $0211               read_pen_status()
                    fdb       $01f4               plot_with_pen()


* This code adds the load offsets to the program offsets above
*
*  u00ab = loop counter
*
L0158               tst       L008f,pcr           test if we've loaded the offsets already
                    bne       L0174               done once leave
                    inc       L008f,pcr           not done set the flag
                    lda       #$0b                set our index to 11
                    sta       u00ab               stow it in mem since we are going to clobber b
                    leau      >L0142,pcr          load table head address
L016a               ldd       u002e               get load offset set in sierra
                    addd      ,u                  add the load offset
                    std       ,u++                and stow it back, bump pointer
                    dec       u00ab               decrement the index
                    bne       L016a               ain't done go again
L0174               rts                           we're out of here


* The interaction between render_pic and pic_cmd_loop is divided
* differently in the NAGI source pic_render.c

* render_pic()
* 4 = proirity and color = F, so the note says
* so the priority is MSnibble and the color is LSnibble

L0175               ldd       #$4f4f              load the color
                    pshs      d                   push it on the stack for the pass
                    lbsr      L040e               call sbuff_fill routine
                    leas      $02,s               reset stack to value at entry
                    ldd       $02,s               pull the next word
                    pshs      d                   push it on top of the stack
                    lbsr      L0189               call pic_cmd_loop()
                    leas      $02,s               once we return clean up stack again
                    rts                           return

* pic_cmd_loop() (pic_render.c)
*
*  u005a = color
*  u005b = sbuff_drawmask
*  u006b = pen_status

L0189               pshs      y
                    bsr       L0158               ensure load offset has been added to table address
                    lbsr      L06fc               sbuff_fill()
                    clra                          make a zero
                    sta       u005b               sbuff_drawmask
                    sta       u006b               pen_status
                    coma                          make the complement FF
                    sta       u005a               store color

                    ldu       4,s                 get the word passed in to us on the stack
                    ldd       5,u                 pull out the required info for the mmu twiddle
                    lbsr      L0074               twiddle mmu

* pic_cmd_loop()  (pic_render.c) starts here
                    ldx       X0551               given_pic_data  set in pic_res.c
L01a2               lda       ,x+                 pic_byte

L01a4               cmpa      #$ff                if it's FF were done
                    beq       L01b9               so head out
                    suba      #cmd_start          first valid cmd = F0 so subtract to get index
                    blo       L01a2               less than F0 ignore it get next byte
                    cmpa      #$0a                check for top end
                    bhi       L01a2               greater than FA ignore it get next byte
                    leau      >L0142,pcr          load the addr of the dispatch table
                    asla                          sign extend multiply by two for double byte offset
                    jsr       [a,u]               make the call
                    bra       L01a4               loop again

L01b9               puls      y                   done then fetch the y back
                    rts                           and return

* Command $F0 change picture color and enable picture draw
*  enable_pic_draw() pic_render.c
*  differs slightly with pic_render.c
*  does't have colour_render()
*  and setting of colour_picpart
*
*  u005a = color
*  u005b = sbuff_drawmask
*
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a

L01bc               ldd       u005a               pulls in color and sbuff_drawmask
                    anda      #$f0                and color with $F0
                    ora       ,x+                 or that result with the pic_byte and bump to next
                    orb       #$0f                or the sbuff_drawmask with $0F
                    std       u005a               store the updated values
                    lda       ,x+                 return value ignored so this just bumps to next pic_byte
                    rts


* Command $F1 Disable picture draw
*  disable_pic_draw()
*
*  u005a = color
*  u005b = sbuff_drawmask
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a

L01c9               ldd       u005a               pulls in color and sbuff_drawmask
                    ora       #$0f                ors color with $0F (white ??)
                    andb      #$f0                ands draw mask with $F0
                    std       u005a               store the updated values
                    lda       ,x+                 return value ignored so this just bumps to next pic_byte
                    rts

* Command $F2 Changes priority color and enables priority draw
*  enable_pri_draw() pic_render.c
*
*  u005a = color
*  u005b = sbuff_drawmask
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a

L01d4               ldd       u005a               pulls in color and sbuff_drawmask
                    anda      #$0f                ands color with $0F
                    sta       u005a               save color
                    lda       ,x+                 loads pic_byte and bumps to next
                    asla                          times 2 with sign extend
                    asla                          again times 2
                    asla                          and again times 2
                    asla                          end result is multiply pic_byte by 16 ($10)
                    ora       u005a               or that value with the modified color
                    orb       #$f0                or the sbuff_drawmask with $F0
                    std       u005a               store the updated values
                    lda       ,x+                 return value ignored so this just bumps to next pic_byte
                    rts

* Command $F3 Disable priority draw
*  diasable_pri_draw() pic_render.c
*
*  u005a = color
*  u005b = sbuff_drawmask
*  x contains pointer to given_pic_data known as the pic_byte
*  after ldd
*  a contains color
*  b contains draw mask
*  returns the next pic_byte in a


L1e9                ldd       u005a               pulls in color and sbuff_drawmask
                    ora       #$f0                or the color with $F0
                    andb      #$0f                and the sbuff_drawmask with $0F
                    std       u005a               store the updated values
                    lda       ,x+                 return value ignored so this just bumps to next pic_byte
                    rts

* Command $FA plot with pen
* Logic is pic_byte >= 0xF0 in c source.
* Emailed Nick Sonneveld 3/14/ 03
*
*  u006b = pen_status
*  u00a2 = pen_x position
*  u00a3 = pen_y position
*  u00a6 = texture_num
*
*  x contains pointer to given_pic_data known as the pic_byte
*  returns the next pic_byte in a

* plot_with_pen()  (pic_render.c)
L01f4               lda       u006b               pen_status
                    bita      #$20                and but don't change check for pen type solid or splater ($20)
                    beq       L0204               is splater
                    lda       ,x+                 load pic_byte (acca) from pic_code and bump pointer
                    cmpa      #cmd_start          test against $F0 if a is less than
*                      based on discussions with Nick this must have been a bug
*                      in the earlier versions of software...
*                      if it is less than $F0 it's just a picture byte
*                      fix next rev.
                    lblo      L02ea               branch to a return statement miles away (could be fixed)
                    sta       u00a6               save our pic_byte in texture_num
L0204               lbsr      L0364               call read_xy_postion
                    lblo      L02ea               far off rts
                    std       u00a2               pen x/y position
                    bsr       L0218               call plot_with_pen2()
                    bra       L01f4               go again ...
*                      yes there is no rts here in the c source either


* Command $F9 Change pen size and style
*  read_pen_status() pic_render.c
*
*  u006b = pen_status
*
*  x contains pointer to given_pic_data known as the pic_byte
*  returns the next pic_byte in a

L0211               lda       ,x+                 get pic_byte
                    sta       u006b               save as pen_status
                    lda       ,x+                 return value ignored so this just bumps to next pic_byte
                    rts


* plot_with_pen2()
* called from plot with pen
*  Sets up circle_ptr
*
*  u006b = pen_status
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a2 = pen_x position
*  u00a3 = pen_y position
*  u00a4 = pen_final_x
*  u00a5 = pen_final_y
*  u00a7 = pen.size
*  u00a8 = t
*  u00a9 = pensize x 2
*  u00aa =  "
*  u00ab = scratch var
*  u00ac = scratch var
*  u00ad = penwidth
*  u00ae =  "

L0218               ldb       u006b               pen_status
                    andb      #$07
                    stb       u00a7               pen.size ?? save for pen_status & $07

                    clra                          clear a and condition codes
                    lslb                          multiply by 2
                    std       u00a9               pen size x 2
                    leau      L0132,pcr           circle_list[]
                    ldd       b,u                 d now holds one of the circle_list values
                    leau      L00b0,pcr           circle_data[]
                    leau      d,u                 use that to index to a circle_data item
*                      u now is circle_ptr

*  Set up x position
                    clra
                    ldb       u00a2               load pen_x position
                    lslb                          multiply by two
                    rola
                    subb      u00a7               subtract the pen.size
                    bcc       L023f               outcome not less than zero move on
                    deca
                    bpl       L023f               if we still have pos must be 0 or >
                    ldd       #0000
                    bra       L024d
L023f               std       u00ab               store pen_x at scratch

                    ldd       #$0140              start with 320
                    subd      u00a9               subtract 2 x pen.size
                    cmpd      u00ab               pen_x to calc
                    bls       L024d               if pen_x is greater keep temp calc
                    ldd       u00ab               otherwise use pen_x

L024d               lsra                          divide by 2
                    rorb
                    stb       u00a2               stow at pen_x
                    stb       u00a4               stow at pen_final_x

*  Set up y position
                    lda       u00a3               pen_y
                    suba      u00a7               pen.size
                    bcc       L025c               >= 0 Ok go stow it
                    clra                          otherwise less than zero so set it to 0
                    bra       L0268               go stow it
L025c               sta       u00ab               store pen_y at scratch

                    lda       #y_max              start with 167
                    suba      u00aa               subtract 2 x pen.size
                    cmpa      u00ab               compare to pen_y calced so far
                    bls       L0268               if pen_y > calc use calc and save it
                    lda       u00ab               otherwise use pen_y
L0268               sta       u00a3               pen_y
                    sta       u00a5               pen_final_y

                    lda       u00a6               texture_num
                    ora       #$01
                    sta       u00a8               t ??

                    ldb       u00aa               2 x pen.size
                    incb                          bump it by one
                    tfr       b,a                 copy b into a
                    adda      u00a5               add value to pen_final_y
                    sta       u00a5               save new pen_final_y
                    lslb                          shift b left (multiply by 2)

                    leax      L0090,pcr           binary list[]
                    ldd       b,x                 use 2x pensize + 1 to index into list
                    std       u00ad               pen width ???

*   this looks like it should have been nested for loops
*   but not coded that way in pic_render.c

*  new y
L0284               leax      L0090,pcr           binary_list[]

*  new x
L0288               lda       u006b               pen_status
                    bita      #O_UPDATE           and it with $10 but don't change
                    bne       L0298               not equal zero go on to next pen status test
                    ldd       ,u                  otherwise  load data at circle_ptr
                    anda      ,x                  and that with first element in binary_list
                    bne       L0298               if thats not zero go on to next pen status check

                    andb      $01,x               and the second bytes of data at circle_ptr
*                      and binary_list
                    beq       L02ba               that outcome is equ zero head for next calcs

L0298               lda       u006b               pen_status
                    bita      #$20                anded with $20 but don't change
                    beq       L02af               equals zero set up and plot buffer
                    lda       u00a8               otherwise load t (texture_num | $01)
                    lsra                          divide by 2
                    bcc       L02a5               no remainder save that number as t
                    eora      #$b8                exclusive or t with $B8
L02a5               sta       u00a8               save new t
                    bita      #O_DRAWN            anded with 1 but don't change
                    bne       L02ba               not equal zero don't plot
                    bita      #O_BLKIGNORE        anded with 2 but don't change
                    beq       L02ba               does equal zero don't plot

L02af               pshs      u                   save current u sbuff_plot uses it
                    ldd       u00a2               load pen_x/pen_y values
                    std       u009e               save at pos_init_x/y positions
                    lbsr      L046f               head for sbuff_plot()
                    puls      u                   retrieve u from before call

L02ba               inc       u00a2               increment pen_x value

                    leax      $04,x               move four bytes in the binary_list
                    cmpx      u00ad               comapre that value to pen_width
                    bls       L0288               less or same go again

                    leau      $02,u               bump circle_ptr to next location in circle_data[]

                    lda       u00a4               load pen_final_x
                    sta       u00a2               store at pen_x
                    inc       u00a3               bump pen_y
                    lda       u00a3               pen_y
                    cmpa      u00a5               compare to pen_final_y
                    bne       L0284               not equal go do the next row
                    rts


* Command $F5 Draw an X corner
* draw_x_corner()  pic_render.c
*
*  u009e = pos_init_x
*  u009f = pos_init_y

L02d1               lbsr      L0364               call read_xy_pos
                    bcs       L02ea               next subs rts
                    std       u009e               save pos_init_x/y positions
                    lbsr      L046f               head for sbuff_plot()
                    bsr       L02eb               draw_corner(0)
                    rts


* Command $F4 Draw a Y corner
* draw_y_corner()  pic_render.c
*
*  u009e = pos_init_x
*  u009f = pos_init_y

L02de               lbsr      L0364               call read_xy_pos
                    bcs       L02ea               return
                    std       u009e               save at pos_init_x/y positions
                    lbsr      L046f               head for sbuff_plot()
                    bsr       L02f9               draw_corner(1)
L02ea               rts



* draw_corner(u8 type)  pic_render.c
*
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a0 = pos_final_x
*  u00a1 = pos_final_y

draw_x
L02eb               lbsr      L036f               get_x_pos()
                    bcs       L02ea               prior subs return
                    sta       u00a0               store as pos_final_x
                    ldb       u009f               load pos_init_y
                    stb       u00a1               store as pos_final_y
                    lbsr      L0421               call sbuff_xline()

draw_y
L02f9               lbsr      L0381               get_y_pos
                    bcs       L02ea               prior subs return
                    stb       u00a1               save pos_final_y
                    lda       u009e               load pos_init_x
                    sta       u00a0               save pos_final_x
                    lbsr      L0447               sbuff_yline()
                    bra       L02eb               head for draw_x



* Command $F6 Absolute line
* absolute_line()
* This command is before Draw X corner in nagi source
*
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a0 = pos_final_x
*  u00a1 = pos_final_y

L0309               bsr       L0364               call read_xy_pos
                    bcs       L02ea               prior subs return
                    std       u009e               save at pos_init_x/y positions
                    lbsr      L046f               head for sbuff_plot()
L0312               bsr       L0364               call read_xy_pos
                    bcs       L02ea               prior subs return
                    std       u00a0               save at pos_final_x/y and passed draw_line in d
                    lbsr      L0394               call draw_line()
                    bra       L0312               go again



* relative_line()
*
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a0 = pos_final_x
*  u00a1 = pos_final_y

L031D               bsr       L0364               call read_xy_pos
                    bcs       L02ea               prior subs return
                    std       u009e               save at pos_init_x/y positions
                    lbsr      L046f               head for sbuff_plot()

* calc x
L0326               lda       ,x+                 get next pic_byte
*                      and load it in pos_data in c source
                    cmpa      #cmd_start          is that equal $F0 or greater
                    bcc       L02ea               yep were done so return (we use prior subs return ??)
*                      that rascal in acca changes names again to x_step
*                      but it's still the same old data
                    anda      #$70                and that with $70
*                      (where these values are derived from I haven't a clue, as of yet :-))
                    lsra                          divide by 2
                    lsra                          and again
                    lsra                          once more
                    lsra                          and finally another for a /16
                    ldb       -$01,x              get the original value
                    bpl       L0337               if original value not negative move on
                    nega                          else it was so flip the sign of the computed value
L0337               adda      u009e               add pos_init_x position
                    cmpa      #x_max              compare to 159
                    bls       L033f               if it's less or same move on
                    lda       #x_max              else cap it at 159
L033f               sta       u00a0               store as pos_final_x

* calc y
*                      not quite the same as pic_render.c almost
*                      we've go the pic_byte ... er pos_data ... now called y_step
*                      in b so lets calc the y_step
                    andb      #$0f                and with $0F (not in pic_render.c)
                    bitb      #$08                and that with $08 but don't change
                    beq       L034a               if result = 0 move on
                    andb      #$07                else and it with $07
                    negb                          and negate it
L034a               addb      u009f               add calced value to pos_init_y
                    cmpb      #y_max              compare to 167
                    bls       L0352               less or same move on
                    ldb       #y_max              greater ? cap it
L0352               stb       u00a1               pos_final_y

*                      passes pos_final_x/y in d
                    lbsr      L0394               call draw_line()

                    bra       L0326               go again exit is conditinals inside loop

* Command $F8 Fill
* pic_fill()
*
*  u009e = pos_init_x
*  u009f = pos_init_y

L0359               bsr       L0364               call read_xy_pos
                    bcs       L02ea               returned a 1 head for prior subs return
                    std       u009e               save at pos_init_x/y position
                    lbsr      L0486               call sbuff_picfill()
                    bra       L0359               loop till we get a 1 back from read_xy_pos

* read_xy_pos()
L0364               lbsr      L036f               go get x position
                    lblo      L02ea               prior subs return
                    lbsr      L0381               go get the y position
                    rts


* get_x_pos()
L036f               lda       ,x+                 load pic_byte
                    cmpa      #cmd_start          is it a command?
                    bhs       L037e               if so set CC
                    cmpa      #x_max              compare to 159
                    bls       L037b               is it less or same clear CC and return
                    lda       #x_max              greater than load acca with 159
L037b               andcc     #$fe                clear CC ad return
                    rts


L037e               orcc      #1                  returns a "1"
                    rts

* get_y_pos()
L0381               ldb       ,x+                 load pic_byte
                    cmpb      #cmd_start          is it a command
                    blo       L038b               nope less than command
                    lda       -$01,x              was a command load x back in acca
                    bra       L037e               go set CC
L038b               cmpb      #y_max              compare to 167
                    bls       L0391               is it less or same clear CC and return
                    ldb       #y_max              greater than load accb with 167
L0391               andcc     #$fe                clear CC and return
                    rts


* draw_line()  pic_render.c
* while this is a void function() seems pos_final_x/y are passed in d
*
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a0 = pos_final_x
*  u00a1 = pos_final_y
*  u00a2 = x_count
*  u00a3 = y_count
*  u00a4 = pos_x
*  u00a5 = pos_y
*  u00a6 = line_x_inc
*  u00a7 = line_y_inc
*  u00a8 = x_component
*  u00a9 = y_component
*  u00aa = largest_line
*  u00ab = counter

*  process straight lines
L0394               cmpb      u009f               compare pos_final_y with pos_init_y
                    lbeq      L0421               if equal call sbuff_xline() and don't return here
                    cmpa      u009e               else compare with pos_init_x position
                    lbeq      L0447               if equal call sbuff_yline() and don't return here

                    ldd       u009e               load pos_init_x/y positions
                    std       u00a4               store at pen_final ??? not in pic_render.c version

*  process y
                    lda       #$01                line_y_inc

                    ldb       u00a1               load pos_final_y
                    subb      u009f               subtract pos_init_y
                    bcc       L03ae               greater or equal zero don't negate
*                      less than zero
                    nega                          flip the sign of line_y_inc
                    negb                          flip the sign of y_component

L03ae               sta       u00a7               store line_y_inc
                    stb       u00a9               store y_component

* process x
                    lda       #$01                line_x_inc

                    ldb       u00a0               load pos_final_x
                    subb      u009e               subtract pos_init_x
                    bcc       L03bc               greater or equal zero don't negate
*                      less than zero
                    nega                          flip the sign of line_x_inc
                    negb                          flip the sign of x_component
L03bc               sta       u00a6               store line_x_inc
                    stb       u00a8               store x_component

* compare x/y components
                    cmpb      u00a9               compare y_component to x_component
                    blo       L03d0               if x_component is smaller move on


*  x >= y
*                      x_component is in b
                    stb       u00ab               counter
                    stb       u00aa               largest_line
                    lsrb                          divide by 2
                    stb       u00a3               store y_count
                    clra                          make a zero
                    sta       u00a2               store x_count
                    bra       L03dc               move on

*  x < y
L03d0               lda       u00a9               load y_component
                    sta       u00ab               stow as counter
                    sta       u00aa               stow as largest line
                    lsra                          divide by 2
                    sta       u00a2               store x_count
                    clrb                          make a zero
                    stb       u00a3               store as y_count


* loops through the line and uses sbuff_plot to do the screen write
*                      y_count is in b
L03dc               addb      u00a9               add in the y_component
                    stb       u00a3               and stow back as y_count
                    cmpb      u00aa               compare that with line_largest
                    blo       L03ee               if y_count >= line_largest is not the case branch
                    subb      u00aa               subtract line_largest
                    stb       u00a3               store as y_count
                    ldb       u00a5               load pos_y
                    addb      u00a7               add line_y_inc
                    stb       u00a5               stow as pos_y

*                      x_count is in a
L03ee               adda      u00a8               add in x_component
                    sta       u00a2               store as x_count
                    cmpa      u00aa               compare that with line_largest
                    blo       L0400               if x_count >= line_largest is not the case branch
                    suba      u00aa               subtract line_longest
                    sta       u00a2               store at x_count
                    lda       u00a4               load pos_x
                    adda      u00a6               add line_x_inc
                    sta       u00a4               stow as pos_x

L0400               ldd       u00a4               load computed pos_x/y
                    std       u009e               store at pos_init_x/y positions
                    lbsr      L046f               head for sbuff_plot()
                    ldd       u00a2               reload x/y_count
                    dec       u00ab               decrement counter
                    bne       L03dc               if counter not zero go again
                    rts

***********************************************************************


* sbuff_fill() sbuf_util.c
* fill color is passed in s register

L040e               pshs      x                   save x as we use it for an index
                    ldu       #gbuffend           address to write to
                    ldx       #picb_size          $6900 bytes to write (26.25K)
*                      this would be picture buffer width x height
                    ldd       $04,s               since we pushed x pull our color input out of the stack
L0418               std       ,--u                store them and dec dest address
                    leax      -$02,x              dec counter
                    bne       L0418               loop till done
                    puls      x                   fetch the x
                    rts                           return


* sbuff_xline()  sbuff_util.c
* gets called here with pos_final_x/y in accd
*
*  u005a = color
*  u005b = sbuff_drawmask
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a0 = pos_final_x
*  u00a1 = pos_final_y
*  u00ac = x_orig

L0421               sta       u00ac               stow as x_orig
                    cmpa      u009e               compare with pos_init_x position
                    bhs       L042d               if pos_final_x same or greater branch

*                      otherwise init >  final so swap init and final
                    ldb       u009e               load pos_init_x position
                    stb       u00a0               save pos_final_x position
                    sta       u009e               save pos_init_x position

L042d               bsr       L046f               head for sbuff_plot() returns pointer in u

                    ldb       u00a0               load pos_final_x
                    subb      u009e               subtract pos_init_x position
                    beq       L0442               if they are the same move on
*                      b now holds the loop counter len
*                      u is the pointer returned from sbuff_plot
                    leau      $01,u               bump the pointer one byte right
L0437               lda       ,u                  get the the byte
                    ora       u005b               or it with sbuff_drawmmask
                    anda      u005a               and it with the color
                    sta       ,u+                 save it back and bump u to next byte
                    decb                          decrememnt the loop counter
                    bne       L0437               done them all? Nope loop

L0442               lda       u00ac               x_orig (pos_final_x)
                    sta       u009e               save at pos_init_x position
                    rts


* sbuff_yline() sbuf_util.c
* gets called here with pos_final_x/y in accd
*
*  u005a = color
*  u005b = sbuff_drawmask
*  u009e = pos_init_x
*  u009f = pos_init_y
*  u00a0 = pos_final_x
*  u00a1 = pos_final_y
*  u00ac = y_orig

L0447               stb       u00ac               stow as y_orig
                    cmpb      u009f               compare with pos_init_y
                    bhs       L0453               if pos_final same or greater branch

*                           otherwise init > final so swap 'em
                    lda       u009f               load pos_init_y
                    sta       u00a1               stow as pos_final_y
                    stb       u009f               stow as pos_init_y

L0453               bsr       L046f               head for sbuff_plot() returns pointer in u
                    ldb       u00a1               load pos_final_y
                    subb      u009f               subtract pos_init_y
                    beq       L046a               if they are the same move on
*                           b now holds the loop counter len
*                           u is the pointer returned from sbuff_plot
L045b               leau      PICBUFF_WIDTH,u     bump ptr one line up
                    lda       ,u                  get the byte
                    ora       u005b               or it with sbuff_drawmmask
                    anda      u005a               and it with the color
                    sta       ,u                  save it back out
                    decb                          decrement the loop counter
                    bne       L045b               done them all ? Nope loop

L046a               ldb       u00ac               load y_orig
                    stb       u009f               save it as pos_init_y
                    rts


* sbuff_plot()  from sbuf_util.c
* according to agi.h PBUF_MULT(width) ((( (width)<<2) + (width))<<5)
* which next 3 lines equate to so the $A0 is from 2 x 5
* pointer is returned in index reg u
*
*  u005a = color
*  u005b = sbuff_drawmask
*  u009e = pos_init_x
*  u009f = pos_init_y

L046f               ldb       u009f               load pos_init_y
                    lda       #$A0                according to PBUF_MULT()
                    mul                           do the math
                    addb      u009e               add pos_init_x position
                    adca      #0000               this adds the carry bit in to a
                    addd      #gfx_picbuff        add that to the start of the screen buf $6040
                    tfr       d,u                 move this into u
                    lda       ,u                  get the byte u points to
                    ora       u005b               or it with sbuff_drawmask
                    anda      u005a               and it with the color
                    sta       ,u                  and stow it back at the same place
                    rts                           return




* sbuff_picfill(u8 ypos, u8 xpos) sbuf_util.c
* u005a = color
* u005b = sbuff_drawmask
* u009e = pos_init_x
* u009f = pos_init_y
* u00a0 = left
* u00a1 = right
* u00a2 = old_direction
* u00a3 = direction
* u00a4 = old_initx
* u00a5 = old_inity
* u00a6 = old_left
* u00a7 = old_right
* u00a8 = stack_left
* u00a9 = stack_right
* u00aa = toggle
* u00ab = old_toggle
* u00ae = color_bl
* u00af = mask_dl
* u00b0 = old_buff (word)
* u00b2 = temp (buff)


colorbl             set       $4F
temp_stk            set       $E000

L0486               pshs      x                   save x
                    ldx       #temp_stk           load addr to create a new stack
                    sts       ,--x                store current stack pointer there and decrement x
                    tfr       x,s                 make that the stack
*                           s is now stack_ptr pointing to fill_stack

                    ldb       u009f               pos_init_y
                    lda       #$a0                set up PBUF_MULT
                    mul                           do the math
                    addb      u009e               add pos_init_x
                    adca      #0000               add in that carry bit
                    addd      #gfx_picbuff        add the start of screen buffer $6040
                    tfr       d,u                 move this to u
*                           u now is pointer to screen buffer b


                    ldb       u005a               load color
                    lda       u005b               load sbuff_drawmask

*                           next 2 lines must have been a if (sbuff_drawmask > 0)
*                           not in the nagi source

                    lbeq      L05f5               if sbuff_drawmask = 0 we're done
                    bpl       L04b8               if not negative branch to test color

                    cmpa      #cmd_start          comp $F0 with sbuff_drawmask
                    bne       L04b8               not = go test color for $0F
                    andb      #$f0                and color with $F0
                    cmpb      #$40                compare that to $40 (input was $4x)
                    lbeq      L05f5               if so were done
                    lda       #$f0                set up value for mask_dl
                    bra       L04c2               go save it

L04b8               andb      #$0f                and color with $0F
                    cmpb      #$0f                was it already $0F
                    lbeq      L05f5               if so we're done
                    lda       #$0f                set up value for mask_dl

L04c2               sta       u00af               stow as mask_dl
                    anda      #colorbl            and that with $4F
                    sta       u00ae               stow that as color_bl
                    lda       ,u                  get byte at screen buffer
                    anda      u00af               and with mask_dl
                    cmpa      u00ae               compare to color_bl
                    lbne      L05f5               not equal were done

                    ldd       #$FFFF              push 7 $FF bytes on temp stack
                    pshs      a,b                 and set stack_ptr accordingly
                    pshs      a,b
                    pshs      a,b
                    pshs      a

                    lda       #$a1                load a with 161
                    sta       u00a0               stow it at left
                    clra                          make a zero
                    sta       u00a1               stow it at right
                    sta       u00aa               stow it at toggle
                    inca                          now we want a 1
                    sta       u00a3               stow it at direction

* fill a new line
L04e9               ldd       u00a0               load left/right
                    std       u00a6               stow at old_left/right
                    lda       u00aa               load toggle
                    sta       u00ab               stow at old_toggle
                    ldb       u009e               load pos_init_x
                    stb       u00a4               store as old_initx
                    incb                          accb now becomes counter
                    stu       u00b0               stow current screen byte as old_buff

L04f8               lda       ,u                  get the screen byte pointed to by u
                    ora       u005b               or it with sbuff_drawmmask
                    anda      u005a               and that with the color
                    sta       ,u                  stow that back
                    lda       ,-u                 get the screen byte befor that one
                    anda      u00af               and that with mask_dl
                    cmpa      u00ae               compare result with color_bl
                    bne       L050b               not equal move on
                    decb                          otherwise decrement the counter
                    bne       L04f8               if were not at zero go again

L050b               leau      1,u                 since cranked to zero bump the screen pointer by one
                    tfr       u,d                 move that into d
                    subd      u00b0               subtract old_buff
                    addb      u009e               add pos_init_x
                    stb       u00a0               stow at left
                    lda       u009e               load pos_init_x
                    stb       u009e               store left at pos_init_x
                    stu       u00b2               temp buff
                    ldu       u00b0               load  old_buff
                    leau      1,u                 bump to the next byte
                    nega                          negate pos_init_x value
                    adda      #x_max              add that to 159 (subtract pos_init_x)
                    beq       L0537               that's the new counter and if zero move on

L0524               ldb       ,u                  get that screen byte (color_old)
                    andb      u00af               and it with mask_dl
                    cmpb      u00ae               check against color_bl
                    bne       L0537               not equal move on
                    ldb       ,u                  load that byte again to do something with
                    orb       u005b               or it with sbuff_drawmmask
                    andb      u005a               and it with color
                    stb       ,u+                 stow it back and bump the pointer
                    deca                          decrement the counter
                    bne       L0524               if we haven't hit zero go again

L0537               tfr       u,d                 move the screen buff ptr to d
                    subd      u00b2               subtract that saved old pointer
                    decb                          sunbtract a 1
                    addb      u00a0               add in the left
                    stb       u00a1               store as the right
                    lda       u00a6               load old_left
                    cmpa      #$a1                compare to 161
                    beq       L0577               if it is move on

                    cmpb      u00a7               if the new right == old right
                    beq       L0552               then move on
                    bhi       L0566               not equal and right > old_right
*                           otherwise
                    stb       u00a4               stow right as old_initx
                    clr       u00aa               clear toggle
                    bra       L056c               head for next calc
*                           they were equal
L0552               lda       u00a0               load a with left
                    cmpa      u00a6               compare that to old_left
                    bne       L0566               move on
                    lda       #$01                set up a one
                    cmpa      u00aa               compare toggle
                    beq       L0577               is a one ? go to locnext
                    sta       u00aa               not one ? set it to 1
                    lda       u00a1               load right
                    sta       u00a4               stow it as old_initx
                    bra       L056c               head for the next calc
*                           right > old_right or left > old left
L0566               clr       u00aa               clear toggle
                    lda       u00a7               load old right
                    sta       u00a4               save as old_initx

*         push a bunch on our temp stack
L056c               ldy       u00a2               old_direction/direction
                    ldx       u00a4               old_initx/y
                    ldu       u00a6               old_left/right
                    lda       u00ab               old_toggle
                    pshs      a,x,y,u             push them on the stack

locnext
L0577               lda       u00a3               load direction
                    sta       u00a2               stow as old_direction
                    ldb       u009f               load pos_init_y
                    stb       u00a5               stow as old_inity

L057f               addb      u00a3               add direction to pos_init_y
                    stb       u009f               stow the updated pos_init_y
                    cmpb      #y_max              compare that to 167
                    bhi       L05c5               greater than 167 go test direction

L0587               ldb       u009f               load pos_init_y
                    lda       #$A0                according to PBUF_MULT
                    mul                           do the math
                    addb      u009e               add pos_init_x position
                    adca      #0000               this adds the carry bit into the answer
                    addd      #gfx_picbuff        add that to the screen buff start addr $6040
                    tfr       d,u                 move it into u
                    lda       ,u                  get the byte pointed to
                    anda      u00af               and with mask_dl
                    cmpa      u00ae               compare with color_bl
                    lbeq      L04e9               if equal go fill a new line

                    lda       u009e               load pos_init_x
                    ldb       u00a3               load direction
                    cmpb      u00a2               compare to old_direction
                    beq       L05bc               go comapre pos_init_x and right
                    tst       u00aa               test toggle
                    bne       L05bc               not zero go comapre pos_init_x and right
                    cmpa      u00a8               compare pos_init_x and stack_left
                    blo       L05bc               less than stack_left go comapre pos_init_x and right
                    cmpa      u00a9               compare it to stack_right
                    bhi       L05bc               greater than go comapre pos_init_x and right
                    lda       u00a9               load stack_right
                    cmpa      u00a1               compare to right
                    bhs       L05c5               greater or equal go check direction
                    inca                          add one to stack_right
                    sta       u009e               stow as pos_init_x

L05bc               cmpa      u00a1               compare updated value to right
                    bhs       L05c5               go check directions
                    inca                          less than then increment by 1
                    sta       u009e               stow updated value pos_init_x
                    bra       L0587               loop for next byte

* test direction and toggle
L05c5               lda       u00a3               load direction
                    cmpa      u00a2               compare old_direction
                    bne       L05dc               not equal go pull stacked values
                    tst       u00aa               test toggle
                    bne       L05dc               not zero go pull stack values
                    nega                          negate direction
                    sta       u00a3               store back at direction
                    lda       u00a0               load left
                    sta       u009e               stow as pos_init_x
                    ldb       u00a5               load old_inity
                    stb       u009f               stow at pos_init_y
                    bra       L05ef               go grab off stack and move on

* directions not equal
L05dc               puls      a,x,y,u             grab the stuff off the stack
                    cmpa      #$FF                test toggle for $FF source has test of pos_init_y
                    beq       L05f5               equal ? clean up stack and return
                    sty       u00a2               stow old_direction/direction
                    stx       u009e               stow pos_init_x/y
                    stu       u00a0               stow left/right
                    sta       u00aa               stow toggle

                    ldb       u009f               load pos_init_y
                    stb       u00a5               stow old_inity
L05ef               ldx       $05,s               gets left right  off stack
                    stx       u00a8               stow stack_left/right
                    bra       L057f               always loop

L05f5               lds       ,s                  reset stack
                    puls      x                   retrieve our x
                    rts                           return


* this routine effective swaps postion of
* the two nibbles of the byte loaded
* and returns it to the screen
* it is the workhorse loop in gfx_picbuff_update gfx.c ???
* called via remap call in mnln

gfx_picbuff_update_remap
L05fb               ldx       #gfx_picbuff        starting low address of srceen mem
L05fe               lda       ,x                  get the first byte  bit order 0,1,2,3,4,5,6,7
                    clrb                          empty b
                    lsra                          shift one bit from a
                    rorb                          into b
                    lsra                          again
                    rorb
                    lsra                          and again
                    rorb
                    lsra                          and finally once more
                    rorb
                    stb       ,x                  were changing x anyway so use it for temp storage
                    ora       ,x                  or that with acca so now bit order from orig
*                        is 4,5,6,7,0,1,2,3
                    sta       ,x+                 put it back at x and go for the next one
                    cmpx      #gbuffend           ending high address of screen mem
                    bcs       L05fe
                    rts

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


* blitlist_draw(BLIT *b) obj_base.c
L0615               leas      -$02,s              make room on the stack
                    ldx       $04,s               get the blit_struct pointer
                    ldu       $02,x               load u with pointer to next blit

L061b               stu       ,s                  stow it on the stack
                    beq       L0637               if it's zero we're done
                    pshs      u                   push the pointer on the stack
                    lbsr      L09d8               call blit_save()
                    leas      $02,s               get the pointer back in s
                    ldu       ,s                  put it in u
                    ldu       $04,u               get the pointer to view_struct
                    pshs      u                   push that on the stack and
                    lbsr      L07be               call obj_blit()
                    leas      $02,s               get the pointer back in s
                    ldu       ,s                  put it in u
                    ldu       $02,u               get the pointer to the next one
                    bra       L061b               and go again

L0637               leas      $02,s               clean up stack and leave
                    rts

* blitlist_erase(BLIT *b) obj_base.c
* nagi has a return blitlist_free at the end

L063a               leas      -$02,s              make room on the stack
                    ldx       $04,s               get the blit_struct pointer
                    ldu       ,x                  load u with the prev pointer
                    beq       L0651               if it's zero we're done
L0642               stu       ,s                  stow it on the stack
                    pshs      u                   push the pointer
                    lbsr      L0a0f               call blit_restore()
                    leas      $02,s               get the pointer back in s
                    ldx       ,s                  load x with the pointer
                    ldu       ,x                  get the prev from that struct
                    bne       L0642               loop again

L0651               leas      $02,s               clean up stack and leave
                    rts

* From obj_picbuff.c the pri_table[172]
* ours is only 168
pri_table
L0654               fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

                    fcb       $00,$00,$00,$00,$00,$00
                    fcb       $00,$00,$00,$00,$00,$00

* loops thru 48 bytes with a = 4
* bumps a by one load b with 12 this
* iterates thru ten sets of twelve bytes
* bumping acca by one as it goes.

* table_init()   obj_pic_buff.c
L06fc               leax      L0654,pcr           point to data block
                    ldb       #$30                load index 48
                    lda       #4                  load acca = 4
L0704               sta       ,x+                 save a in buffer
                    decb                          dec the inner loop counter
                    bne       L0704               go again if loop not finished
                    cmpa      #$0e                get here when inner loop is done
                    bcc       L0712               did we do 10 loops (e-4)
                    inca                          nope bump data byte
                    ldb       #$0c                set new counter on loops 2-10
*                       to do 12 bytes and
                    bra       L0704               have at it again
L0712               rts


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


*  u00a5 = flag_signal
*  u00a6 = flag_water
*  u005c = flag_control
*
*  X01af is loaction of state.flag
*  see agi.h for definition of state structure
L0713               pshs      y                   save y

                    ldx       $04,s               sets up mmu info
                    ldd       $08,x               load view_data passed to mmu twiddler
                    lbsr      L0074               twiddle mmu

                    ldb       $04,x               load y
                    lda       $26,x               load flags
                    bita      #O_PRIFIXED         and with $04 but don't change
                    bne       L072f               not zero move on
*                         it is zero then
                    leau      L0654,pcr           load buffer address
                    clra                          clear a since we will use d as an index
                    lda       d,u                 fetch the data from pri_table
                    sta       $24,x               save as priority

L072f               lda       #$A0                set up PBUF_MULT()
                    mul                           do the math
                    addb      $03,x               add in x
                    adca      #0000               add in the carry bit
                    addd      #gfx_picbuff        add it to the start of the screen buff addr 6040
                    tfr       d,u                 move the pointer pb to u

                    ldy       $10,x               load y with cel_data ptr
                    clra                          make a zero
                    sta       u00a6               stow it at flag_water
                    sta       u00a5               stow it at flag_signal
                    inca                          make a 1
                    sta       u005c               stow it at flag_contro1
                    ldb       $24,x               load priority
                    cmpb      #$0F                compare it with 15
                    beq       L078b               If it equals 15 move on
*                         otherwise if not equal 15
                    sta       u00a6               stow that 1 at flag_water
                    ldb       ,y                  cx  first byte of cel_data  (cel_width)

*  do while cx != 0

L0752               lda       ,u+                 (pri) put byte at pb in acca and bump pointer
                    anda      #$F0                and that with $F0  (obstacle ??)
                    beq       L077a               if it equals 0 set flag_control =0 and check_finish

                    cmpa      #$30                compare pri to 48 (water ??)
                    beq       L0766               not equal  move to end of loop
                    clr       u00a6               clear the water flag
                    cmpa      #$10                compare it with 16 (conditional ??)
                    beq       L077e               if equal go test for observe blocks
                    cmpa      #$20                compare with 32
                    beq       L0787

L0766               decb                          decrement cx
                    bne       L0752               not zero yet loop again

                    lda       $25,x               load flags in  acca
                    tst       u00a6               test flag_water
                    bne       L0776               not zero next test
                    bita      #O_DRAWN            should be O_WATER Looks like a BUG in ours
                    beq       L078b               if it equals one head for check_finish
                    bra       L077a               clear that flag control first and leave
L0776               bita      #O_HRZNIGNORE       should be O_LAND  Looks like a BUG in ours
                    beq       L078b

L077a               clr       u005c               clear flag_control
                    bra       L078b               head for check_finish

L077e               lda       $26,x               load flags in acca
                    bita      #O_BLKIGNORE        and with $02 but don't change
                    beq       L077a               equals zero clear flag_control and go check_finish
                    bra       L0766               then  head back in the loop

L0787               sta       u00a5               store acca at flag signal (obj_picbuff.c has =1)
                    bra       L0766               continue with loop



L078b               lda       $02,x               load num
                    bne       L07bb               if not zero were done head out

* flag signal test
                    lda       u00a5               load flag_signal
*                         operates on F03_EGOSIGNAL
                    beq       L079d               if its zero go reset the signal
*                         otherwise set the flag
                    lda       X01af               load the state.flag element
                    ora       #$10                set the bits
                    sta       X01af               save it back
                    bra       L07a5               go test the water flag
L079d               lda       X01af               load the state.flag element
                    anda      #$ef                reset the bits
                    sta       X01af               save it back

* flag_water test
L07a5               lda       u00a6               load flag_water
                    beq       L07b3               if zero go reset the flag
*                         otherwise set it
                    lda       X01af               load the state.flag element
                    ora       #$80                set the bits
                    sta       X01af               save it back
                    bra       L07bb               baby we're out of here
L07b3               lda       X01af               load the state.flag element
                    anda      #$7f                reset the bits
                    sta       X01af               save it back

L07bb               puls      y                   retrieve our y and leave
                    rts


*  obj_blit(VIEW *v)   obj_blit.c
*  our index reg x points to the view structure
*  are 3 = x, 4 = y instead of 3-4 = x & 5-6 = y ???
*  u00a2 = cel_height
*  u00a7 = cel_trans
*  u00a8 = init (pb)
*  u00ac = cel_invis
*  u00ad = pb_pri
*  u009e = view_pri
*  u009f = col

L07be               ldx       $02,s               pull our x pointer off the stack
                    ldd       $08,x               load d with view_data
                    lbsr      L0074               twiddle mmu

                    ldu       $10,x               u now is a pointer to cel_data
                    lda       $02,u               cel_data[$02] loaded
                    bita      #O_Block            are we testing against a block or does $80 mean something else here?
                    beq       L07d1               if zero skip next instruction

                    lbsr      L087f               otherwise call obj_cell_mirror

L07d1               ldd       ,u++                load the first 2 bytes of cel_data and bump to next word
*                        cel_width is in acca we ignore
                    stb       u00a2               save as cel_height
*                        obj_blit.c has and $0F which is a divide by 16
*                        we do a multiply x 16 ???
                    lda       ,u+                 cel_trans
                    asla
                    asla
                    asla
                    asla
                    sta       u00a7               save as cel_tran

                    lda       $24,x               priority
                    asla                          shift left 4
                    asla
                    asla
                    asla
                    sta       u009e               view_pri

                    ldb       $04,x               load the y value
                    subb      u00a2               subtract the cel_height
                    incb                          add 1
                    lda       #$a0                set up PBUF_MULT()
                    mul                           do the math
                    addb      $03,x               add in the x value
                    adca      #0000               add in the carry from multiply
                    addd      #gfx_picbuff        add this to the start of the screen buff addr $6040
                    std       u00a8               pb pointer to the pic buffer
                    ldx       u00a8               load it in an index reg

                    lda       #$01
                    sta       u00ac               set cel_invis to 1 and save

                    bra       L0800
L07ff               abx                           bump the pb pointer

L0800               lda       ,u+                 get the next "chunk"
                    beq       L082d               if zero
                    ldb       -$01,u              not zero load the same byte in accb
                    anda      #$f0                and chunk with $F0 (col)
                    andb      #$0f                and chunk with $0F (chunk_len)
                    cmpa      u00a7               compare with cel_trans
                    beq       L07ff               set up and go again color is trasnparent
                    lsra                          shift right 4
                    lsra
                    lsra
                    lsra
                    sta       u009f               save the color

L0814               lda       ,x                  get the byte pointed to by pb
                    anda      #$f0                get the priority portion
                    cmpa      #$20                compare to $20
                    bls       L083b               less or equal
                    cmpa      u009e               compare to view_pri
                    bhi       L085b               pb_pri > view_pri
*                        otherwise
                    lda       u009e               load view_pri
L0822               ora       u009f               or it with col
                    sta       ,x+                 store that at pb and bump the pointer
                    clr       u00ac               zero cel_invis
                    decb                          decrement chunk_len
                    bne       L0814               not equal zero go again inner loop
                    bra       L0800               go again outer loop

L082d               dec       u00a2               decrement cel_height
                    beq       L0862               equal zero move on out of cel_height loop
                    ldx       u00a8               load init
                    leax      >PICBUFF_WIDTH,x    move 160 into screen
                    stx       u00a8               stow that back as init/pb
                    bra       L0800               go again

L083b               stx       u00ad               save the pointer
                    clra                          set up ch

L083e               cmpx      #blit_end           compare to gfx_picbuff+$6860
                    bhs       L084f               not less than then branch out
*                             less than the end
                    leax      >PICBUFF_WIDTH,x    bump the pointer by 160
                    lda       ,x                  get that byte
                    anda      #$f0                and it with $F0
                    cmpa      #$20                test against $20
                    bls       L083e               less or equal go again

L084f               ldx       u00ad               load pb_pri
                    cmpa      u009e               compare with view_pri
                    bhi       L085b               pb_pri > view_pri
                    lda       ,x                  make the next
                    anda      #$f0                pb_pri
                    bra       L0822               go or it with the color

L085b               leax      $01,x               bump the pb pointer
                    decb                          decrement chunk_len
                    bne       L0814               not equal do middle loop again
                    bra       L0800               go again

L0862               ldx       $02,s               pull our view pointer back off the stack
                    lda       $02,x               get the num
                    bne       L087e               if not zero exit routine
                    lda       u00ac               get the cel_invis value
                    beq       L0876               reset the flag

* set the flag
                    lda       X01af               load the state.flag
                    ora       #$40                set it
                    sta       X01af               stow it back
                    bra       L087e               exit routine

* reset the flag
L0876               lda       X01af               load state.flag
                    anda      #$bf                clear it
                    sta       X01af               stow it
L087e               rts


* obj_cel_mirror(View *v) in obj_picbuff.c
* we use different values from those shown nagi files
* on entry
*    a contains cell_data[$02] in call from obj_blit()
*    x contains pointer to view data
*    u contains pointer to cel_data
*
*    saves and restores x,y,u regs on exit
*
*  u00a1 = width
*  u00a2 = height_count
*  u00a7 = trans transparent color left shifted 4
*  u00aa = tran_size ??
*  u00ab = meat_size
*  u00af = loop_cur << 4
*  u00b0 = al


L087f               anda      #$30                and that with $30  (nagi has $70)
                    lsra                          shift right 4
                    lsra
                    lsra
                    lsra
                    cmpa      $0A,x               compare that with loop_cur
                    lbeq      L0926               if equal we're done

                    pshs      x,y,u               save our view (x) what ever (y) and cel_data (u) pointers

                    lda       $0A,x               load loop_cur
                    asla                          and shift it 4 left
                    asla
                    asla
                    asla
                    sta       u00af               stow it as ??
                    lda       #$cf                load a with with $CF  (nagi has $8F)
                    anda      $02,u               and that with cel[2]
                    ora       u00af               or with loop_cur<<4
                    sta       $02,u               stow it back at cel[2]

                    ldy       #gbuffend

                    ldd       ,u++                load d with width and hieght
                    std       u00a1               stow that
                    lda       ,u+                 load a with trans color
                    asla                          and shift left 4
                    asla
                    asla
                    asla
                    sta       u00a7               stow as trans
                    stu       u00b0               stow u as al
L08af               clrb                          make a zero
                    stb       u00ab               stow it as meat_size

*                      nagi code has tran_size set to width and
*                      al&$0F subtracted from it.
*                      in this loop

L08b2               stb       u00aa               and tran_size

                    lda       ,u+                 load in the next cel_data byte
                    beq       L08fc               if its a zero leave loop
                    ldb       -$01,u              otherwise fetch the same data into b
*                      at this point a & b both have the same data byte
                    anda      #$f0                and the a copy with $F0
                    andb      #$0f                and the b copy with $0F
                    cmpa      u00a7               compare byte&$F0 with trans
                    bne       L08cc               not equal branch out of loop
                    addb      u00aa               otherwise add in tran_size
                    bra       L08b2               and loop

L08c6               ldb       ,u+                 load the nbext byte and bump the pointer
                    beq       L08d4               if it was zero move on
                    andb      #$0f                otherwise and it with $0F
L08cc               addb      u00aa               add in tran_size
                    stb       u00aa               save it as tran_size
                    inc       u00ab               bump meat_size
                    bra       L08c6               loop to the next byte

L08d4               lda       u00aa               load tran_size
                    nega                          negate it
                    adda      u00a1               add in the width
                    beq       L08f1               if that is zero move on

L08db               suba      #$0f                subtract 15 from it
                    bls       L08eb               less or same move on
                    sta       u00aa               otherwise stow that back as tran_size
                    lda       u00a7               fetch trans
                    ora       #$0f                or it with 15
                    sta       ,y+                 store it at buff (gbuffend) and bump pointer
                    lda       u00aa               fetch tra_size
                    bra       L08db               loop again

L08eb               adda      #$0f                add 15 back into a (tran_size)
                    ora       u00a7               or that with trans
                    sta       ,y+                 stow that at buff and bump the pointer

L08f1               leax      -$01,u              set x to the last cel_data byte processed
                    ldb       u00ab               load b with the meat_size (the loop counter)
L08f5               lda       ,-x                 copy from the cel_data end
                    sta       ,y+                 to the buff front
                    decb                          dec the counter
                    bne       L08f5               not done loop again

L08fc               stb       ,y+                 on entry b should always = 0 stow that at the next buff location
                    dec       u00a2               decrement the height_count
                    bne       L08af               not zero go again

* now we are going to copy the backward temp buffer back to the cel
                    tfr       y,d                 get the buff pointer in d
                    subd      #gbuffend           subtract the starting value of the buffer
                    stb       u00b2               save that as the buffer size
                    andb      #$fe                make it an even number
                    tfr       d,x                 transfer that to x
                    ldu       u00b0               al cel_data pointer
                    ldy       #gbuffend           load y start of our temp buffer

L0913               ldd       ,y++                get a word
                    std       ,u++                stow a word
                    leax      -$02,x              dec the counter by a word
                    bne       L0913               not zero go again
*                      so we've moved an even number of bytes
                    lda       u00b2               load the actual byte count
                    lsra                          divide by 2
                    bcc       L0924               no remainder (not odd) we're done
                    lda       ,y                  otherwise move the last
                    sta       ,u                  byte
L0924               puls      x,y,u               retrieve our x,y,u values

L0926               rts                           and return to caller



* obj_add_pic_pri(VIEW *v)  obj_picbuff.c
* our index reg x points to the view structure
*
*  u009e = priority&$F0
*  u00a3 = pri_table[y]
*  u00a4 = pri_table[y]
*  u00a8 = pb (word)
*  u00a9 = "
*  u00b3 = pri_height/height

L0927               pshs      y                   save the y
                    ldx       $04,s               get the the pointer to our view
                    ldd       $08,x               load d with view_data ?
                    lbsr      L0074               twiddle mmu

*                      set up d as pointer to pri_table value
                    clra                          zero a
                    ldb       $04,x               load view y value
                    leau      L0654,pcr           load pri_table address
                    lda       d,u                 fetch the pri_table y data
                    std       u00a3               stow it in a temp
                    ldb       $24,x               load priority
                    andb      #$0f                and that with $0F
                    bne       L0948               if that equals zero move on
                    ora       $24,x               otherwise or the pri_table[y] with priority
                    sta       $24,x               stow that back as priority

L0948               pshs      x                   push the pointer to the view on the stack
                    lbsr      L07be               call obj_blit()
                    leas      $02,s               reset the stack
                    ldx       $04,s               get the pointer to our view
                    lda       $24,x               load priority
                    cmpa      #$3F                compare to $3F
                    lbhi      L09d5               if greater then nothing to do head out

                    leau      L0654,pcr           load pri_table address
                    ldb       u00a4               fetch pri_table[y] (cx)
                    clr       u00b3               clear pri_height
L0962               clra                          zero acca
                    inc       u00b3               bump pri_hieght
                    tstb                          is pri_table[y]
                    beq       L096f               equal zero if so move on
                    decb                          dec our counter cx
                    lda       d,u                 load pri_table[cx]
                    cmpa      u00a3               compare to pri_table[y]
                    beq       L0962               if they are equal loop again

* set up and execute PBUF_MULT call
L096f               ldb       $04,x               load the view->y in
                    lda       #$a0                from pbuf mult
                    mul                           do the math
                    addb      $03,x               add in the x value
                    adca      #0000               add in the carry
                    addd      #gfx_picbuff        add in the base address $6040
                    tfr       d,u                 move that to an index reg (pb)
                    stu       u00a8               stow it as pb

                    ldy       $10,x               load y with cel_data pointer
                    ldb       $01,y               get the second byte (height)
                    cmpb      u00b3               compare to pri_height
                    bhi       L098b               greater move on
                    stb       u00b3               otherwise save the largest as pri_height
L098b               lda       $24,x               load the priority again
                    anda      #$f0                and it with $F0
                    sta       u009e               stow that for later use

* bottom line
                    ldb       ,y                  load b with the first byte in cel_data (cx)
L0994               lda       ,u                  get the byte at our pic buff pb
                    anda      #$0f                and it with $0F
                    ora       u009e               or it with priority&F0
                    sta       ,u+                 stow it back and bump the pointer
                    decb                          dec the loop counter cx
                    bne       L0994               not zero go again

* it has a height
                    dec       u00b3               test "height" for > 1
                    beq       L09d5               wasn't head no more to do so head out
                    ldu       u00a8               reset u to our pb pic buff pointer

* the sides
                    ldb       ,y                  get the first byte of cel_data
                    decb                          subtract 1 (sideoff)
L09a8               leau      -$A0,u              decrement pb by 160
                    tfr       u,x                 move that value into x
                    lda       ,u                  get the data
                    anda      #$0f                and it with $0F
                    ora       u009e               or it priority&$F0
                    sta       ,u                  stow it back
                    clra                          zero a so we can use d as a pointer
                    lda       d,u                 use "sideoff" as an index into pb
                    anda      #$0f                and that with $0F
                    ora       u009e               or that rascal with priority&$F0
                    abx                           add that value to our x pointer
                    sta       ,x                  and store it there
                    dec       u00b3               dec the height
                    bne       L09a8               greater than zero go again

* the top of the box

                    ldb       ,y                  get the cel_data first byte in b
                    subb      #$02                subtract 2
                    leau      $01,u               bump the pb pointer
L09ca               lda       ,u                  grab the byte
                    anda      #$0f                and that with $0F
                    ora       u009e               or it with priority &$F0
                    sta       ,u+                 stow it back and bump the pointer
                    decb                          dec our counter
                    bne       L09ca               loop if not finished

L09d5               puls      y                   return the y value
                    rts                           return



* blit_save(BLIT *b) obj_blit.c
*  our blit_struct is a bit different from the one in nagi
*
* u00a0 = zeroed and never changed cause we use the next byte :-)
* u00a1 = x_count (x_size)         when cmpx ha ha
* u00a2 = y_count (y_size)
* u00a8 = pic buffer start pic_cur
* u00ad = pic_cur + offset

L09d8               ldu       $02,s               get the pointer to the blit_struct
                    ldd       $0C,u               get the pointer to the view_data for mmu twiddler
                    lbsr      L0074               twiddle mmu

                    ldu       $02,s               get the pointer to the blit_struct data back in u
                    ldd       $08,u               load the x/y_size
                    std       u00a1               stow that at x/y_count
                    clr       u00a0               zero some adder
                    ldb       $07,u               get the y value
                    lda       #$a0                set up PBUF_MULT
                    mul                           do the math
                    addb      $06,u               add in x
                    adca      #0                  add in the carry bit
                    addd      #gfx_picbuff        add in pic buff base $6040

                    ldu       $0A,u               load u with with the buffer pointer blit_cur
L09f5               std       u00a8               save the buffer start pointer pic_cur
                    addd      u00a0               add in the offset x_size
                    std       u00ad               stow that at pic_cur + offset
                    ldx       u00a8               load x with pic_cur
L09fd               ldd       ,x++                copy 2 bytes at a time
                    std       ,u++                to the buffer at blit_cur
                    cmpx      u00ad               have we copied it all ??
                    blo       L09fd               nope loop again

                    ldd       u00a8               load with pic buffer start
                    addd      #PICBUFF_WIDTH      add 160
                    dec       u00a2               dec y_count
                    bne       L09f5               not zero loop again
                    rts


* blit_restore(BLIT *b) obj_blit.c
* blit_save(BLIT *b) obj_blit.c
*  our blit_struct is a bit different from the one in nagi
*
* u00a0 = zeroed and never changed cause we use the next byte :-)
* u00a1 = x_count (x_size)         when cmpx ha ha
* u00a2 = y_count (y_size)
* u00a8 = pic buffer start pic_cur
* u00ad = pic_cur + offset

L0a0f               ldu       $02,s               get the pointer to the blit structure
                    ldd       $0C,u
                    lbsr      L0074               twiddle mmu

                    ldu       $02,s               get the blit_structure back in u
                    ldd       $08,u               load x/y_size
                    std       u00a1               stow them at x/y_count
                    clr       u00a0               clear the byte prior to x_size
                    ldb       $07,u               get the y value
                    lda       #$a0                set up PBUF_MULT
                    mul                           do the math
                    addb      $06,u               add in the x value
                    adca      #0                  add in the carry bit
                    addd      #gfx_picbuff        add in the base address $6040

                    ldu       $0A,u               load u with buffer pointer blit_cur
L0a2c               std       u00a8               save the screen start buffer pic_cur
                    addd      u00a0               add in the x_size
                    std       u00ad               stow at pic_cur + offset
                    ldx       u00a8               load x pic_cur pointer
L0a34               ldd       ,u++                grab em from the buffer
                    std       ,x++                and send them to the screen
                    cmpx      u00ad               moved them all ??
                    blo       L0a34               nope then keep on keeping on

                    ldd       u00a8               load the pic_cur pointer
                    addd      #PICBUFF_WIDTH      add 160
                    dec       u00a2               dec the y count
                    bne       L0a2c               not zero move some more
                    rts

                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcc       "shdw"
                    fcb       $00

                    emod
eom                 equ       *
                    end

