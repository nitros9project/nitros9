********************************************************************
* MNLN - Leisure Suit Larry main line module
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
* Annotated by /annotate-asm (Claude Code) 2026-05-15:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction

*  >$0154  flag for using extended lookups
*  >$0541  joystick button status
*  >$0532  vol_handle_table
*  >$05B9  input_edit_disabled


StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

*  equates for direct page vars
*  shared with sierra module
DataBlockSize               equ       $00                 holds size of data block
SierraRemapOff               equ       $09                 sierra - offset from entry to the routine for the remap call
PsgCurLatch               equ       $0A
ScrnRemapOff               equ       $19                 scrn - offset from entry to the routine for the remap call
ShdwRemapOff               equ       $21                 shdw - offset from entry to the routine for the remap call
SierraRemapVal               equ       $22                 sierra remap value holder
ScrnRemapVal               equ       $26                 scrn remap value holder
ShdwRemapVal               equ       $28                 shdw remap value holder
PixDispAddr               equ       $2C
SierraBiasVal               equ       $2E
ViewObjBase               equ       $30
ViewObjEnd               equ       $32
ViewObjSizeD               equ       $34
ViewObjLast               equ       $36
BlockPtr               equ       $38
BlockOffset               equ       $3A
BlockSizeLimit               equ       $3C
LoopCounter               equ       $3E
TextRow               equ       $40
TextCol               equ       $41
PsgBlockNum               equ       $42
PsgPortAddr               equ       $43
DrawAttr               equ       $45
SierraModSize               equ       $4B
MnlnModSize               equ       $4D
HeapPtr               equ       $4F
HeapEnd               equ       $51
HeapBase               equ       $53
HeapTop               equ       $55
HeapMax               equ       $57
HeapByteCnt               equ       $58
ShdwContact               equ       $5C
PriorityYBase               equ       $5F
CurrentLogicPtr               equ       $62
LogicTablePtr               equ       $64
VolFileSize               equ       $66
NegCondFlag               equ       $68
FirstExecFlag               equ       $69
StringPtrFlag               equ       $6A
SavedYPtr               equ       $6C
TempRegA               equ       $6E
ObjXPos               equ       $6F
TempObjByte               equ       $70
ObjXRight               equ       $71
WordMatchCnt               equ       $72
WordMatchFlag               equ       $73
AnimStep               equ       $74
AnimStepMax               equ       $75
TempMultByte               equ       $76
OpenPathCnt               equ       $77                 open path counter
PathNum               equ       $78                 path number holder
DiskNameBufPtr               equ       $79
CmpKey3Hi               equ       $7B
CmpKey3Lo               equ       $7D
DiskKeyAHi               equ       $7E
DiskKeyALo               equ       $80
DiskKeyBHi               equ       $81
DiskKeyBLo               equ       $83
SeekMSW               equ       $84                 seek MSW
SeekLSW               equ       $86                 seek LSW
DivDivisor               equ       $88
DiskInfoIdx               equ       $89
RandSeedHi               equ       $8B
RandSeedLo               equ       $8C
DivBitCount               equ       $8D
DelayParam               equ       $8E
DelayParamX               equ       $90
EvtWritePtr               equ       $92
EvtReadPtr               equ       $94
JoyNum               equ       $96                 holds joystick number
JoyDirState               equ       $97
JoyEnabled               equ       $98
JoyLastDir               equ       $99
JoyTimerLo               equ       $9A
JoyTimerHi               equ       $9C
JoyDebounce               equ       $9D


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
                    lbra      ModuleEntry
AgiCopyright        fcc       /AGI (c) copyright 1988 SIERRA On-Line/
                    fcc       /CoCo3 version by Chris Iden/
                    fcb       0
PauseMsg            fcc       /      Game paused./
                    fcb       $0a
                    fcc       /Press ENTER to continue./
                    fcb       0
QuitMsg             fcc       /Press ENTER to quit./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to keep playing./
                    fcb       0

ModuleEntry         leas      -6,s                make room on the stack
                    lbsr      PatchCmdTable               modifies table values at 1B0
                    lbsr      FixupEvalTbl               modifies table values at D09
                    lbsr      InitGameState               calls the mmu twiddler at >$659
*                         uses toc and words.tok

MainCycleLoop       clra
                    ldb       >$043B              ** who loads me with ??
                    std       ,s
CycleLoopTop        lbsr      JoystickPoll
CheckScriptTimer    ldd       <$003E
                    cmpd      ,s
TimerReady          bcc       ResetGameState
                    cmpd      $04,s
                    beq       CheckScriptTimer
                    std       $04,s
                    bra       CycleLoopTop
ResetGameState      ldd       #$0000
                    std       <$003E
                    lbsr      ClearInputBuffer               self contained call to clear 50 bytes 05BA
ClearCycleFlags     lda       >$01AE
                    anda      #$DF
StoreStateFlag      sta       >$01AE
                    lda       >$01AE
                    anda      #$F7
                    sta       >$01AE
                    lbsr      EventLoop
                    ldx       <$0030
                    lda       >$0250
                    beq       SetEgoDir
                    lda       >$0437
                    sta       <$21,x
                    bra       DispatchMotionObjs
SetEgoDir           lda       <$21,x
                    sta       >$0437
DispatchMotionObjs  lbsr      DispatchMotion
                    lda       >$01AF
                    anda      #$40
                    sta       $03,s
                    lbsr      GetStackFrame
RunScriptLoop       lda       >$0434
ScriptEntryPoint    sta       $02,s
                    clrb
                    lbsr      ExecLogic
                    leay      ,y
                    bne       ScriptDone
                    clra
                    sta       >$043A
                    sta       >$0436
                    sta       >$0435
                    lda       >$01AE
                    anda      #$DF
                    sta       >$01AE
                    bra       RunScriptLoop
ScriptDone          lda       >$0437
                    ldx       <$0030
                    sta       <$21,x
                    lda       $02,s
                    cmpa      >$0434
                    bne       UpdateScreenState
                    lda       >$01AF
                    anda      #$40
                    cmpa      $03,s
                    beq       CycleEndCleanup
UpdateScreenState   lbsr      StatusLineWrite
CycleEndCleanup     clra
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
                    lbne      MainCycleLoop
                    lbsr      UpdateAllObjs
                    lbra      MainCycleLoop

cmd_pause
CmdPauseImpl        lda       #$01
                    sta       >$0102              set clock_state = 1
                    lbsr      events_clear               events_clear
                    leau      >PauseMsg,pcr          get addr of game paused msg
                    lbsr      message_box               pass it to message_box()
                    clr       >$0102              set clock_state = 0
                    rts

cmd_quit
CmdQuitImpl         lda       ,y+
                    cmpa      #$01
                    beq       DoQuitAgi               if arg was a 1 then quit
                    leau      >QuitMsg,pcr          get addr of quit / continue msg
                    lbsr      message_box               pass it to message_box()
                    beq       CmdQuitReturn               if we didn't get a 1 continue play

DoQuitAgi           lda       #$03                load the offset to exit_agi()
                    sta       <$0009
                    ldx       <$0022              set up to jump to sierra
                    jsr       >$0701              mmu twiddle
CmdQuitReturn       rts

* every other word gets added to by a value saved in sierra
* when this module is loaded. I assume it's a mem offset
* Jump table of some kind  but what are the second words used
* to do ????

* the first word is the pointer to the function
* the second word holds two items
*   MSB = number of parameters
*   LSB = parameter flag

cmd_table
CmdTableStart       fdb       NoopCmdsRet,$0000         *do nothing
                    fdb       cmd_increment,$180          *increment
                    fdb       cmd_decrement,$180          *decrement
                    fdb       cmd_assignn,$280          *assign nn
                    fdb       cmd_assignv,$2c0          *assign nv
                    fdb       cmd_addn,$280          *add n
                    fdb       cmd_addv,$2c0          *add v
                    fdb       cmd_subn,$280          *sub n
                    fdb       cmd_subv,$2c0          *sub v
                    fdb       cmd_lindirectv,$2c0          *l indirect v
                    fdb       cmd_rindirect,$2c0          *r indirect
                    fdb       cmd_lindirectn,$280          *l indirect n

                    fdb       CmdSetImpl,$100          *set
                    fdb       CmdResetImpl,$100          *reset
                    fdb       CmdToggleImpl,$100          *toggle
                    fdb       CmdSetVImpl,$180          *set v
                    fdb       CmdResetVImpl,$180          *reset v
                    fdb       CmdToggleVImpl,$180          *toggle v

                    fdb       cmd_new_room,$100          *new room
                    fdb       cmd_new_room_v,$180          *new room v

                    fdb       cmd_load_logics,$100          *load logics
                    fdb       cmd_load_logics_v,$180          *load logics v
                    fdb       cmd_call,$100          *call
                    fdb       cmd_call_v,$180          *call v

                    fdb       cmd_load_pic,$180          *load pic
                    fdb       cmd_draw_pic,$180          *draw pic
                    fdb       cmd_show_pic,$0000         *show pic
                    fdb       cmd_discard_pic,$180          *discard overlay
                    fdb       cmd_overlay_pic,$180          *animate obj

                    fdb       CmdSaveGame,$0000         *show pri

                    fdb       cmd_load_view,$100          *load view
                    fdb       cmd_load_view_v,$180          *load view v
                    fdb       cmd_discard_view,$100          *discard view

                    fdb       CmdAnimateObj,$100          *animate obj
                    fdb       CmdUnanimateAll,$0000         *unanumate all

                    fdb       CmdDrawImpl,$100          *draw
                    fdb       CmdEraseImpl,$100          *erase

                    fdb       cmd_position,$300          *position
                    fdb       cmd_position_v,$360          *position v
                    fdb       cmd_get_position,$360          *get position
                    fdb       cmd_reposition,$360          *reposition

                    fdb       cmd_set_view,$200          *set view
                    fdb       cmd_set_view_v,$240          *set view v
                    fdb       cmd_set_loop,$200          *set loop
                    fdb       cmd_set_loop_v,$240          *set loop v

                    fdb       CmdFixLoop,$100          *fix loop
                    fdb       CmdReleaseLoop,$100          *release loop

                    fdb       cmd_set_cel,$200          *set cel
                    fdb       cmd_set_cel_v,$240          *set cel v
                    fdb       cmd_last_cel,$240          *last cel
                    fdb       cmd_current_cel,$240          *current cel
                    fdb       cmd_current_loop,$240          *current loop
                    fdb       cmd_current_view,$240          *current view
                    fdb       cmd_number_of_loops,$240          *number of loops

                    fdb       cmd_set_priority,$200          *set priority
                    fdb       cmd_set_priority_v,$240          *set priority v
                    fdb       cmd_release_priority,$100          *release priority
                    fdb       cmd_get_priority,$240          *get priority

                    fdb       CmdStopUpdate,$100          *stop update
                    fdb       CmdStartUpdate,$100          *start update
                    fdb       CmdForceUpdate,$100          *force update

                    fdb       cmd_ignore_horizon,$100          *ignore horizon
                    fdb       cmd_observe_horizon,$100          *observe horizon
                    fdb       cmd_set_horizon,$100          *set horizon
                    fdb       cmd_obj_on_water,$100          *obj on water
                    fdb       cmd_obj_on_land,$100          *obj on land
                    fdb       cmd_obj_on_anything,$100          *obj on anything

                    fdb       CmdIgnoreObjects,$100          *ignore objects
                    fdb       CmdObserveObjects,$100          *observe objects
                    fdb       CmdDistance,$320          *distance
                    fdb       CmdStopCycling,$100          *stop cycling
                    fdb       CmdStartCycling,$100          *start cycling
                    fdb       CmdNormalCycle,$100          *normal cycle
                    fdb       CmdEndOfLoop,$200          *end of loop
                    fdb       CmdReverseCycle,$100          *reverse cycle
                    fdb       CmdReverseLoop,$200          *reverse loop
                    fdb       CmdSetCycleTime,$240          *cycle time

                    fdb       cmd_stop_motion,$100          *stop motion
                    fdb       cmd_start_motion,$100          *start motion
                    fdb       cmd_step_size_v,$240          *step size
                    fdb       cmd_step_time,$240          *step time
                    fdb       cmd_move_obj,$500          *move obj
                    fdb       cmd_move_obj_v,$570          *move obj v
                    fdb       cmd_follow_ego,$300          *follow ego
                    fdb       cmd_wander,$100          *wander
                    fdb       cmd_normal_motion,$100          *normal motion
                    fdb       cmd_set_dir,$240          *set dir

                    fdb       cmd_get_dir,$240          *get dir

                    fdb       CmdIgnoreBlocks,$100          *ignore blocks
                    fdb       CmdObserveBlocks,$100          *observe blocks
                    fdb       CmdSetBlock,$400          *block
                    fdb       CmdClearBlock,$0000         *unblock

                    fdb       cmd_get,$100          *get
                    fdb       cmd_get_v,$180          *get v
                    fdb       cmd_drop,$100          *drop
                    fdb       cmd_put,$200          *put
                    fdb       cmd_put_v,$240          *put v
                    fdb       cmd_get_room_v,$2c0          *get room v

                    fdb       cmd_load_sound,$100          *load sound
                    fdb       cmd_sound,$200          *sound
                    fdb       NoopCmdsRet,$0000         *stop sound
                    fdb       cmd_print,$100          *print
                    fdb       cmd_print_v,$180          *print v
                    fdb       cmd_display,$300          *display

                    fdb       cmd_display_v,$3e0          *display v
                    fdb       cmd_clear_lines,$300          *clear lines
                    fdb       cmd_text_screen,$0000         *text screen
                    fdb       cmd_graphics,$0000         *graphics
                    fdb       cmd_set_cursor_char,$100          *set cursor char
                    fdb       cmd_set_text_attribute,$200          *set text attribute
                    fdb       cmd_shake_screen,$100          *shake screen
                    fdb       cmd_config_screen,$300          *config screen
                    fdb       cmd_status_line_on,$0000         *status line on
                    fdb       cmd_status_line_off,$0000         *status line off

                    fdb       cmd_set_string,$200          *set string
                    fdb       cmd_get_string,$500          *get string
                    fdb       cmd_word_to_string,$200          *word to string
                    fdb       cmd_parse,$100          *parse
                    fdb       CmdObjStatus,$240          *get num
                    fdb       cmd_prevent_input,$0000         *prevent input
                    fdb       cmd_accept_input,$0000         *accept inpur
                    fdb       CmdSetKey,$300          *set key
                    fdb       cmd_add_to_pic,$700          *add to pic
                    fdb       cmd_add_to_pic_v,$7fe          *add to pic v
                    fdb       cmd_status,$0000         *status
                    fdb       cmd_save_game,$0000         *save game
                    fdb       cmd_restore_game,$0000         *restore game
                    fdb       NoopCmdsRet,$0000         *init disk
                    fdb       cmd_restart_game,$0000         *restart game
                    fdb       cmd_show_obj,$100          *sow obj
                    fdb       CmdRandomImpl,$320          *random
                    fdb       cmd_program_control,$0000         *program control
                    fdb       cmd_player_control,$0000         *player control
                    fdb       CmdObjStatusV,$180          *obj status v
                    fdb       CmdQuitImpl,$100          *quit
                    fdb       CmdShowMemInfo,$0000         *show mem
                    fdb       CmdPauseImpl,$0000         *pause
                    fdb       cmd_echo_line,$0000         *echo line
                    fdb       cmd_cancel_line,$0000         *cancel line
                    fdb       cmd_init_joy,$0000         *init joy
                    fdb       cmd_toggle_monitor,$0000         *toggle monitor
                    fdb       CmdShowAgiInfo,$0000         *version
                    fdb       cmd_script_size,$100          *script size
                    fdb       cmd_set_game_id,$100          *set game id
                    fdb       cmd_shake_screen,$100          *log
                    fdb       cmd_set_scan_start,$0000         *set scan start
                    fdb       cmd_reset_scan_start,$0000         *reset scan start
                    fdb       cmd_reposition_to,$300          *reposition to
                    fdb       cmd_reposition_to_v,$360          *reposition to v
                    fdb       cmd_trace_on,$0000         *trace on
                    fdb       cmd_trace_info,$300          *trace info
                    fdb       cmd_print_at,$400          *print at
                    fdb       cmd_print_at_v,$480          *print at v
                    fdb       cmd_discard_view_v,$180          *discard view v
                    fdb       cmd_clear_text_rect,$500          *clear text rect
                    fdb       cmd_set_upper_left,$200          *set upper left
                    fdb       cmd_set_menu,$100          *set menu
                    fdb       cmd_set_menu_item,$200          *set menu item
                    fdb       cmd_submit_menu,$0000         *submit menu
                    fdb       cmd_enable_item,$100          *enable item
                    fdb       cmd_disable_item,$100          *disable item
                    fdb       cmd_menu_input,$0000         *menu input
                    fdb       cmd_show_obj_v,$100          *show obj v
                    fdb       NoopCmdsRet,$0000         *open dialogue
                    fdb       NoopCmdsRet,$0000         *close dialogue
                    fdb       cmd_multn,$280          *mult n
                    fdb       cmd_multv,$2c0          *mult v
                    fdb       cmd_divn,$280          *div n
                    fdb       cmd_divv,$2c0          *div v
                    fdb       cmd_close_window,$0000         *close window
                    fdb       cmd_set_simple,$100          *set simple
                    fdb       cmd_push_script,$0000         *push script
                    fdb       cmd_pop_script,$0000         *pop script
                    fdb       NoopCmdsRet,$0000         *hold key
                    fdb       SetPriBaseStub,$100         *set pri base, via patch stub
                    fdb       cmd_shake_screen,$180          *discard sound
                    fdb       NoopCmdsRet,$0000         *do nothing
                    fdb       cmd_show_menu,$100
                    fdb       NoopCmdsRet,$0000         *do nothing
                    fdb       cmd_hide_mouse,$400          *hide mouse
                    fdb       cmd_set_upper_left,$2c0          *allow menu
                    fdb       NoopCmdsRet,$0000         *do nothing

PatchCmdTable       leas      -$01,s
                    lda       #$B6
                    sta       ,s
                    leau      >CmdTableStart,pcr
PatchCmdTableLoop   ldd       <$002E
                    addd      ,u
                    std       ,u
                    leau      $04,u
                    dec       ,s
                    bne       PatchCmdTableLoop
                    leas      $01,s
                    rts
DispatchCmd         cmpb      #$B5
                    bls       CheckTraceFlag
                    lda       #$10
                    lbsr      ReportError
CheckTraceFlag      lda       <$0068
                    beq       CallCmdHandler
                    cmpa      #$01
                    bne       CallCmdHandler
                    pshs      y
                    lbsr      ScriptDispatch
                    puls      y
CallCmdHandler      leax      >cmd_table,pcr
                    lda       #$04
                    mul
                    jsr       [d,x]
                    leay      ,y
                    beq       DispatchCmdReturn
                    ldb       ,y+
                    beq       DispatchCmdReturn
                    cmpb      #$FC
                    bcs       DispatchCmd
DispatchCmdReturn   rts
AdvanceCelFrame     lda       <$25,u
                    bita      #$10
                    beq       GetCelIndex
                    anda      #$EF
                    sta       <$25,u
                    bra       AdvCelReturn
GetCelIndex         ldd       $0E,u
                    decb
                    std       <$0074
                    lda       <$23,u
                    cmpa      #$00
                    bne       CycleReverse
                    ldb       <$0074
                    incb
                    cmpb      <$0075
                    bls       SetCelInLoop
                    clrb
                    bra       SetCelInLoop
CycleReverse        cmpa      #$03
                    bne       CycleRevEnd
                    ldb       <$0074
                    decb
                    bpl       SetCelInLoop
                    ldb       <$0075
                    bra       SetCelInLoop
CycleRevEnd         cmpa      #$02
                    bne       CycleEnd
                    ldb       <$0074
                    beq       NotifyEndOfLoop
                    decb
                    bne       SetCelInLoop
                    stb       <$0074
                    bra       NotifyEndOfLoop
CycleEnd            cmpa      #$01
                    bne       SetCelInLoop
                    ldb       <$0074
                    cmpb      <$0075
                    bcc       NotifyEndOfLoop
                    incb
                    cmpb      <$0075
                    bne       SetCelInLoop
                    stb       <$0074
NotifyEndOfLoop     lda       <$27,u
                    lbsr      SetFlag
                    lda       <$26,u
                    anda      #$DF
                    sta       <$26,u
                    clra
                    sta       <$21,u
                    sta       <$23,u
                    ldb       <$0074
SetCelInLoop        lbsr      SetCelHelper
AdvCelReturn        rts
CmdFixLoop          lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,x
                    lda       <$25,x
                    ora       #$20
                    sta       <$25,x
                    rts
CmdReleaseLoop      lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,x
                    lda       <$25,x
                    anda      #$DF
                    sta       <$25,x
                    rts
IsOnWater           lda       #$01
                    ldb       <$26,u
                    andb      #$51
                    cmpb      #$51
                    beq       IsOnWaterOk
                    clra
IsOnWaterOk         rts
IsOnLand            lda       #$01
                    ldb       <$26,u
                    andb      #$51
                    cmpb      #$41
                    beq       IsOnLandOk
                    clra
IsOnLandOk          rts
SetWaterRange       ldx       #$0548
                    leau      >IsOnWater,pcr
                    lbsr      ScanViewObjs
                    rts
SetLandRange        ldx       #$054C
                    leau      >IsOnLand,pcr
                    lbsr      ScanViewObjs
                    rts
ClearBothRanges     ldx       #$0548
                    lbsr      BlitListDraw
                    ldx       #$054C
                    lbsr      BlitListDraw
                    rts
SwapObjRanges       bsr       SetLandRange
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    bsr       SetWaterRange
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    rts
UpdateObjSegments   ldx       #$054C
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
ResetObjRanges      ldx       #$0548
                    lbsr      ProcessDrawList
                    ldx       #$054C
                    lbsr      ProcessDrawList
                    rts
CmdStopUpdate       lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    bsr       StopUpdateHelper
                    rts
CmdStartUpdate      lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    bsr       StartUpdateHelper
                    rts
CmdForceUpdate      lda       ,y+
                    bsr       ClearBothRanges
                    bsr       SwapObjRanges
                    bsr       UpdateObjSegments
                    rts
StopUpdateHelper    lda       <$26,u
                    bita      #$10
                    beq       StopUpdateReturn
                    pshs      u
                    lbsr      ClearBothRanges
                    puls      u
                    lda       <$26,u
                    anda      #$EF
                    sta       <$26,u
                    lbsr      SwapObjRanges
StopUpdateReturn    rts
StartUpdateHelper   lda       <$26,u
                    bita      #$10
                    bne       StartUpdateReturn
                    pshs      u
                    lbsr      ClearBothRanges
                    puls      u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    lbsr      SwapObjRanges
StartUpdateReturn   rts
DirTableFwd         fcb       4,4,0,0,0,4,1,1,1
DirTableRev         fcb       4,3,0,0,0,2,1,1,1

CmdAnimateObj       lda       ,y+
                    bsr       AnimateObjHelper
                    rts
AnimateObjHelper    leas      -$01,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    cmpu      <$0032
                    bcs       AnimObjBadIndex
                    lda       #$0D
                    ldb       ,s
                    lbsr      ReportError
AnimObjBadIndex     lda       <$26,u
                    bita      #$40
                    bne       AnimObjAlready
                    lda       #$70
                    sta       <$26,u
                    lda       #$00
                    sta       <$22,u
                    sta       <$23,u
                    sta       <$21,u
AnimObjAlready      leas      $01,s
                    rts
CmdUnanimateAll     lbsr      ClearBothRanges
                    ldu       <$0030
UnanimateAllLoop    cmpu      <$0032
                    bcc       UnanimateAllDone
                    lda       <$26,u
                    anda      #$BE
                    sta       <$26,u
                    leau      <$2B,u
                    bra       UnanimateAllLoop
UnanimateAllDone    rts
UpdateAllObjs       leas      -$01,s
                    clr       ,s
                    ldu       <$0030
UpdateAllLoop       cmpu      <$0032
                    bcc       UpdateAllPostLoop
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    bne       NextObjInUpdateLoop
                    inc       ,s
                    ldb       #$04
                    lda       <$25,u
                    bita      #$20
                    bne       CheckCycleTick
                    lda       $0B,u
                    cmpa      #$03
                    bhi       CheckCycleType4
                    cmpa      #$02
                    bcs       CheckCycleTick
                    lda       <$21,u
                    leay      >DirTableFwd,pcr
                    ldb       a,y
                    bra       CheckObjVisible
CheckCycleType4     cmpa      #$04
                    beq       LookupRevDirTable
                    lda       >$01B0
                    anda      #$08
                    beq       CheckCycleTick
LookupRevDirTable   lda       <$21,u
                    leay      >DirTableRev,pcr
                    ldb       a,y
CheckObjVisible     lda       $01,u
CheckObjIsEgo       cmpa      #$01
                    bne       CheckCycleTick
                    cmpb      #$04
                    beq       CheckCycleTick
                    cmpb      $0A,u
                    beq       CheckCycleTick
                    lbsr      SetLoopHelper
CheckCycleTick      lda       <$26,u
                    bita      #$20
                    beq       NextObjInUpdateLoop
                    lda       <$20,u
                    beq       NextObjInUpdateLoop
                    dec       <$20,u
                    bne       NextObjInUpdateLoop
                    lbsr      AdvanceCelFrame
                    lda       <$1F,u
                    sta       <$20,u
NextObjInUpdateLoop leau      <$2B,u
                    bra       UpdateAllLoop
UpdateAllPostLoop   lda       ,s
                    beq       UpdateAllReturn
                    ldx       #$0548
                    lbsr      BlitListDraw
                    lbsr      UpdateAllMotion
                    lbsr      SetWaterRange
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
UpdateAllReturn     leas      $01,s
                    rts
DispatchMotion      ldu       <$0030
MotionObjLoop       cmpu      <$0032
                    bcc       DispatchMotionDone
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    bne       NextMotionObj
                    lda       $01,u
                    cmpa      #$01
                    bne       NextMotionObj
                    lda       <$22,u
                    beq       MotionCheckBlock
                    cmpa      #$01
                    bne       MotionTypeWander
                    lbsr      ObjAnimStep
                    bra       MotionCheckBlock
MotionTypeWander    cmpa      #$02
                    bne       MotionTypeFollow
                    lbsr      CalcFollowDir
                    bra       MotionCheckBlock
MotionTypeFollow    cmpa      #$03
                    bhi       MotionCheckBlock
                    lbsr      SetObjMotion
MotionCheckBlock    lda       <$26,u
                    ldb       >$01AC
                    bne       MotionCheckCollide
                    anda      #$7F
                    sta       <$26,u
                    bra       NextMotionObj
MotionCheckCollide  bita      #$02
                    bne       NextMotionObj
                    lda       <$21,u
                    beq       NextMotionObj
                    bsr       MoveObjOneStep
NextMotionObj       leau      <$2B,u
                    bra       MotionObjLoop
DispatchMotionDone  rts
MoveObjOneStep      leas      -$03,s
                    ldd       $03,u
                    std       $01,s
                    lbsr      InBlockRect
                    sta       ,s
                    lda       <$21,u
                    beq       MoveNoBlock
                    cmpa      #$01
                    bne       MoveDir2Diagonal
                    ldb       $02,s
                    subb      <$1E,u
                    lda       $01,s
                    bra       CheckMoveCollision
MoveDir2Diagonal    cmpa      #$02
                    bne       MoveDir3
                    ldd       $01,s
                    adda      <$1E,u
                    subb      <$1E,u
                    bra       CheckMoveCollision
MoveDir3            cmpa      #$03
                    bne       MoveDir4
                    lda       $01,s
                    adda      <$1E,u
                    ldb       $02,s
                    bra       CheckMoveCollision
MoveDir4            cmpa      #$04
                    bne       MoveDir5
                    ldd       $01,s
                    adda      <$1E,u
                    addb      <$1E,u
                    bra       CheckMoveCollision
MoveDir5            cmpa      #$05
                    bne       MoveDir6
                    ldb       $02,s
                    addb      <$1E,u
                    lda       $01,s
                    bra       CheckMoveCollision
MoveDir6            cmpa      #$06
                    bne       MoveDir7
                    ldd       $01,s
                    suba      <$1E,u
                    addb      <$1E,u
                    bra       CheckMoveCollision
MoveDir7            cmpa      #$07
                    bne       MoveDir8
                    lda       $01,s
                    suba      <$1E,u
                    ldb       $02,s
                    bra       CheckMoveCollision
MoveDir8            ldd       $01,s
                    suba      <$1E,u
                    subb      <$1E,u
CheckMoveCollision  lbsr      InBlockRect
                    cmpa      ,s
                    bne       MoveIsBlocked
MoveNoBlock         lda       <$26,u
                    anda      #$7F
                    sta       <$26,u
                    bra       MoveOneStepReturn
MoveIsBlocked       lda       <$26,u
                    ora       #$80
                    sta       <$26,u
                    clr       <$21,u
                    cmpu      <$0030
                    bne       MoveOneStepReturn
                    clr       >$0437
MoveOneStepReturn   leas      $03,s
                    rts
CmdSetBlock         lda       #$01
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
CmdClearBlock       clr       >$01AC
                    rts
CmdIgnoreBlocks     lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$02
                    sta       <$26,u
                    rts
CmdObserveBlocks    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$FD
                    sta       <$26,u
                    rts
InBlockRect         leas      -$01,s
                    clr       ,s
                    cmpa      >$024E
                    bls       InBlockRectReturn
                    cmpa      >$023C
                    bcc       InBlockRectReturn
                    cmpb      >$024F
                    bls       InBlockRectReturn
                    cmpb      >$023D
                    bcc       InBlockRectReturn
                    inc       ,s
InBlockRectReturn   lda       ,s
                    leas      $01,s
                    rts
CheckObjCollision   clra
                    ldb       <$25,u
                    bitb      #$02
                    bne       CollisionReturn
                    ldx       <$0030
CheckCollisionLoop  cmpx      <$0032
                    bcc       CollisionReturn
                    ldb       <$26,x
                    andb      #$41
                    cmpb      #$41
                    bne       NextCollisionObj
                    ldb       <$25,x
                    bitb      #$02
                    bne       NextCollisionObj
                    ldb       $02,x
                    cmpb      $02,u
                    beq       NextCollisionObj
                    ldb       $03,u
                    addb      <$1C,u
                    cmpb      $03,x
                    bcs       NextCollisionObj
                    ldb       $03,x
                    addb      <$1C,x
                    cmpb      $03,u
                    bcs       NextCollisionObj
                    ldb       $04,x
                    cmpb      $04,u
                    beq       CollisionDetected
                    bhi       CheckPriorityHigher
                    ldb       <$1B,x
                    cmpb      <$1B,u
                    bhi       CollisionDetected
                    bra       NextCollisionObj
CheckPriorityHigher ldb       <$1B,x
                    cmpb      <$1B,u
                    bcs       CollisionDetected
NextCollisionObj    leax      <$2B,x
                    bra       CheckCollisionLoop
CollisionDetected   lda       #$01
CollisionReturn     rts
CmdIgnoreObjects    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$02
                    sta       <$25,u
                    rts
CmdObserveObjects   lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    anda      #$FD
                    sta       <$25,u
                    rts
CmdDistance         lda       ,y+
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
                    beq       StoreDistResult
                    ldb       <$26,u
                    bitb      #$01
                    beq       StoreDistResult
                    lda       <$1C,u
                    lsra
                    adda      $03,u
                    ldb       <$1C,x
                    lsrb
                    addb      $03,x
                    stb       <$0076
                    suba      <$0076
                    bcc       CalcDistStoreX
                    nega
CalcDistStoreX      sta       <$0076
                    lda       $04,u
                    suba      $04,x
                    bcc       CalcDistAddY
                    nega
CalcDistAddY        adda      <$0076
                    bcs       DistMaxOut
                    cmpa      #$FF
                    bne       StoreDistResult
DistMaxOut          lda       #$FE
StoreDistResult     ldb       ,y+
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts
ClearInputBuffer    ldu       #$05BA
                    ldx       #$0032
                    clrb
                    lbsr      FillMem
                    rts
CmdSetKey           ldx       #$01D8
                    lda       #$32
ScanKeyTableLoop    tst       ,x
                    beq       KeySlotFound
                    deca
                    bne       NextKeySlot
                    ldx       #$0000
                    bra       KeySlotFound
NextKeySlot         leax      $02,x
                    bra       ScanKeyTableLoop
KeySlotFound        lda       ,y+
                    ldb       ,y+
                    beq       StoreKeyEntry
                    tfr       b,a
                    adda      #$FB
StoreKeyEntry       ldb       ,y+
                    leax      ,x
                    beq       KeyDone
                    std       ,x
KeyDone             rts
CmdNormalCycle      lda       ,y+
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
CmdEndOfLoop        lda       ,y+
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
                    lbsr      ClearFlag
                    rts
