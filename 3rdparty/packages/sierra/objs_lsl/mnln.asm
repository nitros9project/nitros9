********************************************************************
* MNLN - Leisure Suit Larry main line module
*
* $Id$
*
*        Header for : mnln
*        Module size: $6372  #25458
*        Module CRC : $81A0CC (Good)
*        Hdr parity : $39
*        Exec. off  : $0012  #18
*        Data size  : $0000  #0
*        Edition    : $00  #0
*        Ty/La At/Rv: $11 $81
*        Prog mod, 6809 Obj, re-ent, R/O
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/06  Paul W. Zibaila
* Disassembly of original distribution; assembles to original mnln.
*
* NitrOS-9 has switched from the original to the code from Leisure Suit Larry. Paul's comments
* are mostly still believed to be accurate but locations may have moved and some things are likely wrong.
*
* New version disassembled 2010/03/28 11:51:53 by Disasm v1.5 (C) 1988 by RML
* April 10, 2010 - Code that writes to $FF20 was changed to prevent RS-232 line from trashing.
*                 The I/O port gets changed to make RS-232 an input.
*                 This solves multiple problems with DW3 application. Robert Gault
* April 28, 2010 - Adjusting the RS-232 input direction seems to cause other problems, probably at the other
*                 end of the RS-232 connection. I've gone back to masking the bit at $FF20. RG
* April 4,  2014 - Corrected the set.pri.base routine used in KQ4. GM & RG
* April 21, 2014 - Corrected the clear.text.rect routine. GM

*  >$0154  flag for using extended lookups
*  >$0541  joystick button status
*  >$0532  vol_handle_table
*  >$05B9  input_edit_disabled


StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

*  equates for direct page vars
*  shared with sierra module
u0000               equ       $00                 holds size of data block
u0009               equ       $09                 sierra - offset from entry to the routine for the remap call
u000A               equ       $0A
u0019               equ       $19                 scrn - offset from entry to the routine for the remap call
u0021               equ       $21                 shdw - offset from entry to the routine for the remap call
u0022               equ       $22                 sierra remap value holder
u0026               equ       $26                 scrn remap value holder
u0028               equ       $28                 shdw remap value holder
u002C               equ       $2C
u002E               equ       $2E
u0030               equ       $30
u0032               equ       $32
u0034               equ       $34
u0036               equ       $36
u0038               equ       $38
u003A               equ       $3A
u003C               equ       $3C
u003E               equ       $3E
u0040               equ       $40
u0041               equ       $41
u0042               equ       $42
u0043               equ       $43
u0045               equ       $45
u004B               equ       $4B
u004D               equ       $4D
u004F               equ       $4F
u0051               equ       $51
u0053               equ       $53
u0055               equ       $55
u0057               equ       $57
u0058               equ       $58
u005C               equ       $5C
u005F               equ       $5F
u0062               equ       $62
u0064               equ       $64
u0066               equ       $66
u0068               equ       $68
u0069               equ       $69
u006A               equ       $6A
u006C               equ       $6C
u006E               equ       $6E
u006F               equ       $6F
u0070               equ       $70
u0071               equ       $71
u0072               equ       $72
u0073               equ       $73
u0074               equ       $74
u0075               equ       $75
u0076               equ       $76
u0077               equ       $77                 open path counter
u0078               equ       $78                 path number holder
u0079               equ       $79
u007B               equ       $7B
u007D               equ       $7D
u007E               equ       $7E
u0080               equ       $80
u0081               equ       $81
u0083               equ       $83
u0084               equ       $84                 seek MSW
u0086               equ       $86                 seek LSW
u0088               equ       $88
u0089               equ       $89
u008B               equ       $8B
u008C               equ       $8C
u008D               equ       $8D
u008E               equ       $8E
u0090               equ       $90
u0092               equ       $92
u0094               equ       $94
u0096               equ       $96                 holds joystick number
u0097               equ       $97
u0098               equ       $98
u0099               equ       $99
u009A               equ       $9A
u009C               equ       $9C
u009D               equ       $9D


X0089               equ       $0089               ???

X0100               equ       $0100               pic_visible
X0101               equ       $0101
X0102               equ       $0102               clock_state

X0154               equ       $0154               flag for extended table look up
X0155               equ       $0155

X0157               equ       $0157
X0158               equ       $0158
X0159               equ       $0159
X015A               equ       $015A
X015B               equ       $015B
X015C               equ       $015C

X0167               equ       $0167

X0172               equ       $0172
X0173               equ       $0173
X0176               equ       $0176
X0177               equ       $0177
X0178               equ       $0178
X0179               equ       $0179
X017B               equ       $017B
X017C               equ       $017C
X017D               equ       $017D
X017E               equ       $017E
X017F               equ       $017F
X0180               equ       $0180
X01A9               equ       $01A9
X01AB               equ       $01AB
X01AD               equ       $01AD               state.block_state
X01AE               equ       $01AE               state.cursor
X01AF               equ       $01AF               state.flag
X01B0               equ       $01B0               state.flag
X01B1               equ       $01B1
X01D6               equ       $01D6
X01D7               equ       $01D7
X01D8               equ       $01D8
X023D               equ       $023D               state.block_x2
X023E               equ       $023E               state.block_y2
X0240               equ       $0240
X0241               equ       $0241               state.pic_num
X0242               equ       $0242
X0244               equ       $0244               state.script_saved
X0245               equ       $0245               state.script_count
X0246               equ       $0246
X0247               equ       $0247               state.status_state
X0248               equ       $0248
X0249               equ       $0249
X024B               equ       $024B

X024D               equ       $024D               state.text_fg
X024E               equ       $024E               state.text_bg

X024F               equ       $024F               state.block_x1
X0250               equ       $0250               state.block_y1
X0251               equ       $0251               state.ego_control_state

X0252               equ       $0252               state.string

X0432               equ       $0432               state.var[]
X0433               equ       $0433
X0434               equ       $0434
X0435               equ       $0435
X0436               equ       $0436
X0437               equ       $0437
X0438               equ       $0438
X0439               equ       $0439
X043A               equ       $043A
X043B               equ       $043B
X043C               equ       $043C
X043D               equ       $043D
X043E               equ       $043E
X043F               equ       $043F
X0440               equ       $0440
X0441               equ       $0441
X0442               equ       $0442
X0443               equ       $0443
X0444               equ       $0444
X0445               equ       $0445
X0446               equ       $0446
X0447               equ       $0447
X0448               equ       $0448
X044A               equ       $044A
X044B               equ       $044B
X044C               equ       $044C

X0532               equ       $0532
X0541               equ       $0541
X0542               equ       $0542
X0543               equ       $0543
X0545               equ       $0545
X0547               equ       $0547

X0550               equ       $0550               gfx_picbuffrotate
X0551               equ       $0551               given_pic_data
X0553               equ       $0553               display_type

X05AE               equ       $05AE
X05AF               equ       $05AF
X05B1               equ       $05B1               obj_displayed in obj_show()
X05B8               equ       $05B8
X05B9               equ       $05B9               input_edit_disabled
X05EC               equ       $05EC               chgen_textmode
X05ED               equ       $05ED
X0659               equ       $0659

XFF01               equ       $FF01               hsync control
XFF02               equ       $FF02               keyboard col
XFF03               equ       $FF03               vsync control
XFF20               equ       $FF20               d/a, cassette & rs232 out
XFF22               equ       $FF22               vdg control and rs-232 in
XFF23               equ       $FF23               control reg


XFFA9               equ       $FFA9               task 1 block 2


* Program equates
*  Cycle Types
CY_NORM             equ       0
CY_END              equ       1
CY_REVEND           equ       2
CY_REV              equ       3

*  Motion Types
MT_NORM             equ       0
MT_WANDER           equ       1
MT_FOLLOW           equ       2
MT_MOVE             equ       3
MT_EGO              equ       4

*  Loop Directions
RIGHT               equ       $00
LEFT                equ       $01
DOWN                equ       $02
UP                  equ       $03
IGNORE              equ       $04


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

                    nam       mnln
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
                    mod       eom,name,tylg,atrv,start,size

size                equ       .
name                equ       *
                    fcs       /mnln/
                    fcb       $00

* This module is linked to in sierra
* upon entry
*   a -> type language
*   b -> attributes / revision level
*   x -> address of the last byte of the module name + 1
*   y -> module entry point absolute address
*   u -> module header absolute address

start               equ       *
                    lbra      L00B9
L0015               fcc       /AGI (c) copyright 1988 SIERRA On-Line/
                    fcc       /CoCo3 version by Chris Iden/
                    fcb       0
L0056               fcc       /      Game paused./
                    fcb       $0a
                    fcc       /Press ENTER to continue./
                    fcb       0
L0082               fcc       /Press ENTER to quit./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to keep playing./
                    fcb       0

L00B9               leas      -6,s                make room on the stack
                    lbsr      L0488               modifies table values at 1B0
                    lbsr      L0D72               modifies table values at D09
                    lbsr      L2188               calls the mmu twiddler at >$659
*                         uses toc and words.tok

L00C4               clra
                    ldb       >$043B              ** who loads me with ??
                    std       ,s
L00CA               lbsr      L130A
L00CD               ldd       <$003E
                    cmpd      ,s
L00D2               bcc       L00DD
                    cmpd      $04,s
                    beq       L00CD
                    std       $04,s
                    bra       L00CA
L00DD               ldd       #$0000
                    std       <$003E
                    lbsr      L096F               self contained call to clear 50 bytes 05BA
L00E5               lda       >$01AE
                    anda      #$DF
L00EA               sta       >$01AE
                    lda       >$01AE
                    anda      #$F7
                    sta       >$01AE
                    lbsr      L5D63
                    ldx       <$0030
                    lda       >$0250
                    beq       L0107
                    lda       >$0437
                    sta       <$21,x
                    bra       L010D
L0107               lda       <$21,x
                    sta       >$0437
L010D               lbsr      L0750
                    lda       >$01AF
                    anda      #$40
                    sta       $03,s
                    lbsr      L5130
L011A               lda       >$0434
L011D               sta       $02,s
                    clrb
                    lbsr      L266C
                    leay      ,y
                    bne       L013B
                    clra
                    sta       >$043A
                    sta       >$0436
                    sta       >$0435
                    lda       >$01AE
                    anda      #$DF
                    sta       >$01AE
                    bra       L011A
L013B               lda       >$0437
                    ldx       <$0030
                    sta       <$21,x
                    lda       $02,s
                    cmpa      >$0434
                    bne       L0153
                    lda       >$01AF
                    anda      #$40
                    cmpa      $03,s
                    beq       L0156
L0153               lbsr      L5801
L0156               clra
                    sta       >$0436
                    sta       >$0435
                    lda       >$01AE
                    anda      #$FB
                    sta       >$01AE
                    lda       >$01AE
                    anda      #$FD
                    sta       >$01AE
                    lda       >$01AF
                    anda      #$F7
                    sta       >$01AF
                    lda       >$05EC
                    cmpa      #$00
                    lbne      L00C4
                    lbsr      L069E
                    lbra      L00C4

cmd_pause
L0184               lda       #$01
                    sta       >$0102              set clock_state = 1
                    lbsr      L12FC               events_clear
                    leau      >L0056,pcr          get addr of game paused msg
                    lbsr      L3AA7               pass it to message_box()
                    clr       >$0102              set clock_state = 0
                    rts

cmd_quit
L0197               lda       ,y+
                    cmpa      #$01
                    beq       L01A6               if arg was a 1 then quit
                    leau      >L0082,pcr          get addr of quit / continue msg
                    lbsr      L3AA7               pass it to message_box()
                    beq       L01AF               if we didn't get a 1 continue play

L01A6               lda       #$03                load the offset to exit_agi()
                    sta       <$0009
                    ldx       <$0022              set up to jump to sierra
                    jsr       >$0701              mmu twiddle
L01AF               rts

* every other word gets added to by a value saved in sierra
* when this module is loaded. I assume it's a mem offset
* Jump table of some kind  but what are the second words used
* to do ????

* the first word is the pointer to the function
* the second word holds two items
*   MSB = number of parameters
*   LSB = parameter flag

cmd_table
L01B0               fdb       L5A16,$0000         *do nothing
                    fdb       L5F08,$180          *increment
                    fdb       L5F16,$180          *decrement
                    fdb       L5F24,$280          *assign nn
                    fdb       L5F2F,$2c0          *assign nv
                    fdb       L5F40,$280          *add n
                    fdb       L5F4D,$2c0          *add v
                    fdb       L5F60,$280          *sub n
                    fdb       L5F6D,$2c0          *sub v
                    fdb       L5F81,$2c0          *l indirect v
                    fdb       L5FA9,$2c0          *r indirect
                    fdb       L5F98,$280          *l indirect n

                    fdb       L1701,$100          *set
                    fdb       L1705,$100          *reset
                    fdb       L1709,$100          *toggle
                    fdb       L170D,$180          *set v
                    fdb       L1717,$180          *reset v
                    fdb       L1721,$180          *toggle v

                    fdb       L323B,$100          *new room
                    fdb       L3240,$180          *new room v

                    fdb       L25A7,$100          *load logics
                    fdb       L25AC,$180          *load logics v
                    fdb       L2640,$100          *call
                    fdb       L2653,$180          *call v

                    fdb       L379A,$180          *load pic
                    fdb       L37FA,$180          *draw pic
                    fdb       L388B,$0000         *show pic
                    fdb       L389F,$180          *discard overlay
                    fdb       L3841,$180          *animate obj

                    fdb       L0CBC,$0000         *show pri

                    fdb       L603F,$100          *load view
                    fdb       L6046,$180          *load view v
                    fdb       L62A8,$100          *discard view

                    fdb       L0650,$100          *animate obj
                    fdb       L0686,$0000         *unanumate all

                    fdb       L0F6F,$100          *draw
                    fdb       L0FF4,$100          *erase

                    fdb       L38E9,$300          *position
                    fdb       L38FA,$360          *position v
                    fdb       L3919,$360          *get position
                    fdb       L3937,$360          *reposition

                    fdb       L60B3,$200          *set view
                    fdb       L60CE,$240          *set view v
                    fdb       L6118,$200          *set loop
                    fdb       L6133,$240          *set loop v

                    fdb       L053B,$100          *fix loop
                    fdb       L054D,$100          *release loop

                    fdb       L6196,$200          *set cel
                    fdb       L61B1,$240          *set cel v
                    fdb       L6243,$240          *last cel
                    fdb       L6258,$240          *current cel
                    fdb       L626C,$240          *current loop
                    fdb       L6280,$240          *current view
                    fdb       L6294,$240          *number of loops

                    fdb       L3FD7,$200          *set priority
                    fdb       L4015,$240          *set priority v
                    fdb       L3FEE,$100          *release priority
                    fdb       L4000,$240          *get priority

                    fdb       L05E9,$100          *stop update
                    fdb       L05F5,$100          *start update
                    fdb       L0601,$100          *force update

                    fdb       L39F6,$100          *ignore horizon
                    fdb       L3A08,$100          *observe horizon
                    fdb       L39F0,$100          *set horizon
                    fdb       L39BA,$100          *obj on water
                    fdb       L39CC,$100          *obj on land
                    fdb       L39DE,$100          *obj on anything

                    fdb       L08FA,$100          *ignore objects
                    fdb       L090C,$100          *observe objects
                    fdb       L091E,$320          *distance
                    fdb       L0A2A,$100          *stop cycling
                    fdb       L0A3C,$100          *start cycling
                    fdb       L09A2,$100          *normal cycle
                    fdb       L09B9,$200          *end of loop
                    fdb       L09DA,$100          *reverse cycle
                    fdb       L09F1,$200          *reverse loop
                    fdb       L0A12,$240          *cycle time

                    fdb       L2FB5,$100          *stop motion
                    fdb       L2FD3,$100          *start motion
                    fdb       L2FEF,$240          *step size
                    fdb       L3004,$240          *step time
                    fdb       L2EBF,$500          *move obj
                    fdb       L2F00,$570          *move obj v
                    fdb       L2F53,$300          *follow ego
                    fdb       L2F87,$100          *wander
                    fdb       L2FA6,$100          *normal motion
                    fdb       L301A,$240          *set dir

                    fdb       L302F,$240          *get dir

                    fdb       L085F,$100          *ignore blocks
                    fdb       L0871,$100          *observe blocks
                    fdb       L0841,$400          *block
                    fdb       L085B,$0000         *unblock

                    fdb       L330A,$100          *get
                    fdb       L3311,$180          *get v
                    fdb       L3318,$100          *drop
                    fdb       L3351,$200          *put
                    fdb       L335E,$240          *put v
                    fdb       L336B,$2c0          *get room v

                    fdb       L5391,$100          *load sound
                    fdb       L53ED,$200          *sound
                    fdb       L5A16,$0000         *stop sound
                    fdb       L3A5A,$100          *print
                    fdb       L3A62,$180          *print v
                    fdb       L3E35,$300          *display

                    fdb       L3E65,$3e0          *display v
                    fdb       L483A,$300          *clear lines
                    fdb       L4821,$0000         *text screen
                    fdb       L4833,$0000         *graphics
                    fdb       L5EB9,$100          *set cursor char
                    fdb       L486A,$200          *set text attribute
                    fdb       L5A14,$100          *shake screen
                    fdb       L48A3,$300          *config screen
                    fdb       L5863,$0000         *status line on
                    fdb       L586B,$0000         *status line off

                    fdb       L58EC,$200          *set string
                    fdb       L587F,$500          *get string
                    fdb       L5904,$200          *word to string
                    fdb       L3541,$100          *parse
                    fdb       L0BAA,$240          *get num
                    fdb       L5EA4,$0000         *prevent input
                    fdb       L5EB1,$0000         *accept inpur
                    fdb       L097A,$300          *set key
                    fdb       L368C,$700          *add to pic
                    fdb       L36AC,$7fe          *add to pic v
                    fdb       L5619,$0000         *status
                    fdb       L4567,$0000         *save game
                    fdb       L41D0,$0000         *restore game
                    fdb       L5A16,$0000         *init disk
                    fdb       L40BB,$0000         *restart game
                    fdb       L5156,$100          *sow obj
                    fdb       L12BD,$320          *random
                    fdb       L3044,$0000         *program control
                    fdb       L3048,$0000         *player control
                    fdb       L0BF4,$180          *obj status v
                    fdb       L0197,$100          *quit
                    fdb       L0CD4,$0000         *show mem
                    fdb       L0184,$0000         *pause
                    fdb       L5E4B,$0000         *echo line
                    fdb       L5E3D,$0000         *cancel line
                    fdb       L2367,$0000         *init joy
                    fdb       L48C2,$0000         *toggle monitor
                    fdb       L0CCC,$0000         *version
                    fdb       L49C2,$100          *script size
                    fdb       L59A8,$100          *set game id
                    fdb       L5A14,$100          *log
                    fdb       L26E0,$0000         *set scan start
                    fdb       L26E6,$0000         *reset scan start
                    fdb       L397A,$300          *reposition to
                    fdb       L3993,$360          *reposition to v
                    fdb       L5A5A,$0000         *trace on
                    fdb       L5ADB,$300          *trace info
                    fdb       L3A70,$400          *print at
                    fdb       L3A75,$480          *print at v
                    fdb       L62AD,$180          *discard view v
                    fdb       L484E,$500          *clear text rect
                    fdb       L5A12,$200          *set upper left
                    fdb       L2835,$100          *set menu
                    fdb       L28B3,$200          *set menu item
                    fdb       L2935,$0000         *submit menu
                    fdb       L2958,$100          *enable item
                    fdb       L297F,$100          *disable item
                    fdb       L29AE,$0000         *menu input
                    fdb       L514B,$100          *show obj v
                    fdb       L5A16,$0000         *open dialogue
                    fdb       L5A16,$0000         *close dialogue
                    fdb       L5FC0,$280          *mult n
                    fdb       L5FCE,$2c0          *mult v
                    fdb       L5FE2,$280          *div n
                    fdb       L5FF1,$2c0          *div v
                    fdb       L3C4C,$0000         *close window
                    fdb       L4552,$100          *set simple
                    fdb       L49D1,$0000         *push script
                    fdb       L49D8,$0000         *pop script
                    fdb       L5A16,$0000         *hold key
                    fdb       L115CB,$100         *set pri base, via patch stub
                    fdb       L5A14,$180          *discard sound
                    fdb       L5A16,$0000         *do nothing
                    fdb       L29BB,$100
                    fdb       L5A16,$0000         *do nothing
                    fdb       L5A0E,$400          *hide mouse
                    fdb       L5A12,$2c0          *allow menu
                    fdb       L5A16,$0000         *do nothing

L0488               leas      -$01,s
                    lda       #$B6
                    sta       ,s
                    leau      >L01B0,pcr
L0492               ldd       <$002E
                    addd      ,u
                    std       ,u
                    leau      $04,u
                    dec       ,s
                    bne       L0492
                    leas      $01,s
                    rts
L04A1               cmpb      #$B5
                    bls       L04AA
                    lda       #$10
                    lbsr      L10ED
L04AA               lda       <$0068
                    beq       L04B9
                    cmpa      #$01
                    bne       L04B9
                    pshs      y
                    lbsr      L5B10
                    puls      y
L04B9               leax      >L01B0,pcr
                    lda       #$04
                    mul
                    jsr       [d,x]
                    leay      ,y
                    beq       L04CE
                    ldb       ,y+
                    beq       L04CE
                    cmpb      #$FC
                    bcs       L04A1
L04CE               rts
L04CF               lda       <$25,u
                    bita      #$10
                    beq       L04DD
                    anda      #$EF
                    sta       <$25,u
                    bra       L053A
L04DD               ldd       $0E,u
                    decb
                    std       <$0074
                    lda       <$23,u
                    cmpa      #$00
                    bne       L04F3
                    ldb       <$0074
                    incb
                    cmpb      <$0075
                    bls       L0537
                    clrb
                    bra       L0537
L04F3               cmpa      #$03
                    bne       L0500
                    ldb       <$0074
                    decb
                    bpl       L0537
                    ldb       <$0075
                    bra       L0537
L0500               cmpa      #$02
                    bne       L050F
                    ldb       <$0074
                    beq       L0520
                    decb
                    bne       L0537
                    stb       <$0074
                    bra       L0520
L050F               cmpa      #$01
                    bne       L0537
                    ldb       <$0074
                    cmpb      <$0075
                    bcc       L0520
                    incb
                    cmpb      <$0075
                    bne       L0537
                    stb       <$0074
L0520               lda       <$27,u
                    lbsr      L172B
                    lda       <$26,u
                    anda      #$DF
                    sta       <$26,u
                    clra
                    sta       <$21,u
                    sta       <$23,u
                    ldb       <$0074
L0537               lbsr      L61D2
L053A               rts
L053B               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,x
                    lda       <$25,x
                    ora       #$20
                    sta       <$25,x
                    rts
L054D               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,x
                    lda       <$25,x
                    anda      #$DF
                    sta       <$25,x
                    rts
L055F               lda       #$01
                    ldb       <$26,u
                    andb      #$51
                    cmpb      #$51
                    beq       L056B
                    clra
L056B               rts
L056C               lda       #$01
                    ldb       <$26,u
                    andb      #$51
                    cmpb      #$41
                    beq       L0578
                    clra
L0578               rts
L0579               ldx       #$0548
                    leau      >L055F,pcr
                    lbsr      L33AE
                    rts
L0584               ldx       #$054C
                    leau      >L056C,pcr
                    lbsr      L33AE
                    rts
L058F               ldx       #$0548
                    lbsr      L3379
                    ldx       #$054C
                    lbsr      L3379
                    rts
L059C               bsr       L0584
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    bsr       L0579
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    rts
L05BB               ldx       #$054C
                    pshs      x
                    lda       #$18
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    ldx       #$0548
                    pshs      x
                    lda       #$18
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    rts
L05DC               ldx       #$0548
                    lbsr      L3391
                    ldx       #$054C
                    lbsr      L3391
                    rts
L05E9               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    bsr       L060A
                    rts
L05F5               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    bsr       L0624
                    rts
L0601               lda       ,y+
                    bsr       L058F
                    bsr       L059C
                    bsr       L05BB
                    rts
L060A               lda       <$26,u
                    bita      #$10
                    beq       L0623
                    pshs      u
                    lbsr      L058F
                    puls      u
                    lda       <$26,u
                    anda      #$EF
                    sta       <$26,u
                    lbsr      L059C
L0623               rts
L0624               lda       <$26,u
                    bita      #$10
                    bne       L063D
                    pshs      u
                    lbsr      L058F
                    puls      u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    lbsr      L059C
L063D               rts
L063E               fcb       4,4,0,0,0,4,1,1,1
L0647               fcb       4,3,0,0,0,2,1,1,1

L0650               lda       ,y+
                    bsr       L0655
                    rts
L0655               leas      -$01,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    cmpu      <$0032
                    bcs       L066C
                    lda       #$0D
                    ldb       ,s
                    lbsr      L10ED
L066C               lda       <$26,u
                    bita      #$40
                    bne       L0683
                    lda       #$70
                    sta       <$26,u
                    lda       #$00
                    sta       <$22,u
                    sta       <$23,u
                    sta       <$21,u
L0683               leas      $01,s
                    rts
L0686               lbsr      L058F
                    ldu       <$0030
L068B               cmpu      <$0032
                    bcc       L069D
                    lda       <$26,u
                    anda      #$BE
                    sta       <$26,u
                    leau      <$2B,u
                    bra       L068B
L069D               rts
L069E               leas      -$01,s
                    clr       ,s
                    ldu       <$0030
L06A4               cmpu      <$0032
                    bcc       L0716
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    bne       L0711
                    inc       ,s
                    ldb       #$04
                    lda       <$25,u
                    bita      #$20
                    bne       L06F7
                    lda       $0B,u
                    cmpa      #$03
                    bhi       L06D2
                    cmpa      #$02
                    bcs       L06F7
                    lda       <$21,u
                    leay      >L063E,pcr
                    ldb       a,y
                    bra       L06E6
L06D2               cmpa      #$04
                    beq       L06DD
                    lda       >$01B0
                    anda      #$08
                    beq       L06F7
L06DD               lda       <$21,u
                    leay      >L0647,pcr
                    ldb       a,y
L06E6               lda       $01,u
L06E8               cmpa      #$01
                    bne       L06F7
                    cmpb      #$04
                    beq       L06F7
                    cmpb      $0A,u
                    beq       L06F7
                    lbsr      L6154
L06F7               lda       <$26,u
                    bita      #$20
                    beq       L0711
                    lda       <$20,u
                    beq       L0711
                    dec       <$20,u
                    bne       L0711
                    lbsr      L04CF
                    lda       <$1F,u
                    sta       <$20,u
L0711               leau      <$2B,u
                    bra       L06A4
L0716               lda       ,s
                    beq       L074D
                    ldx       #$0548
                    lbsr      L3379
                    lbsr      L3067
                    lbsr      L0579
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldx       #$0548
                    pshs      x
                    lda       #$18
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    ldu       <$0030
                    lda       <$25,u
                    anda      #$F6
                    sta       <$25,u
L074D               leas      $01,s
                    rts
L0750               ldu       <$0030
L0752               cmpu      <$0032
                    bcc       L07A3
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    bne       L079E
                    lda       $01,u
                    cmpa      #$01
                    bne       L079E
                    lda       <$22,u
                    beq       L0784
                    cmpa      #$01
                    bne       L0774
                    lbsr      L62FE
                    bra       L0784
L0774               cmpa      #$02
                    bne       L077D
                    lbsr      L1758
                    bra       L0784
L077D               cmpa      #$03
                    bhi       L0784
                    lbsr      L31A4
L0784               lda       <$26,u
                    ldb       >$01AC
                    bne       L0793
                    anda      #$7F
                    sta       <$26,u
                    bra       L079E
L0793               bita      #$02
                    bne       L079E
                    lda       <$21,u
                    beq       L079E
                    bsr       L07A4
L079E               leau      <$2B,u
                    bra       L0752
L07A3               rts
L07A4               leas      -$03,s
                    ldd       $03,u
                    std       $01,s
                    lbsr      L0883
                    sta       ,s
                    lda       <$21,u
                    beq       L0821
                    cmpa      #$01
                    bne       L07C1
                    ldb       $02,s
                    subb      <$1E,u
                    lda       $01,s
                    bra       L081A
L07C1               cmpa      #$02
                    bne       L07CF
                    ldd       $01,s
                    adda      <$1E,u
                    subb      <$1E,u
                    bra       L081A
L07CF               cmpa      #$03
                    bne       L07DC
                    lda       $01,s
                    adda      <$1E,u
                    ldb       $02,s
                    bra       L081A
L07DC               cmpa      #$04
                    bne       L07EA
                    ldd       $01,s
                    adda      <$1E,u
                    addb      <$1E,u
                    bra       L081A
L07EA               cmpa      #$05
                    bne       L07F7
                    ldb       $02,s
                    addb      <$1E,u
                    lda       $01,s
                    bra       L081A
L07F7               cmpa      #$06
                    bne       L0805
                    ldd       $01,s
                    suba      <$1E,u
                    addb      <$1E,u
                    bra       L081A
L0805               cmpa      #$07
                    bne       L0812
                    lda       $01,s
                    suba      <$1E,u
                    ldb       $02,s
                    bra       L081A
L0812               ldd       $01,s
                    suba      <$1E,u
                    subb      <$1E,u
L081A               lbsr      L0883
                    cmpa      ,s
                    bne       L082B
L0821               lda       <$26,u
                    anda      #$7F
                    sta       <$26,u
                    bra       L083E
L082B               lda       <$26,u
                    ora       #$80
                    sta       <$26,u
                    clr       <$21,u
                    cmpu      <$0030
                    bne       L083E
                    clr       >$0437
L083E               leas      $03,s
                    rts
L0841               lda       #$01
                    sta       >$01AC
                    lda       ,y+
                    sta       >$024E
                    lda       ,y+
                    sta       >$024F
                    lda       ,y+
                    sta       >$023C
                    lda       ,y+
                    sta       >$023D
                    rts
L085B               clr       >$01AC
                    rts
L085F               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$02
                    sta       <$26,u
                    rts
L0871               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$FD
                    sta       <$26,u
                    rts
L0883               leas      -$01,s
                    clr       ,s
                    cmpa      >$024E
                    bls       L089D
                    cmpa      >$023C
                    bcc       L089D
                    cmpb      >$024F
                    bls       L089D
                    cmpb      >$023D
                    bcc       L089D
                    inc       ,s
