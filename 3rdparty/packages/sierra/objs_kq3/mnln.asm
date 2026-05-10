********************************************************************
* MNLN - Kings Quest III main line module
*
*        Header for : mnln
*        Module size: $602E  #24622
*        Module CRC : $4A3F24 (Good)
*        Hdr parity : $66
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

* Disassembled 03/02/06 21:32:32 by Disasm v1.6 (C) 1988 by RML

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
                    lbra      L00B9               jump over strings


* Text strings think this was probably an Info thing
L0015               fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       C$NULL

L0056               fcc       '      Game paused.'
                    fcb       C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL


L0082               fcc       'Press ENTER to quit.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to keep playing.'
                    fcb       C$NULL

L00B9               leas      -$06,s              make room on the stack
                    lbsr      L0478               modifies table values at 1B0
                    lbsr      L0D55               modifies table values at D09
                    lbsr      L2132               calls the mmu twiddler at >$659
*                         uses toc and words.tok`

L00C4               clra
                    ldb       >$043C              ** who loads me with ??
                    std       ,s

L00CA               lbsr      L12A8
L00CD               ldd       <u003E
                    cmpd      ,s
                    bcc       L00DD
                    cmpd      $04,s
                    beq       L00CD
                    std       $04,s
                    bra       L00CA
L00DD               ldd       #$0000
                    std       <u003E
                    lbsr      L0952               self contained call to clear 50 bytes 05BA
                    lda       >$01AF
                    anda      #$DF
                    sta       >$01AF
                    lda       >$01AF
                    anda      #$F7
                    sta       >$01AF
                    lbsr      L5A4C
                    ldx       <u0030
                    lda       >$0251
                    beq       L0107
                    lda       >$0438
                    sta       <$21,x
                    bra       L010D
L0107               lda       <$21,x
                    sta       >$0438
L010D               lbsr      L0733
                    lda       >$01B0
                    anda      #$40
                    sta       $03,s
                    lbsr      L4E26
L011A               lda       >$0435
                    sta       $02,s
                    clrb
                    lbsr      L2612
                    leay      ,y
                    bne       L013B
                    clra
                    sta       >$043B
                    sta       >$0437
                    sta       >$0436
                    lda       >$01AF
                    anda      #$DF
                    sta       >$01AF
                    bra       L011A
L013B               lda       >$0438
                    ldx       <u0030
                    sta       <$21,x
                    lda       $02,s
                    cmpa      >$0435
                    bne       L0153
                    lda       >$01B0
                    anda      #$40
                    cmpa      $03,s
                    beq       L0156
L0153               lbsr      L54F7
L0156               clra
                    sta       >$0437
                    sta       >$0436
                    lda       >$01AF
                    anda      #$FB
                    sta       >$01AF
                    lda       >$01AF
                    anda      #$FD
                    sta       >$01AF
                    lda       >$01B0
                    anda      #$F7
                    sta       >$01B0
                    lda       >$05EC
                    cmpa      #$00
                    lbne      L00C4
                    lbsr      L068C
                    lbra      L00C4

cmd_pause
L0184               lda       #$01
                    sta       >X0102              set clock_state = 1
                    lbsr      L129A               events_clear
                    leau      >L0056,pcr          get addr of game paused msg
                    lbsr      L37F2               pass it to message_box()
                    clr       >X0102              set clock_state = 0
                    rts

cmd_quit
L0197               lda       ,y+                 get the arg passed and bump y
                    cmpa      #$01                was it a 1?
                    beq       L01A6               if so time to exit
                    leau      >L0082,pcr          get addr of quit / continue msg
                    lbsr      L37F2               pass it to message_box()
                    beq       L01AF               if we didn't get a one back play on
*                           otherwise time to close down the game
L01A6               lda       #$03                load the offset to exit_agi()
                    sta       <u0009              save the offset
                    ldx       <u0022              set up to jump to sierra
                    jsr       >$0659              mmu twiddle
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
L01B0               fdb       cmd_do_nothing,$0000
                    fdb       cmd_increment,$0180
                    fdb       cmd_decrement,$0180
                    fdb       cmd_assignn,$0280
                    fdb       cmd_assignv,$02C0
                    fdb       cmd_addn,$0280
                    fdb       cmd_addv,$02C0
                    fdb       cmd_subn,$0280
                    fdb       cmd_subv,$02C0
                    fdb       cmd_lindirectv,$02C0
                    fdb       cmd_rindirect,$02C0
                    fdb       cmd_lindirectn,$0280

                    fdb       cmd_set,$0100
                    fdb       cmd_reset,$0100
                    fdb       cmd_toggle,$0100
                    fdb       cmd_set_v,$0180
                    fdb       cmd_reset_v,$0180
                    fdb       cmd_toggle_v,$0180

                    fdb       cmd_new_room,$0100
                    fdb       cmd_new_room_v,$0180

                    fdb       cmd_load_logics,$0100
                    fdb       cmd_load_logics_v,$0180
                    fdb       cmd_call,$0100
                    fdb       cmd_call_v,$0180

                    fdb       cmd_load_pic,$0180
                    fdb       cmd_draw_pic,$0180
                    fdb       cmd_show_pic,$0000
                    fdb       cmd_discard_pic,$0180
                    fdb       cmd_overlay_pic,$0180
                    fdb       cmd_show_pri,$0000

                    fdb       cmd_load_view,$0100
                    fdb       cmd_load_view_v,$0180
                    fdb       cmd_discard_view,$0100
                    fdb       cmd_animate_obj,$0100
                    fdb       cmd_unanimate_all,$0000
                    fdb       cmd_draw,$0100
                    fdb       cmd_erase,$0100

                    fdb       cmd_position,$0300
                    fdb       cmd_position_v,$0360
                    fdb       cmd_get_position,$0360
                    fdb       cmd_reposition,$0360

                    fdb       cmd_set_view,$0200
                    fdb       cmd_set_view_v,$0240
                    fdb       cmd_set_loop,$0200
                    fdb       cmd_set_loop_v,$0240
                    fdb       cmd_fix_loop,$0100
                    fdb       cmd_release_loop,$0100
                    fdb       cmd_set_cel,$0200
                    fdb       cmd_set_cel_v,$0240
                    fdb       cmd_last_cel,$0240
                    fdb       cmd_current_cel,$0240
                    fdb       cmd_current_loop,$0240
                    fdb       cmd_current_view,$0240
                    fdb       cmd_number_of_loops,$0240

                    fdb       cmd_set_priority,$0200
                    fdb       cmd_set_priority_v,$0240
                    fdb       cmd_release_priority,$0100
                    fdb       cmd_get_priority,$0240

                    fdb       cmd_stop_update,$0100
                    fdb       cmd_start_update,$0100
                    fdb       cmd_force_update,$0100

                    fdb       cmd_ignore_horizon,$0100
                    fdb       cmd_observe_horizon,$0100
                    fdb       cmd_set_horizon,$0100
                    fdb       cmd_obj_on_water,$0100
                    fdb       cmd_obj_on_land,$0100
                    fdb       cmd_obj_on_anything,$0100

                    fdb       cmd_ignore_objects,$0100
                    fdb       cmd_observe_objects,$0100
                    fdb       cmd_distance,$0320

                    fdb       cmd_stop_cycling,$0100
                    fdb       cmd_start_cycling,$0100
                    fdb       cmd_normal_cycle,$0100
                    fdb       cmd_end_of_loop,$0200
                    fdb       cmd_reverse_cycle,$0100
                    fdb       cmd_reverse_loop,$0200
                    fdb       cmd_cycle_time,$0240

                    fdb       cmd_stop_motion,$0100
                    fdb       cmd_start_motion,$0100
                    fdb       cmd_step_size,$0240
                    fdb       cmd_step_time,$0240
                    fdb       cmd_move_obj,$0500
                    fdb       cmd_move_obj_v,$0570
                    fdb       cmd_follow_ego,$0300
                    fdb       cmd_wander,$0100
                    fdb       cmd_normal_motion,$0100
                    fdb       cmd_set_dir,$0240
                    fdb       cmd_get_dir,$0240

                    fdb       cmd_ignore_blocks,$0100
                    fdb       cmd_observe_blocks,$0100
                    fdb       cmd_block,$0400
                    fdb       cmd_unblock,$0000

                    fdb       cmd_get,$0100
                    fdb       cmd_get_v,$0180
                    fdb       cmd_drop,$0100
                    fdb       cmd_put,$0200
                    fdb       cmd_put_v,$0240
                    fdb       cmd_get_room_v,$02C0

*              are these really sound commands in ours ?
                    fdb       cmd_load_sound,$0100
                    fdb       cmd_sound,$0200
                    fdb       cmd_stop_sound,$0000 (cmd_do_nothing)

                    fdb       cmd_print,$0100
                    fdb       cmd_print_v,$0180
                    fdb       cmd_display,$0300
                    fdb       cmd_display_v,$03E0
                    fdb       cmd_clear_lines,$0300
                    fdb       cmd_text_screen,$0000
                    fdb       cmd_graphics,$0000

                    fdb       cmd_set_cursor_char,$0100
                    fdb       cmd_set_text_attribute,$0200
                    fdb       cmd_shake_screen,$0100 ( bump a byte and cmd_do_nothing)
                    fdb       cmd_config_screen,$0300
                    fdb       cmd_status_line_on,$0000
                    fdb       cmd_status_line_off,$0000
                    fdb       cmd_set_string,$0200
                    fdb       cmd_get_string,$0500
                    fdb       cmd_word_to_string,$0200
                    fdb       cmd_parse,$0100

                    fdb       cmd_get_num,$0240
                    fdb       cmd_prevent_input,$0000
                    fdb       cmd_accept_input,$0000
                    fdb       cmd_set_key,$0300
                    fdb       cmd_add_to_pic,$0700
                    fdb       cmd_add_to_pic_v,$07FE
                    fdb       cmd_status,$0000
                    fdb       cmd_save_game,$0000
                    fdb       cmd_restore_game,$0000
                    fdb       cmd_init_disk,$0000 (cmd_do_nothing)

                    fdb       cmd_restart_game,$0000
                    fdb       cmd_show_obj,$0100
                    fdb       cmd_random,$0320
                    fdb       cmd_program_control,$0000
                    fdb       cmd_player_control,$0000
                    fdb       cmd_obj_status_v,$0180 ( nagi has as donothing)
                    fdb       cmd_quit,$0100
                    fdb       cmd_show_mem,$0000  ( nagi has as do nothing)
                    fdb       cmd_pause,$0000
                    fdb       cmd_echo_line,$0000

                    fdb       cmd_cancel_line,$0000
                    fdb       cmd_init_joy,$0000  ( nagi has as do nothing)
                    fdb       cmd_toggle_monitor,$0000
                    fdb       cmd_version,$0000
                    fdb       cmd_script_size,$0100
                    fdb       cmd_set_game_id,$0100
                    fdb       cmd_log,$0100       ( an almost do nothing, we may want to implement)
                    fdb       cmd_set_scan_start,$0000
                    fdb       cmd_reset_scan_start,$0000

                    fdb       cmd_reposition_to,$0300
                    fdb       cmd_reposition_to_v,$0360

                    fdb       cmd_trace_on,$0000
                    fdb       cmd_trace_info,$0300
                    fdb       cmd_print_at,$0400
                    fdb       cmd_print_at_v,$0480
                    fdb       cmd_discard_view_v,$0180
                    fdb       cmd_clear_text_rect,$0500
                    fdb       cmd_set_upper_left,$0200 almost a do nothing

                    fdb       cmd_set_menu,$0100
                    fdb       cmd_set_menu_item,$0200
                    fdb       cmd_submit_menu,$0000
                    fdb       cmd_enable_item,$0100
                    fdb       cmd_disable_item,$0100
                    fdb       cmd_menu_input,$0000

                    fdb       cmd_show_obj_v,$0100
                    fdb       cmd_open_dialogue,$0000 (cmd_do_nothing)
                    fdb       cmd_close_dialogue,$0000 (cmd_do_nothing)

                    fdb       cmd_multn,$0280
                    fdb       cmd_multv,$02C0
                    fdb       cmd_divn,$0280
                    fdb       cmd_divv,$02C0

                    fdb       cmd_close_window,$0000
                    fdb       cmd_set_simple,$0100 (unknown_170)
                    fdb       cmd_push_script,$0000 (unknown_171)
                    fdb       cmd_pop_script,$0000 (unknown_172)
                    fdb       cmd_hold_key,$0000  (unknown_173)  (cmd_do_nothing)
                    fdb       cmd_set_pri_base,$0000 (unknown_174)  (cmd_do_nothing)
                    fdb       cmd_discard_sound,$0000 (cmd_do_nothing)
                    fdb       cmd_hide_mouse,$0400 might be fence  almost do nothing
                    fdb       cmd_allow_menu,$02C0 might be mouse posn  almost do nothing




*  This is interesting but stupid
*  seems to use some value saved at load time of this module in sierra
*  add it to every other word here (2bytes) and stow it back in place.

L0478               leas      -$01,s              Make temp storage on stack for one byte
                    lda       #$B2                load the counter for the move 178
                    sta       ,s                  store the value on the stack
*        leau  >$01B0,pcr     --- disassembly
                    leau      >L01B0,pcr          point u at the beginning of the data block

L0482               ldd       <u002E              value set in sierra at nmload of mnln
                    addd      ,u                  add that to current u and stow in u
                    std       ,u                  now stow that back at u
                    leau      $04,u               next u will move 4 bytes
                    dec       ,s                  drop the counter by 1 and go again
                    bne       L0482
                    leas      $01,s
                    rts

***********************************************************
*
* Uses the value stored at u0068 in A and
*      the value passed in B
*      to select a value to jump to
*

L0491               cmpb      #$B1                compare input value
                    bls       L049A               less than or equal
                    lda       #$10                greater than load and go into never land
                    lbsr      L10CE
L049A               lda       <u0068
                    cmpa      #$01
                    bne       L04A7
                    pshs      y
                    lbsr      L5802
                    puls      y
L04A7               leax      >L01B0,pcr          big jump table address
                    lda       #$04
                    mul
                    jsr       [d,x]
                    leay      ,y
                    beq       L04BC               is zero ?? leave
                    ldb       ,y+
                    beq       L04BC               is the next byte zero leave
                    cmpb      #$FC
                    bcs       L0491               start again
L04BC               rts

L04BD               lda       <$25,u
                    bita      #$10
                    beq       L04CB
                    anda      #$EF
                    sta       <$25,u
                    bra       L0528               your done so leave
L04CB               ldd       $0E,u
                    decb
                    std       <u0074
                    lda       <$23,u
                    cmpa      #$00                is it zero?
                    bne       L04E1               no test for next num
                    ldb       <u0074
                    incb
                    cmpb      <u0075
                    bls       L0525               head for exit
                    clrb
                    bra       L0525               head for exit
L04E1               cmpa      #$03                is it a 3?
                    bne       L04EE               no test for next num
                    ldb       <u0074
                    decb
                    bpl       L0525               head for exit
                    ldb       <u0075
                    bra       L0525               head for exit
L04EE               cmpa      #$02                is it a 2?
                    bne       L04FD               no test for next number
                    ldb       <u0074
                    beq       L050E
                    decb
                    bne       L0525               head for exit
                    stb       <u0074
                    bra       L050E
L04FD               cmpa      #$01                is it a 1?
                    bne       L0525               head for exit
                    ldb       <u0074
                    cmpb      <u0075
                    bcc       L050E
                    incb
                    cmpb      <u0075
                    bne       L0525               head for exit
                    stb       <u0074
L050E               lda       <$27,u
                    lbsr      L16D5
                    lda       <$26,u
                    anda      #$DF
                    sta       <$26,u
                    clra
                    sta       <$21,u
                    sta       <$23,u
                    ldb       <u0074
L0525               lbsr      L5EBB
L0528               rts

* The bulk of this string of subs called thru the jump table
* use the value passed thru y and the value stowed at u0030
* to resolve a pointer for use in manipulating the rest of the
* data handled
* These could be consolidated to reduce program size


cmd_fix_loop
L0529               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,x
                    lda       <$25,x
                    ora       #$20
                    sta       <$25,x
                    rts

cmd_release_loop
L053B               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,x
                    lda       <$25,x
                    anda      #$DF
                    sta       <$25,x
                    rts

L054D               lda       #$01
                    ldb       <$26,u
                    andb      #$51
                    cmpb      #$51
                    beq       L0559
                    clra
L0559               rts

L055A               lda       #$01
                    ldb       <$26,u
                    andb      #$51
                    cmpb      #$41
                    beq       L0566
                    clra
L0566               rts

L0567               ldx       #$0548
                    leau      >L054D,pcr          routine above ($51,$51)
                    lbsr      L3113
                    rts

L0572               ldx       #$054C
                    leau      >L055A,pcr          routine above ($51,$41)
                    lbsr      L3113
                    rts

L057D               ldx       #$0548
                    lbsr      L30DE               twiddle mmu
                    ldx       #$054C
                    lbsr      L30DE               twiddle mmu
                    rts

L058A               bsr       L0572

                    pshs      x
                    lda       #$1E                blitlist_erase()
                    sta       <u0021              save the offset
                    ldx       <u0028              set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    bsr       L0567
                    pshs      x
                    lda       #$1E                blitlist_erase()
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack
                    rts

L05A9               ldx       #$054C
                    pshs      x
                    lda       #$18
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    ldx       #$0548
                    pshs      x
                    lda       #$18
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack
                    rts

L05CA               ldx       #$0548
                    lbsr      L30F6
                    ldx       #$054C
                    lbsr      L30F6
                    rts

cmd_stop_update
L05D7               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    bsr       L05F8
                    rts

cmd_start_update
L05E3               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    bsr       L0612
                    rts

cmd_force_update
L05EF               lda       ,y+
                    bsr       L057D
                    bsr       L058A
                    bsr       L05A9
                    rts

L05F8               lda       <$26,u
                    bita      #$10
                    beq       L0611
                    pshs      u
                    lbsr      L057D
                    puls      u
                    lda       <$26,u
                    anda      #$EF
                    sta       <$26,u
                    lbsr      L058A
L0611               rts

L0612               lda       <$26,u
                    bita      #$10
                    bne       L062B
                    pshs      u
                    lbsr      L057D
                    puls      u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    lbsr      L058A
L062B               rts


* from obj_base.c of nagi 2002_11_14 except those have one more right turn at the end.

loop_small
L062C               fcb       IGNORE,IGNORE
                    fcb       RIGHT,RIGHT,RIGHT
                    fcb       IGNORE
                    fcb       LEFT,LEFT,LEFT

loop_large
L0635               fcb       IGNORE,UP
                    fcb       RIGHT,RIGHT,RIGHT
                    fcb       DOWN
                    fcb       LEFT,LEFT,LEFT

cmd_animate_obj
L063E               lda       ,y+
                    bsr       L0643
                    rts

L0643               leas      -$01,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    cmpu      <u0032
                    bcs       L065A
                    lda       #$0D
                    ldb       ,s
                    lbsr      L10CE
L065A               lda       <$26,u
                    bita      #$40
                    bne       L0671
                    lda       #$70
                    sta       <$26,u
                    lda       #$00
                    sta       <$22,u
                    sta       <$23,u
                    sta       <$21,u
L0671               leas      $01,s
                    rts

cmd_unanimate_all
L0674               lbsr      L057D
                    ldu       <u0030
L0679               cmpu      <u0032
                    bcc       L068B
                    lda       <$26,u
                    anda      #$BE
                    sta       <$26,u
                    leau      <$2B,u
                    bra       L0679
L068B               rts

L068C               leas      -$01,s
                    clr       ,s
                    ldu       <u0030
L0692               cmpu      <u0032
                    bcc       L06F9
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    bne       L06F4
                    inc       ,s
                    ldb       #$04
                    lda       <$25,u
                    bita      #$20
                    bne       L06DA
                    lda       $0B,u
                    cmpa      #$03
                    bhi       L06C0
                    cmpa      #$02
                    bcs       L06DA
                    lda       <$21,u
                    leay      >L062C,pcr          loop_small data address
                    ldb       a,y
                    bra       L06C9
L06C0               lda       <$21,u
                    leay      >L0635,pcr          loop_large data address
                    ldb       a,y
L06C9               lda       $01,u
                    cmpa      #$01
                    bne       L06DA
                    cmpb      #$04
                    beq       L06DA
                    cmpb      $0A,u
                    beq       L06DA
                    lbsr      L5E3D
L06DA               lda       <$26,u
                    bita      #$20
                    beq       L06F4
                    lda       <$20,u
                    beq       L06F4
                    dec       <$20,u
                    bne       L06F4
                    lbsr      L04BD
                    lda       <$1F,u
                    sta       <$20,u
L06F4               leau      <$2B,u
                    bra       L0692
L06F9               lda       ,s
                    beq       L0730
                    ldx       #$0548
                    lbsr      L30DE               twiddle mmu
                    lbsr      L2DCD
                    lbsr      L0567

                    pshs      x
                    lda       #$1E                blitlist_erase()
                    sta       <u0021              save the offset
                    ldx       <u0028              set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldx       #$0548
                    pshs      x
                    lda       #$18
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    ldu       <u0030
                    lda       <$25,u
                    anda      #$F6
                    sta       <$25,u
L0730               leas      $01,s
                    rts

L0733               ldu       <u0030
L0735               cmpu      <u0032
                    bcc       L0786
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    bne       L0781
                    lda       $01,u
                    cmpa      #$01
                    bne       L0781
                    lda       <$22,u
                    beq       L0767
                    cmpa      #$01
                    bne       L0757
                    lbsr      L5FE7
                    bra       L0767
L0757               cmpa      #$02
                    bne       L0760
                    lbsr      L1702
                    bra       L0767
L0760               cmpa      #$03
                    bhi       L0767
                    lbsr      L2F0A
L0767               lda       <$26,u
                    ldb       >X01AD              state.block_state
                    bne       L0776
                    anda      #$7F
                    sta       <$26,u
                    bra       L0781
L0776               bita      #$02
                    bne       L0781
                    lda       <$21,u
                    beq       L0781
                    bsr       L0787
L0781               leau      <$2B,u
                    bra       L0735
L0786               rts

L0787               leas      -$03,s
                    ldd       $03,u
                    std       $01,s
                    lbsr      L0866
                    sta       ,s
                    lda       <$21,u
                    beq       L0804
                    cmpa      #$01
                    bne       L07A4
                    ldb       $02,s
                    subb      <$1E,u
                    lda       $01,s
                    bra       L07FD
L07A4               cmpa      #$02
                    bne       L07B2
                    ldd       $01,s
                    adda      <$1E,u
                    subb      <$1E,u
                    bra       L07FD
L07B2               cmpa      #$03
                    bne       L07BF
                    lda       $01,s
                    adda      <$1E,u
                    ldb       $02,s
                    bra       L07FD
L07BF               cmpa      #$04
                    bne       L07CD
                    ldd       $01,s
                    adda      <$1E,u
                    addb      <$1E,u
                    bra       L07FD
L07CD               cmpa      #$05
                    bne       L07DA
                    ldb       $02,s
                    addb      <$1E,u
                    lda       $01,s
                    bra       L07FD
L07DA               cmpa      #$06
                    bne       L07E8
                    ldd       $01,s
                    suba      <$1E,u
                    addb      <$1E,u
                    bra       L07FD
L07E8               cmpa      #$07
                    bne       L07F5
                    lda       $01,s
                    suba      <$1E,u
                    ldb       $02,s
                    bra       L07FD
L07F5               ldd       $01,s
                    suba      <$1E,u
                    subb      <$1E,u
L07FD               lbsr      L0866
                    cmpa      ,s
                    bne       L080E
L0804               lda       <$26,u
                    anda      #$7F
                    sta       <$26,u
                    bra       L0821
L080E               lda       <$26,u
                    ora       #$80
                    sta       <$26,u
                    clr       <$21,u
                    cmpu      <u0030
                    bne       L0821
                    clr       >$0438
L0821               leas      $03,s
                    rts

cmd_block
L0824               lda       #$01
                    sta       >X01AD              state.block_state = 1
                    lda       ,y+
                    sta       >X024F              state.block_x1
                    lda       ,y+
                    sta       >X0250              state.block_y1
                    lda       ,y+
                    sta       >X023D              state.block_x2
                    lda       ,y+
                    sta       >X023E              state.block_y2
                    rts

cmd_unblock
L083E               clr       >X01AD              state.block_state = 0
                    rts

cmd_ignore_blocks
L0842               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u              load objtable[*(c++)]flags
                    ora       #O_BLKIGNORE        set the ignore flag $02
                    sta       <$26,u              stow it back
                    rts

cmd_observe_blocks
L0854               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #^O_BLKIGNORE       $FD
                    sta       <$26,u
                    rts

L0866               leas      -$01,s
                    clr       ,s
                    cmpa      >X024F              state.block_x1
                    bls       L0880
                    cmpa      >X023D              state.block_x2
                    bcc       L0880
                    cmpb      >X0250              state.block_y1
                    bls       L0880
                    cmpb      >X023E              state.block_y2
                    bcc       L0880
                    inc       ,s
L0880               lda       ,s
                    leas      $01,s
                    rts

L0885               clra
                    ldb       <$25,u
                    bitb      #$02
                    bne       L08DC
                    ldx       <u0030
L088F               cmpx      <u0032
                    bcc       L08DC
                    ldb       <$26,x
                    andb      #$41
                    cmpb      #$41
                    bne       L08D5
                    ldb       <$25,x
                    bitb      #$02
                    bne       L08D5
                    ldb       $02,x
                    cmpb      $02,u
                    beq       L08D5
                    ldb       $03,u
                    addb      <$1C,u
                    cmpb      $03,x
                    bcs       L08D5
                    ldb       $03,x
                    addb      <$1C,x
                    cmpb      $03,u
                    bcs       L08D5
                    ldb       $04,x
                    cmpb      $04,u
                    beq       L08DA
                    bhi       L08CD
                    ldb       <$1B,x
                    cmpb      <$1B,u
                    bhi       L08DA
                    bra       L08D5
L08CD               ldb       <$1B,x
                    cmpb      <$1B,u
                    bcs       L08DA
L08D5               leax      <$2B,x
                    bra       L088F
L08DA               lda       #$01
L08DC               rts

cmd_ignore_objects
L08DD               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$02
                    sta       <$25,u
                    rts

cmd_observe_objects
L08EF               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$25,u
                    anda      #$FD
                    sta       <$25,u
                    rts

cmd_distance
L0901               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,x
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$FF
                    ldb       <$26,x
                    bitb      #$01
                    beq       L0949
                    ldb       <$26,u
                    bitb      #$01
                    beq       L0949
                    lda       <$1C,u
                    lsra
                    adda      $03,u
                    ldb       <$1C,x
                    lsrb
                    addb      $03,x
                    stb       <u0076
                    suba      <u0076
                    bcc       L0936
                    nega
L0936               sta       <u0076
                    lda       $04,u
                    suba      $04,x
                    bcc       L093F
                    nega
L093F               adda      <u0076
                    bcs       L0947
                    cmpa      #$FF
                    bne       L0949
L0947               lda       #$FE
L0949               ldb       ,y+
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

* clears 50 bytes at 05BA
L0952               ldu       #$05BA              set address of bytes to be cleared
                    ldx       #$0032              set number of bytes to clear to 50
                    clrb                          set value of store there to 00
                    lbsr      L2BF6               go clear them
                    rts

cmd_set_key
L095D               ldx       #$01D9
                    lda       #$32
L0962               tst       ,x
                    beq       L0972
                    deca
                    bne       L096E
                    ldx       #$0000
                    bra       L0972
L096E               leax      $02,x
                    bra       L0962
L0972               lda       ,y+
                    ldb       ,y+
                    beq       L097C
                    tfr       b,a
                    adda      #$FB
L097C               ldb       ,y+
                    leax      ,x
                    beq       L0984
                    std       ,x
L0984               rts

cmd_normal_cycle
L0985               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$00
                    sta       <$23,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts

cmd_end_of_loop
L099C               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$01
                    sta       <$23,u
                    ldd       <$25,u
                    ora       #$10
                    orb       #$30
                    std       <$25,u
                    lda       ,y+
                    sta       <$27,u
                    lbsr      L16DC
                    rts

cmd_reverse_cycle
L09BD               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$03
                    sta       <$23,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts

cmd_reverse_loop
L09D4               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$02
                    sta       <$23,u
                    ldd       <$25,u
                    ora       #$10
                    orb       #$30
                    std       <$25,u
                    lda       ,y+
                    sta       <$27,u
                    lbsr      L16DC
                    rts

cmd_cycle_time
L09F5               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       <$1F,u
                    sta       <$20,u
                    rts

cmd_stop_cycling
L0A0D               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$DF
                    sta       <$26,u
                    rts

cmd_start_cycling
L0A1F               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts

L0A31               fcc       'normal cycle'
                    fcb       C$NULL

L0A3E               fcc       'end of loop'
                    fcb       C$NULL

L0A4A               fcc       'reverse loop'
                    fcb       C$NULL

L0A57               fcc       'reverse cycle'
                    fcb       C$NULL

L0A65               fcc       'normal motion'
                    fcb       C$NULL

L0A73               fcc       'wander'
                    fcb       C$NULL

L0A7A               fcc       'follow'
                    fcb       C$NULL

L0A81               fcc       'move to (%d, %d)'
                    fcb       C$NULL

L0A92               fcc       'Object %d:'
                    fcb       C$LF
                    fcc       'x: %d  xsize: %d'
                    fcb       C$LF
                    fcc       'y: %d  ysize: %d'
                    fcb       C$LF
                    fcc       'pri: %d'
                    fcb       C$LF
                    fcc       'stepsize: %d'
                    fcb       C$LF
                    fcc       'control: %x'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$NULL

L0AE6               fcc       'Adventure Game Interpreter'
                    fcb       C$LF
                    fcc       '      Version 2.023'
                    fcb       $00

L0B15               fcc       'room: %u'
                    fcb       C$LF
                    fcc       'heap size: %u'
                    fcb       C$LF
                    fcc       'now: %u  max: %u'
                    fcb       C$LF
                    fcc       'rm.0, etc.: %u'
                    fcb       C$LF
                    fcc       'common size: %u'
                    fcb       C$LF
                    fcc       'now: %u  max: %u'
                    fcb       C$LF
                    fcc       'tables, etc.: %u'
                    fcb       C$LF
                    fcc       'max script: %u'
                    fcb       C$NULL

cmd_get_num
L0B8D               leas      -$54,s
                    lbsr      L5B7A               input_edit_on
                    lda       >$01D8
                    clrb
                    std       <u0040
                    ldb       ,y+
                    lbsr      L3B58
                    ldd       #$0028
L0BA1               pshs      d
                    pshs      u
                    ldd       $08,s
                    pshs      d
                    lbsr      L39B5
                    leas      $06,s
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    clr       ,s
                    ldb       #$04
                    leax      ,s
                    lbsr      L5613
                    lbsr      L5BAD
                    leax      ,s
                    lbsr      L113E
                    beq       L0BCB
                    lbsr      L1199
L0BCB               ldx       #$0432
                    ldb       ,y+
L0BD0               abx
                    sta       ,x
                    leas      <$54,s
                    rts

cmd_obj_status_v
L0BD7               leas      >-$0194,s
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    std       >$0192,s
                    lda       <$23,u
                    cmpa      #CY_NORM            $00
                    bne       L0BFB
                    leax      >L0A31,pcr          normal cycle
                    bra       L0C13
L0BFB               cmpa      #CY_END             $01
                    bne       L0C05
                    leax      >L0A3E,pcr          end of loop
                    bra       L0C13
L0C05               cmpa      #CY_REVEND          $02
                    bne       L0C0F
                    leax      >L0A4A,pcr          reverse loop
                    bra       L0C13               ** default must be CY_REV #$03
L0C0F               leax      >L0A57,pcr          reverse cycle
L0C13               stx       >$0190,s
                    lda       <$22,u
                    cmpa      #MT_NORM            $00
                    bne       L0C24
                    leax      >L0A65,pcr          normal motion
                    bra       L0C54
L0C24               cmpa      #MT_WANDER          $01
                    bne       L0C2E
                    leax      >L0A73,pcr          wander
                    bra       L0C54
L0C2E               cmpa      #MT_FOLLOW          $02
                    bne       L0C38
                    leax      >L0A7A,pcr          follow
                    bra       L0C54
L0C38               clra
                    ldb       <$28,u
                    pshs      b,a
                    ldb       <$27,u
                    pshs      b,a
                    leax      >L0A81,pcr          move to
                    pshs      x
                    leax      >$0132,s
                    pshs      x
                    lbsr      L3C21
                    leas      $08,s
L0C54               pshs      u
                    leax      >$0192,s
                    pshs      x
                    ldu       >$0196,s
                    ldd       <$25,u
                    pshs      b,a
                    clra
                    ldb       <$1E,u
                    pshs      b,a
                    ldb       <$24,u
                    pshs      b,a
                    ldb       <$1D,u
                    pshs      b,a
                    ldb       $04,u
                    pshs      b,a
                    ldb       <$1C,u
                    pshs      b,a
                    ldb       $03,u
                    pshs      b,a
                    ldb       $02,u
                    pshs      b,a
                    leau      >L0A92,pcr          Object descript
                    pshs      u
                    leax      <$16,s
                    pshs      x
                    lbsr      L3C21
                    leas      <$18,s
                    lbsr      L37F2
                    leas      >$0194,s
                    rts

* gfx_picbuff_update() is in the shdw module
* L2C01 sets up MMU swaps to get it mapped in
cmd_show_pri
L0C9F               inc       >X0550              sets gfx_picbuffrotate = 1 (>0)
                    lbsr      L2C01               calls gfx_picbuff_update()
                    lbsr      L1361               calls user_bolean_poll()
                    lbsr      L2C01               calls gfx_picbuff_update()
                    clr       >X0550              sets gfx_picbuffrotate = 0
                    rts

cmd_version
L0CAF               leau      >L0AE6,pcr          version banner
                    lbsr      L37F2               message_box()
                    rts

cmd_show_mem
L0CB7               leas      >-$00C8,s
                    ldd       <u0057
                    pshs      d
                    ldd       <u0053
                    subd      #$06CE
                    pshs      d
                    ldd       <u0051
                    subd      <u0053
                    pshs      d
                    ldd       <u0055
                    subd      <u0053
                    pshs      d
                    ldd       <u0000
                    subd      #$06CE
                    pshs      d
                    ldd       <u004D
                    pshs      d
                    ldd       <u004B
                    pshs      d
                    ldd       <u004F
                    pshs      d
                    ldd       #$FFFF
                    pshs      d
                    clra
                    ldb       >$0432
                    leax      >L0B15,pcr          room heap, common etc msg
                    leau      <$12,s
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      <$18,s
                    lbsr      L37F2               message_box()
                    leas      >$00C8,s
                    rts


eval_table
L0D09               fdb       cmd_ret_false,$0000
                    fdb       cmd_equal_n,$0280
                    fdb       cmd_equal_v,$02C0
                    fdb       cmd_less_n,$0280
                    fdb       cmd_less_v,$02C0
                    fdb       cmd_greater_n,$0280
                    fdb       cmd_greater_v,$02C0
                    fdb       cmd_isset,$0100
                    fdb       cmd_isset_v,$0180
                    fdb       cmd_has,$0100
                    fdb       cmd_obj_in_room,$0240
                    fdb       cmd_posn,$0500
                    fdb       cmd_controller,$0100
                    fdb       cmd_have_key,$0000
                    fdb       cmd_said,$0000
                    fdb       cmd_compare_strings,$0200
                    fdb       cmd_obj_in_box,$0500
                    fdb       cmd_center_posn,$0500
                    fdb       cmd_right_posn,$0500
*        not in our table "unknown 19" cmd_ret_false


* Same function as sub at L0478 just different table
L0D55               leas      -01,s               make room on stack for counter
                    lda       #$13                load the count
                    sta       ,s                  to it on the stack
                    leau      >L0D09,pcr          get table addr
L0D5F               ldd       <u002E              get the bias value
                    addd      ,u                  add em
                    std       ,u                  stow it
                    leau      $04,u               skip a word
                    dec       ,s                  drop the count
                    bne       L0D5F               branch till we finish
                    leas      $01,s               clean up stack
                    rts                           return

L0D6E               leax      -$01,y
                    stx       <u006C
                    cmpa      #$12
                    bhi       L0D93               leave
                    lsla
                    lsla
                    leax      >L0D09,pcr          jump table 2 address
                    jsr       [a,x]
                    ldb       <u0068
                    cmpb      #$01
                    bne       L0D9A               leave
                    pshs      y
                    sta       <u006E
                    ldu       <u006C
                    lbsr      L582A
                    puls      y
                    lda       <u006E
                    bra       L0D9A               leave
L0D93               tfr       a,b
                    lda       #$0F
                    lbsr      L10CE
L0D9A               rts

cmd_equal_n
L0D9B               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbne      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_equal_v
L0DAC               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x


                    ldb       ,y+
                    ldx       #$0432
                    abx
                    cmpa      ,x
                    lbne      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_less_n
L0DC3               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbcc      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_less_v
L0DD4               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x

                    ldb       ,y+
                    ldx       #$0432
                    abx
                    cmpa      ,x
                    lbcc      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_greater_n
L0DEB               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbls      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_greater_v
L0DFC               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x

                    ldb       ,y+
                    ldx       #$0432
                    abx
                    cmpa      ,x
                    lbls      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_isset
L0E13               lda       ,y+
                    lbsr      L16EB
                    lbeq      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_isset_v
L0E1F               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    lbsr      L16EB
                    lbeq      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return
                    rts

cmd_has
L0E32               ldb       ,y+
                    ldx       <u0038
                    abx
                    abx
                    abx
                    lda       #$FF
                    cmpa      $02,x
                    lbne      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_obj_in_room
L0E44               ldb       $01,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       <u0038
                    abx
                    abx
                    abx
                    cmpa      $02,x
                    lbne      L0F4E               clr a and return
                    lbra      L0F4B               load a with #$01 and return

cmd_controller
L0E5C               lda       ,y+
                    ldx       #$05BA
                    lda       a,x
                    rts

cmd_have_key
L0E64               ldx       #$0432
                    lda       <$13,x
                    lbne      L0F4B               load a with #$01 and return
L0E6E               lbsr      L132C
                    cmpa      #$FF
                    beq       L0E6E
                    tsta
                    lbeq      L0F4E               clr a and return
                    sta       <$13,x
                    lbra      L0F4B               load a with #$01 and return

cmd_said
L0E80               lda       ,y+
                    sta       <u0072
                    lda       >$015A
                    beq       L0ECE
                    sta       <u0073
                    lda       >$01AF
                    anda      #$08
                    bne       L0ECE
                    lda       >$01AF
                    anda      #$20
                    beq       L0ECE
                    ldx       #$0195
L0E9C               lda       <u0072
                    beq       L0ECE
                    ldb       ,y+
                    lda       ,y+
                    dec       <u0072
                    cmpd      #$270F
                    bne       L0EB6
                    lda       <u0072
                    beq       L0ED2
                    lsla
                    leay      a,y
                    lbra      L0ED2
L0EB6               tst       <u0073
                    bne       L0EBF
                    inc       <u0073
                    lbra      L0ECE
L0EBF               cmpd      ,x++
                    beq       L0ECA
                    cmpd      #$0001
                    bne       L0ECE
L0ECA               dec       <u0073
                    bra       L0E9C
L0ECE               ldd       <u0072
                    bne       L0EDD
L0ED2               lda       >$01AF
                    ora       #$08
                    sta       >$01AF
                    lbra      L0F4B               load a with #$01 and return
L0EDD               lsla
                    leay      a,y
                    lbra      L0F4E               clr a and return

cmd_compare_strings
L0EE3               lda       ,y+
                    ldb       ,y+
                    lbsr      L56AF
                    rts

cmd_posn
L0EEB               bsr       L0F1B
                    sta       <u006F
                    sta       <u0071
                    bra       L0F29

cmd_center_posn
L0EF3               bsr       L0F1B
                    sta       <u006F
                    lda       <$1C,u
                    lsra
                    adda      <u006F
                    sta       <u006F
                    sta       <u0071
                    bra       L0F29

cmd_right_posn
L0F03               bsr       L0F1B
                    adda      <$1C,u
                    deca
                    sta       <u006F
                    sta       <u0071
                    bra       L0F29

cmd_obj_in_box
L0F0F               bsr       L0F1B
                    sta       <u006F
                    adda      <$1C,u
                    deca
                    sta       <u0071
                    bra       L0F29
L0F1B               ldb       ,y+
                    lda       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldd       $03,u
                    stb       <u0070
                    rts

L0F29               ldd       <u006F
                    cmpa      ,y+
                    bcc       L0F33
                    leay      $03,y
                    bra       L0F4E               clr a and return
L0F33               cmpb      ,y+
                    bcc       L0F3B
                    leay      $02,y
                    bra       L0F4E               clr a and return
L0F3B               lda       <u0071
                    cmpa      ,y+
                    bls       L0F45
                    leay      $01,y
                    bra       L0F4E               clr a and return
L0F45               cmpb      ,y+
                    bls       L0F4B               load a with #$01 and return
                    bra       L0F4E               clr a and return

L0F4B               lda       #$01
                    rts

L0F4E               clra

cmd_ret_false
L0F4F               rts                           called from eval_table cmd_return_false

cmd_draw
L0F50               lda       ,y+
                    pshs      y
                    bsr       L0F59
                    puls      y
                    rts

L0F59               leas      -$03,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    cmpu      <u0032
                    bcs       L0F70
                    lda       #$13
                    ldb       ,s
                    lbsr      L10CE
L0F70               ldd       <$10,u
                    bne       L0F7A
                    lda       #$14
                    lbsr      L10CE
L0F7A               lda       <$26,u
                    bita      #$01
                    bne       L0FD2
                    stu       $01,s
                    ora       #$10
                    sta       <$26,u
                    lbsr      L15F5
                    ldd       <$10,u
                    std       <$12,u
                    ldd       $08,u
                    std       <$14,u
                    ldd       $03,u
                    std       <$1A,u
                    ldx       #$0548
                    lbsr      L30DE               twiddle mmu
                    ldu       $01,s
                    lda       <$26,u
                    ora       #$01
                    sta       <$26,u
                    lbsr      L0567

                    pshs      x
                    lda       #$1E                blitlist_erase()
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               cleanup the stack

                    ldu       $01,s
                    lda       <$25,u
                    anda      #$EF
                    sta       <$25,u
                    pshs      u
                    lda       #$1B
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

L0FD2               leas      $03,s
                    rts

cmd_erase
L0FD5               lda       ,y+
                    pshs      y
                    bsr       L0FDE
                    puls      y
                    rts

L0FDE               leas      -$04,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    cmpu      <u0032
                    bcs       L0FF5
                    lda       #$0C
                    ldb       ,s
                    lbsr      L10CE
L0FF5               lda       <$26,u
                    bita      #$01
                    beq       L1052
                    stu       $01,s
                    ldx       #$0548
                    lbsr      L30DE               twiddle mmu
                    ldu       $01,s
                    lda       <$26,u
                    anda      #$10
                    sta       $03,s
                    bne       L1017
                    ldx       #$054C
                    lbsr      L30DE               twiddle mmu
                    ldu       $01,s
L1017               lda       <$26,u
                    anda      #$FE
                    sta       <$26,u
                    lda       $03,s
                    bne       L1033
                    lbsr      L0572

                    pshs      x
                    lda       #$1E                blitlist_erase()
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

L1033               lbsr      L0567

                    pshs      x
                    lda       #$1E                blitlist_erase()
                    sta       <u0021              save the offset
                    ldx       <u0028              set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldu       $01,s
                    pshs      u
                    lda       #$1B
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

L1052               leas      $04,s
                    rts

L1055               fcc       'Avis Durgan'
L1060               fcb       C$NULL


L1061               leas      -$02,s
                    stu       ,s
                    leau      >L1055,pcr          Avis msg
L1069               cmpx      ,s
                    bcc       L107D               leave
                    tst       ,u
                    bne       L1075
                    leau      >L1055,pcr          Avis msg
L1075               lda       ,x
                    eora      ,u+
                    sta       ,x+
                    bra       L1069
L107D               leas      $02,s
                    rts


L1080               fcb       C$BELL,C$NULL

L1082               fcb       C$LF
                    fcc       'Press CTRL-BREAK to quit.'
                    fcb       C$NULL

L109D               fcb       C$LF
                    fcc       'Press ENTER to try again.'
                    fcb       C$NULL

L10B8               fcc       'System error #%u.%s%s'
                    fcb       C$NULL


L10CE               sta       >$0443
L10D1               stb       >$0444
                    lbsr      L2778
                    lbsr      L129A
                    lbsr      L229D
                    bsr       L1118               ring the bell
                    bsr       L1118               ring the bell
                    lbsr      L4E2F

L10E4               leas      >-$00B1,s
                    lbsr      L5B7A               input_edit_on
                    bsr       L1118               ring the bell
                    bsr       L1118               ring the bell
L10EF               leau      >L1082,pcr          quit msg
                    pshs      u
                    leau      >L109D,pcr          try again msg
                    pshs      u
                    clra
                    ldb       >$015B
                    leau      >L10B8,pcr          sys error msg
                    leax      $04,s
                    pshs      b,a
                    pshs      u
L1109               pshs      x
                    lbsr      L3C21
                    leas      $0A,s
                    lbsr      L37F2               message_box()
L1113               leas      >$00B1,s
                    rts

*  I$Write Writes to a file or device
*
* entry:
*       a -> path number
*       x -> start address of the data to write
*       y -> number of bytes to write
*
* exit:
*       y -> number of bytes written
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

L1118               pshs      y                   save current y
                    ldy       #$0002              two bytes bell $07 and null
                    lda       #StdOut             $01
                    leax      >L1080,pcr          load the addr
                    os9       I$Write             send it (ring the bell)
                    puls      y                   retrieve our y
                    rts                           return

L112A               fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00

L1133               fcb       $00

L1134               fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00

L113E               leas      -$02,s
                    stx       ,s
L1142               lda       ,x+
                    bne       L1142
                    tfr       x,d
                    ldx       ,s
                    subd      ,s
                    subd      #$0001
                    leas      $02,s
                    rts

L1152               pshs      u
L1154               lda       ,x+
                    sta       ,u+
                    bne       L1154
                    puls      x
                    rts

* copy routine terminates on null value transfer
***********************************************************
*
* entry:
*       d -> number of bytes to move
*       x -> from address
*       y -> unused
*       u -> to address
*       s -> used as buffer
*
* exit:
*       d -> should contain a zero value
*       y -> unchanged
*       x -> contains address of moved info
*       u -> cleared
*       s -> restored

L115D               leas      -$04,s              make room on stack
                    std       ,s                  save counter value on stack
                    stu       $02,s               save to address on the stack
L1163               lda       ,x+                 copy byte at a time
                    sta       ,u+
                    beq       L1174               if we move a null value were done
                    ldd       ,s                  move the counter back to d
                    subd      #$0001              decrement it
                    std       ,s                  save it again
                    bne       L1163               if not zero loop again
                    clr       ,u                  clear u orig to address
L1174               ldx       $02,s               put destination address in x
                    leas      $04,s               clean up stack
                    rts                           return

* append copy routine checks for data and copies to end
***********************************************************
*
* entry:
*       a ->
*       b ->
*       x -> from address
*       y -> unused
*       u -> to address
*       s -> used as buffer
*
* exit:
*       a -> destroyed
*       b -> unchanged
*       y -> unchanged
*       x -> contains address of moved info
*       u -> end of stored data + 1
*       s -> restored

L1179               pshs      u                   save to address
L117B               lda       ,u+                 get byte and increment
                    bne       L117B               if not null loop again
                    leau      -$01,u              found a null back up to it
L1181               lda       ,x+                 load byte to move and bump pointer
                    sta       ,u+                 stow it and bump to pointer
                    bne       L1181               loop again if it wasn't a null
                    puls      x
                    rts

* Compares 2 sets of input byte for byte
***********************************************************
*
* entry:
*       a -> don't care
*       b -> don't care
*       x -> address 1
*       y -> unused
*       u -> address 2
*       s -> used as buffer
*
* exit:
*       a -> last tested value
*       b -> unchanged
*       y -> unchanged
*       x -> restored
*       u -> restored
*       s -> restored

L118A               pshs      u,x                 save original addresses
L118C               lda       ,x                  get byte of at x
                    suba      ,u+                 compare against byte at u and bump u pointer
                    bne       L1196               not a match exit routine
                    tst       ,x+                 test for null and bump x pointer
                    bne       L118C               not a null loop again
L1196               puls      u,x                 pull originals and
                    rts                           return

* converts 0-9 string to decimal number
* x contains the address of the string

L1199               leas      -$02,s              make a little room on the stack
                    clra                          zero a
                    sta       ,s                  stow it on the stack twice
                    sta       $01,s               so the current stack word = $0000
L11A0               ldb       ,x+                 get the first byte and bump ptr
                    cmpb      #C$SPAC             $20   is it a space
                    beq       L11A0               yes get next char
L11A6               cmpb      #'0                 $30  is it a "0"
                    blo       L11BF               if lower clean up stack and leave
                    cmpb      #'9                 $39 is it a "9"
                    bhi       L11BF               if greater clean up stack and leave
                    subb      #'0                 $30 subtract the ascii value of 0
                    stb       $01,s               save that value
                    lda       #10                 $0A load a with ten
                    ldb       ,s                  load b with number accumulated so far
                    mul                           multiply
                    addb      $01,s               add in the last digit resolved
                    stb       ,s                  save new number
                    ldb       ,x+                 go fetch the next digit
                    bne       L11A6               if not null resolve it
L11BF               lda       ,s                  move the number to a
                    leas      $02,s               clean up stack
                    rts

L11C4               leax      >L1133,pcr          data byte
                    clr       ,x
L11CA               ldu       #$000A
                    bsr       L11FA
                    addb      #$30                add ascii value for 0
                    stb       ,-x
                    tfr       u,d
                    cmpd      #$0000
                    bhi       L11CA
                    rts

L11DC               leax      >L1133,pcr          data byte
                    clr       ,x
L11E2               ldu       #$0010
                    bsr       L11FA
                    addb      #$30                add ascii value for 0
                    cmpb      #$39                compare to ascii value for 9
                    ble       L11EF
                    addb      #$07
L11EF               stb       ,-x
                    tfr       u,d
                    cmpd      #$0000
                    bhi       L11E2
                    rts

L11FA               leas      -$05,s
                    std       ,s
                    stu       $02,s
                    lda       #$10
                    sta       $04,s
                    ldd       #$0000
L1207               lsl       $01,s
                    rol       ,s
                    rolb
                    rola
                    cmpd      $02,s
                    bcs       L1216
                    subd      $02,s
                    inc       $01,s
L1216               dec       $04,s
                    bne       L1207
                    ldu       ,s
                    leas      $05,s
                    rts

L121F               leas      -$0B,s
                    pshs      x,b                 save x and b on entry
                    tfr       u,x                 transfer u to x
                    leau      $04,s
                    lbsr      L1152
                    lbsr      L113E
                    stb       $03,s
                    leau      >L1134,pcr          10 byte data table
                    ldx       #$000A              set x to 10
                    ldb       #$30                set value to store there to ASCII 0
                    lbsr      L2BF6               go set the bytes
                    puls      b                   grab orig b value
                    subb      $02,s
                    bpl       L1242
                    clrb
L1242               clr       b,u
                    leax      $03,s               from address for append
                    lbsr      L1179               append routine
                    tfr       x,u                 to address back in u
                    puls      x                   restore orig x
                    leas      $0B,s               clean up stack
                    rts

* tests for A-Z in accumulator a
* and if found returns a-z
L1250               cmpa      #'A                 $41  compare to Cap A
                    blo       L125A               less than exit
                    cmpa      #'Z                 $5A  compare to cap Z
                    bhi       L125A               greater exit
                    ora       #$20                was between A-Z make lowercase
L125A               rts

cmd_random
L125B               lbsr      L3D7D
                    lda       $01,y
                    suba      ,y++
                    inca
                    bne       L1269
                    tfr       b,a
                    bra       L126E
L1269               lbsr      L5CEF
                    adda      -$02,y
L126E               ldx       #$0432
                    ldb       ,y+
                    abx
                    sta       ,x
                    rts

L1277               tst       ,x
                    bne       L1280
                    ldx       #$0000
                    bra       L1286
L1280               cmpa      ,x+
                    bne       L1277
                    leax      -$01,x
L1286               rts


* upper to lower case string conversion
* address of string passed in u

L1287               tfr       u,x                 move  addr passed in u to x
L1289               lda       ,x                  load a with value
                    beq       L1293               if zero exit if not do an
                    bsr       L1250               upper to lower case conversion
                    sta       ,x+                 stow that value back at x and bump the pointer
                    bra       L1289               go again
L1293               rts                           we found a null so leave

L1294               lbsr      L2311               prompt for joysticks and get results
                    bsr       L129A               branch below discard stdin & read joysticks
                    rts

events_clear
L129A               lbsr      L24D8               go read stdin and discard values ?? clear_key_queue
                    lbsr      L235F               set up call to joysticks            reset_joy

                    ldx       #$0103              load and store the value $0103
                    stx       <u0092              in these memory locations
                    stx       <u0094
                    rts

L12A8               lbsr      L2365               set up call to joysticks
                    lbsr      L24DF               read input and check table
                    rts

L12AF               ldu       <u0092
                    stb       ,u+
                    sta       ,u+
                    stu       <u0092
                    ldx       #$012B
                    cmpx      <u0092
                    bhi       L12C3
                    ldx       #$0103
                    stx       <u0092
L12C3               ldx       <u0092
                    cmpx      <u0094
                    bne       L12CD
                    leau      -$02,u
                    stu       <u0092
L12CD               rts

L12CE               ldd       <u0094
                    cmpd      <u0092
                    bne       L12DA
                    ldx       #$0000
                    bra       L12EF
L12DA               ldx       #$0002
                    leax      d,x
                    stx       <u0094
                    ldx       #$012B
                    cmpx      <u0094
                    bhi       L12ED
                    ldx       #$0103
                    stx       <u0094
L12ED               tfr       d,x
L12EF               rts

L12F0               leas      -$02,s
L12F2               ldd       >$024B
                    std       ,s
                    bsr       L12CE
                    leax      ,x
                    bne       L130A
L12FD               ldd       ,s
                    cmpd      >$024B
                    beq       L12FD
                    lbsr      L12A8
                    bra       L12F2
L130A               lbsr      L1369
                    leas      $02,s
                    rts

L1310               leax      ,x
                    beq       L132B
                    ldb       ,x
                    cmpb      #$01
                    bne       L132B
                    ldu       #$01D9
L131D               ldb       ,u++
                    beq       L132B               leave
                    cmpb      $01,x
                    bne       L131D
                    lda       #$03
                    ldb       -$01,u
                    std       ,x
L132B               rts


L132C               lbsr      L12A8
                    bsr       L12CE
                    tfr       x,d
                    leax      ,x
                    beq       L1341               leave
                    bsr       L1369
                    lda       ,x
                    cmpa      #$01
                    bne       L1342
                    lda       $01,x
L1341               rts

L1342               lda       #$FF
                    rts


L1345               bsr       L132C
                    beq       L1345
                    cmpa      #$FF
                    beq       L1345
                    rts


L134E               bsr       L132C
                    tfr       a,b
                    lda       #$01
                    cmpb      #$0D
                    beq       L1360               leave
                    lda       #$00
                    cmpb      #$1B
                    beq       L1360               leave
                    lda       #$FF
L1360               rts


L1361               lbsr      L129A               events_clear
L1364               bsr       L134E
                    bmi       L1364
                    rts


L1369               lda       ,x
                    cmpa      #$01
                    bne       L1381               leave
                    lda       $01,x
                    cmpa      #$FC
                    bne       L1379
                    lda       #$0D
                    bra       L137F
L1379               cmpa      #$FE
                    bne       L1381               leave
                    lda       #$1B
L137F               sta       $01,x
L1381               rts


* these get accessed for a getstat call
* if a call to the Seek routine contained a value in b
                    fcb       SS.Pos              $05
                    fcb       SS.Size             $02

*        Think these values have no significance
*        and are just junk place holders ??
L1384               fcb       $2E
L1385               fcb       $2E,$0D
L1387               fcb       $00

* Create File - Creates and opens a disk file
*
* entry:
*       a -> access mode (write or update)
*       b -> file attributes
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last byte of the path list + 1;
*            trailing blanks are skipped.
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)


L1388               pshs      x,d
                    bsr       L13CA               delete call first
                    clr       >$015B              clear error code holder
                    puls      x,b,a
                    os9       I$Create
L1394               bcc       L1399               ok then leave
                    lbsr      L15E6               error go to error handler
L1399               rts

* Open Path - Opens a path to the an existing file or device
*             as specified by the path list
* entry:
*       a -> access mode (D S PE PW PR E W R)
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last byte of the path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)


L139A               clr       >$015B              clear error code holder
                    os9       I$Open
                    bcc       L13A5               no error return
                    lbsr      L15E6               error go to error handler
L13A5               rts

* Read  - Reads N bytes from the specified path
* entry:
*       a -> path number
*       x -> number of bytes to read
*       y -> adderess in which to store the data
*
* exit:
*       y -> number of bytes to be read
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

L13A6               clr       >$015B              clear error code holder
                    os9       I$Read
                    bcc       L13B5               ok leave
                    lbsr      L15E6               error go to error handler
                    ldy       #$0000              clr y
L13B5               tfr       y,d                 number of bytes read
                    rts

* Write - Writes to a file or device
* entry:
*       a -> path number
*       x -> starting address of data to write
*       y -> number of bytes to be written
*
* exit:
*       y -> number of bytes written
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

L13B8               clr       >$015B              clear error code holder
                    os9       I$Write
                    bcc       L13C7               ok leave
                    lbsr      L15E6               error go to error handler
                    ldy       #$0000              clr y
L13C7               tfr       y,d                 number of bytes written
                    rts

* Delete File - deletes a specific disk file
* entry:
*       x -> address of path list
*
* exit:
*       x -> address of path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

L13CA               clr       >$015B              clear error code holder
                    os9       I$Delete
                    bcc       L13D5               ok leave
                    lbsr      L15E6               error go to error handler
L13D5               rts

* Close Path - terminates an I/O path
* entry:
*       a -> path number
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

L13D6               clr       >$015B              clear error code holder
                    os9       I$Close
                    bcc       L13E1               ok leave
                    lbsr      L15E6               error go to error handler
L13E1               rts

* Seek - repositions the file pointer
*        seeks to address 0 is the same as rewind
* entry:
*       a -> path number
*       x -> most significant 16 bits of the desired file position
*       u -> least significant 16 bits of the desired file position
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

* I am assuming that a clear b signals a rewind

L13E2               clr       >$015B              clear error code holder
                    tstb                          is there a value in b?
                    bne       L13F6               if so do other processing first
                    os9       I$Seek              if b=0 do the seek
                    bcc       L141E               no error leave
L13ED               lbsr      L15E6               error go to error handler
                    ldy       #$0000              clear y but why ?
                    bra       L141E               and now leave

* if b contained value use it
* to determine seek from current pos or end of file
*
* Get status - Returns the status of a file or device
*              Wildcard call exit status differs based on cal code
* entry:
*       a -> path number
*       b -> function code (SS.Size or SS.Pos)
*
* exit:
*       x -> most significant 16 bits of the current file size
*       u -> least significant 16 bits of the current file size
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

L13F6               stx       <u0084              stow current MSW value
                    stu       <u0086              stow current LSW value
                    leau      >L1381,pcr          points to rts address above values
                    ldb       b,u                 use value of b to point to getsta param
                    os9       I$GetStt            make the getsta call
                    bcs       L13ED               error go to error handler
                    pshs      a                   save our path number

                    tfr       u,d                 resolve LSW first
                    addd      <u0086              add value passed in to getsta value
                    tfr       d,u                 return it to u

                    tfr       x,d                 resolve MSW next

                    adcb      #$00                don't think these do anything sometimes used
                    adca      #$00                to test for before begin of file no test of results

                    addd      <u0084              add value passed in to getsta value
                    tfr       d,x                 return it to u

                    puls      a                   retrieve the path number
                    os9       I$Seek              make the seek
                    bcs       L13ED               error go to error handler
L141E               rts

* Duplicate path  -  Returns a synonymous path number
* entry:
*       a -> old path number (one to be duplicated)
*
* exit:
*       a ->new path number (if no error)
*
* error:
*       CC -> Carry set on error
*       b  -> error code if any

L141F               clr       >$015B              clear error code holder
                    os9       I$Dup
                    bcc       L142A               good dup ? leave
                    lbsr      L15E6               error go to error handler
L142A               rts



L142B               leas      <-$22,s             make room on the stack
*                          2 bytes for y and 32 for buffer
                    sty       ,s                  save the current y
                    clra                          zero a
                    sta       ,y                  clear at y
                    sta       <u0077              clear open path counter
                    leax      >L1385,pcr          load x with address to store path num
                    lbsr      L155F               open path
                    bcs       L145D               error on open go close the path
                    sta       <u0078              save open path number

                    ldb       #SS.DevNm           Returns a device name $0E
                    leax      $02,s               address of 32 byte buffer to hold name
                    os9       I$GetStt
                    bcs       L145D               close open path
                    ldy       ,s
                    ldb       #'/                 slash $2F
                    stb       ,y+
                    ldd       ,x++
                    andb      #$7F
                    std       ,y++
                    ldb       #'/                 slash $2F
                    stb       ,y+
                    clr       ,y
L145D               lbsr      L1572               close open path
                    leas      <$22,s              clean up stack
                    rts


* lib_get_disk (state_info.c)
L1464               leas      -$0A,s
                    leay      ,s
                    bsr       L142B               opens a path and gets device name
                    leax      $01,s
                    ldd       #$0002              number of bytes to copy
                    lbsr      L115D               copy routine
                    tfr       x,u                 move copy destination back to u
                    lbsr      L1287               upper to lower string conversion
                    ldd       ,u                  load d with our converted value
                    subb      #'0                 #$30 subtract ascii zero from b (second letter)
                    cmpa      #'d                 #$64  test first letter for a d
                    beq       L1481               if it is stow the difference between 0 and orig b
                    orb       #$10                else add $10 to b then save it
L1481               stb       $03,u               save value of b in u
                    leas      $0A,s               clean up stack
                    rts

L1486               leas      >-$00C2,s
                    stu       ,s
                    clra
                    sta       <u0077
                    leax      >$00A1,s
                    sta       ,x
                    stx       <u0079
                    leax      >L1385,pcr          load x with address to store path number
                    lbsr      L155F               open path
                    sta       <u0078              save open path number
                    leax      >$00A2,s
                    lbsr      L153A
L14A7               ldd       <u0081
                    std       <u007B
                    lda       <u0083
                    sta       <u007D
                    ldx       #$0081              address of values to compare
                    ldy       #$007E              address of values to compare
                    lbsr      L1553               call compare 3 byte routine
                    beq       L14F4               if equal close the path
                    leax      >L1384,pcr          data byte that is init to period
                    lbsr      L157C               change dir routine
                    lbsr      L1572               close open path
                    bcs       L1510
                    leax      >L1385,pcr          load x with address to store path num
                    lbsr      L155F               open path
                    leax      >$00A2,s
                    bsr       L153A
L14D4               leax      >$00A2,s
                    lda       <u0078
                    lbsr      L1569
                    bcs       L1510
                    leax      <$1D,x              address of values to compare
                    ldy       #$007B              address of values to compare
                    bsr       L1553               call 3 byte compare routine
                    bne       L14D4
                    leax      >$00A2,s
                    bsr       L151D
                    bcs       L1510
                    bra       L14A7
L14F4               lbsr      L1572               close open path
                    leay      >$00A2,s
                    lbsr      L142B
                    leax      >$00A2,s
                    bsr       L151D
                    bcs       L1510
                    ldu       ,s
                    ldx       <u0079
                    lbsr      L1152
                    lbsr      L157C               change dir routine
L1510               ldu       ,s                  load u for call to string conversion
                    lbsr      L1287               upper to lower string conversion
                    lbsr      L1572               close open path
                    leas      >$00C2,s
                    rts

L151D               os9       F$PrsNam
                    bcs       L1539
                    ldx       <u0079
L1524               lda       ,-y
                    anda      #$7F
                    sta       ,-x
                    decb
                    bne       L1524
                    cmpa      #$2F
                    beq       L1537
                    lda       #$2F
                    sta       ,-x
                    andcc     #$FE
L1537               stx       <u0079
L1539               rts

L153A               bsr       L1569
                    ldd       <$1D,x
                    std       <u007E
                    lda       <$1F,x
                    sta       <u0080
                    bsr       L1569
                    ldd       <$1D,x
                    std       <u0081
                    lda       <$1F,x
                    sta       <u0083
                    rts

* compares three bytes
* called with address of values to compare in x & y
L1553               ldd       ,x++
                    cmpd      ,y++
                    bne       L155E               leave not equal
                    lda       ,x
                    cmpa      ,y
L155E               rts

L155F               lda       #READ.+DIR.         $81
                    lbsr      L139A               Open path routine
                    bcs       L1568               if error leave
                    inc       <u0077              increment open file counter
L1568               rts

L1569               lda       <u0078              load path number
                    ldy       #$0020              number of bytes to read
                    lbra      L13A6               Read routine
L1572               lda       <u0078              load path number
                    lbsr      L13D6               Close path routine
                    bcs       L157B               leave
                    clr       <u0077              clear open file counter
L157B               rts

L157C               clr       >$015B
                    lda       #READ.+DIR.         $81
                    os9       I$ChgDir
                    bcc       L1589               return on successful change
                    lbsr      L15E6               error go to error handler
L1589               rts

L158A               lda       $05,s
                    ldy       $02,s
                    lbsr      L139A               Open path routine
                    bcs       L1598               leave
                    ldx       $06,s
                    bsr       L159C
L1598               lda       >$015B
                    rts

L159C               clr       >$015B
                    ldb       #$0F
                    ldy       #$0010
                    os9       I$GetStt
                    bcc       L15AC               leave
                    bsr       L15E6               error go to error handler
L15AC               rts

L15AD               leas      <-$14,s
                    leax      ,s
                    bsr       L159C
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

*  error handler for os9 calls
L15E6               pshs      cc
                    cmpb      #E$PNNF             error $D8 path name not found
                    bne       L15EF               any other error
                    lda       #$FF
                    clrb
L15EF               stb       >$015B              store error
                    puls      cc
                    rts

L15F5               leas      -$05,s
                    stu       ,s
                    clra
                    sta       $03,s
                    inca
                    sta       $02,s
                    sta       $04,s
                    lda       >$01D7
                    cmpa      $04,u
                    bcs       L1612
                    ldb       <$26,u
                    bitb      #$08
                    bne       L1612
                    inca
                    sta       $04,u
L1612               lbsr      L167C
                    tsta
                    beq       L1631
                    lbsr      L0885
                    tsta
                    bne       L1631

                    pshs      u
                    lda       #$03                obj_chk_control()
                    sta       <u0021              save the offset
                    ldx       <u0028              set up the remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldu       ,s
                    lda       <u005C
                    bne       L1679
L1631               lda       $03,s
                    bne       L1643
                    dec       $03,u
                    dec       $04,s
                    bne       L1612
                    inc       $03,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1612
L1643               cmpa      #$01
                    bne       L1657
                    inc       $04,u
                    dec       $04,s
                    bne       L1612
                    inc       $03,s
                    inc       $02,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1612
L1657               cmpa      #$02
                    bne       L1669
                    inc       $03,u
                    dec       $04,s
                    bne       L1612
                    inc       $03,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1612
L1669               dec       $04,u
                    dec       $04,s
                    bne       L1612
                    clr       $03,s
                    inc       $02,s
                    lda       $02,s
                    sta       $04,s
                    bra       L1612
L1679               leas      $05,s
                    rts

L167C               clra
                    ldb       $03,u
                    addb      <$1C,u
                    bcs       L16A2
                    cmpb      #$A0
                    bhi       L16A2
                    ldb       $04,u
                    cmpb      #$A7
                    bhi       L16A2
                    incb
                    cmpb      <$1D,u
                    bcs       L16A2
                    decb
                    cmpb      >$01D7
                    bhi       L16A1
                    ldb       <$26,u
                    bitb      #$08
                    beq       L16A2
L16A1               inca
L16A2               rts

L16A3               fcb       $80,$40,$20,$10,$08,$04,$02,$01


cmd_set
L16AB               lda       ,y+
                    bra       L16D5

cmd_reset
L16AF               lda       ,y+
                    bra       L16DC

cmd_toggle
L16B3               lda       ,y+
                    bra       L16E4

cmd_set_v
L16B7               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    bra       L16D5

cmd_reset_v
L16C1               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    bra       L16DC

cmd_toggle_v
L16CB               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    bra       L16E4
L16D5               bsr       L16F0
                    ora       ,x
                    sta       ,x
                    rts

L16DC               bsr       L16F0
                    coma
                    anda      ,x
                    sta       ,x
                    rts

L16E4               bsr       L16F0
                    eora      ,x
                    sta       ,x
                    rts
L16EB               bsr       L16F0
                    anda      ,x
                    rts

L16F0               tfr       a,b
                    leax      >L16A3,pcr          data table above
                    anda      #$07
                    lda       a,x
                    lsrb
                    lsrb
                    lsrb
                    ldx       #$01AF
                    abx
                    rts


L1702               leas      -$05,s
                    ldb       <$27,u
                    pshs      b,a
                    ldx       <u0030
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
                    lbsr      L2F4C
                    leas      $06,s
                    sta       ,s
                    bne       L173A
                    sta       <$21,u
                    sta       <$22,u
                    lda       <$28,u
                    lbsr      L16D5
                    bra       L17A7
L173A               lda       <$29,u
                    cmpa      #$FF
                    bne       L1746
                    clr       <$29,u
                    bra       L17A2
L1746               lda       <$25,u
                    bita      #$40
                    beq       L1790
L174D               lbsr      L3D7D
                    lda       #$09
                    lbsr      L5CEF
                    sta       <$21,u
                    beq       L174D
                    ldb       $03,s
                    subb      $01,s
                    bcc       L1761
                    negb
L1761               stb       $04,s
                    ldb       $04,u
                    subb      $02,s
                    bcc       L176A
                    negb
L176A               clra
                    addb      $04,s
                    adca      #$00
                    lsra
                    rorb
                    incb
                    stb       $04,s
                    lda       <$1E,u
                    sta       <$29,u
                    cmpa      $04,s
                    bcc       L17A7
L177E               lbsr      L3D7D
                    lda       $04,s
                    lbsr      L5CEF
                    cmpa      <$1E,u
                    bcs       L177E
                    sta       <$29,u
                    bra       L17A7
L1790               lda       <$29,u
                    beq       L17A2
                    clr       <$29,u
                    suba      <$1E,u
                    bcs       L17A7
                    sta       <$29,u
                    bra       L17A7
L17A2               lda       ,s
                    sta       <$21,u
L17A7               leas      $05,s
                    rts


L17AA               fcb       $01

L17AB               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

L17CA               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

L17E9               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00

* save_disk_check (state_info.c)
L1829               fcc       'save'
                    fcb       C$NULL

* save_disk_check (state_info.c)
L182E               fcc       'restore'
                    fcb       C$NULL

L1836               fcc       ' - %s'
                    fcb       C$NULL


* state_get_info strings (state_info.c)
L183C               fcc       'How would you like to describe this saved game?'
                    fcb       C$LF,C$LF,C$NULL

* save_disk_check strings (state_info.c)
L186E               fcc       'Please put your save game'
                    fcb       C$LF
                    fcc       'disk in drive %s.'
                    fcb       C$LF,C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to not'
                    fcb       C$LF
                    fcc       '%s a game.'
                    fcb       C$NULL

* state_get_path strings (state_info.c)
L18D7               fcc       '(For example, "/d1" or "/h0/savegame")'
                    fcb       C$NULL

* state_get_path strings (state_info.c)
L18FE               fcc       '         SAVE GAME'
                    fcb       C$LF,C$LF
                    fcc       'On which disk or in which directory do you '
                    fcc       'wish to save this game?'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcb       C$NULL

* state_get_path strings (state_info.c)
L195B               fcc       '        RESTORE GAME'
                    fcb       C$LF,C$LF
                    fcc       'On which disk or in which directory is the '
                    fcc       'game that you want to restore?'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
L19C1               fcc       'Use the arrow keys to move'
                    fcb       C$LF
                    fcc       '     the pointer to your name.'
                    fcb       C$LF
                    fcc       'Then press ENTER.'
                    fcb       C$LF
                    fcb       C$NULL

* state_get_path strings (state_info.c)
L1A0E               fcc       'There is no directory named:'
                    fcb       C$LF
                    fcc       '%s.'
                    fcb       C$LF
                    fcc       'Press ENTER to try again.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to cancel.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
L1A65               fcc       'There are no games to'
                    fcb       C$LF
                    fcc       'restore in:'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
L1AA5               fcc       'Use the arrow keys to select the slot '
                    fcc       'in which you wish to save the game. '
                    fcc       'Press ENTER to save in the slot, '
                    fcc       'CTRL-BREAK to not save a game.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
L1B2F               fcc       'Use the arrow keys to select the game which you '
                    fcc       'wish to restore. Press ENTER to restore the game, '
                    fcc       'CTRL-BREAK to not restore a game.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
L1BB3               fcc       '   Sorry, this disk is full.'
                    fcb       C$LF
                    fcc       'Position pointer and press ENTER'
                    fcb       C$LF
                    fcc       '    to overwrite a saved game'
                    fcb       C$LF
                    fcc       'or press CTRL-BREAK and try again'
                    fcb       C$LF
                    fcc       '    with another disk.'
                    fcb       C$LF
                    fcb       C$NULL



* state_get_info  (state_info.c)
L1C49               leas      -$02,s
                    clr       $01,s
                    lda       >$05B9              input_edit_disabled
                    sta       ,s
                    lbsr      L5B7A               input_edit_on
                    lbsr      L464E
                    lbsr      L47AA

                    ldd       #$000F
                    lbsr      L45BA

                    ldd       $04,s
                    pshs      d
                    lbsr      L1D10
                    leas      $02,s
L1C6A               beq       L1CAB
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L1CBD               save_disk_check
                    leas      $02,s
                    beq       L1CAB
                    ldd       $04,s
                    pshs      b,a
                    lbsr      L1DE0
                    leas      $02,s
                    sta       $01,s
                    beq       L1CAB
                    lda       $05,s
                    cmpa      #$73
                    bne       L1CA2
                    lda       >L41E5,pcr          FILE struct datablock ???
                    bne       L1CA2
                    leax      >L17CA,pcr          31 byte data block
                    leau      >L183C,pcr          describe game msg
                    lbsr      L1D83
                    tsta
L1C9C               bne       L1CA2
                    clr       $01,s
                    bra       L1CAB
L1CA2               leax      >L17E9,pcr          64 byte data block
                    ldb       $01,s
                    lbsr      L4430
L1CAB               lbsr      L47BE
                    lbsr      L4663
                    lda       ,s
                    beq       L1CB8
                    lbsr      L5B69
L1CB8               lda       $01,s
                    leas      $02,s
                    rts

* save_disk_check
* passed in  state_type for checking
L1CBD               leas      >-$00A5,s
                    lda       #$01
                    sta       ,s                  tempa2
                    leau      >$00A1,s
                    lbsr      L1464               lib_get_disk
                    lda       >L4423,pcr          save_drive
                    cmpa      >$00A4,s
                    bne       L1D09               clean up and return
                    cmpa      #$10
                    bcc       L1D09               clean up and return
                    lbsr      L4BBA               volumes_close
                    leau      >L1829,pcr          load the "save" string
                    lda       >$00A8,s            load the state_type passed to function
                    cmpa      #'s                 is it an 's' for save? $73
                    beq       L1CED               it was s so don't load the restore string
                    leau      >L182E,pcr          restore string
L1CED               pshs      u                   push state_type string on stack
                    leau      >$00A3,s            address of out temp buffer
                    pshs      u                   push on stack
                    leau      >L186E,pcr          save game disk in drive msg
                    leax      $05,s
                    pshs      u
                    pshs      x
                    lbsr      L3C21               ???
                    leas      $08,s
                    lbsr      L37F2               message_box()
                    sta       ,s
L1D09               lda       ,s
                    leas      >$00A5,s
                    rts

L1D10               leas      >-$00C8,s
                    lda       >L17AB,pcr          31 byte data block
                    bne       L1D23
                    leau      >L17AB,pcr          31 byte data block
                    lbsr      L1486
                    leas      ,s
L1D23               tst       >L41E5,pcr          FILE struct data block ???
                    bne       L1D7E
L1D29               leau      >L18D7,pcr          example msg
                    pshs      u
                    leau      >L18FE,pcr          SAVE GAME msg
                    ldb       >$00CD,s
                    cmpb      #$73
                    beq       L1D3F
                    leau      >L195B,pcr          RESTORE GAME msg
L1D3F               leax      $02,s
                    pshs      u
                    pshs      x
                    lbsr      L3C21
                    leas      $06,s
                    leax      >L17AB,pcr          31 byte data block
                    lbsr      L1D83
                    tsta
                    beq       L1D7E
                    leau      >L17AB,pcr          31 byte data block  string to convert
                    lbsr      L1287               upper to lower string conversion
                    pshs      u
                    lbsr      L4478
                    leas      $02,s
                    bne       L1D7E
                    leau      >L17AB,pcr          31 byte data block
                    pshs      u
                    leau      >L1A0E,pcr          No Directory msg
                    leax      $02,s
                    pshs      u
                    pshs      x
                    lbsr      L3C21
                    leas      $06,s
                    lbsr      L37F2               message_box()
                    bne       L1D29
L1D7E               leas      >$00C8,s
                    rts

L1D83               leas      -$03,s
                    stx       ,s
                    ldd       #$0001
                    pshs      d
                    ldd       #$001F
                    pshs      d
                    ldd       #$0000
                    pshs      d
                    pshs      u
                    lbsr      L3868               message_box_draw
                    leas      $08,s
                    ldd       #$0000
                    pshs      d
                    lda       >$0178
                    ldb       >$0177
                    std       <u0040
                    ldb       >$0179
                    decb
                    pshs      d
                    ldb       >$0177
                    pshs      d
                    lbsr      L48A1
                    leas      $06,s
                    lbsr      L464E
                    lda       #$0F
                    clrb
                    lbsr      L45BA
                    ldb       #$1F
                    ldx       ,s
                    lbsr      L5613
                    sta       $02,s
                    lbsr      L4663
                    lbsr      L3997               cmd_close_window
                    lda       #$01
                    ldb       $02,s
                    cmpb      #$0D
                    beq       L1DDB
                    clra
L1DDB               ldx       ,s
                    leas      $03,s
                    rts

L1DE0               leas      >-$0256,s
                    lda       #$01
                    sta       >X0154              flag for extended table lookup
                    lda       #$06
                    sta       >$0547
                    ldd       #$0000
                    sta       >$024C,s
                    std       >$024E,s
                    std       >$0250,s            state.block_y1
                    lda       >$0259,s
                    suba      #$72
                    beq       L1E07
                    lda       #$0C
L1E07               std       >$024A,s
L1E0B               cmpb      #$0C
                    lbcc      L1EB3
                    leau      >$0252,s            state.string
                    pshs      u
                    incb
                    pshs      b,a
                    ldb       >$025D,s
                    lda       >$024E,s
                    cmpb      #$73
                    bne       L1E2A
                    lda       >$024F,s            state.block_x1??
L1E2A               ldb       #$20
                    mul
                    leau      $06,s
                    leau      d,u
                    pshs      u
                    lbsr      L209C
                    leas      $06,s
                    beq       L1EA8
                    ldb       >$0259,s
                    cmpb      #$73
                    bne       L1E74
                    ldd       >$0252,s            state.string
                    cmpd      >$024E,s
                    bhi       L1E5A
                    bcs       L1EA8
                    ldd       >$0254,s
                    cmpd      >$0250,s            state.block_y1
                    bls       L1EA8
L1E5A               ldd       >$0254,s
                    std       >$0250,s            state.block_y1
                    ldd       >$0252,s            state.string
                    std       >$024E,s
                    lda       >$024B,s
                    sta       >$024C,s
                    bra       L1EA8
L1E74               ldd       >$0252,s            state.string
                    cmpd      >$024E,s
                    bhi       L1E8C
                    bcs       L1EA4
                    ldd       >$0254,s
                    cmpd      >$0250,s            state.block_y1
                    bls       L1EA4
L1E8C               ldd       >$0254,s
                    std       >$0250,s            state.block_y1
                    ldd       >$0252,s            state.string
                    std       >$024E,s
                    lda       >$024A,s
                    sta       >$024C,s
L1EA4               inc       >$024A,s
L1EA8               inc       >$024B,s
                    ldb       >$024B,s
                    lbra      L1E0B
L1EB3               lda       >$024A,s
                    bne       L1EDD
                    lda       >L41E5,pcr          FILE struct data block
                    bne       L1EE5
                    leau      >L17AB,pcr          31 byte data block
                    pshs      u
                    leau      >L1A65,pcr          No games to restore
                    leax      >$0184,s
                    pshs      u
                    pshs      x
                    lbsr      L3C21
                    leas      $06,s
                    lbsr      L37F2               message_box()
                    clra
                    lbra      L2091
L1EDD               lda       >L41E5,pcr          FILE struct datablock ???
                    lbeq      L1F65
L1EE5               lda       >L17AA,pcr          data byte
                    bne       L1F56
                    leax      >L41E5,pcr          FILE struct datablock
                    leau      >L17CA,pcr          31 byte data block
                    lbsr      L1152
                    clrb
                    stb       >$024B,s
L1EFB               cmpb      #$0C
                    bcc       L1F1F
                    leau      >L17CA,pcr          31 byte data block
                    lda       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    leax      $01,x
                    lbsr      L118A               compare routine
                    tsta                          test what was left in a
                    lbeq      L208F               if it was a 0 then branch
                    inc       >$024B,s
                    ldb       >$024B,s
                    lbra      L1EFB
L1F1F               lda       >$0259,s
                    cmpa      #$73
                    bne       L1F4A
                    clrb
                    stb       >$024B,s
L1F2C               cmpb      #$0C
                    bcc       L1F4A
                    lda       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    ldb       ,x
                    lda       $01,x
                    lbeq      L208F
                    inc       >$024B,s
                    ldb       >$024B,s
                    lbra      L1F2C
L1F4A               lda       >$0259,s
                    suba      #$72
                    lbeq      L2091
                    bra       L1F65
L1F56               leau      >$0182,s
                    lbsr      L1464               lib_get_disk
                    lda       >$0185,s
                    sta       >L4423,pcr          save_drive
L1F65               ldd       #$0001
                    pshs      b,a
                    ldd       #$0022
                    pshs      b,a
                    ldb       #$05
                    stb       >$0251,s
                    addb      >$024E,s
                    pshs      b,a
                    ldb       >L41E5,pcr          FILE struct datablock
                    beq       L1F91
                    leau      >L1BB3,pcr          disk full msg
                    ldb       >L17AA,pcr          data byte
                    beq       L1F65
                    leau      >L19C1,pcr          arrow key message
                    bra       L1F65
L1F91               lda       >$025F,s
                    leau      >L1AA5,pcr          slot select msg
                    cmpa      #$73
                    beq       L1FA1
                    leau      >L1B2F,pcr          game select msg
L1FA1               pshs      u
                    lbsr      L3868               message_box_draw
                    leas      $08,s
                    lda       >$024D,s
                    adda      >$0176
                    sta       >$024D,s
                    clra
                    sta       >L17AA,pcr          data byte
                    sta       >$024B,s
L1FBC               cmpa      >$024A,s
                    bcc       L1FF0
                    adda      >$024D,s
                    ldb       >$0177
                    std       <u0040
                    lda       >$024B,s
                    ldb       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    leax      $01,x
                    pshs      x
                    leax      >L1836,pcr          dash percent s
                    pshs      x
                    lbsr      L3C34
                    leas      $04,s
                    inc       >$024B,s
                    lda       >$024B,s
                    lbra      L1FBC
L1FF0               lda       >$024C,s
                    sta       >$024B,s
                    adda      >$024D,s
                    lbsr      L2107
L1FFF               lbsr      L12F0
                    stx       ,s
                    lda       ,x
                    cmpa      #$01
                    bne       L2041
                    lda       $01,x
                    cmpa      #$0D
                    bne       L2037
                    lbsr      L3997               cmd_close_window
                    leau      >L17CA,pcr          31 byte data block
                    lda       >L41E5,pcr          FILE struct data block ???
                    beq       L2021
                    leau      >L41E5,pcr          FILE struct datablock ???
L2021               lda       >$024B,s
                    ldb       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    pshs      x
                    leax      $01,x
                    lbsr      L1152
                    puls      x
                    bra       L208F
L2037               cmpa      #$1B
                    bne       L1FFF
                    lbsr      L3997               cmd_close_window
                    clra
                    bra       L2091
L2041               cmpa      #$02
                    bne       L1FFF
                    lda       >$024D,s
                    adda      >$024B,s
                    ldb       $01,x
                    cmpb      #$01
                    bne       L206E
                    lbsr      L2112
                    lda       >$024B,s
                    bne       L2060
                    lda       >$024A,s
L2060               deca
                    sta       >$024B,s
                    adda      >$024D,s
                    lbsr      L2107
                    bra       L1FFF
L206E               cmpb      #$05
                    bne       L1FFF
                    lbsr      L2112
                    lda       >$024B,s
                    inca
                    cmpa      >$024A,s
                    bne       L2081
                    clra
L2081               sta       >$024B,s
                    adda      >$024D,s
                    lbsr      L2107
                    lbra      L1FFF
L208F               lda       ,x
L2091               clr       >X0154              flag for extended table lookup
                    clr       >$0547
                    leas      >$0256,s
                    rts

L209C               leas      <-$48,s
                    ldu       <$4A,s
                    ldb       <$4D,s
                    stb       ,u
                    leax      ,s
                    lbsr      L4430
                    lda       #$01
                    lbsr      L139A               Open path routine
                    bcs       L20FD
                    sta       <$47,s
                    lbsr      L15AD
                    ldy       <$4E,s
                    stx       ,y++
                    std       ,y
                    ldy       #$001F
                    ldx       <$4A,s
                    leax      $01,x
                    lda       <$47,s
                    lbsr      L13A6               Read routine
                    ldx       #$0000
                    ldu       #$0024
                    lda       <$47,s
                    ldb       #$01
                    lbsr      L13E2
                    ldy       #$0007
                    leax      <$40,s
                    lda       <$47,s
                    lbsr      L13A6               Read routine
                    lda       <$47,s
                    lbsr      L13D6               Close path routine
                    ldu       #$01CF
                    lbsr      L118A               compare routine
                    bne       L20FD               not a match
                    lda       #$01
                    bra       L2103
L20FD               clra
                    ldu       <$4A,s
                    sta       $01,u
L2103               leas      <$48,s
                    rts

L2107               ldb       >$0177
                    std       <u0040
                    lda       #$1A
                    lbsr      L4734
                    rts


L2112               ldb       >$0177
                    std       <u0040
                    lda       #$20
                    lbsr      L4734
                    rts

tOC                 fcc       'toc'
                    fcb       C$NULL

WordsTok            fcc       'words.tok'
                    fcb       C$NULL

Object              fcc       'object'
                    fcb       C$NULL


L2132               ldd       #$E000              looks like our block 8 address boundary?
                    std       <$002E              this is u002E slot ?

                    ldd       #$4040              load the color for sbuff_fill()
                    pshs      d                   stuff it on the stack
                    lda       #$18                offset for sbuff_fill()
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    lbsr      L129A               events_clear
                    lbsr      L4CD8
                    lda       #$0F
                    clrb
                    lbsr      L45BA
                    lbsr      L5BAD
                    lbsr      L1294
                    leau      >tOC,pcr
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0089
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L4BDB
                    leas      $08,s
                    ldu       <u0089
                    clra
                    ldb       ,u+
                    stb       >$05ED
                    tfr       d,x
                    stu       <u0089
L217F               ldd       <u0089
                    addd      ,u
                    std       ,u++
                    leax      -$01,x
                    bne       L217F
                    leau      >WordsTok,pcr
                    ldd       #$01AB
                    pshs      b,a
                    ldd       #$01A9
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
L219C               pshs      u
                    lbsr      L4BDB
                    leas      $08,s
                    lbsr      L2529
                    lbsr      L5D0D
                    lbsr      L506C
                    lbsr      L34CA
                    bsr       L21CC
                    clrb
                    lbsr      L2571
                    ldd       <u004F
                    std       <u004D
                    ldd       <u0055
                    std       <u0053
                    lda       >$01B0
                    ora       #$40
                    sta       >$01B0
                    lbsr      L523B
                    lbsr      L5265
                    rts

L21CC               leas      -$01,s
                    leau      >Object,pcr
                    ldx       <u0038
                    beq       L21DA
                    leax      -$03,x
                    stx       <u0038
L21DA               ldd       #$0000
                    pshs      b,a
                    ldd       #$0038
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L4BDB
                    leas      $08,s
                    ldx       <u0038
                    ldd       <u0066
                    leau      d,x
                    lbsr      L1061
                    ldd       <u0066
                    subd      #$0003
                    std       <u003A
                    ldu       <u0038
                    lda       $02,u
                    sta       ,s
                    lda       $01,u
                    ldb       ,u
                    leau      $03,u
                    stu       <u0038
                    leau      d,u
                    stu       <u003C
                    ldu       <u0038
L2211               cmpu      <u003C
                    bcc       L2222
                    lda       $01,u
                    ldb       ,u
                    addd      <u0038
                    std       ,u
                    leau      $03,u
                    bra       L2211
L2222               inc       ,s
                    ldu       <u0030
                    bne       L2241
                    lda       ,s
                    ldb       #$2B
                    mul
                    std       <u0034
                    lbsr      L2730
                    stu       <u0030              this is where u0030 is set
                    ldd       <u0034
                    leau      d,u
                    stu       <u0032
                    leau      <-$2B,u
                    stu       <u0036
                    ldu       <u0030              load address of values to clear
L2241               ldx       <u0034              load number of bytes to clear
                    clrb                          set the value to store to 00
                    lbsr      L2BF6               go clear them
                    clra
L2248               cmpa      ,s
                    bcc       L2254
                    sta       $02,u
                    leau      <$2B,u
                    inca
                    bra       L2248
L2254               ldu       #$0432              load address of the values to clear
                    ldx       #$0100              load number of bytes to clear (256)
                    clrb                          set the value to store there to 00
                    lbsr      L2BF6               go clear them
                    ldu       #$01AF              load address of the values to clear
                    ldx       #$0020              load the number of bytes to clear (64)
                    lbsr      L2BF6               go clear them
                    lbsr      L0952               self contained call to clear 50 bytes at 05BA
                    bsr       L229D
                    lbsr      L057D
                    lda       #$09
                    sta       >$0446
                    lda       >$0553
                    sta       >$044C
                    lda       #$29
                    sta       >$044A
                    lda       >$01AF
                    ora       #$04
                    sta       >$01AF
                    clra
                    sta       >X0241              state.pic_num
                    sta       >X01AD              state.block_state
                    inca
                    sta       >$0251
                    tst       >$0173
                    bne       L229A
                    sta       >$0448
L229A               leas      $01,s
                    rts

L229D               lbsr      L2533
                    lbsr      L5D0D
                    lbsr      L506C
                    lbsr      L34CA
                    rts


L22AA               fcb       $00                 selected joystick x value set in L23DA
                    fcb       $00                 selected joystick y value set in L23DA
                    fcb       $00                 never set but used at L2481


L22AD               fcc       'If you have a joystick, and'
                    fcb       C$LF
                    fcc       'wish to use it, press its'
                    fcb       C$LF
                    fcc       'button.'
                    fcb       C$LF
                    fcc       'If not, press CTRL-BREAK to'
                    fcb       C$LF
                    fcc       'continue.'
                    fcb       C$NULL

cmd_init_joy
L2311               lda       <u0098
                    eora      #$01
                    sta       <u0098
                    beq       L235B
                    clr       <u0099
L231B               leau      >L22AD,pcr          joystick message
                    ldd       #$0000              load the 4 arguments for message_box_draw
                    pshs      d
                    ldd       #$0020
                    pshs      d
                    ldd       #$0000
                    pshs      d
                    pshs      u                   pointer to the string
                    lbsr      L3868               message_box_draw
                    leas      $08,s
                    ldb       #$00
L2337               stb       <u0097
                    lbsr      L132C
                    ldb       >$0541              joystick button status
                    bne       L2350
L2341               ldb       <u0097
                    eorb      #$01
                    cmpa      #$1B
                    bne       L2337
                    clr       <u0098
                    lbsr      L3997               cmd_close_window
                    bra       L235B
L2350               lbsr      L3997               cmd_close_window
L2353               lbsr      L23F3
                    lda       >$0541              joystick button status
                    bne       L2353
L235B               lbsr      L129A               events_clear
                    rts

*  set up calls to joysticks
reset_joy
L235F               clr       >$0541              clear joystick button status
                    clr       >$0542              clear memory location
L2365               lda       <u0098              get value here
                    lbeq      L23D9               is zero branch leave and return
                    ldb       >$0547              get mem location value
                    beq       L23A7               branch to set up joystick call
                    ldx       <u009C
                    bne       L2394
                    ldx       <u009A
                    bne       L2394
                    clra
L2379               orcc      #IntMasks           $50
                    addd      >$024B
                    std       <u009C
                    ldd       >$0249
                    andcc     #^IntMasks          $AF
                    bcc       L238A
                    addd      #$0001
L238A               std       <u009A
                    bne       L2394
                    ldd       <u009C
                    bne       L2394
                    inc       <u009D
L2394               orcc      #IntMasks           $50
                    ldx       >$024B
                    ldd       >$0249
                    andcc     #^IntMasks          $AF
                    cmpd      <u009A
                    bhi       L23A7
                    cmpx      <u009C
                    bls       L23D7

L23A7               ldd       #$0000              clear d
                    std       <u009A              clear mem location
                    std       <u009C              clear mem location
                    bsr       L23DA               get joystick x,y status
                    lbsr      L2481               check values and mostly waste time see note there
                    ldb       >X0154              flag for extended table lookup
                    bne       L23BD
                    ldb       >$0180
                    beq       L23C2
L23BD               tsta
                    beq       L23D7
                    bra       L23D2
L23C2               cmpa      <u0099
                    beq       L23D7
                    ldb       >X0102
                    bne       L23D7
                    sta       <u0099
                    cmpa      >$0438
                    beq       L23D7
L23D2               ldb       #$02
                    lbsr      L12AF
L23D7               bsr       L2404
L23D9               rts

* Get status - Returns the status of a file or device
*              Wildcard call exit status differs based on cal code
* entry:
*       a -> path number
*       b -> function code (SS.Joy) $13
*       x -> joystick number
*            0 - right joystick
*            1 - left joystick
*
* exit:
*       a -> fire button down
*            0 - none
*            1 - Button 1
*            2 - Button 2
*            3 - Buttons 1 & 2
*
*       Note: in Level 1 a values as follows
*            $00 - button off
*            $FF - button on
*
*       x -> selected joystick x value (0-63)
*       y -> selected joystick y value (0-63)

L23DA               pshs      y                   save our y value
                    lda       #StdIn              $00
                    ldb       #SS.Joy             $13
                    ldx       <u0096              joystick number
                    os9       I$GetStt            make the call
                    tfr       x,d                 move x vale to d
                    leax      >L22AA,pcr          point to joystick data
                    sty       $01,x               store y value second byte
                    std       ,x                  store x value first byte
                    puls      y                   retrieve orig y value
                    rts                           return

L23F3               pshs      y                   save our y
                    lda       #StdIn              $00
                    ldb       #SS.Joy             $13
                    ldx       <u0096              joystick number
                    os9       I$GetStt            make the call
                    sta       >$0541              joystick buttons status
                    puls      y                   restore our y
                    rts

L2404               bsr       L23F3               get joystick button stat
                    lda       >$0542              get byte after joy stat
                    cmpa      #$02                is it 2?
                    bne       L2430               not 2 branch below
                    orcc      #IntMasks           mask interrupts  $50 but why
                    ldx       >$024B              get some data
                    ldd       >$0249              get some more
                    andcc     #^IntMasks          un mask      $AF
                    cmpd      >$0543
                    blo       L2430
                    bhi       L2424
                    cmpx      >$0545
                    bcs       L2430
L2424               clr       >$0542
                    lda       #$FC
                    ldb       #$01
                    lbsr      L12AF
                    bra       L2439
L2430               lda       >$0542
                    beq       L2439
                    cmpa      #$02
                    bne       L2443
L2439               lda       >$0541
                    beq       L2480
                    inc       >$0542
                    bra       L2480
L2443               cmpa      #$01
                    bne       L2471
                    lda       >$0541
                    bne       L2480
                    lda       >$01B0              state.flag
                    anda      #$80
                    beq       L2424
                    clra
                    ldb       >$0441
                    orcc      #IntMasks           why      $50
                    addd      >$024B
                    std       >$0545
                    ldd       >$0249
                    andcc     #^IntMasks          $AF
                    bcc       L2469
                    addd      #$0001
L2469               std       >$0543
                    inc       >$0542
                    bra       L2480
L2471               lda       >$0541
                    bne       L2480
                    clr       >$0542
                    lda       #$FE
                    ldb       #$01
                    lbsr      L12AF
L2480               rts

* This does a check of the joystick values but I'm confused
* since at this point x points to L22AA the first of three bytes
* byte 0 (L22AA) = x co-ordinate
* byte 1 (L22AB) = y co-ordinate
* byte 2 (L22AC) = null since nobody set it
* Possible good old C-code off by one error ???

L2481               lda       $02,x               we get the third byte which is null ??
                    ldb       $01,x               we get the second byte which is the y value
                    cmpa      #$25                ** as I see it this will always
                    bls       L2499               **  less or same branch here
*                           dead code ???
                    lda       #$08
                    cmpb      #$16
                    blo       L24BB               less than leave
                    lda       #$02
                    cmpb      #$25
                    bhi       L24BB               greater than leave
                    lda       #$01
                    bra       L24BB               always leave
*                          end of dead code  ???
L2499               cmpa      #$16                a still = 00 from initial load
                    bcc       L24AD               will never happen
                    lda       #$06                so we load a with 6
                    cmpb      #$16                and test
                    blo       L24BB               less than leave
                    lda       #$04
                    cmpb      #$25
                    bhi       L24BB               greater than leave
                    lda       #$05
                    bra       L24BB               always leave
L24AD               lda       #$07
                    cmpb      #$16
                    blo       L24BB               leave
                    lda       #$03
                    cmpb      #$25
                    bhi       L24BB               leave
                    lda       #$00
L24BB               rts


L24BC               fcb       $1C,$01
                    fcb       $10,$02
                    fcb       $19,$03
                    fcb       $11,$04
                    fcb       $1A,$05
                    fcb       $12,$06
                    fcb       $18,$07
                    fcb       $13,$08
                    fcb       $00,$00

L24CE               fcb       $0C,$01
                    fcb       $09,$03
                    fcb       $0A,$05
                    fcb       $08,$07
                    fcb       $00,$00

*  reads input from stdin and discards it ???
clear_key_queue
L24D8               lbsr      L2BC0               go do getstat and read of stdin
                    tsta                          check a for value
                    bne       L24D8               if it has a value loop to read again
                    rts

L24DF               lbsr      L2BC0               go do a getstat and read of input
                    tsta                          check for return value
                    beq       L24F7               if zero leave else has a value so continue
                    bsr       L24F8               use lookup table to match val in a
                    tstb                          check b value for match found
                    bmi       L24EE               if b is neg i.e. hit L2515 below
                    ldb       #$02                load b with 2
                    bra       L24F4               branch to sub call
L24EE               cmpa      #$0C                b < 0 check a for first byte in second table
                    beq       L24F7               it is then leave
                    ldb       #$01                else load b with two
L24F4               lbsr      L12AF               make call to sub that uses u0092
L24F7               rts

* compares value passed in "a" to table vals
L24F8               leax      >L24BC,pcr          data table above
L24FC               cmpa      ,x+                 compare val in a with table and bump x
                    beq       L2519               is it a match ? go load 2nd byte of x in a
                    ldb       ,x+                 load second byte in b
                    bne       L24FC               if not a zero more to test
                    ldb       >X0154              it was zero get flag for table 2 use
                    beq       L2515               that val zero go load b with FF and leave
                    leax      >L24CE,pcr          otherwise load info from 2nd data table above
L250D               cmpa      ,x+                 check and bump
                    beq       L2519               match ?? go load second byte of the pair and leave
                    ldb       ,x+                 else load second byte in b and bump x
                    bne       L250D               second byte not zero loop
L2515               ldb       #$FF                was zero load b with FF and leave
                    bra       L251C               exit if no match
L2519               lda       ,x                  this is one byte after a match value
                    clrb                          clear b
L251C               rts

L251D               fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

L2529               leax      >L251D,pcr          load table address
                    ldd       #$0000              clear d
                    std       ,x                  store at first word
                    rts

* waste of time since you zero it out and don't save anything
L2533               leay      >L251D,pcr          load table address
                    ldy       ,y                  check value
                    beq       L2541               is it zero
                    ldd       #$0000              nope make it zero
                    std       ,y
L2541               rts


L2542               leau      >L251D,pcr          load table address
L2546               stu       <u0064              save value
                    ldu       ,u                  load it
                    beq       L2550               if zero leave
                    cmpb      $02,u               comp b to 2nd word
                    bne       L2546               not zero leave
L2550               rts

cmd_load_logics
L2551               ldb       ,y+
                    bsr       L2561
                    rts

cmd_load_logics_v
L2556               ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    bsr       L2561
                    rts

L2561               leas      -$01,s
                    stb       ,s
                    lda       #$00
                    lbsr      L4699
                    ldb       ,s
                    bsr       L2571
                    leas      $01,s
                    rts

L2571               leas      -$07,s              make room on the stack
                    stb       ,s                  save b
                    bsr       L2542               go test table at L251D
                    cmpu      #$0000              did we find 0000
                    bne       L25E3               nope clean up stack and leave
                    ldd       <u000A
                    std       $03,s
                    lbsr      L057D
                    ldd       #$000C
                    lbsr      L2730
                    ldx       <u0064
                    stu       ,x
                    ldd       #$0000
                    std       ,u
                    ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      L4D55
                    ldx       #$0000
                    lbsr      L4966
                    beq       L25D9
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
                    beq       L25D9
                    ldd       <u0062
                    std       $05,s
                    stx       <u0062
                    clrb
                    lbsr      L3B58
                    clra
                    ldb       $03,x
                    ldx       $0A,x
                    addd      #$0001
                    lslb
                    rola
                    leax      d,x
                    lbsr      L1061
                    ldd       $05,s
                    std       <u0062
L25D9               lbsr      L058A
                    ldd       $03,s
                    lbsr      L27AF
                    ldu       $01,s
L25E3               leas      $07,s               clean up stack and leave
                    rts

cmd_call
L25E6               leas      -$02,s
                    ldb       ,y+
                    sty       ,s
                    bsr       L2612
                    leay      ,y
                    beq       L25F6
                    ldy       ,s
L25F6               leas      $02,s
                    rts

cmd_call_v
L25F9               leas      -$02,s
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    sty       ,s
                    bsr       L2612
                    leay      ,y
                    beq       L260F
                    ldy       ,s
L260F               leas      $02,s
                    rts

L2612               leas      -$0A,s
                    stb       ,s
                    ldd       <u0062
                    std       $01,s
                    lda       #$01
                    sta       $03,s
                    ldb       ,s
                    lbsr      L2542
                    stu       <u0062
                    beq       L262E
                    ldd       $04,u
                    lbsr      L27AF
                    bra       L2648
L262E               ldd       <u0064
                    std       $04,s
                    ldb       ,s
                    lbsr      L2571
                    stu       <u0062
                    stu       $06,s
                    lda       $04,u
                    ldu       $06,u
                    leau      -$02,u
                    lbsr      L278F
                    stu       $08,s
                    clr       $03,s
L2648               lda       <u0068
                    cmpa      #$02
                    bne       L2652
                    lda       #$01
                    sta       <u0068
L2652               lda       ,s
                    bne       L265A
                    lda       #$01
                    sta       <u0069
L265A               lbsr      L44AE
                    lda       $03,s
                    bne       L2676
                    ldd       #$0000
                    ldx       $04,s
                    std       ,x
                    lbsr      L057D
                    ldd       $08,s
                    std       <u004F
                    ldd       $06,s
                    std       <u0055
                    lbsr      L058A
L2676               ldu       $01,s
                    stu       <u0062
                    beq       L2681
                    ldd       $04,u
                    lbsr      L27AF
L2681               leas      $0A,s
                    rts

cmd_set_scan_start
L2684               ldx       <u0062
                    sty       $08,x
                    rts

cmd_reset_scan_start
L268A               ldx       <u0062
                    ldd       $06,x
                    std       $08,x
                    rts

L2691               leau      >L251D,pcr          load 12 byte table address
                    ldx       #$0554
L2698               lda       $02,u
                    sta       ,x
                    ldd       $08,u
                    subd      $06,u
                    std       $01,x
                    leax      $03,x
                    ldu       ,u
                    bne       L2698
                    lda       #$FF
                    sta       ,x
                    tfr       x,d
                    subd      #$0553
                    tfr       d,x
                    rts

L26B4               ldx       #$0554
L26B7               lda       ,x
                    cmpa      #$FF
                    beq       L26CB
                    cmpa      $02,u
                    beq       L26C5
                    leax      $03,x
                    bra       L26B7
L26C5               ldd       $06,u
                    addd      $01,x
                    std       $08,u
L26CB               rts


L26CC               fcc       'Out of %s memory.'
                    fcb       C$LF
                    fcc       'Want: %d, Have: %d'
                    fcb       C$NULL

L26F1               fcc       'heap'
                    fcb       C$NULL

L26F6               fcc       'common'
                    fcb       C$NULL


L26FD               leas      -$34,s
                    std       ,s
                    ldd       <u004F
                    tfr       d,u
                    addd      ,s
                    bcc       L271E
L270A               ldd       #$FFFF
                    subd      <u004F
                    addd      #$0001
                    pshs      b,a
L2714               ldd       $02,s
                    pshs      b,a
                    leax      >L26F1,pcr          heap
                    bra       L2748
L271E               std       <u004F
                    lbsr      L2786
                    ldd       <u004F
                    cmpd      <u004B
                    bls       L272C
                    std       <u004B
L272C               leas      <$34,s
                    rts

L2730               leas      <-$34,s
                    std       ,s
                    ldd       <u0000
                    subd      <u0055
                    cmpd      ,s
                    bcc       L2765
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
L2744               leax      >L26F6,pcr          common
L2748               pshs      x
                    leax      >L26CC,pcr          out of memory msg
                    leau      $08,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $0A,s
                    lbsr      L37F2               message_box()

                    lda       #$03                load the offset to exit_agi()
                    sta       <u0009              save the value
                    ldx       <u0022              set up call to sierra
                    jsr       >$0659              mmu twiddle

L2765               ldd       <u0055
                    tfr       d,u
                    addd      ,s
                    std       <u0055
                    cmpd      <u0051
                    bls       L2774
                    std       <u0051
L2774               leas      <$34,s
                    rts

L2778               lbsr      L05CA
                    ldd       <u004D
                    std       <u004F
                    bsr       L2786
                    ldd       <u0053
                    std       <u0055
                    rts

L2786               ldd       #$FFFF
                    subd      <u004F
                    sta       >$043A
                    rts

L278F               suba      <u005F
                    ldb       #$20
                    mul
                    exg       b,a
                    subd      #$2000
                    leau      d,u
                    rts

L279C               tfr       u,d
                    anda      #$1F
                    adda      #$20
                    exg       d,u
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    adda      <u005F
                    tfr       a,b
                    incb
                    rts

L27AF               cmpa      <u000A
                    beq       L27C9
                    orcc      #IntMasks           $50
                    std       <u000A
                    lda       <u0042
                    sta       >$FFA9
                    ldx       <u0043
                    lda       <u000A
                    sta       ,x
                    stb       $02,x
                    std       >$FFA9
                    andcc     #^IntMasks          $AF
L27C9               rts

L27CA               fdb       $0000
L27CC               fdb       $0000
L27CE               fcb       $00
L27CF               fcb       $00
L27D0               fdb       $0000
L27D2               fcb       $00
L27D3               fcb       $00
L27D4               fcb       $00
L27D5               fcb       $00
L27D6               fcb       $00
L27D7               fcb       $00


cmd_set_menu
L27D8               leas      -$04,s
                    ldb       ,y+
                    lbsr      L3B58
                    stu       ,s
                    ldu       <u0062
                    ldd       $04,u
                    std       $02,s
                    lda       >L27D7,pcr          data byte
                    bne       L2853
                    ldd       #$0010
                    lbsr      L2730
                    ldd       >L27D0,pcr          data word
                    bne       L2805
                    stu       >L27D0,pcr          data word
                    lda       #$01
                    sta       >L27D2,pcr          data byte
                    bra       L2813
L2805               ldx       >L27CC,pcr          data word
                    stu       ,x
                    stx       $02,u
                    ldd       $0B,x
                    bne       L2813
                    sta       $0A,x
L2813               ldx       >L27D0,pcr          data word
                    stx       ,u
                    stu       $02,x
                    stu       >L27CC,pcr          data word
                    ldd       #$0000
                    std       $0B,u
                    sta       $08,u
                    sta       $0F,u
                    lda       >L27D2,pcr          data byte
                    sta       $09,u
                    lda       #$01
                    sta       $0A,u
                    ldx       ,s
                    stx       $04,u
                    ldd       $02,s
                    std       $06,u
                    lbsr      L113E
                    incb
                    addb      >L27D2,pcr          data byte
                    stb       >L27D2,pcr          data byte
                    ldd       #$0000
                    std       >L27CA,pcr          data word
                    lda       #$01
                    sta       >L27CE,pcr          data byte
L2853               leas      $04,s
                    rts

cmd_set_menu_item
L2856               leas      -$05,s
                    ldb       ,y+
                    lbsr      L3B58
                    stu       ,s
                    ldu       <u0062
                    ldd       $04,u
                    std       $02,s
                    lda       ,y+
                    sta       $04,s
                    lda       >L27D7,pcr          data byte
                    bne       L28D5
                    ldd       #$000C
                    lbsr      L2730
                    ldx       >L27CA,pcr          data word
                    bne       L2887
                    ldx       >L27CC,pcr          data word
                    stu       $0D,x
                    stu       $0B,x
                    stu       $02,u
                    bra       L288F
L2887               stu       ,x
                    stx       $02,u
                    ldx       >L27CC,pcr          data word
L288F               ldx       $0B,x
                    stx       ,u
                    stu       $02,x
                    stu       >L27CA,pcr          data word
                    ldx       ,s
                    stx       $04,u
                    ldd       $02,s
                    std       $06,u
                    lda       >L27CE,pcr          data byte
                    inc       >L27CE,pcr          data byte
                    cmpa      #$01
                    bne       L28C1
                    lbsr      L113E
                    negb
                    addb      #$27
                    ldx       >L27CC,pcr          data word
                    cmpb      $09,x
                    bls       L28BD
                    ldb       $09,x
L28BD               stb       >L27CF,pcr
L28C1               ldd       >L27CE,pcr          data byte
                    std       $08,u
                    lda       #$01
                    sta       $0A,u
                    lda       $04,s
                    sta       $0B,u
                    ldx       >L27CC,pcr          data word
                    inc       $0F,x
L28D5               leas      $05,s
                    rts

cmd_submit_menu
L28D8               ldu       >L27CC,pcr          data word
                    ldd       $0B,u
                    bne       L28E2
                    sta       $0A,u
L28E2               ldd       <u0055
                    std       <u0053
                    ldu       >L27D0,pcr          data word
                    stu       >L27CC,pcr          data word
                    ldd       $0B,u
                    std       >L27CA,pcr          data word
                    lda       #$01
                    sta       >L27D7,pcr          data byte
                    rts

cmd_enable_item
L28FB               lda       ,y+
                    ldb       #$01
                    bsr       L2929
                    rts

L2902               ldu       >L27D0,pcr          data word
                    beq       L2921
L2908               lda       $0A,u
                    beq       L2918
                    ldx       $0B,u
L290E               lda       #$01
                    sta       $0A,x
                    ldx       ,x
                    cmpx      $0B,u
                    bne       L290E
L2918               ldu       ,u
                    cmpu      >L27D0,pcr          data word
                    bne       L2908
L2921               rts

cmd_disable_item
L2922               lda       ,y+
                    ldb       #$00
                    bsr       L2929
                    rts

L2929               leas      -$02,s
                    std       ,s
                    ldu       >L27D0,pcr          data word
L2931               lda       $0A,u
                    beq       L2945
                    ldx       $0B,u
                    ldd       ,s
L2939               cmpa      $0B,x
                    bne       L293F
                    stb       $0A,x
L293F               ldx       ,x
                    cmpx      $0B,u
                    bne       L2939
L2945               ldu       ,u
                    cmpu      >L27D0,pcr          data word
                    bne       L2931
                    leas      $02,s
                    rts

cmd_menu_input
L2951               lda       >$01B0              state.flag
                    anda      #$02
                    beq       L295D
                    lda       #$01
                    sta       >$05AE
L295D               rts

L295E               leas      -$04,s
                    lbsr      L47AA
                    lbsr      L464E
                    ldd       #$000F
                    lbsr      L47D0
                    ldu       >L27D0,pcr          data word
L2970               stu       ,s
                    ldx       ,s
                    lbsr      L2B58
                    ldu       ,s
                    ldu       ,u
                    cmpu      >L27D0,pcr          data word
                    bne       L2970
                    ldd       >L27CA,pcr          data word
                    std       $02,s
                    ldu       >L27CC,pcr          data word
                    stu       ,s
                    lbsr      L2ACD
                    lda       #$01
                    sta       >X0154              flag for extended table lookup
                    lda       #$03
                    sta       >$0547
L299B               lbsr      L12F0
                    lda       ,x
                    cmpa      #$01
                    bne       L29E3
                    lda       $01,x
                    cmpa      #$0D
                    bne       L29B9
                    ldu       $02,s
                    lda       $0A,u
                    beq       L299B
                    lda       $0B,u
                    ldb       #$03
                    lbsr      L12AF
                    bra       L29BF
L29B9               cmpa      #$1B
                    lbne      L2AB0
L29BF               ldu       ,s
                    ldx       $02,s
                    lbsr      L2B13
                    clr       >$0547
                    lbsr      L4663
                    lbsr      L47BE
                    lda       >X0247              state.status_state
                    beq       L29DA
                    lbsr      L54F7
                    lbra      L2ABF
L29DA               ldd       #$0000
                    lbsr      L47D0
                    lbra      L2ABF
L29E3               cmpa      #$02
                    lbne      L2AB0
                    lda       $01,x
                    cmpa      #$01
                    bne       L2A00
                    ldx       $02,s
                    lbsr      L2B58
                    ldx       $02,s
                    ldx       $02,x
                    stx       $02,s
                    lbsr      L2B31
                    lbra      L2AB0
L2A00               cmpa      #$02
                    bne       L2A15
                    ldx       $02,s
                    lbsr      L2B58
                    ldu       ,s
                    ldx       $0B,u
                    stx       $02,s
                    lbsr      L2B31
                    lbra      L2AB0
L2A15               cmpa      #$03
                    bne       L2A34
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B13
                    ldu       ,s
L2A22               ldu       ,u
                    lda       $0A,u
                    beq       L2A22
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2ACD
                    lbra      L2AB0
L2A34               cmpa      #$04
                    bne       L2A4A
                    ldx       $02,s
                    lbsr      L2B58
                    ldu       ,s
                    ldx       $0B,u
                    ldx       $02,x
                    stx       $02,s
                    lbsr      L2B31
                    bra       L2AB0
L2A4A               cmpa      #$05
                    bne       L2A5E
                    ldx       $02,s
                    lbsr      L2B58
                    ldx       $02,s
                    ldx       ,x
                    stx       $02,s
                    lbsr      L2B31
                    bra       L2AB0
L2A5E               cmpa      #$06
                    bne       L2A7A
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B13
                    ldu       >L27D0,pcr          data word
                    ldu       $02,u
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2ACD
                    bra       L2AB0
L2A7A               cmpa      #$07
                    bne       L2A98
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B13
                    ldu       ,s
L2A87               ldu       $02,u
                    lda       $0A,u
                    beq       L2A87
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2ACD
                    bra       L2AB0
L2A98               cmpa      #$08
                    bne       L2AB0
                    ldu       ,s
                    ldx       $02,s
                    lbsr      L2B13
                    ldu       >L27D0,pcr          data word
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      L2ACD
L2AB0               ldd       ,s
                    std       >L27CC,pcr          data word
                    ldd       $02,s
                    std       >L27CA,pcr          data word
                    lbra      L299B
L2ABF               lda       #$00
                    sta       >X0154              flag for extended table lookup
                    sta       >$05AE
                    sta       >$0547
                    leas      $04,s
                    rts

L2ACD               leas      -$04,s
                    stu       ,s
                    ldx       ,s
                    bsr       L2B31
                    ldu       ,s
                    lbsr      L2B7F

                    ldd       #$000F
                    pshs      b,a
                    ldd       >L27D3,pcr          data byte
                    pshs      b,a
                    ldd       >L27D5,pcr          data byte
                    pshs      b,a
                    lda       #$0C
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up stack

                    ldu       ,s
                    ldx       $0B,u
L2AFA               stx       $02,s
                    cmpx      $0D,u
                    beq       L2B04
                    bsr       L2B58
                    bra       L2B06
L2B04               bsr       L2B31
L2B06               ldx       $02,s
                    ldx       ,x
                    ldu       ,s
                    cmpx      $0B,u
                    bne       L2AFA
                    leas      $04,s
                    rts

L2B13               stx       $0D,u
                    tfr       u,x
                    bsr       L2B58

                    ldd       >L27D3,pcr          data byte
                    pshs      b,a
                    ldd       >L27D5,pcr          data byte
                    pshs      b,a
                    lda       #$03
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $04,s               clean up stack
                    rts

L2B31               ldd       $08,x
                    std       <u0040
                    ldd       #$0F00
                    lbsr      L45BA
                    lda       $0A,x
                    bne       L2B43
                    lda       #$0F
                    sta       <u0045
L2B43               pshs      x
                    ldd       $06,x
                    lbsr      L27AF
                    puls      x
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L3C34
                    leas      $02,s
                    clr       <u0045
                    rts

L2B58               ldd       $08,x
                    std       <u0040
                    ldd       #$000F
                    lbsr      L45BA
                    lda       $0A,x
                    bne       L2B6A
                    lda       #$0F
                    sta       <u0045
L2B6A               pshs      x
                    ldd       $06,x
                    lbsr      L27AF
                    puls      x
                    ldd       $04,x
                    pshs      b,a
                    lbsr      L3C34
                    leas      $02,s
                    clr       <u0045
                    rts

L2B7F               leas      -$01,s
                    lda       $0F,u
                    sta       ,s
                    ldb       #$08
                    mul
                    addb      #$10
                    stb       >L27D3,pcr          data byte
                    ldu       $0B,u
                    ldd       $06,u
                    lbsr      L27AF
                    ldx       $04,u
                    lbsr      L113E
                    lda       #$04
                    mul
                    addb      #$08
                    stb       >L27D4,pcr          data byte
                    lda       $09,u
                    deca
                    ldb       #$04
                    mul
                    stb       >L27D5,pcr          data byte
                    lda       ,s
                    adda      #$02
                    suba      >$0242
                    ldb       #$08
                    mul
                    addb      #$07
                    stb       >L27D6,pcr          data byte
                    leas      $01,s
                    rts

* Reads a byte from Stdin and returns it in a
* clears a on getsta or read error
* saves y and s

L2BC0               leas      -$03,s              make room on the stack
                    sty       ,s                  stow current y since os9 calls may mod it

* Get status - Returns the status of a file or device
*              Wildcard call exit status differs based on cal code
* entry:
*       a -> path number
*       b -> function code (SS.Ready) $01
*            tests for data available on SCF-supported device
* exit:
*     if device is ready:
*       CC -> carry clear
*       b  -> $00 ... see note
*
*     if not ready:
*       CC -> carry set
*       b  -> $F6 (E$SRNDY)
*
*      Note:
*      On devices that support it (both CC3IO and ACIAPAK
*      support this), the b register will return the number
*      of characters that are ready to be read.
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

                    lda       #StdIn              $00
                    ldb       #SS.Ready           $01
                    os9       I$GetStt
                    bcs       L2BEF               error during call go clear a,
*                               restore y, cleanup stack & leave


* Read  - Reads N bytes from the specified path
* entry:
*       a -> path number
*       x -> number of bytes to read
*       y -> address in which to store the data
*
* exit:
*       y -> number of bytes to be read
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    lda       #StdIn              $00
                    ldy       #$0001              (1) number of bytes to read
                    leax      $02,s               address to store the byte stack buff
                    os9       I$Read              make the read call
                    bcs       L2BEF               error during call clear a
*                                restore y, cleanup stack & leave
                    lda       $02,s               clean read move byte to a
                    bra       L2BF0               restore y, clean up stack and leave
*
*    Since the above inst is a bra this looks like dead code
*    unless he does something cute and uses a magic jump into this.

                    cmpa      #$F4
                    bne       L2BF0
                    lda       <u0068
                    bne       L2BEC
                    lbsr      L5757
                    bra       L2BEF
L2BEC               lbsr      L57E4
*
*    end dead code

L2BEF               clra                          if we had an error clear a
L2BF0               ldy       ,s                  restore y
                    leas      $03,s               reset stack pointer
                    rts                           return to caller

*  stores the value passed in b at address pointed to by u
*  the number of times held in x
***********************************************************
*
* entry:
*       a -> unused
*       b -> value to store
*       x -> number of bytes to store
*       y -> unused
*       u -> to address
*       s -> unused
*
* exit:
*       a -> unchanged
*       b -> unchanged
*       y -> unchanged
*       x -> returns 0
*       u -> restored
*       s -> unchanged

L2BF6               pshs      u                   save destination address
L2BF8               stb       ,u+                 store value in b and bump pointer
                    leax      -$01,x              count down index
                    bne       L2BF8               test index and if more left go again
                    puls      u                   restore the destination address
                    rts                           return

* maps shdw into working space
* and calls code that flips the screen byte nibbles

gfx_picbuff_update
L2C01               tst       >X0550              test gfx_picbuffrotate
                    beq       L2C0F               it's zero ? go
*                          not zero the do the byte flip flop
                    lda       #$00                gfx_picbuff_update remap
                    sta       <u0021              save the offset
                    ldx       <u0028              set up the remap to shdw
                    jsr       >$0659              mmu twiddler

L2C0F               ldd       #$A8A0              160,168
                    pshs      d                   push on the stack
                    ldd       #$00A7              0,167
                    pshs      d                   push on stack
                    lda       #$00
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $04,s               clean up stack
                    rts

cmd_move_obj
L2C25               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
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
                    beq       L2C4A
                    sta       <$1E,u
L2C4A               lda       ,y+
                    sta       <$2A,u
                    lbsr      L16DC
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <u0030
                    bne       L2C62
                    clr       >$0251
L2C62               lbsr      L2F0A
                    rts

cmd_move_obj_v
L2C66               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$03
                    sta       <$22,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       <$27,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       <$28,u
                    lda       <$1E,u
                    sta       <$29,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    beq       L2C9D
                    sta       <$1E,u
L2C9D               lda       ,y+
                    sta       <$2A,u
                    lbsr      L16DC
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <u0030
                    bne       L2CB5
                    clr       >$0251
L2CB5               lbsr      L2F0A
                    rts

cmd_follow_ego
L2CB9               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$02
                    sta       <$22,u
                    lda       <$1E,u
                    sta       <$27,u
                    lda       ,y+
                    cmpa      <$1E,u
                    bls       L2CD7
                    sta       <$27,u
L2CD7               lda       ,y+
                    sta       <$28,u
                    lbsr      L16DC
                    lda       #$FF
                    sta       <$29,u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    rts

cmd_wander
L2CED               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$01
                    sta       <$22,u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <u0030
                    bne       L2D0B
                    clr       >$0251
L2D0B               rts

cmd_normal_motion
L20DC               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    rts

cmd_stop_motion
L2D1B               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    clra
                    sta       <$21,u
                    cmpu      <u0030
                    bne       L2D38
                    sta       >$0438
                    sta       >$0251
L2D38               rts

cmd_start_motion
L2D39               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    cmpu      <u0030
                    bne       L2D54
                    clr       >$0438
                    lda       #$01
                    sta       >$0251
L2D54               rts

cmd_step_size
L2D55               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       <$1E,u
                    rts

cmd_step_time
L2D6A               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       ,u
                    sta       $01,u
                    rts

cmd_set_dir
L2D80               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       <$21,u
                    rts

cmd_get_dir
L2D95               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       <$21,u
                    sta       ,x
                    rts

cmd_program_control
L2DAA               clr       >$0251              state.ego_control_state = 0
                    rts

cmd_player_control
L2DAE               lda       #$01
                    sta       >$0251              state.ego_control_state = 1
                    ldu       <u0030
                    lda       #$00
                    sta       <$22,u
                    rts

* From nagi 2002_11_14 obj_motion.c
* x_dir_mult[] = {0,0,1,1,1,0,-1,-1,-1};

x_dir_mult
L2DBB               fcb       $00,$00,$01,$01
                    fcb       $01,$00,$FF,$FF
                    fcb       $FF

* y_dir_mult[] = {0,-1,-1,0,1,1,1,0,-1};

y_dir_mult
L2DC4               fcb       $00,$FF,$FF,$00
                    fcb       $01,$01,$01,$00
                    fcb       $FF

L2DCD               leas      -$0B,s
                    clra
                    sta       >$0434
                    sta       >$0436
                    sta       >$0437
                    ldu       <u0030
L2DDB               cmpu      <u0032
                    lbcc      L2EFE
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    lbne      L2EF8
                    lda       $01,u
                    beq       L2DF9
                    deca
                    beq       L2DF9
                    sta       $01,u
                    lbra      L2EF8
L2DF9               lda       ,u
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
                    bne       L2E4E
                    leax      >L2DBB,pcr          x_dir_mult
                    lda       <$21,u
                    lda       a,x
                    beq       L2E33
                    bpl       L2E2D
                    ldd       $03,s
                    subd      $09,s
                    std       $03,s
                    bra       L2E33
L2E2D               ldd       $03,s
                    addd      $09,s
                    std       $03,s
L2E33               leax      >L2DC4,pcr          y_dir_mult
                    lda       <$21,u
                    lda       a,x
                    beq       L2E4E
                    bpl       L2E48
                    ldd       $05,s
                    subd      $09,s
                    std       $05,s
                    bra       L2E4E
L2E48               ldd       $05,s
                    addd      $09,s
                    std       $05,s
L2E4E               ldd       #$0000
                    cmpd      $03,s
                    ble       L2E5E
                    std       $03,s
                    lda       #$04
                    sta       $02,s
                    bra       L2E72
L2E5E               ldb       <$1C,u
                    negb
                    lda       #$FF
                    addd      #$00A0
                    cmpd      $03,s
                    bge       L2E72
                    std       $03,s
                    lda       #$02
                    sta       $02,s
L2E72               clra
                    ldb       <$1D,u
                    decb
                    cmpd      $05,s
                    ble       L2E84
                    std       $05,s
                    lda       #$01
                    sta       $02,s
                    bra       L2EA9
L2E84               ldd       #$00A7
                    cmpd      $05,s
                    bge       L2E94
                    std       $05,s
                    lda       #$03
                    sta       $02,s
                    bra       L2EA9
L2E94               lda       <$26,u
                    bita      #$08
                    bne       L2EA9
                    lda       >$01D7
                    cmpa      $06,s
                    bls       L2EA9
                    inca
                    sta       $06,s
                    lda       #$01
                    sta       $02,s
L2EA9               lda       $04,s
                    ldb       $06,s
                    std       $03,u
                    lbsr      L0885
                    tsta
                    bne       L2ECA
                    stu       ,s
                    pshs      u
                    lda       #$03                obj_chk_control
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldu       ,s
                    lda       <u005C
                    bne       L2ED3
L2ECA               ldd       $07,s
                    std       $03,u
                    clr       $02,s
                    lbsr      L15F5
L2ED3               lda       $02,s
                    beq       L2EF0
                    ldb       $02,u
                    bne       L2EE0
                    sta       >$0434
                    bra       L2EE6
L2EE0               stb       >$0436
                    sta       >$0437
L2EE6               lda       <$22,u
                    cmpa      #$03
                    bne       L2EF0
                    lbsr      L2F2D
L2EF0               lda       <$25,u
                    anda      #$FB
                    sta       <$25,u
L2EF8               leau      <$2B,u
                    lbra      L2DDB
L2EFE               leas      $0B,s
                    rts

L2F01               fcb       $08,$01,$02
                    fcb       $07,$00,$03
                    fcb       $06,$05,$04

L2F0A               ldb       $1E,u
                    pshs      b,a
                    ldd       <$27,u
                    pshs      b,a
                    ldd       $03,u
                    pshs      b,a
                    lbsr      L2F4C
                    leas      $06,s
                    cmpu      <u0030
                    bne       L2F25
                    sta       >$0438
L2F25               sta       <$21,u
                    bne       L2F2C
                    bsr       L2F2D
L2F2C               rts

L2F2D               lda       <$29,u
                    sta       <$1E,u
                    lda       <$2A,u
                    lbsr      L16D5
                    lda       #$00
                    sta       <$22,u
                    cmpu      <u0030
                    bne       L2F4B
                    lda       #$01
                    sta       >$0251              state.ego_control_state = 1
                    clr       >$0438
L2F4B               rts

L2F4C               leas      -$03,s
                    clra
                    sta       $09,s
                    ldb       $05,s
                    std       ,s
                    ldb       $07,s
                    subd      ,s
                    pshs      b,a
                    ldd       $0B,s
                    pshs      b,a
                    lbsr      L2F86
                    leas      $04,s
                    sta       $02,s
                    clra
                    sta       $05,s
                    ldb       $08,s
                    subd      $05,s
                    pshs      b,a
                    ldd       $0B,s
                    pshs      b,a
                    lbsr      L2F86
                    leas      $04,s
                    leax      >L2F01,pcr          9 byte table
                    ldb       #$03
                    mul
                    addb      $02,s
                    lda       b,x
                    leas      $03,s
                    rts

L2F86               ldd       #$0000
                    subd      $02,s
                    cmpd      $04,s
                    blt       L2F93
                    clra
                    bra       L2FA0
L2F93               ldd       $02,s
                    cmpd      $04,s
                    bgt       L2F9E
                    lda       #$02
                    bra       L2FA0
L2F9E               lda       #$01
L2FA0               rts


cmd_new_room
L2FA1               lda       ,y
                    bsr       L2FB1
                    rts

cmd_new_room_v
L2FA6               ldb       ,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    bsr       L2FB1
                    rts

L2FB1               leas      -$01,s
                    sta       ,s
                    lbsr      L2778
                    lbsr      L129A               events_clear
                    lbsr      L467A
                    lda       #$01
                    sta       >$05B1
                    ldu       <u0030
L2FC5               cmpu      <u0032
                    bcc       L2FF5
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
                    bra       L2FC5
L2FF5               lbsr      L229D
                    clra
                    sta       >X01AD              state.block_state=0
                    sta       >$0436
                    sta       >$0437
                    inca
                    sta       >$0251              state.ego_control_state = 1
                    lda       #$24
                    sta       >$01D7
                    lda       >$0432
                    sta       >$0433
                    ldb       ,s
                    stb       >$0432
                    lbsr      L2561
                    ldb       <u006A
                    beq       L3020
                    lbsr      L2571
L3020               ldu       <u0030
                    lda       $05,u
                    sta       >$0442
                    lda       >$0434
                    beq       L3058
                    cmpa      #$01
                    bne       L3036
                    lda       #$A7
                    sta       $04,u
                    bra       L3055
L3036               cmpa      #$02
                    bne       L3040
                    lda       #$00
                    sta       $03,u
                    bra       L3055
L3040               cmpa      #$03
                    bne       L304A
                    lda       #$25
                    sta       $04,u
                    bra       L3055
L304A               cmpa      #$04
                    bne       L3055
                    lda       #$A0
                    suba      <$1C,u
                    sta       $03,u
L3055               clr       >$0434
L3058               lda       >$01AF
                    ora       #$04
                    sta       >$01AF
                    lbsr      L0952               self contained call to clear 50 bytes 05BA
                    lbsr      L54F7
                    lbsr      L5BAD
                    ldy       #$0000
                    leas      $01,s
                    rts

cmd_get
L3070               bsr       L3085
                    lda       #$FF
                    sta       $02,u
                    rts

cmd_get_v
L3077               bsr       L309B
                    lda       #$FF
                    sta       $02,u
                    rts

cmd_drop
L307E               bsr       L3085
                    lda       #$00
                    sta       $02,u
                    rts

L3085               ldx       <u0038
                    ldb       ,y+
                    abx
                    abx
                    abx
                    tfr       x,u
                    cmpu      <u003C
                    bcs       L309A
                    lda       #$17
                    ldb       -$01,y
                    lbsr      L10CE
L309A               rts

L309B               ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    ldx       <u0038
                    abx
                    abx
                    abx
                    tfr       x,u
                    cmpu      <u003C
                    bcs       L30B6
                    lda       #$17
                    ldb       -$01,y
                    lbsr      L10CE
L30B6               rts

cmd_put
L30B7               bsr       L3085
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       $02,u
                    rts

cmd_put_v
L30C4               bsr       L309B
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    sta       $02,u
                    rts

cmd_get_room_v
L30D1               bsr       L309B
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       $02,u
                    sta       ,x
                    rts

L30DE               leas      -$02,s
                    stx       ,s
                    pshs      x
                    lda       #$1B                blitlist_draw()
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              twiddle mmu
                    leas      $02,s
                    ldx       ,s
                    bsr       L30F6
                    leas      $02,s
                    rts

*  called from above and L05CA twice
*  with different addresses in x

L30F6               ldu       ,x                  load address in u
                    beq       L3112               exit on zero
                    ldd       #$0000              clear d
                    std       ,x                  clear the address held in x
                    std       $02,x               clear the next word after x
                    tfr       u,x                 move saved value back to x
L3103               stx       <u0055              stow this value
                    ldu       $0A,x
                    lda       $0C,x
                    lbsr      L278F
                    stu       <u004F
                    ldx       ,x
                    bne       L3103
L3112               rts

*  called from L0567 and L0572
*  with x containing a hard coded address and u pointing to a subroutine
L3113               leas      >-$00C8,s
                    stu       ,s                  save the subroutine address
                    stx       $02,s               save the address
                    ldu       <u0030
                    clr       $04,s               clear the word behind our saves
L311F               cmpu      <u0032
                    bcc       L3152               if u0030 & u0032 = then branch around calls to sub
                    jsr       [,s]                call the sub whose address was passed in
                    tsta                          check a set to 1 if cmp fails
                    beq       L314D               found what we were looking for
                    leax      $05,s
                    lda       $04,s
                    lsla
                    stu       a,x
                    ldb       $04,u
                    lda       <$26,u
                    bita      #$04
                    beq       L3143
                    lda       <$24,u
                    suba      #$05
                    ldb       #$0C
                    mul
                    addb      #$30
L3143               leax      >$0085,s
                    lda       $04,s
                    stb       a,x
                    inc       $04,s
L314D               leau      <$2B,u
                    bra       L311F
L3152               clra
L3153               sta       >$00C5,s
                    cmpa      $04,s
                    bcc       L3195
                    leax      >$0085,s
                    lda       #$FF
                    sta       >$00C7,s
                    clra
L3166               cmpa      $04,s
                    bcc       L317D
                    ldb       a,x
                    cmpb      >$00C7,s
                    bcc       L317A
                    sta       >$00C6,s
                    stb       >$00C7,s
L317A               inca
                    bra       L3166
L317D               lda       #$FF
                    ldb       >$00C6,s
                    sta       b,x
                    leau      $05,s
                    lslb
                    ldx       b,u
                    ldu       $02,s
                    bsr       L319C
                    lda       >$00C5,s
                    inca
                    bra       L3153
L3195               ldx       $02,s
                    leas      >$00C8,s
                    rts

L319C               leas      -$02,s
                    stu       ,s
                    lbsr      L41A6
                    ldx       ,s
                    ldx       ,x
                    stx       ,u
                    beq       L31AD
                    stu       $02,x
L31AD               ldx       ,s
                    stu       ,x
                    ldd       $02,x
                    bne       L31B7
                    stu       $02,x
L31B7               leas      $02,s
                    rts




L31BA               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00

L31E3               fdb       $0000

* although these are printing chars I think
* they are just junk place holders

L31E5               fcb       $20,$2C,$2E,$3F     ,.?
                    fcb       $21,$28,$29,$3B     !();
                    fcb       $3A,$5B,$5D,$7B     :[]{
                    fcb       $7D,$00             }.

L31F3               fcb       $27,$60,$2D,$22     '`-".
                    fcb       $00