CmdReverseCycle     lda       ,y+
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
CmdReverseLoop      lda       ,y+
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
                    lbsr      ClearFlag
                    rts
CmdSetCycleTime     lda       ,y+
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
CmdStopCycling      lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$DF
                    sta       <$26,u
                    rts
CmdStartCycling     lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$20
                    sta       <$26,u
                    rts

StrNormalCycle      fcc       /normal cycle/
                    fcb       0
StrEndOfLoop        fcc       /end of loop/
                    fcb       0
StrReverseLoop      fcc       /reverse loop/
                    fcb       0
StrReverseCycle     fcc       /reverse cycle/
                    fcb       0
StrNormalMotion     fcc       /normal motion/
                    fcb       0
StrWander           fcc       /wander/
                    fcb       0
StrFollow           fcc       /follow/
                    fcb       0
StrMoveTo           fcc       /move to (%d, %d)/
                    fcb       0
StrObjHeader        fcc       /Object %d:/
                    fcb       $0a
StrObjX             fcc       /x: %d  xsize: %d/
                    fcb       $0a
StrObjY             fcc       /y: %d  ysize: %d/
                    fcb       $0a
StrObjPri           fcc       /pri: %d/
                    fcb       $0a
StrObjStepSize      fcc       /stepsize: %d/
                    fcb       $0a
StrObjControl       fcc       /control: %x/
                    fcb       $0a
StrFmtNewline       fcc       /%s/
                    fcb       $0a
StrFmtNull          fcc       /%s/
                    fcb       0
StrAgiVersion       fcc       /Adventure Game Interpreter/
                    fcb       $0a
                    fcc       /      Version 2.072/
                    fcb       0
StrRoom             fcc       /room: %u/
                    fcb       $0a
StrHeapSize         fcc       /heap size: %u/
                    fcb       $0a
StrHeapNowMax       fcc       /now: %u  max: %u/
                    fcb       $0a
StrRm0Size          fcc       /rm.0, etc.: %u/
                    fcb       $0a
StrCommonSize       fcc       /common size: %u/
                    fcb       $0a
StrTableNowMax      fcc       /now: %u  max: %u/
                    fcb       $0a
StrTablesSize       fcc       /tables, etc.: %u/
                    fcb       $0a
StrMaxScript        fcc       /max script: %u/
                    fcb       0

CmdObjStatus        leas      -$54,s
                    lbsr      InputEditOn
                    lda       $01d7
                    clrb
                    std       <$0040
                    ldb       ,y+
                    lbsr      GetMsgPtr
                    leax      $04,s
ObjStatusLoop       ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      MsgTextSetup
                    leas      $06,s
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    clr       ,s
                    ldb       #$04
                    leax      ,s
                    lbsr      EditString
                    lbsr      InputRedraw
                    leax      ,s
                    lbsr      StrLen
                    beq       ObjStatusDone
                    lbsr      AtoI
ObjStatusDone       ldx       #$0431
                    ldb       ,y+
ObjStatusStore      abx
                    sta       ,x
                    leas      <$54,s
                    rts
* obj.status.v command
CmdObjStatusV       leas      >-$0194,s
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
                    bne       CheckCycleType1
                    leax      >StrNormalCycle,pcr          normal cycle
                    bra       GotCycleStr
CheckCycleType1     cmpa      #$01
                    bne       CheckCycleType2
                    leax      >StrEndOfLoop,pcr          end of loop
                    bra       GotCycleStr
CheckCycleType2     cmpa      #$02
                    bne       DefaultCycleStr
                    leax      >StrReverseLoop,pcr          reverse loop
                    bra       GotCycleStr
DefaultCycleStr     leax      >StrReverseCycle,pcr          reverse cycle
GotCycleStr         stx       >$0190,s
                    lda       <$22,u              motion type
                    cmpa      #$00
                    bne       CheckMotionType1
                    leax      >StrNormalMotion,pcr          normal motion
                    bra       GotMotionStr
CheckMotionType1    cmpa      #$01
                    bne       CheckMotionType2
                    leax      >StrWander,pcr          wander
                    bra       GotMotionStr
CheckMotionType2    cmpa      #$02
                    bne       BuildMoveToStr
                    leax      >StrFollow,pcr          follow
                    bra       GotMotionStr
BuildMoveToStr      clra
                    ldb       <$28,u              y pos
                    pshs      b,a
                    ldb       <$27,u              x pos
                    pshs      b,a
                    leax      >StrMoveTo,pcr          move to (x,y)
                    pshs      x
                    leax      >$0132,s
                    pshs      x
                    lbra      stub1               format string into X
MoveToFormatDone    leas      $08,s
GotMotionStr        pshs      x
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
                    leau      >StrObjHeader,pcr          msg
                    pshs      u
                    leax      <$16,s
                    pshs      x
                    lbsr      PrintFmtStr               format string
                    leas      <$18,s
                    lbsr      message_box               message box
                    leas      >$0194,s
                    rts
CmdSaveGame         inc       >$0550
                    lbsr      gfx_picbuff_update
                    lbsr      BooleanPoll
                    lbsr      gfx_picbuff_update
                    clr       >$0550
                    rts
CmdShowAgiInfo      leau      >StrAgiVersion,pcr
                    lbsr      message_box
                    rts
CmdShowMemInfo      leas      >-$00C8,s
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
                    leax      >StrRoom,pcr
                    leau      <$12,s
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      <$18,s
                    lbsr      message_box
                    leas      >$00C8,s
                    rts

eval_table          fdb       $0f6e,$0000
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

FixupEvalTbl        leas      -1,s
                    lda       #$13
FixupEvalTblLoop    sta       ,s
                    leau      >eval_table,pcr
EvalTblLoopBody     ldd       <$002E
                    addd      ,u
                    std       ,u
                    leau      $04,u
                    dec       ,s
                    bne       EvalTblLoopBody
                    leas      $01,s
                    rts
EvalExpr            leax      -$01,y
                    stx       <$006C
                    cmpa      #$12
                    bhi       EvalExprUnknown
                    lsla
                    lsla
                    leax      >eval_table,pcr
                    jsr       [a,x]
                    ldb       <$0068
                    beq       EvalExprRet
                    cmpb      #$01
                    bne       EvalExprRet
                    pshs      y
                    sta       <$006E
                    ldu       <$006C
                    lbsr      ScriptArgDispatch
                    puls      y
                    lda       <$006E
                    bra       EvalExprRet
EvalExprUnknown     tfr       a,b
                    lda       #$0F
                    lbsr      ReportError
EvalExprRet         rts
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbne      RetFalse
                    lbra      RetTrue
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    cmpa      ,x
                    lbne      RetFalse
                    lbra      RetTrue
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbcc      RetFalse
                    lbra      RetTrue
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    cmpa      ,x
                    lbcc      RetFalse
                    lbra      RetTrue
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    cmpa      ,y+
                    lbls      RetFalse
                    lbra      RetTrue
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    cmpa      ,x
                    lbls      RetFalse
                    lbra      RetTrue
                    lda       ,y+
                    lbsr      TestFlag
                    lbeq      RetFalse
                    lbra      RetTrue
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    lbsr      TestFlag
                    lbeq      RetFalse
                    lbra      RetTrue
                    rts
                    ldb       ,y+
                    ldx       <$0038
                    abx
                    abx
                    abx
                    lda       #$FF
                    cmpa      $02,x
                    lbne      RetFalse
                    lbra      RetTrue
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
                    lbne      RetFalse
                    lbra      RetTrue
                    lda       ,y+
                    ldx       #$05BA
                    lda       a,x
                    rts
                    ldx       #$0431
                    lda       <$13,x
                    lbne      RetTrue
HaveKeyPollLoop     lbsr      GetKeyEvent
                    cmpa      #$FF
                    beq       HaveKeyPollLoop
                    tsta
                    lbeq      RetFalse
                    sta       <$13,x
                    lbra      RetTrue
                    lda       ,y+
                    sta       <$0072
                    lda       >$015A
                    beq       SaidCheckDone
                    sta       <$0073
                    lda       >$01AE
                    anda      #$08
                    bne       SaidCheckDone
                    lda       >$01AE
                    anda      #$20
                    beq       SaidCheckDone
                    ldx       #$0194
SaidMatchLoop       lda       <$0072
                    beq       SaidCheckDone
                    ldb       ,y+
                    lda       ,y+
                    dec       <$0072
                    cmpd      #$270F
                    bne       SaidCheckWild
                    lda       <$0072
                    beq       SaidSetMatch
                    lsla
                    leay      a,y
                    lbra      SaidSetMatch
SaidCheckWild       tst       <$0073
                    bne       SaidWordCompare
                    inc       <$0073
                    lbra      SaidCheckDone
SaidWordCompare     cmpd      ,x++
                    beq       SaidWordMatch
                    cmpd      #$0001
                    bne       SaidCheckDone
SaidWordMatch       dec       <$0073
                    bra       SaidMatchLoop
SaidCheckDone       ldd       <$0072
                    bne       SaidNoMatch
SaidSetMatch        lda       >$01AE
                    ora       #$08
                    sta       >$01AE
                    lbra      RetTrue
SaidNoMatch         lsla
                    leay      a,y
                    lbra      RetFalse
                    lda       ,y+
                    ldb       ,y+
                    lbsr      MatchWord
                    rts
                    bsr       GetObjViewPtr
                    sta       <$006F
                    sta       <$0071
                    bra       TestPosnX
                    bsr       GetObjViewPtr
                    sta       <$006F
                    lda       <$1C,u
                    lsra
                    adda      <$006F
                    sta       <$006F
                    sta       <$0071
                    bra       TestPosnX
                    bsr       GetObjViewPtr
                    adda      <$1C,u
                    deca
                    sta       <$006F
                    sta       <$0071
                    bra       TestPosnX
                    bsr       GetObjViewPtr
                    sta       <$006F
                    adda      <$1C,u
                    deca
                    sta       <$0071
                    bra       TestPosnX
GetObjViewPtr       ldb       ,y+
                    lda       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldd       $03,u
                    stb       <$0070
                    rts
TestPosnX           ldd       <$006F
                    cmpa      ,y+
                    bcc       TestPosnY
                    leay      $03,y
                    bra       RetFalse
TestPosnY           cmpb      ,y+
                    bcc       TestPosnXRight
                    leay      $02,y
                    bra       RetFalse
TestPosnXRight      lda       <$0071
                    cmpa      ,y+
                    bls       TestPosnYBot
                    leay      $01,y
                    bra       RetFalse
TestPosnYBot        cmpb      ,y+
                    bls       RetTrue
                    bra       RetFalse
RetTrue             lda       #$01
                    rts
RetFalse            clra
                    rts
CmdDrawImpl         lda       ,y+
                    pshs      y
                    bsr       DrawObjHelper
                    puls      y
                    rts
DrawObjHelper       leas      -$03,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    cmpu      <$0032
                    bcs       DrawObjCheckView
                    lda       #$13
                    ldb       ,s
                    lbsr      ReportError
DrawObjCheckView    ldd       <$10,u
                    bne       DrawObjStart
                    lda       #$14
                    lbsr      ReportError
DrawObjStart        lda       <$26,u
                    bita      #$01
                    bne       DrawObjDone
                    stu       $01,s
                    ora       #$10
                    sta       <$26,u
                    lbsr      FindObjPos
                    ldd       <$10,u
                    std       <$12,u
                    ldd       $08,u
                    std       <$14,u
                    ldd       $03,u
                    std       <$1A,u
                    ldx       #$0548
                    lbsr      BlitListDraw
                    ldu       $01,s
                    lda       <$26,u
                    ora       #$01
                    sta       <$26,u
                    lbsr      SetWaterRange
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
DrawObjDone         leas      $03,s
                    rts
CmdEraseImpl        lda       ,y+
                    pshs      y
                    bsr       EraseObjHelper
                    puls      y
                    rts
EraseObjHelper      leas      -$04,s
                    sta       ,s
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    cmpu      <$0032
                    bcs       EraseObjCheck
                    lda       #$0C
                    ldb       ,s
                    lbsr      ReportError
EraseObjCheck       lda       <$26,u
                    bita      #$01
                    beq       EraseObjDone
                    stu       $01,s
                    ldx       #$0548
                    lbsr      BlitListDraw
                    ldu       $01,s
                    lda       <$26,u
                    anda      #$10
                    sta       $03,s
                    bne       EraseObjDraw
                    ldx       #$054C
                    lbsr      BlitListDraw
                    ldu       $01,s
EraseObjDraw        lda       <$26,u
                    anda      #$FE
                    sta       <$26,u
                    lda       $03,s
                    bne       EraseObjScan
                    lbsr      SetLandRange
                    pshs      x
                    lda       #$1E
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
EraseObjScan        lbsr      SetWaterRange
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
EraseObjDone        leas      $04,s
                    rts

XorKeyStr           fcc       /Avis Durgan/
                    fcb       0

XorDecrypt          leas      -$02,s
                    stu       ,s
                    leau      >XorKeyStr,pcr
XorDecryptLoop      cmpx      ,s
                    bcc       XorDecryptDone
                    tst       ,u
                    bne       XorDecryptWrap
                    leau      >XorKeyStr,pcr
XorDecryptWrap      lda       ,x
                    eora      ,u+
                    sta       ,x+
                    bra       XorDecryptLoop
XorDecryptDone      leas      $02,s
                    rts

StrBell             fcb       7,0
StrQuitMsg2         fcb       $0a
                    fcc       /Press CTRL-BREAK to quit./
                    fcb       0
StrTryAgain         fcb       $0a
                    fcc       /Press ENTER to try again./
                    fcb       0
StrSysError         fcc       /System error #%u.%s%s/
                    fcb       0

ReportError         sta       $442
ReportErrorB        stb       >$0443
                    lbsr      ResetHeap
                    lbsr      events_clear
                    lbsr      ResetGameTables
                    bsr       RingBell
                    bsr       RingBell
                    lbsr      RestoreStackFrame
ErrorDialog         leas      >-$00B1,s
                    lbsr      InputEditOn
                    bsr       RingBell
                    bsr       RingBell
ErrorFormatMsg      leau      >StrQuitMsg2,pcr
                    pshs      u
                    leau      >StrTryAgain,pcr
                    pshs      u
                    clra
                    ldb       <$009F
                    leau      >StrSysError,pcr
                    leax      $04,s
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStr
                    leas      $0A,s
                    lbsr      message_box
                    leas      >$00B1,s
                    rts
RingBell            pshs      y
                    ldy       #$0002
                    lda       #$01
RingBellWrite       leax      >StrBell,pcr
                    os9       I$Write
                    puls      y
                    rts
NumConvBuf          fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fcb       $00
NumConvEnd          fcb       0
NumZeroPad          fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

* set.pri.base command
SetPriBase          leas      -$04,s
                    clr       >PriBaseFlag,pcr
                    ldb       ,y+
                    stb       $01,s
                    ldb       #$A8
                    subb      $01,s
                    lda       #$A8
                    mul
                    ldu       #$000A
                    lbsr      UIntDivide
                    stu       $02,s               * Save the division result
                    clrb
                    stb       ,s
SetPriBaseLoop      subb      $01,s
                    bcc       SetPriBaseMul
                    ldb       #$04
                    bra       SetPriBaseStore
SetPriBaseMul       lda       #$A8
                    mul
                    ldu       $02,s
                    lbsr      UIntDivideToD           * perform tfr u,d as well
                    addd      #$0005
                    cmpd      #$000F
                    bls       SetPriBaseStore
                    ldb       #$0F
SetPriBaseStore     stb       ,x+
                    inc       ,s
                    ldb       ,s
                    cmpb      #$A8
                    bcs       SetPriBaseLoop
                    leas      $04,s
                    rts
StrLen              leas      -$02,s
                    stx       ,s
StrLenLoop          lda       ,x+
                    bne       StrLenLoop
                    tfr       x,d
                    ldx       ,s
                    subd      ,s
                    subd      #$0001
                    leas      $02,s
                    rts
StrCopy             pshs      u
StrCopyLoop         lda       ,x+
                    sta       ,u+
                    bne       StrCopyLoop
                    puls      x
                    rts
MemCopyNull         leas      -$04,s
                    std       ,s
                    stu       $02,s
MemCopyLoop         lda       ,x+
                    sta       ,u+
                    beq       MemCopyDone
                    ldd       ,s
                    subd      #$0001
                    std       ,s
                    bne       MemCopyLoop
                    clr       ,u
MemCopyDone         ldx       $02,s
                    leas      $04,s
                    rts
StrAppend           pshs      u
StrAppendFind       lda       ,u+
                    bne       StrAppendFind
                    leau      -$01,u
StrAppendCopy       lda       ,x+
                    sta       ,u+
                    bne       StrAppendCopy
                    puls      x
                    rts
StrCompare          pshs      u,x
StrCompareLoop      lda       ,x
                    suba      ,u+
                    bne       StrCompareRet
                    tst       ,x+
                    bne       StrCompareLoop
StrCompareRet       puls      u,x
                    rts
AtoI                leas      -$02,s
                    clra
                    sta       ,s
                    sta       $01,s
AtoISkipSpace       ldb       ,x+
                    cmpb      #$20
                    beq       AtoISkipSpace
AtoIDigitLoop       cmpb      #$30
                    bcs       AtoIDone
                    cmpb      #$39
                    bhi       AtoIDone
                    subb      #$30
                    stb       $01,s
                    lda       #$0A
                    ldb       ,s
                    mul
                    addb      $01,s
                    stb       ,s
                    ldb       ,x+
                    bne       AtoIDigitLoop
AtoIDone            lda       ,s
                    leas      $02,s
                    rts
UIntToDecStr        leax      >NumConvEnd,pcr
                    clr       ,x
UIntToDecLoop       ldu       #$000A
                    bsr       UIntDivide
                    addb      #$30
                    stb       ,-x
                    tfr       u,d
                    cmpd      #$0000
                    bhi       UIntToDecLoop
                    rts
UIntToHexStr        leax      >NumConvEnd,pcr
                    clr       ,x
UIntToHexLoop       ldu       #$0010
                    bsr       UIntDivide
                    addb      #$30
                    cmpb      #$39
                    ble       UIntToHexStore
                    addb      #$07
UIntToHexStore      stb       ,-x
                    tfr       u,d
                    cmpd      #$0000
                    bhi       UIntToHexLoop
                    rts
UIntDivide          leas      -$05,s
                    std       ,s
                    stu       $02,s
                    lda       #$10
                    sta       $04,s
                    ldd       #$0000
UIntDivideLoop      lsl       $01,s
                    rol       ,s
                    rolb
                    rola
                    cmpd      $02,s
                    bcs       UIntDivideShift
                    subd      $02,s
                    inc       $01,s
UIntDivideShift     dec       $04,s
                    bne       UIntDivideLoop
                    ldu       ,s
                    leas      $05,s
                    rts
StrZeroPad               leas      -$0B,s
                    pshs      x,b
                    tfr       u,x
                    leau      $04,s
                    lbsr      StrCopy
                    lbsr      StrLen
                    stb       $03,s
                    leau      >NumZeroPad,pcr
                    ldx       #$000A
                    ldb       #$30
                    lbsr      FillMem
                    puls      b
                    subb      $02,s
                    bpl       StrZeroPadDo
                    clrb
StrZeroPadDo               clr       b,u
                    leax      $03,s
                    lbsr      StrAppend
                    tfr       x,u
                    puls      x
                    leas      $0B,s
                    rts
ToLower               cmpa      #$41
                    bcs       ToLowerRet
                    cmpa      #$5A
                    bhi       ToLowerRet
                    ora       #$20
ToLowerRet               rts
CmdRandomImpl               lbsr      InitRandSeed
                    lda       $01,y
                    suba      ,y++
                    inca
                    bne       CmdRandomMod
                    tfr       b,a
                    bra       CmdRandomStore
CmdRandomMod               lbsr      Div8
                    adda      -$02,y
CmdRandomStore               ldx       #$0431
                    ldb       ,y+
                    abx
                    sta       ,x
                    rts
FindByte               tst       ,x
                    bne       FindByteLoop
                    ldx       #$0000
                    bra       FindByteRet
FindByteLoop               cmpa      ,x+
                    bne       FindByte
                    leax      -$01,x
FindByteRet               rts
StrToLower               tfr       u,x
StrToLowerLoop               lda       ,x
                    beq       StrToLowerDone
                    bsr       ToLower
                    sta       ,x+
                    bra       StrToLowerLoop
StrToLowerDone               rts
JoystickReadInit               lbsr      cmd_init_joy
                    bsr       events_clear
                    rts
events_clear               lbsr      clear_key_queue
                    lbsr      reset_joy
                    ldx       #$0103
                    stx       <$0092
                    stx       <$0094
                    rts
JoystickPoll               lbsr      PollJoystick
                    lbsr      PollKeyInput
                    rts
EventPush               ldu       <$0092
                    stb       ,u+
                    sta       ,u+
                    stu       <$0092
                    ldx       #$012B
                    cmpx      <$0092
                    bhi       EventPushWrap
                    ldx       #$0103
                    stx       <$0092
EventPushWrap               ldx       <$0092
                    cmpx      <$0094
                    bne       EventPushRet
                    leau      -$02,u
                    stu       <$0092
EventPushRet               rts
EventPop               ldd       <$0094
                    cmpd      <$0092
                    bne       EventPopGet
                    ldx       #$0000
                    bra       EventPopRet
EventPopGet               ldx       #$0002
                    leax      d,x
                    stx       <$0094
                    ldx       #$012B
                    cmpx      <$0094
                    bhi       EventPopAddr
                    ldx       #$0103
                    stx       <$0094
EventPopAddr               tfr       d,x
EventPopRet               rts
WaitForEvent               leas      -$02,s
WaitForEventLoop               ldd       >$024A
                    std       ,s
                    bsr       EventPop
                    leax      ,x
                    bne       EventFound
WaitPollLoop               ldd       ,s
                    cmpd      >$024A
                    beq       WaitPollLoop
                    lbsr      JoystickPoll
                    bra       WaitForEventLoop
EventFound               lbsr      RemapJoyToKey
                    leas      $02,s
                    rts
RemapKeyEvent               leax      ,x
                    beq       RemapKeyEventRet
                    ldb       ,x
                    cmpb      #$01
                    bne       RemapKeyEventRet
                    ldu       #$01D8
RemapKeyEventLoop               ldb       ,u++
                    beq       RemapKeyEventRet
                    cmpb      $01,x
                    bne       RemapKeyEventLoop
                    lda       #$03
                    ldb       -$01,u
                    std       ,x
RemapKeyEventRet               rts
GetKeyEvent               lbsr      JoystickPoll
                    bsr       EventPop
                    tfr       x,d
                    leax      ,x
                    beq       GetKeyEventRet
                    bsr       RemapJoyToKey
                    lda       ,x
                    cmpa      #$01
                    bne       GetKeyNotFound
                    lda       $01,x
GetKeyEventRet               rts
GetKeyNotFound               lda       #$FF
                    rts
WaitKeyNonNull               bsr       GetKeyEvent
                    beq       WaitKeyNonNull
                    cmpa      #$FF
                    beq       WaitKeyNonNull
                    rts
WaitEnterOrEsc               bsr       GetKeyEvent
                    tfr       a,b
                    lda       #$01
                    cmpb      #$0D
                    beq       WaitEnterOrEscRet
                    lda       #$00
                    cmpb      #$1B
                    beq       WaitEnterOrEscRet
                    lda       #$FF
WaitEnterOrEscRet               rts
BooleanPoll               lbsr      events_clear
BooleanPollLoop               bsr       WaitEnterOrEsc
                    bmi       BooleanPollLoop
                    rts
RemapJoyToKey               lda       ,x
                    cmpa      #$01
                    bne       RemapJoyToKeyRet
                    lda       $01,x
                    cmpa      #$FC
                    bne       RemapJoyToEsc
                    lda       #$0D
                    bra       StoreRemappedKey
RemapJoyToEsc               cmpa      #$FE
                    bne       RemapJoyToKeyRet
                    lda       #$1B
StoreRemappedKey               sta       $01,x
RemapJoyToKeyRet               rts
SS_GetSttData               fcb       5,2
DataPathBuf               fcc       /./
DataPathEntry               fcc       /./
                    fcb       $0d,0
CreateFile               pshs      x,d
                    bsr       DeleteFile
                    clr       <$9f
                    puls      d,x
                    os9       I$Create
                    bcc       CreateRet
                    lbsr      OsErrorHandler
CreateRet               rts
OpenFile               clr       <$009F
                    os9       I$Open
                    bcc       OpenFileRet
                    lbsr      OsErrorHandler
OpenFileRet               rts
ReadFile               clr       <$009F
                    os9       I$Read
                    bcc       ReadFileRet
                    lbsr      OsErrorHandler
                    ldy       #$0000
ReadFileRet               tfr       y,d
                    rts
WriteFile               clr       <$009F
                    os9       I$Write
                    bcc       WriteFileRet
                    lbsr      OsErrorHandler
                    ldy       #$0000
WriteFileRet               tfr       y,d
                    rts
DeleteFile               clr       <$009F
                    os9       I$Delete
                    bcc       DeleteFileRet
                    lbsr      OsErrorHandler
DeleteFileRet               rts
CloseFilePath               clr       <$009F
                    os9       I$Close
                    bcc       CloseFilePathRet
                    lbsr      OsErrorHandler
CloseFilePathRet               rts
SeekFile               clr       <$009F
                    tstb
                    bne       GetSttSeek
                    os9       I$Seek
                    bcc       SeekFileRet
SeekFileErr               lbsr      OsErrorHandler
                    ldy       #$0000
                    bra       SeekFileRet
GetSttSeek               stx       <$0084
                    stu       <$0086
                    leau      >RemapJoyToKeyRet,pcr
                    ldb       b,u
                    os9       I$GetStt
                    bcs       SeekFileErr
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
                    bcs       SeekFileErr
SeekFileRet               rts
                    clr       <$009F
                    os9       I$Dup
                    bcc       DupPathRet
                    lbsr      OsErrorHandler
DupPathRet               rts
GetDeviceName               leas      <-$22,s
                    sty       ,s
                    clra
                    sta       ,y
                    sta       <$0077
                    leax      >DataPathEntry,pcr
                    lbsr      OpenDirPath
                    bcs       GetDeviceNameClose
                    sta       <$0078
                    ldb       #$0E
                    leax      $02,s
                    os9       I$GetStt
                    bcs       GetDeviceNameClose
                    ldy       ,s
                    ldb       #$2F
                    stb       ,y+
                    ldd       ,x++
                    andb      #$7F
                    std       ,y++
                    ldb       #$2F
                    stb       ,y+
                    clr       ,y
GetDeviceNameClose               lbsr      CloseDirPath
                    leas      <$22,s
                    rts
GetDiskName               leas      -$0A,s
                    leay      ,s
                    bsr       GetDeviceName
                    leax      $01,s
                    ldd       #$0002
                    lbsr      MemCopyNull
                    tfr       x,u
                    lbsr      StrToLower
                    ldd       ,u
                    subb      #$30
                    cmpa      #$64
                    beq       GetDiskNameStore
                    orb       #$10
GetDiskNameStore               stb       $03,u
                    leas      $0A,s
                    rts
FindCurrentDisk               leas      >-$00C2,s
                    stu       ,s
                    clra
                    sta       <$0077
                    leax      >$00A1,s
                    sta       ,x
                    stx       <$0079
                    leax      >DataPathEntry,pcr
                    lbsr      OpenDirPath
                    sta       <$0078
                    leax      >$00A2,s
                    lbsr      ReadDiskEntry
FindCurrentDiskLoop               ldd       <$0081
                    std       <$007B
                    lda       <$0083
                    sta       <$007D
                    ldx       #$0081
                    ldy       #$007E
                    lbsr      Compare3Bytes
                    beq       FindDiskEntryFound
                    leax      >DataPathBuf,pcr
                    lbsr      ChangeDir
                    lbsr      CloseDirPath
                    bcs       FindDiskEntryDone
                    leax      >DataPathEntry,pcr
                    lbsr      OpenDirPath
                    leax      >$00A2,s
                    bsr       ReadDiskEntry
FindDiskEntryLoop               leax      >$00A2,s
                    lda       <$0078
                    lbsr      ReadDirEntry
                    bcs       FindDiskEntryDone
                    leax      <$1D,x
                    ldy       #$007B
                    bsr       Compare3Bytes
                    bne       FindDiskEntryLoop
                    leax      >$00A2,s
                    bsr       ParseDiskName
                    bcs       FindDiskEntryDone
                    bra       FindCurrentDiskLoop
FindDiskEntryFound               lbsr      CloseDirPath
                    leay      >$00A2,s
                    lbsr      GetDeviceName
                    leax      >$00A2,s
                    bsr       ParseDiskName
                    bcs       FindDiskEntryDone
                    ldu       ,s
                    ldx       <$0079
                    lbsr      StrCopy
                    lbsr      ChangeDir
FindDiskEntryDone               ldu       ,s
                    lbsr      StrToLower
                    lbsr      CloseDirPath
                    leas      >$00C2,s
                    rts
ParseDiskName               os9       F$PrsNam
                    bcs       ParseDiskNameEnd
                    ldx       <$0079
ParseDiskNameCopy               lda       ,-y
                    anda      #$7F
                    sta       ,-x
                    decb
                    bne       ParseDiskNameCopy
                    cmpa      #$2F
                    beq       ParseDiskNameRet
                    lda       #$2F
                    sta       ,-x
                    andcc     #$FE
ParseDiskNameRet               stx       <$0079
ParseDiskNameEnd               rts
ReadDiskEntry               bsr       ReadDirEntry
                    ldd       <$1D,x
                    std       <$007E
                    lda       <$1F,x
                    sta       <$0080
                    bsr       ReadDirEntry
                    ldd       <$1D,x
                    std       <$0081
                    lda       <$1F,x
                    sta       <$0083
                    rts
Compare3Bytes               ldd       ,x++
                    cmpd      ,y++
                    bne       Compare3BytesRet
                    lda       ,x
                    cmpa      ,y
Compare3BytesRet               rts
OpenDirPath               lda       #$81
                    lbsr      OpenFile
                    bcs       OpenDirPathRet
                    inc       <$0077
OpenDirPathRet               rts
ReadDirEntry               lda       <$0078
                    ldy       #$0020
                    lbra      ReadFile
CloseDirPath               lda       <$0078
                    lbsr      CloseFilePath
                    bcs       CloseDirPathRet
                    clr       <$0077
CloseDirPathRet               rts
ChangeDir               clr       <$009F
                    lda       #$81
                    os9       I$ChgDir
                    bcc       ChangeDirRet
                    lbsr      OsErrorHandler
ChangeDirRet               rts
                    lda       $05,s
                    ldy       $02,s
                    lbsr      OpenFile
                    bcs       OpenPathRet
                    ldx       $06,s
                    bsr       GetFileStatus
OpenPathRet               lda       <$009F
                    rts
GetFileStatus               clr       <$009F
                    ldb       #$0F
                    ldy       #$0010
                    os9       I$GetStt
                    bcc       GetFileStatusRet
                    bsr       OsErrorHandler
GetFileStatusRet               rts
GetFileTime               leas      <-$14,s
                    leax      ,s
                    bsr       GetFileStatus
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
OsErrorHandler               pshs      cc
                    cmpb      #$D8
                    bne       OsErrorStore
                    lda       #$FF
                    clrb
OsErrorStore               stb       <$009F
                    puls      cc
                    rts
FindObjPos               leas      -$05,s
                    stu       ,s
                    clra
                    sta       $03,s
                    inca
                    sta       $02,s
                    sta       $04,s
                    lda       >$01D6
                    cmpa      $04,u
                    bcs       FindObjPosIter
                    ldb       <$26,u
                    bitb      #$08
                    bne       FindObjPosIter
                    inca
                    sta       $04,u
FindObjPosIter               lbsr      CheckObjBounds
                    tsta
                    beq       FindObjPosDirNone
                    lbsr      CheckObjCollision
                    tsta
                    bne       FindObjPosDirNone
                    pshs      u
                    lda       #$03
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldu       ,s
                    lda       <$005C
                    bne       FindObjPosDone
FindObjPosDirNone               lda       $03,s
                    bne       FindObjPosDirOne
                    dec       $03,u
                    dec       $04,s
                    bne       FindObjPosIter
                    inc       $03,s
                    lda       $02,s
                    sta       $04,s
                    bra       FindObjPosIter
FindObjPosDirOne               cmpa      #$01
                    bne       FindObjPosDirTwo
                    inc       $04,u
                    dec       $04,s
                    bne       FindObjPosIter
                    inc       $03,s
                    inc       $02,s
                    lda       $02,s
                    sta       $04,s
                    bra       FindObjPosIter
FindObjPosDirTwo               cmpa      #$02
                    bne       FindObjPosDirThree
                    inc       $03,u
                    dec       $04,s
                    bne       FindObjPosIter
                    inc       $03,s
                    lda       $02,s
                    sta       $04,s
                    bra       FindObjPosIter