L089D               lda       ,s
                    leas      $01,s
                    rts
L08A2               clra
                    ldb       <$25,u
                    bitb      #$02
                    bne       L08F9
                    ldx       <$0030
L08AC               cmpx      <$0032
                    bcc       L08F9
                    ldb       <$26,x
                    andb      #$41
                    cmpb      #$41
                    bne       L08F2
                    ldb       <$25,x
                    bitb      #$02
                    bne       L08F2
                    ldb       $02,x
                    cmpb      $02,u
                    beq       L08F2
                    ldb       $03,u
                    addb      <$1C,u
                    cmpb      $03,x
                    bcs       L08F2
                    ldb       $03,x
                    addb      <$1C,x
                    cmpb      $03,u
                    bcs       L08F2
                    ldb       $04,x
                    cmpb      $04,u
                    beq       L08F7
                    bhi       L08EA
                    ldb       <$1B,x
                    cmpb      <$1B,u
                    bhi       L08F7
                    bra       L08F2
L08EA               ldb       <$1B,x
                    cmpb      <$1B,u
                    bcs       L08F7
L08F2               leax      <$2B,x
                    bra       L08AC
L08F7               lda       #$01
L08F9               rts
L08FA               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$02
                    sta       <$25,u
                    rts
L090C               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    anda      #$FD
                    sta       <$25,u
                    rts
L091E               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,x
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$FF
                    ldb       <$26,x
                    bitb      #$01
                    beq       L0966
                    ldb       <$26,u
                    bitb      #$01
                    beq       L0966
                    lda       <$1C,u
                    lsra
                    adda      $03,u
                    ldb       <$1C,x
                    lsrb
                    addb      $03,x
                    stb       <$0076
                    suba      <$0076
                    bcc       L0953
                    nega
L0953               sta       <$0076
                    lda       $04,u
                    suba      $04,x
                    bcc       L095C
                    nega
L095C               adda      <$0076
                    bcs       L0964
                    cmpa      #$FF
                    bne       L0966
L0964               lda       #$FE
L0966               ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts
L096F               ldu       #$05BA
                    ldx       #$0032
                    clrb
                    lbsr      L2C7A
                    rts
L097A               ldx       #$01D8
                    lda       #$32
L097F               tst       ,x
                    beq       L098F
                    deca
                    bne       L098B
                    ldx       #$0000
                    bra       L098F
L098B               leax      $02,x
                    bra       L097F
L098F               lda       ,y+
                    ldb       ,y+
                    beq       L0999
                    tfr       b,a
                    adda      #$FB
L0999               ldb       ,y+
                    leax      ,x
                    beq       L09A1
                    std       ,x
L09A1               rts
L09A2               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$23,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts
L09B9               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$01
                    sta       <$23,u
                    ldd       <$25,u
                    ora       #$10
                    orb       #$30
                    std       <$25,u
                    lda       ,y+
                    sta       <$27,u
                    lbsr      L1732
                    rts
L09DA               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$03
                    sta       <$23,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts
L09F1               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$02
                    sta       <$23,u
                    ldd       <$25,u
                    ora       #$10
                    orb       #$30
                    std       <$25,u
                    lda       ,y+
                    sta       <$27,u
                    lbsr      L1732
                    rts
L0A12               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       <$1F,u
                    sta       <$20,u
                    rts
L0A2A               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$DF
                    sta       <$26,u
                    rts
L0A3C               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts

L0A4E               fcc       /normal cycle/
                    fcb       0
L0A5B               fcc       /end of loop/
                    fcb       0
L0A67               fcc       /reverse loop/
                    fcb       0
L0A74               fcc       /reverse cycle/
                    fcb       0
L0A82               fcc       /normal motion/
                    fcb       0
L0A90               fcc       /wander/
                    fcb       0
L0A97               fcc       /follow/
                    fcb       0
L0A9E               fcc       /move to (%d, %d)/
                    fcb       0
L0AAF               fcc       /Object %d:/
                    fcb       $0a
L0ABA               fcc       /x: %d  xsize: %d/
                    fcb       $0a
L0ACB               fcc       /y: %d  ysize: %d/
                    fcb       $0a
L0ADC               fcc       /pri: %d/
                    fcb       $0a
L0AE4               fcc       /stepsize: %d/
                    fcb       $0a
L0AF1               fcc       /control: %x/
                    fcb       $0a
L0AFD               fcc       /%s/
                    fcb       $0a
L0B00               fcc       /%s/
                    fcb       0
L0B03               fcc       /Adventure Game Interpreter/
                    fcb       $0a
                    fcc       /      Version 2.072/
                    fcb       0
L0B32               fcc       /room: %u/
                    fcb       $0a
L0B3B               fcc       /heap size: %u/
                    fcb       $0a
L0B49               fcc       /now: %u  max: %u/
                    fcb       $0a
L0B5A               fcc       /rm.0, etc.: %u/
                    fcb       $0a
L0B69               fcc       /common size: %u/
                    fcb       $0a
L0B79               fcc       /now: %u  max: %u/
                    fcb       $0a
L0B8A               fcc       /tables, etc.: %u/
                    fcb       $0a
L0B9B               fcc       /max script: %u/
                    fcb       0

L0BAA               leas      -$54,s
                    lbsr      L5E91
                    lda       $01d7
                    clrb
                    std       <$0040
                    ldb       ,y+
                    lbsr      L3E0D
                    leax      $04,s
L0BBD               ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3C6A
                    leas      $06,s
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    clr       ,s
                    ldb       #$04
                    leax      ,s
                    lbsr      L591D
                    lbsr      L5EC4
                    leax      ,s
                    lbsr      L11A0
                    beq       L0BE8
                    lbsr      L11FB
L0BE8               ldx       #$0431
                    ldb       ,y+
L0BED               abx
                    sta       ,x
                    leas      <$54,s
                    rts
* obj.status.v command
L0BF4               leas      >-$0194,s
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    std       >$0192,s
                    lda       <$23,u              cycle type
                    cmpa      #$00
                    bne       L0C18
                    leax      >L0A4E,pcr          normal cycle
                    bra       L0C30
L0C18               cmpa      #$01
                    bne       L0C22
                    leax      >L0A5B,pcr          end of loop
                    bra       L0C30
L0C22               cmpa      #$02
                    bne       L0C2C
                    leax      >L0A67,pcr          reverse loop
                    bra       L0C30
L0C2C               leax      >L0A74,pcr          reverse cycle
L0C30               stx       >$0190,s
                    lda       <$22,u              motion type
                    cmpa      #$00
                    bne       L0C41
                    leax      >L0A82,pcr          normal motion
                    bra       L0C71
L0C41               cmpa      #$01
                    bne       L0C4B
                    leax      >L0A90,pcr          wander
                    bra       L0C71
L0C4B               cmpa      #$02
                    bne       L0C55
                    leax      >L0A97,pcr          follow
                    bra       L0C71
L0C55               clra
                    ldb       <$28,u              y pos
                    pshs      b,a
                    ldb       <$27,u              x pos
                    pshs      b,a
                    leax      >L0A9E,pcr          move to (x,y)
                    pshs      x
                    leax      >$0132,s
                    pshs      x
                    lbra      stub1               format string into X
L0C6F               leas      $08,s
L0C71               pshs      x
                    ldx       >$0192,s
                    pshs      x
                    ldu       >$0196,s
                    ldd       <$25,u              flags
                    pshs      b,a
                    clra
                    ldb       <$1E,u              stepsize
                    pshs      b,a
                    ldb       <$24,u              priority
                    pshs      b,a
                    ldb       <$1D,u              ysize
                    pshs      b,a
                    ldb       $04,u               y pos
                    pshs      b,a
                    ldb       <$1C,u              xsize
                    pshs      b,a
                    ldb       $03,u               x pos
                    pshs      b,a
                    ldb       $02,u               object number
                    pshs      b,a
                    leau      >L0AAF,pcr          msg
                    pshs      u
                    leax      <$16,s
                    pshs      x
                    lbsr      L3ED6               format string
                    leas      <$18,s
                    lbsr      L3AA7               message box
                    leas      >$0194,s
                    rts
L0CBC               inc       >$0550
                    lbsr      L2E9B
                    lbsr      L13C3
                    lbsr      L2E9B
                    clr       >$0550
                    rts
L0CCC               leau      >L0B03,pcr
                    lbsr      L3AA7
                    rts
L0CD4               leas      >-$00C8,s
                    ldd       <$0057
                    pshs      b,a
                    ldd       <$0053
                    subd      #$0776
                    pshs      b,a
                    ldd       <$0051
                    subd      <$0053
                    pshs      b,a
                    ldd       <$0055
                    subd      <$0053
                    pshs      b,a
                    ldd       <0
                    subd      #$0776
                    pshs      b,a
                    ldd       <$004D
                    pshs      b,a
                    ldd       <$004B
                    pshs      b,a
                    ldd       <$004F
                    pshs      b,a
                    ldd       #$FFFF
                    pshs      b,a
                    clra
                    ldb       >$0431
                    leax      >L0B32,pcr
                    leau      <$12,s
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      <$18,s
                    lbsr      L3AA7
                    leas      >$00C8,s
                    rts

L0D26               fdb       $0f6e,$0000
                    fdb       $0dba,$280
                    fdb       $0dcb,$2c0
                    fdb       $0de2,$280
                    fdb       $0df3,$2c0
                    fdb       $0e0a,$280
                    fdb       $0e1b,$2c0
                    fdb       $0e32,$100
                    fdb       $0e3e,$180
                    fdb       $0e51,$100
                    fdb       $0e63,$240
                    fdb       $0f0a,$500
                    fdb       $0e7b,$100
                    fdb       $0e83,$0000
                    fdb       $0e9f,$0000
                    fdb       $0f02,$200
                    fdb       $0f2e,$500
                    fdb       $0f12,$500
                    fdb       $0f22,$500

L0D72               leas      -1,s
                    lda       #$13
L0D76               sta       ,s
                    leau      >L0D26,pcr
L0D7C               ldd       <$002E
                    addd      ,u
                    std       ,u
                    leau      $04,u
                    dec       ,s
                    bne       L0D7C
                    leas      $01,s
                    rts
L0D8B               leax      -$01,y
                    stx       <$006C
                    cmpa      #$12
                    bhi       L0DB2
                    lsla
                    lsla
                    leax      >L0D26,pcr
                    jsr       [a,x]
                    ldb       <$0068
                    beq       L0DB9
                    cmpb      #$01
                    bne       L0DB9
                    pshs      y
                    sta       <$006E
                    ldu       <$006C
                    lbsr      L5B38
                    puls      y
                    lda       <$006E
                    bra       L0DB9
L0DB2               tfr       a,b
                    lda       #$0F
                    lbsr      L10ED
L0DB9               rts
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbne      L0F6D
                    lbra      L0F6A
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    cmpa      ,x
                    lbne      L0F6D
                    lbra      L0F6A
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbcc      L0F6D
                    lbra      L0F6A
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    cmpa      ,x
                    lbcc      L0F6D
                    lbra      L0F6A
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbls      L0F6D
                    lbra      L0F6A
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    cmpa      ,x
                    lbls      L0F6D
                    lbra      L0F6A
                    lda       ,y+
                    lbsr      L1741
                    lbeq      L0F6D
                    lbra      L0F6A
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    lbsr      L1741
                    lbeq      L0F6D
                    lbra      L0F6A
                    rts
                    ldb       ,y+
                    ldx       <$0038
                    abx
                    abx
                    abx
                    lda       #$FF
                    cmpa      $02,x
                    lbne      L0F6D
                    lbra      L0F6A
                    ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       <$0038
                    abx
                    abx
                    abx
                    cmpa      $02,x
                    lbne      L0F6D
                    lbra      L0F6A
                    lda       ,y+
                    ldx       #$05BA
                    lda       a,x
                    rts
                    ldx       #$0431
                    lda       <$13,x
                    lbne      L0F6A
L0E8D               lbsr      L138E
                    cmpa      #$FF
                    beq       L0E8D
                    tsta
                    lbeq      L0F6D
                    sta       <$13,x
                    lbra      L0F6A
                    lda       ,y+
                    sta       <$0072
                    lda       >$015A
                    beq       L0EED
                    sta       <$0073
                    lda       >$01AE
                    anda      #$08
                    bne       L0EED
                    lda       >$01AE
                    anda      #$20
                    beq       L0EED
                    ldx       #$0194
L0EBB               lda       <$0072
                    beq       L0EED
                    ldb       ,y+
                    lda       ,y+
                    dec       <$0072
                    cmpd      #$270F
                    bne       L0ED5
                    lda       <$0072
                    beq       L0EF1
                    lsla
                    leay      a,y
                    lbra      L0EF1
L0ED5               tst       <$0073
                    bne       L0EDE
                    inc       <$0073
                    lbra      L0EED
L0EDE               cmpd      ,x++
                    beq       L0EE9
                    cmpd      #$0001
                    bne       L0EED
L0EE9               dec       <$0073
                    bra       L0EBB
L0EED               ldd       <$0072
                    bne       L0EFC
L0EF1               lda       >$01AE
                    ora       #$08
                    sta       >$01AE
                    lbra      L0F6A
L0EFC               lsla
                    leay      a,y
                    lbra      L0F6D
                    lda       ,y+
                    ldb       ,y+
                    lbsr      L59B9
                    rts
                    bsr       L0F3A
                    sta       <$006F
                    sta       <$0071
                    bra       L0F48
                    bsr       L0F3A
                    sta       <$006F
                    lda       <$1C,u
                    lsra
                    adda      <$006F
                    sta       <$006F
                    sta       <$0071
                    bra       L0F48
                    bsr       L0F3A
                    adda      <$1C,u
                    deca
                    sta       <$006F
                    sta       <$0071
                    bra       L0F48
                    bsr       L0F3A
                    sta       <$006F
                    adda      <$1C,u
                    deca
                    sta       <$0071
                    bra       L0F48
L0F3A               ldb       ,y+
                    lda       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldd       $03,u
                    stb       <$0070
                    rts
L0F48               ldd       <$006F
                    cmpa      ,y+
                    bcc       L0F52
                    leay      $03,y
                    bra       L0F6D
L0F52               cmpb      ,y+
                    bcc       L0F5A
                    leay      $02,y
                    bra       L0F6D
L0F5A               lda       <$0071
                    cmpa      ,y+
                    bls       L0F64
                    leay      $01,y
                    bra       L0F6D
L0F64               cmpb      ,y+
                    bls       L0F6A
                    bra       L0F6D
L0F6A               lda       #$01
                    rts
L0F6D               clra
                    rts
L0F6F               lda       ,y+
                    pshs      y
                    bsr       L0F78
                    puls      y
                    rts
L0F78               leas      -$03,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    cmpu      <$0032
                    bcs       L0F8F
                    lda       #$13
                    ldb       ,s
                    lbsr      L10ED
L0F8F               ldd       <$10,u
                    bne       L0F99
                    lda       #$14
                    lbsr      L10ED
L0F99               lda       <$26,u
                    bita      #$01
                    bne       L0FF1
                    stu       $01,s
                    ora       #$10
                    sta       <$26,u
                    lbsr      L164B
                    ldd       <$10,u
                    std       <$12,u
                    ldd       $08,u
                    std       <$14,u
                    ldd       $03,u
                    std       <$1A,u
                    ldx       #$0548
                    lbsr      L3379
                    ldu       $01,s
                    lda       <$26,u
                    ora       #$01
                    sta       <$26,u
                    lbsr      L0579
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldu       $01,s
                    lda       <$25,u
                    anda      #$EF
                    sta       <$25,u
                    pshs      u
                    lda       #$1B
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
L0FF1               leas      $03,s
                    rts
L0FF4               lda       ,y+
                    pshs      y
                    bsr       L0FFD
                    puls      y
                    rts
L0FFD               leas      -$04,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    cmpu      <$0032
                    bcs       L1014
                    lda       #$0C
                    ldb       ,s
                    lbsr      L10ED
L1014               lda       <$26,u
                    bita      #$01
                    beq       L1071
                    stu       $01,s
                    ldx       #$0548
                    lbsr      L3379
                    ldu       $01,s
                    lda       <$26,u
                    anda      #$10
                    sta       $03,s
                    bne       L1036
                    ldx       #$054C
                    lbsr      L3379
                    ldu       $01,s
L1036               lda       <$26,u
                    anda      #$FE
                    sta       <$26,u
                    lda       $03,s
                    bne       L1052
                    lbsr      L0584
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
L1052               lbsr      L0579
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldu       $01,s
                    pshs      u
                    lda       #$1B
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
L1071               leas      $04,s
                    rts

L1074               fcc       /Avis Durgan/
                    fcb       0

L1080               leas      -$02,s
                    stu       ,s
                    leau      >L1074,pcr
L1088               cmpx      ,s
                    bcc       L109C
                    tst       ,u
                    bne       L1094
                    leau      >L1074,pcr
L1094               lda       ,x
                    eora      ,u+
                    sta       ,x+
                    bra       L1088
L109C               leas      $02,s
                    rts

L109F               fcb       7,0
L10A1               fcb       $0a
                    fcc       /Press CTRL-BREAK to quit./
                    fcb       0
L10BC               fcb       $0a
                    fcc       /Press ENTER to try again./
                    fcb       0
L10D7               fcc       /System error #%u.%s%s/
                    fcb       0

L10ED               sta       $442
L10F0               stb       >$0443
                    lbsr      L27D4
                    lbsr      L12FC
                    lbsr      L22F3
                    bsr       L1136
                    bsr       L1136
                    lbsr      L5139
L1103               leas      >-$00B1,s
                    lbsr      L5E91
                    bsr       L1136
                    bsr       L1136
L110E               leau      >L10A1,pcr
                    pshs      u
                    leau      >L10BC,pcr
                    pshs      u
                    clra
                    ldb       <$009F
                    leau      >L10D7,pcr
                    leax      $04,s
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3ED6
                    leas      $0A,s
                    lbsr      L3AA7
                    leas      >$00B1,s
                    rts
L1136               pshs      y
                    ldy       #$0002
                    lda       #$01
L113E               leax      >L109F,pcr
                    os9       I$Write
                    puls      y
                    rts
L1148               fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fcb       $00
L1151               fcb       0
L1152               fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

* set.pri.base command
L115C               leas      -$04,s
                    clr       >L3378,pcr
                    ldb       ,y+
                    stb       $01,s
                    ldb       #$A8
                    subb      $01,s
                    lda       #$A8
                    mul
                    ldu       #$000A
                    lbsr      L125C
                    stu       $02,s               * Save the division result
                    clrb
                    stb       ,s
L1178               subb      $01,s
                    bcc       L1180
                    ldb       #$04
                    bra       L1193
L1180               lda       #$A8
                    mul
                    ldu       $02,s
                    lbsr      L125CB              * perform tfr u,d as well
                    addd      #$0005
                    cmpd      #$000F
                    bls       L1193
                    ldb       #$0F
L1193               stb       ,x+
                    inc       ,s
                    ldb       ,s
                    cmpb      #$A8
                    bcs       L1178
                    leas      $04,s
                    rts
L11A0               leas      -$02,s
                    stx       ,s
L11A4               lda       ,x+
                    bne       L11A4
                    tfr       x,d
                    ldx       ,s
                    subd      ,s
                    subd      #$0001
                    leas      $02,s
                    rts
L11B4               pshs      u
L11B6               lda       ,x+
                    sta       ,u+
                    bne       L11B6
                    puls      x
                    rts
L11BF               leas      -$04,s
                    std       ,s
                    stu       $02,s
L11C5               lda       ,x+
                    sta       ,u+
                    beq       L11D6
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bne       L11C5
                    clr       ,u
L11D6               ldx       $02,s
                    leas      $04,s
                    rts
L11DB               pshs      u
L11DD               lda       ,u+
                    bne       L11DD
                    leau      -$01,u
L11E3               lda       ,x+
                    sta       ,u+
                    bne       L11E3
                    puls      x
                    rts
L11EC               pshs      u,x
L11EE               lda       ,x
                    suba      ,u+
                    bne       L11F8
                    tst       ,x+
                    bne       L11EE
L11F8               puls      u,x
                    rts
L11FB               leas      -$02,s
                    clra
                    sta       ,s
                    sta       $01,s
L1202               ldb       ,x+
                    cmpb      #$20
                    beq       L1202
L1208               cmpb      #$30
                    bcs       L1221
                    cmpb      #$39
                    bhi       L1221
                    subb      #$30
                    stb       $01,s
                    lda       #$0A
                    ldb       ,s
                    mul
                    addb      $01,s
                    stb       ,s
                    ldb       ,x+
                    bne       L1208
L1221               lda       ,s
                    leas      $02,s
                    rts
L1226               leax      >L1151,pcr
                    clr       ,x
L122C               ldu       #$000A
                    bsr       L125C
                    addb      #$30
                    stb       ,-x
                    tfr       u,d
                    cmpd      #$0000
                    bhi       L122C
                    rts
L123E               leax      >L1151,pcr
                    clr       ,x
L1244               ldu       #$0010
                    bsr       L125C
                    addb      #$30
                    cmpb      #$39
                    ble       L1251
                    addb      #$07
L1251               stb       ,-x
                    tfr       u,d
                    cmpd      #$0000
                    bhi       L1244
                    rts
L125C               leas      -$05,s
                    std       ,s
                    stu       $02,s
                    lda       #$10
                    sta       $04,s
                    ldd       #$0000
L1269               lsl       $01,s
                    rol       ,s
                    rolb
                    rola
                    cmpd      $02,s
                    bcs       L1278
                    subd      $02,s
                    inc       $01,s
L1278               dec       $04,s
                    bne       L1269
                    ldu       ,s
                    leas      $05,s
                    rts
L1281               leas      -$0B,s
                    pshs      x,b
                    tfr       u,x
                    leau      $04,s
                    lbsr      L11B4
                    lbsr      L11A0
                    stb       $03,s
                    leau      >L1152,pcr
                    ldx       #$000A
                    ldb       #$30
                    lbsr      L2C7A
                    puls      b
                    subb      $02,s
                    bpl       L12A4
                    clrb
L12A4               clr       b,u
                    leax      $03,s
                    lbsr      L11DB
                    tfr       x,u
                    puls      x
                    leas      $0B,s
                    rts
L12B2               cmpa      #$41
                    bcs       L12BC
                    cmpa      #$5A
                    bhi       L12BC
                    ora       #$20
L12BC               rts
L12BD               lbsr      L4032
                    lda       $01,y
                    suba      ,y++
                    inca
                    bne       L12CB
                    tfr       b,a
                    bra       L12D0
L12CB               lbsr      L6006
                    adda      -$02,y
L12D0               ldx       #$0431
                    ldb       ,y+
                    abx
                    sta       ,x
                    rts
L12D9               tst       ,x
                    bne       L12E2
                    ldx       #$0000
                    bra       L12E8
L12E2               cmpa      ,x+
                    bne       L12D9
                    leax      -$01,x
L12E8               rts
L12E9               tfr       u,x
L12EB               lda       ,x
                    beq       L12F5
                    bsr       L12B2
                    sta       ,x+
                    bra       L12EB
L12F5               rts
L12F6               lbsr      L2367
                    bsr       L12FC
                    rts
L12FC               lbsr      L252E
                    lbsr      L23B5
                    ldx       #$0103
                    stx       <$0092
                    stx       <$0094
                    rts
L130A               lbsr      L23BB
                    lbsr      L2535
                    rts
L1311               ldu       <$0092
                    stb       ,u+
                    sta       ,u+
                    stu       <$0092
                    ldx       #$012B
                    cmpx      <$0092
                    bhi       L1325
                    ldx       #$0103
                    stx       <$0092
L1325               ldx       <$0092
                    cmpx      <$0094
                    bne       L132F
                    leau      -$02,u
                    stu       <$0092
L132F               rts
L1330               ldd       <$0094
                    cmpd      <$0092
                    bne       L133C
                    ldx       #$0000
                    bra       L1351
L133C               ldx       #$0002
                    leax      d,x
                    stx       <$0094
                    ldx       #$012B
                    cmpx      <$0094
                    bhi       L134F
                    ldx       #$0103
                    stx       <$0094
L134F               tfr       d,x
L1351               rts
L1352               leas      -$02,s
L1354               ldd       >$024A
                    std       ,s
                    bsr       L1330
                    leax      ,x
                    bne       L136C
L135F               ldd       ,s
                    cmpd      >$024A
                    beq       L135F
                    lbsr      L130A
                    bra       L1354
L136C               lbsr      L13CB
                    leas      $02,s
                    rts
L1372               leax      ,x
                    beq       L138D
                    ldb       ,x
                    cmpb      #$01
                    bne       L138D
                    ldu       #$01D8
L137F               ldb       ,u++
                    beq       L138D
                    cmpb      $01,x
                    bne       L137F
                    lda       #$03
                    ldb       -$01,u
                    std       ,x
L138D               rts
L138E               lbsr      L130A
                    bsr       L1330
                    tfr       x,d
                    leax      ,x
                    beq       L13A3
                    bsr       L13CB
                    lda       ,x
                    cmpa      #$01
                    bne       L13A4
                    lda       $01,x
L13A3               rts
L13A4               lda       #$FF
                    rts
L13A7               bsr       L138E
                    beq       L13A7
                    cmpa      #$FF
                    beq       L13A7
                    rts
L13B0               bsr       L138E
                    tfr       a,b
                    lda       #$01
                    cmpb      #$0D
                    beq       L13C2
                    lda       #$00
                    cmpb      #$1B
                    beq       L13C2
                    lda       #$FF
L13C2               rts
L13C3               lbsr      L12FC
L13C6               bsr       L13B0
                    bmi       L13C6
                    rts
L13CB               lda       ,x
                    cmpa      #$01
                    bne       L13E3
                    lda       $01,x
                    cmpa      #$FC
                    bne       L13DB
                    lda       #$0D
                    bra       L13E1
L13DB               cmpa      #$FE
                    bne       L13E3
                    lda       #$1B
L13E1               sta       $01,x
L13E3               rts
L13E4               fcb       5,2
L13E6               fcc       /./
L13E7               fcc       /./
                    fcb       $0d,0
L13EA               pshs      x,d
                    bsr       L1428
                    clr       <$9f
                    puls      d,x
                    os9       I$Create
                    bcc       L13FA
                    lbsr      L163D
L13FA               rts
L13FB               clr       <$009F
                    os9       I$Open
                    bcc       L1405
                    lbsr      L163D
L1405               rts
L1406               clr       <$009F
                    os9       I$Read
                    bcc       L1414
                    lbsr      L163D
                    ldy       #$0000
L1414               tfr       y,d
                    rts
L1417               clr       <$009F
                    os9       I$Write
                    bcc       L1425
                    lbsr      L163D
                    ldy       #$0000
L1425               tfr       y,d
                    rts
L1428               clr       <$009F
                    os9       I$Delete
                    bcc       L1432
                    lbsr      L163D
L1432               rts
L1433               clr       <$009F
                    os9       I$Close
                    bcc       L143D
                    lbsr      L163D
L143D               rts
L143E               clr       <$009F
                    tstb
                    bne       L1451
                    os9       I$Seek
                    bcc       L1479
L1448               lbsr      L163D
                    ldy       #$0000
                    bra       L1479
L1451               stx       <$0084
                    stu       <$0086
                    leau      >L13E3,pcr
                    ldb       b,u
                    os9       I$GetStt
                    bcs       L1448
                    pshs      a
                    tfr       u,d
                    addd      <$0086
                    tfr       d,u
                    tfr       x,d
                    adcb      #$00
                    adca      #$00
                    addd      <$0084
                    tfr       d,x
                    puls      a
                    os9       I$Seek
                    bcs       L1448
L1479               rts
                    clr       <$009F
                    os9       I$Dup
                    bcc       L1484
                    lbsr      L163D
L1484               rts
L1485               leas      <-$22,s
                    sty       ,s
                    clra
                    sta       ,y
                    sta       <$0077
                    leax      >L13E7,pcr
                    lbsr      L15B9
                    bcs       L14B7
                    sta       <$0078
                    ldb       #$0E
                    leax      $02,s
                    os9       I$GetStt
                    bcs       L14B7
                    ldy       ,s
                    ldb       #$2F
                    stb       ,y+
                    ldd       ,x++
                    andb      #$7F
                    std       ,y++
                    ldb       #$2F
                    stb       ,y+
                    clr       ,y
L14B7               lbsr      L15CC
                    leas      <$22,s
                    rts
L14BE               leas      -$0A,s
                    leay      ,s
                    bsr       L1485
                    leax      $01,s
                    ldd       #$0002
                    lbsr      L11BF
                    tfr       x,u
                    lbsr      L12E9
                    ldd       ,u
                    subb      #$30
                    cmpa      #$64
                    beq       L14DB
                    orb       #$10
L14DB               stb       $03,u
                    leas      $0A,s
                    rts
L14E0               leas      >-$00C2,s
                    stu       ,s
                    clra
                    sta       <$0077
                    leax      >$00A1,s
                    sta       ,x
                    stx       <$0079
                    leax      >L13E7,pcr
                    lbsr      L15B9
                    sta       <$0078
                    leax      >$00A2,s
                    lbsr      L1594
L1501               ldd       <$0081
                    std       <$007B
                    lda       <$0083
                    sta       <$007D
                    ldx       #$0081
                    ldy       #$007E
                    lbsr      L15AD
                    beq       L154E
                    leax      >L13E6,pcr
                    lbsr      L15D6
                    lbsr      L15CC
                    bcs       L156A
                    leax      >L13E7,pcr
                    lbsr      L15B9
                    leax      >$00A2,s
                    bsr       L1594
L152E               leax      >$00A2,s
                    lda       <$0078
                    lbsr      L15C3
                    bcs       L156A
                    leax      <$1D,x
                    ldy       #$007B
                    bsr       L15AD
                    bne       L152E
                    leax      >$00A2,s
                    bsr       L1577
                    bcs       L156A
                    bra       L1501
L154E               lbsr      L15CC
                    leay      >$00A2,s
                    lbsr      L1485
                    leax      >$00A2,s
                    bsr       L1577
                    bcs       L156A
                    ldu       ,s
                    ldx       <$0079
                    lbsr      L11B4
                    lbsr      L15D6
L156A               ldu       ,s
                    lbsr      L12E9
                    lbsr      L15CC
                    leas      >$00C2,s
                    rts
L1577               os9       F$PrsNam
                    bcs       L1593
                    ldx       <$0079