L31F8               leas      -$07,s
                    stx       ,s
*                       this seems stupid here since it clears two
*                       sets of twenty byte at sequential addresses
*                       must be two data structures of equal length
                    clrb                          clear b to 00
                    ldu       #$0181              load address of destination to be cleared
                    ldx       #$0014              set x to clear 20 bytes
                    lbsr      L2BF6               go clear the bytes
                    ldu       #$0195              load address of destination to be cleared
                    ldx       #$0014              set x to clear 20 bytes
                    lbsr      L2BF6               go clear bytes
                    ldu       ,s
                    lbsr      L32AE
                    clr       $02,s
L3216               leau      >L31BA,pcr          41 byte table
                    stu       >L31E3,pcr          data word
                    ldd       <u000A
                    std       $05,s
                    ldd       >$01AB
                    lbsr      L27AF
L3228               lda       ,u
                    beq       L3275
                    lda       $02,s
                    cmpa      #$0A
                    bcc       L3275
                    lbsr      L330F
                    std       $03,s
                    beq       L326F
                    bpl       L3255
                    ldx       #$0181
                    ldb       $02,s
                    abx
                    abx
                    stu       ,x
                    incb
                    stb       >$015A
                    stb       >$043B
                    lda       >$01AF
                    ora       #$20
                    sta       >$01AF
                    bra       L3284