FindObjPosDirThree               dec       $04,u
                    dec       $04,s
                    bne       FindObjPosIter
                    clr       $03,s
                    inc       $02,s
                    lda       $02,s
                    sta       $04,s
                    bra       FindObjPosIter
FindObjPosDone               leas      $05,s
                    rts
CheckObjBounds               clra
                    ldb       $03,u
                    addb      <$1C,u
                    bcs       CheckObjBoundsRet
                    cmpb      #$A0
                    bhi       CheckObjBoundsRet
                    ldb       $04,u
                    cmpb      #$A7
                    bhi       CheckObjBoundsRet
                    incb
                    cmpb      <$1D,u
                    bcs       CheckObjBoundsRet
                    decb
                    cmpb      >$01D6
                    bhi       CheckObjInBounds
                    ldb       <$26,u
                    bitb      #$08
                    beq       CheckObjBoundsRet
CheckObjInBounds               inca
CheckObjBoundsRet               rts
FlagBitTable               fcb       $80,$40,$20,$10,8,4,2,1



CmdSetImpl               lda       ,y+
                    bra       SetFlag


CmdResetImpl               lda       ,y+
                    bra       ClearFlag


CmdToggleImpl               lda       ,y+
                    bra       ToggleFlag

CmdSetVImpl               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    bra       SetFlag

CmdResetVImpl               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    bra       ClearFlag

CmdToggleVImpl               ldb       ,y+
                    ldx       #$431
                    abx
                    lda       ,x
                    bra       ToggleFlag

SetFlag               bsr       GetFlagBitAddr
                    ora       ,x
                    sta       ,x
                    rts

ClearFlag               bsr       GetFlagBitAddr
                    coma
                    anda      ,x
                    sta       ,x
                    rts

ToggleFlag               bsr       GetFlagBitAddr
                    eora      ,x
                    sta       ,x
                    rts
TestFlag               bsr       GetFlagBitAddr
                    anda      ,x
                    rts
GetFlagBitAddr               tfr       a,b
                    leax      >FlagBitTable,pcr
                    anda      #$07
                    lda       a,x
                    lsrb
                    lsrb
                    lsrb
                    ldx       #$01AE
                    abx
                    rts
CalcFollowDir               leas      -$05,s
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
                    lbsr      CalcMoveDir
                    leas      $06,s
                    sta       ,s
                    bne       FollowCheckStop
                    sta       <$21,u
                    sta       <$22,u
                    lda       <$28,u
                    lbsr      SetFlag
                    bra       FollowRet
FollowCheckStop               lda       <$29,u
                    cmpa      #$FF
                    bne       FollowCheckWander
                    clr       <$29,u
                    bra       FollowSetDir
FollowCheckWander               lda       <$25,u
                    bita      #$40
                    beq       FollowDecTimer
FollowSetWander               lbsr      InitRandSeed
                    lda       #$09
                    lbsr      Div8
                    sta       <$21,u
                    beq       FollowSetWander
                    ldb       $03,s
                    subb      $01,s
                    bcc       FollowCalcDir
                    negb
FollowCalcDir               stb       $04,s
                    ldb       $04,u
                    subb      $02,s
                    bcc       FollowCalcStep
                    negb
FollowCalcStep               clra
                    addb      $04,s
                    adca      #$00
                    lsra
                    rorb
                    incb
                    stb       $04,s
                    lda       <$1E,u
                    sta       <$29,u
                    cmpa      $04,s
                    bcc       FollowRet
FollowRandomStep               lbsr      InitRandSeed
                    lda       $04,s
                    lbsr      Div8
                    cmpa      <$1E,u
                    bcs       FollowRandomStep
                    sta       <$29,u
                    bra       FollowRet
FollowDecTimer               lda       <$29,u
                    beq       FollowSetDir
                    clr       <$29,u
                    suba      <$1E,u
                    bcs       FollowRet
                    sta       <$29,u
                    bra       FollowRet
FollowSetDir               lda       ,s
                    sta       <$21,u
FollowRet               leas      $05,s
                    rts
DataSaveDiskFlag               fcb       1
SaveDiskNameBuf               fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DataSaveGameBuf               fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DataSaveGameBuf2               fcb       0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
StrSave               fcc       /save/
                    fcb       0
StrRestore               fcc       /restore/
                    fcb       0
StrDescFmt               fcc       / - %s/
                    fcb       0
StrSaveDesc               fcc       /How would you like to describe this saved game?/
                    fcb       $0a,$0a,0
StrSaveDiskPrompt               fcc       /Please put your save game/
                    fcb       $0a
                    fcc       /disk in drive %s./
                    fcb       $0a,$0a
                    fcc       /Press ENTER to continue./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to not/
                    fcb       $0a
StrSaveDiskAction               fcc       /%s a game./
                    fcb       0
StrDirExample               fcc       '(For example, "/d1" or "/h0/savegame")'
                    fcb       0
StrSaveGameMenu               fcc       /         SAVE GAME/
                    fcb       $0a,$0a
                    fcc       /On which disk or in which directory do you wish to save this game?/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a,0
StrRestoreGameMenu               fcc       /        RESTORE GAME/
                    fcb       $0a,$0a
                    fcc       /On which disk or in which directory is the game that you want to restore?/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a,0
StrArrowInstr               fcc       /Use the arrow keys to move/
                    fcb       $0a
                    fcc       /     the pointer to your name./
                    fcb       $0a
                    fcc       /Then press ENTER./
                    fcb       $0a,0
StrNoDirFound               fcc       /There is no directory named:/
                    fcb       $0a
                    fcc       /%s./
                    fcb       $0a
                    fcc       /Press ENTER to try again./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to cancel./
                    fcb       0
StrNoGamesToRestore               fcc       /There are no games to/
                    fcb       $0a
                    fcc       /restore in:/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /Press ENTER to continue./
                    fcb       0

StrSaveSlotSelect               fcc       /Use the arrow keys to select the slot in which you wish to save the game. /
                    fcc       /Press ENTER to save in the slot, /
                    fcc       /CTRL-BREAK to not save a game./
                    fcb       0

StrRestoreSelect               fcc       /Use the arrow keys to select the game which you wish to restore. /
                    fcc       /Press ENTER to restore the game, /
                    fcc       /CTRL-BREAK to not restore a game./
                    fcb       0

StrDiskFull               fcc       /   Sorry, this disk is full./
                    fcb       $0a
                    fcc       /Position pointer and press ENTER/
                    fcb       $0a
                    fcc       /    to overwrite a saved game/
                    fcb       $0a
                    fcc       /or press CTRL-BREAK and try again/
                    fcb       $0a
                    fcc       /    with another disk./
                    fcb       $0a,0


StateGetInfo               leas      -$02,s
                    clr       $01,s
                    lda       >$05B9
                    sta       ,s
                    lbsr      InputEditOn
                    lbsr      PushTextColor
                    lbsr      PushRowCol
                    ldd       #$000F
                    lbsr      text_color
                    ldd       $04,s
                    pshs      b,a
                    lbsr      GetSavePath
                    leas      $02,s
GetInfoLoop               beq       GetInfoCleanup
                    ldd       $04,s
                    pshs      b,a
                    lbsr      CheckSaveDisk
                    leas      $02,s
                    beq       GetInfoCleanup
                    ldd       $04,s
                    pshs      b,a
                    lbsr      GetSaveFilename
                    leas      $02,s
                    sta       $01,s
                    beq       GetInfoCleanup
                    lda       $05,s
                    cmpa      #$73
                    bne       GetInfoRestoreSlot
                    lda       >state_name_auto,pcr
                    bne       GetInfoRestoreSlot
                    leax      >DataSaveGameBuf,pcr
                    leau      >StrSaveDesc,pcr
                    lbsr      EditBoxInput
                    tsta
GetInfoAbort               bne       GetInfoRestoreSlot
                    clr       $01,s
                    bra       GetInfoCleanup
GetInfoRestoreSlot               leax      >DataSaveGameBuf2,pcr
                    ldb       $01,s
                    lbsr      BuildSaveFilePath
GetInfoCleanup               lbsr      PopRowCol
                    lbsr      PopTextColor
                    lda       ,s
                    beq       GetInfoRet
                    lbsr      InputCursorBlink
GetInfoRet               lda       $01,s
                    leas      $02,s
                    rts
CheckSaveDisk               leas      >-$00A5,s
                    lda       #$01
                    sta       ,s
                    leau      >$00A1,s
                    lbsr      GetDiskName
                    lda       >SaveDriveNum,pcr
                    cmpa      >$00A4,s
                    bne       CheckSaveDiskRet
                    cmpa      #$10
                    bcc       CheckSaveDiskRet
                    lbsr      VolumesClose
                    leau      >StrSave,pcr
                    lda       >$00A8,s
                    cmpa      #$73
                    beq       SaveDiskDoPrompt
                    leau      >StrRestore,pcr
SaveDiskDoPrompt               pshs      u
                    leau      >$00A3,s
                    pshs      u
                    leau      >StrSaveDiskPrompt,pcr
                    leax      $05,s
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStr
                    leas      $08,s
                    lbsr      message_box
                    sta       ,s
CheckSaveDiskRet               lda       ,s
                    leas      >$00A5,s
                    rts
GetSavePath               leas      >-$00C8,s
                    lda       >SaveDiskNameBuf,pcr
                    bne       GetSavePathCheck
                    leau      >SaveDiskNameBuf,pcr
                    lbsr      FindCurrentDisk
                    leas      ,s
GetSavePathCheck               tst       >state_name_auto,pcr
                    bne       GetSavePathDone
GetSavePathShowMenu               leau      >StrDirExample,pcr
                    pshs      u
                    leau      >StrSaveGameMenu,pcr
                    ldb       >$00CD,s
                    cmpb      #$73
                    beq       GetSavePathFormat
                    leau      >StrRestoreGameMenu,pcr
GetSavePathFormat               leax      $02,s
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStr
                    leas      $06,s
                    leax      >SaveDiskNameBuf,pcr
                    lbsr      EditBoxInput
                    tsta
                    beq       GetSavePathDone
                    leau      >SaveDiskNameBuf,pcr
                    lbsr      StrToLower
                    pshs      u
                    lbsr      GetDiskInfo
                    leas      $02,s
                    bne       GetSavePathDone
                    leau      >SaveDiskNameBuf,pcr
                    pshs      u
                    leau      >StrNoDirFound,pcr
                    leax      $02,s
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStr
                    leas      $06,s
                    lbsr      message_box
                    bne       GetSavePathShowMenu
GetSavePathDone               leas      >$00C8,s
                    rts
EditBoxInput               leas      -$03,s
                    stx       ,s
                    ldd       #$0001
                    pshs      b,a
                    ldd       #$001F
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      message_box_draw
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
                    lbsr      ClearTextRect
                    leas      $06,s
                    lbsr      PushTextColor
                    lda       #$0F
                    clrb
                    lbsr      text_color
                    ldb       #$1F
                    ldx       ,s
                    lbsr      EditString
                    sta       $02,s
                    lbsr      PopTextColor
                    lbsr      cmd_close_window
                    lda       #$01
                    ldb       $02,s
                    cmpb      #$0D
                    beq       EditBoxRet
                    clra
EditBoxRet               ldx       ,s
                    leas      $03,s
                    rts
GetSaveFilename               leas      >-$0256,s
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
                    beq       GetFilenameInitY
                    lda       #$0C
GetFilenameInitY               std       >$024A,s
GetFilenameLoop               cmpb      #$0C
                    lbcc      GetFilenameDone
                    leau      >$0252,s
                    pshs      u
                    incb
                    pshs      b,a
                    ldb       >$025D,s
                    lda       >$024E,s
                    cmpb      #$73
                    bne       GetFilenameCalc
                    lda       >$024F,s
GetFilenameCalc               ldb       #$20
                    mul
                    leau      $06,s
                    leau      d,u
                    pshs      u
                    lbsr      ReadSaveSlotEntry
                    leas      $06,s
                    beq       GetFilenameIncY
                    ldb       >$0259,s
                    cmpb      #$73
                    bne       GetFilenameUpdateRestore
                    ldd       >$0252,s
                    cmpd      >$024E,s
                    bhi       GetFilenameUpdateSave
                    bcs       GetFilenameIncY
                    ldd       >$0254,s
                    cmpd      >$0250,s
                    bls       GetFilenameIncY
GetFilenameUpdateSave               ldd       >$0254,s
                    std       >$0250,s
                    ldd       >$0252,s
                    std       >$024E,s
                    lda       >$024B,s
                    sta       >$024C,s
                    bra       GetFilenameIncY
GetFilenameUpdateRestore               ldd       >$0252,s
                    cmpd      >$024E,s
                    bhi       GetFilenameStoreBest
                    bcs       GetFilenameIncX
                    ldd       >$0254,s
                    cmpd      >$0250,s
                    bls       GetFilenameIncX
GetFilenameStoreBest               ldd       >$0254,s
                    std       >$0250,s
                    ldd       >$0252,s
                    std       >$024E,s
                    lda       >$024A,s
                    sta       >$024C,s
GetFilenameIncX               inc       >$024A,s
GetFilenameIncY               inc       >$024B,s
                    ldb       >$024B,s
                    lbra      GetFilenameLoop
GetFilenameDone               lda       >$024A,s
                    bne       GetFilenameCheck
                    lda       >state_name_auto,pcr
                    bne       GetFilenameSetup
                    leau      >SaveDiskNameBuf,pcr
                    pshs      u
                    leau      >StrNoGamesToRestore,pcr
                    leax      >$0184,s
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStr
                    leas      $06,s
                    lbsr      message_box
                    clra
                    lbra      GetFilenameExit
GetFilenameCheck               lda       >state_name_auto,pcr
                    lbeq      GetFilenameDrawList
GetFilenameSetup               lda       >DataSaveDiskFlag,pcr
                    bne       GetFilenameDiskMode
                    leax      >state_name_auto,pcr
                    leau      >DataSaveGameBuf,pcr
                    lbsr      StrCopy
                    clrb
                    stb       >$024B,s
GetFilenameMatchLoop               cmpb      #$0C
                    bcc       GetFilenameMatchSave
                    leau      >DataSaveGameBuf,pcr
                    lda       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    leax      $01,x
                    lbsr      StrCompare
                    tsta
                    lbeq      GetFilenameAccept
                    inc       >$024B,s
                    ldb       >$024B,s
                    lbra      GetFilenameMatchLoop
GetFilenameMatchSave               lda       >$0259,s
                    cmpa      #$73
                    bne       GetFilenameCheckMode
                    clrb
                    stb       >$024B,s
GetFilenameMatchSaveLoop               cmpb      #$0C
                    bcc       GetFilenameCheckMode
                    lda       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    ldb       ,x
                    lda       $01,x
                    lbeq      GetFilenameAccept
                    inc       >$024B,s
                    ldb       >$024B,s
                    lbra      GetFilenameMatchSaveLoop
GetFilenameCheckMode               lda       >$0259,s
                    suba      #$72
                    lbeq      GetFilenameExit
                    bra       GetFilenameDrawList
GetFilenameDiskMode               leau      >$0182,s
                    lbsr      GetDiskName
                    lda       >$0185,s
                    sta       >SaveDriveNum,pcr
GetFilenameDrawList               ldd       #$0001
                    pshs      b,a
                    ldd       #$0022
                    pshs      b,a
                    ldb       #$05
                    stb       >$0251,s
                    addb      >$024E,s
                    pshs      b,a
                    ldb       >state_name_auto,pcr
                    beq       GetFilenameShowPrompt
                    leau      >StrDiskFull,pcr
                    ldb       >DataSaveDiskFlag,pcr
                    beq       GetFilenameDrawList
                    leau      >StrArrowInstr,pcr
                    bra       GetFilenameDrawList
GetFilenameShowPrompt               lda       >$025F,s
                    leau      >StrSaveSlotSelect,pcr
                    cmpa      #$73
                    beq       GetFilenameDrawItems
                    leau      >StrRestoreSelect,pcr
GetFilenameDrawItems               pshs      u
                    lbsr      message_box_draw
                    leas      $08,s
                    lda       >$024D,s
                    adda      >$0175
                    sta       >$024D,s
                    clra
                    sta       >DataSaveDiskFlag,pcr
                    sta       >$024B,s
GetFilenameListLoop               cmpa      >$024A,s
                    bcc       GetFilenameHighlight
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
                    leax      >StrDescFmt,pcr
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $04,s
                    inc       >$024B,s
                    lda       >$024B,s
                    lbra      GetFilenameListLoop
GetFilenameHighlight               lda       >$024C,s
                    sta       >$024B,s
                    adda      >$024D,s
                    lbsr      HighlightRow
GetFilenameEventLoop               lbsr      WaitForEvent
                    stx       ,s
                    lda       ,x
                    cmpa      #$01
                    bne       GetFilenameNavKey
                    lda       $01,x
                    cmpa      #$0D
                    bne       GetFilenameEscKey
                    lbsr      cmd_close_window
                    leau      >DataSaveGameBuf,pcr
                    lda       >state_name_auto,pcr
                    beq       GetFilenameCopyEntry
                    leau      >state_name_auto,pcr
GetFilenameCopyEntry               lda       >$024B,s
                    ldb       #$20
                    mul
                    leax      $02,s
                    leax      d,x
                    pshs      x
                    leax      $01,x
                    lbsr      StrCopy
                    puls      x
                    bra       GetFilenameAccept
GetFilenameEscKey               cmpa      #$1B
                    bne       GetFilenameEventLoop
                    lbsr      cmd_close_window
                    clra
                    bra       GetFilenameExit
GetFilenameNavKey               cmpa      #$02
                    bne       GetFilenameEventLoop
                    lda       >$024D,s
                    adda      >$024B,s
                    ldb       $01,x
                    cmpb      #$01
                    bne       GetFilenameNextKey
                    lbsr      NormalRow
                    lda       >$024B,s
                    bne       GetFilenameDecIdx
                    lda       >$024A,s
GetFilenameDecIdx               deca
                    sta       >$024B,s
                    adda      >$024D,s
                    lbsr      HighlightRow
                    bra       GetFilenameEventLoop
GetFilenameNextKey               cmpb      #$05
                    bne       GetFilenameEventLoop
                    lbsr      NormalRow
                    lda       >$024B,s
                    inca
                    cmpa      >$024A,s
                    bne       GetFilenameWrapIdx
                    clra
GetFilenameWrapIdx               sta       >$024B,s
                    adda      >$024D,s
                    lbsr      HighlightRow
                    lbra      GetFilenameEventLoop
GetFilenameAccept               lda       ,x
GetFilenameExit               clr       >$0154
                    clr       >$0547
                    leas      >$0256,s
                    rts
ReadSaveSlotEntry               leas      <-$48,s
                    ldu       <$4A,s
                    ldb       <$4D,s
                    stb       ,u
                    leax      ,s
                    lbsr      BuildSaveFilePath
                    lda       #$01
                    lbsr      OpenFile
                    bcs       ReadSaveSlotFail
                    sta       <$47,s
                    lbsr      GetFileTime
                    ldy       <$4E,s
                    stx       ,y++
                    std       ,y
                    ldy       #$001F
                    ldx       <$4A,s
                    leax      $01,x
                    lda       <$47,s
                    lbsr      ReadFile
                    ldx       #$0000
                    ldu       #$0024
                    lda       <$47,s
                    ldb       #$01
                    lbsr      SeekFile
                    ldy       #$0007
                    leax      <$40,s
                    lda       <$47,s
                    lbsr      ReadFile
                    lda       <$47,s
                    lbsr      CloseFilePath
                    ldu       #$01CE
                    lbsr      StrCompare
                    bne       ReadSaveSlotFail
                    lda       #$01
                    bra       ReadSaveSlotRet
ReadSaveSlotFail               clra
                    ldu       <$4A,s
                    sta       $01,u
ReadSaveSlotRet               leas      <$48,s
                    rts
HighlightRow               ldb       >$0176
                    std       <$0040
                    lda       #$1A
                    lbsr      PutCharToWindow
                    rts
NormalRow               ldb       >$0176
                    std       <$0040
                    lda       #$20
                    lbsr      PutCharToWindow
                    rts
tOC               fcc       /toc/
                    fcb       0
WordsTok               fcc       /words.tok/
                    fcb       0
Object               fcc       /object/
                    fcb       0

InitGameState               ldd       #$e000
                    std       <$2e
                    ldd       #$4040
                    pshs      d
                    lda       #$18
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      events_clear
                    lbsr      LoadAllDirs
                    lda       #$0F
                    clrb
                    lbsr      text_color
                    lbsr      InputRedraw
                    lbsr      JoystickReadInit
                    leau      >tOC,pcr
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0089
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      FileLoad
                    leas      $08,s
                    ldu       <$0089
                    clra
                    ldb       ,u+
                    stb       >$05ED
                    tfr       d,x
                    stu       <$0089
DiskInfoLoop               ldd       <$0089
                    addd      ,u
                    std       ,u++
                    leax      -$01,x
                    bne       DiskInfoLoop
                    leau      >WordsTok,pcr
                    ldd       #$01AA
                    pshs      b,a
                    ldd       #$01A8
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
LoadWordsLoop               pshs      u
                    lbsr      FileLoad
                    leas      $08,s
                    lbsr      ClearLogicTable
                    lbsr      list_clear
                    lbsr      SoundListClear
                    lbsr      PicListClear
                    bsr       LoadObjectData
                    clrb
                    lbsr      AllocLoadLogic
                    ldd       <$004F
                    std       <$004D
                    ldd       <$0055
                    std       <$0053
                    lda       >$01AF
                    ora       #$40
                    sta       >$01AF
                    lbsr      SoundPIASave
                    lbsr      SoundPIARestore
                    rts
LoadObjectData               leas      -$01,s
                    leau      >Object,pcr
                    ldx       <$0038
                    beq       LoadObjectSetup
                    leax      -$03,x
                    stx       <$0038
LoadObjectSetup               ldd       #$0000
                    pshs      b,a
                    ldd       #$0038
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      FileLoad
                    leas      $08,s
                    ldx       <$0038
                    ldd       <$0066
                    leau      d,x
                    lbsr      XorDecrypt
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
FixupObjPtrs               cmpu      <$003C
                    bcc       InitViewObjs
                    lda       $01,u
                    ldb       ,u
                    addd      <$0038
                    std       ,u
                    leau      $03,u
                    bra       FixupObjPtrs
InitViewObjs               inc       ,s
                    ldu       <$0030
                    bne       ClearViewObjs
                    lda       ,s
                    ldb       #$2B
                    mul
                    std       <$0034
                    lbsr      AllocDataBlock
                    stu       <$0030
                    ldd       <$0034
                    leau      d,u
                    stu       <$0032
                    leau      <-$2B,u
                    stu       <$0036
                    ldu       <$0030
ClearViewObjs               ldx       <$0034
                    clrb
                    lbsr      FillMem
                    clra
SetViewObjIdx               cmpa      ,s
                    bcc       ClearGameTables
                    sta       $02,u
                    leau      <$2B,u
                    inca
                    bra       SetViewObjIdx
ClearGameTables               ldu       #$0431
                    ldx       #$0100
                    clrb
                    lbsr      FillMem
                    ldu       #$01AE
                    ldx       #$0020
                    lbsr      FillMem
                    lbsr      ClearInputBuffer
                    bsr       ResetGameTables
                    lbsr      ClearBothRanges
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
                    bne       InitGameStateRet
                    sta       >$0447
InitGameStateRet               leas      $01,s
                    rts
ResetGameTables               lbsr      ResetLogicTable
                    lbsr      list_clear
                    lbsr      SoundListClear
                    lbsr      PicListClear
                    rts
JoystickData               fcb       0,0,0
StrJoystickMsg               fcc       /If you have a joystick, and/
                    fcb       $0a
                    fcc       /wish to use it, press its/
                    fcb       $0a
                    fcc       /button./
                    fcb       $0a
                    fcc       /If not, press CTRL-BREAK to/
                    fcb       $0a
                    fcc       /continue./
                    fcb       0

cmd_init_joy               lda       <$0098
                    eora      #$01
                    sta       <$0098
                    beq       JoyInitDone
                    clr       <$0099
ShowJoyMsg               leau      >StrJoystickMsg,pcr
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0020
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      message_box_draw
                    leas      $08,s
                    ldb       #$00
JoyInputLoop               stb       <$0097
                    lbsr      GetKeyEvent
                    ldb       >$0541
                    bne       JoyBtnRelease
JoyInputCheck               ldb       <$0097
                    eorb      #$01
                    cmpa      #$1B
                    bne       JoyInputLoop
                    clr       <$0098
                    lbsr      cmd_close_window
                    bra       JoyInitDone
JoyBtnRelease               lbsr      cmd_close_window
WaitJoyRelease               lbsr      ReadJoyButton
                    lda       >$0541
                    bne       WaitJoyRelease
JoyInitDone               lbsr      events_clear
                    rts
reset_joy           clr       >$0541
                    clr       >$0542
PollJoystick        lda       <$0098
                    lbeq      JoyPollRet
                    ldb       >$0547
                    beq       JoystickUpdate
                    ldx       <$009C
                    bne       JoyPollCheck
                    ldx       <$009A
                    bne       JoyPollCheck
                    clra
CalcJoyDelta        orcc      #$50
                    addd      >$024A
                    std       <$009C
                    ldd       >$0248
                    andcc     #$AF
                    bcc       JoyDeltaStore
                    addd      #$0001
JoyDeltaStore       std       <$009A
                    bne       JoyPollCheck
                    ldd       <$009C
                    bne       JoyPollCheck
                    inc       <$009D
JoyPollCheck        orcc      #$50
                    ldx       >$024A
                    ldd       >$0248
                    andcc     #$AF
                    cmpd      <$009A
                    bhi       JoystickUpdate
                    cmpx      <$009C
                    bls       JoyPollEnd
JoystickUpdate               ldd       #$0000
                    std       <$009A
                    std       <$009C
                    bsr       ReadJoystick
                    lbsr      CheckJoyDirection
                    ldb       >$0154
                    bne       JoyCheckBtn
                    ldb       >$017F
                    beq       JoyCheckChange
JoyCheckBtn               tsta
                    beq       JoyPollEnd
                    bra       JoyPushEvent
JoyCheckChange               cmpa      <$0099
                    beq       JoyPollEnd
                    ldb       >$0102
                    bne       JoyPollEnd
                    sta       <$0099
                    cmpa      >$0437
                    beq       JoyPollEnd
JoyPushEvent               ldb       #$02
                    lbsr      EventPush
JoyPollEnd               bsr       PollJoyButton
JoyPollRet               rts
ReadJoystick               pshs      y
                    lda       #$00
                    ldb       #$13
                    ldx       <$0096
                    os9       I$GetStt
                    tfr       x,d
                    leax      >JoystickData,pcr
                    sty       $01,x
                    std       ,x
                    puls      y
                    rts
ReadJoyButton               pshs      y
                    lda       #$00
                    ldb       #$13
                    ldx       <$0096
                    os9       I$GetStt
                    sta       >$0541
                    puls      y
                    rts
PollJoyButton               bsr       ReadJoyButton
                    lda       >$0542
                    cmpa      #$02
                    bne       JoyBtnState
                    orcc      #$50
                    ldx       >$024A
                    ldd       >$0248
                    andcc     #$AF
                    cmpd      >$0543
                    bcs       JoyBtnState
                    bhi       JoyClickEvent
                    cmpx      >$0545
                    bcs       JoyBtnState
JoyClickEvent               clr       >$0542
                    lda       #$FC
                    ldb       #$01
                    lbsr      EventPush
                    bra       JoyBtnTrack
JoyBtnState               lda       >$0542
                    beq       JoyBtnTrack
                    cmpa      #$02
                    bne       JoyBtnHold
JoyBtnTrack               lda       >$0541
                    beq       PollJoyButtonRet
                    inc       >$0542
                    bra       PollJoyButtonRet
JoyBtnHold               cmpa      #$01
                    bne       JoyBtnUp
                    lda       >$0541
                    bne       PollJoyButtonRet
                    lda       >$01AF
                    anda      #$80
                    beq       JoyClickEvent
                    clra
                    ldb       >$0440
                    orcc      #$50
                    addd      >$024A
                    std       >$0545
                    ldd       >$0248
                    andcc     #$AF
                    bcc       JoyBtnTimestamp
                    addd      #$0001
JoyBtnTimestamp               std       >$0543
                    inc       >$0542
                    bra       PollJoyButtonRet
JoyBtnUp               lda       >$0541
                    bne       PollJoyButtonRet
                    clr       >$0542
                    lda       #$FE
                    ldb       #$01
                    lbsr      EventPush
PollJoyButtonRet               rts
CheckJoyDirection               lda       $02,x
                    ldb       $01,x
                    cmpa      #$25
                    bls       JoyDirLow
                    lda       #$08
                    cmpb      #$16
                    bcs       JoyDirRet
                    lda       #$02
                    cmpb      #$25
                    bhi       JoyDirRet
                    lda       #$01
                    bra       JoyDirRet
JoyDirLow               cmpa      #$16
                    bcc       JoyDirHigh
                    lda       #$06
                    cmpb      #$16
                    bcs       JoyDirRet
                    lda       #$04
                    cmpb      #$25
                    bhi       JoyDirRet
                    lda       #$05
                    bra       JoyDirRet
JoyDirHigh               lda       #$07
                    cmpb      #$16
                    bcs       JoyDirRet
                    lda       #$03
                    cmpb      #$25
                    bhi       JoyDirRet
                    lda       #$00
JoyDirRet               rts
JoyKeyMapPrimary               fcb       $1c,$01
                    fcb       $10,$02
                    fcb       $19,$03
                    fcb       $11,$04
                    fcb       $1a,$05
                    fcb       $12,$06
                    fcb       $18,$07
                    fcb       $13,$08
                    fcb       $00,$00
JoyKeyMapSecondary               fcb       $0c,$01
                    fcb       $09,$03
                    fcb       $0a,$05
                    fcb       $08,$07
                    fcb       $00,$00

clear_key_queue               lbsr      ReadStdinByte
                    tsta
                    bne       clear_key_queue
                    rts
PollKeyInput               lbsr      ReadStdinByte
                    tsta
                    beq       PollKeyInputRet
                    bsr       LookupKeyInTable
                    tstb
                    bmi       CheckKeyTable2
                    ldb       #$02
                    bra       PushKeyEvent
CheckKeyTable2               cmpa      #$0C
                    beq       PollKeyInputRet
                    ldb       #$01
PushKeyEvent               lbsr      EventPush
PollKeyInputRet               rts
LookupKeyInTable               leax      >JoyKeyMapPrimary,pcr
LookupKeyLoop               cmpa      ,x+
                    beq       LookupKeyMatch
                    ldb       ,x+
                    bne       LookupKeyLoop
                    ldb       >$0154
                    beq       LookupKeyNoMatch
                    leax      >JoyKeyMapSecondary,pcr
LookupKeyLoop2               cmpa      ,x+
                    beq       LookupKeyMatch
                    ldb       ,x+
                    bne       LookupKeyLoop2
LookupKeyNoMatch               ldb       #$FF
                    bra       LookupKeyRet
LookupKeyMatch               lda       ,x
                    clrb
LookupKeyRet               rts
LogicTableData               fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0

ClearLogicTable               leax      >LogicTableData,pcr
                    ldd       #$0000
                    std       ,x
                    rts
ResetLogicTable               leay      >LogicTableData,pcr
                    ldy       ,y
                    beq       ResetLogicTableRet
                    ldd       #$0000
                    std       ,y
ResetLogicTableRet               rts
FindLogicSlot               leau      >LogicTableData,pcr
FindLogicSlotLoop               stu       <$0064
                    ldu       ,u
                    beq       FindLogicSlotRet
                    cmpb      $02,u
                    bne       FindLogicSlotLoop
FindLogicSlotRet               rts
cmd_load_logics               ldb       ,y+
                    bsr       LoadLogicNum
                    rts
cmd_load_logics_v               ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       LoadLogicNum
                    rts
LoadLogicNum               leas      -$01,s
                    stb       ,s
                    lda       #$00
                    lbsr      PushScript
                    ldb       ,s
                    bsr       AllocLoadLogic
                    leas      $01,s
                    rts
AllocLoadLogic               leas      -$07,s
                    stb       ,s
                    bsr       FindLogicSlot
                    cmpu      #$0000
                    bne       AllocLoadLogicRet
                    ldd       <$000A
                    std       $03,s
                    lbsr      ClearBothRanges
                    ldd       #$000C
                    lbsr      AllocDataBlock
                    ldx       <$0064
                    stu       ,x
                    ldd       #$0000
                    std       ,u
                    ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      FetchLogic
                    ldx       #$0000
                    lbsr      OpenVolFile
                    beq       AllocLoadLogicEnd
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
                    beq       AllocLoadLogicEnd
                    lda       <$009E
                    beq       AllocLoadLogicEnd
                    ldd       <$0062
                    std       $05,s
                    stx       <$0062
                    clrb
                    lbsr      GetMsgPtr
                    clra
                    ldb       $03,x
                    ldx       $0A,x
                    addd      #$0001
                    lslb
                    rola
                    leax      d,x
                    lbsr      XorDecrypt
                    ldd       $05,s
                    std       <$0062