L157E               lda       ,-y
                    anda      #$7F
                    sta       ,-x
                    decb
                    bne       L157E
                    cmpa      #$2F
                    beq       L1591
                    lda       #$2F
                    sta       ,-x
                    andcc     #$FE
L1591               stx       <$0079
L1593               rts
L1594               bsr       L15C3
                    ldd       <$1D,x
                    std       <$007E
                    lda       <$1F,x
                    sta       <$0080
                    bsr       L15C3
                    ldd       <$1D,x
                    std       <$0081
                    lda       <$1F,x
                    sta       <$0083
                    rts
L15AD               ldd       ,x++
                    cmpd      ,y++
                    bne       L15B8
                    lda       ,x
                    cmpa      ,y
L15B8               rts
L15B9               lda       #$81
                    lbsr      L13FB
                    bcs       L15C2
                    inc       <$0077
L15C2               rts
L15C3               lda       <$0078
                    ldy       #$0020
                    lbra      L1406
L15CC               lda       <$0078
                    lbsr      L1433
                    bcs       L15D5
                    clr       <$0077
L15D5               rts
L15D6               clr       <$009F
                    lda       #$81
                    os9       I$ChgDir
                    bcc       L15E2
                    lbsr      L163D
L15E2               rts
                    lda       $05,s
                    ldy       $02,s
                    lbsr      L13FB
                    bcs       L15F1
                    ldx       $06,s
                    bsr       L15F4
L15F1               lda       <$009F
                    rts
L15F4               clr       <$009F
                    ldb       #$0F
                    ldy       #$0010
                    os9       I$GetStt
                    bcc       L1603
                    bsr       L163D
L1603               rts
L1604               leas      <-$14,s
                    leax      ,s
                    bsr       L15F4
                    leax      $03,x
                    clrb
                    lda       ,x
                    suba      #$50
                    lsla
                    std       <$10,s
                    ldb       $01,x
                    lda       #$20
                    mul
                    addd      <$10,s
                    addb      $02,x
                    adca      #$00
                    std       <$10,s
                    clrb
                    lda       $03,x
                    lsla
                    lsla
                    lsla
                    std       <$12,s
                    ldb       $04,x
                    lda       #$20
                    mul
                    addd      <$12,s
                    ldx       <$10,s
                    leas      <$14,s
                    rts
L163D               pshs      cc
                    cmpb      #$D8
                    bne       L1646
                    lda       #$FF
                    clrb
L1646               stb       <$009F
                    puls      cc
                    rts
L164B               leas      -$05,s
                    stu       ,s
                    clra
                    sta       $03,s
                    inca
                    sta       $02,s
                    sta       $04,s
                    lda       >$01D6
                    cmpa      $04,u
                    bcs       L1668
                    ldb       <$26,u
                    bitb      #$08
                    bne       L1668
                    inca
                    sta       $04,u
L1668               lbsr      L16D2
                    tsta
                    beq       L1687
                    lbsr      L08A2
                    tsta
                    bne       L1687
                    pshs      u
                    lda       #$03
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldu       ,s
                    lda       <$005C
                    bne       L16CF
L1687               lda       $03,s
                    bne       L1699
                    dec       $03,u
                    dec       $04,s
                    bne       L1668
                    inc       $03,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1668
L1699               cmpa      #$01
                    bne       L16AD
                    inc       $04,u
                    dec       $04,s
                    bne       L1668
                    inc       $03,s
                    inc       $02,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1668
L16AD               cmpa      #$02
                    bne       L16BF
                    inc       $03,u
                    dec       $04,s
                    bne       L1668
                    inc       $03,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1668
L16BF               dec       $04,u
                    dec       $04,s
                    bne       L1668
                    clr       $03,s
                    inc       $02,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1668
L16CF               leas      $05,s
                    rts
L16D2               clra
                    ldb       $03,u
                    addb      <$1C,u
                    bcs       L16F8
                    cmpb      #$A0
                    bhi       L16F8
                    ldb       $04,u
                    cmpb      #$A7
                    bhi       L16F8
                    incb
                    cmpb      <$1D,u
                    bcs       L16F8
                    decb
                    cmpb      >$01D6
                    bhi       L16F7
                    ldb       <$26,u
                    bitb      #$08
                    beq       L16F8
L16F7               inca
L16F8               rts
L16F9               fcb       $80,$40,$20,$10,8,4,2,1



L1701               lda       ,y+
                    bra       L172B


L1705               lda       ,y+
                    bra       L1732


L1709               lda       ,y+
                    bra       L173A

L170D               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    bra       L172B

L1717               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    bra       L1732

L1721               ldb       ,y+
                    ldx       #$431
                    abx
                    lda       ,x
                    bra       L173A

L172B               bsr       L1746
                    ora       ,x
                    sta       ,x
                    rts

L1732               bsr       L1746
                    coma
                    anda      ,x
                    sta       ,x
                    rts

L173A               bsr       L1746
                    eora      ,x
                    sta       ,x
                    rts
L1741               bsr       L1746
                    anda      ,x
                    rts
L1746               tfr       a,b
                    leax      >L16F9,pcr
                    anda      #$07
                    lda       a,x
                    lsrb
                    lsrb
                    lsrb
                    ldx       #$01AE
                    abx
                    rts
L1758               leas      -$05,s
                    ldb       <$27,u
                    pshs      b,a
                    ldx       <$0030
                    lda       <$1C,x
                    lsra
                    adda      $03,x
                    ldb       $04,x
                    std       $03,s
                    pshs      b,a
                    lda       <$1C,u
                    lsra
                    adda      $03,u
                    sta       $07,s
                    ldb       $04,u
                    pshs      b,a
                    lbsr      L31E6
                    leas      $06,s
                    sta       ,s
                    bne       L1790
                    sta       <$21,u
                    sta       <$22,u
                    lda       <$28,u
                    lbsr      L172B
                    bra       L17FD
L1790               lda       <$29,u
                    cmpa      #$FF
                    bne       L179C
                    clr       <$29,u
                    bra       L17F8
L179C               lda       <$25,u
                    bita      #$40
                    beq       L17E6
L17A3               lbsr      L4032
                    lda       #$09
                    lbsr      L6006
                    sta       <$21,u
                    beq       L17A3
                    ldb       $03,s
                    subb      $01,s
                    bcc       L17B7
                    negb
L17B7               stb       $04,s
                    ldb       $04,u
                    subb      $02,s
                    bcc       L17C0
                    negb
L17C0               clra
                    addb      $04,s
                    adca      #$00
                    lsra
                    rorb
                    incb
                    stb       $04,s
                    lda       <$1E,u
                    sta       <$29,u
                    cmpa      $04,s
                    bcc       L17FD
L17D4               lbsr      L4032
                    lda       $04,s
                    lbsr      L6006
                    cmpa      <$1E,u
                    bcs       L17D4
                    sta       <$29,u
                    bra       L17FD
L17E6               lda       <$29,u
                    beq       L17F8
                    clr       <$29,u
                    suba      <$1E,u
                    bcs       L17FD
                    sta       <$29,u
                    bra       L17FD
L17F8               lda       ,s
                    sta       <$21,u
L17FD               leas      $05,s
                    rts
L1800               fcb       1
L1801               fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L1820               fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L183F               fcb       0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L187F               fcc       /save/
                    fcb       0
L1884               fcc       /restore/
                    fcb       0
L188C               fcc       / - %s/
                    fcb       0
L1892               fcc       /How would you like to describe this saved game?/
                    fcb       $0a,$0a,0
L18C4               fcc       /Please put your save game/
                    fcb       $0a
                    fcc       /disk in drive %s./
                    fcb       $0a,$0a
                    fcc       /Press ENTER to continue./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to not/
                    fcb       $0a
L1922               fcc       /%s a game./
                    fcb       0
L192D               fcc       '(For example, "/d1" or "/h0/savegame")'
                    fcb       0
L1954               fcc       /         SAVE GAME/
                    fcb       $0a,$0a
                    fcc       /On which disk or in which directory do you wish to save this game?/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a,0
L19B1               fcc       /        RESTORE GAME/
                    fcb       $0a,$0a
                    fcc       /On which disk or in which directory is the game that you want to restore?/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a,0
L1A17               fcc       /Use the arrow keys to move/
                    fcb       $0a
                    fcc       /     the pointer to your name./
                    fcb       $0a
                    fcc       /Then press ENTER./
                    fcb       $0a,0
L1A64               fcc       /There is no directory named:/
                    fcb       $0a
                    fcc       /%s./
                    fcb       $0a
                    fcc       /Press ENTER to try again./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to cancel./
                    fcb       0
L1ABB               fcc       /There are no games to/
                    fcb       $0a
                    fcc       /restore in:/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /Press ENTER to continue./
                    fcb       0

L1AFB               fcc       /Use the arrow keys to select the slot in which you wish to save the game. /
                    fcc       /Press ENTER to save in the slot, /
                    fcc       /CTRL-BREAK to not save a game./
                    fcb       0

L1B85               fcc       /Use the arrow keys to select the game which you wish to restore. /
                    fcc       /Press ENTER to restore the game, /
                    fcc       /CTRL-BREAK to not restore a game./
                    fcb       0

L1C09               fcc       /   Sorry, this disk is full./
                    fcb       $0a
                    fcc       /Position pointer and press ENTER/
                    fcb       $0a
                    fcc       /    to overwrite a saved game/
                    fcb       $0a
                    fcc       /or press CTRL-BREAK and try again/
                    fcb       $0a
                    fcc       /    with another disk./
                    fcb       $0a,0


L1C9F               leas      -$02,s
                    clr       $01,s
                    lda       >$05B9
                    sta       ,s
                    lbsr      L5E91
                    lbsr      L4903
                    lbsr      L4A5F
                    ldd       #$000F
                    lbsr      L486F
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L1D66
                    leas      $02,s
L1CC0               beq       L1D01
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L1D13
                    leas      $02,s
                    beq       L1D01
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L1E36
                    leas      $02,s
                    sta       $01,s
                    beq       L1D01
                    lda       $05,s
                    cmpa      #$73
                    bne       L1CF8
                    lda       >L449A,pcr
                    bne       L1CF8
                    leax      >L1820,pcr
                    leau      >L1892,pcr
                    lbsr      L1DD9
                    tsta
L1CF2               bne       L1CF8
                    clr       $01,s
                    bra       L1D01
L1CF8               leax      >L183F,pcr
                    ldb       $01,s
                    lbsr      L46E5
L1D01               lbsr      L4A73
                    lbsr      L4918
                    lda       ,s
                    beq       L1D0E
                    lbsr      L5E80
L1D0E               lda       $01,s
                    leas      $02,s
                    rts
L1D13               leas      >-$00A5,s
                    lda       #$01
                    sta       ,s
                    leau      >$00A1,s
                    lbsr      L14BE
                    lda       >L46D8,pcr
                    cmpa      >$00A4,s
                    bne       L1D5F
                    cmpa      #$10
                    bcc       L1D5F
                    lbsr      L4EBE
                    leau      >L187F,pcr
                    lda       >$00A8,s
                    cmpa      #$73
                    beq       L1D43
                    leau      >L1884,pcr
L1D43               pshs      u
                    leau      >$00A3,s
                    pshs      u
                    leau      >L18C4,pcr
                    leax      $05,s
                    pshs      u
                    pshs      x
                    lbsr      L3ED6
                    leas      $08,s
                    lbsr      L3AA7
                    sta       ,s
L1D5F               lda       ,s
                    leas      >$00A5,s
                    rts
L1D66               leas      >-$00C8,s
                    lda       >L1801,pcr
                    bne       L1D79
                    leau      >L1801,pcr
                    lbsr      L14E0
                    leas      ,s
L1D79               tst       >L449A,pcr
                    bne       L1DD4
L1D7F               leau      >L192D,pcr
                    pshs      u
                    leau      >L1954,pcr
                    ldb       >$00CD,s
                    cmpb      #$73
                    beq       L1D95
                    leau      >L19B1,pcr
L1D95               leax      $02,s
                    pshs      u
                    pshs      x
                    lbsr      L3ED6
                    leas      $06,s
                    leax      >L1801,pcr
                    lbsr      L1DD9
                    tsta
                    beq       L1DD4
                    leau      >L1801,pcr
                    lbsr      L12E9
                    pshs      u
                    lbsr      L472D
                    leas      $02,s
                    bne       L1DD4
                    leau      >L1801,pcr
                    pshs      u
                    leau      >L1A64,pcr
                    leax      $02,s
                    pshs      u
                    pshs      x
                    lbsr      L3ED6
                    leas      $06,s
                    lbsr      L3AA7
                    bne       L1D7F
L1DD4               leas      >$00C8,s
                    rts
L1DD9               leas      -$03,s
                    stx       ,s
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$001F
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3B1D
                    leas      $08,s
                    ldd       #$0000
                    pshs      b,a
                    lda       >$0177
                    ldb       >$0176
                    std       <$0040
                    ldb       >$0178
                    decb
                    pshs      b,a
                    ldb       >$0176
                    pshs      b,a
                    lbsr      L4B56
                    leas      $06,s
                    lbsr      L4903
                    lda       #$0F
                    clrb
                    lbsr      L486F
                    ldb       #$1F
                    ldx       ,s
                    lbsr      L591D
                    sta       $02,s
                    lbsr      L4918
                    lbsr      L3C4C
                    lda       #$01
                    ldb       $02,s
                    cmpb      #$0D
                    beq       L1E31
                    clra
L1E31               ldx       ,s
                    leas      $03,s
                    rts
L1E36               leas      >-$0256,s
                    lda       #$01
                    sta       >$0154
                    lda       #$06
                    sta       >$0547
                    ldd       #$0000
                    sta       >$024C,s
                    std       >$024E,s
                    std       >$0250,s
                    lda       >$0259,s
                    suba      #$72
                    beq       L1E5D
                    lda       #$0C
L1E5D               std       >$024A,s
L1E61               cmpb      #$0C
                    lbcc      L1F09
                    leau      >$0252,s
                    pshs      u
                    incb
                    pshs      b,a
                    ldb       >$025D,s
                    lda       >$024E,s
                    cmpb      #$73
                    bne       L1E80
                    lda       >$024F,s
L1E80               ldb       #$20
                    mul
                    leau      $06,s
                    leau      d,u
                    pshs      u
                    lbsr      L20F2
                    leas      $06,s
                    beq       L1EFE
                    ldb       >$0259,s
                    cmpb      #$73
                    bne       L1ECA
                    ldd       >$0252,s
                    cmpd      >$024E,s
                    bhi       L1EB0
                    bcs       L1EFE
                    ldd       >$0254,s
                    cmpd      >$0250,s
                    bls       L1EFE
L1EB0               ldd       >$0254,s
                    std       >$0250,s
                    ldd       >$0252,s
                    std       >$024E,s
                    lda       >$024B,s
                    sta       >$024C,s
                    bra       L1EFE
L1ECA               ldd       >$0252,s
                    cmpd      >$024E,s
                    bhi       L1EE2
                    bcs       L1EFA
                    ldd       >$0254,s
                    cmpd      >$0250,s
                    bls       L1EFA
L1EE2               ldd       >$0254,s
                    std       >$0250,s
                    ldd       >$0252,s
                    std       >$024E,s
                    lda       >$024A,s
                    sta       >$024C,s
L1EFA               inc       >$024A,s
L1EFE               inc       >$024B,s
                    ldb       >$024B,s
                    lbra      L1E61
L1F09               lda       >$024A,s
                    bne       L1F33
                    lda       >L449A,pcr
                    bne       L1F3B
                    leau      >L1801,pcr
                    pshs      u
                    leau      >L1ABB,pcr
                    leax      >$0184,s
                    pshs      u
                    pshs      x
                    lbsr      L3ED6
                    leas      $06,s
                    lbsr      L3AA7
                    clra
                    lbra      L20E7
L1F33               lda       >L449A,pcr
                    lbeq      L1FBB
L1F3B               lda       >L1800,pcr
                    bne       L1FAC
                    leax      >L449A,pcr
                    leau      >L1820,pcr
                    lbsr      L11B4
                    clrb
                    stb       >$024B,s
L1F51               cmpb      #$0C
                    bcc       L1F75
                    leau      >L1820,pcr
                    lda       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    leax      $01,x
                    lbsr      L11EC
                    tsta
                    lbeq      L20E5
                    inc       >$024B,s
                    ldb       >$024B,s
                    lbra      L1F51
L1F75               lda       >$0259,s
                    cmpa      #$73
                    bne       L1FA0
                    clrb
                    stb       >$024B,s
L1F82               cmpb      #$0C
                    bcc       L1FA0
                    lda       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    ldb       ,x
                    lda       $01,x
                    lbeq      L20E5
                    inc       >$024B,s
                    ldb       >$024B,s
                    lbra      L1F82
L1FA0               lda       >$0259,s
                    suba      #$72
                    lbeq      L20E7
                    bra       L1FBB
L1FAC               leau      >$0182,s
                    lbsr      L14BE
                    lda       >$0185,s
                    sta       >L46D8,pcr
L1FBB               ldd       #$0001
                    pshs      b,a
                    ldd       #$0022
                    pshs      b,a
                    ldb       #$05
                    stb       >$0251,s
                    addb      >$024E,s
                    pshs      b,a
                    ldb       >L449A,pcr
                    beq       L1FE7
                    leau      >L1C09,pcr
                    ldb       >L1800,pcr
                    beq       L1FBB
                    leau      >L1A17,pcr
                    bra       L1FBB
L1FE7               lda       >$025F,s
                    leau      >L1AFB,pcr
                    cmpa      #$73
                    beq       L1FF7
                    leau      >L1B85,pcr
L1FF7               pshs      u
                    lbsr      L3B1D
                    leas      $08,s
                    lda       >$024D,s
                    adda      >$0175
                    sta       >$024D,s
                    clra
                    sta       >L1800,pcr
                    sta       >$024B,s
L2012               cmpa      >$024A,s
                    bcc       L2046
                    adda      >$024D,s
                    ldb       >$0176
                    std       <$0040
                    lda       >$024B,s
                    ldb       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    leax      $01,x
                    pshs      x
                    leax      >L188C,pcr
                    pshs      x
                    lbsr      L3EE9
                    leas      $04,s
                    inc       >$024B,s
                    lda       >$024B,s
                    lbra      L2012
L2046               lda       >$024C,s
                    sta       >$024B,s
                    adda      >$024D,s
                    lbsr      L215D
L2055               lbsr      L1352
                    stx       ,s
                    lda       ,x
                    cmpa      #$01
                    bne       L2097
                    lda       $01,x
                    cmpa      #$0D
                    bne       L208D
                    lbsr      L3C4C
                    leau      >L1820,pcr
                    lda       >L449A,pcr
                    beq       L2077
                    leau      >L449A,pcr
L2077               lda       >$024B,s
                    ldb       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    pshs      x
                    leax      $01,x
                    lbsr      L11B4
                    puls      x
                    bra       L20E5
L208D               cmpa      #$1B
                    bne       L2055
                    lbsr      L3C4C
                    clra
                    bra       L20E7
L2097               cmpa      #$02
                    bne       L2055
                    lda       >$024D,s
                    adda      >$024B,s
                    ldb       $01,x
                    cmpb      #$01
                    bne       L20C4
                    lbsr      L2168
                    lda       >$024B,s
                    bne       L20B6
                    lda       >$024A,s
L20B6               deca
                    sta       >$024B,s
                    adda      >$024D,s
                    lbsr      L215D
                    bra       L2055
L20C4               cmpb      #$05
                    bne       L2055
                    lbsr      L2168
                    lda       >$024B,s
                    inca
                    cmpa      >$024A,s
                    bne       L20D7
                    clra
L20D7               sta       >$024B,s
                    adda      >$024D,s
                    lbsr      L215D
                    lbra      L2055
L20E5               lda       ,x
L20E7               clr       >$0154
                    clr       >$0547
                    leas      >$0256,s
                    rts
L20F2               leas      <-$48,s
                    ldu       <$4A,s
                    ldb       <$4D,s
                    stb       ,u
                    leax      ,s
                    lbsr      L46E5
                    lda       #$01
                    lbsr      L13FB
                    bcs       L2153
                    sta       <$47,s
                    lbsr      L1604
                    ldy       <$4E,s
                    stx       ,y++
                    std       ,y
                    ldy       #$001F
                    ldx       <$4A,s
                    leax      $01,x
                    lda       <$47,s
                    lbsr      L1406
                    ldx       #$0000
                    ldu       #$0024
                    lda       <$47,s
                    ldb       #$01
                    lbsr      L143E
                    ldy       #$0007
                    leax      <$40,s
                    lda       <$47,s
                    lbsr      L1406
                    lda       <$47,s
                    lbsr      L1433
                    ldu       #$01CE
                    lbsr      L11EC
                    bne       L2153
                    lda       #$01
                    bra       L2159
L2153               clra
                    ldu       <$4A,s
                    sta       $01,u
L2159               leas      <$48,s
                    rts
L215D               ldb       >$0176
                    std       <$0040
                    lda       #$1A
                    lbsr      L49E9
                    rts
L2168               ldb       >$0176
                    std       <$0040
                    lda       #$20
                    lbsr      L49E9
                    rts
L2173               fcc       /toc/
                    fcb       0
L2177               fcc       /words.tok/
                    fcb       0
L2181               fcc       /object/
                    fcb       0

L2188               ldd       #$e000
                    std       <$2e
                    ldd       #$4040
                    pshs      d
                    lda       #$18
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      L12FC
                    lbsr      L4FDC
                    lda       #$0F
                    clrb
                    lbsr      L486F
                    lbsr      L5EC4
                    lbsr      L12F6
                    leau      >L2173,pcr
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0089
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L4EDF
                    leas      $08,s
                    ldu       <$0089
                    clra
                    ldb       ,u+
                    stb       >$05ED
                    tfr       d,x
                    stu       <$0089
L21D5               ldd       <$0089
                    addd      ,u
                    std       ,u++
                    leax      -$01,x
                    bne       L21D5
                    leau      >L2177,pcr
                    ldd       #$01AA
                    pshs      b,a
                    ldd       #$01A8
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
L21F2               pshs      u
                    lbsr      L4EDF
                    leas      $08,s
                    lbsr      L257F
                    lbsr      L6024
                    lbsr      L5376
                    lbsr      L377F
                    bsr       L2222
                    clrb
                    lbsr      L25C7
                    ldd       <$004F
                    std       <$004D
                    ldd       <$0055
                    std       <$0053
                    lda       >$01AF
                    ora       #$40
                    sta       >$01AF
                    lbsr      L5545
                    lbsr      L556F
                    rts
L2222               leas      -$01,s
                    leau      >L2181,pcr
                    ldx       <$0038
                    beq       L2230
                    leax      -$03,x
                    stx       <$0038
L2230               ldd       #$0000
                    pshs      b,a
                    ldd       #$0038
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L4EDF
                    leas      $08,s
                    ldx       <$0038
                    ldd       <$0066
                    leau      d,x
                    lbsr      L1080
                    ldd       <$0066
                    subd      #$0003
                    std       <$003A
                    ldu       <$0038
                    lda       $02,u
                    sta       ,s
                    lda       $01,u
                    ldb       ,u
                    leau      $03,u
                    stu       <$0038
                    leau      d,u
                    stu       <$003C
                    ldu       <$0038
L2267               cmpu      <$003C
                    bcc       L2278
                    lda       $01,u
                    ldb       ,u
                    addd      <$0038
                    std       ,u
                    leau      $03,u
                    bra       L2267
L2278               inc       ,s
                    ldu       <$0030
                    bne       L2297
                    lda       ,s
                    ldb       #$2B
                    mul
                    std       <$0034
                    lbsr      L278C
                    stu       <$0030
                    ldd       <$0034
                    leau      d,u
                    stu       <$0032
                    leau      <-$2B,u
                    stu       <$0036
                    ldu       <$0030
L2297               ldx       <$0034
                    clrb
                    lbsr      L2C7A
                    clra
L229E               cmpa      ,s
                    bcc       L22AA
                    sta       $02,u
                    leau      <$2B,u
                    inca
                    bra       L229E
L22AA               ldu       #$0431
                    ldx       #$0100
                    clrb
                    lbsr      L2C7A
                    ldu       #$01AE
                    ldx       #$0020
                    lbsr      L2C7A
                    lbsr      L096F
                    bsr       L22F3
                    lbsr      L058F
                    lda       #$09
                    sta       >$0445
                    lda       >$0553
                    sta       >$044B
                    lda       #$29
                    sta       >$0449
                    lda       >$01AE
                    ora       #$04
                    sta       >$01AE
                    clra
                    sta       >$0240
                    sta       >$01AC
                    inca
                    sta       >$0250
                    tst       >$0172
                    bne       L22F0
                    sta       >$0447
L22F0               leas      $01,s
                    rts
L22F3               lbsr      L2589
                    lbsr      L6024
                    lbsr      L5376
                    lbsr      L377F
                    rts
L2300               fcb       0,0,0
L2303               fcc       /If you have a joystick, and/
                    fcb       $0a
                    fcc       /wish to use it, press its/
                    fcb       $0a
                    fcc       /button./
                    fcb       $0a
                    fcc       /If not, press CTRL-BREAK to/
                    fcb       $0a
                    fcc       /continue./
                    fcb       0

L2367               lda       <$0098
                    eora      #$01
                    sta       <$0098
                    beq       L23B1
                    clr       <$0099
L2371               leau      >L2303,pcr
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0020
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3B1D
                    leas      $08,s
                    ldb       #$00
L238D               stb       <$0097
                    lbsr      L138E
                    ldb       >$0541
                    bne       L23A6
L2397               ldb       <$0097
                    eorb      #$01
                    cmpa      #$1B
                    bne       L238D
                    clr       <$0098
                    lbsr      L3C4C
                    bra       L23B1
L23A6               lbsr      L3C4C
L23A9               lbsr      L2449
                    lda       >$0541
                    bne       L23A9
L23B1               lbsr      L12FC
                    rts
L23B5               clr       >$0541
                    clr       >$0542
L23BB               lda       <$0098
                    lbeq      L242F
                    ldb       >$0547
                    beq       L23FD
                    ldx       <$009C
                    bne       L23EA
                    ldx       <$009A
                    bne       L23EA
                    clra
L23CF               orcc      #$50
                    addd      >$024A
                    std       <$009C
                    ldd       >$0248
                    andcc     #$AF
                    bcc       L23E0
                    addd      #$0001
L23E0               std       <$009A
                    bne       L23EA
                    ldd       <$009C
                    bne       L23EA
                    inc       <$009D
L23EA               orcc      #$50
                    ldx       >$024A
                    ldd       >$0248
                    andcc     #$AF
                    cmpd      <$009A
                    bhi       L23FD
                    cmpx      <$009C
                    bls       L242D
L23FD               ldd       #$0000
                    std       <$009A
                    std       <$009C
                    bsr       L2430
                    lbsr      L24D7
                    ldb       >$0154
                    bne       L2413
                    ldb       >$017F
                    beq       L2418
L2413               tsta
                    beq       L242D
                    bra       L2428
L2418               cmpa      <$0099
                    beq       L242D
                    ldb       >$0102
                    bne       L242D
                    sta       <$0099
                    cmpa      >$0437
                    beq       L242D
L2428               ldb       #$02
                    lbsr      L1311
L242D               bsr       L245A
L242F               rts
L2430               pshs      y
                    lda       #$00
                    ldb       #$13
                    ldx       <$0096
                    os9       I$GetStt
                    tfr       x,d
                    leax      >L2300,pcr
                    sty       $01,x
                    std       ,x
                    puls      y
                    rts
L2449               pshs      y
                    lda       #$00
                    ldb       #$13
                    ldx       <$0096
                    os9       I$GetStt
                    sta       >$0541
                    puls      y
                    rts
L245A               bsr       L2449
                    lda       >$0542
                    cmpa      #$02
                    bne       L2486
                    orcc      #$50
                    ldx       >$024A
                    ldd       >$0248
                    andcc     #$AF
                    cmpd      >$0543
                    bcs       L2486
                    bhi       L247A
                    cmpx      >$0545
                    bcs       L2486
L247A               clr       >$0542
                    lda       #$FC
                    ldb       #$01
                    lbsr      L1311
                    bra       L248F
L2486               lda       >$0542
                    beq       L248F
                    cmpa      #$02
                    bne       L2499
L248F               lda       >$0541
                    beq       L24D6
                    inc       >$0542
                    bra       L24D6
L2499               cmpa      #$01
                    bne       L24C7
                    lda       >$0541
                    bne       L24D6
                    lda       >$01AF
                    anda      #$80
                    beq       L247A
                    clra
                    ldb       >$0440
                    orcc      #$50
                    addd      >$024A
                    std       >$0545
                    ldd       >$0248
                    andcc     #$AF
                    bcc       L24BF
                    addd      #$0001
L24BF               std       >$0543
                    inc       >$0542
                    bra       L24D6
L24C7               lda       >$0541
                    bne       L24D6
                    clr       >$0542
                    lda       #$FE
                    ldb       #$01
                    lbsr      L1311
L24D6               rts
L24D7               lda       $02,x
                    ldb       $01,x
                    cmpa      #$25
                    bls       L24EF
                    lda       #$08
                    cmpb      #$16
                    bcs       L2511
                    lda       #$02
                    cmpb      #$25
                    bhi       L2511
                    lda       #$01
                    bra       L2511
L24EF               cmpa      #$16
                    bcc       L2503
                    lda       #$06
                    cmpb      #$16
                    bcs       L2511
                    lda       #$04
                    cmpb      #$25
                    bhi       L2511
                    lda       #$05
                    bra       L2511
L2503               lda       #$07
                    cmpb      #$16
                    bcs       L2511
                    lda       #$03
                    cmpb      #$25
                    bhi       L2511
                    lda       #$00
L2511               rts
L2512               fcb       $1c,$01
                    fcb       $10,$02
                    fcb       $19,$03
                    fcb       $11,$04
                    fcb       $1a,$05
                    fcb       $12,$06
                    fcb       $18,$07
                    fcb       $13,$08
                    fcb       $00,$00
L2524               fcb       $0c,$01
                    fcb       $09,$03
                    fcb       $0a,$05
                    fcb       $08,$07
                    fcb       $00,$00

L252E               lbsr      L2C34
                    tsta
                    bne       L252E
                    rts
L2535               lbsr      L2C34
                    tsta
                    beq       L254D
                    bsr       L254E
                    tstb
                    bmi       L2544
                    ldb       #$02
                    bra       L254A
L2544               cmpa      #$0C
                    beq       L254D
                    ldb       #$01