L3255               ldb       $02,s
                    ldx       #$0195
                    abx
                    abx
                    ldd       $03,s
                    std       ,x
                    ldb       $02,s
                    ldx       #$0181
                    abx
                    abx
                    ldd       >L31E3,pcr          data word
                    std       ,x
                    inc       $02,s
L326F               stu       >L31E3,pcr          data word
                    bra       L3228
L3275               lda       $02,s
                    beq       L3284
                    sta       >$015A
                    lda       >$01AF
                    ora       #$20
                    sta       >$01AF
L3284               ldd       $05,s
                    lbsr      L27AF
                    leas      $07,s
                    rts

cmd_parse
L328C               lda       >X01AF              flag_reset(F02_PLAYERCMD)
                    anda      #$DF
                    sta       >X01AF

                    lda       >X01AF              flag_reset(F04_SAIDACCEPT)
                    anda      #$F7
                    sta       >X01AF

                    lda       ,y+                 get the byte
                    cmpa      #$0C                compare it to 12
                    bcc       L32AD               greater than 12 were out of here
*                       less than 12
                    ldb       #$28
                    mul
                    ldx       #X0252              state.string
                    leax      d,x
                    lbsr      L31F8
L32AD               rts

L32AE               leas      -$02,s
                    leax      >L31BA,pcr          41 byte table
                    stx       ,s