AllocLoadLogicEnd               lbsr      SwapObjRanges
                    ldd       $03,s
                    lbsr      SetLogicPage
                    ldu       $01,s
AllocLoadLogicRet               leas      $07,s
                    rts
cmd_call               leas      -$02,s
                    ldb       ,y+
                    sty       ,s
                    bsr       ExecLogic
                    leay      ,y
                    beq       CmdCallRet
                    ldy       ,s
CmdCallRet               leas      $02,s
                    rts
cmd_call_v               leas      -$02,s
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    sty       ,s
                    bsr       ExecLogic
                    leay      ,y
                    beq       CmdCallVRet
                    ldy       ,s
CmdCallVRet               leas      $02,s
                    rts
ExecLogic               leas      -$0A,s
                    stb       ,s
                    ldd       <$0062
                    std       $01,s
                    lda       #$01
                    sta       $03,s
                    ldb       ,s
                    lbsr      FindLogicSlot
                    stu       <$0062
                    beq       ExecLogicLoad
                    ldd       $04,u
                    lbsr      SetLogicPage
                    bra       ExecLogicRun
ExecLogicLoad               ldd       <$0064
                    std       $04,s
                    ldb       ,s
                    lbsr      AllocLoadLogic
                    stu       <$0062
                    stu       $06,s
                    lda       $04,u
                    ldu       $06,u
                    leau      -$02,u
                    lbsr      CalcPriAddr
                    stu       $08,s
                    clr       $03,s
ExecLogicRun               lda       <$0068
                    beq       ExecLogicRetState
                    cmpa      #$02
                    bne       ExecLogicRetState
                    lda       #$01
                    sta       <$0068
ExecLogicRetState               lda       ,s
                    bne       ExecLogicRetCheck
                    lda       #$01
                    sta       <$0069
ExecLogicRetCheck               lbsr      ExecLogicScript
                    lda       $03,s
                    bne       ExecLogicRestore
                    ldd       #$0000
                    ldx       $04,s
                    std       ,x
                    lbsr      ClearBothRanges
                    ldd       $08,s
                    std       <$004F
                    ldd       $06,s
                    std       <$0055
                    lbsr      SwapObjRanges
ExecLogicRestore               ldu       $01,s
                    stu       <$0062
                    beq       ExecLogicRet
                    ldd       $04,u
                    lbsr      SetLogicPage
ExecLogicRet               leas      $0A,s
                    rts
cmd_set_scan_start               ldx       <$0062
                    sty       $08,x
                    rts
cmd_reset_scan_start               ldx       <$0062
                    ldd       $06,x
                    std       $08,x
                    rts
BuildLogicList               leau      >LogicTableData,pcr
                    ldx       #$0554
BuildLogicListLoop               lda       $02,u
                    sta       ,x
                    ldd       $08,u
                    subd      $06,u
                    std       $01,x
                    leax      $03,x
                    ldu       ,u
                    bne       BuildLogicListLoop
                    lda       #$FF
                    sta       ,x
                    tfr       x,d
                    subd      #$0553
                    tfr       d,x
                    rts
SeekLogicInList               ldx       #$0554
SeekLogicListLoop               lda       ,x
                    cmpa      #$FF
                    beq       SeekLogicListRet
                    cmpa      $02,u
                    beq       SeekLogicFound
                    leax      $03,x
                    bra       SeekLogicListLoop
SeekLogicFound               ldd       $06,u
                    addd      $01,x
                    std       $08,u
SeekLogicListRet               rts
StrOutOfMemory               fcc       /Out of %s memory./
                    fcb       $0a
StrWantHave               fcc       /Want: %d, Have: %d/
                    fcb       0

StrHeap               fcc       /heap/
                    fcb       0

StrCommon               fcc       /common/
                    fcb       0

AllocHeap               leas      -$34,s
                    std       ,s
                    ldd       <$4f
                    tfr       d,u
                    addd      ,s
                    bhs       AllocHeapOk
AllocHeapFull               ldd       #$FFFF
                    subd      <$004F
                    addd      #$0001
                    pshs      b,a
AllocHeapFailMsg               ldd       $02,s
                    pshs      b,a
                    leax      >StrHeap,pcr
                    bra       ShowOutOfMemMsg
AllocHeapOk               std       <$004F
                    lbsr      UpdateFreeSpace
                    ldd       <$004F
                    cmpd      <$004B
                    bls       AllocHeapRet
                    std       <$004B
AllocHeapRet               leas      <$34,s
                    rts
AllocDataBlock               leas      <-$34,s
                    std       ,s
                    ldd       <0
                    subd      <$0055
                    cmpd      ,s
                    bcc       AllocDataBlockOk
                    pshs      b,a
                    ldd       $02,s
                    pshs      b,a
AllocDataBlockFail               leax      >StrCommon,pcr
ShowOutOfMemMsg               pshs      x
                    leax      >StrOutOfMemory,pcr
                    leau      $08,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $0A,s
                    lbsr      message_box
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
AllocDataBlockOk               ldd       <$0055
                    tfr       d,u
                    addd      ,s
                    std       <$0055
                    cmpd      <$0051
                    bls       AllocDataBlockRet
                    std       <$0051
AllocDataBlockRet               leas      <$34,s
                    rts
ResetHeap               lbsr      ResetObjRanges
                    ldd       <$004D
                    std       <$004F
                    bsr       UpdateFreeSpace
                    ldd       <$0053
                    std       <$0055
                    rts
UpdateFreeSpace               ldd       #$FFFF
                    subd      <$004F
                    sta       >$0439
                    rts
CalcPriAddr               suba      <$005F
                    ldb       #$20
                    mul
                    exg       b,a
                    subd      #$2000
                    leau      d,u
                    rts
CalcPriCoord               tfr       u,d
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
SetLogicPage               cmpa      <$000A
                    beq       SetLogicPageRet
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
SetLogicPageRet               rts
MenuExtraFlag               fcb       1
MenuItemCurrent               fcb       0,0
MenuCurrent               fcb       0,0
MenuItemNum               fcb       0
MenuItemMaxLen               fcb       0
MenuHead               fcb       0,0
MenuCurWidth               fcb       0
MenuItemRow               fcb       0
MenuItemWidth               fcb       0
MenuItemCol               fcb       0
MenuItemHeight               fcb       0
MenuSubmitted               fcb       0
cmd_set_menu               leas      -$04,s
                    ldb       ,y+
                    lbsr      GetMsgPtr
                    stu       ,s
                    ldu       <$0062
                    ldd       $04,u
                    std       $02,s
                    lda       >MenuSubmitted,pcr
                    bne       SetMenuItemReturn
                    ldd       #$0010
                    lbsr      AllocDataBlock
                    ldd       >MenuHead,pcr
                    bne       SetMenuAppend
                    stu       >MenuHead,pcr
                    lda       #$01
                    sta       >MenuCurWidth,pcr
                    bra       SetMenuLink
SetMenuAppend               ldx       >MenuCurrent,pcr
                    stu       ,x
                    stx       $02,u
                    ldd       $0B,x
                    bne       SetMenuLink
                    sta       $0A,x
SetMenuLink               ldx       >MenuHead,pcr
                    stx       ,u
                    stu       $02,x
                    stu       >MenuCurrent,pcr
                    ldd       #$0000
                    std       $0B,u
                    sta       $08,u
                    sta       $0F,u
                    lda       >MenuCurWidth,pcr
                    sta       $09,u
                    lda       #$01
                    sta       $0A,u
                    ldx       ,s
                    stx       $04,u
                    ldd       $02,s
                    std       $06,u
                    lbsr      StrLen
                    incb
                    addb      >MenuCurWidth,pcr
                    stb       >MenuCurWidth,pcr
                    ldd       #$0000
                    std       >MenuItemCurrent,pcr
                    lda       #$01
                    sta       >MenuItemNum,pcr
SetMenuItemReturn               leas      $04,s
                    rts
cmd_set_menu_item               leas      -$05,s
                    ldb       ,y+
                    lbsr      GetMsgPtr
                    stu       ,s
                    ldu       <$0062
                    ldd       $04,u
                    std       $02,s
                    lda       ,y+
                    sta       $04,s
                    lda       >MenuSubmitted,pcr
                    bne       SetMenuItemRet
                    ldd       #$000C
                    lbsr      AllocDataBlock
                    ldx       >MenuItemCurrent,pcr
                    bne       SetMenuItemAppend
                    ldx       >MenuCurrent,pcr
                    stu       $0D,x
                    stu       $0B,x
                    stu       $02,u
                    bra       SetMenuItemLink
SetMenuItemAppend               stu       ,x
                    stx       $02,u
                    ldx       >MenuCurrent,pcr
SetMenuItemLink               ldx       $0B,x
                    stx       ,u
                    stu       $02,x
                    stu       >MenuItemCurrent,pcr
                    ldx       ,s
                    stx       $04,u
                    ldd       $02,s
                    std       $06,u
                    lda       >MenuItemNum,pcr
                    inc       >MenuItemNum,pcr
                    cmpa      #$01
                    bne       SetMenuItemNumChk
                    lbsr      StrLen
                    negb
                    addb      #$27
                    ldx       >MenuCurrent,pcr
                    cmpb      $09,x
                    bls       SetMenuItemMaxLen
                    ldb       $09,x
SetMenuItemMaxLen               stb       >MenuItemMaxLen,pcr
SetMenuItemNumChk               ldd       >MenuItemNum,pcr
                    std       $08,u
                    lda       #$01
                    sta       $0A,u
                    lda       $04,s
                    sta       $0B,u
                    ldx       >MenuCurrent,pcr
                    inc       $0F,x
SetMenuItemRet               leas      $05,s
                    rts
cmd_submit_menu               ldu       >MenuCurrent,pcr
                    ldd       $0B,u
                    bne       SubmitMenuFinalize
                    sta       $0A,u
SubmitMenuFinalize               ldd       <$0055
                    std       <$0053
                    ldu       >MenuHead,pcr
                    stu       >MenuCurrent,pcr
                    ldd       $0B,u
                    std       >MenuItemCurrent,pcr
                    lda       #$01
                    sta       >MenuSubmitted,pcr
                    rts
cmd_enable_item               lda       ,y+
                    ldb       #$01
                    bsr       SetItemEnable
                    rts
EnableItemLoop               ldu       >MenuHead,pcr
                    beq       EnableItemRet
EnableItemScan               lda       $0A,u
                    beq       EnableItemNext
                    ldx       $0B,u
EnableItemInner               lda       #$01
                    sta       $0A,x
                    ldx       ,x
                    cmpx      $0B,u
                    bne       EnableItemInner
EnableItemNext               ldu       ,u
                    cmpu      >MenuHead,pcr
                    bne       EnableItemScan
EnableItemRet               rts
cmd_disable_item               lda       ,y+
                    ldb       #$00
                    bsr       SetItemEnable
                    rts
SetItemEnable               leas      -$02,s
                    std       ,s
                    ldu       >MenuHead,pcr
SetItemEnableLoop               lda       $0A,u
                    beq       SetItemEnableNext
                    ldx       $0B,u
                    ldd       ,s
SetItemEnableInner               cmpa      $0B,x
                    bne       SetItemEnableMatch
                    stb       $0A,x
SetItemEnableMatch               ldx       ,x
                    cmpx      $0B,u
                    bne       SetItemEnableInner
SetItemEnableNext               ldu       ,u
                    cmpu      >MenuHead,pcr
                    bne       SetItemEnableLoop
                    leas      $02,s
                    rts
cmd_menu_input               lda       >$01AF
                    anda      #$02
                    beq       MenuInputRet
                    lda       #$01
                    sta       >$05AE
MenuInputRet               rts
cmd_show_menu               ldb       ,y+
                    stb       >MenuExtraFlag,pcr
                    rts
DrawMenuBar               leas      -$04,s
                    lda       >MenuExtraFlag,pcr
                    lbeq      MenuInputExit
                    lbsr      PushRowCol
                    lbsr      PushTextColor
                    ldd       #$000F
                    lbsr      ClearTextLine
                    ldu       >MenuHead,pcr
DrawMenuBarLoop               stu       ,s
                    ldx       ,s
                    lbsr      DrawMenuItemNormal
                    ldu       ,s
                    ldu       ,u
                    cmpu      >MenuHead,pcr
                    bne       DrawMenuBarLoop
                    ldd       >MenuItemCurrent,pcr
                    std       $02,s
                    ldu       >MenuCurrent,pcr
                    stu       ,s
                    lbsr      DrawMenuItem
                    lda       #$01
                    sta       >$0154
                    lda       #$03
                    sta       >$0547
MenuInputEventLoop               lbsr      WaitForEvent
                    lda       ,x
                    cmpa      #$01
                    bne       MenuNavEvent
                    lda       $01,x
                    cmpa      #$0D
                    bne       MenuEscCheck
                    ldu       $02,s
                    lda       $0A,u
                    beq       MenuInputEventLoop
                    lda       $0B,u
                    ldb       #$03
                    lbsr      EventPush
                    bra       MenuInputAccept
MenuEscCheck               cmpa      #$1B
                    lbne      MenuNavUpdate
MenuInputAccept               ldu       ,s
                    ldx       $02,s
                    lbsr      EraseMenuItem
                    clr       >$0547
                    lbsr      PopTextColor
                    lbsr      PopRowCol
                    lda       >$0246
                    beq       MenuInputHideStatus
                    lbsr      StatusLineWrite
                    lbra      MenuInputExit
MenuInputHideStatus               ldd       #$0000
                    lbsr      ClearTextLine
                    lbra      MenuInputExit
MenuNavEvent               cmpa      #$02
                    lbne      MenuNavUpdate
                    lda       $01,x
                    cmpa      #$01
                    bne       MenuNavDown
                    ldx       $02,s
                    lbsr      DrawMenuItemNormal
                    ldx       $02,s
                    ldx       $02,x
                    stx       $02,s
                    lbsr      DrawMenuItemHighlight
                    lbra      MenuNavUpdate
MenuNavDown               cmpa      #$02
                    bne       MenuNavRight
                    ldx       $02,s
                    lbsr      DrawMenuItemNormal
                    ldu       ,s
                    ldx       $0B,u
                    stx       $02,s
                    lbsr      DrawMenuItemHighlight
                    lbra      MenuNavUpdate
MenuNavRight               cmpa      #$03
                    bne       MenuNavLeft
                    ldu       ,s
                    ldx       $02,s
                    lbsr      EraseMenuItem
                    ldu       ,s
MenuNavRightScan               ldu       ,u
                    lda       $0A,u
                    beq       MenuNavRightScan
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      DrawMenuItem
                    lbra      MenuNavUpdate
MenuNavLeft               cmpa      #$04
                    bne       MenuNavUp
                    ldx       $02,s
                    lbsr      DrawMenuItemNormal
                    ldu       ,s
                    ldx       $0B,u
                    ldx       $02,x
                    stx       $02,s
                    lbsr      DrawMenuItemHighlight
                    bra       MenuNavUpdate
MenuNavUp               cmpa      #$05
                    bne       MenuNavPrevLeft
                    ldx       $02,s
                    lbsr      DrawMenuItemNormal
                    ldx       $02,s
                    ldx       ,x
                    stx       $02,s
                    lbsr      DrawMenuItemHighlight
                    bra       MenuNavUpdate
MenuNavPrevLeft               cmpa      #$06
                    bne       MenuNavNextRight
                    ldu       ,s
                    ldx       $02,s
                    lbsr      EraseMenuItem
                    ldu       >MenuHead,pcr
                    ldu       $02,u
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      DrawMenuItem
                    bra       MenuNavUpdate
MenuNavNextRight               cmpa      #$07
                    bne       MenuNavHome
                    ldu       ,s
                    ldx       $02,s
                    lbsr      EraseMenuItem
                    ldu       ,s
MenuNavNextRightScan               ldu       $02,u
                    lda       $0A,u
                    beq       MenuNavNextRightScan
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      DrawMenuItem
                    bra       MenuNavUpdate
MenuNavHome               cmpa      #$08
                    bne       MenuNavUpdate
                    ldu       ,s
                    ldx       $02,s
                    lbsr      EraseMenuItem
                    ldu       >MenuHead,pcr
                    stu       ,s
                    ldx       $0D,u
                    stx       $02,s
                    lbsr      DrawMenuItem
MenuNavUpdate               ldd       ,s
                    std       >MenuCurrent,pcr
                    ldd       $02,s
                    std       >MenuItemCurrent,pcr
                    lbra      MenuInputEventLoop
MenuInputExit               lda       #$00
                    sta       >$0154
                    sta       >$05AE
                    sta       >$0547
                    leas      $04,s
                    rts
DrawMenuItem               leas      -$04,s
                    stu       ,s
                    ldx       ,s
                    bsr       DrawMenuItemHighlight
                    ldu       ,s
                    lbsr      CalcMenuItemGeometry
                    ldd       #$000F
                    pshs      b,a
                    ldd       >MenuItemRow,pcr
                    pshs      b,a
                    ldd       >MenuItemCol,pcr
                    pshs      b,a
                    lda       #$0C
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $06,s
                    ldu       ,s
                    ldx       $0B,u
DrawMenuItemLoop               stx       $02,s
                    cmpx      $0D,u
                    beq       DrawMenuItemCurrent
                    bsr       DrawMenuItemNormal
                    bra       DrawMenuItemNext
DrawMenuItemCurrent               bsr       DrawMenuItemHighlight
DrawMenuItemNext               ldx       $02,s
                    ldx       ,x
                    ldu       ,s
                    cmpx      $0B,u
                    bne       DrawMenuItemLoop
                    leas      $04,s
                    rts
EraseMenuItem               stx       $0D,u
                    tfr       u,x
                    bsr       DrawMenuItemNormal
                    ldd       >MenuItemRow,pcr
                    pshs      b,a
                    ldd       >MenuItemCol,pcr
                    pshs      b,a
                    lda       #$03
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
                    rts
DrawMenuItemHighlight               ldd       $08,x
                    std       <$0040
                    ldd       #$0F00
                    lbsr      text_color
                    lda       $0A,x
                    bne       DrawMenuItemHiText
                    lda       #$0F
                    sta       <$0045
DrawMenuItemHiText               pshs      x
                    ldd       $06,x
                    lbsr      SetLogicPage
                    puls      x
                    ldd       $04,x
                    pshs      b,a
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    clr       <$0045
                    rts
DrawMenuItemNormal               ldd       $08,x
                    std       <$0040
                    ldd       #$000F
                    lbsr      text_color
                    lda       $0A,x
                    bne       DrawMenuItemNormText
                    lda       #$0F
                    sta       <$0045
DrawMenuItemNormText               pshs      x
                    ldd       $06,x
                    lbsr      SetLogicPage
                    puls      x
                    ldd       $04,x
                    pshs      b,a
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    clr       <$0045
                    rts
CalcMenuItemGeometry               leas      -$01,s
                    lda       $0F,u
                    sta       ,s
                    ldb       #$08
                    mul
                    addb      #$10
                    stb       >MenuItemRow,pcr
                    ldu       $0B,u
                    ldd       $06,u
                    lbsr      SetLogicPage
                    ldx       $04,u
                    lbsr      StrLen
                    lda       #$04
                    mul
                    addb      #$08
                    stb       >MenuItemWidth,pcr
                    lda       $09,u
                    deca
                    ldb       #$04
                    mul
                    stb       >MenuItemCol,pcr
                    lda       ,s
                    adda      #$02
                    suba      >$0241
                    ldb       #$08
                    mul
                    addb      #$07
                    stb       >MenuItemHeight,pcr
                    leas      $01,s
                    rts
JoySpeedTable               fcb       1,$ff
                    fcb       3,$ff
                    fcb       7,$ff
                    fcb       $f,$ff

ReadStdinByte               leas      -$03,s
                    sty       ,s
                    lda       #$00
                    ldb       #$01
                    os9       I$GetStt
                    bcs       ReadStdinByteErr
                    lda       #$00
                    ldy       #$0001
                    leax      $02,s
                    os9       I$Read
                    bcs       ReadStdinByteErr
                    lda       $02,s
                    bra       ReadStdinByteRet
                    cmpa      #$F4
                    bne       ReadStdinByteRet
                    lda       <$0068
                    bne       ReadStdinByteAlt
                    lda       >$01AF
                    ora       #$20
                    sta       >$01AF
                    lbsr      TraceInit
                    bra       ReadStdinByteErr
ReadStdinByteAlt               lda       >$01AF
                    anda      #$DF
                    sta       >$01AF
                    lbsr      TraceErase
ReadStdinByteErr               clra
ReadStdinByteRet               ldy       ,s
                    leas      $03,s
                    rts
FillMem               pshs      u
FillMemLoop               stb       ,u+
                    leax      -$01,x
                    bne       FillMemLoop
                    puls      u
                    rts
PicRenderSetup               lda       $02,s
                    sta       <$00B9
                    ldd       $06,s
                    std       <$00A2
                    lbsr      MapShdwPage
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
                    lbsr      ReadPicChunk
                    tst       <$009F
                    lbne      PicRenderDone
                    ldx       $04,s
PicDecodeLoop               lbsr      ReadPicPixel
                    tst       <$009F
                    lbne      PicRenderDone
                    cmpd      #$0101
                    lbeq      PicRenderDone
                    cmpd      #$0100
                    bne       PicDataProcess
                    ldd       #$0009
                    std       <$00A4
                    ldd       #$0102
                    std       <$00A9
                    ldd       #$0200
                    std       <$00B1
                    lbsr      ReadPicPixel
                    tst       <$009F
                    lbne      PicRenderDone
                    std       <$00A6
                    std       <$00B4
                    stb       <$00AD
                    stb       <$00A8
                    stb       ,x+
                    bra       PicDecodeLoop
PicDataProcess               std       <$00A6
                    std       <$00AB
                    cmpd      <$00A9
                    bcs       PicDataCheck
                    ldb       <$00A8
                    pshs      b
                    inc       <$00B6
                    ldd       <$00B4
                    std       <$00A6
PicDataCheck               cmpd      #$0100
                    bcs       PicColorStore
                    addd      <$00A6
                    addd      <$00A6
                    ldu       #$6400
                    leau      d,u
                    ldb       $02,u
                    pshs      b
                    inc       <$00B6
                    ldd       ,u
                    std       <$00A6
                    bra       PicDataCheck
PicColorStore       stb       <$00A8
                    stb       <$00AD
                    pshs      b
                    lda       <$00B6
                    inca
PicWriteLoop        puls      b
                    stb       ,x+
                    deca
                    bne       PicWriteLoop
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
                    lbcs      PicDecodeLoop
                    ldb       <$00A5
                    cmpb      #$0B
                    lbeq      PicDecodeLoop
                    incb
                    stb       <$00A5
                    lsl       <$00B1
                    lbra      PicDecodeLoop
PicRenderDone               tfr       x,d
                    subd      $04,s
                    rts
RenderPicStrip      lda       $02,s
                    sta       <$00B9
                    ldd       $06,s
                    std       <$00A2
                    bsr       MapShdwPage
                    clrb
                    stb       <$00BC
                    stb       <$00B3
                    lbsr      ReadPicChunk
                    tst       <$009F
                    bne       PicStripDone
                    ldu       #$6000
                    ldx       $04,s
PicBufCheck         cmpu      #$63FE
                    bcs       PicReadByte
                    stx       <$00B7
                    tfr       u,d
                    subd      #$6000
                    lbsr      PicBufReadWord
                    tst       <$009F
                    bne       PicStripDone
                    ldu       #$6000
                    ldx       <$00B7
PicReadByte         ldb       ,u
                    lda       <$00BC
                    beq       PicNibbleHi
                    lda       <$00B3
                    anda      #$01
                    beq       PicNibbleLo
                    andb      #$0F
                    bra       PicNibbleAdv
PicNibbleLo         lsrb
                    lsrb
                    lsrb
                    lsrb
PicNibbleAdv        leau      a,u
                    eora      #$01
                    sta       <$00B3
                    clr       <$00BC
                    bra       PicStorePixel
PicNibbleHi         leau      $01,u
                    lda       <$00B3
                    anda      #$01
                    beq       PicNibbleSet
                    lda       ,u
                    lsla
                    rolb
                    lsla
                    rolb
                    lsla
                    rolb
                    lsla
                    rolb
PicNibbleSet        lda       #$01
                    sta       <$00BC
                    cmpb      #$F0
                    beq       PicStorePixel
                    cmpb      #$F2
                    beq       PicStorePixel
                    clr       <$00BC
PicStorePixel       stb       ,x+
                    cmpb      #$FF
                    bne       PicBufCheck
PicStripDone        tfr       x,d
                    subd      $04,s
                    rts
MapShdwPage               orcc      #$50
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
ReadPicPixel               stx       <$00B7
                    ldd       <$00BA
                    cmpd      #$1FF0
                    bcs       ReadPicPixelInner
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    bsr       PicBufReadWord
                    tst       <$009F
                    bne       PicPixelRet
                    clra
                    ldb       <$00BB
                    andb      #$07
                    std       <$00BA
ReadPicPixelInner               ldu       <$00A4
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
                    beq       PicPixelMask
PicShiftLoop        lsr       <$00B0
                    ror       <$00AE
                    ror       <$00AF
                    decb
                    bne       PicShiftLoop
PicPixelMask               ldb       <$00A5
                    subb      #$09
                    lslb
                    leax      >JoySpeedTable,pcr
                    abx
                    ldd       <$00AE
                    anda      ,x
                    andb      $01,x
PicPixelRet               ldx       <$00B7
                    rts
PicBufReadWord               ldu       #$6000
                    ldu       d,u
                    stu       >$6000
                    subd      #$0400
                    negb
                    lbsr      ReadPicChunk
                    rts
ReadPicChunk               ldx       #$6000
                    abx
                    negb
                    sex
                    addd      #$0400
                    std       <$00A0
                    ldd       <$00A2
                    beq       ReadPicChunkRet
                    cmpd      <$00A0
                    bcs       ReadPicChunkFull
                    subd      <$00A0
                    std       <$00A2
                    ldd       <$00A0
                    bra       ReadPicChunkRead
ReadPicChunkFull    ldu       #$0000
                    stu       <$00A2
ReadPicChunkRead    tfr       d,y
                    lda       <$00B9
                    lbsr      ReadFile
ReadPicChunkRet               rts
gfx_picbuff_update               tst       >$0550
                    beq       GfxUpdateBlit
                    lda       #$00
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
GfxUpdateBlit               ldd       #$A8A0
                    pshs      b,a
                    ldd       #$00A7
                    pshs      b,a
                    lda       #$00
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
                    rts
cmd_move_obj               lda       ,y+
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
                    beq       MoveObjDir
                    sta       <$1E,u
MoveObjDir               lda       ,y+
                    sta       <$2A,u
                    lbsr      ClearFlag
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <$0030
                    bne       MoveObjDone
                    clr       >$0250
MoveObjDone               lbsr      SetObjMotion
                    rts
cmd_move_obj_v               lda       ,y+
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
                    beq       MoveObjVDir
                    sta       <$1E,u
MoveObjVDir               lda       ,y+
                    sta       <$2A,u
                    lbsr      ClearFlag
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    cmpu      <$0030
                    bne       MoveObjVDone
                    clr       >$0250
MoveObjVDone               lbsr      SetObjMotion
                    rts
cmd_follow_ego               lda       ,y+
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
                    bls       FollowEgoSpeed
                    sta       <$27,u
FollowEgoSpeed               lda       ,y+
                    sta       <$28,u
                    lbsr      ClearFlag
                    lda       #$FF
                    sta       <$29,u
                    lda       <$26,u
                    ora       #$10
                    sta       <$26,u
                    rts
cmd_wander               lda       ,y+
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
                    bne       WanderDone
                    clr       >$0250
WanderDone               rts
cmd_normal_motion               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    rts
cmd_stop_motion               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    clra
                    sta       <$21,u
                    cmpu      <$0030
                    bne       StopMotionDone
                    sta       >$0437
                    sta       >$0250
StopMotionDone               rts
cmd_start_motion               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       #$00
                    sta       <$22,u
                    cmpu      <$0030
                    bne       StartMotionDone
                    clr       >$0437
                    lda       #$01
                    sta       >$0250
StartMotionDone               rts

cmd_step_size_v               lda       ,y+
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

cmd_step_time               lda       ,y+
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

cmd_set_dir               lda       ,y+
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

cmd_get_dir               lda       ,y+
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

cmd_program_control               clr       >$0250
                    rts

cmd_player_control               lda       #$01
                    sta       >$0250
                    ldu       <$0030
                    lda       #$00
                    sta       <$22,u
                    rts
x_dir_mult               fcb       0,0
                    fcb       1,1
                    fcb       1,0
                    fcb       $ff,$ff
                    fcb       $ff
y_dir_mult               fcb       0
                    fcb       $ff,$ff
                    fcb       0,1
                    fcb       1,1
                    fcb       0,$ff

UpdateAllMotion               leas      -$0B,s
                    clra
                    sta       >$0433
                    sta       >$0435
                    sta       >$0436
                    ldu       <$0030
UpdateObjsLoop               cmpu      <$0032
                    lbcc      UpdateAllObjsRet
                    lda       <$26,u
                    anda      #$51
                    cmpa      #$51
                    lbne      UpdateObjsNext
                    lda       $01,u
                    beq       UpdateObjCycle
                    deca
                    beq       UpdateObjCycle
                    sta       $01,u
                    lbra      UpdateObjsNext
UpdateObjCycle               lda       ,u
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
                    bne       ClampObjXLeft
                    leax      >x_dir_mult,pcr
                    lda       <$21,u
                    lda       a,x
                    beq       UpdateObjY
                    bpl       UpdateObjXPlus
                    ldd       $03,s
                    subd      $09,s
                    std       $03,s
                    bra       UpdateObjY
UpdateObjXPlus               ldd       $03,s
                    addd      $09,s
                    std       $03,s
UpdateObjY               leax      >y_dir_mult,pcr
                    lda       <$21,u
                    lda       a,x
                    beq       ClampObjXLeft
                    bpl       UpdateObjYPlus
                    ldd       $05,s
                    subd      $09,s
                    std       $05,s
                    bra       ClampObjXLeft
UpdateObjYPlus      ldd       $05,s
                    addd      $09,s
                    std       $05,s
ClampObjXLeft               ldd       #$0000
                    cmpd      $03,s
                    ble       ClampObjXRight
                    std       $03,s
                    lda       #$04
                    sta       $02,s
                    bra       ClampObjYTop
ClampObjXRight               ldb       <$1C,u
                    negb
                    lda       #$FF
                    addd      #$00A0
                    cmpd      $03,s
                    bge       ClampObjYTop
                    std       $03,s
                    lda       #$02
                    sta       $02,s
ClampObjYTop               clra
                    ldb       <$1D,u
                    decb
                    cmpd      $05,s
                    ble       ClampObjYBot
                    std       $05,s
                    lda       #$01
                    sta       $02,s
                    bra       ApplyObjPosition
ClampObjYBot               ldd       #$00A7
                    cmpd      $05,s
                    bge       CheckObjPriority
                    std       $05,s
                    lda       #$03
                    sta       $02,s
                    bra       ApplyObjPosition
CheckObjPriority               lda       <$26,u
                    bita      #$08
                    bne       ApplyObjPosition
                    lda       >$01D6
                    cmpa      $06,s
                    bls       ApplyObjPosition
                    inca
                    sta       $06,s
                    lda       #$01
                    sta       $02,s
ApplyObjPosition               lda       $04,s
                    ldb       $06,s
                    std       $03,u
                    lbsr      CheckObjCollision
                    tsta
                    bne       ObjHitRestore
                    stu       ,s
                    pshs      u
                    lda       #$03
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldu       ,s
                    lda       <$005C
                    bne       CheckObjBoundary
ObjHitRestore               ldd       $07,s
                    std       $03,u
                    clr       $02,s
                    lbsr      FindObjPos
CheckObjBoundary               lda       $02,s
                    beq       UpdateObjFlags
                    ldb       $02,u
                    bne       ObjBoundaryHit
                    sta       >$0433
                    bra       CheckMoveTarget
ObjBoundaryHit               stb       >$0435
                    sta       >$0436
CheckMoveTarget               lda       <$22,u
                    cmpa      #$03
                    bne       UpdateObjFlags
                    lbsr      ObjMoveReached
UpdateObjFlags               lda       <$25,u
                    anda      #$FB
                    sta       <$25,u
UpdateObjsNext               leau      <$2B,u
                    lbra      UpdateObjsLoop
UpdateAllObjsRet               leas      $0B,s
                    rts
MoveTableData               fcb       8,1,2,7,0,3,6,5,4
SetObjMotion               ldb       $1e,u
                    pshs      b,a
                    ldd       <$27,u
                    pshs      b,a
                    ldd       $03,u
                    pshs      b,a
                    lbsr      CalcMoveDir
                    leas      $06,s
                    cmpu      <$0030
                    bne       SetObjMotionStore
                    sta       >$0437