L254A               lbsr      L1311
L254D               rts
L254E               leax      >L2512,pcr
L2552               cmpa      ,x+
                    beq       L256F
                    ldb       ,x+
                    bne       L2552
                    ldb       >$0154
                    beq       L256B
                    leax      >L2524,pcr
L2563               cmpa      ,x+
                    beq       L256F
                    ldb       ,x+
                    bne       L2563
L256B               ldb       #$FF
                    bra       L2572
L256F               lda       ,x
                    clrb
L2572               rts
L2573               fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0

L257F               leax      >L2573,pcr
                    ldd       #$0000
                    std       ,x
                    rts
L2589               leay      >L2573,pcr
                    ldy       ,y
                    beq       L2597
                    ldd       #$0000
                    std       ,y
L2597               rts
L2598               leau      >L2573,pcr
L259C               stu       <$0064
                    ldu       ,u
                    beq       L25A6
                    cmpb      $02,u
                    bne       L259C
L25A6               rts
L25A7               ldb       ,y+
                    bsr       L25B7
                    rts
L25AC               ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L25B7
                    rts
L25B7               leas      -$01,s
                    stb       ,s
                    lda       #$00
                    lbsr      L494E
                    ldb       ,s
                    bsr       L25C7
                    leas      $01,s
                    rts
L25C7               leas      -$07,s
                    stb       ,s
                    bsr       L2598
                    cmpu      #$0000
                    bne       L263D
                    ldd       <$000A
                    std       $03,s
                    lbsr      L058F
                    ldd       #$000C
                    lbsr      L278C
                    ldx       <$0064
                    stu       ,x
                    ldd       #$0000
                    std       ,u
                    ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      L505F
                    ldx       #$0000
                    lbsr      L4C1B
                    beq       L2633
                    ldx       $01,s
                    std       $04,x
                    leau      $02,u
                    stu       $06,x
                    stu       $08,x
                    ldb       -$02,u
                    lda       -$01,u
                    leau      d,u
                    lda       ,u+
                    stu       $0A,x
                    sta       $03,x
                    beq       L2633
                    lda       <$009E
                    beq       L2633
                    ldd       <$0062
                    std       $05,s
                    stx       <$0062
                    clrb
                    lbsr      L3E0D
                    clra
                    ldb       $03,x
                    ldx       $0A,x
                    addd      #$0001
                    lslb
                    rola
                    leax      d,x
                    lbsr      L1080
                    ldd       $05,s
                    std       <$0062
L2633               lbsr      L059C
                    ldd       $03,s
                    lbsr      L280B
                    ldu       $01,s
L263D               leas      $07,s
                    rts
L2640               leas      -$02,s
                    ldb       ,y+
                    sty       ,s
                    bsr       L266C
                    leay      ,y
                    beq       L2650
                    ldy       ,s
L2650               leas      $02,s
                    rts
L2653               leas      -$02,s
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    sty       ,s
                    bsr       L266C
                    leay      ,y
                    beq       L2669
                    ldy       ,s
L2669               leas      $02,s
                    rts
L266C               leas      -$0A,s
                    stb       ,s
                    ldd       <$0062
                    std       $01,s
                    lda       #$01
                    sta       $03,s
                    ldb       ,s
                    lbsr      L2598
                    stu       <$0062
                    beq       L2688
                    ldd       $04,u
                    lbsr      L280B
                    bra       L26A2
L2688               ldd       <$0064
                    std       $04,s
                    ldb       ,s
                    lbsr      L25C7
                    stu       <$0062
                    stu       $06,s
                    lda       $04,u
                    ldu       $06,u
                    leau      -$02,u
                    lbsr      L27EB
                    stu       $08,s
                    clr       $03,s
L26A2               lda       <$0068
                    beq       L26AE
                    cmpa      #$02
                    bne       L26AE
                    lda       #$01
                    sta       <$0068
L26AE               lda       ,s
                    bne       L26B6
                    lda       #$01
                    sta       <$0069
L26B6               lbsr      L4763
                    lda       $03,s
                    bne       L26D2
                    ldd       #$0000
                    ldx       $04,s
                    std       ,x
                    lbsr      L058F
                    ldd       $08,s
                    std       <$004F
                    ldd       $06,s
                    std       <$0055
                    lbsr      L059C
L26D2               ldu       $01,s
                    stu       <$0062
                    beq       L26DD
                    ldd       $04,u
                    lbsr      L280B
L26DD               leas      $0A,s
                    rts
L26E0               ldx       <$0062
                    sty       $08,x
                    rts
L26E6               ldx       <$0062
                    ldd       $06,x
                    std       $08,x
                    rts
L26ED               leau      >L2573,pcr
                    ldx       #$0554
L26F4               lda       $02,u
                    sta       ,x
                    ldd       $08,u
                    subd      $06,u
                    std       $01,x
                    leax      $03,x
                    ldu       ,u
                    bne       L26F4
                    lda       #$FF
                    sta       ,x
                    tfr       x,d
                    subd      #$0553
                    tfr       d,x
                    rts
L2710               ldx       #$0554
L2713               lda       ,x
                    cmpa      #$FF
                    beq       L2727
                    cmpa      $02,u
                    beq       L2721
                    leax      $03,x
                    bra       L2713
L2721               ldd       $06,u
                    addd      $01,x
                    std       $08,u
L2727               rts
L2728               fcc       /Out of %s memory./
                    fcb       $0a
L274A               fcc       /Want: %d, Have: %d/
                    fcb       0

L274D               fcc       /heap/
                    fcb       0

L2752               fcc       /common/
                    fcb       0

L2759               leas      -$34,s
                    std       ,s
                    ldd       <$4f
                    tfr       d,u
                    addd      ,s
                    bhs       L277A
L2766               ldd       #$FFFF
                    subd      <$004F
                    addd      #$0001
                    pshs      b,a
L2770               ldd       $02,s
                    pshs      b,a
                    leax      >L274D,pcr
                    bra       L27A4
L277A               std       <$004F
                    lbsr      L27E2
                    ldd       <$004F
                    cmpd      <$004B
                    bls       L2788
                    std       <$004B
L2788               leas      <$34,s
                    rts
L278C               leas      <-$34,s
                    std       ,s
                    ldd       <0
                    subd      <$0055
                    cmpd      ,s
                    bcc       L27C1
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
L27A0               leax      >L2752,pcr
L27A4               pshs      x
                    leax      >L2728,pcr
                    leau      $08,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $0A,s
                    lbsr      L3AA7
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L27C1               ldd       <$0055
                    tfr       d,u
                    addd      ,s
                    std       <$0055
                    cmpd      <$0051
                    bls       L27D0
                    std       <$0051
L27D0               leas      <$34,s
                    rts
L27D4               lbsr      L05DC
                    ldd       <$004D
                    std       <$004F
                    bsr       L27E2
                    ldd       <$0053
                    std       <$0055
                    rts
L27E2               ldd       #$FFFF
                    subd      <$004F
                    sta       >$0439
                    rts
L27EB               suba      <$005F
                    ldb       #$20
                    mul
                    exg       b,a
                    subd      #$2000
                    leau      d,u
                    rts
L27F8               tfr       u,d
                    anda      #$1F
                    adda      #$20
                    exg       d,u
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      <$005F
                    tfr       a,b
                    incb
                    rts
L280B               cmpa      <$000A
                    beq       L2825
                    orcc      #$50
                    std       <$000A
                    lda       <$0042
                    sta       >$FFA9
                    ldx       <$0043
                    lda       <$000A
                    sta       ,x
                    stb       $02,x
                    std       >$FFA9
                    andcc     #$AF
L2825               rts
L2826               fcb       1
L2827               fcb       0,0
L2829               fcb       0,0
L282B               fcb       0
L282C               fcb       0
L282D               fcb       0,0
L282F               fcb       0
L2830               fcb       0
L2831               fcb       0
L2832               fcb       0
L2833               fcb       0
L2834               fcb       0
L2835               leas      -$04,s
                    ldb       ,y+
                    lbsr      L3E0D
                    stu       ,s
                    ldu       <$0062
                    ldd       $04,u
                    std       $02,s
                    lda       >L2834,pcr
                    bne       L28B0
                    ldd       #$0010
                    lbsr      L278C
                    ldd       >L282D,pcr
                    bne       L2862
                    stu       >L282D,pcr
                    lda       #$01
                    sta       >L282F,pcr
                    bra       L2870
L2862               ldx       >L2829,pcr
                    stu       ,x
                    stx       $02,u
                    ldd       $0B,x
                    bne       L2870
                    sta       $0A,x
L2870               ldx       >L282D,pcr
                    stx       ,u
                    stu       $02,x
                    stu       >L2829,pcr
                    ldd       #$0000
                    std       $0B,u
                    sta       $08,u
                    sta       $0F,u
                    lda       >L282F,pcr
                    sta       $09,u
                    lda       #$01
                    sta       $0A,u
                    ldx       ,s
                    stx       $04,u
                    ldd       $02,s
                    std       $06,u
                    lbsr      L11A0
                    incb
                    addb      >L282F,pcr
                    stb       >L282F,pcr
                    ldd       #$0000
                    std       >L2827,pcr
                    lda       #$01
                    sta       >L282B,pcr
L28B0               leas      $04,s
                    rts
L28B3               leas      -$05,s
                    ldb       ,y+
                    lbsr      L3E0D
                    stu       ,s
                    ldu       <$0062
                    ldd       $04,u
                    std       $02,s
                    lda       ,y+
                    sta       $04,s
                    lda       >L2834,pcr
                    bne       L2932
                    ldd       #$000C
                    lbsr      L278C
                    ldx       >L2827,pcr
                    bne       L28E4
                    ldx       >L2829,pcr
                    stu       $0D,x
                    stu       $0B,x
                    stu       $02,u
                    bra       L28EC
L28E4               stu       ,x
                    stx       $02,u
                    ldx       >L2829,pcr
L28EC               ldx       $0B,x
                    stx       ,u
                    stu       $02,x
                    stu       >L2827,pcr
                    ldx       ,s
                    stx       $04,u
                    ldd       $02,s
                    std       $06,u
                    lda       >L282B,pcr
                    inc       >L282B,pcr
                    cmpa      #$01
                    bne       L291E
                    lbsr      L11A0
                    negb
                    addb      #$27
                    ldx       >L2829,pcr
                    cmpb      $09,x
                    bls       L291A
                    ldb       $09,x
L291A               stb       >L282C,pcr
L291E               ldd       >L282B,pcr
                    std       $08,u
                    lda       #$01
                    sta       $0A,u
                    lda       $04,s
                    sta       $0B,u
                    ldx       >L2829,pcr
                    inc       $0F,x
L2932               leas      $05,s
                    rts
L2935               ldu       >L2829,pcr
                    ldd       $0B,u
                    bne       L293F
                    sta       $0A,u
L293F               ldd       <$0055
                    std       <$0053
                    ldu       >L282D,pcr
                    stu       >L2829,pcr
                    ldd       $0B,u
                    std       >L2827,pcr
                    lda       #$01
                    sta       >L2834,pcr
                    rts
L2958               lda       ,y+
                    ldb       #$01
                    bsr       L2986
                    rts
L295F               ldu       >L282D,pcr
                    beq       L297E
L2965               lda       $0A,u
                    beq       L2975
                    ldx       $0B,u
L296B               lda       #$01
                    sta       $0A,x
                    ldx       ,x
                    cmpx      $0B,u
                    bne       L296B
L2975               ldu       ,u
                    cmpu      >L282D,pcr
                    bne       L2965
L297E               rts
L297F               lda       ,y+
                    ldb       #$00
                    bsr       L2986
                    rts
L2986               leas      -$02,s
                    std       ,s
                    ldu       >L282D,pcr
L298E               lda       $0A,u
                    beq       L29A2
                    ldx       $0B,u
                    ldd       ,s
L2996               cmpa      $0B,x
                    bne       L299C
                    stb       $0A,x
L299C               ldx       ,x
                    cmpx      $0B,u
                    bne       L2996
L29A2               ldu       ,u
                    cmpu      >L282D,pcr
                    bne       L298E
                    leas      $02,s
                    rts
L29AE               lda       >$01AF
                    anda      #$02
                    beq       L29BA
                    lda       #$01
                    sta       >$05AE
L29BA               rts
L29BB               ldb       ,y+
                    stb       >L2826,pcr
                    rts
L29C2               leas      -$04,s
                    lda       >L2826,pcr
                    lbeq      L2B2B
                    lbsr      L4A5F
                    lbsr      L4903
                    ldd       #$000F
                    lbsr      L4A85
                    ldu       >L282D,pcr
L29DC               stu       ,s
                    ldx       ,s
                    lbsr      L2BC4
                    ldu       ,s
                    ldu       ,u
                    cmpu      >L282D,pcr
                    bne       L29DC
                    ldd       >L2827,pcr
                    std       $02,s
                    ldu       >L2829,pcr
                    stu       ,s
                    lbsr      L2B39
                    lda       #$01
                    sta       >$0154
                    lda       #$03
                    sta       >$0547
L2A07               lbsr      L1352
                    lda       ,x
                    cmpa      #$01
                    bne       L2A4F
                    lda       $01,x
                    cmpa      #$0D
                    bne       L2A25
                    ldu       $02,s
                    lda       $0A,u
                    beq       L2A07
                    lda       $0B,u
                    ldb       #$03
                    lbsr      L1311
                    bra       L2A2B
L2A25               cmpa      #$1B
                    lbne      L2B1C
L2A2B               ldu       ,s
                    ldx       $02,s
                    lbsr      L2B7F
                    clr       >$0547
                    lbsr      L4918
                    lbsr      L4A73
                    lda       >$0246
                    beq       L2A46
                    lbsr      L5801
                    lbra      L2B2B
L2A46               ldd       #$0000
                    lbsr      L4A85
                    lbra      L2B2B
L2A4F               cmpa      #$02
                    lbne      L2B1C
                    lda       $01,x
                    cmpa      #$01
                    bne       L2A6C
                    ldx       $02,s
                    lbsr      L2BC4
                    ldx       $02,s
                    ldx       $02,x
                    stx       $02,s
                    lbsr      L2B9D
                    lbra      L2B1C
L2A6C               cmpa      #$02
                    bne       L2A81
                    ldx       $02,s
                    lbsr      L2BC4
                    ldu       ,s
                    ldx       $0B,u
                    stx       $02,s
                    lbsr      L2B9D
                    lbra      L2B1C
L2A81               cmpa      #$03
                    bne       L2AA0
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B7F
                    ldu       ,s
L2A8E               ldu       ,u
                    lda       $0A,u
                    beq       L2A8E
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2B39
                    lbra      L2B1C
L2AA0               cmpa      #$04
                    bne       L2AB6
                    ldx       $02,s
                    lbsr      L2BC4
                    ldu       ,s
                    ldx       $0B,u
                    ldx       $02,x
                    stx       $02,s
                    lbsr      L2B9D
                    bra       L2B1C
L2AB6               cmpa      #$05
                    bne       L2ACA
                    ldx       $02,s
                    lbsr      L2BC4
                    ldx       $02,s
                    ldx       ,x
                    stx       $02,s
                    lbsr      L2B9D
                    bra       L2B1C
L2ACA               cmpa      #$06
                    bne       L2AE6
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B7F
                    ldu       >L282D,pcr
                    ldu       $02,u
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2B39
                    bra       L2B1C
L2AE6               cmpa      #$07
                    bne       L2B04
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B7F
                    ldu       ,s
L2AF3               ldu       $02,u
                    lda       $0A,u
                    beq       L2AF3
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2B39
                    bra       L2B1C
L2B04               cmpa      #$08
                    bne       L2B1C
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B7F
                    ldu       >L282D,pcr
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2B39
L2B1C               ldd       ,s
                    std       >L2829,pcr
                    ldd       $02,s
                    std       >L2827,pcr
                    lbra      L2A07
L2B2B               lda       #$00
                    sta       >$0154
                    sta       >$05AE
                    sta       >$0547
                    leas      $04,s
                    rts
L2B39               leas      -$04,s
                    stu       ,s
                    ldx       ,s
                    bsr       L2B9D
                    ldu       ,s
                    lbsr      L2BEB
                    ldd       #$000F
                    pshs      b,a
                    ldd       >L2830,pcr
                    pshs      b,a
                    ldd       >L2832,pcr
                    pshs      b,a
                    lda       #$0C
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $06,s
                    ldu       ,s
                    ldx       $0B,u
L2B66               stx       $02,s
                    cmpx      $0D,u
                    beq       L2B70
                    bsr       L2BC4
                    bra       L2B72
L2B70               bsr       L2B9D
L2B72               ldx       $02,s
                    ldx       ,x
                    ldu       ,s
                    cmpx      $0B,u
                    bne       L2B66
                    leas      $04,s
                    rts
L2B7F               stx       $0D,u
                    tfr       u,x
                    bsr       L2BC4
                    ldd       >L2830,pcr
                    pshs      b,a
                    ldd       >L2832,pcr
                    pshs      b,a
                    lda       #$03
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
                    rts
L2B9D               ldd       $08,x
                    std       <$0040
                    ldd       #$0F00
                    lbsr      L486F
                    lda       $0A,x
                    bne       L2BAF
                    lda       #$0F
                    sta       <$0045
L2BAF               pshs      x
                    ldd       $06,x
                    lbsr      L280B
                    puls      x
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L3EE9
                    leas      $02,s
                    clr       <$0045
                    rts
L2BC4               ldd       $08,x
                    std       <$0040
                    ldd       #$000F
                    lbsr      L486F
                    lda       $0A,x
                    bne       L2BD6
                    lda       #$0F
                    sta       <$0045
L2BD6               pshs      x
                    ldd       $06,x
                    lbsr      L280B
                    puls      x
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L3EE9
                    leas      $02,s
                    clr       <$0045
                    rts
L2BEB               leas      -$01,s
                    lda       $0F,u
                    sta       ,s
                    ldb       #$08
                    mul
                    addb      #$10
                    stb       >L2830,pcr
                    ldu       $0B,u
                    ldd       $06,u
                    lbsr      L280B
                    ldx       $04,u
                    lbsr      L11A0
                    lda       #$04
                    mul
                    addb      #$08
                    stb       >L2831,pcr
                    lda       $09,u
                    deca
                    ldb       #$04
                    mul
                    stb       >L2832,pcr
                    lda       ,s
                    adda      #$02
                    suba      >$0241
                    ldb       #$08
                    mul
                    addb      #$07
                    stb       >L2833,pcr
                    leas      $01,s
                    rts
L2C2C               fcb       1,$ff
                    fcb       3,$ff
                    fcb       7,$ff
                    fcb       $f,$ff

L2C34               leas      -$03,s
                    sty       ,s
                    lda       #$00
                    ldb       #$01
                    os9       I$GetStt
                    bcs       L2C73
                    lda       #$00
                    ldy       #$0001
                    leax      $02,s
                    os9       I$Read
                    bcs       L2C73
                    lda       $02,s
                    bra       L2C74
                    cmpa      #$F4
                    bne       L2C74
                    lda       <$0068
                    bne       L2C68
                    lda       >$01AF
                    ora       #$20
                    sta       >$01AF
                    lbsr      L5A61
                    bra       L2C73
L2C68               lda       >$01AF
                    anda      #$DF
                    sta       >$01AF
                    lbsr      L5AF2
L2C73               clra
L2C74               ldy       ,s
                    leas      $03,s
                    rts
L2C7A               pshs      u
L2C7C               stb       ,u+
                    leax      -$01,x
                    bne       L2C7C
                    puls      u
                    rts
L2C85               lda       $02,s
                    sta       <$00B9
                    ldd       $06,s
                    std       <$00A2
                    lbsr      L2DED
                    ldd       #$0009
                    std       <$00A4
                    ldd       #$0102
                    std       <$00A9
                    ldd       #$0200
                    std       <$00B1
                    ldd       #$0000
                    std       <$00A6
                    std       <$00B4
                    std       <$00AB
                    std       <$00BA
                    stb       <$00B6
                    stb       <$00A8
                    stb       <$00AD
                    lbsr      L2E72
                    tst       <$009F
                    lbne      L2D6B
                    ldx       $04,s
L2CBB               lbsr      L2E08
                    tst       <$009F
                    lbne      L2D6B
                    cmpd      #$0101
                    lbeq      L2D6B
                    cmpd      #$0100
                    bne       L2CF6
                    ldd       #$0009
                    std       <$00A4
                    ldd       #$0102
                    std       <$00A9
                    ldd       #$0200
                    std       <$00B1
                    lbsr      L2E08
                    tst       <$009F
                    lbne      L2D6B
                    std       <$00A6
                    std       <$00B4
                    stb       <$00AD
                    stb       <$00A8
                    stb       ,x+
                    bra       L2CBB
L2CF6               std       <$00A6
                    std       <$00AB
                    cmpd      <$00A9
                    bcs       L2D09
                    ldb       <$00A8
                    pshs      b
                    inc       <$00B6
                    ldd       <$00B4
                    std       <$00A6
L2D09               cmpd      #$0100
                    bcs       L2D24
                    addd      <$00A6
                    addd      <$00A6
                    ldu       #$6400
                    leau      d,u
                    ldb       $02,u
                    pshs      b
                    inc       <$00B6
                    ldd       ,u
                    std       <$00A6
                    bra       L2D09
L2D24               stb       <$00A8
                    stb       <$00AD
                    pshs      b
                    lda       <$00B6
                    inca
L2D2D               puls      b
                    stb       ,x+
                    deca
                    bne       L2D2D
                    sta       <$00B6
                    ldd       <$00A9
                    addd      <$00A9
                    addd      <$00A9
                    ldu       #$6400
                    leau      d,u
                    ldb       <$00AD
                    stb       $02,u
                    ldd       <$00B4
                    std       ,u
                    ldd       <$00A9
                    addd      #$0001
                    std       <$00A9
                    ldu       <$00AB
                    stu       <$00B4
                    cmpd      <$00B1
                    lbcs      L2CBB
                    ldb       <$00A5
                    cmpb      #$0B
                    lbeq      L2CBB
                    incb
                    stb       <$00A5
                    lsl       <$00B1
                    lbra      L2CBB
L2D6B               tfr       x,d
                    subd      $04,s
                    rts
L2D70               lda       $02,s
                    sta       <$00B9
                    ldd       $06,s
                    std       <$00A2
                    bsr       L2DED
                    clrb
                    stb       <$00BC
                    stb       <$00B3
                    lbsr      L2E72
                    tst       <$009F
                    bne       L2DE8
                    ldu       #$6000
                    ldx       $04,s
L2D8B               cmpu      #$63FE
                    bcs       L2DA4
                    stx       <$00B7
                    tfr       u,d
                    subd      #$6000
                    lbsr      L2E62
                    tst       <$009F
                    bne       L2DE8
                    ldu       #$6000
                    ldx       <$00B7
L2DA4               ldb       ,u
                    lda       <$00BC
                    beq       L2DC2
                    lda       <$00B3
                    anda      #$01
                    beq       L2DB4
                    andb      #$0F
                    bra       L2DB8
L2DB4               lsrb
                    lsrb
                    lsrb
                    lsrb
L2DB8               leau      a,u
                    eora      #$01
                    sta       <$00B3
                    clr       <$00BC
                    bra       L2DE2
L2DC2               leau      $01,u
                    lda       <$00B3
                    anda      #$01
                    beq       L2DD4
                    lda       ,u
                    lsla
                    rolb
                    lsla
                    rolb
                    lsla
                    rolb
                    lsla
                    rolb
L2DD4               lda       #$01
                    sta       <$00BC
                    cmpb      #$F0
                    beq       L2DE2
                    cmpb      #$F2
                    beq       L2DE2
                    clr       <$00BC
L2DE2               stb       ,x+
                    cmpb      #$FF
                    bne       L2D8B
L2DE8               tfr       x,d
                    subd      $04,s
                    rts
L2DED               orcc      #$50
                    lda       >$FFA9
                    ldb       <$0042
                    stb       >$FFA9
                    ldx       <$0043
                    ldb       <$005F
                    addb      #$08
                    stb       $04,x
                    stb       >$FFAB
                    sta       >$FFA9
                    andcc     #$AF
                    rts
L2E08               stx       <$00B7
                    ldd       <$00BA
                    cmpd      #$1FF0
                    bcs       L2E25
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    bsr       L2E62
                    tst       <$009F
                    bne       L2E5F
                    clra
                    ldb       <$00BB
                    andb      #$07
                    std       <$00BA
L2E25               ldu       <$00A4
                    leau      d,u
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    ldx       #$6000
                    leax      d,x
                    lda       $01,x
                    ldb       ,x
                    std       <$00AE
                    ldb       $02,x
                    stb       <$00B0
                    ldb       <$00BB
                    stu       <$00BA
                    andb      #$07
                    beq       L2E4F
L2E46               lsr       <$00B0
                    ror       <$00AE
                    ror       <$00AF
                    decb
                    bne       L2E46
L2E4F               ldb       <$00A5
                    subb      #$09
                    lslb
                    leax      >L2C2C,pcr
                    abx
                    ldd       <$00AE
                    anda      ,x
                    andb      $01,x
L2E5F               ldx       <$00B7
                    rts
L2E62               ldu       #$6000
                    ldu       d,u
                    stu       >$6000
                    subd      #$0400
                    negb
                    lbsr      L2E72
                    rts
L2E72               ldx       #$6000
                    abx
                    negb
                    sex
                    addd      #$0400
                    std       <$00A0
                    ldd       <$00A2
                    beq       L2E9A
                    cmpd      <$00A0
                    bcs       L2E8E
                    subd      <$00A0
                    std       <$00A2
                    ldd       <$00A0
                    bra       L2E93
L2E8E               ldu       #$0000
                    stu       <$00A2
L2E93               tfr       d,y
                    lda       <$00B9
                    lbsr      L1406
L2E9A               rts
L2E9B               tst       >$0550
                    beq       L2EA9
                    lda       #$00
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
L2EA9               ldd       #$A8A0
                    pshs      b,a
                    ldd       #$00A7
                    pshs      b,a
                    lda       #$00
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
                    rts
L2EBF               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$03
                    sta       <$22,u
                    lda       ,y+
                    sta       <$27,u
                    lda       ,y+
                    sta       <$28,u
                    lda       <$1E,u
                    sta       <$29,u
                    lda       ,y+
                    beq       L2EE4
                    sta       <$1E,u
L2EE4               lda       ,y+
                    sta       <$2A,u
                    lbsr      L1732
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <$0030
                    bne       L2EFC
                    clr       >$0250
L2EFC               lbsr      L31A4
                    rts
L2F00               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$03
                    sta       <$22,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       <$27,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       <$28,u
                    lda       <$1E,u
                    sta       <$29,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    beq       L2F37
                    sta       <$1E,u
L2F37               lda       ,y+
                    sta       <$2A,u
                    lbsr      L1732
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <$0030
                    bne       L2F4F
                    clr       >$0250
L2F4F               lbsr      L31A4
                    rts
L2F53               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$02
                    sta       <$22,u
                    lda       <$1E,u
                    sta       <$27,u
                    lda       ,y+
                    cmpa      <$1E,u
                    bls       L2F71
                    sta       <$27,u
L2F71               lda       ,y+
                    sta       <$28,u
                    lbsr      L1732
                    lda       #$FF
                    sta       <$29,u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    rts
L2F87               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$01
                    sta       <$22,u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <$0030
                    bne       L2FA5
                    clr       >$0250
L2FA5               rts
L2FA6               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    rts
L2FB5               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    clra
                    sta       <$21,u
                    cmpu      <$0030
                    bne       L2FD2
                    sta       >$0437
                    sta       >$0250
l2FD2               rts
L2FD3               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    cmpu      <$0030
                    bne       L2FEE
                    clr       >$0437
                    lda       #$01
                    sta       >$0250
L2FEE               rts

L2FEF               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       <$1E,u
                    rts

L3004               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       ,u
                    sta       $01,u
                    rts

L301A               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       <$21,u
                    rts

L302F               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       <$21,u
                    sta       ,x
                    rts

L3044               clr       >$0250
                    rts

L3048               lda       #$01
                    sta       >$0250
                    ldu       <$0030
                    lda       #$00
                    sta       <$22,u
                    rts
L3055               fcb       0,0
                    fcb       1,1
                    fcb       1,0
                    fcb       $ff,$ff
                    fcb       $ff
L305E               fcb       0
                    fcb       $ff,$ff
                    fcb       0,1
                    fcb       1,1
                    fcb       0,$ff

L3067               leas      -$0B,s
                    clra
                    sta       >$0433
                    sta       >$0435
                    sta       >$0436
                    ldu       <$0030
L3075               cmpu      <$0032
                    lbcc      L3198
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    lbne      L3192
                    lda       $01,u
                    beq       L3093
                    deca
                    beq       L3093
                    sta       $01,u
                    lbra      L3192
L3093               lda       ,u
                    sta       $01,u
                    clra
                    sta       $02,s
                    ldb       <$1E,u
                    std       $09,s
                    ldb       $03,u
                    std       $03,s
                    stb       $07,s
                    ldb       $04,u
                    std       $05,s
                    stb       $08,s
                    lda       <$25,u
                    bita      #$04
                    bne       L30E8
                    leax      >L3055,pcr
                    lda       <$21,u
                    lda       a,x
                    beq       L30CD
                    bpl       L30C7
                    ldd       $03,s
                    subd      $09,s
                    std       $03,s
                    bra       L30CD
L30C7               ldd       $03,s
                    addd      $09,s
                    std       $03,s
L30CD               leax      >L305E,pcr
                    lda       <$21,u
                    lda       a,x
                    beq       L30E8
                    bpl       L30E2
                    ldd       $05,s
                    subd      $09,s
                    std       $05,s
                    bra       L30E8
L30E2               ldd       $05,s
                    addd      $09,s
                    std       $05,s
L30E8               ldd       #$0000
                    cmpd      $03,s
                    ble       L30F8
                    std       $03,s
                    lda       #$04
                    sta       $02,s
                    bra       L310C
L30F8               ldb       <$1C,u
                    negb
                    lda       #$FF
                    addd      #$00A0
                    cmpd      $03,s
                    bge       L310C
                    std       $03,s
                    lda       #$02
                    sta       $02,s
L310C               clra
                    ldb       <$1D,u
                    decb
                    cmpd      $05,s
                    ble       L311E
                    std       $05,s
                    lda       #$01
                    sta       $02,s
                    bra       L3143
L311E               ldd       #$00A7
                    cmpd      $05,s
                    bge       L312E
                    std       $05,s
                    lda       #$03
                    sta       $02,s
                    bra       L3143