L32B6               lda       ,u+
                    beq       L32F6
                    leax      >L31E5,pcr          14 byte table
                    lbsr      L1277
                    bne       L32B6
                    leax      >L31F3,pcr          5 byte table
                    lbsr      L1277
                    bne       L32B6
                    bra       L32E0
L32CE               leax      >L31E5,pcr          14 byte table
                    lbsr      L1277
                    bne       L32EC
                    leax      >L31F3,pcr          5 byte table
                    lbsr      L1277
                    bne       L32E6
L32E0               ldx       ,s
                    sta       ,x+
                    stx       ,s
L32E6               lda       ,u+
                    bne       L32CE
                    bra       L32F6
L32EC               lda       #$20
                    ldx       ,s
                    sta       ,x+
                    stx       ,s
                    bra       L32B6
L32F6               leax      >L31BA,pcr          41 byte table
                    cmpx      ,s
                    bcc       L330A
                    ldx       ,s
                    lda       -$01,x
                    cmpa      #$20
                    bne       L330A
                    leax      -$01,x
                    stx       ,s
L330A               clr       [,s]
                    leas      $02,s
                    rts

L330F               leas      -$06,s
                    ldd       #$FFFF
                    std       ,s
                    ldd       #$0000
                    std       $02,s
                    lda       ,u
                    lbsr      L1250               single char upper to lower case conversion
                    cmpa      #$61
                    bcs       L3328
                    cmpa      #$7A
                    bls       L332E