SetObjMotionStore   sta       <$21,u
                    bne       SetObjMotionRet
                    bsr       ObjMoveReached
SetObjMotionRet     rts
ObjMoveReached               lda       <$29,u
                    sta       <$1E,u
                    lda       <$2A,u
                    lbsr      SetFlag
                    lda       #$00
                    sta       <$22,u
                    cmpu      <$0030
                    bne       ObjMoveReachedRet
                    lda       #$01
                    sta       >$0250
                    clr       >$0437
ObjMoveReachedRet               rts
CalcMoveDir               leas      -$03,s
                    clra
                    sta       $09,s
                    ldb       $05,s
                    std       ,s
                    ldb       $07,s
                    subd      ,s
                    pshs      b,a
                    ldd       $0B,s
                    pshs      b,a
                    lbsr      CalcAxisDir
                    leas      $04,s
                    sta       $02,s
                    clra
                    sta       $05,s
                    ldb       $08,s
                    subd      $05,s
                    pshs      b,a
                    ldd       $0B,s
                    pshs      b,a
                    lbsr      CalcAxisDir
                    leas      $04,s
                    leax      >MoveTableData,pcr
                    ldb       #$03
                    mul
                    addb      $02,s
                    lda       b,x
                    leas      $03,s
                    rts
CalcAxisDir               ldd       #$0000
                    subd      $02,s
                    cmpd      $04,s
                    blt       CalcAxisDirNeg
                    clra
                    bra       CalcAxisDirRet
CalcAxisDirNeg               ldd       $02,s
                    cmpd      $04,s
                    bgt       CalcAxisDirPos
                    lda       #$02
                    bra       CalcAxisDirRet
CalcAxisDirPos               lda       #$01
CalcAxisDirRet               rts
cmd_new_room               lda       ,y
                    bsr       NewRoomSetup
                    rts
cmd_new_room_v               ldb       ,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    bsr       NewRoomSetup
                    rts
NewRoomSetup               leas      -$01,s
                    sta       ,s
                    lbsr      ResetHeap
                    lbsr      events_clear
                    lbsr      InitScriptBuf
                    lda       #$01
                    sta       >$05B1
                    ldu       <$0030
NewRoomObjLoop               cmpu      <$0032
                    bcc       NewRoomObjsDone
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
                    bra       NewRoomObjLoop
NewRoomObjsDone               lbsr      ResetGameTables
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
                    lbsr      LoadLogicNum
                    ldb       <$006A
                    beq       NewRoomLoadView
                    lbsr      AllocLoadLogic
NewRoomLoadView               ldu       <$0030
                    lda       $05,u
                    sta       >$0441
                    lda       >$0433
                    beq       NewRoomFlagSetup
                    cmpa      #$01
                    bne       NewRoomEgoDir2
                    lda       #$A7
                    sta       $04,u
                    bra       NewRoomEgoDirDone
NewRoomEgoDir2               cmpa      #$02
                    bne       NewRoomEgoDir3
                    lda       #$00
                    sta       $03,u
                    bra       NewRoomEgoDirDone
NewRoomEgoDir3               cmpa      #$03
                    bne       NewRoomEgoDir4
                    lda       #$25
                    sta       $04,u
                    bra       NewRoomEgoDirDone
NewRoomEgoDir4               cmpa      #$04
                    bne       NewRoomEgoDirDone
                    lda       #$A0
                    suba      <$1C,u
                    sta       $03,u
NewRoomEgoDirDone               clr       >$0433
NewRoomFlagSetup               lda       >$01AE
                    ora       #$04
                    sta       >$01AE
                    lbsr      ClearInputBuffer
                    lbsr      StatusLineWrite
                    lbsr      InputRedraw
                    ldy       #$0000
                    leas      $01,s
                    rts
cmd_get               bsr       GetObjPtr
                    lda       #$FF
                    sta       $02,u
                    rts
cmd_get_v               bsr       GetObjPtrV
                    lda       #$FF
                    sta       $02,u
                    rts
cmd_drop               bsr       GetObjPtr
                    lda       #$00
                    sta       $02,u
                    rts
GetObjPtr               ldx       <$0038
                    ldb       ,y+
                    abx
                    abx
                    abx
                    tfr       x,u
                    cmpu      <$003C
                    bcs       GetObjPtrRet
                    lda       #$17
                    ldb       -$01,y
                    lbsr      ReportError
GetObjPtrRet               rts
GetObjPtrV               ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    ldx       <$0038
                    abx
                    abx
                    abx
                    tfr       x,u
                    cmpu      <$003C
                    bcs       GetObjPtrVRet
                    lda       #$17
                    ldb       -$01,y
                    lbsr      ReportError
GetObjPtrVRet               rts
cmd_put               bsr       GetObjPtr
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       $02,u
                    rts
cmd_put_v               bsr       GetObjPtrV
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    sta       $02,u
                    rts
cmd_get_room_v               bsr       GetObjPtrV
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       $02,u
                    sta       ,x
                    rts
PriBaseFlag               fcb       1
BlitListDraw               leas      -2,s
                    stx       ,s
                    pshs      x
                    lda       #$1B
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    ldx       ,s
                    bsr       ProcessDrawList
                    leas      $02,s
                    rts
ProcessDrawList               ldu       ,x
                    beq       ProcessDrawListRet
                    ldd       #$0000
                    std       ,x
                    std       $02,x
                    tfr       u,x
ProcessDrawListLoop               stx       <$0055
                    ldu       $0A,x
                    lda       $0C,x
                    lbsr      CalcPriAddr
                    stu       <$004F
                    ldx       ,x
                    bne       ProcessDrawListLoop
ProcessDrawListRet               rts
ScanViewObjs               leas      >-$00C8,s
                    stu       ,s
                    stx       $02,s
                    ldu       <$0030
                    clr       $04,s
ScanViewObjsLoop               cmpu      <$0032
                    bcc       ScanViewObjsSort
                    jsr       [,s]
                    tsta
                    beq       ScanViewObjsNext
                    leax      $05,s
                    lda       $04,s
                    lsla
                    stu       a,x
                    ldb       $04,u
                    lda       <$26,u
                    bita      #$04
                    beq       ScanViewObjsPriStore
                    lda       >PriBaseFlag,pcr
                    beq       ScanViewObjsPriCalc
                    lda       <$24,u
                    suba      #$05
                    ldb       #$0C
                    mul
                    addb      #$30
                    bra       ScanViewObjsPriStore
ScanViewObjsPriCalc               clrb
                    lda       <$24,u
                    beq       ScanViewObjsPriStore
                    ldx       #$05ED
                    ldb       #$A8
ScanViewObjsPriLoop               cmpa      b,x
                    bhi       ScanViewObjsPriStore
                    decb
                    bne       ScanViewObjsPriLoop
ScanViewObjsPriStore               leax      >$0085,s
                    lda       $04,s
                    stb       a,x
                    inc       $04,s
ScanViewObjsNext               leau      <$2B,u
                    bra       ScanViewObjsLoop
ScanViewObjsSort               clra
ScanViewObjsSortOuter               sta       >$00C5,s
                    cmpa      $04,s
                    bcc       ScanViewObjsRet
                    leax      >$0085,s
                    lda       #$FF
                    sta       >$00C7,s
                    clra
ScanViewObjsSortInner               cmpa      $04,s
                    bcc       ScanViewObjsSortStore
                    ldb       a,x
                    cmpb      >$00C7,s
                    bcc       ScanViewObjsSortNext
                    sta       >$00C6,s
                    stb       >$00C7,s
ScanViewObjsSortNext               inca
                    bra       ScanViewObjsSortInner
ScanViewObjsSortStore               lda       #$FF
                    ldb       >$00C6,s
                    sta       b,x
                    leau      $05,s
                    lslb
                    ldx       b,u
                    ldu       $02,s
                    bsr       InsertPriList
                    lda       >$00C5,s
                    inca
                    bra       ScanViewObjsSortOuter
ScanViewObjsRet               ldx       $02,s
                    leas      >$00C8,s
                    rts
InsertPriList               leas      -$02,s
                    stu       ,s
                    lbsr      AllocViewEntry
                    ldx       ,s
                    ldx       ,x
                    stx       ,u
                    beq       InsertPriListHead
                    stu       $02,x
InsertPriListHead               ldx       ,s
                    stu       ,x
                    ldd       $02,x
                    bne       InsertPriListRet
                    stu       $02,x
InsertPriListRet               leas      $02,s
                    rts

SortObjsBuf               fcb       0,0
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
SortObjsPtr               fcb       0,0
PunctChars1               fcc       / ,.?!();:[]{}/
                    fcb       0
PunctChars2               fcc       /'`-"/
                    fcb       0

ParseSentence               leas      -$07,s
                    stx       ,s
                    clrb
                    ldu       #$0180
                    ldx       #$0014
                    lbsr      FillMem
                    ldu       #$0194
                    ldx       #$0014
                    lbsr      FillMem
                    ldu       ,s
                    lbsr      TokenizeString
                    clr       $02,s
ParseWordLoop               leau      >SortObjsBuf,pcr
                    stu       >SortObjsPtr,pcr
                    ldd       <$000A
                    std       $05,s
                    ldd       >$01AA
                    lbsr      SetLogicPage
ParseWordLoopTop               lda       ,u
                    beq       ParseSentenceDone
                    lda       $02,s
                    cmpa      #$0A
                    bcc       ParseSentenceDone
                    lbsr      LookupWord
                    std       $03,s
                    beq       ParseWordContinue
                    bpl       ParseWordMinus
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
                    bra       ParseSentenceStore
ParseWordMinus               ldb       $02,s
                    ldx       #$0194
                    abx
                    abx
                    ldd       $03,s
                    std       ,x
                    ldb       $02,s
                    ldx       #$0180
                    abx
                    abx
                    ldd       >SortObjsPtr,pcr
                    std       ,x
                    inc       $02,s
ParseWordContinue               stu       >SortObjsPtr,pcr
                    bra       ParseWordLoopTop
ParseSentenceDone               lda       $02,s
                    beq       ParseSentenceStore
                    sta       >$015A
                    lda       >$01AE
                    ora       #$20
                    sta       >$01AE
ParseSentenceStore               ldd       $05,s
                    lbsr      SetLogicPage
                    leas      $07,s
                    rts

cmd_parse               lda       >$01AE
                    anda      #$DF
                    sta       >$01AE
                    lda       >$01AE
                    anda      #$F7
                    sta       >$01AE
                    lda       ,y+
                    cmpa      #$0C
                    bcc       CmdParseRet
                    ldb       #$28
                    mul
                    ldx       #$0251
                    leax      d,x
                    lbsr      ParseSentence
CmdParseRet               rts

TokenizeString               leas      -$02,s
                    leax      >SortObjsBuf,pcr
                    stx       ,s
TokenizeLoop               lda       ,u+
                    beq       TokenizeDone
                    leax      >PunctChars1,pcr
                    lbsr      FindByte
                    bne       TokenizeLoop
                    leax      >PunctChars2,pcr
                    lbsr      FindByte
                    bne       TokenizeLoop
                    bra       TokenizeStoreChar
TokenizeCharLoop               leax      >PunctChars1,pcr
                    lbsr      FindByte
                    bne       TokenizeAddSpace
                    leax      >PunctChars2,pcr
                    lbsr      FindByte
                    bne       TokenizeNextChar
TokenizeStoreChar               ldx       ,s
                    sta       ,x+
                    stx       ,s
TokenizeNextChar               lda       ,u+
                    bne       TokenizeCharLoop
                    bra       TokenizeDone
TokenizeAddSpace               lda       #$20
                    ldx       ,s
                    sta       ,x+
                    stx       ,s
                    bra       TokenizeLoop
TokenizeDone               leax      >SortObjsBuf,pcr
                    cmpx      ,s
                    bcc       TokenizeTerminate
                    ldx       ,s
                    lda       -$01,x
                    cmpa      #$20
                    bne       TokenizeTerminate
                    leax      -$01,x
                    stx       ,s
TokenizeTerminate               clr       [,s]
                    leas      $02,s
                    rts

LookupWord               leas      -$06,s
                    ldd       #$FFFF
                    std       ,s
                    ldd       #$0000
                    std       $02,s
                    lda       ,u
                    lbsr      ToLower
                    cmpa      #$61
                    bcs       LookupNotAlpha
                    cmpa      #$7A
                    bls       LookupAlphaNext
LookupNotAlpha               lbsr      StripLastWord
                    lbra      LookupWordRet
LookupAlphaNext               ldb       $01,u
                    cmpb      #$20
                    beq       LookupSingleWord
                    cmpb      #$00
                    bne       LookupAlphaSearch
LookupSingleWord               cmpa      #$61
                    beq       LookupSingleFound
                    cmpa      #$69
                    bne       LookupAlphaSearch
LookupSingleFound               clrb
                    stb       ,s
                    stb       $01,s
                    leax      $01,u
                    stx       $02,s
                    ldb       ,x+
                    cmpb      #$20
                    bne       LookupAlphaSearch
                    stx       $02,s
LookupAlphaSearch               suba      #$61
                    lsla
                    ldx       >$01A8
                    ldd       a,x
                    beq       LookupNotAlpha
                    leax      d,x
                    clr       $04,s
LookupWordOuter               lda       $04,s
                    cmpa      ,x+
                    bhi       LookupWordNotFound
                    bne       LookupCharMiss
LookupCharMatch               lda       ,x
                    anda      #$7F
                    sta       $05,s
                    lda       ,u
                    lbsr      ToLower
                    eora      #$7F
                    cmpa      $05,s
                    bne       LookupCharMiss
                    leau      $01,u
                    inc       $04,s
                    lda       ,x
                    anda      #$80
                    beq       LookupCharNext
                    lda       ,u
                    cmpa      #$00
                    beq       LookupWordFound
                    cmpa      #$20
                    bne       LookupSkipWord
LookupWordFound               ldd       $01,x
                    std       ,s
                    stu       $02,s
                    lda       ,u
                    cmpa      #$00
                    beq       LookupWordRet
                    tfr       u,d
                    addd      #$0001
                    std       $02,s
                    bra       LookupSkipWord
LookupCharNext               leax      $01,x
                    bra       LookupCharMatch
LookupCharMiss               lda       ,u
                    cmpa      #$00
                    beq       LookupWordNotFound
LookupSkipWord               lda       ,x+
                    bpl       LookupSkipWord
                    leax      $02,x
                    cmpa      #$00
                    bne       LookupWordOuter
LookupWordNotFound               ldu       $02,s
                    lbeq      LookupNotAlpha
                    lda       ,u
                    beq       LookupWordRet
                    clr       -$01,u
LookupWordRet               ldd       ,s
                    leas      $06,s
                    rts

StripLastWord               ldu       >SortObjsPtr,pcr
                    tfr       u,x
StripLastWordLoop               lda       ,x+
                    beq       StripLastWordRet
                    cmpa      #$20
                    bne       StripLastWordLoop
                    clr       -$01,x
StripLastWordRet               rts

cmd_add_to_pic               ldu       #$05B2
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
                    bsr       AddToPicImpl
                    rts

cmd_add_to_pic_v               ldu       #$05B2
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
                    bsr       AddToPicImpl
                    rts

AddToPicImpl               leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       #$05
                    clrb
                    lbsr      PushScript
                    ldx       #$05B2
                    ldd       ,x
                    lbsr      PushScript
                    ldd       $02,x
                    lbsr      PushScript
                    ldd       $04,x
                    lbsr      PushScript
                    ldu       <$0036
                    ldb       $02,x
                    stb       $0E,u
                    ldb       $01,x
                    stb       $0A,u
                    ldb       ,x
                    lbsr      SetViewForObj
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
                    lbsr      FindObjPos
                    ldx       #$05B2
                    lda       $05,x
                    anda      #$0F
                    bne       AddToPicColor
                    lda       #$08
                    sta       <$26,u
AddToPicColor               lda       $05,x
                    sta       <$24,u
                    lbsr      ClearBothRanges
                    ldd       <$0036
                    pshs      b,a
                    lda       #$0F
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      SwapObjRanges
                    ldd       <$0036
                    pshs      b,a
                    lda       #$1B
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

PicListBuf               fcb       0,0,0,0,0,0,0
PicListPtr               fdb       0

PicListClear               leau      $3776,pcr
                    ldd       #0
                    std       ,u
                    rts

pic_find               leau      >PicListBuf,pcr
PicFindLoop               stu       >PicListPtr,pcr
                    ldu       ,u
                    beq       PicFindRet
                    cmpb      $02,u
                    bne       PicFindLoop
PicFindRet               rts

cmd_load_pic               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       LoadPicImpl
                    rts

LoadPicImpl               leas      -$05,s
                    stb       ,s
                    bsr       pic_find
                    cmpu      #$0000
                    bne       LoadPicRet
                    ldd       <$000A
                    std       $03,s
                    lbsr      ClearBothRanges
                    lda       #$02
                    ldb       ,s
                    lbsr      PushScript
                    leau      >PicListBuf,pcr
                    ldx       >PicListPtr,pcr
                    beq       LoadPicStore
                    ldd       #$0007
                    lbsr      AllocDataBlock
                    stu       ,x
                    ldd       #$0000
                    std       ,u
LoadPicStore               ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      FetchPicture
                    ldx       #$0000
                    lbsr      OpenVolFile
                    beq       LoadPicDone
                    ldx       $01,s
                    std       $05,x
                    stu       $03,x
LoadPicDone               lbsr      SwapObjRanges
                    ldd       $03,s
                    lbsr      SetLogicPage
                    ldu       $01,s
LoadPicRet               leas      $05,s
                    rts

cmd_draw_pic               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       DrawPicImpl
                    rts

DrawPicImpl               leas      -$01,s
                    stb       ,s
                    stb       >$0240
                    lbsr      pic_find
                    cmpu      #$0000
                    bne       DrawPicFind
                    lda       #$12
                    ldb       ,s
                    lbsr      ReportError
DrawPicFind               ldd       $03,u
                    std       >$0551
                    pshs      u
                    lda       #$04
                    ldb       $02,s
                    lbsr      PushScript
                    lbsr      ClearBothRanges
                    lda       #$06
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      SwapObjRanges
                    clr       >$0100
                    leas      $01,s
                    rts

cmd_overlay_pic               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       pic_overlay
                    rts

pic_overlay               leas      -$01,s
                    stb       ,s
                    stb       >$0240
                    lbsr      pic_find
                    cmpu      #$0000
                    bne       OverlayPicRender
                    lda       #$12
                    ldb       ,s
                    lbsr      ReportError
OverlayPicRender               ldd       $03,u
                    std       >$0551
                    pshs      u
                    lda       #$08
                    ldb       $02,s
                    lbsr      PushScript
                    lbsr      ClearBothRanges
                    lda       #$09
                    sta       <$0021
                    ldx       <$0028
                    jsr       >$0701
                    leas      $02,s
                    lbsr      SwapObjRanges
                    lbsr      UpdateObjSegments
                    clr       >$0100
                    leas      $01,s
                    rts

cmd_show_pic               lda       >$01AF
                    anda      #$FE
                    sta       >$01AF
                    lbsr      cmd_close_window
                    lbsr      gfx_picbuff_update
                    lda       #$01
                    sta       >$0100
                    rts

cmd_discard_pic               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       DiscardPicImpl
                    rts

DiscardPicImpl               leas      -$03,s
                    stb       ,s
                    lbsr      pic_find
                    ldb       ,s
                    cmpu      #$0000
                    bne       DiscardPicFound
                    lda       #$15
                    lbsr      ReportError
DiscardPicFound               stu       $01,s
                    lda       #$06
                    ldb       ,s
                    lbsr      PushScript
                    ldu       >PicListPtr,pcr
                    ldd       #$0000
                    std       ,u
                    lbsr      ClearBothRanges
                    ldu       $01,s
                    stu       <$0055
                    lda       $05,u
                    ldu       $03,u
                    lbsr      CalcPriAddr
                    stu       <$004F
                    lbsr      SwapObjRanges
                    lbsr      UpdateFreeSpace
                    leas      $03,s
                    rts

cmd_position               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldd       ,y++
                    std       $03,u
                    std       <$1A,u
                    rts

cmd_position_v               lda       ,y+
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

cmd_get_position               lda       ,y+
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

cmd_reposition               leas      -$02,s
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
                    bpl       ReposXDone
                    clrb
ReposXDone               stb       $03,u
                    ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    sex
                    std       ,s
                    clra
                    ldb       $04,u
                    addd      ,s
                    bpl       ReposYDone
                    clrb
ReposYDone               stb       $04,u
                    lbsr      FindObjPos
                    leas      $02,s
                    rts

cmd_reposition_to               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldd       ,y++
                    std       $03,u
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lbsr      FindObjPos
                    rts

cmd_reposition_to_v               lda       ,y+
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
                    lbsr      FindObjPos
                    rts

cmd_obj_on_water               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$01
                    sta       <$25,u
                    rts

cmd_obj_on_land               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    ora       #$08
                    sta       <$25,u
                    rts

cmd_obj_on_anything               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$25,u
                    anda      #$F6
                    sta       <$25,u
                    rts

cmd_set_horizon               lda       ,y+
                    sta       >$01D6
                    rts

cmd_ignore_horizon               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    ora       #$08
                    sta       <$26,u
                    rts

cmd_observe_horizon               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$F7
                    sta       <$26,u
                    rts

StrMsgTooVerbose               fcc       /Message too verbose:/
                    fcb       $0a,$0a
                    fcc       /"%s..."/
                    fcb       $0a,$0a
                    fcc       /Press CTRL-BREAK to continue./
                    fcb       0

PrintAtRow               fcb       $ff
PrintAtCol               fcb       $ff
PrintAtHeight               fcb       $ff

cmd_print               ldb       ,y+
                    lbsr      GetMsgPtr
                    bsr       message_box
                    rts
cmd_print_v               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    lbsr      GetMsgPtr
                    bsr       message_box
                    rts
cmd_print_at               ldb       ,y+
                    bsr       SetPrintAtImpl
                    rts
cmd_print_at_v               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       SetPrintAtImpl
                    rts

SetPrintAtImpl               lda       ,y+
                    sta       >PrintAtCol,pcr
                    lda       ,y+
                    sta       >PrintAtRow,pcr
                    lda       ,y+
                    bne       SetPrintAtHeight
                    lda       #$1E
SetPrintAtHeight               sta       >PrintAtHeight,pcr
                    lbsr      GetMsgPtr
                    bsr       message_box
                    ldd       #$FFFF
                    sta       >PrintAtHeight,pcr
                    std       >PrintAtRow,pcr
SetPrintAtRet               rts

message_box               leas      -$05,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      message_box_draw
                    leas      $08,s
MsgBoxCheckPrint               lda       >$01AF
                    anda      #$01
                    beq       MsgBoxGetInput
                    lda       >$01AF
                    anda      #$FE
                    sta       >$01AF
                    lda       #$01
                    bra       MsgBoxRet
MsgBoxGetInput               lda       >$0446
                    bne       MsgBoxTimedWait
                    lda       #$01
                    sta       ,s
                    lbsr      BooleanPoll
                    cmpa      #$01
                    beq       MsgBoxClose
                    clra
                    sta       ,s
                    bra       MsgBoxClose
MsgBoxTimedWait               ldb       #$0A
                    mul
                    orcc      #$50
                    addd      >$024A
                    std       $03,s
                    ldd       >$0248
                    andcc     #$AF
                    bcc       MsgBoxTimerSet
                    addd      #$0001
MsgBoxTimerSet               std       $01,s
MsgBoxWaitLoop               ldd       $01,s
                    cmpd      >$0248
                    blt       MsgBoxClose
                    bgt       MsgBoxWaitKey
                    ldd       $03,s
                    cmpd      >$024A
                    bls       MsgBoxClose
MsgBoxWaitKey               lbsr      WaitEnterOrEsc
                    tsta
                    bmi       MsgBoxWaitLoop
MsgBoxClose               lbsr      cmd_close_window
                    lda       ,s
MsgBoxRet               leas      $05,s
                    rts

message_box_draw               leas      >-$02BC,s
                    lbsr      cmd_close_window
                    lbsr      PushTextColor
                    lbsr      PushRowCol
                    clra
                    ldb       #$0F
                    lbsr      text_color
                    ldb       >PrintAtHeight,pcr
                    cmpb      #$FF
                    bne       MsgBoxSetHeight
                    tst       >$02C3,s
                    bne       MsgBoxSetupDraw
                    ldb       #$1E
                    stb       >$02C3,s
                    bra       MsgBoxSetupDraw
MsgBoxSetHeight               lda       >PrintAtHeight,pcr
                    sta       >$02C3,s
MsgBoxSetupDraw               leax      ,s
                    ldd       >$02C2,s
                    pshs      b,a
                    ldd       >$02C0,s
                    pshs      b,a
                    pshs      x
                    lbsr      MsgTextSetup
                    leas      $06,s
                    tst       >$02C5,s
                    beq       MsgBoxSkipPrintAt
                    lda       >$02C3,s
                    sta       >$0159
                    lda       >$02C1,s
                    beq       MsgBoxSkipPrintAt
                    sta       >$015B
MsgBoxSkipPrintAt               lda       #$13
                    cmpa      >$015B
                    bcc       MsgBoxHeightOk
                    ldx       >$02BE,s
                    lda       <$14,x
                    clr       <$14,x
                    pshs      x,a
                    leau      >StrMsgTooVerbose,pcr
                    leax      >$025B,s
                    ldd       >$02C1,s
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStr
                    leas      $06,s
                    puls      x,a
                    sta       <$14,x
                    stu       >$02BE,s
                    bra       MsgBoxSetupDraw
MsgBoxHeightOk               lda       >$015B
                    ldb       #$08
                    mul
                    addb      #$0A
                    stb       >$017B
                    lda       >$0159
                    ldb       #$04
                    mul
                    addb      #$0A
                    stb       >$017C
                    lda       >PrintAtCol,pcr
                    bpl       MsgBoxColCalc
                    lda       #$13
                    suba      >$015B
                    lsra
                    adda      #$01
MsgBoxColCalc               adda      >$0241
                    sta       >$0175
                    adda      >$015B
                    deca
                    sta       >$0177
                    lda       >PrintAtRow,pcr
                    bpl       MsgBoxRowCalc
                    lda       #$28
                    suba      >$0159
                    lsra
MsgBoxRowCalc               sta       >$0176
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
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    clr       >$017A
                    lbsr      PopRowCol
                    lbsr      PopTextColor
                    leas      >$02BC,s
                    rts

cmd_close_window               tst       >$017F
                    beq       CloseWindowRet
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
CloseWindowRet               rts

MsgTextSetup               ldd       #$0000
                    sta       >$015B
                    sta       >$0157
                    sta       >$0159
                    std       >$0155
                    lda       $07,s
                    sta       >$0158
                    ldu       $04,s
                    beq       MsgTextSetupNoStr
                    ldd       $02,s
                    pshs      b,a
                    pshs      u
                    lbsr      FormatStr
                    leas      $04,s
                    clr       ,u
                    lbsr      IncrLineCount
MsgTextSetupNoStr               ldx       $02,s
                    rts

FormatStr               leas      -$02,s
                    pshs      x
                    ldx       $06,s
                    ldu       $08,s
                    tst       ,x
                    lbeq      FormatStrDone
                    lda       >$015B
                    cmpa      #$13
                    lbhi      FormatStrDone
FormatStrLoop               lda       >$0157
                    cmpa      >$0158
                    lbcc      FormatStrWordWrap
                    lda       ,x
                    lbeq      FormatStrDone
                    cmpa      >$0101
                    bne       FormatStrCheckEsc
                    tst       ,x+
                    bra       FormatStrStoreChar
FormatStrCheckEsc               cmpa      #$25
                    beq       FormatStrEscape
                    cmpa      #$0A
                    bne       FormatStrCheckNl
                    lbsr      IncrLineCount
                    bra       FormatStrCopyChar
FormatStrCheckNl               cmpa      #$20
                    bne       FormatStrStoreChar
                    stu       >$0155
FormatStrStoreChar               inc       >$0157
FormatStrCopyChar               lda       ,x+
                    sta       ,u+
                    bra       FormatStrLoop
FormatStrEscape               ldd       ,x++
                    cmpb      #$77
                    beq       FormatStrEscapeW
                    cmpb      #$73
                    beq       FormatStrEscapeS
                    cmpb      #$6D
                    beq       FormatStrEscapeM
                    cmpb      #$67
                    beq       FormatStrEscapeG
                    cmpb      #$76
                    lbeq      FormatStrEscapeV
                    cmpb      #$6F
                    bne       FormatStrLoop
                    stu       $08,s
                    lbsr      ParseDecStr
                    clra
                    ldu       #$0431
                    lda       d,u
                    ldb       #$03
                    mul
                    addd      #$0000
                    ldu       <$0038
                    ldu       d,u
                    lbra      FormatStrEscapeRec
FormatStrEscapeW               stu       $08,s
                    lbsr      ParseDecStr
                    decb
                    bmi       FormatStrLoop
                    cmpb      >$015A
                    bcc       FormatStrLoop
                    lslb
                    ldu       #$0180
                    leau      [b,u]
                    lbra      FormatStrEscapeRec
FormatStrEscapeS               stu       $08,s
                    lbsr      ParseDecStr
                    lda       #$28
                    mul
                    addd      #$0251
                    tfr       d,u
                    bra       FormatStrEscapeRec
FormatStrEscapeM               stu       $08,s
                    lbsr      ParseDecStr
                    lbsr      GetMsgPtr
                    cmpu      #$0000
                    lbeq      FormatStrLoop
                    bra       FormatStrEscapeRec
FormatStrEscapeG               stu       $08,s
                    ldd       <$0062
                    std       $02,s
                    clrb
                    lbsr      FindLogicSlot
                    stu       <$0062
                    ldd       $04,u
                    lbsr      SetLogicPage
                    lbsr      ParseDecStr
                    lbsr      GetMsgPtr
                    cmpu      #$0000
                    beq       FormatStrEscapeGRet
                    ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      FormatStr
                    leas      $04,s
FormatStrEscapeGRet               ldu       $02,s
                    stu       <$0062
                    ldd       $04,u
                    lbsr      SetLogicPage
                    ldu       $08,s
                    lbra      FormatStrLoop
FormatStrEscapeV               stu       $08,s
                    lbsr      ParseDecStr
                    ldu       #$0431
                    clra
                    ldb       d,u
                    pshs      x
                    lbsr      UIntToDecStr
                    tfr       x,u
                    puls      x
                    lda       ,x
                    cmpa      #$7C
                    bne       FormatStrEscapeRec
                    leax      $01,x
                    lbsr      ParseDecStr
                    lbsr      StrZeroPad
FormatStrEscapeRec               ldd       $08,s
                    pshs      b,a
                    pshs      u
                    lbsr      FormatStr
                    leas      $04,s
                    stu       $08,s
                    lbra      FormatStrLoop
FormatStrWordWrap               ldd       >$0155
                    bne       FormatStrWordWrapMove
                    lda       #$0A
                    sta       ,u+
                    stu       $08,s
                    lbsr      IncrLineCount
                    lbra      FormatStrLoop
FormatStrWordWrapMove               clr       ,u
                    tfr       u,d
                    subd      >$0155
                    negb
                    addb      >$0157
                    stb       >$0157
                    lbsr      IncrLineCount
                    pshs      x
                    ldx       >$0155
                    lda       #$0A
                    sta       ,x+
FormatStrSkipSpaces               lda       ,x+
                    cmpa      #$20
                    beq       FormatStrSkipSpaces
                    leax      -$01,x
                    ldu       >$0155
                    leau      $01,u
                    lbsr      StrCopy
                    ldd       #$0000
                    std       >$0155
FormatStrCountChars               lda       ,x+
                    beq       FormatStrCountRet
                    inc       >$0157
                    bra       FormatStrCountChars
FormatStrCountRet               leau      -$01,x
                    stu       $0A,s
                    puls      x
                    lbra      FormatStrLoop
FormatStrDone               puls      x
                    leas      $02,s
                    rts

GetMsgPtr               leas      -$01,s
                    ldu       <$0062
                    cmpb      $03,u
                    bls       GetMsgPtrFound
                    ldd       #$0000
                    tfr       d,u
                    bra       GetMsgPtrRet
GetMsgPtrFound               ldu       $0A,u
                    stb       ,s
                    clra
                    lslb
                    rola
                    ldd       d,u
                    bne       GetMsgPtrRet
                    ldb       ,s
                    lda       #$0E
                    lbsr      ReportError
GetMsgPtrRet               exg       a,b
                    leau      d,u
                    leas      $01,s
                    rts

cmd_display               leas      >-$03E8,s
                    lbsr      PushRowCol
                    ldd       ,y++
                    std       <$0040
                    ldb       ,y+
                    bsr       GetMsgPtr
                    leax      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      MsgTextSetup
                    leas      $06,s
                    leax      ,s
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    lbsr      PopRowCol
                    leas      >$03E8,s
                    rts