L312E               lda       <$26,u
                    bita      #$08
                    bne       L3143
                    lda       >$01D6
                    cmpa      $06,s
                    bls       L3143
                    inca
                    sta       $06,s
                    lda       #$01
                    sta       $02,s
L3143               lda       $04,s
                    ldb       $06,s
                    std       $03,u
                    lbsr      L08A2
                    tsta
                    bne       L3164
                    stu       ,s
                    pshs      u
                    lda       #$03
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldu       ,s
                    lda       <$005C
                    bne       L316D
L3164               ldd       $07,s
                    std       $03,u
                    clr       $02,s
                    lbsr      L164B
L316D               lda       $02,s
                    beq       L318A
                    ldb       $02,u
                    bne       L317A
                    sta       >$0433
                    bra       L3180
L317A               stb       >$0435
                    sta       >$0436
L3180               lda       <$22,u
                    cmpa      #$03
                    bne       L318A
                    lbsr      L31C7
L318A               lda       <$25,u
                    anda      #$FB
                    sta       <$25,u
L3192               leau      <$2B,u
                    lbra      L3075
L3198               leas      $0B,s
                    rts
L319B               fcb       8,1,2,7,0,3,6,5,4
L31A4               ldb       $1e,u
                    pshs      b,a
                    ldd       <$27,u
                    pshs      b,a
                    ldd       $03,u
                    pshs      b,a
                    lbsr      L31E6
                    leas      $06,s
                    cmpu      <$0030
                    bne       L31BF
                    sta       >$0437
L31BF               sta       <$21,u
                    bne       L31C6
                    bsr       L31C7
L31C6               rts
L31C7               lda       <$29,u
                    sta       <$1E,u
                    lda       <$2A,u
                    lbsr      L172B
                    lda       #$00
                    sta       <$22,u
                    cmpu      <$0030
                    bne       L31E5
                    lda       #$01
                    sta       >$0250
                    clr       >$0437
L31E5               rts
L31E6               leas      -$03,s
                    clra
                    sta       $09,s
                    ldb       $05,s
                    std       ,s
                    ldb       $07,s
                    subd      ,s
                    pshs      b,a
                    ldd       $0B,s
                    pshs      b,a
                    lbsr      L3220
                    leas      $04,s
                    sta       $02,s
                    clra
                    sta       $05,s
                    ldb       $08,s
                    subd      $05,s
                    pshs      b,a
                    ldd       $0B,s
                    pshs      b,a
                    lbsr      L3220
                    leas      $04,s
                    leax      >L319B,pcr
                    ldb       #$03
                    mul
                    addb      $02,s
                    lda       b,x
                    leas      $03,s
                    rts
L3220               ldd       #$0000
                    subd      $02,s
                    cmpd      $04,s
                    blt       L322D
                    clra
                    bra       L323A
L322D               ldd       $02,s
                    cmpd      $04,s
                    bgt       L3238
                    lda       #$02
                    bra       L323A
L3238               lda       #$01
L323A               rts
L323B               lda       ,y
                    bsr       L324B
                    rts
L3240               ldb       ,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    bsr       L324B
                    rts
L324B               leas      -$01,s
                    sta       ,s
                    lbsr      L27D4
                    lbsr      L12FC
                    lbsr      L492F
                    lda       #$01
                    sta       >$05B1
                    ldu       <$0030
L325F               cmpu      <$0032
                    bcc       L328F
                    lda       <$26,u
                    anda      #$BE
                    ora       #$10
                    sta       <$26,u
                    ldd       #$0000
                    sta       <$25,u
                    std       <$10,u
                    std       $06,u
                    std       <$16,u
                    inca
                    sta       <$1E,u
                    sta       <$1F,u
                    sta       <$20,u
                    sta       $01,u
                    sta       ,u
                    leau      <$2B,u
                    bra       L325F
L328F               lbsr      L22F3
                    clra
                    sta       >$01AC
                    sta       >$0435
                    sta       >$0436
                    inca
                    sta       >$0250
                    lda       #$24
                    sta       >$01D6
                    lda       >$0431
                    sta       >$0432
                    ldb       ,s
                    stb       >$0431
                    lbsr      L25B7
                    ldb       <$006A
                    beq       L32BA
                    lbsr      L25C7
L32BA               ldu       <$0030
                    lda       $05,u
                    sta       >$0441
                    lda       >$0433
                    beq       L32F2
                    cmpa      #$01
                    bne       L32D0
                    lda       #$A7
                    sta       $04,u
                    bra       L32EF
L32D0               cmpa      #$02
                    bne       L32DA
                    lda       #$00
                    sta       $03,u
                    bra       L32EF
L32DA               cmpa      #$03
                    bne       L32E4
                    lda       #$25
                    sta       $04,u
                    bra       L32EF
L32E4               cmpa      #$04
                    bne       L32EF
                    lda       #$A0
                    suba      <$1C,u
                    sta       $03,u
L32EF               clr       >$0433
L32F2               lda       >$01AE
                    ora       #$04
                    sta       >$01AE
                    lbsr      L096F
                    lbsr      L5801
                    lbsr      L5EC4
                    ldy       #$0000
                    leas      $01,s
                    rts
L330A               bsr       L331F
                    lda       #$FF
                    sta       $02,u
                    rts
L3311               bsr       L3335
                    lda       #$FF
                    sta       $02,u
                    rts
L3318               bsr       L331F
                    lda       #$00
                    sta       $02,u
                    rts
L331F               ldx       <$0038
                    ldb       ,y+
                    abx
                    abx
                    abx
                    tfr       x,u
                    cmpu      <$003C
                    bcs       L3334
                    lda       #$17
                    ldb       -$01,y
                    lbsr      L10ED
L3334               rts
L3335               ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    ldx       <$0038
                    abx
                    abx
                    abx
                    tfr       x,u
                    cmpu      <$003C
                    bcs       L3350
                    lda       #$17
                    ldb       -$01,y
                    lbsr      L10ED
l3350               rts
L3351               bsr       L331F
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       $02,u
                    rts
L335E               bsr       L3335
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       $02,u
                    rts
L336B               bsr       L3335
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       $02,u
                    sta       ,x
                    rts
L3378               fcb       1
L3379               leas      -2,s
                    stx       ,s
                    pshs      x
                    lda       #$1B
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldx       ,s
                    bsr       L3391
                    leas      $02,s
                    rts
L3391               ldu       ,x
                    beq       L33AD
                    ldd       #$0000
                    std       ,x
                    std       $02,x
                    tfr       u,x
L339E               stx       <$0055
                    ldu       $0A,x
                    lda       $0C,x
                    lbsr      L27EB
                    stu       <$004F
                    ldx       ,x
                    bne       L339E
L33AD               rts
L33AE               leas      >-$00C8,s
                    stu       ,s
                    stx       $02,s
                    ldu       <$0030
                    clr       $04,s
L33BA               cmpu      <$0032
                    bcc       L3407
                    jsr       [,s]
                    tsta
                    beq       L3402
                    leax      $05,s
                    lda       $04,s
                    lsla
                    stu       a,x
                    ldb       $04,u
                    lda       <$26,u
                    bita      #$04
                    beq       L33F8
                    lda       >L3378,pcr
                    beq       L33E6
                    lda       <$24,u
                    suba      #$05
                    ldb       #$0C
                    mul
                    addb      #$30
                    bra       L33F8
L33E6               clrb
                    lda       <$24,u
                    beq       L33F8
                    ldx       #$05ED
                    ldb       #$A8
L33F1               cmpa      b,x
                    bhi       L33F8
                    decb
                    bne       L33F1
L33F8               leax      >$0085,s
                    lda       $04,s
                    stb       a,x
                    inc       $04,s
L3402               leau      <$2B,u
                    bra       L33BA
L3407               clra
L3408               sta       >$00C5,s
                    cmpa      $04,s
                    bcc       L344A
                    leax      >$0085,s
                    lda       #$FF
                    sta       >$00C7,s
                    clra
L341B               cmpa      $04,s
                    bcc       L3432
                    ldb       a,x
                    cmpb      >$00C7,s
                    bcc       L342F
                    sta       >$00C6,s
                    stb       >$00C7,s
L342F               inca
                    bra       L341B
L3432               lda       #$FF
                    ldb       >$00C6,s
                    sta       b,x
                    leau      $05,s
                    lslb
                    ldx       b,u
                    ldu       $02,s
                    bsr       L3451
                    lda       >$00C5,s
                    inca
                    bra       L3408
L344A               ldx       $02,s
                    leas      >$00C8,s
                    rts
L3451               leas      -$02,s
                    stu       ,s
                    lbsr      L445B
                    ldx       ,s
                    ldx       ,x
                    stx       ,u
                    beq       L3462
                    stu       $02,x
L3462               ldx       ,s
                    stu       ,x
                    ldd       $02,x
                    bne       L346C
                    stu       $02,x
L346C               leas      $02,s
                    rts

L346F               fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0
L3498               fcb       0,0
L349A               fcc       / ,.?!();:[]{}/
                    fcb       0
L34A8               fcc       /'`-"/
                    fcb       0

L34AD               leas      -$07,s
                    stx       ,s
                    clrb
                    ldu       #$0180
                    ldx       #$0014
                    lbsr      L2C7A
                    ldu       #$0194
                    ldx       #$0014
                    lbsr      L2C7A
                    ldu       ,s
                    lbsr      L3563
                    clr       $02,s
L34CB               leau      >L346F,pcr
                    stu       >L3498,pcr
                    ldd       <$000A
                    std       $05,s
                    ldd       >$01AA
                    lbsr      L280B
L34DD               lda       ,u
                    beq       L352A
                    lda       $02,s
                    cmpa      #$0A
                    bcc       L352A
                    lbsr      L35C4
                    std       $03,s
                    beq       L3524
                    bpl       L350A
                    ldx       #$0180
                    ldb       $02,s
                    abx
                    abx
                    stu       ,x
                    incb
                    stb       >$015A
                    stb       >$043A
                    lda       >$01AE
                    ora       #$20
                    sta       >$01AE
                    bra       L3539
L350A               ldb       $02,s
                    ldx       #$0194
                    abx
                    abx
                    ldd       $03,s
                    std       ,x
                    ldb       $02,s
                    ldx       #$0180
                    abx
                    abx
                    ldd       >L3498,pcr
                    std       ,x
                    inc       $02,s
L3524               stu       >L3498,pcr
                    bra       L34DD
L352A               lda       $02,s
                    beq       L3539
                    sta       >$015A
                    lda       >$01AE
                    ora       #$20
                    sta       >$01AE
L3539               ldd       $05,s
                    lbsr      L280B
                    leas      $07,s
                    rts

L3541               lda       >$01AE
                    anda      #$DF
                    sta       >$01AE
                    lda       >$01AE
                    anda      #$F7
                    sta       >$01AE
                    lda       ,y+
                    cmpa      #$0C
                    bcc       L3562
                    ldb       #$28
                    mul
                    ldx       #$0251
                    leax      d,x
                    lbsr      L34AD
L3562               rts

L3563               leas      -$02,s
                    leax      >L346F,pcr
                    stx       ,s
L356B               lda       ,u+
                    beq       L35AB
                    leax      >L349A,pcr
                    lbsr      L12D9
                    bne       L356B
                    leax      >L34A8,pcr
                    lbsr      L12D9
                    bne       L356B
                    bra       L3595
L3583               leax      >L349A,pcr
                    lbsr      L12D9
                    bne       L35A1
                    leax      >L34A8,pcr
                    lbsr      L12D9
                    bne       L359B
L3595               ldx       ,s
                    sta       ,x+
                    stx       ,s
L359B               lda       ,u+
                    bne       L3583
                    bra       L35AB
L35A1               lda       #$20
                    ldx       ,s
                    sta       ,x+
                    stx       ,s
                    bra       L356B
L35AB               leax      >L346F,pcr
                    cmpx      ,s
                    bcc       L35BF
                    ldx       ,s
                    lda       -$01,x
                    cmpa      #$20
                    bne       L35BF
                    leax      -$01,x
                    stx       ,s
L35BF               clr       [,s]
                    leas      $02,s
                    rts

L35C4               leas      -$06,s
                    ldd       #$FFFF
                    std       ,s
                    ldd       #$0000
                    std       $02,s
                    lda       ,u
                    lbsr      L12B2
                    cmpa      #$61
                    bcs       L35DD
                    cmpa      #$7A
                    bls       L35E3
L35DD               lbsr      L367B
                    lbra      L3676
L35E3               ldb       $01,u
                    cmpb      #$20
                    beq       L35ED
                    cmpb      #$00
                    bne       L3606
L35ED               cmpa      #$61
                    beq       L35F5
                    cmpa      #$69
                    bne       L3606
L35F5               clrb
                    stb       ,s
                    stb       $01,s
                    leax      $01,u
                    stx       $02,s
                    ldb       ,x+
                    cmpb      #$20
                    bne       L3606
                    stx       $02,s
L3606               suba      #$61
                    lsla
                    ldx       >$01A8
                    ldd       a,x
                    beq       L35DD
                    leax      d,x
                    clr       $04,s
L3614               lda       $04,s
                    cmpa      ,x+
                    bhi       L366A
                    bne       L365A
L361C               lda       ,x
                    anda      #$7F
                    sta       $05,s
                    lda       ,u
                    lbsr      L12B2
                    eora      #$7F
                    cmpa      $05,s
                    bne       L365A
                    leau      $01,u
                    inc       $04,s
                    lda       ,x
                    anda      #$80
                    beq       L3656
                    lda       ,u
                    cmpa      #$00
                    beq       L3641
                    cmpa      #$20
                    bne       L3660
L3641               ldd       $01,x
                    std       ,s
                    stu       $02,s
                    lda       ,u
                    cmpa      #$00
                    beq       L3676
                    tfr       u,d
                    addd      #$0001
                    std       $02,s
                    bra       L3660
L3656               leax      $01,x
                    bra       L361C
L365A               lda       ,u
                    cmpa      #$00
                    beq       L366A
L3660               lda       ,x+
                    bpl       L3660
                    leax      $02,x
                    cmpa      #$00
                    bne       L3614
L366A               ldu       $02,s
                    lbeq      L35DD
                    lda       ,u
                    beq       L3676
                    clr       -$01,u
L3676               ldd       ,s
                    leas      $06,s
                    rts

L367B               ldu       >L3498,pcr
                    tfr       u,x
L3681               lda       ,x+
                    beq       L368B
                    cmpa      #$20
                    bne       L3681
                    clr       -$01,x
L368B               rts

L368C               ldu       #$05B2
                    lda       ,y+
                    sta       ,u
                    lda       ,y+
                    sta       $01,u
                    lda       ,y+
                    sta       $02,u
                    ldd       ,y++
                    std       $03,u
                    lda       $01,y
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       ,y++
                    sta       $05,u
                    bsr       L36E6
                    rts

L36AC               ldu       #$05B2
                    ldx       #$0431
                    clra
                    ldb       ,y+
                    ldb       d,x
                    stb       ,u
                    ldb       ,y+
                    ldb       d,x
                    stb       $01,u
                    ldb       ,y+
                    ldb       d,x
                    stb       $02,u
                    ldb       ,y+
                    ldb       d,x
                    stb       $03,u
                    ldb       ,y+
                    ldb       d,x
                    stb       $04,u
                    ldb       ,y+
                    ldb       d,x
                    stb       $05,u
                    ldb       ,y+
                    ldb       d,x
                    lslb
                    lslb
                    lslb
                    lslb
                    orb       $05,u
                    stb       $05,u
                    bsr       L36E6
                    rts

L36E6               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       #$05
                    clrb
                    lbsr      L494E
                    ldx       #$05B2
                    ldd       ,x
                    lbsr      L494E
                    ldd       $02,x
                    lbsr      L494E
                    ldd       $04,x
                    lbsr      L494E
                    ldu       <$0036
                    ldb       $02,x
                    stb       $0E,u
                    ldb       $01,x
                    stb       $0A,u
                    ldb       ,x
                    lbsr      L60EF
                    ldd       <$10,u
                    std       <$12,u
                    ldd       $08,u
                    std       <$14,u
                    ldx       #$05B2
                    ldd       $03,x
                    std       $03,u
                    std       <$1A,u
                    lda       #$02
                    ldb       #$0C
                    std       <$25,u
                    lda       #$0F
                    sta       <$24,u
                    lbsr      L164B
                    ldx       #$05B2
                    lda       $05,x
                    anda      #$0F
                    bne       L3745
                    lda       #$08
                    sta       <$26,u
L3745               lda       $05,x
                    sta       <$24,u
                    lbsr      L058F
                    ldd       <$0036
                    pshs      b,a
                    lda       #$0F
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      L059C
                    ldd       <$0036
                    pshs      b,a
                    lda       #$1B
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L3776               fcb       0,0,0,0,0,0,0
L377D               fdb       0

L377F               leau      $3776,pcr
                    ldd       #0
                    std       ,u
                    rts

L3789               leau      >L3776,pcr
L378D               stu       >L377D,pcr
                    ldu       ,u
                    beq       L3799
                    cmpb      $02,u
                    bne       L378D
L3799               rts

L379A               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L37A5
                    rts

L37A5               leas      -$05,s
                    stb       ,s
                    bsr       L3789
                    cmpu      #$0000
                    bne       L37F7
                    ldd       <$000A
                    std       $03,s
                    lbsr      L058F
                    lda       #$02
                    ldb       ,s
                    lbsr      L494E
                    leau      >L3776,pcr
                    ldx       >L377D,pcr
                    beq       L37D6
                    ldd       #$0007
                    lbsr      L278C
                    stu       ,x
                    ldd       #$0000
                    std       ,u
L37D6               ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      L50B2
                    ldx       #$0000
                    lbsr      L4C1B
                    beq       L37ED
                    ldx       $01,s
                    std       $05,x
                    stu       $03,x
L37ED               lbsr      L059C
                    ldd       $03,s
                    lbsr      L280B
                    ldu       $01,s
L37F7               leas      $05,s
                    rts

L37FA               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L3805
                    rts

L3805               leas      -$01,s
                    stb       ,s
                    stb       >$0240
                    lbsr      L3789
                    cmpu      #$0000
                    bne       L381C
                    lda       #$12
                    ldb       ,s
                    lbsr      L10ED
L381C               ldd       $03,u
                    std       >$0551
                    pshs      u
                    lda       #$04
                    ldb       $02,s
                    lbsr      L494E
                    lbsr      L058F
                    lda       #$06
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      L059C
                    clr       >$0100
                    leas      $01,s
                    rts

L3841               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L384C
                    rts

L384C               leas      -$01,s
                    stb       ,s
                    stb       >$0240
                    lbsr      L3789
                    cmpu      #$0000
                    bne       L3863
                    lda       #$12
                    ldb       ,s
                    lbsr      L10ED
L3863               ldd       $03,u
                    std       >$0551
                    pshs      u
                    lda       #$08
                    ldb       $02,s
                    lbsr      L494E
                    lbsr      L058F
                    lda       #$09
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      L059C
                    lbsr      L05BB
                    clr       >$0100
                    leas      $01,s
                    rts

L388B               lda       >$01AF
                    anda      #$FE
                    sta       >$01AF
                    lbsr      L3C4C
                    lbsr      L2E9B
                    lda       #$01
                    sta       >$0100
                    rts

L389F               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L38AA
                    rts

L38AA               leas      -$03,s
                    stb       ,s
                    lbsr      L3789
                    ldb       ,s
                    cmpu      #$0000
                    bne       L38BE
                    lda       #$15
                    lbsr      L10ED
L38BE               stu       $01,s
                    lda       #$06
                    ldb       ,s
                    lbsr      L494E
                    ldu       >L377D,pcr
                    ldd       #$0000
                    std       ,u
                    lbsr      L058F
                    ldu       $01,s
                    stu       <$0055
                    lda       $05,u
                    ldu       $03,u
                    lbsr      L27EB
                    stu       <$004F
                    lbsr      L059C
                    lbsr      L27E2
                    leas      $03,s
                    rts

L38E9               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldd       ,y++
                    std       $03,u
                    std       <$1A,u
                    rts

L38FA               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    std       $03,u
                    std       <$1A,u
                    rts

L3919               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       $03,u
                    sta       ,x
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       $04,u
                    sta       ,x
                    rts

L3937               leas      -$02,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    sex
                    std       ,s
                    clra
                    ldb       $03,u
                    addd      ,s
                    bpl       L395D
                    clrb
L395D               stb       $03,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    sex
                    std       ,s
                    clra
                    ldb       $04,u
                    addd      ,s
                    bpl       L3972
                    clrb
L3972               stb       $04,u
                    lbsr      L164B
                    leas      $02,s
                    rts

L397A               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldd       ,y++
                    std       $03,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lbsr      L164B
                    rts

L3993               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    std       $03,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lbsr      L164B
                    rts

L39BA               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$01
                    sta       <$25,u
                    rts

L39CC               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$08
                    sta       <$25,u
                    rts

L39DE               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    anda      #$F6
                    sta       <$25,u
                    rts

L39F0               lda       ,y+
                    sta       >$01D6
                    rts

L39F6               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$08
                    sta       <$26,u
                    rts

L3A08               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$F7
                    sta       <$26,u
                    rts

L3A1A               fcc       /Message too verbose:/
                    fcb       $0a,$0a
                    fcc       /"%s..."/
                    fcb       $0a,$0a
                    fcc       /Press CTRL-BREAK to continue./
                    fcb       0

L3A57               fcb       $ff
L3A58               fcb       $ff
L3A59               fcb       $ff

L3A5A               ldb       ,y+
                    lbsr      L3E0D
                    bsr       L3AA7
                    rts
L3A62               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    lbsr      L3E0D
                    bsr       L3AA7
                    rts
L3A70               ldb       ,y+
                    bsr       L3A80
                    rts
L3A75               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L3A80
                    rts

L3A80               lda       ,y+
                    sta       >L3A58,pcr
                    lda       ,y+
                    sta       >L3A57,pcr
                    lda       ,y+
                    bne       L3A92
                    lda       #$1E
L3A92               sta       >L3A59,pcr
                    lbsr      L3E0D
                    bsr       L3AA7
                    ldd       #$FFFF
                    sta       >L3A59,pcr
                    std       >L3A57,pcr
L3AA6               rts

L3AA7               leas      -$05,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3B1D
                    leas      $08,s
L3ABF               lda       >$01AF
                    anda      #$01
                    beq       L3AD2
                    lda       >$01AF
                    anda      #$FE
                    sta       >$01AF
                    lda       #$01
                    bra       L3B1A
L3AD2               lda       >$0446
                    bne       L3AE7
                    lda       #$01
                    sta       ,s
                    lbsr      L13C3
                    cmpa      #$01
                    beq       L3B15
                    clra
                    sta       ,s
                    bra       L3B15
L3AE7               ldb       #$0A
                    mul
                    orcc      #$50
                    addd      >$024A
                    std       $03,s
                    ldd       >$0248
                    andcc     #$AF
                    bcc       L3AFB
                    addd      #$0001
L3AFB               std       $01,s
L3AFD               ldd       $01,s
                    cmpd      >$0248
                    blt       L3B15
                    bgt       L3B0F
                    ldd       $03,s
                    cmpd      >$024A
                    bls       L3B15
L3B0F               lbsr      L13B0
                    tsta
                    bmi       L3AFD
L3B15               lbsr      L3C4C
                    lda       ,s
L3B1A               leas      $05,s
                    rts

L3B1D               leas      >-$02BC,s
                    lbsr      L3C4C
                    lbsr      L4903
                    lbsr      L4A5F
                    clra
                    ldb       #$0F
                    lbsr      L486F
                    ldb       >L3A59,pcr
                    cmpb      #$FF
                    bne       L3B46
                    tst       >$02C3,s
                    bne       L3B4E
                    ldb       #$1E
                    stb       >$02C3,s
                    bra       L3B4E
L3B46               lda       >L3A59,pcr
                    sta       >$02C3,s
L3B4E               leax      ,s
                    ldd       >$02C2,s
                    pshs      b,a
                    ldd       >$02C0,s
                    pshs      b,a
                    pshs      x
                    lbsr      L3C6A
                    leas      $06,s
                    tst       >$02C5,s
                    beq       L3B79
                    lda       >$02C3,s
                    sta       >$0159
                    lda       >$02C1,s
                    beq       L3B79
                    sta       >$015B
L3B79               lda       #$13
                    cmpa      >$015B
                    bcc       L3BAE
                    ldx       >$02BE,s
                    lda       <$14,x
                    clr       <$14,x
                    pshs      x,a
                    leau      >L3A1A,pcr
                    leax      >$025B,s
                    ldd       >$02C1,s
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3ED6
                    leas      $06,s
                    puls      x,a
                    sta       <$14,x
                    stu       >$02BE,s
                    bra       L3B4E
L3BAE               lda       >$015B
                    ldb       #$08
                    mul
                    addb      #$0A
                    stb       >$017B
                    lda       >$0159
                    ldb       #$04
                    mul
                    addb      #$0A
                    stb       >$017C
                    lda       >L3A58,pcr
                    bpl       L3BD2
                    lda       #$13
                    suba      >$015B
                    lsra
                    adda      #$01
L3BD2               adda      >$0241
                    sta       >$0175
                    adda      >$015B
                    deca
                    sta       >$0177
                    lda       >L3A57,pcr
                    bpl       L3BEB
                    lda       #$28
                    suba      >$0159
                    lsra
L3BEB               sta       >$0176
                    sta       >$017A
                    adda      >$0159
                    sta       >$0178
                    lda       >$0175
                    ldb       >$0176
                    std       <$0040
                    lda       #$04
                    mul
                    subb      #$05
                    stb       >$017D
                    lda       >$0177
                    inca
                    suba      >$0241
                    ldb       #$08
                    mul
                    addb      #$04
                    stb       >$017E
                    ldd       #$040F
                    pshs      b,a
                    ldd       >$017B
                    pshs      b,a
                    ldd       >$017D
                    pshs      b,a
                    lda       #$0C
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $06,s
                    lda       #$01
                    sta       >$017F
                    leax      ,s
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    clr       >$017A
                    lbsr      L4A73
                    lbsr      L4918
                    leas      >$02BC,s
                    rts

L3C4C               tst       >$017F
                    beq       L3C69
                    ldd       >$017B
                    pshs      b,a
                    ldd       >$017D
                    pshs      b,a
                    lda       #$03
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
                    clr       >$017F
L3C69               rts

L3C6A               ldd       #$0000
                    sta       >$015B
                    sta       >$0157
                    sta       >$0159
                    std       >$0155
                    lda       $07,s
                    sta       >$0158
                    ldu       $04,s
                    beq       L3C92
                    ldd       $02,s
                    pshs      b,a
                    pshs      u
                    lbsr      L3C95
                    leas      $04,s
                    clr       ,u
                    lbsr      L3EBE
L3C92               ldx       $02,s
                    rts

L3C95               leas      -$02,s
                    pshs      x
                    ldx       $06,s
                    ldu       $08,s
                    tst       ,x
                    lbeq      L3E08
                    lda       >$015B
                    cmpa      #$13
                    lbhi      L3E08
L3CAC               lda       >$0157
                    cmpa      >$0158
                    lbcc      L3DB5
                    lda       ,x
                    lbeq      L3E08
                    cmpa      >$0101
                    bne       L3CC5
                    tst       ,x+
                    bra       L3CD9
L3CC5               cmpa      #$25
                    beq       L3CE2
                    cmpa      #$0A
                    bne       L3CD2
                    lbsr      L3EBE
                    bra       L3CDC
L3CD2               cmpa      #$20
                    bne       L3CD9
                    stu       >$0155
L3CD9               inc       >$0157
L3CDC               lda       ,x+
                    sta       ,u+
                    bra       L3CAC
L3CE2               ldd       ,x++
                    cmpb      #$77
                    beq       L3D16
                    cmpb      #$73
                    beq       L3D2C
                    cmpb      #$6D
                    beq       L3D3B
                    cmpb      #$67
                    beq       L3D4D
                    cmpb      #$76
                    lbeq      L3D83
                    cmpb      #$6F
                    bne       L3CAC
                    stu       $08,s
                    lbsr      L3EA9
                    clra
                    ldu       #$0431
                    lda       d,u
                    ldb       #$03
                    mul
                    addd      #$0000
                    ldu       <$0038
                    ldu       d,u
                    lbra      L3DA5
L3D16               stu       $08,s
                    lbsr      L3EA9
                    decb
                    bmi       L3CAC
                    cmpb      >$015A
                    bcc       L3CAC
                    lslb
                    ldu       #$0180
                    leau      [b,u]
                    lbra      L3DA5
L3D2C               stu       $08,s
                    lbsr      L3EA9
                    lda       #$28
                    mul
                    addd      #$0251
                    tfr       d,u
                    bra       L3DA5
L3D3B               stu       $08,s
                    lbsr      L3EA9
                    lbsr      L3E0D
                    cmpu      #$0000
                    lbeq      L3CAC
                    bra       L3DA5
L3D4D               stu       $08,s
                    ldd       <$0062
                    std       $02,s
                    clrb
                    lbsr      L2598
                    stu       <$0062
                    ldd       $04,u
                    lbsr      L280B
                    lbsr      L3EA9
                    lbsr      L3E0D
                    cmpu      #$0000
                    beq       L3D75
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      L3C95
                    leas      $04,s
L3D75               ldu       $02,s
                    stu       <$0062
                    ldd       $04,u
                    lbsr      L280B
                    ldu       $08,s
                    lbra      L3CAC
L3D83               stu       $08,s
                    lbsr      L3EA9
                    ldu       #$0431
                    clra
                    ldb       d,u
                    pshs      x
                    lbsr      L1226
                    tfr       x,u
                    puls      x
                    lda       ,x
                    cmpa      #$7C
                    bne       L3DA5
                    leax      $01,x
                    lbsr      L3EA9
                    lbsr      L1281
L3DA5               ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      L3C95
                    leas      $04,s
                    stu       $08,s
                    lbra      L3CAC
L3DB5               ldd       >$0155
                    bne       L3DC6
                    lda       #$0A
                    sta       ,u+
                    stu       $08,s
                    lbsr      L3EBE
                    lbra      L3CAC
L3DC6               clr       ,u
                    tfr       u,d
                    subd      >$0155
                    negb
                    addb      >$0157
                    stb       >$0157
                    lbsr      L3EBE
                    pshs      x
                    ldx       >$0155
                    lda       #$0A
                    sta       ,x+
