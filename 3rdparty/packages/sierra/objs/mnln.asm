********************************************************************
* mnln - Sierra AGI interpreter main-line module
*        (used with King's Quest I-IV, Space Quest I-II,
*        Police Quest I, Leisure Suit Larry, Black Cauldron,
*        Gold Rush, Manhunter I-II, Christmas Card 1986,
*        and other Sierra AGI games for NitrOS-9)
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/06  Paul W. Zibaila
* Disassembly of original distribution; assembles to original mnln.
* Annotated by /annotate-asm (Claude Code) 2026-05-14:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction

*  >$0154  flag for using extended lookups
*  >$0541  joystick button status
*  >$0532  vol_handle_table
*  >$05B9  input_edit_disabled


StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

*  data area layout — absolute addresses in the Sierra data block
*  pre-allocated by the sierra module; shared between sierra and mnln
          ifp1

*  direct page (DP) variables: $00–$9D, accessed via < prefix
          org       0
DataBlockSize       rmb       1                   holds size of data block
                    rmb       8                   unused $01–$08
SierraRemapOff      rmb       1                   sierra - offset from entry to the routine for the remap call
PsgCurLatch         rmb       1                   last latch byte written to PSG
                    rmb       14                  unused $0B–$18
ScrnRemapOff        rmb       1                   scrn - offset from entry to the routine for the remap call
                    rmb       7                   unused $1A–$20
ShdwRemapOff        rmb       1                   shdw - offset from entry to the routine for the remap call
SierraRemapVal      rmb       1                   sierra remap value holder
                    rmb       3                   unused $23–$25
ScrnRemapVal        rmb       1                   scrn remap value holder
                    rmb       1                   unused $27
ShdwRemapVal        rmb       1                   shdw remap value holder
                    rmb       3                   unused $29–$2B
PixDispAddr         rmb       2                   display buffer pixel address
SierraBiasVal       rmb       2                   sierra module load bias value
ViewObjBase         rmb       2                   view object table base pointer
ViewObjEnd          rmb       2                   view object table end pointer
ViewObjSizeD        rmb       2                   default view object alloc size
ViewObjLast         rmb       2                   last active view object pointer
BlockPtr            rmb       2                   current block data pointer
BlockOffset         rmb       2                   byte offset into current block
BlockSizeLimit      rmb       2                   block size limit
LoopCounter         rmb       2                   general-purpose loop counter
TextRow             rmb       1                   current text output row
TextCol             rmb       1                   current text output column
PsgBlockNum         rmb       1                   MMU block number for PSG hardware
PsgPortAddr         rmb       1                   PSG port address within block
                    rmb       1                   unused $44
DrawAttr            rmb       1                   current drawing attribute byte
                    rmb       5                   unused $46–$4A
SierraModSize       rmb       2                   size of sierra module in memory
MnlnModSize         rmb       2                   size of mnln module in memory
HeapPtr             rmb       2                   current heap allocation pointer
HeapEnd             rmb       2                   heap end boundary pointer
HeapBase            rmb       2                   heap base (start) pointer
HeapTop             rmb       2                   heap top of free space pointer
HeapMax             rmb       1                   heap max occupancy watermark
HeapByteCnt         rmb       1                   heap free byte count
                    rmb       3                   unused $59–$5B
ShdwContact         rmb       1                   shadow module contact result
                    rmb       2                   unused $5D–$5E
PriorityYBase       rmb       2                   priority band Y-coord base table
                    rmb       1                   unused $61
CurrentLogicPtr     rmb       2                   pointer to current logic script
LogicTablePtr       rmb       2                   pointer to loaded logic table
VolFileSize         rmb       2                   VOL file size
NegCondFlag         rmb       1                   negate next condition test flag
FirstExecFlag       rmb       1                   set until first game cycle runs
StringPtrFlag       rmb       1                   flag: next arg is string pointer
                    rmb       1                   unused $6B
SavedYPtr           rmb       2                   saved Y register across calls
TempRegA            rmb       1                   temporary A register scratch byte
ObjXPos             rmb       1                   object X pixel position
TempObjByte         rmb       1                   temporary object scratch byte
ObjXRight           rmb       1                   object right X boundary
WordMatchCnt        rmb       1                   count of vocabulary word matches
WordMatchFlag       rmb       1                   word match found flag
AnimStep            rmb       1                   current animation step index
AnimStepMax         rmb       1                   animation step count limit
TempMultByte        rmb       1                   temporary multiply scratch byte
OpenPathCnt         rmb       1                   open path counter
PathNum             rmb       1                   path number holder
DiskNameBufPtr      rmb       2                   pointer to disk volume name buffer
CmpKey3Hi           rmb       2                   disk compare key 3 high word
CmpKey3Lo           rmb       1                   disk compare key 3 low byte
DiskKeyAHi          rmb       2                   disk search key A high word
DiskKeyALo          rmb       1                   disk search key A low byte
DiskKeyBHi          rmb       2                   disk search key B high word
DiskKeyBLo          rmb       1                   disk search key B low byte
SeekMSW             rmb       2                   seek MSW
SeekLSW             rmb       2                   seek LSW
DivDivisor          rmb       1                   divisor for integer divide
DiskInfoIdx         rmb       1                   disk volume info table index
                    rmb       1                   unused $8A
RandSeedHi          rmb       1                   RNG seed high byte
RandSeedLo          rmb       1                   RNG seed low byte
DivBitCount         rmb       1                   bit loop counter for divide
DelayParam          rmb       2                   sound half-period delay count
DelayParamX         rmb       2                   sound outer loop count
EvtWritePtr         rmb       2                   event queue write pointer
EvtReadPtr          rmb       2                   event queue read pointer
JoyNum              rmb       1                   holds joystick number
JoyDirState         rmb       1                   current joystick direction state
JoyEnabled          rmb       1                   joystick enabled flag
JoyLastDir          rmb       1                   last sampled joystick direction
JoyTimerLo          rmb       2                   joystick sample timer low word
JoyTimerHi          rmb       1                   joystick sample timer high byte
JoyDebounce         rmb       1                   joystick debounce counter

*  Sierra game state: extended addresses ($0100–$0659), accessed via > prefix
                    rmb       98                  unused $9E–$00FF
PicVisible          rmb       1                   pic_visible
FmtEscPrefix        rmb       1                   format string escape prefix byte
ClockState          rmb       1                   clock_state
                    rmb       81                  unused $0103–$0153
ExtTableFlag        rmb       1                   flag for extended table look up
WordWrapPos         rmb       1                   word wrap column position
                    rmb       1                   unused $0156
PrintColPos         rmb       1                   current print column position
WrapWidth           rmb       1                   text line wrap width in chars
MsgHeight           rmb       1                   message window height in rows
InputParsed         rmb       1                   flag: user input has been parsed
OsErrCode           rmb       1                   last OS-9 error code
MsgWidth            rmb       1                   message window width in chars
                    rmb       10                  unused $015D–$0166
StateField167       rmb       1                   game state byte at $0167 (unknown)
                    rmb       10                  unused $0168–$0171
StateField172       rmb       1                   game state byte at $0172 (unknown)
InputModeFlag       rmb       1                   text input mode flag
                    rmb       2                   unused $0174–$0175
DlgCharLeft         rmb       1                   dialog box left column (chars)
DlgCharTop          rmb       1                   dialog box top row (chars)
DlgCharRight        rmb       1                   dialog box right column (chars)
DlgCharBottom       rmb       1                   dialog box bottom row (chars)
                    rmb       1                   unused $017A
DlgPixTop           rmb       1                   dialog box top pixel row
DlgPixH             rmb       1                   dialog box pixel height
DlgPixW             rmb       1                   dialog box pixel width
DlgPixX             rmb       1                   dialog box pixel X origin
DlgPixW2            rmb       1                   dialog box secondary pixel width
DlgOpenFlag         rmb       1                   dialog box currently open flag
                    rmb       40                  unused $0181–$01A8
WordIdxTblPtr       rmb       2                   word index table pointer
WordsTokVolIdx      rmb       2                   words.tok volume index
BlockState          rmb       1                   state.block_state
CursorChar          rmb       1                   state.cursor
GameFlags1          rmb       1                   state.flag
GameFlags2          rmb       1                   state.flag
RestartFlags        rmb       1                   game restart mode flags
                    rmb       36                  unused $01B2–$01D5
InputState          rmb       1                   current user input state
HorizonY            rmb       1                   horizon Y pixel row
InputRow            rmb       1                   text row for user input line
                    rmb       100                 unused $01D9–$023C
BlockX2             rmb       1                   state.block_x2
BlockY2             rmb       1                   state.block_y2
                    rmb       1                   unused $023F
StateField240       rmb       1                   game state byte at $0240 (unknown)
CurPicNum           rmb       1                   state.pic_num
DisplayOffset       rmb       2                   display buffer byte offset
ScriptSaved         rmb       1                   state.script_saved
ScriptCount         rmb       1                   state.script_count
ScriptMax           rmb       1                   maximum script entry count
StatusState         rmb       1                   state.status_state
StatusRow           rmb       1                   status bar text row
TimerEpoch          rmb       2                   game timer epoch reference count
TickCounter         rmb       2                   frame tick counter
TextFgColor         rmb       1                   state.text_fg
TextBgColor         rmb       1                   state.text_bg
BlockX1             rmb       1                   state.block_x1
BlockY1             rmb       1                   state.block_y1
EgoCtrlMode         rmb       1                   state.ego_control_state
StringTable         rmb       $01E0               state.string (24 strings × 20 chars)
AgiVar0             rmb       1                   state.var[]
AgiVar1             rmb       1                   previous room number
AgiVar2             rmb       1                   ego border contact code
AgiVar3             rmb       1                   current cycle of ego view
AgiVar4             rmb       1                   current view number of ego
AgiVar5             rmb       1                   most recently pressed key
AgiVar6             rmb       1                   ego sprite Y half-height
AgiVar7             rmb       1                   ego Y pixel position
AgiVar8             rmb       1                   currently held key code
AgiVar9             rmb       1                   matched vocabulary word number
AgiVar10            rmb       1                   game clock: minutes
AgiVar11            rmb       1                   game clock: hours
AgiVar12            rmb       1                   game clock: days
AgiVar13            rmb       1                   joystick sensitivity
AgiVar14            rmb       1                   direction of ego motion
AgiVar15            rmb       1                   ego view object number
AgiVar16            rmb       1                   AGI game variable 16
AgiVar17            rmb       1                   AGI game variable 17
AgiVar18            rmb       1                   AGI game variable 18
AgiVar19            rmb       1                   AGI game variable 19
AgiVar20            rmb       1                   AGI game variable 20
AgiVar21            rmb       1                   AGI game variable 21
AgiVar22            rmb       1                   AGI game variable 22
                    rmb       1                   unused (AgiVar23 not referenced)
AgiVar24            rmb       1                   AGI game variable 24
AgiVar25            rmb       1                   AGI game variable 25
AgiVar26            rmb       1                   AGI game variable 26
                    rmb       229                 unused $044D–$0531
VolHandleTable      rmb       $0F                 vol_handle_table
JoyBtnStatus        rmb       1                   joystick button status byte
JoyBtnPhase         rmb       1                   joystick button phase tracker
JoyTimeLo           rmb       2                   joystick timing low word
JoyTimeHi           rmb       2                   joystick timing high word
JoyModeFlag         rmb       1                   joystick mode flag
                    rmb       8                   unused $0548–$054F
PicBufRotate        rmb       1                   gfx_picbuffrotate
GivenPicData        rmb       2                   given_pic_data
DisplayType         rmb       1                   display_type
                    rmb       90                  unused $0554–$05AD
MenuVisible         rmb       1                   menu bar currently visible flag
ScriptBufPtr        rmb       2                   script buffer pointer
ObjDisplayed        rmb       1                   obj_displayed in obj_show()
                    rmb       6                   unused $05B2–$05B7
StateField5B8       rmb       1                   game state byte at $05B8 (unknown)
InputEditDis        rmb       1                   input_edit_disabled
                    rmb       50                  unused $05BA–$05EB
ChgenTextMode       rmb       1                   chgen_textmode
DiskCount           rmb       1                   disk volume count
                    rmb       107                 unused $05EE–$0658
MmuTwiddler         rmb       1                   MMU block twiddler scratchpad

          endc

HwHSync             equ       $FF01               hsync control
HwKeyboard          equ       $FF02               keyboard col
HwVSync             equ       $FF03               vsync control
HwDAC               equ       $FF20               d/a, cassette & rs232 out
HwVDGCtrl           equ       $FF22               vdg control and rs-232 in
HwCtrlReg           equ       $FF23               control reg


MmuT1Blk2           equ       $FFA9               task 1 block 2


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
                    lbra      ModuleInit          jump over strings


* Text strings think this was probably an Info thing
StrCopyright        fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       C$NULL

StrPaused           fcc       '      Game paused.'
                    fcb       C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL


StrQuitPrompt       fcc       'Press ENTER to quit.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to keep playing.'
                    fcb       C$NULL

* ====================================================================
* MODULE INITIALIZATION
* Invoked once by sierra module. Loads all resource directories from
* disk, initializes the game state, patches command/eval jump tables,
* then falls through into the main interpreter loop.
* ====================================================================
ModuleInit          leas      -$06,s              make room on the stack
                    lbsr      FixupCmdTbl         modifies table values at 1B0
                    lbsr      FixupEvalTbl        modifies table values at D09
                    lbsr      InitGameState       calls the mmu twiddler at >$659
*                         uses toc and words.tok`

* ====================================================================
* MAIN INTERPRETER LOOP
* Each cycle: poll joystick/input, run logic scripts for the current
* room, advance object motion, render sprites, and update the screen.
* Speed is throttled by waiting for the tick counter to reach the
* configured cycle rate.
* ====================================================================
GameLoop            clra                          clear D high byte (speed is 8-bit)
                    ldb       >$043C              load speed setting
                    std       ,s                  save as cycle target

InterpCycleTop      lbsr      JoystickPoll        poll joystick for events
SpeedWaitLoop       ldd       <LoopCounter        load tick counter
                    cmpd      ,s                  reached cycle target?
                    bcc       CycleDoneNext       yes — proceed
                    cmpd      $04,s               tick changed since last check?
                    beq       SpeedWaitLoop       no — spin-wait
                    std       $04,s               yes — save new tick snapshot
                    bra       InterpCycleTop      loop until target reached
CycleDoneNext       ldd       #$0000              reset loop counter to zero
                    std       <LoopCounter        write zero to LoopCounter
                    lbsr      ClearStateVars      self contained call to clear 50 bytes 05BA
                    lda       >$01AF              clear flags bit 5 (reset flag)
                    anda      #$DF                mask off bit 5
                    sta       >$01AF              write back cleared flags
                    lda       >$01AF              reload flags for next mask
                    anda      #$F7                clear flag bit 3
                    sta       >$01AF              write back cleared flags
                    lbsr      EventLoop           process all pending input events
                    ldx       <ViewObjBase        X = ego object
                    lda       >$0251              ego control mode (0=joystick, 1=program)
                    beq       SaveEgoLoop         joystick — save ego direction
                    lda       >$0438              program-controlled — apply last dir
                    sta       <$21,x              store into ego direction field
                    bra       AfterEgoCtrl        skip joystick path
SaveEgoLoop         lda       <$21,x              read ego's current direction
                    sta       >$0438              save for next cycle
AfterEgoCtrl        lbsr      UpdateObjMotion     move all objects
                    lda       >$01B0              load status flags
                    anda      #$40                isolate screen-update bit
                    sta       $03,s               save pre-logic screen state
                    lbsr      GetStackFrame       set up logic execution context
ExecCmdLoop         lda       >$0435              load current logic number
                    sta       $02,s               save for change detection
                    clrb                          logic 0 = room logic
                    lbsr      ExecLogic           execute logic script
                    leay      ,y                  Y = 0 if no new room?
                    bne       AfterExecCmd        nonzero — room changed
                    clra                          room not changed — reset flags
                    sta       >$043B              clear ego direction
                    sta       >$0437              clear screen-update flag
                    sta       >$0436              clear script-change flag
                    lda       >$01AF              reload flags for bit-5 mask
                    anda      #$DF                clear flag bit 5
                    sta       >$01AF              write back cleared flags
                    bra       ExecCmdLoop         re-run logic for new state
AfterExecCmd        lda       >$0438              load saved ego direction
                    ldx       <ViewObjBase        X = ego view-object
                    sta       <$21,x              apply saved direction to ego
                    lda       $02,s               saved logic number
                    cmpa      >$0435              same logic as before?
                    bne       UpdateScreenChk     no — always update status
                    lda       >$01B0              load status flags
                    anda      #$40                screen-update bit
                    cmpa      $03,s               same as pre-logic value?
                    beq       CycleTailClean      unchanged — skip status update
UpdateScreenChk     lbsr      StatusLineWrite     redraw status bar
CycleTailClean      clra                          A = 0 for clearing cycle flags
                    sta       >$0437              clear screen-update flag
                    sta       >$0436              clear script-change flag
                    lda       >$01AF              reload flags for bit-2 mask
                    anda      #$FB                clear flag bit 2
                    sta       >$01AF              write back cleared flags
                    lda       >$01AF              reload flags for bit-1 mask
                    anda      #$FD                clear flag bit 1
                    sta       >$01AF              write back cleared flags
                    lda       >$01B0              load status flags
                    anda      #$F7                clear status bit 3
                    sta       >$01B0              write back cleared status
                    lda       >$05EC              update-all flag
                    cmpa      #$00                non-zero = skip UpdateAllObjs this cycle
                    lbne      GameLoop            skip — straight back to top
                    lbsr      UpdateAllObjs       animate/draw all objects
                    lbra      GameLoop            next interpreter cycle

cmd_pause
CmdPauseImpl        lda       #$01                set clock_state = 1 (paused)
                    sta       >ClockState         set clock_state = 1
                    lbsr      events_clear        events_clear
                    leau      >StrPaused,pcr      get addr of game paused msg
                    lbsr      message_box         pass it to message_box()
                    clr       >ClockState         set clock_state = 0
                    rts

cmd_quit
CmdQuitImpl         lda       ,y+                 get the arg passed and bump y
                    cmpa      #$01                was it a 1?
                    beq       QuitConfirmed       if so time to exit
                    leau      >StrQuitPrompt,pcr  get addr of quit / continue msg
                    lbsr      message_box         pass it to message_box()
                    beq       QuitRet             if we didn't get a one back play on
*                           otherwise time to close down the game
QuitConfirmed       lda       #$03                load the offset to exit_agi()
                    sta       <SierraRemapOff     save the offset
                    ldx       <SierraRemapVal     set up to jump to sierra
                    jsr       >$0659              mmu twiddle
QuitRet             rts


* ====================================================================
* COMMAND AND CONDITION DISPATCH TABLES
* Two parallel jump tables patch-linked by the sierra loader. Each
* entry is four bytes: a function pointer (first word) and a packed
* parameter descriptor (second word: MSB=count, LSB=type flags).
* cmd_table is indexed by AGI command byte; eval_table is indexed by
* condition (test) byte. Both tables are patched at load time with
* the host segment base so that function pointers resolve correctly.
* ====================================================================

cmd_table
CmdTableStart       fdb       cmd_do_nothing,$0000
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

FixupCmdTbl         leas      -$01,s              Make temp storage on stack for one byte
                    lda       #$B2                load the counter for the move 178
                    sta       ,s                  store the value on the stack
*        leau  >$01B0,pcr     --- disassembly
                    leau      >CmdTableStart,pcr  point u at the beginning of the data block

FixupCmdTblLoop     ldd       <SierraBiasVal      value set in sierra at nmload of mnln
                    addd      ,u                  add that to current u and stow in u
                    std       ,u                  now stow that back at u
                    leau      $04,u               next u will move 4 bytes
                    dec       ,s                  drop the counter by 1 and go again
                    bne       FixupCmdTblLoop     loop until all entries patched
                    leas      $01,s               release counter byte from stack
                    rts

***********************************************************
*
* Uses the value stored at NegCondFlag in A and
*      the value passed in B
*      to select a value to jump to
*

ExecCmd             cmpb      #$B1                compare input value
                    bls       ExecCmdNeg          less than or equal
                    lda       #$10                greater than load and go into never land
                    lbsr      ReportError         report invalid opcode (>$B1)
ExecCmdNeg          lda       <NegCondFlag        load trace-mode flag
                    cmpa      #$01                is trace mode active?
                    bne       ExecCmdJump         no — skip trace output
                    pshs      y                   save script pointer
                    lbsr      ScriptDispatch      display current trace line
                    puls      y                   restore script pointer
ExecCmdJump         leax      >CmdTableStart,pcr  big jump table address
                    lda       #$04                4 bytes per command table entry
                    mul                           scale opcode index by 4 bytes/entry
                    jsr       [d,x]               dispatch through command jump table
                    leay      ,y                  test Y (zero = null / end of script)
                    beq       ExecCmdRet          is zero ?? leave
                    ldb       ,y+                 fetch next opcode byte
                    beq       ExecCmdRet          is the next byte zero leave
                    cmpb      #$FC                is it a control byte ($FC+)?
                    bcs       ExecCmd             no — dispatch next command
ExecCmdRet          rts

UpdateObjAnim       lda       <$25,u              load object flags byte
                    bita      #$10                test one-shot cycle-done flag
                    beq       AnimCycleNorm       not set — run normal cycle
                    anda      #$EF                clear the one-shot flag
                    sta       <$25,u              save updated flags
                    bra       AnimRet             your done so leave
AnimCycleNorm       ldd       $0E,u               load loop/cel counters
                    decb                          decrement frame counter (B)
                    std       <AnimStep           save updated counters to scratch
                    lda       <$23,u              load cycle mode
                    cmpa      #$00                is it zero?
                    bne       AnimCycleRev        no test for next num
                    ldb       <AnimStep           load current cel index
                    incb                          advance to next cel
                    cmpb      <AnimStepMax        past last cel?
                    bls       AnimUpdateCell      head for exit
                    clrb                          wrap back to cel 0
                    bra       AnimUpdateCell      head for exit
AnimCycleRev        cmpa      #$03                is it a 3?
                    bne       AnimCycleBounce     no test for next num
                    ldb       <AnimStep           load current cel
                    decb                          step backwards
                    bpl       AnimUpdateCell      head for exit
                    ldb       <AnimStepMax        wrap to last cel
                    bra       AnimUpdateCell      head for exit
AnimCycleBounce     cmpa      #$02                is it a 2?
                    bne       AnimEndOfLoop       no test for next number
                    ldb       <AnimStep           load current cel
                    beq       AnimLoopDone        at cel 0 — signal done
                    decb                          step backwards
                    bne       AnimUpdateCell      head for exit
                    stb       <AnimStep           store new cel index
                    bra       AnimLoopDone        reached cel 0 — signal cycle done
AnimEndOfLoop       cmpa      #$01                is it a 1?
                    bne       AnimUpdateCell      head for exit
                    ldb       <AnimStep           load current cel
                    cmpb      <AnimStepMax        at or past last cel?
                    bcc       AnimLoopDone        yes — signal end-of-loop
                    incb                          advance to next cel
                    cmpb      <AnimStepMax        reached last cel?
                    bne       AnimUpdateCell      head for exit
                    stb       <AnimStep           save final cel index
AnimLoopDone        lda       <$27,u              load end-of-loop flag var index
                    lbsr      SetFlag             set the AGI flag to signal loop done
                    lda       <$26,u              load object flags2
                    anda      #$DF                clear "cycling" bit (bit 5)
                    sta       <$26,u              save updated flags2
                    clra                          zero — clear cycle mode
                    sta       <$21,u              clear direction/motion field
                    sta       <$23,u              clear cycle mode field
                    ldb       <AnimStep           load final cel index
AnimUpdateCell      lbsr      SetCelHelper        install new cel into object
AnimRet             rts

* The bulk of this string of subs called thru the jump table
* use the value passed thru y and the value stowed at ViewObjBase
* to resolve a pointer for use in manipulating the rest of the
* data handled
* These could be consolidated to reduce program size


cmd_fix_loop
CmdFixLoopImpl      lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,x                 X = object pointer
                    lda       <$25,x              load state flags
                    ora       #$20                set "fix loop" bit
                    sta       <$25,x              save updated flags
                    rts

cmd_release_loop
CmdReleaseLoopImpl  lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,x                 X = object pointer
                    lda       <$25,x              load state flags
                    anda      #$DF                clear "fix loop" bit
                    sta       <$25,x              save updated flags
                    rts

TestObjAnimActive   lda       #$01                assume active (return 1)
                    ldb       <$26,u              load object flags
                    andb      #$51                mask: animated + cycling + drawn
                    cmpb      #$51                all three set?
                    beq       TestObjAnimActiveRet yes — object is fully active
                    clra                          no — return 0
TestObjAnimActiveRet rts

TestObjAnimDrawn    lda       #$01                assume drawn (return 1)
                    ldb       <$26,u              load object flags
                    andb      #$51                mask: animated + cycling + drawn
                    cmpb      #$41                animated + drawn (but not cycling)?
                    beq       TestObjAnimDrawnRet yes — object qualifies
                    clra                          no — return 0
TestObjAnimDrawnRet rts

ScanActiveObjs      ldx       #$0548              blit list address for active objs
                    leau      >TestObjAnimActive,pcr predicate: fully active objects
                    lbsr      ScanViewObjs        build blit list from matching objects
                    rts

ScanAnimObjs        ldx       #$054C              blit list address for drawn objs
                    leau      >TestObjAnimDrawn,pcr predicate: animated + drawn
                    lbsr      ScanViewObjs        build blit list from matching objects
                    rts

* ====================================================================
* SPRITE BLIT MANAGEMENT
* Routines for building the active and animated object blit lists,
* then erasing and redrawing all sprites to/from the screen and the
* shadow background buffer. BlitBothErase removes both sprite layers
* from both buffers; BlitBothDraw stamps them back.  Inter-frame
* ordering: erase → update priority/motion → redraw.
* ====================================================================
BlitBothErase       ldx       #$0548              erase active-object blit list
                    lbsr      BlitListDraw        dispatch erase via MMU twiddler
                    ldx       #$054C              erase drawn-object blit list
                    lbsr      BlitListDraw        dispatch erase via MMU twiddler
                    rts

EraseAndBlitShdw    bsr       ScanAnimObjs        rebuild drawn-object list

                    pshs      x                   push list ptr for shdw call
                    lda       #$1E                blitlist_erase()
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler — erase from shadow buf
                    leas      $02,s               clean up the stack

                    bsr       ScanActiveObjs      rebuild active-object list
                    pshs      x                   push list ptr for shdw call
                    lda       #$1E                blitlist_erase()
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler — erase from shadow buf
                    leas      $02,s               clean up stack
                    rts

BlitScrn            ldx       #$054C              blit drawn-object list to screen
                    pshs      x                   push list ptr for scrn call
                    lda       #$18                blit-to-screen opcode
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler — draw to screen buf
                    leas      $02,s               clean up stack

                    ldx       #$0548              blit active-object list to screen
                    pshs      x                   push list ptr for scrn call
                    lda       #$18                blit-to-screen opcode
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler — draw to screen buf
                    leas      $02,s               clean up stack
                    rts

BlitBothDraw        ldx       #$0548              process active-object draw list
                    lbsr      ProcessDrawList     draw each object into priority buf
                    ldx       #$054C              process drawn-object draw list
                    lbsr      ProcessDrawList     draw each object into priority buf
                    rts

cmd_stop_update
CmdStopUpdateImpl   lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    bsr       StopObjUpdate       disable auto-update for this object
                    rts

cmd_start_update
CmdStartUpdateImpl  lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    bsr       StartObjUpdate      enable auto-update for this object
                    rts

cmd_force_update
CmdForceUpdateImpl  lda       ,y+                 consume unused arg byte
                    bsr       BlitBothErase       erase both blit lists
                    bsr       EraseAndBlitShdw    erase shadow buffer
                    bsr       BlitScrn            redraw to screen buffer
                    rts

StopObjUpdate       lda       <$26,u              load object flags
                    bita      #$10                already stopped (update bit clear)?
                    beq       StopObjUpdateRet    yes — nothing to do
                    pshs      u                   save object pointer across blit call
                    lbsr      BlitBothErase       erase object from both lists
                    puls      u                   restore object pointer
                    lda       <$26,u              reload flags
                    anda      #$EF                clear update-enabled bit ($10)
                    sta       <$26,u              save updated flags
                    lbsr      EraseAndBlitShdw    sync shadow buffer
StopObjUpdateRet    rts

StartObjUpdate      lda       <$26,u              load object flags
                    bita      #$10                already started (update bit set)?
                    bne       StartObjUpdateRet   yes — nothing to do
                    pshs      u                   save object pointer across blit call
                    lbsr      BlitBothErase       erase object from both lists
                    puls      u                   restore object pointer
                    lda       <$26,u              reload flags
                    ora       #$10                set update-enabled bit
                    sta       <$26,u              save updated flags
                    lbsr      EraseAndBlitShdw    sync shadow buffer
StartObjUpdateRet   rts


* from obj_base.c of nagi 2002_11_14 except those have one more right turn at the end.

loop_small          fcb       IGNORE,IGNORE
                    fcb       RIGHT,RIGHT,RIGHT
                    fcb       IGNORE
                    fcb       LEFT,LEFT,LEFT

loop_large          fcb       IGNORE,UP
                    fcb       RIGHT,RIGHT,RIGHT
                    fcb       DOWN
                    fcb       LEFT,LEFT,LEFT

cmd_animate_obj
CmdAnimateObjImpl   lda       ,y+                 get object number from script
                    bsr       AnimateObj          activate animation for this object
                    rts

AnimateObj          leas      -$01,s              allocate 1-byte local (object number)
                    sta       ,s                  save object number
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    cmpu      <ViewObjEnd         beyond end of object table?
                    bcs       AnimateObjCheck     no — within bounds
                    lda       #$0D                error code: invalid object number
                    ldb       ,s                  recover object number for message
                    lbsr      ReportError         report out-of-range object
AnimateObjCheck     lda       <$26,u              load object flags
                    bita      #$40                already animated?
                    bne       AnimateObjRet       yes — skip re-initialization
                    lda       #$70                animated + cycling + drawn flags
                    sta       <$26,u              set all three active bits
                    lda       #$00                reset motion and cycle fields
                    sta       <$22,u              clear motion type
                    sta       <$23,u              clear cycle mode
                    sta       <$21,u              clear direction
AnimateObjRet       leas      $01,s               release local byte
                    rts

cmd_unanimate_all
CmdUnanimateAllImpl lbsr      BlitBothErase       erase all objects before deactivating
                    ldu       <ViewObjBase        U = first object in list
UnanimateAllLoop    cmpu      <ViewObjEnd         past end of object list?
                    bcc       UnanimateAllRet     yes — done
                    lda       <$26,u              load object flags
                    anda      #$BE                clear animated + drawn bits
                    sta       <$26,u              save updated flags
                    leau      <$2B,u              advance to next object (43 bytes)
                    bra       UnanimateAllLoop    process next object
UnanimateAllRet     rts

UpdateAllObjs       leas      -$01,s              allocate 1-byte "any animated" flag
                    clr       ,s                  animated-object count = 0
                    ldu       <ViewObjBase        U = first object in list
UpdateAllObjsLoop   cmpu      <ViewObjEnd         past end of list?
                    bcc       AnimObjsDone        yes — finished scanning
                    lda       <$26,u              load object flags
                    anda      #$51                mask: animated + cycling + draw bits
                    cmpa      #$51                all three active?
                    bne       AnimObjNext         no — skip this object
                    inc       ,s                  at least one animated object present
                    ldb       #$04                default loop selection value
                    lda       <$25,u              load object state flags
                    bita      #$20                direction-dependent loop active?
                    bne       AnimCycleStep       yes — skip loop recalculation
                    lda       $0B,u               load loop count
                    cmpa      #$03                3 or fewer loops?
                    bhi       AnimDirLarge        no — use large direction table
                    cmpa      #$02                fewer than 2?
                    bcs       AnimCycleStep       yes — skip direction loop mapping
                    lda       <$21,u              load movement direction
                    leay      >loop_small,pcr     loop_small data address
                    ldb       a,y                 look up loop index for this direction (small)
                    bra       AnimDirMerge        apply selected loop index
AnimDirLarge        lda       <$21,u              load movement direction
                    leay      >loop_large,pcr     loop_large data address
                    ldb       a,y                 look up loop index for this direction (large)
AnimDirMerge        lda       $01,u               load object number
                    cmpa      #$01                is it ego?
                    bne       AnimCycleStep       no — apply loop directly
                    cmpb      #$04                loop 4 (invalid for small set)?
                    beq       AnimCycleStep       yes — skip
                    cmpb      $0A,u               same as current loop?
                    beq       AnimCycleStep       yes — no change needed
                    lbsr      SetLoopHelper       change to new direction-based loop
AnimCycleStep       lda       <$26,u              reload object flags
                    bita      #$20                cycling enabled?
                    beq       AnimObjNext         no — skip animation step
                    lda       <$20,u              load cycle timer
                    beq       AnimObjNext         timer = 0 means already fired
                    dec       <$20,u              decrement cycle timer
                    bne       AnimObjNext         not yet zero — wait
                    lbsr      UpdateObjAnim       advance cel animation
                    lda       <$1F,u              load cycle speed
                    sta       <$20,u              reset cycle timer
AnimObjNext         leau      <$2B,u              advance to next object (43 bytes)
                    bra       UpdateAllObjsLoop   loop over all objects   process next object
AnimObjsDone        lda       ,s                  any animated objects this cycle?
                    beq       AnimObjsDoneRet     no — skip blit
                    ldx       #$0548              blit list address
                    lbsr      BlitListDraw        twiddle mmu
                    lbsr      UpdateAllMotion     apply pending movements
                    lbsr      ScanActiveObjs      rebuild active-object blit list

                    pshs      x                   push blit list for erase
                    lda       #$1E                blitlist_erase()
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldx       #$0548              blit list address
                    pshs      x                   push for screen blit
                    lda       #$18                blit-to-screen opcode
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    ldu       <ViewObjBase        U = ego object
                    lda       <$25,u              load ego state flags
                    anda      #$F6                clear update-pending bits
                    sta       <$25,u              save cleared flags
AnimObjsDoneRet     leas      $01,s               release local flag byte
                    rts

* ====================================================================
* OBJECT MOTION AND ANIMATION UPDATE
* Per-frame pass over every view object. For each object that has
* motion enabled the motion type (wander/follow/move-to/normal) is
* evaluated, the target direction is calculated, and the object is
* advanced one step. Collision with priority bands, the ego border,
* and room edges is resolved. On arrival at a target, the
* corresponding flag is set and the motion type is cleared.
* ====================================================================
UpdateObjMotion     ldu       <ViewObjBase        U = first object in list
UpdateObjMotionLoop cmpu      <ViewObjEnd         past end of object list?
                    bcc       ObjMotionRet        yes — done
                    lda       <$26,u              load object flags
                    anda      #$51                mask: animated + cycling + draw bits
                    cmpa      #$51                all three active?
                    bne       ObjMotionNext       no — skip motion for this object
                    lda       $01,u               load object number
                    cmpa      #$01                is it ego (object 1)?
                    bne       ObjMotionNext       no — skip (only ego gets motion)
                    lda       <$22,u              load motion type
                    beq       ObjBlockCheck       stopped — go check block
                    cmpa      #$01                motion type 1 = wander?
                    bne       ObjMotionFollow     no — check follow
                    lbsr      ObjAnimStep         yes — step wander animation
                    bra       ObjBlockCheck       then check for block collision
ObjMotionFollow     cmpa      #$02                motion type 2 = follow?
                    bne       ObjMotionMove       no — check move-to
                    lbsr      CalcFollowDir       calculate direction toward target
                    bra       ObjBlockCheck       then check for block collision
ObjMotionMove       cmpa      #$03                motion type > 3?
                    bhi       ObjBlockCheck       yes — unknown, skip
                    lbsr      SetObjMotion        apply motion type 3 (move-to)
ObjBlockCheck       lda       <$26,u              reload object flags
                    ldb       >BlockState         state.block_state
                    bne       ObjBlockHit         block active — check collision
                    anda      #$7F                clear block-hit flag
                    sta       <$26,u              save cleared flags
                    bra       ObjMotionNext       proceed without block action
ObjBlockHit         bita      #$02                object set to ignore blocks?
                    bne       ObjMotionNext       yes — skip block check
                    lda       <$21,u              load object direction
                    beq       ObjMotionNext       stopped — no collision
                    bsr       ObjMoveCalc         calculate and apply movement
ObjMotionNext       leau      <$2B,u              advance to next object (43 bytes)
                    bra       UpdateObjMotionLoop loop over all objects
ObjMotionRet        rts

ObjMoveCalc         leas      -$03,s              allocate 3-byte local frame
                    ldd       $03,u               load object x/y position
                    std       $01,s               save current position
                    lbsr      TestInBlock         test current position against block
                    sta       ,s                  save current block-test result
                    lda       <$21,u              load movement direction (1–8)
                    beq       ObjMoveNormal       direction 0 = stopped
                    cmpa      #$01                direction 1 = up?
                    bne       ObjDirUpRight       no — check next
                    ldb       $02,s               y position
                    subb      <$1E,u              subtract step size
                    lda       $01,s               x unchanged
                    bra       ObjMoveApply        apply new position
ObjDirUpRight       cmpa      #$02                direction 2 = up-right?
                    bne       ObjDirRight         no — check next direction
                    ldd       $01,s               load x/y
                    adda      <$1E,u              x += step
                    subb      <$1E,u              y -= step
                    bra       ObjMoveApply        apply new position
ObjDirRight         cmpa      #$03                direction 3 = right?
                    bne       ObjDirDownRight     no — check next direction
                    lda       $01,s               x position
                    adda      <$1E,u              x += step
                    ldb       $02,s               y unchanged
                    bra       ObjMoveApply        apply new position
ObjDirDownRight     cmpa      #$04                direction 4 = down-right?
                    bne       ObjDirDown          no — check next direction
                    ldd       $01,s               load current x/y position
                    adda      <$1E,u              x += step
                    addb      <$1E,u              y += step
                    bra       ObjMoveApply        apply new position
ObjDirDown          cmpa      #$05                direction 5 = down?
                    bne       ObjDirDownLeft      no — check next direction
                    ldb       $02,s               y position
                    addb      <$1E,u              y += step
                    lda       $01,s               x unchanged
                    bra       ObjMoveApply        apply new position
ObjDirDownLeft      cmpa      #$06                direction 6 = down-left?
                    bne       ObjDirLeft          no — check next direction
                    ldd       $01,s               load current x/y position
                    suba      <$1E,u              x -= step
                    addb      <$1E,u              y += step
                    bra       ObjMoveApply        apply new position
ObjDirLeft          cmpa      #$07                direction 7 = left?
                    bne       ObjDirUpLeft        no — direction 8 (up-left)
                    lda       $01,s               x position
                    suba      <$1E,u              x -= step
                    ldb       $02,s               y unchanged
                    bra       ObjMoveApply        apply new position
ObjDirUpLeft        ldd       $01,s               direction 8 = up-left: load x/y
                    suba      <$1E,u              x -= step
                    subb      <$1E,u              y -= step
ObjMoveApply        lbsr      TestInBlock         test new position against block
                    cmpa      ,s                  same block result as before?
                    bne       ObjMoveBlocked      different — object crossed boundary
ObjMoveNormal       lda       <$26,u              clear block-hit flag in flags
                    anda      #$7F                mask off block-hit bit
                    sta       <$26,u              save cleared flags
                    bra       ObjMoveCalcRet      done — no block collision
ObjMoveBlocked      lda       <$26,u              set block-hit flag in flags
                    ora       #$80                set block-hit bit
                    sta       <$26,u              save updated flags
                    clr       <$21,u              stop object (direction = 0)
                    cmpu      <ViewObjBase        is this ego?
                    bne       ObjMoveCalcRet      no — done
                    clr       >$0438              clear ego movement direction
ObjMoveCalcRet      leas      $03,s               release local frame
                    rts

cmd_block
CmdBlockImpl        lda       #$01                set block_state = 1 (block active)
                    sta       >BlockState         state.block_state = 1 (block active)
                    lda       ,y+                 block x1 from bytecode
                    sta       >BlockX1            state.block_x1
                    lda       ,y+                 block y1 from bytecode
                    sta       >BlockY1            state.block_y1
                    lda       ,y+                 block x2 from bytecode
                    sta       >BlockX2            state.block_x2
                    lda       ,y+                 block y2 from bytecode
                    sta       >BlockY2            state.block_y2
                    rts

cmd_unblock
CmdUnblockImpl      clr       >BlockState         state.block_state = 0
                    rts

cmd_ignore_blocks
CmdIgnoreBlocksImpl lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       <$26,u              load objtable[*(c++)]flags
                    ora       #O_BLKIGNORE        set the ignore flag $02
                    sta       <$26,u              stow it back
                    rts

cmd_observe_blocks
CmdObserveBlocksImpl lda      ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       <$26,u              load object flags
                    anda      #^O_BLKIGNORE       clear block-ignore flag ($FD)
                    sta       <$26,u              save updated flags
                    rts

TestInBlock         leas      -$01,s              allocate 1-byte result
                    clr       ,s                  assume not inside block
                    cmpa      >BlockX1            A <= block_x1?
                    bls       TestInBlockRet      yes — outside block
                    cmpa      >BlockX2            A >= block_x2?
                    bcc       TestInBlockRet      yes — outside block
                    cmpb      >BlockY1            B <= block_y1?
                    bls       TestInBlockRet      yes — outside block
                    cmpb      >BlockY2            B >= block_y2?
                    bcc       TestInBlockRet      yes — outside block
                    inc       ,s                  inside all bounds — set result = 1
TestInBlockRet      lda       ,s                  load result (0 = outside, 1 = inside)
                    leas      $01,s               release local byte
                    rts

TestObjContact      clra                          assume no contact (return 0)
                    ldb       <$25,u              load object state flags
                    bitb      #$02                ignore-objects flag set?
                    bne       ObjContactRet       yes — skip contact check
                    ldx       <ViewObjBase        X = first object to scan
TestObjContactLoop  cmpx      <ViewObjEnd         past end of object list?
                    bcc       ObjContactRet       yes — no contact found
                    ldb       <$26,x              load candidate object flags
                    andb      #$41                mask: animated + drawn
                    cmpb      #$41                both set?
                    bne       ObjContactNext      no — skip this object
                    ldb       <$25,x              load candidate state flags
                    bitb      #$02                candidate ignores objects?
                    bne       ObjContactNext      yes — skip
                    ldb       $02,x               load candidate object number
                    cmpb      $02,u               same object as U?
                    beq       ObjContactNext      yes — don't collide with self
                    ldb       $03,u               U's y-bottom edge
                    addb      <$1C,u              add U's height
                    cmpb      $03,x               above candidate's top edge?
                    bcs       ObjContactNext      yes — no vertical overlap
                    ldb       $03,x               candidate's y-bottom edge
                    addb      <$1C,x              add candidate's height
                    cmpb      $03,u               below U's top edge?
                    bcs       ObjContactNext      yes — no vertical overlap
                    ldb       $04,x               candidate priority
                    cmpb      $04,u               equal to U's priority?
                    beq       ObjContactFound     equal — count as contact
                    bhi       ObjPriorityHigher   candidate has higher priority
                    ldb       <$1B,x              candidate width
                    cmpb      <$1B,u              candidate wider than U?
                    bhi       ObjContactFound     yes — overlap
                    bra       ObjContactNext      no — skip
ObjPriorityHigher   ldb       <$1B,x              candidate width
                    cmpb      <$1B,u              candidate narrower than U?
                    bcs       ObjContactFound     yes — overlap
ObjContactNext      leax      <$2B,x              advance to next object (43 bytes)
                    bra       TestObjContactLoop  check next
ObjContactFound     lda       #$01                contact detected — return 1
ObjContactRet       rts

cmd_ignore_objects
CmdIgnoreObjectsImpl lda      ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       <$25,u              load state flags
                    ora       #$02                set ignore-objects bit
                    sta       <$25,u              save updated flags
                    rts

cmd_observe_objects
CmdObserveObjectsImpl lda     ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       <$25,u              load state flags
                    anda      #$FD                clear ignore-objects bit
                    sta       <$25,u              save updated flags
                    rts

cmd_distance
CmdDistanceImpl     lda       ,y+                 get first object number
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get first object pointer
                    tfr       d,x                 X = first object
                    lda       ,y+                 get second object number
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get second object pointer
                    tfr       d,u                 U = second object
                    lda       #$FF                default distance = $FF (not visible)
                    ldb       <$26,x              load first object flags
                    bitb      #$01                first object visible?
                    beq       DistStore           no — store $FF
                    ldb       <$26,u              load second object flags
                    bitb      #$01                second object visible?
                    beq       DistStore           no — store $FF
                    lda       <$1C,u              U's width
                    lsra                          half-width for center X
                    adda      $03,u               add U's x position → center X of U
                    ldb       <$1C,x              X's width
                    lsrb                          half-width for center X
                    addb      $03,x               add X's x position → center X of X
                    stb       <TempMultByte       save X's center X
                    suba      <TempMultByte       A = U.cx - X.cx
                    bcc       DistXDiff           positive — keep as-is
                    nega                          negative — take absolute value
DistXDiff           sta       <TempMultByte       save |dx|
                    lda       $04,u               U's y position
                    suba      $04,x               A = U.y - X.y
                    bcc       DistYDiff           positive — keep as-is
                    nega                          negative — take absolute value
DistYDiff           adda      <TempMultByte       A = |dx| + |dy| (Manhattan distance)
                    bcs       DistOverflow        overflow — clamp to $FE
                    cmpa      #$FF                exactly $FF?
                    bne       DistStore           no — store result
DistOverflow        lda       #$FE                clamp to max valid distance
DistStore           ldb       ,y+                 get destination variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index into variable table
                    sta       ,x                  store computed distance
                    rts

* clears 50 bytes at 05BA
ClearStateVars      ldu       #$05BA              set address of bytes to be cleared
                    ldx       #$0032              set number of bytes to clear to 50
                    clrb                          set value of store there to 00
                    lbsr      FillMem             go clear them
                    rts

cmd_set_key
CmdSetKeyImpl       ldx       #$01D9              X = start of key-mapping table
                    lda       #$32                50 entries to search
SetKeySearchLoop    tst       ,x                  slot empty?
                    beq       SetKeyStore         yes — use this slot
                    deca                          decrement remaining count
                    bne       SetKeySearchNext    not exhausted — keep looking
                    ldx       #$0000              table full — use null slot
                    bra       SetKeyStore         skip search, go store (or discard)
SetKeySearchNext    leax      $02,x               advance to next 2-byte slot
                    bra       SetKeySearchLoop    continue scanning
SetKeyStore         lda       ,y+                 get key code (first arg)
                    ldb       ,y+                 get modifier byte (second arg)
                    beq       SetKeyCtrl          zero modifier — store as-is
                    tfr       b,a                 use modifier as the key value
                    adda      #$FB                remap: $05→$00 ctrl range offset
SetKeyCtrl          ldb       ,y+                 get AGI controller number (third arg)
                    leax      ,x                  test X (null slot means discard)
                    beq       SetKeyRet           null — don't store
                    std       ,x                  store key+controller pair
SetKeyRet           rts

cmd_normal_cycle
CmdNormCycleImpl    lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       #$00                cycle mode 0 = normal forward
                    sta       <$23,u              set cycle mode field
                    lda       <$26,u              load object flags
                    ora       #$20                set cycling-enabled bit
                    sta       <$26,u              save updated flags
                    rts

cmd_end_of_loop
CmdEndOfLoopImpl    lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       #$01                cycle mode 1 = end-of-loop notify
                    sta       <$23,u              set cycle mode field
                    ldd       <$25,u              load state flags (A) and flags2 (B)
                    ora       #$10                set "one-shot done" bit in state flags
                    orb       #$30                set cycling + end-of-loop bits in flags2
                    std       <$25,u              save both flag bytes
                    lda       ,y+                 get flag variable index to signal when done
                    sta       <$27,u              store notify-flag variable index
                    lbsr      ClearFlag           pre-clear the notification flag
                    rts

cmd_reverse_cycle
CmdRevCycleImpl     lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       #$03                cycle mode 3 = reverse cycle
                    sta       <$23,u              set cycle mode field
                    lda       <$26,u              load object flags
                    ora       #$20                set cycling-enabled bit
                    sta       <$26,u              save updated flags
                    rts

cmd_reverse_loop
CmdRevLoopImpl      lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       #$02                cycle mode 2 = reverse loop
                    sta       <$23,u              set cycle mode field
                    ldd       <$25,u              load state flags (A) and flags2 (B)
                    ora       #$10                set "one-shot done" bit in state flags
                    orb       #$30                set cycling + reverse-loop bits in flags2
                    std       <$25,u              save both flag bytes
                    lda       ,y+                 get flag variable index to signal when done
                    sta       <$27,u              store notify-flag variable index
                    lbsr      ClearFlag           pre-clear the notification flag
                    rts

cmd_cycle_time
CmdCycleTimeImpl    lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    ldb       ,y+                 get variable index holding cycle speed
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read cycle-speed value from variable
                    sta       <$1F,u              store as cycle speed
                    sta       <$20,u              store as initial cycle timer
                    rts

cmd_stop_cycling
CmdStopCyclingImpl  lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       <$26,u              load object flags
                    anda      #$DF                clear cycling-enabled bit
                    sta       <$26,u              save updated flags
                    rts

cmd_start_cycling
CmdStartCyclingImpl lda       ,y+                 get object number from script
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    lda       <$26,u              load object flags
                    ora       #$20                set cycling-enabled bit
                    sta       <$26,u              save updated flags
                    rts

StrNormCycle        fcc       'normal cycle'
                    fcb       C$NULL

StrEndOfLoop        fcc       'end of loop'
                    fcb       C$NULL

StrRevLoop          fcc       'reverse loop'
                    fcb       C$NULL

StrRevCycle         fcc       'reverse cycle'
                    fcb       C$NULL

StrNormMotion       fcc       'normal motion'
                    fcb       C$NULL

StrWander           fcc       'wander'
                    fcb       C$NULL

StrFollow           fcc       'follow'
                    fcb       C$NULL

StrMoveTo           fcc       'move to (%d, %d)'
                    fcb       C$NULL

StrObjStatus        fcc       'Object %d:'
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

StrVersion          fcc       'Adventure Game Interpreter'
                    fcb       C$LF
                    fcc       '      Version 2.023'
                    fcb       $00

StrMemStatus        fcc       'room: %u'
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
CmdGetNumImpl       leas      -$54,s              allocate 84-byte input buffer on stack
                    lbsr      InputEditOn         enable input edit mode
                    lda       >$01D8              load current input row
                    clrb                          D = row:0
                    std       <TextRow            save as text cursor row
                    ldb       ,y+                 get message index arg
                    lbsr      GetMsgPtr           resolve message pointer → U
                    ldd       #$0028              column = 0, width = 40
GetNumInputLoop     pshs      d                   save column/width
                    pshs      u                   save message pointer
                    ldd       $08,s               reload row/col
                    pshs      d                   push row/col for MsgTextSetup
                    lbsr      MsgTextSetup        set up text position for message
                    leas      $06,s               clean up MsgTextSetup args
                    pshs      x                   push formatted string ptr
                    lbsr      PrintFmtStrToScr    print message to screen
                    leas      $02,s               clean up PrintFmtStrToScr arg
                    clr       ,s                  initialize input buffer to empty
                    ldb       #$04                max input length = 4 chars
                    leax      ,s                  X = pointer to input buffer
                    lbsr      EditString          get numeric string from user
                    lbsr      InputRedraw         redraw input line after edit
                    leax      ,s                  X = input buffer
                    lbsr      StrLen              measure entered string
                    beq       GetNumDone          empty — skip conversion
                    lbsr      AtoI                convert ASCII string to integer in A
GetNumDone          ldx       #$0432              base of AGI variable table
                    ldb       ,y+                 get destination variable index
StoreNumResult      abx                           index to the variable
                    sta       ,x                  store converted number
                    leas      <$54,s              release local buffer
                    rts

cmd_obj_status_v
CmdObjStatusVImpl   leas      >-$0194,s           allocate 404-byte status display buffer
                    ldx       #$0432              base of AGI variable table
                    ldb       ,y+                 get variable holding object number
                    abx                           index to the variable
                    lda       ,x                  read object number from variable
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    std       >$0192,s            save object pointer in local frame
                    lda       <$23,u              load cycle mode
                    cmpa      #CY_NORM            $00 = normal cycle?
                    bne       CheckCycleEnd       no — check next
                    leax      >StrNormCycle,pcr   point to "normal cycle" string
                    bra       StoreCycleStr       store cycle-mode string pointer
CheckCycleEnd       cmpa      #CY_END             $01 = end-of-loop?
                    bne       CheckCycleRevEnd    no — check next
                    leax      >StrEndOfLoop,pcr   point to "end of loop" string
                    bra       StoreCycleStr       store cycle-mode string pointer
CheckCycleRevEnd    cmpa      #CY_REVEND          $02 = reverse loop?
                    bne       SetRevCycleStr      no — must be reverse cycle
                    leax      >StrRevLoop,pcr     point to "reverse loop" string
                    bra       StoreCycleStr       ** default must be CY_REV #$03
SetRevCycleStr      leax      >StrRevCycle,pcr    point to "reverse cycle" string
StoreCycleStr       stx       >$0190,s            save cycle-mode string pointer
                    lda       <$22,u              load motion mode
                    cmpa      #MT_NORM            $00 = normal motion?
                    bne       CheckMotionWander   no — check next
                    leax      >StrNormMotion,pcr  point to "normal motion" string
                    bra       ObjStatusFormat     go format and display status
CheckMotionWander   cmpa      #MT_WANDER          $01 = wander?
                    bne       CheckMotionFollow   no — check next
                    leax      >StrWander,pcr      point to "wander" string
                    bra       ObjStatusFormat     go format and display status
CheckMotionFollow   cmpa      #MT_FOLLOW          $02 = follow?
                    bne       BuildMoveToStr      no — must be move-to
                    leax      >StrFollow,pcr      point to "follow" string
                    bra       ObjStatusFormat     go format and display status
BuildMoveToStr      clra                          high byte = 0
                    ldb       <$28,u              load move-to target Y
                    pshs      b,a                 push Y coordinate
                    ldb       <$27,u              load move-to target X
                    pshs      b,a                 push X coordinate
                    leax      >StrMoveTo,pcr      pointer to "move to (%d, %d)" format
                    pshs      x                   push format string
                    leax      >$0132,s            point to output buffer in local frame
                    pshs      x                   push output buffer pointer
                    lbsr      PrintFmtStr         format "move to (x, y)" into buffer
                    leas      $08,s               clean up PrintFmtStr args
ObjStatusFormat     pshs      u                   save object pointer
                    leax      >$0192,s            point to object-pointer slot in frame
                    pshs      x                   push pointer to object pointer
                    ldu       >$0196,s            reload object pointer
                    ldd       <$25,u              load state flags and flags2
                    pshs      b,a                 push flags pair
                    clra                          high byte = 0
                    ldb       <$1E,u              load step size
                    pshs      b,a                 push step size
                    ldb       <$24,u              load priority
                    pshs      b,a                 push priority
                    ldb       <$1D,u              load y size
                    pshs      b,a                 push y size
                    ldb       $04,u               load priority band
                    pshs      b,a                 push priority band
                    ldb       <$1C,u              load x size
                    pshs      b,a                 push x size
                    ldb       $03,u               load y position
                    pshs      b,a                 push y position
                    ldb       $02,u               load object number
                    pshs      b,a                 push object number
                    leau      >StrObjStatus,pcr   point to status format string
                    pshs      u                   push format string pointer
                    leax      <$16,s              point to output buffer
                    pshs      x                   push output buffer pointer
                    lbsr      PrintFmtStr         format object status into buffer
                    leas      <$18,s              clean up all args
                    lbsr      message_box         display formatted status in a box
                    leas      >$0194,s            release entire local frame
                    rts

* gfx_picbuff_update() is in the shdw module
* gfx_picbuff_update sets up MMU swaps to get it mapped in
cmd_show_pri
ShowPriImpl         inc       >PicBufRotate       sets gfx_picbuffrotate = 1 (>0)
                    lbsr      gfx_picbuff_update  calls gfx_picbuff_update()
                    lbsr      BooleanPoll         calls user_bolean_poll()
                    lbsr      gfx_picbuff_update  calls gfx_picbuff_update()
                    clr       >PicBufRotate       sets gfx_picbuffrotate = 0
                    rts

cmd_version
ShowVersionImpl     leau      >StrVersion,pcr     version banner
                    lbsr      message_box         message_box()
                    rts

cmd_show_mem
ShowMemImpl         leas      >-$00C8,s           200-byte output buffer on stack
                    ldd       <HeapMax            load heap max size
                    pshs      d                   push as format arg
                    ldd       <HeapBase           load heap base address
                    subd      #$06CE              subtract constant (data segment offset)
                    pshs      d                   push adjusted base as format arg
                    ldd       <HeapEnd            load heap end address
                    subd      <HeapBase           compute heap total size
                    pshs      d                   push as format arg
                    ldd       <HeapTop            load heap top pointer
                    subd      <HeapBase           compute bytes used
                    pshs      d                   push as format arg
                    ldd       <DataBlockSize      load total data block size
                    subd      #$06CE              subtract constant
                    pshs      d                   push as format arg
                    ldd       <MnlnModSize        load mnln module size
                    pshs      d                   push as format arg
                    ldd       <SierraModSize      load sierra module size
                    pshs      d                   push as format arg
                    ldd       <HeapPtr            load current heap pointer
                    pshs      d                   push as format arg
                    ldd       #$FFFF              sentinel value for format end
                    pshs      d                   push sentinel
                    clra                          clear high byte
                    ldb       >$0432              load room number
                    leax      >StrMemStatus,pcr   format string for memory status
                    leau      <$12,s              output buffer address
                    pshs      b,a                 push room number as last arg
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format memory status string
                    leas      <$18,s              advance past pushed args
                    lbsr      message_box         message_box()
                    leas      >$00C8,s            release output buffer
                    rts


* ====================================================================
* CONDITION (TEST) DISPATCH TABLE
* Parallel table to cmd_table for AGI condition bytes.  Each entry
* is a 4-byte (pointer, descriptor) pair indexed by condition opcode.
* Entries are patched by the sierra loader with the segment base.
* ====================================================================
eval_table          fdb       cmd_ret_false,$0000
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


* Same function as sub at FixupCmdTbl just different table
FixupEvalTbl        leas      -01,s               make room on stack for counter
                    lda       #$13                19 entries in eval_table
                    sta       ,s                  store count on stack
                    leau      >eval_table,pcr     get table addr
FixupEvalTblLoop    ldd       <SierraBiasVal      get the load-address bias
                    addd      ,u                  relocate function pointer
                    std       ,u                  write back relocated pointer
                    leau      $04,u               advance past this entry (ptr + arg mask)
                    dec       ,s                  decrement entry count
                    bne       FixupEvalTblLoop    branch till we finish
                    leas      $01,s               clean up stack
                    rts                           return

EvalExpr            leax      -$01,y              point X one byte before condition opcode
                    stx       <SavedYPtr          save for ScriptArgDispatch
                    cmpa      #$12                is opcode > max (18)?
                    bhi       EvalExprUnknown     yes — unknown condition
                    lsla                          ×2 (each entry is 4 bytes, shift twice)
                    lsla                          ×4 = byte offset into eval_table
                    leax      >eval_table,pcr     eval_table base address
                    jsr       [a,x]               dispatch to condition evaluator
                    ldb       <NegCondFlag        check trace mode
                    cmpb      #$01                is trace active?
                    bne       EvalExprRet         no — return result
                    pshs      y                   save Y across ScriptArgDispatch
                    sta       <TempRegA           save condition result
                    ldu       <SavedYPtr          restore pointer to condition start
                    lbsr      ScriptArgDispatch   display condition arguments in trace
                    puls      y                   restore Y
                    lda       <TempRegA           restore condition result
                    bra       EvalExprRet         fall through to return
EvalExprUnknown     tfr       a,b                 move unknown opcode to B
                    lda       #$0F                error code for unknown condition
                    lbsr      ReportError         report it
EvalExprRet         rts

cmd_equal_n
CmdEqualNImpl       ldb       ,y+                 get variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read variable value
                    cmpa      ,y+                 compare with immediate operand
                    lbne      RetFalse            not equal — return false
                    lbra      RetTrue             equal — return true

cmd_equal_v
CmdEqualVImpl       ldb       ,y+                 get first variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to first variable
                    lda       ,x                  read first variable value


                    ldb       ,y+                 get second variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to second variable
                    cmpa      ,x                  compare first and second variable
                    lbne      RetFalse            not equal — return false
                    lbra      RetTrue             equal — return true

cmd_less_n
CmdLessNImpl        ldb       ,y+                 get variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read variable value
                    cmpa      ,y+                 compare with immediate operand
                    lbcc      RetFalse            A >= immediate — return false
                    lbra      RetTrue             A < immediate — return true

cmd_less_v
CmdLessVImpl        ldb       ,y+                 get first variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to first variable
                    lda       ,x                  read first variable value

                    ldb       ,y+                 get second variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to second variable
                    cmpa      ,x                  compare first and second variable
                    lbcc      RetFalse            first >= second — return false
                    lbra      RetTrue             first < second — return true

cmd_greater_n
CmdGreaterNImpl     ldb       ,y+                 get variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read variable value
                    cmpa      ,y+                 compare with immediate operand
                    lbls      RetFalse            A <= immediate — return false
                    lbra      RetTrue             A > immediate — return true

cmd_greater_v
CmdGreaterVImpl     ldb       ,y+                 get first variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to first variable
                    lda       ,x                  read first variable value

                    ldb       ,y+                 get second variable index
                    ldx       #$0432              base of AGI variable table
                    abx                           index to second variable
                    cmpa      ,x                  compare first and second variable
                    lbls      RetFalse            first <= second — return false
                    lbra      RetTrue             first > second — return true

cmd_isset
CmdIssetImpl        lda       ,y+                 get flag index from script
                    lbsr      TestFlag            test the AGI flag
                    lbeq      RetFalse            flag clear — return false
                    lbra      RetTrue             flag set — return true

cmd_isset_v
CmdIssetVImpl       ldb       ,y+                 get variable index holding flag number
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read flag number from variable
                    lbsr      TestFlag            test the AGI flag
                    lbeq      RetFalse            flag clear — return false
                    lbra      RetTrue             flag set — return true
                    rts

cmd_has
CmdHasImpl          ldb       ,y+                 get object number from script
                    ldx       <BlockPtr           base of game object table
                    abx                           ×1 (each entry pointer is 1 byte here)
                    abx                           ×2
                    abx                           ×3 — offset to object room byte
                    lda       #$FF                $FF = "in inventory" sentinel
                    cmpa      $02,x               object in inventory?
                    lbne      RetFalse            no — return false
                    lbra      RetTrue             yes — return true

cmd_obj_in_room
CmdObjInRoomImpl    ldb       $01,y               get variable index for room
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read current room number from variable
                    ldb       ,y++                get object number (advance Y twice)
                    ldx       <BlockPtr           base of game object table
                    abx                           ×1 (each entry is 1 byte, so 3 abx = ×3)
                    abx                           ×2
                    abx                           ×3 — offset to object room byte
                    cmpa      $02,x               object in that room?
                    lbne      RetFalse            no — return false
                    lbra      RetTrue             yes — return true

cmd_controller
CmdControllerImpl   lda       ,y+                 get controller index from script
                    ldx       #$05BA              base of controller-state table
                    lda       a,x                 read controller state byte
                    rts

cmd_have_key
CmdHaveKeyImpl      ldx       #$0432              base of AGI variable table
                    lda       <$13,x              load pending key variable ($13 = var 19)
                    lbne      RetTrue             already have a key — return true
HaveKeyPollLoop     lbsr      GetKeyEvent         poll for a key event
                    cmpa      #$FF                no event ($FF)?
                    beq       HaveKeyPollLoop     yes — keep polling
                    tsta                          key code = 0?
                    lbeq      RetFalse            no key mapped — return false
                    sta       <$13,x              store key code in pending-key variable
                    lbra      RetTrue             key received — return true

cmd_said
CmdSaidImpl         lda       ,y+                 get word count from script
                    sta       <WordMatchCnt       save number of words to match
                    lda       >$015A              load "input parsed" flag
                    beq       SaidCheckDone       no input parsed — skip
                    sta       <WordMatchFlag      init word-match counter from parsed count
                    lda       >$01AF              load input-state flags
                    anda      #$08                isolate "already matched" bit
                    bne       SaidCheckDone       already matched this cycle — skip
                    lda       >$01AF              reload input-state flags
                    anda      #$20                isolate "input available" bit
                    beq       SaidCheckDone       no input available — skip
                    ldx       #$0195              X = base of parsed word table
SaidMatchLoop       lda       <WordMatchCnt       words left to match?
                    beq       SaidCheckDone       no — done (all remaining consumed)
                    ldb       ,y+                 load high byte of word token
                    lda       ,y+                 load low byte of word token
                    dec       <WordMatchCnt       decrement remaining word count
                    cmpd      #$270F              is it "any word" wildcard ($270F)?
                    bne       SaidCheckWild       no — compare normally
                    lda       <WordMatchCnt       remaining words after wildcard
                    beq       SaidSetMatch        zero remaining — we have a match
                    lsla                          ×2 (each token is 2 bytes)
                    leay      a,y                 skip remaining tokens in said list
                    lbra      SaidSetMatch        count as matched
SaidCheckWild       tst       <WordMatchFlag      any words in parsed input?
                    bne       SaidWordCompare     yes — compare against input word
                    inc       <WordMatchFlag      advance past "no more input" state
                    lbra      SaidCheckDone       input exhausted — no match
SaidWordCompare     cmpd      ,x++                compare token against next parsed word
                    beq       SaidWordMatch       match — continue
                    cmpd      #$0001              is parsed word "any word" ($0001)?
                    bne       SaidCheckDone       no — mismatch
SaidWordMatch       dec       <WordMatchFlag      one more input word consumed
                    bra       SaidMatchLoop       process next said token
SaidCheckDone       ldd       <WordMatchCnt       any unmatched tokens remaining?
                    bne       SaidNoMatch         yes — not a complete match
SaidSetMatch        lda       >$01AF              set "matched this cycle" bit
                    ora       #$08                set bit 3 (said-matched flag)
                    sta       >$01AF              write back updated flags
                    lbra      RetTrue             return true
SaidNoMatch         lsla                          ×2 (skip remaining 2-byte tokens)
                    leay      a,y                 advance Y past unmatched tokens
                    lbra      RetFalse            return false

cmd_compare_strings
CmdCompareStrImpl   lda       ,y+                 get first string index
                    ldb       ,y+                 get second string index
                    lbsr      MatchWord           compare string[A] against string[B]
                    rts

cmd_posn
CmdPosnImpl         bsr       GetObjViewPtr       resolve object pointer and get x/y
                    sta       <ObjXPos            save x position
                    sta       <ObjXRight          both edges = left edge (exact posn)
                    bra       TestPosnX           compare x against bounding box

cmd_center_posn
CmdCenterPosnImpl   bsr       GetObjViewPtr       resolve object pointer and get x/y
                    sta       <ObjXPos            save x position
                    lda       <$1C,u              load object width
                    lsra                          half-width for center offset
                    adda      <ObjXPos            add to x to get center x
                    sta       <ObjXPos            save center x
                    sta       <ObjXRight          both edges = center x
                    bra       TestPosnX           compare x against bounding box

cmd_right_posn
CmdRightPosnImpl    bsr       GetObjViewPtr       resolve object pointer and get x/y
                    adda      <$1C,u              add object width to x
                    deca                          subtract 1 for zero-based right edge
                    sta       <ObjXPos            save right-edge x
                    sta       <ObjXRight          both edges = right edge
                    bra       TestPosnX           compare x against bounding box

cmd_obj_in_box
CmdObjInBoxImpl     bsr       GetObjViewPtr       resolve object pointer and get x/y
                    sta       <ObjXPos            save left-edge x
                    adda      <$1C,u              add object width for right-edge
                    deca                          subtract 1 for zero-based right edge
                    sta       <ObjXRight          save right-edge x
                    bra       TestPosnX           compare x against bounding box
GetObjViewPtr       ldb       ,y+                 get object number from script
                    lda       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    ldd       $03,u               load x (A) and y (B) position
                    stb       <TempObjByte        save y for later TestPosnY comparison
                    rts

TestPosnX           ldd       <ObjXPos            A = left/center/right x, B = y
                    cmpa      ,y+                 x >= box_x1?
                    bcc       TestPosnY           yes — check y lower bound
                    leay      $03,y               skip remaining 3 arg bytes
                    bra       RetFalse            outside box — return false
TestPosnY           cmpb      ,y+                 y >= box_y1?
                    bcc       TestPosnXRight      yes — check x upper bound
                    leay      $02,y               skip remaining 2 arg bytes
                    bra       RetFalse            outside box — return false
TestPosnXRight      lda       <ObjXRight          load right-edge x
                    cmpa      ,y+                 right x <= box_x2?
                    bls       TestPosnYBot        yes — check y upper bound
                    leay      $01,y               skip remaining 1 arg byte
                    bra       RetFalse            outside box — return false
TestPosnYBot        cmpb      ,y+                 y <= box_y2?
                    bls       RetTrue             yes — inside box — return true
                    bra       RetFalse            outside box — return false

RetTrue             lda       #$01                return value = true
                    rts

RetFalse            clra                          return value = false

cmd_ret_false
CmdRetFalseImpl     rts                           called from eval_table cmd_return_false

cmd_draw
CmdDrawImpl         lda       ,y+                 get object number from script
                    pshs      y                   save script pointer
                    bsr       DrawObjHelper       make object visible
                    puls      y                   restore script pointer
                    rts

DrawObjHelper       leas      -$03,s              allocate 3-byte local frame
                    sta       ,s                  save object number
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    cmpu      <ViewObjEnd         beyond end of object table?
                    bcs       DrawObjCheckView    no — within bounds
                    lda       #$13                error code: invalid object number
                    ldb       ,s                  recover object number for message
                    lbsr      ReportError         report out-of-range error
DrawObjCheckView    ldd       <$10,u              load view resource ID
                    bne       DrawObjStart        non-zero — view is loaded, proceed
                    lda       #$14                error code: no view loaded for object
                    lbsr      ReportError         report missing view
DrawObjStart        lda       <$26,u              load object flags
                    bita      #$01                already visible (drawn)?
                    bne       DrawObjDone         yes — skip re-draw
                    stu       $01,s               save object pointer in local frame
                    ora       #$10                set update-pending bit
                    sta       <$26,u              save updated flags
                    lbsr      FindObjPos          calculate initial screen position
                    ldd       <$10,u              load view resource pointer
                    std       <$12,u              save as current view pointer
                    ldd       $08,u               load loop/cel data
                    std       <$14,u              save as current loop/cel
                    ldd       $03,u               load x/y position
                    std       <$1A,u              save as previous x/y position
                    ldx       #$0548              blit list address
                    lbsr      BlitListDraw        erase current blit list
                    ldu       $01,s               restore object pointer
                    lda       <$26,u              reload flags
                    ora       #$01                set visible bit
                    sta       <$26,u              save updated flags
                    lbsr      ScanActiveObjs      rebuild active-object blit list

                    pshs      x                   push list ptr for shadow erase
                    lda       #$1E                blitlist_erase()
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler — erase from shadow
                    leas      $02,s               clean up the stack

                    ldu       $01,s               restore object pointer
                    lda       <$25,u              load state flags
                    anda      #$EF                clear "one-shot done" bit
                    sta       <$25,u              save updated state flags
                    pshs      u                   push object pointer for screen draw
                    lda       #$1B                draw-single-object opcode
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler — draw to screen
                    leas      $02,s               clean up stack

DrawObjDone         leas      $03,s               release local frame
                    rts

cmd_erase
CmdEraseImpl        lda       ,y+                 get object number from script
                    pshs      y                   save script pointer
                    bsr       EraseObjHelper      make object invisible
                    puls      y                   restore script pointer
                    rts

EraseObjHelper      leas      -$04,s              allocate 4-byte local frame
                    sta       ,s                  save object number
                    ldb       #$2B                43 bytes per object entry
                    mul                           scale to object table offset
                    addd      <ViewObjBase        add base to get object pointer
                    tfr       d,u                 U = object pointer
                    cmpu      <ViewObjEnd         beyond end of object table?
                    bcs       EraseObjCheck       no — within bounds
                    lda       #$0C                error code: invalid object number
                    ldb       ,s                  recover object number for message
                    lbsr      ReportError         report out-of-range error
EraseObjCheck       lda       <$26,u              load object flags
                    bita      #$01                currently visible (drawn)?
                    beq       EraseObjDone        no — nothing to erase
                    stu       $01,s               save object pointer in local frame
                    ldx       #$0548              active-object blit list
                    lbsr      BlitListDraw        dispatch erase via MMU twiddler
                    ldu       $01,s               restore object pointer
                    lda       <$26,u              reload flags
                    anda      #$10                isolate update-enabled bit
                    sta       $03,s               save for branch below
                    bne       EraseObjDraw        update-enabled — skip drawn-list erase
                    ldx       #$054C              drawn-object blit list
                    lbsr      BlitListDraw        dispatch erase via MMU twiddler
                    ldu       $01,s               restore object pointer
EraseObjDraw        lda       <$26,u              reload flags
                    anda      #$FE                clear visible bit
                    sta       <$26,u              save updated flags
                    lda       $03,s               was update-enabled?
                    bne       EraseObjScan        yes — skip drawn-list shadow erase
                    lbsr      ScanAnimObjs        rebuild drawn-object list

                    pshs      x                   push list ptr for shadow erase
                    lda       #$1E                blitlist_erase()
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler — erase from shadow
                    leas      $02,s               clean up the stack

EraseObjScan        lbsr      ScanActiveObjs      rebuild active-object list

                    pshs      x                   push list ptr for shadow erase
                    lda       #$1E                blitlist_erase()
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler — erase from shadow
                    leas      $02,s               clean up the stack

                    ldu       $01,s               restore object pointer
                    pshs      u                   push object pointer for screen update
                    lda       #$1B                draw-single-object opcode
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler — sync screen
                    leas      $02,s               clean up stack

EraseObjDone        leas      $04,s               release local frame
                    rts

StrAvisDurgan       fcc       'Avis Durgan'
StrAvisDurganEnd    fcb       C$NULL


XorDecrypt          leas      -$02,s              save key pointer on stack
                    stu       ,s                  save U (key pointer)
                    leau      >StrAvisDurgan,pcr  point U to start of key string
XorDecryptLoop      cmpx      ,s                  X reached end of data?
                    bcc       XorDecryptDone      yes — done
                    tst       ,u                  end of key string (null byte)?
                    bne       XorDecryptWrap      no — use current key byte
                    leau      >StrAvisDurgan,pcr  yes — reset U to start of key
XorDecryptWrap      lda       ,x                  load ciphertext byte
                    eora      ,u+                 XOR with key byte, advance key pointer
                    sta       ,x+                 store decrypted byte, advance data pointer
                    bra       XorDecryptLoop      process next byte
XorDecryptDone      leas      $02,s               release saved U
                    rts


StrBell             fcb       C$BELL,C$NULL

StrQuitMsg          fcb       C$LF
                    fcc       'Press CTRL-BREAK to quit.'
                    fcb       C$NULL

StrTryAgain         fcb       C$LF
                    fcc       'Press ENTER to try again.'
                    fcb       C$NULL

StrSysError         fcc       'System error #%u.%s%s'
                    fcb       C$NULL


ReportError         sta       >$0443              save error code A
ReportErrorB        stb       >$0444              save error detail B
                    lbsr      ResetHeap           free heap to clean state
                    lbsr      events_clear        discard pending input events
                    lbsr      ResetGameTables     restore game state tables
                    bsr       RingBell            ring the bell
                    bsr       RingBell            ring the bell
                    lbsr      RestoreStackFrame   unwind to safe stack level

ErrorDialog         leas      >-$00B1,s           177-byte output buffer on stack
                    lbsr      InputEditOn         input_edit_on
                    bsr       RingBell            ring the bell
                    bsr       RingBell            ring the bell
ErrorFormatMsg      leau      >StrQuitMsg,pcr     "Quit game" option string
                    pshs      u                   push as format arg
                    leau      >StrTryAgain,pcr    "Try again" option string
                    pshs      u                   push as format arg
                    clra                          zero high byte
                    ldb       >$015B              load current error (script line#?)
                    leau      >StrSysError,pcr    format string for error dialog
                    leax      $04,s               X = output buffer (past pushed args)
                    pshs      b,a                 push error number
                    pshs      u                   push format string
ErrorShowMsg        pshs      x                   push output buffer
                    lbsr      PrintFmtStr         build error message string
                    leas      $0A,s               release pushed args
                    lbsr      message_box         message_box()
ErrorCleanupRet     leas      >$00B1,s            release 177-byte error-handler frame
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

RingBell            pshs      y                   save current y
                    ldy       #$0002              two bytes: bell $07 and null
                    lda       #StdOut             path = stdout ($01)
                    leax      >StrBell,pcr        load address of bell string
                    os9       I$Write             write bell character to terminal
                    puls      y                   restore Y
                    rts

NumConvBuf          fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00

NumConvEnd          fcb       $00

NumZeroPad          fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00
                    fcb       $00,$00

StrLen              leas      -$02,s              allocate 2-byte local (save X)
                    stx       ,s                  save start pointer
StrLenLoop          lda       ,x+                 load byte and advance
                    bne       StrLenLoop          not null — keep scanning
                    tfr       x,d                 D = pointer past null terminator
                    ldx       ,s                  X = original start pointer
                    subd      ,s                  D = end+1 - start
                    subd      #$0001              subtract 1 to exclude null
                    leas      $02,s               release local storage
                    rts

StrCopy             pshs      u                   save destination start for return
StrCopyLoop         lda       ,x+                 load source byte and advance
                    sta       ,u+                 store to destination and advance
                    bne       StrCopyLoop         not null — continue
                    puls      x                   return destination start in X
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

MemCopyNull         leas      -$04,s              make room on stack
                    std       ,s                  save byte count on stack
                    stu       $02,s               save destination pointer
MemCopyLoop         lda       ,x+                 copy byte from source and advance
                    sta       ,u+                 store to destination and advance
                    beq       MemCopyDone         null byte transferred — done
                    ldd       ,s                  reload remaining count
                    subd      #$0001              decrement it
                    std       ,s                  save updated count
                    bne       MemCopyLoop         not zero — copy more
                    clr       ,u                  write null to close the destination
MemCopyDone         ldx       $02,s               return destination start in X
                    leas      $04,s               clean up stack
                    rts

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

StrAppend           pshs      u                   save destination start for return
StrAppendFindEnd    lda       ,u+                 scan forward looking for null
                    bne       StrAppendFindEnd    not null — keep scanning
                    leau      -$01,u              back up to the null position
StrAppendCopy       lda       ,x+                 load source byte and advance
                    sta       ,u+                 store at end of destination and advance
                    bne       StrAppendCopy       not null — continue copying
                    puls      x                   return original destination start in X
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

StrCompare          pshs      u,x                 save original addresses
StrCompareLoop      lda       ,x                  load byte from string 1
                    suba      ,u+                 subtract string 2 byte, advance U
                    bne       StrCompareRet       difference found — strings differ
                    tst       ,x+                 test for null, advance X
                    bne       StrCompareLoop      not null — compare next byte
StrCompareRet       puls      u,x                 restore both pointers
                    rts

* converts 0-9 string to decimal number
* x contains the address of the string

AtoI                leas      -$02,s              allocate 2-byte local accumulator
                    clra                          clear high byte
                    sta       ,s                  running total = 0
                    sta       $01,s               scratch digit = 0
AtoISkipSpace       ldb       ,x+                 get next byte and advance
                    cmpb      #C$SPAC             space character?
                    beq       AtoISkipSpace       yes — skip leading spaces
AtoIDigitLoop       cmpb      #'0                 below '0'?
                    blo       AtoIDone            yes — non-digit, done
                    cmpb      #'9                 above '9'?
                    bhi       AtoIDone            yes — non-digit, done
                    subb      #'0                 convert ASCII digit to 0–9
                    stb       $01,s               save current digit
                    lda       #10                 multiplier
                    ldb       ,s                  running total so far
                    mul                           total × 10
                    addb      $01,s               add current digit
                    stb       ,s                  save updated total
                    ldb       ,x+                 fetch next character
                    bne       AtoIDigitLoop       not null — process next digit
AtoIDone            lda       ,s                  load converted integer into A
                    leas      $02,s               release local storage
                    rts

UIntToDecStr        leax      >NumConvEnd,pcr     point past conversion buffer
                    clr       ,x                  null-terminate buffer
UIntToDecLoop       ldu       #$000A              divisor = 10
                    bsr       UIntDivide          D / 10 → quotient in U, remainder in B
                    addb      #$30                convert remainder to ASCII digit
                    stb       ,-x                 prepend digit to buffer
                    tfr       u,d                 move quotient to D
                    cmpd      #$0000              quotient exhausted?
                    bhi       UIntToDecLoop       no — process next digit
                    rts

UIntToHexStr        leax      >NumConvEnd,pcr     point past conversion buffer
                    clr       ,x                  null-terminate buffer
UIntToHexLoop       ldu       #$0010              divisor = 16
                    bsr       UIntDivide          D / 16 → quotient in U, remainder in B
                    addb      #$30                convert to ASCII digit base
                    cmpb      #$39                above '9'?
                    ble       UIntToHexStoreDigit no — digit is 0–9
                    addb      #$07                yes — shift to 'A'–'F'
UIntToHexStoreDigit stb       ,-x                 prepend hex digit to buffer
                    tfr       u,d                 move quotient to D
                    cmpd      #$0000              quotient exhausted?
                    bhi       UIntToHexLoop       no — process next digit
                    rts

UIntDivide          leas      -$05,s              allocate 5-byte local frame
                    std       ,s                  save dividend (D)
                    stu       $02,s               save divisor (U)
                    lda       #$10                bit count = 16
                    sta       $04,s               save bit counter
                    ldd       #$0000              remainder = 0
UIntDivideLoop      lsl       $01,s               shift dividend low byte left
                    rol       ,s                  shift dividend high byte, carry in
                    rolb                          shift remainder left, bring in quotient bit
                    rola                          continue 16-bit left shift
                    cmpd      $02,s               remainder >= divisor?
                    bcs       UIntDivideShift     no — don't subtract
                    subd      $02,s               yes — subtract divisor from remainder
                    inc       $01,s               set quotient bit (low byte of dividend)
UIntDivideShift     dec       $04,s               decrement bit counter
                    bne       UIntDivideLoop      not done — process next bit
                    ldu       ,s                  return quotient in U (low 16 bits of dividend)
                    leas      $05,s               release local frame
                    rts

StrZeroPad          leas      -$0B,s              allocate 11-byte local frame
                    pshs      x,b                 save original X and B (desired width)
                    tfr       u,x                 X = source string pointer
                    leau      $04,s               U = local copy buffer
                    lbsr      StrCopy             copy source string into local buffer
                    lbsr      StrLen              measure copied string length → B
                    stb       $03,s               save actual string length
                    leau      >NumZeroPad,pcr     U = 10-byte zero-pad buffer
                    ldx       #$000A              fill length = 10
                    ldb       #$30                fill value = ASCII '0'
                    lbsr      FillMem             fill pad buffer with '0' characters
                    puls      b                   recover desired field width
                    subb      $02,s               width - actual length = padding count
                    bpl       StrZeroPadDo        positive — pad needed
                    clrb                          negative — no padding
StrZeroPadDo        clr       b,u                 null-terminate pad string at correct length
                    leax      $03,s               X = address of local string copy
                    lbsr      StrAppend           append string after zero padding
                    tfr       x,u                 U = result pointer (to caller)
                    puls      x                   restore original X
                    leas      $0B,s               release local frame
                    rts

* tests for A-Z in accumulator a
* and if found returns a-z
ToLower             cmpa      #'A                 below 'A'?
                    blo       ToLowerRet          yes — not uppercase, return as-is
                    cmpa      #'Z                 above 'Z'?
                    bhi       ToLowerRet          yes — not uppercase, return as-is
                    ora       #$20                set lowercase bit (A→a, B→b, etc.)
ToLowerRet          rts

cmd_random
CmdRandomImpl       lbsr      InitRandSeed        generate random byte in B
                    lda       $01,y               load upper bound
                    suba      ,y++                subtract lower bound (D=range, Y+=2)
                    inca                          range is inclusive, add 1
                    bne       CmdRandomMod        non-zero range — compute modulo
                    tfr       b,a                 range=256 — use raw random value
                    bra       CmdRandomStore      skip modulo, store directly
CmdRandomMod        lbsr      Div8                B mod A → remainder in A
                    adda      -$02,y              add lower bound to get result
CmdRandomStore      ldx       #$0432              base of AGI variable table
                    ldb       ,y+                 get destination variable index
                    abx                           index to the variable
                    sta       ,x                  store random result
                    rts

FindByte            tst       ,x                  empty table (first byte = 0)?
                    bne       FindByteLoop        no — search
                    ldx       #$0000              table empty — return null pointer
                    bra       FindByteRet         return null
FindByteLoop        cmpa      ,x+                 compare A against current byte
                    bne       FindByte            no match — check next
                    leax      -$01,x              match — back up to the found byte
FindByteRet         rts

* upper to lower case string conversion
* address of string passed in u

StrToLower          tfr       u,x                 U → X as working pointer
StrToLowerLoop      lda       ,x                  load current character
                    beq       StrToLowerDone      null — end of string
                    bsr       ToLower             convert uppercase to lowercase
                    sta       ,x+                 store result and advance
                    bra       StrToLowerLoop      process next character
StrToLowerDone      rts

JoystickReadInit    lbsr      cmd_init_joy        prompt for joysticks and get results
                    bsr       events_clear        discard stdin & read joysticks
                    rts

events_clear        lbsr      clear_key_queue     drain keyboard input queue
                    lbsr      reset_joy           reset joystick state

                    ldx       #$0103              event queue start address
                    stx       <EvtWritePtr            reset event write pointer
                    stx       <EvtReadPtr            reset event read pointer
                    rts

JoystickPoll        lbsr      PollJoystick        read and queue joystick events
                    lbsr      PollKeyInput        read input and check key-mapping table
                    rts

EventPush           ldu       <EvtWritePtr            U = event queue write pointer
                    stb       ,u+                 store event type byte
                    sta       ,u+                 store event data byte
                    stu       <EvtWritePtr            advance write pointer
                    ldx       #$012B              end-of-buffer address
                    cmpx      <EvtWritePtr            past end?
                    bhi       EventPushWrap       no — no wrap needed
                    ldx       #$0103              wrap: reset write pointer to buffer start
                    stx       <EvtWritePtr            update write pointer
EventPushWrap       ldx       <EvtWritePtr            X = updated write pointer
                    cmpx      <EvtReadPtr            write caught up to read (buffer full)?
                    bne       EventPushRet        no — slot was free
                    leau      -$02,u              yes — back up write, discard this event
                    stu       <EvtWritePtr            restore write pointer (drop event)
EventPushRet        rts

EventPop            ldd       <EvtReadPtr            D = read pointer
                    cmpd      <EvtWritePtr            read == write (queue empty)?
                    bne       EventPopGet         no — entry available
                    ldx       #$0000              return NULL (no event)
                    bra       EventPopRet         return empty-queue sentinel
EventPopGet         ldx       #$0002              offset to advance past current entry
                    leax      d,x                 X = next read position
                    stx       <EvtReadPtr            advance read pointer
                    ldx       #$012B              end-of-buffer address
                    cmpx      <EvtReadPtr            past end?
                    bhi       EventPopAddr        no — pointer is valid
                    ldx       #$0103              wrap: reset read pointer to buffer start
                    stx       <EvtReadPtr            update read pointer
EventPopAddr        tfr       d,x                 X = pointer to popped event
EventPopRet         rts

WaitForEvent        leas      -$02,s              allocate 2-byte timer snapshot
WaitForEventLoop    ldd       >$024B              load current tick counter
                    std       ,s                  save tick snapshot for change detection
                    bsr       EventPop            check for queued event
                    leax      ,x                  event NULL?
                    bne       EventFound          no — process it
WaitPollLoop        ldd       ,s                  load saved tick snapshot
                    cmpd      >$024B              tick counter changed?
                    beq       WaitPollLoop        no — keep spinning
                    lbsr      JoystickPoll        poll joystick for new events
                    bra       WaitForEventLoop    retry event queue
EventFound          lbsr      RemapJoyToKey       translate joystick event to key if needed
                    leas      $02,s               release timer snapshot
                    rts

RemapKeyEvent       leax      ,x                  NULL event?
                    beq       RemapKeyEventRet    yes — nothing to remap
                    ldb       ,x                  load event type byte
                    cmpb      #$01                is it a keypress event?
                    bne       RemapKeyEventRet    no — joystick or other
                    ldu       #$01D9              U = key remap table base
RemapKeyEventLoop   ldb       ,u++                load next remap-from key code
                    beq       RemapKeyEventRet    null terminator — no match
                    cmpb      $01,x               matches event key?
                    bne       RemapKeyEventLoop   no — try next entry
                    lda       #$03                match: event type = remapped
                    ldb       -$01,u              load remap-to value
                    std       ,x                  overwrite event type+data in queue
RemapKeyEventRet    rts


GetKeyEvent         lbsr      JoystickPoll        poll joystick for new events
                    bsr       EventPop            pop next event from queue
                    tfr       x,d                 save event pointer in D
                    leax      ,x                  NULL event?
                    beq       GetKeyEventRet      leave
                    bsr       RemapJoyToKey       translate joystick event to key
                    lda       ,x                  load event type
                    cmpa      #$01                is it a keypress?
                    bne       GetKeyNotFound      no — return $FF (no key)
                    lda       $01,x               load key character
GetKeyEventRet      rts

GetKeyNotFound      lda       #$FF                signal: no key in queue
                    rts


WaitKeyNonNull      bsr       GetKeyEvent         poll for a keypress
                    beq       WaitKeyNonNull      no event — keep waiting
                    cmpa      #$FF                non-key event (joy/etc)?
                    beq       WaitKeyNonNull      yes — keep waiting
                    rts


WaitEnterOrEsc      bsr       GetKeyEvent         poll for a keypress
                    tfr       a,b                 save key in B
                    lda       #$01                assume Enter (return 1)
                    cmpb      #$0D                Enter key?
                    beq       WaitEnterOrEscRet   leave
                    lda       #$00                assume Escape (return 0)
                    cmpb      #$1B                Escape key?
                    beq       WaitEnterOrEscRet   leave
                    lda       #$FF                neither — signal: keep waiting
WaitEnterOrEscRet   rts


BooleanPoll         lbsr      events_clear        events_clear
BooleanPollLoop     bsr       WaitEnterOrEsc      wait for Enter or Escape
                    bmi       BooleanPollLoop     $FF returned — not done yet
                    rts


RemapJoyToKey       lda       ,x                  load event type
                    cmpa      #$01                is it already a keypress?
                    bne       RemapJoyToKeyRet    leave
                    lda       $01,x               load key code
                    cmpa      #$FC                joystick fire 1 ($FC)?
                    bne       RemapJoyToEsc       no — check fire 2
                    lda       #$0D                map fire 1 → Enter
                    bra       StoreRemappedKey    store remapped key code
RemapJoyToEsc       cmpa      #$FE                joystick fire 2 ($FE)?
                    bne       RemapJoyToKeyRet    leave
                    lda       #$1B                map fire 2 → Escape
StoreRemappedKey    sta       $01,x               overwrite key code in event
RemapJoyToKeyRet    rts


* these get accessed for a getstat call
* if a call to the Seek routine contained a value in b
                    fcb       SS.Pos              $05
                    fcb       SS.Size             $02

*        Think these values have no significance
*        and are just junk place holders ??
DataPathBuf         fcb       $2E
DataPathEntry       fcb       $2E,$0D
DataPathNull        fcb       $00

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


CreateFile          pshs      x,d                 save path pointer and access/attr
                    bsr       DeleteFile          delete any existing file first
                    clr       >$015B              clear error code holder
                    puls      x,b,a               restore path/attr/mode for create
                    os9       I$Create
CreateOkChk         bcc       CreateRet           create succeeded — return
                    lbsr      OsErrorHandler      handle OS error
CreateRet           rts

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


OpenFile            clr       >$015B              clear error code holder
                    os9       I$Open
                    bcc       OpenFileRet         open succeeded — return
                    lbsr      OsErrorHandler      handle OS error
OpenFileRet         rts

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

ReadFile            clr       >$015B              clear error code holder
                    os9       I$Read
                    bcc       ReadFileRet         read succeeded — return
                    lbsr      OsErrorHandler      handle OS error
                    ldy       #$0000              zero bytes read on error
ReadFileRet         tfr       y,d                 return byte count in D
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

WriteFile           clr       >$015B              clear error code holder
                    os9       I$Write
                    bcc       WriteFileRet        write succeeded — return
                    lbsr      OsErrorHandler      handle OS error
                    ldy       #$0000              zero bytes written on error
WriteFileRet        tfr       y,d                 return byte count in D
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

DeleteFile          clr       >$015B              clear error code holder
                    os9       I$Delete
                    bcc       DeleteFileRet       delete succeeded — return
                    lbsr      OsErrorHandler      handle OS error
DeleteFileRet       rts

* Close Path - terminates an I/O path
* entry:
*       a -> path number
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

CloseFilePath       clr       >$015B              clear error code holder
                    os9       I$Close
                    bcc       CloseFilePathRet    close succeeded — return
                    lbsr      OsErrorHandler      handle OS error
CloseFilePathRet    rts

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

SeekFile            clr       >$015B              clear error code holder
                    tstb                          B non-zero = relative seek requested
                    bne       GetSttSeek          yes — get file size first
                    os9       I$Seek              B=0 — seek to absolute position
                    bcc       SeekFileRet         seek succeeded — return
SeekFileErr         lbsr      OsErrorHandler      handle OS error
                    ldy       #$0000              clear Y after error
                    bra       SeekFileRet         return error result

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

GetSttSeek          stx       <SeekMSW            save caller's MSW offset
                    stu       <SeekLSW            save caller's LSW offset
                    leau      >RemapJoyToKeyRet,pcr point to SS.Pos/SS.Size bytes above
                    ldb       b,u                 use B as index into SS.Pos/SS.Size table
                    os9       I$GetStt            get current file position/size
                    bcs       SeekFileErr         error — handle it
                    pshs      a                   save path number

                    tfr       u,d                 D = GetStt LSW result
                    addd      <SeekLSW            add caller's LSW offset
                    tfr       d,u                 U = new LSW position

                    tfr       x,d                 D = GetStt MSW result

                    adcb      #$00                propagate carry from LSW add (rarely fires)
                    adca      #$00                propagate carry into MSW high byte

                    addd      <SeekMSW            add caller's MSW offset
                    tfr       d,x                 X = new MSW position

                    puls      a                   restore path number
                    os9       I$Seek              seek to computed position
                    bcs       SeekFileErr         error — handle it
SeekFileRet         rts

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

DupPath             clr       >$015B              clear error code holder
                    os9       I$Dup
                    bcc       DupPathRet          dup succeeded — return
                    lbsr      OsErrorHandler      handle OS error
DupPathRet          rts



GetDeviceName       leas      <-$22,s             allocate 2-byte Y save + 32-byte device name buffer
                    sty       ,s                  save Y (output pointer)
                    clra                          zero high byte
                    sta       ,y                  clear first byte at output pointer
                    sta       <OpenPathCnt        clear open path counter
                    leax      >DataPathEntry,pcr  X = "."+CR path for current directory
                    lbsr      OpenDirPath         open current directory path
                    bcs       GetDeviceNameClose  error — close and return
                    sta       <PathNum            save opened path number

                    ldb       #SS.DevNm           GetStt function: get device name
                    leax      $02,s               X = 32-byte name buffer in local frame
                    os9       I$GetStt            request device name
                    bcs       GetDeviceNameClose  error — close and return
                    ldy       ,s                  restore Y (output pointer)
                    ldb       #'/                 write leading slash
                    stb       ,y+                 store '/' at output pointer, advance
                    ldd       ,x++                load first two chars of device name
                    andb      #$7F                strip high bit from second char
                    std       ,y++                write two device name chars, advance
                    ldb       #'/                 write trailing slash
                    stb       ,y+                 store trailing '/'
                    clr       ,y                  null-terminate
GetDeviceNameClose  lbsr      CloseDirPath        close the directory path
                    leas      <$22,s              release local frame
                    rts


* lib_get_disk (state_info.c)
GetDiskName         leas      -$0A,s              allocate 10-byte local frame
                    leay      ,s                  Y = start of local frame
                    bsr       GetDeviceName       get device path (e.g. "/d0/") into frame
                    leax      $01,s               X = second char of device name (skip first '/')
                    ldd       #$0002              copy 2 bytes
                    lbsr      MemCopyNull         copy drive letters to U output buffer
                    tfr       x,u                 U = output buffer pointer
                    lbsr      StrToLower          convert drive letters to lowercase
                    ldd       ,u                  D = two drive letter chars
                    subb      #'0                 convert digit char to 0-based drive number
                    cmpa      #'d                 first char = 'd' (disk drive)?
                    beq       GetDiskNameStore    yes — store digit offset
                    orb       #$10                no — add $10 to distinguish device type
GetDiskNameStore    stb       $03,u               store computed drive number
                    leas      $0A,s               release local frame
                    rts

FindCurrentDisk     leas      >-$00C2,s           allocate 194-byte local frame
                    stu       ,s                  save output buffer pointer
                    clra                          zero
                    sta       <OpenPathCnt        clear open path counter
                    leax      >$00A1,s            X = first byte of name buffer area
                    sta       ,x                  clear it
                    stx       <DiskNameBufPtr            save name buffer pointer
                    leax      >DataPathEntry,pcr  X = "."+CR path spec
                    lbsr      OpenDirPath         open current directory
                    sta       <PathNum            save opened path number
                    leax      >$00A2,s            X = disk-entry comparison area
                    lbsr      ReadDiskEntry       read two directory entries for comparison
FindCurrentDiskLoop ldd       <DiskKeyBHi            load second entry's 3-byte key (high)
                    std       <CmpKey3Hi            save for Compare3Bytes
                    lda       <DiskKeyBLo            load second entry's key (low byte)
                    sta       <CmpKey3Lo            save for Compare3Bytes
                    ldx       #$0081              address of first-entry key
                    ldy       #$007E              address of saved key to compare
                    lbsr      Compare3Bytes       compare entry keys
                    beq       FindDiskEntryFound  match — this is the current disk
                    leax      >DataPathBuf,pcr    X = "." single-byte path
                    lbsr      ChangeDir           change to parent directory
                    lbsr      CloseDirPath        close current directory path
                    bcs       FindDiskEntryDone   error — done
                    leax      >DataPathEntry,pcr  X = "."+CR path spec
                    lbsr      OpenDirPath         reopen current (parent) directory
                    leax      >$00A2,s            X = disk-entry comparison area
                    bsr       ReadDiskEntry       read two entries from new directory
FindDiskEntryLoop   leax      >$00A2,s            X = disk-entry buffer
                    lda       <PathNum            path number for read
                    lbsr      ReadDirEntry        read one directory entry
                    bcs       FindDiskEntryDone   read error or EOF — done
                    leax      <$1D,x              X = entry creation-date field
                    ldy       #$007B              Y = saved key for comparison
                    bsr       Compare3Bytes       compare entry against saved key
                    bne       FindDiskEntryLoop   no match — try next entry
                    leax      >$00A2,s            X = disk-entry buffer
                    bsr       ParseDiskName       parse disk name from entry into DiskNameBufPtr
                    bcs       FindDiskEntryDone   parse error — done
                    bra       FindCurrentDiskLoop restart comparison with new parent
FindDiskEntryFound  lbsr      CloseDirPath        close search path
                    leay      >$00A2,s            Y = output buffer for device name
                    lbsr      GetDeviceName       get current device name into buffer
                    leax      >$00A2,s            X = device name
                    bsr       ParseDiskName       extract disk path component
                    bcs       FindDiskEntryDone   error — done
                    ldu       ,s                  restore output buffer pointer
                    ldx       <DiskNameBufPtr            X = parsed path string
                    lbsr      StrCopy             copy parsed name to output
                    lbsr      ChangeDir           change to identified directory
FindDiskEntryDone   ldu       ,s                  restore output buffer pointer
                    lbsr      StrToLower          convert result to lowercase
                    lbsr      CloseDirPath        close any open path
                    leas      >$00C2,s            release local frame
                    rts

ParseDiskName       os9       F$PrsNam            parse name from X path buffer
                    bcs       ParseDiskNameEnd    error — return with carry set
                    ldx       <DiskNameBufPtr            X = output name buffer pointer
ParseDiskNameCopy   lda       ,-y                 load char from parsed name (reverse)
                    anda      #$7F                strip high bit (last char marker)
                    sta       ,-x                 store into output buffer (reverse)
                    decb                          decrement name length
                    bne       ParseDiskNameCopy   more chars to copy
                    cmpa      #$2F                first char was '/'?
                    beq       ParseDiskNameRet    yes — already have leading slash
                    lda       #$2F                prepend '/'
                    sta       ,-x                 store '/' before current output position
                    andcc     #$FE                clear carry (success)
ParseDiskNameRet    stx       <DiskNameBufPtr            save updated output pointer
ParseDiskNameEnd    rts

ReadDiskEntry       bsr       ReadDirEntry        read first directory entry
                    ldd       <$1D,x              load 3-byte creation-date field (high)
                    std       <DiskKeyAHi            save for FindCurrentDisk
                    lda       <$1F,x              load third byte of creation date
                    sta       <DiskKeyALo            save for FindCurrentDisk
                    bsr       ReadDirEntry        read second directory entry
                    ldd       <$1D,x              load 3-byte creation-date field (high)
                    std       <DiskKeyBHi            save for FindCurrentDisk
                    lda       <$1F,x              load third byte of creation date
                    sta       <DiskKeyBLo            save for FindCurrentDisk
                    rts

* compares three bytes
* called with address of values to compare in x & y
Compare3Bytes       ldd       ,x++                load and advance X by 2
                    cmpd      ,y++                compare two bytes, advance Y by 2
                    bne       Compare3BytesRet    mismatch — return NE
                    lda       ,x                  load third byte
                    cmpa      ,y                  compare third byte
Compare3BytesRet    rts

OpenDirPath         lda       #READ.+DIR.         open for read as directory ($81)
                    lbsr      OpenFile            open the path
                    bcs       OpenDirPathRet      error — return with carry set
                    inc       <OpenPathCnt        track one more open path
OpenDirPathRet      rts

ReadDirEntry        lda       <PathNum            path number to read from
                    ldy       #$0020              read 32 bytes (one directory entry)
                    lbra      ReadFile            read and return
CloseDirPath        lda       <PathNum            path number to close
                    lbsr      CloseFilePath       close the path
                    bcs       CloseDirPathRet     error — return
                    clr       <OpenPathCnt        clear open path counter
CloseDirPathRet     rts

ChangeDir           clr       >$015B              clear error code holder
                    lda       #READ.+DIR.         open for read as directory ($81)
                    os9       I$ChgDir
                    bcc       ChangeDirRet        change succeeded — return
                    lbsr      OsErrorHandler      handle OS error
ChangeDirRet        rts

OpenPathFromStack   lda       $05,s               load access mode from caller's stack frame
                    ldy       $02,s               Y = path name length
                    lbsr      OpenFile            open the path
                    bcs       OpenPathRet         error — return carry set
                    ldx       $06,s               X = file status buffer
                    bsr       GetFileStatus       get file status into buffer
OpenPathRet         lda       >$015B              return error code from $015B
                    rts

GetFileStatus       clr       >$015B              clear error code holder
                    ldb       #$0F                GetStt function $0F (SS.FDInf)
                    ldy       #$0010              16-byte file descriptor buffer
                    os9       I$GetStt
                    bcc       GetFileStatusRet    status retrieved — return
                    bsr       OsErrorHandler      handle OS error
GetFileStatusRet    rts

GetFileTime         leas      <-$14,s             allocate 20-byte local time buffer
                    leax      ,s                  X = local buffer
                    bsr       GetFileStatus       read file descriptor into buffer
                    leax      $03,x               X = pointer to year byte in descriptor
                    clrb                          clear B for 16-bit shift
                    lda       ,x                  load year byte
                    suba      #$50                subtract 1980 (OS-9 epoch offset)
                    lsla                          shift year left for packing
                    std       <$10,s              save packed year value
                    ldb       $01,x               load day byte
                    lda       #$20                day multiplier = 32 (5-bit field max)
                    mul                           D = day × 32
                    addd      <$10,s              add year component
                    addb      $02,x               add hour byte
                    adca      #$00                propagate carry
                    std       <$10,s              save year+day+hour packed value
                    clrb                          clear B
                    lda       $03,x               load minute byte
                    lsla                          × 2
                    lsla                          × 4
                    lsla                          × 8 → scale minutes
                    std       <$12,s              save minute component
                    ldb       $04,x               load second byte
                    lda       #$20                second multiplier = 32
                    mul                           D = second × 32
                    addd      <$12,s              add minute component
                    ldx       <$10,s              load year+day+hour value
                    leas      <$14,s              release local buffer
                    rts

*  error handler for os9 calls
OsErrorHandler      pshs      cc                  save condition codes
                    cmpb      #E$PNNF             path-name not found error?
                    bne       OsErrorStore        no — store as-is
                    lda       #$FF                remap to $FF (game-level "not found")
                    clrb                          clear error code
OsErrorStore        stb       >$015B              store (possibly remapped) error code
                    puls      cc                  restore condition codes
                    rts

FindObjPos          leas      -$05,s              allocate 5-byte local: [,s]=U [2]=tries [3]=dir [4]=countdown
                    stu       ,s                  save object pointer
                    clra                          start direction = 0 (none)
                    sta       $03,s               initial search direction = none
                    inca                          counter starts at 1
                    sta       $02,s               save try-radius counter
                    sta       $04,s               save countdown (= try-radius initially)
                    lda       >$01D7              load horizon Y position
                    cmpa      $04,u               object Y above horizon?
                    bcs       FindObjPosIter      yes — skip priority assignment
                    ldb       <$26,u              load object flags
                    bitb      #$08                priority fixed?
                    bne       FindObjPosIter      yes — skip priority assignment
                    inca                          auto-assign priority (increment for horizon)
                    sta       $04,u               set object priority from horizon
FindObjPosIter      lbsr      CheckObjBounds      check if current position is valid
                    tsta                          A = 0 means out of bounds
                    beq       FindObjPosDirNone   out of bounds — try next direction
                    lbsr      TestObjContact      test for overlap with other objects
                    tsta                          A = 0 means no contact
                    bne       FindObjPosDirNone   contact — try next direction

                    pshs      u                   push object pointer for obj_chk_control
                    lda       #$03                obj_chk_control() offset
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up the remap to shdw
                    jsr       >$0659              mmu twiddler — check control line
                    leas      $02,s               clean up the stack

                    ldu       ,s                  restore object pointer
                    lda       <ShdwContact            check control result
                    bne       FindObjPosDone      valid position found — done
FindObjPosDirNone   lda       $03,s               load current search direction
                    bne       FindObjPosDirOne    non-zero direction — check next
                    dec       $03,u               direction 0: move object Y down
                    dec       $04,s               decrement countdown
                    bne       FindObjPosIter      not zero — iterate
                    inc       $03,s               exhausted — advance direction
                    lda       $02,s               reload radius
                    sta       $04,s               reset countdown
                    bra       FindObjPosIter      next iteration
FindObjPosDirOne    cmpa      #$01                direction 1?
                    bne       FindObjPosDirTwo    no — check next
                    inc       $04,u               direction 1: move object Y up
                    dec       $04,s               decrement countdown
                    bne       FindObjPosIter      not zero — iterate dir 1
                    inc       $03,s               advance direction
                    inc       $02,s               increase radius
                    lda       $02,s               reload new radius
                    sta       $04,s               reset countdown
                    bra       FindObjPosIter      next iteration
FindObjPosDirTwo    cmpa      #$02                direction 2?
                    bne       FindObjPosDirThree  no — check next
                    inc       $03,u               direction 2: move object X right
                    dec       $04,s               decrement countdown
                    bne       FindObjPosIter      not zero — iterate dir 2
                    inc       $03,s               advance direction
                    lda       $02,s               reload radius
                    sta       $04,s               reset countdown
                    bra       FindObjPosIter      next iteration
FindObjPosDirThree  dec       $04,u               direction 3: move object X left
                    dec       $04,s               decrement countdown
                    bne       FindObjPosIter      not zero — iterate dir 3
                    clr       $03,s               wrap direction back to 0
                    inc       $02,s               increase search radius
                    lda       $02,s               reload new radius
                    sta       $04,s               reset countdown
                    bra       FindObjPosIter      next iteration
FindObjPosDone      leas      $05,s               release local frame
                    rts

CheckObjBounds      clra                          assume out-of-bounds (return 0)
                    ldb       $03,u               load object X position
                    addb      <$1C,u              add object width for right edge
                    bcs       CheckObjBoundsRet   overflow — off right edge
                    cmpb      #$A0                right edge > 160 (screen width)?
                    bhi       CheckObjBoundsRet   yes — off right edge
                    ldb       $04,u               load object Y position
                    cmpb      #$A7                Y > 167 (screen height)?
                    bhi       CheckObjBoundsRet   yes — off bottom
                    incb                          Y+1 for bottom-edge check
                    cmpb      <$1D,u              below object's height minimum?
                    bcs       CheckObjBoundsRet   yes — off top
                    decb                          restore Y
                    cmpb      >$01D7              below horizon?
                    bhi       CheckObjInBounds    yes — valid position
                    ldb       <$26,u              load object flags
                    bitb      #$08                above-horizon flag set?
                    beq       CheckObjBoundsRet   no — treat as out-of-bounds above horizon
CheckObjInBounds    inca                          in bounds — return 1
CheckObjBoundsRet   rts

FlagBitTable        fcb       $80,$40,$20,$10,$08,$04,$02,$01


cmd_set
CmdSetImpl          lda       ,y+                 get flag index from script
                    bra       SetFlag             set the AGI flag

cmd_reset
CmdResetImpl        lda       ,y+                 get flag index from script
                    bra       ClearFlag           clear the AGI flag

cmd_toggle
CmdToggleImpl       lda       ,y+                 get flag index from script
                    bra       ToggleFlag          toggle the AGI flag

cmd_set_v
CmdSetVImpl         ldb       ,y+                 get variable index from script
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read flag number from variable
                    bra       SetFlag             set the flag

cmd_reset_v
CmdResetVImpl       ldb       ,y+                 get variable index from script
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read flag number from variable
                    bra       ClearFlag           clear the flag

cmd_toggle_v
CmdToggleVImpl      ldb       ,y+                 get variable index from script
                    ldx       #$0432              base of AGI variable table
                    abx                           index to the variable
                    lda       ,x                  read flag number from variable
                    bra       ToggleFlag          toggle the flag
SetFlag             bsr       GetFlagBitAddr      get byte address and bit mask
                    ora       ,x                  OR bit into flag byte
                    sta       ,x                  write updated flag byte
                    rts

ClearFlag           bsr       GetFlagBitAddr      get byte address and bit mask
                    coma                          invert mask — all bits set except target
                    anda      ,x                  AND to clear only the target bit
                    sta       ,x                  write updated flag byte
                    rts

ToggleFlag          bsr       GetFlagBitAddr      get byte address and bit mask
                    eora      ,x                  XOR to flip only the target bit
                    sta       ,x                  write updated flag byte
                    rts
TestFlag            bsr       GetFlagBitAddr      get byte address and bit mask
                    anda      ,x                  AND to isolate target bit (0 if clear)
                    rts

GetFlagBitAddr      tfr       a,b                 B = raw flag index
                    leax      >FlagBitTable,pcr   X = bit-mask lookup table
                    anda      #$07                A = bit position within byte (0–7)
                    lda       a,x                 A = bit mask for this position
                    lsrb                          B >>= 1
                    lsrb                          B >>= 1
                    lsrb                          B = byte offset into flag table (index/8)
                    ldx       #$01AF              base address of AGI flag table
                    abx                           X = address of flag byte for this flag
                    rts


CalcFollowDir       leas      -$05,s              allocate 5-byte local frame
                    ldb       <$27,u              load follow target object number
                    pshs      b,a                 push target obj number + scratch
                    ldx       <ViewObjBase        X = ego (object 0)
                    lda       <$1C,x              load ego width
                    lsra                          half-width for center X
                    adda      $03,x               ego center X = x + half-width
                    ldb       $04,x               ego Y position
                    std       $03,s               save ego center (X in A, Y in B)
                    pshs      b,a                 push ego center for CalcMoveDir
                    lda       <$1C,u              load follower width
                    lsra                          half-width for center X
                    adda      $03,u               follower center X
                    sta       $07,s               save follower X into frame
                    ldb       $04,u               follower Y position
                    pshs      b,a                 push follower center for CalcMoveDir
                    lbsr      CalcMoveDir         compute direction from follower to ego
                    leas      $06,s               clean up CalcMoveDir args
                    sta       ,s                  save computed direction
                    bne       FollowCheckStop     non-zero direction — check stop condition
                    sta       <$21,u              direction 0 = arrived; stop follower
                    sta       <$22,u              clear motion type (no longer following)
                    lda       <$28,u              load "reached target" flag variable
                    lbsr      SetFlag             signal that follower reached ego
                    bra       FollowRet           done
FollowCheckStop     lda       <$29,u              load follow distance timer
                    cmpa      #$FF                $FF = no distance check
                    bne       FollowCheckWander   normal — check wander flag
                    clr       <$29,u              clear distance sentinel
                    bra       FollowSetDir        set direction immediately
FollowCheckWander   lda       <$25,u              load state flags
                    bita      #$40                "just repositioned" flag set?
                    beq       FollowDecTimer      no — decrement timer normally
FollowSetWander     lbsr      InitRandSeed        yes — pick a random intermediate direction
                    lda       #$09                modulo 9 (8 directions + stopped)
                    lbsr      Div8                random direction in A
                    sta       <$21,u              apply random direction
                    beq       FollowSetWander     direction 0 = stopped — try again
                    ldb       $03,s               ego center X
                    subb      $01,s               follower X
                    bcc       FollowCalcDir       positive difference — keep
                    negb                          negative — take absolute value
FollowCalcDir       stb       $04,s               save |dx|
                    ldb       $04,u               follower Y
                    subb      $02,s               ego Y
                    bcc       FollowCalcStep      positive difference — keep
                    negb                          negative — take absolute value
FollowCalcStep      clra                          zero high byte
                    addb      $04,s               B = |dx| + |dy| (Manhattan distance)
                    adca      #$00                propagate carry
                    lsra                          divide by 2
                    rorb                          rotate through A
                    incb                          round up: step = distance/2 + 1
                    stb       $04,s               save computed step size
                    lda       <$1E,u              load follower's step size
                    sta       <$29,u              save as distance timer
                    cmpa      $04,s               step size >= computed step?
                    bcc       FollowRet           yes — follow at current rate
FollowRandomStep    lbsr      InitRandSeed        pick a random step within range
                    lda       $04,s               step ceiling
                    lbsr      Div8                random value 0..ceiling-1
                    cmpa      <$1E,u              random >= step size?
                    bcs       FollowRandomStep    yes — retry
                    sta       <$29,u              store random step offset
                    bra       FollowRet           done
FollowDecTimer      lda       <$29,u              load follow timer
                    beq       FollowSetDir        timer expired — set direction now
                    clr       <$29,u              clear "just repositioned" sentinel
                    suba      <$1E,u              subtract step size from timer
                    bcs       FollowRet           underflow — wait more
                    sta       <$29,u              save updated timer
                    bra       FollowRet           done
FollowSetDir        lda       ,s                  load computed direction
                    sta       <$21,u              apply direction to follower
FollowRet           leas      $05,s               release local frame
                    rts


DataSaveDiskFlag    fcb       $01

SaveDiskNameBuf     fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

DataSaveGameBuf     fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

DataSaveGameBuf2    fcb       $00,$00,$00,$00
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
StrSave             fcc       'save'
                    fcb       C$NULL

* save_disk_check (state_info.c)
StrRestore          fcc       'restore'
                    fcb       C$NULL

StrDescFmt          fcc       ' - %s'
                    fcb       C$NULL


* state_get_info strings (state_info.c)
StrSaveDesc         fcc       'How would you like to describe this saved game?'
                    fcb       C$LF,C$LF,C$NULL

* save_disk_check strings (state_info.c)
StrSaveDiskPrompt   fcc       'Please put your save game'
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
StrDirExample       fcc       '(For example, "/d1" or "/h0/savegame")'
                    fcb       C$NULL

* state_get_path strings (state_info.c)
StrSaveGameMenu     fcc       '         SAVE GAME'
                    fcb       C$LF,C$LF
                    fcc       'On which disk or in which directory do you '
                    fcc       'wish to save this game?'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcb       C$NULL

* state_get_path strings (state_info.c)
StrRestoreGameMenu  fcc       '        RESTORE GAME'
                    fcb       C$LF,C$LF
                    fcc       'On which disk or in which directory is the '
                    fcc       'game that you want to restore?'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
StrArrowInstr       fcc       'Use the arrow keys to move'
                    fcb       C$LF
                    fcc       '     the pointer to your name.'
                    fcb       C$LF
                    fcc       'Then press ENTER.'
                    fcb       C$LF
                    fcb       C$NULL

* state_get_path strings (state_info.c)
StrNoDirFound       fcc       'There is no directory named:'
                    fcb       C$LF
                    fcc       '%s.'
                    fcb       C$LF
                    fcc       'Press ENTER to try again.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to cancel.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
StrNoGamesToRestore fcc       'There are no games to'
                    fcb       C$LF
                    fcc       'restore in:'
                    fcb       C$LF,C$LF
                    fcc       '%s'
                    fcb       C$LF,C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
StrSaveSlotSelect   fcc       'Use the arrow keys to select the slot '
                    fcc       'in which you wish to save the game. '
                    fcc       'Press ENTER to save in the slot, '
                    fcc       'CTRL-BREAK to not save a game.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
StrRestoreSelect    fcc       'Use the arrow keys to select the game which you '
                    fcc       'wish to restore. Press ENTER to restore the game, '
                    fcc       'CTRL-BREAK to not restore a game.'
                    fcb       C$NULL

* state_get_filename strings (state_info.c)
StrDiskFull         fcc       '   Sorry, this disk is full.'
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
StateGetInfo        leas      -$02,s              allocate 2-byte local: [,s]=saved edit flag, [$01,s]=result
                    clr       $01,s               clear result (0 = no save slot chosen)
                    lda       >$05B9              load input_edit_disabled flag
                    sta       ,s                  save it for restore later
                    lbsr      InputEditOn         enable input editing
                    lbsr      PushTextColor       save current text color
                    lbsr      PushRowCol          save current cursor position

                    ldd       #$000F              text color 15 (white)
                    lbsr      text_color          set text color

                    ldd       $04,s               load state_type arg from caller's frame
                    pshs      d                   push state_type for GetSavePath
                    lbsr      GetSavePath         verify/select save disk and path
                    leas      $02,s               clean up GetSavePath arg
GetInfoLoop         beq       GetInfoCleanup      path not ready — skip to cleanup
                    ldd       $04,s               reload state_type
                    pshs      b,a                 push for CheckSaveDisk
                    lbsr      CheckSaveDisk       verify correct save disk is inserted
                    leas      $02,s               clean up CheckSaveDisk arg
                    beq       GetInfoCleanup      disk not ready — skip to cleanup
                    ldd       $04,s               reload state_type
                    pshs      b,a                 push for GetSaveFilename
                    lbsr      GetSaveFilename     prompt user to choose save slot
                    leas      $02,s               clean up GetSaveFilename arg
                    sta       $01,s               save slot number result
                    beq       GetInfoCleanup      slot = 0 — cancelled
                    lda       $05,s               load state_type from caller's frame
                    cmpa      #$73                's' for save?
                    bne       GetInfoRestoreSlot  no — restoring, skip description prompt
                    lda       >state_name_auto,pcr load auto-name flag
                    bne       GetInfoRestoreSlot  auto-named — skip description prompt
                    leax      >DataSaveGameBuf,pcr X = description buffer (31 bytes)
                    leau      >StrSaveDesc,pcr    U = "How would you like to describe..." prompt
                    lbsr      EditBoxInput        get save description from user
                    tsta                          result = 0 means cancelled
GetInfoAbort        bne       GetInfoRestoreSlot  non-zero — accepted, store slot
                    clr       $01,s               cancelled — clear result
                    bra       GetInfoCleanup      skip save and clean up
GetInfoRestoreSlot  leax      >DataSaveGameBuf2,pcr X = 64-byte restore info buffer
                    ldb       $01,s               load save slot number
                    lbsr      BuildSaveFilePath   build full save file path for slot
GetInfoCleanup      lbsr      PopRowCol           restore saved cursor position
                    lbsr      PopTextColor        restore saved text color
                    lda       ,s                  was input editing originally disabled?
                    beq       GetInfoRet          no — leave editing on
                    lbsr      InputCursorBlink    restore cursor blink state
GetInfoRet          lda       $01,s               load result (slot number or 0)
                    leas      $02,s               release local frame
                    rts

* save_disk_check
* passed in  state_type for checking
CheckSaveDisk       leas      >-$00A5,s           allocate 165-byte local frame
                    lda       #$01                default result = success
                    sta       ,s                  save result byte
                    leau      >$00A1,s            U = local disk-name buffer
                    lbsr      GetDiskName         get current disk name into buffer
                    lda       >SaveDriveNum,pcr   load expected save-game drive number
                    cmpa      >$00A4,s            matches current drive?
                    bne       CheckSaveDiskRet    no — wrong disk
                    cmpa      #$10                drive number >= $10 (non-disk device)?
                    bcc       CheckSaveDiskRet    yes — not a valid save drive
                    lbsr      VolumesClose        close any open volume paths
                    leau      >StrSave,pcr        U = "save" label string
                    lda       >$00A8,s            load state_type passed to function
                    cmpa      #'s                 's' = save operation?
                    beq       SaveDiskDoPrompt    yes — use "save" label
                    leau      >StrRestore,pcr     no — use "restore" label
SaveDiskDoPrompt    pshs      u                   push save/restore label string
                    leau      >$00A3,s            U = output buffer in local frame
                    pshs      u                   push output buffer
                    leau      >StrSaveDiskPrompt,pcr "Please insert your [save/restore] game disk..."
                    leax      $05,s               X = format argument area
                    pshs      u                   push format string
                    pshs      x                   push argument pointer
                    lbsr      PrintFmtStr         format the prompt into output buffer
                    leas      $08,s               clean up PrintFmtStr args
                    lbsr      message_box         display prompt in message box
                    sta       ,s                  save message_box result
CheckSaveDiskRet    lda       ,s                  load result byte
                    leas      >$00A5,s            release local frame
                    rts

GetSavePath         leas      >-$00C8,s           allocate 200-byte local frame
                    lda       >SaveDiskNameBuf,pcr load first byte of saved disk name
                    bne       GetSavePathCheck    non-zero — disk name already known
                    leau      >SaveDiskNameBuf,pcr U = disk name buffer
                    lbsr      FindCurrentDisk     search for current disk identifier
                    leas      ,s                  (no-op: local frame not moved)
GetSavePathCheck    tst       >state_name_auto,pcr auto-naming active?
                    bne       GetSavePathDone     yes — skip manual path entry
GetSavePathShowMenu leau      >StrDirExample,pcr  U = directory example string
                    pshs      u                   push example for format
                    leau      >StrSaveGameMenu,pcr U = "SAVE GAME" menu header
                    ldb       >$00CD,s            load state_type from caller's frame
                    cmpb      #$73                's' = save?
                    beq       GetSavePathFormat   yes — use "SAVE GAME" header
                    leau      >StrRestoreGameMenu,pcr no — use "RESTORE GAME" header
GetSavePathFormat   leax      $02,s               X = output buffer in local frame
                    pshs      u                   push header string
                    pshs      x                   push output buffer
                    lbsr      PrintFmtStr         format menu header into buffer
                    leas      $06,s               clean up PrintFmtStr args
                    leax      >SaveDiskNameBuf,pcr X = disk name input buffer
                    lbsr      EditBoxInput        prompt user to enter save disk path
                    tsta                          result = 0 means cancelled
                    beq       GetSavePathDone     cancelled — done
                    leau      >SaveDiskNameBuf,pcr U = disk name buffer to convert
                    lbsr      StrToLower          convert entered path to lowercase
                    pshs      u                   push disk name for GetDiskInfo
                    lbsr      GetDiskInfo         verify/open the disk path
                    leas      $02,s               clean up GetDiskInfo arg
                    bne       GetSavePathDone     success — done
                    leau      >SaveDiskNameBuf,pcr U = disk name buffer (for error message)
                    pshs      u                   push disk name pointer
                    leau      >StrNoDirFound,pcr  U = "There is no directory named:" format
                    leax      $02,s               X = output buffer
                    pshs      u                   push format string
                    pshs      x                   push output buffer
                    lbsr      PrintFmtStr         format "no directory" error message
                    leas      $06,s               clean up PrintFmtStr args
                    lbsr      message_box         display error in message box
                    bne       GetSavePathShowMenu user accepted — try again
GetSavePathDone     leas      >$00C8,s            release local frame
                    rts

EditBoxInput        leas      -$03,s              allocate 3-byte local: [,s]=X (input buffer)
                    stx       ,s                  save input buffer pointer
                    ldd       #$0001              arg: wait_for_key = 1
                    pshs      d                   push on stack
                    ldd       #$001F              arg: box width = 31 chars
                    pshs      d                   push on stack
                    ldd       #$0000              arg: row = 0
                    pshs      d                   push on stack
                    pshs      u                   push prompt string (U = from caller)
                    lbsr      message_box_draw    draw the input dialog box
                    leas      $08,s               clean up message_box_draw args
                    ldd       #$0000              row/col = 0 for EditString
                    pshs      d                   push row/col arg
                    lda       >$0178              load box row
                    ldb       >$0177              load box column
                    std       <TextRow            set text cursor position
                    ldb       >$0179              load box width
                    decb                          -1 for interior width
                    pshs      d                   push width arg
                    ldb       >$0177              load box column again
                    pshs      d                   push column arg
                    lbsr      ClearTextRect       clear the input area
                    leas      $06,s               clean up ClearTextRect args
                    lbsr      PushTextColor       save current text color
                    lda       #$0F                text color = white
                    clrb                          high byte = 0
                    lbsr      text_color          set text color
                    ldb       #$1F                max input length = 31
                    ldx       ,s                  X = input buffer (saved at entry)
                    lbsr      EditString          get string input from user
                    sta       $02,s               save EditString result (last key)
                    lbsr      PopTextColor        restore original text color
                    lbsr      cmd_close_window    close the message box
                    lda       #$01                assume Enter (return 1)
                    ldb       $02,s               load saved key code
                    cmpb      #$0D                Enter key?
                    beq       EditBoxRet          yes — success
                    clra                          not Enter — return 0 (cancelled)
EditBoxRet          ldx       ,s                  restore caller's X (input buffer)
                    leas      $03,s               release local frame
                    rts

GetSaveFilename     leas      >-$0256,s           allocate 598-byte local frame
                    lda       #$01                extended table lookup = enabled
                    sta       >ExtTableFlag       set extended table lookup flag
                    lda       #$06                slot mode byte
                    sta       >$0547              store mode
                    ldd       #$0000              clear D for zero-init
                    sta       >$024C,s            clear best-slot index
                    std       >$024E,s            clear best timestamp hi word
                    std       >$0250,s            clear best timestamp lo word
                    lda       >$0259,s            load save/restore mode byte
                    suba      #$72                subtract $72 to test restore mode
                    beq       GetFilenameInitY    branch if restore mode
                    lda       #$0C                save mode: scan all 12 slots
GetFilenameInitY    std       >$024A,s            init slot count (0 for restore, 12 for save)
GetFilenameLoop     cmpb      #$0C                all 12 slots scanned?
                    lbcc      GetFilenameDone     yes — done scanning
                    leau      >$0252,s            point U to timestamp buffer
                    pshs      u                   push timestamp buffer pointer
                    incb                          advance to next slot
                    pshs      b,a                 save slot index and mode
                    ldb       >$025D,s            load save/restore flag
                    lda       >$024E,s            load best timestamp hi
                    cmpb      #$73                save mode?
                    bne       GetFilenameCalc     no — use timestamp hi as-is
                    lda       >$024F,s            yes — use alternate field for save mode
GetFilenameCalc     ldb       #$20                slot entry size = 32 bytes
                    mul                           compute byte offset for this slot
                    leau      $06,s               base of slot data on stack
                    leau      d,u                 add offset to reach slot entry
                    pshs      u                   push pointer to slot entry
                    lbsr      ReadSaveSlotEntry   read and validate save slot
                    leas      $06,s               pop 3 args (6 bytes)
                    beq       GetFilenameIncY     slot empty — skip
                    ldb       >$0259,s            reload mode byte
                    cmpb      #$73                save mode?
                    bne       GetFilenameUpdateRestore branch if restore mode
                    ldd       >$0252,s            load slot timestamp hi
                    cmpd      >$024E,s            compare with current best
                    bhi       GetFilenameUpdateSave newer — update best
                    bcs       GetFilenameIncY     older — skip
                    ldd       >$0254,s            timestamps equal hi — load lo
                    cmpd      >$0250,s            compare lo with best lo
                    bls       GetFilenameIncY     not better — skip
GetFilenameUpdateSave ldd     >$0254,s            load new best timestamp lo
                    std       >$0250,s            store as best timestamp lo
                    ldd       >$0252,s            load new best timestamp hi
                    std       >$024E,s            store as best timestamp hi
                    lda       >$024B,s            load current slot index
                    sta       >$024C,s            record as best slot for save
                    bra       GetFilenameIncY     advance to next slot
GetFilenameUpdateRestore ldd  >$0252,s            load slot timestamp hi
                    cmpd      >$024E,s            compare with best timestamp
                    bhi       GetFilenameStoreBest newer — update best
                    bcs       GetFilenameIncX     older — skip
                    ldd       >$0254,s            timestamps equal hi — load lo
                    cmpd      >$0250,s            compare lo with current best
                    bls       GetFilenameIncX     not better — skip
GetFilenameStoreBest ldd      >$0254,s            load new best timestamp lo
                    std       >$0250,s            store best timestamp lo
                    ldd       >$0252,s            load new best timestamp hi
                    std       >$024E,s            store best timestamp hi
                    lda       >$024A,s            load slot X counter
                    sta       >$024C,s            record as best slot for restore
GetFilenameIncX     inc       >$024A,s            increment valid-slot counter
GetFilenameIncY     inc       >$024B,s            increment scan index
                    ldb       >$024B,s            reload scan index
                    lbra      GetFilenameLoop     loop to next slot
GetFilenameDone     lda       >$024A,s            any valid slots found?
                    bne       GetFilenameCheck    yes — proceed
                    lda       >state_name_auto,pcr load auto-save name flag
                    bne       GetFilenameSetup    if set, skip "no games" message
                    leau      >SaveDiskNameBuf,pcr point to disk name buffer
                    pshs      u                   push buffer arg
                    leau      >StrNoGamesToRestore,pcr "No games to restore" string
                    leax      >$0184,s            point to text output buffer
                    pshs      u                   push format string
                    pshs      x                   push output buffer
                    lbsr      PrintFmtStr         format "no games" message
                    leas      $06,s               pop 3 args
                    lbsr      message_box         display message box
                    clra                          return 0 — no slot selected
                    lbra      GetFilenameExit     exit
GetFilenameCheck    lda       >state_name_auto,pcr check auto-save name state
                    lbeq      GetFilenameDrawList no auto-name — draw slot list
GetFilenameSetup    lda       >DataSaveDiskFlag,pcr check if disk-based save mode
                    bne       GetFilenameDiskMode disk mode — get disk name
                    leax      >state_name_auto,pcr point to auto-save name string
                    leau      >DataSaveGameBuf,pcr point to save-game name buffer
                    lbsr      StrCopy             copy auto-name into save buffer
                    clrb                          start slot scan at index 0
                    stb       >$024B,s            store scan index = 0
GetFilenameMatchLoop cmpb     #$0C                all 12 slots checked?
                    bcc       GetFilenameMatchSave done — no match found
                    leau      >DataSaveGameBuf,pcr point to save-game name buffer
                    lda       #$20                slot entry size = 32 bytes
                    mul                           compute offset for this slot
                    leax      $02,s               base of slot data on stack
                    leax      d,x                 add offset to reach name field
                    leax      $01,x               skip slot-number byte
                    lbsr      StrCompare          compare slot name with auto-name
                    tsta                          test comparison result
                    lbeq      GetFilenameAccept   match found — accept this slot
                    inc       >$024B,s            no match — advance slot index
                    ldb       >$024B,s            reload index
                    lbra      GetFilenameMatchLoop loop to next slot
GetFilenameMatchSave lda      >$0259,s            load mode byte
                    cmpa      #$73                save mode ($73)?
                    bne       GetFilenameCheckMode no — skip save-slot scan
                    clrb                          reset slot index for save scan
                    stb       >$024B,s            store index = 0
GetFilenameMatchSaveLoop cmpb #$0C                all slots scanned?
                    bcc       GetFilenameCheckMode done — no empty slot found
                    lda       #$20                slot entry size = 32 bytes
                    mul                           compute offset for this slot
                    leax      $02,s               base of slot data on stack
                    leax      d,x                 add offset to reach slot entry
                    ldb       ,x                  load slot flag byte
                    lda       $01,x               load first byte of slot name
                    lbeq      GetFilenameAccept   empty slot found — use it for save
                    inc       >$024B,s            slot occupied — try next
                    ldb       >$024B,s            reload slot index
                    lbra      GetFilenameMatchSaveLoop loop to next slot
GetFilenameCheckMode lda      >$0259,s            load mode byte
                    suba      #$72                subtract $72 to check restore mode
                    lbeq      GetFilenameExit     restore with no match — exit
                    bra       GetFilenameDrawList save mode — draw slot list
GetFilenameDiskMode leau      >$0182,s            point to disk entry buffer
                    lbsr      GetDiskName         get name of save disk
                    lda       >$0185,s            load drive number from result
                    sta       >SaveDriveNum,pcr   store as active save drive number
GetFilenameDrawList ldd       #$0001              screen position y=0, x=1
                    pshs      b,a                 push position arg
                    ldd       #$0022              width/height for dialog
                    pshs      b,a                 push dimensions arg
                    ldb       #$05                initial Y row offset
                    stb       >$0251,s            save row offset
                    addb      >$024E,s            add to timestamp offset
                    pshs      b,a                 push for message_box_draw
                    ldb       >state_name_auto,pcr check auto-save name state
                    beq       GetFilenameShowPrompt no auto-name — show slot prompt
                    leau      >StrDiskFull,pcr    "disk full" message pointer
                    ldb       >DataSaveDiskFlag,pcr check disk flag
                    beq       GetFilenameDrawList loop back if disk flag clear
                    leau      >StrArrowInstr,pcr  "use arrow keys" instruction
                    bra       GetFilenameDrawList redraw with arrow instruction
GetFilenameShowPrompt lda     >$025F,s            load mode byte
                    leau      >StrSaveSlotSelect,pcr "select save slot" prompt
                    cmpa      #$73                save mode?
                    beq       GetFilenameDrawItems yes — use save prompt
                    leau      >StrRestoreSelect,pcr "select game to restore" prompt
GetFilenameDrawItems pshs     u                   push prompt string pointer
                    lbsr      message_box_draw    draw selection dialog
                    leas      $08,s               pop 4 args (8 bytes)
                    lda       >$024D,s            load row base
                    adda      >$0176              add screen row offset
                    sta       >$024D,s            update row position
                    clra                          clear A (list index = 0)
                    sta       >DataSaveDiskFlag,pcr clear disk flag
                    sta       >$024B,s            init slot display index = 0
GetFilenameListLoop cmpa      >$024A,s            all slots listed?
                    bcc       GetFilenameHighlight yes — highlight default
                    adda      >$024D,s            compute screen row for this slot
                    ldb       >$0177              load screen column
                    std       <TextRow            set text cursor row/col
                    lda       >$024B,s            load slot display index
                    ldb       #$20                slot entry size = 32 bytes
                    mul                           compute byte offset for slot
                    leax      $02,s               base of slot data on stack
                    leax      d,x                 add offset to slot entry
                    leax      $01,x               skip flag byte (point to name)
                    pshs      x                   push slot name pointer
                    leax      >StrDescFmt,pcr     format string "- %s"
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print formatted slot name to screen
                    leas      $04,s               pop 2 args
                    inc       >$024B,s            advance slot display index
                    lda       >$024B,s            reload index
                    lbra      GetFilenameListLoop next slot
GetFilenameHighlight lda      >$024C,s            load default highlighted slot
                    sta       >$024B,s            set current cursor index
                    adda      >$024D,s            compute row for highlight
                    lbsr      HighlightRow        highlight selected row
GetFilenameEventLoop lbsr     WaitForEvent        wait for keyboard/joystick event
                    stx       ,s                  save event pointer to stack
                    lda       ,x                  load event type byte
                    cmpa      #$01                keyboard event?
                    bne       GetFilenameNavKey   no — check navigation
                    lda       $01,x               load key code
                    cmpa      #$0D                Enter key?
                    bne       GetFilenameEscKey   no — check Escape
                    lbsr      cmd_close_window    close selection window
                    leau      >DataSaveGameBuf,pcr default destination: save-game buffer
                    lda       >state_name_auto,pcr check auto-save name state
                    beq       GetFilenameCopyEntry no auto-name — use save buffer
                    leau      >state_name_auto,pcr auto-name set — use as destination
GetFilenameCopyEntry lda      >$024B,s            load selected slot index
                    ldb       #$20                slot entry size = 32 bytes
                    mul                           compute offset for selected slot
                    leax      $02,s               base of slot data on stack
                    leax      d,x                 add offset to slot entry
                    pshs      x                   save source pointer
                    leax      $01,x               skip flag byte (point to name)
                    lbsr      StrCopy             copy slot name to destination
                    puls      x                   restore source pointer
                    bra       GetFilenameAccept   accept selected slot
GetFilenameEscKey   cmpa      #$1B                Escape key?
                    bne       GetFilenameEventLoop no — wait for more events
                    lbsr      cmd_close_window    close selection window
                    clra                          return 0 (cancelled)
                    bra       GetFilenameExit     exit with cancel
GetFilenameNavKey   cmpa      #$02                navigation event?
                    bne       GetFilenameEventLoop no — ignore
                    lda       >$024D,s            load row offset
                    adda      >$024B,s            add current slot index
                    ldb       $01,x               load navigation direction code
                    cmpb      #$01                up arrow?
                    bne       GetFilenameNextKey  no — check down arrow
                    lbsr      NormalRow           un-highlight current row
                    lda       >$024B,s            load current slot index
                    bne       GetFilenameDecIdx   nonzero — decrement normally
                    lda       >$024A,s            at top — wrap to last slot
GetFilenameDecIdx   deca                          decrement slot index
                    sta       >$024B,s            save new slot index
                    adda      >$024D,s            compute new highlight row
                    lbsr      HighlightRow        highlight new row
                    bra       GetFilenameEventLoop wait for next event
GetFilenameNextKey  cmpb      #$05                down arrow?
                    bne       GetFilenameEventLoop no — ignore
                    lbsr      NormalRow           un-highlight current row
                    lda       >$024B,s            load current slot index
                    inca                          increment slot index
                    cmpa      >$024A,s            past end of list?
                    bne       GetFilenameWrapIdx  no — keep incremented index
                    clra                          yes — wrap to first slot (0)
GetFilenameWrapIdx  sta       >$024B,s            store (possibly wrapped) slot index
                    adda      >$024D,s            compute new highlight row
                    lbsr      HighlightRow        highlight newly selected row
                    lbra      GetFilenameEventLoop wait for next event
GetFilenameAccept   lda       ,x                  load accepted event data
GetFilenameExit     clr       >ExtTableFlag       clear extended table lookup flag
                    clr       >$0547              clear mode byte
                    leas      >$0256,s            release 598-byte local frame
                    rts

ReadSaveSlotEntry   leas      <-$48,s             allocate 72-byte local frame
                    ldu       <$4A,s              load slot entry pointer
                    ldb       <$4D,s              load slot number argument
                    stb       ,u                  store slot number in entry
                    leax      ,s                  point X to path buffer (local frame)
                    lbsr      BuildSaveFilePath   build save-file path string
                    lda       #$01                read-only open mode
                    lbsr      OpenFile            open save file
                    bcs       ReadSaveSlotFail    skip if open failed
                    sta       <$47,s              save file path descriptor
                    lbsr      GetFileTime         get file modification time (X:D)
                    ldy       <$4E,s              load timestamp destination pointer
                    stx       ,y++                store timestamp hi word, advance Y
                    std       ,y                  store timestamp lo word
                    ldy       #$001F              read up to 31 bytes (slot name)
                    ldx       <$4A,s              load slot entry pointer
                    leax      $01,x               skip slot-number byte
                    lda       <$47,s              reload file descriptor
                    lbsr      ReadFile            read slot name (31 bytes)
                    ldx       #$0000              seek offset hi = 0
                    ldu       #$0024              seek offset lo = $24 (36 bytes in)
                    lda       <$47,s              reload file descriptor
                    ldb       #$01                seek mode: from beginning
                    lbsr      SeekFile            seek to validation data offset
                    ldy       #$0007              read 7 bytes of validation data
                    leax      <$40,s              point to local validation buffer
                    lda       <$47,s              reload file descriptor
                    lbsr      ReadFile            read validation signature
                    lda       <$47,s              reload file descriptor
                    lbsr      CloseFilePath       close save file
                    ldu       #$01CF              point to expected signature string
                    lbsr      StrCompare          compare read data with signature
                    bne       ReadSaveSlotFail    mismatch — not a valid save slot
                    lda       #$01                valid slot — return 1
                    bra       ReadSaveSlotRet     done
ReadSaveSlotFail    clra                          invalid slot — return 0
                    ldu       <$4A,s              load slot entry pointer
                    sta       $01,u               clear name byte (mark invalid)
ReadSaveSlotRet     leas      <$48,s              release 72-byte local frame
                    rts

HighlightRow        ldb       >$0177              load screen column
                    std       <TextRow            set text cursor row/col
                    lda       #$1A                highlight attribute character
                    lbsr      PutCharToWindow     write highlight char to window
                    rts


NormalRow           ldb       >$0177              load screen column
                    std       <TextRow            set text cursor row/col
                    lda       #$20                space (normal/un-highlighted)
                    lbsr      PutCharToWindow     write space to window
                    rts

tOC                 fcc       'toc'
                    fcb       C$NULL

WordsTok            fcc       'words.tok'
                    fcb       C$NULL

Object              fcc       'object'
                    fcb       C$NULL


InitGameState       ldd       #$E000              base address of block 8 boundary
                    std       <$002E              store Sierra bias value

                    ldd       #$4040              fill color for shadow buffer clear
                    pshs      d                   push color arg
                    lda       #$18                remap offset for shadow buffer
                    sta       <ShdwRemapOff       save shadow remap offset
                    ldx       <ShdwRemapVal       load remap-to-shadow base address
                    jsr       >$0659              invoke MMU twiddler to map shadow buffer
                    leas      $02,s               pop color arg

                    lbsr      events_clear        clear pending event queue
                    lbsr      LoadAllDirs         load all AGI directory files
                    lda       #$0F                foreground white (15)
                    clrb                          background black (0)
                    lbsr      text_color          set initial text color
                    lbsr      InputRedraw         redraw input line
                    lbsr      JoystickReadInit    initialize joystick state
                    leau      >tOC,pcr            point to "toc" filename string
                    ldd       #$0000              load offset arg lo
                    pshs      b,a                 push offset
                    ldd       #$0089              load volume index arg
                    pshs      b,a                 push volume
                    ldd       #$0000              load address arg
                    pshs      b,a                 push address
                    pshs      u                   push filename pointer
                    lbsr      FileLoad            load table-of-contents file
                    leas      $08,s               pop 4 args
                    ldu       <DiskInfoIdx        load disk-info index pointer
                    clra                          clear A for loop
                    ldb       ,u+                 load disk count, advance U
                    stb       >$05ED              store disk count
                    tfr       d,x                 move disk count to X for loop
                    stu       <DiskInfoIdx        update disk-info pointer past count
DiskInfoLoop        ldd       <DiskInfoIdx        load current offset pointer
                    addd      ,u                  add entry's relative offset
                    std       ,u++                store absolute pointer, advance U
                    leax      -$01,x              decrement loop counter
                    bne       DiskInfoLoop        loop for each disk entry
                    leau      >WordsTok,pcr       point to "words.tok" filename
                    ldd       #$01AB              volume index for words.tok
                    pshs      b,a                 push volume index
                    ldd       #$01A9              file type for words.tok
                    pshs      b,a                 push file type
                    ldd       #$0000              address arg
                    pshs      b,a                 push address
LoadWordsLoop       pshs      u                   push filename pointer
                    lbsr      FileLoad            load words.tok file
                    leas      $08,s               pop 4 args
                    lbsr      ClearLogicTable     reset logic table entries
                    lbsr      list_clear          clear animation object list
                    lbsr      SoundListClear      clear sound list
                    lbsr      PicListClear        clear picture list
                    bsr       LoadObjectData      load and set up object data
                    clrb                          logic 0 (always-run logic)
                    lbsr      AllocLoadLogic      allocate and load logic 0
                    ldd       <HeapPtr            get current heap pointer
                    std       <MnlnModSize        save as module size reference
                    ldd       <HeapTop            get top of heap
                    std       <HeapBase           save as heap base
                    lda       >$01B0              load state flags byte
                    ora       #$40                set initialized flag (bit 6)
                    sta       >$01B0              store updated flags
                    lbsr      SoundPIASave        save PIA sound state
                    lbsr      SoundPIARestore     restore PIA sound state
                    rts

LoadObjectData      leas      -$01,s              allocate 1-byte local (object count)
                    leau      >Object,pcr         point to "object" filename string
                    ldx       <BlockPtr           load current block pointer
                    beq       LoadObjectSetup     if null, go directly to load
                    leax      -$03,x              back up 3 bytes past header
                    stx       <BlockPtr           update block pointer
LoadObjectSetup     ldd       #$0000              address arg = 0
                    pshs      b,a                 push address
                    ldd       #$0038              volume index for object file
                    pshs      b,a                 push volume
                    pshs      x                   push block pointer
                    pshs      u                   push filename pointer
                    lbsr      FileLoad            load object data file
                    leas      $08,s               pop 4 args
                    ldx       <BlockPtr           load pointer to loaded data
                    ldd       <VolFileSize        load size of loaded data
                    leau      d,x                 point to end of data
                    lbsr      XorDecrypt          decrypt object data
                    ldd       <VolFileSize        reload file size
                    subd      #$0003              subtract 3-byte header size
                    std       <BlockOffset        save data offset
                    ldu       <BlockPtr           load pointer to data start
                    lda       $02,u               load object count (3rd byte of header)
                    sta       ,s                  save object count on stack
                    lda       $01,u               load second byte of header
                    ldb       ,u                  load first byte (flag byte)
                    leau      $03,u               advance past 3-byte header
                    stu       <BlockPtr           save pointer past header as base
                    leau      d,u                 point to end of object data
                    stu       <BlockSizeLimit     save end-of-data pointer
                    ldu       <BlockPtr           reload pointer to object entries
FixupObjPtrs        cmpu      <BlockSizeLimit     past end of object data?
                    bcc       InitViewObjs        yes — all pointers fixed up
                    lda       $01,u               load pointer hi byte
                    ldb       ,u                  load pointer lo byte
                    addd      <BlockPtr           add base address to relative offset
                    std       ,u                  store absolute pointer in place
                    leau      $03,u               advance to next entry (3 bytes)
                    bra       FixupObjPtrs        loop for next object
InitViewObjs        inc       ,s                  increment object count (1-based)
                    ldu       <ViewObjBase        load existing view-object table
                    bne       ClearViewObjs       already allocated — just clear
                    lda       ,s                  load object count
                    ldb       #$2B                bytes per view object = 43
                    mul                           compute total table size
                    std       <ViewObjSizeD       save total size
                    lbsr      AllocDataBlock      allocate view-object table
                    stu       <ViewObjBase        save base pointer
                    ldd       <ViewObjSizeD       reload table size
                    leau      d,u                 point to end of table
                    stu       <ViewObjEnd         save end pointer
                    leau      <-$2B,u             point to last entry
                    stu       <ViewObjLast        save last-entry pointer
                    ldu       <ViewObjBase        reload table base for clearing
ClearViewObjs       ldx       <ViewObjSizeD       load byte count to clear
                    clrb                          zero fill value
                    lbsr      FillMem             zero-fill view-object table
                    clra                          start index at 0
SetViewObjIdx       cmpa      ,s                  reached object count?
                    bcc       ClearGameTables     yes — done assigning indices
                    sta       $02,u               store object index in entry
                    leau      <$2B,u              advance to next entry
                    inca                          increment object index
                    bra       SetViewObjIdx       loop
ClearGameTables     ldu       #$0432              flag/state table base address
                    ldx       #$0100              clear 256 bytes (flag table)
                    clrb                          zero fill value
                    lbsr      FillMem             zero-fill flag table
                    ldu       #$01AF              secondary state block address
                    ldx       #$0020              clear 32 bytes
                    lbsr      FillMem             zero-fill secondary state block
                    lbsr      ClearStateVars      clear 50 state variables at $05BA
                    bsr       ResetGameTables     reset all list tables
                    lbsr      BlitBothErase       erase both screen buffers
                    lda       #$09                initial horizon value
                    sta       >$0446              store horizon
                    lda       >$0553              load saved priority band setting
                    sta       >$044C              restore priority band
                    lda       #$29                initial priority band value (41)
                    sta       >$044A              store priority band
                    lda       >$01AF              load state flags byte
                    ora       #$04                set "objects loaded" flag
                    sta       >$01AF              store updated flags
                    clra                          zero A for state init
                    sta       >CurPicNum          clear current picture number
                    sta       >BlockState         clear block state
                    inca                          A = 1
                    sta       >$0251              set initial display flag
                    tst       >$0173              test input mode flag
                    bne       InitGameStateRet    non-zero — skip input-area init
                    sta       >$0448              set input area visible
InitGameStateRet    leas      $01,s               release 1-byte local frame
                    rts

ResetGameTables     lbsr      ResetLogicTable     reset logic table
                    lbsr      list_clear          clear animation list
                    lbsr      SoundListClear      clear sound list
                    lbsr      PicListClear        clear picture list
                    rts


JoystickData        fcb       $00                 selected joystick x value set in ReadJoystick
                    fcb       $00                 selected joystick y value set in ReadJoystick
                    fcb       $00                 never set but used at CheckJoyDirection


StrJoystickMsg      fcc       'If you have a joystick, and'
                    fcb       C$LF
                    fcc       'wish to use it, press its'
                    fcb       C$LF
                    fcc       'button.'
                    fcb       C$LF
                    fcc       'If not, press CTRL-BREAK to'
                    fcb       C$LF
                    fcc       'continue.'
                    fcb       C$NULL

cmd_init_joy        lda       <JoyEnabled            load joystick-enabled flag
                    eora      #$01                toggle enabled/disabled
                    sta       <JoyEnabled            store updated flag
                    beq       JoyInitDone         just disabled — skip display
                    clr       <JoyLastDir            clear last-direction state
ShowJoyMsg          leau      >StrJoystickMsg,pcr point to joystick prompt string
                    ldd       #$0000              position args (y=0, x=0)
                    pshs      d                   push position
                    ldd       #$0020              size args
                    pshs      d                   push size
                    ldd       #$0000              reserved args
                    pshs      d                   push reserved
                    pshs      u                   push string pointer
                    lbsr      message_box_draw    draw joystick prompt dialog
                    leas      $08,s               pop 4 args
                    ldb       #$00                initial direction state = 0
JoyInputLoop        stb       <JoyDirState            store current direction state
                    lbsr      GetKeyEvent         poll for keyboard event
                    ldb       >$0541              load joystick button status
                    bne       JoyBtnRelease       button pressed — exit loop
JoyInputCheck       ldb       <JoyDirState            reload direction state
                    eorb      #$01                toggle check bit
                    cmpa      #$1B                Escape / CTRL-BREAK pressed?
                    bne       JoyInputLoop        no — keep polling
                    clr       <JoyEnabled            Escape pressed — disable joystick
                    lbsr      cmd_close_window    close dialog
                    bra       JoyInitDone         done
JoyBtnRelease       lbsr      cmd_close_window    button pressed — close dialog
WaitJoyRelease      lbsr      ReadJoyButton       read current button state
                    lda       >$0541              check button still held
                    bne       WaitJoyRelease      still held — keep waiting
JoyInitDone         lbsr      events_clear        flush events after init
                    rts

*  set up calls to joysticks
reset_joy           clr       >$0541              clear joystick button status
                    clr       >$0542              clear joystick state byte
PollJoystick        lda       <JoyEnabled            joystick enabled?
                    lbeq      JoyPollRet          no — skip poll
                    ldb       >$0547              check movement threshold flag
                    beq       JoystickUpdate      zero — go read joystick now
                    ldx       <JoyTimerHi            load timer hi
                    bne       JoyPollCheck        nonzero — check timing
                    ldx       <JoyTimerLo            load timer lo
                    bne       JoyPollCheck        nonzero — check timing
                    clra                          clear A for timestamp calc
CalcJoyDelta        orcc      #IntMasks           disable interrupts for timestamp read
                    addd      >$024B              add tick counter hi
                    std       <JoyTimerHi            store timer hi
                    ldd       >$0249              read tick counter lo
                    andcc     #^IntMasks          re-enable interrupts
                    bcc       JoyDeltaStore       no carry — store directly
                    addd      #$0001              adjust for carry
JoyDeltaStore       std       <JoyTimerLo            store timer lo
                    bne       JoyPollCheck        nonzero — check timing now
                    ldd       <JoyTimerHi            reload timer hi
                    bne       JoyPollCheck        nonzero — check timing
                    inc       <JoyDebounce            both zero — increment debounce counter
JoyPollCheck        orcc      #IntMasks           disable interrupts for comparison
                    ldx       >$024B              load tick counter hi
                    ldd       >$0249              load tick counter lo
                    andcc     #^IntMasks          re-enable interrupts
                    cmpd      <JoyTimerLo            compare lo against stored threshold
                    bhi       JoystickUpdate      past threshold — update joystick
                    cmpx      <JoyTimerHi            compare hi against threshold
                    bls       JoyPollEnd          not yet — skip update

JoystickUpdate      ldd       #$0000              clear timer accumulators
                    std       <JoyTimerLo            clear timer lo
                    std       <JoyTimerHi            clear timer hi
                    bsr       ReadJoystick        read joystick x,y position
                    lbsr      CheckJoyDirection   map position to direction code
                    ldb       >ExtTableFlag       check extended-mode flag
                    bne       JoyCheckBtn         extended — check button only
                    ldb       >$0180              check movement-event flag
                    beq       JoyCheckChange      zero — check for direction change
JoyCheckBtn         tsta                          direction code = 0?
                    beq       JoyPollEnd          yes — no event to push
                    bra       JoyPushEvent        push direction event
JoyCheckChange      cmpa      <JoyLastDir            direction changed?
                    beq       JoyPollEnd          same — no event
                    ldb       >ClockState         check input-busy flag
                    bne       JoyPollEnd          busy — suppress event
                    sta       <JoyLastDir            save new direction
                    cmpa      >$0438              same as last pushed direction?
                    beq       JoyPollEnd          yes — no duplicate event
JoyPushEvent        ldb       #$02                event type 2 = joystick direction
                    lbsr      EventPush           push joystick direction event
JoyPollEnd          bsr       PollJoyButton       poll joystick button state
JoyPollRet          rts

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

ReadJoystick        pshs      y                   save Y (clobbered by I$GetStt)
                    lda       #StdIn              path 0 (stdin)
                    ldb       #SS.Joy             SS.Joy status code ($13)
                    ldx       <JoyNum             joystick number (0=right, 1=left)
                    os9       I$GetStt            read joystick position
                    tfr       x,d                 move X axis value to D
                    leax      >JoystickData,pcr   point to joystick data storage
                    sty       $01,x               store Y axis value
                    std       ,x                  store X axis value
                    puls      y                   restore Y
                    rts

ReadJoyButton       pshs      y                   save Y (clobbered by I$GetStt)
                    lda       #StdIn              path 0 (stdin)
                    ldb       #SS.Joy             SS.Joy status code ($13)
                    ldx       <JoyNum             joystick number
                    os9       I$GetStt            read joystick status
                    sta       >$0541              store fire-button state
                    puls      y                   restore Y
                    rts

PollJoyButton       bsr       ReadJoyButton       read current button state
                    lda       >$0542              load button-tracking state
                    cmpa      #$02                in "timing" state?
                    bne       JoyBtnState         no — check button state
                    orcc      #IntMasks           disable interrupts for tick read
                    ldx       >$024B              load tick counter hi
                    ldd       >$0249              load tick counter lo
                    andcc     #^IntMasks          re-enable interrupts
                    cmpd      >$0543              compare lo against click threshold
                    blo       JoyBtnState         before threshold — not a click yet
                    bhi       JoyClickEvent       past threshold — fire click event
                    cmpx      >$0545              compare hi against threshold
                    bcs       JoyBtnState         before hi threshold — not yet
JoyClickEvent       clr       >$0542              clear button-tracking state
                    lda       #$FC                button-click event code
                    ldb       #$01                event data byte
                    lbsr      EventPush           push button-click event
                    bra       JoyBtnTrack         track button state
JoyBtnState         lda       >$0542              reload tracking state
                    beq       JoyBtnTrack         zero — not tracking, just track
                    cmpa      #$02                still in timing state?
                    bne       JoyBtnHold          no — check hold state
JoyBtnTrack         lda       >$0541              read current button
                    beq       PollJoyButtonRet    button up — done
                    inc       >$0542              button down — advance tracking state
                    bra       PollJoyButtonRet    done
JoyBtnHold          cmpa      #$01                in "first press" state?
                    bne       JoyBtnUp            no — check for release
                    lda       >$0541              check if still held
                    bne       PollJoyButtonRet    still held — wait
                    lda       >$01B0              load state flags
                    anda      #$80                check movement-in-progress flag
                    beq       JoyClickEvent       not moving — treat as click
                    clra                          clear A for timestamp calc
                    ldb       >$0441              load click-hold delay threshold
                    orcc      #IntMasks           disable interrupts
                    addd      >$024B              add tick counter hi
                    std       >$0545              store timestamp hi threshold
                    ldd       >$0249              read tick counter lo
                    andcc     #^IntMasks          re-enable interrupts
                    bcc       JoyBtnTimestamp     no carry — store directly
                    addd      #$0001              adjust for carry
JoyBtnTimestamp     std       >$0543              store timestamp lo threshold
                    inc       >$0542              advance to timing state (2)
                    bra       PollJoyButtonRet    done
JoyBtnUp            lda       >$0541              button still held?
                    bne       PollJoyButtonRet    yes — wait for release
                    clr       >$0542              button released — clear state
                    lda       #$FE                button-release event code
                    ldb       #$01                event data byte
                    lbsr      EventPush           push button-release event
PollJoyButtonRet    rts

* This does a check of the joystick values but I'm confused
* since at this point x points to JoystickData the first of three bytes
* byte 0 (JoystickData) = x co-ordinate
* byte 1 (L22AB) = y co-ordinate
* byte 2 (L22AC) = null since nobody set it
* Possible good old C-code off by one error ???

CheckJoyDirection   lda       $02,x               load 3rd byte (null — always 0; see note above)
                    ldb       $01,x               load Y axis value
                    cmpa      #$25                compare null byte to $25 (always ≤ $25)
                    bls       JoyDirLow           always taken — code below is dead
*                           dead code ???
                    lda       #$08                direction 8 (up-left)
                    cmpb      #$16                Y < $16?
                    blo       JoyDirRet           yes — return direction 8
                    lda       #$02                direction 2 (up)
                    cmpb      #$25                Y < $25?
                    bhi       JoyDirRet           yes — return direction 2
                    lda       #$01                direction 1 (up-right)
                    bra       JoyDirRet           return direction 1
*                          end of dead code  ???
JoyDirLow           cmpa      #$16                compare null byte to $16 (always < $16)
                    bcc       JoyDirHigh          always not taken — code below also dead
                    lda       #$06                direction 6 (left)
                    cmpb      #$16                Y < $16?
                    blo       JoyDirRet           yes — return 6
                    lda       #$04                direction 4 (center-left)
                    cmpb      #$25                Y > $25?
                    bhi       JoyDirRet           yes — return 4
                    lda       #$05                direction 5 (none / center)
                    bra       JoyDirRet           return 5
JoyDirHigh          lda       #$07                direction 7 (right)
                    cmpb      #$16                Y < $16?
                    blo       JoyDirRet           yes — return 7
                    lda       #$03                direction 3 (center-right)
                    cmpb      #$25                Y > $25?
                    bhi       JoyDirRet           yes — return 3
                    lda       #$00                direction 0 (center)
JoyDirRet           rts


JoyKeyMapPrimary    fcb       $1C,$01
                    fcb       $10,$02
                    fcb       $19,$03
                    fcb       $11,$04
                    fcb       $1A,$05
                    fcb       $12,$06
                    fcb       $18,$07
                    fcb       $13,$08
                    fcb       $00,$00

JoyKeyMapSecondary  fcb       $0C,$01
                    fcb       $09,$03
                    fcb       $0A,$05
                    fcb       $08,$07
                    fcb       $00,$00

*  reads input from stdin and discards it ???
clear_key_queue     lbsr      ReadStdinByte       read and discard one stdin byte
                    tsta                          any data returned?
                    bne       clear_key_queue     yes — keep draining queue
                    rts

PollKeyInput        lbsr      ReadStdinByte       read one byte from stdin
                    tsta                          any data?
                    beq       PollKeyInputRet     no — nothing to process
                    bsr       LookupKeyInTable    look up key code in joystick map
                    tstb                          match found?
                    bmi       CheckKeyTable2      negative (no match) — check table 2
                    ldb       #$02                event type 2 = joystick direction
                    bra       PushKeyEvent        push joystick direction event
CheckKeyTable2      cmpa      #$0C                key code $0C?
                    beq       PollKeyInputRet     yes — discard (special key)
                    ldb       #$01                event type 1 = keyboard key
PushKeyEvent        lbsr      EventPush           push key/direction event
PollKeyInputRet     rts

* compares value passed in "a" to table vals
LookupKeyInTable    leax      >JoyKeyMapPrimary,pcr load primary joystick key map
LookupKeyLoop       cmpa      ,x+                 compare A with table entry, advance X
                    beq       LookupKeyMatch      match — load corresponding direction
                    ldb       ,x+                 load direction byte, advance X
                    bne       LookupKeyLoop       nonzero — more entries to check
                    ldb       >ExtTableFlag       end of primary table — check extended flag
                    beq       LookupKeyNoMatch    flag clear — no match
                    leax      >JoyKeyMapSecondary,pcr load secondary key map
LookupKeyLoop2      cmpa      ,x+                 compare A with secondary table entry
                    beq       LookupKeyMatch      match — load direction
                    ldb       ,x+                 load direction byte, advance X
                    bne       LookupKeyLoop2      nonzero — more entries
LookupKeyNoMatch    ldb       #$FF                no match — return $FF in B (negative)
                    bra       LookupKeyRet        exit
LookupKeyMatch      lda       ,x                  load direction code (byte after matched key)
                    clrb                          clear B (match found, not negative)
LookupKeyRet        rts

LogicTableData      fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000
                    fdb       $0000

ClearLogicTable     leax      >LogicTableData,pcr load logic table address
                    ldd       #$0000              zero value
                    std       ,x                  clear first entry pointer
                    rts

* waste of time since you zero it out and don't save anything
ResetLogicTable     leay      >LogicTableData,pcr load logic table address
                    ldy       ,y                  load first entry pointer
                    beq       ResetLogicTableRet  zero — nothing to reset
                    ldd       #$0000              clear value
                    std       ,y                  zero out the entry
ResetLogicTableRet  rts


FindLogicSlot       leau      >LogicTableData,pcr load logic table pointer
FindLogicSlotLoop   stu       <LogicTablePtr      save current table entry pointer
                    ldu       ,u                  load next pointer in chain
                    beq       FindLogicSlotRet    null — end of table
                    cmpb      $02,u               compare logic number with entry
                    bne       FindLogicSlotLoop   no match — continue
FindLogicSlotRet    rts

cmd_load_logics     ldb       ,y+                 read logic number from bytecode
                    bsr       LoadLogicNum        load logic by number
                    rts

cmd_load_logics_v   ldb       ,y+                 read variable index from bytecode
                    ldx       #$0432              flag table base address
                    abx                           index into flag table
                    ldb       ,x                  load logic number from variable
                    bsr       LoadLogicNum        load logic by number
                    rts

LoadLogicNum        leas      -$01,s              allocate 1-byte local
                    stb       ,s                  save logic number
                    lda       #$00                script type 0
                    lbsr      PushScript          push current logic script context
                    ldb       ,s                  reload logic number
                    bsr       AllocLoadLogic      allocate and load logic
                    leas      $01,s               release local frame
                    rts

AllocLoadLogic      leas      -$07,s              allocate 7-byte local frame
                    stb       ,s                  save logic number
                    bsr       FindLogicSlot       search logic table for cached entry
                    cmpu      #$0000              found in cache?
                    bne       AllocLoadLogicRet   yes — return existing slot
                    ldd       <PsgCurLatch        save current PSG latch state
                    std       $03,s               stash on frame
                    lbsr      BlitBothErase       erase both screen buffers
                    ldd       #$000C              12 bytes per logic slot
                    lbsr      AllocDataBlock      allocate logic slot
                    ldx       <LogicTablePtr      load current table entry pointer
                    stu       ,x                  link new slot into table
                    ldd       #$0000              zero forward pointer
                    std       ,u                  store as new slot's forward pointer
                    ldb       ,s                  reload logic number
                    stb       $02,u               store logic number in slot
                    stu       $01,s               save new slot pointer on frame
                    lbsr      FetchLogic          fetch logic data for this number
                    ldx       #$0000              volume file index arg
                    lbsr      OpenVolFile         open volume file for this logic
                    beq       AllocLoadLogicEnd   empty volume — skip load
                    ldx       $01,s               reload slot pointer
                    std       $04,x               store volume offset in slot
                    leau      $02,u               advance U past header
                    stu       $06,x               store data start pointer
                    stu       $08,x               store secondary data pointer
                    ldb       -$02,u              load data size hi
                    lda       -$01,u              load data size lo
                    leau      d,u                 advance to message area
                    lda       ,u+                 load message count, advance U
                    stu       $0A,x               store message pointer
                    sta       $03,x               store message count in slot
                    beq       AllocLoadLogicEnd   no messages — skip decrypt
                    ldd       <CurrentLogicPtr    load current logic context
                    std       $05,s               save on frame for restore
                    stx       <CurrentLogicPtr    set new logic as current
                    clrb                          message index 0 (first message)
                    lbsr      GetMsgPtr           get pointer to messages
                    clra                          clear A
                    ldb       $03,x               load message count from slot
                    ldx       $0A,x               load message table pointer
                    addd      #$0001              add 1 for length word
                    lslb                          multiply by 2 (each entry is word)
                    rola                          shift high byte
                    leax      d,x                 point to message data start
                    lbsr      XorDecrypt          decrypt message strings
                    ldd       $05,s               reload saved logic context
                    std       <CurrentLogicPtr    restore previous logic context
AllocLoadLogicEnd   lbsr      EraseAndBlitShdw    erase/blit shadow buffer
                    ldd       $03,s               reload saved PSG latch
                    lbsr      SetLogicPage        set logic page
                    ldu       $01,s               reload new logic slot pointer
AllocLoadLogicRet   leas      $07,s               release 7-byte local frame
                    rts

cmd_call            leas      -$02,s              allocate 2-byte local frame
                    ldb       ,y+                 read logic number from bytecode
                    sty       ,s                  save current bytecode pointer
                    bsr       ExecLogic           execute called logic
                    leay      ,y                  test Y (null return?)
                    beq       CmdCallRet          null — restore saved Y
                    ldy       ,s                  restore bytecode pointer from frame
CmdCallRet          leas      $02,s               release local frame
                    rts

cmd_call_v          leas      -$02,s              allocate 2-byte local frame
                    ldb       ,y+                 read variable index from bytecode
                    ldx       #$0432              flag table base
                    abx                           index into flag table
                    ldb       ,x                  load logic number from variable
                    sty       ,s                  save current bytecode pointer
                    bsr       ExecLogic           execute logic by variable
                    leay      ,y                  test Y
                    beq       CmdCallVRet         null — restore saved Y
                    ldy       ,s                  restore bytecode pointer
CmdCallVRet         leas      $02,s               release local frame
                    rts

* ====================================================================
* LOGIC SCRIPT EXECUTION ENGINE
* ExecLogic loads the bytecode for a given logic resource and runs
* it through ExecLogicScript. Nested calls via cmd_call recurse back
* into ExecLogic with the caller's bytecode pointer saved on the
* stack. ExecLogicScript dispatches condition (test) opcodes through
* eval_table and action opcodes through cmd_table. Each opcode
* handler reads its own operand bytes directly from Y.
* ====================================================================
ExecLogic           leas      -$0A,s              allocate 10-byte local frame
                    stb       ,s                  save logic number
                    ldd       <CurrentLogicPtr    save caller's logic context
                    std       $01,s               stash on frame
                    lda       #$01                flag: this logic is pre-loaded
                    sta       $03,s               store pre-loaded flag
                    ldb       ,s                  reload logic number
                    lbsr      FindLogicSlot       search cache for this logic
                    stu       <CurrentLogicPtr    point to found/new slot
                    beq       ExecLogicLoad       slot was empty — need to load
                    ldd       $04,u               logic already cached — get page number
                    lbsr      SetLogicPage        map cached logic into memory
                    bra       ExecLogicRun        skip load, go execute
ExecLogicLoad       ldd       <LogicTablePtr      save logic table pointer for cleanup
                    std       $04,s               stash on frame
                    ldb       ,s                  reload logic number
                    lbsr      AllocLoadLogic      allocate slot and load logic from disk
                    stu       <CurrentLogicPtr    point to newly loaded slot
                    stu       $06,s               save slot pointer for heap cleanup
                    lda       $04,u               get page number of loaded logic
                    ldu       $06,u               reload slot pointer
                    leau      -$02,u              point just before logic data
                    lbsr      CalcPriAddr         compute priority display address
                    stu       $08,s               save priority address for cleanup
                    clr       $03,s               clear pre-loaded flag (loaded dynamically)
ExecLogicRun        lda       <NegCondFlag        check if trace needs reset
                    cmpa      #$02                NegCondFlag == 2 (deferred reset)?
                    bne       ExecLogicRetState   no — skip reset
                    lda       #$01                reset to active trace state
                    sta       <NegCondFlag        store updated flag
ExecLogicRetState   lda       ,s                  load logic state byte
                    bne       ExecLogicRetCheck   nonzero — skip first-time init
                    lda       #$01                set first-run flag
                    sta       <FirstExecFlag            signal first-time execution
ExecLogicRetCheck   lbsr      ExecLogicScript     run the logic bytecode
                    lda       $03,s               was logic pre-loaded?
                    bne       ExecLogicRestore    yes — skip heap cleanup
                    ldd       #$0000              zero the logic table entry
                    ldx       $04,s               load saved table pointer
                    std       ,x                  clear table entry (logic unloaded)
                    lbsr      BlitBothErase       erase screen objects
                    ldd       $08,s               load saved priority address
                    std       <HeapPtr            restore heap pointer
                    ldd       $06,s               load saved slot pointer
                    std       <HeapTop            restore heap top
                    lbsr      EraseAndBlitShdw    redraw shadow screen
ExecLogicRestore    ldu       $01,s               reload saved caller context
                    stu       <CurrentLogicPtr    restore caller's logic pointer
                    beq       ExecLogicRet        caller was null — top-level return
                    ldd       $04,u               get caller's page number
                    lbsr      SetLogicPage        restore caller's page mapping
ExecLogicRet        leas      $0A,s               release 10-byte local frame
                    rts

cmd_set_scan_start  ldx       <CurrentLogicPtr    load current logic slot pointer
                    sty       $08,x               store bytecode pointer as scan start
                    rts

cmd_reset_scan_start ldx      <CurrentLogicPtr    load current logic slot pointer
                    ldd       $06,x               load base data pointer
                    std       $08,x               reset scan start to base
                    rts

BuildLogicList      leau      >LogicTableData,pcr point to logic table
                    ldx       #$0554              output list buffer address
BuildLogicListLoop  lda       $02,u               load logic number from slot
                    sta       ,x                  store in output list
                    ldd       $08,u               load scan-end pointer
                    subd      $06,u               subtract data start = size
                    std       $01,x               store size in list entry
                    leax      $03,x               advance output pointer (3 bytes/entry)
                    ldu       ,u                  follow forward chain pointer
                    bne       BuildLogicListLoop  more entries — loop
                    lda       #$FF                end-of-list sentinel
                    sta       ,x                  store sentinel
                    tfr       x,d                 compute list length
                    subd      #$0553              subtract base address
                    tfr       d,x                 return length in X
                    rts

SeekLogicInList     ldx       #$0554              logic list base address
SeekLogicListLoop   lda       ,x                  load next list entry logic number
                    cmpa      #$FF                end-of-list sentinel?
                    beq       SeekLogicListRet    yes — logic not found
                    cmpa      $02,u               compare with target logic number
                    beq       SeekLogicFound      match — update scan pointer
                    leax      $03,x               advance to next entry
                    bra       SeekLogicListLoop   loop
SeekLogicFound      ldd       $06,u               load current scan position
                    addd      $01,x               add entry's size offset
                    std       $08,u               update scan-end pointer
SeekLogicListRet    rts


StrOutOfMemory      fcc       'Out of %s memory.'
                    fcb       C$LF
                    fcc       'Want: %d, Have: %d'
                    fcb       C$NULL

StrHeap             fcc       'heap'
                    fcb       C$NULL

StrCommon           fcc       'common'
                    fcb       C$NULL


AllocHeap           leas      -$34,s              allocate 52-byte local frame
                    std       ,s                  save requested size
                    ldd       <HeapPtr            load current heap pointer
                    tfr       d,u                 save as return address
                    addd      ,s                  add requested size
                    bcc       AllocHeapOk         no overflow — proceed
AllocHeapFull       ldd       #$FFFF              overflow: compute available space
                    subd      <HeapPtr            subtract current heap pointer
                    addd      #$0001              add 1 for accurate count
                    pshs      b,a                 push available space
AllocHeapFailMsg    ldd       $02,s               load requested size
                    pshs      b,a                 push requested size
                    leax      >StrHeap,pcr        "heap" label string
                    bra       ShowOutOfMemMsg     show out-of-memory message
AllocHeapOk         std       <HeapPtr            update heap pointer
                    lbsr      UpdateFreeSpace     update free-space display
                    ldd       <HeapPtr            reload updated heap pointer
                    cmpd      <SierraModSize      past largest seen size?
                    bls       AllocHeapRet        no — done
                    std       <SierraModSize      yes — update high-water mark
AllocHeapRet        leas      <$34,s              release local frame
                    rts

AllocDataBlock      leas      <-$34,s             allocate 52-byte local frame
                    std       ,s                  save requested size
                    ldd       <DataBlockSize      load total data block size
                    subd      <HeapTop            subtract current heap top
                    cmpd      ,s                  enough space for request?
                    bcc       AllocDataBlockOk    yes — allocate
                    pshs      b,a                 push available space
                    ldd       $02,s               load requested size
                    pshs      b,a                 push requested size
AllocDataBlockFail  leax      >StrCommon,pcr      "common" label string
ShowOutOfMemMsg     pshs      x                   push memory-area label
                    leax      >StrOutOfMemory,pcr "Out of %s memory." format string
                    leau      $08,s               point to message output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format out-of-memory message
                    leas      $0A,s               pop 5 args (10 bytes)
                    lbsr      message_box         display out-of-memory dialog

                    lda       #$03                offset to exit_agi() entry point
                    sta       <SierraRemapOff     save remap offset
                    ldx       <SierraRemapVal     load remap-to-sierra base
                    jsr       >$0659              invoke MMU twiddler to call exit_agi

AllocDataBlockOk    ldd       <HeapTop            load current heap top
                    tfr       d,u                 save as return pointer
                    addd      ,s                  add requested size
                    std       <HeapTop            update heap top
                    cmpd      <HeapEnd            past end of data block?
                    bls       AllocDataBlockRet   no overflow — allocation succeeded
                    std       <HeapEnd            update heap end pointer
AllocDataBlockRet   leas      <$34,s              release local frame
                    rts

ResetHeap           lbsr      BlitBothDraw        redraw both screen buffers
                    ldd       <MnlnModSize        reload original module size
                    std       <HeapPtr            reset heap pointer to module end
                    bsr       UpdateFreeSpace     update free-space display
                    ldd       <HeapBase           reload heap base pointer
                    std       <HeapTop            reset heap top to base
                    rts

UpdateFreeSpace     ldd       #$FFFF              max address
                    subd      <HeapPtr            subtract current heap pointer
                    sta       >$043A              store free-space byte
                    rts

CalcPriAddr         suba      <PriorityYBase      subtract priority Y base
                    ldb       #$20                32 bytes per priority row
                    mul                           compute row byte offset
                    exg       b,a                 swap: A=lo, B=hi
                    subd      #$2000              subtract block base ($2000)
                    leau      d,u                 apply offset to U
                    rts

CalcPriCoord        tfr       u,d                 copy U to D
                    anda      #$1F                extract column offset (low 5 bits)
                    adda      #$20                add $20 (base column)
                    exg       d,u                 swap D and U
                    lsra                          shift right 1
                    lsra                          shift right 2
                    lsra                          shift right 3
                    lsra                          shift right 4
                    lsra                          shift right 5 (divide by 32)
                    adda      <PriorityYBase      add priority Y base
                    tfr       a,b                 copy row to B
                    incb                          increment B (1-based row)
                    rts

SetLogicPage        cmpa      <PsgCurLatch        same page already mapped?
                    beq       SetLogicPageRet     yes — nothing to do
                    orcc      #IntMasks           disable interrupts for page switch
                    std       <PsgCurLatch        save new latch value
                    lda       <PsgBlockNum        load PSG MMU block number
                    sta       >$FFA9              map PSG block into MMU slot 9
                    ldx       <PsgPortAddr        load PSG port address
                    lda       <PsgCurLatch        reload latch byte
                    sta       ,x                  write latch to PSG port
                    stb       $02,x               write data byte to PSG
                    std       >$FFA9              restore previous MMU mapping
                    andcc     #^IntMasks          re-enable interrupts
SetLogicPageRet     rts

MenuItemCurrent     fdb       $0000
MenuCurrent         fdb       $0000
MenuItemNum         fcb       $00
MenuItemMaxLen      fcb       $00
MenuHead            fdb       $0000
MenuCurWidth        fcb       $00
MenuItemRow         fcb       $00
MenuItemWidth       fcb       $00
MenuItemCol         fcb       $00
MenuItemHeight      fcb       $00
MenuSubmitted       fcb       $00


cmd_set_menu        leas      -$04,s              allocate 4-byte local frame
                    ldb       ,y+                 read message number from bytecode
                    lbsr      GetMsgPtr           get pointer to menu-name message
                    stu       ,s                  save message pointer
                    ldu       <CurrentLogicPtr    load current logic slot
                    ldd       $04,u               get logic page number
                    std       $02,s               save page for new menu entry
                    lda       >MenuSubmitted,pcr  check if menu already submitted
                    bne       SetMenuItemReturn   already submitted — skip
                    ldd       #$0010              16 bytes per menu entry
                    lbsr      AllocDataBlock      allocate menu entry
                    ldd       >MenuHead,pcr       load menu list head
                    bne       SetMenuAppend       list exists — append
                    stu       >MenuHead,pcr       empty list — set this as head
                    lda       #$01                initial column position
                    sta       >MenuCurWidth,pcr   store current menu width
                    bra       SetMenuLink         go link entry
SetMenuAppend       ldx       >MenuCurrent,pcr    load last menu entry pointer
                    stu       ,x                  link new entry at end of list
                    stx       $02,u               set new entry's back pointer
                    ldd       $0B,x               load last item's column
                    bne       SetMenuLink         has items — keep column
                    sta       $0A,x               clear column (no items yet)
SetMenuLink         ldx       >MenuHead,pcr       load menu head pointer
                    stx       ,u                  store head as forward link
                    stu       $02,x               store this entry as head's back
                    stu       >MenuCurrent,pcr    update current menu pointer
                    ldd       #$0000              zero value
                    std       $0B,u               clear item list pointer
                    sta       $08,u               clear item count
                    sta       $0F,u               clear item flags
                    lda       >MenuCurWidth,pcr   load current column position
                    sta       $09,u               store column in menu entry
                    lda       #$01                enabled flag
                    sta       $0A,u               mark menu as enabled
                    ldx       ,s                  load saved message pointer
                    stx       $04,u               store name pointer in entry
                    ldd       $02,s               load saved page number
                    std       $06,u               store page in entry
                    lbsr      StrLen              compute menu name length
                    incb                          add 1 (include null terminator)
                    addb      >MenuCurWidth,pcr   add to current column position
                    stb       >MenuCurWidth,pcr   update column width
                    ldd       #$0000              zero value
                    std       >MenuItemCurrent,pcr clear current item pointer
                    lda       #$01                starting item number
                    sta       >MenuItemNum,pcr    store item number
SetMenuItemReturn   leas      $04,s               release 4-byte local frame
                    rts

cmd_set_menu_item   leas      -$05,s              allocate 5-byte local frame
                    ldb       ,y+                 read message index from bytecode
                    lbsr      GetMsgPtr           get pointer to item-name message
                    stu       ,s                  save message pointer
                    ldu       <CurrentLogicPtr    load current logic slot
                    ldd       $04,u               load logic page number
                    std       $02,s               save page
                    lda       ,y+                 read item action code from bytecode
                    sta       $04,s               save action code
                    lda       >MenuSubmitted,pcr  check if menu already submitted
                    bne       SetMenuItemRet      already submitted — skip
                    ldd       #$000C              12 bytes per menu item
                    lbsr      AllocDataBlock      allocate menu item entry
                    ldx       >MenuItemCurrent,pcr load current item pointer
                    bne       SetMenuItemAppend   has items — append
                    ldx       >MenuCurrent,pcr    no items yet — get menu entry
                    stu       $0D,x               store item as menu's last item
                    stu       $0B,x               store item as menu's first item
                    stu       $02,u               store menu as item's back link
                    bra       SetMenuItemLink     go link
SetMenuItemAppend   stu       ,x                  link new item at current end
                    stx       $02,u               set back pointer to previous
                    ldx       >MenuCurrent,pcr    load menu entry
SetMenuItemLink     ldx       $0B,x               load first item pointer
                    stx       ,u                  store as this item's forward link
                    stu       $02,x               set first item's back to this
                    stu       >MenuItemCurrent,pcr update current item pointer
                    ldx       ,s                  load saved message pointer
                    stx       $04,u               store name pointer in item
                    ldd       $02,s               load saved page number
                    std       $06,u               store page in item
                    lda       >MenuItemNum,pcr    load current item number
                    inc       >MenuItemNum,pcr    advance item counter
                    cmpa      #$01                first item in this menu?
                    bne       SetMenuItemStore    no — skip max-length calc
                    lbsr      StrLen              compute item name length
                    negb                          negate for column calc
                    addb      #$27                add $27 (39) to compute max width
                    ldx       >MenuCurrent,pcr    load menu entry
                    cmpb      $09,x               compare with menu column position
                    bls       SetMenuItemMaxLen   computed ≤ column — use it
                    ldb       $09,x               else use menu column position
SetMenuItemMaxLen   stb       >MenuItemMaxLen,pcr store max item display length
SetMenuItemStore    ldd       >MenuItemNum,pcr    load updated item number
                    std       $08,u               store item number in entry
                    lda       #$01                enabled flag
                    sta       $0A,u               mark item as enabled
                    lda       $04,s               load saved action code
                    sta       $0B,u               store action code in item
                    ldx       >MenuCurrent,pcr    load menu entry
                    inc       $0F,x               increment menu's item count
SetMenuItemRet      leas      $05,s               release 5-byte local frame
                    rts

cmd_submit_menu     ldu       >MenuCurrent,pcr    load last menu entry pointer
                    ldd       $0B,u               check item list pointer
                    bne       SubmitMenuFinalize  has items — finalize
                    sta       $0A,u               mark menu column as active
SubmitMenuFinalize  ldd       <HeapTop            snapshot current heap top
                    std       <HeapBase           save as base for menu data
                    ldu       >MenuHead,pcr       load menu list head
                    stu       >MenuCurrent,pcr    reset current to head
                    ldd       $0B,u               load first menu's item list
                    std       >MenuItemCurrent,pcr set as current item pointer
                    lda       #$01                submitted flag
                    sta       >MenuSubmitted,pcr  mark menu as submitted
                    rts

cmd_enable_item     lda       ,y+                 read action code from bytecode
                    ldb       #$01                enable flag = 1
                    bsr       SetItemEnable       enable menu item
                    rts

EnableItemLoop      ldu       >MenuHead,pcr       load menu list head
                    beq       EnableItemRet       empty — done
EnableItemScan      lda       $0A,u               check menu enabled flag
                    beq       EnableItemNext      disabled — skip items
                    ldx       $0B,u               load first item pointer
EnableItemInner     lda       #$01                enable flag
                    sta       $0A,x               mark item as enabled
                    ldx       ,x                  follow item forward link
                    cmpx      $0B,u               back to first item?
                    bne       EnableItemInner     no — continue
EnableItemNext      ldu       ,u                  follow menu forward link
                    cmpu      >MenuHead,pcr       back to head?
                    bne       EnableItemScan      no — continue scanning
EnableItemRet       rts

cmd_disable_item    lda       ,y+                 read action code from bytecode
                    ldb       #$00                disable flag = 0
                    bsr       SetItemEnable       disable menu item
                    rts

SetItemEnable       leas      -$02,s              allocate 2-byte local frame
                    std       ,s                  save action code and enable flag
                    ldu       >MenuHead,pcr       load menu list head
SetItemEnableLoop   lda       $0A,u               check menu enabled flag
                    beq       SetItemEnableNext   disabled menu — skip
                    ldx       $0B,u               load first item pointer
                    ldd       ,s                  reload action code and flag
SetItemEnableInner  cmpa      $0B,x               compare action code with item
                    bne       SetItemEnableMatch  no match — check next
                    stb       $0A,x               match — store enable/disable flag
SetItemEnableMatch  ldx       ,x                  follow item forward link
                    cmpx      $0B,u               back to first item?
                    bne       SetItemEnableInner  no — continue
SetItemEnableNext   ldu       ,u                  follow menu forward link
                    cmpu      >MenuHead,pcr       back to head?
                    bne       SetItemEnableLoop   no — continue
                    leas      $02,s               release local frame
                    rts

cmd_menu_input      lda       >$01B0              load game state flags
                    anda      #$02                test menu-input-pending flag (bit 1)
                    beq       MenuInputRet        not pending — done
                    lda       #$01                set menu-input-active flag
                    sta       >$05AE              signal menu input is active
MenuInputRet        rts

DrawMenuBar         leas      -$04,s              allocate 4-byte frame (,s=menu ptr, $02=item ptr)
                    lbsr      PushRowCol          save cursor position
                    lbsr      PushTextColor       save text color
                    ldd       #$000F              row 0, col 15
                    lbsr      ClearTextLine       erase status/menu bar line
                    ldu       >MenuHead,pcr       data word
DrawMenuBarLoop     stu       ,s                  save current menu pointer
                    ldx       ,s                  X = current menu node
                    lbsr      DrawMenuItemNormal  draw this menu title (normal style)
                    ldu       ,s                  reload menu pointer
                    ldu       ,u                  follow next-menu link
                    cmpu      >MenuHead,pcr       data word
                    bne       DrawMenuBarLoop     not back to head — more menus
                    ldd       >MenuItemCurrent,pcr load last-selected menu item
                    std       $02,s               save as current item
                    ldu       >MenuCurrent,pcr    load last-selected menu
                    stu       ,s                  save as current menu
                    lbsr      DrawMenuItem        draw current menu + item list
                    lda       #$01                enable extended table lookup
                    sta       >ExtTableFlag       flag for extended table lookup
                    lda       #$03                joystick button state initial value
                    sta       >$0547              initialize joystick button state register
MenuInputEventLoop  lbsr      WaitForEvent        wait for key or joystick
                    lda       ,x                  load event type
                    cmpa      #$01                keypress event?
                    bne       MenuNavEvent        no — joystick nav event
                    lda       $01,x               load key character
                    cmpa      #$0D                Enter key?
                    bne       MenuEscCheck        no — check Escape
                    ldu       $02,s               U = current item node
                    lda       $0A,u               item enabled flag
                    beq       MenuInputEventLoop  disabled — ignore Enter
                    lda       $0B,u               item key/event code
                    ldb       #$03                event type = remapped key
                    lbsr      EventPush           push item's action as event
                    bra       MenuInputAccept     close menu
MenuEscCheck        cmpa      #$1B                Escape key?
                    lbne      MenuNavUpdate       no — treat as nav event
MenuInputAccept     ldu       ,s                  U = current menu
                    ldx       $02,s               X = current item
                    lbsr      EraseMenuItem       erase dropdown
                    clr       >$0547              clear joystick state
                    lbsr      PopTextColor        restore saved text color
                    lbsr      PopRowCol           restore saved cursor
                    lda       >StatusState        state.status_state
                    beq       MenuInputHideStatus status bar off — just clear
                    lbsr      StatusLineWrite     redraw status bar
                    lbra      MenuInputExit       return from menu input
MenuInputHideStatus ldd       #$0000              row 0, col 0
                    lbsr      ClearTextLine       erase menu bar area
                    lbra      MenuInputExit       return from menu input
MenuNavEvent        cmpa      #$02                joystick event type?
                    lbne      MenuNavUpdate       no — unknown, skip
                    lda       $01,x               load direction code
                    cmpa      #$01                direction up?
                    bne       MenuNavDown         no — check down
                    ldx       $02,s               X = current item
                    lbsr      DrawMenuItemNormal  unhighlight current
                    ldx       $02,s               reload item
                    ldx       $02,x               follow prev-item link
                    stx       $02,s               update current item
                    lbsr      DrawMenuItemHighlight highlight new item
                    lbra      MenuNavUpdate       wait for next event
MenuNavDown         cmpa      #$02                direction down?
                    bne       MenuNavRight        no — check right
                    ldx       $02,s               X = current item
                    lbsr      DrawMenuItemNormal  unhighlight current
                    ldu       ,s                  U = current menu
                    ldx       $0B,u               follow next-item link
                    stx       $02,s               update current item
                    lbsr      DrawMenuItemHighlight highlight new item
                    lbra      MenuNavUpdate       wait for next event
MenuNavRight        cmpa      #$03                direction right?
                    bne       MenuNavLeft         no — check left
                    ldu       ,s                  U = current menu
                    ldx       $02,s               X = current item
                    lbsr      EraseMenuItem       erase this menu's dropdown
                    ldu       ,s                  reload current menu
MenuNavRightScan    ldu       ,u                  advance to next menu node
                    lda       $0A,u               menu has items?
                    beq       MenuNavRightScan    no items — skip to next
                    stu       ,s                  save new current menu
                    ldx       $0D,u               load first item of new menu
                    stx       $02,s               set as current item
                    lbsr      DrawMenuItem        draw new menu + item list
                    lbra      MenuNavUpdate       wait for next event
MenuNavLeft         cmpa      #$04                direction left?
                    bne       MenuNavUp           no — check up
                    ldx       $02,s               X = current item
                    lbsr      DrawMenuItemNormal  unhighlight current
                    ldu       ,s                  U = current menu
                    ldx       $0B,u               load current item's prev link
                    ldx       $02,x               follow prev-item's prev
                    stx       $02,s               update current item
                    lbsr      DrawMenuItemHighlight highlight new item
                    bra       MenuNavUpdate       wait for next event
MenuNavUp           cmpa      #$05                direction further up (page up)?
                    bne       MenuNavFirst        no — check first menu
                    ldx       $02,s               X = current item
                    lbsr      DrawMenuItemNormal  unhighlight current
                    ldx       $02,s               reload item
                    ldx       ,x                  follow first-item link
                    stx       $02,s               update current item
                    lbsr      DrawMenuItemHighlight highlight new item
                    bra       MenuNavUpdate       wait for next event
MenuNavFirst        cmpa      #$06                jump to first menu?
                    bne       MenuNavPrevMenu     no — check prev menu
                    ldu       ,s                  U = current menu
                    ldx       $02,s               X = current item
                    lbsr      EraseMenuItem       erase current menu
                    ldu       >MenuHead,pcr       data word
                    ldu       $02,u               first real menu (skip sentinel)
                    stu       ,s                  set as current menu
                    ldx       $0D,u               load first item
                    stx       $02,s               set as current item
                    lbsr      DrawMenuItem        draw new menu
                    bra       MenuNavUpdate       wait for next event
MenuNavPrevMenu     cmpa      #$07                previous menu?
                    bne       MenuNavHome         no — check home
                    ldu       ,s                  U = current menu
                    ldx       $02,s               X = current item
                    lbsr      EraseMenuItem       erase current dropdown
                    ldu       ,s                  reload current menu
MenuNavPrevScan     ldu       $02,u               follow prev-menu link
                    lda       $0A,u               menu has items?
                    beq       MenuNavPrevScan     no — skip to prev
                    stu       ,s                  save new current menu
                    ldx       $0D,u               load first item
                    stx       $02,s               set as current item
                    lbsr      DrawMenuItem        draw previous menu
                    bra       MenuNavUpdate       redisplay and wait for input
MenuNavHome         cmpa      #$08                jump to home (first) menu?
                    bne       MenuNavUpdate       no — unknown, fall through
                    ldu       ,s                  U = current menu
                    ldx       $02,s               X = current item
                    lbsr      EraseMenuItem       erase current dropdown
                    ldu       >MenuHead,pcr       data word
                    stu       ,s                  set head as current menu
                    ldx       $0D,u               load head's first item
                    stx       $02,s               set as current item
                    lbsr      DrawMenuItem        draw home menu
MenuNavUpdate       ldd       ,s                  save updated menu/item state
                    std       >MenuCurrent,pcr    data word
                    ldd       $02,s               load current item from frame
                    std       >MenuItemCurrent,pcr data word
                    lbra      MenuInputEventLoop  wait for next event
MenuInputExit       lda       #$00                clear all menu-active flags
                    sta       >ExtTableFlag       flag for extended table lookup
                    sta       >$05AE              clear menu-visible flag
                    sta       >$0547              clear joystick state
                    leas      $04,s               release local frame
                    rts

DrawMenuItem        leas      -$04,s              allocate 4-byte local frame
                    stu       ,s                  save current menu pointer
                    ldx       ,s                  load menu pointer for highlight
                    bsr       DrawMenuItemHighlight draw menu title highlighted
                    ldu       ,s                  reload menu pointer
                    lbsr      CalcMenuItemGeometry compute item list geometry

                    ldd       #$000F              row 0, col 15
                    pshs      b,a                 push row/col arg
                    ldd       >MenuItemRow,pcr    load item list row
                    pshs      b,a                 push row arg
                    ldd       >MenuItemCol,pcr    load item list column
                    pshs      b,a                 push col arg
                    lda       #$0C                remap offset for scrn draw
                    sta       <ScrnRemapOff       save remap offset
                    ldx       <ScrnRemapVal       load remap-to-scrn value
                    jsr       >$0659              invoke MMU twiddler for scrn
                    leas      $06,s               pop 3 args (6 bytes)

                    ldu       ,s                  reload menu pointer
                    ldx       $0B,u               load first item pointer
DrawMenuItemLoop    stx       $02,s               save current item pointer
                    cmpx      $0D,u               is this the current (selected) item?
                    beq       DrawMenuItemCurrent yes — draw highlighted
                    bsr       DrawMenuItemNormal  no — draw normal
                    bra       DrawMenuItemNext    advance to next item
DrawMenuItemCurrent bsr       DrawMenuItemHighlight draw item highlighted
DrawMenuItemNext    ldx       $02,s               reload current item pointer
                    ldx       ,x                  follow forward link to next item
                    ldu       ,s                  reload menu pointer
                    cmpx      $0B,u               looped back to first item?
                    bne       DrawMenuItemLoop    no — draw next item
                    leas      $04,s               release local frame
                    rts

EraseMenuItem       stx       $0D,u               save current item as menu's selected
                    tfr       u,x                 copy menu pointer to X
                    bsr       DrawMenuItemNormal  draw menu title in normal style

                    ldd       >MenuItemRow,pcr    load item list row
                    pshs      b,a                 push row arg
                    ldd       >MenuItemCol,pcr    load item list column
                    pshs      b,a                 push col arg
                    lda       #$03                remap offset for scrn erase
                    sta       <ScrnRemapOff       save remap offset
                    ldx       <ScrnRemapVal       load remap-to-scrn value
                    jsr       >$0659              invoke MMU twiddler to erase dropdown
                    leas      $04,s               pop 2 args (4 bytes)
                    rts

DrawMenuItemHighlight ldd     $08,x               load row/col from item entry
                    std       <TextRow            set text cursor row/col
                    ldd       #$0F00              foreground 15 (white), background 0 (black)
                    lbsr      text_color          set highlight colors
                    lda       $0A,x               load item enabled flag
                    bne       DrawMenuItemHiText  enabled — draw text
                    lda       #$0F                disabled — set dim color
                    sta       <DrawAttr            store dim attribute
DrawMenuItemHiText  pshs      x                   save item pointer
                    ldd       $06,x               load logic page number
                    lbsr      SetLogicPage        map logic page for string access
                    puls      x                   restore item pointer
                    ldd       $04,x               load item name string pointer
                    pshs      b,a                 push string pointer
                    lbsr      PrintFmtStrToScr    print highlighted item name
                    leas      $02,s               pop string pointer arg
                    clr       <DrawAttr            clear dim attribute
                    rts

DrawMenuItemNormal  ldd       $08,x               load row/col from item entry
                    std       <TextRow            set text cursor row/col
                    ldd       #$000F              foreground 0 (black), background 15 (white)
                    lbsr      text_color          set normal colors
                    lda       $0A,x               load item enabled flag
                    bne       DrawMenuItemNormText enabled — draw text
                    lda       #$0F                disabled — set dim color
                    sta       <DrawAttr            store dim attribute
DrawMenuItemNormText pshs     x                   save item pointer
                    ldd       $06,x               load logic page number
                    lbsr      SetLogicPage        map logic page for string access
                    puls      x                   restore item pointer
                    ldd       $04,x               load item name string pointer
                    pshs      b,a                 push string pointer
                    lbsr      PrintFmtStrToScr    print normal item name
                    leas      $02,s               pop string pointer arg
                    clr       <DrawAttr            clear dim attribute
                    rts

CalcMenuItemGeometry leas     -$01,s              allocate 1-byte local (item count)
                    lda       $0F,u               load item count from menu entry
                    sta       ,s                  save item count
                    ldb       #$08                8 pixels per row
                    mul                           compute row pixel offset
                    addb      #$10                add 16 (base row offset)
                    stb       >MenuItemRow,pcr    store item list top row
                    ldu       $0B,u               load first item pointer
                    ldd       $06,u               load first item's page number
                    lbsr      SetLogicPage        map page for string access
                    ldx       $04,u               load item name string pointer
                    lbsr      StrLen              compute item name length
                    lda       #$04                4 pixels per character
                    mul                           compute name pixel width
                    addb      #$08                add 8 for padding
                    stb       >MenuItemWidth,pcr  store item dropdown width
                    lda       $09,u               load menu column position
                    deca                          make 0-based
                    ldb       #$04                4 pixels per column
                    mul                           compute pixel column offset
                    stb       >MenuItemCol,pcr    store item list left column
                    lda       ,s                  reload item count
                    adda      #$02                add 2 for border rows
                    suba      >$0242              subtract screen row offset
                    ldb       #$08                8 pixels per row
                    mul                           compute pixel height
                    addb      #$07                add 7 for rounding
                    stb       >MenuItemHeight,pcr store item list height
                    leas      $01,s               release local frame
                    rts

* Reads a byte from Stdin and returns it in a
* clears a on getsta or read error
* saves y and s

ReadStdinByte       leas      -$03,s              make room on the stack
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
                    bcs       ReadStdinByteErr    error during call go clear a,
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
                    bcs       ReadStdinByteErr    error during call clear a
*                                restore y, cleanup stack & leave
                    lda       $02,s               clean read move byte to a
                    bra       ReadStdinByteRet    restore y, clean up stack and leave
*
*    Since the above inst is a bra this looks like dead code
*    unless he does something cute and uses a magic jump into this.

                    cmpa      #$F4                check for special key code $F4
                    bne       ReadStdinByteRet    not $F4 — normal return
                    lda       <NegCondFlag        load negation-condition flag
                    bne       ReadStdinByteAlt    set — toggle trace off
                    lbsr      TraceInit           init trace display
                    bra       ReadStdinByteErr    return via error path
ReadStdinByteAlt    lbsr      TraceErase          erase trace display
*
*    end dead code

ReadStdinByteErr    clra                          if we had an error clear a
ReadStdinByteRet    ldy       ,s                  restore y
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

FillMem             pshs      u                   save destination start address
FillMemLoop         stb       ,u+                 store fill byte and advance U
                    leax      -$01,x              decrement byte count
                    bne       FillMemLoop         more bytes — continue
                    puls      u                   restore destination start address
                    rts

* maps shdw into working space
* and calls code that flips the screen byte nibbles

gfx_picbuff_update  tst       >PicBufRotate       test pic-buffer-rotate flag
                    beq       GfxUpdateBlit       zero — skip nibble flip
*                          not zero the do the byte flip flop
                    lda       #$00                remap offset 0 for shadow flip
                    sta       <ShdwRemapOff       save shadow remap offset
                    ldx       <ShdwRemapVal       load remap-to-shadow value
                    jsr       >$0659              invoke MMU twiddler (flip nibbles)

GfxUpdateBlit       ldd       #$A8A0              y2=168, x2=160 (blit extent)
                    pshs      d                   push blit extent args
                    ldd       #$00A7              y1=0, x1=167 (blit origin)
                    pshs      d                   push blit origin args
                    lda       #$00                remap offset 0 for screen blit
                    sta       <ScrnRemapOff       save screen remap offset
                    ldx       <ScrnRemapVal       load remap-to-screen value
                    jsr       >$0659              invoke MMU twiddler (blit to screen)
                    leas      $04,s               pop blit args
                    rts

cmd_move_obj        lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object = 43
                    mul                           compute object table offset
                    addd      <ViewObjBase        add base address to get object pointer
                    tfr       d,u                 U = object entry pointer
                    lda       #$03                motion type 3 = move-to-position
                    sta       <$22,u              store motion type
                    lda       ,y+                 read target X from bytecode
                    sta       <$27,u              store target X in object
                    lda       ,y+                 read target Y from bytecode
                    sta       <$28,u              store target Y in object
                    lda       <$1E,u              load current speed
                    sta       <$29,u              save original speed for restore
                    lda       ,y+                 read new speed (0 = keep current)
                    beq       MoveObjDir          zero — don't change speed
                    sta       <$1E,u              store new speed
MoveObjDir          lda       ,y+                 read end-flag number from bytecode
                    sta       <$2A,u              store flag to set on arrival
                    lbsr      ClearFlag           clear the arrival flag
                    lda       <$26,u              load object control flags
                    ora       #$10                set motion-in-progress bit
                    sta       <$26,u              store updated flags
                    cmpu      <ViewObjBase        is this ego (object 0)?
                    bne       MoveObjDone         no — done
                    clr       >$0251              ego moving — clear control flag
MoveObjDone         lbsr      SetObjMotion        apply motion settings
                    rts

cmd_move_obj_v      lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    lda       #$03                motion type 3 = move-to-position
                    sta       <$22,u              store motion type
                    ldb       ,y+                 read target-X variable index
                    ldx       #$0432              flag/variable table base
                    abx                           index into variable table
                    lda       ,x                  load target X from variable
                    sta       <$27,u              store target X
                    ldb       ,y+                 read target-Y variable index
                    ldx       #$0432              variable table base
                    abx                           index into table
                    lda       ,x                  load target Y from variable
                    sta       <$28,u              store target Y
                    lda       <$1E,u              load current speed
                    sta       <$29,u              save original speed
                    ldb       ,y+                 read speed variable index
                    ldx       #$0432              variable table base
                    abx                           index into table
                    lda       ,x                  load speed from variable (0 = keep)
                    beq       MoveObjVDir         zero — don't change speed
                    sta       <$1E,u              store new speed
MoveObjVDir         lda       ,y+                 read arrival flag number
                    sta       <$2A,u              store arrival flag
                    lbsr      ClearFlag           clear arrival flag
                    lda       <$26,u              load object flags
                    ora       #$10                set motion-in-progress bit
                    sta       <$26,u              store updated flags
                    cmpu      <ViewObjBase        is this ego?
                    bne       MoveObjVDone        no — done
                    clr       >$0251              ego moving — clear control flag
MoveObjVDone        lbsr      SetObjMotion        apply motion settings
                    rts

cmd_follow_ego      lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    lda       #$02                motion type 2 = follow-ego
                    sta       <$22,u              store motion type
                    lda       <$1E,u              load ego's current speed
                    sta       <$27,u              store as follower's default speed
                    lda       ,y+                 read minimum follow distance
                    cmpa      <$1E,u              larger than ego speed?
                    bls       FollowEgoSpeed      no — use default
                    sta       <$27,u              yes — store as follower speed
FollowEgoSpeed      lda       ,y+                 read follow flag number
                    sta       <$28,u              store "close enough" flag
                    lbsr      ClearFlag           clear the flag
                    lda       #$FF                $FF = "haven't reached yet" marker
                    sta       <$29,u              mark as not-yet-reached
                    lda       <$26,u              load object flags
                    ora       #$10                set motion-in-progress bit
                    sta       <$26,u              store updated flags
                    rts

cmd_wander          lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    lda       #$01                motion type 1 = random wander
                    sta       <$22,u              store motion type
                    lda       <$26,u              load object flags
                    ora       #$10                set motion-in-progress bit
                    sta       <$26,u              store updated flags
                    cmpu      <ViewObjBase        is this ego?
                    bne       WanderDone          no — done
                    clr       >$0251              ego wandering — clear control flag
WanderDone          rts

cmd_normal_motion   lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    lda       #$00                motion type 0 = normal (user-controlled)
                    sta       <$22,u              store motion type
                    rts

cmd_stop_motion     lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    lda       #$00                motion type 0 = normal
                    sta       <$22,u              store motion type (stopped = type 0)
                    clra                          zero direction/speed
                    sta       <$21,u              clear direction
                    cmpu      <ViewObjBase        is this ego?
                    bne       StopMotionDone      no — done
                    sta       >$0438              clear ego direction variable
                    sta       >$0251              clear ego control flag
StopMotionDone      rts

cmd_start_motion    lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    lda       #$00                motion type 0 = normal
                    sta       <$22,u              store motion type
                    cmpu      <ViewObjBase        is this ego?
                    bne       StartMotionDone     no — done
                    clr       >$0438              clear ego direction variable
                    lda       #$01                enable player control
                    sta       >$0251              set ego control flag
StartMotionDone     rts

cmd_step_size       lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    ldb       ,y+                 read speed variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       ,x                  load step size from variable
                    sta       <$1E,u              store step size in object
                    rts

cmd_step_time       lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    ldb       ,y+                 read cycle-time variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       ,x                  load cycle time from variable
                    sta       ,u                  store as current cycle counter
                    sta       $01,u               store as cycle time preset
                    rts

cmd_set_dir         lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    ldb       ,y+                 read direction variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       ,x                  load direction from variable
                    sta       <$21,u              store direction in object
                    rts

cmd_get_dir         lda       ,y+                 read object number from bytecode
                    ldb       #$2B                bytes per view object
                    mul                           compute object offset
                    addd      <ViewObjBase        add base address
                    tfr       d,u                 U = object entry pointer
                    ldb       ,y+                 read destination variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       <$21,u              load current direction from object
                    sta       ,x                  store direction in variable
                    rts

cmd_program_control clr       >$0251              clear ego control flag (program controls ego)
                    rts

cmd_player_control  lda       #$01                player takes control of ego
                    sta       >$0251              set ego control flag (player-controlled)
                    ldu       <ViewObjBase        load ego object pointer
                    lda       #$00                motion type 0 = normal
                    sta       <$22,u              store motion type for ego
                    rts

* From nagi 2002_11_14 obj_motion.c
* x_dir_mult[] = {0,0,1,1,1,0,-1,-1,-1};

x_dir_mult          fcb       $00,$00,$01,$01
                    fcb       $01,$00,$FF,$FF
                    fcb       $FF

* y_dir_mult[] = {0,-1,-1,0,1,1,1,0,-1};

y_dir_mult          fcb       $00,$FF,$FF,$00
                    fcb       $01,$01,$01,$00
                    fcb       $FF

UpdateAllMotion     leas      -$0B,s              allocate 11-byte local frame
                    clra                          zero value
                    sta       >$0434              clear boundary-hit counter
                    sta       >$0436              clear object-hit tracking
                    sta       >$0437              clear boundary state
                    ldu       <ViewObjBase        start at first view object
UpdateObjsLoop      cmpu      <ViewObjEnd         past last object?
                    lbcc      UpdateAllObjsRet    yes — done
                    lda       <$26,u              load object flags
                    anda      #$51                mask: animated+visible+active bits
                    cmpa      #$51                all three set?
                    lbne      UpdateObjsNext      no — skip this object
                    lda       $01,u               load cycle countdown
                    beq       UpdateObjCycle      zero — cycle now
                    deca                          decrement countdown
                    beq       UpdateObjCycle      reached zero — cycle now
                    sta       $01,u               store updated countdown
                    lbra      UpdateObjsNext      skip to next object
UpdateObjCycle      lda       ,u                  load cycle preset value
                    sta       $01,u               reset cycle countdown
                    clra                          clear boundary-collision flag
                    sta       $02,s               store on frame
                    ldb       <$1E,u              load step size
                    std       $09,s               store step size (A=0, B=step) on frame
                    ldb       $03,u               load current X hi
                    std       $03,s               store X hi on frame
                    stb       $07,s               save X hi for restore
                    ldb       $04,u               load current X lo
                    std       $05,s               store X lo on frame
                    stb       $08,s               save X lo for restore
                    lda       <$25,u              load motion flags
                    bita      #$04                fixed-position flag set?
                    bne       ClampObjXLeft       yes — skip movement
                    leax      >x_dir_mult,pcr     load X direction multiplier table
                    lda       <$21,u              load current direction
                    lda       a,x                 look up X multiplier for direction
                    beq       UpdateObjY          zero — no X movement
                    bpl       UpdateObjXPlus      positive — move right
                    ldd       $03,s               load current X position
                    subd      $09,s               subtract step size (move left)
                    std       $03,s               store updated X
                    bra       UpdateObjY          process Y
UpdateObjXPlus      ldd       $03,s               load current X position
                    addd      $09,s               add step size (move right)
                    std       $03,s               store updated X
UpdateObjY          leax      >y_dir_mult,pcr     load Y direction multiplier table
                    lda       <$21,u              load current direction
                    lda       a,x                 look up Y multiplier for direction
                    beq       ClampObjXLeft       zero — no Y movement
                    bpl       UpdateObjYPlus      positive — move down
                    ldd       $05,s               load current Y position
                    subd      $09,s               subtract step size (move up)
                    std       $05,s               store updated Y
                    bra       ClampObjXLeft       clamp coordinates
UpdateObjYPlus      ldd       $05,s               load current Y position
                    addd      $09,s               add step size (move down)
                    std       $05,s               store updated Y
ClampObjXLeft       ldd       #$0000              left boundary = 0
                    cmpd      $03,s               X < 0?
                    ble       ClampObjXRight      no — check right
                    std       $03,s               clamp X to 0
                    lda       #$04                boundary code = left
                    sta       $02,s               store boundary hit
                    bra       ClampObjYTop        check Y bounds
ClampObjXRight      ldb       <$1C,u              load sprite width
                    negb                          negate for right-edge calc
                    lda       #$FF                $FF for sign extension
                    addd      #$00A0              add 160 (screen width)
                    cmpd      $03,s               X > right edge?
                    bge       ClampObjYTop        no — check Y
                    std       $03,s               clamp X to right edge
                    lda       #$02                boundary code = right
                    sta       $02,s               store boundary hit
ClampObjYTop        clra                          zero hi byte for Y compare
                    ldb       <$1D,u              load sprite height
                    decb                          subtract 1 for bottom row
                    cmpd      $05,s               Y - height < horizon?
                    ble       ClampObjYBot        no — check bottom
                    std       $05,s               clamp Y to top
                    lda       #$01                boundary code = top
                    sta       $02,s               store boundary hit
                    bra       ApplyObjPosition    apply position
ClampObjYBot        ldd       #$00A7              bottom boundary = 167
                    cmpd      $05,s               Y > 167?
                    bge       CheckObjPriority    no — check priority
                    std       $05,s               clamp Y to 167
                    lda       #$03                boundary code = bottom
                    sta       $02,s               store boundary hit
                    bra       ApplyObjPosition    apply position
CheckObjPriority    lda       <$26,u              load object flags
                    bita      #$08                priority-override flag set?
                    bne       ApplyObjPosition    yes — skip priority check
                    lda       >$01D7              load screen priority level
                    cmpa      $06,s               compare with stored priority
                    bls       ApplyObjPosition    not higher — no change
                    inca                          increment priority level
                    sta       $06,s               store new priority
                    lda       #$01                boundary flag = 1
                    sta       $02,s               flag priority collision
ApplyObjPosition    lda       $04,s               load computed X
                    ldb       $06,s               load computed priority/Y
                    std       $03,u               write new X,priority to object
                    lbsr      TestObjContact      test for object-object contact
                    tsta                          contact detected?
                    bne       ObjHitRestore       yes — restore old position
                    stu       ,s                  save object pointer on frame
                    pshs      u                   push for shadow check
                    lda       #$03                remap offset for shadow obj-check
                    sta       <ShdwRemapOff       save shadow remap offset
                    ldx       <ShdwRemapVal       load remap-to-shadow value
                    jsr       >$0659              invoke MMU twiddler (obj_chk_control)
                    leas      $02,s               pop pushed U

                    ldu       ,s                  reload object pointer
                    lda       <ShdwContact            check contact result from shadow
                    bne       CheckObjBoundary    nonzero — check boundary
ObjHitRestore       ldd       $07,s               load saved X position
                    std       $03,u               restore original X,Y in object
                    clr       $02,s               clear boundary-hit flag
                    lbsr      FindObjPos          recalculate object position
CheckObjBoundary    lda       $02,s               load boundary-hit code
                    beq       UpdateObjFlags      zero — no boundary hit
                    ldb       $02,u               load object flag byte
                    bne       ObjBoundaryHit      nonzero — record as object hit
                    sta       >$0434              store boundary hit in counter
                    bra       CheckMoveTarget     check if move target reached
ObjBoundaryHit      stb       >$0436              store object flag for hit tracking
                    sta       >$0437              store boundary hit type
CheckMoveTarget     lda       <$22,u              load motion type
                    cmpa      #$03                move-to-position?
                    bne       UpdateObjFlags      no — skip target check
                    lbsr      ObjMoveReached      check if object reached target
UpdateObjFlags      lda       <$25,u              load secondary flags
                    anda      #$FB                clear bit 2 (motion-complete flag)
                    sta       <$25,u              store updated flags
UpdateObjsNext      leau      <$2B,u              advance to next object entry
                    lbra      UpdateObjsLoop      process next object
UpdateAllObjsRet    leas      $0B,s               release 11-byte local frame
                    rts

MoveTableData       fcb       $08,$01,$02
                    fcb       $07,$00,$03
                    fcb       $06,$05,$04

SetObjMotion        ldb       $1E,u               load current step size
                    pshs      b,a                 push step size arg
                    ldd       <$27,u              load target X,Y
                    pshs      b,a                 push target position arg
                    ldd       $03,u               load current X,Y position
                    pshs      b,a                 push current position arg
                    lbsr      CalcMoveDir         compute direction toward target
                    leas      $06,s               pop 3 args
                    cmpu      <ViewObjBase        is this ego?
                    bne       SetObjMotionStore   no — just store direction
                    sta       >$0438              update ego direction variable
SetObjMotionStore   sta       <$21,u              store computed direction in object
                    bne       SetObjMotionRet     nonzero direction — still moving
                    bsr       ObjMoveReached      direction 0 = at target, signal arrival
SetObjMotionRet     rts

ObjMoveReached      lda       <$29,u              load saved original speed
                    sta       <$1E,u              restore speed (undo move speed override)
                    lda       <$2A,u              load arrival flag number
                    lbsr      SetFlag             set arrival flag
                    lda       #$00                motion type 0 = done
                    sta       <$22,u              clear motion type
                    cmpu      <ViewObjBase        is this ego?
                    bne       ObjMoveReachedRet   no — done
                    lda       #$01                restore player control
                    sta       >$0251              set ego control flag
                    clr       >$0438              clear ego direction variable
ObjMoveReachedRet   rts

CalcMoveDir         leas      -$03,s              allocate 3-byte local frame
                    clra                          clear hi byte
                    sta       $09,s               clear local scratch
                    ldb       $05,s               load target Y (from caller args)
                    std       ,s                  store target Y
                    ldb       $07,s               load current Y
                    subd      ,s                  current Y - target Y = Y delta
                    pshs      b,a                 push Y delta
                    ldd       $0B,s               load step size
                    pshs      b,a                 push step size
                    lbsr      CalcAxisDir         compute Y axis direction (0/1/2)
                    leas      $04,s               pop 2 args
                    sta       $02,s               save Y direction on frame
                    clra                          clear hi byte
                    sta       $05,s               clear local scratch
                    ldb       $08,s               load target X
                    subd      $05,s               compute X delta
                    pshs      b,a                 push X delta
                    ldd       $0B,s               load step size
                    pshs      b,a                 push step size
                    lbsr      CalcAxisDir         compute X axis direction (0/1/2)
                    leas      $04,s               pop 2 args
                    leax      >MoveTableData,pcr  load 3×3 direction lookup table
                    ldb       #$03                row size = 3
                    mul                           A×3 = row offset for X direction
                    addb      $02,s               add Y direction for column
                    lda       b,x                 look up resulting direction
                    leas      $03,s               release local frame
                    rts

CalcAxisDir         ldd       #$0000              zero value
                    subd      $02,s               negate delta: 0 - delta
                    cmpd      $04,s               |delta| < step size?
                    blt       CalcAxisDirNeg      yes — direction negative
                    clra                          zero direction (at target on this axis)
                    bra       CalcAxisDirRet      done
CalcAxisDirNeg      ldd       $02,s               reload delta
                    cmpd      $04,s               delta > step size?
                    bgt       CalcAxisDirPos      yes — direction positive
                    lda       #$02                direction 2 = negative axis
                    bra       CalcAxisDirRet      done
CalcAxisDirPos      lda       #$01                direction 1 = positive axis
CalcAxisDirRet      rts


* ====================================================================
* ROOM TRANSITION
* cmd_new_room and cmd_new_room_v trigger a room change: they set the
* target room number into the game state, clear the current room's
* resources, reset ego's position and direction, load the new room's
* logic/view/picture resources, and run logic 0 to initialise the
* new scene before returning to the main interpreter loop.
* ====================================================================
cmd_new_room        lda       ,y                  read new room number from bytecode
                    bsr       NewRoomSetup        transition to new room
                    rts

cmd_new_room_v      ldb       ,y                  read variable index from bytecode
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       ,x                  load room number from variable
                    bsr       NewRoomSetup        transition to room from variable
                    rts

NewRoomSetup        leas      -$01,s              allocate 1-byte local (new room number)
                    sta       ,s                  save new room number
                    lbsr      ResetHeap           free heap to start of module
                    lbsr      events_clear        flush pending event queue
                    lbsr      InitScriptBuf       initialize script buffer
                    lda       #$01                room-load-in-progress flag
                    sta       >$05B1              set loading flag
                    ldu       <ViewObjBase        start at first view object
NewRoomObjLoop      cmpu      <ViewObjEnd         past last object?
                    bcc       NewRoomObjsDone     yes — done resetting objects
                    lda       <$26,u              load object flags
                    anda      #$BE                clear animated/visible bits
                    ora       #$10                set motion-in-progress bit
                    sta       <$26,u              store updated flags
                    ldd       #$0000              zero value
                    sta       <$25,u              clear secondary flags
                    std       <$10,u              clear view/loop/cel
                    std       $06,u               clear position data
                    std       <$16,u              clear cel data
                    inca                          A = 1 (initial speed/timer values)
                    sta       <$1E,u              reset step size to 1
                    sta       <$1F,u              reset cycle time to 1
                    sta       <$20,u              reset step time to 1
                    sta       $01,u               reset cycle counter to 1
                    sta       ,u                  reset cycle preset to 1
                    leau      <$2B,u              advance to next object
                    bra       NewRoomObjLoop      loop
NewRoomObjsDone     lbsr      ResetGameTables     reset all game lists and tables
                    clra                          zero value
                    sta       >BlockState         clear block state
                    sta       >$0436              clear object-hit tracking
                    sta       >$0437              clear boundary hit state
                    inca                          A = 1
                    sta       >$0251              restore player control of ego
                    lda       #$24                default priority band (36)
                    sta       >$01D7              restore priority band
                    lda       >$0432              load current room number
                    sta       >$0433              save as previous room
                    ldb       ,s                  reload new room number
                    stb       >$0432              store as current room
                    lbsr      LoadLogicNum        load room logic
                    ldb       <StringPtrFlag      check if extra logic needed
                    beq       NewRoomLoadView     no — go load view
                    lbsr      AllocLoadLogic      load auxiliary logic
NewRoomLoadView     ldu       <ViewObjBase        load ego object pointer
                    lda       $05,u               load ego view number
                    sta       >$0442              save ego view number
                    lda       >$0434              load boundary-hit code from previous room
                    beq       NewRoomFlagSetup    no boundary — use current position
                    cmpa      #$01                top boundary (came from top)?
                    bne       NewRoomEgoDir2      no — check other edges
                    lda       #$A7                bottom of screen (167)
                    sta       $04,u               place ego at bottom
                    bra       NewRoomEgoDirDone   done
NewRoomEgoDir2      cmpa      #$02                right boundary?
                    bne       NewRoomEgoDir3      no
                    lda       #$00                left edge (X=0)
                    sta       $03,u               place ego at left
                    bra       NewRoomEgoDirDone   done
NewRoomEgoDir3      cmpa      #$03                bottom boundary?
                    bne       NewRoomEgoDir4      no
                    lda       #$25                near top (Y=37)
                    sta       $04,u               place ego near top
                    bra       NewRoomEgoDirDone   done
NewRoomEgoDir4      cmpa      #$04                left boundary?
                    bne       NewRoomEgoDirDone   no — use current position
                    lda       #$A0                right edge base (160)
                    suba      <$1C,u              subtract sprite width
                    sta       $03,u               place ego at right edge
NewRoomEgoDirDone   clr       >$0434              clear boundary-hit code
NewRoomFlagSetup    lda       >$01AF              load state flags
                    ora       #$04                set objects-loaded flag
                    sta       >$01AF              store updated flags
                    lbsr      ClearStateVars      clear 50 state variables at $05BA
                    lbsr      StatusLineWrite     redraw status bar
                    lbsr      InputRedraw         redraw input line
                    ldy       #$0000              clear Y register (no return value)
                    leas      $01,s               release local frame
                    rts

cmd_get             bsr       GetObjPtr           get pointer to object entry
                    lda       #$FF                $FF = carried-by-ego marker
                    sta       $02,u               set object's room to ego's inventory
                    rts

cmd_get_v           bsr       GetObjPtrV          get pointer via variable index
                    lda       #$FF                $FF = carried by ego
                    sta       $02,u               set object's room
                    rts

cmd_drop            bsr       GetObjPtr           get pointer to object entry
                    lda       #$00                0 = in-room (dropped in current room)
                    sta       $02,u               set object's room to 0
                    rts

GetObjPtr           ldx       <BlockPtr           load object data base pointer
                    ldb       ,y+                 read object index from bytecode
                    abx                           add 1×index
                    abx                           add 2×index
                    abx                           add 3×index (3 bytes/entry)
                    tfr       x,u                 U = pointer to object entry
                    cmpu      <BlockSizeLimit     within valid range?
                    bcs       GetObjPtrRet        yes — return pointer
                    lda       #$17                error code = invalid object
                    ldb       -$01,y              reload object index
                    lbsr      ReportError         report out-of-range error
GetObjPtrRet        rts

GetObjPtrV          ldb       ,y+                 read variable index from bytecode
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    ldb       ,x                  load object number from variable
                    ldx       <BlockPtr           load object data base pointer
                    abx                           add 1×object
                    abx                           add 2×object
                    abx                           add 3×object (3 bytes/entry)
                    tfr       x,u                 U = pointer to object entry
                    cmpu      <BlockSizeLimit     within valid range?
                    bcs       GetObjPtrVRet       yes — return
                    lda       #$17                error code = invalid object
                    ldb       -$01,y              reload object index
                    lbsr      ReportError         report error
GetObjPtrVRet       rts

cmd_put             bsr       GetObjPtr           get pointer to object entry
                    ldb       ,y+                 read destination variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       ,x                  load destination room from variable
                    sta       $02,u               store new room in object entry
                    rts

cmd_put_v           bsr       GetObjPtrV          get pointer via variable index
                    ldb       ,y+                 read destination variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       ,x                  load destination room from variable
                    sta       $02,u               store new room in object entry
                    rts

cmd_get_room_v      bsr       GetObjPtrV          get pointer via variable index
                    ldb       ,y+                 read destination variable index
                    ldx       #$0432              variable table base
                    abx                           index into variable table
                    lda       $02,u               load object's current room
                    sta       ,x                  store room in destination variable
                    rts

BlitListDraw        leas      -$02,s              allocate 2-byte local frame
                    stx       ,s                  save draw-list pointer
                    pshs      x                   push draw-list pointer
                    lda       #$1B                remap offset for blitlist_draw
                    sta       <ShdwRemapOff       save shadow remap offset
                    ldx       <ShdwRemapVal       load remap-to-shadow value
                    jsr       >$0659              invoke MMU twiddler (blitlist_draw)
                    leas      $02,s               pop pushed X
                    ldx       ,s                  reload draw-list pointer
                    bsr       ProcessDrawList     process all draw-list entries
                    leas      $02,s               release local frame
                    rts

*  called from above and BlitBothDraw twice
*  with different addresses in x

ProcessDrawList     ldu       ,x                  load draw-list entry pointer
                    beq       ProcessDrawListRet  null — list empty, done
                    ldd       #$0000              zero value
                    std       ,x                  clear head pointer
                    std       $02,x               clear secondary pointer
                    tfr       u,x                 move entry pointer to X
ProcessDrawListLoop stx       <HeapTop            save entry pointer as heap top
                    ldu       $0A,x               load entry's U data pointer
                    lda       $0C,x               load entry's priority byte
                    lbsr      CalcPriAddr         compute priority address
                    stu       <HeapPtr            store priority address
                    ldx       ,x                  follow forward link
                    bne       ProcessDrawListLoop more entries — continue
ProcessDrawListRet  rts

*  called from ScanActiveObjs and ScanAnimObjs
*  with x containing a hard coded address and u pointing to a subroutine
ScanViewObjs        leas      >-$00C8,s           allocate 200-byte scratch frame
                    stu       ,s                  save callback subroutine address
                    stx       $02,s               save output list pointer
                    ldu       <ViewObjBase        start at first view object
                    clr       $04,s               clear sorted-count index
ScanViewObjsLoop    cmpu      <ViewObjEnd         past last object?
                    bcc       ScanViewObjsSort    yes — go sort collected objects
                    jsr       [,s]                call callback (tests object; A=0 if match)
                    tsta                          did callback match this object?
                    beq       ScanViewObjsNext    no match (A=0) — skip
                    leax      $05,s               point to object pointer array
                    lda       $04,s               load current count
                    lsla                          multiply by 2 for word index
                    stu       a,x                 store object pointer in array
                    ldb       $04,u               load priority from object
                    lda       <$26,u              load object flags
                    bita      #$04                fixed-priority flag set?
                    beq       ScanViewObjsPriCalc no — compute priority from position
                    lda       <$24,u              load assigned priority
                    suba      #$05                subtract 5 (priority offset)
                    ldb       #$0C                scale factor 12
                    mul                           compute priority rank
                    addb      #$30                add $30 base offset
ScanViewObjsPriCalc leax      >$0085,s            point to priority sort array
                    lda       $04,s               load count index
                    stb       a,x                 store computed priority rank
                    inc       $04,s               increment count
ScanViewObjsNext    leau      <$2B,u              advance to next object
                    bra       ScanViewObjsLoop    loop
ScanViewObjsSort    clra                          start outer sort index at 0
ScanViewObjsSortOuter sta     >$00C5,s            save outer index
                    cmpa      $04,s               reached count?
                    bcc       ScanViewObjsRet     yes — sorted
                    leax      >$0085,s            point to priority rank array
                    lda       #$FF                start with "max priority" sentinel
                    sta       >$00C7,s            save as current minimum
                    clra                          start inner index at 0
ScanViewObjsSortInner cmpa    $04,s               reached count?
                    bcc       ScanViewObjsSortStore done inner scan
                    ldb       a,x                 load priority rank at index
                    cmpb      >$00C7,s            less than current minimum?
                    bcc       ScanViewObjsSortNext no — keep looking
                    sta       >$00C6,s            save index of new minimum
                    stb       >$00C7,s            save new minimum priority
ScanViewObjsSortNext inca                         advance inner index
                    bra       ScanViewObjsSortInner loop inner scan
ScanViewObjsSortStore lda     #$FF                sentinel = "used"
                    ldb       >$00C6,s            load index of minimum-priority entry
                    sta       b,x                 mark that slot as used ($FF)
                    leau      $05,s               point to object pointer array
                    lslb                          multiply index by 2
                    ldx       b,u                 load pointer to this object
                    ldu       $02,s               load output list head pointer
                    bsr       InsertPriList       insert object into priority list
                    lda       >$00C5,s            reload outer index
                    inca                          advance outer index
                    bra       ScanViewObjsSortOuter loop outer sort
ScanViewObjsRet     ldx       $02,s               reload output list pointer
                    leas      >$00C8,s            release scratch frame
                    rts

InsertPriList       leas      -$02,s              allocate 2-byte local frame
                    stu       ,s                  save new-entry pointer
                    lbsr      AllocViewEntry      allocate view list entry
                    ldx       ,s                  load new-entry pointer
                    ldx       ,x                  load existing list head
                    stx       ,u                  store list head as new entry's forward link
                    beq       InsertPriListHead   list was empty — just update head
                    stu       $02,x               update existing head's back link to new entry
InsertPriListHead   ldx       ,s                  reload new-entry pointer
                    stu       ,x                  update list head to new entry
                    ldd       $02,x               load back pointer from head
                    bne       InsertPriListRet    already set — done
                    stu       $02,x               initialize back pointer = new entry (circular)
InsertPriListRet    leas      $02,s               release local frame
                    rts




SortObjsBuf         fcb       $00,$00,$00,$00
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

SortObjsPtr         fdb       $0000

* although these are printing chars I think
* they are just junk place holders

PunctChars1         fcb       $20,$2C,$2E,$3F     ,.?
                    fcb       $21,$28,$29,$3B     !();
                    fcb       $3A,$5B,$5D,$7B     :[]{
                    fcb       $7D,$00             }.

PunctChars2         fcb       $27,$60,$2D,$22     '`-".
                    fcb       $00


ParseSentence       leas      -$07,s              allocate 7-byte local frame
                    stx       ,s                  save tokenized input pointer
*                       this seems stupid here since it clears two
*                       sets of twenty byte at sequential addresses
*                       must be two data structures of equal length
                    clrb                          clear b to 00
                    ldu       #$0181              load address of destination to be cleared
                    ldx       #$0014              set x to clear 20 bytes
                    lbsr      FillMem             go clear the bytes
                    ldu       #$0195              load address of destination to be cleared
                    ldx       #$0014              set x to clear 20 bytes
                    lbsr      FillMem             go clear bytes
                    ldu       ,s                  restore tokenized string pointer
                    lbsr      TokenizeString      break input into word tokens
                    clr       $02,s               word count = 0
                    leau      >SortObjsBuf,pcr    41 byte table
                    stu       >SortObjsPtr,pcr    data word
                    ldd       <PsgCurLatch        save PSG latch state
                    std       $05,s               preserve for restore after parse
                    ldd       >$01AB              load current logic page ID
                    lbsr      SetLogicPage        ensure word-lookup page is mapped
ParseWordLoop       lda       ,u                  peek at next token
                    beq       ParseSentenceDone   null — end of tokens
                    lda       $02,s               load word count
                    cmpa      #$0A                10 words max?
                    bcc       ParseSentenceDone   yes — stop
                    lbsr      LookupWord          look up token in words.tok (→ D, U)
                    std       $03,s               save lookup result
                    beq       ParseWordContinue   unknown word — skip
                    bpl       ParseWordMinus      negative result — synonym group
                    ldx       #$0181              word group table
                    ldb       $02,s               current word index
                    abx                           × 2 for 2-byte entries
                    abx                           X = &word_group_table[word_idx]
                    stu       ,x                  store matched word pointer
                    incb                          increment word count
                    stb       >$015A              update ego direction count
                    stb       >$043B              update controller state
                    lda       >$01AF              set flag bit 5 (player command)
                    ora       #$20                set F02_PLAYERCMD bit
                    sta       >$01AF              write back updated flags
                    bra       ParseSentenceStore  store and continue
ParseWordMinus      ldb       $02,s               synonym — store word-group ID
                    ldx       #$0195              synonym group table
                    abx                           × 2 for 2-byte entries
                    abx                           X = &synonym_table[word_idx]
                    ldd       $03,s               reload word-group ID
                    std       ,x                  store synonym group
                    ldb       $02,s               reload word index
                    ldx       #$0181              word group table
                    abx                           × 2 for 2-byte entries
                    abx                           X = &word_group_table[word_idx]
                    ldd       >SortObjsPtr,pcr    data word
                    std       ,x                  store matched pointer in word group table
                    inc       $02,s               increment word count
ParseWordContinue   stu       >SortObjsPtr,pcr    advance token pointer
                    bra       ParseWordLoop       process next token
ParseSentenceDone   lda       $02,s               final word count
                    beq       ParseSentenceStore  zero — no words recognized
                    sta       >$015A              save word count
                    lda       >$01AF              set player-command flag
                    ora       #$20                set F02_PLAYERCMD bit
                    sta       >$01AF              write back updated flags
ParseSentenceStore  ldd       $05,s               restore saved PSG latch state
                    lbsr      SetLogicPage        restore original logic page
                    leas      $07,s               release local frame
                    rts

cmd_parse           lda       >GameFlags1         load game flags
                    anda      #$DF                clear bit 5 (player-command flag)
                    sta       >GameFlags1         store — reset F02_PLAYERCMD

                    lda       >GameFlags1         reload game flags
                    anda      #$F7                clear bit 3 (said-accepted flag)
                    sta       >GameFlags1         store — reset F04_SAIDACCEPT

                    lda       ,y+                 read string index from bytecode
                    cmpa      #$0C                string index ≥ 12?
                    bcc       CmdParseRet         yes — invalid, skip
*                       less than 12
                    ldb       #$28                40 bytes per string slot
                    mul                           compute string slot offset
                    ldx       #StringTable        string table base address
                    leax      d,x                 point to the string slot
                    lbsr      ParseSentence       parse player's typed sentence
CmdParseRet         rts

TokenizeString      leas      -$02,s              allocate 2 bytes for output pointer
                    leax      >SortObjsBuf,pcr    output buffer start
                    stx       ,s                  initialize output write pointer
TokenizeLoop        lda       ,u+                 load next input character, advance U
                    beq       TokenizeDone        null — end of input
                    leax      >PunctChars1,pcr    primary punctuation table
                    lbsr      FindByte            check for leading punctuation
                    bne       TokenizeLoop        punctuation — discard and continue
                    leax      >PunctChars2,pcr    secondary punctuation table
                    lbsr      FindByte            check for secondary punctuation
                    bne       TokenizeLoop        punctuation — discard and continue
                    bra       TokenizeStoreChar   non-punctuation — start storing word
TokenizeCharLoop    leax      >PunctChars1,pcr    primary punctuation table
                    lbsr      FindByte            word-ending punctuation?
                    bne       TokenizeAddSpace    yes — end of word, emit space
                    leax      >PunctChars2,pcr    secondary punctuation table
                    lbsr      FindByte            secondary punctuation?
                    bne       TokenizeNextChar    yes — skip without storing
TokenizeStoreChar   ldx       ,s                  X = current output write pointer
                    sta       ,x+                 store character, advance output pointer
                    stx       ,s                  save updated output pointer
TokenizeNextChar    lda       ,u+                 load next character
                    bne       TokenizeCharLoop    non-null — continue this word
                    bra       TokenizeDone        null — end of input
TokenizeAddSpace    lda       #$20                space separator
                    ldx       ,s                  current output pointer
                    sta       ,x+                 store space, advance pointer
                    stx       ,s                  save updated pointer
                    bra       TokenizeLoop        scan for next word start
TokenizeDone        leax      >SortObjsBuf,pcr    output buffer start
                    cmpx      ,s                  output pointer still at start (empty)?
                    bcc       TokenizeTerminate   yes — just null-terminate
                    ldx       ,s                  X = end of output
                    lda       -$01,x              check last stored character
                    cmpa      #$20                trailing space?
                    bne       TokenizeTerminate   no — terminate here
                    leax      -$01,x              back up over trailing space
                    stx       ,s                  update pointer
TokenizeTerminate   clr       [,s]                null-terminate output buffer
                    leas      $02,s               release output pointer
                    rts

LookupWord          leas      -$06,s              allocate 6-byte local frame
                    ldd       #$FFFF              init best-match result to "not found"
                    std       ,s                  store result
                    ldd       #$0000              init best-match pointer to NULL
                    std       $02,s               store NULL pointer
                    lda       ,u                  peek at first character of token
                    lbsr      ToLower             convert to lowercase
                    cmpa      #$61                below 'a'?
                    bcs       LookupNotAlpha      yes — not an alpha word
                    cmpa      #$7A                above 'z'?
                    bls       LookupAlphaNext     no — valid letter, proceed
LookupNotAlpha      lbsr      StripLastWord       non-alpha — remove last token
                    lbra      LookupWordRet       exit
LookupAlphaNext     ldb       $01,u               load second character of token
                    cmpb      #$20                space (single-char word)?
                    beq       LookupSingleWord    yes — check for "a" or "i"
                    cmpb      #$00                null (end of string)?
                    bne       LookupAlphaSearch   no — multi-char word
LookupSingleWord    cmpa      #$61                is it 'a'?
                    beq       LookupSingleFound   yes — common word
                    cmpa      #$69                is it 'i'?
                    bne       LookupAlphaSearch   no — do full search
LookupSingleFound   clrb                          single-letter word: group ID = 0
                    stb       ,s                  store result high byte
                    stb       $01,s               store result low byte
                    leax      $01,u               X = pointer past the single char
                    stx       $02,s               save as best-match pointer
                    ldb       ,x+                 check char after 'a'/'i'
                    cmpb      #$20                followed by space?
                    bne       LookupAlphaSearch   no — continue to full search
                    stx       $02,s               yes — advance past the space
LookupAlphaSearch   suba      #$61                A = 0-based letter index (0='a')
                    lsla                          multiply by 2 (2-byte index entries)
                    ldx       >$01A9              load per-letter word-index table base
                    ldd       a,x                 load offset for this letter's word list
                    beq       LookupNotAlpha      no words start with this letter
                    leax      d,x                 X = start of word list for this letter
                    clr       $04,s               matched-char count = 0
LookupWordOuter     lda       $04,s               load matched-char count
                    cmpa      ,x+                 compare with next word-entry length byte
                    bhi       LookupWordNotFound  past matching entries — fail
                    bne       LookupCharMiss      length mismatch — skip word
LookupCharMatch     lda       ,x                  load next dictionary character byte
                    anda      #$7F                mask off end-of-word flag
                    sta       $05,s               save stripped dictionary char
                    lda       ,u                  load next input character
                    lbsr      ToLower             convert to lowercase
                    eora      #$7F                invert for XOR comparison
                    cmpa      $05,s               matches dictionary char (inverted)?
                    bne       LookupCharMiss      no — try next word
                    leau      $01,u               advance input pointer past matched char
                    inc       $04,s               increment matched-char count
                    lda       ,x                  reload dictionary byte (with flag)
                    anda      #$80                end-of-word flag set?
                    beq       LookupCharNext      no — more chars to match
                    lda       ,u                  check char after matched word
                    cmpa      #$00                end of input?
                    beq       LookupWordFound     yes — full match
                    cmpa      #$20                followed by space?
                    bne       LookupSkipWord      no — partial match, keep searching
LookupWordFound     ldd       $01,x               load word-group ID from dictionary
                    std       ,s                  save as best-match result
                    stu       $02,s               save input pointer position
                    lda       ,u                  check what follows the match
                    cmpa      #$00                end of input?
                    beq       LookupWordRet       yes — done
                    tfr       u,d                 D = current input pointer
                    addd      #$0001              skip space separator
                    std       $02,s               save advanced pointer
                    bra       LookupSkipWord      continue searching for longer match
LookupCharNext      leax      $01,x               advance dictionary pointer
                    bra       LookupCharMatch     try next dictionary char
LookupCharMiss      lda       ,u                  check input char at mismatch
                    cmpa      #$00                end of input?
                    beq       LookupWordNotFound  yes — no match possible
LookupSkipWord      lda       ,x+                 scan forward in dictionary
                    bpl       LookupSkipWord      keep skipping until end-of-word flag ($80)
                    leax      $02,x               skip word-group ID (2 bytes)
                    cmpa      #$00                was this the last word in the list?
                    bne       LookupWordOuter     no — try next word
LookupWordNotFound  ldu       $02,s               U = best-match input pointer (NULL if none)
                    lbeq      LookupNotAlpha      no match at all — strip token
                    lda       ,u                  check char after best match
                    beq       LookupWordRet       end of input — done
                    clr       -$01,u              null-terminate at word boundary
LookupWordRet       ldd       ,s                  D = matched word-group ID
                    leas      $06,s               release local frame
                    rts

StripLastWord       ldu       >SortObjsPtr,pcr    U = current token pointer
                    tfr       u,x                 X = scan pointer
StripLastWordLoop   lda       ,x+                 load next character
                    beq       StripLastWordRet    null — nothing to strip
                    cmpa      #$20                space (word boundary)?
                    bne       StripLastWordLoop   no — keep scanning
                    clr       -$01,x              null-terminate before the space
StripLastWordRet    rts

cmd_add_to_pic      ldu       #$05B2              point to add-to-pic parameter block
                    lda       ,y+                 read view number from bytecode
                    sta       ,u                  store view number
                    lda       ,y+                 read loop number from bytecode
                    sta       $01,u               store loop number
                    lda       ,y+                 read cel number from bytecode
                    sta       $02,u               store cel number
                    ldd       ,y++                read X,Y position (2 bytes)
                    std       $03,u               store X,Y position
                    lda       $01,y               read priority hi nibble from bytecode
                    lsla                          shift left 4 for hi nibble
                    lsla                          — shift 2
                    lsla                          — shift 3
                    lsla                          — shift 4: hi nibble in position
                    ora       ,y++                OR with priority lo nibble
                    sta       $05,u               store packed priority bytes
                    bsr       AddToPicImpl        execute add-to-pic
                    rts

cmd_add_to_pic_v    ldu       #$05B2              point to add-to-pic parameter block
                    ldx       #$0432              variable table base
                    clra                          clear A for indexed load
                    ldb       ,y+                 read view variable index
                    ldb       d,x                 load view number from variable
                    stb       ,u                  store view number
                    ldb       ,y+                 read loop variable index
                    ldb       d,x                 load loop number from variable
                    stb       $01,u               store loop number
                    ldb       ,y+                 read cel variable index
                    ldb       d,x                 load cel number from variable
                    stb       $02,u               store cel number
                    ldb       ,y+                 read X variable index
                    ldb       d,x                 load X position from variable
                    stb       $03,u               store X position
                    ldb       ,y+                 read Y variable index
                    ldb       d,x                 load Y position from variable
                    stb       $04,u               store Y position
                    ldb       ,y+                 read priority lo variable index
                    ldb       d,x                 load priority lo from variable
                    stb       $05,u               store priority lo
                    ldb       ,y+                 read priority hi variable index
                    ldb       d,x                 load priority hi from variable
                    lslb                          shift left 4 for hi nibble
                    lslb                          — shift 2
                    lslb                          — shift 3
                    lslb                          — shift 4: hi nibble in position
                    orb       $05,u               OR with priority lo
                    stb       $05,u               store packed priority
                    bsr       AddToPicImpl        execute add-to-pic
                    rts


AddToPicImpl        leas      -$02,s              allocate 2-byte local frame
                    ldd       <PsgCurLatch        save current PSG latch state
                    std       ,s                  stash on frame
                    lda       #$05                script event type 5 = add_to_pic
                    clrb                          sub-type 0
                    lbsr      PushScript          log event to script
                    ldx       #$05B2              point to parameter block
                    ldd       ,x                  load view/loop parameters
                    lbsr      PushScript          log view/loop to script
                    ldd       $02,x               load cel/X parameters
                    lbsr      PushScript          log cel/X to script
                    ldd       $04,x               load Y/priority parameters
                    lbsr      PushScript          log Y/priority to script
                    ldu       <ViewObjLast        load last view object pointer
                    ldb       $02,x               load cel number
                    stb       $0E,u               store cel in object
                    ldb       $01,x               load loop number
                    stb       $0A,u               store loop in object
                    ldb       ,x                  load view number
                    lbsr      SetViewForObj       set view resource for object
                    ldd       <$10,u              load view dimensions hi
                    std       <$12,u              store as cel dimensions
                    ldd       $08,u               load view data hi
                    std       <$14,u              store as cel data
                    ldx       #$05B2              reload parameter block
                    ldd       $03,x               load X,Y position
                    std       $03,u               store X,Y in object
                    std       <$1A,u              store as last-drawn X,Y
                    lda       #$02                priority-override flag
                    ldb       #$0C                object type
                    std       <$25,u              store flags
                    lda       #$0F                assign highest priority
                    sta       <$24,u              store priority in object
                    lbsr      FindObjPos          compute object screen position
                    ldx       #$05B2              reload parameter block
                    lda       $05,x               load priority byte
                    anda      #$0F                extract lo nibble
                    bne       AddToPicColor       nonzero — use specified color
                    lda       #$08                no priority — set non-animated flag
                    sta       <$26,u              store object flags
AddToPicColor       lda       $05,x               reload priority byte
                    sta       <$24,u              store as color/priority
                    lbsr      BlitBothErase       erase both buffers

                    ldd       <ViewObjLast        load last object pointer
                    pshs      d                   push for shadow obj_add_pic_pri call
                    lda       #$0F                remap offset for obj_add_pic_pri
                    sta       <ShdwRemapOff       save shadow remap offset
                    ldx       <ShdwRemapVal       load remap-to-shadow value
                    jsr       >$0659              invoke MMU twiddler (add to shadow pic)
                    leas      $02,s               pop pushed object pointer

                    lbsr      EraseAndBlitShdw    blit shadow to screen

                    ldd       <ViewObjLast        load last object pointer
                    pshs      d                   push for screen blitlist_draw call
                    lda       #$1B                remap offset for screen blit
                    sta       <ScrnRemapOff       save screen remap offset
                    ldx       <ScrnRemapVal       load remap-to-screen value
                    jsr       >$0659              invoke MMU twiddler (blit to screen)
                    leas      $02,s               pop pushed object pointer

                    ldd       ,s                  reload saved PSG latch state
                    lbsr      SetLogicPage        restore logic page
                    leas      $02,s               release local frame
                    rts

PicListBuf          fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

PicListPtr          fdb       $0000

PicListClear        leau      >PicListBuf,pcr     load picture list buffer address
                    ldd       #$0000              zero value
                    std       ,u                  clear first entry (head pointer)
                    rts

pic_find            leau      >PicListBuf,pcr     start at picture list head
PicFindLoop         stu       >PicListPtr,pcr     save current entry pointer
                    ldu       ,u                  load forward link pointer
                    beq       PicFindRet          null — picture not found
                    cmpb      $02,u               compare pic number with entry
                    bne       PicFindLoop         no match — continue
PicFindRet          rts


cmd_load_pic        ldx       #$0432              variable table base
                    ldb       ,y+                 read variable index from bytecode
                    abx                           index into variable table
                    ldb       ,x                  load pic number from variable
                    bsr       LoadPicImpl         load picture resource
                    rts

LoadPicImpl         leas      -$05,s              allocate 5-byte local frame
                    stb       ,s                  save pic number
                    bsr       pic_find            search picture list
                    cmpu      #$0000              already loaded?
                    bne       LoadPicRet          yes — return existing entry
                    ldd       <PsgCurLatch        save current PSG latch
                    std       $03,s               stash on frame
                    lbsr      BlitBothErase       erase both screen buffers
                    lda       #$02                script event type 2 = load_pic
                    ldb       ,s                  reload pic number
                    lbsr      PushScript          log load_pic to script
                    leau      >PicListBuf,pcr     load pic list buffer
                    ldx       >PicListPtr,pcr     load current list tail pointer
                    beq       LoadPicStore        list empty — use buffer directly
                    ldd       #$0007              7 bytes per picture list entry
                    lbsr      AllocDataBlock      allocate new entry
                    stu       ,x                  link new entry at tail
                    ldd       #$0000              zero forward pointer
                    std       ,u                  clear new entry's forward link
LoadPicStore        ldb       ,s                  reload pic number
                    stb       $02,u               store pic number in entry
                    stu       $01,s               save entry pointer on frame
                    lbsr      FetchPicture        fetch picture resource info
                    ldx       #$0000              volume file offset hi = 0
                    lbsr      OpenVolFile         open picture volume file
                    beq       LoadPicDone         empty — skip storing data
                    ldx       $01,s               reload entry pointer
                    std       $05,x               store resource info in entry
                    stu       $03,x               store data pointer in entry
LoadPicDone         lbsr      EraseAndBlitShdw    blit shadow after erase
                    ldd       $03,s               reload saved PSG latch
                    lbsr      SetLogicPage        restore logic page
                    ldu       $01,s               reload entry pointer
LoadPicRet          leas      $05,s               release local frame
                    rts

* ====================================================================
* PICTURE RENDERING
* cmd_draw_pic loads a picture resource and renders it into the
* shadow background buffer (priority and visual planes). cmd_show_pic
* copies the shadow buffer to the display. DrawPicImpl and LoadPic
* handle resource lookup, MMU block mapping, and calling the scrn
* module's picture decoder to expand the picture data in place.
* ====================================================================
cmd_draw_pic        ldx       #$0432              variable table base
                    ldb       ,y+                 read variable index from bytecode
                    abx                           index into variable table
                    ldb       ,x                  load pic number from variable
                    bsr       DrawPicImpl         draw picture to shadow buffer
                    rts

DrawPicImpl         leas      -$01,s              allocate 1-byte local (pic number)
                    stb       ,s                  save pic number
                    stb       >CurPicNum          update current pic number state
                    lbsr      pic_find            look up pic resource (→ U)
                    cmpu      #$0000              found?
                    bne       DrawPicFind         yes — proceed
                    lda       #$12                error code: pic not found
                    ldb       ,s                  reload pic number
                    lbsr      ReportError         report AGI error
DrawPicFind         ldd       $03,u               load pic data pointer
                    std       >GivenPicData       store as given_pic_data
                    pshs      u                   save resource pointer
                    lda       #$04                script event type 4 = draw_pic
                    ldb       $02,s               reload pic number
                    lbsr      PushScript          log draw_pic to script
                    lbsr      BlitBothErase       erase all objects from both buffers

                    lda       #$06                remap offset for render_pic
                    sta       <ShdwRemapOff       save shadow remap offset
                    ldx       <ShdwRemapVal       load remap-to-shadow value
                    jsr       >$0659              invoke MMU twiddler (render_pic)
                    leas      $02,s               pop saved resource pointer

                    lbsr      EraseAndBlitShdw    blit shadow buffer to screen
                    clr       >PicVisible         clear pic_visible flag
                    leas      $01,s               release local frame
                    rts

cmd_overlay_pic     ldx       #$0432              variable table base
                    ldb       ,y+                 read variable index from bytecode
                    abx                           index into variable table
                    ldb       ,x                  load pic number from variable
                    bsr       pic_overlay         overlay picture onto shadow buffer
                    rts

* args passed in d ?

pic_overlay         leas      -$01,s              make room for pic number
                    stb       ,s                  save pic_num on stack
                    stb       >CurPicNum          store at state.pic_num
                    lbsr      pic_find            pic_find() returns resource pointer in U
                    cmpu      #$0000              found?
                    bne       OverlayPicRender    yes we found one move on
*                         did find one
                    lda       #$12                load the error code
                    ldb       ,s                  and the pic_num
                    lbsr      ReportError         call set_agi_error

OverlayPicRender    ldd       $03,u               load resource vol/offset data
                    std       >GivenPicData       save at state.given_pic_data
                    pshs      u                   save resource pointer on stack
                    lda       #$08                script type: overlay-pic
                    ldb       $02,s               reload pic_num from stack
                    lbsr      PushScript          record in script buffer

                    lbsr      BlitBothErase       erase sprites from both buffers
                    lda       #$09                offset: render_pic into shadow
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler — render pic
                    leas      $02,s               pop resource pointer

                    lbsr      EraseAndBlitShdw    copy shadow to screen buffer
                    lbsr      BlitScrn            blit screen buffer to display
                    clr       >PicVisible         pic_visible = 0 (pic overlaid, not drawn)
                    leas      $01,s               pop pic_num frame slot
                    rts

cmd_show_pic        lda       >GameFlags2         load state flags
                    anda      #$FE                clear F15_PRINTMODE bit
                    sta       >GameFlags2         save updated flags

                    lbsr      cmd_close_window    close any open message window
                    lbsr      gfx_picbuff_update  blit pic buffer to screen
                    lda       #$01                pic_visible = 1
                    sta       >PicVisible         mark picture as visible
                    rts

cmd_discard_pic     ldx       #$0432              resolve state.var[] address
                    ldb       ,y+                 get pic variable index
                    abx                           X = &state.var[idx]
                    ldb       ,x                  load pic number from variable
                    bsr       DiscardPicImpl      call discard implementation
                    rts

DiscardPicImpl      leas      -$03,s              allocate 3-byte frame
                    stb       ,s                  save pic_num
                    lbsr      pic_find            search pic list for this resource
                    ldb       ,s                  reload pic_num
                    cmpu      #$0000              was it found?
                    bne       DiscardPicFound     yes — proceed
                    lda       #$15                error: pic not loaded
                    lbsr      ReportError         report: pic resource not found
DiscardPicFound     stu       $01,s               save resource pointer
                    lda       #$06                script type: discard-pic
                    ldb       ,s                  reload pic_num
                    lbsr      PushScript          record in script buffer
                    ldu       >PicListPtr,pcr     point to pic-list head
                    ldd       #$0000              null out head pointer
                    std       ,u                  clear pic list
                    lbsr      BlitBothErase       erase sprites from both buffers
                    ldu       $01,s               reload resource pointer
                    stu       <HeapTop            restore heap top to resource
                    lda       $05,u               load priority coordinate
                    ldu       $03,u               load resource data pointer
                    lbsr      CalcPriAddr         compute heap-free address
                    stu       <HeapPtr            update heap pointer
                    lbsr      EraseAndBlitShdw    redraw shadow and blit to screen
                    lbsr      UpdateFreeSpace     recompute free-space counter
                    leas      $03,s               release frame
                    rts

cmd_position        lda       ,y+                 get object index from bytecode
                    ldb       #$2B                43 bytes per view-object entry
                    mul                           D = index × 43
                    addd      <ViewObjBase        D = pointer to this object's entry
                    tfr       d,u                 U = view-object pointer
                    ldd       ,y++                load X/Y from bytecode (2 bytes)
                    std       $03,u               store as current X/Y position
                    std       <$1A,u              also store as saved X/Y position
                    rts

cmd_position_v      lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get X variable index
                    abx                           X = &state.var[x_idx]
                    lda       ,x                  A = X value from variable
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get Y variable index
                    abx                           X = &state.var[y_idx]
                    ldb       ,x                  B = Y value from variable
                    std       $03,u               store X/Y position
                    std       <$1A,u              store saved X/Y
                    rts

cmd_get_position    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get dest-X variable index
                    abx                           X = &state.var[dest_x]
                    lda       $03,u               load object X position
                    sta       ,x                  store into X variable
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get dest-Y variable index
                    abx                           X = &state.var[dest_y]
                    lda       $04,u               load object Y position
                    sta       ,x                  store into Y variable
                    rts

cmd_reposition      leas      -$02,s              2-byte signed-delta frame
                    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$25,u              load secondary flags
                    ora       #$04                set repos-in-progress bit
                    sta       <$25,u              save updated flags
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get signed-delta-X variable index
                    abx                           X = &state.var[dx_idx]
                    ldb       ,x                  load delta-X value (signed byte)
                    sex                           sign-extend B into D
                    std       ,s                  save signed delta on stack
                    clra                          clear A for unsigned X
                    ldb       $03,u               load current X
                    addd      ,s                  X + delta_X
                    bpl       ReposXDone          non-negative result — use it
                    clrb                          negative — clamp to 0
ReposXDone          stb       $03,u               store clamped new X
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get signed-delta-Y variable index
                    abx                           X = &state.var[dy_idx]
                    ldb       ,x                  load delta-Y value (signed byte)
                    sex                           sign-extend B into D
                    std       ,s                  save signed delta on stack
                    clra                          clear A for unsigned Y
                    ldb       $04,u               load current Y
                    addd      ,s                  Y + delta_Y
                    bpl       ReposYDone          non-negative result — use it
                    clrb                          negative — clamp to 0
ReposYDone          stb       $04,u               store clamped new Y
                    lbsr      FindObjPos          update object's position in scene
                    leas      $02,s               release delta frame
                    rts

cmd_reposition_to   lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldd       ,y++                load absolute X/Y from bytecode
                    std       $03,u               set object X/Y directly
                    lda       <$25,u              load secondary flags
                    ora       #$04                set repos-in-progress bit
                    sta       <$25,u              save updated flags
                    lbsr      FindObjPos          update object's position in scene
                    rts

cmd_reposition_to_v lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get X variable index
                    abx                           X = &state.var[x_idx]
                    lda       ,x                  A = X value
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get Y variable index
                    abx                           X = &state.var[y_idx]
                    ldb       ,x                  B = Y value
                    std       $03,u               set object X/Y
                    lda       <$25,u              load secondary flags
                    ora       #$04                set repos-in-progress bit
                    sta       <$25,u              save updated flags
                    lbsr      FindObjPos          update object's position in scene
                    rts

cmd_obj_on_water    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$25,u              load secondary flags
                    ora       #$01                set water-only flag (bit 0)
                    sta       <$25,u              save updated flags
                    rts

cmd_obj_on_land     lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$25,u              load secondary flags
                    ora       #$08                set land-only flag (bit 3)
                    sta       <$25,u              save updated flags
                    rts

cmd_obj_on_anything lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$25,u              load secondary flags
                    anda      #$F6                clear water-only and land-only bits
                    sta       <$25,u              save updated flags
                    rts

cmd_set_horizon     lda       ,y+                 read new horizon Y value
                    sta       >$01D7              store as state.horizon
                    rts

cmd_ignore_horizon  lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$26,u              load control flags
                    ora       #$08                set ignore-horizon flag (bit 3)
                    sta       <$26,u              save updated flags
                    rts

cmd_observe_horizon lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$26,u              load control flags
                    anda      #$F7                clear ignore-horizon flag (bit 3)
                    sta       <$26,u              save updated flags
                    rts


StrMsgTooVerbose    fcc       'Message too verbose:'
                    fcb       C$LF,C$LF
                    fcc       '"%s..."'
                    fcb       C$LF,C$LF
                    fcc       'Press CTRL-BREAK to continue.'
                    fcb       C$NULL


PrintAtRow          fcb       $FF
PrintAtCol          fcb       $FF
PrintAtHeight       fcb       $FF

* ====================================================================
* TEXT AND MESSAGE DISPLAY
* cmd_print and cmd_print_v look up a game message by number and
* display it in a dialog box via message_box. Print position can be
* overridden with cmd_set_text_attribute / cmd_print_at. message_box
* handles the dialog frame, word wrapping, and waiting for a keypress.
* FormatStr expands %-escape sequences (variables, strings, words)
* into a flat output buffer; PrintFmtStr renders the result to the
* screen one line at a time using the screen module's text routines.
* ====================================================================
cmd_print           ldb       ,y+                 get message number from bytecode
                    lbsr      GetMsgPtr           look up message text pointer
                    bsr       message_box         display message in dialog
                    rts

cmd_print_v         ldx       #$0432              state.var[] base
                    ldb       ,y+                 get variable index
                    abx                           X = &state.var[idx]
                    ldb       ,x                  load message number from variable
                    lbsr      GetMsgPtr           look up message text pointer
                    bsr       message_box         display message in dialog
                    rts

cmd_print_at        ldb       ,y+                 get message number
                    bsr       SetPrintAtImpl      handle positioned print with args
                    rts

cmd_print_at_v      ldx       #$0432              state.var[] base
                    ldb       ,y+                 get variable index
                    abx                           X = &state.var[idx]
                    ldb       ,x                  load message number from variable
                    bsr       SetPrintAtImpl      handle positioned print with args
                    rts


SetPrintAtImpl      lda       ,y+                 read column from bytecode
                    sta       >PrintAtCol,pcr     store explicit column
                    lda       ,y+                 read row from bytecode
                    sta       >PrintAtRow,pcr     store explicit row
                    lda       ,y+                 read height from bytecode
                    bne       SetPrintAtHeight    non-zero — use it directly
                    lda       #$1E                zero means default height (30 rows)
SetPrintAtHeight    sta       >PrintAtHeight,pcr  store print-at height
                    lbsr      GetMsgPtr           look up message text pointer
                    bsr       message_box         display positioned message
                    ldd       #$FFFF              reset print-at height to $FF (unset)
                    sta       >PrintAtHeight,pcr  clear height override
                    std       >PrintAtRow,pcr     clear row/col overrides
SetPrintAtRet       rts

message_box         leas      -$05,s              make room on stack
                    ldd       #$0000              clear d and push on stack
                    pshs      d                   0
                    ldd       #$0000              clear d and push on stack
                    pshs      d                   push zero arg 2
                    ldd       #$0000              clear d and push on stack
                    pshs      d                   push zero arg 3
                    pshs      u                   push ourcurrent u pntr
                    lbsr      message_box_draw    now the 4 argumnets are loaded call message_box_draw
                    leas      $08,s               reset stack pntr

MsgBoxCheckPrint    lda       >GameFlags2         load state.flag
                    anda      #$01                flag_test(F15_PRINTMODE)
                    beq       MsgBoxGetInput      if not set move on
                    lda       >GameFlags2         flag_reset(F15_PRINTMODE)
                    anda      #$FE                clear bit 0 (print-mode flag)
                    sta       >GameFlags2         write back cleared flag
                    lda       #$01                return 1 = Enter (print-mode skip)
                    bra       MsgBoxRet           go clean up stack and leave

MsgBoxGetInput      lda       >$0447              load timed-display flag
                    bne       MsgBoxTimedWait     non-zero — use timer
                    lda       #$01                default result = Enter
                    sta       ,s                  save default
                    lbsr      BooleanPoll         wait for Enter or Escape
                    cmpa      #$01                Enter pressed?
                    beq       MsgBoxClose         yes — close with Enter result
                    clra                          Escape — result = 0
                    sta       ,s                  save Escape result
                    bra       MsgBoxClose         close dialog with Escape result
MsgBoxTimedWait     ldb       #$0A                convert tenths to ticks
                    mul                           D = timeout in ticks
                    orcc      #IntMasks           disable interrupts for tick read
                    addd      >$024B              expiry = now + timeout
                    std       $03,s               save tick expiry
                    ldd       >$0249              load timer epoch counter
                    andcc     #^IntMasks          re-enable interrupts
                    bcc       MsgBoxTimerSet      no overflow — store as-is
                    addd      #$0001              compensate for carry
MsgBoxTimerSet      std       $01,s               save timer epoch

MsgBoxWaitLoop      ldd       $01,s               load saved epoch
                    cmpd      >$0249              epoch changed (timer wrapped)?
                    blt       MsgBoxClose         yes — timed out
                    bgt       MsgBoxWaitKey       not yet — check for key
                    ldd       $03,s               load tick expiry
                    cmpd      >$024B              tick counter reached expiry?
                    bls       MsgBoxClose         yes — timed out
MsgBoxWaitKey       lbsr      WaitEnterOrEsc      poll for Enter or Escape
                    tsta                          $FF = no key yet
                    bmi       MsgBoxWaitLoop      still waiting
MsgBoxClose         lbsr      cmd_close_window    cmd_close_window
                    lda       ,s                  load result (1=Enter, 0=Esc)

MsgBoxRet           leas      $05,s               clean up stack
                    rts

message_box_draw    leas      >-$02BC,s           allocate large local text buffer
                    lbsr      cmd_close_window    cmd_close_window
                    lbsr      PushTextColor       save current text color
                    lbsr      PushRowCol          save current cursor position
                    clra                          fg = 0
                    ldb       #$0F                bg = 15 (normal)
                    lbsr      text_color          set normal text color
                    ldb       >PrintAtHeight,pcr  data byte iniz to FF
                    cmpb      #$FF                no explicit height set?
                    bne       MsgBoxSetHeight     height was set — use it
                    tst       >$02C3,s            auto-height already calculated?
                    bne       MsgBoxSetupDraw     yes — skip init
                    ldb       #$1E                default max height = 30 rows
                    stb       >$02C3,s            store default
                    bra       MsgBoxSetupDraw     proceed with layout
MsgBoxSetHeight     lda       >PrintAtHeight,pcr  data byte iniz to FF
                    sta       >$02C3,s            store explicit height
MsgBoxSetupDraw     leax      ,s                  X = local text buffer
                    ldd       >$02C2,s            load message length arg
                    pshs      b,a                 push length
                    ldd       >$02C0,s            load message string arg
                    pshs      b,a                 push string pointer
                    pshs      x                   push destination buffer
                    lbsr      MsgTextSetup        format message text into buffer
                    leas      $06,s               pop three args
                    tst       >$02C5,s            print-at flag set?
                    beq       MsgBoxSkipPrintAt   no — use auto-position
                    lda       >$02C3,s            load height
                    sta       >$0159              store window height
                    lda       >$02C1,s            load width
                    beq       MsgBoxSkipPrintAt   zero width — skip
                    sta       >$015C              store window width
MsgBoxSkipPrintAt   lda       #$13                max allowed height = 19
                    cmpa      >$015C              window fits?
                    bcc       MsgBoxHeightOk      yes — proceed
                    ldx       >$02BE,s            X = message resource pointer
                    lda       <$14,x              save resource byte
                    clr       <$14,x              clear it (truncation marker)
                    pshs      x,a                 save pointer and byte
                    leau      >StrMsgTooVerbose,pcr to verbose message
                    leax      >$025B,s            X = scratch buffer
                    ldd       >$02C1,s            load width arg
                    pshs      b,a                 push width
                    pshs      u                   push "too verbose" string
                    pshs      x                   push scratch buffer
                    lbsr      PrintFmtStr         format truncated message
                    leas      $06,s               pop args
                    puls      x,a                 restore pointer and saved byte
                    sta       <$14,x              restore resource byte
                    stu       >$02BE,s            restore message pointer
                    bra       MsgBoxSetupDraw     retry layout with truncated message
MsgBoxHeightOk      lda       >$015C              window height in chars
                    ldb       #$08                8 pixels per char row
                    mul                           D = height in pixels
                    addb      #$0A                add top/bottom border
                    stb       >$017C              store pixel height
                    lda       >$0159              window width in chars
                    ldb       #$04                4 pixels per char column
                    mul                           D = width in pixels
                    addb      #$0A                add left/right border
                    stb       >$017D              store pixel width
                    lda       >PrintAtCol,pcr     data byte iniz to FF
                    bpl       MsgBoxColCalc       explicit column set
                    lda       #$13                center: start from col 19
                    suba      >$015C              subtract width
                    lsra                          / 2
                    adda      #$01                +1 for border
MsgBoxColCalc       adda      >$0242              add display offset
                    sta       >$0176              store left column
                    adda      >$015C              add width
                    deca                          right column = left + width - 1
                    sta       >$0178              store right column
                    lda       >PrintAtRow,pcr     data byte iniz to FF
                    bpl       MsgBoxRowCalc       explicit row set
                    lda       #$28                center: start from row 40
                    suba      >$0159              subtract height
                    lsra                          / 2
MsgBoxRowCalc       sta       >$0177              store top row
                    sta       >$017B              store window top
                    adda      >$0159              add height
                    sta       >$0179              store bottom row
                    lda       >$0176              load left column
                    ldb       >$0177              load top row
                    std       <TextRow            position cursor at window top-left
                    lda       #$04                4 pixels per column
                    mul                           D = left-edge pixel x
                    subb      #$05                subtract border offset
                    stb       >$017E              store pixel x
                    lda       >$0178              load right column
                    inca                          +1
                    suba      >$0242              subtract display offset
                    ldb       #$08                8 pixels per row
                    mul                           D = width in pixels
                    addb      #$04                add right border
                    stb       >$017F              store pixel width

                    ldd       #$040F              window color: fg=4, bg=15
                    pshs      d                   push color arg
                    ldd       >$017C              pixel height + width
                    pshs      d                   push height/width arg
                    ldd       >$017E              pixel x + pixel width
                    pshs      d                   push x/pixel-width arg
                    lda       #$0C                draw_window()
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up stack

                    lda       #$01                mark window as open
                    sta       >$0180              set window-open flag
                    leax      ,s                  X = formatted text buffer
                    pshs      x                   push for print
                    lbsr      PrintFmtStrToScr    render message text into window
                    leas      $02,s               pop arg
                    clr       >$017B              clear window-top cursor
                    lbsr      PopRowCol           restore saved cursor position
                    lbsr      PopTextColor        restore saved text color
                    leas      >$02BC,s            release local text buffer
                    rts

cmd_close_window    tst       >$0180              window open?
                    beq       CloseWindowRet      no — nothing to do

                    ldd       >$017C              load pixel height + width
                    pshs      d                   push for close_window call
                    ldd       >$017E              load pixel X + pixel width
                    pshs      d                   push for close_window call
                    lda       #$03                offset: close_window in scrn module
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler — erase window
                    leas      $04,s               pop close_window args

                    clr       >$0180              mark window as closed
CloseWindowRet      rts

MsgTextSetup        ldd       #$0000              clear line/word-wrap counters
                    sta       >$015C              line count = 0
                    sta       >PrintColPos        column position = 0
                    sta       >$0159              max line width = 0
                    std       >WordWrapPos        word-wrap pointer = null
                    lda       $07,s               load max-width arg
                    sta       >$0158              store as line width limit
                    ldu       $04,s               load source string pointer
                    beq       MsgTextSetupNoStr   null string — skip format
                    ldd       $02,s               load destination buffer pointer
                    pshs      b,a                 push destination
                    pshs      u                   push source string
                    lbsr      FormatStr           format/word-wrap string into buffer
                    leas      $04,s               pop format args
                    clr       ,u                  null-terminate formatted output
                    lbsr      IncrLineCount       count the final line
MsgTextSetupNoStr   ldx       $02,s               load destination buffer pointer
                    rts

FormatStr           leas      -$02,s              allocate 2-byte scratch frame
                    pshs      x                   save format string pointer
                    ldx       $06,s               X = source format string
                    ldu       $08,s               U = output buffer pointer
                    tst       ,x                  format string empty?
                    lbeq      FormatStrDone       yes — nothing to format
                    lda       >$015C              load current column width
                    cmpa      #$13                beyond max width (19)?
                    lbhi      FormatStrDone       yes — output is full
FormatStrLoop       lda       >PrintColPos        load current column position
                    cmpa      >$0158              reached line width limit?
                    lbcc      FormatStrWordWrap   yes — word-wrap
                    lda       ,x                  peek at next format char
                    lbeq      FormatStrDone       null terminator — done
                    cmpa      >FmtEscPrefix       matches escape prefix?
                    bne       FormatStrCheckEsc   no — check for %
                    tst       ,x+                 skip escape prefix byte
                    bra       FormatStrStoreChar  copy character as-is
FormatStrCheckEsc   cmpa      #$25                is it '%' escape?
                    beq       FormatStrEscape     yes — process escape
                    cmpa      #$0A                newline character?
                    bne       FormatStrCheckNl    no — check for space
                    lbsr      IncrLineCount       count the line break
                    bra       FormatStrCopyChar   copy newline to output
FormatStrCheckNl    cmpa      #$20                is it a space?
                    bne       FormatStrStoreChar  no — just store char
                    stu       >WordWrapPos        save space position for word-wrap
FormatStrStoreChar  inc       >PrintColPos        increment column position
FormatStrCopyChar   lda       ,x+                 load char from source, advance X
                    sta       ,u+                 store char to output, advance U
                    bra       FormatStrLoop       process next character
FormatStrEscape     ldd       ,x++                load escape code byte pair, advance X
                    cmpb      #$77                is it %w (word)?
                    beq       FormatStrEscapeW    yes — substitute word
                    cmpb      #$73                is it %s (string variable)?
                    beq       FormatStrEscapeS    yes — substitute string
                    cmpb      #$6D                is it %m (message)?
                    beq       FormatStrEscapeM    yes — substitute message
                    cmpb      #$67                is it %g (global message)?
                    beq       FormatStrEscapeG    yes — substitute global message
                    cmpb      #$76                is it %v (variable)?
                    lbeq      FormatStrEscapeV    yes — substitute variable value
                    cmpb      #$6F                is it %o (object name)?
                    bne       FormatStrLoop       unknown escape — skip
                    stu       $08,s               save output position
                    lbsr      ParseDecStr         parse decimal number from X
                    clra                          clear A for byte index
                    ldu       #$0432              U = state.var[] base
                    lda       d,u                 A = variable value
                    ldb       #$03                3 bytes per object entry
                    mul                           D = offset to object entry
                    addd      #$0000              (align offset)
                    ldu       <BlockPtr           U = object data block
                    ldu       d,u                 U = object name pointer
                    lbra      FormatStrEscapeRec  recurse to substitute name
FormatStrEscapeW    stu       $08,s               save output position
                    lbsr      ParseDecStr         parse word index from X
                    decb                          word index is 1-based — adjust
                    bmi       FormatStrLoop       was 0 — invalid, skip
                    cmpb      >$015A              word index in range?
                    bcc       FormatStrLoop       out of range — skip
                    lslb                          × 2 for word-table entry size
                    ldu       #$0181              U = word group table base
                    leau      [b,u]               U = word_table[word_idx]
                    lbra      FormatStrEscapeRec  recurse to substitute word text
FormatStrEscapeS    stu       $08,s               save output position
                    lbsr      ParseDecStr         parse string number from X
                    lda       #$28                40 bytes per string slot
                    mul                           D = offset into string table
                    addd      #StringTable        D = &state.string[n]
                    tfr       d,u                 U = pointer to string variable
                    bra       FormatStrEscapeRec  recurse to substitute string
FormatStrEscapeM    stu       $08,s               save output position
                    lbsr      ParseDecStr         parse message number from X
                    lbsr      GetMsgPtr           U = pointer to message text
                    cmpu      #$0000              message found?
                    lbeq      FormatStrLoop       no — skip
                    bra       FormatStrEscapeRec  recurse to substitute message
FormatStrEscapeG    stu       $08,s               save output position
                    ldd       <CurrentLogicPtr    save current logic context
                    std       $02,s               stash for restore
                    clrb                          clear B before logic find
                    lbsr      FindLogicSlot       find global logic slot
                    stu       <CurrentLogicPtr    switch to global logic
                    ldd       $04,u               load logic page info
                    lbsr      SetLogicPage        map global logic page
                    lbsr      ParseDecStr         parse message number from X
                    lbsr      GetMsgPtr           U = pointer to global message
                    cmpu      #$0000              message found?
                    beq       FormatStrEscapeGRet no — skip recursion
                    ldd       $08,s               load output buffer position
                    pshs      b,a                 push output position
                    pshs      u                   push message pointer
                    lbsr      FormatStr           recurse: substitute global message
                    leas      $04,s               pop recursion args
FormatStrEscapeGRet ldu       $02,s               restore saved logic pointer
                    stu       <CurrentLogicPtr    restore current logic context
                    ldd       $04,u               load original logic page info
                    lbsr      SetLogicPage        restore original logic page mapping
                    ldu       $08,s               reload output buffer position
                    lbra      FormatStrLoop       continue format processing
FormatStrEscapeV    stu       $08,s               save output position
                    lbsr      ParseDecStr         parse variable number from X
                    ldu       #$0432              U = state.var[] base
                    clra                          clear A for byte index
                    ldb       d,u                 B = variable value
                    pshs      x                   save format string pointer
                    lbsr      UIntToDecStr        convert variable value to decimal string
                    tfr       x,u                 U = decimal string
                    puls      x                   restore format string pointer
                    lda       ,x                  peek at next char
                    cmpa      #$7C                is it '|' (zero-pad specifier)?
                    bne       FormatStrEscapeRec  no — substitute as-is
                    leax      $01,x               skip past '|'
                    lbsr      ParseDecStr         parse pad width
                    lbsr      StrZeroPad          zero-pad the decimal string
FormatStrEscapeRec  ldd       $08,s               load current output position
                    pshs      b,a                 push output position
                    pshs      u                   push substitution string pointer
                    lbsr      FormatStr           recurse to substitute value
                    leas      $04,s               pop recursion args
                    stu       $08,s               update output pointer after substitution
                    lbra      FormatStrLoop       continue format processing
FormatStrWordWrap   ldd       >WordWrapPos        load last-space position
                    bne       FormatStrWordWrapMove yes — wrap at last space
                    lda       #$0A                no space found — force newline here
                    sta       ,u+                 write newline to output
                    stu       $08,s               update output pointer
                    lbsr      IncrLineCount       count the new line
                    lbra      FormatStrLoop       continue
FormatStrWordWrapMove clr     ,u                  null-terminate at current position
                    tfr       u,d                 D = current output position
                    subd      >WordWrapPos        D = distance from last space to here
                    negb                          B = negative displacement
                    addb      >PrintColPos        column = current col - displacement
                    stb       >PrintColPos        update column counter after wrap
                    lbsr      IncrLineCount       count the wrapped line
                    pshs      x                   save format string pointer
                    ldx       >WordWrapPos        X = position of last space in output
                    lda       #$0A                write newline at the space position
                    sta       ,x+                 replace space with newline
FormatStrSkipSpaces lda       ,x+                 skip leading spaces after wrap
                    cmpa      #$20                is it a space?
                    beq       FormatStrSkipSpaces continue skipping
                    leax      -$01,x              back up to first non-space
                    ldu       >WordWrapPos        U = start of wrap region
                    leau      $01,u               U = past the newline
                    lbsr      StrCopy             copy tail of string to wrap position
                    ldd       #$0000              clear last-space tracker
                    std       >WordWrapPos        reset word-wrap anchor
FormatStrCountChars lda       ,x+                 count chars remaining in copied tail
                    beq       FormatStrCountRet   null — done counting
                    inc       >PrintColPos        increment column for each char
                    bra       FormatStrCountChars loop
FormatStrCountRet   leau      -$01,x              back up to null terminator
                    stu       $0A,s               update output end pointer
                    puls      x                   restore format string pointer
                    lbra      FormatStrLoop       continue format processing
FormatStrDone       puls      x                   restore original format pointer
                    leas      $02,s               release scratch frame
                    rts

GetMsgPtr           leas      -$01,s              1-byte scratch frame
                    ldu       <CurrentLogicPtr    U = current logic slot
                    cmpb      $03,u               msg number within valid range?
                    bls       GetMsgPtrFound      yes — look it up
                    ldd       #$0000              out of range — return null
                    tfr       d,u                 U = null pointer
                    bra       GetMsgPtrRet        return null
GetMsgPtrFound      ldu       $0A,u               U = message offset table for this logic
                    stb       ,s                  save msg number
                    clra                          clear high byte for word index
                    lslb                          msg_num × 2 (each entry is a word offset)
                    rola                          propagate carry into A
                    ldd       d,u                 D = offset to message text
                    bne       GetMsgPtrRet        non-zero offset — valid message
                    ldb       ,s                  reload msg number for error report
                    lda       #$0E                error: message not found
                    lbsr      ReportError         report message-not-found error
GetMsgPtrRet        exg       a,b                 swap offset bytes (big-endian → word)
                    leau      d,u                 U = pointer to message text
                    leas      $01,s               release scratch frame
                    rts

cmd_display         leas      >-$03E8,s           make room for a thousand bytes the message
                    lbsr      PushRowCol          push_row_col
                    ldd       ,y++                get the row and col from the input
                    std       <TextRow            stow it as row,col
                    ldb       ,y+                 load message number from bytecode
                    bsr       GetMsgPtr           U = pointer to message text
                    leax      ,s                  X = local 1000-byte text buffer
                    ldd       #$0028              max width = 40 chars
                    pshs      d                   push width arg
                    pshs      u                   push message pointer arg
                    pshs      x                   push output buffer arg
                    lbsr      MsgTextSetup        agi_printf ?? or str_wordwrap
                    leas      $06,s               clean up the stack

                    leax      ,s                  X = formatted text buffer
                    pshs      x                   push buffer pointer arg
                    lbsr      PrintFmtStrToScr    render text to screen
                    leas      $02,s               pop arg

                    lbsr      PopRowCol           pop_row_col
                    leas      >$03E8,s            cleanup the stack
                    rts

cmd_display_v       leas      >-$03E8,s           allocate 1000-byte text buffer
                    lbsr      PushRowCol          save current cursor position
                    ldx       #$0432              X = state.var[] base
                    ldb       ,y+                 load row variable index
                    abx                           X = &state.var[row_var]
                    lda       ,x                  A = row value from variable
                    ldx       #$0432              X = state.var[] base
                    ldb       ,y+                 load col variable index
                    abx                           X = &state.var[col_var]
                    ldb       ,x                  B = col value from variable
                    std       <TextRow            set cursor row/col from variables
                    ldx       #$0432              X = state.var[] base
                    ldb       ,y+                 load message-number variable index
                    abx                           X = &state.var[msg_var]
                    ldb       ,x                  B = message number from variable
                    bsr       GetMsgPtr           U = pointer to message text
                    leax      ,s                  X = local text buffer
                    ldd       #$0028              max width = 40 chars
                    pshs      b,a                 push width arg
                    pshs      u                   push message pointer arg
                    pshs      x                   push output buffer arg
                    lbsr      MsgTextSetup        format message into buffer
                    leas      $06,s               pop args
                    leax      ,s                  X = formatted text buffer
                    pshs      x                   push buffer pointer arg
                    lbsr      PrintFmtStrToScr    render text to screen
                    leas      $02,s               pop arg
                    lbsr      PopRowCol           restore cursor position
                    leas      >$03E8,s            release text buffer
                    rts

ParseDecStr         clrb                          B = accumulator, start at 0
ParseDecStrLoop     lda       ,x                  load next character
                    cmpa      #$30                below '0'?
                    bcs       ParseDecStrRet      yes — end of number
                    cmpa      #$39                above '9'?
                    bhi       ParseDecStrRet      yes — end of number
                    lda       #$0A                multiply accumulator by 10
                    mul                           D = B × 10
                    subb      #$30                subtract '0' from next digit
                    addb      ,x+                 add digit to product, advance X
                    bra       ParseDecStrLoop     next character
ParseDecStrRet      rts

IncrLineCount       inc       >$015C              increment line count
                    lda       >PrintColPos        load current column position
                    clr       >PrintColPos        reset column to 0 (new line)
                    cmpa      >$0159              was this the widest line?
                    bls       IncrLineCountRet    no — keep current max width
                    sta       >$0159              yes — update max line width
IncrLineCountRet    rts

PrintFmtOutPtr      fdb       $0000
PrintFmtDrawFlag    fcb       $00
PrintFmtHasText     fcb       $00
PrintFmtBasePtr     fdb       $0000

PrintFmtStr         clr       >PrintFmtDrawFlag,pcr clear data byte
                    ldd       $02,s               D = output buffer pointer
                    std       >PrintFmtOutPtr,pcr save output pointer
                    ldx       $04,s               X = format string
                    leau      $06,s               U = variadic args start
                    bsr       PrintFmtLoop        format and copy
                    ldu       $02,s               U = output buffer start
                    rts

PrintFmtStrToScr    leas      <-$2A,s             allocate 42-byte line buffer
                    clr       >PrintFmtHasText,pcr data byre
                    lda       #$01                flag: draw to screen
                    sta       >PrintFmtDrawFlag,pcr enable screen-draw mode
                    leax      ,s                  X = local line buffer
                    stx       >PrintFmtBasePtr,pcr save buffer base
                    stx       >PrintFmtOutPtr,pcr init output pointer to buffer start
                    ldx       <$2C,s              X = format string (from caller frame)
                    leau      <$2E,s              U = variadic args start
                    bsr       PrintFmtLoop        format and output
                    leas      <$2A,s              release line buffer
                    rts

PrintFmtLoop        lda       ,x+                 load next format char, advance X
                    beq       PrintFmtOutputChar  null — output it (flushes line)
                    cmpa      #$25                is it '%' escape?
                    beq       PrintFmtEscS        yes — process format specifier
                    bsr       PrintFmtOutputChar  literal char — output it
                    bra       PrintFmtLoop        continue
PrintFmtEscS        lda       ,x+                 load format specifier char
                    cmpa      #$73                is it 's' (string)?
                    bne       PrintFmtEscD        no — check 'd'
                    ldd       ,u++                load string pointer arg, advance U
                    pshs      u,x                 save format pointer and arg pointer
                    bra       PrintFmtStrEmit     emit string
PrintFmtEscD        cmpa      #$64                is it 'd' (signed decimal)?
                    bne       PrintFmtEscUX       no — check 'u'/'x'
                    tst       ,u                  test sign of value
                    bpl       PrintFmtEscU        non-negative — use unsigned path
                    lda       #$2D                negative — emit '-' sign
                    bsr       PrintFmtOutputChar  output minus sign
                    ldd       #$0000              negate: 0 - value
                    subd      ,u++                D = absolute value
                    pshs      u,x                 save pointers
                    lbsr      UIntToDecStr        convert absolute value to string
                    tfr       x,d                 D = string pointer
                    bra       PrintFmtStrEmit     emit decimal string
PrintFmtEscUX       cmpa      #$75                is it 'u' (unsigned decimal)?
                    beq       PrintFmtEscU        yes — unsigned decimal path
                    cmpa      #$78                is it 'x' (hex)?
                    bne       PrintFmtEscC        no — check 'c'
                    ldd       ,u++                load value arg, advance U
                    pshs      u,x                 save pointers
                    lbsr      UIntToHexStr        convert to hex string
                    tfr       x,d                 D = string pointer
                    bra       PrintFmtStrEmit     emit hex string
PrintFmtEscU        ldd       ,u++                load unsigned value arg, advance U
                    pshs      u,x                 save pointers
                    lbsr      UIntToDecStr        convert to decimal string
                    tfr       x,d                 D = string pointer
                    bra       PrintFmtStrEmit     emit decimal string
PrintFmtEscC        cmpa      #$63                is it 'c' (char)?
                    bne       PrintFmtEscOther    no — unknown specifier
                    ldd       ,u++                load char arg, advance U
                    bsr       PrintFmtOutputChar  output char directly
                    bra       PrintFmtLoop        continue
PrintFmtEscOther    leax      -$01,x              back up past specifier
                    lda       -$01,x              reload the '%' character
                    bsr       PrintFmtOutputChar  output '%' literally
                    bra       PrintFmtLoop        continue
PrintFmtStrEmit     tfr       d,x                 X = string to emit
PrintFmtStrEmitLoop lda       ,x+                 load next char from string, advance
                    lbne      PrintFmtStrEmitChar non-null — output it
                    puls      u,x                 restore format/arg pointers
                    lbra      PrintFmtLoop        continue format processing
PrintFmtStrEmitChar bsr       PrintFmtOutputChar  output char to buffer/screen
                    bra       PrintFmtStrEmitLoop continue emitting string
PrintFmtOutputChar  pshs      u,x                 save caller's pointers
                    ldu       >PrintFmtOutPtr,pcr load output pointer
                    sta       ,u+                 store char, advance output pointer
                    stu       >PrintFmtOutPtr,pcr update output pointer
                    tst       >PrintFmtDrawFlag,pcr screen-draw mode active?
                    beq       PrintFmtOutputCharRet no — buffer-only mode, done
                    tsta                          is char a null (end of string)?
                    beq       PrintFmtFlushLine   yes — flush any buffered line
                    cmpa      #$0A                is char a newline (LF)?
                    beq       PrintFmtFlushLine   yes — flush line
                    cmpa      #$0D                is char a carriage return?
                    beq       PrintFmtFlushLine   yes — flush line
                    lda       #$01                printable char — mark line as having text
                    sta       >PrintFmtHasText,pcr set has-text flag
                    bra       PrintFmtOutputCharRet done
PrintFmtFlushLine   tst       >PrintFmtHasText,pcr any printable text buffered?
                    beq       PrintFmtPostFlush   no — skip line render
                    clr       ,-u                 null-terminate line (pre-decrement)
                    pshs      a                   save delimiter char

                    ldd       >PrintFmtBasePtr,pcr load line buffer base
                    pshs      d                   push buffer pointer arg
                    lda       #$0F                screen-print MMU remap offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    clra                          A = 0 (clear has-text flag)
                    sta       >PrintFmtHasText,pcr reset has-text flag
                    puls      a                   restore delimiter char
PrintFmtPostFlush   tsta                          null delimiter (end of string)?
                    beq       PrintFmtResetOutPtr zero — reset output pointer
                    lbsr      PutCharToWindow     non-zero — emit to window
PrintFmtResetOutPtr ldu       >PrintFmtBasePtr,pcr reset output to buffer start
                    stu       >PrintFmtOutPtr,pcr restore output pointer
PrintFmtOutputCharRet puls    u,x                 restore caller's pointers
                    rts

cmd_set_priority    lda       ,y+                 get the byet passed in and bump y
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object pointer
                    lda       <$26,u              load control flags
                    ora       #O_PRIFIXED         set priority-fixed bit
                    sta       <$26,u              save updated flags
                    lda       ,y+                 read explicit priority value
                    sta       <$24,u              store as object priority
                    rts

cmd_release_priority lda      ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$26,u              load control flags
                    anda      #$FB                clear priority-fixed bit
                    sta       <$26,u              allow engine to recalculate priority
                    rts

cmd_get_priority    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$24,u              load current priority
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get destination variable index
                    abx                           X = &state.var[dst]
                    sta       ,x                  store priority in variable
                    rts

cmd_set_priority_v  lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       <$26,u              load control flags
                    ora       #$04                set priority-fixed bit
                    sta       <$26,u              save updated flags
                    ldx       #$0432              state.var[] base
                    ldb       ,y+                 get variable index holding priority
                    abx                           X = &state.var[prio_var]
                    lda       ,x                  load priority value from variable
                    sta       <$24,u              store as object priority
                    rts

InitRandSeed        leas      -$09,s              9-byte local frame (time packet + result)
                    clr       ,s                  clear result flag
                    ldd       <RandSeedHi            is seed already set?
                    bne       ComputeRand         yes — generate next value
                    leax      $03,s               X = time packet buffer
                    os9       F$Time              get current time
                    ldd       $07,s               load seconds from time packet
                    addd      $05,s               add minutes
                    addd      $03,s               add hours
                    orb       #$01                force odd seed (avoid zero)
                    std       <RandSeedHi            save initial seed
ComputeRand         lda       #$4D                LCG step: multiply by 0x4D
                    mul                           D = seed_hi × 0x4D
                    std       $01,s               save high product
                    ldb       <RandSeedHi            load seed low byte
                    lda       #$4D                multiply by 0x4D
                    mul                           D = seed_lo × 0x4D
                    addd      ,s                  add high product
                    std       ,s                  save combined product
                    lda       #$7C                add increment 0x7C × seed_hi2
                    ldb       <RandSeedLo            load second seed byte
                    mul                           D = 0x7C × seed_hi2
                    addd      ,s                  accumulate into combined product
                    std       ,s                  save updated value
                    ldd       $01,s               load new seed word
                    addd      #$0001              add 1 (LCG addend)
                    std       <RandSeedHi            save new seed
                    eorb      <RandSeedHi            mix in low byte of new seed as result
                    leas      $09,s               release frame
                    rts


StrRestartGame      fcc       'Press ENTER to start a new'
                    fcb       C$LF
                    fcc       'game.'
                    fcb       C$LF,C$LF
                    fcc       'Press CTRL-BREAK to continue'
                    fcb       C$LF
                    fcc       'with this game.'
                    fcb       C$NULL

* ====================================================================
* GAME STATE: RESTART, RESTORE, AND SAVE
* Three commands for persisting and resetting game state. cmd_restart
* prompts (unless auto-restart is set) and reinitialises the engine
* from scratch. cmd_restore deserialises a previously saved file back
* into live game state. cmd_save_game serialises the current state
* (variables, flags, objects, loaded resources, script log) to a
* numbered save slot on disk.
* ====================================================================
cmd_restart_game    leas      -$01,s              allocate 1-byte local frame
                    lbsr      InputEditOn         input_edit_on
                    lda       >$01B1              load restart flags
                    anda      #$80                test auto-restart bit
                    bne       RestartGameWithSave no dialog — restart directly
                    leau      >StrRestartGame,pcr new game message
                    lbsr      message_box         show restart confirmation dialog
                    beq       RestartGameDone     Escape pressed — cancel
RestartGameWithSave lbsr      cmd_cancel_line     clear input line
                    lda       >$01B0              load state flags
                    anda      #$40                isolate save-score bit
RestartGameReload   sta       ,s                  save score-restore flag
                    lbsr      ResetHeap           free heap memory
                    lbsr      LoadObjectData      reload object data from volume
                    lbsr      VolumesClose        volumes_close
                    lda       >$01AF              load game flags
                    ora       #$02                set restart-in-progress bit
                    sta       >$01AF              write back flags
                    lda       ,s                  reload score-restore flag
RestartGameSetFlags beq       RestartGameReset    no saved score — skip
                    lda       >$01B0              load state flags
RestartGameSetScore ora       #$40                set save-score bit
                    sta       >$01B0              write back flags
RestartGameReset    orcc      #IntMasks           disable interrupts
                    ldd       #$0000              zero value for timer clear
                    std       >$0249              clear timer epoch counter
                    std       >$024B              clear tick counter
                    andcc     #^IntMasks          re-enable interrupts
                    ldb       <StringPtrFlag      check if logic is loaded
                    beq       RestartGameLoadLogic no — skip reload
                    lbsr      AllocLoadLogic      reload logic 0
RestartGameLoadLogic lbsr     EnableItemLoop      re-enable all items
                    ldy       #$0000              reset bytecode program counter
RestartGameDone     lbsr      InputCursorBlink    restore input cursor
                    leas      $01,s               release local frame
                    rts

* cmd_restore_game text strings
StrRestoreGameMsg   fcc       'About to restore the game'
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

StrCantOpenFile     fcc       "Can't open file:"
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$NULL

StrRestoreErr       fcc       'Error in restoring game.'
                    fcb       C$LF
                    fcc       'Press ENTER to quit.'
                    fcb       C$LF
                    fcb       C$NULL


StrContinueCancel   fcc       'Press ENTER to continue.'
                    fcb       C$LF
                    fcc       'Press CTRL-BREAK to cancel.'
                    fcb       C$NULL

SaveFilePathNum     fcb       $00


* cmd_restore_game (state_io.c)

cmd_restore_game    leas      >-$00FD,s           allocate large restore frame
                    sty       ,s                  code_ret (arg passed in)
                    lda       #$01                set clock_state = 1 (paused)
                    sta       >ClockState         clock_state?
                    lda       >$0101              msgstate.newline_char
                    sta       $02,s               save original
                    lda       #'@                 $40 load value for msgstate.newline_char
                    sta       >$0101              save it
RestoreGameLoop     ldd       #$0072              load save-slot list size
                    pshs      d                   push size arg
                    lbsr      StateGetInfo        build saved-game slot list
                    leas      $02,s               pop size arg
                    tsta                          any saved games?
                    lbeq      rest_end            no — nothing to restore
                    lda       >state_name_auto,pcr FILE struct datablock ???
                    bne       RestoreGameOpenFile auto-restore (no dialog)
                    leau      >StrContinueCancel,pcr continue/cancel message
                    pshs      u                   push footer button label
RestoreGameGetDesc  leau      >DataSaveGameBuf2,pcr 64 byte data block
RestoreGameShowMsg  pshs      u                   push save-game description buffer
                    leau      >DataSaveGameBuf,pcr 31 byte data block
                    pshs      u                   push filename buffer
                    leax      >StrRestoreGameMsg,pcr about to restore message
                    leau      $09,s               U = message output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format "Restore game: <desc>" message
                    leas      $0A,s               pop all args
                    ldd       #$0000              print-at row = auto
                    pshs      b,a                 push row arg (0 = auto-center)
                    ldd       #$0023              print-at col = 35
                    pshs      b,a                 push col arg
                    ldd       #$0000              width = auto
                    pshs      b,a                 push width arg
                    pshs      u                   push formatted message
                    lbsr      message_box_draw    message_box_draw
                    leas      $08,s               pop message_box_draw args
                    lbsr      BooleanPoll         wait for Enter or Escape
                    cmpa      #$00                Escape pressed?
                    lbeq      rest_end            yes — cancel restore
RestoreGameOpenFile lda       #$01                open for read
                    leax      >DataSaveGameBuf2,pcr 64 byte data block
                    lbsr      OpenFile            Open path routine
                    bcc       RestoreGameReadData opened successfully
                    leau      >DataSaveGameBuf2,pcr 64 byte data block
                    pshs      u                   push filename for error msg
                    leau      >DataSaveGameBuf,pcr 31 byte data block
                    pshs      u                   push path buffer
                    leax      >StrCantOpenFile,pcr can't open file message
                    leau      $07,s               U = message buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format "Can't open <file>" message
                    leas      $08,s               pop all args
                    lbsr      message_box         display error dialog
                    lbra      rest_end            exit
RestoreGameReadData sta       >SaveFilePathNum,pcr save open path number
                    clrb                          seek mode = absolute
                    ldx       #$0000              offset high word = 0
                    ldu       #$001F              offset = 31 (skip header)
                    lbsr      SeekFile            seek past game header
                    ldd       #$01AD              state.block_state address
                    pshs      b,a                 push destination
                    lbsr      RestoreReadBlock    read state block
                    leas      $02,s               pop arg
                    beq       RestoreGameReadErr  short read — error
                    ldd       <ViewObjBase        object table address
                    pshs      b,a                 push destination
                    lbsr      RestoreReadBlock    read object table
                    leas      $02,s               pop arg
                    beq       RestoreGameReadErr  short read — error
                    ldd       <BlockPtr           heap block pointer
                    pshs      b,a                 push heap destination
                    lbsr      RestoreReadBlock    read heap block pointer
                    leas      $02,s               pop arg
                    beq       RestoreGameReadErr  short read — error
                    ldx       <BlockPtr           X = heap base
                    ldd       <BlockOffset        D = current heap offset
                    leau      d,x                 U = current heap top
                    lbsr      XorDecrypt          decrypt heap data in place
                    ldd       >$05AF              script table address
                    pshs      b,a                 push script destination
                    lbsr      RestoreReadBlock    read script table
                    leas      $02,s               pop arg
                    beq       RestoreGameReadErr  short read — error
                    ldd       #$0554              misc state address
                    pshs      b,a                 push misc-state destination
                    lbsr      RestoreReadBlock    read misc state block
                    leas      $02,s               pop arg
                    bne       RestoreGameReadOk   all blocks read OK
RestoreGameReadErr  lda       >SaveFilePathNum,pcr load path number
                    lbsr      CloseFilePath       Close path routine
                    leau      >StrRestoreErr,pcr  Error in restoring game message
                    lbsr      message_box         display read-error dialog

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

RestoreGameReadOk   lda       >SaveFilePathNum,pcr load path number
                    lbsr      CloseFilePath       Close path routine
                    lda       >$0553              load saved room number
                    sta       >$044C              set current room number
                    lbsr      RestoreGameTables   rebuild all resource tables
                    lbsr      ClearStateVars      self contained call to clear 50 bytes 05BA
                    lda       >$01B0              set restore-in-progress flag
                    ora       #$08                set bit 3 (restore active)
                    sta       >$01B0              write back flags
                    lbsr      VolumesClose        volumes_close
                    ldd       #$0000              clear room-change counter
                    std       ,s                  zero room-change on the stack
                    lbsr      EnableItemLoop      re-enable all inventory items

rest_end            lbsr      cmd_close_window    cmd_close_window
                    lda       $02,s               pull newline_org
                    sta       >$0101              save it in msgstate.newline_char
                    clr       >ClockState         clock_state = 0
                    ldy       ,s                  code_ret
                    leas      >$00FD,s            release frame
                    rts

RestoreReadBlock    leas      -$02,s              allocate 2-byte size buffer
                    lda       >SaveFilePathNum,pcr data byte
                    leax      ,s                  X = size buffer
                    ldy       #$0002              read 2 bytes (block size field)
                    lbsr      ReadFile            Read routine
                    cmpd      #$0002              read exactly 2 bytes?
                    bne       RestoreReadBlockFail no — short read, fail
                    ldy       ,x                  Y = block size from file
                    sty       ,s                  save size in local
                    lda       >SaveFilePathNum,pcr data byte
                    ldx       $04,s               X = destination buffer address
                    lbsr      ReadFile            Read routine
                    cmpy      ,s                  read expected number of bytes?
                    bne       RestoreReadBlockFail no — short read, fail
                    lda       #$01                success return code
                    bra       RestoreReadBlockRet return
RestoreReadBlockFail clra                         return 0 = failure
RestoreReadBlockRet leas      $02,s               release size buffer
                    rts

RestoreGameTables   leas      >-$0206,s           allocate 518-byte work buffer
                    leax      $06,s               X = start of work buffer
                    stx       $04,s               save buffer pointer
                    lbsr      ResetGameTables     clear all resource tables
                    clr       >$05B1              clear heap-init flag
                    ldu       <ViewObjBase        U = first object
RestoreGameObjLoop  cmpu      <ViewObjEnd         past end of object list?
                    bcc       RestoreGameObjDone  yes — done scanning
                    ldd       <$25,u              load object state/flags word
                    ldx       $04,s               X = work buffer write pointer
                    std       ,x++                save state/flags in work buffer
                    stx       $04,s               advance write pointer
                    bitb      #$40                draw flag set?
                    beq       RestoreGameObjNext  no — skip flag fixup
                    andb      #$FE                clear draw-pending bit
                    orb       #$10                set draw-complete bit
                    stb       <$26,u              store updated flags
RestoreGameObjNext  leau      <$2B,u              advance to next object (43 bytes)
                    bra       RestoreGameObjLoop  process next object
RestoreGameObjDone  lbsr      BlitBothErase       erase all objects from both buffers
                    lbsr      ResetHeap           reset the heap allocator
                    clr       >PicVisible         pic_visible = 0
                    lbsr      ResetScriptPtrs     reset script replay pointers
RestoreGameHeapLoop lbsr      PopScript           pop next script entry (→ U)
                    cmpu      #$0000              end of script?
                    beq       RestoreGameHeapDone yes — done replaying
                    ldd       ,u                  load script entry type + resource number
                    cmpa      #$00                type 0 = load logic?
                    bne       RestoreHeapType1    no — check type 1
                    lbsr      AllocLoadLogic      reload logic resource
                    lbsr      SeekLogicInList     place in logic list
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType1    cmpa      #$01                type 1 = load view?
                    bne       RestoreHeapType2    no — check type 2
                    lda       #$01                flag: loading for restore
                    lbsr      view_load           reload view resource
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType2    cmpa      #$02                type 2 = load pic?
                    bne       RestoreHeapType3    no — check type 3
                    lbsr      LoadPicImpl         reload pic resource
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType3    cmpa      #$03                type 3 = load sound?
                    bne       RestoreHeapType4    no — check type 4
                    lbsr      LoadSoundData       reload sound resource
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType4    cmpa      #$04                type 4 = draw pic?
                    bne       RestoreHeapType5    no — check type 5
                    lbsr      DrawPicImpl         redraw pic
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType5    cmpa      #$05                type 5 = add-to-pic?
                    bne       RestoreHeapType6    no — check type 6
                    lbsr      PopScript           pop add-to-pic args (3 entries)
                    ldd       ,u                  load first arg pair
                    ldx       #$05B2              add-to-pic parameter block
                    std       ,x                  store arg 1
                    lbsr      PopScript           pop second arg entry
                    ldd       ,u                  load second arg pair
                    std       $02,x               store arg 2
                    lbsr      PopScript           pop third arg entry
                    ldd       ,u                  load third arg pair
                    std       $04,x               store arg 3
                    lbsr      AddToPicImpl        re-render add-to-pic overlay
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType6    cmpa      #$06                type 6 = discard pic?
                    bne       RestoreHeapType7    no — check type 7
                    lbsr      DiscardPicImpl      free pic resource
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType7    cmpa      #$07                type 7 = discard view?
                    bne       RestoreHeapType8    no — check type 8
                    lbsr      DiscardViewHelper   free view resource
                    bra       RestoreGameHeapLoop continue replay
RestoreHeapType8    cmpa      #$08                type 8 = overlay pic?
                    bne       RestoreGameHeapLoop unknown type — skip
                    lbsr      pic_overlay         re-render overlay pic
                    bra       RestoreGameHeapLoop continue replay
RestoreGameHeapDone lda       #$01                mark heap as initialized
                    sta       >$05B1              set heap-init flag
                    ldu       <ViewObjEnd         U = past last object (iterate backwards)
RestoreGameViewLoop leau      <-$2B,u             step back one object
                    cmpu      <ViewObjBase        before first object?
                    bcs       RestoreGameViewDone yes — done
                    ldx       $04,s               X = work buffer read pointer
                    ldd       ,--x                read saved state/flags word
                    stx       $04,s               save updated read pointer
                    std       ,s                  save state/flags for this object
                    stu       $02,s               save object pointer
                    ldb       $05,u               load view number
                    lbsr      view_find           find view resource (→ X)
                    leax      ,x                  NULL?
                    beq       RestoreGameViewCheck yes — no view to restore
                    ldb       $05,u               reload view number
                    lbsr      SetViewForObj       assign view to object
RestoreGameViewCheck ldd      ,s                  reload saved state/flags
                    bitb      #$40                was object drawn?
                    beq       RestoreGameViewLoop no — skip draw restore
                    bitb      #$01                draw-active flag set?
                    beq       RestoreGameViewNext no — skip
                    lda       $02,u               load object priority
                    lbsr      DrawObjHelper       draw object at saved position
                    ldu       $02,s               reload object pointer
                    lda       <$22,u              load motion type
                    cmpa      #$02                motion type 2 = follow?
                    bne       RestoreGameViewFlags no
                    lda       #$FF                reset follow target distance
                    sta       <$29,u              mark follow-target as uninitialized
RestoreGameViewFlags ldd      ,s                  reload state/flags
                    bitb      #$10                update-stopped flag?
                    bne       RestoreGameViewNext yes — leave stopped
                    lbsr      StopObjUpdate       stop animation updates
                    ldu       $02,s               reload object pointer
                    ldd       ,s                  reload state/flags
RestoreGameViewNext std       <$25,u              store restored state/flags
                    bra       RestoreGameViewLoop process next object
RestoreGameViewDone lbsr      InputEditOn         input_edit_on
                    lbsr      cmd_cancel_line     clear any pending input
                    lbsr      gfx_picbuff_update  blit restored pic to screen
                    lda       #$01                mark pic as visible
                    sta       >PicVisible         pic_visible = 1
                    lbsr      StatusLineWrite     redraw status bar
                    lbsr      InputRedraw         redraw input line
                    leas      >$0206,s            release work buffer
                    rts

AllocViewEntry      ldd       #$000E              allocate 14-byte view-entry node
                    lbsr      AllocDataBlock      alloc from data heap
                    ldd       #$0000              clear first two fields
                    std       ,u                  zero link + reserved
                    std       $02,u               zero next two fields
                    stx       $04,u               store X (parent view-object pointer)
                    stu       <$16,x              link view-entry back into object
                    ldd       <$1C,x              load sprite width
                    std       $08,u               save width in entry
                    ldd       $03,x               load X/Y position
                    bita      #$01                X position odd?
                    beq       AllocViewEntrySize  no — keep as-is
                    deca                          yes — adjust for alignment
                    inc       $08,u               widen sprite by 1
AllocViewEntrySize  subb      <$1D,x              B = bottom_row - sprite_height
                    incb                          +1 to include bottom row
                    std       $06,u               store row range in entry
                    ldd       $08,u               reload width
                    bita      #$01                width odd?
                    beq       AllocViewEntryAlloc no — use as-is
                    inca                          round up to even width
                    sta       $08,u               save adjusted width
AllocViewEntryAlloc mul                           A × B = sprite buffer size (pixels)
                    tfr       u,x                 save entry pointer in X
                    lbsr      AllocHeap           allocate sprite pixel buffer
                    lbsr      CalcPriCoord        compute priority coordinates
                    std       $0C,x               save priority coords in entry
                    stu       $0A,x               save pixel buffer pointer in entry
                    tfr       x,u                 return view-entry pointer in U
                    rts

*  nagi has 50 bytes
state_name_auto     fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00

StrSaveGameMsg      fcc       'About to save the game'
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

StrDirFullMsg       fcc       'The directory'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$LF
                    fcc       'is full.'
                    fcb       C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL

StrDiskFullMsg      fcc       'The disk is full.'
                    fcb       C$LF
                    fcc       'Press ENTER to continue.'
                    fcb       C$NULL

SaveFileHandle      fcb       $00


cmd_set_simple      lda       ,y+                 load string variable index from bytecode
                    ldb       #$28                40 bytes per string slot
                    mul                           D = offset into string table
                    ldx       #StringTable        state.string
                    leax      d,x                 from address
                    leau      >state_name_auto,pcr state_name_auto
                    ldd       #$001F              load d with 31
                    lbsr      MemCopyNull         copy routine
                    rts                           return

cmd_save_game       leas      >-$00FE,s           allocate large save frame
                    sty       ,s                  save bytecode return address
                    clr       $02,s               clear save-slot index
                    lda       #$01                set clock_state = 1 (paused)
                    sta       >ClockState         pause clock
                    lda       >$0101              save original newline char
                    sta       $03,s               stash for restore
                    lda       #$40                set newline char to '@' (64)
                    sta       >$0101              override newline for dialog
                    ldd       #$0073              save-slot list buffer size
                    pshs      b,a                 push size arg
SaveGameLoop        lbsr      StateGetInfo        build saved-game slot list
                    leas      $02,s               pop size arg
                    tsta                          any save slots available?
                    lbeq      SaveGameDone        no — nothing to do
SaveGameCheck       lda       >state_name_auto,pcr FILE struct data block ???
                    bne       SaveGameCreateFile  auto-save (no dialog)
SaveGameShowMsg     leau      >StrContinueCancel,pcr continue / cancel message
                    pshs      u                   push button labels
                    leau      >DataSaveGameBuf2,pcr 64 byte data block
                    pshs      u                   push save description buffer
                    leau      >DataSaveGameBuf,pcr 31 byte data block
                    pshs      u                   push filename buffer
                    leax      >StrSaveGameMsg,pcr about to save game msg
                    leau      $0A,s               U = message output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format "Save game: <desc>" message
                    leas      $0A,s               pop all args
                    ldd       #$0000              print-at row = auto
                    pshs      b,a                 push row arg
                    ldd       #$0023              print-at col = 35
                    pshs      b,a                 push col arg
                    ldd       #$0000              width = auto
                    pshs      b,a                 push width arg
                    pshs      u                   push formatted message
                    lbsr      message_box_draw    message_box_draw
                    leas      $08,s               pop message_box_draw args
                    lbsr      BooleanPoll         wait for Enter or Escape
                    cmpa      #$00                Escape?
                    lbeq      SaveGameDone        yes — cancel save
SaveGameCreateFile  lda       #$02                create/write access
                    ldb       #$03                attributes: public r/w
                    leax      >DataSaveGameBuf2,pcr 64 byte data block
                    lbsr      CreateFile          Create routine
                    bcc       SaveGameWriteData   created OK
                    leau      >SaveDiskNameBuf,pcr 31 byte data block
                    pshs      u                   push disk name for error msg
                    leax      >StrDirFullMsg,pcr  dir is full msg
                    leau      $06,s               U = message buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format "Directory full" message
                    leas      $06,s               pop all args
                    lbsr      message_box         display directory-full dialog
                    lbra      SaveGameDone        abort save
SaveGameWriteData   sta       >SaveFileHandle,pcr save open file path number
                    leax      >DataSaveGameBuf,pcr 31 byte data block
                    ldy       #$001F              write 31-byte header
                    lbsr      WriteFile           Write routine
                    cmpd      #$001F              wrote expected bytes?
                    bne       SaveGameWriteErr    no — disk error
                    ldd       #$0385              state block size
                    pshs      b,a                 push size
                    ldd       #$01AD              state.block_state address
                    pshs      b,a                 push address
                    lbsr      SaveWriteBlock      write state block
                    leas      $04,s               pop args
                    beq       SaveGameWriteErr    write failed
                    ldd       <ViewObjSizeD       object table size
                    pshs      b,a                 push size
                    ldd       <ViewObjBase        object table address
                    pshs      b,a                 push address
                    lbsr      SaveWriteBlock      write object table
                    leas      $04,s               pop args
                    beq       SaveGameWriteErr    write failed
                    inc       $02,s               mark: heap was encrypted (for XorDone check)
                    ldx       <BlockPtr           X = heap base
                    ldd       <BlockOffset        D = current heap size
                    leau      d,x                 U = heap top
                    lbsr      XorDecrypt          encrypt heap in place for save
                    ldd       <BlockOffset        heap size
                    pshs      b,a                 push heap size
                    ldd       <BlockPtr           heap base address
                    pshs      b,a                 push heap address
                    lbsr      SaveWriteBlock      write heap block
                    leas      $04,s               pop args
                    beq       SaveGameWriteErr    write failed
                    lda       >$0246              script entry count
                    ldb       #$02                2 bytes per entry
                    mul                           D = script table size in bytes
                    pshs      b,a                 push script size
                    ldd       >$05AF              script table address
                    pshs      b,a                 push address
                    lbsr      SaveWriteBlock      write script table
                    leas      $04,s               pop args
                    beq       SaveGameWriteErr    write failed
                    lbsr      BuildLogicList      build list of loaded logics
                    pshs      x                   push logic list
                    ldd       #$0554              misc state address
                    pshs      b,a                 push misc-state address
                    lbsr      SaveWriteBlock      write misc state block
                    leas      $04,s               pop args
                    bne       SaveGameWriteOk     all blocks written OK
SaveGameWriteErr    lda       >SaveFileHandle,pcr load path number
                    lbsr      CloseFilePath       Close path routine
                    leax      >DataSaveGameBuf2,pcr 64 byte data block
                    lbsr      DeleteFile          Delete routine
                    leau      >StrDiskFullMsg,pcr the disk is full msg
                    lbsr      message_box         display disk-full error
                    bra       SaveGameDone        abort after error
SaveGameWriteOk     lda       >SaveFileHandle,pcr load path number
                    lbsr      CloseFilePath       Close path routine
SaveGameDone        lda       $02,s               was heap encrypted during save?
                    beq       SaveGameXorDone     no — skip decrypt
                    ldx       <BlockPtr           X = heap base
                    ldd       <BlockOffset        D = heap size
                    leau      d,x                 U = heap top
                    lbsr      XorDecrypt          decrypt heap back to normal
SaveGameXorDone     lbsr      cmd_close_window    cmd_close_window
                    lda       $03,s               load saved newline char
                    sta       >$0101              restore msgstate.newline_char
                    clr       >ClockState         clock_state = 0
                    ldy       ,s                  restore return address
                    leas      >$00FE,s            release frame
                    rts

SaveWriteBlock      lda       >SaveFileHandle,pcr load file path number
                    leax      $04,s               X = block size field (2 bytes)
                    ldy       #$0002              write 2-byte size header
                    lbsr      WriteFile           Write routine
                    cmpd      #$0002              wrote 2 bytes?
                    bne       SaveWriteBlockFail  no — fail
                    lda       >SaveFileHandle,pcr reload path number
                    ldx       $02,s               X = block data address
                    ldy       $04,s               Y = block data size
                    lbsr      WriteFile           Write routine
                    cmpd      $04,s               wrote expected bytes?
                    bne       SaveWriteBlockFail  no — fail
                    lda       #$01                return 1 = success
                    bra       SaveWriteBlockRet   return success
SaveWriteBlockFail  clra                          return 0 = failure
SaveWriteBlockRet   rts

*save_drive
SaveDriveNum        fcb       $00                 drive number to hold working disk

StrSaveFmtDir       fcc       '%s%s'
StrSaveFmtFile      fcc       '%ssg.%d'
                    fcb       C$NULL


BuildSaveFilePath   leas      -$05,s              5-byte frame: [,s]=dest X, [2,s]=slot#, [3,s]=sep char
                    stx       ,s                  save destination buffer pointer
                    stb       $02,s               save save-slot number
                    ldd       #$0000              clear separator char field
                    std       $03,s               initialize separator to none
                    leax      >SaveDiskNameBuf,pcr X = save directory name
                    lbsr      StrLen              measure directory name length
                    decb                          point to last char (length - 1)
                    leax      b,x                 X = last char of directory name
                    lda       #$2F                '/' path separator
                    cmpa      ,-x                 does directory name end with '/'?
                    beq       BuildSaveFilePathFmt yes — no separator needed
                    sta       $03,s               no — store '/' as separator to insert
BuildSaveFilePathFmt clra                         clear high byte
                    ldb       $02,s               reload slot number
                    pshs      b,a                 push slot number as arg
                    ldd       #$01CF              game ID buffer address
                    pshs      b,a                 push game ID pointer
                    leax      $07,s               X = destination buffer in frame
                    pshs      x                   push dest buffer
                    leax      >SaveDiskNameBuf,pcr X = save directory name
                    pshs      x                   push directory name
                    leax      >StrSaveFmtDir,pcr  format: "%s%s"
                    ldu       $08,s               U = output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format directory + separator
                    leas      $0C,s               pop all args
                    lbsr      StrToLower          convert filename to lowercase
                    tfr       u,x                 X = end of formatted path
                    leas      $05,s               release frame
                    rts

* (state_info.c)
GetDiskInfo         leas      <-$45,s             69-byte frame (drive info + disk name)
                    clr       ,s                  clear result flag
                    leau      ,s                  U = frame base
                    lbsr      FindCurrentDisk     locate current disk
                    ldx       <$47,s              X = saved directory path
                    lbsr      ChangeDir           change to save game directory
                    bcs       GetDiskInfoFail     failed — directory doesn't exist
                    clr       <$40,s              clear disk name buffer
                    leau      <$40,s              U = disk name buffer
                    lbsr      GetDiskName         read disk volume name into buffer
GetDiskInfoFound    ldb       <$43,s              load drive number found
                    stb       >SaveDriveNum,pcr   save as current save drive
                    lda       #$01                return 1 = success
                    bra       GetDiskInfoRet      return success
GetDiskInfoFail     clra                          return 0 = failure
GetDiskInfoRet      sta       <$44,s              save result
                    leax      ,s                  X = original directory path
                    lbsr      ChangeDir           restore original directory
                    lda       <$44,s              reload result
                    leas      <$45,s              release frame
                    rts

ExecLogicScript     leas      -$02,s              2-byte locals: [,s]=result [1,s]=not-flag
                    ldy       <CurrentLogicPtr    point to current logic slot
                    ldd       $04,y               get logic's memory page
                    lbsr      SetLogicPage        map it in
                    ldy       $08,y               point Y to script bytecode
ExecScriptLoop      ldb       ,y+                 fetch next bytecode
ExecScriptCheck     tstb                          is it zero?
                    beq       ExecScriptDone      yes — end of script
                    cmpb      #$FF                is it an IF opcode?
                    beq       ExecScriptIf        yes — evaluate condition block
                    cmpb      #$FE                is it a GOTO opcode?
                    bne       ExecScriptCmd       no — it's a regular command
ExecScriptJump      ldb       ,y+                 fetch high offset byte
                    lda       ,y+                 fetch low offset byte
                    leay      d,y                 apply relative jump
                    bra       ExecScriptLoop      continue at new position
ExecScriptCmd       lbsr      ExecCmd             execute the command
                    leay      ,y                  test Y (zero = script ended)
                    bne       ExecScriptCheck     non-zero — keep going
ExecScriptDone      bra       ExecLogicScriptRet  script done — return
ExecScriptIf        ldd       #$0000              init locals: result=0, not-flag=0
                    std       ,s                  zero both locals
ExecScriptIfLoop    lda       ,y+                 fetch condition opcode
                    cmpa      #$FC                is it $FC (end of condition list)?
                    bhi       ExecScriptIfHi      > $FC — special control byte
                    bne       ExecScriptEvalExpr  non-zero — evaluate condition
                    lda       ,s                  $00: load accumulated result
                    bne       ExecScriptSkipBlock result true — execute block
                    inc       ,s                  result was false — set to 1 (true)
                    bra       ExecScriptIfLoop    evaluate next condition
ExecScriptIfHi      cmpa      #$FF                is it $FF (end of IF block)?
                    bne       ExecScriptIfFD      no — check for $FD (OR/NOT)
                    leay      $02,y               skip the else-block offset word
                    bra       ExecScriptLoop      continue main loop
ExecScriptIfFD      cmpa      #$FD                is it $FD (NOT/OR toggle)?
                    bne       ExecScriptEvalExpr  no — evaluate as condition
                    lda       $01,s               load not-flag
                    eora      #$01                toggle it
                    sta       $01,s               save toggled flag
                    bra       ExecScriptIfLoop    evaluate next condition
ExecScriptEvalExpr  lbsr      EvalExpr            call into eval_table index calc
                    eora      $01,s               XOR result with not-flag
                    clr       $01,s               clear not-flag for next condition
                    tsta                          test result
                    bne       ExecScriptTrueBlock condition true — execute block
                    lda       ,s                  load accumulated AND result
                    bne       ExecScriptIfLoop    was true — keep evaluating
ExecScriptSkipBlock clr       ,s                  clear result flag
ExecScriptSkipLoop  lda       ,y+                 scan past command bytes
                    cmpa      #$FF                end-of-if marker?
                    beq       ExecScriptJump      yes — apply the jump offset
                    cmpa      #$FC                control byte?
                    bcc       ExecScriptSkipLoop  yes — skip it
                    bsr       ExecScriptExecCmd   skip past command arguments
                    bra       ExecScriptSkipLoop  continue skipping
ExecScriptTrueBlock lda       ,s                  load result flag
                    beq       ExecScriptIfLoop    false — keep evaluating
                    clr       ,s                  clear result flag
ExecScriptTrueLoop  lda       ,y+                 fetch byte in true-block
                    cmpa      #$FC                control byte?
                    bhi       ExecScriptTrueLoop  yes — skip it
                    beq       ExecScriptIfLoop    $FC end — back to conditions
                    bsr       ExecScriptExecCmd   advance Y past command args
                    bra       ExecScriptTrueLoop  continue executing true block
ExecScriptExecCmd   cmpa      #$0E                is it a "said" command ($0E)?
                    bne       ExecScriptExecCmdImpl no — regular skip
                    lda       ,y+                 fetch word-pair count
                    lsla                          ×2 bytes per word pair
                    leay      a,y                 skip over word-pair data
                    rts

ExecScriptExecCmdImpl lsla                        ×2
                    lsla                          ×4 = table offset
                    adda      #$02                +2 to reach arg-mask byte
                    leax      >eval_table,pcr     eval_table base
                    lda       a,x                 fetch argument mask for this command
                    leay      a,y                 advance Y past command arguments
                    rts

ExecLogicScriptRet  leas      $02,s               release locals
                    rts

* same sequence of bytes at L00E2 in sierra

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


cmd_text_screen     lbsr      InputEditOn         input_edit_on
                    lda       #$01                make a 1
                    sta       ChgenTextMode       stow it at chgen_textmode
                    lda       #$15                text-mode MMU remap offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    rts

cmd_graphics        lbsr      InputEditOn         input_edit_on
                    lbsr      SetGraphicsMode     switch to graphics display mode
                    rts

cmd_clear_lines     ldb       $02,y               load color byte arg (3rd arg)
                    pshs      b,a                 push color
                    ldb       $01,y               load end row (2nd arg)
                    pshs      b,a                 push end row
                    ldb       ,y                  load start row (1st arg)
                    pshs      b,a                 push start row
                    lbsr      ClearTextRows       erase the rows
                    leas      $06,s               pop 3 args
                    leay      $03,y               advance bytecode past 3 arguments
                    rts

cmd_clear_text_rect ldb       $04,y               load 5th arg (color)
                    pshs      b,a                 push color
                    ldb       $03,y               load 4th arg (right col)
                    pshs      b,a                 push right col
                    ldb       $02,y               load 3rd arg (bottom row)
                    pshs      b,a                 push bottom row
                    ldb       $01,y               load 2nd arg (left col)
                    pshs      b,a                 push left col
                    ldb       ,y                  load 1st arg (top row)
                    pshs      b,a                 push top row
                    lbsr      ClearTextRect       erase the rectangle
                    leas      $0A,s               pop 5 args
                    leay      $05,y               advance bytecode past 5 arguments
                    rts

cmd_set_text_attribute ldd    ,y++                load foreground and background in d
                    bsr       text_color          set text colors
                    rts

* this routine takes the LSB value and copies it to the MSB also
text_color          anda      #$0F                mask the MSB off of forground
                    sta       >TextFgColor        stow at state.text_fg
                    lsla                          shift left 4
                    lsla                          — shift 2
                    lsla                          — shift 3
                    lsla                          — shift 4: foreground in high nibble
                    ora       >TextFgColor        or that with state.text_fg
                    sta       >TextFgColor        and save it back

                    andb      #$0F                mask the MSB off of background
                    stb       >TextBgColor        stow it at state.text.bg
                    lslb                          shift left 4
                    lslb                          — shift 2
                    lslb                          — shift 3
                    lslb                          — shift 4: background in high nibble
                    orb       >TextBgColor        or it with state.text_bg
                    stb       >TextBgColor        save it back
                    rts

SetGraphicsMode     lda       #$00                clear text-mode flag
                    sta       >$05EC              chgen_textmode = 0 (graphics mode)

                    lda       #$09                offset: init_graphics in scrn module
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler — switch to graphics mode
                    lbsr      StatusLineWrite     redraw status bar
                    lbsr      InputRedraw         redraw input line
                    rts

cmd_config_screen   lda       ,y                  read display-offset arg
                    sta       >$0242              store as screen display offset
                    adda      #$15                add 21 rows for full display offset
                    sta       >$0240              store as extended display offset
                    lda       ,y+                 re-read display-offset arg, advance Y
                    ldb       #$08                8 pixels per row
                    mul                           D = row count × 8 pixels
                    lda       #$A0                160 pixels per row (double-wide CoCo)
                    mul                           D = total pixel offset
                    std       <PixDispAddr            save as pixel display address
                    lda       ,y+                 read input-row arg
                    sta       >$01D8              store as state.input_row
                    lda       ,y+                 read status-row arg
                    sta       >$0248              store as state.status_row
                    rts

cmd_toggle_monitor  leas      -$04,s              allocate 4-byte local frame
                    pshs      y                   save bytecode pointer
                    leax      >PaletteData,pcr    data table
                    ldb       >$0553              display type
                    eorb      #$01                change display type to the other
*                          will change the type from comp<->rbg
                    stb       >$0553              save that as display_type
                    lda       #$10                16 times the type
                    mul                           D = palette table offset
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
PaletteWriteLoop    ldb       ,x+                 get color table value
                    stb       $05,s               put it on stack
                    pshs      x                   push our x value
                    lda       #StdOut             set path to stdout
                    leax      $04,s               start of data to write
                    os9       I$Write             send it
                    bcs       PaletteWriteRet     error during write clean up stack and leave
                    puls      x                   retrieve or x
                    inc       $04,s               bump the PRN value
                    lda       $04,s               grab the PRN value
                    cmpa      #$10                have we done all 16 ?
                    blo       PaletteWriteLoop    nope go again
PaletteWriteRet     puls      y                   restore bytecode pointer
                    leas      $04,s               release local frame
                    rts

PushTextColor       ldb       >$0172              load color stack depth
                    cmpb      #$05                stack full (max 5 saved colors)?
                    bcc       PushTextColorRet    yes — don't overflow
                    ldx       #$015D              color stack base
                    lslb                          depth × 2 (each entry is 2 bytes: fg+bg)
                    abx                           X = next stack slot
                    ldd       >TextFgColor        load current text_fg/bg
                    std       ,x                  save colors onto stack
                    inc       >$0172              advance stack depth
PushTextColorRet    rts

PopTextColor        ldb       >$0172              load color stack depth
                    ble       PopTextColorRet     stack empty — nothing to restore
                    decb                          decrement depth
                    stb       >$0172              save updated depth
                    ldx       #$015D              color stack base
                    lslb                          depth × 2
                    ldd       b,x                 load saved fg/bg colors
                    std       >TextFgColor        restore text_fg/bg
PopTextColorRet     rts

ScriptWritePtr      fdb       $0000
ScriptReadPtr       fdb       $0000

InitScriptBuf       ldu       >$05AF              load script buffer address
                    bne       InitScriptBufRet    already allocated — just reset
                    lda       >$0246              load script_size (max entries)
                    beq       InitScriptBufRet    zero size — nothing to do
                    ldb       #$02                2 bytes per entry
                    mul                           D = total buffer bytes
                    lbsr      AllocDataBlock      allocate from data heap
                    stu       >$05AF              save script buffer base address
                    ldd       <HeapTop            load heap top
                    std       <HeapBase           record as heap base for script
InitScriptBufRet    stu       >ScriptWritePtr,pcr write pointer = buffer start
                    clr       >ScriptCount        state.script_count = 0
                    rts

PushScript          leas      -$02,s              save 2-byte type+resource arg
                    std       ,s                  save entry on stack
                    lda       >$01AF              load state flags
                    anda      #$01                script disabled?
                    bne       PushScriptRet       yes — don't record
                    lda       >$05B1              heap initialized flag
                    beq       PushScriptUpdate    not init — just update high-water mark
                    clra                          clear high byte
                    ldb       >$0246              load max script entries
                    lslb                          × 2 bytes each
                    rola                          propagate carry
                    addd      >$05AF              D = buffer end address
                    cmpd      >ScriptWritePtr,pcr within buffer bounds?
                    bhi       PushScriptStore     yes — safe to write
                    lda       #$0B                error: script buffer overflow
                    ldb       <HeapByteCnt        pass heap stats
                    lbsr      ReportError         report buffer-overflow error
PushScriptStore     ldu       >ScriptWritePtr,pcr U = write pointer
                    ldd       ,s                  reload entry
                    std       ,u++                write entry and advance write pointer
                    stu       >ScriptWritePtr,pcr save updated write pointer
                    inc       >ScriptCount        increment script entry count
PushScriptUpdate    ldd       >ScriptWritePtr,pcr load current write pointer
                    subd      >$05AF              D = bytes used so far
                    cmpd      <HeapMax            new high-water mark?
                    bls       PushScriptRet       no — leave as is
                    std       <HeapMax            yes — update high-water mark
PushScriptRet       leas      $02,s               release arg frame
                    rts

ResetScriptPtrs     ldd       >$05AF              D = script buffer base
                    std       >ScriptReadPtr,pcr  read pointer = buffer start (for replay)
                    lda       >ScriptCount        load script entry count
                    ldb       #$02                2 bytes per entry
                    mul                           D = byte offset to write end
                    addd      >$05AF              D = end of written entries
                    std       >ScriptWritePtr,pcr set write pointer for replay
                    rts

PopScript           ldu       #$0000              default: return null (no entry)
                    ldd       >ScriptReadPtr,pcr  D = current read pointer
                    cmpd      >ScriptWritePtr,pcr at write end?
                    bcc       PopScriptRet        yes — script exhausted
                    tfr       d,u                 U = pointer to this entry
                    addd      #$0002              advance read pointer by 2 bytes
                    std       >ScriptReadPtr,pcr  save updated read pointer
PopScriptRet        rts

cmd_script_size     lda       ,y+                 read new script size from bytecode
                    sta       >$0246              update max script entries
                    lbsr      BlitBothErase       erase sprites from both buffers
                    lbsr      InitScriptBuf       reinitialize script buffer
                    lbsr      EraseAndBlitShdw    redraw shadow and blit to screen
                    rts

cmd_push_script     lda       >ScriptCount        save current script count
                    sta       >ScriptSaved        state.script_saved = script_count
                    rts

cmd_pop_script      clra                          clear high byte
                    ldb       >ScriptSaved        load saved script count
                    stb       >ScriptCount        restore script count
                    lslb                          count × 2 bytes/entry
                    rola                          propagate carry
                    addd      >$05AF              D = new write-pointer position
                    std       >ScriptWritePtr,pcr restore write pointer
                    rts

* window_put_char cmd_input.c ???
PutCharToWindow     leas      -$02,s              2-byte char/flag frame
                    pshs      u,x                 save caller's U and X
                    leau      $04,s               U = char arg (from caller's frame)
                    tsta                          is char null?
                    beq       PutCharRet          yes — nothing to output
                    cmpa      #$08                backspace character?
                    bne       PutCharCheckCR      no — check CR/LF
                    dec       <TextCol            move cursor left
                    bpl       PutCharBackspace    still on same row — draw space
                    lda       #$00                column went negative — clamp to 0
                    sta       <TextCol            reset column to 0
                    lda       <TextRow            load row
                    cmpa      #$15                above row 21 (top of text area)?
                    bls       PutCharBackspace    yes — don't scroll up
                    deca                          scroll up one row
                    sta       <TextRow            update row
                    lda       #$27                new col = last column (39)
                    sta       <TextCol            set column

PutCharBackspace    ldd       #$2000              space char + attribute
                    std       ,u                  write space to erase old char
                    pshs      u                   push char buffer pointer
                    lda       #$0F                screen-write MMU offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    dec       <TextCol            move cursor back one more
                    bra       PutCharRet          done
PutCharCheckCR      cmpa      #C$CR               $0D
                    beq       PutCharNewLine      carriage return — go to new line
                    cmpa      #C$LF               $0A
                    bne       PutCharNormal       neither CR nor LF — normal char
PutCharNewLine      lda       <TextRow            load current row
                    cmpa      #C$PAUS             $17 — last scrollable row?
                    bcc       PutCharSetCol       at or below — don't scroll
                    inca                          advance to next row
                    sta       <TextRow            update row
PutCharSetCol       lda       >$017B              load window-left column
                    sta       <TextCol            reset column to window left
                    bra       PutCharRet          done
PutCharNormal       clrb                          B = 0 (normal attribute)
                    cmpa      #$7F                printable char?
                    bls       PutCharWriteScr     yes — write directly

                    ldd       #$2000              non-printable — write space instead
PutCharWriteScr     std       ,u                  store char + attribute
                    pshs      u                   push char buffer pointer
                    lda       #$0F                screen-write MMU offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    lda       <TextCol            load current column
                    cmpa      #$27                reached end of line (col 39)?
                    bls       PutCharRet          no — stay on same line
                    lda       #$0D                yes — emit CR for new line
                    bsr       PutCharToWindow     recurse to handle newline
PutCharRet          puls      u,x                 restore U and X
                    leas      $02,s               release local frame
                    rts

PushRowCol          ldb       >$0167              load row/col stack depth
                    cmpb      #$05                stack full (max 5)?
                    bcc       PushRowColRet       yes — don't overflow
                    ldx       #$0168              row/col stack base
                    lslb                          depth × 2 (each entry is row+col)
                    abx                           X = next stack slot
                    ldd       <TextRow            load current row/col
                    std       ,x                  save onto stack
                    inc       >$0167              advance stack depth
PushRowColRet       rts

PopRowCol           ldb       >$0167              load row/col stack depth
                    ble       PopRowColRet        stack empty — nothing to restore
                    decb                          decrement depth
                    stb       >$0167              save updated depth
                    ldx       #$0168              row/col stack base
                    lslb                          depth × 2
                    ldd       b,x                 load saved row/col
                    std       <TextRow            restore cursor position
PopRowColRet        rts

ClearTextLine       pshs      b,a                 save A (row) and B (color)
                    tfr       a,b                 B = row (to use as both start and end)
                    pshs      b,a                 push row twice (start = end = same row)
                    pshs      b,a                 push again (ClearTextRows needs 3 args)
                    lbsr      ClearTextRows       clear the single row
                    leas      $06,s               pop 3 args
                    rts

ClearTextRows       ldb       $07,s               load color arg from caller's frame
                    pshs      b,a                 push color
                    lda       $07,s               load start row arg
                    ldb       #$27                column 39 (full width)
                    pshs      b,a                 push end col + start row
                    lda       $07,s               load end row arg
                    ldb       #$00                column 0 (left edge)
                    pshs      b,a                 push start col + end row
                    lbsr      ClearTextRect       erase the text rows
                    leas      $06,s               pop 3 args
                    rts

DrawTextRect        leas      <-$2A,s             allocate 42-byte text row buffer
                    lda       #$17                max row = 23 (0-based)
                    cmpa      <$2D,s              start row > max?
                    lbcs      DrawTextRectRet     yes — nothing to draw
                    cmpa      <$2F,s              end row > max?
                    bcc       DrawTextRectClipRow yes — clip needed
                    sta       <$2F,s              clamp end row to max
                    inca                          A = max+1 (one past end)
                    suba      <$2D,s              A = actual height
                    cmpa      <$37,s              height fits in buffer?
                    bcc       DrawTextRectClipRow yes — clip width too
                    sta       <$37,s              store clipped height
DrawTextRectClipRow ldb       <$37,s              load width
                    beq       DrawTextRectDoRows  zero width — skip fill, do rows
                    negb                          negate width
                    incb                          -width + 1
                    addb      <$2F,s              add end col
                    subb      <$2D,s              subtract start col
                    bhi       DrawTextRectFill    positive — fill needed
                    clr       <$37,s              no fill — clear width
                    bra       DrawTextRectDoRows  proceed to row draw
DrawTextRectFill    lda       <$37,s              load clipped height
                    pshs      d                   push height + width
                    lda       <$37,s              reload height for second arg
                    ldb       <$35,s              load right column
                    pshs      d                   push height/right
                    ldb       <$31,s              load start row
                    pshs      d                   push start row
                    lda       #$12                fill-rect MMU remap offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up sthe stack

DrawTextRectDoRows  lda       <$35,s              load right column
                    inca                          +1 for inclusive width
                    suba      <$33,s              subtract left col = char count
                    leau      ,s                  U = local text row buffer
                    ldb       #$20                space character
DrawTextRectFillLoop stb      ,u+                 fill row with spaces
                    deca                          decrement char count
                    bne       DrawTextRectFillLoop loop until filled
                    sta       ,u                  null-terminate row string
                    ldd       >TextFgColor        state.text_fg/bg
                    pshs      b,a                 save current colors
                    ldb       <$33,s              load text color arg
                    lbsr      text_color          set colors for this row
                    lda       <$39,s              load row counter
                    bne       DrawTextRectRowNext non-zero — not first row
                    lda       <$2F,s              first row — load start row
                    sta       <TextRow            set cursor row
                    nega                          negate start row
                    adda      <$31,s              add base row
                    inca                          +1
                    sta       <$39,s              store row count
                    bra       DrawTextRectWriteRow write this row
DrawTextRectRowNext nega                          negate
                    adda      <$31,s              compute row from base
                    inca                          +1 for current row
                    sta       <TextRow            set cursor row
DrawTextRectWriteRow lda      <$35,s              load left column
                    sta       <TextCol            set cursor column

                    leau      $02,s               U = text row buffer (past color stack entry)
                    pshs      u                   push buffer pointer
                    lda       #$0F                screen-write MMU offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    inc       <TextRow            advance to next row
                    dec       <$39,s              decrement remaining rows
                    bne       DrawTextRectWriteRow loop until all rows written
                    puls      b,a                 restore saved colors
                    std       >TextFgColor        restore state.text_fg/bg
DrawTextRectRet     leas      <$2A,s              release local buffer
                    rts

ClearTextRect       ldd       <TextRow            save current cursor row/col
                    pshs      b,a                 push to preserve
                    ldd       #$0000              load a zero for color arg
                    pshs      b,a                 push color = 0 (background)
                    ldb       $09,s               load right-col arg
                    pshs      b,a                 push right col
                    ldb       $09,s               load right-col again (for width)
                    pshs      b,a                 push width
                    ldb       $0F,s               load bottom-row arg
                    pshs      b,a                 push bottom row
                    ldb       $0E,s               load left-col arg
                    pshs      b,a                 push left col
                    ldb       $0E,s               load top-row arg (same as left)
                    pshs      b,a                 push top row
                    lbsr      DrawTextRect        draw (erase) the rectangle
                    leas      $0C,s               pop all args
                    puls      b,a                 restore cursor row/col
                    std       <TextRow            restore cursor position
                    rts

StrInsertDisk       fcc       'Please insert disk %d, side %d'
                    fcb       C$LF
                    fcc       'and press ENTER.'
                    fcb       C$NULL

StrTurnOverDisk     fcc       'Please turn over the disk'
                    fcb       C$LF
                    fcc       'and press ENTER.'
                    fcb       C$NULL

StrWrongDisk        fcc       'That is the wrong disk.'
                    fcb       C$LF,C$LF
                    fcb       C$NULL

StrVolumeFmt        fcc       '%s%s'
                    fcb       C$LF
                    fcc       '%s'
                    fcb       C$NULL

StrVolumeName       fcc       'vol.%d'
                    fcb       C$NULL

StrCantFindVol      fcc       "Can't find %s.%s%s"
                    fcb       C$NULL

VolMaxDisk          fcb       $01
VolCurDisk          fcb       $01
VolCurSide          fcb       $01
VolWrongDisk        fcb       $00
VolDiskInfoPtr      fcb       $00
VolDriveFlag        fcb       $00
VolFileIdx          fcb       $00


OpenVolFile         leas      -$06,s              allocate 6-byte frame
                    std       ,s                  save D (logic page info)
                    stu       $02,s               save U (destination)
                    stx       $04,s               save X (vol entry pointer)
OpenVolFileLoop     bsr       FindVol             search for volume file
                    cmpu      #$0000              found?
OpenVolFileCheckResult bne    OpenVolFileRet      yes — return with U set
                    lda       >VolWrongDisk,pcr   data byte
                    cmpa      #$05                tried 5 times already?
                    beq       OpenVolFileRet      yes — give up
                    ldd       ,s                  reload saved logic page info
OpenVolFileRetry    lbsr      SetLogicPage        restore logic page mapping
                    ldu       $02,s               reload destination pointer
                    ldx       $04,s               reload vol entry pointer
OpenVolFileNextPage bra       OpenVolFileLoop     retry with next page
OpenVolFileRet      leas      $06,s               release frame
                    rts

FindVol             leas      -$0E,s              allocate 14-byte frame
                    stu       ,s                  save caller's U (destination pointer)
                    stx       $02,s               save X (vol entry pointer)
                    pshs      y                   save Y
                    ldu       <HeapPtr            save heap pointer for cleanup on fail
                    stu       $06,s               save heap pointer
                    lda       >$0532              check vol_handle_table[0]
                    cmpa      #$FF                is volume already open?
                    bne       FindVolGotHandle    yes — go use it
                    ldd       >VolDiskInfoPtr,pcr have we loaded disk info yet?
                    bne       FindVolLoadDisk     yes — skip init
                    ldx       [>$0089]            load pointer from disk-info vector
                    stx       >VolDiskInfoPtr,pcr save it
                    ldd       ,x                  load disk/side from info
                    cmpd      #$0101              is disk 1 side 1?
                    beq       FindVolLoadDisk     yes — no prompt needed
                    clrb                          disk number 0 = default
                    lbsr      ShowInsertDiskMsg   prompt to insert disk
FindVolLoadDisk     lbsr      ReadDiskVol         read volume directory from disk
FindVolGotHandle    ldu       $02,s               reload vol entry pointer
                    lda       ,u                  get volume entry byte
                    lsra                          shift volume number to low nibble
                    lsra                          — shift 2
                    lsra                          — shift 3
                    lsra                          — shift 4: volume index in low nibble
                    sta       $08,s               save volume index
                    ldx       #$0532              vol_handle_table base
                    ldb       a,x                 get handle for this volume
                    cmpb      #$FF                is handle valid?
                    bne       FindVolCheckHandle  yes — seek and read
                    lbsr      VolumesClose        close all open volumes
                    ldb       $08,s               reload volume index
                    beq       FindVolDefaultDisk  volume 0 = use default disk
                    cmpb      >$05ED              compare to max known disk
                    bls       FindVolLoadDiskInfo within range — look it up
FindVolDefaultDisk  ldb       >VolMaxDisk,pcr     use max disk as fallback
                    stb       $08,s               store disk index
FindVolLoadDiskInfo decb                          make disk index 0-based
                    lslb                          ×2 (each entry is a word pointer)
                    ldx       <DiskInfoIdx        disk info index table
                    ldx       b,x                 load pointer to this disk's info
                    stx       >VolDiskInfoPtr,pcr save as current disk info
                    ldd       ,x                  load disk number and side
                    cmpa      >VolCurDisk,pcr     matches currently loaded disk?
                    bne       FindVolWrongDisk    no — need to prompt
                    cmpb      >VolCurSide,pcr     matches current side?
                    beq       FindVolLoadSide     yes — just re-read vol
FindVolWrongDisk    lda       #$01                set wrong-disk flag
                    sta       >VolWrongDisk,pcr   mark disk mismatch
                    ldb       $08,s               reload disk number for prompt
                    lbsr      ShowInsertDiskMsg   ask user to insert correct disk
FindVolLoadSide     lbsr      ReadDiskVol         re-read volume after disk change
                    lbra      FindVolFail         (fall through to fail if read failed)
FindVolCheckHandle  stb       >VolFileIdx,pcr     save file handle index
                    clra                          clear high byte of offset
                    ldb       ,u                  load low nibble of vol entry
                    andb      #$0F                mask to file offset (low nibble)
                    tfr       d,x                 transfer offset to X
                    ldu       $01,u               load file pointer from vol entry
                    lda       >VolFileIdx,pcr     reload handle
                    clrb                          zero high byte of seek offset
                    lbsr      SeekFile            seek to resource location in vol file
                    bcs       FindVolReadErr      seek failed
                    lda       >VolFileIdx,pcr     reload file handle
                    leax      $09,s               point to on-stack header buffer
                    ldy       #$0005              read 5-byte resource header
                    lbsr      ReadFile            Read routine
                    bcs       FindVolReadErr      read failed
                    cmpd      #$0005              did we get all 5 bytes?
                    beq       FindVolVerifyHdr    yes — check the magic
FindVolReadErr      lbsr      ErrorDialog         show disk error dialog
                    lbne      FindVolFail         user chose retry — fail out

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

FindVolVerifyHdr    ldd       $09,s               load magic bytes from header
                    cmpd      #$1234              check AGI resource magic number
                    bne       FindVolWrongSide    wrong magic — wrong disk/side
                    lda       $0B,s               get volume number from header
                    cmpa      $08,s               matches what we expected?
                    beq       FindVolGoodHdr      yes — header is valid
FindVolWrongSide    lbsr      VolumesClose        close all volumes
                    lda       #$01                set wrong-disk flag
                    sta       >VolWrongDisk,pcr   mark disk as wrong
                    ldb       $08,s               disk number for message
                    lbsr      ShowWrongDiskMsg    show wrong disk message
                    tsta                          did ShowWrongDiskMsg return non-zero?
                    bne       FindVolRetryDisk    yes — retry

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

FindVolRetryDisk    lbsr      ReadDiskVol         re-read volume directory
                    bra       FindVolFail         and fail this attempt
FindVolGoodHdr      ldb       $0C,s               get resource length high byte
                    lda       $0D,s               get resource length low byte
                    std       <VolFileSize        save total resource size
                    ldu       $04,s               check if destination already allocated
                    bne       FindVolReadData     yes — skip alloc
                    lda       >$05B8              check free-space tracking flag
                    beq       FindVolAllocMem     not tracking — just alloc
                    lbsr      UpdateFreeSpace     compute available heap space
                    cmpd      <VolFileSize        is there enough room?
                    bcc       FindVolAllocMem     yes — proceed
                    lda       #$05                error: not enough memory
                    sta       >VolWrongDisk,pcr   mark as memory error
                    bra       FindVolFail         fail this allocation
FindVolAllocMem     ldd       <VolFileSize        get size to allocate
                    lbsr      AllocHeap           allocate from heap
                    lbsr      CalcPriCoord        compute priority coordinates
                    stu       $04,s               save allocated pointer
                    std       $0E,s               save coordinates
                    lbsr      SetLogicPage        map in the logic page
FindVolReadData     lda       >VolFileIdx,pcr     file handle
                    ldx       $04,s               destination buffer
                    ldy       <VolFileSize        bytes to read
                    lbsr      ReadFile            Read routine
                    bcs       FindVolReadErr      read failed
                    ldu       $04,s               reload destination pointer
                    cmpd      <VolFileSize        got expected byte count?
                    beq       FindVolRet          yes — success
                    lbra      FindVolReadErr      short read — treat as error
FindVolFail         ldd       $06,s               restore saved heap pointer
                    std       <HeapPtr            roll back heap allocation
                    ldu       #$0000              return null U (failure)
FindVolRet          ldd       $0E,s               load coordinates/result
                    puls      y                   restore Y
                    leas      $0E,s               release frame
                    rts

ShowInsertDiskMsg   leas      <-$64,s             allocate 100-byte message buffer
                    leau      ,s                  U = message buffer
                    pshs      b,a                 push disk/side numbers as args
                    pshs      u                   push buffer pointer
                    lbsr      FormatInsertDiskMsg format insert-disk message
                    leas      $04,s               pop args
                    lbsr      message_box         show dialog
                    leas      <$64,s              release buffer
                    rts

FormatInsertDiskMsg ldx       >VolDiskInfoPtr,pcr data byte
                    clra                          clear A (used as 0 for indexing)
                    ldb       $05,s               load requested disk number
                    beq       FormatInsertDiskMsgBody zero — use current disk info
                    cmpb      >$05ED              disk in range?
                    bhi       FormatInsertDiskMsgBody out of range — use current
                    stb       >VolMaxDisk,pcr     update max disk number
                    decb                          make 0-based
                    lslb                          × 2 (each entry is a word pointer)
                    ldx       <DiskInfoIdx        disk info index table
                    ldx       b,x                 load pointer to this disk's info
FormatInsertDiskMsgBody ldb   $01,x               load side number from disk info
                    pshs      b,a                 push side number
                    ldb       ,x                  load disk number from disk info
                    pshs      b,a                 push disk number
                    leax      >StrInsertDisk,pcr  please insert disk
                    cmpb      >VolCurDisk,pcr     matches current disk?
                    bne       FormatInsertDiskMsgRet no — show insert message
                    ldb       $01,x               load side number again
                    cmpb      >VolCurSide,pcr     matches current side?
                    beq       FormatInsertDiskMsgRet same side — no flip needed
                    leax      >StrTurnOverDisk,pcr please turn over the disk
FormatInsertDiskMsgRet ldu    $06,s               load output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format the message
                    leas      $08,s               pop all args
                    rts

ShowWrongDiskMsg    leas      >-$012C,s           allocate 300-byte message buffer
                    pshs      b,a                 push disk number arg
                    lbsr      RingBell            ring the bell
                    leau      $02,s               U = message buffer
                    pshs      u                   push output buffer
                    lbsr      FormatInsertDiskMsg format wrong-disk message
                    leas      $04,s               pop args
                    leau      >StrQuitMsg,pcr     quit msg
                    pshs      u                   push quit message
                    leau      $02,s               U = formatted message buffer
                    pshs      u                   push formatted message
                    leau      >StrWrongDisk,pcr   this is the wrong disk msg
                    pshs      u                   push wrong-disk message
                    leax      >StrVolumeFmt,pcr   %s%s
                    leau      <$6A,s              U = final output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         combine wrong-disk and continue/quit messages
                    leas      $0A,s               pop all args
                    lbsr      message_box         show wrong-disk dialog
                    leas      >$012C,s            release message buffer
                    rts

ReadDiskVol         leas      -$0D,s              allocate 13-byte work frame
                    ldx       >VolDiskInfoPtr,pcr data byte
                    leax      $02,x               skip to vol-table entry
                    ldb       ,x                  load first entry byte
ReadDiskVolName     clra                          clear A for indexing
                    stx       ,s                  save vol-table pointer
                    andb      #$7F                mask to vol number (strip flags)
                    stb       $02,s               save vol number
                    leax      >StrVolumeName,pcr  vol %d
                    leau      $03,s               U = filename buffer
                    pshs      b,a                 push vol number arg
                    pshs      x                   push format string
                    pshs      u                   push filename buffer
                    lbsr      PrintFmtStr         format "vol.N" filename
                    leas      $06,s               pop args
ReadDiskVolOpen     lda       #$01                open for read
                    leax      $03,s               X = filename buffer
                    lbsr      OpenFile            Open path routine
                    bcc       ReadDiskVolStore    opened OK — store handle
                    tstb                          was error E$NotFound (B=0)?
                    bne       ReadDiskVolRetry    real error — show retry dialog
                    clr       >VolCurDisk,pcr     file not found — clear current disk
                    bra       ReadDiskVolRet      return
ReadDiskVolRetry    lbsr      ErrorDialog         show disk-error dialog
                    cmpa      #$00                user chose quit?
                    bne       ReadDiskVolOpen     no — retry open

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

ReadDiskVolStore    ldu       #$0532              vol_handle_table
                    ldb       $02,s               load vol number
                    sta       b,u                 store open handle into table
                    ldx       ,s                  reload vol-table pointer
                    ldb       ,x+                 load current entry, advance
                    bmi       ReadDiskVolSetDisk  high bit set — last vol entry
                    ldb       ,x                  load next vol entry byte
                    bra       ReadDiskVolName     process next vol
ReadDiskVolSetDisk  ldx       >VolDiskInfoPtr,pcr data byte
                    ldd       ,x                  load disk/side info
                    std       >VolCurDisk,pcr     update current disk/side
ReadDiskVolRet      leas      $0D,s               release work frame
                    rts

* volumes_close (res_vol.c)
VolumesClose        leas      -$01,s              allocate 1-byte index frame
                    clrb                          B = vol index = 0
                    ldx       #$0532              vol_handle_table
VolumesCloseLoop    cmpb      #$0F                There are 15 vols in kq3 (0-14)
                    bhs       VolumesCloseDone    >= 15 were finished so leave
                    stb       ,s                  save the offset
                    lda       ,x                  get the val of the vol_handle
                    cmpa      #$FF                is it flagged closed ??
                    beq       VolumesCloseNext    if so no need to close it but
*                          store stow FF there so we can inc the x
                    lbsr      CloseFilePath       Close path routine
                    lda       #$FF                we had a good close so set the close flag
VolumesCloseNext    sta       ,x+                 stow it in the table and bump the pointer
                    ldb       ,s                  grab our index back again
                    incb                          bump it
                    bra       VolumesCloseLoop    go again
VolumesCloseDone    leas      $01,s               clean up stack and were
                    rts                           back at ya

* file_load(u8 *name u8 *buff)  res_vol.c
FileLoad            leas      <-$65,s             allocate 101-byte work frame
                    pshs      y                   save Y
FileLoadOpen        lda       #$01                open for read
                    ldx       <$69,s              X = filename
                    lbsr      OpenFile            Open path routine
                    bcc       FileLoadGetSize     opened OK
                    lda       #$40                set '@' as newline for dialog
                    sta       >$0101              override newline char
                    leau      >StrQuitMsg,pcr     quit msg
                    pshs      u                   push quit message
                    leau      >StrTryAgain,pcr    try again message
                    pshs      u                   push try-again message
                    ldd       <$6D,s              load filename pointer
                    pshs      b,a                 push filename arg
                    leax      >StrCantFindVol,pcr can't find msg
                    leau      $09,s               U = message output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format "can't find <vol>" message
                    leas      $0A,s               pop all args
                    lbsr      message_box         show can't-open dialog
                    bne       FileLoadOpen        user chose retry — try again

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

FileLoadGetSize     sta       $02,s               save open file handle
                    ldu       #$0000              seek offset = 0
                    tfr       u,x                 X = 0 (high word)
                    ldb       #$02                seek mode = end
                    lbsr      SeekFile            seek to end to get size
                    stu       <VolFileSize        save file size
                    ldu       #$0000              seek offset = 0
                    clrb                          seek mode = beginning
                    lbsr      SeekFile            seek back to start
                    ldx       <$6B,s              load destination buffer pointer
                    bne       FileLoadRead        non-null — use caller's buffer
                    ldd       <VolFileSize        need to allocate — get size
                    ldu       <$6F,s              load alloc-info pointer
                    beq       FileLoadAllocData   null — use data-block alloc
                    lbsr      AllocHeap           allocate from heap
                    lbsr      CalcPriCoord        compute priority coordinates
                    stu       [<$6D,s]            store ptr via pointer-to-pointer
                    std       [<$6F,s]            store coordinates
                    lbsr      SetLogicPage        map in logic page
                    bra       FileLoadSetPtr      proceed with read
FileLoadAllocData   lbsr      AllocDataBlock      allocate from data block pool
                    stu       [<$6D,s]            store allocated pointer
FileLoadSetPtr      tfr       u,x                 X = destination buffer
FileLoadRead        lda       $02,s               reload file handle
                    ldy       <VolFileSize        Y = bytes to read
                    lbsr      ReadFile            Read routine
                    cmpd      <VolFileSize        got expected byte count?
                    beq       FileLoadClose       yes — success
                    lbsr      ErrorDialog         read error — show dialog
                    cmpb      #$00                user chose quit?
                    bne       FileLoadClose       no — retry read

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

FileLoadClose       lda       $02,s               reload file handle
                    lbsr      CloseFilePath       Close path routine
                    puls      y                   restore Y
                    leas      <$65,s              release work frame
                    rts

StrLogics           fcc       'Logics'
                    fcb       C$NULL

StrView             fcc       'View'
                    fcb       C$NULL

StrPicture          fcc       'Picture'
                    fcb       C$NULL

StrSoundName        fcc       'Sound'
                    fcb       C$NULL

StrLogDir           fcc       'logDir'
                    fcb       C$NULL

StrViewDir          fcc       'viewDir'
                    fcb       C$NULL

StrPicDir           fcc       'picDir'
                    fcb       C$NULL

StrSndDir           fcc       'sndDir'
                    fcb       C$NULL


StrResNotFound      fcc       '%s #%d not found.'
                    fcb       C$NULL

LogDirPtr           fdb       $0000
LogDirPage          fdb       $0000
ViewDirPtr          fdb       $0000
ViewDirPage         fdb       $0000
PicDirPtr           fdb       $0000
PicDirPage          fdb       $0000
SndDirPtr           fdb       $0000
SndDirPage          fdb       $0000


* ====================================================================
* RESOURCE DIRECTORY LOADING AND FETCH
* LoadAllDirs opens the four AGI directory files (logDir, picDir,
* viewDir, sndDir) at startup and builds in-memory directory tables
* pointing into the VOL files. FetchLogic/View/Picture/Sound look up
* a resource number in the appropriate directory, open the correct
* VOL file, seek to the offset, and load the compressed resource
* data into a heap-allocated block, returning its address in U.
* ====================================================================
LoadAllDirs         leau      >LogDirPage,pcr     data word
                    pshs      u                   push page-store pointer
                    leau      >LogDirPtr,pcr      data word
                    leax      >StrLogDir,pcr      logDir
                    pshs      u                   push ptr-store pointer
                    ldd       #$0000              alloc-info = null
                    pshs      b,a                 push alloc arg
                    pshs      x                   push filename
                    lbsr      FileLoad            load logDir into heap
                    leas      $08,s               pop all args
                    leau      >PicDirPage,pcr     data word
                    pshs      u                   push page-store pointer
                    leau      >PicDirPtr,pcr      data word
                    leax      >StrPicDir,pcr      picDir
                    pshs      u                   push ptr-store pointer
                    ldd       #$0000              alloc-info = null
                    pshs      b,a                 push alloc arg
                    pshs      x                   push filename
                    lbsr      FileLoad            load picDir into heap
                    leas      $08,s               pop all args
                    leau      >ViewDirPage,pcr    data word
                    pshs      u                   push page-store pointer
                    leau      >ViewDirPtr,pcr     data word
                    leax      >StrViewDir,pcr     viewDir
                    pshs      u                   push ptr-store pointer
LoadViewDirCall     ldd       #$0000              alloc-info = null
                    pshs      b,a                 push alloc arg
                    pshs      x                   push filename
                    lbsr      FileLoad            load viewDir into heap
                    leas      $08,s               pop all args
LoadSndDirCall      leau      >SndDirPage,pcr     data word
                    pshs      u                   push page-store pointer
                    leau      >SndDirPtr,pcr      data word
                    leax      >StrSndDir,pcr      sndDir
                    pshs      u                   push ptr-store pointer
                    ldd       #$0000              alloc-info = null
                    pshs      b,a                 push alloc arg
                    pshs      x                   push filename
                    lbsr      FileLoad            load sndDir into heap
                    leas      $08,s               pop all args
                    rts

CheckResPtr         lda       ,u                  load resource entry high nibble
                    anda      #$F0                mask to high nibble
                    cmpa      #$F0                $F0 = not present in this volume
                    bne       CheckResPtrRet      valid entry — return as-is
                    ldu       #$0000              invalid — return null
CheckResPtrRet      rts

FetchLogic          leas      -$01,s              1-byte scratch frame
                    stb       ,s                  save resource number
                    ldd       >LogDirPage,pcr     data word
                    lbsr      SetLogicPage        map logic directory page
                    lda       ,s                  reload resource number
                    ldb       #$03                3 bytes per dir entry
                    mul                           D = offset into logDir
                    ldu       >LogDirPtr,pcr      data word
                    leau      d,u                 U = &logDir[resource]
                    bsr       CheckResPtr         validate entry
                    bne       FetchLogicRet       valid — return entry
                    leax      >StrLogics,pcr      logistics
                    ldb       ,s                  reload resource number
                    lbsr      ResNotFoundErr      report not-found error
FetchLogicRet       ldd       >LogDirPage,pcr     data word
                    leas      $01,s               release scratch frame
                    rts

FetchView           leas      -$01,s              1-byte scratch frame
                    stb       ,s                  save resource number
                    ldd       >ViewDirPage,pcr    data word
                    lbsr      SetLogicPage        map view directory page
                    lda       ,s                  reload resource number
                    ldb       #$03                3 bytes per dir entry
                    mul                           D = offset into viewDir
                    ldu       >ViewDirPtr,pcr     data word
                    leau      d,u                 U = &viewDir[resource]
                    bsr       CheckResPtr         validate entry
                    bne       FetchViewRet        valid — return entry
                    leax      >StrView,pcr        view
                    ldb       ,s                  reload resource number
                    bsr       ResNotFoundErr      report not-found error
FetchViewRet        ldd       >ViewDirPage,pcr    data word
                    leas      $01,s               release scratch frame
                    rts

FetchPicture        leas      -$01,s              1-byte scratch frame
                    stb       ,s                  save resource number
                    ldd       >PicDirPage,pcr     data word
                    lbsr      SetLogicPage        map picture directory page
                    lda       ,s                  reload resource number
                    ldb       #$03                3 bytes per dir entry
                    mul                           D = offset into picDir
                    ldu       >PicDirPtr,pcr      data word
                    leau      d,u                 U = &picDir[resource]
                    bsr       CheckResPtr         validate entry
                    bne       FetchPictureRet     valid — return entry
                    leax      >StrPicture,pcr     picture
                    ldb       ,s                  reload resource number
                    bsr       ResNotFoundErr      report not-found error
FetchPictureRet     ldd       >PicDirPage,pcr     data word
                    leas      $01,s               release scratch frame
                    rts

FetchSound          leas      -$01,s              1-byte scratch frame
                    stb       ,s                  save resource number
                    ldd       >SndDirPage,pcr     data word
                    lbsr      SetLogicPage        map sound directory page
                    lda       ,s                  reload resource number
                    ldb       #$03                3 bytes per dir entry
                    mul                           D = offset into sndDir
                    ldu       >SndDirPtr,pcr      data word
                    leau      d,u                 U = &sndDir[resource]
                    lbsr      CheckResPtr         validate entry
                    bne       FetchSoundRet       valid — return entry
                    leax      >StrSoundName,pcr   sound
                    ldb       ,s                  reload resource number
                    bsr       ResNotFoundErr      report not-found error
FetchSoundRet       ldd       >SndDirPage,pcr     data word
                    leas      $01,s               release scratch frame
                    rts

ResNotFoundErr      leas      <-$64,s             make room on the stack
                    clra                          clear A for word index
                    pshs      b,a                 push resource number
                    pshs      x                   push resource-type string
                    leax      >StrResNotFound,pcr not found msg
                    leau      $04,s               U = output buffer
                    pshs      x                   push format string
                    pshs      u                   push output buffer
                    lbsr      PrintFmtStr         format "<type> N not found" message
                    leas      $08,s               pop all args
                    lbsr      message_box         show not-found dialog

                    lda       #$03                load offset to exit_agi()
                    sta       <SierraRemapOff     save offset
                    ldx       <SierraRemapVal     set up remap to sierra
                    jsr       >$0659              mmu twiddle

                    leas      <$64,s              clean up stack and leave
                    rts

SoundScratchBuf     fdb       $0000
                    fdb       $0000

GetStackFrame       leau      >GetStackFrame,pcr  U = our own address (U-stack anchor)
                    ldd       ,s                  load caller's return address from S-stack
                    pshu      s,b,a               push return addr + S-stack ptr onto U-stack
                    rts

RestoreStackFrame   leau      >SoundScratchBuf,pcr U = saved-frame buffer
                    pulu      s,b,a               pop saved return addr and S-stack ptr
                    std       ,s                  restore return address on S-stack
                    rts

StrNotNow           fcc       'Not now.'
StrNotNowEnd        fcb       C$NULL
F
cmd_show_obj_v
                    ldx       #$0432              resolve state.var[] addr
                    ldb       ,y+                 load variable index from bytecode
                    abx                           X = &state.var[idx]
                    ldb       ,x                  load b with data to be passed
                    bsr       obj_show            show object by variable value
                    rts


cmd_show_obj
                    ldb       ,y+                 load b with the data to be passed
                    bsr       obj_show            go do it to it at obj_show
                    rts


* obj_show(u16 view_num) passed a view_num to show
obj_show
                    leas      <-$36,s             make room on the stack
                    stb       $02,s               save our arg passed in
                    clra                          make a zero
                    sta       >ObjDisplayed       stow at obj_displayed
                    sta       $04,s               store on the stack too
                    sta       $03,s               store on the stack too
                    lbsr      view_find           view_find()

                    leax      ,x                  test X for null (view not loaded)
                    beq       ObjShowLoadView     not loaded — load it now
                    stx       $05,s               save view entry pointer
                    inc       $04,s               mark: view was pre-loaded
                    bra       ObjShowSetup        proceed to setup
ObjShowLoadView     lda       #$01                set free-space tracking
                    sta       >$05B8              enable tracking
                    clra                          clear A (no force-reload)
                    ldb       $02,s               reload view number
                    lbsr      view_load           load view resource
                    clr       >$05B8              disable tracking
                    stu       $05,s               save loaded view pointer
                    bne       ObjShowSetup        loaded OK — proceed
                    leau      >StrNotNow,pcr      not now msg
                    lbsr      message_box         show "not now" dialog
                    lbra      ObjShowDone         abort show
ObjShowSetup        ldd       <PsgCurLatch        save PSG latch state
                    std       <$34,s              stash for restore later
                    ldu       $05,s               U = view entry pointer
                    ldd       $05,u               load cel dimensions
                    leau      $07,s               U = local view arg block
                    std       $08,u               store cel dimensions in block
                    clra                          clear priority flags
                    sta       $0A,u               clear arg field
                    sta       $0E,u               clear arg field
                    ldb       $02,s               reload view number
                    lbsr      SetViewForObj       assign view resource to display slot
                    ldd       <$10,u              load view display position
                    std       <$12,u              save as draw position
                    lda       #$9F                compute center X: 159
                    suba      <$1C,u              subtract half-width
                    lsra                          / 2 = left edge
                    ldb       #$A7                Y center = 167
                    std       $03,u               store X/Y position
                    std       <$1A,u              also store as object position
                    lda       #$0F                priority = 15 (topmost)
                    sta       <$24,u              set object priority
                    lda       <$26,u              load object control flags
                    ora       #$04                set "fixed priority" bit
                    sta       <$26,u              update flags
                    lda       #$FF                invalid cel marker
                    sta       $02,u               force full redraw
                    ldd       <$1C,u              load sprite dimensions
                    mul                           D = pixel area
                    addd      #$000E              add header overhead
                    std       <$32,s              save required space
                    lbsr      UpdateFreeSpace     check available heap
                    cmpd      <$32,s              enough space for save?
                    bcs       ObjShowDisplay      yes — skip blit-save
                    inc       $03,s               mark: blit save was done
                    tfr       u,x                 X = view slot
                    lbsr      AllocViewEntry      allocate shadow save buffer
                    stu       ,s                  save allocated buffer pointer
                    pshs      u                   push buffer as arg
                    lda       #$15                blit_save
                    sta       <ShdwRemapOff       save offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    leau      $07,s               U = view arg block
                    pshs      u                   push as arg
                    lda       #$0C                obj_blit()
                    sta       <ShdwRemapOff       save offset
                    ldx       <ShdwRemapVal       set up remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up stack

                    leau      $07,s               U = screen args block
                    pshs      u                   push as arg
                    lda       #$1B                scrn blit-to-screen offset
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

ObjShowDisplay      ldu       $05,s               load view entry pointer
                    ldu       $03,u               pointer to view data in resource
                    ldb       $03,u               get cel width
                    lda       $04,u               get cel height
                    leau      d,u                 advance U past the pixel data
                    lbsr      message_box         display the object image as a dialog
                    lda       $03,s               was view pre-loaded?
                    beq       ObjShowRestore      no — skip blit-restore call

                    ldu       ,s                  load saved shadow pointer
                    pshs      u                   push as argument
                    lda       #$12                blit_restore() offset in shdw module
                    sta       <ShdwRemapOff       save the offset
                    ldx       <ShdwRemapVal       setup remap to shdw
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    leau      $07,s               load screen arguments pointer
                    pshs      u                   push as argument
                    lda       #$1B                blit function offset in scrn module
                    sta       <ScrnRemapOff       save  the index
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $02,s               clean up the stack

                    ldx       ,s                  reload view entry pointer
                    lda       $0C,x               get priority coordinate
                    ldu       $0A,x               get view data pointer
                    lbsr      CalcPriAddr         compute priority-line address
                    stu       <HeapPtr            restore heap pointer
                    stx       <HeapTop            restore heap top
ObjShowRestore      ldd       <$34,s              load saved logic page
                    lbsr      SetLogicPage        restore logic page mapping
                    lda       $04,s               was view pre-loaded?
                    bne       ObjShowDone         yes — leave resource in place
                    ldb       $02,s               view number to discard
                    lbsr      DiscardViewHelper   free view resource
ObjShowDone         lda       #$01                set "obj shown" flag
                    sta       >$05B1              update obj_displayed flag
                    leas      <$36,s              release frame
                    rts


SoundScratch9       fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
                    fcb       $00

SoundListPtr        fdb       $0000
SoundPIA1Ctrl       fcb       $00
SoundPIA2Ctrl       fcb       $00
SoundEnableReg      fcb       $00

NoteFreqTable       fcb       $07,$78
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

MonthDayTable       fcb       $00
                    fcb       $1F,$1C
                    fcb       $1F,$1E
                    fcb       $1F,$1E
                    fcb       $1F,$1F
                    fcb       $1E,$1F
                    fcb       $1E,$1F

SoundListClear      leau      >SoundScratch9,pcr  point to sound node anchor
                    ldd       #$0000              null link word
                    std       ,u                  clear first node pointer (empty list)
                    rts

SoundListFind       leau      >SoundScratch9,pcr  start at list head
SoundListFindLoop   stu       >SoundListPtr,pcr   save pointer to previous node
                    ldu       ,u                  follow next link
                    beq       SoundListFindRet    null — not found, return null in U
                    cmpb      $02,u               does this node's sound# match B?
                    bne       SoundListFindLoop   no — keep walking
SoundListFindRet    rts                           U = matching node (or null)

cmd_load_sound
                    ldb       ,y+                 get sound number from bytecode
                    bsr       LoadSoundData       load the sound resource
                    rts

LoadSoundData       leas      -$05,s              5-byte frame: [,s]=snd#, [1,s]=node, [3,s]=page
                    stb       ,s                  save sound number
                    bsr       SoundListFind       check if already loaded
                    cmpu      #$0000              found in list?
                    bne       LoadSoundRet        yes — already loaded, return it
                    ldd       <PsgCurLatch        save current logic page
                    std       $03,s               stash for restore after load
                    lbsr      BlitBothErase       erase sprites for heap ops
                    lda       #$03                script type: load-sound
                    ldb       ,s                  reload sound number
                    lbsr      PushScript          record in script buffer
                    leau      >SoundScratch9,pcr  point to list anchor
                    ldx       >SoundListPtr,pcr   X = insertion point (last node or anchor)
                    beq       LoadSoundAlloc      list was empty — just allocate
                    ldd       #$0009              9-byte node size
                    lbsr      AllocDataBlock      allocate node
                    stu       ,x                  link new node into list
                    ldd       #$0000              clear next link
                    std       ,u                  null-terminate list node
LoadSoundAlloc      ldb       ,s                  reload sound number
                    stb       $02,u               store sound number in node
                    stu       $01,s               save node pointer
                    lbsr      FetchSound          look up sound resource in sndDir
                    ldx       #$0000              no pre-allocated buffer
                    lbsr      OpenVolFile         open and read sound from volume file
                    beq       LoadSoundDone       no data — nothing to store
                    ldx       $01,s               reload node pointer
                    std       $05,x               save priority coords in node
                    stu       $03,x               save resource data pointer in node
                    std       $07,x               save coords again (backup)
LoadSoundDone       lbsr      EraseAndBlitShdw    redraw shadow after heap ops
                    ldd       $03,s               restore saved logic page
                    lbsr      SetLogicPage        restore logic page mapping
                    ldu       $01,s               return node pointer in U
LoadSoundRet        leas      $05,s               release frame
                    rts

* ====================================================================
* SOUND PLAYBACK
* cmd_sound loads a sound resource, builds a time packet (start time
* encoded as packed BCD), launches PlaySound which steps through the
* note sequence driving the SN76489 PSG on the Wildbits board (one
* channel, channel 0 of PSGM). After playback the elapsed game-time
* variables are updated. cmd_stop_sound silences the PSG and clears
* the playing-sound flag.
* ====================================================================
cmd_sound
                    leas      -$0B,s              11-byte frame: [,s]=snd#, [1,s]=node, [3,s]=page, [5,s..]=time packet
                    ldb       ,y+                 get sound number from bytecode
                    stb       ,s                  save sound number
                    lbsr      SoundListFind       find loaded sound node
                    cmpu      #$0000              found?
                    bne       SoundCheckFlags     yes — check if playback enabled
                    lda       #$09                error: sound not loaded
                    ldb       ,s                  reload sound number for error detail
SoundErrExit        lbsr      ReportError         report sound-not-loaded error
SoundCheckFlags     lda       >$01B0              load event/sound state flags
                    anda      #$40                sound-enabled bit set?
                    lbeq      SoundSetFlagDone    no — skip playback
                    lda       >$0173              is another sound playing?
                    lbne      SoundSetFlagDone    yes — skip
                    ldd       <PsgCurLatch        save current PSG latch state
                    std       $03,s               stash for restore
                    stu       $01,s               save sound node pointer
                    ldd       $05,u               load resource page for this sound
                    lbsr      SetLogicPage        map resource page

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

                    leax      $05,s               X = address of local time packet buffer
                    os9       F$Time
                    ldu       $01,s               restore sound node pointer
                    lbsr      PlaySound           play the sound, D = duration elapsed
                    cmpd      #$0000              any time elapsed?
                    lbeq      SoundSetFlagDone    no — skip time update
                    pshs      b,a                 save elapsed time (seconds:fractions)
                    addb      $0C,s               add elapsed seconds to current seconds
                    bcc       TimeSecCarry        no overflow — skip carry
                    inca                          carry into minutes high byte
TimeSecCarry        ldu       #$003C              divisor 60 for seconds→minutes
                    lbsr      UIntDivide          D = minutes carry, B = remaining seconds
                    stb       $0C,s               store new seconds value
                    tfr       u,d                 D = carry minutes (quotient)
                    cmpd      #$0000              any minute carry?
                    beq       TimeSetSys          no — write time and done
                    addb      $0B,s               add carry to current minutes
                    bcc       TimeMinCarry        no overflow — skip carry
                    inca                          carry into hours high byte
TimeMinCarry        ldu       #$003C              divisor 60 for minutes→hours
                    lbsr      UIntDivide          D = hours carry, B = remaining minutes
                    stb       $0B,s               store new minutes value
                    tfr       u,d                 D = carry hours
                    tstb                          any hour carry?
                    beq       TimeSetSys          no — write time and done
                    addb      $0A,s               add carry to current hours
                    lda       #$17                divisor 23 for hours→days
                    lbsr      Div8                B = remaining hours, A = carry days
                    sta       $0A,s               store new hours value
                    tstb                          any day carry?
                    beq       TimeSetSys          no — write time and done
                    inc       $09,s               increment day-of-month
                    ldd       $08,s               D.A = month, D.B = year
                    leax      >MonthDayTable,pcr  13 byte data table
                    cmpb      a,x                 current day <= days-in-month?
                    bls       TimeSetSys          yes — no month rollover
                    ldb       a,x                 B = days in current month
                    cmpa      #$02                is it February?
                    bne       TimeDayIncr         no — roll to next month
                    ldb       $07,s               load year value
                    beq       TimeDayIncr         year = 0 — not a leap year
                    bitb      #$03                year divisible by 4?
                    bne       TimeDayIncr         no — not a leap year
                    ldb       $09,s               load current day
                    cmpb      #$1D                is it day 29?
                    beq       TimeSetSys          yes — Feb 29 is valid (leap year)
TimeDayIncr         ldb       #$01                reset day to 1st of next month
                    stb       $09,s               store day = 1
                    inca                          increment month
                    cmpa      #$0C                past December (12)?
                    bls       TimeMonthAdv        no — store updated month
                    stb       $08,s               yes — month = 1 (January)
                    inc       $07,s               increment year
                    bra       TimeSetSys          write updated time
TimeMonthAdv        sta       $08,s               store updated month number

* Set time - sets the system time and date
* entry:
*       x -> relative address of the time packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

TimeSetSys          leax      $07,s               X = time packet within stack frame
                    os9       F$STime
                    puls      b,a                 restore elapsed time (seconds:fractions)
                    addb      >$043D              add elapsed to saved-game second counter
                    bcc       TimeSec2Carry       no overflow — skip carry
                    inca                          carry into minute counter
TimeSec2Carry       ldu       #$003C              divisor 60
                    lbsr      UIntDivide          D = carry minutes, B = remaining seconds
                    stb       >$043D              update saved-game seconds
                    tfr       u,d                 D = carry minutes
                    cmpd      #$0000              any minute carry?
                    beq       TimeRestorePage     no — done with game clock
                    addb      >$043E              add carry to saved-game minutes
                    bcc       TimeMin2Carry       no overflow — skip carry
                    inca                          carry into hours
TimeMin2Carry       ldu       #$003C              divisor 60
                    lbsr      UIntDivide          D = carry hours, B = remaining minutes
                    stb       >$043E              update saved-game minutes
                    tfr       u,d                 D = carry hours
                    tstb                          any hour carry?
                    beq       TimeRestorePage     no — done
                    addb      >$043F              add carry to saved-game hours
                    lda       #$17                divisor 23 for hours→days
                    lbsr      Div8                B = remaining hours, A = carry days
                    sta       >$043F              update saved-game hours
                    tstb                          any day carry?
                    beq       TimeRestorePage     no — done
                    inc       >$0440              increment saved-game day counter
TimeRestorePage     ldd       $03,s               reload saved logic page
                    lbsr      SetLogicPage        restore logic page mapping
SoundSetFlagDone    lda       ,y+                 read flag number from bytecode
                    lbsr      SetFlag             set the completion flag
                    leas      $0B,s               release sound stack frame
                    rts

PlaySound           pshs      y                   save Y (note duration counter)
                    clrb                          B=0 (initial note index)
                    ldu       $03,u               point U to note data in resource
                    bsr       SoundPIASave        save PIA state and silence output
PlaySoundLoop       ldb       ,u+                 fetch next note byte
                    cmpb      #$FF                end-of-sequence marker?
                    beq       PlaySoundEnd        yes — done
                    lslb                          ×2 (each freq table entry is 2 bytes)

                    nop
*         lda   ,u+
*         sta   >$FF20
                    jsr       fxsnd1,pcr          send note byte to sound hardware

                    ldy       ,u++                load duration word (advance U past it)
                    leax      >NoteFreqTable,pcr  freq table base address
                    abx                           index to entry for this note
                    ldd       ,x                  load delay parameter for half-period
                    std       <DelayParam         save for inner delay loops
                    leax      >$007A,x            advance to second half of table entry
                    ldd       ,x                  load cycle count
                    std       <DelayParamX        save outer loop count

*         tst   >$FF20
                    tst       -3,u                test note control byte (high/low select)
                    nop

                    beq       PlaySoundWaveLow    zero = low note path
PlaySoundWaveHigh   ldx       <DelayParamX        outer loop count
PlaySoundHighLoop   ldd       <DelayParam         load half-period delay
PlaySoundHighDelay  subd      #$0001              count down delay
                    bne       PlaySoundHighDelay  busy wait

*         com   >$FF20
*         leax  -$01,x
                    jsr       fxsnd2,pcr          toggle output and decrement X
                    nop

                    bne       PlaySoundHighLoop   inner cycle not done
                    leay      -$01,y              decrement duration counter
                    bne       PlaySoundWaveHigh   still playing this note
                    bra       PlaySoundLoop       next note
PlaySoundWaveLow    ldx       <DelayParamX        outer loop count
PlaySoundLowLoop    ldd       <DelayParam         load half-period delay
PlaySoundLowDelay   subd      #$0001              count down delay
                    bne       PlaySoundLowDelay   busy wait
                    tst       >$FF20              toggle output via read
                    leax      -$01,x              decrement outer count
                    bne       PlaySoundLowLoop    inner cycle not done
                    leay      -$01,y              decrement duration counter
                    bne       PlaySoundWaveLow    still playing this note
                    bra       PlaySoundLoop       next note
PlaySoundEnd        bsr       SoundPIARestore     restore PIA state
                    ldd       ,u                  pick up return value after note data
                    puls      y                   restore Y
                    rts

*        read keyboard & joystick pias
SoundPIASave        jsr       fxsnd3,pcr          disable interrupts, silence output
                    nop
*         orcc  #IntMasks         $50
*         clr   >$FF20
                    lda       >$FF01              read PIA1 control register
                    sta       >SoundPIA1Ctrl,pcr  save it for restore
                    anda      #$F7                clear sound-enable bit
                    sta       >$FF01              write back (disable PIA1 sound)
                    lda       >$FF03              read PIA2 control register
                    sta       >SoundPIA2Ctrl,pcr  save it for restore
                    anda      #$F7                clear sound-enable bit
                    sta       >$FF03              write back (disable PIA2 sound)
                    lda       >$FF23              read sound-enable register
                    sta       >SoundEnableReg,pcr save it for restore
                    ora       #$08                set sound-enable bit
                    sta       >$FF23              enable hardware sound
                    rts

SoundPIARestore     lda       >SoundPIA1Ctrl,pcr  saved PIA1 control
                    sta       >$FF01              restore PIA1 control register
                    lda       >SoundPIA2Ctrl,pcr  saved PIA2 control
                    sta       >$FF03              restore PIA2 control register
                    lda       >SoundEnableReg,pcr saved sound-enable value
                    sta       >$FF23              restore sound-enable register
*         clr   >$FF20
*         lda   >$FF02
                    jsr       fxsnd4,pcr          re-enable interrupts, clear output
                    nop
                    nop
                    lda       >$FF22              read GIME interrupt register (clear pending)
                    andcc     #^IntMasks          re-enable CPU interrupts
                    rts

StrNothing          fcc       'nothing'
                    fcb       C$NULL

StrYouAreCarrying   fcc       'You are carrying:'
                    fcb       C$NULL

StrEnterToSelect    fcc       'ENTER to select / CTRL-BREAK to cancel'
                    fcb       C$NULL

StrPressKeyReturn   fcc       'Press a key to return to the game'
                    fcb       C$NULL

StrScoreFmt         fcc       'Score:%d of %d  '
                    fcb       C$NULL

StrSoundFmt         fcc       'Sound: %s'
                    fcb       C$NULL,C$NULL,C$NULL,C$NULL

StrOn               fcc       'on '
                    fcb       C$NULL

StrOff              fcc       'off'
                    fcb       C$NULL

* ====================================================================
* STATUS LINE AND INVENTORY SCREEN
* cmd_status displays a full-screen overlay showing the current score,
* sound state, and the player's inventory. Items are laid out in a
* scrollable list; the player navigates with arrow keys and confirms
* with ENTER. cmd_status_line_on/off toggle the one-line HUD at the
* top of the screen that shows score and sound status.
* ====================================================================
cmd_status
                    lbsr      InputEditOn         input_edit_on
                    lbsr      PushTextColor       save text color before status screen
                    clra                          foreground = 0 (black)
                    ldb       #$0F                background = 15 (white)
                    lbsr      text_color          set colors for status display
CmdStatusTextMode   lbsr      cmd_text_screen     switch to text mode
                    bsr       InventoryDraw       draw inventory screen
                    lbsr      PopTextColor        restore text color
                    lbsr      SetGraphicsMode     return to graphics mode
                    rts

InventoryDraw       leas      >-$0105,s           allocate 261-byte frame (item list)
                    lda       #$02                initial display column (even = left col)
                    sta       ,s                  save initial column value in frame
InventoryDrawInit   leax      $04,s               point X to item list buffer
                    stx       $02,s               save list base pointer
                    stx       >$00FE,s            save selected-item pointer (default = first)
                    ldu       <BlockPtr           point to game object table
                    clra                          A = object index, start at 0
                    sta       $01,s               item count = 0
InventoryItemLoop   sta       >$0100,s            save current object index
                    stu       >$0101,s            save object pointer
                    cmpu      <BlockSizeLimit     past end of object table?
                    bcc       InventoryCheckEmpty yes — done scanning
                    ldb       $02,u               get object's room number
                    cmpb      #$FF                $FF = in player's inventory?
                    bne       InventoryItemAdvance no — skip this object
                    sta       ,x                  store object index in list entry
                    cmpa      >$044B              is this the currently selected item?
                    bne       InventoryItemSetup  no — fill entry normally
                    stx       >$00FE,s            yes — save as selected pointer
InventoryItemSetup  ldd       ,u                  load object name pointer
                    std       $01,x               store in list entry
                    lda       ,s                  current column (0=left, 1=right)
                    sta       $03,x               save column in entry
                    ldb       $01,s               get item count
                    bitb      #$01                odd count? (right column)
                    bne       InventoryItemFormat yes — calculate padding
                    lda       #$01                left column — next item goes right
                    sta       $04,x               store column flag
                    bra       InventoryItemNext   advance to next object
InventoryItemFormat inca                          increment column counter
                    sta       ,s                  save updated column state
                    stx       $02,s               save current entry pointer
                    ldx       $01,x               load name string pointer
                    lbsr      StrLen              get string length in B
                    ldx       $02,s               restore entry pointer
                    negb                          negate length
                    addb      #$27                add 39 to get right-column padding
                    stb       $04,x               store padding amount
                    ldb       $01,s               reload item count
InventoryItemNext   incb                          increment item count
                    stb       $01,s               save updated count
                    leax      $05,x               advance list pointer (5 bytes per entry)
InventoryItemAdvance leau     $03,u               advance to next object (3 bytes/object)
                    lda       >$0100,s            reload object index
                    inca                          increment index
                    bra       InventoryItemLoop   check next object
InventoryCheckEmpty lda       $01,s               any items found?
                    bne       InventoryDisplayItems yes — show the list
                    sta       ,x                  zero-terminate list
                    leau      >StrNothing,pcr     nothing string
                    stu       $01,x               store "nothing" as first item
                    lda       ,s                  column
                    sta       $03,x               save in entry
                    lda       #$10                padding for centering
                    sta       $04,x               store padding
                    leax      $05,x               advance past the entry
InventoryDisplayItems leax    -$05,x              back up to last valid entry
                    stx       >$0103,s            save end-of-list pointer
                    pshs      x                   push end pointer
                    leax      $06,s               point to list buffer
                    pshs      x                   push start pointer
                    ldx       >$0102,s            load selected item pointer
                    stx       $06,s               save on stack
                    pshs      x                   push selected pointer
                    lbsr      InventoryListDraw   draw the item list
                    leas      $06,s               clean up 3 pushed args
InventoryWaitKey    lbsr      WaitForEvent        wait for key or joystick event
                    lda       >$01B0              check event flags
                    anda      #$04                isolate input-available bit
                    beq       InventoryExit       no input — exit
                    ldd       ,x                  load event type and value
                    cmpa      #$01                is it a keyboard event?
                    bne       InventoryCheckJoy   no — check joystick
                    cmpb      #$0D                is it Enter (select)?
                    bne       InventoryCheckEsc   no — check Escape
                    ldx       $02,s               load selected item pointer
                    lda       ,x                  get selected object index
                    sta       >$044B              store as selected inventory item
                    bra       InventoryExit       close inventory screen
InventoryCheckEsc   cmpb      #$1B                is it Escape (cancel)?
                    bne       InventoryWaitKey    no — ignore, keep waiting
                    lda       #$FF                $FF = no selection
                    sta       >$044B              clear selected item ($FF = none)
                    bra       InventoryExit       close inventory screen
InventoryCheckJoy   cmpa      #$02                is it a joystick event?
                    bne       InventoryWaitKey    no — ignore
                    leax      $04,s               point to cursor state
                    pshs      x                   push cursor pointer
                    pshs      b,a                 push event data
                    ldd       $06,s               load current list start
                    pshs      b,a                 push start
                    ldd       >$0109,s            load list end pointer
                    pshs      b,a                 push end
                    lbsr      InventoryMoveCursor move highlight based on joy
                    leas      $08,s               clean up args
                    stx       $02,s               save updated selection pointer
                    bra       InventoryWaitKey    wait for next event
InventoryExit       clra                          clear selection-active flag
                    sta       >ExtTableFlag       clear extended table lookup flag
                    sta       >$0547              clear joystick button state
                    leas      >$0105,s            release frame
                    rts


InventoryListDraw   leas      -$04,s              allocate 4 bytes of local storage
                    lda       #$00                row 0
                    ldb       #$0B                column 11
                    std       <TextRow            position cursor for heading
                    leau      >StrYouAreCarrying,pcr you are carrying string
                    pshs      u                   push string address
                    lbsr      PrintFmtStrToScr    print "You are carrying:" header
                    leas      $02,s               pop string arg
                    ldx       $08,s               X = pointer to first item node
InventoryListLoop   stx       ,s                  save current item pointer
                    cmpx      $0A,s               past end of list?
                    bhi       InventoryListDone   yes — done drawing items
                    ldd       $03,x               load item's screen row/col
                    std       <TextRow            position cursor for this item
                    clra                          default fg = 0
                    ldb       #$0F                default bg = 15 (normal)
                    std       $02,s               save colors
                    cmpx      $06,s               is this the selected item?
                    bne       InventoryListHighlight no — use default color
                    lda       >$01B0              load controller flags
                    anda      #$04                joystick button held?
                    beq       InventoryListHighlight no — keep default
                    lda       #$0F                highlight fg = 15
                    clrb                          highlight bg = 0
                    std       $02,s               store inverted colors
InventoryListHighlight ldd    $02,s               load fg/bg colors
                    lbsr      text_color          set text color
                    ldx       ,s                  restore current item pointer
                    ldx       $01,x               load item name string pointer
                    pshs      x                   push name for print
                    lbsr      PrintFmtStrToScr    print item name
                    leas      $02,s               pop name arg
                    ldx       ,s                  restore item pointer
                    leax      $05,x               advance to next item node (5 bytes each)
                    bra       InventoryListLoop   continue drawing
InventoryListDone   clra                          reset fg = 0
                    ldb       #$0F                reset bg = 15 (normal)
                    lbsr      text_color          restore default text color
                    lda       >$01B0              load controller flags
                    anda      #$04                joystick button held?
                    beq       InventoryListFooter no — show plain footer
                    lda       #$01                enable extended table lookup
                    sta       >ExtTableFlag       flag for extended table lookup
                    lda       #$03                joystick button state
                    sta       >$0547              store joystick state
                    lda       #$17                row 23 (bottom)
                    ldb       #$01                column 1
                    std       <TextRow            position footer cursor
                    leax      >StrEnterToSelect,pcr Enter to select string
                    bra       InventoryListFooterPrint print selection prompt
InventoryListFooter lda       #$17                row 23 (bottom)
                    ldb       #$04                column 4
                    std       <TextRow            position footer cursor
                    leax      >StrPressKeyReturn,pcr press a key to return to the game
InventoryListFooterPrint pshs x                   push footer string
                    lbsr      PrintFmtStrToScr    print footer message
                    leas      $02,s               pop string arg
                    leas      $04,s               release local storage
                    rts

InventoryMoveCursor ldu       $04,s               U = current selection pointer
                    tfr       u,x                 X = candidate new selection
                    lda       $07,s               load movement direction
                    cmpa      #$01                up?
                    bne       InventoryMoveDown   no — check down
                    leax      -$0A,x              up = back 2 items (10 bytes)
                    bra       InventoryMoveCheck  validate new position
InventoryMoveDown   cmpa      #$03                down?
                    bne       InventoryMovePageDown no — check page-down
                    leax      $05,x               down = forward 1 item (5 bytes)
                    bra       InventoryMoveCheck  validate new position
InventoryMovePageDown cmpa    #$05                page-down?
                    bne       InventoryMovePageUp no — check page-up
                    leax      $0A,x               page-down = forward 2 items (10 bytes)
                    bra       InventoryMoveCheck  validate new position
InventoryMovePageUp cmpa      #$07                page-up?
                    bne       InventoryMoveRet    no — unknown direction, return
                    leax      -$05,x              page-up = back 1 item (5 bytes)
InventoryMoveCheck  cmpx      $08,s               below start of list?
                    bcs       InventoryMoveClamp  yes — clamp to current
                    cmpx      $02,s               beyond end of list?
                    bls       InventoryMoveSwap   no — swap highlights
InventoryMoveClamp  tfr       u,x                 invalid position — restore old selection
                    bra       InventoryMoveRet    return unchanged
InventoryMoveSwap   pshs      x                   push new selection pointer
                    pshs      u                   push old selection pointer
                    lbsr      InventorySwapHighlight redraw both items with new highlight
                    leas      $04,s               pop both args
InventoryMoveRet    rts

InventorySwapHighlight lda    #$0F                inverted: fg = 15
                    clrb                          inverted: bg = 0
                    lbsr      text_color          set inverted (highlight) color
                    ldu       $04,s               U = previously selected item
                    ldd       $03,u               load old item's row/col
                    std       <TextRow            position at old item
                    ldd       $01,u               load old item's name pointer
                    pshs      b,a                 push name pointer
                    lbsr      PrintFmtStrToScr    redraw old item highlighted (deselect)
                    leas      $02,s               pop name arg
                    clra                          normal: fg = 0
                    ldb       #$0F                normal: bg = 15
                    lbsr      text_color          restore normal color
                    ldu       $02,s               U = newly selected item
                    ldd       $03,u               load new item's row/col
                    std       <TextRow            position at new item
                    ldd       $01,u               load new item's name pointer
                    pshs      b,a                 push name pointer
                    lbsr      PrintFmtStrToScr    redraw new item in normal (selected) color
                    leas      $02,s               pop name arg
                    ldx       $04,s               return new selection pointer in X
                    rts

StatusLineWrite     lda       >StatusState        load status-line enabled flag
                    beq       StatusLineWriteRet  disabled — do nothing
                    lbsr      PushRowCol          save current cursor position
                    lbsr      PushTextColor       save current text color
                    lda       >$0248              load status bar row number
                    ldb       #$0F                white color
                    lbsr      ClearTextLine       erase the status line
                    clra                          black background
                    ldb       #$0F                white foreground
                    lbsr      text_color          set text colors
                    lda       >$0248              status bar row
                    ldb       #$01                column 1
                    std       <TextRow            set cursor to status bar position
                    clra                          high byte of score
                    ldb       >$0439              current score value
                    pshs      b,a                 push score
                    ldb       >$0435              maximum score
                    leax      >StrScoreFmt,pcr    Score string
                    pshs      b,a                 push max score
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print "Score: N of M"
                    leas      $06,s               clean up 3 args
                    ldb       #$1E                column 30 (right side of status bar)
                    stb       <TextCol            position cursor at column 30
                    leau      >StrOff,pcr         default to "off" label
                    lda       >$01B0              check event/sound flags
                    anda      #$40                test sound-enabled bit
                    beq       StatusLineSoundLabel bit clear — sound off
                    lda       >$0173              check sound-busy flag
                    bne       StatusLineSoundLabel busy — show "off"
                    leau      >StrOn,pcr          sound is on and idle
StatusLineSoundLabel leax     >StrSoundFmt,pcr    Sound
                    pshs      u                   push on/off string
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print "Sound: on/off"
                    leas      $04,s               clean up 2 args
                    lbsr      PopTextColor        restore text color
                    lbsr      PopRowCol           restore cursor position
StatusLineWriteRet  rts

cmd_status_line_on
                    lda       #$01                enable status line
                    sta       >StatusState        state.status_state = 1
                    bsr       StatusLineWrite     status_line_write()
                    rts

cmd_status_line_off
                    clr       >StatusState        state.status_state = 0
                    lda       >$0248              state.status_line_row ??
                    clrb                          column 0
                    lbsr      ClearTextLine       erase the status bar
                    rts

* Junk filler string ?
StrPunctuation      fcc       / .,;:'!-/
                    fcb       C$NULL


cmd_get_string
                    leas      >-$0197,s           allocate large local frame
                    lda       >$05B9              save cursor-blink active flag
                    sta       ,s                  store in frame
                    lbsr      PushRowCol          save cursor position
                    lbsr      InputEditOn         input_edit_on
                    lda       ,y+                 read string slot index from script
                    ldb       #$28                40 bytes per string slot
                    mul                           D = slot index × 40
                    ldx       #StringTable        base of state.string table
                    leax      d,x                 X = destination string buffer
                    stx       $01,s               save destination pointer
                    lda       ,y+                 read message number for prompt
                    sta       $05,s               save message number
GetStringReadArgs   ldd       ,y++                read row/col from script
                    std       $03,s               save row/col in frame
                    lda       ,y+                 read max-length argument
                    inca                          +1 for null terminator
                    cmpa      #$28                exceeds 40 chars?
                    bls       GetStringMaxLen     no — use as-is
                    lda       #$28                clamp to 40
GetStringMaxLen     sta       >$0196,s            store max length in frame
                    clr       ,x                  pre-clear destination buffer
                    ldd       $03,s               reload row/col
                    cmpa      #$18                row >= 24 (off-screen)?
GetStringCheckRow   bcc       GetStringShowMsg    yes — skip positioning
                    std       <TextRow            position cursor at specified row/col
GetStringShowMsg    ldb       $05,s               load prompt message number
                    lbsr      GetMsgPtr           look up message text pointer (→ U)
                    leax      $06,s               X = local text buffer in frame
                    ldd       #$0028              max 40 chars
                    pshs      b,a                 push max length
                    pshs      u                   push message pointer
                    pshs      x                   push destination buffer
                    lbsr      MsgTextSetup        copy/format message into buffer
                    leas      $06,s               pop three args
                    pshs      x                   push formatted prompt buffer
                    lbsr      PrintFmtStrToScr    display prompt text
                    leas      $02,s               pop prompt arg
                    ldb       >$0196,s            load max input length
                    ldx       $01,s               load destination string buffer
                    bsr       EditString          run interactive string editor
                    lbsr      PopRowCol           restore saved cursor position
                    lda       ,s                  load saved cursor-blink flag
                    beq       GetStringDone       was off — skip re-enabling blink
                    lbsr      InputCursorBlink    re-enable cursor blink
GetStringDone       leas      >$0197,s            release local frame
                    rts

cmd_set_string
                    lda       ,y+                 read destination string slot index
                    ldb       #$28                40 bytes per string slot
                    mul                           D = slot index × 40
                    ldx       #StringTable        state.string
                    leax      d,x                 X = destination buffer
                    ldb       ,y+                 read source message number
                    lbsr      GetMsgPtr           look up message pointer (→ U)
                    exg       u,x                 swap: X = source message, U = destination
                    ldd       #$0028              number of bytes to copy (40)
                    lbsr      MemCopyNull         copy routine
                    rts

cmd_word_to_string
                    lda       ,y+                 read destination string slot index
                    ldb       #$28                40 bytes per string slot
                    mul                           D = slot index × 40
                    ldu       #StringTable        state.string
                    leau      d,u                 U = destination string buffer
                    ldb       ,y+                 read source word table index
                    lslb                          × 2 (word table entries are 2 bytes)
                    ldx       #$0181              base of word recognition table
                    ldx       b,x                 X = pointer to recognized word string
                    ldd       #$0028              number of bytes to copy
                    lbsr      MemCopyNull         copy routine
                    rts

EditString          leas      <-$2F,s             allocate 47-byte local frame
                    stx       ,s                  save destination string pointer
                    cmpb      #$28                max length > 40?
                    bls       EditStringInit      no — use as given
                    ldb       #$28                clamp max length to 40
EditStringInit      leax      $06,s               X = start of local edit buffer
                    abx                           advance X by max length
                    stx       $04,s               save buffer end pointer
                    clra                          set up for MemCopyNull
                    ldx       ,s                  from: destination string (existing content)
                    leau      $07,s               to: local edit buffer
                    lbsr      MemCopyNull         copy existing string into edit buffer
                    lbsr      StrLen              measure copied string
                    beq       EditStringCalcPos   empty — skip printing existing text
                    pshs      x                   push edit buffer for print
                    lbsr      PrintFmtStrToScr    display existing string content
                    leas      $02,s               pop print arg
                    leax      $07,s               X = start of edit buffer
                    lbsr      StrLen              measure string length again
EditStringCalcPos   abx                           X = pointer to end of string (insert point)
                    stx       $02,s               save current cursor position
                    lbsr      InputCursorBlink    show cursor at insert point
EditStringWait      lbsr      WaitKeyNonNull      wait for a keypress
                    sta       $06,s               save key code
                    lbsr      InputEditOn         input_edit_on
                    lda       $06,s               reload key code
                    cmpa      #$08                backspace?
                    bne       EditStringCtrlC     no — check Ctrl-C
EditStringBackspace leau      $07,s               U = start of edit buffer
                    cmpu      $02,s               already at start?
                    bcc       EditStringContinue  yes — nothing to delete
                    ldu       $02,s               U = current insert point
                    leau      -$01,u              back up one character
                    stu       $02,s               update insert pointer
                    lbsr      PutCharToWindow     erase character on screen
                    lda       #$08                backspace char
                    cmpa      $06,s               was key already backspace?
                    beq       EditStringContinue  yes — single delete done
                    bra       EditStringBackspace no — keep deleting (Ctrl-C clears all)
EditStringCtrlC     cmpa      #$03                Ctrl-C?
                    bne       EditStringEnter     no — check Enter
                    lda       #$08                convert to backspace loop
                    bra       EditStringBackspace delete all characters
EditStringEnter     cmpa      #$0D                Enter?
                    bne       EditStringEsc       no — check Escape
                    ldu       $02,s               U = end of edited string
                    clr       ,u                  null-terminate the edit buffer
                    leax      $07,s               X = edit buffer source
                    ldu       ,s                  U = destination string
                    lbsr      StrCopy             copy edit buffer → destination
                    bra       EditStringDone      done
EditStringEsc       cmpa      #$1B                Escape? (cancel without saving)
                    beq       EditStringDone      yes — exit without copying
                    ldu       $02,s               U = current insert point
                    cmpu      $04,s               at buffer end (max length)?
                    bcc       EditStringContinue  yes — discard character
                    sta       ,u+                 store character in buffer
                    stu       $02,s               advance insert pointer
                    lbsr      PutCharToWindow     echo character to screen
EditStringContinue  lbsr      InputCursorBlink    show cursor
                    bra       EditStringWait      wait for next key
EditStringDone      lda       $06,s               load key that ended editing (Enter/Esc)
                    leas      <$2F,s              release local frame
                    rts

cmd_set_game_id
                    ldb       ,y+                 read message number from bytecode
                    lbsr      GetMsgPtr           look up message text pointer (→ U)
                    tfr       u,x                 x is from address
                    ldu       #$01CF              destination address
                    ldd       #$0007              number of bytes to copy  ID_SIZE ??? is 20
                    lbsr      MemCopyNull         copy routine
                    rts

MatchWord           leas      <-$53,s             allocate 83-byte local frame (two 40-char norm buffers + spare)
                    stb       ,s                  save string slot index
                    leau      $01,s               U = first normalize buffer
                    bsr       NormWord            normalize slot B → buffer at U
                    lda       ,s                  reload string slot index
                    leau      <$2A,s              U = second normalize buffer (42 bytes in)
                    bsr       NormWord            normalize slot A → second buffer
                    leau      $01,s               U = start of first normalized string
                    leax      <$2A,s              X = start of second normalized string
MatchWordLoop       lda       ,u+                 load next char from first string
                    beq       MatchWordFound      null → first string exhausted, match so far
                    cmpa      ,x+                 compare with second string char
                    beq       MatchWordLoop       match — continue
                    bra       MatchWordNoMatch    mismatch — words differ
MatchWordFound      lda       #$01                match result = true
                    ldb       ,x                  load word-group ID at match position
                    beq       MatchWordRet        group ID is 0 — skip (wildcard/junk)
MatchWordNoMatch    clra                          match result = false (or group 0)
MatchWordRet        leas      <$53,s              release local frame
                    rts

NormWord            leas      -$02,s              save 2 bytes
                    stu       ,s                  save output buffer pointer
                    ldb       #$28                40 bytes per string slot
                    mul                           D = slot index × 40
                    ldu       #StringTable        base of state.string table
                    leau      d,u                 U = source string for this slot
NormWordLoop        lda       ,u+                 load next source character
                    beq       NormWordNull        null terminator — done
                    leax      >StrPunctuation,pcr punc string
                    lbsr      FindByte            is it punctuation?
                    bne       NormWordLoop        yes — skip punctuation
                    lbsr      ToLower             single char upper to lower case conversion
                    ldx       ,s                  X = current output position
                    sta       ,x+                 store normalized character
                    stx       ,s                  advance output pointer
                    bra       NormWordLoop        continue
NormWordNull        ldx       ,s                  X = end of output
                    clr       ,x                  null-terminate normalized string
                    leas      $02,s               release saved pointer
                    rts

cmd_hide_mouse
                    lda       ,y+                 read and discard arg 1 (stub)
                    lda       ,y+                 read and discard arg 2 (stub)

cmd_set_upper_left
cmd_allow_menu
                    lda       ,y+                 read and discard arg (stub)

cmd_shake_screen
cmd_log
                    lda       ,y+                 read and discard arg (stub)


cmd_do_nothing
cmd_stop_sound
cmd_init_disk
cmd_open_dialogue
cmd_close_dialogue
cmd_hold_key
cmd_set_pri_base
cmd_discard_sound
NoopCmdsRet         rts

StrTraceSep         fcc       '=========================='
                    fcb       C$NULL

StrTraceNumNum      fcc       '%d: %d'
                    fcb       C$NULL

StrTraceNumStr      fcc       '%d: %s'
                    fcb       C$NULL

StrTraceColon       fcc       ' :%c'
                    fcb       C$NULL

StrTraceNum         fcc       '%d'
                    fcb       C$NULL

StrReturn           fcc       'return'
                    fcb       C$NULL

TraceArgMode        fcb       $00
TraceLineOff        fcb       $01
TraceNumLines       fcb       $0F
TraceWinHeight      fcb       $00
TraceWinBg          fcb       $00
TraceWinCol         fcb       $00
TraceWinWidth       fcb       $00
TraceWinPixH        fcb       $00
TraceWinLastCol     fcb       $00
TraceTopRow         fcb       $00
TraceBottomRow      fcb       $00

cmd_trace_on
                    lda       <NegCondFlag        load trace-enable flag
                    beq       TraceOnRet          already enabled — skip init
                    bsr       TraceInit           initialize trace window
TraceOnRet          rts

TraceInit           lda       <NegCondFlag        load trace-enable flag
TraceInitCheck      bne       TraceInitRet        non-zero = trace active, skip init
                    lda       >$01B0              read event/state flags
                    anda      #$20                test trace-capability bit
                    lda       #$01                set trace enabled
                    sta       <NegCondFlag        activate trace mode
                    lda       >$0242              load base row number
                    inca                          +1 to get trace top row
                    adda      >TraceLineOff,pcr   add trace-line offset
                    sta       >TraceTopRow,pcr    store top row of trace window
                    adda      >TraceNumLines,pcr  add number of trace lines
                    deca                          -1 to get last row index
                    sta       >TraceBottomRow,pcr store bottom row of trace window
                    lda       #$02                starting column = 2
                    sta       >TraceWinCol,pcr    store trace window left column
                    adda      #$23                column + 35 = right edge
                    sta       >TraceWinLastCol,pcr store trace window right column
                    lda       >TraceWinCol,pcr    reload left column
                    ldb       #$04                4 pixels per text column
                    mul                           D = pixel column position
                    subb      #$05                subtract 5 pixel margin
                    stb       >TraceWinWidth,pcr  store trace window pixel width
                    lda       >TraceBottomRow,pcr reload bottom row
                    ldb       #$08                8 pixels per text row
                    mul                           D = pixel row position
                    addb      #$05                add 5 pixel margin
                    stb       >TraceWinPixH,pcr   store trace window pixel height
                    lda       >TraceNumLines,pcr  number of trace lines
                    ldb       #$08                8 pixels per row
                    mul                           D = total pixel height
                    addb      #$0A                add 10 pixel padding
                    stb       >TraceWinHeight,pcr store trace window total height
                    ldb       #$9A                background color attribute
                    stb       >TraceWinBg,pcr     set trace window background color

                    ldd       #$040F              window draw parameters
                    pshs      d                   push height/color args
                    ldd       >TraceWinHeight,pcr trace window height
                    pshs      d                   push height
                    ldd       >TraceWinWidth,pcr  trace window width
                    pshs      d                   push width
                    lda       #$0C                remap offset for scrn module
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $06,s               clean up the stack

TraceInitRet        rts

cmd_trace_info
                    lda       ,y+                 read first arg (row offset base)
                    lda       ,y+                 read line-offset value
                    sta       >TraceLineOff,pcr   store trace line offset
                    lda       ,y+                 read requested number of lines
                    cmpa      #$02                more than 2 lines?
                    bcc       TraceInfoSetLines   no — use as given
                    lda       #$02                clamp to 2 lines maximum
TraceInfoSetLines   sta       >TraceNumLines,pcr  store trace line count
                    rts

TraceErase          lda       <NegCondFlag        trace window active?
                    beq       TraceEraseRet       no — nothing to erase
                    clr       <NegCondFlag        deactivate trace mode

                    ldd       >TraceWinHeight,pcr trace window height
                    pshs      d                   push height
                    ldd       >TraceWinWidth,pcr  trace window width
                    pshs      d                   push width
                    lda       #$03                remap offset for erase operation
                    sta       <ScrnRemapOff       save the offset
                    ldx       <ScrnRemapVal       set up remap to scrn
                    jsr       >$0659              mmu twiddler
                    leas      $04,s               clean up the stack

TraceEraseRet       rts

ScriptDispatch      leas      -$02,s              allocate 2-byte local frame
                    stb       $01,s               save bytecode opcode
                    clr       >TraceArgMode,pcr   clear trace argument mode flag
                    leax      >CmdTableStart,pcr  big jump table address
                    ldd       #$FFFF              end-of-table sentinel
                    pshs      d                   push sentinel
                    ldd       #$0000              initial index
                    pshs      d                   push index
                    pshs      y                   push current bytecode pointer
                    pshs      x                   push command table pointer
                    ldd       $08,s               load trace display parameters
                    pshs      d                   push parameters
                    lbsr      ScriptDisplayLine   draw trace overlay for this command
                    leas      $0A,s               clean up display args
                    ldb       $01,s               restore saved bytecode opcode
                    leas      $02,s               release local frame
                    rts

ScriptArgDispatch   leas      -$03,s              allocate 3-byte local frame
                    sta       $02,s               save arg type byte
                    lda       #$01                set initial trace mode = 1
                    ldb       ,u+                 read next bytecode byte (arg opcode)
                    stb       $01,s               save arg opcode
                    cmpb      #$0E                is it opcode $0E?
                    beq       TraceInfoSetMode    yes — keep trace mode = 1
                    clra                          no — trace mode = 0
TraceInfoSetMode    sta       >TraceArgMode,pcr   set trace argument mode
                    leax      >eval_table,pcr     jump table 2 address
                    ldd       $02,s               reload arg type byte
                    pshs      b,a                 push arg type
                    ldd       #$00DC              display column offset
                    pshs      b,a                 push column offset
                    pshs      u                   push bytecode pointer
                    pshs      x                   push eval table pointer
                    ldd       $08,s               load display parameters
                    pshs      b,a                 push parameters
                    lbsr      ScriptDisplayLine   draw trace overlay for this arg
                    leas      $0A,s               clean up display args
                    leas      $03,s               release local frame
                    rts

ScriptDisplayLine   leas      -$04,s              allocate 4-byte local frame
                    clr       $06,s               clear first-pass flag in caller frame
                    lda       $07,s               load display row index
                    ldb       #$04                4 bytes per table entry
                    mul                           D = offset into jump table
                    ldx       $08,s               load jump table base pointer
                    leax      d,x                 X = entry for this row
                    stx       $08,s               update table pointer in caller frame
                    lbsr      PushRowCol          save current cursor position
                    lbsr      PushTextColor       save current text color
                    ldd       #$000F              fg=0, bg=15 (white on black)
                    lbsr      text_color          set trace text colors

*    this bizarre little fragment is interesting
*    bytes are $17 $01 $82
*    next instruction loads "a" with the second byte
*    in the first pass its $01 and gets cleared
*    any pass after that it will be
*    $17 $00 $82
*    which branches to L58F9
*    that is one byte into leax >StrTraceColon.pcr below
*    and that instruct decodes to the following
*    L58F9  bsr L5859
*           abx
*           ... continues
*    what am I missing in all of this or is my math off

ScriptDisplayDraw   lbsr      TraceDrawWindow     draw the trace window frame

                    lda       <ScriptDisplayDraw+1,pcr load self-modifying byte
                    beq       ScriptDisplayContent zero = not first call, skip header
                    clr       <ScriptDisplayDraw+1,pcr clear flag for subsequent calls

                    leax      >StrTraceSep,pcr    ======= header
                    pshs      x                   push separator string
                    lbsr      PrintFmtStrToScr    print trace header separator
                    leas      $02,s               pop arg
                    lbsr      TraceDrawWindow     redraw window frame after header

ScriptDisplayContent ldy      <CurrentLogicPtr    Y = current bytecode position
                    sty       ,s                  save bytecode pointer on stack
                    ldb       <StringPtrFlag      check if arg uses string pointer
                    beq       ScriptDisplayNumNum zero = use numeric format
                    lbsr      FindLogicSlot       look up logic slot for U
                    cmpu      #$0000              valid slot found?
                    bne       ScriptDisplayNumStr yes — use string format
ScriptDisplayNumNum ldu       $06,s               load trace data pointer
                    clra                          high byte = 0
                    ldb       $02,y               load bytecode arg value
                    leax      >StrTraceNumNum,pcr "%d: %d"
                    bra       ScriptDisplayPrint  print numeric:numeric trace line
ScriptDisplayNumStr leax      >StrReturn,pcr      return
                    ldb       $07,s               load string-mode flag
                    beq       ScriptDisplayNumStrMsg zero = no message lookup
                    addb      $0D,s               add base to get message index
                    lbsr      GetMsgPtr           look up message pointer
ScriptDisplayNumStrMsg clra                       high byte = 0
                    ldb       $02,y               load bytecode arg value
                    leax      >StrTraceNumStr,pcr "%d: %s"
                    ldy       ,s                  restore bytecode pointer
                    sty       <CurrentLogicPtr    update current logic pointer
ScriptDisplayPrint  pshs      u                   push message/data pointer
                    pshs      b,a                 push numeric arg
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print trace line to screen
                    leas      $06,s               pop 3 print args
                    ldd       $0A,s               load first trace display parameter
                    pshs      b,a                 push first parameter
                    ldd       $0A,s               load second trace display parameter
                    pshs      b,a                 push second parameter
                    lbsr      TraceLineDraw       draw argument type indicators
                    leas      $04,s               pop 2 args
                    ldb       $0E,s               check trace display mode byte
                    bmi       ScriptDisplayWait   negative = wait mode, skip label
                    lda       >TraceBottomRow,pcr bottom row of trace window
                    ldb       >TraceWinLastCol,pcr right column of trace window
                    subb      #$02                back up 2 columns from right edge
                    std       <TextRow            position cursor for label display
                    ldb       #$54                default label char 'T' (command mode)
                    ldb       $0E,s               reload display mode byte
                    bne       ScriptDisplayCmd    non-zero = command mode
                    ldb       #$46                zero = 'F' (flag/arg mode)
ScriptDisplayCmd    pshs      b,a                 push label char + row
                    leax      >StrTraceColon,pcr  " %c:"
                    pshs      b,a                 push format string twice (bug workaround?)
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print label string
                    leas      $06,s               pop args
                    ldd       >$024B              load current event counter
                    std       $02,s               save as wait reference
ScriptDisplayWait   lda       <NegCondFlag        trace still active?
                    beq       ScriptDisplayDone   no — done
                    lbsr      EventPop            pop next event from queue
                    leax      ,x                  is event pointer null?
                    beq       ScriptDisplayWaitKey yes — no event, poll for key
                    lda       ,x                  load event type
                    cmpa      #$01                keypress event?
                    beq       ScriptDisplayPlusKey yes — check for '+' key
ScriptDisplayWaitKey ldd      $02,s               load saved event counter
                    cmpd      >$024B              counter changed (new event)?
                    beq       ScriptDisplayWaitKey no — keep waiting
                    lbsr      JoystickPoll        poll joystick state
                    ldd       >$024B              reload updated event counter
                    std       $02,s               save new counter value
                    bra       ScriptDisplayWait   check again
ScriptDisplayPlusKey lda      $01,x               load key character
                    cmpa      #$2B                is it '+' (advance trace)?
                    bne       ScriptDisplayDone   no — exit trace
                    lda       #$02                set trace mode = step-by-step
                    sta       <NegCondFlag        update trace mode
ScriptDisplayDone   lbsr      PopRowCol           restore saved cursor position
                    lbsr      PopTextColor        restore saved text color
                    leas      $04,s               release local frame
                    rts

TraceLineDraw       leas      -$06,s              allocate 6-byte local frame
                    lbsr      PushRowCol          save cursor position
                    ldu       $08,s               load trace data pointer
                    ldx       $0A,s               load bytecode pointer
                    lda       $02,u               load argument count
                    ldb       >TraceArgMode,pcr   check argument display mode
                    beq       TraceLineArg        zero = normal arg mode
                    lda       ,x+                 fetch next bytecode byte
                    stx       $0A,s               advance bytecode pointer in caller
TraceLineArg        ldb       $03,u               load argument type mask
                    std       ,s                  save arg count and type
                    lda       #$28                '(' open paren character
                    lbsr      PutCharToWindow     print '('
                    lda       ,s                  reload arg count
                    beq       TraceLineCloseParen zero args — just close paren
                    clr       $02,s               clear argument index
                    leax      >StrTraceNum,pcr    "%d"
TraceLineArgLoop    ldb       $02,s               load current arg index
                    ldu       $0A,s               reload bytecode pointer
                    lbsr      TraceArgFetch       fetch argument value
                    pshs      b,a                 push arg value
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print argument value
                    leas      $04,s               pop args
                    ldb       $02,s               reload arg index
                    incb                          advance to next arg
                    cmpb      ,s                  past last arg?
                    bcc       TraceLineCloseParen yes — print close paren
                    stb       $02,s               save updated arg index
                    lda       #$2C                ',' separator character
                    lbsr      PutCharToWindow     print ','
                    bra       TraceLineArgLoop    print next argument
TraceLineCloseParen lda       #$29                ')' close paren character
                    lbsr      PutCharToWindow     print ')'
                    ldb       $01,s               load second argument block flag
                    beq       TraceLineArgs2      zero = no second block
                    lbsr      TraceDrawWindow     redraw trace window after first block
TraceLineArgs2      lbsr      PopRowCol           restore cursor position
                    ldb       $01,s               reload second block flag
                    beq       TraceLineDrawRet    zero = done
                    lda       #$28                '(' for second arg block
                    lbsr      PutCharToWindow     print '('
                    lda       #$80                bitmask for arg type checking
                    clr       $02,s               clear second-block arg index
TraceLineArg2Loop   sta       $03,s               save current bitmask
                    ldb       $02,s               load current arg index
                    ldu       $0A,s               reload bytecode pointer
                    lbsr      TraceArgFetch       fetch next argument value
                    std       $04,s               save fetched arg (D)
                    lda       $01,s               load arg type mask
                    anda      $03,s               test type against current bitmask
                    beq       TraceLineArg2Print  zero = print as raw number
                    ldx       #$0432              state.var[] base for indirect lookup
                    abx                           X = &state.var[B]
                    ldb       ,x                  load variable value at index
                    clra                          clear high byte
                    std       $04,s               store resolved value
TraceLineArg2Print  leax      >StrTraceNum,pcr    "%d"
                    ldd       $04,s               load value to print
                    pshs      b,a                 push value arg
                    pshs      x                   push format string
                    lbsr      PrintFmtStrToScr    print argument value
                    leas      $04,s               pop 2 args
                    ldb       $02,s               reload arg index
                    incb                          advance to next arg
                    cmpb      ,s                  past last arg?
                    bcc       TraceLineArg2Paren  yes — close paren
                    stb       $02,s               save updated arg index
                    lda       #$2C                ',' separator
                    lbsr      PutCharToWindow     print ','
                    lda       $03,s               reload bitmask
                    lsra                          shift bitmask right for next arg type
                    bra       TraceLineArg2Loop   print next argument
TraceLineArg2Paren  lda       #$29                ')' close paren character
                    lbsr      PutCharToWindow     print ')'
TraceLineDrawRet    leas      $06,s               release local frame
                    rts

TraceArgFetch       lda       >TraceArgMode,pcr   check argument display mode
                    bne       TraceArgFetchWord   non-zero = word (16-bit) mode
                    ldb       b,u                 fetch byte arg at index B from U
                    bra       TraceArgFetchRet    return byte value
TraceArgFetchWord   lslb                          × 2 for word (2 bytes per arg)
                    leau      b,u                 advance U by 2×B
                    ldb       ,u+                 load high byte of word arg
                    lda       ,u                  load low byte of word arg
TraceArgFetchRet    rts

TraceDrawWindow     ldd       #$0001              draw mode = 1 (draw window)
                    pshs      b,a                 push draw mode
                    ldb       >TraceWinLastCol,pcr right column of trace window
                    pshs      b,a                 push right column
                    ldb       >TraceWinCol,pcr    left column of trace window
                    pshs      b,a                 push left column
                    ldd       #$000F              fg=0, bg=15 (white)
                    pshs      b,a                 push colors
                    ldb       >TraceBottomRow,pcr bottom row of trace window
                    pshs      b,a                 push bottom row
                    ldb       >TraceTopRow,pcr    top row of trace window
                    pshs      b,a                 push top row
                    lbsr      DrawTextRect        draw the trace window frame
                    leas      $0C,s               clean up 6 args
                    rts

InputBufLen         fcb       $00
InputBuf            fcb       $00,$00,$00,$00
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

* ====================================================================
* EVENT AND INPUT LOOP
* EventLoop is entered each interpreter cycle after the logic scripts
* run. It reads joystick axes and buttons, translates them into ego
* direction and fire events, polls the keyboard buffer, and maps
* keystrokes to AGI controller numbers via the active key table.
* InputProcess handles the text input line (player types commands);
* InputCursorBlink manages the cursor flash timing.
* ====================================================================
EventLoop           clra                          A = 0 for clearing event state
                    sta       >$0445              clear last key pressed
                    sta       >$043B              clear controller direction
                    lda       >$05AE              menu bar visible?
                    beq       EventLoopCheck      no — skip redraw
                    lbsr      DrawMenuBar         yes — refresh menu bar
EventLoopCheck      lbsr      EventPop            pop next event from queue
                    lbsr      RemapKeyEvent       translate remapped keys
                    leax      ,x                  NULL event?
                    beq       EventLoopDone       yes — all events consumed
                    ldd       ,x                  load event type+data
                    cmpa      #$01                keypress event?
                    bne       EventLoopJoy        no — check joystick
                    stb       >$0445              store key character
                    lda       >$01D6              input mode active?
                    beq       EventLoopCheck      no — discard key
                    bsr       InputProcess        yes — handle typed character
                    bra       EventLoopCheck      process next event
EventLoopJoy        cmpa      #$02                joystick direction event?
                    bne       EventLoopKey        no — store as generic key event
                    ldu       <ViewObjBase        U = ego object
                    cmpb      <$21,u              same direction as current ego dir?
                    bne       EventLoopJoyStore   no — store new direction
                    clrb                          same dir again — stop ego
EventLoopJoyStore   stb       >$0438              store ego movement direction
                    lda       >$0251              state.ego_control_state
                    beq       EventLoopCheck      program-controlled — ignore joystick
                    lda       #$00                clear ego's current direction
                    sta       <$22,u              store zero as ego's current direction
                    bra       EventLoopCheck      process next event
EventLoopKey        ldu       #$05BA              U = key-event table
                    lda       #$01                mark slot as active
                    sta       b,u                 store in key table at B offset
                    bra       EventLoopCheck      process next event
EventLoopDone       rts

InputProcess        leas      -$02,s              allocate 2-byte local frame
                    stb       ,s                  save key code
                    ldx       #StringTable        state.string (command input buffer display)
                    lbsr      StrLen              measure current display string
                    negb                          B = -(used chars)
                    addb      #$28                B = remaining space in 40-char buffer
                    lda       >CursorChar         state.cursor (cursor shown?)
                    beq       InputCheckLen       no cursor — use raw remaining
                    decb                          subtract 1 for cursor column
InputCheckLen       cmpb      >$044A              compare with configured max input length
                    bls       InputDispatch       within limit — use that value
                    ldb       >$044A              clamp to configured max
InputDispatch       stb       $01,s               save effective max length
                    lbsr      InputEditOn         input_edit_on
                    lda       ,s                  reload key code
                    cmpa      #$0A                Ctrl-J (line feed) ?
                    beq       InputProcessDone    yes — ignore
                    cmpa      #$0D                Enter key?
                    bne       InputBackspace      no — check backspace
                    lda       >InputBufLen,pcr    data byte
                    beq       InputProcessDone    empty buffer — nothing to submit
                    ldx       #$012B              X = input buffer address
                    leau      >InputBuf,pcr       41 byte block
                    lbsr      StrCopy             copy input buffer to parse area
                    ldx       #$012B              reload buffer address
                    lbsr      ParseSentence       parse typed sentence into word table
                    clra                          clear input buffer
                    sta       >InputBufLen,pcr    data byte
                    ldx       #$012B              reload buffer address
                    sta       ,x                  null-terminate buffer
                    lbsr      InputRedraw         redraw blank input line
                    bra       InputProcessDone    done — submit processed
InputBackspace      cmpa      #$08                backspace?
                    bne       InputAddChar        no — add character
                    lda       >InputBufLen,pcr    data byte
                    beq       InputProcessDone    buffer empty — nothing to delete
                    deca                          decrement length
                    sta       >InputBufLen,pcr    data byte
                    ldu       #$012B              U = input buffer
                    clr       a,u                 null-terminate at new length
                    lda       ,s                  reload backspace key code
                    lbsr      PutCharToWindow     erase last character on screen
                    bra       InputProcessDone    done — backspace processed
InputAddChar        ldb       >InputBufLen,pcr    current input length
                    cmpb      $01,s               at max length?
                    bcc       InputProcessDone    yes — discard character
                    lda       ,s                  reload key code
                    beq       InputProcessDone    null char — discard
                    ldu       #$012B              U = input buffer
                    sta       b,u                 store character at end of buffer
                    incb                          increment length
                    stb       >InputBufLen,pcr    data byte
                    clr       b,u                 null-terminate at new end
                    lbsr      PutCharToWindow     echo character to screen
InputProcessDone    bsr       InputCursorBlink    update cursor display
                    leas      $02,s               release local frame
                    rts

cmd_cancel_line
                    lda       >InputBufLen,pcr    any characters in input buffer?
                    beq       CancelLineRet       empty — nothing to cancel
                    ldb       #$08                backspace key code
                    lbsr      InputProcess        delete one character
                    bra       cmd_cancel_line     repeat until buffer empty
CancelLineRet       rts

cmd_echo_line
                    lda       >$01D6              state.input_state
                    beq       EchoLineRet         equal zero were done
                    bsr       input_echo          otherwise input_echo()
EchoLineRet         rts

input_echo
                    leax      >InputBuf,pcr       41 byte block
                    lbsr      StrLen              measure InputBuf length
                    cmpb      >InputBufLen,pcr    data byte
                    bls       InputEchoRet        nothing new to echo
                    bsr       InputEditOn         input_edit_on
InputEchoLoop       ldb       >InputBufLen,pcr    B = current length
                    ldu       #$012B              U = live input buffer
                    leax      >InputBuf,pcr       41 byte block
                    lda       b,x                 load next char to append from InputBuf
                    sta       b,u                 mirror it into live input buffer
                    beq       InputEchoRedraw     null — done
                    incb                          advance position
                    stb       >InputBufLen,pcr    data byte
                    lbsr      PutCharToWindow     echo character to screen
                    bra       InputEchoLoop       continue echoing
InputEchoRedraw     bsr       InputCursorBlink    update cursor after echo
InputEchoRet        rts

InputCursorBlink    lda       >$05B9              load cursor-blink guard flag
                    bne       InputCursorBlinkRet non-zero = already blinking, skip
                    com       >$05B9              toggle guard flag to prevent re-entry
                    lda       >CursorChar         state.cursor (cursor character)
                    beq       InputCursorBlinkRet zero = no cursor defined, skip
                    lbsr      PutCharToWindow     draw/erase cursor character
InputCursorBlinkRet rts

* input_edit_on
InputEditOn         lda       >InputEditDis       load input_edit_disabled flag
                    beq       InputEditOnRet      is it zero ?? good edit is on were done
                    com       >InputEditDis       not zero make it so
                    lda       >CursorChar         state.cursor
                    beq       InputEditOnRet      if it's clear were out a here
                    lda       #$08                otherwise load arg to window_put_char
                    lbsr      PutCharToWindow     and go for it
InputEditOnRet      rts

cmd_prevent_input   bsr       InputEditOn         turn off input edit mode
                    lda       >$01D8              load input row for clearing
                    clrb                          column 0
                    stb       >$01D6              clear input-active flag
                    lbsr      ClearTextLine       erase the input line
                    rts

cmd_accept_input    lda       #$01                set input-active flag
                    sta       >$01D6              state.input_state = 1
                    bsr       InputRedraw         redraw input line with new state
                    rts

cmd_set_cursor_char ldb       ,y+                 read message number from bytecode
                    lbsr      GetMsgPtr           look up message pointer (→ U)
                    lda       ,u                  load first character of message
                    sta       >CursorChar         store as input cursor character
                    rts

InputRedraw         leas      <-$50,s             allocate 80-byte format buffer
                    lda       >$01D6              input active?
                    beq       InputRedrawRet      no — skip redraw
                    bsr       InputEditOn         input_edit_on
                    lda       >$01D8              input row number
                    ldb       >TextBgColor        input background color
                    lbsr      ClearTextLine       clear the input line
                    lda       >$01D8              reload input row
                    clrb                          column 0
                    std       <TextRow            position cursor at start of input row
                    ldx       #StringTable        state.string (current input)
                    leau      ,s                  U = local format buffer
                    ldd       #$0028              max 40 chars
                    pshs      d                   push max length
                    pshs      x                   push source string
                    pshs      u                   push destination buffer
                    lbsr      MsgTextSetup        format string into local buffer
                    leas      $06,s               pop 3 args
                    pshs      x                   push formatted string
                    lbsr      PrintFmtStrToScr    print formatted input prompt
                    leas      $02,s               pop arg
                    ldd       #$012B              address of live input buffer
                    pshs      b,a                 push buffer address
                    lbsr      PrintFmtStrToScr    print current typed characters
                    leas      $02,s               pop arg
                    lbsr      InputCursorBlink    show cursor after redraw
InputRedrawRet      leas      <$50,s              release format buffer
                    rts

* these commands are found in arithmetic.c in nagi
* they all have the form of
* u8 cmd_xyz(u8 *code)
*
* increments state.var[] pointed to by offset held in y
cmd_increment       ldb       ,y+                 get the offset of the first byte in y and bump y
                    ldx       #$0432              address of the state.var[]
                    abx                           add the offset value to x
                    lda       ,x                  get the byte pointed to by that address
                    inca                          increment it by one
                    beq       IncrSkip            if it rolls over FF to 00 don't save it
                    sta       ,x                  otherwise stow it back
IncrSkip            rts                           return

cmd_decrement       ldb       ,y+                 get variable index from bytecode
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[idx]
                    lda       ,x                  load current variable value
                    beq       DecrSkip            zero — do not decrement below 0
                    deca                          otherwsie decrement it
                    sta       ,x                  stow it back
DecrSkip            rts

cmd_assignn         ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    lda       ,y+                 get the immediate value to assign
                    abx                           X = &state.var[dst]
                    sta       ,x                  store immediate value into variable
                    rts

cmd_assignv         ldb       $01,y               get source variable index (arg 2)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[src]
                    lda       ,x                  load source variable value
                    ldb       ,y++                get dest variable index (arg 1), advance Y past both
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  assign src value to dest variable
                    rts

cmd_addn            ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    lda       ,x                  get the value of the first byte
                    adda      ,y+                 add in the value of the second and bump the pointer
                    sta       ,x                  store the sum in the first byte
                    rts

cmd_addv            ldb       $01,y               get source variable index (arg 2)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[src]
                    lda       ,x                  load source value
                    ldb       ,y++                get dest variable index, advance Y past both
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    adda      ,x                  add dest current value to source
                    sta       ,x                  store sum back into dest variable
                    rts

cmd_subn            ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    lda       ,x                  load current variable value
                    suba      ,y+                 subtract immediate value, advance Y
                    sta       ,x                  store difference back into variable
                    rts

cmd_subv            ldb       $01,y               get source variable index (arg 2)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[src]
                    lda       ,x                  load source value
                    nega                          negate: A = -src (for subtraction via add)
                    ldb       ,y++                get dest variable index, advance Y past both
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    adda      ,x                  dst + (-src) = dst - src
                    sta       ,x                  store result back into dest variable
                    rts

cmd_lindirectv      ldb       $01,y               get source variable index (arg 2)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[src]
                    lda       ,x                  A = value to write (from source var)
                    ldb       ,y++                get indirect-index variable (arg 1), advance Y
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[idx_var]
                    ldb       ,x                  B = indirect index from variable
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[*idx_var] (double-indirect dst)
                    sta       ,x                  store source value at doubly-indirect address
                    rts

cmd_lindirectn      lda       $01,y               get immediate value to write (arg 2)
                    ldb       ,y++                get indirect-index variable (arg 1), advance Y
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[idx_var]
                    ldb       ,x                  B = indirect index from variable
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[*idx_var] (indirect dst)
                    sta       ,x                  store immediate at indirected address
                    rts

cmd_rindirect       ldb       $01,y               get indirect-index variable (arg 2)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[idx_var]
                    ldb       ,x                  B = indirect index from variable
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[*idx_var] (indirect src)
                    lda       ,x                  A = value read from indirect address
                    ldb       ,y++                get destination variable index (arg 1), advance Y
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  store indirectly-read value to dest
                    rts

cmd_multn           ldx       #$0432              state.var[] base
                    ldb       ,y+                 get destination variable index
                    abx                           X = &state.var[dst]
                    lda       ,x                  load destination variable value
                    ldb       ,y+                 get immediate multiplier
                    mul                           D = dst × immediate
                    stb       ,x                  store low byte of product back to dst
                    rts

cmd_multv           ldb       $01,y               get source variable index (arg 2)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[src]
                    lda       ,x                  load source variable value
                    ldb       ,y++                get dest variable index (arg 1), advance Y
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    ldb       ,x                  load dest variable value
                    mul                           D = src × dst
                    stb       ,x                  store low byte of product back to dst
                    rts

cmd_divn            ldx       #$0432              state.var[] base
                    ldb       ,y+                 get destination variable index
                    abx                           X = &state.var[dst]
                    ldb       ,x                  B = dividend (current variable value)
                    lda       ,y+                 A = immediate divisor
                    bsr       Div8                B = quotient (B div A)
                    stb       ,x                  store quotient back to variable
                    rts

cmd_divv            ldb       $01,y               get source variable index (arg 2 = divisor)
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[src]
                    lda       ,x                  A = divisor value
                    ldb       ,y++                get dest variable index (arg 1), advance Y
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    ldb       ,x                  B = dividend (dest variable value)
                    bsr       Div8                B = quotient (B div A)
                    stb       ,x                  store quotient back to dest variable
                    rts

Div8                sta       <DivDivisor         save divisor
                    lda       #$08                8-bit division: 8 iterations
                    sta       <DivBitCount        initialize bit counter
                    clra                          A = running partial remainder
Div8Loop            lslb                          shift dividend left; low bit of quotient enters B
                    rola                          carry into remainder
                    cmpa      <DivDivisor         partial remainder >= divisor?
                    bcs       Div8Next            no — quotient bit is 0, continue
                    suba      <DivDivisor         subtract divisor from remainder
                    incb                          set quotient bit (already shifted in)
Div8Next            dec       <DivBitCount        decrement bit counter
                    bne       Div8Loop            loop until all 8 bits processed
                    rts                           B = quotient, A = remainder

* list struct
*
*	NODE *head;
*	NODE *tail;
*
*	// private
*	int contents_size;
list_struct         fdb       $0000
                    fdb       $0000
                    fcb       $00,$00,$00

ListLastNode        fdb       $0000

list_clear          leau      >list_struct,pcr    U = view linked-list head
                    ldd       #$0000              null head pointer
                    std       ,u                  clear list (head = null)
                    rts

view_find           leax      >list_struct,pcr    X = list head anchor
ViewFindLoop        stx       >ListLastNode,pcr   save pointer to previous node
                    ldx       ,x                  follow next link
                    beq       ViewFindRet         null — view not found
                    cmpb      $02,x               view number matches this node?
                    bne       ViewFindLoop        no — keep walking
ViewFindRet         rts                           X = found node (or null)


cmd_load_view       lda       #$00                clear MSB
                    ldb       ,y+                 get the arg passed in (passed in d)
                    bsr       view_load           call view_load
                    rts

cmd_load_view_v     lda       #$00                clear MSB
                    ldb       ,y+                 resolve state.var[] addr
                    ldx       #$0432              state.var[] base address
                    abx                           add offset to base address
                    ldb       ,x                  get the arg passed in (passed in d)
                    bsr       view_load           call view_load
                    rts

* ====================================================================
* VIEW AND CEL MANAGEMENT
* view_load allocates a heap node for a view resource and decodes its
* loop/cel headers into the node. cmd_set_view/loop/cel bind a view
* and specific loop and cel to a view object; SetLoopHelper and
* SetCelHelper update the object's cel pointer and clip its position
* to stay on screen. cmd_discard_view releases the heap node and
* clears the view reference from any bound objects.
* ====================================================================
view_load           leas      -$06,s              6-byte frame: [,s]=view# [2,s]=node [4,s]=saved page
                    std       ,s                  save view number (D = 0:view#)
                    bsr       view_find           search list for existing node
                    leax      ,x                  test result for null
                    beq       ViewLoadCreate      not found — create new node
                    ldb       ,s                  reload view number
                    bne       ViewLoadCreate      non-zero: force reload even if found
                    tfr       x,u                 U = existing node (no reload needed)
                    bra       ViewLoadRet         return existing node
ViewLoadCreate      stx       $02,s               save current list pointer (may be null)
                    ldd       <PsgCurLatch        save current logic page
                    std       $04,s               save logic page in frame
                    lbsr      BlitBothErase       erase sprites before heap allocation
                    ldu       $02,s               reload saved node pointer
                    bne       ViewLoadFetch       node exists — just fetch resource data
                    lda       #$01                script type: load-view
                    ldb       $01,s               reload view number
                    lbsr      PushScript          record in script buffer
                    ldd       #$0007              7 bytes per view node
                    lbsr      AllocDataBlock      allocate from data heap
                    stu       $02,s               save new node pointer
                    ldx       >ListLastNode,pcr   X = previous list link (for insertion)
                    stu       ,x                  link new node into list
                    ldd       #$0000              initialize next-link to null
                    std       ,u                  node.next = null
                    std       $03,u               node.data_ptr = null
                    ldb       $01,s               reload view number
                    stb       $02,u               store view number in node
ViewLoadFetch       ldb       $02,u               view number from node
                    lbsr      FetchView           locate view resource descriptor
                    ldx       $02,s               reload node pointer
                    ldx       $03,x               load resource data pointer from node
                    lbsr      OpenVolFile         open/map the volume data
                    beq       ViewLoadDone        already mapped — skip address save
                    ldx       $02,s               reload node pointer
                    std       $05,x               save vol/offset coords in node
                    stu       $03,x               save mapped data pointer in node
ViewLoadDone        lbsr      EraseAndBlitShdw    redraw shadow after resource load
                    ldd       $04,s               restore saved logic page
                    lbsr      SetLogicPage        restore logic page mapping
                    ldu       $02,s               U = loaded view node
ViewLoadRet         leas      $06,s               release frame
                    rts

cmd_set_view        leas      -$02,s              2-byte: save current page
                    ldd       <PsgCurLatch        save current logic page
                    std       ,s                  save logic page in frame
                    lda       ,y+                 get object index from bytecode
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldb       ,y+                 get view number (immediate) from bytecode
                    bsr       SetViewForObj       apply view to object
                    ldd       ,s                  restore saved page
                    lbsr      SetLogicPage        restore saved logic page
                    leas      $02,s               release frame
                    rts

cmd_set_view_v      leas      -$02,s              2-byte: save current page
                    ldd       <PsgCurLatch        save current logic page
                    std       ,s                  save logic page in frame
                    lda       ,y+                 get object index from bytecode
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldb       ,y+                 get variable index from bytecode
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[view_var]
                    ldb       ,x                  load view number from variable
                    bsr       SetViewForObj       apply view to object
                    ldd       ,s                  restore saved page
                    lbsr      SetLogicPage        restore saved logic page
                    leas      $02,s               release frame
                    rts

SetViewForObj       lbsr      view_find           find loaded view node for view number in B
                    leax      ,x                  test for null result
                    bne       SetViewData         found — apply view data to object
                    lda       #$03                error: view not loaded
                    lbsr      ReportError         report and continue (non-fatal)
SetViewData         stb       $05,u               store view number in object
                    ldd       $05,x               load resource page + coords from view node
                    std       $08,u               save resource page in object
                    ldx       $03,x               load view data pointer from node
                    stx       $06,u               save in object
                    lbsr      SetLogicPage        map view resource page
                    ldx       $06,u               reload view data pointer
                    lda       $02,x               load loop count from view header
                    sta       $0B,u               store as object's loop count
                    ldb       $0A,u               load current loop number
                    cmpb      $0B,u               current loop within range?
                    bcs       SetViewRet          yes — keep current loop
                    clrb                          no — reset to loop 0
SetViewRet          bsr       SetLoopHelper       set loop (and reset cel if needed)
                    rts

cmd_set_loop        leas      -$02,s              2-byte: save current page
                    ldd       <PsgCurLatch        save current logic page
                    std       ,s                  save logic page in frame
                    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldb       ,y+                 get loop number from bytecode
                    bsr       SetLoopHelper       set loop and reset cel
                    ldd       ,s                  restore saved page
                    lbsr      SetLogicPage        restore saved logic page
                    leas      $02,s               release frame
                    rts

cmd_set_loop_v      leas      -$02,s              2-byte: save current page
                    ldd       <PsgCurLatch        save current logic page
                    std       ,s                  save logic page in frame
                    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldb       ,y+                 get variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[loop_var]
                    ldb       ,x                  load loop number from variable
                    bsr       SetLoopHelper       set loop and reset cel
                    ldd       ,s                  restore saved page
                    lbsr      SetLogicPage        restore saved logic page
                    leas      $02,s               release frame
                    rts

SetLoopHelper       leas      -$01,s              1-byte: error code scratch
                    ldx       $06,u               load view data pointer
                    bne       SetLoopFound        non-null — view is loaded
                    ldb       #$06                error: no view set
                    bra       SetLoopErr          skip to error handler
SetLoopFound        cmpb      $0B,u               loop number < loop count?
                    bcs       SetLoopData         yes — valid loop
                    ldb       #$05                no — error: invalid loop
SetLoopErr          stb       ,s                  save error code
                    tfr       u,d                 D = object pointer
                    subd      <ViewObjBase        D = object index offset
                    lda       ,s                  reload error code
                    lbsr      ReportError         report and continue (non-fatal)
SetLoopData         stb       $0A,u               store loop number in object
                    ldd       $08,u               load resource page for view
                    lbsr      SetLogicPage        map view resource
                    ldb       $0A,u               load current loop number
                    lslb                          × 2 (each loop entry is 2 bytes)
                    addb      #$06                add loop table offset in view header
                    ldx       $06,u               load view data pointer
                    lda       b,x                 load high byte of loop offset
                    decb                          point to low byte
                    ldb       b,x                 load low byte of loop offset
                    leax      d,x                 X = pointer to loop data
                    stx       $0C,u               save loop data pointer in object
                    lda       ,x                  load cel count from loop header
                    sta       $0F,u               store as object's cel count
                    ldb       $0E,u               load current cel number
                    cmpb      $0F,u               current cel within range?
                    bcs       SetLoopRet          yes — keep current cel
                    clrb                          no — reset to cel 0
SetLoopRet          bsr       SetCelHelper        set cel (update dimensions etc.)
                    leas      $01,s               release scratch byte
                    rts

cmd_set_cel         leas      -$02,s              2-byte: save current page
                    ldd       <PsgCurLatch        save current logic page
                    std       ,s                  save logic page in frame
                    lda       ,y+                 get object index from bytecode
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldb       ,y+                 get cel number (immediate) from bytecode
                    bsr       SetCelHelper        apply cel to object
                    ldd       ,s                  restore saved page
                    lbsr      SetLogicPage        restore saved logic page
                    leas      $02,s               release frame
                    rts

cmd_set_cel_v       leas      -$02,s              2-byte: save current page
                    ldd       <PsgCurLatch        save current logic page
                    std       ,s                  save logic page in frame
                    lda       ,y+                 get object index from bytecode
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    ldb       ,y+                 get variable index from bytecode
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[cel_var]
                    ldb       ,x                  load cel number from variable
                    bsr       SetCelHelper        apply cel to object
                    ldd       ,s                  restore saved page
                    lbsr      SetLogicPage        restore saved logic page
                    leas      $02,s               release frame
                    rts

SetCelHelper        leas      -$01,s              1-byte: error code scratch
                    ldx       $06,u               load view data pointer
                    bne       SetCelFound         non-null — view is loaded
                    ldb       #$0A                error: no view set (set_cel)
                    bra       SetCelErr           skip to error handler
SetCelFound         cmpb      $0F,u               cel number < cel count?
                    bcs       SetCelData          yes — valid cel
                    ldb       #$08                no — error: invalid cel
SetCelErr           stb       ,s                  save error code
                    tfr       u,d                 D = object pointer
                    subd      <ViewObjBase        D = object index offset
                    lda       ,s                  reload error code
                    lbsr      ReportError         report and continue (non-fatal)
SetCelData          stb       $0E,u               store cel number in object
                    ldd       $08,u               load resource page for view
                    lbsr      SetLogicPage        map view resource
                    ldb       $0E,u               load current cel number
                    lslb                          × 2 (each cel entry is 2 bytes)
                    addb      #$02                add cel table offset in loop header
                    ldx       $0C,u               load loop data pointer
                    lda       b,x                 load high byte of cel offset
                    decb                          point to low byte
                    ldb       b,x                 load low byte of cel offset
                    leax      d,x                 X = pointer to cel data
                    stx       <$10,u              save cel data pointer in object
                    ldd       ,x                  load cel width + height
                    std       <$1C,u              save sprite dimensions in object
                    adda      $03,u               add current X position
                    cmpa      #$A0                would sprite extend past right edge (160)?
                    bls       SetCelWidthClip     no — use full width
                    lda       <$25,u              yes — set repos-needed flag
                    ora       #$04                set repos-needed bit
                    sta       <$25,u              update object flags
                    lda       #$A0                clip X to right edge (160)
                    suba      <$1C,u              X = right edge - sprite width
                    sta       $03,u               store clipped X
SetCelWidthClip     decb                          B = cel height - 1 (bottom row)
                    cmpb      $04,u               below horizon?
                    bls       SetCelRet           no — OK
                    lda       <$25,u              yes — set repos-needed flag
                    ora       #$04                set repos-needed bit
                    sta       <$25,u              update object flags
                    stb       $04,u               store bottom row as new Y
                    cmpb      >$01D7              is it also above horizon?
                    bhi       SetCelRet           no — done
                    lda       <$26,u              load control flags
                    bita      #$08                ignore-horizon flag set?
                    bne       SetCelRet           yes — don't clamp to horizon
                    ldb       >$01D7              load horizon Y
                    incb                          Y = horizon + 1
                    stb       $04,u               clamp object to just below horizon
SetCelRet           leas      $01,s               release scratch byte
                    rts

cmd_last_cel        lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       $0F,u               load cel count
                    deca                          last cel index = count - 1
                    ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  store last cel number in variable
                    rts

cmd_current_cel     lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       $0E,u               load current cel number
                    ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  store current cel in variable
                    rts

cmd_current_loop    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       $0A,u               load current loop number
                    ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  store current loop in variable
                    rts

cmd_current_view    lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       $05,u               load current view number
                    ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  store current view in variable
                    rts

cmd_number_of_loops lda       ,y+                 get object index
                    ldb       #$2B                43 bytes per entry
                    mul                           D = object offset
                    addd      <ViewObjBase        D = object pointer
                    tfr       d,u                 U = view-object
                    lda       $0B,u               load loop count for this view
                    ldb       ,y+                 get destination variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[dst]
                    sta       ,x                  store loop count in variable
                    rts

cmd_discard_view    ldb       ,y+                 get view number from bytecode
                    bsr       DiscardViewHelper   free view resource
                    rts

cmd_discard_view_v  ldb       ,y+                 get variable index
                    ldx       #$0432              state.var[] base
                    abx                           X = &state.var[idx]
                    ldb       ,x                  load view number from variable
                    bsr       DiscardViewHelper   free view resource
                    rts

DiscardViewHelper   leas      -$05,s              5-byte frame: [,s]=view#, [1,s]=node, [3,s]=page
                    stb       ,s                  save view number
                    lbsr      view_find           find view node in list
                    leax      ,x                  test for null
                    bne       DiscardViewDoFree   found — free it
                    lda       #$01                error: view not loaded
                    ldb       ,s                  reload view number for error report
                    lbsr      ReportError         report view-not-loaded error
DiscardViewDoFree   stx       $01,s               save view node pointer
                    ldd       <PsgCurLatch        save current logic page
                    std       $03,s               store page in frame
                    lda       #$07                script type: discard-view
                    ldb       ,s                  reload view number
                    lbsr      PushScript          record in script buffer
                    ldu       >ListLastNode,pcr   U = pointer to previous list link
                    ldd       #$0000              null forward link
                    std       ,u                  unlink this node from list
                    lbsr      BlitBothErase       erase sprites for heap ops
                    ldx       $01,s               reload view node pointer
                    ldu       $03,x               load resource data pointer from node
                    lda       $05,x               load priority coordinate from node
                    lbsr      CalcPriAddr         compute heap-free address
                    stu       <HeapPtr            restore heap pointer
                    stx       <HeapTop            restore heap top
                    lbsr      EraseAndBlitShdw    redraw shadow after heap ops
                    lbsr      UpdateFreeSpace     update free-space counter
                    ldd       $03,s               restore saved logic page
                    lbsr      SetLogicPage        restore logic page mapping
                    leas      $05,s               release frame
                    rts

ObjAnimStep         lda       <$27,u              load animation delay counter
                    beq       AnimStepRoll        zero — time to advance animation
                    dec       <$27,u              decrement delay counter
                    lda       <$25,u              load secondary flags
                    bita      #$40                wander-mode flag set?
                    beq       AnimStepRet         no — just wait out the delay
AnimStepRoll        lbsr      InitRandSeed        generate random number
                    lda       #$09                modulo 9 (direction 0-8)
                    lbsr      Div8                B = random direction
                    sta       <$21,u              store new direction in object
                    cmpu      <ViewObjBase        is this the ego object?
                    bne       AnimStepCheckDelay  no — just check delay
                    sta       >$0438              yes — update ego direction state too
AnimStepCheckDelay  lda       <$27,u              load (now-decremented) delay
AnimStepDelayLoop   cmpa      #$06                delay >= 6 ticks?
                    bcc       AnimStepRet         yes — skip re-randomizing delay
                    lbsr      InitRandSeed        randomize to get new delay value
                    lda       #$33                divisor: 51 ticks maximum
                    lbsr      Div8                B = random delay 0..50
                    sta       <$27,u              store new delay counter
                    bra       AnimStepDelayLoop   re-check against minimum
AnimStepRet         rts

AniScratch          fcb       $00,$00,$00,$00
                    fcb       $00,$00,$00,$00
StrModName          fcc       'mnln'
                    fcb       C$NULL

fxsnd1              lda       ,u+                 load next note byte from resource, advance U
fxsnd               ora       #2                  set bit 1 (CoCo3 PIA sound bit)
                    sta       $ff20               write to PIA sound output register
                    rts

fxsnd2              lda       $ff20               read current PIA sound output
                    coma                          complement: toggle all bits
                    bsr       fxsnd               write complemented value (toggling output)
                    leax      -1,x                decrement outer cycle counter
                    rts

fxsnd3              orcc      #$50                disable IRQ and FIRQ interrupts
fxsnd4              lda       #2                  value with bit 1 set (silence)
                    sta       $ff02               write to PIA1-B data register (silence DAC)
                    rts

                    emod
eom                 equ       *
                    end