L3328               lbsr      L33C6
                    lbra      L33C1
L332E               ldb       $01,u
                    cmpb      #$20
                    beq       L3338
                    cmpb      #$00
                    bne       L3351
L3338               cmpa      #$61
                    beq       L3340
                    cmpa      #$69
                    bne       L3351
L3340               clrb
                    stb       ,s
                    stb       $01,s
                    leax      $01,u
                    stx       $02,s
                    ldb       ,x+
                    cmpb      #$20
                    bne       L3351
                    stx       $02,s
L3351               suba      #$61
                    lsla
                    ldx       >$01A9
                    ldd       a,x
                    beq       L3328
                    leax      d,x
                    clr       $04,s
L335F               lda       $04,s
                    cmpa      ,x+
                    bhi       L33B5
                    bne       L33A5
L3367               lda       ,x
                    anda      #$7F
                    sta       $05,s
                    lda       ,u
                    lbsr      L1250               single char upper to lower case conversion
                    eora      #$7F
                    cmpa      $05,s
                    bne       L33A5
                    leau      $01,u
                    inc       $04,s
                    lda       ,x
                    anda      #$80
                    beq       L33A1
                    lda       ,u
                    cmpa      #$00
                    beq       L338C
                    cmpa      #$20
                    bne       L33AB
L338C               ldd       $01,x
                    std       ,s
                    stu       $02,s
                    lda       ,u
                    cmpa      #$00
                    beq       L33C1
                    tfr       u,d
                    addd      #$0001
                    std       $02,s
                    bra       L33AB
L33A1               leax      $01,x
                    bra       L3367
L33A5               lda       ,u
                    cmpa      #$00
                    beq       L33B5
L33AB               lda       ,x+
                    bpl       L33AB
                    leax      $02,x
                    cmpa      #$00
                    bne       L335F
L33B5               ldu       $02,s
                    lbeq      L3328
                    lda       ,u
                    beq       L33C1
                    clr       -$01,u
L33C1               ldd       ,s
                    leas      $06,s
                    rts

L33C6               ldu       >L31E3,pcr          data word
                    tfr       u,x
L33CC               lda       ,x+
                    beq       L33D6
                    cmpa      #$20
                    bne       L33CC
                    clr       -$01,x
L33D6               rts

cmd_add_to_pic
L33D7               ldu       #$05B2
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
                    bsr       L3431
                    rts

cmd_add_to_pic_v
L33F7               ldu       #$05B2
                    ldx       #$0432
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
                    bsr       L3431
                    rts


L3431               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       #$05
                    clrb
                    lbsr      L4699
                    ldx       #$05B2
                    ldd       ,x
                    lbsr      L4699
                    ldd       $02,x
                    lbsr      L4699
                    ldd       $04,x
                    lbsr      L4699
                    ldu       <u0036
                    ldb       $02,x
                    stb       $0E,u
                    ldb       $01,x
                    stb       $0A,u
                    ldb       ,x
                    lbsr      L5DD8
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
                    lbsr      L15F5
                    ldx       #$05B2
                    lda       $05,x
                    anda      #$0F
                    bne       L3490
                    lda       #$08
                    sta       <$26,u
L3490               lda       $05,x
                    sta       <$24,u
                    lbsr      L057D

                    ldd       <u0036
                    pshs      d
                    lda       #$0F                obj_add_pic_pri
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    lbsr      L058A

                    ldd       <u0036
                    pshs      d
                    lda       #$1B
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

L34C1               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

L34C8               fdb       $0000

L34CA               leau      >L34C1,pcr          7 byte table
                    ldd       #$0000
                    std       ,u
                    rts

pic_find
L34D4               leau      >L34C1,pcr          7 byte table
L34D8               stu       >L34C8,pcr          data word
                    ldu       ,u
                    beq       L34E4
                    cmpb      $02,u
                    bne       L34D8
L34E4               rts


cmd_load_pic
L34E5               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L34F0
                    rts

L34F0               leas      -$05,s
                    stb       ,s
                    bsr       L34D4
                    cmpu      #$0000
                    bne       L3542
                    ldd       <u000A
                    std       $03,s
                    lbsr      L057D
                    lda       #$02
                    ldb       ,s
                    lbsr      L4699
                    leau      >L34C1,pcr          7 byte table
                    ldx       >L34C8,pcr          data word
                    beq       L3521
                    ldd       #$0007
                    lbsr      L2730
                    stu       ,x
                    ldd       #$0000
                    std       ,u
L3521               ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      L4DA8
                    ldx       #$0000
                    lbsr      L4966
                    beq       L3538
                    ldx       $01,s
                    std       $05,x
                    stu       $03,x
L3538               lbsr      L058A
                    ldd       $03,s
                    lbsr      L27AF
                    ldu       $01,s
L3542               leas      $05,s
                    rts

cmd_draw_pic
L3545               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L3550
                    rts

L3550               leas      -$01,s
                    stb       ,s
                    stb       >X0241              state.pic_num
                    lbsr      L34D4
                    cmpu      #$0000
                    bne       L3567
                    lda       #$12
                    ldb       ,s
                    lbsr      L10CE
L3567               ldd       $03,u
                    std       >X0551              given_pic_data
                    pshs      u
                    lda       #$04
                    ldb       $02,s
                    lbsr      L4699
                    lbsr      L057D

                    lda       #$06                render_pic()
                    sta       <u0021              save the offset
                    ldx       <u0028              set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    lbsr      L058A
                    clr       >X0100              pic_visible = 0
                    leas      $01,s
                    rts

cmd_overlay_pic
L358C               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L3597
                    rts

* args passed in d ?

pic_overlay
L3597               leas      -$01,s              make room on the stack
                    stb       ,s                  save pic_num on stack
                    stb       >X0241              store at state.pic_num
                    lbsr      L34D4               pic_find() returns a pointer in u
                    cmpu      #$0000              did we find one?
                    bne       L35AE               yes we found one move on
*                         did find one
                    lda       #$12                load the error code
                    ldb       ,s                  and the pic_num
                    lbsr      L10CE               call set_agi_error

L35AE               ldd       $03,u               get the data
                    std       >X0551              stow at given_pic_data
                    pshs      u
                    lda       #$08
                    ldb       $02,s               load pic_num
                    lbsr      L4699               script_write

                    lbsr      L057D
                    lda       #$09                render_pic()
                    sta       <u0021              save the offset
                    ldx       <u0028              set up the remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    lbsr      L058A
                    lbsr      L05A9
                    clr       >X0100              pic_visible = 0
                    leas      $01,s
                    rts

cmd_show_pic
L35D6               lda       >X01B0              flag_reset(F15_PRINTMODE)
                    anda      #$FE
                    sta       >X01B0

                    lbsr      L3997               cmd_close_window(0)
                    lbsr      L2C01               gfx_picbuff_update()
                    lda       #$01
                    sta       >X0100              set pic_visible to 1
                    rts

cmd_discard_pic
L35EA               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L35F5
                    rts

L35F5               leas      -$03,s
                    stb       ,s
                    lbsr      L34D4
                    ldb       ,s
                    cmpu      #$0000
                    bne       L3609
                    lda       #$15
                    lbsr      L10CE
L3609               stu       $01,s
                    lda       #$06
                    ldb       ,s
                    lbsr      L4699
                    ldu       >L34C8,pcr          data word
                    ldd       #$0000
                    std       ,u
                    lbsr      L057D
                    ldu       $01,s
                    stu       <u0055
                    lda       $05,u
                    ldu       $03,u
                    lbsr      L278F
                    stu       <u004F
                    lbsr      L058A
                    lbsr      L2786
                    leas      $03,s
                    rts

cmd_position
L3634               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldd       ,y++
                    std       $03,u
                    std       <$1A,u
                    rts

cmd_position_v
L3645               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    std       $03,u
                    std       <$1A,u
                    rts

cmd_get_position
L3664               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       $03,u
                    sta       ,x
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       $04,u
                    sta       ,x
                    rts

cmd_reposition
L3682               leas      -$02,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    sex
                    std       ,s
                    clra
                    ldb       $03,u
                    addd      ,s
                    bpl       L36A8
                    clrb
L36A8               stb       $03,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    sex
                    std       ,s
                    clra
                    ldb       $04,u
                    addd      ,s
                    bpl       L36BD
                    clrb
L36BD               stb       $04,u
                    lbsr      L15F5
                    leas      $02,s
                    rts

cmd_reposition_to
L36C5               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldd       ,y++
                    std       $03,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lbsr      L15F5
                    rts

cmd_reposition_to_v
L36DE               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    std       $03,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lbsr      L15F5
                    rts

cmd_obj_on_water
L3705               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$01
                    sta       <$25,u
                    rts

cmd_obj_on_land
L3717               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$08
                    sta       <$25,u
                    rts

cmd_obj_on_anything
L3729               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$25,u
                    anda      #$F6
                    sta       <$25,u
                    rts

cmd_set_horizon
L373B               lda       ,y+
                    sta       >$01D7
                    rts

cmd_ignore_horizon
L3741               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$08
                    sta       <$26,u
                    rts

cmd_observe_horizon
L3753               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u

                    anda      #$F7
                    sta       <$26,u
                    rts


L3765               fcc       'Message too verbose:'
                    fcb       C$LF,C$LF
                    fcc       '"%s..."'
                    fcb       C$LF,C$LF
                    fcc       'Press CTRL-BREAK to continue.'
                    fcb       C$NULL


L37A2               fcb       $FF
L37A3               fcb       $FF
L37A4               fcb       $FF

cmd_print
L37A5               ldb       ,y+
                    lbsr      L3B58
                    bsr       L37F2               message_box()
                    rts

cmd_print_v
L37AD               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    lbsr      L3B58
                    bsr       L37F2               message_box()
                    rts

cmd_print_at
L37BB               ldb       ,y+
                    bsr       L37CB
                    rts

cmd_print_at_v
L37C0               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L37CB
                    rts


L37CB               lda       ,y+
                    sta       >L37A3,pcr          data byte iniz to FF
                    lda       ,y+
                    sta       >L37A2,pcr          data byte iniz to FF
                    lda       ,y+
                    bne       L37DD
                    lda       #$1E
L37DD               sta       >L37A4,pcr          data byte iniz to FF
                    lbsr      L3B58
                    bsr       L37F2               message_box()
                    ldd       #$FFFF
                    sta       >L37A4,pcr          data byte iniz to FF
                    std       >L37A2,pcr          data byte iniz to FF
L37F1               rts

message_box
L37F2               leas      -$05,s              make room on stack
                    ldd       #$0000              clear d and push on stack
                    pshs      d                   0
                    ldd       #$0000              clear d and push on stack
                    pshs      d
                    ldd       #$0000              clear d and push on stack
                    pshs      d
                    pshs      u                   push ourcurrent u pntr
                    lbsr      L3868               now the 4 argumnets are loaded call message_box_draw
                    leas      $08,s               reset stack pntr

L380A               lda       >X01B0              load state.flag
                    anda      #$01                flag_test(F15_PRINTMODE)
                    beq       L381D               if not set move on
                    lda       >X01B0              flag_reset(F15_PRINTMODE)
                    anda      #$FE
                    sta       >X01B0
                    lda       #$01                set up a with a 1
                    bra       L3865               go clean up stack and leave

L381D               lda       >$0447
                    bne       L3832
                    lda       #$01
                    sta       ,s
                    lbsr      L1361
                    cmpa      #$01
                    beq       L3860
                    clra
                    sta       ,s
                    bra       L3860
L3832               ldb       #$0A
                    mul
                    orcc      #IntMasks           $50
                    addd      >$024B
                    std       $03,s
                    ldd       >$0249
                    andcc     #^IntMasks          $AF
                    bcc       L3846
                    addd      #$0001
L3846               std       $01,s

L3848               ldd       $01,s
                    cmpd      >$0249
                    blt       L3860
                    bgt       L385A
                    ldd       $03,s
                    cmpd      >$024B
                    bls       L3860
L385A               lbsr      L134E
                    tsta
                    bmi       L3848
L3860               lbsr      L3997               cmd_close_window
                    lda       ,s

L3865               leas      $05,s               clean up stack
                    rts

message_box_draw
L3868               leas      >-$02BC,s
                    lbsr      L3997               cmd_close_window
                    lbsr      L464E
                    lbsr      L47AA
                    clra
                    ldb       #$0F
                    lbsr      L45BA
                    ldb       >L37A4,pcr          data byte iniz to FF
                    cmpb      #$FF
                    bne       L3891
                    tst       >$02C3,s
                    bne       L3899
                    ldb       #$1E
                    stb       >$02C3,s
                    bra       L3899
L3891               lda       >L37A4,pcr          data byte iniz to FF
                    sta       >$02C3,s
L3899               leax      ,s
                    ldd       >$02C2,s
                    pshs      b,a
                    ldd       >$02C0,s
                    pshs      b,a
                    pshs      x
                    lbsr      L39B5
                    leas      $06,s
                    tst       >$02C5,s
                    beq       L38C4
                    lda       >$02C3,s
                    sta       >$0159
                    lda       >$02C1,s
                    beq       L38C4
                    sta       >$015C
L38C4               lda       #$13
                    cmpa      >$015C
                    bcc       L38F9
                    ldx       >$02BE,s
                    lda       <$14,x
                    clr       <$14,x
                    pshs      x,a
                    leau      >L3765,pcr          to verbose message
                    leax      >$025B,s
                    ldd       >$02C1,s
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L3C21
                    leas      $06,s
                    puls      x,a
                    sta       <$14,x
                    stu       >$02BE,s
                    bra       L3899
L38F9               lda       >$015C
                    ldb       #$08
                    mul
                    addb      #$0A
                    stb       >$017C
                    lda       >$0159
                    ldb       #$04
                    mul
                    addb      #$0A
                    stb       >$017D
                    lda       >L37A3,pcr          data byte iniz to FF
                    bpl       L391D
                    lda       #$13
                    suba      >$015C
                    lsra
                    adda      #$01
L391D               adda      >$0242
                    sta       >$0176
                    adda      >$015C
                    deca
                    sta       >$0178
                    lda       >L37A2,pcr          data byte iniz to FF
                    bpl       L3936
                    lda       #$28
                    suba      >$0159
                    lsra
L3936               sta       >$0177
                    sta       >$017B
                    adda      >$0159
                    sta       >$0179
                    lda       >$0176
                    ldb       >$0177
                    std       <u0040
                    lda       #$04
                    mul
                    subb      #$05
                    stb       >$017E
                    lda       >$0178
                    inca
                    suba      >$0242
                    ldb       #$08
                    mul
                    addb      #$04
                    stb       >$017F

                    ldd       #$040F
                    pshs      d
                    ldd       >$017C
                    pshs      d
                    ldd       >$017E
                    pshs      d
                    lda       #$0C
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up stack

                    lda       #$01
                    sta       >$0180
                    leax      ,s
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    clr       >$017B
                    lbsr      L47BE
                    lbsr      L4663
                    leas      >$02BC,s
                    rts

cmd_close_window
L3997               tst       >$0180
                    beq       L39B4

                    ldd       >$017C
                    pshs      d
                    ldd       >$017E
                    pshs      d
                    lda       #$03
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $04,s               clean up the stack

                    clr       >$0180
L39B4               rts

L39B5               ldd       #$0000
                    sta       >$015C
                    sta       >X0157
                    sta       >$0159
                    std       >X0155
                    lda       $07,s
                    sta       >$0158
                    ldu       $04,s
                    beq       L39DD
                    ldd       $02,s
                    pshs      b,a
                    pshs      u
                    lbsr      L39E0
                    leas      $04,s
                    clr       ,u
                    lbsr      L3C09
L39DD               ldx       $02,s
                    rts

L39E0               leas      -$02,s
                    pshs      x
                    ldx       $06,s
                    ldu       $08,s
                    tst       ,x
                    lbeq      L3B53
                    lda       >$015C
                    cmpa      #$13
                    lbhi      L3B53
L39F7               lda       >X0157
                    cmpa      >$0158
                    lbcc      L3B00
                    lda       ,x
                    lbeq      L3B53
                    cmpa      >X0101
                    bne       L3A10
                    tst       ,x+
                    bra       L3A24
L3A10               cmpa      #$25
                    beq       L3A2D
                    cmpa      #$0A
                    bne       L3A1D
                    lbsr      L3C09
                    bra       L3A27
L3A1D               cmpa      #$20
                    bne       L3A24
                    stu       >X0155
L3A24               inc       >X0157
L3A27               lda       ,x+
                    sta       ,u+
                    bra       L39F7
L3A2D               ldd       ,x++
                    cmpb      #$77
                    beq       L3A61
                    cmpb      #$73
                    beq       L3A77
                    cmpb      #$6D
                    beq       L3A86
                    cmpb      #$67
                    beq       L3A98
                    cmpb      #$76
                    lbeq      L3ACE
                    cmpb      #$6F
                    bne       L39F7
                    stu       $08,s
                    lbsr      L3BF4
                    clra
                    ldu       #$0432
                    lda       d,u
                    ldb       #$03
                    mul
                    addd      #$0000
                    ldu       <u0038
                    ldu       d,u
                    lbra      L3AF0
L3A61               stu       $08,s
                    lbsr      L3BF4
                    decb
                    bmi       L39F7
                    cmpb      >$015A
                    bcc       L39F7
                    lslb
                    ldu       #$0181
                    leau      [b,u]
                    lbra      L3AF0
L3A77               stu       $08,s
                    lbsr      L3BF4
                    lda       #$28
                    mul
                    addd      #X0252              state.string
                    tfr       d,u
                    bra       L3AF0
L3A86               stu       $08,s
                    lbsr      L3BF4
                    lbsr      L3B58
                    cmpu      #$0000
                    lbeq      L39F7
                    bra       L3AF0
L3A98               stu       $08,s
                    ldd       <u0062
                    std       $02,s
                    clrb
                    lbsr      L2542
                    stu       <u0062
                    ldd       $04,u
                    lbsr      L27AF
                    lbsr      L3BF4
                    lbsr      L3B58
                    cmpu      #$0000
                    beq       L3AC0
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      L39E0
                    leas      $04,s
L3AC0               ldu       $02,s
                    stu       <u0062
                    ldd       $04,u
                    lbsr      L27AF
                    ldu       $08,s
                    lbra      L39F7
L3ACE               stu       $08,s
                    lbsr      L3BF4
                    ldu       #$0432
                    clra
                    ldb       d,u
                    pshs      x
                    lbsr      L11C4
                    tfr       x,u
                    puls      x
                    lda       ,x
                    cmpa      #$7C
                    bne       L3AF0
                    leax      $01,x
                    lbsr      L3BF4
                    lbsr      L121F
L3AF0               ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      L39E0
                    leas      $04,s
                    stu       $08,s
                    lbra      L39F7
L3B00               ldd       >X0155
                    bne       L3B11
                    lda       #$0A
                    sta       ,u+
                    stu       $08,s
                    lbsr      L3C09
                    lbra      L39F7
L3B11               clr       ,u
                    tfr       u,d
                    subd      >X0155
                    negb
                    addb      >X0157
                    stb       >X0157
                    lbsr      L3C09
                    pshs      x
                    ldx       >X0155
                    lda       #$0A
                    sta       ,x+
L3B2B               lda       ,x+
                    cmpa      #$20
                    beq       L3B2B
                    leax      -$01,x
                    ldu       >X0155
                    leau      $01,u
                    lbsr      L1152
                    ldd       #$0000
                    std       >X0155
L3B41               lda       ,x+
                    beq       L3B4A
                    inc       >X0157
                    bra       L3B41
L3B4A               leau      -$01,x
                    stu       $0A,s
                    puls      x
                    lbra      L39F7
L3B53               puls      x
                    leas      $02,s
                    rts

L3B58               leas      -$01,s
                    ldu       <u0062
                    cmpb      $03,u
                    bls       L3B67
                    ldd       #$0000
                    tfr       d,u
                    bra       L3B79
L3B67               ldu       $0A,u
                    stb       ,s
                    clra
                    lslb
                    rola
                    ldd       d,u
                    bne       L3B79
                    ldb       ,s
                    lda       #$0E
                    lbsr      L10CE
L3B79               exg       a,b
                    leau      d,u
                    leas      $01,s
                    rts

cmd_display
L3B80               leas      >-$03E8,s           make room for a thousand bytes the message
                    lbsr      L47AA               push_row_col
                    ldd       ,y++                get the row and col from the input
                    std       <u0040              stow it as row,col
                    ldb       ,y+
                    bsr       L3B58               goto_row_col
                    leax      ,s
                    ldd       #$0028              load a 40
                    pshs      d
                    pshs      u
                    pshs      x
                    lbsr      L39B5               agi_printf ?? or str_wordwrap
                    leas      $06,s               clean up the stack

                    leax      ,s
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s

                    lbsr      L47BE               pop_row_col
                    leas      >$03E8,s            cleanup the stack
                    rts