L3DE0               lda       ,x+
                    cmpa      #$20
                    beq       L3DE0
                    leax      -$01,x
                    ldu       >$0155
                    leau      $01,u
                    lbsr      L11B4
                    ldd       #$0000
                    std       >$0155
L3DF6               lda       ,x+
                    beq       L3DFF
                    inc       >$0157
                    bra       L3DF6
L3DFF               leau      -$01,x
                    stu       $0A,s
                    puls      x
                    lbra      L3CAC
L3E08               puls      x
                    leas      $02,s
                    rts

L3E0D               leas      -$01,s
                    ldu       <$0062
                    cmpb      $03,u
                    bls       L3E1C
                    ldd       #$0000
                    tfr       d,u
                    bra       L3E2E
L3E1C               ldu       $0A,u
                    stb       ,s
                    clra
                    lslb
                    rola
                    ldd       d,u
                    bne       L3E2E
                    ldb       ,s
                    lda       #$0E
                    lbsr      L10ED
L3E2E               exg       a,b
                    leau      d,u
                    leas      $01,s
                    rts

L3E35               leas      >-$03E8,s
                    lbsr      L4A5F
                    ldd       ,y++
                    std       <$0040
                    ldb       ,y+
                    bsr       L3E0D
                    leax      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3C6A
                    leas      $06,s
                    leax      ,s
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    lbsr      L4A73
                    leas      >$03E8,s
                    rts

L3E65               leas      >-$03E8,s
                    lbsr      L4A5F
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    std       <$0040
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L3E0D
                    leax      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3C6A
                    leas      $06,s
                    leax      ,s
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    lbsr      L4A73
                    leas      >$03E8,s
                    rts

L3EA9               clrb
L3EAA               lda       ,x
                    cmpa      #$30
                    bcs       L3EBD
                    cmpa      #$39
                    bhi       L3EBD
                    lda       #$0A
                    mul
                    subb      #$30
                    addb      ,x+
                    bra       L3EAA
L3EBD               rts
L3EBE               inc       >$015B
                    lda       >$0157
                    clr       >$0157
                    cmpa      >$0159
                    bls       L3ECF
                    sta       >$0159
L3ECF               rts
L3ED0               fcb       0,0
L3ED2               fcb       0
L3ED3               fcb       0
L3ED4               fcb       0,0

L3ED6               clr       >L3ED2,pcr
                    ldd       $02,s
                    std       >L3ED0,pcr
                    ldx       $04,s
                    leau      $06,s
                    bsr       L3F0C
                    ldu       $02,s
                    rts

L3EE9               leas      <-$2A,s
                    clr       >L3ED3,pcr
                    lda       #$01
                    sta       >L3ED2,pcr
                    leax      ,s
                    stx       >L3ED4,pcr
                    stx       >L3ED0,pcr
                    ldx       <$2C,s
                    leau      <$2E,s
                    bsr       L3F0C
                    leas      <$2A,s
                    rts

L3F0C               lda       ,x+
                    beq       L3F7F
                    cmpa      #$25
                    beq       L3F18
                    bsr       L3F7F
                    bra       L3F0C
L3F18               lda       ,x+
                    cmpa      #$73
                    bne       L3F24
                    ldd       ,u++
                    pshs      u,x
                    bra       L3F6E
L3F24               cmpa      #$64
                    bne       L3F3E
                    tst       ,u
                    bpl       L3F51
                    lda       #$2D
                    bsr       L3F7F
                    ldd       #$0000
                    subd      ,u++
                    pshs      u,x
                    lbsr      L1226
                    tfr       x,d
                    bra       L3F6E
L3F3E               cmpa      #$75
                    beq       L3F51
                    cmpa      #$78
                    bne       L3F5C
                    ldd       ,u++
                    pshs      u,x
                    lbsr      L123E
                    tfr       x,d
                    bra       L3F6E
L3F51               ldd       ,u++
                    pshs      u,x
                    lbsr      L1226
                    tfr       x,d
                    bra       L3F6E
L3F5C               cmpa      #$63
                    bne       L3F66
                    ldd       ,u++
                    bsr       L3F7F
                    bra       L3F0C
L3F66               leax      -$01,x
                    lda       -$01,x
                    bsr       L3F7F
                    bra       L3F0C
L3F6E               tfr       d,x
L3F70               lda       ,x+
                    lbne      L3F7B
                    puls      u,x
                    lbra      L3F0C
L3F7B               bsr       L3F7F
                    bra       L3F70
L3F7F               pshs      u,x
                    ldu       >L3ED0,pcr
                    sta       ,u+
                    stu       >L3ED0,pcr
                    tst       >L3ED2,pcr
                    beq       L3FD4
                    tsta
                    beq       L3FA4
                    cmpa      #$0A
                    beq       L3FA4
                    cmpa      #$0D
                    beq       L3FA4
                    lda       #$01
                    sta       >L3ED3,pcr
                    bra       L3FD4
L3FA4               tst       >L3ED3,pcr
                    beq       L3FC6
                    clr       ,-u
                    pshs      a
                    ldd       >L3ED4,pcr
                    pshs      b,a
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    clra
                    sta       >L3ED3,pcr
                    puls      a
L3FC6               tsta
                    beq       L3FCC
                    lbsr      L49E9
L3FCC               ldu       >L3ED4,pcr
                    stu       >L3ED0,pcr
L3FD4               puls      u,x
                    rts

L3FD7               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$04
                    sta       <$26,u
                    lda       ,y+
                    sta       <$24,u
                    rts

L3FEE               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$FB
                    sta       <$26,u
                    rts

L4000               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$24,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    sta       ,x
                    rts

L4015               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$04
                    sta       <$26,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    sta       <$24,u
                    rts

L4032               leas      -$09,s
                    clr       ,s
                    ldd       <$008B
                    bne       L4049
                    leax      $03,s
                    os9       F$Time
                    ldd       $07,s
                    addd      $05,s
                    addd      $03,s
                    orb       #$01
                    std       <$008B
L4049               lda       #$4D
                    mul
                    std       $01,s
                    ldb       <$008B
                    lda       #$4D
                    mul
                    addd      ,s
                    std       ,s
                    lda       #$7C
                    ldb       <$008C
                    mul
                    addd      ,s
                    std       ,s
                    ldd       $01,s
                    addd      #$0001
                    std       <$008B
                    eorb      <$008B
                    leas      $09,s
                    rts

L406C               fcc       /Press ENTER to start a new/
                    fcb       $0a
                    fcc       /game./
                    fcb       $0a,$0a
                    fcc       /Press CTRL-BREAK to continue/
                    fcb       $0a
                    fcc       /with this game./
                    fcb       0

L40BB               leas      -$01,s
                    lbsr      L5E91
                    lda       >$01B0
                    anda      #$80
                    bne       L40D0
                    leau      >L406C,pcr
                    lbsr      L3AA7
                    beq       L4112
L40D0               lbsr      L5E3D
                    lda       >$01AF
                    anda      #$40
L40D8               sta       ,s
                    lbsr      L27D4
                    lbsr      L2222
                    lbsr      L4EBE
                    lda       >$01AE
                    ora       #$02
                    sta       >$01AE
                    lda       ,s
L40ED               beq       L40F7
                    lda       >$01AF
L40F2               ora       #$40
                    sta       >$01AF
L40F7               orcc      #$50
                    ldd       #$0000
                    std       >$0248
                    std       >$024A
                    andcc     #$AF
                    ldb       <$006A
                    beq       L410B
                    lbsr      L25C7
L410B               lbsr      L295F
                    ldy       #$0000
L4112               lbsr      L5E80
                    leas      $01,s
                    rts

L4118               fcc       /About to restore the game/
                    fcb       $0a
                    fcc       /described as:/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /from file:/
                    fcb       $0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       0
L4157               fcc       /Can't open file:/
                    fcb       $0a
                    fcc       /%s/
                    fcb       0
L416B               fcc       /Error in restoring game./
                    fcb       $0a
                    fcc       /Press ENTER to quit./
                    fcb       $0a,0
L419A               fcc       /Press ENTER to continue./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to cancel./
                    fcb       0
L41CF               fcb       0

L41D0               leas      >-$00FD,s
                    sty       ,s
                    lda       #$01
                    sta       >$0102
                    lda       >$0101
                    sta       $02,s
                    lda       #$40
                    sta       >$0101
L41E6               ldd       #$0072
                    pshs      b,a
                    lbsr      L1C9F
                    leas      $02,s
                    tsta
                    lbeq      L42F5
                    lda       >L449A,pcr
                    bne       L423B
                    leau      >L419A,pcr
                    pshs      u
L4201               leau      >L183F,pcr
L4205               pshs      u
                    leau      >L1820,pcr
                    pshs      u
                    leax      >L4118,pcr
                    leau      $09,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $0A,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3B1D
                    leas      $08,s
                    lbsr      L13C3
                    cmpa      #$00
                    lbeq      L42F5
L423B               lda       #$01
                    leax      >L183F,pcr
                    lbsr      L13FB
                    bcc       L4267
                    leau      >L183F,pcr
                    pshs      u
                    leau      >L1820,pcr
                    pshs      u
                    leax      >L4157,pcr
                    leau      $07,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $08,s
                    lbsr      L3AA7
                    lbra      L42F5
L4267               sta       >L41CF,pcr
                    clrb
                    ldx       #$0000
                    ldu       #$001F
                    lbsr      L143E
                    ldd       #$01AC
                    pshs      b,a
                    lbsr      L4308
                    leas      $02,s
                    beq       L42B8
                    ldd       <$0030
                    pshs      b,a
                    lbsr      L4308
                    leas      $02,s
                    beq       L42B8
                    ldd       <$0038
                    pshs      b,a
                    lbsr      L4308
                    leas      $02,s
                    beq       L42B8
                    ldx       <$0038
                    ldd       <$003A
                    leau      d,x
                    lbsr      L1080
                    ldd       >$05AF
                    pshs      b,a
                    lbsr      L4308
                    leas      $02,s
                    beq       L42B8
                    ldd       #$0554
                    pshs      b,a
                    lbsr      L4308
                    leas      $02,s
                    bne       L42CF
L42B8               lda       >L41CF,pcr
                    lbsr      L1433
                    leau      >L416B,pcr
                    lbsr      L3AA7
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L42CF               lda       >L41CF,pcr
                    lbsr      L1433
                    lda       >$0553
                    sta       >$044B
                    lbsr      L4339
                    lbsr      L096F
                    lda       >$01AF
                    ora       #$08
                    sta       >$01AF
                    lbsr      L4EBE
                    ldd       #$0000
                    std       ,s
                    lbsr      L295F
L42F5               lbsr      L3C4C
                    lda       $02,s
                    sta       >$0101
                    clr       >$0102
                    ldy       ,s
                    leas      >$00FD,s
                    rts

L4308               leas      -$02,s
                    lda       >L41CF,pcr
                    leax      ,s
                    ldy       #$0002
                    lbsr      L1406
                    cmpd      #$0002
                    bne       L4335
                    ldy       ,x
                    sty       ,s
                    lda       >L41CF,pcr
                    ldx       $04,s
                    lbsr      L1406
                    cmpy      ,s
                    bne       L4335
                    lda       #$01
                    bra       L4336
L4335               clra
L4336               leas      $02,s
                    rts

L4339               leas      >-$0206,s
                    leax      $06,s
                    stx       $04,s
                    lbsr      L22F3
                    clr       >$05B1
                    ldu       <$0030
L4349               cmpu      <$0032
                    bcc       L4367
                    ldd       <$25,u
                    ldx       $04,s
                    std       ,x++
                    stx       $04,s
                    bitb      #$40
                    beq       L4362
                    andb      #$FE
                    orb       #$10
                    stb       <$26,u
L4362               leau      <$2B,u
                    bra       L4349
L4367               lbsr      L058F
                    lbsr      L27D4
                    clr       >$0100
                    lbsr      L4995
L4373               lbsr      L49AA
                    cmpu      #$0000
                    beq       L43EC
                    ldd       ,u
                    cmpa      #$00
                    bne       L438A
                    lbsr      L25C7
                    lbsr      L2710
                    bra       L4373
L438A               cmpa      #$01
                    bne       L4395
                    lda       #$01
                    lbsr      L6053
                    bra       L4373
L4395               cmpa      #$02
                    bne       L439E
                    lbsr      L37A5
                    bra       L4373
L439E               cmpa      #$03
                    bne       L43A7
                    lbsr      L5396
                    bra       L4373
L43A7               cmpa      #$04
                    bne       L43B0
                    lbsr      L3805
                    bra       L4373
L43B0               cmpa      #$05
                    bne       L43D1
                    lbsr      L49AA
                    ldd       ,u
                    ldx       #$05B2
                    std       ,x
                    lbsr      L49AA
                    ldd       ,u
                    std       $02,x
                    lbsr      L49AA
                    ldd       ,u
                    std       $04,x
                    lbsr      L36E6
                    bra       L4373
L43D1               cmpa      #$06
                    bne       L43DA
                    lbsr      L38AA
                    bra       L4373
L43DA               cmpa      #$07
                    bne       L43E3
                    lbsr      L62B8
                    bra       L4373
L43E3               cmpa      #$08
                    bne       L4373
                    lbsr      L384C
                    bra       L4373
L43EC               lda       #$01
                    sta       >$05B1
                    ldu       <$0032
L43F3               leau      <-$2B,u
                    cmpu      <$0030
                    bcs       L4442
                    ldx       $04,s
                    ldd       ,--x
                    stx       $04,s
                    std       ,s
                    stu       $02,s
                    ldb       $05,u
                    lbsr      L602E
                    leax      ,x
                    beq       L4413
                    ldb       $05,u
                    lbsr      L60EF
L4413               ldd       ,s
                    bitb      #$40
                    beq       L43F3
                    bitb      #$01
                    beq       L443D
                    lda       $02,u
                    lbsr      L0F78
                    ldu       $02,s
                    lda       <$22,u
                    cmpa      #$02
                    bne       L4430
                    lda       #$FF
                    sta       <$29,u
L4430               ldd       ,s
                    bitb      #$10
                    bne       L443D
                    lbsr      L060A
                    ldu       $02,s
                    ldd       ,s
L443D               std       <$25,u
                    bra       L43F3
L4442               lbsr      L5E91
                    lbsr      L5E3D
                    lbsr      L2E9B
                    lda       #$01
                    sta       >$0100
                    lbsr      L5801
                    lbsr      L5EC4
                    leas      >$0206,s
                    rts

L445B               ldd       #$000E
                    lbsr      L278C
                    ldd       #$0000
                    std       ,u
                    std       $02,u
                    stx       $04,u
                    stu       <$16,x
                    ldd       <$1C,x
                    std       $08,u
                    ldd       $03,x
                    bita      #$01
                    beq       L447B
                    deca
                    inc       $08,u
L447B               subb      <$1D,x
                    incb
                    std       $06,u
                    ldd       $08,u
                    bita      #$01
                    beq       L448A
                    inca
                    sta       $08,u
L448A               mul
                    tfr       u,x
                    lbsr      L2759
                    lbsr      L27F8
                    std       $0C,x
                    stu       $0A,x
                    tfr       x,u
                    rts
L449A               fdb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0
L44B9               fcc       /About to save the game/
                    fcb       $0a
                    fcc       /described as:/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /in file:/
                    fcb       $0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       0
L44F3               fcc       /The directory/
                    fcb       $0a
                    fcc       /%s/
                    fcb       $0a
                    fcc       /is full./
                    fcb       $0a
                    fcc       /Press ENTER to continue./
                    fcb       0
L4526               fcc       /The disk is full./
                    fcb       $0a
                    fcc       /Press ENTER to continue./
                    fcb       0
L4551               fcb       0
L4552               lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #$251
                    leax      d,x
L455C               leau      >L449A,pcr
                    ldd       #$001F
                    lbsr      L11BF
                    rts

L4567               leas      >-$00FE,s
                    sty       ,s
                    clr       $02,s
                    lda       #$01
                    sta       >$0102
                    lda       >$0101
                    sta       $03,s
                    lda       #$40
                    sta       >$0101
                    ldd       #$0073
                    pshs      b,a
L4584               lbsr      L1C9F
                    leas      $02,s
                    tsta
                    lbeq      L468E
L458E               lda       >L449A,pcr
                    bne       L45D4
L4594               leau      >L419A,pcr
                    pshs      u
                    leau      >L183F,pcr
                    pshs      u
                    leau      >L1820,pcr
                    pshs      u
                    leax      >L44B9,pcr
                    leau      $0A,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $0A,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3B1D
                    leas      $08,s
                    lbsr      L13C3
                    cmpa      #$00
                    lbeq      L468E
L45D4               lda       #$02
                    ldb       #$03
                    leax      >L183F,pcr
                    lbsr      L13EA
                    bcc       L45FC
                    leau      >L1801,pcr
                    pshs      u
                    leax      >L44F3,pcr
                    leau      $06,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $06,s
                    lbsr      L3AA7
                    lbra      L468E
L45FC               sta       >L4551,pcr
                    leax      >L1820,pcr
                    ldy       #$001F
                    lbsr      L1417
                    cmpd      #$001F
                    bne       L4670
                    ldd       #$0385
                    pshs      b,a
                    ldd       #$01AC
                    pshs      b,a
                    lbsr      L46AE
                    leas      $04,s
                    beq       L4670
                    ldd       <$0034
                    pshs      b,a
                    ldd       <$0030
                    pshs      b,a
                    lbsr      L46AE
                    leas      $04,s
                    beq       L4670
                    inc       $02,s
                    ldx       <$0038
                    ldd       <$003A
                    leau      d,x
                    lbsr      L1080
                    ldd       <$003A
                    pshs      b,a
                    ldd       <$0038
                    pshs      b,a
                    lbsr      L46AE
                    leas      $04,s
                    beq       L4670
                    lda       >$0245
                    ldb       #$02
                    mul
                    pshs      b,a
                    ldd       >$05AF
                    pshs      b,a
                    lbsr      L46AE
                    leas      $04,s
                    beq       L4670
                    lbsr      L26ED
                    pshs      x
                    ldd       #$0554
                    pshs      b,a
                    lbsr      L46AE
                    leas      $04,s
                    bne       L4687
L4670               lda       >L4551,pcr
                    lbsr      L1433
                    leax      >L183F,pcr
                    lbsr      L1428
                    leau      >L4526,pcr
                    lbsr      L3AA7
                    bra       L468E
L4687               lda       >L4551,pcr
                    lbsr      L1433
L468E               lda       $02,s
                    beq       L469B
                    ldx       <$0038
                    ldd       <$003A
                    leau      d,x
                    lbsr      L1080
L469B               lbsr      L3C4C
                    lda       $03,s
                    sta       >$0101
                    clr       >$0102
                    ldy       ,s
                    leas      >$00FE,s
                    rts

L46AE               lda       >L4551,pcr
                    leax      $04,s
                    ldy       #$0002
                    lbsr      L1417
                    cmpd      #$0002
                    bne       L46D6
                    lda       >L4551,pcr
                    ldx       $02,s
                    ldy       $04,s
                    lbsr      L1417
                    cmpd      $04,s
                    bne       L46D6
                    lda       #$01
                    bra       L46D7
L46D6               clra
L46D7               rts

L46D8               fcb       0
L46D9               fcc       /%s%s%ssg.%d/
                    fcb       0

L46E5               leas      -5,s
                    stx       ,s
                    stb       2,s
                    ldd       #0
                    std       3,s
                    leax      $1801,pcr
                    lbsr      L11A0
                    decb
                    leax      b,x
                    lda       #$2F
                    cmpa      ,-x
                    beq       L4702
                    sta       $03,s
L4702               clra
                    ldb       $02,s
                    pshs      b,a
                    ldd       #$01CE
                    pshs      b,a
                    leax      $07,s
                    pshs      x
                    leax      >L1801,pcr
                    pshs      x
                    leax      >L46D9,pcr
                    ldu       $08,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $0C,s
                    lbsr      L12E9
                    tfr       u,x
                    leas      $05,s
                    rts
L472D               leas      <-$45,s
                    clr       ,s
                    leau      ,s
                    lbsr      L14E0
                    ldx       <$47,s
                    lbsr      L15D6
                    bcs       L4753
                    clr       <$40,s
                    leau      <$40,s
                    lbsr      L14BE
L4748               ldb       <$43,s
                    stb       >L46D8,pcr
                    lda       #$01
                    bra       L4754
L4753               clra
L4754               sta       <$44,s
                    leax      ,s
                    lbsr      L15D6
                    lda       <$44,s
                    leas      <$45,s
                    rts

L4763               leas      -$02,s
                    ldy       <$0062
                    ldd       $04,y
                    lbsr      L280B
                    ldy       $08,y
L4770               ldb       ,y+
L4772               tstb
                    beq       L478C
                    cmpb      #$FF
                    beq       L478E
                    cmpb      #$FE
                    bne       L4785
L477D               ldb       ,y+
                    lda       ,y+
                    leay      d,y
                    bra       L4770
L4785               lbsr      L04A1
                    leay      ,y
                    bne       L4772
L478C               bra       L47FE
L478E               ldd       #$0000
                    std       ,s
L4793               lda       ,y+
                    cmpa      #$FC
                    bhi       L47A3
                    bne       L47B7
                    lda       ,s
                    bne       L47C5
                    inc       ,s
                    bra       L4793
L47A3               cmpa      #$FF
                    bne       L47AB
                    leay      $02,y
                    bra       L4770
L47AB               cmpa      #$FD
                    bne       L47B7
                    lda       $01,s
                    eora      #$01
                    sta       $01,s
                    bra       L4793
L47B7               lbsr      L0D8B
                    eora      $01,s
                    clr       $01,s
                    tsta
                    bne       L47D5
                    lda       ,s
                    bne       L4793
L47C5               clr       ,s
L47C7               lda       ,y+
                    cmpa      #$FF
                    beq       L477D
                    cmpa      #$FC
                    bcc       L47C7
                    bsr       L47E7
                    bra       L47C7
L47D5               lda       ,s
                    beq       L4793
                    clr       ,s
L47DB               lda       ,y+
                    cmpa      #$FC
                    bhi       L47DB
                    beq       L4793
                    bsr       L47E7
                    bra       L47DB
L47E7               cmpa      #$0E
                    bne       L47F1
                    lda       ,y+
                    lsla
                    leay      a,y
                    rts

L47F1               lsla
                    lsla
                    adda      #$02
                    leax      >L0D26,pcr
                    lda       a,x
                    leay      a,y
                    rts
L47FE               leas      $02,s
                    rts

L4801               fcb       $00                 composite
                    fcb       $0C
                    fcb       $02
                    fcb       $2E
                    fcb       $06
                    fcb       $09
                    fcb       $04
                    fcb       $20
                    fcb       $10
                    fcb       $1B
                    fcb       $11
                    fcb       $3D
                    fcb       $17
                    fcb       $29
                    fcb       $33
                    fcb       $3F

                    fcb       $00                 rgb
                    fcb       $08
                    fcb       $14
                    fcb       $18
                    fcb       $20
                    fcb       $28
                    fcb       $22
                    fcb       $38
                    fcb       $07
                    fcb       $0B
                    fcb       $16
                    fcb       $1F
                    fcb       $27
                    fcb       $2D
                    fcb       $37
                    fcb       $3F

L4821               lbsr      L5E91
                    lda       #1
                    sta       $5EC
                    lda       #$15
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    rts

L4833               lbsr      L5E91
                    lbsr      L488E
                    rts

L483A               ldb       $02,y
                    pshs      b,a
                    ldb       $01,y
                    pshs      b,a
                    ldb       ,y
                    pshs      b,a
                    lbsr      L4A93
                    leas      $06,s
                    leay      $03,y
                    rts

* clear text rect (fixed)
L484E               ldb       $04,y
                    pshs      b,a
                    ldb       $03,y
                    lda       $02,y
                    pshs      b,a
                    ldb       $01,y
                    lda       ,y
                    pshs      b,a
                    lbsr      L4B56
                    leas      $06,s
                    leay      $05,y
                    rts

                    fcb       0,0,0,0             * to keep same code length

L486A               ldd       ,y++
                    bsr       L486F
                    rts

L486F               anda      #$0F
                    sta       >$024C
                    lsla
                    lsla
                    lsla
                    lsla
                    ora       >$024C
                    sta       >$024C
                    andb      #$0F
                    stb       >$024D
                    lslb
                    lslb
                    lslb
                    lslb
                    orb       >$024D
                    stb       >$024D
                    rts

L488E               lda       #$00
                    sta       >$05EC
                    lda       #$09
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    lbsr      L5801
                    lbsr      L5EC4
                    rts

L48A3               lda       ,y
                    sta       >$0241
                    adda      #$15
                    sta       >$023F
                    lda       ,y+
                    ldb       #$08
                    mul
                    lda       #$A0
                    mul
                    std       <$002C
                    lda       ,y+
                    sta       >$01D7
                    lda       ,y+
                    sta       >$0247
                    rts

L48C2               leas      -$04,s
                    pshs      y
                    leax      >L4801,pcr
                    ldb       >$0553
                    eorb      #$01
                    stb       >$0553
                    lda       #$10
                    mul
                    abx
                    lda       #$1B
                    sta       $02,s
                    lda       #$31
                    sta       $03,s
                    clra
                    sta       $04,s
                    ldy       #$0004
L48E5               ldb       ,x+
                    stb       $05,s
                    pshs      x
                    lda       #$01
                    leax      $04,s
                    os9       I$Write
                    bcs       L48FE
                    puls      x
                    inc       $04,s
                    lda       $04,s
                    cmpa      #$10
                    bcs       L48E5
L48FE               puls      y
                    leas      $04,s
                    rts

L4903               ldb       >$0171
                    cmpb      #$05
                    bcc       L4917
                    ldx       #$015C
                    lslb
                    abx
                    ldd       >$024C
                    std       ,x
                    inc       >$0171
L4917               rts

L4918               ldb       >$0171
                    ble       L492A
                    decb
                    stb       >$0171
                    ldx       #$015C
                    lslb
                    ldd       b,x
                    std       >$024C
L492A               rts

L492B               fdb       0
L492D               fdb       0

L492F               ldu       >$05AF
                    bne       L4946
                    lda       >$0245
                    beq       L4946
                    ldb       #$02
                    mul
                    lbsr      L278C
                    stu       >$05AF
                    ldd       <$0055
                    std       <$0053
L4946               stu       >L492B,pcr
                    clr       >$0244
                    rts

L494E               leas      -$02,s
                    std       ,s
                    lda       >$01AE
                    anda      #$01
                    bne       L4992
                    lda       >$05B1
                    beq       L4984
                    clra
                    ldb       >$0245
                    lslb
                    rola
                    addd      >$05AF
                    cmpd      >L492B,pcr
                    bhi       L4975
                    lda       #$0B
                    ldb       <$0058
                    lbsr      L10ED
L4975               ldu       >L492B,pcr
                    ldd       ,s
                    std       ,u++
                    stu       >L492B,pcr
                    inc       >$0244
L4984               ldd       >L492B,pcr
                    subd      >$05AF
                    cmpd      <$0057
                    bls       L4992
                    std       <$0057
L4992               leas      $02,s
                    rts

L4995               ldd       >$05AF
                    std       >L492D,pcr
                    lda       >$0244
                    ldb       #$02
                    mul
                    addd      >$05AF
                    std       >L492B,pcr
                    rts

L49AA               ldu       #$0000
                    ldd       >L492D,pcr
                    cmpd      >L492B,pcr
                    bcc       L49C1
                    tfr       d,u
                    addd      #$0002
                    std       >L492D,pcr
L49C1               rts

L49C2               lda       ,y+
                    sta       >$0245
                    lbsr      L058F
                    lbsr      L492F
                    lbsr      L059C
                    rts
L49D1               lda       >$0244
                    sta       >$0243
                    rts

L49D8               clra
                    ldb       >$0243
                    stb       >$0244
                    lslb
                    rola
                    addd      >$05AF
                    std       >L492B,pcr
                    rts

L49E9               leas      -$02,s
                    pshs      u,x
                    leau      $04,s
                    tsta
                    beq       L4A5A
                    cmpa      #$08
                    bne       L4A21
                    dec       <$0041
                    bpl       L4A0B
                    lda       #$00
                    sta       <$0041
                    lda       <$0040
                    cmpa      #$15
                    bls       L4A0B
                    deca
                    sta       <$0040
                    lda       #$27
                    sta       <$0041
L4A0B               ldd       #$2000
                    std       ,u
                    pshs      u
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    dec       <$0041
                    bra       L4A5A
L4A21               cmpa      #$0D
                    beq       L4A29
                    cmpa      #$0A
                    bne       L4A39
L4A29               lda       <$0040
                    cmpa      #$17
                    bcc       L4A32
                    inca
                    sta       <$0040
L4A32               lda       >$017A
                    sta       <$0041
                    bra       L4A5A
L4A39               clrb
                    cmpa      #$7F
                    bls       L4A41
                    ldd       #$2000
L4A41               std       ,u
                    pshs      u
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    lda       <$0041
                    cmpa      #$27
                    bls       L4A5A
                    lda       #$0D
                    bsr       L49E9
L4A5A               puls      u,x
                    leas      $02,s
                    rts

L4A5F               ldb       >$0166
                    cmpb      #$05
                    bcc       L4A72
                    ldx       #$0167
                    lslb
                    abx
                    ldd       <$0040
                    std       ,x
                    inc       >$0166
L4A72               rts

L4A73               ldb       >$0166
                    ble       L4A84
                    decb
                    stb       >$0166
                    ldx       #$0167
                    lslb
                    ldd       b,x
                    std       <$0040
L4A84               rts

L4A85               pshs      b,a
                    tfr       a,b
                    pshs      b,a
                    pshs      b,a
                    lbsr      L4A93
                    leas      $06,s
                    rts

L4A93               ldb       $07,s
                    pshs      b,a
                    lda       $07,s
                    ldb       #$27
                    pshs      b,a
                    lda       $07,s
                    ldb       #$00
                    pshs      b,a
                    lbsr      L4B56
                    leas      $06,s
                    rts

L4AA9               leas      <-$2A,s
                    lda       #$17
                    cmpa      <$2D,s
                    lbcs      L4B52
                    cmpa      <$2F,s
                    bcc       L4AC9
                    sta       <$2F,s
                    inca
                    suba      <$2D,s
                    cmpa      <$37,s
                    bcc       L4AC9
                    sta       <$37,s