cmd_display_v               leas      >-$03E8,s
                    lbsr      PushRowCol
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
                    bsr       GetMsgPtr
                    leax      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      MsgTextSetup
                    leas      $06,s
                    leax      ,s
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    lbsr      PopRowCol
                    leas      >$03E8,s
                    rts

ParseDecStr               clrb
ParseDecStrLoop               lda       ,x
                    cmpa      #$30
                    bcs       ParseDecStrRet
                    cmpa      #$39
                    bhi       ParseDecStrRet
                    lda       #$0A
                    mul
                    subb      #$30
                    addb      ,x+
                    bra       ParseDecStrLoop
ParseDecStrRet               rts
IncrLineCount               inc       >$015B
                    lda       >$0157
                    clr       >$0157
                    cmpa      >$0159
                    bls       IncrLineCountRet
                    sta       >$0159
IncrLineCountRet               rts
PrintFmtOutPtr               fcb       0,0
PrintFmtDrawFlag               fcb       0
PrintFmtHasText               fcb       0
PrintFmtBasePtr               fcb       0,0

PrintFmtStr               clr       >PrintFmtDrawFlag,pcr
                    ldd       $02,s
                    std       >PrintFmtOutPtr,pcr
                    ldx       $04,s
                    leau      $06,s
                    bsr       PrintFmtLoop
                    ldu       $02,s
                    rts

PrintFmtStrToScr               leas      <-$2A,s
                    clr       >PrintFmtHasText,pcr
                    lda       #$01
                    sta       >PrintFmtDrawFlag,pcr
                    leax      ,s
                    stx       >PrintFmtBasePtr,pcr
                    stx       >PrintFmtOutPtr,pcr
                    ldx       <$2C,s
                    leau      <$2E,s
                    bsr       PrintFmtLoop
                    leas      <$2A,s
                    rts

PrintFmtLoop               lda       ,x+
                    beq       PrintFmtOutputChar
                    cmpa      #$25
                    beq       PrintFmtEscS
                    bsr       PrintFmtOutputChar
                    bra       PrintFmtLoop
PrintFmtEscS               lda       ,x+
                    cmpa      #$73
                    bne       PrintFmtEscD
                    ldd       ,u++
                    pshs      u,x
                    bra       PrintFmtStrEmit
PrintFmtEscD               cmpa      #$64
                    bne       PrintFmtEscUX
                    tst       ,u
                    bpl       PrintFmtEscU
                    lda       #$2D
                    bsr       PrintFmtOutputChar
                    ldd       #$0000
                    subd      ,u++
                    pshs      u,x
                    lbsr      UIntToDecStr
                    tfr       x,d
                    bra       PrintFmtStrEmit
PrintFmtEscUX               cmpa      #$75
                    beq       PrintFmtEscU
                    cmpa      #$78
                    bne       PrintFmtEscC
                    ldd       ,u++
                    pshs      u,x
                    lbsr      UIntToHexStr
                    tfr       x,d
                    bra       PrintFmtStrEmit
PrintFmtEscU               ldd       ,u++
                    pshs      u,x
                    lbsr      UIntToDecStr
                    tfr       x,d
                    bra       PrintFmtStrEmit
PrintFmtEscC               cmpa      #$63
                    bne       PrintFmtEscOther
                    ldd       ,u++
                    bsr       PrintFmtOutputChar
                    bra       PrintFmtLoop
PrintFmtEscOther               leax      -$01,x
                    lda       -$01,x
                    bsr       PrintFmtOutputChar
                    bra       PrintFmtLoop
PrintFmtStrEmit               tfr       d,x
PrintFmtStrEmitLoop               lda       ,x+
                    lbne      PrintFmtStrEmitChar
                    puls      u,x
                    lbra      PrintFmtLoop
PrintFmtStrEmitChar               bsr       PrintFmtOutputChar
                    bra       PrintFmtStrEmitLoop
PrintFmtOutputChar               pshs      u,x
                    ldu       >PrintFmtOutPtr,pcr
                    sta       ,u+
                    stu       >PrintFmtOutPtr,pcr
                    tst       >PrintFmtDrawFlag,pcr
                    beq       PrintFmtOutputCharRet
                    tsta
                    beq       PrintFmtFlushLine
                    cmpa      #$0A
                    beq       PrintFmtFlushLine
                    cmpa      #$0D
                    beq       PrintFmtFlushLine
                    lda       #$01
                    sta       >PrintFmtHasText,pcr
                    bra       PrintFmtOutputCharRet
PrintFmtFlushLine               tst       >PrintFmtHasText,pcr
                    beq       PrintFmtPostFlush
                    clr       ,-u
                    pshs      a
                    ldd       >PrintFmtBasePtr,pcr
                    pshs      b,a
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    clra
                    sta       >PrintFmtHasText,pcr
                    puls      a
PrintFmtPostFlush               tsta
                    beq       PrintFmtResetOutPtr
                    lbsr      PutCharToWindow
PrintFmtResetOutPtr               ldu       >PrintFmtBasePtr,pcr
                    stu       >PrintFmtOutPtr,pcr
PrintFmtOutputCharRet               puls      u,x
                    rts

cmd_set_priority               lda       ,y+
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

cmd_release_priority               lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    lda       <$26,u
                    anda      #$FB
                    sta       <$26,u
                    rts

cmd_get_priority               lda       ,y+
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

cmd_set_priority_v               lda       ,y+
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

InitRandSeed               leas      -$09,s
                    clr       ,s
                    ldd       <$008B
                    bne       ComputeRand
                    leax      $03,s
                    os9       F$Time
                    ldd       $07,s
                    addd      $05,s
                    addd      $03,s
                    orb       #$01
                    std       <$008B
ComputeRand               lda       #$4D
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

StrRestartGame               fcc       /Press ENTER to start a new/
                    fcb       $0a
                    fcc       /game./
                    fcb       $0a,$0a
                    fcc       /Press CTRL-BREAK to continue/
                    fcb       $0a
                    fcc       /with this game./
                    fcb       0

cmd_restart_game               leas      -$01,s
                    lbsr      InputEditOn
                    lda       >$01B0
                    anda      #$80
                    bne       RestartGameWithSave
                    leau      >StrRestartGame,pcr
                    lbsr      message_box
                    beq       RestartGameDone
RestartGameWithSave               lbsr      cmd_cancel_line
                    lda       >$01AF
                    anda      #$40
RestartGameReload               sta       ,s
                    lbsr      ResetHeap
                    lbsr      LoadObjectData
                    lbsr      VolumesClose
                    lda       >$01AE
                    ora       #$02
                    sta       >$01AE
                    lda       ,s
RestartGameSetFlags               beq       RestartGameReset
                    lda       >$01AF
RestartGameSetScore               ora       #$40
                    sta       >$01AF
RestartGameReset               orcc      #$50
                    ldd       #$0000
                    std       >$0248
                    std       >$024A
                    andcc     #$AF
                    ldb       <$006A
                    beq       RestartGameLoadLogic
                    lbsr      AllocLoadLogic
RestartGameLoadLogic               lbsr      EnableItemLoop
                    ldy       #$0000
RestartGameDone               lbsr      InputCursorBlink
                    leas      $01,s
                    rts

StrRestoreGameMsg               fcc       /About to restore the game/
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
StrCantOpenFile               fcc       /Can't open file:/
                    fcb       $0a
                    fcc       /%s/
                    fcb       0
StrRestoreErr               fcc       /Error in restoring game./
                    fcb       $0a
                    fcc       /Press ENTER to quit./
                    fcb       $0a,0
StrContinueCancel               fcc       /Press ENTER to continue./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to cancel./
                    fcb       0
SaveFilePathNum               fcb       0

cmd_restore_game               leas      >-$00FD,s
                    sty       ,s
                    lda       #$01
                    sta       >$0102
                    lda       >$0101
                    sta       $02,s
                    lda       #$40
                    sta       >$0101
RestoreGameLoop               ldd       #$0072
                    pshs      b,a
                    lbsr      StateGetInfo
                    leas      $02,s
                    tsta
                    lbeq      rest_end
                    lda       >state_name_auto,pcr
                    bne       RestoreGameOpenFile
                    leau      >StrContinueCancel,pcr
                    pshs      u
RestoreGameGetDesc               leau      >DataSaveGameBuf2,pcr
RestoreGameShowMsg               pshs      u
                    leau      >DataSaveGameBuf,pcr
                    pshs      u
                    leax      >StrRestoreGameMsg,pcr
                    leau      $09,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $0A,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      message_box_draw
                    leas      $08,s
                    lbsr      BooleanPoll
                    cmpa      #$00
                    lbeq      rest_end
RestoreGameOpenFile               lda       #$01
                    leax      >DataSaveGameBuf2,pcr
                    lbsr      OpenFile
                    bcc       RestoreGameReadData
                    leau      >DataSaveGameBuf2,pcr
                    pshs      u
                    leau      >DataSaveGameBuf,pcr
                    pshs      u
                    leax      >StrCantOpenFile,pcr
                    leau      $07,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $08,s
                    lbsr      message_box
                    lbra      rest_end
RestoreGameReadData               sta       >SaveFilePathNum,pcr
                    clrb
                    ldx       #$0000
                    ldu       #$001F
                    lbsr      SeekFile
                    ldd       #$01AC
                    pshs      b,a
                    lbsr      RestoreReadBlock
                    leas      $02,s
                    beq       RestoreGameReadErr
                    ldd       <$0030
                    pshs      b,a
                    lbsr      RestoreReadBlock
                    leas      $02,s
                    beq       RestoreGameReadErr
                    ldd       <$0038
                    pshs      b,a
                    lbsr      RestoreReadBlock
                    leas      $02,s
                    beq       RestoreGameReadErr
                    ldx       <$0038
                    ldd       <$003A
                    leau      d,x
                    lbsr      XorDecrypt
                    ldd       >$05AF
                    pshs      b,a
                    lbsr      RestoreReadBlock
                    leas      $02,s
                    beq       RestoreGameReadErr
                    ldd       #$0554
                    pshs      b,a
                    lbsr      RestoreReadBlock
                    leas      $02,s
                    bne       RestoreGameReadOk
RestoreGameReadErr               lda       >SaveFilePathNum,pcr
                    lbsr      CloseFilePath
                    leau      >StrRestoreErr,pcr
                    lbsr      message_box
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
RestoreGameReadOk               lda       >SaveFilePathNum,pcr
                    lbsr      CloseFilePath
                    lda       >$0553
                    sta       >$044B
                    lbsr      RestoreGameTables
                    lbsr      ClearInputBuffer
                    lda       >$01AF
                    ora       #$08
                    sta       >$01AF
                    lbsr      VolumesClose
                    ldd       #$0000
                    std       ,s
                    lbsr      EnableItemLoop
rest_end               lbsr      cmd_close_window
                    lda       $02,s
                    sta       >$0101
                    clr       >$0102
                    ldy       ,s
                    leas      >$00FD,s
                    rts

RestoreReadBlock               leas      -$02,s
                    lda       >SaveFilePathNum,pcr
                    leax      ,s
                    ldy       #$0002
                    lbsr      ReadFile
                    cmpd      #$0002
                    bne       RestoreReadBlockFail
                    ldy       ,x
                    sty       ,s
                    lda       >SaveFilePathNum,pcr
                    ldx       $04,s
                    lbsr      ReadFile
                    cmpy      ,s
                    bne       RestoreReadBlockFail
                    lda       #$01
                    bra       RestoreReadBlockRet
RestoreReadBlockFail               clra
RestoreReadBlockRet               leas      $02,s
                    rts

RestoreGameTables               leas      >-$0206,s
                    leax      $06,s
                    stx       $04,s
                    lbsr      ResetGameTables
                    clr       >$05B1
                    ldu       <$0030
RestoreGameObjLoop  cmpu      <$0032
                    bcc       RestoreGameObjDone
                    ldd       <$25,u
                    ldx       $04,s
                    std       ,x++
                    stx       $04,s
                    bitb      #$40
                    beq       RestoreGameObjNext
                    andb      #$FE
                    orb       #$10
                    stb       <$26,u
RestoreGameObjNext  leau      <$2B,u
                    bra       RestoreGameObjLoop
RestoreGameObjDone  lbsr      ClearBothRanges
                    lbsr      ResetHeap
                    clr       >$0100
                    lbsr      ResetScriptPtrs
RestoreGameHeapLoop lbsr      PopScript
                    cmpu      #$0000
                    beq       RestoreGameHeapDone
                    ldd       ,u
                    cmpa      #$00
                    bne       RestoreHeapType1
                    lbsr      AllocLoadLogic
                    lbsr      SeekLogicInList
                    bra       RestoreGameHeapLoop
RestoreHeapType1    cmpa      #$01
                    bne       RestoreHeapType2
                    lda       #$01
                    lbsr      view_load
                    bra       RestoreGameHeapLoop
RestoreHeapType2    cmpa      #$02
                    bne       RestoreHeapType3
                    lbsr      LoadPicImpl
                    bra       RestoreGameHeapLoop
RestoreHeapType3    cmpa      #$03
                    bne       RestoreHeapType4
                    lbsr      LoadSoundData
                    bra       RestoreGameHeapLoop
RestoreHeapType4    cmpa      #$04
                    bne       RestoreHeapType5
                    lbsr      DrawPicImpl
                    bra       RestoreGameHeapLoop
RestoreHeapType5    cmpa      #$05
                    bne       RestoreHeapType6
                    lbsr      PopScript
                    ldd       ,u
                    ldx       #$05B2
                    std       ,x
                    lbsr      PopScript
                    ldd       ,u
                    std       $02,x
                    lbsr      PopScript
                    ldd       ,u
                    std       $04,x
                    lbsr      AddToPicImpl
                    bra       RestoreGameHeapLoop
RestoreHeapType6    cmpa      #$06
                    bne       RestoreHeapType7
                    lbsr      DiscardPicImpl
                    bra       RestoreGameHeapLoop
RestoreHeapType7    cmpa      #$07
                    bne       RestoreHeapType8
                    lbsr      DiscardViewHelper
                    bra       RestoreGameHeapLoop
RestoreHeapType8    cmpa      #$08
                    bne       RestoreGameHeapLoop
                    lbsr      pic_overlay
                    bra       RestoreGameHeapLoop
RestoreGameHeapDone lda       #$01
                    sta       >$05B1
                    ldu       <$0032
RestoreGameViewLoop leau      <-$2B,u
                    cmpu      <$0030
                    bcs       RestoreGameViewDone
                    ldx       $04,s
                    ldd       ,--x
                    stx       $04,s
                    std       ,s
                    stu       $02,s
                    ldb       $05,u
                    lbsr      view_find
                    leax      ,x
                    beq       RestoreGameViewCheck
                    ldb       $05,u
                    lbsr      SetViewForObj
RestoreGameViewCheck ldd      ,s
                    bitb      #$40
                    beq       RestoreGameViewLoop
                    bitb      #$01
                    beq       RestoreGameViewNext
                    lda       $02,u
                    lbsr      DrawObjHelper
                    ldu       $02,s
                    lda       <$22,u
                    cmpa      #$02
                    bne       RestoreGameViewFlags
                    lda       #$FF
                    sta       <$29,u
RestoreGameViewFlags ldd      ,s
                    bitb      #$10
                    bne       RestoreGameViewNext
                    lbsr      StopUpdateHelper
                    ldu       $02,s
                    ldd       ,s
RestoreGameViewNext std       <$25,u
                    bra       RestoreGameViewLoop
RestoreGameViewDone lbsr      InputEditOn
                    lbsr      cmd_cancel_line
                    lbsr      gfx_picbuff_update
                    lda       #$01
                    sta       >$0100
                    lbsr      StatusLineWrite
                    lbsr      InputRedraw
                    leas      >$0206,s
                    rts

AllocViewEntry      ldd       #$000E
                    lbsr      AllocDataBlock
                    ldd       #$0000
                    std       ,u
                    std       $02,u
                    stx       $04,u
                    stu       <$16,x
                    ldd       <$1C,x
                    std       $08,u
                    ldd       $03,x
                    bita      #$01
                    beq       AllocViewEntrySize
                    deca
                    inc       $08,u
AllocViewEntrySize  subb      <$1D,x
                    incb
                    std       $06,u
                    ldd       $08,u
                    bita      #$01
                    beq       AllocViewEntryAlloc
                    inca
                    sta       $08,u
AllocViewEntryAlloc mul
                    tfr       u,x
                    lbsr      AllocHeap
                    lbsr      CalcPriCoord
                    std       $0C,x
                    stu       $0A,x
                    tfr       x,u
                    rts
state_name_auto     fdb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0
StrSaveGameMsg      fcc       /About to save the game/
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
StrDirFullMsg       fcc       /The directory/
                    fcb       $0a
                    fcc       /%s/
                    fcb       $0a
                    fcc       /is full./
                    fcb       $0a
                    fcc       /Press ENTER to continue./
                    fcb       0
StrDiskFullMsg      fcc       /The disk is full./
                    fcb       $0a
                    fcc       /Press ENTER to continue./
                    fcb       0
SaveFileHandle      fcb       0
cmd_set_simple      lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #$251
                    leax      d,x
                    leau      >state_name_auto,pcr
                    ldd       #$001F
                    lbsr      MemCopyNull
                    rts

cmd_save_game       leas      >-$00FE,s
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
SaveGameLoop        lbsr      StateGetInfo
                    leas      $02,s
                    tsta
                    lbeq      SaveGameDone
SaveGameCheck       lda       >state_name_auto,pcr
                    bne       SaveGameCreateFile
SaveGameShowMsg     leau      >StrContinueCancel,pcr
                    pshs      u
                    leau      >DataSaveGameBuf2,pcr
                    pshs      u
                    leau      >DataSaveGameBuf,pcr
                    pshs      u
                    leax      >StrSaveGameMsg,pcr
                    leau      $0A,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $0A,s
                    ldd       #$0000
                    pshs      b,a
                    ldd       #$0023
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      u
                    lbsr      message_box_draw
                    leas      $08,s
                    lbsr      BooleanPoll
                    cmpa      #$00
                    lbeq      SaveGameDone
SaveGameCreateFile  lda       #$02
                    ldb       #$03
                    leax      >DataSaveGameBuf2,pcr
                    lbsr      CreateFile
                    bcc       SaveGameWriteData
                    leau      >SaveDiskNameBuf,pcr
                    pshs      u
                    leax      >StrDirFullMsg,pcr
                    leau      $06,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $06,s
                    lbsr      message_box
                    lbra      SaveGameDone
SaveGameWriteData   sta       >SaveFileHandle,pcr
                    leax      >DataSaveGameBuf,pcr
                    ldy       #$001F
                    lbsr      WriteFile
                    cmpd      #$001F
                    bne       SaveGameWriteErr
                    ldd       #$0385
                    pshs      b,a
                    ldd       #$01AC
                    pshs      b,a
                    lbsr      SaveWriteBlock
                    leas      $04,s
                    beq       SaveGameWriteErr
                    ldd       <$0034
                    pshs      b,a
                    ldd       <$0030
                    pshs      b,a
                    lbsr      SaveWriteBlock
                    leas      $04,s
                    beq       SaveGameWriteErr
                    inc       $02,s
                    ldx       <$0038
                    ldd       <$003A
                    leau      d,x
                    lbsr      XorDecrypt
                    ldd       <$003A
                    pshs      b,a
                    ldd       <$0038
                    pshs      b,a
                    lbsr      SaveWriteBlock
                    leas      $04,s
                    beq       SaveGameWriteErr
                    lda       >$0245
                    ldb       #$02
                    mul
                    pshs      b,a
                    ldd       >$05AF
                    pshs      b,a
                    lbsr      SaveWriteBlock
                    leas      $04,s
                    beq       SaveGameWriteErr
                    lbsr      BuildLogicList
                    pshs      x
                    ldd       #$0554
                    pshs      b,a
                    lbsr      SaveWriteBlock
                    leas      $04,s
                    bne       SaveGameWriteOk
SaveGameWriteErr    lda       >SaveFileHandle,pcr
                    lbsr      CloseFilePath
                    leax      >DataSaveGameBuf2,pcr
                    lbsr      DeleteFile
                    leau      >StrDiskFullMsg,pcr
                    lbsr      message_box
                    bra       SaveGameDone
SaveGameWriteOk     lda       >SaveFileHandle,pcr
                    lbsr      CloseFilePath
SaveGameDone        lda       $02,s
                    beq       SaveGameXorDone
                    ldx       <$0038
                    ldd       <$003A
                    leau      d,x
                    lbsr      XorDecrypt
SaveGameXorDone     lbsr      cmd_close_window
                    lda       $03,s
                    sta       >$0101
                    clr       >$0102
                    ldy       ,s
                    leas      >$00FE,s
                    rts

SaveWriteBlock      lda       >SaveFileHandle,pcr
                    leax      $04,s
                    ldy       #$0002
                    lbsr      WriteFile
                    cmpd      #$0002
                    bne       SaveWriteBlockFail
                    lda       >SaveFileHandle,pcr
                    ldx       $02,s
                    ldy       $04,s
                    lbsr      WriteFile
                    cmpd      $04,s
                    bne       SaveWriteBlockFail
                    lda       #$01
                    bra       SaveWriteBlockRet
SaveWriteBlockFail  clra
SaveWriteBlockRet   rts

SaveDriveNum        fcb       0
StrSaveFmtFile      fcc       /%s%s%ssg.%d/
                    fcb       0

BuildSaveFilePath   leas      -5,s
                    stx       ,s
                    stb       2,s
                    ldd       #0
                    std       3,s
                    leax      $1801,pcr
                    lbsr      StrLen
                    decb
                    leax      b,x
                    lda       #$2F
                    cmpa      ,-x
                    beq       BuildSaveFilePathFmt
                    sta       $03,s
BuildSaveFilePathFmt clra
                    ldb       $02,s
                    pshs      b,a
                    ldd       #$01CE
                    pshs      b,a
                    leax      $07,s
                    pshs      x
                    leax      >SaveDiskNameBuf,pcr
                    pshs      x
                    leax      >StrSaveFmtFile,pcr
                    ldu       $08,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $0C,s
                    lbsr      StrToLower
                    tfr       u,x
                    leas      $05,s
                    rts
GetDiskInfo         leas      <-$45,s
                    clr       ,s
                    leau      ,s
                    lbsr      FindCurrentDisk
                    ldx       <$47,s
                    lbsr      ChangeDir
                    bcs       GetDiskInfoFail
                    clr       <$40,s
                    leau      <$40,s
                    lbsr      GetDiskName
GetDiskInfoFound    ldb       <$43,s
                    stb       >SaveDriveNum,pcr
                    lda       #$01
                    bra       GetDiskInfoRet
GetDiskInfoFail     clra
GetDiskInfoRet      sta       <$44,s
                    leax      ,s
                    lbsr      ChangeDir
                    lda       <$44,s
                    leas      <$45,s
                    rts

ExecLogicScript     leas      -$02,s
                    ldy       <$0062
                    ldd       $04,y
                    lbsr      SetLogicPage
                    ldy       $08,y
ExecScriptLoop      ldb       ,y+
ExecScriptCheck     tstb
                    beq       ExecScriptDone
                    cmpb      #$FF
                    beq       ExecScriptIf
                    cmpb      #$FE
                    bne       ExecScriptCmd
ExecScriptJump      ldb       ,y+
                    lda       ,y+
                    leay      d,y
                    bra       ExecScriptLoop
ExecScriptCmd       lbsr      DispatchCmd
                    leay      ,y
                    bne       ExecScriptCheck
ExecScriptDone      bra       ExecLogicScriptRet
ExecScriptIf        ldd       #$0000
                    std       ,s
ExecScriptIfLoop    lda       ,y+
                    cmpa      #$FC
                    bhi       ExecScriptIfHi
                    bne       ExecScriptEvalExpr
                    lda       ,s
                    bne       ExecScriptSkipBlock
                    inc       ,s
                    bra       ExecScriptIfLoop
ExecScriptIfHi      cmpa      #$FF
                    bne       ExecScriptIfFD
                    leay      $02,y
                    bra       ExecScriptLoop
ExecScriptIfFD      cmpa      #$FD
                    bne       ExecScriptEvalExpr
                    lda       $01,s
                    eora      #$01
                    sta       $01,s
                    bra       ExecScriptIfLoop
ExecScriptEvalExpr  lbsr      EvalExpr
                    eora      $01,s
                    clr       $01,s
                    tsta
                    bne       ExecScriptTrueBlock
                    lda       ,s
                    bne       ExecScriptIfLoop
ExecScriptSkipBlock clr       ,s
ExecScriptSkipLoop  lda       ,y+
                    cmpa      #$FF
                    beq       ExecScriptJump
                    cmpa      #$FC
                    bcc       ExecScriptSkipLoop
                    bsr       ExecScriptExecCmd
                    bra       ExecScriptSkipLoop
ExecScriptTrueBlock lda       ,s
                    beq       ExecScriptIfLoop
                    clr       ,s
ExecScriptTrueLoop  lda       ,y+
                    cmpa      #$FC
                    bhi       ExecScriptTrueLoop
                    beq       ExecScriptIfLoop
                    bsr       ExecScriptExecCmd
                    bra       ExecScriptTrueLoop
ExecScriptExecCmd   cmpa      #$0E
                    bne       ExecScriptExecCmdImpl
                    lda       ,y+
                    lsla
                    leay      a,y
                    rts

ExecScriptExecCmdImpl lsla
                    lsla
                    adda      #$02
                    leax      >eval_table,pcr
                    lda       a,x
                    leay      a,y
                    rts
ExecLogicScriptRet  leas      $02,s
                    rts

PaletteData         fcb       $00                 composite
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

cmd_text_screen     lbsr      InputEditOn
                    lda       #1
                    sta       $5EC
                    lda       #$15
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    rts

cmd_graphics        lbsr      InputEditOn
                    lbsr      SetGraphicsMode
                    rts

cmd_clear_lines     ldb       $02,y
                    pshs      b,a
                    ldb       $01,y
                    pshs      b,a
                    ldb       ,y
                    pshs      b,a
                    lbsr      ClearTextRows
                    leas      $06,s
                    leay      $03,y
                    rts

* clear text rect (fixed)
cmd_clear_text_rect ldb       $04,y
                    pshs      b,a
                    ldb       $03,y
                    lda       $02,y
                    pshs      b,a
                    ldb       $01,y
                    lda       ,y
                    pshs      b,a
                    lbsr      ClearTextRect
                    leas      $06,s
                    leay      $05,y
                    rts

                    fcb       0,0,0,0             * to keep same code length

cmd_set_text_attribute ldd    ,y++
                    bsr       text_color
                    rts

text_color          anda      #$0F
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

SetGraphicsMode     lda       #$00
                    sta       >$05EC
                    lda       #$09
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    lbsr      StatusLineWrite
                    lbsr      InputRedraw
                    rts

cmd_config_screen   lda       ,y
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

cmd_toggle_monitor  leas      -$04,s
                    pshs      y
                    leax      >PaletteData,pcr
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
PaletteWriteLoop    ldb       ,x+
                    stb       $05,s
                    pshs      x
                    lda       #$01
                    leax      $04,s
                    os9       I$Write
                    bcs       PaletteWriteRet
                    puls      x
                    inc       $04,s
                    lda       $04,s
                    cmpa      #$10
                    bcs       PaletteWriteLoop
PaletteWriteRet     puls      y
                    leas      $04,s
                    rts

PushTextColor       ldb       >$0171
                    cmpb      #$05
                    bcc       PushTextColorRet
                    ldx       #$015C
                    lslb
                    abx
                    ldd       >$024C
                    std       ,x
                    inc       >$0171
PushTextColorRet    rts

PopTextColor        ldb       >$0171
                    ble       PopTextColorRet
                    decb
                    stb       >$0171
                    ldx       #$015C
                    lslb
                    ldd       b,x
                    std       >$024C
PopTextColorRet     rts

ScriptWritePtr      fdb       0
ScriptReadPtr       fdb       0

InitScriptBuf       ldu       >$05AF
                    bne       InitScriptBufRet
                    lda       >$0245
                    beq       InitScriptBufRet
                    ldb       #$02
                    mul
                    lbsr      AllocDataBlock
                    stu       >$05AF
                    ldd       <$0055
                    std       <$0053
InitScriptBufRet    stu       >ScriptWritePtr,pcr
                    clr       >$0244
                    rts

PushScript          leas      -$02,s
                    std       ,s
                    lda       >$01AE
                    anda      #$01
                    bne       PushScriptRet
                    lda       >$05B1
                    beq       PushScriptUpdate
                    clra
                    ldb       >$0245
                    lslb
                    rola
                    addd      >$05AF
                    cmpd      >ScriptWritePtr,pcr
                    bhi       PushScriptStore
                    lda       #$0B
                    ldb       <$0058
                    lbsr      ReportError
PushScriptStore     ldu       >ScriptWritePtr,pcr
                    ldd       ,s
                    std       ,u++
                    stu       >ScriptWritePtr,pcr
                    inc       >$0244
PushScriptUpdate    ldd       >ScriptWritePtr,pcr
                    subd      >$05AF
                    cmpd      <$0057
                    bls       PushScriptRet
                    std       <$0057
PushScriptRet       leas      $02,s
                    rts

ResetScriptPtrs     ldd       >$05AF
                    std       >ScriptReadPtr,pcr
                    lda       >$0244
                    ldb       #$02
                    mul
                    addd      >$05AF
                    std       >ScriptWritePtr,pcr
                    rts

PopScript           ldu       #$0000
                    ldd       >ScriptReadPtr,pcr
                    cmpd      >ScriptWritePtr,pcr
                    bcc       PopScriptRet
                    tfr       d,u
                    addd      #$0002
                    std       >ScriptReadPtr,pcr
PopScriptRet        rts

cmd_script_size     lda       ,y+
                    sta       >$0245
                    lbsr      ClearBothRanges
                    lbsr      InitScriptBuf
                    lbsr      SwapObjRanges
                    rts
cmd_push_script     lda       >$0244
                    sta       >$0243
                    rts

cmd_pop_script      clra
                    ldb       >$0243
                    stb       >$0244
                    lslb
                    rola
                    addd      >$05AF
                    std       >ScriptWritePtr,pcr
                    rts

PutCharToWindow     leas      -$02,s
                    pshs      u,x
                    leau      $04,s
                    tsta
                    beq       PutCharRet
                    cmpa      #$08
                    bne       PutCharCheckCR
                    dec       <$0041
                    bpl       PutCharBackspace
                    lda       #$00
                    sta       <$0041
                    lda       <$0040
                    cmpa      #$15
                    bls       PutCharBackspace
                    deca
                    sta       <$0040
                    lda       #$27
                    sta       <$0041
PutCharBackspace    ldd       #$2000
                    std       ,u
                    pshs      u
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    dec       <$0041
                    bra       PutCharRet
PutCharCheckCR      cmpa      #$0D
                    beq       PutCharNewLine
                    cmpa      #$0A
                    bne       PutCharNormal
PutCharNewLine      lda       <$0040
                    cmpa      #$17
                    bcc       PutCharSetCol
                    inca
                    sta       <$0040
PutCharSetCol       lda       >$017A
                    sta       <$0041
                    bra       PutCharRet
PutCharNormal       clrb
                    cmpa      #$7F
                    bls       PutCharWriteScr
                    ldd       #$2000
PutCharWriteScr     std       ,u
                    pshs      u
                    lda       #$0F
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $02,s
                    lda       <$0041
                    cmpa      #$27
                    bls       PutCharRet
                    lda       #$0D
                    bsr       PutCharToWindow
PutCharRet          puls      u,x
                    leas      $02,s
                    rts

PushRowCol          ldb       >$0166
                    cmpb      #$05
                    bcc       PushRowColRet
                    ldx       #$0167
                    lslb
                    abx
                    ldd       <$0040
                    std       ,x
                    inc       >$0166
PushRowColRet       rts

PopRowCol           ldb       >$0166
                    ble       PopRowColRet
                    decb
                    stb       >$0166
                    ldx       #$0167
                    lslb
                    ldd       b,x
                    std       <$0040
PopRowColRet        rts

ClearTextLine       pshs      b,a
                    tfr       a,b
                    pshs      b,a
                    pshs      b,a
                    lbsr      ClearTextRows
                    leas      $06,s
                    rts

ClearTextRows               ldb       $07,s
                    pshs      b,a
                    lda       $07,s
                    ldb       #$27
                    pshs      b,a
                    lda       $07,s
                    ldb       #$00
                    pshs      b,a
                    lbsr      ClearTextRect
                    leas      $06,s
                    rts

DrawTextRect        leas      <-$2A,s
                    lda       #$17
                    cmpa      <$2D,s
                    lbcs      DrawTextRectRet
                    cmpa      <$2F,s
                    bcc       DrawTextRectClipRow
                    sta       <$2F,s
                    inca
                    suba      <$2D,s
                    cmpa      <$37,s
                    bcc       DrawTextRectClipRow
                    sta       <$37,s