cmd_display_v
L3BB0               leas      >-$03E8,s
                    lbsr      L47AA
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    std       <u0040
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       L3B58
                    leax      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L39B5
                    leas      $06,s
                    leax      ,s
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    lbsr      L47BE
                    leas      >$03E8,s
                    rts

L3BF4               clrb
L3BF5               lda       ,x
                    cmpa      #$30
                    bcs       L3C08
                    cmpa      #$39
                    bhi       L3C08
                    lda       #$0A
                    mul
                    subb      #$30
                    addb      ,x+
                    bra       L3BF5
L3C08               rts

L3C09               inc       >$015C
                    lda       >X0157
                    clr       >X0157
                    cmpa      >$0159
                    bls       L3C1A
                    sta       >$0159
L3C1A               rts

L3C1B               fdb       $0000
L3C1D               fcb       $00
L3C1E               fcb       $00
L3C1F               fdb       $0000

L3C21               clr       >L3C1D,pcr          clear data byte
                    ldd       $02,s
                    std       >L3C1B,pcr          store at data word
                    ldx       $04,s
                    leau      $06,s
                    bsr       L3C57
                    ldu       $02,s
                    rts

L3C34               leas      <-$2A,s
                    clr       >L3C1E,pcr          data byre
                    lda       #$01
                    sta       >L3C1D,pcr          data byte
                    leax      ,s
                    stx       >L3C1F,pcr          data word
                    stx       >L3C1B,pcr          store at data word
                    ldx       <$2C,s
                    leau      <$2E,s
                    bsr       L3C57
                    leas      <$2A,s
                    rts

L3C57               lda       ,x+
                    beq       L3CCA
                    cmpa      #$25
                    beq       L3C63
                    bsr       L3CCA
                    bra       L3C57
L3C63               lda       ,x+
                    cmpa      #$73
                    bne       L3C6F
                    ldd       ,u++
                    pshs      u,x
                    bra       L3CB9
L3C6F               cmpa      #$64
                    bne       L3C89
                    tst       ,u
                    bpl       L3C9C
                    lda       #$2D
                    bsr       L3CCA
                    ldd       #$0000
                    subd      ,u++
                    pshs      u,x
                    lbsr      L11C4
                    tfr       x,d
                    bra       L3CB9
L3C89               cmpa      #$75
                    beq       L3C9C
                    cmpa      #$78
                    bne       L3CA7
                    ldd       ,u++
                    pshs      u,x
                    lbsr      L11DC
                    tfr       x,d
                    bra       L3CB9
L3C9C               ldd       ,u++
                    pshs      u,x
                    lbsr      L11C4
                    tfr       x,d
                    bra       L3CB9
L3CA7               cmpa      #$63
                    bne       L3CB1
                    ldd       ,u++
                    bsr       L3CCA
                    bra       L3C57
L3CB1               leax      -$01,x
                    lda       -$01,x
                    bsr       L3CCA
                    bra       L3C57
L3CB9               tfr       d,x
L3CBB               lda       ,x+
                    lbne      L3CC6
                    puls      u,x
                    lbra      L3C57
L3CC6               bsr       L3CCA
                    bra       L3CBB
L3CCA               pshs      u,x
                    ldu       >L3C1B,pcr          store at data word
                    sta       ,u+
                    stu       >L3C1B,pcr          store at data word
                    tst       >L3C1D,pcr          data byte
                    beq       L3D1F
                    tsta
                    beq       L3CEF
                    cmpa      #$0A
                    beq       L3CEF
                    cmpa      #$0D
                    beq       L3CEF
                    lda       #$01
                    sta       >L3C1E,pcr          data byre
                    bra       L3D1F
L3CEF               tst       >L3C1E,pcr          data byre
                    beq       L3D11
                    clr       ,-u
                    pshs      a

                    ldd       >L3C1F,pcr          data word
                    pshs      d
                    lda       #$0F
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    clra
                    sta       >L3C1E,pcr          data byre
                    puls      a
L3D11               tsta
                    beq       L3D17
                    lbsr      L4734
L3D17               ldu       >L3C1F,pcr          data word
                    stu       >L3C1B,pcr          store at data word
L3D1F               puls      u,x
                    rts

cmd_set_priority
L3D22               lda       ,y+                 get the byet passed in and bump y
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u                 u now is a pointer to a VIEW struct
                    lda       <$26,u              load flag
                    ora       #O_PRIFIXED         or that with the prifixed flag so agi can't change it
                    sta       <$26,u              stow it back
                    lda       ,y+                 get the next byte bump y
                    sta       <$24,u              stow that as the priority
                    rts

cmd_release_priority
L3D39               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$FB
                    sta       <$26,u
                    rts

cmd_get_priority
L394B               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$24,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    sta       ,x
                    rts

cmd_set_priority_v
L3D60               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$04
                    sta       <$26,u
                    ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       ,x
                    sta       <$24,u
                    rts

L3D7D               leas      -$09,s
                    clr       ,s
                    ldd       <u008B
                    bne       L3D94
                    leax      $03,s
                    os9       F$Time
                    ldd       $07,s
                    addd      $05,s
                    addd      $03,s
                    orb       #$01
                    std       <u008B
L3D94               lda       #$4D
                    mul
                    std       $01,s
                    ldb       <u008B
                    lda       #$4D
                    mul
                    addd      ,s
                    std       ,s
                    lda       #$7C
                    ldb       <u008C
                    mul
                    addd      ,s
                    std       ,s
                    ldd       $01,s
                    addd      #$0001
                    std       <u008B
                    eorb      <u008B
                    leas      $09,s
                    rts


L3DB7               fcc       'Press ENTER to start a new'
                    fcb       C$LF
                    fcc       'game.'
                    fcb       C$LF,C$LF
                    fcc       'Press CTRL-BREAK to continue'
                    fcb       C$LF
                    fcc       'with this game.'
                    fcb       C$NULL

cmd_restart_game
L3E06               leas      -$01,s
                    lbsr      L5B7A               input_edit_on
                    lda       >$01B1
                    anda      #$80
                    bne       L3E1B
                    leau      >L3DB7,pcr          new game message
                    lbsr      L37F2
                    beq       L3E5D
L3E1B               lbsr      L5B26
                    lda       >$01B0
                    anda      #$40
L3E23               sta       ,s
                    lbsr      L2778
                    lbsr      L21CC
                    lbsr      L4BBA               volumes_close
                    lda       >$01AF
                    ora       #$02
                    sta       >$01AF
                    lda       ,s
L3E38               beq       L3E42
                    lda       >$01B0
L3E3D               ora       #$40
                    sta       >$01B0
L3E42               orcc      #IntMasks           $50
                    ldd       #$0000
                    std       >$0249
                    std       >$024B
                    andcc     #^IntMasks          $AF
                    ldb       <u006A
                    beq       L3E56
                    lbsr      L2571
L3E56               lbsr      L2902
                    ldy       #$0000
L3E5D               lbsr      L5B69
                    leas      $01,s
                    rts

* cmd_restore_game text strings
L3E63               fcc       'About to restore the game'
                    fcb       C$LF
                    fcc       'described as:'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcc       'from file:'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$NULL

L3EA2               fcc       "Can't open file:"
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$NULL

L3EB6               fcc       'Error in restoring game.'
                    fcb       C$LF
                    fcc       'Press ENTER to quit.'
                    fcb       C$LF
                    fcb       C$NULL


L3EE5               fcc       'Press ENTER to continue.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to cancel.'
                    fcb       C$NULL

L3F1A               fcb       $00


* cmd_restore_game (state_io.c)

cmd_restore_game
L3F1B               leas      >-$00FD,s
                    sty       ,s                  code_ret (arg passed in)
                    lda       #$01
                    sta       >X0102              clock_state?
                    lda       >$0101              msgstate.newline_char
                    sta       $02,s               save original
                    lda       #'@                 $40 load value for msgstate.newline_char
                    sta       >$0101              save it
L3F31               ldd       #$0072
                    pshs      d
                    lbsr      L1C49
                    leas      $02,s
                    tsta
                    lbeq      L4040
                    lda       >L41E5,pcr          FILE struct datablock ???
                    bne       L3F86
                    leau      >L3EE5,pcr          continue/cancel message
                    pshs      u
L3F4C               leau      >L17E9,pcr          64 byte data block
L3F50               pshs      u
                    leau      >L17CA,pcr          31 byte data block
                    pshs      u
                    leax      >L3E63,pcr          about to restore message
                    leau      $09,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $0A,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3868               message_box_draw
                    leas      $08,s
                    lbsr      L1361
                    cmpa      #$00
                    lbeq      L4040
L3F86               lda       #$01
                    leax      >L17E9,pcr          64 byte data block
                    lbsr      L139A               Open path routine
                    bcc       L3FB2
                    leau      >L17E9,pcr          64 byte data block
                    pshs      u
                    leau      >L17CA,pcr          31 byte data block
                    pshs      u
                    leax      >L3EA2,pcr          can't open file message
                    leau      $07,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $08,s
                    lbsr      L37F2
                    lbra      L4040
L3FB2               sta       >L3F1A,pcr          data byte
                    clrb
                    ldx       #$0000
                    ldu       #$001F
                    lbsr      L13E2
                    ldd       #$01AD              state.block_state
                    pshs      b,a
                    lbsr      L4053
                    leas      $02,s
                    beq       L4003
                    ldd       <u0030
                    pshs      b,a
                    lbsr      L4053
                    leas      $02,s
                    beq       L4003
                    ldd       <u0038
                    pshs      b,a
                    lbsr      L4053
                    leas      $02,s
                    beq       L4003
                    ldx       <u0038
                    ldd       <u003A
                    leau      d,x
                    lbsr      L1061
                    ldd       >$05AF
                    pshs      b,a
                    lbsr      L4053
                    leas      $02,s
                    beq       L4003
                    ldd       #$0554
                    pshs      b,a
                    lbsr      L4053
                    leas      $02,s
                    bne       L401A
L4003               lda       >L3F1A,pcr          data byte
                    lbsr      L13D6               Close path routine
                    leau      >L3EB6,pcr          Error in restoring game message
                    lbsr      L37F2

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

L401A               lda       >L3F1A,pcr          data byte
                    lbsr      L13D6               Close path routine
                    lda       >$0553
                    sta       >$044C
                    lbsr      L4084
                    lbsr      L0952               self contained call to clear 50 bytes 05BA
                    lda       >$01B0
                    ora       #$08
                    sta       >$01B0
                    lbsr      L4BBA               volumes_close
                    ldd       #$0000
                    std       ,s
                    lbsr      L2902

rest_end
L4040               lbsr      L3997               cmd_close_window
                    lda       $02,s               pull newline_org
                    sta       >$0101              save it in msgstate.newline_char
                    clr       >X0102              clock_state = 0
                    ldy       ,s                  code_ret
                    leas      >$00FD,s
                    rts

L4053               leas      -$02,s
                    lda       >L3F1A,pcr          data byte
                    leax      ,s
                    ldy       #$0002
                    lbsr      L13A6               Read routine
                    cmpd      #$0002
                    bne       L4080
                    ldy       ,x
                    sty       ,s
                    lda       >L3F1A,pcr          data byte
                    ldx       $04,s
                    lbsr      L13A6               Read routine
                    cmpy      ,s
                    bne       L4080
                    lda       #$01
                    bra       L4081
L4080               clra
L4081               leas      $02,s
                    rts

L4084               leas      >-$0206,s
                    leax      $06,s
                    stx       $04,s
                    lbsr      L229D
                    clr       >$05B1
                    ldu       <u0030
L4094               cmpu      <u0032
                    bcc       L40B2
                    ldd       <$25,u
                    ldx       $04,s
                    std       ,x++
                    stx       $04,s
                    bitb      #$40
                    beq       L40AD
                    andb      #$FE
                    orb       #$10
                    stb       <$26,u
L40AD               leau      <$2B,u
                    bra       L4094
L40B2               lbsr      L057D
                    lbsr      L2778
                    clr       >X0100              pic_visible = 0
                    lbsr      L46E0
L40BE               lbsr      L46F5
                    cmpu      #$0000
                    beq       L4137
                    ldd       ,u
                    cmpa      #$00
                    bne       L40D5
                    lbsr      L2571
                    lbsr      L26B4
                    bra       L40BE
L40D5               cmpa      #$01
                    bne       L40E0
                    lda       #$01
                    lbsr      L5D3C
                    bra       L40BE
L40E0               cmpa      #$02
                    bne       L40E9
                    lbsr      L34F0
                    bra       L40BE
L40E9               cmpa      #$03
                    bne       L40F2
                    lbsr      L508C
                    bra       L40BE
L40F2               cmpa      #$04
                    bne       L40FB
                    lbsr      L3550
                    bra       L40BE
L40FB               cmpa      #$05
                    bne       L411C
                    lbsr      L46F5
                    ldd       ,u
                    ldx       #$05B2
                    std       ,x
                    lbsr      L46F5
                    ldd       ,u
                    std       $02,x
                    lbsr      L46F5
                    ldd       ,u
                    std       $04,x
                    lbsr      L3431
                    bra       L40BE
L411C               cmpa      #$06
                    bne       L4125
                    lbsr      L35F5
                    bra       L40BE
L4125               cmpa      #$07
                    bne       L412E
                    lbsr      L5FA1
                    bra       L40BE
L412E               cmpa      #$08
                    bne       L40BE
                    lbsr      L3597
                    bra       L40BE
L4137               lda       #$01
                    sta       >$05B1
                    ldu       <u0032
L413E               leau      <-$2B,u
                    cmpu      <u0030
                    bcs       L418D
                    ldx       $04,s
                    ldd       ,--x
                    stx       $04,s
                    std       ,s
                    stu       $02,s
                    ldb       $05,u
                    lbsr      L5D17
                    leax      ,x
                    beq       L415E
                    ldb       $05,u
                    lbsr      L5DD8
L415E               ldd       ,s
                    bitb      #$40
                    beq       L413E
                    bitb      #$01
                    beq       L4188
                    lda       $02,u
                    lbsr      L0F59
                    ldu       $02,s
                    lda       <$22,u
                    cmpa      #$02
                    bne       L417B
                    lda       #$FF
                    sta       <$29,u
L417B               ldd       ,s
                    bitb      #$10
                    bne       L4188
                    lbsr      L05F8
                    ldu       $02,s
                    ldd       ,s
L4188               std       <$25,u
                    bra       L413E
L418D               lbsr      L5B7A               input_edit_on
                    lbsr      L5B26
                    lbsr      L2C01
                    lda       #$01
                    sta       >X0100              pic_visible = 1
                    lbsr      L54F7
                    lbsr      L5BAD
                    leas      >$0206,s
                    rts

L41A6               ldd       #$000E
                    lbsr      L2730
                    ldd       #$0000
                    std       ,u
                    std       $02,u
                    stx       $04,u
                    stu       <$16,x
                    ldd       <$1C,x
                    std       $08,u
                    ldd       $03,x
                    bita      #$01
                    beq       L41C6
                    deca
                    inc       $08,u
L41C6               subb      <$1D,x
                    incb
                    std       $06,u
                    ldd       $08,u
                    bita      #$01
                    beq       L41D5
                    inca
                    sta       $08,u
L41D5               mul
                    tfr       u,x
                    lbsr      L26FD
                    lbsr      L279C
                    std       $0C,x
                    stu       $0A,x
                    tfr       x,u
                    rts

*  nagi has 50 bytes
state_name_auto
L41E5               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

L4204               fcc       'About to save the game'
                    fcb       C$LF
                    fcc       'described as:'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcc       'in file:'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$NULL

L423E               fcc       'The directory'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$LF
                    fcc       'is full.'
                    fcb       C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL

L4271               fcc       'The disk is full.'
                    fcb       C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL

L429C               fcb       $00


cmd_set_simple
L429D               lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #X0252              state.string
                    leax      d,x                 from address
                    leau      >L41E5,pcr          state_name_auto
                    ldd       #$001F              load d with 31
                    lbsr      L115D               copy routine
                    rts                           return

cmd_save_game
L42B2               leas      >-$00FE,s
                    sty       ,s
                    clr       $02,s
                    lda       #$01
                    sta       >X0102
                    lda       >$0101
                    sta       $03,s
                    lda       #$40
                    sta       >$0101
                    ldd       #$0073
                    pshs      b,a
L42CF               lbsr      L1C49
                    leas      $02,s
                    tsta
                    lbeq      L43D9
L42D9               lda       >L41E5,pcr          FILE struct data block ???
                    bne       L431F
L42DF               leau      >L3EE5,pcr          continue / cancel message
                    pshs      u
                    leau      >L17E9,pcr          64 byte data block
                    pshs      u
                    leau      >L17CA,pcr          31 byte data block
                    pshs      u
                    leax      >L4204,pcr          about to save game msg
                    leau      $0A,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $0A,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      L3868               message_box_draw
                    leas      $08,s
                    lbsr      L1361
                    cmpa      #$00
                    lbeq      L43D9
L431F               lda       #$02
                    ldb       #$03
                    leax      >L17E9,pcr          64 byte data block
                    lbsr      L1388               Create routine
                    bcc       L4347
                    leau      >L17AB,pcr          31 byte data block
                    pshs      u
                    leax      >L423E,pcr          dir is full msg
                    leau      $06,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $06,s
                    lbsr      L37F2
                    lbra      L43D9
L4347               sta       >L429C,pcr          data byte
                    leax      >L17CA,pcr          31 byte data block
                    ldy       #$001F
                    lbsr      L13B8               Write routine
                    cmpd      #$001F
                    bne       L43BB
                    ldd       #$0385
                    pshs      b,a
                    ldd       #$01AD              state.block_state
                    pshs      b,a
                    lbsr      L43F9
                    leas      $04,s
                    beq       L43BB
                    ldd       <u0034
                    pshs      b,a
                    ldd       <u0030
                    pshs      b,a
                    lbsr      L43F9
                    leas      $04,s
                    beq       L43BB
                    inc       $02,s
                    ldx       <u0038
                    ldd       <u003A
                    leau      d,x
                    lbsr      L1061
                    ldd       <u003A
                    pshs      b,a
                    ldd       <u0038
                    pshs      b,a
                    lbsr      L43F9
                    leas      $04,s
                    beq       L43BB
                    lda       >$0246
                    ldb       #$02
                    mul
                    pshs      b,a
                    ldd       >$05AF
                    pshs      b,a
                    lbsr      L43F9
                    leas      $04,s
                    beq       L43BB
                    lbsr      L2691
                    pshs      x
                    ldd       #$0554
                    pshs      b,a
                    lbsr      L43F9
                    leas      $04,s
                    bne       L43D2
L43BB               lda       >L429C,pcr          data byte
                    lbsr      L13D6               Close path routine
                    leax      >L17E9,pcr          64 byte data block
                    lbsr      L13CA               Delete routine
                    leau      >L4271,pcr          the disk is full msg
                    lbsr      L37F2
                    bra       L43D9
L43D2               lda       >L429C,pcr          data byte
                    lbsr      L13D6               Close path routine
L43D9               lda       $02,s
                    beq       L43E6
                    ldx       <u0038
                    ldd       <u003A
                    leau      d,x
                    lbsr      L1061
L43E6               lbsr      L3997               cmd_close_window
                    lda       $03,s
                    sta       >$0101
                    clr       >X0102
                    ldy       ,s
                    leas      >$00FE,s
                    rts

L43F9               lda       >L429C,pcr          data byte
                    leax      $04,s
                    ldy       #$0002
                    lbsr      L13B8               Write routine
                    cmpd      #$0002
                    bne       L4421
                    lda       >L429C,pcr          data byte
                    ldx       $02,s
                    ldy       $04,s
                    lbsr      L13B8               Write routine
                    cmpd      $04,s
                    bne       L4421
                    lda       #$01
                    bra       L4422
L4421               clra
L4422               rts

*save_drive
L4423               fcb       $00                 drive number to hold working disk

L4424               fcc       '%s%s'
L4428               fcc       '%ssg.%d'
                    fcb       C$NULL


L4430               leas      -$05,s
                    stx       ,s
                    stb       $02,s
                    ldd       #$0000
                    std       $03,s
                    leax      >L17AB,pcr          31 byte data block
                    lbsr      L113E
                    decb
                    leax      b,x
                    lda       #$2F
                    cmpa      ,-x
                    beq       L444D
                    sta       $03,s
L444D               clra
                    ldb       $02,s
                    pshs      b,a
                    ldd       #$01CF
                    pshs      b,a
                    leax      $07,s
                    pshs      x
                    leax      >L17AB,pcr          31 byte data block
                    pshs      x
                    leax      >L4424,pcr          %s%s
                    ldu       $08,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $0C,s
                    lbsr      L1287               upper to lower string conversion
                    tfr       u,x
                    leas      $05,s
                    rts

* (state_info.c)
L4478               leas      <-$45,s
                    clr       ,s
                    leau      ,s
                    lbsr      L1486
                    ldx       <$47,s
                    lbsr      L157C               change dir routine
                    bcs       L449E
                    clr       <$40,s
                    leau      <$40,s
                    lbsr      L1464               lib_get_disk
L4493               ldb       <$43,s
                    stb       >L4423,pcr          save_drive
                    lda       #$01
                    bra       L449F
L449E               clra
L449F               sta       <$44,s
                    leax      ,s
                    lbsr      L157C               change dir routine
                    lda       <$44,s
                    leas      <$45,s
                    rts

L44AE               leas      -$02,s
                    ldy       <u0062
                    ldd       $04,y
                    lbsr      L27AF
                    ldy       $08,y
L44BB               ldb       ,y+
L44BD               tstb
                    beq       L44D7
                    cmpb      #$FF
                    beq       L44D9
                    cmpb      #$FE
                    bne       L44D0
L44C8               ldb       ,y+
                    lda       ,y+
                    leay      d,y
                    bra       L44BB
L44D0               lbsr      L0491
                    leay      ,y
                    bne       L44BD
L44D7               bra       L4549
L44D9               ldd       #$0000
                    std       ,s
L44DE               lda       ,y+
                    cmpa      #$FC
                    bhi       L44EE
                    bne       L4502
                    lda       ,s
                    bne       L4510
                    inc       ,s
                    bra       L44DE
L44EE               cmpa      #$FF
                    bne       L44F6
                    leay      $02,y
                    bra       L44BB
L44F6               cmpa      #$FD
                    bne       L4502
                    lda       $01,s
                    eora      #$01
                    sta       $01,s
                    bra       L44DE
L4502               lbsr      L0D6E               call into eval_table index calc
                    eora      $01,s
                    clr       $01,s
                    tsta
                    bne       L4520
                    lda       ,s
                    bne       L44DE
L4510               clr       ,s
L4512               lda       ,y+
                    cmpa      #$FF
                    beq       L44C8
                    cmpa      #$FC
                    bcc       L4512
                    bsr       L4532
                    bra       L4512
L4520               lda       ,s
                    beq       L44DE
                    clr       ,s
L4526               lda       ,y+
                    cmpa      #$FC
                    bhi       L4526
                    beq       L44DE
                    bsr       L4532
                    bra       L4526
L4532               cmpa      #$0E
                    bne       L453C
                    lda       ,y+
                    lsla
                    leay      a,y
                    rts

L453C               lsla
                    lsla
                    adda      #$02
                    leax      >L0D09,pcr          jump table 2 address
                    lda       a,x
                    leay      a,y
                    rts

L4549               leas      $02,s
                    rts

* same sequence of bytes at L00E2 in sierra

L454C               fcb       $00                 composite
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


cmd_text_screen
L456C               lbsr      L5B7A               input_edit_on
                    lda       #$01                make a 1
                    sta       X05EC               stow it at chgen_textmode
                    lda       #$15
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    rts

cmd_graphics
L457E               lbsr      L5B7A               input_edit_on
                    lbsr      L45D9
                    rts

cmd_clear_lines
L4585               ldb       $02,y
                    pshs      b,a
                    ldb       $01,y
                    pshs      b,a
                    ldb       ,y
                    pshs      b,a
                    lbsr      L47DE
                    leas      $06,s
                    leay      $03,y
                    rts

cmd_clear_text_rect
L4599               ldb       $04,y
                    pshs      b,a
                    ldb       $03,y
                    pshs      b,a
                    ldb       $02,y
                    pshs      b,a
                    ldb       $01,y
                    pshs      b,a
                    ldb       ,y
                    pshs      b,a
                    lbsr      L48A1
                    leas      $0A,s
                    leay      $05,y
                    rts

cmd_set_text_attribute
L45B5               ldd       ,y++                load foreground and background in d
                    bsr       L45BA
                    rts

* this routine takes the LSB value and copies it to the MSB also
text_color
L45BA               anda      #$0F                mask the MSB off of forground
                    sta       >X024D              stow at state.text_fg
                    lsla                          shift left 4
                    lsla
                    lsla
                    lsla
                    ora       >X024D              or that with state.text_fg
                    sta       >X024D              and save it back

                    andb      #$0F                mask the MSB off of background
                    stb       >X024E              stow it at state.text.bg
                    lslb                          shift left 4
                    lslb
                    lslb
                    lslb
                    orb       >X024E              or it with state.text_bg
                    stb       >X024E              save it back
                    rts

L45D9               lda       #$00
                    sta       >$05EC

                    lda       #$09
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    lbsr      L54F7
                    lbsr      L5BAD
                    rts

cmd_config_screen
L45EE               lda       ,y
                    sta       >$0242
                    adda      #$15
                    sta       >$0240
                    lda       ,y+
                    ldb       #$08
                    mul
                    lda       #$A0
                    mul
                    std       <u002C
                    lda       ,y+
                    sta       >$01D8
                    lda       ,y+
                    sta       >$0248
                    rts

cmd_toggle_monitor
L460D               leas      -$04,s
                    pshs      y
                    leax      >L454C,pcr          data table
                    ldb       >$0553              display type
                    eorb      #$01                change display type to the other
*                          will change the type from comp<->rbg
                    stb       >$0553              save that as display_type
                    lda       #$10                16 times the type
                    mul
                    abx                           add that back to x so we use the other palette set

* This loads up the control sequence to set the pallete 1B 31 PRN CTN
*  PRN palette register 0 - 15, CTN color table 0 - 63
                    lda       #$1B                loading escape codes for writing to screen
                    sta       $02,s               put on the stack
                    lda       #$31                Palette code
                    sta       $03,s               put on the stack
                    clra                          make a zero PRN value
                    sta       $04,s               put it on the stack
                    ldy       #$0004              number of bytes to write
L4630               ldb       ,x+                 get color table value
                    stb       $05,s               put it on stack
                    pshs      x                   push our x value
                    lda       #StdOut             set path to stdout
                    leax      $04,s               start of data to write
                    os9       I$Write             send it
                    bcs       L4649               error during write clean up stack and leave
                    puls      x                   retrieve or x
                    inc       $04,s               bump the PRN value
                    lda       $04,s               grab the PRN value
                    cmpa      #$10                have we done all 16 ?
                    blo       L4630               nope go again
L4649               puls      y
                    leas      $04,s
                    rts

L464E               ldb       >$0172
                    cmpb      #$05
                    bcc       L4662
                    ldx       #$015D
                    lslb
                    abx
                    ldd       >X024D              state.text_fg/bg
                    std       ,x
                    inc       >$0172
L4662               rts

L4663               ldb       >$0172
                    ble       L4675
                    decb
                    stb       >$0172
                    ldx       #$015D
                    lslb
                    ldd       b,x
                    std       >X024D              state.text_fg/bg
L4675               rts

L4676               fdb       $0000
L4678               fdb       $0000

L467A               ldu       >$05AF
                    bne       L4691
                    lda       >$0246
                    beq       L4691
                    ldb       #$02
                    mul
                    lbsr      L2730
                    stu       >$05AF
                    ldd       <u0055
                    std       <u0053
L4691               stu       >L4676,pcr          data word
                    clr       >X0245              state.script_count
                    rts

L4699               leas      -$02,s
                    std       ,s
                    lda       >$01AF
                    anda      #$01
                    bne       L46DD
                    lda       >$05B1
                    beq       L46CF
                    clra
                    ldb       >$0246
                    lslb
                    rola
                    addd      >$05AF
                    cmpd      >L4676,pcr          data word
                    bhi       L46C0
                    lda       #$0B
                    ldb       <u0058
                    lbsr      L10CE
L46C0               ldu       >L4676,pcr          data word
                    ldd       ,s
                    std       ,u++
                    stu       >L4676,pcr          data word
                    inc       >X0245              state.script_count
L46CF               ldd       >L4676,pcr          data word
                    subd      >$05AF
                    cmpd      <u0057
                    bls       L46DD
                    std       <u0057
L46DD               leas      $02,s
                    rts

L46E0               ldd       >$05AF
                    std       >L4678,pcr          data word
                    lda       >X0245              state.script_count
                    ldb       #$02
                    mul
                    addd      >$05AF
                    std       >L4676,pcr          data word
                    rts

L46F5               ldu       #$0000
                    ldd       >L4678,pcr          data word
                    cmpd      >L4676,pcr          data word
                    bcc       L470C
                    tfr       d,u
                    addd      #$0002
                    std       >L4678,pcr          data word
L470C               rts

cmd_script_size
L470D               lda       ,y+
                    sta       >$0246
                    lbsr      L057D
                    lbsr      L467A
                    lbsr      L058A
                    rts

cmd_push_script
L471C               lda       >X0245              state.script_count
                    sta       >X0244              state.script_saved
                    rts

cmd_pop_script
L4723               clra
                    ldb       >X0244              state.script_saved
                    stb       >X0245              state.script_count
                    lslb
                    rola
                    addd      >$05AF
                    std       >L4676,pcr          data word
                    rts

* window_put_char cmd_input.c ???
L4734               leas      -$02,s
                    pshs      u,x
                    leau      $04,s
                    tsta
                    beq       L47A5
                    cmpa      #$08
                    bne       L476C
                    dec       <u0041
                    bpl       L4756
                    lda       #$00
                    sta       <u0041
                    lda       <u0040
                    cmpa      #$15
                    bls       L4756
                    deca
                    sta       <u0040
                    lda       #$27
                    sta       <u0041

L4756               ldd       #$2000
                    std       ,u
                    pshs      u
                    lda       #$0F
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    dec       <u0041
                    bra       L47A5
L476C               cmpa      #C$CR               $0D
                    beq       L4774
                    cmpa      #C$LF               $0A
                    bne       L4784
L4774               lda       <u0040
                    cmpa      #C$PAUS             $17
                    bcc       L477D
                    inca
                    sta       <u0040
L477D               lda       >$017B
                    sta       <u0041
                    bra       L47A5
L4784               clrb
                    cmpa      #$7F
                    bls       L478C

                    ldd       #$2000
L478C               std       ,u
                    pshs      u
                    lda       #$0F
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    lda       <u0041
                    cmpa      #$27
                    bls       L47A5
                    lda       #$0D
                    bsr       L4734
L47A5               puls      u,x
                    leas      $02,s
                    rts

L47AA               ldb       >$0167
                    cmpb      #$05
                    bcc       L47BD
                    ldx       #$0168
                    lslb
                    abx
                    ldd       <u0040
                    std       ,x
                    inc       >$0167
L47BD               rts

L47BE               ldb       >$0167
                    ble       L47CF
                    decb
                    stb       >$0167
                    ldx       #$0168
                    lslb
                    ldd       b,x
                    std       <u0040
L47CF               rts

L47D0               pshs      b,a
                    tfr       a,b
                    pshs      b,a
                    pshs      b,a
                    lbsr      L47DE
                    leas      $06,s
                    rts

L47DE               ldb       $07,s
                    pshs      b,a
                    lda       $07,s
                    ldb       #$27
                    pshs      b,a
                    lda       $07,s
                    ldb       #$00
                    pshs      b,a
                    lbsr      L48A1
                    leas      $06,s
                    rts

L47F4               leas      <-$2A,s
                    lda       #$17
                    cmpa      <$2D,s
                    lbcs      L489D
                    cmpa      <$2F,s
                    bcc       L4814
                    sta       <$2F,s
                    inca
                    suba      <$2D,s
                    cmpa      <$37,s
                    bcc       L4814
                    sta       <$37,s
L4814               ldb       <$37,s
                    beq       L4845
                    negb
                    incb
                    addb      <$2F,s
                    subb      <$2D,s
                    bhi       L4828
                    clr       <$37,s
                    bra       L4845