L4AC9               ldb       <$37,s
                    beq       L4AFA
                    negb
                    incb
                    addb      <$2F,s
                    subb      <$2D,s
                    bhi       L4ADD
                    clr       <$37,s
                    bra       L4AFA
L4ADD               lda       <$37,s
                    pshs      b,a
                    lda       <$37,s
                    ldb       <$35,s
                    pshs      b,a
                    ldb       <$31,s
                    pshs      b,a
                    lda       #$12
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $06,s
L4AFA               lda       <$35,s
                    inca
                    suba      <$33,s
                    leau      ,s
                    ldb       #$20
L4B05               stb       ,u+
                    deca
                    bne       L4B05
                    sta       ,u
                    ldd       >$024C
                    pshs      b,a
                    ldb       <$33,s
                    lbsr      L486F
                    lda       <$39,s
                    bne       L4B2B
                    lda       <$2F,s
                    sta       <$0040
                    nega
                    adda      <$31,s
                    inca
                    sta       <$39,s
                    bra       L4B32
L4B2B               nega
                    adda      <$31,s
                    inca
                    sta       <$0040
L4B32               lda       <$35,s
                    sta       <$0041
                    leau      $02,s
                    pshs      u
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    inc       <$0040
                    dec       <$39,s
                    bne       L4B32
                    puls      b,a
                    std       >$024C
L4B52               leas      <$2A,s
                    rts

L4B56               ldd       <$0040
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    ldb       $09,s
                    pshs      b,a
                    ldb       $09,s
                    pshs      b,a
                    ldb       $0F,s
                    pshs      b,a
                    ldb       $0E,s
                    pshs      b,a
                    ldb       $0E,s
                    pshs      b,a
                    lbsr      L4AA9
                    leas      $0C,s
                    puls      b,a
                    std       <$0040
                    rts
L4B7D               fcc       /Please insert disk %d, side %d/
                    fcb       $0a
                    fcc       /and press ENTER./
                    fcb       0
L4BAD               fcc       /Please turn over the disk/
                    fcb       $0a
                    fcc       /and press ENTER./
                    fcb       0
L4BD8               fcc       /That is the wrong disk./
                    fcb       $0a,$0a,0
L4BF2               fcc       /%s%s/
                    fcb       $0a
                    fcc       /%s/
                    fcb       0
L4BFA               fcc       /vol.%d/
                    fcb       0
L4C01               fcc       /Can't find %s.%s%s/
                    fcb       0
L4C14               fcb       1
L4C15               fcb       1
L4C16               fcb       1
L4C17               fcb       0
L4C18               fcb       0
L4C19               fcb       0
L4C1A               fcb       0

L4C1B               leas      -6,s
                    std       ,s
                    stu       $02,s
                    stx       $04,s
L4C23               bsr       L4C41
                    cmpu      #$0000
L4C29               bne       L4C3E
                    lda       >L4C17,pcr
                    cmpa      #$05
                    beq       L4C3E
                    ldd       ,s
L4C35               lbsr      L280B
                    ldu       $02,s
                    ldx       $04,s
L4C3C               bra       L4C23
L4C3E               leas      $06,s
                    rts
L4C41               leas      <-$12,s
                    stu       ,s
                    stx       $02,s
                    pshs      y
                    ldu       <$004F
                    stu       $06,s
                    lda       >$0531
                    cmpa      #$FF
                    bne       L4C72
                    ldd       >L4C18,pcr
                    bne       L4C6F
                    ldx       [>$0089]
                    stx       >L4C18,pcr
                    ldd       ,x
                    cmpd      #$0101
L4C69               beq       L4C6F
                    clrb
                    lbsr      L4DCB
L4C6F               lbsr      L4E5C
L4C72               ldu       $02,s
                    lda       ,u
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       $08,s
                    ldx       #$0531
                    ldb       a,x
L4C81               cmpb      #$FF
                    bne       L4CC0
                    lbsr      L4EBE
                    ldb       $08,s
                    beq       L4C91
                    cmpb      >$05ED
                    bls       L4C97
L4C91               ldb       >L4C14,pcr
                    stb       $08,s
L4C97               decb
                    lslb
                    ldx       <$0089
                    ldx       b,x
                    stx       >L4C18,pcr
                    ldd       ,x
                    cmpa      >L4C15,pcr
                    bne       L4CAF
                    cmpb      >L4C16,pcr
                    beq       L4CBA
L4CAF               lda       #$01
                    sta       >L4C17,pcr
                    ldb       $08,s
                    lbsr      L4DCB
L4CBA               lbsr      L4E5C
                    lbra      L4DBB
L4CC0               stb       >L4C1A,pcr
                    clra
                    ldb       ,u
                    andb      #$0F
                    tfr       d,x
                    ldu       $01,u
                    lda       >L4C1A,pcr
                    clrb
                    lbsr      L143E
                    bcs       L4CEC
                    lda       >L4C1A,pcr
                    leax      $09,s
                    ldy       #$0007
                    lbsr      L1406
                    bcs       L4CEC
                    cmpd      #$0007
                    beq       L4CFC
L4CEC               lbsr      L1103
                    lbne      L4DBB
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L4CFC               ldd       $09,s
                    cmpd      #$1234
                    bne       L4D0C
                    lda       $0B,s
                    anda      #$0F
                    cmpa      $08,s
                    beq       L4D2C
L4D0C               lbsr      L4EBE
                    lda       #$01
                    sta       >L4C17,pcr
                    ldb       $08,s
                    lbsr      L4E22
                    tsta
                    bne       L4D26
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L4D26               lbsr      L4E5C
                    lbra      L4DBB
L4D2C               ldb       $0C,s
                    lda       $0D,s
                    std       <$0066
                    ldb       $0E,s
                    lda       $0F,s
                    std       <$12,s
                    ldu       $04,s
                    bne       L4D62
                    lda       >$05B8
                    beq       L4D52
                    lbsr      L27E2
                    cmpd      <$0066
                    bcc       L4D52
                    lda       #$05
                    sta       >L4C17,pcr
                    bra       L4DBB
L4D52               ldd       <$0066
                    lbsr      L2759
                    lbsr      L27F8
                    stu       $04,s
                    std       <$10,s
                    lbsr      L280B
L4D62               lda       $0B,s
                    anda      #$80
                    beq       L4D7E
                    ldd       <$12,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >L4C1A,pcr
                    pshs      b,a
                    lbsr      L2D70
                    leas      $06,s
                    bra       L4DAB
L4D7E               ldd       <$12,s
                    cmpd      <$0066
                    bne       L4D98
                    lda       #$01
                    sta       <$009E
                    lda       >L4C1A,pcr
                    ldx       $04,s
                    ldy       <$0066
                    lbsr      L1406
                    bra       L4DAB
L4D98               clr       <$009E
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >L4C1A,pcr
                    pshs      b,a
                    lbsr      L2C85
                    leas      $06,s
L4DAB               tst       <$009F
                    lbne      L4CEC
                    ldu       $04,s
                    cmpd      <$0066
                    beq       L4DC2
                    lbra      L4CEC
L4DBB               ldd       $06,s
                    std       <$004F
                    ldu       #$0000
L4DC2               ldd       <$10,s
                    puls      y
                    leas      <$12,s
                    rts

L4DCB               leas      <-$64,s
                    leau      ,s
                    pshs      b,a
                    pshs      u
                    lbsr      L4DE0
                    leas      $04,s
                    lbsr      L3AA7
                    leas      <$64,s
                    rts

L4DE0               ldx       >L4C18,pcr
                    clra
                    ldb       $05,s
                    beq       L4DF8
                    cmpb      >$05ED
                    bhi       L4DF8
                    stb       >L4C14,pcr
                    decb
                    lslb
                    ldx       <$0089
                    ldx       b,x
L4DF8               ldb       $01,x
                    pshs      b,a
                    ldb       ,x
                    pshs      b,a
                    leax      >L4B7D,pcr
                    cmpb      >L4C15,pcr
                    bne       L4E16
                    ldb       $01,x
                    cmpb      >L4C16,pcr
                    beq       L4E16
                    leax      >L4BAD,pcr
L4E16               ldu       $06,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $08,s
                    rts

L4E22               leas      >-$012C,s
                    pshs      b,a
                    lbsr      L1136
                    leau      $02,s
                    pshs      u
                    lbsr      L4DE0
                    leas      $04,s
                    leau      >L10A1,pcr
                    pshs      u
                    leau      $02,s
                    pshs      u
                    leau      >L4BD8,pcr
                    pshs      u
                    leax      >L4BF2,pcr
                    leau      <$6A,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $0A,s
                    lbsr      L3AA7
                    leas      >$012C,s
                    rts

L4E5C               leas      -$0D,s
                    ldx       >L4C18,pcr
                    leax      $02,x
                    ldb       ,x
L4E66               clra
                    stx       ,s
                    andb      #$7F
                    stb       $02,s
                    leax      >L4BFA,pcr
                    leau      $03,s
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $06,s
L4E7E               lda       #$01
                    leax      $03,s
                    lbsr      L13FB
                    bcc       L4EA0
                    tstb
                    bne       L4E90
                    clr       >L4C15,pcr
                    bra       L4EBB
L4E90               lbsr      L1103
                    cmpa      #$00
                    bne       L4E7E
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L4EA0               ldu       #$0531
                    ldb       $02,s
                    sta       b,u
                    ldx       ,s
                    ldb       ,x+
                    bmi       L4EB1
                    ldb       ,x
                    bra       L4E66
L4EB1               ldx       >L4C18,pcr
                    ldd       ,x
                    std       >L4C15,pcr
L4EBB               leas      $0D,s
                    rts

L4EBE               leas      -$01,s
                    clrb
                    ldx       #$0531
L4EC4               cmpb      #$0F
                    bhi       L4EDC
                    stb       ,s
                    lda       ,x
                    cmpa      #$FF
                    beq       L4ED5
                    lbsr      L1433
                    lda       #$FF
L4ED5               sta       ,x+
                    ldb       ,s
                    incb
                    bra       L4EC4
L4EDC               leas      $01,s
                    rts

L4EDF               leas      <-$65,s
                    pshs      y
L4EE4               lda       #$01
                    ldx       <$69,s
                    lbsr      L13FB
                    bcc       L4F21
                    lda       #$40
                    sta       >$0101
                    leau      >L10A1,pcr
                    pshs      u
                    leau      >L10BC,pcr
                    pshs      u
                    ldd       <$6D,s
                    pshs      b,a
                    leax      >L4C01,pcr
                    leau      $09,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $0A,s
                    lbsr      L3AA7
                    bne       L4EE4
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L4F21               sta       $02,s
                    ldu       #$0000
                    tfr       u,x
                    ldb       #$02
                    lbsr      L143E
                    stu       <$0066
                    ldu       #$0000
                    clrb
                    lbsr      L143E
                    ldx       <$6B,s
                    bne       L4F5B
                    ldd       <$0066
                    ldu       <$6F,s
                    beq       L4F53
                    lbsr      L2759
                    lbsr      L27F8
                    stu       [<$6D,s]
                    std       [<$6F,s]
                    lbsr      L280B
                    bra       L4F59
L4F53               lbsr      L278C
                    stu       [<$6D,s]
L4F59               tfr       u,x
L4F5B               lda       $02,s
                    ldy       <$0066
                    lbsr      L1406
                    cmpd      <$0066
                    beq       L4F78
                    lbsr      L1103
                    cmpb      #$00
                    bne       L4F78
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
L4F78               lda       $02,s
                    lbsr      L1433
                    puls      y
                    leas      <$65,s
                    rts

L4F83               fcc       /Logics/
                    fcb       0
L4F8A               fcc       /View/
                    fcb       0
L4F8F               fcc       /Picture/
                    fcb       0
L4F97               fcc       /Sound/
                    fcb       0
L4F9D               fcc       /logDir/
                    fcb       0
L4FA4               fcc       /viewDir/
                    fcb       0
L4FAC               fcc       /picDir/
                    fcb       0
L4FB3               fcc       /sndDir/
                    fcb       0
L4FBA               fcc       /%s #%d not found./
                    fcb       0

L4FCC               fdb       0
L4FCE               fdb       0
L4FD0               fdb       0
L4FD2               fdb       0
L4FD4               fdb       0
L4FD6               fdb       0
L4FD8               fdb       0
L4FDA               fdb       0
L4FDC               leau      >L4FCE,pcr
                    pshs      u
                    leau      >L4FCC,pcr
                    leax      >L4F9D,pcr
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4EDF
                    leas      $08,s
                    leau      >L4FD6,pcr
                    pshs      u
                    leau      >L4FD4,pcr
                    leax      >L4FAC,pcr
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4EDF
                    leas      $08,s
                    leau      >L4FD2,pcr
                    pshs      u
                    leau      >L4FD0,pcr
                    leax      >L4FA4,pcr
                    pshs      u
L5024               ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4EDF
                    leas      $08,s
L5030               leau      >L4FDA,pcr
                    pshs      u
                    leau      >L4FD8,pcr
                    leax      >L4FB3,pcr
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4EDF
                    leas      $08,s
                    rts

L504D               lda       ,u
                    cmpa      #$FF
                    bne       L505E
                    ldd       $01,u
                    cmpd      #$FFFF
                    bne       L505E
                    ldu       #$0000
L505E               rts

L505F               leas      -$01,s
                    stb       ,s
                    ldd       >L4FCE,pcr
                    lbsr      L280B
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4FCC,pcr
                    leau      d,u
                    bsr       L504D
                    bne       L5082
                    leax      >L4F83,pcr
                    ldb       ,s
                    lbsr      L5105
L5082               ldd       >L4FCE,pcr
                    leas      $01,s
                    rts

L5089               leas      -$01,s
                    stb       ,s
                    ldd       >L4FD2,pcr
                    lbsr      L280B
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4FD0,pcr
                    leau      d,u
                    bsr       L504D
                    bne       L50AB
                    leax      >L4F8A,pcr
                    ldb       ,s
                    bsr       L5105
L50AB               ldd       >L4FD2,pcr
                    leas      $01,s
                    rts

L50B2               leas      -$01,s
                    stb       ,s
                    ldd       >L4FD6,pcr
                    lbsr      L280B
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4FD4,pcr
                    leau      d,u
                    bsr       L504D
                    bne       L50D4
                    leax      >L4F8F,pcr
                    ldb       ,s
                    bsr       L5105
L50D4               ldd       >L4FD6,pcr
                    leas      $01,s
                    rts

L50DB               leas      -$01,s
                    stb       ,s
                    ldd       >L4FDA,pcr
                    lbsr      L280B
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4FD8,pcr
                    leau      d,u
                    lbsr      L504D
                    bne       L50FE
                    leax      >L4F97,pcr
                    ldb       ,s
                    bsr       L5105
L50FE               ldd       >L4FDA,pcr
                    leas      $01,s
                    rts

L5105               leas      <-$64,s
                    clra
                    pshs      b,a
                    pshs      x
                    leax      >L4FBA,pcr
                    leau      $04,s
                    pshs      x
                    pshs      u
                    lbsr      L3ED6
                    leas      $08,s
                    lbsr      L3AA7
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
                    leas      <$64,s
                    rts

L512C               fcb       0,0
                    fcb       0,0

L5130               leau      >L5130,pcr
                    ldd       ,s
                    pshu      s,b,a
                    rts
L5139               leau      >L512C,pcr
                    pulu      s,b,a
                    std       ,s
                    rts

L5142               fcc       /Not now./
                    fcb       0

L514B               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L515B
                    rts

L5156               ldb       ,y+
                    bsr       L515B
                    rts
L515B               leas      <-$36,s
                    stb       $02,s
                    clra
                    sta       >$05B1
                    sta       $04,s
                    sta       $03,s
                    lbsr      L602E
                    leax      ,x
                    beq       L5175
                    stx       $05,s
                    inc       $04,s
                    bra       L5191
L5175               lda       #$01
                    sta       >$05B8
                    clra
                    ldb       $02,s
                    lbsr      L6053
                    clr       >$05B8
                    stu       $05,s
                    bne       L5191
                    leau      >L5142,pcr
                    lbsr      L3AA7
                    lbra      L525E
L5191               ldd       <$000A
                    std       <$34,s
                    ldu       $05,s
                    ldd       $05,u
                    leau      $07,s
                    std       $08,u
                    clra
                    sta       $0A,u
                    sta       $0E,u
                    ldb       $02,s
                    lbsr      L60EF
                    ldd       <$10,u
                    std       <$12,u
                    lda       #$9F
                    suba      <$1C,u
                    lsra
                    ldb       #$A7
                    std       $03,u
                    std       <$1A,u
                    lda       #$0F
                    sta       <$24,u
                    lda       <$26,u
                    ora       #$04
                    sta       <$26,u
                    lda       #$FF
                    sta       $02,u
                    ldd       <$1C,u
                    mul
                    addd      #$000E
                    std       <$32,s
                    lbsr      L27E2
                    cmpd      <$32,s
                    bcs       L5213
                    inc       $03,s
                    tfr       u,x
                    lbsr      L445B
                    stu       ,s
                    pshs      u
                    lda       #$15
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    leau      $07,s
                    pshs      u
                    lda       #$0C
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    leau      $07,s
                    pshs      u
                    lda       #$1B
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
L5213               ldu       $05,s
                    ldu       $03,u
                    ldb       $03,u
                    lda       $04,u
                    leau      d,u
                    lbsr      L3AA7
                    lda       $03,s
                    beq       L524F
                    ldu       ,s
                    pshs      u
                    lda       #$12
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    leau      $07,s
                    pshs      u
                    lda       #$1B
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    ldx       ,s
                    lda       $0C,x
                    ldu       $0A,x
                    lbsr      L27EB
                    stu       <$004F
                    stx       <$0055
L524F               ldd       <$34,s
                    lbsr      L280B
                    lda       $04,s
                    bne       L525E
                    ldb       $02,s
                    lbsr      L62B8
L525E               lda       #$01
                    sta       >$05B1
                    leas      <$36,s
                    rts

L5267               fcb       0,0,0,0,0,0,0,0,0
L5270               fcb       0,0
L5272               fcb       0
L5273               fcb       0
L5274               fcb       0

L5275               fcb       $07,$78
                    fcb       $07,$0C
                    fcb       $06,$A8
                    fcb       $06,$48
                    fcb       $05,$EC
                    fcb       $05,$98
                    fcb       $05,$48
                    fcb       $04,$FC
                    fcb       $04,$B4
                    fcb       $04,$70
                    fcb       $04,$30
                    fcb       $03,$F4
                    fcb       $03,$BC
                    fcb       $03,$86
                    fcb       $03,$54
                    fcb       $03,$24
                    fcb       $02,$F6
                    fcb       $02,$CC
                    fcb       $02,$A4
                    fcb       $02,$7E
                    fcb       $02,$5A
                    fcb       $02,$38
                    fcb       $02,$18
                    fcb       $01,$FA
                    fcb       $01,$DE
                    fcb       $01,$C2
                    fcb       $01,$AA
                    fcb       $01,$92
                    fcb       $01,$7A
                    fcb       $01,$66
                    fcb       $01,$52
                    fcb       $01,$3E
                    fcb       $01,$2C
                    fcb       $01,$1C
                    fcb       $01,$0C
                    fcb       $00,$FC
                    fcb       $00,$EE
                    fcb       $00,$E2
                    fcb       $00,$D4
                    fcb       $00,$C8
                    fcb       $00,$BE
                    fcb       $00,$B2
                    fcb       $00,$A8
                    fcb       $00,$9C
                    fcb       $00,$96
                    fcb       $00,$8E
                    fcb       $00,$86
                    fcb       $00,$7E
                    fcb       $00,$78
                    fcb       $00,$70
                    fcb       $00,$6A
                    fcb       $00,$64
                    fcb       $00,$5E
                    fcb       $00,$5A
                    fcb       $00,$54
                    fcb       $00,$50
                    fcb       $00,$4C
                    fcb       $00,$46
                    fcb       $00,$42
                    fcb       $00,$3E
                    fcb       $00,$3C
                    fcb       $00,$02
                    fcb       $00,$02
                    fcb       $00,$02
                    fcb       $00,$03
                    fcb       $00,$03
                    fcb       $00,$03
                    fcb       $00,$03
                    fcb       $00,$03
                    fcb       $00,$03
                    fcb       $00,$04
                    fcb       $00,$04
                    fcb       $00,$04
                    fcb       $00,$04
                    fcb       $00,$05
                    fcb       $00,$05
                    fcb       $00,$05
                    fcb       $00,$05
                    fcb       $00,$06
                    fcb       $00,$06
                    fcb       $00,$06
                    fcb       $00,$07
                    fcb       $00,$07
                    fcb       $00,$08
                    fcb       $00,$08
                    fcb       $00,$09
                    fcb       $00,$09
                    fcb       $00,$0A
                    fcb       $00,$0A
                    fcb       $00,$0B
                    fcb       $00,$0C
                    fcb       $00,$0C
                    fcb       $00,$0D
                    fcb       $00,$0E
                    fcb       $00,$0E
                    fcb       $00,$0F
                    fcb       $00,$10
                    fcb       $00,$11
                    fcb       $00,$12
                    fcb       $00,$13
                    fcb       $00,$14
                    fcb       $00,$15
                    fcb       $00,$17
                    fcb       $00,$19
                    fcb       $00,$1A
                    fcb       $00,$1B
                    fcb       $00,$1D
                    fcb       $00,$1E
                    fcb       $00,$20
                    fcb       $00,$22
                    fcb       $00,$24
                    fcb       $00,$26
                    fcb       $00,$28
                    fcb       $00,$2B
                    fcb       $00,$2D
                    fcb       $00,$30
                    fcb       $00,$33
                    fcb       $00,$35
                    fcb       $00,$39
                    fcb       $00,$3D
                    fcb       $00,$40
                    fcb       $00,$42

L5369               fcb       0
                    fcb       $1f,$1c
                    fcb       $1f,$1e
                    fcb       $1f,$1e
                    fcb       $1f,$1f
                    fcb       $1e,$1f
                    fcb       $1e,$1f

L5376               leau      L5267,pcr
                    ldd       #0
                    std       ,u
                    rts

L5380               leau      >L5267,pcr
L5384               stu       >L5270,pcr
                    ldu       ,u
                    beq       L5390
                    cmpb      $02,u
                    bne       L5384
L5390               rts

L5391               ldb       ,y+
                    bsr       L5396
                    rts

L5396               leas      -$05,s
                    stb       ,s
                    bsr       L5380
                    cmpu      #$0000
                    bne       L53EA
                    ldd       <$000A
                    std       $03,s
                    lbsr      L058F
                    lda       #$03
                    ldb       ,s
                    lbsr      L494E
                    leau      >L5267,pcr
                    ldx       >L5270,pcr
                    beq       L53C7
                    ldd       #$0009
                    lbsr      L278C
                    stu       ,x
                    ldd       #$0000
                    std       ,u
L53C7               ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      L50DB
                    ldx       #$0000
                    lbsr      L4C1B
                    beq       L53E0
                    ldx       $01,s
                    std       $05,x
                    stu       $03,x
                    std       $07,x
L53E0               lbsr      L059C
                    ldd       $03,s
                    lbsr      L280B
                    ldu       $01,s
L53EA               leas      $05,s
                    rts

L53ED               leas      -$0B,s
                    ldb       ,y+
                    stb       ,s
                    lbsr      L5380
                    cmpu      #$0000
                    bne       L5403
                    lda       #$09
                    ldb       ,s
                    lbsr      L10ED
L5403               lda       >$01AF
                    anda      #$40
                    lbeq      L54DE
                    lda       >$0172
                    lbne      L54DE
                    ldd       <$000A
                    std       $03,s
                    stu       $01,s
                    ldd       $05,u
                    lbsr      L280B
                    leax      $05,s
                    os9       F$Time
                    ldu       $01,s
                    lbsr      L54E6
                    cmpd      #$0000
                    lbeq      L54D9
                    pshs      b,a
                    addb      $0C,s
                    bcc       L5437
                    inca
L5437               ldu       #$003C
                    lbsr      L125C
                    stb       $0C,s
                    tfr       u,d
                    cmpd      #$0000
                    beq       L5496
                    addb      $0B,s
                    bcc       L544C
                    inca
L544C               ldu       #$003C
                    lbsr      L125C
                    stb       $0B,s
                    tfr       u,d
                    tstb
                    beq       L5496
                    addb      $0A,s
                    lda       #$17
                    lbsr      L6006
                    sta       $0A,s
                    tstb
                    beq       L5496
                    inc       $09,s
                    ldd       $08,s
                    leax      >L5369,pcr
                    cmpb      a,x
                    bls       L5496
                    ldb       a,x
                    cmpa      #$02
                    bne       L5485
                    ldb       $07,s
                    beq       L5485
                    bitb      #$03
                    bne       L5485
                    ldb       $09,s
                    cmpb      #$1D
                    beq       L5496
L5485               ldb       #$01
                    stb       $09,s
                    inca
                    cmpa      #$0C
                    bls       L5494
                    stb       $08,s
                    inc       $07,s
                    bra       L5496
L5494               sta       $08,s
L5496               leax      $07,s
                    os9       F$STime
                    puls      b,a
                    addb      >$043C
                    bcc       L54A3
                    inca
L54A3               ldu       #$003C
                    lbsr      L125C
                    stb       >$043C
                    tfr       u,d
                    cmpd      #$0000
                    beq       L54D9
                    addb      >$043D
                    bcc       L54BA
                    inca
L54BA               ldu       #$003C
                    lbsr      L125C
                    stb       >$043D
                    tfr       u,d
                    tstb
                    beq       L54D9
                    addb      >$043E
                    lda       #$17
                    lbsr      L6006
                    sta       >$043E
                    tstb
                    beq       L54D9
                    inc       >$043F
L54D9               ldd       $03,s
                    lbsr      L280B
L54DE               lda       ,y+
                    lbsr      L172B
                    leas      $0B,s
                    rts

L54E6               pshs      y
                    clrb
                    ldu       $03,u
                    bsr       L5545
L54ED               ldb       ,u+
                    cmpb      #$FF
                    beq       L553E
                    lslb
                    lda       ,u+
                    ora       #2
                    sta       >$FF20
                    ldy       ,u++
                    leax      >L5275,pcr
                    abx
                    ldd       ,x
                    std       <$008E
                    leax      >$007A,x
                    ldd       ,x
                    std       <$0090
* The RS-232 line is now masked and forced high.
* Therefore $FF20 can't be tested for $00 but we can test the actual
* data stream. RG
*         tst   $FF20	old
                    tst       -3,u                new
                    beq       L5528
L5512               ldx       <$0090
L5514               ldd       <$008E
L5516               subd      #$0001
                    bne       L5516
*         com   $FF20
                    lda       $ff20               patch RG
                    coma
                    ora       #2
                    sta       $ff20
                    leax      -1,x
                    bne       L5514
                    leay      -$01,y
                    bne       L5512
                    bra       L54ED
L5528               ldx       <$0090
L552A               ldd       <$008E
L552C               subd      #$0001
                    bne       L552C
* This is a meaningless test and must be here to balance cycles. RG
                    tst       >$FF20
                    leax      -$01,x
                    bne       L552A
                    leay      -$01,y
                    bne       L5528
                    bra       L54ED
L553E               bsr       L556F
                    ldd       ,u
                    puls      y
                    rts

*Sound on
* RS-232 toggle change. RG

L5545               orcc      #IntMasks
*        clr   $FF20		this would trash the RS-232 line while zeroing the DAC
                    lda       #2                  patch RG
                    sta       $ff20
                    lda       >$FF01              save PIA setting
                    sta       >L5272,pcr
                    anda      #$F7                set MUX to 0
                    sta       >$FF01
                    lda       >$FF03              save PIA setting
                    sta       >L5273,pcr
                    anda      #$F7                set MUX to 0
                    sta       >$FF03              DAC now selected
                    lda       >$FF23              save Sound setting
                    sta       >L5274,pcr
                    ora       #$08                turn sound on
                    sta       >$FF23
                    rts

*Sound off
* RS-232 toggle change. RG
L556F               lda       >L5272,pcr          get saved PIA HSYNC setting
                    sta       >$FF01              restore it
                    lda       >L5273,pcr          get saved PIA VSYNC setting
                    sta       >$FF03              restore it
                    lda       >L5274,pcr          get Sound setting (presumably off)
                    sta       >$FF23              restore it
                    lda       #2                  patch RG
                    sta       $FF20
                    lda       $FF02
                    lda       $FF22
                    andcc     #$AF
                    rts

L5590               fcc       /nothing/
                    fcb       0
L5598               fcc       /You are carrying:/
                    fcb       0
L55AA               fcc       'ENTER to select / CTRL-BREAK to cancel'
                    fcb       0
L55D1               fcc       /Press a key to return to the game/
                    fcb       0
L55F3               fcc       /Score:%d of %d  /
                    fcb       0
L5604               fcc       /Sound: %s/
                    fcb       0
L560E               fcb       0,0,0
L5611               fcc       /on /
                    fcb       0

L5615               fcc       /off/
                    fcb       0

L5619               lbsr      L5E91
                    lbsr      L4903
                    clra
                    ldb       #$0F
                    lbsr      L486F
L5625               lbsr      L4821
                    bsr       L5631
                    lbsr      L4918
                    lbsr      L488E
                    rts

L5631               leas      >-$0105,s
                    lda       #$02
                    sta       ,s
L5639               leax      $04,s
                    stx       $02,s
                    stx       >$00FE,s
                    ldu       <$0038
                    clra
                    sta       $01,s
L5646               sta       >$0100,s
                    stu       >$0101,s
                    cmpu      <$003C
                    bcc       L5699
                    ldb       $02,u
                    cmpb      #$FF
                    bne       L5690
                    sta       ,x
                    cmpa      >$044A
                    bne       L5664
                    stx       >$00FE,s
L5664               ldd       ,u
                    std       $01,x
                    lda       ,s
                    sta       $03,x
                    ldb       $01,s
                    bitb      #$01
                    bne       L5678
                    lda       #$01
                    sta       $04,x
                    bra       L568B
L5678               inca
                    sta       ,s
                    stx       $02,s
                    ldx       $01,x
                    lbsr      L11A0
                    ldx       $02,s
                    negb
                    addb      #$27
                    stb       $04,x
                    ldb       $01,s
L568B               incb
                    stb       $01,s
                    leax      $05,x
L5690               leau      $03,u
                    lda       >$0100,s
                    inca
                    bra       L5646
L5699               lda       $01,s
                    bne       L56AF
                    sta       ,x
                    leau      >L5590,pcr
                    stu       $01,x
                    lda       ,s
                    sta       $03,x
                    lda       #$10
                    sta       $04,x
                    leax      $05,x