DrawTextRectClipRow ldb       <$37,s
                    beq       DrawTextRectDoRows
                    negb
                    incb
                    addb      <$2F,s
                    subb      <$2D,s
                    bhi       DrawTextRectFill
                    clr       <$37,s
                    bra       DrawTextRectDoRows
DrawTextRectFill    lda       <$37,s
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
DrawTextRectDoRows  lda       <$35,s
                    inca
                    suba      <$33,s
                    leau      ,s
                    ldb       #$20
DrawTextRectFillLoop stb       ,u+
                    deca
                    bne       DrawTextRectFillLoop
                    sta       ,u
                    ldd       >$024C
                    pshs      b,a
                    ldb       <$33,s
                    lbsr      text_color
                    lda       <$39,s
                    bne       DrawTextRectRowNext
                    lda       <$2F,s
                    sta       <$0040
                    nega
                    adda      <$31,s
                    inca
                    sta       <$39,s
                    bra       DrawTextRectWriteRow
DrawTextRectRowNext nega
                    adda      <$31,s
                    inca
                    sta       <$0040
DrawTextRectWriteRow lda      <$35,s
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
                    bne       DrawTextRectWriteRow
                    puls      b,a
                    std       >$024C
DrawTextRectRet     leas      <$2A,s
                    rts

ClearTextRect       ldd       <$0040
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
                    lbsr      DrawTextRect
                    leas      $0C,s
                    puls      b,a
                    std       <$0040
                    rts
StrInsertDiskMsg    fcc       /Please insert disk %d, side %d/
                    fcb       $0a
                    fcc       /and press ENTER./
                    fcb       0
StrTurnOverDisk     fcc       /Please turn over the disk/
                    fcb       $0a
                    fcc       /and press ENTER./
                    fcb       0
StrWrongDisk        fcc       /That is the wrong disk./
                    fcb       $0a,$0a,0
StrVolumeFmt        fcc       /%s%s/
                    fcb       $0a
                    fcc       /%s/
                    fcb       0
StrVolumeName       fcc       /vol.%d/
                    fcb       0
StrCantFindVol      fcc       /Can't find %s.%s%s/
                    fcb       0
VolMaxDisk          fcb       1
VolCurDisk          fcb       1
VolCurSide          fcb       1
VolWrongDisk        fcb       0
VolDiskInfoPtr      fcb       0
VolDriveFlag        fcb       0
VolFileIdx          fcb       0

OpenVolFile         leas      -6,s
                    std       ,s
                    stu       $02,s
                    stx       $04,s
OpenVolFileLoop     bsr       FindVol
                    cmpu      #$0000
OpenVolFileCheckResult bne    OpenVolFileRet
                    lda       >VolWrongDisk,pcr
                    cmpa      #$05
                    beq       OpenVolFileRet
                    ldd       ,s
OpenVolFileRetry    lbsr      SetLogicPage
                    ldu       $02,s
                    ldx       $04,s
OpenVolFileNextPage bra       OpenVolFileLoop
OpenVolFileRet      leas      $06,s
                    rts
FindVol             leas      <-$12,s
                    stu       ,s
                    stx       $02,s
                    pshs      y
                    ldu       <$004F
                    stu       $06,s
                    lda       >$0531
                    cmpa      #$FF
                    bne       FindVolGotHandle
                    ldd       >VolDiskInfoPtr,pcr
                    bne       FindVolLoadDisk
                    ldx       [>$0089]
                    stx       >VolDiskInfoPtr,pcr
                    ldd       ,x
                    cmpd      #$0101
                    beq       FindVolLoadDisk
                    clrb
                    lbsr      ShowInsertDiskMsg
FindVolLoadDisk     lbsr      ReadDiskVol
FindVolGotHandle    ldu       $02,s
                    lda       ,u
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       $08,s
                    ldx       #$0531
                    ldb       a,x
                    cmpb      #$FF
                    bne       FindVolCheckHandle
                    lbsr      VolumesClose
                    ldb       $08,s
                    beq       FindVolDefaultDisk
                    cmpb      >$05ED
                    bls       FindVolLoadDiskInfo
FindVolDefaultDisk  ldb       >VolMaxDisk,pcr
                    stb       $08,s
FindVolLoadDiskInfo decb
                    lslb
                    ldx       <$0089
                    ldx       b,x
                    stx       >VolDiskInfoPtr,pcr
                    ldd       ,x
                    cmpa      >VolCurDisk,pcr
                    bne       FindVolWrongDisk
                    cmpb      >VolCurSide,pcr
                    beq       FindVolLoadSide
FindVolWrongDisk    lda       #$01
                    sta       >VolWrongDisk,pcr
                    ldb       $08,s
                    lbsr      ShowInsertDiskMsg
FindVolLoadSide     lbsr      ReadDiskVol
                    lbra      FindVolFail
FindVolCheckHandle  stb       >VolFileIdx,pcr
                    clra
                    ldb       ,u
                    andb      #$0F
                    tfr       d,x
                    ldu       $01,u
                    lda       >VolFileIdx,pcr
                    clrb
                    lbsr      SeekFile
                    bcs       FindVolReadErr
                    lda       >VolFileIdx,pcr
                    leax      $09,s
                    ldy       #$0007
                    lbsr      ReadFile
                    bcs       FindVolReadErr
                    cmpd      #$0007
                    beq       FindVolVerifyHdr
FindVolReadErr      lbsr      ErrorDialog
                    lbne      FindVolFail
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
FindVolVerifyHdr    ldd       $09,s
                    cmpd      #$1234
                    bne       FindVolWrongSide
                    lda       $0B,s
                    anda      #$0F
                    cmpa      $08,s
                    beq       FindVolGoodHdr
FindVolWrongSide    lbsr      VolumesClose
                    lda       #$01
                    sta       >VolWrongDisk,pcr
                    ldb       $08,s
                    lbsr      ShowWrongDiskMsg
                    tsta
                    bne       FindVolRetryDisk
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
FindVolRetryDisk    lbsr      ReadDiskVol
                    lbra      FindVolFail
FindVolGoodHdr      ldb       $0C,s
                    lda       $0D,s
                    std       <$0066
                    ldb       $0E,s
                    lda       $0F,s
                    std       <$12,s
                    ldu       $04,s
                    bne       FindVolReadData
                    lda       >$05B8
                    beq       FindVolAllocMem
                    lbsr      UpdateFreeSpace
                    cmpd      <$0066
                    bcc       FindVolAllocMem
                    lda       #$05
                    sta       >VolWrongDisk,pcr
                    bra       FindVolFail
FindVolAllocMem     ldd       <$0066
                    lbsr      AllocHeap
                    lbsr      CalcPriCoord
                    stu       $04,s
                    std       <$10,s
                    lbsr      SetLogicPage
FindVolReadData     lda       $0B,s
                    anda      #$80
                    beq       FindVolDirectRead
                    ldd       <$12,s
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >VolFileIdx,pcr
                    pshs      b,a
                    lbsr      RenderPicStrip
                    leas      $06,s
                    bra       FindVolRet2
FindVolDirectRead   ldd       <$12,s
                    cmpd      <$0066
                    bne       FindVolCompressed
                    lda       #$01
                    sta       <$009E
                    lda       >VolFileIdx,pcr
                    ldx       $04,s
                    ldy       <$0066
                    lbsr      ReadFile
                    bra       FindVolRet2
FindVolCompressed   clr       <$009E
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >VolFileIdx,pcr
                    pshs      b,a
                    lbsr      PicRenderSetup
                    leas      $06,s
FindVolRet2         tst       <$009F
                    lbne      FindVolReadErr
                    ldu       $04,s
                    cmpd      <$0066
                    beq       FindVolRet
                    lbra      FindVolReadErr
FindVolFail         ldd       $06,s
                    std       <$004F
                    ldu       #$0000
FindVolRet          ldd       <$10,s
                    puls      y
                    leas      <$12,s
                    rts

ShowInsertDiskMsg   leas      <-$64,s
                    leau      ,s
                    pshs      b,a
                    pshs      u
                    lbsr      FormatInsertDiskMsg
                    leas      $04,s
                    lbsr      message_box
                    leas      <$64,s
                    rts

FormatInsertDiskMsg ldx       >VolDiskInfoPtr,pcr
                    clra
                    ldb       $05,s
                    beq       FormatInsertDiskMsgBody
                    cmpb      >$05ED
                    bhi       FormatInsertDiskMsgBody
                    stb       >VolMaxDisk,pcr
                    decb
                    lslb
                    ldx       <$0089
                    ldx       b,x
FormatInsertDiskMsgBody ldb   $01,x
                    pshs      b,a
                    ldb       ,x
                    pshs      b,a
                    leax      >StrInsertDiskMsg,pcr
                    cmpb      >VolCurDisk,pcr
                    bne       FormatInsertDiskMsgRet
                    ldb       $01,x
                    cmpb      >VolCurSide,pcr
                    beq       FormatInsertDiskMsgRet
                    leax      >StrTurnOverDisk,pcr
FormatInsertDiskMsgRet ldu    $06,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $08,s
                    rts

ShowWrongDiskMsg    leas      >-$012C,s
                    pshs      b,a
                    lbsr      RingBell
                    leau      $02,s
                    pshs      u
                    lbsr      FormatInsertDiskMsg
                    leas      $04,s
                    leau      >StrQuitMsg2,pcr
                    pshs      u
                    leau      $02,s
                    pshs      u
                    leau      >StrWrongDisk,pcr
                    pshs      u
                    leax      >StrVolumeFmt,pcr
                    leau      <$6A,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $0A,s
                    lbsr      message_box
                    leas      >$012C,s
                    rts

ReadDiskVol         leas      -$0D,s
                    ldx       >VolDiskInfoPtr,pcr
                    leax      $02,x
                    ldb       ,x
ReadDiskVolName     clra
                    stx       ,s
                    andb      #$7F
                    stb       $02,s
                    leax      >StrVolumeName,pcr
                    leau      $03,s
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $06,s
ReadDiskVolOpen     lda       #$01
                    leax      $03,s
                    lbsr      OpenFile
                    bcc       ReadDiskVolStore
                    tstb
                    bne       ReadDiskVolRetry
                    clr       >VolCurDisk,pcr
                    bra       ReadDiskVolRet
ReadDiskVolRetry    lbsr      ErrorDialog
                    cmpa      #$00
                    bne       ReadDiskVolOpen
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
ReadDiskVolStore    ldu       #$0531
                    ldb       $02,s
                    sta       b,u
                    ldx       ,s
                    ldb       ,x+
                    bmi       ReadDiskVolSetDisk
                    ldb       ,x
                    bra       ReadDiskVolName
ReadDiskVolSetDisk  ldx       >VolDiskInfoPtr,pcr
                    ldd       ,x
                    std       >VolCurDisk,pcr
ReadDiskVolRet      leas      $0D,s
                    rts

VolumesClose        leas      -$01,s
                    clrb
                    ldx       #$0531
VolumesCloseLoop    cmpb      #$0F
                    bhi       VolumesCloseDone
                    stb       ,s
                    lda       ,x
                    cmpa      #$FF
                    beq       VolumesCloseNext
                    lbsr      CloseFilePath
                    lda       #$FF
VolumesCloseNext    sta       ,x+
                    ldb       ,s
                    incb
                    bra       VolumesCloseLoop
VolumesCloseDone    leas      $01,s
                    rts

FileLoad            leas      <-$65,s
                    pshs      y
FileLoadOpen        lda       #$01
                    ldx       <$69,s
                    lbsr      OpenFile
                    bcc       FileLoadGetSize
                    lda       #$40
                    sta       >$0101
                    leau      >StrQuitMsg2,pcr
                    pshs      u
                    leau      >StrTryAgain,pcr
                    pshs      u
                    ldd       <$6D,s
                    pshs      b,a
                    leax      >StrCantFindVol,pcr
                    leau      $09,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $0A,s
                    lbsr      message_box
                    bne       FileLoadOpen
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
FileLoadGetSize     sta       $02,s
                    ldu       #$0000
                    tfr       u,x
                    ldb       #$02
                    lbsr      SeekFile
                    stu       <$0066
                    ldu       #$0000
                    clrb
                    lbsr      SeekFile
                    ldx       <$6B,s
                    bne       FileLoadRead
                    ldd       <$0066
                    ldu       <$6F,s
                    beq       FileLoadAllocData
                    lbsr      AllocHeap
                    lbsr      CalcPriCoord
                    stu       [<$6D,s]
                    std       [<$6F,s]
                    lbsr      SetLogicPage
                    bra       FileLoadSetPtr
FileLoadAllocData   lbsr      AllocDataBlock
                    stu       [<$6D,s]
FileLoadSetPtr      tfr       u,x
FileLoadRead        lda       $02,s
                    ldy       <$0066
                    lbsr      ReadFile
                    cmpd      <$0066
                    beq       FileLoadClose
                    lbsr      ErrorDialog
                    cmpb      #$00
                    bne       FileLoadClose
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
FileLoadClose       lda       $02,s
                    lbsr      CloseFilePath
                    puls      y
                    leas      <$65,s
                    rts

StrLogics               fcc       /Logics/
                    fcb       0
StrView               fcc       /View/
                    fcb       0
StrPicture          fcc       /Picture/
                    fcb       0
StrSoundName        fcc       /Sound/
                    fcb       0
StrLogDir           fcc       /logDir/
                    fcb       0
StrViewDir          fcc       /viewDir/
                    fcb       0
StrPicDir           fcc       /picDir/
                    fcb       0
StrSndDir           fcc       /sndDir/
                    fcb       0
StrResNotFound      fcc       /%s #%d not found./
                    fcb       0

LogDirPtr           fdb       0
LogDirPage          fdb       0
ViewDirPtr          fdb       0
ViewDirPage         fdb       0
PicDirPtr           fdb       0
PicDirPage          fdb       0
SndDirPtr           fdb       0
SndDirPage          fdb       0
LoadAllDirs         leau      >LogDirPage,pcr
                    pshs      u
                    leau      >LogDirPtr,pcr
                    leax      >StrLogDir,pcr
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      FileLoad
                    leas      $08,s
                    leau      >PicDirPage,pcr
                    pshs      u
                    leau      >PicDirPtr,pcr
                    leax      >StrPicDir,pcr
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      FileLoad
                    leas      $08,s
                    leau      >ViewDirPage,pcr
                    pshs      u
                    leau      >ViewDirPtr,pcr
                    leax      >StrViewDir,pcr
                    pshs      u
LoadViewDirCall     ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      FileLoad
                    leas      $08,s
LoadSndDirCall      leau      >SndDirPage,pcr
                    pshs      u
                    leau      >SndDirPtr,pcr
                    leax      >StrSndDir,pcr
                    pshs      u
                    ldd       #$0000
                    pshs      b,a
                    pshs      x
                    lbsr      FileLoad
                    leas      $08,s
                    rts

CheckResPtr               lda       ,u
                    cmpa      #$FF
                    bne       CheckResPtrRet
                    ldd       $01,u
                    cmpd      #$FFFF
                    bne       CheckResPtrRet
                    ldu       #$0000
CheckResPtrRet               rts

FetchLogic               leas      -$01,s
                    stb       ,s
                    ldd       >LogDirPage,pcr
                    lbsr      SetLogicPage
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >LogDirPtr,pcr
                    leau      d,u
                    bsr       CheckResPtr
                    bne       FetchLogicRet
                    leax      >StrLogics,pcr
                    ldb       ,s
                    lbsr      ResNotFoundErr
FetchLogicRet               ldd       >LogDirPage,pcr
                    leas      $01,s
                    rts

FetchView               leas      -$01,s
                    stb       ,s
                    ldd       >ViewDirPage,pcr
                    lbsr      SetLogicPage
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >ViewDirPtr,pcr
                    leau      d,u
                    bsr       CheckResPtr
                    bne       FetchViewRet
                    leax      >StrView,pcr
                    ldb       ,s
                    bsr       ResNotFoundErr
FetchViewRet               ldd       >ViewDirPage,pcr
                    leas      $01,s
                    rts

FetchPicture               leas      -$01,s
                    stb       ,s
                    ldd       >PicDirPage,pcr
                    lbsr      SetLogicPage
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >PicDirPtr,pcr
                    leau      d,u
                    bsr       CheckResPtr
                    bne       FetchPictureRet
                    leax      >StrPicture,pcr
                    ldb       ,s
                    bsr       ResNotFoundErr
FetchPictureRet               ldd       >PicDirPage,pcr
                    leas      $01,s
                    rts

FetchSound               leas      -$01,s
                    stb       ,s
                    ldd       >SndDirPage,pcr
                    lbsr      SetLogicPage
                    lda       ,s
                    ldb       #$03
                    mul
                    ldu       >SndDirPtr,pcr
                    leau      d,u
                    lbsr      CheckResPtr
                    bne       FetchSoundRet
                    leax      >StrSoundName,pcr
                    ldb       ,s
                    bsr       ResNotFoundErr
FetchSoundRet               ldd       >SndDirPage,pcr
                    leas      $01,s
                    rts

ResNotFoundErr      leas      <-$64,s
                    clra
                    pshs      b,a
                    pshs      x
                    leax      >StrResNotFound,pcr
                    leau      $04,s
                    pshs      x
                    pshs      u
                    lbsr      PrintFmtStr
                    leas      $08,s
                    lbsr      message_box
                    lda       #$03
                    sta       <$0009
                    ldx       <$0022
                    jsr       >$0701
                    leas      <$64,s
                    rts

SoundScratchBuf               fcb       0,0
                    fcb       0,0

GetStackFrame               leau      >GetStackFrame,pcr
                    ldd       ,s
                    pshu      s,b,a
                    rts
RestoreStackFrame               leau      >SoundScratchBuf,pcr
                    pulu      s,b,a
                    std       ,s
                    rts

StrNotNow               fcc       /Not now./
                    fcb       0

cmd_show_obj_v               ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    bsr       obj_show
                    rts

cmd_show_obj               ldb       ,y+
                    bsr       obj_show
                    rts
obj_show               leas      <-$36,s
                    stb       $02,s
                    clra
                    sta       >$05B1
                    sta       $04,s
                    sta       $03,s
                    lbsr      view_find
                    leax      ,x
                    beq       ObjShowLoadView
                    stx       $05,s
                    inc       $04,s
                    bra       ObjShowSetup
ObjShowLoadView               lda       #$01
                    sta       >$05B8
                    clra
                    ldb       $02,s
                    lbsr      view_load
                    clr       >$05B8
                    stu       $05,s
                    bne       ObjShowSetup
                    leau      >StrNotNow,pcr
                    lbsr      message_box
                    lbra      ObjShowDone
ObjShowSetup               ldd       <$000A
                    std       <$34,s
                    ldu       $05,s
                    ldd       $05,u
                    leau      $07,s
                    std       $08,u
                    clra
                    sta       $0A,u
                    sta       $0E,u
                    ldb       $02,s
                    lbsr      SetViewForObj
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
                    lbsr      UpdateFreeSpace
                    cmpd      <$32,s
                    bcs       ObjShowDisplay
                    inc       $03,s
                    tfr       u,x
                    lbsr      AllocViewEntry
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
ObjShowDisplay               ldu       $05,s
                    ldu       $03,u
                    ldb       $03,u
                    lda       $04,u
                    leau      d,u
                    lbsr      message_box
                    lda       $03,s
                    beq       ObjShowRestore
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
                    lbsr      CalcPriAddr
                    stu       <$004F
                    stx       <$0055
ObjShowRestore               ldd       <$34,s
                    lbsr      SetLogicPage
                    lda       $04,s
                    bne       ObjShowDone
                    ldb       $02,s
                    lbsr      DiscardViewHelper
ObjShowDone               lda       #$01
                    sta       >$05B1
                    leas      <$36,s
                    rts

SoundScratch9               fcb       0,0,0,0,0,0,0,0,0
SoundListPtr               fcb       0,0
SoundPIA1Ctrl               fcb       0
SoundPIA2Ctrl               fcb       0
SoundEnableReg               fcb       0

NoteFreqTable               fcb       $07,$78
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

MonthDayTable               fcb       0
                    fcb       $1f,$1c
                    fcb       $1f,$1e
                    fcb       $1f,$1e
                    fcb       $1f,$1f
                    fcb       $1e,$1f
                    fcb       $1e,$1f

SoundListClear               leau      SoundScratch9,pcr
                    ldd       #0
                    std       ,u
                    rts

SoundListFind               leau      >SoundScratch9,pcr
SoundListFindLoop               stu       >SoundListPtr,pcr
                    ldu       ,u
                    beq       SoundListFindRet
                    cmpb      $02,u
                    bne       SoundListFindLoop
SoundListFindRet               rts

cmd_load_sound               ldb       ,y+
                    bsr       LoadSoundData
                    rts

LoadSoundData               leas      -$05,s
                    stb       ,s
                    bsr       SoundListFind
                    cmpu      #$0000
                    bne       LoadSoundRet
                    ldd       <$000A
                    std       $03,s
                    lbsr      ClearBothRanges
                    lda       #$03
                    ldb       ,s
                    lbsr      PushScript
                    leau      >SoundScratch9,pcr
                    ldx       >SoundListPtr,pcr
                    beq       LoadSoundAlloc
                    ldd       #$0009
                    lbsr      AllocDataBlock
                    stu       ,x
                    ldd       #$0000
                    std       ,u
LoadSoundAlloc               ldb       ,s
                    stb       $02,u
                    stu       $01,s
                    lbsr      FetchSound
                    ldx       #$0000
                    lbsr      OpenVolFile
                    beq       LoadSoundDone
                    ldx       $01,s
                    std       $05,x
                    stu       $03,x
                    std       $07,x
LoadSoundDone               lbsr      SwapObjRanges
                    ldd       $03,s
                    lbsr      SetLogicPage
                    ldu       $01,s
LoadSoundRet               leas      $05,s
                    rts

cmd_sound               leas      -$0B,s
                    ldb       ,y+
                    stb       ,s
                    lbsr      SoundListFind
                    cmpu      #$0000
                    bne       SoundCheckFlags
                    lda       #$09
                    ldb       ,s
                    lbsr      ReportError
SoundCheckFlags               lda       >$01AF
                    anda      #$40
                    lbeq      SoundSetFlagDone
                    lda       >$0172
                    lbne      SoundSetFlagDone
                    ldd       <$000A
                    std       $03,s
                    stu       $01,s
                    ldd       $05,u
                    lbsr      SetLogicPage
                    leax      $05,s
                    os9       F$Time
                    ldu       $01,s
                    lbsr      PlaySound
                    cmpd      #$0000
                    lbeq      TimeRestorePage
                    pshs      b,a
                    addb      $0C,s
                    bcc       TimeSecCarry
                    inca
TimeSecCarry               ldu       #$003C
                    lbsr      UIntDivide
                    stb       $0C,s
                    tfr       u,d
                    cmpd      #$0000
                    beq       TimeSetSys
                    addb      $0B,s
                    bcc       TimeMinCarry
                    inca
TimeMinCarry               ldu       #$003C
                    lbsr      UIntDivide
                    stb       $0B,s
                    tfr       u,d
                    tstb
                    beq       TimeSetSys
                    addb      $0A,s
                    lda       #$17
                    lbsr      Div8
                    sta       $0A,s
                    tstb
                    beq       TimeSetSys
                    inc       $09,s
                    ldd       $08,s
                    leax      >MonthDayTable,pcr
                    cmpb      a,x
                    bls       TimeSetSys
                    ldb       a,x
                    cmpa      #$02
                    bne       TimeDayIncr
                    ldb       $07,s
                    beq       TimeDayIncr
                    bitb      #$03
                    bne       TimeDayIncr
                    ldb       $09,s
                    cmpb      #$1D
                    beq       TimeSetSys
TimeDayIncr               ldb       #$01
                    stb       $09,s
                    inca
                    cmpa      #$0C
                    bls       TimeMonthAdv
                    stb       $08,s
                    inc       $07,s
                    bra       TimeSetSys
TimeMonthAdv               sta       $08,s
TimeSetSys               leax      $07,s
                    os9       F$STime
                    puls      b,a
                    addb      >$043C
                    bcc       TimeSec2Carry
                    inca
TimeSec2Carry               ldu       #$003C
                    lbsr      UIntDivide
                    stb       >$043C
                    tfr       u,d
                    cmpd      #$0000
                    beq       TimeRestorePage
                    addb      >$043D
                    bcc       TimeMin2Carry
                    inca
TimeMin2Carry               ldu       #$003C
                    lbsr      UIntDivide
                    stb       >$043D
                    tfr       u,d
                    tstb
                    beq       TimeRestorePage
                    addb      >$043E
                    lda       #$17
                    lbsr      Div8
                    sta       >$043E
                    tstb
                    beq       TimeRestorePage
                    inc       >$043F
TimeRestorePage               ldd       $03,s
                    lbsr      SetLogicPage
SoundSetFlagDone               lda       ,y+
                    lbsr      SetFlag
                    leas      $0B,s
                    rts

PlaySound               pshs      y
                    clrb
                    ldu       $03,u
                    bsr       SoundPIASave
PlaySoundLoop               ldb       ,u+
                    cmpb      #$FF
                    beq       PlaySoundEnd
                    lslb
                    lda       ,u+
                    ora       #2
                    sta       >$FF20
                    ldy       ,u++
                    leax      >NoteFreqTable,pcr
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
                    beq       PlaySoundWaveLow
PlaySoundWaveHigh               ldx       <$0090
PlaySoundHighLoop               ldd       <$008E
PlaySoundHighDelay               subd      #$0001
                    bne       PlaySoundHighDelay
*         com   $FF20
                    lda       $ff20               patch RG
                    coma
                    ora       #2
                    sta       $ff20
                    leax      -1,x
                    bne       PlaySoundHighLoop
                    leay      -$01,y
                    bne       PlaySoundWaveHigh
                    bra       PlaySoundLoop
PlaySoundWaveLow               ldx       <$0090
PlaySoundLowLoop               ldd       <$008E
PlaySoundLowDelay               subd      #$0001
                    bne       PlaySoundLowDelay
* This is a meaningless test and must be here to balance cycles. RG
                    tst       >$FF20
                    leax      -$01,x
                    bne       PlaySoundLowLoop
                    leay      -$01,y
                    bne       PlaySoundWaveLow
                    bra       PlaySoundLoop
PlaySoundEnd               bsr       SoundPIARestore
                    ldd       ,u
                    puls      y
                    rts

*Sound on
* RS-232 toggle change. RG

SoundPIASave               orcc      #IntMasks
*        clr   $FF20		this would trash the RS-232 line while zeroing the DAC
                    lda       #2                  patch RG
                    sta       $ff20
                    lda       >$FF01              save PIA setting
                    sta       >SoundPIA1Ctrl,pcr
                    anda      #$F7                set MUX to 0
                    sta       >$FF01
                    lda       >$FF03              save PIA setting
                    sta       >SoundPIA2Ctrl,pcr
                    anda      #$F7                set MUX to 0
                    sta       >$FF03              DAC now selected
                    lda       >$FF23              save Sound setting
                    sta       >SoundEnableReg,pcr
                    ora       #$08                turn sound on
                    sta       >$FF23
                    rts

*Sound off
* RS-232 toggle change. RG
SoundPIARestore               lda       >SoundPIA1Ctrl,pcr          get saved PIA HSYNC setting
                    sta       >$FF01              restore it
                    lda       >SoundPIA2Ctrl,pcr          get saved PIA VSYNC setting
                    sta       >$FF03              restore it
                    lda       >SoundEnableReg,pcr          get Sound setting (presumably off)
                    sta       >$FF23              restore it
                    lda       #2                  patch RG
                    sta       $FF20
                    lda       $FF02
                    lda       $FF22
                    andcc     #$AF
                    rts

StrNothing               fcc       /nothing/
                    fcb       0
StrYouAreCarrying               fcc       /You are carrying:/
                    fcb       0
StrEnterToSelect               fcc       'ENTER to select / CTRL-BREAK to cancel'
                    fcb       0
StrPressKeyReturn               fcc       /Press a key to return to the game/
                    fcb       0
StrScoreFmt               fcc       /Score:%d of %d  /
                    fcb       0
StrSoundFmt               fcc       /Sound: %s/
                    fcb       0
                    fcb       0,0,0
StrOn               fcc       /on /
                    fcb       0

StrOff               fcc       /off/
                    fcb       0

cmd_status               lbsr      InputEditOn
                    lbsr      PushTextColor
                    clra
                    ldb       #$0F
                    lbsr      text_color
CmdStatusTextMode               lbsr      cmd_text_screen
                    bsr       InventoryDraw
                    lbsr      PopTextColor
                    lbsr      SetGraphicsMode
                    rts

InventoryDraw               leas      >-$0105,s
                    lda       #$02
                    sta       ,s
InventoryDrawInit               leax      $04,s
                    stx       $02,s
                    stx       >$00FE,s
                    ldu       <$0038
                    clra
                    sta       $01,s
InventoryItemLoop               sta       >$0100,s
                    stu       >$0101,s
                    cmpu      <$003C
                    bcc       InventoryCheckEmpty
                    ldb       $02,u
                    cmpb      #$FF
                    bne       InventoryItemAdvance
                    sta       ,x
                    cmpa      >$044A
                    bne       InventoryItemSetup
                    stx       >$00FE,s
InventoryItemSetup               ldd       ,u
                    std       $01,x
                    lda       ,s
                    sta       $03,x
                    ldb       $01,s
                    bitb      #$01
                    bne       InventoryItemFormat
                    lda       #$01
                    sta       $04,x
                    bra       InventoryItemNext
InventoryItemFormat               inca
                    sta       ,s
                    stx       $02,s
                    ldx       $01,x
                    lbsr      StrLen
                    ldx       $02,s
                    negb
                    addb      #$27
                    stb       $04,x
                    ldb       $01,s
InventoryItemNext               incb
                    stb       $01,s
                    leax      $05,x
InventoryItemAdvance               leau      $03,u
                    lda       >$0100,s
                    inca
                    bra       InventoryItemLoop
InventoryCheckEmpty               lda       $01,s
                    bne       InventoryDisplayItems
                    sta       ,x
                    leau      >StrNothing,pcr
                    stu       $01,x
                    lda       ,s
                    sta       $03,x
                    lda       #$10
                    sta       $04,x
                    leax      $05,x
InventoryDisplayItems               leax      -$05,x
                    stx       >$0103,s
                    pshs      x
                    leax      $06,s
                    pshs      x
                    ldx       >$0102,s
                    stx       $06,s
                    pshs      x
                    lbsr      InventoryListDraw
                    leas      $06,s
InventoryWaitKey               lbsr      WaitForEvent
                    lda       >$01AF
                    anda      #$04
                    beq       InventoryExit
                    ldd       ,x
                    cmpa      #$01
                    bne       InventoryCheckJoy
                    cmpb      #$0D
                    bne       InventoryCheckEsc
                    ldx       $02,s
                    lda       ,x
                    sta       >$044A
                    bra       InventoryExit
InventoryCheckEsc               cmpb      #$1B
                    bne       InventoryWaitKey
                    lda       #$FF
                    sta       >$044A
                    bra       InventoryExit
InventoryCheckJoy               cmpa      #$02
                    bne       InventoryWaitKey
                    leax      $04,s
                    pshs      x
                    pshs      b,a
                    ldd       $06,s
                    pshs      b,a
                    ldd       >$0109,s
                    pshs      b,a
                    lbsr      InventoryMoveCursor
                    leas      $08,s
                    stx       $02,s
                    bra       InventoryWaitKey
InventoryExit               clra
                    sta       >$0154
                    sta       >$0547
                    leas      >$0105,s
                    rts

InventoryListDraw               leas      -$04,s
                    lda       #$00
                    ldb       #$0B
                    std       <$0040
                    leau      >StrYouAreCarrying,pcr
                    pshs      u
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    ldx       $08,s
InventoryListLoop               stx       ,s
                    cmpx      $0A,s
                    bhi       InventoryListDone
                    ldd       $03,x
                    std       <$0040
                    clra
                    ldb       #$0F
                    std       $02,s
                    cmpx      $06,s
                    bne       InventoryListHighlight
                    lda       >$01AF
                    anda      #$04
                    beq       InventoryListHighlight
                    lda       #$0F
                    clrb
                    std       $02,s
InventoryListHighlight               ldd       $02,s
                    lbsr      text_color
                    ldx       ,s
                    ldx       $01,x
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    ldx       ,s
                    leax      $05,x
                    bra       InventoryListLoop
InventoryListDone               clra
                    ldb       #$0F
                    lbsr      text_color
                    lda       >$01AF
                    anda      #$04
                    beq       InventoryListFooter
                    lda       #$01
                    sta       >$0154
                    lda       #$03
                    sta       >$0547
                    lda       #$17
                    ldb       #$01
                    std       <$0040
                    leax      >StrEnterToSelect,pcr
                    bra       InventoryListFooterPrint
InventoryListFooter               lda       #$17
                    ldb       #$04
                    std       <$0040
                    leax      >StrPressKeyReturn,pcr