L4828               lda       <$37,s
                    pshs      d
                    lda       <$37,s
                    ldb       <$35,s
                    pshs      d
                    ldb       <$31,s
                    pshs      d
                    lda       #$12
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up sthe stack

L4845               lda       <$35,s
                    inca
                    suba      <$33,s
                    leau      ,s
                    ldb       #$20
L4850               stb       ,u+
                    deca
                    bne       L4850
                    sta       ,u
                    ldd       >X024D              state.text_fg/bg
                    pshs      b,a
                    ldb       <$33,s
                    lbsr      L45BA
                    lda       <$39,s
                    bne       L4876
                    lda       <$2F,s
                    sta       <u0040
                    nega
                    adda      <$31,s
                    inca
                    sta       <$39,s
                    bra       L487D
L4876               nega
                    adda      <$31,s
                    inca
                    sta       <u0040
L487D               lda       <$35,s
                    sta       <u0041

                    leau      $02,s
                    pshs      u
                    lda       #$0F
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    inc       <u0040
                    dec       <$39,s
                    bne       L487D
                    puls      b,a
                    std       >X024D              state.text_fg/bg
L489D               leas      <$2A,s
                    rts

L48A1               ldd       <u0040
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
                    lbsr      L47F4
                    leas      $0C,s
                    puls      b,a
                    std       <u0040
                    rts

L48C8               fcc       'Please insert disk %d, side %d'
                    fcb       C$LF
                    fcc       'and press ENTER.'
                    fcb       C$NULL

L48F8               fcc       'Please turn over the disk'
                    fcb       C$LF
                    fcc       'and press ENTER.'
                    fcb       C$NULL

L4923               fcc       'That is the wrong disk.'
                    fcb       C$LF,C$LF
                    fcb       C$NULL

L493D               fcc       '%s%s'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$NULL

L4945               fcc       'vol.%d'
                    fcb       C$NULL

L494C               fcc       "Can't find %s.%s%s"
                    fcb       C$NULL

L495F               fcb       $01
L4960               fcb       $01
L4961               fcb       $01
L4962               fcb       $00
L4963               fcb       $00
L4964               fcb       $00
L4965               fcb       $00


L4966               leas      -$06,s
                    std       ,s
                    stu       $02,s
                    stx       $04,s
L496E               bsr       L498C
                    cmpu      #$0000
L4974               bne       L4989
                    lda       >L4962,pcr          data byte
                    cmpa      #$05
                    beq       L4989
                    ldd       ,s
L4980               lbsr      L27AF
                    ldu       $02,s
                    ldx       $04,s
L4987               bra       L496E
L4989               leas      $06,s
                    rts

L498C               leas      -$0E,s
                    stu       ,s
                    stx       $02,s
                    pshs      y
                    ldu       <u004F
                    stu       $06,s
                    lda       >$0532              vol_handle_table
                    cmpa      #$FF
                    bne       L49BC
                    ldd       >L4963,pcr          data byte
                    bne       L49B9
                    ldx       [>$0089]
                    stx       >L4963,pcr          data byte
                    ldd       ,x
                    cmpd      #$0101
                    beq       L49B9
                    clrb
                    lbsr      L4AC7
L49B9               lbsr      L4B58
L49BC               ldu       $02,s
                    lda       ,u
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       $08,s
                    ldx       #$0532              vol_handle_table
                    ldb       a,x
                    cmpb      #$FF
                    bne       L4A0A
                    lbsr      L4BBA               volumes_close
                    ldb       $08,s
                    beq       L49DB
                    cmpb      >$05ED
                    bls       L49E1
L49DB               ldb       >L495F,pcr          data byte
                    stb       $08,s
L49E1               decb
                    lslb
                    ldx       <u0089
                    ldx       b,x
                    stx       >L4963,pcr          data byte
                    ldd       ,x
                    cmpa      >L4960,pcr          data byte
                    bne       L49F9
                    cmpb      >L4961,pcr          data byte
                    beq       L4A04
L49F9               lda       #$01
                    sta       >L4962,pcr          data byte
                    ldb       $08,s
                    lbsr      L4AC7
L4A04               lbsr      L4B58
                    lbra      L4AB9
L4A0A               stb       >L4965,pcr          data byte
                    clra
                    ldb       ,u
                    andb      #$0F
                    tfr       d,x
                    ldu       $01,u
                    lda       >L4965,pcr          data byte
                    clrb
                    lbsr      L13E2
                    bcs       L4A36
                    lda       >L4965,pcr          data byte
                    leax      $09,s
                    ldy       #$0005
                    lbsr      L13A6               Read routine
                    bcs       L4A36
                    cmpd      #$0005
                    beq       L4A46
L4A36               lbsr      L10E4
                    lbne      L4AB9

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

L4A46               ldd       $09,s
                    cmpd      #$1234
                    bne       L4A54
                    lda       $0B,s
                    cmpa      $08,s
                    beq       L4A73
L4A54               lbsr      L4BBA               volumes_close
                    lda       #$01
                    sta       >L4962,pcr          data byte
                    ldb       $08,s
                    lbsr      L4B1E
                    tsta
                    bne       L4A6E

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

L4A6E               lbsr      L4B58
                    bra       L4AB9
L4A73               ldb       $0C,s
                    lda       $0D,s
                    std       <u0066
                    ldu       $04,s
                    bne       L4AA1
                    lda       >$05B8
                    beq       L4A92
                    lbsr      L2786
                    cmpd      <u0066
                    bcc       L4A92
                    lda       #$05
                    sta       >L4962,pcr          data byte
                    bra       L4AB9
L4A92               ldd       <u0066
                    lbsr      L26FD
                    lbsr      L279C
                    stu       $04,s
                    std       $0E,s
                    lbsr      L27AF
L4AA1               lda       >L4965,pcr          data byte
                    ldx       $04,s
                    ldy       <u0066
                    lbsr      L13A6               Read routine
                    bcs       L4A36
                    ldu       $04,s
                    cmpd      <u0066
                    beq       L4AC0
                    lbra      L4A36
L4AB9               ldd       $06,s
                    std       <u004F
                    ldu       #$0000
L4AC0               ldd       $0E,s
                    puls      y
                    leas      $0E,s
                    rts

L4AC7               leas      <-$64,s
                    leau      ,s
                    pshs      b,a
                    pshs      u
                    lbsr      L4ADC
                    leas      $04,s
                    lbsr      L37F2
                    leas      <$64,s
                    rts

L4ADC               ldx       >L4963,pcr          data byte
                    clra
                    ldb       $05,s
                    beq       L4AF4
                    cmpb      >$05ED
                    bhi       L4AF4
                    stb       >L495F,pcr          data byte
                    decb
                    lslb
                    ldx       <u0089
                    ldx       b,x
L4AF4               ldb       $01,x
                    pshs      b,a
                    ldb       ,x
                    pshs      b,a
                    leax      >L48C8,pcr          please insert disk
                    cmpb      >L4960,pcr          data byte
                    bne       L4B12
                    ldb       $01,x
                    cmpb      >L4961,pcr          data byte
                    beq       L4B12
                    leax      >L48F8,pcr          please turn over the disk
L4B12               ldu       $06,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $08,s
                    rts

L4B1E               leas      >-$012C,s
                    pshs      b,a
                    lbsr      L1118
                    leau      $02,s
                    pshs      u
                    lbsr      L4ADC
                    leas      $04,s
                    leau      >L1082,pcr          quit msg
                    pshs      u
                    leau      $02,s
                    pshs      u
                    leau      >L4923,pcr          this is the wrong disk msg
                    pshs      u
                    leax      >L493D,pcr          %s%s
                    leau      <$6A,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $0A,s
                    lbsr      L37F2
                    leas      >$012C,s
                    rts

L4B58               leas      -$0D,s
                    ldx       >L4963,pcr          data byte
                    leax      $02,x
                    ldb       ,x
L4B62               clra
                    stx       ,s
                    andb      #$7F
                    stb       $02,s
                    leax      >L4945,pcr          vol %d
                    leau      $03,s
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $06,s
L4B7A               lda       #$01
                    leax      $03,s
                    lbsr      L139A               Open path routine
                    bcc       L4B9C
                    tstb
                    bne       L4B8C
                    clr       >L4960,pcr          data byte
                    bra       L4BB7
L4B8C               lbsr      L10E4
                    cmpa      #$00
                    bne       L4B7A

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

L4B9C               ldu       #$0532              vol_handle_table
                    ldb       $02,s
                    sta       b,u
                    ldx       ,s
                    ldb       ,x+
                    bmi       L4BAD
                    ldb       ,x
                    bra       L4B62
L4BAD               ldx       >L4963,pcr          data byte
                    ldd       ,x
                    std       >L4960,pcr          data byte
L4BB7               leas      $0D,s
                    rts

* volumes_close (res_vol.c)
L4BBA               leas      -$01,s
                    clrb
                    ldx       #$0532              vol_handle_table
L4BC0               cmpb      #$0F                There are 15 vols in kq3 (0-14)
                    bhs       L4BD8               >= 15 were finished so leave
                    stb       ,s                  save the offset
                    lda       ,x                  get the val of the vol_handle
                    cmpa      #$FF                is it flagged closed ??
                    beq       L4BD1               if so no need to close it but
*                          store stow FF there so we can inc the x
                    lbsr      L13D6               Close path routine
                    lda       #$FF                we had a good close so set the close flag
L4BD1               sta       ,x+                 stow it in the table and bump the pointer
                    ldb       ,s                  grab our index back again
                    incb                          bump it
                    bra       L4BC0               go again
L4BD8               leas      $01,s               clean up stack and were
                    rts                           back at ya

* file_load(u8 *name u8 *buff)  res_vol.c
L4BDB               leas      <-$65,s
                    pshs      y
L4BE0               lda       #$01
                    ldx       <$69,s
                    lbsr      L139A               Open path routine
                    bcc       L4C1D
                    lda       #$40
                    sta       >$0101
                    leau      >L1082,pcr          quit msg
                    pshs      u
                    leau      >L109D,pcr          try again message
                    pshs      u
                    ldd       <$6D,s
                    pshs      b,a
                    leax      >L494C,pcr          can't find msg
                    leau      $09,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $0A,s
                    lbsr      L37F2
                    bne       L4BE0

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

L4C1D               sta       $02,s
                    ldu       #$0000
                    tfr       u,x
                    ldb       #$02
                    lbsr      L13E2
                    stu       <u0066
                    ldu       #$0000
                    clrb
                    lbsr      L13E2
                    ldx       <$6B,s
                    bne       L4C57
                    ldd       <u0066
                    ldu       <$6F,s
                    beq       L4C4F
                    lbsr      L26FD
                    lbsr      L279C
                    stu       [<$6D,s]
                    std       [<$6F,s]
                    lbsr      L27AF
                    bra       L4C55
L4C4F               lbsr      L2730
                    stu       [<$6D,s]
L4C55               tfr       u,x
L4C57               lda       $02,s
                    ldy       <u0066
                    lbsr      L13A6               Read routine
                    cmpd      <u0066
                    beq       L4C74
                    lbsr      L10E4
                    cmpb      #$00
                    bne       L4C74

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

L4C74               lda       $02,s
                    lbsr      L13D6               Close path routine
                    puls      y
                    leas      <$65,s
                    rts

L4C7F               fcc       'Logics'
                    fcb       C$NULL

L4C86               fcc       'View'
                    fcb       C$NULL

L4C8B               fcc       'Picture'
                    fcb       C$NULL

L4C93               fcc       'Sound'
                    fcb       C$NULL

L4C99               fcc       'logDir'
                    fcb       C$NULL

L4CA0               fcc       'viewDir'
                    fcb       C$NULL

L4CA8               fcc       'picDir'
                    fcb       C$NULL

L4CAF               fcc       'sndDir'
                    fcb       C$NULL


L4CB6               fcc       '%s #%d not found.'
                    fcb       C$NULL

L4CC8               fdb       $0000
L4CCA               fdb       $0000
L4CCC               fdb       $0000
L4CCE               fdb       $0000
L4CD0               fdb       $0000
L4CD2               fdb       $0000
L4CD4               fdb       $0000
L4CD6               fdb       $0000


L4CD8               leau      >L4CCA,pcr          data word
                    pshs      u
                    leau      >L4CC8,pcr          data word
                    leax      >L4C99,pcr          logDir
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4BDB
                    leas      $08,s
                    leau      >L4CD2,pcr          data word
                    pshs      u
                    leau      >L4CD0,pcr          data word
                    leax      >L4CA8,pcr          picDir
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4BDB
                    leas      $08,s
                    leau      >L4CCE,pcr          data word
                    pshs      u
                    leau      >L4CCC,pcr          data word
                    leax      >L4CA0,pcr          viewDir
                    pshs      u
L4D20               ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4BDB
                    leas      $08,s
L4D2C               leau      >L4CD6,pcr          data word
                    pshs      u
                    leau      >L4CD4,pcr          data word
                    leax      >L4CAF,pcr          sndDir
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      L4BDB
                    leas      $08,s
                    rts

L4D49               lda       ,u
                    anda      #$F0
                    cmpa      #$F0
                    bne       L4D54
                    ldu       #$0000
L4D54               rts

L4D55               leas      -$01,s
                    stb       ,s
                    ldd       >L4CCA,pcr          data word
                    lbsr      L27AF
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4CC8,pcr          data word
                    leau      d,u
                    bsr       L4D49
                    bne       L4D78
                    leax      >L4C7F,pcr          logistics
                    ldb       ,s
                    lbsr      L4DFB
L4D78               ldd       >L4CCA,pcr          data word
                    leas      $01,s
                    rts

L4D7F               leas      -$01,s
                    stb       ,s
                    ldd       >L4CCE,pcr          data word
                    lbsr      L27AF
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4CCC,pcr          data word
                    leau      d,u
                    bsr       L4D49
                    bne       L4DA1
                    leax      >L4C86,pcr          view
                    ldb       ,s
                    bsr       L4DFB
L4DA1               ldd       >L4CCE,pcr          data word
                    leas      $01,s
                    rts

L4DA8               leas      -$01,s
                    stb       ,s
                    ldd       >L4CD2,pcr          data word
                    lbsr      L27AF
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4CD0,pcr          data word
                    leau      d,u
                    bsr       L4D49
                    bne       L4DCA
                    leax      >L4C8B,pcr          picture
                    ldb       ,s
                    bsr       L4DFB
L4DCA               ldd       >L4CD2,pcr          data word
                    leas      $01,s
                    rts

L4DD1               leas      -$01,s
                    stb       ,s
                    ldd       >L4CD6,pcr          data word
                    lbsr      L27AF
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >L4CD4,pcr          data word
                    leau      d,u
                    lbsr      L4D49
                    bne       L4DF4
                    leax      >L4C93,pcr          sound
                    ldb       ,s
                    bsr       L4DFB
L4DF4               ldd       >L4CD6,pcr          data word
                    leas      $01,s
                    rts

L4DFB               leas      <-$64,s             make room on the stack
                    clra
                    pshs      b,a
                    pshs      x
                    leax      >L4CB6,pcr          not found msg
                    leau      $04,s
                    pshs      x
                    pshs      u
                    lbsr      L3C21
                    leas      $08,s
                    lbsr      L37F2

                    lda       #$03                load offset to exit_agi()
                    sta       <u0009              save offset
                    ldx       <u0022              set up remap to sierra
                    jsr       >$0659              mmu twiddle

                    leas      <$64,s              clean up stack and leave
                    rts

L4E22               fdb       $0000
                    fdb       $0000

L4E26               leau      >L4E26,pcr          load our own address
                    ldd       ,s
                    pshu      u,b,a
                    rts

L4E2F               leau      >L4E22,pcr          2 data words
                    pulu      u,b,a
                    std       ,s
                    rts

L4E38               fcc       'Not now.'
L4E40               fcb       C$NULL
F
cmd_show_obj_v
L4E41               ldx       #$0432              resolve state.var[] addr
                    ldb       ,y+
                    abx
                    ldb       ,x                  load b with data to be passed
                    bsr       L4E51
                    rts


cmd_show_obj
L4E4C               ldb       ,y+                 load b with the data to be passed
                    bsr       L4E51               go do it to it at obj_show
                    rts


* obj_show(u16 view_num) passed a view_num to show
obj_show
L4E51               leas      <-$36,s             make room on the stack
                    stb       $02,s               save our arg passed in
                    clra                          make a zero
                    sta       >X05B1              stow at obj_displayed
                    sta       $04,s               store on the stack too
                    sta       $03,s               store on the stack too
                    lbsr      L5D17               view_find()

                    leax      ,x
                    beq       L4E6B
                    stx       $05,s
                    inc       $04,s
                    bra       L4E87
L4E6B               lda       #$01
                    sta       >$05B8
                    clra
                    ldb       $02,s
                    lbsr      L5D3C
                    clr       >$05B8
                    stu       $05,s
                    bne       L4E87
                    leau      >L4E38,pcr          not now msg
                    lbsr      L37F2
                    lbra      L4F54
L4E87               ldd       <u000A
                    std       <$34,s
                    ldu       $05,s
                    ldd       $05,u
                    leau      $07,s
                    std       $08,u
                    clra
                    sta       $0A,u
                    sta       $0E,u
                    ldb       $02,s
                    lbsr      L5DD8
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
                    lbsr      L2786
                    cmpd      <$32,s
                    bcs       L4F09
                    inc       $03,s
                    tfr       u,x
                    lbsr      L41A6
                    stu       ,s
                    pshs      u
                    lda       #$15                blit_save
                    sta       <u0021              save offset
                    ldx       <u0028              set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    leau      $07,s
                    pshs      u
                    lda       #$0C                obj_blit()
                    sta       <u0021              save offset
                    ldx       <u0028              set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    leau      $07,s
                    pshs      u
                    lda       #$1B
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

L4F09               ldu       $05,s
                    ldu       $03,u
                    ldb       $03,u
                    lda       $04,u
                    leau      d,u
                    lbsr      L37F2
                    lda       $03,s
                    beq       L4F45

                    ldu       ,s
                    pshs      u
                    lda       #$12                blit_restore()
                    sta       <u0021              save the offset
                    ldx       <u0028              setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    leau      $07,s
                    pshs      u
                    lda       #$1B
                    sta       <u0019              save  the index
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldx       ,s
                    lda       $0C,x
                    ldu       $0A,x
                    lbsr      L278F
                    stu       <u004F
                    stx       <u0055
L4F45               ldd       <$34,s
                    lbsr      L27AF
                    lda       $04,s
                    bne       L4F54
                    ldb       $02,s
                    lbsr      L5FA1
L4F54               lda       #$01
                    sta       >$05B1
                    leas      <$36,s
                    rts


L4F5D               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00

L4F66               fdb       $0000
L4F68               fcb       $00
L4F69               fcb       $00
L4F6A               fcb       $00

L4F6B               fcb       $07,$78
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
                    fcb       $00,$0A
                    fcb       $00,$0C
                    fcb       $00,$0C
                    fcb       $00,$0E
                    fcb       $00,$0E
                    fcb       $00,$0E
                    fcb       $00,$10
                    fcb       $00,$10
                    fcb       $00,$12
                    fcb       $00,$12
                    fcb       $00,$14
                    fcb       $00,$16
                    fcb       $00,$16
                    fcb       $00,$18
                    fcb       $00,$1A
                    fcb       $00,$1C
                    fcb       $00,$1C
                    fcb       $00,$1E
                    fcb       $00,$20
                    fcb       $00,$22
                    fcb       $00,$24
                    fcb       $00,$26
                    fcb       $00,$28
                    fcb       $00,$2C
                    fcb       $00,$2E
                    fcb       $00,$30
                    fcb       $00,$34
                    fcb       $00,$36
                    fcb       $00,$3A
                    fcb       $00,$3E
                    fcb       $00,$40
                    fcb       $00,$44
                    fcb       $00,$48
                    fcb       $00,$4C
                    fcb       $00,$52
                    fcb       $00,$56
                    fcb       $00,$5C
                    fcb       $00,$60
                    fcb       $00,$66
                    fcb       $00,$6C
                    fcb       $00,$72
                    fcb       $00,$7A
                    fcb       $00,$80
                    fcb       $00,$8A
                    fcb       $00,$8E
                    fcb       $00,$96
                    fcb       $00,$9E
                    fcb       $00,$A8
                    fcb       $01,$BA
                    fcb       $01,$D6
                    fcb       $01,$F0
                    fcb       $02,$0A
                    fcb       $02,$2A
                    fcb       $02,$40
                    fcb       $02,$64
                    fcb       $02,$80
                    fcb       $02,$9E
                    fcb       $02,$D2
                    fcb       $02,$F8
                    fcb       $03,$22
                    fcb       $03,$3A

L505F               fcb       $00
                    fcb       $1F,$1C
                    fcb       $1F,$1E
                    fcb       $1F,$1E
                    fcb       $1F,$1F
                    fcb       $1E,$1F
                    fcb       $1E,$1F

L506C               leau      >L4F5D,pcr          9 byte table
                    ldd       #$0000
                    std       ,u
                    rts

L5076               leau      >L4F5D,pcr          9 byte table
L507A               stu       >L4F66,pcr          data word
                    ldu       ,u
                    beq       L5086
                    cmpb      $02,u
                    bne       L507A
L5086               rts

cmd_load_sound
L5087               ldb       ,y+
                    bsr       L508C
                    rts

L508C               leas      -$05,s
                    stb       ,s
                    bsr       L5076
                    cmpu      #$0000
                    bne       L50E0
                    ldd       <u000A
                    std       $03,s
                    lbsr      L057D
                    lda       #$03
                    ldb       ,s
                    lbsr      L4699
                    leau      >L4F5D,pcr          9 byte table
                    ldx       >L4F66,pcr          data word
                    beq       L50BD
                    ldd       #$0009
                    lbsr      L2730
                    stu       ,x
                    ldd       #$0000
                    std       ,u
L50BD               ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      L4DD1
                    ldx       #$0000
                    lbsr      L4966
                    beq       L50D6
                    ldx       $01,s
                    std       $05,x
                    stu       $03,x
                    std       $07,x
L50D6               lbsr      L058A
                    ldd       $03,s
                    lbsr      L27AF
                    ldu       $01,s
L50E0               leas      $05,s
                    rts

cmd_sound
L50E3               leas      -$0B,s
                    ldb       ,y+
                    stb       ,s
                    lbsr      L5076
                    cmpu      #$0000
                    bne       L50F9
                    lda       #$09
                    ldb       ,s
L50F6               lbsr      L10CE
L50F9               lda       >$01B0
                    anda      #$40
                    lbeq      L51D4
                    lda       >$0173
                    lbne      L51D4
                    ldd       <u000A
                    std       $03,s
                    stu       $01,s
                    ldd       $05,u
                    lbsr      L27AF

* Time - gets the system time and date
* entry:
*       x -> address to store the time and date packet
*
* exit:
*      x ->  address of the stored time and date packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    leax      $05,s
                    os9       F$Time
                    ldu       $01,s
                    lbsr      L51DC
                    cmpd      #$0000
                    lbeq      L51D4
                    pshs      b,a
                    addb      $0C,s
                    bcc       L512D
                    inca
L512D               ldu       #$003C
                    lbsr      L11FA
                    stb       $0C,s
                    tfr       u,d
                    cmpd      #$0000
                    beq       L518C
                    addb      $0B,s
                    bcc       L5142
                    inca
L5142               ldu       #$003C
                    lbsr      L11FA
                    stb       $0B,s
                    tfr       u,d
                    tstb
                    beq       L518C
                    addb      $0A,s
                    lda       #$17
                    lbsr      L5CEF
                    sta       $0A,s
                    tstb
                    beq       L518C
                    inc       $09,s
                    ldd       $08,s
                    leax      >L505F,pcr          13 byte data table
                    cmpb      a,x
                    bls       L518C
                    ldb       a,x
                    cmpa      #$02
                    bne       L517B
                    ldb       $07,s
                    beq       L517B
                    bitb      #$03
                    bne       L517B
                    ldb       $09,s
                    cmpb      #$1D
                    beq       L518C
L517B               ldb       #$01
                    stb       $09,s
                    inca
                    cmpa      #$0C
                    bls       L518A
                    stb       $08,s
                    inc       $07,s
                    bra       L518C
L518A               sta       $08,s

* Set time - sets the system time and date
* entry:
*       x -> relative address of the time packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

L518C               leax      $07,s
                    os9       F$STime
                    puls      b,a
                    addb      >$043D
                    bcc       L5199
                    inca
L5199               ldu       #$003C
                    lbsr      L11FA
                    stb       >$043D
                    tfr       u,d
                    cmpd      #$0000
                    beq       L51CF
                    addb      >$043E
                    bcc       L51B0
                    inca
L51B0               ldu       #$003C
                    lbsr      L11FA
                    stb       >$043E
                    tfr       u,d
                    tstb
                    beq       L51CF
                    addb      >$043F
                    lda       #$17
                    lbsr      L5CEF
                    sta       >$043F
                    tstb
                    beq       L51CF
                    inc       >$0440
L51CF               ldd       $03,s
                    lbsr      L27AF
L51D4               lda       ,y+
                    lbsr      L16D5
                    leas      $0B,s
                    rts

L51DC               pshs      y
                    clrb
                    ldu       $03,u
                    bsr       L523B
L51E3               ldb       ,u+
                    cmpb      #$FF
                    beq       L5234
                    lslb

                    nop
*         lda   ,u+
*         sta   >$FF20
                    jsr       fxsnd1,pcr

                    ldy       ,u++
                    leax      >L4F6B,pcr          data table
                    abx
                    ldd       ,x
                    std       <u008E
                    leax      >$007A,x
                    ldd       ,x
                    std       <u0090

*         tst   >$FF20
                    tst       -3,u
                    nop

                    beq       L521E
L5208               ldx       <u0090
L520A               ldd       <u008E
L520C               subd      #$0001
                    bne       L520C

*         com   >$FF20
*         leax  -$01,x
                    jsr       fxsnd2,pcr
                    nop

                    bne       L520A
                    leay      -$01,y
                    bne       L5208
                    bra       L51E3
L521E               ldx       <u0090
L5220               ldd       <u008E
L5222               subd      #$0001
                    bne       L5222
                    tst       >$FF20
                    leax      -$01,x
                    bne       L5220
                    leay      -$01,y
                    bne       L521E
                    bra       L51E3
L5234               bsr       L5265
                    ldd       ,u
                    puls      y
                    rts

*        read keyboard & joystick pias
L523B               jsr       fxsnd3,pcr
                    nop
*         orcc  #IntMasks         $50
*         clr   >$FF20
                    lda       >$FF01
                    sta       >L4F68,pcr          data byte
                    anda      #$F7
                    sta       >$FF01
                    lda       >$FF03
                    sta       >L4F69,pcr          data byte
                    anda      #$F7
                    sta       >$FF03
                    lda       >$FF23
                    sta       >L4F6A,pcr          data byte
                    ora       #$08                enable sound flag
                    sta       >$FF23              tell hardware to do it
                    rts

L5265               lda       >L4F68,pcr          data byte
                    sta       >$FF01
                    lda       >L4F69,pcr          data byte
                    sta       >$FF03
                    lda       >L4F6A,pcr          data byte
                    sta       >$FF23
*         clr   >$FF20
*         lda   >$FF02
                    jsr       fxsnd4,pcr
                    nop
                    nop
                    lda       >$FF22
                    andcc     #^IntMasks          $AF
                    rts

L5286               fcc       'nothing'
                    fcb       C$NULL

L528E               fcc       'You are carrying:'
                    fcb       C$NULL

L52A0               fcc       'ENTER to select / CTRL-BREAK to cancel'
                    fcb       C$NULL

L52C7               fcc       'Press a key to return to the game'
                    fcb       C$NULL

L52E9               fcc       'Score:%d of %d  '
                    fcb       C$NULL

L52FA               fcc       'Sound: %s'
                    fcb       C$NULL,C$NULL,C$NULL,C$NULL

L5307               fcc       'on '
                    fcb       C$NULL

L530B               fcc       'off'
                    fcb       C$NULL

cmd_status
L530F               lbsr      L5B7A               input_edit_on
                    lbsr      L464E
                    clra
                    ldb       #$0F
                    lbsr      L45BA
L531B               lbsr      L456C
                    bsr       L5327
                    lbsr      L4663
                    lbsr      L45D9
                    rts

L5327               leas      >-$0105,s
                    lda       #$02
                    sta       ,s
L532F               leax      $04,s
                    stx       $02,s
                    stx       >$00FE,s
                    ldu       <u0038
                    clra
                    sta       $01,s
L533C               sta       >$0100,s
                    stu       >$0101,s
                    cmpu      <u003C
                    bcc       L538F
                    ldb       $02,u
                    cmpb      #$FF
                    bne       L5386
                    sta       ,x
                    cmpa      >$044B
                    bne       L535A
                    stx       >$00FE,s
L535A               ldd       ,u
                    std       $01,x
                    lda       ,s
                    sta       $03,x
                    ldb       $01,s
                    bitb      #$01
                    bne       L536E
                    lda       #$01
                    sta       $04,x
                    bra       L5381
L536E               inca
                    sta       ,s
                    stx       $02,s
                    ldx       $01,x
                    lbsr      L113E
                    ldx       $02,s
                    negb
                    addb      #$27
                    stb       $04,x
                    ldb       $01,s
L5381               incb
                    stb       $01,s
                    leax      $05,x
L5386               leau      $03,u
                    lda       >$0100,s
                    inca
                    bra       L533C
L538F               lda       $01,s
                    bne       L53A5
                    sta       ,x
                    leau      >L5286,pcr          nothing string
                    stu       $01,x
                    lda       ,s
                    sta       $03,x
                    lda       #$10
                    sta       $04,x
                    leax      $05,x
L53A5               leax      -$05,x
                    stx       >$0103,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    ldx       >$0102,s
                    stx       $06,s
                    pshs      x
                    lbsr      L540F
                    leas      $06,s
L53BE               lbsr      L12F0
                    lda       >$01B0
                    anda      #$04
                    beq       L5403
                    ldd       ,x
                    cmpa      #$01
                    bne       L53E6
                    cmpb      #$0D
                    bne       L53DB
                    ldx       $02,s
                    lda       ,x
                    sta       >$044B
                    bra       L5403
L53DB               cmpb      #$1B
                    bne       L53BE
                    lda       #$FF
                    sta       >$044B
                    bra       L5403
L53E6               cmpa      #$02
                    bne       L53BE
                    leax      $04,s
                    pshs      x
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >$0109,s
                    pshs      b,a
                    lbsr      L5490
                    leas      $08,s
                    stx       $02,s
                    bra       L53BE
L5403               clra
                    sta       >X0154              flag for extended table lookup
                    sta       >$0547
                    leas      >$0105,s
                    rts


L540F               leas      -$04,s
                    lda       #$00
                    ldb       #$0B
                    std       <u0040
                    leau      >L528E,pcr          you are carrying string
                    pshs      u
                    lbsr      L3C34
                    leas      $02,s
                    ldx       $08,s
L5424               stx       ,s
                    cmpx      $0A,s
                    bhi       L5459
                    ldd       $03,x
                    std       <u0040
                    clra
                    ldb       #$0F
                    std       $02,s
                    cmpx      $06,s
                    bne       L5443
                    lda       >$01B0
                    anda      #$04
                    beq       L5443
                    lda       #$0F
                    clrb
                    std       $02,s
L5443               ldd       $02,s
                    lbsr      L45BA
                    ldx       ,s
                    ldx       $01,x
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    ldx       ,s
                    leax      $05,x
                    bra       L5424
L5459               clra
                    ldb       #$0F
                    lbsr      L45BA
                    lda       >$01B0
                    anda      #$04
                    beq       L547C
                    lda       #$01
                    sta       >X0154              flag for extended table lookup
                    lda       #$03
                    sta       >$0547
                    lda       #$17
                    ldb       #$01
                    std       <u0040
                    leax      >L52A0,pcr          Enter to select string
                    bra       L5486
L547C               lda       #$17
                    ldb       #$04
                    std       <u0040
                    leax      >L52C7,pcr          press a key to return to the game
L5486               pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    leas      $04,s
                    rts

L5490               ldu       $04,s
                    tfr       u,x
                    lda       $07,s
                    cmpa      #$01
                    bne       L549E
                    leax      -$0A,x
                    bra       L54B4
L549E               cmpa      #$03
                    bne       L54A6
                    leax      $05,x
                    bra       L54B4
L54A6               cmpa      #$05
                    bne       L54AE
                    leax      $0A,x
                    bra       L54B4
L54AE               cmpa      #$07
                    bne       L54C9
                    leax      -$05,x