L56AF               leax      -$05,x
                    stx       >$0103,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    ldx       >$0102,s
                    stx       $06,s
                    pshs      x
                    lbsr      L5719
                    leas      $06,s
L56C8               lbsr      L1352
                    lda       >$01AF
                    anda      #$04
                    beq       L570D
                    ldd       ,x
                    cmpa      #$01
                    bne       L56F0
                    cmpb      #$0D
                    bne       L56E5
                    ldx       $02,s
                    lda       ,x
                    sta       >$044A
                    bra       L570D
L56E5               cmpb      #$1B
                    bne       L56C8
                    lda       #$FF
                    sta       >$044A
                    bra       L570D
L56F0               cmpa      #$02
                    bne       L56C8
                    leax      $04,s
                    pshs      x
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >$0109,s
                    pshs      b,a
                    lbsr      L579A
                    leas      $08,s
                    stx       $02,s
                    bra       L56C8
L570D               clra
                    sta       >$0154
                    sta       >$0547
                    leas      >$0105,s
                    rts

L5719               leas      -$04,s
                    lda       #$00
                    ldb       #$0B
                    std       <$0040
                    leau      >L5598,pcr
                    pshs      u
                    lbsr      L3EE9
                    leas      $02,s
                    ldx       $08,s
L572E               stx       ,s
                    cmpx      $0A,s
                    bhi       L5763
                    ldd       $03,x
                    std       <$0040
                    clra
                    ldb       #$0F
                    std       $02,s
                    cmpx      $06,s
                    bne       L574D
                    lda       >$01AF
                    anda      #$04
                    beq       L574D
                    lda       #$0F
                    clrb
                    std       $02,s
L574D               ldd       $02,s
                    lbsr      L486F
                    ldx       ,s
                    ldx       $01,x
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    ldx       ,s
                    leax      $05,x
                    bra       L572E
L5763               clra
                    ldb       #$0F
                    lbsr      L486F
                    lda       >$01AF
                    anda      #$04
                    beq       L5786
                    lda       #$01
                    sta       >$0154
                    lda       #$03
                    sta       >$0547
                    lda       #$17
                    ldb       #$01
                    std       <$0040
                    leax      >L55AA,pcr
                    bra       L5790
L5786               lda       #$17
                    ldb       #$04
                    std       <$0040
                    leax      >L55D1,pcr
L5790               pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    leas      $04,s
                    rts

L579A               ldu       $04,s
                    tfr       u,x
                    lda       $07,s
                    cmpa      #$01
                    bne       L57A8
                    leax      -$0A,x
                    bra       L57BE
L57A8               cmpa      #$03
                    bne       L57B0
                    leax      $05,x
                    bra       L57BE
L57B0               cmpa      #$05
                    bne       L57B8
                    leax      $0A,x
                    bra       L57BE
L57B8               cmpa      #$07
                    bne       L57D3
                    leax      -$05,x
L57BE               cmpx      $08,s
                    bcs       L57C6
                    cmpx      $02,s
                    bls       L57CA
L57C6               tfr       u,x
                    bra       L57D3
L57CA               pshs      x
                    pshs      u
                    lbsr      L57D4
                    leas      $04,s
L57D3               rts

L57D4               lda       #$0F
                    clrb
                    lbsr      L486F
                    ldu       $04,s
                    ldd       $03,u
                    std       <$0040
                    ldd       $01,u
                    pshs      b,a
                    lbsr      L3EE9
                    leas      $02,s
                    clra
                    ldb       #$0F
                    lbsr      L486F
                    ldu       $02,s
                    ldd       $03,u
                    std       <$0040
                    ldd       $01,u
                    pshs      b,a
                    lbsr      L3EE9
                    leas      $02,s
                    ldx       $04,s
                    rts

L5801               lda       >$0246
                    beq       L5862
                    lbsr      L4A5F
                    lbsr      L4903
                    lda       >$0247
                    ldb       #$0F
                    lbsr      L4A85
                    clra
                    ldb       #$0F
                    lbsr      L486F
                    lda       >$0247
                    ldb       #$01
                    std       <$0040
                    clra
                    ldb       >$0438
                    pshs      b,a
                    ldb       >$0434
                    leax      >L55F3,pcr
                    pshs      b,a
                    pshs      x
                    lbsr      L3EE9
                    leas      $06,s
                    ldb       #$1E
                    stb       <$0041
                    leau      >L5615,pcr
                    lda       >$01AF
                    anda      #$40
                    beq       L584F
                    lda       >$0172
                    bne       L584F
                    leau      >L5611,pcr
L584F               leax      >L5604,pcr
                    pshs      u
                    pshs      x
                    lbsr      L3EE9
                    leas      $04,s
                    lbsr      L4918
                    lbsr      L4A73
L5862               rts

L5863               lda       #$01
                    sta       >$0246
                    bsr       L5801
                    rts

L586B               clr       >$0246
                    lda       >$0247
                    clrb
                    lbsr      L4A85
                    rts

L5876               fcc       / .,;:'!-/
                    fcb       0

L587F               leas      >-$0197,s
                    lda       >$05B9
                    sta       ,s
                    lbsr      L4A5F
                    lbsr      L5E91
                    lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #$0251
                    leax      d,x
                    stx       $01,s
                    lda       ,y+
                    sta       $05,s
L589E               ldd       ,y++
                    std       $03,s
                    lda       ,y+
                    inca
                    cmpa      #$28
                    bls       L58AB
                    lda       #$28
L58AB               sta       >$0196,s
                    clr       ,x
                    ldd       $03,s
                    cmpa      #$18
L58B5               bcc       L58B9
                    std       <$0040
L58B9               ldb       $05,s
                    lbsr      L3E0D
                    leax      $06,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3C6A
                    leas      $06,s
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    ldb       >$0196,s
                    ldx       $01,s
                    bsr       L591D
                    lbsr      L4A73
                    lda       ,s
                    beq       L58E7
                    lbsr      L5E80
L58E7               leas      >$0197,s
                    rts

L58EC               lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #$0251
                    leax      d,x
                    ldb       ,y+
                    lbsr      L3E0D
                    exg       u,x
                    ldd       #$0028
                    lbsr      L11BF
                    rts

L5904               lda       ,y+
                    ldb       #$28
                    mul
                    ldu       #$0251
                    leau      d,u
                    ldb       ,y+
                    lslb
                    ldx       #$0180
                    ldx       b,x
                    ldd       #$0028
                    lbsr      L11BF
                    rts

L591D               leas      <-$2F,s
                    stx       ,s
                    cmpb      #$28
                    bls       L5928
                    ldb       #$28
L5928               leax      $06,s
                    abx
                    stx       $04,s
                    clra
                    ldx       ,s
                    leau      $07,s
                    lbsr      L11BF
                    lbsr      L11A0
                    beq       L5947
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    leax      $07,s
                    lbsr      L11A0
                    abx
L5947               stx       $02,s
                    lbsr      L5E80
L594C               lbsr      L13A7
                    sta       $06,s
                    lbsr      L5E91
                    lda       $06,s
                    cmpa      #$08
                    bne       L5972
L595A               leau      $07,s
                    cmpu      $02,s
                    bcc       L599D
                    ldu       $02,s
                    leau      -$01,u
                    stu       $02,s
                    lbsr      L49E9
                    lda       #$08
                    cmpa      $06,s
                    beq       L599D
                    bra       L595A
L5972               cmpa      #$03
                    bne       L597A
                    lda       #$08
                    bra       L595A
L597A               cmpa      #$0D
                    bne       L598B
                    ldu       $02,s
                    clr       ,u
                    leax      $07,s
                    ldu       ,s
                    lbsr      L11B4
                    bra       L59A2
L598B               cmpa      #$1B
                    beq       L59A2
                    ldu       $02,s
                    cmpu      $04,s
                    bcc       L599D
                    sta       ,u+
                    stu       $02,s
                    lbsr      L49E9
L599D               lbsr      L5E80
                    bra       L594C
L59A2               lda       $06,s
                    leas      <$2F,s
                    rts

L59A8               ldb       ,y+
                    lbsr      L3E0D
                    tfr       u,x
                    ldu       #$01CE
                    ldd       #$0007
                    lbsr      L11BF
                    rts

L59B9               leas      <-$53,s
                    stb       ,s
                    leau      $01,s
                    bsr       L59E3
                    lda       ,s
                    leau      <$2A,s
                    bsr       L59E3
                    leau      $01,s
                    leax      <$2A,s
L59CE               lda       ,u+
                    beq       L59D8
                    cmpa      ,x+
                    beq       L59CE
                    bra       L59DE
L59D8               lda       #$01
                    ldb       ,x
                    beq       L59DF
L59DE               clra
L59DF               leas      <$53,s
                    rts

L59E3               leas      -$02,s
                    stu       ,s
                    ldb       #$28
                    mul
                    ldu       #$0251
                    leau      d,u
L59EF               lda       ,u+
                    beq       L5A07
                    leax      >L5876,pcr
                    lbsr      L12D9
                    bne       L59EF
                    lbsr      L12B2
                    ldx       ,s
                    sta       ,x+
                    stx       ,s
                    bra       L59EF
L5A07               ldx       ,s
                    clr       ,x
                    leas      $02,s
                    rts

L5A0E               lda       ,y+
                    lda       ,y+
L5A12               lda       ,y+
L5A14               lda       ,y+
L5A16               rts
L5A17               fcc       /==========/
                    fcc       /================/
                    fcb       0
L5A32               fcc       /%d: %d/
                    fcb       0
L5A39               fcc       /%d: %s/
                    fcb       0
L5A40               fcc       / :%c/
                    fcb       0
L5A45               fcc       /%d/
                    fcb       0
L5A48               fcc       /return/
                    fcb       0
L5A4F               fcb       0
L5A50               fcb       1
L5A51               fcb       $f
L5A52               fcb       0
L5A53               fcb       0
L5A54               fcb       0
L5A55               fcb       0
L5A56               fcb       0
L5A57               fcb       0
L5A58               fcb       0
L5A59               fcb       0

L5A5A               lda       <$68
                    bne       L5A60
                    bsr       L5A61
L5A60               rts
L5A61               lda       <$0068
L5A63               bne       L5ADA
                    lda       >$01AF
                    anda      #$20
                    beq       L5ADA
                    lda       #$01
                    sta       <$0068
                    lda       >$0241
                    inca
                    adda      >L5A50,pcr
                    sta       >L5A58,pcr
                    adda      >L5A51,pcr
                    deca
                    sta       >L5A59,pcr
                    lda       #$02
                    sta       >L5A54,pcr
                    adda      #$23
                    sta       >L5A57,pcr
                    lda       >L5A54,pcr
                    ldb       #$04
                    mul
                    subb      #$05
                    stb       >L5A55,pcr
                    lda       >L5A59,pcr
                    ldb       #$08
                    mul
                    addb      #$05
L5AA7               stb       >L5A56,pcr
                    lda       >L5A51,pcr
                    ldb       #$08
                    mul
                    addb      #$0A
                    stb       >L5A52,pcr
                    ldb       #$9A
                    stb       >L5A53,pcr
                    ldd       #$040F
                    pshs      b,a
                    ldd       >L5A52,pcr
                    pshs      b,a
                    ldd       >L5A55,pcr
                    pshs      b,a
                    lda       #$0C
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $06,s
L5ADA               rts

L5ADB               lda       ,y+
                    sta       <$006A
                    lda       ,y+
                    sta       >L5A50,pcr
                    lda       ,y+
                    cmpa      #$02
                    bcc       L5AED
                    lda       #$02
L5AED               sta       >L5A51,pcr
                    rts
L5AF2               lda       <$0068
                    beq       L5B0F
                    clr       <$0068
                    ldd       >L5A52,pcr
                    pshs      b,a
                    ldd       >L5A55,pcr
                    pshs      b,a
                    lda       #$03
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
L5B0F               rts

L5B10               leas      -$02,s
                    stb       $01,s
                    clr       >L5A4F,pcr
                    leax      >L01B0,pcr
                    ldd       #$FFFF
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      y
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L5B68
                    leas      $0A,s
                    ldb       $01,s
                    leas      $02,s
                    rts

L5B38               leas      -$03,s
                    sta       $02,s
                    lda       #$01
                    ldb       ,u+
                    stb       $01,s
                    cmpb      #$0E
                    beq       L5B47
                    clra
L5B47               sta       >L5A4F,pcr
                    leax      >L0D26,pcr
                    ldd       $02,s
                    pshs      b,a
                    ldd       #$00DC
                    pshs      b,a
                    pshs      u
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L5B68
                    leas      $0A,s
                    leas      $03,s
                    rts

L5B68               leas      -$04,s
                    clr       $06,s
                    lda       $07,s
                    ldb       #$04
                    mul
                    addd      $08,s
                    std       $08,s
                    lbsr      L4A5F
                    lbsr      L4903
                    ldd       #$000F
                    lbsr      L486F
                    lbsr      L5D07
                    lda       <$0069
                    beq       L5B98
                    clr       <$0069
                    leax      >L5A17,pcr
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    lbsr      L5D07
L5B98               ldy       <$0062
                    sty       ,s
                    ldb       <$006A
                    beq       L5BAB
                    lbsr      L2598
                    cmpu      #$0000
                    bne       L5BB6
L5BAB               ldu       $06,s
                    clra
                    ldb       $02,y
                    leax      >L5A32,pcr
                    bra       L5BD2
L5BB6               stu       <$0062
                    leau      >L5A48,pcr
                    ldb       $07,s
                    beq       L5BC5
                    addb      $0D,s
                    lbsr      L3E0D
L5BC5               clra
                    ldb       $02,y
                    leax      >L5A39,pcr
                    ldy       ,s
                    sty       <$0062
L5BD2               pshs      u
                    pshs      b,a
                    pshs      x
                    lbsr      L3EE9
                    leas      $06,s
                    ldd       $0A,s
                    pshs      b,a
                    ldd       $0A,s
                    pshs      b,a
                    lbsr      L5C4C
                    leas      $04,s
                    ldb       $0E,s
                    bmi       L5C16
                    lda       >L5A59,pcr
                    ldb       >L5A57,pcr
                    subb      #$02
                    std       <$0040
                    lda       #$54
                    ldb       $0E,s
                    bne       L5C02
                    lda       #$46
L5C02               pshs      b,a
                    leax      >L5A40,pcr
                    pshs      b,a
                    pshs      x
                    lbsr      L3EE9
                    leas      $06,s
                    ldd       >$024A
                    std       $02,s
L5C16               lda       <$0068
                    beq       L5C43
                    lbsr      L1330
                    leax      ,x
                    beq       L5C27
                    lda       ,x
                    cmpa      #$01
                    beq       L5C39
L5C27               ldd       $02,s
                    cmpd      >$024A
                    beq       L5C27
                    lbsr      L130A
                    ldd       >$024A
                    std       $02,s
                    bra       L5C16
L5C39               lda       $01,x
                    cmpa      #$2B
                    bne       L5C43
                    lda       #$02
                    sta       <$0068
L5C43               lbsr      L4A73
                    lbsr      L4918
                    leas      $04,s
                    rts

L5C4C               leas      -$06,s
                    lbsr      L4A5F
                    ldu       $08,s
                    ldx       $0A,s
                    lda       $02,u
                    ldb       >L5A4F,pcr
                    beq       L5C61
                    lda       ,x+
                    stx       $0A,s
L5C61               ldb       $03,u
                    std       ,s
                    lda       #$28
                    lbsr      L49E9
                    lda       ,s
                    beq       L5C94
                    clr       $02,s
L5C70               ldb       $02,s
                    ldu       $0A,s
                    lbsr      L5CF4
                    leax      >L5A45,pcr
                    pshs      b,a
                    pshs      x
                    lbsr      L3EE9
                    leas      $04,s
                    ldb       $02,s
                    incb
                    cmpb      ,s
                    bcc       L5C94
                    stb       $02,s
                    lda       #$2C
                    lbsr      L49E9
                    bra       L5C70
L5C94               lda       #$29
                    lbsr      L49E9
                    ldb       $01,s
                    beq       L5CA0
                    lbsr      L5D07
L5CA0               lbsr      L4A73
                    ldb       $01,s
                    beq       L5CF1
                    lda       #$28
                    lbsr      L49E9
                    lda       #$80
                    clr       $02,s
L5CB0               sta       $03,s
                    ldb       $02,s
                    ldu       $0A,s
                    lbsr      L5CF4
                    std       $04,s
                    lda       $01,s
                    anda      $03,s
                    beq       L5CCA
                    ldx       #$0431
                    abx
                    ldb       ,x
                    clra
                    std       $04,s
L5CCA               leax      >L5A45,pcr
                    ldd       $04,s
                    pshs      b,a
                    pshs      x
                    lbsr      L3EE9
                    leas      $04,s
                    ldb       $02,s
                    incb
                    cmpb      ,s
                    bcc       L5CEC
                    stb       $02,s
                    lda       #$2C
                    lbsr      L49E9
                    lda       $03,s
                    lsra
                    bra       L5CB0
L5CEC               lda       #$29
                    lbsr      L49E9
L5CF1               leas      $06,s
                    rts

L5CF4               lda       >L5A4F,pcr
                    bne       L5CFF
                    clra
                    ldb       b,u
                    bra       L5D06
L5CFF               lslb
                    leau      b,u
                    ldb       ,u+
                    lda       ,u
L5D06               rts

L5D07               ldd       #$0001
                    pshs      b,a
                    ldb       >L5A57,pcr
                    pshs      b,a
                    ldb       >L5A54,pcr
                    pshs      b,a
                    ldd       #$000F
                    pshs      b,a
                    ldb       >L5A59,pcr
                    pshs      b,a
                    ldb       >L5A58,pcr
                    pshs      b,a
                    lbsr      L4AA9
                    leas      $0C,s
                    lda       >L5A59,pcr
                    ldb       >L5A54,pcr
                    std       <$0040
                    rts

L5D39               fcb       0
L5D3A               fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0,0

L5D63               clra
                    sta       >$0444
                    sta       >$043A
                    lda       >$05AE
                    beq       L5D72
                    lbsr      L29C2
L5D72               lbsr      L1330
                    lbsr      L1372
                    leax      ,x
                    beq       L5DB2
                    ldd       ,x
                    cmpa      #$01
                    bne       L5D8E
                    stb       >$0444
                    lda       >$01D5
                    beq       L5D72
                    bsr       L5DB3
                    bra       L5D72
L5D8E               cmpa      #$02
                    bne       L5DA9
                    ldu       <$0030
                    cmpb      <$21,u
                    bne       L5D9A
                    clrb
L5D9A               stb       >$0437
                    lda       >$0250
                    beq       L5D72
                    lda       #$00
                    sta       <$22,u
                    bra       L5D72
L5DA9               ldu       #$05BA
                    lda       #$01
                    sta       b,u
                    bra       L5D72
L5DB2               rts

L5DB3               leas      -$02,s
                    stb       ,s
                    ldx       #$0251
                    lbsr      L11A0
                    negb
                    addb      #$28
                    lda       >$01AD
                    beq       L5DC6
                    decb
L5DC6               cmpb      >$0449
                    bls       L5DCE
                    ldb       >$0449
L5DCE               stb       $01,s
                    lbsr      L5E91
                    lda       ,s
                    cmpa      #$0A
                    beq       L5E38
                    cmpa      #$0D
                    bne       L5E02
                    lda       >L5D39,pcr
                    beq       L5E38
                    ldx       #$012B
                    leau      >L5D3A,pcr
                    lbsr      L11B4
                    ldx       #$012B
                    lbsr      L34AD
                    clra
                    sta       >L5D39,pcr
                    ldx       #$012B
                    sta       ,x
                    lbsr      L5EC4
                    bra       L5E38
L5E02               cmpa      #$08
                    bne       L5E1D
                    lda       >L5D39,pcr
                    beq       L5E38
                    deca
                    sta       >L5D39,pcr
                    ldu       #$012B
                    clr       a,u
                    lda       ,s
                    lbsr      L49E9
                    bra       L5E38
L5E1D               ldb       >L5D39,pcr
                    cmpb      $01,s
                    bcc       L5E38
                    lda       ,s
                    beq       L5E38
                    ldu       #$012B
                    sta       b,u
                    incb
                    stb       >L5D39,pcr
                    clr       b,u
                    lbsr      L49E9
L5E38               bsr       L5E80
                    leas      $02,s
                    rts

L5E3D               lda       >L5D39,pcr
                    beq       L5E4A
                    ldb       #$08
                    lbsr      L5DB3
                    bra       L5E3D
L5E4A               rts

L5E4B               lda       >$01D5
                    beq       L5E52
                    bsr       L5E53
L5E52               rts

L5E53               leax      >L5D3A,pcr
                    lbsr      L11A0
                    cmpb      >L5D39,pcr
                    bls       L5E7F
                    bsr       L5E91
L5E62               ldb       >L5D39,pcr
                    ldu       #$012B
                    leax      >L5D3A,pcr
                    lda       b,x
                    sta       b,u
                    beq       L5E7D
                    incb
                    stb       >L5D39,pcr
                    lbsr      L49E9
                    bra       L5E62
L5E7D               bsr       L5E80
L5E7F               rts

L5E80               lda       >$05B9
                    bne       L5E90
                    com       >$05B9
                    lda       >$01AD
                    beq       L5E90
                    lbsr      L49E9
L5E90               rts

L5E91               lda       >$05B9
                    beq       L5EA3
                    com       >$05B9
                    lda       >$01AD
                    beq       L5EA3
                    lda       #$08
                    lbsr      L49E9
L5EA3               rts

L5EA4               bsr       L5E91
                    lda       >$01D7
                    clrb
                    stb       >$01D5
                    lbsr      L4A85
                    rts

L5EB1               lda       #$01
                    sta       >$01D5
                    bsr       L5EC4
                    rts

L5EB9               ldb       ,y+
                    lbsr      L3E0D
                    lda       ,u
                    sta       >$01AD
                    rts

L5EC4               leas      <-$50,s
                    lda       >$01D5
                    beq       L5F04
                    bsr       L5E91
                    lda       >$01D7
                    ldb       >$024D
                    lbsr      L4A85
                    lda       >$01D7
                    clrb
                    std       <$0040
                    ldx       #$0251
                    leau      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L3C6A
                    leas      $06,s
                    pshs      x
                    lbsr      L3EE9
                    leas      $02,s
                    ldd       #$012B
                    pshs      b,a
                    lbsr      L3EE9
                    leas      $02,s
                    lbsr      L5E80
L5F04               leas      <$50,s
                    rts

L5F08               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    inca
                    beq       L5F15
                    sta       ,x
L5F15               rts

L5F16               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    beq       L5F23
                    deca
                    sta       ,x
L5F23               rts

L5F24               ldb       ,y+
                    ldx       #$0431
                    lda       ,y+
                    abx
                    sta       ,x
                    rts

L5F2F               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L5F40               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    adda      ,y+
                    sta       ,x
                    rts

L5F4D               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    adda      ,x
                    sta       ,x
                    rts

L5F60               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    suba      ,y+
                    sta       ,x
                    rts

L5F6D               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    nega
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    adda      ,x
                    sta       ,x
                    rts

L5F81               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    ldb       ,x
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L5F98               lda       $01,y
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    ldb       ,x
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L5FA9               ldb       $01,y
                    ldx       #$0431
                    abx
                    ldb       ,x
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L5FC0               ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldb       ,y+
                    mul
                    stb       ,x
                    rts

L5FCE               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    ldb       ,x
                    mul
                    stb       ,x
                    rts

L5FE2               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    lda       ,y+
                    bsr       L6006
                    stb       ,x
                    rts

L5FF1               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L6006
                    stb       ,x
                    rts

L6006               sta       <$0088
                    lda       #$08
                    sta       <$008D
                    clra
L600D               lslb
                    rola
                    cmpa      <$0088
                    bcs       L6016
                    suba      <$0088
                    incb
L6016               dec       <$008D
                    bne       L600D
                    rts

L601B               fcb       0,0
                    fcb       0,0
                    fcb       0,0,0
L6022               fcb       0,0

L6024               leau      L601B,pcr
                    ldd       #0
                    std       ,u
                    rts

L602E               leax      >L601B,pcr
L6032               stx       >L6022,pcr
                    ldx       ,x
                    beq       L603E
                    cmpb      $02,x
                    bne       L6032
L603E               rts

L603F               lda       #$00
                    ldb       ,y+
                    bsr       L6053
                    rts

L6046               lda       #$00
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L6053
                    rts

L6053               leas      -$06,s
                    std       ,s
                    bsr       L602E
                    leax      ,x
                    beq       L6065
                    ldb       ,s
                    bne       L6065
                    tfr       x,u
                    bra       L60B0
L6065               stx       $02,s
                    ldd       <$000A
                    std       $04,s
                    lbsr      L058F
                    ldu       $02,s
                    bne       L6092
                    lda       #$01
                    ldb       $01,s
                    lbsr      L494E
                    ldd       #$0007
                    lbsr      L278C
                    stu       $02,s
                    ldx       >L6022,pcr
                    stu       ,x
                    ldd       #$0000
                    std       ,u
                    std       $03,u
                    ldb       $01,s
                    stb       $02,u
L6092               ldb       $02,u
                    lbsr      L5089
                    ldx       $02,s
                    ldx       $03,x
                    lbsr      L4C1B
                    beq       L60A6
                    ldx       $02,s
                    std       $05,x
                    stu       $03,x
L60A6               lbsr      L059C
                    ldd       $04,s
                    lbsr      L280B
                    ldu       $02,s
L60B0               leas      $06,s
                    rts

L60B3               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       L60EF
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L60CE               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L60EF
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L60EF               lbsr      L602E
                    leax      ,x
                    bne       L60FB
                    lda       #$03
                    lbsr      L10ED
L60FB               stb       $05,u
                    ldd       $05,x
                    std       $08,u
                    ldx       $03,x
                    stx       $06,u
                    lbsr      L280B
                    ldx       $06,u
                    lda       $02,x
                    sta       $0B,u
                    ldb       $0A,u
                    cmpb      $0B,u
                    bcs       L6115
                    clrb
L6115               bsr       L6154
                    rts

L6118               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       L6154
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L6133               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L6154
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L6154               leas      -$01,s
                    ldx       $06,u
                    bne       L615E
                    ldb       #$06
                    bra       L6164
L615E               cmpb      $0B,u
                    bcs       L616F
                    ldb       #$05
L6164               stb       ,s
                    tfr       u,d
                    subd      <$0030
                    lda       ,s
                    lbsr      L10ED
L616F               stb       $0A,u
                    ldd       $08,u
                    lbsr      L280B
                    ldb       $0A,u
                    lslb
                    addb      #$06
                    ldx       $06,u
                    lda       b,x
                    decb
                    ldb       b,x
                    leax      d,x
                    stx       $0C,u
                    lda       ,x
                    sta       $0F,u
                    ldb       $0E,u
                    cmpb      $0F,u
                    bcs       L6191
                    clrb
L6191               bsr       L61D2
                    leas      $01,s
                    rts

L6196               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       L61D2
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L61B1               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L61D2
                    ldd       ,s
                    lbsr      L280B
                    leas      $02,s
                    rts

L61D2               leas      -$01,s
                    ldx       $06,u
                    bne       L61DC
                    ldb       #$0A
                    bra       L61E2
L61DC               cmpb      $0F,u
                    bcs       L61ED
                    ldb       #$08
L61E2               stb       ,s
                    tfr       u,d
                    subd      <$0030
                    lda       ,s
                    lbsr      L10ED
L61ED               stb       $0E,u
                    ldd       $08,u
                    lbsr      L280B
                    ldb       $0E,u
                    lslb
                    addb      #$02
                    ldx       $0C,u
                    lda       b,x
                    decb
                    ldb       b,x
                    leax      d,x
                    stx       <$10,u
                    ldd       ,x
                    std       <$1C,u
                    adda      $03,u
                    cmpa      #$A0
                    bls       L621F
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lda       #$A0
                    suba      <$1C,u
                    sta       $03,u
L621F               decb
                    cmpb      $04,u
                    bls       L6240
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    stb       $04,u
                    cmpb      >$01D6
                    bhi       L6240
                    lda       <$26,u
                    bita      #$08
                    bne       L6240
                    ldb       >$01D6
                    incb
                    stb       $04,u
L6240               leas      $01,s
                    rts

L6243               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       $0F,u
                    deca
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L6258               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       $0E,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L626C               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       $0A,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L6280               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       $05,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L6294               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       $0B,u
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

L62A8               ldb       ,y+
                    bsr       L62B8
                    rts

L62AD               ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       L62B8
                    rts

L62B8               leas      -$05,s
                    stb       ,s
                    lbsr      L602E
                    leax      ,x
                    bne       L62CA
                    lda       #$01
                    ldb       ,s
                    lbsr      L10ED
L62CA               stx       $01,s
                    ldd       <$000A
                    std       $03,s
                    lda       #$07
                    ldb       ,s
                    lbsr      L494E
                    ldu       >L6022,pcr
                    ldd       #$0000
                    std       ,u
                    lbsr      L058F
                    ldx       $01,s
                    ldu       $03,x
                    lda       $05,x
                    lbsr      L27EB
                    stu       <$004F
                    stx       <$0055
                    lbsr      L059C
                    lbsr      L27E2
                    ldd       $03,s
                    lbsr      L280B
                    leas      $05,s
                    rts

L62FE               lda       <$27,u
                    beq       L630D
                    dec       <$27,u
                    lda       <$25,u
                    bita      #$40
                    beq       L6334
L630D               lbsr      L4032
                    lda       #$09
                    lbsr      L6006
                    sta       <$21,u
                    cmpu      <$0030
                    bne       L6320
                    sta       >$0437
L6320               lda       <$27,u
L6323               cmpa      #$06
                    bcc       L6334
                    lbsr      L4032
                    lda       #$33
                    lbsr      L6006
                    sta       <$27,u
                    bra       L6323
L6334               rts

L115CB              ldx       #$05ee              * regX will now point to the priority table
                    lbra      L115C               * back to the original code

L125CB              lbsr      L125C
                    tfr       u,d
                    rts

* Patch stub to have "format string" return string in X
* without altering code length in "move to (x,y)"
stub1               lbsr      L3ED6
                    tfr       u,x
                    lbra      L0C6F

                    fcb       0,0,0,0,0,0,0,0
L633D               fcc       /mnln/
                    fcb       0

                    emod
eom                 equ       *
                    end