InventoryListFooterPrint               pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    leas      $04,s
                    rts

InventoryMoveCursor               ldu       $04,s
                    tfr       u,x
                    lda       $07,s
                    cmpa      #$01
                    bne       InventoryMoveDown
                    leax      -$0A,x
                    bra       InventoryMoveCheck
InventoryMoveDown               cmpa      #$03
                    bne       InventoryMovePageDown
                    leax      $05,x
                    bra       InventoryMoveCheck
InventoryMovePageDown               cmpa      #$05
                    bne       InventoryMovePageUp
                    leax      $0A,x
                    bra       InventoryMoveCheck
InventoryMovePageUp               cmpa      #$07
                    bne       InventoryMoveRet
                    leax      -$05,x
InventoryMoveCheck               cmpx      $08,s
                    bcs       InventoryMoveClamp
                    cmpx      $02,s
                    bls       InventoryMoveSwap
InventoryMoveClamp               tfr       u,x
                    bra       InventoryMoveRet
InventoryMoveSwap               pshs      x
                    pshs      u
                    lbsr      InventorySwapHighlight
                    leas      $04,s
InventoryMoveRet               rts

InventorySwapHighlight               lda       #$0F
                    clrb
                    lbsr      text_color
                    ldu       $04,s
                    ldd       $03,u
                    std       <$0040
                    ldd       $01,u
                    pshs      b,a
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    clra
                    ldb       #$0F
                    lbsr      text_color
                    ldu       $02,s
                    ldd       $03,u
                    std       <$0040
                    ldd       $01,u
                    pshs      b,a
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    ldx       $04,s
                    rts

StatusLineWrite               lda       >$0246
                    beq       StatusLineWriteRet
                    lbsr      PushRowCol
                    lbsr      PushTextColor
                    lda       >$0247
                    ldb       #$0F
                    lbsr      ClearTextLine
                    clra
                    ldb       #$0F
                    lbsr      text_color
                    lda       >$0247
                    ldb       #$01
                    std       <$0040
                    clra
                    ldb       >$0438
                    pshs      b,a
                    ldb       >$0434
                    leax      >StrScoreFmt,pcr
                    pshs      b,a
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $06,s
                    ldb       #$1E
                    stb       <$0041
                    leau      >StrOff,pcr
                    lda       >$01AF
                    anda      #$40
                    beq       StatusLineSoundLabel
                    lda       >$0172
                    bne       StatusLineSoundLabel
                    leau      >StrOn,pcr
StatusLineSoundLabel               leax      >StrSoundFmt,pcr
                    pshs      u
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $04,s
                    lbsr      PopTextColor
                    lbsr      PopRowCol
StatusLineWriteRet               rts

cmd_status_line_on               lda       #$01
                    sta       >$0246
                    bsr       StatusLineWrite
                    rts

cmd_status_line_off               clr       >$0246
                    lda       >$0247
                    clrb
                    lbsr      ClearTextLine
                    rts

StrPunctuation               fcc       / .,;:'!-/
                    fcb       0

cmd_get_string               leas      >-$0197,s
                    lda       >$05B9
                    sta       ,s
                    lbsr      PushRowCol
                    lbsr      InputEditOn
                    lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #$0251
                    leax      d,x
                    stx       $01,s
                    lda       ,y+
                    sta       $05,s
GetStringReadArgs               ldd       ,y++
                    std       $03,s
                    lda       ,y+
                    inca
                    cmpa      #$28
                    bls       GetStringMaxLen
                    lda       #$28
GetStringMaxLen               sta       >$0196,s
                    clr       ,x
                    ldd       $03,s
                    cmpa      #$18
GetStringCheckRow               bcc       GetStringShowMsg
                    std       <$0040
GetStringShowMsg               ldb       $05,s
                    lbsr      GetMsgPtr
                    leax      $06,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      u
                    pshs      x
                    lbsr      MsgTextSetup
                    leas      $06,s
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    ldb       >$0196,s
                    ldx       $01,s
                    bsr       EditString
                    lbsr      PopRowCol
                    lda       ,s
                    beq       GetStringDone
                    lbsr      InputCursorBlink
GetStringDone               leas      >$0197,s
                    rts

cmd_set_string               lda       ,y+
                    ldb       #$28
                    mul
                    ldx       #$0251
                    leax      d,x
                    ldb       ,y+
                    lbsr      GetMsgPtr
                    exg       u,x
                    ldd       #$0028
                    lbsr      MemCopyNull
                    rts

cmd_word_to_string               lda       ,y+
                    ldb       #$28
                    mul
                    ldu       #$0251
                    leau      d,u
                    ldb       ,y+
                    lslb
                    ldx       #$0180
                    ldx       b,x
                    ldd       #$0028
                    lbsr      MemCopyNull
                    rts

EditString               leas      <-$2F,s
                    stx       ,s
                    cmpb      #$28
                    bls       EditStringInit
                    ldb       #$28
EditStringInit               leax      $06,s
                    abx
                    stx       $04,s
                    clra
                    ldx       ,s
                    leau      $07,s
                    lbsr      MemCopyNull
                    lbsr      StrLen
                    beq       EditStringCalcPos
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    leax      $07,s
                    lbsr      StrLen
                    abx
EditStringCalcPos               stx       $02,s
                    lbsr      InputCursorBlink
EditStringWait               lbsr      WaitKeyNonNull
                    sta       $06,s
                    lbsr      InputEditOn
                    lda       $06,s
                    cmpa      #$08
                    bne       EditStringCtrlC
EditStringBackspace               leau      $07,s
                    cmpu      $02,s
                    bcc       EditStringContinue
                    ldu       $02,s
                    leau      -$01,u
                    stu       $02,s
                    lbsr      PutCharToWindow
                    lda       #$08
                    cmpa      $06,s
                    beq       EditStringContinue
                    bra       EditStringBackspace
EditStringCtrlC               cmpa      #$03
                    bne       EditStringEnter
                    lda       #$08
                    bra       EditStringBackspace
EditStringEnter               cmpa      #$0D
                    bne       EditStringEsc
                    ldu       $02,s
                    clr       ,u
                    leax      $07,s
                    ldu       ,s
                    lbsr      StrCopy
                    bra       EditStringDone
EditStringEsc               cmpa      #$1B
                    beq       EditStringDone
                    ldu       $02,s
                    cmpu      $04,s
                    bcc       EditStringContinue
                    sta       ,u+
                    stu       $02,s
                    lbsr      PutCharToWindow
EditStringContinue               lbsr      InputCursorBlink
                    bra       EditStringWait
EditStringDone               lda       $06,s
                    leas      <$2F,s
                    rts

cmd_set_game_id               ldb       ,y+
                    lbsr      GetMsgPtr
                    tfr       u,x
                    ldu       #$01CE
                    ldd       #$0007
                    lbsr      MemCopyNull
                    rts

MatchWord               leas      <-$53,s
                    stb       ,s
                    leau      $01,s
                    bsr       NormWord
                    lda       ,s
                    leau      <$2A,s
                    bsr       NormWord
                    leau      $01,s
                    leax      <$2A,s
MatchWordLoop               lda       ,u+
                    beq       MatchWordFound
                    cmpa      ,x+
                    beq       MatchWordLoop
                    bra       MatchWordNoMatch
MatchWordFound               lda       #$01
                    ldb       ,x
                    beq       MatchWordRet
MatchWordNoMatch               clra
MatchWordRet               leas      <$53,s
                    rts

NormWord               leas      -$02,s
                    stu       ,s
                    ldb       #$28
                    mul
                    ldu       #$0251
                    leau      d,u
NormWordLoop               lda       ,u+
                    beq       NormWordNull
                    leax      >StrPunctuation,pcr
                    lbsr      FindByte
                    bne       NormWordLoop
                    lbsr      ToLower
                    ldx       ,s
                    sta       ,x+
                    stx       ,s
                    bra       NormWordLoop
NormWordNull               ldx       ,s
                    clr       ,x
                    leas      $02,s
                    rts

cmd_hide_mouse               lda       ,y+
                    lda       ,y+
cmd_set_upper_left               lda       ,y+
cmd_shake_screen               lda       ,y+
NoopCmdsRet               rts
StrTraceSep               fcc       /==========/
                    fcc       /================/
                    fcb       0
StrTraceNumNum               fcc       /%d: %d/
                    fcb       0
StrTraceNumStr               fcc       /%d: %s/
                    fcb       0
StrTraceColon               fcc       / :%c/
                    fcb       0
StrTraceNum               fcc       /%d/
                    fcb       0
StrReturn               fcc       /return/
                    fcb       0
TraceArgMode               fcb       0
TraceLineOff               fcb       1
TraceNumLines               fcb       $f
TraceWinHeight               fcb       0
TraceWinBg               fcb       0
TraceWinCol               fcb       0
TraceWinWidth               fcb       0
TraceWinPixH               fcb       0
TraceWinLastCol               fcb       0
TraceTopRow               fcb       0
TraceBottomRow               fcb       0

cmd_trace_on               lda       <$68
                    bne       TraceOnRet
                    bsr       TraceInit
TraceOnRet               rts
TraceInit               lda       <$0068
TraceInitCheck               bne       TraceInitRet
                    lda       >$01AF
                    anda      #$20
                    beq       TraceInitRet
                    lda       #$01
                    sta       <$0068
                    lda       >$0241
                    inca
                    adda      >TraceLineOff,pcr
                    sta       >TraceTopRow,pcr
                    adda      >TraceNumLines,pcr
                    deca
                    sta       >TraceBottomRow,pcr
                    lda       #$02
                    sta       >TraceWinCol,pcr
                    adda      #$23
                    sta       >TraceWinLastCol,pcr
                    lda       >TraceWinCol,pcr
                    ldb       #$04
                    mul
                    subb      #$05
                    stb       >TraceWinWidth,pcr
                    lda       >TraceBottomRow,pcr
                    ldb       #$08
                    mul
                    addb      #$05
                    stb       >TraceWinPixH,pcr
                    lda       >TraceNumLines,pcr
                    ldb       #$08
                    mul
                    addb      #$0A
                    stb       >TraceWinHeight,pcr
                    ldb       #$9A
                    stb       >TraceWinBg,pcr
                    ldd       #$040F
                    pshs      b,a
                    ldd       >TraceWinHeight,pcr
                    pshs      b,a
                    ldd       >TraceWinWidth,pcr
                    pshs      b,a
                    lda       #$0C
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $06,s
TraceInitRet               rts

cmd_trace_info               lda       ,y+
                    sta       <$006A
                    lda       ,y+
                    sta       >TraceLineOff,pcr
                    lda       ,y+
                    cmpa      #$02
                    bcc       TraceInfoSetLines
                    lda       #$02
TraceInfoSetLines               sta       >TraceNumLines,pcr
                    rts
TraceErase               lda       <$0068
                    beq       TraceEraseRet
                    clr       <$0068
                    ldd       >TraceWinHeight,pcr
                    pshs      b,a
                    ldd       >TraceWinWidth,pcr
                    pshs      b,a
                    lda       #$03
                    sta       <$0019
                    ldx       <$0026
                    jsr       >$0701
                    leas      $04,s
TraceEraseRet               rts

ScriptDispatch               leas      -$02,s
                    stb       $01,s
                    clr       >TraceArgMode,pcr
                    leax      >CmdTableStart,pcr
                    ldd       #$FFFF
                    pshs      b,a
                    ldd       #$0000
                    pshs      b,a
                    pshs      y
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    lbsr      ScriptDisplayLine
                    leas      $0A,s
                    ldb       $01,s
                    leas      $02,s
                    rts

ScriptArgDispatch               leas      -$03,s
                    sta       $02,s
                    lda       #$01
                    ldb       ,u+
                    stb       $01,s
                    cmpb      #$0E
                    beq       TraceInfoSetMode
                    clra
TraceInfoSetMode               sta       >TraceArgMode,pcr
                    leax      >eval_table,pcr
                    ldd       $02,s
                    pshs      b,a
                    ldd       #$00DC
                    pshs      b,a
                    pshs      u
                    pshs      x
                    ldd       $08,s
                    pshs      b,a
                    lbsr      ScriptDisplayLine
                    leas      $0A,s
                    leas      $03,s
                    rts

ScriptDisplayLine               leas      -$04,s
                    clr       $06,s
                    lda       $07,s
                    ldb       #$04
                    mul
                    addd      $08,s
                    std       $08,s
                    lbsr      PushRowCol
                    lbsr      PushTextColor
                    ldd       #$000F
                    lbsr      text_color
                    lbsr      TraceDrawWindow
                    lda       <$0069
                    beq       ScriptDisplayContent
                    clr       <$0069
                    leax      >StrTraceSep,pcr
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    lbsr      TraceDrawWindow
ScriptDisplayContent               ldy       <$0062
                    sty       ,s
                    ldb       <$006A
                    beq       ScriptDisplayNumNum
                    lbsr      FindLogicSlot
                    cmpu      #$0000
                    bne       ScriptDisplayNumStr
ScriptDisplayNumNum               ldu       $06,s
                    clra
                    ldb       $02,y
                    leax      >StrTraceNumNum,pcr
                    bra       ScriptDisplayPrint
ScriptDisplayNumStr               stu       <$0062
                    leau      >StrReturn,pcr
                    ldb       $07,s
                    beq       ScriptDisplayNumStrMsg
                    addb      $0D,s
                    lbsr      GetMsgPtr
ScriptDisplayNumStrMsg               clra
                    ldb       $02,y
                    leax      >StrTraceNumStr,pcr
                    ldy       ,s
                    sty       <$0062
ScriptDisplayPrint               pshs      u
                    pshs      b,a
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $06,s
                    ldd       $0A,s
                    pshs      b,a
                    ldd       $0A,s
                    pshs      b,a
                    lbsr      TraceLineDraw
                    leas      $04,s
                    ldb       $0E,s
                    bmi       ScriptDisplayWait
                    lda       >TraceBottomRow,pcr
                    ldb       >TraceWinLastCol,pcr
                    subb      #$02
                    std       <$0040
                    lda       #$54
                    ldb       $0E,s
                    bne       ScriptDisplayCmd
                    lda       #$46
ScriptDisplayCmd               pshs      b,a
                    leax      >StrTraceColon,pcr
                    pshs      b,a
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $06,s
                    ldd       >$024A
                    std       $02,s
ScriptDisplayWait               lda       <$0068
                    beq       ScriptDisplayDone
                    lbsr      EventPop
                    leax      ,x
                    beq       ScriptDisplayWaitKey
                    lda       ,x
                    cmpa      #$01
                    beq       ScriptDisplayPlusKey
ScriptDisplayWaitKey               ldd       $02,s
                    cmpd      >$024A
                    beq       ScriptDisplayWaitKey
                    lbsr      JoystickPoll
                    ldd       >$024A
                    std       $02,s
                    bra       ScriptDisplayWait
ScriptDisplayPlusKey               lda       $01,x
                    cmpa      #$2B
                    bne       ScriptDisplayDone
                    lda       #$02
                    sta       <$0068
ScriptDisplayDone               lbsr      PopRowCol
                    lbsr      PopTextColor
                    leas      $04,s
                    rts

TraceLineDraw               leas      -$06,s
                    lbsr      PushRowCol
                    ldu       $08,s
                    ldx       $0A,s
                    lda       $02,u
                    ldb       >TraceArgMode,pcr
                    beq       TraceLineArg
                    lda       ,x+
                    stx       $0A,s
TraceLineArg               ldb       $03,u
                    std       ,s
                    lda       #$28
                    lbsr      PutCharToWindow
                    lda       ,s
                    beq       TraceLineCloseParen
                    clr       $02,s
TraceLineArgLoop               ldb       $02,s
                    ldu       $0A,s
                    lbsr      TraceArgFetch
                    leax      >StrTraceNum,pcr
                    pshs      b,a
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $04,s
                    ldb       $02,s
                    incb
                    cmpb      ,s
                    bcc       TraceLineCloseParen
                    stb       $02,s
                    lda       #$2C
                    lbsr      PutCharToWindow
                    bra       TraceLineArgLoop
TraceLineCloseParen               lda       #$29
                    lbsr      PutCharToWindow
                    ldb       $01,s
                    beq       TraceLineArgs2
                    lbsr      TraceDrawWindow
TraceLineArgs2               lbsr      PopRowCol
                    ldb       $01,s
                    beq       TraceLineDrawRet
                    lda       #$28
                    lbsr      PutCharToWindow
                    lda       #$80
                    clr       $02,s
TraceLineArg2Loop               sta       $03,s
                    ldb       $02,s
                    ldu       $0A,s
                    lbsr      TraceArgFetch
                    std       $04,s
                    lda       $01,s
                    anda      $03,s
                    beq       TraceLineArg2Print
                    ldx       #$0431
                    abx
                    ldb       ,x
                    clra
                    std       $04,s
TraceLineArg2Print               leax      >StrTraceNum,pcr
                    ldd       $04,s
                    pshs      b,a
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $04,s
                    ldb       $02,s
                    incb
                    cmpb      ,s
                    bcc       TraceLineArg2Paren
                    stb       $02,s
                    lda       #$2C
                    lbsr      PutCharToWindow
                    lda       $03,s
                    lsra
                    bra       TraceLineArg2Loop
TraceLineArg2Paren               lda       #$29
                    lbsr      PutCharToWindow
TraceLineDrawRet               leas      $06,s
                    rts

TraceArgFetch               lda       >TraceArgMode,pcr
                    bne       TraceArgFetchWord
                    clra
                    ldb       b,u
                    bra       TraceArgFetchRet
TraceArgFetchWord               lslb
                    leau      b,u
                    ldb       ,u+
                    lda       ,u
TraceArgFetchRet               rts

TraceDrawWindow               ldd       #$0001
                    pshs      b,a
                    ldb       >TraceWinLastCol,pcr
                    pshs      b,a
                    ldb       >TraceWinCol,pcr
                    pshs      b,a
                    ldd       #$000F
                    pshs      b,a
                    ldb       >TraceBottomRow,pcr
                    pshs      b,a
                    ldb       >TraceTopRow,pcr
                    pshs      b,a
                    lbsr      DrawTextRect
                    leas      $0C,s
                    lda       >TraceBottomRow,pcr
                    ldb       >TraceWinCol,pcr
                    std       <$0040
                    rts

InputBufLen               fcb       0
InputBuf               fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0,0

EventLoop               clra
                    sta       >$0444
                    sta       >$043A
                    lda       >$05AE
                    beq       EventLoopCheck
                    lbsr      DrawMenuBar
EventLoopCheck               lbsr      EventPop
                    lbsr      RemapKeyEvent
                    leax      ,x
                    beq       EventLoopDone
                    ldd       ,x
                    cmpa      #$01
                    bne       EventLoopJoy
                    stb       >$0444
                    lda       >$01D5
                    beq       EventLoopCheck
                    bsr       InputProcess
                    bra       EventLoopCheck
EventLoopJoy               cmpa      #$02
                    bne       EventLoopKey
                    ldu       <$0030
                    cmpb      <$21,u
                    bne       EventLoopJoyStore
                    clrb
EventLoopJoyStore               stb       >$0437
                    lda       >$0250
                    beq       EventLoopCheck
                    lda       #$00
                    sta       <$22,u
                    bra       EventLoopCheck
EventLoopKey               ldu       #$05BA
                    lda       #$01
                    sta       b,u
                    bra       EventLoopCheck
EventLoopDone               rts

InputProcess               leas      -$02,s
                    stb       ,s
                    ldx       #$0251
                    lbsr      StrLen
                    negb
                    addb      #$28
                    lda       >$01AD
                    beq       InputCheckLen
                    decb
InputCheckLen               cmpb      >$0449
                    bls       InputDispatch
                    ldb       >$0449
InputDispatch               stb       $01,s
                    lbsr      InputEditOn
                    lda       ,s
                    cmpa      #$0A
                    beq       InputProcessDone
                    cmpa      #$0D
                    bne       InputBackspace
                    lda       >InputBufLen,pcr
                    beq       InputProcessDone
                    ldx       #$012B
                    leau      >InputBuf,pcr
                    lbsr      StrCopy
                    ldx       #$012B
                    lbsr      ParseSentence
                    clra
                    sta       >InputBufLen,pcr
                    ldx       #$012B
                    sta       ,x
                    lbsr      InputRedraw
                    bra       InputProcessDone
InputBackspace               cmpa      #$08
                    bne       InputAddChar
                    lda       >InputBufLen,pcr
                    beq       InputProcessDone
                    deca
                    sta       >InputBufLen,pcr
                    ldu       #$012B
                    clr       a,u
                    lda       ,s
                    lbsr      PutCharToWindow
                    bra       InputProcessDone
InputAddChar               ldb       >InputBufLen,pcr
                    cmpb      $01,s
                    bcc       InputProcessDone
                    lda       ,s
                    beq       InputProcessDone
                    ldu       #$012B
                    sta       b,u
                    incb
                    stb       >InputBufLen,pcr
                    clr       b,u
                    lbsr      PutCharToWindow
InputProcessDone               bsr       InputCursorBlink
                    leas      $02,s
                    rts

cmd_cancel_line               lda       >InputBufLen,pcr
                    beq       CancelLineRet
                    ldb       #$08
                    lbsr      InputProcess
                    bra       cmd_cancel_line
CancelLineRet               rts

cmd_echo_line               lda       >$01D5
                    beq       EchoLineRet
                    bsr       input_echo
EchoLineRet               rts

input_echo               leax      >InputBuf,pcr
                    lbsr      StrLen
                    cmpb      >InputBufLen,pcr
                    bls       InputEchoRet
                    bsr       InputEditOn
InputEchoLoop               ldb       >InputBufLen,pcr
                    ldu       #$012B
                    leax      >InputBuf,pcr
                    lda       b,x
                    sta       b,u
                    beq       InputEchoRedraw
                    incb
                    stb       >InputBufLen,pcr
                    lbsr      PutCharToWindow
                    bra       InputEchoLoop
InputEchoRedraw               bsr       InputCursorBlink
InputEchoRet               rts

InputCursorBlink               lda       >$05B9
                    bne       InputCursorBlinkRet
                    com       >$05B9
                    lda       >$01AD
                    beq       InputCursorBlinkRet
                    lbsr      PutCharToWindow
InputCursorBlinkRet               rts

InputEditOn               lda       >$05B9
                    beq       InputEditOnRet
                    com       >$05B9
                    lda       >$01AD
                    beq       InputEditOnRet
                    lda       #$08
                    lbsr      PutCharToWindow
InputEditOnRet               rts

cmd_prevent_input               bsr       InputEditOn
                    lda       >$01D7
                    clrb
                    stb       >$01D5
                    lbsr      ClearTextLine
                    rts

cmd_accept_input               lda       #$01
                    sta       >$01D5
                    bsr       InputRedraw
                    rts

cmd_set_cursor_char               ldb       ,y+
                    lbsr      GetMsgPtr
                    lda       ,u
                    sta       >$01AD
                    rts

InputRedraw               leas      <-$50,s
                    lda       >$01D5
                    beq       InputRedrawRet
                    bsr       InputEditOn
                    lda       >$01D7
                    ldb       >$024D
                    lbsr      ClearTextLine
                    lda       >$01D7
                    clrb
                    std       <$0040
                    ldx       #$0251
                    leau      ,s
                    ldd       #$0028
                    pshs      b,a
                    pshs      x
                    pshs      u
                    lbsr      MsgTextSetup
                    leas      $06,s
                    pshs      x
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    ldd       #$012B
                    pshs      b,a
                    lbsr      PrintFmtStrToScr
                    leas      $02,s
                    lbsr      InputCursorBlink
InputRedrawRet               leas      <$50,s
                    rts

cmd_increment               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    inca
                    beq       IncrSkip
                    sta       ,x
IncrSkip               rts

cmd_decrement               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    beq       DecrSkip
                    deca
                    sta       ,x
DecrSkip               rts

cmd_assignn               ldb       ,y+
                    ldx       #$0431
                    lda       ,y+
                    abx
                    sta       ,x
                    rts

cmd_assignv               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

cmd_addn               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    adda      ,y+
                    sta       ,x
                    rts

cmd_addv               ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    adda      ,x
                    sta       ,x
                    rts

cmd_subn               ldb       ,y+
                    ldx       #$0431
                    abx
                    lda       ,x
                    suba      ,y+
                    sta       ,x
                    rts

cmd_subv               ldb       $01,y
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

cmd_lindirectv               ldb       $01,y
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

cmd_lindirectn               lda       $01,y
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    ldb       ,x
                    ldx       #$0431
                    abx
                    sta       ,x
                    rts

cmd_rindirect               ldb       $01,y
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

cmd_multn           ldx       #$0431
                    ldb       ,y+
                    abx
                    lda       ,x
                    ldb       ,y+
                    mul
                    stb       ,x
                    rts

cmd_multv           ldb       $01,y
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

cmd_divn            ldx       #$0431
                    ldb       ,y+
                    abx
                    ldb       ,x
                    lda       ,y+
                    bsr       Div8
                    stb       ,x
                    rts

cmd_divv            ldb       $01,y
                    ldx       #$0431
                    abx
                    lda       ,x
                    ldb       ,y++
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       Div8
                    stb       ,x
                    rts

Div8                sta       <$0088
                    lda       #$08
                    sta       <$008D
                    clra
Div8Loop            lslb
                    rola
                    cmpa      <$0088
                    bcs       Div8Next
                    suba      <$0088
                    incb
Div8Next            dec       <$008D
                    bne       Div8Loop
                    rts

list_struct          fcb       0,0
                    fcb       0,0
                    fcb       0,0,0
ListLastNode        fcb       0,0

list_clear          leau      list_struct,pcr
                    ldd       #0
                    std       ,u
                    rts

view_find           leax      >list_struct,pcr
ViewFindLoop        stx       >ListLastNode,pcr
                    ldx       ,x
                    beq       ViewFindRet
                    cmpb      $02,x
                    bne       ViewFindLoop
ViewFindRet         rts

cmd_load_view       lda       #$00
                    ldb       ,y+
                    bsr       view_load
                    rts

cmd_load_view_v     lda       #$00
                    ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       view_load
                    rts

view_load           leas      -$06,s
                    std       ,s
                    bsr       view_find
                    leax      ,x
                    beq       ViewLoadCreate
                    ldb       ,s
                    bne       ViewLoadCreate
                    tfr       x,u
                    bra       ViewLoadRet
ViewLoadCreate      stx       $02,s
                    ldd       <$000A
                    std       $04,s
                    lbsr      ClearBothRanges
                    ldu       $02,s
                    bne       ViewLoadFetch
                    lda       #$01
                    ldb       $01,s
                    lbsr      PushScript
                    ldd       #$0007
                    lbsr      AllocDataBlock
                    stu       $02,s
                    ldx       >ListLastNode,pcr
                    stu       ,x
                    ldd       #$0000
                    std       ,u
                    std       $03,u
                    ldb       $01,s
                    stb       $02,u
ViewLoadFetch       ldb       $02,u
                    lbsr      FetchView
                    ldx       $02,s
                    ldx       $03,x
                    lbsr      OpenVolFile
                    beq       ViewLoadDone
                    ldx       $02,s
                    std       $05,x
                    stu       $03,x
ViewLoadDone        lbsr      SwapObjRanges
                    ldd       $04,s
                    lbsr      SetLogicPage
                    ldu       $02,s
ViewLoadRet         leas      $06,s
                    rts

cmd_set_view        leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       SetViewForObj
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

cmd_set_view_v      leas      -$02,s
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
                    bsr       SetViewForObj
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

SetViewForObj       lbsr      view_find
                    leax      ,x
                    bne       SetViewData
                    lda       #$03
                    lbsr      ReportError
SetViewData         stb       $05,u
                    ldd       $05,x
                    std       $08,u
                    ldx       $03,x
                    stx       $06,u
                    lbsr      SetLogicPage
                    ldx       $06,u
                    lda       $02,x
                    sta       $0B,u
                    ldb       $0A,u
                    cmpb      $0B,u
                    bcs       SetViewRet
                    clrb
SetViewRet          bsr       SetLoopHelper
                    rts

cmd_set_loop        leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       SetLoopHelper
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

cmd_set_loop_v      leas      -$02,s
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
                    bsr       SetLoopHelper
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

SetLoopHelper       leas      -$01,s
                    ldx       $06,u
                    bne       SetLoopFound
                    ldb       #$06
                    bra       SetLoopErr
SetLoopFound        cmpb      $0B,u
                    bcs       SetLoopData
                    ldb       #$05
SetLoopErr          stb       ,s
                    tfr       u,d
                    subd      <$0030
                    lda       ,s
                    lbsr      ReportError
SetLoopData         stb       $0A,u
                    ldd       $08,u
                    lbsr      SetLogicPage
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
                    bcs       SetLoopRet
                    clrb
SetLoopRet          bsr       SetCelHelper
                    leas      $01,s
                    rts

cmd_set_cel         leas      -$02,s
                    ldd       <$000A
                    std       ,s
                    lda       ,y+
                    ldb       #$2B
                    mul
                    addd      <$0030
                    tfr       d,u
                    ldb       ,y+
                    bsr       SetCelHelper
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

cmd_set_cel_v       leas      -$02,s
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
                    bsr       SetCelHelper
                    ldd       ,s
                    lbsr      SetLogicPage
                    leas      $02,s
                    rts

SetCelHelper        leas      -$01,s
                    ldx       $06,u
                    bne       SetCelFound
                    ldb       #$0A
                    bra       SetCelErr
SetCelFound         cmpb      $0F,u
                    bcs       SetCelData
                    ldb       #$08
SetCelErr           stb       ,s
                    tfr       u,d
                    subd      <$0030
                    lda       ,s
                    lbsr      ReportError
SetCelData          stb       $0E,u
                    ldd       $08,u
                    lbsr      SetLogicPage
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
                    bls       SetCelWidthClip
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    lda       #$A0
                    suba      <$1C,u
                    sta       $03,u
SetCelWidthClip     decb
                    cmpb      $04,u
                    bls       SetCelRet
                    lda       <$25,u
                    ora       #$04
                    sta       <$25,u
                    stb       $04,u
                    cmpb      >$01D6
                    bhi       SetCelRet
                    lda       <$26,u
                    bita      #$08
                    bne       SetCelRet
                    ldb       >$01D6
                    incb
                    stb       $04,u
SetCelRet           leas      $01,s
                    rts

cmd_last_cel        lda       ,y+
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

cmd_current_cel     lda       ,y+
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

cmd_current_loop    lda       ,y+
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

cmd_current_view    lda       ,y+
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

cmd_number_of_loops lda       ,y+
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

cmd_discard_view    ldb       ,y+
                    bsr       DiscardViewHelper
                    rts

cmd_discard_view_v  ldb       ,y+
                    ldx       #$0431
                    abx
                    ldb       ,x
                    bsr       DiscardViewHelper
                    rts

DiscardViewHelper   leas      -$05,s
                    stb       ,s
                    lbsr      view_find
                    leax      ,x
                    bne       DiscardViewDoFree
                    lda       #$01
                    ldb       ,s
                    lbsr      ReportError
DiscardViewDoFree   stx       $01,s
                    ldd       <$000A
                    std       $03,s
                    lda       #$07
                    ldb       ,s
                    lbsr      PushScript
                    ldu       >ListLastNode,pcr
                    ldd       #$0000
                    std       ,u
                    lbsr      ClearBothRanges
                    ldx       $01,s
                    ldu       $03,x
                    lda       $05,x
                    lbsr      CalcPriAddr
                    stu       <$004F
                    stx       <$0055
                    lbsr      SwapObjRanges
                    lbsr      UpdateFreeSpace
                    ldd       $03,s
                    lbsr      SetLogicPage
                    leas      $05,s
                    rts

ObjAnimStep         lda       <$27,u
                    beq       AnimStepRoll
                    dec       <$27,u
                    lda       <$25,u
                    bita      #$40
                    beq       AnimStepRet
AnimStepRoll        lbsr      InitRandSeed
                    lda       #$09
                    lbsr      Div8
                    sta       <$21,u
                    cmpu      <$0030
                    bne       AnimStepCheckDelay
                    sta       >$0437
AnimStepCheckDelay  lda       <$27,u
AnimStepDelayLoop   cmpa      #$06
                    bcc       AnimStepRet
                    lbsr      InitRandSeed
                    lda       #$33
                    lbsr      Div8
                    sta       <$27,u
                    bra       AnimStepDelayLoop
AnimStepRet         rts

SetPriBaseStub      ldx       #$05ee              * regX will now point to the priority table
                    lbra      SetPriBase               * back to the original code

UIntDivideToD       lbsr      UIntDivide
                    tfr       u,d
                    rts

* Patch stub to have "format string" return string in X
* without altering code length in "move to (x,y)"
stub1               lbsr      PrintFmtStr
                    tfr       u,x
                    lbra      MoveToFormatDone

                    fcb       0,0,0,0,0,0,0,0
StrModName          fcc       /mnln/
                    fcb       0

                    emod
eom                 equ       *
                    end