L54B4               cmpx      $08,s
                    bcs       L54BC
                    cmpx      $02,s
                    bls       L54C0
L54BC               tfr       u,x
                    bra       L54C9
L54C0               pshs      x
                    pshs      u
                    lbsr      L54CA
                    leas      $04,s
L54C9               rts

L54CA               lda       #$0F
                    clrb
                    lbsr      L45BA
                    ldu       $04,s
                    ldd       $03,u
                    std       <u0040
                    ldd       $01,u
                    pshs      b,a
                    lbsr      L3C34
                    leas      $02,s
                    clra
                    ldb       #$0F
                    lbsr      L45BA
                    ldu       $02,s
                    ldd       $03,u
                    std       <u0040
                    ldd       $01,u
                    pshs      b,a
                    lbsr      L3C34
                    leas      $02,s
                    ldx       $04,s
                    rts

L54F7               lda       >X0247              state.status_state
                    beq       L5558
                    lbsr      L47AA
                    lbsr      L464E
                    lda       >$0248
                    ldb       #$0F
                    lbsr      L47D0
                    clra
                    ldb       #$0F
                    lbsr      L45BA
                    lda       >$0248
                    ldb       #$01
                    std       <u0040
                    clra
                    ldb       >$0439
                    pshs      b,a
                    ldb       >$0435
                    leax      >L52E9,pcr          Score string
                    pshs      b,a
                    pshs      x
                    lbsr      L3C34
                    leas      $06,s
                    ldb       #$1E
                    stb       <u0041
                    leau      >L530B,pcr          off
                    lda       >$01B0
                    anda      #$40
                    beq       L5545
                    lda       >$0173
                    bne       L5545
                    leau      >L5307,pcr          on
L5545               leax      >L52FA,pcr          Sound
                    pshs      u
                    pshs      x
                    lbsr      L3C34
                    leas      $04,s
                    lbsr      L4663
                    lbsr      L47BE
L5558               rts

cmd_status_line_on
L5559               lda       #$01
                    sta       >X0247              state.status_state = 1
                    bsr       L54F7               status_line_write()
                    rts

cmd_status_line_off
L5561               clr       >X0247              state.status_state = 0
                    lda       >$0248              state.status_line_row ??
                    clrb
                    lbsr      L47D0
                    rts

* Junk filler string ?
L556C               fcc       / .,;:'!-/
                    fcb       C$NULL


cmd_get_string
L5575               leas      >-$0197,s
                    lda       >$05B9
                    sta       ,s
                    lbsr      L47AA
                    lbsr      L5B7A               input_edit_on
                    lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #X0252              state.string
                    leax      d,x
                    stx       $01,s
                    lda       ,y+
                    sta       $05,s
L5594               ldd       ,y++
                    std       $03,s
                    lda       ,y+
                    inca
                    cmpa      #$28
                    bls       L55A1
                    lda       #$28
L55A1               sta       >$0196,s
                    clr       ,x
                    ldd       $03,s
                    cmpa      #$18
L55AB               bcc       L55AF
                    std       <u0040
L55AF               ldb       $05,s
                    lbsr      L3B58
                    leax      $06,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      L39B5
                    leas      $06,s
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    ldb       >$0196,s
                    ldx       $01,s
                    bsr       L5613
                    lbsr      L47BE
                    lda       ,s
                    beq       L55DD
                    lbsr      L5B69
L55DD               leas      >$0197,s
                    rts

cmd_set_string
L55E2               lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #X0252              state.string
                    leax      d,x
                    ldb       ,y+
                    lbsr      L3B58
                    exg       u,x                 x is from u is to
                    ldd       #$0028              number of bytes to copy (40)
                    lbsr      L115D               copy routine
                    rts

cmd_word_to_string
L55FA               lda       ,y+
                    ldb       #$28
                    mul
                    ldu       #X0252              state.string
                    leau      d,u                 u is to address
                    ldb       ,y+
                    lslb
                    ldx       #$0181
                    ldx       b,x                 x is from address
                    ldd       #$0028              number of bytes to copy
                    lbsr      L115D               copy routine
                    rts

L5613               leas      <-$2F,s
                    stx       ,s
                    cmpb      #$28                number of bytes to copy in d
                    bls       L561E
                    ldb       #$28                number of bytes to copy in d
L561E               leax      $06,s
                    abx
                    stx       $04,s
                    clra                          number of bytes to copy in d
                    ldx       ,s                  from address
                    leau      $07,s               to address
                    lbsr      L115D               copy routine
                    lbsr      L113E
                    beq       L563C
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    leax      $07,s
                    lbsr      L113E
L563C               abx
                    stx       $02,s
                    lbsr      L5B69
L5642               lbsr      L1345
                    sta       $06,s
                    lbsr      L5B7A               input_edit_on
                    lda       $06,s
                    cmpa      #$08
                    bne       L5668
L5650               leau      $07,s
                    cmpu      $02,s
                    bcc       L5693
                    ldu       $02,s
                    leau      -$01,u
                    stu       $02,s
                    lbsr      L4734
                    lda       #$08
                    cmpa      $06,s
                    beq       L5693
                    bra       L5650
L5668               cmpa      #$03
                    bne       L5670
                    lda       #$08
                    bra       L5650
L5670               cmpa      #$0D
                    bne       L5681
                    ldu       $02,s
                    clr       ,u
                    leax      $07,s
                    ldu       ,s
                    lbsr      L1152
                    bra       L5698
L5681               cmpa      #$1B
                    beq       L5698
                    ldu       $02,s
                    cmpu      $04,s
                    bcc       L5693
                    sta       ,u+
                    stu       $02,s
                    lbsr      L4734
L5693               lbsr      L5B69
                    bra       L5642
L5698               lda       $06,s
                    leas      <$2F,s
                    rts

cmd_set_game_id
L569E               ldb       ,y+
                    lbsr      L3B58
                    tfr       u,x                 x is from address
                    ldu       #$01CF              destination address
                    ldd       #$0007              number of bytes to copy  ID_SIZE ??? is 20
                    lbsr      L115D               copy routine
                    rts

L56AF               leas      <-$53,s
                    stb       ,s
                    leau      $01,s
                    bsr       L56D9
                    lda       ,s
                    leau      <$2A,s
                    bsr       L56D9
                    leau      $01,s
                    leax      <$2A,s
L56C4               lda       ,u+
                    beq       L56CE
                    cmpa      ,x+
                    beq       L56C4
                    bra       L56D4
L56CE               lda       #$01
                    ldb       ,x
                    beq       L56D5
L56D4               clra
L56D5               leas      <$53,s
                    rts

L56D9               leas      -$02,s
                    stu       ,s
                    ldb       #$28
                    mul
                    ldu       #X0252              state.string
                    leau      d,u
L56E5               lda       ,u+
                    beq       L56FD
                    leax      >L556C,pcr          punc string
                    lbsr      L1277
                    bne       L56E5
                    lbsr      L1250               single char upper to lower case conversion
                    ldx       ,s
                    sta       ,x+
                    stx       ,s
                    bra       L56E5
L56FD               ldx       ,s
                    clr       ,x
                    leas      $02,s
                    rts

cmd_hide_mouse
L5704               lda       ,y+
                    lda       ,y+

cmd_set_upper_left
cmd_allow_menu
L5708               lda       ,y+

cmd_shake_screen
cmd_log
L570A               lda       ,y+


cmd_do_nothing
cmd_stop_sound
cmd_init_disk
cmd_open_dialogue
cmd_close_dialogue
cmd_hold_key
cmd_set_pri_base
cmd_discard_sound
L570c               rts

L570D               fcc       '=========================='
                    fcb       C$NULL

L5728               fcc       '%d: %d'
                    fcb       C$NULL

L572F               fcc       '%d: %s'
                    fcb       C$NULL

L5736               fcc       ' :%c'
                    fcb       C$NULL

L573B               fcc       '%d'
                    fcb       C$NULL

L573E               fcc       'return'
                    fcb       C$NULL

L5745               fcb       $00
L5746               fcb       $01
L5747               fcb       $0F
L5748               fcb       $00
L5749               fcb       $00
L574A               fcb       $00
L574B               fcb       $00
L574C               fcb       $00
L574D               fcb       $00
L574E               fcb       $00
L574F               fcb       $00

cmd_trace_on
L5750               lda       <u0068
                    beq       L5756
                    bsr       L5757
L5756               rts

L5757               lda       <u0068
L5759               bne       L57CE
                    lda       >$01B0
                    anda      #$20
                    lda       #$01
                    sta       <u0068
                    lda       >$0242
                    inca
                    adda      >L5746,pcr          data byte
                    sta       >L574E,pcr          data byte
                    adda      >L5747,pcr          data byte
                    deca
                    sta       >L574F,pcr          data byte
                    lda       #$02
                    sta       >L574A,pcr          data byte
                    adda      #$23
                    sta       >L574D,pcr          data byte
                    lda       >L574A,pcr          data byte
                    ldb       #$04
                    mul
                    subb      #$05
                    stb       >L574B,pcr          data byte
                    lda       >L574F,pcr          data byte
                    ldb       #$08
                    mul
                    addb      #$05
                    stb       >L574C,pcr          data byte
                    lda       >L5747,pcr          data byte
                    ldb       #$08
                    mul
                    addb      #$0A
                    stb       >L5748,pcr          data byte
                    ldb       #$9A
                    stb       >L5749,pcr          data byte

                    ldd       #$040F
                    pshs      d
                    ldd       >L5748,pcr          data byte
                    pshs      d
                    ldd       >L574B,pcr          data byte
                    pshs      d
                    lda       #$0C
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up the stack

L57CE               rts

cmd_trace_info
L57CF               lda       ,y+
                    lda       ,y+
                    sta       >L5746,pcr          data byte
                    lda       ,y+
                    cmpa      #$02
                    bcc       L57DF
                    lda       #$02
L57DF               sta       >L5747,pcr          data byte
                    rts

L57E4               lda       <u0068
                    beq       L5801
                    clr       <u0068

                    ldd       >L5748,pcr          data byte
                    pshs      d
                    ldd       >L574B,pcr          data byte
                    pshs      d
                    lda       #$03
                    sta       <u0019              save the offset
                    ldx       <u0026              set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $04,s               clean up the stack

L5801               rts

L5802               leas      -$02,s
                    stb       $01,s
                    clr       >L5745,pcr          data byte
                    leax      >L01B0,pcr          big jump table address
                    ldd       #$FFFF
                    pshs      d
                    ldd       #$0000
                    pshs      d
                    pshs      y
                    pshs      x
                    ldd       $08,s
                    pshs      d
                    lbsr      L585A
                    leas      $0A,s
                    ldb       $01,s
                    leas      $02,s
                    rts

L582A               leas      -$03,s
                    sta       $02,s
                    lda       #$01
                    ldb       ,u+
                    stb       $01,s
                    cmpb      #$0E
                    beq       L5839
                    clra
L5839               sta       >L5745,pcr          data byte
                    leax      >L0D09,pcr          jump table 2 address
                    ldd       $02,s
                    pshs      b,a
                    ldd       #$00DC
                    pshs      b,a
                    pshs      u
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    lbsr      L585A
                    leas      $0A,s
                    leas      $03,s
                    rts

L585A               leas      -$04,s
                    clr       $06,s
                    lda       $07,s
                    ldb       #$04
                    mul
                    ldx       $08,s
                    leax      d,x
                    stx       $08,s
                    lbsr      L47AA
                    lbsr      L464E
                    ldd       #$000F
                    lbsr      L45BA

*    this bizarre little fragment is interesting
*    bytes are $17 $01 $82
*    next instruction loads "a" with the second byte
*    in the first pass its $01 and gets cleared
*    any pass after that it will be
*    $17 $00 $82
*    which branches to L58F9
*    that is one byte into leax >L5736.pcr below
*    and that instruct decodes to the following
*    L58F9  bsr L5859
*           abx
*           ... continues
*    what am I missing in all of this or is my math off

L5875               lbsr      L59FA

                    lda       <L5875+1,pcr
                    beq       L588E
                    clr       <L5875+1,pcr

                    leax      >L570D,pcr          ======= header
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    lbsr      L59FA

L588E               ldy       <u0062
                    sty       ,s
                    ldb       <u006A
                    beq       L58A1
                    lbsr      L2542
                    cmpu      #$0000
                    bne       L58AC
L58A1               ldu       $06,s
                    clra
                    ldb       $02,y
                    leax      >L5728,pcr          "%d: %d"
                    bra       L58C6
L58AC               leax      >L573E,pcr          return
                    ldb       $07,s
                    beq       L58B9
                    addb      $0D,s
                    lbsr      L3B58
L58B9               clra
                    ldb       $02,y
                    leax      >L572F,pcr          "%d: %s"
                    ldy       ,s
                    sty       <u0062
L58C6               pshs      u
                    pshs      b,a
                    pshs      x
                    lbsr      L3C34
                    leas      $06,s
                    ldd       $0A,s
                    pshs      b,a
                    ldd       $0A,s
                    pshs      b,a
                    lbsr      L5940
                    leas      $04,s
                    ldb       $0E,s
                    bmi       L590A
                    lda       >L574F,pcr          data byte
                    ldb       >L574D,pcr          data byte
                    subb      #$02
                    std       <u0040
                    ldb       #$54
                    ldb       $0E,s
                    bne       L58F6
                    ldb       #$46
L58F6               pshs      b,a
                    leax      >L5736,pcr          " %c:"
                    pshs      b,a
                    pshs      x
                    lbsr      L3C34
                    leas      $06,s
                    ldd       >$024B
                    std       $02,s
L590A               lda       <u0068
                    beq       L5937
                    lbsr      L12CE
                    leax      ,x
                    beq       L591B
                    lda       ,x
                    cmpa      #$01
                    beq       L592D
L591B               ldd       $02,s
                    cmpd      >$024B
                    beq       L591B
                    lbsr      L12A8
                    ldd       >$024B
                    std       $02,s
                    bra       L590A
L592D               lda       $01,x
                    cmpa      #$2B
                    bne       L5937
                    lda       #$02
                    sta       <u0068
L5937               lbsr      L47BE
                    lbsr      L4663
                    leas      $04,s
                    rts

L5940               leas      -$06,s
                    lbsr      L47AA
                    ldu       $08,s
                    ldx       $0A,s
                    lda       $02,u
                    ldb       >L5745,pcr          data byte
                    beq       L5955
                    lda       ,x+
                    stx       $0A,s
L5955               ldb       $03,u
                    std       ,s
                    lda       #$28
                    lbsr      L4734
                    lda       ,s
                    beq       L5988
                    clr       $02,s
                    leax      >L573B,pcr          "%d"
L5968               ldb       $02,s
                    ldu       $0A,s
                    lbsr      L59E8
                    pshs      b,a
                    pshs      x
                    lbsr      L3C34
                    leas      $04,s
                    ldb       $02,s
                    incb
                    cmpb      ,s
                    bcc       L5988
                    stb       $02,s
                    lda       #$2C
                    lbsr      L4734
                    bra       L5968
L5988               lda       #$29
                    lbsr      L4734
                    ldb       $01,s
                    beq       L5994
                    lbsr      L59FA
L5994               lbsr      L47BE
                    ldb       $01,s
                    beq       L59E5
                    lda       #$28
                    lbsr      L4734
                    lda       #$80
                    clr       $02,s
L59A4               sta       $03,s
                    ldb       $02,s
                    ldu       $0A,s
                    lbsr      L59E8
                    std       $04,s
                    lda       $01,s
                    anda      $03,s
                    beq       L59BE
                    ldx       #$0432
                    abx
                    ldb       ,x
                    clra
                    std       $04,s
L59BE               leax      >L573B,pcr          "%d"
                    ldd       $04,s
                    pshs      b,a
                    pshs      x
                    lbsr      L3C34
                    leas      $04,s
                    ldb       $02,s
                    incb
                    cmpb      ,s
                    bcc       L59E0
                    stb       $02,s
                    lda       #$2C
                    lbsr      L4734
                    lda       $03,s
                    lsra
                    bra       L59A4
L59E0               lda       #$29
                    lbsr      L4734
L59E5               leas      $06,s
                    rts

L59E8               lda       >L5745,pcr          data byte
                    bne       L59F2
                    ldb       b,u
                    bra       L59F9
L59F2               lslb
                    leau      b,u
                    ldb       ,u+
                    lda       ,u
L59F9               rts

L59FA               ldd       #$0001
                    pshs      b,a
                    ldb       >L574D,pcr          data byte
                    pshs      b,a
                    ldb       >L574A,pcr          data byte
                    pshs      b,a
                    ldd       #$000F
                    pshs      b,a
                    ldb       >L574F,pcr          data byte
                    pshs      b,a
                    ldb       >L574E,pcr          data byte
                    pshs      b,a
                    lbsr      L47F4
                    leas      $0C,s
                    rts

L5A22               fcb       $00
L5A23               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00

L5A4C               clra
                    sta       >$0445
                    sta       >$043B
                    lda       >$05AE
                    beq       L5A5B
                    lbsr      L295E
L5A5B               lbsr      L12CE
                    lbsr      L1310
                    leax      ,x
                    beq       L5A9B
                    ldd       ,x
                    cmpa      #$01
                    bne       L5A77
                    stb       >$0445
                    lda       >$01D6
                    beq       L5A5B
                    bsr       L5A9C
                    bra       L5A5B
L5A77               cmpa      #$02
                    bne       L5A92
                    ldu       <u0030
                    cmpb      <$21,u
                    bne       L5A83
                    clrb
L5A83               stb       >$0438
                    lda       >$0251              state.ego_control_state
                    beq       L5A5B
                    lda       #$00
                    sta       <$22,u
                    bra       L5A5B
L5A92               ldu       #$05BA
                    lda       #$01
                    sta       b,u
                    bra       L5A5B
L5A9B               rts

L5A9C               leas      -$02,s
                    stb       ,s
                    ldx       #X0252              state.string
                    lbsr      L113E
                    negb
                    addb      #$28
                    lda       >X01AE              state.cursor
                    beq       L5AAF
                    decb
L5AAF               cmpb      >$044A
                    bls       L5AB7
                    ldb       >$044A
L5AB7               stb       $01,s
                    lbsr      L5B7A               input_edit_on
                    lda       ,s
                    cmpa      #$0A
                    beq       L5B21
                    cmpa      #$0D
                    bne       L5AEB
                    lda       >L5A22,pcr          data byte
                    beq       L5B21
                    ldx       #$012B
                    leau      >L5A23,pcr          41 byte block
                    lbsr      L1152
                    ldx       #$012B
                    lbsr      L31F8
                    clra
                    sta       >L5A22,pcr          data byte
                    ldx       #$012B
                    sta       ,x
                    lbsr      L5BAD
                    bra       L5B21
L5AEB               cmpa      #$08
                    bne       L5B06
                    lda       >L5A22,pcr          data byte
                    beq       L5B21
                    deca
                    sta       >L5A22,pcr          data byte
                    ldu       #$012B
                    clr       a,u
                    lda       ,s
                    lbsr      L4734
                    bra       L5B21
L5B06               ldb       >L5A22,pcr          data byte
                    cmpb      $01,s
                    bcc       L5B21
                    lda       ,s
                    beq       L5B21
                    ldu       #$012B
                    sta       b,u
                    incb
                    stb       >L5A22,pcr          data byte
                    clr       b,u
                    lbsr      L4734
L5B21               bsr       L5B69
                    leas      $02,s
                    rts

cmd_cancel_line
L5B26               lda       >L5A22,pcr          data byte
                    beq       L5B33
                    ldb       #$08
                    lbsr      L5A9C
                    bra       L5B26
L5B33               rts

cmd_echo_line
L5B34               lda       >$01D6              state.input_state
                    beq       L5B3B               equal zero were done
                    bsr       L5B3C               otherwise input_echo()
L5B3B               rts

input_echo
L5B3C               leax      >L5A23,pcr          41 byte block
                    lbsr      L113E
                    cmpb      >L5A22,pcr          data byte
                    bls       L5B68
                    bsr       L5B7A               input_edit_on
L5B4B               ldb       >L5A22,pcr          data byte
                    ldu       #$012B
                    leax      >L5A23,pcr          41 byte block
                    lda       b,x
                    sta       b,u
                    beq       L5B66
                    incb
                    stb       >L5A22,pcr          data byte
                    lbsr      L4734
                    bra       L5B4B
L5B66               bsr       L5B69
L5B68               rts

L5B69               lda       >$05B9
                    bne       L5B79
                    com       >$05B9
                    lda       >X01AE              state.cursor
                    beq       L5B79
                    lbsr      L4734
L5B79               rts

* input_edit_on
L5B7A               lda       >X05B9              load input_edit_disabled flag
                    beq       L5B8C               is it zero ?? good edit is on were done
                    com       >X05B9              not zero make it so
                    lda       >X01AE              state.cursor
                    beq       L5B8C               if it's clear were out a here
                    lda       #$08                otherwise load arg to window_put_char
                    lbsr      L4734               and go for it
L5B8C               rts

cmd_prevent_input
L5B8D               bsr       L5B7A               input_edit_on
                    lda       >$01D8
                    clrb
                    stb       >$01D6
                    lbsr      L47D0
                    rts

cmd_accept_input
L5B9A               lda       #$01
                    sta       >$01D6
                    bsr       L5BAD
                    rts

cmd_set_cursor_char
L5BA2               ldb       ,y+
                    lbsr      L3B58
                    lda       ,u
                    sta       >X01AE              state.cursor
                    rts

L5BAD               leas      <-$50,s
                    lda       >$01D6
                    beq       L5BED
                    bsr       L5B7A               input_edit_on
                    lda       >$01D8
                    ldb       >X024E
                    lbsr      L47D0
                    lda       >$01D8
                    clrb
                    std       <u0040
                    ldx       #X0252              state.string
                    leau      ,s
                    ldd       #$0028              set to 40
                    pshs      d
                    pshs      x
                    pshs      u
                    lbsr      L39B5
                    leas      $06,s
                    pshs      x
                    lbsr      L3C34
                    leas      $02,s
                    ldd       #$012B
                    pshs      b,a
                    lbsr      L3C34
                    leas      $02,s
                    lbsr      L5B69
L5BED               leas      <$50,s
                    rts

* these commands are found in arithmetic.c in nagi
* they all have the form of
* u8 cmd_xyz(u8 *code)
*
* increments state.var[] pointed to by offset held in y
cmd_increment
L5BF1               ldb       ,y+                 get the offset of the first byte in y and bump y
                    ldx       #$0432              address of the state.var[]
                    abx                           add the offset value to x
                    lda       ,x                  get the byte pointed to by that address
                    inca                          increment it by one
                    beq       L5BFE               if it rolls over FF to 00 don't save it
                    sta       ,x                  otherwise stow it back
L5BFE               rts                           return

cmd_decrement
L5BFF               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    beq       L5C0C               if it's zero don't do anything
                    deca                          otherwsie decrement it
                    sta       ,x                  stow it back
L5C0C               rts

cmd_assignn
L5C0D               ldb       ,y+
                    ldx       #$0432
                    lda       ,y+                 get the value of the second byte
                    abx
                    sta       ,x                  stow it as the value of the first
                    rts

cmd_assignv
L5C18               ldb       $01,y               get offset of the second byte
                    ldx       #$0432              load the address of state.var[]
                    abx                           add em
                    lda       ,x                  grab the value out
                    ldb       ,y++                get the offset of first byte bump past second byte
                    ldx       #$0432              load the address of state.var[]
                    abx                           add em
                    sta       ,x                  store byte2 value at byte1
                    rts

cmd_addn
L5C29               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x                  get the value of the first byte
                    adda      ,y+                 add in the value of the second and bump the pointer
                    sta       ,x                  store the sum in the first byte
                    rts

cmd_addv
L5C36               ldb       $01,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    adda      ,x
                    sta       ,x
                    rts

cmd_subn
L5C49               ldb       ,y+
                    ldx       #$0432
                    abx
                    lda       ,x
                    suba      ,y+
                    sta       ,x
                    rts

cmd_subv
L5C56               ldb       $01,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    nega
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    adda      ,x
                    sta       ,x
                    rts

cmd_lindirectv
L5C6A               ldb       $01,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    ldb       ,x
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_lindirectn
L5C81               lda       $01,y
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    ldb       ,x
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_rindirect
L5C92               ldb       $01,y
                    ldx       #$0432
                    abx
                    ldb       ,x
                    ldx       #$0432
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_multn
L5CA9               ldx       #$0432
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldb       ,y+
                    mul
                    stb       ,x
                    rts

cmd_multv
L5CB7               ldb       $01,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    ldb       ,x
                    mul
                    stb       ,x
                    rts

cmd_divn
L5CCB               ldx       #$0432
                    ldb       ,y+
                    abx
                    ldb       ,x
                    lda       ,y+
                    bsr       L5CEF
                    stb       ,x
                    rts

cmd_divv
L5CDC               ldb       $01,y
                    ldx       #$0432
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0432
                    abx
                    ldb       ,x
                    bsr       L5CEF
                    stb       ,x
                    rts

L5CEF               sta       <u0088
                    lda       #$08
                    sta       <u008D
                    clra
L5CF6               lslb
                    rola
                    cmpa      <u0088
                    bcs       L5CFF
                    suba      <u0088
                    incb
L5CFF               dec       <u008D
                    bne       L5CF6
                    rts

* list struct
*
*	NODE *head;
*	NODE *tail;
*
*	// private
*	int contents_size;
list_struct
L5D04               fdb       $0000
                    fdb       $0000
                    fcb       $00,$00,$00

L5D0B               fdb       $0000

list_clear
L5D0D               leau      >L5D04,pcr          LIST structure
                    ldd       #$0000              set up clear head & tail
                    std       ,u                  zero them
                    rts

*???
view_find
L5D17               leax      >L5D04,pcr
L5D1B               stx       >L5D0B,pcr          data word
                    ldx       ,x
                    beq       L5D27
                    cmpb      $02,x
                    bne       L5D1B
L5D27               rts


cmd_load_view
L5D28               lda       #$00                clear MSB
                    ldb       ,y+                 get the arg passed in (passed in d)
                    bsr       L5D3C               call view_load
                    rts

cmd_load_view_v
L5D2F               lda       #$00                clear MSB
                    ldb       ,y+                 resolve state.var[] addr
                    ldx       #$0432
                    abx
                    ldb       ,x                  get the arg passed in (passed in d)
                    bsr       L5D3C               call view_load
                    rts

view_load
L5D3C               leas      -$06,s
                    std       ,s
                    bsr       L5D17
                    leax      ,x
                    beq       L5D4E
                    ldb       ,s
                    bne       L5D4E
                    tfr       x,u
                    bra       L5D99
L5D4E               stx       $02,s
                    ldd       <u000A
                    std       $04,s
                    lbsr      L057D
                    ldu       $02,s
                    bne       L5D7B
                    lda       #$01
                    ldb       $01,s
                    lbsr      L4699
                    ldd       #$0007
                    lbsr      L2730
                    stu       $02,s
                    ldx       >L5D0B,pcr          data word
                    stu       ,x
                    ldd       #$0000
                    std       ,u
                    std       $03,u
                    ldb       $01,s
                    stb       $02,u
L5D7B               ldb       $02,u
                    lbsr      L4D7F
                    ldx       $02,s
                    ldx       $03,x
                    lbsr      L4966
                    beq       L5D8F
                    ldx       $02,s
                    std       $05,x
                    stu       $03,x
L5D8F               lbsr      L058A
                    ldd       $04,s
                    lbsr      L27AF
                    ldu       $02,s
L5D99               leas      $06,s
                    rts

cmd_set_view
L5D9C               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       L5DD8
                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

cmd_set_view_v
L5DB7               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    bsr       L5DD8
                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

L5DD8               lbsr      L5D17
                    leax      ,x
                    bne       L5DE4
                    lda       #$03
                    lbsr      L10CE
L5DE4               stb       $05,u
                    ldd       $05,x
                    std       $08,u
                    ldx       $03,x
                    stx       $06,u
                    lbsr      L27AF
                    ldx       $06,u
                    lda       $02,x
                    sta       $0B,u
                    ldb       $0A,u
                    cmpb      $0B,u
                    bcs       L5DFE
                    clrb
L5DFE               bsr       L5E3D
                    rts

cmd_set_loop
L5E01               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       L5E3D
                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

cmd_set_loop_v
L5E1C               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    bsr       L5E3D
                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

L5E3D               leas      -$01,s
                    ldx       $06,u
                    bne       L5E47
                    ldb       #$06
                    bra       L5E4D
L5E47               cmpb      $0B,u
                    bcs       L5E58
                    ldb       #$05
L5E4D               stb       ,s
                    tfr       u,d
                    subd      <u0030
                    lda       ,s
                    lbsr      L10CE
L5E58               stb       $0A,u
                    ldd       $08,u
                    lbsr      L27AF
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
                    bcs       L5E7A
                    clrb
L5E7A               bsr       L5EBB
                    leas      $01,s
                    rts

cmd_set_cel
L5E7F               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       L5EBB
                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

cmd_set_cel_v
L5E9A               leas      -$02,s
                    ldd       <u000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    bsr       L5EBB
                    ldd       ,s
                    lbsr      L27AF
                    leas      $02,s
                    rts

L5EBB               leas      -$01,s
                    ldx       $06,u
                    bne       L5EC5
                    ldb       #$0A
                    bra       L5ECB
L5EC5               cmpb      $0F,u
                    bcs       L5ED6
                    ldb       #$08
L5ECB               stb       ,s
                    tfr       u,d
                    subd      <u0030
                    lda       ,s
                    lbsr      L10CE
L5ED6               stb       $0E,u
                    ldd       $08,u
                    lbsr      L27AF
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
                    bls       L5F08
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lda       #$A0
                    suba      <$1C,u
                    sta       $03,u
L5F08               decb
                    cmpb      $04,u
                    bls       L5F29
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    stb       $04,u
                    cmpb      >$01D7
                    bhi       L5F29
                    lda       <$26,u
                    bita      #$08
                    bne       L5F29
                    ldb       >$01D7
                    incb
                    stb       $04,u
L5F29               leas      $01,s
                    rts

cmd_last_cel
L5F2C               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       $0F,u
                    deca
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_current_cel
L5F41               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       $0E,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_current_loop
L5F55               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       $0A,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_current_view
L5F69               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       $05,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_number_of_loops
L5F7D               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <u0030
                    tfr       d,u
                    lda       $0B,u
                    ldb       ,y+
                    ldx       #$0432
                    abx
                    sta       ,x
                    rts

cmd_discard_view
L5F91               ldb       ,y+
                    bsr       L5FA1
                    rts

cmd_discard_view_v
L5F96               ldb       ,y+
                    ldx       #$0432
                    abx
                    ldb       ,x
                    bsr       L5FA1
                    rts

L5FA1               leas      -$05,s
                    stb       ,s
                    lbsr      L5D17
                    leax      ,x
                    bne       L5FB3
                    lda       #$01
                    ldb       ,s
                    lbsr      L10CE
L5FB3               stx       $01,s
                    ldd       <u000A
                    std       $03,s
                    lda       #$07
                    ldb       ,s
                    lbsr      L4699
                    ldu       >L5D0B,pcr          data word
                    ldd       #$0000
                    std       ,u
                    lbsr      L057D
                    ldx       $01,s
                    ldu       $03,x
                    lda       $05,x
                    lbsr      L278F
                    stu       <u004F
                    stx       <u0055
                    lbsr      L058A
                    lbsr      L2786
                    ldd       $03,s
                    lbsr      L27AF
                    leas      $05,s
                    rts

L5FE7               lda       <$27,u
                    beq       L5FF6
                    dec       <$27,u
                    lda       <$25,u
                    bita      #$40
                    beq       L601D
L5FF6               lbsr      L3D7D
                    lda       #$09
                    lbsr      L5CEF
                    sta       <$21,u
                    cmpu      <u0030
                    bne       L6009
                    sta       >$0438
L6009               lda       <$27,u
L600C               cmpa      #$06
                    bcc       L601D
                    lbsr      L3D7D
                    lda       #$33
                    lbsr      L5CEF
                    sta       <$27,u
                    bra       L600C
L601D               rts

L601E               fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
L6026               fcc       'mnln'
                    fcb       C$NULL

fxsnd1              lda       ,u+
fxsnd               ora       #2
                    sta       $ff20
                    rts

fxsnd2              lda       $ff20
                    coma
                    bsr       fxsnd
                    leax      -1,x
                    rts

fxsnd3              orcc      #$50
fxsnd4              lda       #2
                    sta       $ff02
                    rts

                    emod
eom                 equ       *
                    end
