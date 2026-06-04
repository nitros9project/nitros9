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


*
*======================================================================
* EQUATES — I/O PATH NUMBERS
*   Standard I/O path numbers shared with sierra, scrn, and shdw modules.
*======================================================================
*
StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

*
*======================================================================
* EQUATES — DIRECT PAGE VARIABLES
*   Offsets into the shared Sierra data block, accessed via the direct-page register.
*======================================================================
*
*  equates for direct page vars
*  shared with sierra module
DataBlockSize       equ       $00       holds size of data block
SierraRemapOff      equ       $09       sierra - offset from entry to the routine for the remap call
PsgCurLatch         equ       $0A
ScrnRemapOff        equ       $19       scrn - offset from entry to the routine for the remap call
ShdwRemapOff        equ       $21       shdw - offset from entry to the routine for the remap call
SierraRemapVal      equ       $22       sierra remap value holder
ScrnRemapVal        equ       $26       scrn remap value holder
ShdwRemapVal        equ       $28       shdw remap value holder
PixDispAddr         equ       $2C
SierraBiasVal       equ       $2E
ViewObjBase         equ       $30
ViewObjEnd          equ       $32
ViewObjSizeD        equ       $34
ViewObjLast         equ       $36
BlockPtr            equ       $38
BlockOffset         equ       $3A
BlockSizeLimit      equ       $3C
LoopCounter         equ       $3E
TextRow             equ       $40
TextCol             equ       $41
PsgBlockNum         equ       $42
PsgPortAddr         equ       $43
DrawAttr            equ       $45
SierraModSize       equ       $4B
MnlnModSize         equ       $4D
HeapPtr             equ       $4F
HeapEnd             equ       $51
HeapBase            equ       $53
HeapTop             equ       $55
HeapMax             equ       $57
HeapByteCnt         equ       $58
ShdwContact         equ       $5C
PriorityYBase       equ       $5F
CurrentLogicPtr     equ       $62
LogicTablePtr       equ       $64
VolFileSize         equ       $66
NegCondFlag         equ       $68
FirstExecFlag       equ       $69
StringPtrFlag       equ       $6A
SavedYPtr           equ       $6C
TempRegA            equ       $6E
ObjXPos             equ       $6F
TempObjByte         equ       $70
ObjXRight           equ       $71
WordMatchCnt        equ       $72
WordMatchFlag       equ       $73
AnimStep            equ       $74
AnimStepMax         equ       $75
TempMultByte        equ       $76
OpenPathCnt         equ       $77       open path counter
PathNum             equ       $78       path number holder
DiskNameBufPtr      equ       $79
CmpKey3Hi           equ       $7B
CmpKey3Lo           equ       $7D
DiskKeyAHi          equ       $7E
DiskKeyALo          equ       $80
DiskKeyBHi          equ       $81
DiskKeyBLo          equ       $83
SeekMSW             equ       $84       seek MSW
SeekLSW             equ       $86       seek LSW
DivDivisor          equ       $88
DiskInfoIdx         equ       $89
RandSeedHi          equ       $8B
RandSeedLo          equ       $8C
DivBitCount         equ       $8D
DelayParam          equ       $8E
DelayParamX         equ       $90
EvtWritePtr         equ       $92
EvtReadPtr          equ       $94
JoyNum              equ       $96       holds joystick number
JoyDirState         equ       $97
JoyEnabled          equ       $98
JoyLastDir          equ       $99
JoyTimerLo          equ       $9A
JoyTimerHi          equ       $9C
JoyDebounce         equ       $9D


*
*======================================================================
* EQUATES — ABSOLUTE STATE ADDRESSES
*   Absolute addresses in the Sierra shared data block and CoCo3 hardware registers.
*======================================================================
*
TocDataPtr          equ       $0089     TOC data pointer (direct-page slot $89)

PicVisible          equ       $0100     pic_visible
InputState          equ       $0101     current input state
ClockState          equ       $0102     clock_state (0=running, 1=paused)

InputActiveFlag     equ       $0154     flag for extended table look up / input-active
WordWrapPtr         equ       $0155     word-wrap output position pointer (16-bit)

CharCountLine       equ       $0157     current char count on current line
MaxCharsPerLine     equ       $0158     max chars per line for word wrap
MaxLineWidth        equ       $0159     max line width seen / box height in chars
ParsedWordCount     equ       $015A     parsed-word count
ColCount            equ       $015B     column count (line count / box width in chars)
ColorStackBase      equ       $015C     color stack base address

RowColStackBase     equ       $0167     row/col stack base address

GraphicsMode        equ       $0172     graphics mode active flag / silent flag
Unk0173             equ       $0173     unknown (unreferenced)
BoxTopRow           equ       $0176     box top row
BoxRightCol         equ       $0177     box right column
BoxBottomRow        equ       $0178     box bottom row
Unk0179             equ       $0179     unknown (unreferenced)
WinPixWidth         equ       $017B     window pixel width
WinPixHeight        equ       $017C     window pixel height
WinPixX             equ       $017D     window pixel X position
WinPixW             equ       $017E     window pixel draw width
WinOpenFlag         equ       $017F     window-open flag
NounTableBase       equ       $0180     noun-table / word-string pointer table base
WordsTriePtrLo      equ       $01A9     low byte of words trie pointer ($01A8+1)
WordsPageLo         equ       $01AB     low byte of words logic page ($01AA+1)
BlockState          equ       $01AD     state.block_state
CursorState         equ       $01AE     state.cursor / game flags byte
AudioDisplayFlags   equ       $01AF     state.flag (audio/display flags)
StateFlag1          equ       $01B0     state.flag (player control flags)
Unk01B1             equ       $01B1     unknown (unreferenced)
HorizonY            equ       $01D6     horizon line Y / priority override
MonitorType         equ       $01D7     monitor type
KeyTableBase        equ       $01D8     key-mapping table base address
BlockX2             equ       $023D     state.block_x2
BlockY2             equ       $023E     state.block_y2
NewPicNum           equ       $0240     pending new pic number / room-change flag
PicNum              equ       $0241     state.pic_num (current active pic)
Unk0242             equ       $0242     unknown (unreferenced)
ScriptSaved         equ       $0244     state.script_saved
ScriptCount         equ       $0245     state.script_count
StatusLineEnable    equ       $0246     status-line enabled flag
StatusState         equ       $0247     state.status_state
TickHiWord          equ       $0248     tick counter high word (32-bit timer, high 16 bits)
TickHiLo            equ       $0249     tick counter high word low byte ($0248+1)
Unk024B             equ       $024B     unknown (unreferenced as absolute address)

TextFg              equ       $024D     state.text_fg
TextBg              equ       $024E     state.text_bg

BlockX1             equ       $024F     state.block_x1
BlockY1             equ       $0250     state.block_y1
EgoCtrlState        equ       $0251     state.ego_control_state

StateString         equ       $0252     state.string

VarCurrentRoom      equ       $0432     state.var[0] current room
VarPrevRoom         equ       $0433     state.var[1] prev room / ego entry-side
VarLogicNum         equ       $0434     state.var[2] current/room logic number
VarCycleFlag        equ       $0435     state.var[3] cycle flag / object-boundary flag
VarUpdateFlag       equ       $0436     state.var[4] display update flag / boundary direction
VarEgoDir           equ       $0437     state.var[5] ego direction
VarScore            equ       $0438     state.var[6] current score
VarFreePages        equ       $0439     state.var[7] free memory pages
VarCycleState       equ       $043A     state.var[8] cycle flag / keyboard state
VarCycleDelay       equ       $043B     state.var[9] cycle delay
VarClockSec         equ       $043C     state.var[10] clock seconds
VarClockMin         equ       $043D     state.var[11] clock minutes
VarClockHour        equ       $043E     state.var[12] clock hours
VarClockDay         equ       $043F     state.var[13] clock days
VarJoySensitivity   equ       $0440     state.var[14] joystick repeat delay
VarLastKey          equ       $0441     state.var[15] last key / view setup
VarAnimInterval     equ       $0442     state.var[16] animation interval
VarErrParam         equ       $0443     state.var[17] error parameter B
VarPendingKey       equ       $0444     state.var[18] pending raw keycode
VarRows             equ       $0445     state.var[19] rows variable
VarAutoAdvTimer     equ       $0446     state.var[20] auto-advance timer
VarInputLine        equ       $0447     state.var[21] input-line display flag
VarVar22            equ       $0448     state.var[22] (unreferenced directly)
VarInvSelected      equ       $044A     state.var[24] selected inventory item
VarPicEndRow        equ       $044B     state.var[25] pic-end row / score variable
VarVar26            equ       $044C     state.var[26] (unreferenced directly)

VolHandleTable      equ       $0532     vol_handle_table
JoyBtnStatusFlag    equ       $0541     joystick button status / button-pressed flag
JoyBtnCount         equ       $0542     joystick button state counter
JoyClickStampLo     equ       $0543     joystick click timestamp low word
JoyClickStampHi     equ       $0545     joystick click timestamp high word
EventFilter         equ       $0547     event category filter / cursor-visible flag

GfxPicBufRotate     equ       $0550     gfx_picbuffrotate
GivenPicData        equ       $0551     given_pic_data
DisplayType         equ       $0553     display_type

MenuInputActive     equ       $05AE     menu-input-active flag
ScriptBufPtr        equ       $05AF     logic table pointer / script buffer pointer
ObjDisplayed        equ       $05B1     obj_displayed in obj_show()
MemAvailFlag        equ       $05B8     available memory / temp-load flag
InputEditDisabled   equ       $05B9     input_edit_disabled
ChgenTextmode       equ       $05EC     chgen_textmode / quit-room-change flag
VolumeCount         equ       $05ED     volume count (disk count)
MmuTwiddleAddr      equ       $0659     MMU twiddler call address

HsyncCtrl           equ       $FF01     hsync control
KeyboardCol         equ       $FF02     keyboard col
VsyncCtrl           equ       $FF03     vsync control
DacOut              equ       $FF20     d/a, cassette & rs232 out
VdgCtrl             equ       $FF22     vdg control and rs-232 in
CtrlReg             equ       $FF23     control reg


MmuBlock2           equ       $FFA9     task 1 block 2


*
*======================================================================
* EQUATES — PROGRAM CONSTANTS
*   AGI game-logic constants: cycle types, motion types, loop directions, and object flag bits.
*======================================================================
*
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

*
*======================================================================
* MODULE HEADER
*   NitrOS-9 module preamble, data area layout, and string literals.
*======================================================================
*
                    nam       mnln
                    ttl       program module

                  IFP1
                    use       defsfile
                  ENDC

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

*
*======================================================================
* MAIN CYCLE LOOP
*   Module entry point and the top-level AGI interpreter cycle: poll joystick, run scripts, update objects, refresh screen.
*======================================================================
*
ModuleEntry         leas      -6,s      make room on the stack
                    lbsr      PatchCmdTable modifies table values at 1B0
                    lbsr      FixupEvalTbl modifies table values at D09
                    lbsr      InitGameState calls the mmu twiddler at >$659
*                         uses toc and words.tok

MainCycleLoop       clra                clear A for word store
                    ldb       >$043B    ** who loads me with ??
                    std       ,s        save timer reference on stack
CycleLoopTop        lbsr      JoystickPoll
CheckScriptTimer    ldd       <$003E    load current cycle timer
                    cmpd      ,s        compare to initial timer value
TimerReady          bcc       ResetGameState branch if timer has advanced enough
                    cmpd      $04,s     compare to previous timer snapshot
                    beq       CheckScriptTimer branch if timer unchanged, keep waiting
                    std       $04,s     save new timer snapshot
                    bra       CycleLoopTop loop back to poll joystick
ResetGameState      ldd       #$0000    zero out timer
                    std       <$003E    reset cycle timer
                    lbsr      ClearInputBuffer self contained call to clear 50 bytes 05BA
ClearCycleFlags     lda       >$01AE    load game state flags
                    anda      #$DF      clear cycle-active bit
StoreStateFlag      sta       >$01AE    save updated flags
                    lda       >$01AE    reload flags
                    anda      #$F7      clear another state bit
                    sta       >$01AE    save flags again
                    lbsr      EventLoop process pending game events
                    ldx       <$0030    load ego object pointer
                    lda       >$0250    check joystick control flag
                    beq       SetEgoDir branch if ego controlled by keyboard
                    lda       >$0437    load joystick direction
                    sta       <$21,x    store as ego direction
                    bra       DispatchMotionObjs skip keyboard direction update
SetEgoDir           lda       <$21,x    load ego's current direction
                    sta       >$0437    save ego direction for later
DispatchMotionObjs  lbsr      DispatchMotion
                    lda       >$01AF    load audio/display flags
                    anda      #$40      isolate sound-enabled bit
                    sta       $03,s     save sound state for comparison
                    lbsr      GetStackFrame
RunScriptLoop       lda       >$0434    load current logic number
ScriptEntryPoint    sta       $02,s     save logic number on stack
                    clrb                clear error code
                    lbsr      ExecLogic execute current room logic script
                    leay      ,y        test Y (return value) for zero
                    bne       ScriptDone branch if logic returned non-zero
                    clra                clear script flags
                    sta       >$043A    clear cycle flag
                    sta       >$0436    clear display update flag
                    sta       >$0435    clear another cycle flag
                    lda       >$01AE    load game flags
                    anda      #$DF      clear cycle-active bit
                    sta       >$01AE    save flags
                    bra       RunScriptLoop loop to run next logic
ScriptDone          lda       >$0437    load current ego direction
                    ldx       <$0030    load ego object pointer
                    sta       <$21,x    store direction back to ego object
                    lda       $02,s     load last executed logic number
                    cmpa      >$0434    compare to room logic number
                    bne       UpdateScreenState branch if not the room logic
                    lda       >$01AF    load audio/display flags
                    anda      #$40      isolate sound-enabled bit
                    cmpa      $03,s     compare to saved sound state
                    beq       CycleEndCleanup branch if sound state unchanged
UpdateScreenState   lbsr      StatusLineWrite
CycleEndCleanup     clra                clear A for flag clearing
                    sta       >$0436    clear display update flag
                    sta       >$0435    clear cycle flag
                    lda       >$01AE    load game flags
                    anda      #$FB      clear said-input bit
                    sta       >$01AE    save flags
                    lda       >$01AE    reload flags
                    anda      #$FD      clear another input flag
                    sta       >$01AE    save flags
                    lda       >$01AF    load audio/display flags
                    anda      #$F7      clear a display flag
                    sta       >$01AF    save audio/display flags
                    lda       >$05EC    check quit/room-change flag
                    cmpa      #$00      test if zero
                    lbne      MainCycleLoop branch back if no room change
                    lbsr      UpdateAllObjs
                    lbra      MainCycleLoop restart main game cycle

*
*======================================================================
* BUILT-IN COMMANDS — PAUSE AND QUIT
*   Handlers for AGI commands 0x7A (pause) and 0x7B (quit).
*======================================================================
*
cmd_pause
CmdPauseImpl        lda       #$01      set clock-state to paused
                    sta       >$0102    set clock_state = 1
                    lbsr      events_clear events_clear
                    leau      >PauseMsg,pcr get addr of game paused msg
                    lbsr      message_box pass it to message_box()
                    clr       >$0102    set clock_state = 0
                    rts

cmd_quit
CmdQuitImpl         lda       ,y+       load quit-type argument from script
                    cmpa      #$01      check if immediate-quit requested
                    beq       DoQuitAgi if arg was a 1 then quit
                    leau      >QuitMsg,pcr get addr of quit / continue msg
                    lbsr      message_box pass it to message_box()
                    beq       CmdQuitReturn if we didn't get a 1 continue play

DoQuitAgi           lda       #$03      load the offset to exit_agi()
                    sta       <$0009    store exit dispatch index
                    ldx       <$0022    set up to jump to sierra
                    jsr       >$0701    mmu twiddle
CmdQuitReturn       rts

*
*======================================================================
* COMMAND DISPATCH TABLE
*   Jump table mapping each AGI command byte to its handler address and parameter descriptor word.
*======================================================================
*
* every other word gets added to by a value saved in sierra
* when this module is loaded. I assume it's a mem offset
* Jump table of some kind  but what are the second words used
* to do ????

* the first word is the pointer to the function
* the second word holds two items
*   MSB = number of parameters
*   LSB = parameter flag

cmd_table
CmdTableStart       fdb       NoopCmdsRet,$0000 *do nothing
                    fdb       cmd_increment,$180 *increment
                    fdb       cmd_decrement,$180 *decrement
                    fdb       cmd_assignn,$280 *assign nn
                    fdb       cmd_assignv,$2c0 *assign nv
                    fdb       cmd_addn,$280 *add n
                    fdb       cmd_addv,$2c0 *add v
                    fdb       cmd_subn,$280 *sub n
                    fdb       cmd_subv,$2c0 *sub v
                    fdb       cmd_lindirectv,$2c0 *l indirect v
                    fdb       cmd_rindirect,$2c0 *r indirect
                    fdb       cmd_lindirectn,$280 *l indirect n

                    fdb       CmdSetImpl,$100 *set
                    fdb       CmdResetImpl,$100 *reset
                    fdb       CmdToggleImpl,$100 *toggle
                    fdb       CmdSetVImpl,$180 *set v
                    fdb       CmdResetVImpl,$180 *reset v
                    fdb       CmdToggleVImpl,$180 *toggle v

                    fdb       cmd_new_room,$100 *new room
                    fdb       cmd_new_room_v,$180 *new room v

                    fdb       cmd_load_logics,$100 *load logics
                    fdb       cmd_load_logics_v,$180 *load logics v
                    fdb       cmd_call,$100 *call
                    fdb       cmd_call_v,$180 *call v

                    fdb       cmd_load_pic,$180 *load pic
                    fdb       cmd_draw_pic,$180 *draw pic
                    fdb       cmd_show_pic,$0000 *show pic
                    fdb       cmd_discard_pic,$180 *discard overlay
                    fdb       cmd_overlay_pic,$180 *animate obj

                    fdb       CmdSaveGame,$0000 *show pri

                    fdb       cmd_load_view,$100 *load view
                    fdb       cmd_load_view_v,$180 *load view v
                    fdb       cmd_discard_view,$100 *discard view

                    fdb       CmdAnimateObj,$100 *animate obj
                    fdb       CmdUnanimateAll,$0000 *unanumate all

                    fdb       CmdDrawImpl,$100 *draw
                    fdb       CmdEraseImpl,$100 *erase

                    fdb       cmd_position,$300 *position
                    fdb       cmd_position_v,$360 *position v
                    fdb       cmd_get_position,$360 *get position
                    fdb       cmd_reposition,$360 *reposition

                    fdb       cmd_set_view,$200 *set view
                    fdb       cmd_set_view_v,$240 *set view v
                    fdb       cmd_set_loop,$200 *set loop
                    fdb       cmd_set_loop_v,$240 *set loop v

                    fdb       CmdFixLoop,$100 *fix loop
                    fdb       CmdReleaseLoop,$100 *release loop

                    fdb       cmd_set_cel,$200 *set cel
                    fdb       cmd_set_cel_v,$240 *set cel v
                    fdb       cmd_last_cel,$240 *last cel
                    fdb       cmd_current_cel,$240 *current cel
                    fdb       cmd_current_loop,$240 *current loop
                    fdb       cmd_current_view,$240 *current view
                    fdb       cmd_number_of_loops,$240 *number of loops

                    fdb       cmd_set_priority,$200 *set priority
                    fdb       cmd_set_priority_v,$240 *set priority v
                    fdb       cmd_release_priority,$100 *release priority
                    fdb       cmd_get_priority,$240 *get priority

                    fdb       CmdStopUpdate,$100 *stop update
                    fdb       CmdStartUpdate,$100 *start update
                    fdb       CmdForceUpdate,$100 *force update

                    fdb       cmd_ignore_horizon,$100 *ignore horizon
                    fdb       cmd_observe_horizon,$100 *observe horizon
                    fdb       cmd_set_horizon,$100 *set horizon
                    fdb       cmd_obj_on_water,$100 *obj on water
                    fdb       cmd_obj_on_land,$100 *obj on land
                    fdb       cmd_obj_on_anything,$100 *obj on anything

                    fdb       CmdIgnoreObjects,$100 *ignore objects
                    fdb       CmdObserveObjects,$100 *observe objects
                    fdb       CmdDistance,$320 *distance
                    fdb       CmdStopCycling,$100 *stop cycling
                    fdb       CmdStartCycling,$100 *start cycling
                    fdb       CmdNormalCycle,$100 *normal cycle
                    fdb       CmdEndOfLoop,$200 *end of loop
                    fdb       CmdReverseCycle,$100 *reverse cycle
                    fdb       CmdReverseLoop,$200 *reverse loop
                    fdb       CmdSetCycleTime,$240 *cycle time

                    fdb       cmd_stop_motion,$100 *stop motion
                    fdb       cmd_start_motion,$100 *start motion
                    fdb       cmd_step_size_v,$240 *step size
                    fdb       cmd_step_time,$240 *step time
                    fdb       cmd_move_obj,$500 *move obj
                    fdb       cmd_move_obj_v,$570 *move obj v
                    fdb       cmd_follow_ego,$300 *follow ego
                    fdb       cmd_wander,$100 *wander
                    fdb       cmd_normal_motion,$100 *normal motion
                    fdb       cmd_set_dir,$240 *set dir

                    fdb       cmd_get_dir,$240 *get dir

                    fdb       CmdIgnoreBlocks,$100 *ignore blocks
                    fdb       CmdObserveBlocks,$100 *observe blocks
                    fdb       CmdSetBlock,$400 *block
                    fdb       CmdClearBlock,$0000 *unblock

                    fdb       cmd_get,$100 *get
                    fdb       cmd_get_v,$180 *get v
                    fdb       cmd_drop,$100 *drop
                    fdb       cmd_put,$200 *put
                    fdb       cmd_put_v,$240 *put v
                    fdb       cmd_get_room_v,$2c0 *get room v

                    fdb       cmd_load_sound,$100 *load sound
                    fdb       cmd_sound,$200 *sound
                    fdb       NoopCmdsRet,$0000 *stop sound
                    fdb       cmd_print,$100 *print
                    fdb       cmd_print_v,$180 *print v
                    fdb       cmd_display,$300 *display

                    fdb       cmd_display_v,$3e0 *display v
                    fdb       cmd_clear_lines,$300 *clear lines
                    fdb       cmd_text_screen,$0000 *text screen
                    fdb       cmd_graphics,$0000 *graphics
                    fdb       cmd_set_cursor_char,$100 *set cursor char
                    fdb       cmd_set_text_attribute,$200 *set text attribute
                    fdb       cmd_shake_screen,$100 *shake screen
                    fdb       cmd_config_screen,$300 *config screen
                    fdb       cmd_status_line_on,$0000 *status line on
                    fdb       cmd_status_line_off,$0000 *status line off

                    fdb       cmd_set_string,$200 *set string
                    fdb       cmd_get_string,$500 *get string
                    fdb       cmd_word_to_string,$200 *word to string
                    fdb       cmd_parse,$100 *parse
                    fdb       CmdObjStatus,$240 *get num
                    fdb       cmd_prevent_input,$0000 *prevent input
                    fdb       cmd_accept_input,$0000 *accept inpur
                    fdb       CmdSetKey,$300 *set key
                    fdb       cmd_add_to_pic,$700 *add to pic
                    fdb       cmd_add_to_pic_v,$7fe *add to pic v
                    fdb       cmd_status,$0000 *status
                    fdb       cmd_save_game,$0000 *save game
                    fdb       cmd_restore_game,$0000 *restore game
                    fdb       NoopCmdsRet,$0000 *init disk
                    fdb       cmd_restart_game,$0000 *restart game
                    fdb       cmd_show_obj,$100 *sow obj
                    fdb       CmdRandomImpl,$320 *random
                    fdb       cmd_program_control,$0000 *program control
                    fdb       cmd_player_control,$0000 *player control
                    fdb       CmdObjStatusV,$180 *obj status v
                    fdb       CmdQuitImpl,$100 *quit
                    fdb       CmdShowMemInfo,$0000 *show mem
                    fdb       CmdPauseImpl,$0000 *pause
                    fdb       cmd_echo_line,$0000 *echo line
                    fdb       cmd_cancel_line,$0000 *cancel line
                    fdb       cmd_init_joy,$0000 *init joy
                    fdb       cmd_toggle_monitor,$0000 *toggle monitor
                    fdb       CmdShowAgiInfo,$0000 *version
                    fdb       cmd_script_size,$100 *script size
                    fdb       cmd_set_game_id,$100 *set game id
                    fdb       cmd_shake_screen,$100 *log
                    fdb       cmd_set_scan_start,$0000 *set scan start
                    fdb       cmd_reset_scan_start,$0000 *reset scan start
                    fdb       cmd_reposition_to,$300 *reposition to
                    fdb       cmd_reposition_to_v,$360 *reposition to v
                    fdb       cmd_trace_on,$0000 *trace on
                    fdb       cmd_trace_info,$300 *trace info
                    fdb       cmd_print_at,$400 *print at
                    fdb       cmd_print_at_v,$480 *print at v
                    fdb       cmd_discard_view_v,$180 *discard view v
                    fdb       cmd_clear_text_rect,$500 *clear text rect
                    fdb       cmd_set_upper_left,$200 *set upper left
                    fdb       cmd_set_menu,$100 *set menu
                    fdb       cmd_set_menu_item,$200 *set menu item
                    fdb       cmd_submit_menu,$0000 *submit menu
                    fdb       cmd_enable_item,$100 *enable item
                    fdb       cmd_disable_item,$100 *disable item
                    fdb       cmd_menu_input,$0000 *menu input
                    fdb       cmd_show_obj_v,$100 *show obj v
                    fdb       NoopCmdsRet,$0000 *open dialogue
                    fdb       NoopCmdsRet,$0000 *close dialogue
                    fdb       cmd_multn,$280 *mult n
                    fdb       cmd_multv,$2c0 *mult v
                    fdb       cmd_divn,$280 *div n
                    fdb       cmd_divv,$2c0 *div v
                    fdb       cmd_close_window,$0000 *close window
                    fdb       cmd_set_simple,$100 *set simple
                    fdb       cmd_push_script,$0000 *push script
                    fdb       cmd_pop_script,$0000 *pop script
                    fdb       NoopCmdsRet,$0000 *hold key
                    fdb       SetPriBaseStub,$100 *set pri base, via patch stub
                    fdb       cmd_shake_screen,$180 *discard sound
                    fdb       NoopCmdsRet,$0000 *do nothing
                    fdb       cmd_show_menu,$100
                    fdb       NoopCmdsRet,$0000 *do nothing
                    fdb       cmd_hide_mouse,$400 *hide mouse
                    fdb       cmd_set_upper_left,$2c0 *allow menu
                    fdb       NoopCmdsRet,$0000 *do nothing

*
*======================================================================
* COMMAND DISPATCH ENGINE
*   Patches cmd_table with the module's load address, then dispatches a command by index.
*======================================================================
*
PatchCmdTable       leas      -$01,s    allocate one byte loop counter on stack
                    lda       #$B6      load count of 182 table entries
                    sta       ,s        save loop count
                    leau      >CmdTableStart,pcr point U to start of command table
PatchCmdTableLoop   ldd       <$002E    load Sierra module base address offset
                    addd      ,u        add to table entry pointer value
                    std       ,u        store relocated address back in table
                    leau      $04,u     advance to next 4-byte table entry
                    dec       ,s        decrement loop counter
                    bne       PatchCmdTableLoop loop until all entries relocated
                    leas      $01,s     release stack counter byte
                    rts
DispatchCmd         cmpb      #$B5      check if command index in range
                    bls       CheckTraceFlag branch if valid command number
                    lda       #$10      load error code for bad command
                    lbsr      ReportError
CheckTraceFlag      lda       <$0068    check if trace/debug mode active
                    beq       CallCmdHandler branch if trace disabled
                    cmpa      #$01      compare trace mode level
                    bne       CallCmdHandler branch if not single-step mode
                    pshs      y         save Y (script pointer) for trace
                    lbsr      ScriptDispatch
                    puls      y         restore Y after trace display
CallCmdHandler      leax      >cmd_table,pcr point X to command jump table
                    lda       #$04      each entry is 4 bytes wide
                    mul                 multiply command index by 4
                    jsr       [d,x]     indirect call through table entry
                    leay      ,y        test Y (next script byte pointer)
                    beq       DispatchCmdReturn branch if Y is null (end of script)
                    ldb       ,y+       fetch next opcode byte
                    beq       DispatchCmdReturn branch if opcode is zero (end of block)
                    cmpb      #$FC      check for special opcode threshold
                    bcs       DispatchCmd branch if another normal command follows
DispatchCmdReturn   rts
*
*======================================================================
* OBJECT ANIMATION — CEL CYCLING
*   Advance an animated object's cel frame, handling normal, reverse, end-of-loop, and reverse-end-of-loop cycle modes.
*======================================================================
*
AdvanceCelFrame     lda       <$25,u    load object animation flags
                    bita      #$10      test single-cycle-advance flag
                    beq       GetCelIndex branch if normal cycling
                    anda      #$EF      clear single-advance flag
                    sta       <$25,u    store updated flags
                    bra       AdvCelReturn done for this cycle
GetCelIndex         ldd       $0E,u     load current cel number (A) and last cel (B)
                    decb                decrement last-cel index for comparison
                    std       <$0074    save current and max cel indices
                    lda       <$23,u    load cycle mode
                    cmpa      #$00      check if forward cycling
                    bne       CycleReverse branch if not forward cycle
                    ldb       <$0074    reload current cel index
                    incb                advance to next cel
                    cmpb      <$0075    compare to maximum cel index
                    bls       SetCelInLoop branch if still within range
                    clrb                wrap back to cel 0
                    bra       SetCelInLoop go set the new cel
CycleReverse        cmpa      #$03      check if reverse-cycle mode
                    bne       CycleRevEnd branch if not reverse cycling
                    ldb       <$0074    load current cel index
                    decb                step back one cel
                    bpl       SetCelInLoop branch if still >= 0
                    ldb       <$0075    wrap to last cel
                    bra       SetCelInLoop go set the new cel
CycleRevEnd         cmpa      #$02      check if end-of-loop mode
                    bne       CycleEnd  branch if not end-of-loop
                    ldb       <$0074    load current cel index
                    beq       NotifyEndOfLoop branch if already at cel 0
                    decb                step back one cel
                    bne       SetCelInLoop branch if not yet at cel 0
                    stb       <$0074    save cel index (0)
                    bra       NotifyEndOfLoop signal end of loop
CycleEnd            cmpa      #$01      check if end-of-forward-loop mode
                    bne       SetCelInLoop branch if none of the special modes
                    ldb       <$0074    load current cel index
                    cmpb      <$0075    compare to last cel
                    bcc       NotifyEndOfLoop branch if at or past last cel
                    incb                advance to next cel
                    cmpb      <$0075    compare to last cel again
                    bne       SetCelInLoop branch if not yet at end
                    stb       <$0074    save last cel index
NotifyEndOfLoop     lda       <$27,u    load end-of-loop flag number
                    lbsr      SetFlag   set the end-of-loop flag
                    lda       <$26,u    load object state flags
                    anda      #$DF      clear loop-active bit
                    sta       <$26,u    store updated state
                    clra                clear zero value
                    sta       <$21,u    halt object direction (stop)
                    sta       <$23,u    clear cycle mode
                    ldb       <$0074    reload final cel index
SetCelInLoop        lbsr      SetCelHelper
AdvCelReturn        rts
*
*======================================================================
* OBJECT ANIMATION — LOOP CONTROL
*   Commands to fix and release an object's loop selection.
*======================================================================
*
CmdFixLoop          lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,x       transfer computed address to X
                    lda       <$25,x    load object animation flags
                    ora       #$20      set loop-fix flag
                    sta       <$25,x    store updated flags
                    rts
CmdReleaseLoop      lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,x       transfer computed address to X
                    lda       <$25,x    load object animation flags
                    anda      #$DF      clear loop-fix flag
                    sta       <$25,x    store updated flags
                    rts
*
*======================================================================
* OBJECT TERRAIN CLASSIFICATION
*   Predicates and range-list management for water-only and land-only object constraints.
*======================================================================
*
IsOnWater           lda       #$01      assume on water (default true)
                    ldb       <$26,u    load object terrain flags
                    andb      #$51      isolate water/terrain bits
                    cmpb      #$51      check if all water bits set
                    beq       IsOnWaterOk branch if object is on water
                    clra                not on water, return false
IsOnWaterOk         rts
IsOnLand            lda       #$01      assume on land (default true)
                    ldb       <$26,u    load object terrain flags
                    andb      #$51      isolate water/terrain bits
                    cmpb      #$41      check if land bits set
                    beq       IsOnLandOk branch if object is on land
                    clra                not on land, return false
IsOnLandOk          rts
SetWaterRange       ldx       #$0548    point to water object range list
                    leau      >IsOnWater,pcr load address of water-check predicate
                    lbsr      ScanViewObjs
                    rts
SetLandRange        ldx       #$054C    point to land object range list
                    leau      >IsOnLand,pcr load address of land-check predicate
                    lbsr      ScanViewObjs
                    rts
ClearBothRanges     ldx       #$0548    point to water range list
                    lbsr      BlitListDraw
                    ldx       #$054C    point to land range list
                    lbsr      BlitListDraw
                    rts
SwapObjRanges       bsr       SetLandRange classify objects by land terrain
                    pshs      x         save X across MMU call
                    lda       #$1E      MMU function: swap land ranges
                    sta       <$0021    store function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    bsr       SetWaterRange classify objects by water terrain
                    pshs      x         save X across MMU call
                    lda       #$1E      MMU function: swap water ranges
                    sta       <$0021    store function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    rts
UpdateObjSegments   ldx       #$054C    point to land object segment list
                    pshs      x         pass list pointer as argument
                    lda       #$18      MMU function: update segments
                    sta       <$0019    store function code
                    ldx       <$0026    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    ldx       #$0548    point to water object segment list
                    pshs      x         pass list pointer as argument
                    lda       #$18      MMU function: update segments
                    sta       <$0019    store function code
                    ldx       <$0026    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    rts
ResetObjRanges      ldx       #$0548    point to water range list
                    lbsr      ProcessDrawList
                    ldx       #$054C    point to land range list
                    lbsr      ProcessDrawList
                    rts
*
*======================================================================
* OBJECT UPDATE CONTROL
*   Commands to stop, start, and force the per-cycle screen-update step for an object.
*======================================================================
*
CmdStopUpdate       lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    bsr       StopUpdateHelper
                    rts
CmdStartUpdate      lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    bsr       StartUpdateHelper
                    rts
CmdForceUpdate      lda       ,y+       load object number from script (unused)
                    bsr       ClearBothRanges erase both terrain range lists
                    bsr       SwapObjRanges swap MMU object range pages
                    bsr       UpdateObjSegments update segment mappings for all objects
                    rts
*
*======================================================================
* OBJECT UPDATE HELPERS
*   Internal helpers that set/clear the O_UPDATE flag and refresh the object's screen segments.
*======================================================================
*
StopUpdateHelper    lda       <$26,u    load object state flags
                    bita      #$10      test animated/visible flag
                    beq       StopUpdateReturn branch if already stopped
                    pshs      u         save object pointer
                    lbsr      ClearBothRanges erase object from both range lists
                    puls      u         restore object pointer
                    lda       <$26,u    reload object state flags
                    anda      #$EF      clear animated/visible flag
                    sta       <$26,u    store updated flags
                    lbsr      SwapObjRanges
StopUpdateReturn    rts
StartUpdateHelper   lda       <$26,u    load object state flags
                    bita      #$10      test animated/visible flag
                    bne       StartUpdateReturn branch if already updating
                    pshs      u         save object pointer
                    lbsr      ClearBothRanges erase object from both range lists
                    puls      u         restore object pointer
                    lda       <$26,u    reload object state flags
                    ora       #$10      set animated/visible flag
                    sta       <$26,u    store updated flags
                    lbsr      SwapObjRanges
StartUpdateReturn   rts
DirTableFwd         fcb       4,4,0,0,0,4,1,1,1
DirTableRev         fcb       4,3,0,0,0,2,1,1,1

*
*======================================================================
* ANIMATE / UNANIMATE
*   Commands to start or stop animation for an object or all objects.
*======================================================================
*
CmdAnimateObj       lda       ,y+       load object number from script
                    bsr       AnimateObjHelper
                    rts
AnimateObjHelper    leas      -$01,s    save one byte for object number
                    sta       ,s        store object number
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    cmpu      <$0032    compare to first valid object pointer
                    bcs       AnimObjBadIndex branch if object index too small (invalid)
                    lda       #$0D      load "animate invalid object" error code
                    ldb       ,s        reload object number for error report
                    lbsr      ReportError
AnimObjBadIndex     lda       <$26,u    load object state flags
                    bita      #$40      check if already animated
                    bne       AnimObjAlready branch if already in animated state
                    lda       #$70      initial state: stopped, no loop fix
                    sta       <$26,u    store initial animation flags
                    lda       #$00      zero value
                    sta       <$22,u    clear object's step timer
                    sta       <$23,u    clear cycle mode
                    sta       <$21,u    clear direction (stopped)
AnimObjAlready      leas      $01,s     release stack byte
                    rts
CmdUnanimateAll     lbsr      ClearBothRanges erase all objects from range lists
                    ldu       <$0030    load pointer to first object
UnanimateAllLoop    cmpu      <$0032    compare to end of object table
                    bcc       UnanimateAllDone branch if past last object
                    lda       <$26,u    load object state flags
                    anda      #$BE      clear animated and visible flags
                    sta       <$26,u    store updated flags
                    leau      <$2B,u    advance to next object struct
                    bra       UnanimateAllLoop loop through all objects
UnanimateAllDone    rts
*
*======================================================================
* PER-CYCLE OBJECT UPDATE
*   Iterates all objects each cycle: advances animation, checks cycle types, and triggers direction-based loop selection.
*======================================================================
*
UpdateAllObjs       leas      -$01,s    allocate one byte update-happened flag
                    clr       ,s        clear update flag
                    ldu       <$0030    load pointer to first object
UpdateAllLoop       cmpu      <$0032    compare to end-of-object-table pointer
                    bcc       UpdateAllPostLoop branch if past all objects
                    lda       <$26,u    load object state flags
                    anda      #$51      isolate animated+visible bits
                    cmpa      #$51      check if object is animated and visible
                    bne       NextObjInUpdateLoop branch if not active
                    inc       ,s        mark that at least one object updated
                    ldb       #$04      default loop direction: 4 (no change)
                    lda       <$25,u    load animation control flags
                    bita      #$20      test loop-fix flag
                    bne       CheckCycleTick branch if loop is fixed (skip dir table)
                    lda       $0B,u     load number of loops in view
                    cmpa      #$03      compare to 3 loops
                    bhi       CheckCycleType4 branch if more than 3 loops
                    cmpa      #$02      compare to 2 loops
                    bcs       CheckCycleTick branch if fewer than 2 loops
                    lda       <$21,u    load current movement direction
                    leay      >DirTableFwd,pcr point to forward direction table
                    ldb       a,y       look up loop index from direction
                    bra       CheckObjVisible go validate the loop index
CheckCycleType4     cmpa      #$04      check if exactly 4 loops
                    beq       LookupRevDirTable branch if 4 loops (use reverse table)
                    lda       >$01B0    load player control flags
                    anda      #$08      test reverse-direction enable bit
                    beq       CheckCycleTick branch if reverse dir not enabled
LookupRevDirTable   lda       <$21,u    load current movement direction
                    leay      >DirTableRev,pcr point to reverse direction table
                    ldb       a,y       look up reverse loop index
CheckObjVisible     lda       $01,u     load object visibility/draw flag
CheckObjIsEgo       cmpa      #$01      check if this is the ego object
                    bne       CheckCycleTick branch if not ego
                    cmpb      #$04      check if loop 4 (special ego loop)
                    beq       CheckCycleTick branch if loop 4 (skip set-loop for ego)
                    cmpb      $0A,u     compare to current loop
                    beq       CheckCycleTick branch if already on correct loop
                    lbsr      SetLoopHelper
CheckCycleTick      lda       <$26,u    load object state flags
                    bita      #$20      test cycling-enabled flag
                    beq       NextObjInUpdateLoop branch if cycling disabled
                    lda       <$20,u    load cycle delay counter
                    beq       NextObjInUpdateLoop branch if delay not expired yet
                    dec       <$20,u    decrement cycle delay counter
                    bne       NextObjInUpdateLoop branch if counter not zero
                    lbsr      AdvanceCelFrame advance animation one frame
                    lda       <$1F,u    load cycle time (delay reset value)
                    sta       <$20,u    reset cycle delay counter
NextObjInUpdateLoop leau      <$2B,u    advance U to next object struct
                    bra       UpdateAllLoop loop to process next object
UpdateAllPostLoop   lda       ,s        check update-happened flag
                    beq       UpdateAllReturn branch if no objects updated
                    ldx       #$0548    point to water range list
                    lbsr      BlitListDraw
                    lbsr      UpdateAllMotion
                    lbsr      SetWaterRange
                    pshs      x         save X across MMU call
                    lda       #$1E      MMU function: swap water ranges
                    sta       <$0021    store MMU function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    ldx       #$0548    point to water range list again
                    pshs      x         save X across MMU call
                    lda       #$18      MMU function: update segments
                    sta       <$0019    store MMU function code
                    ldx       <$0026    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    ldu       <$0030    load ego object pointer
                    lda       <$25,u    load ego animation flags
                    anda      #$F6      clear step-size and advance bits
                    sta       <$25,u    store updated flags
UpdateAllReturn     leas      $01,s     release stack flag byte
                    rts
*
*======================================================================
* OBJECT MOTION DISPATCH
*   Iterates all objects and calls the appropriate motion handler (normal, wander, follow, move-to).
*======================================================================
*
DispatchMotion      ldu       <$0030    load pointer to first object
MotionObjLoop       cmpu      <$0032    compare to end-of-object-table pointer
                    bcc       DispatchMotionDone branch if past all objects
                    lda       <$26,u    load object state flags
                    anda      #$51      isolate animated+visible bits
                    cmpa      #$51      check if object is animated and visible
                    bne       NextMotionObj branch if not active
                    lda       $01,u     load object draw/visibility flag
                    cmpa      #$01      check if object is visible
                    bne       NextMotionObj branch if not visible
                    lda       <$22,u    load motion type
                    beq       MotionCheckBlock branch if no special motion (type 0)
                    cmpa      #$01      check for wander motion type
                    bne       MotionTypeWander branch if not wander
                    lbsr      ObjAnimStep do random direction step
                    bra       MotionCheckBlock check for blocking after motion
MotionTypeWander    cmpa      #$02      check for follow motion type
                    bne       MotionTypeFollow branch if not follow
                    lbsr      CalcFollowDir compute direction to follow target
                    bra       MotionCheckBlock check for blocking after follow calc
MotionTypeFollow    cmpa      #$03      check for move-to motion type
                    bhi       MotionCheckBlock branch if unknown motion type
                    lbsr      SetObjMotion compute next step toward target
MotionCheckBlock    lda       <$26,u    reload object state flags
                    ldb       >$01AC    load global blocking-rect enable flag
                    bne       MotionCheckCollide branch if blocking rect is active
                    anda      #$7F      clear blocked bit (no blocking rect)
                    sta       <$26,u    store updated flags
                    bra       NextMotionObj skip collision check
MotionCheckCollide  bita      #$02      test blocked-by-control flag
                    bne       NextMotionObj branch if already flagged blocked
                    lda       <$21,u    load current direction
                    beq       NextMotionObj branch if stopped (direction 0)
                    bsr       MoveObjOneStep try to move one step in current direction
NextMotionObj       leau      <$2B,u    advance to next object struct
                    bra       MotionObjLoop loop to process next object
DispatchMotionDone  rts
*
*======================================================================
* MOVE OBJECT ONE STEP
*   Moves an object one step in its current direction, applying step size and checking for block/horizon collisions.
*======================================================================
*
MoveObjOneStep      leas      -$03,s    allocate 3 bytes: block status + saved pos
                    ldd       $03,u     load current object X,Y position
                    std       $01,s     save original position
                    lbsr      InBlockRect check if current position is in block rect
                    sta       ,s        save block status at current position
                    lda       <$21,u    load movement direction
                    beq       MoveNoBlock branch if direction is zero (stopped)
                    cmpa      #$01      check for direction 1 (up)
                    bne       MoveDir2Diagonal branch if not up
                    ldb       $02,s     load saved Y
                    subb      <$1E,u    subtract step size (move up)
                    lda       $01,s     load saved X (unchanged)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir2Diagonal    cmpa      #$02      check for direction 2 (up-right)
                    bne       MoveDir3  branch if not up-right
                    ldd       $01,s     load saved X,Y
                    adda      <$1E,u    add step size to X (move right)
                    subb      <$1E,u    subtract step size from Y (move up)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir3            cmpa      #$03      check for direction 3 (right)
                    bne       MoveDir4  branch if not right
                    lda       $01,s     load saved X
                    adda      <$1E,u    add step size (move right)
                    ldb       $02,s     load saved Y (unchanged)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir4            cmpa      #$04      check for direction 4 (down-right)
                    bne       MoveDir5  branch if not down-right
                    ldd       $01,s     load saved X,Y
                    adda      <$1E,u    add step size to X (move right)
                    addb      <$1E,u    add step size to Y (move down)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir5            cmpa      #$05      check for direction 5 (down)
                    bne       MoveDir6  branch if not down
                    ldb       $02,s     load saved Y
                    addb      <$1E,u    add step size (move down)
                    lda       $01,s     load saved X (unchanged)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir6            cmpa      #$06      check for direction 6 (down-left)
                    bne       MoveDir7  branch if not down-left
                    ldd       $01,s     load saved X,Y
                    suba      <$1E,u    subtract step from X (move left)
                    addb      <$1E,u    add step size to Y (move down)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir7            cmpa      #$07      check for direction 7 (left)
                    bne       MoveDir8  branch if not left (must be 8: up-left)
                    lda       $01,s     load saved X
                    suba      <$1E,u    subtract step size (move left)
                    ldb       $02,s     load saved Y (unchanged)
                    bra       CheckMoveCollision check if new position is blocked
MoveDir8            ldd       $01,s     load saved X,Y (direction 8: up-left)
                    suba      <$1E,u    subtract step from X (move left)
                    subb      <$1E,u    subtract step from Y (move up)
CheckMoveCollision  lbsr      InBlockRect check if new position is in block rect
                    cmpa      ,s        compare to original block status
                    bne       MoveIsBlocked branch if collision state changed
MoveNoBlock         lda       <$26,u    load object state flags
                    anda      #$7F      clear blocked flag
                    sta       <$26,u    store updated flags
                    bra       MoveOneStepReturn done, object moved successfully
MoveIsBlocked       lda       <$26,u    load object state flags
                    ora       #$80      set blocked flag
                    sta       <$26,u    store updated flags
                    clr       <$21,u    stop object (direction = 0)
                    cmpu      <$0030    check if this is the ego object
                    bne       MoveOneStepReturn branch if not ego
                    clr       >$0437    clear ego direction variable too
MoveOneStepReturn   leas      $03,s     release 3-byte stack frame
                    rts
*
*======================================================================
* BLOCK RECTANGLE COMMANDS
*   Commands to set, clear, ignore, and observe the blocking rectangle that constrains object movement.
*======================================================================
*
CmdSetBlock         lda       #$01      enable blocking rectangle
                    sta       >$01AC    store blocking-rect active flag
                    lda       ,y+       load block rect X1 (left)
                    sta       >$024E    store left edge of block rect
                    lda       ,y+       load block rect Y1 (top)
                    sta       >$024F    store top edge of block rect
                    lda       ,y+       load block rect X2 (right)
                    sta       >$023C    store right edge of block rect
                    lda       ,y+       load block rect Y2 (bottom)
                    sta       >$023D    store bottom edge of block rect
                    rts
CmdClearBlock       clr       >$01AC    disable blocking rectangle
                    rts
CmdIgnoreBlocks     lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       <$26,u    load object state flags
                    ora       #$02      set ignore-blocks flag
                    sta       <$26,u    store updated flags
                    rts
CmdObserveBlocks    lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       <$26,u    load object state flags
                    anda      #$FD      clear ignore-blocks flag
                    sta       <$26,u    store updated flags
                    rts
*
*======================================================================
* COLLISION DETECTION
*   Tests whether a position falls inside the block rectangle, and checks for collisions between objects.
*======================================================================
*
InBlockRect         leas      -$01,s    allocate one byte result on stack
                    clr       ,s        assume not in block rect
                    cmpa      >$024E    compare X to left edge
                    bls       InBlockRectReturn branch if X is left of rect (not inside)
                    cmpa      >$023C    compare X to right edge
                    bcc       InBlockRectReturn branch if X is right of rect (not inside)
                    cmpb      >$024F    compare Y to top edge
                    bls       InBlockRectReturn branch if Y is above rect (not inside)
                    cmpb      >$023D    compare Y to bottom edge
                    bcc       InBlockRectReturn branch if Y is below rect (not inside)
                    inc       ,s        inside rect: set result to 1
InBlockRectReturn   lda       ,s        load result byte
                    leas      $01,s     release stack byte
                    rts
CheckObjCollision   clra                assume no collision
                    ldb       <$25,u    load object animation flags
                    bitb      #$02      test ignore-objects flag
                    bne       CollisionReturn branch if ignoring other objects
                    ldx       <$0030    load pointer to first object
CheckCollisionLoop  cmpx      <$0032    compare to end-of-object-table pointer
                    bcc       CollisionReturn branch if past all objects (no collision)
                    ldb       <$26,x    load candidate object state flags
                    andb      #$41      isolate animated+visible bits
                    cmpb      #$41      check if candidate is animated and visible
                    bne       NextCollisionObj branch if candidate not active
                    ldb       <$25,x    load candidate animation flags
                    bitb      #$02      test ignore-objects flag
                    bne       NextCollisionObj branch if candidate ignores objects
                    ldb       $02,x     load candidate object number
                    cmpb      $02,u     compare to current object number
                    beq       NextCollisionObj branch if same object (skip self)
                    ldb       $03,u     load current object Y bottom
                    addb      <$1C,u    add height to get bottom edge
                    cmpb      $03,x     compare to candidate Y top
                    bcs       NextCollisionObj branch if current is above candidate
                    ldb       $03,x     load candidate object Y bottom
                    addb      <$1C,x    add height to get candidate bottom edge
                    cmpb      $03,u     compare to current Y top
                    bcs       NextCollisionObj branch if candidate is above current
                    ldb       $04,x     load candidate priority
                    cmpb      $04,u     compare to current priority
                    beq       CollisionDetected branch if same priority (collision)
                    bhi       CheckPriorityHigher branch if candidate priority is higher
                    ldb       <$1B,x    load candidate base priority
                    cmpb      <$1B,u    compare to current base priority
                    bhi       CollisionDetected branch if candidate has higher base priority
                    bra       NextCollisionObj no collision
CheckPriorityHigher ldb       <$1B,x    load candidate base priority
                    cmpb      <$1B,u    compare to current base priority
                    bcs       CollisionDetected branch if candidate has lower base priority
NextCollisionObj    leax      <$2B,x    advance to next object struct
                    bra       CheckCollisionLoop loop to check next object
CollisionDetected   lda       #$01      return 1 (collision detected)
CollisionReturn     rts
*
*======================================================================
* OBJECT INTERACTION FLAGS
*   Commands to ignore or observe object-to-object collisions, and to measure the distance between two objects.
*======================================================================
*
CmdIgnoreObjects    lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       <$25,u    load object animation flags
                    ora       #$02      set ignore-objects flag
                    sta       <$25,u    store updated flags
                    rts
CmdObserveObjects   lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       <$25,u    load object animation flags
                    anda      #$FD      clear ignore-objects flag
                    sta       <$25,u    store updated flags
                    rts
CmdDistance         lda       ,y+       load first object number
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,x       transfer first object address to X
                    lda       ,y+       load second object number
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer second object address to U
                    lda       #$FF      default distance = 255 (max)
                    ldb       <$26,x    load first object state flags
                    bitb      #$01      test drawn/visible flag
                    beq       StoreDistResult branch if first object not visible
                    ldb       <$26,u    load second object state flags
                    bitb      #$01      test drawn/visible flag
                    beq       StoreDistResult branch if second object not visible
                    lda       <$1C,u    load second object width
                    lsra                halve width to get center offset
                    adda      $03,u     add Y to get center Y
                    ldb       <$1C,x    load first object width
                    lsrb                halve width to get center offset
                    addb      $03,x     add Y to get center Y
                    stb       <$0076    save first object center Y
                    suba      <$0076    subtract to get delta Y
                    bcc       CalcDistStoreX branch if delta is positive
                    nega                negate to get absolute delta Y
CalcDistStoreX      sta       <$0076    save absolute delta Y
                    lda       $04,u     load second object X position
                    suba      $04,x     subtract first object X
                    bcc       CalcDistAddY branch if delta X is positive
                    nega                negate to get absolute delta X
CalcDistAddY        adda      <$0076    add absolute delta Y to get Manhattan distance
                    bcs       DistMaxOut branch if sum overflowed (distance > 255)
                    cmpa      #$FF      check if distance equals max
                    bne       StoreDistResult branch if distance is not 255
DistMaxOut          lda       #$FE      cap distance at 254
StoreDistResult     ldb       ,y+       load destination variable number
                    ldx       #$0431    point to variable table
                    abx                 index to destination variable
                    sta       ,x        store computed distance
                    rts
*
*======================================================================
* INPUT BUFFER AND KEY TABLE
*   Clears the raw input buffer, and manages the user-defined key-to-variable mapping table.
*======================================================================
*
ClearInputBuffer    ldu       #$05BA    point U to start of input buffer area
                    ldx       #$0032    load count of 50 bytes to clear
                    clrb                zero fill value
                    lbsr      FillMem   zero-fill the 50-byte input buffer
                    rts
CmdSetKey           ldx       #$01D8    point X to start of key table
                    lda       #$32      load count of 50 key slots to scan
ScanKeyTableLoop    tst       ,x        check if current slot is empty
                    beq       KeySlotFound branch if empty slot found
                    deca                decrement remaining slot count
                    bne       NextKeySlot branch if more slots to check
                    ldx       #$0000    no slot found, use null pointer
                    bra       KeySlotFound proceed with null (discard key)
NextKeySlot         leax      $02,x     advance to next 2-byte key slot
                    bra       ScanKeyTableLoop loop to check next slot
KeySlotFound        lda       ,y+       load key code high byte from script
                    ldb       ,y+       load key code low byte from script
                    beq       StoreKeyEntry branch if modifier byte is zero
                    tfr       b,a       transfer modifier to A
                    adda      #$FB      adjust modifier code
StoreKeyEntry       ldb       ,y+       load target variable number
                    leax      ,x        test if slot pointer is null
                    beq       KeyDone   branch if no slot available
                    std       ,x        store key code into key table slot
KeyDone             rts
*
*======================================================================
* CYCLE TYPE COMMANDS
*   Commands controlling how an object's cel sequence advances: normal, end-of-loop, reverse, reverse-end-of-loop, and cycle time.
*======================================================================
*
CmdNormalCycle      lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       #$00      cycle mode 0 = normal forward
                    sta       <$23,u    store cycle mode
                    lda       <$26,u    load object state flags
                    ora       #$20      set cycling-enabled flag
                    sta       <$26,u    store updated flags
                    rts
CmdEndOfLoop        lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       #$01      cycle mode 1 = end-of-loop
                    sta       <$23,u    store cycle mode
                    ldd       <$25,u    load animation flags (both bytes)
                    ora       #$10      set single-advance flag in A
                    orb       #$30      set loop-fix and cycling flags in B
                    std       <$25,u    store updated animation flags
                    lda       ,y+       load end-of-loop flag number
                    sta       <$27,u    store flag to set when loop ends
                    lbsr      ClearFlag clear end-of-loop flag before cycling
                    rts
CmdReverseCycle     lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       #$03      cycle mode 3 = reverse cycle
                    sta       <$23,u    store cycle mode
                    lda       <$26,u    load object state flags
                    ora       #$20      set cycling-enabled flag
                    sta       <$26,u    store updated flags
                    rts
CmdReverseLoop      lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       #$02      cycle mode 2 = reverse-loop
                    sta       <$23,u    store cycle mode
                    ldd       <$25,u    load animation flags (both bytes)
                    ora       #$10      set single-advance flag in A
                    orb       #$30      set loop-fix and cycling flags in B
                    std       <$25,u    store updated animation flags
                    lda       ,y+       load end-of-loop flag number
                    sta       <$27,u    store flag to set when reverse loop ends
                    lbsr      ClearFlag clear end-of-reverse-loop flag
                    rts
CmdSetCycleTime     lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    ldb       ,y+       load variable number for cycle time
                    ldx       #$0431    point to variable table
                    abx                 index to the cycle-time variable
                    lda       ,x        load cycle time value from variable
                    sta       <$1F,u    store as cycle time (delay preset)
                    sta       <$20,u    store as current cycle counter
                    rts
CmdStopCycling      lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       <$26,u    load object state flags
                    anda      #$DF      clear cycling-enabled flag
                    sta       <$26,u    store updated flags
                    rts
CmdStartCycling     lda       ,y+       load object number from script
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer computed address to U
                    lda       <$26,u    load object state flags
                    ora       #$20      set cycling-enabled flag
                    sta       <$26,u    store updated flags
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

*
*======================================================================
* BUILT-IN DEBUG COMMANDS
*   Handlers for obj_status, show_mem, and version — diagnostic commands
*   that display interpreter state.
*======================================================================
*
CmdObjStatus        leas      -$54,s    allocate 84-byte local buffer on stack
                    lbsr      InputEditOn
                    lda       $01d7     load input row
                    clrb                clear column to 0
                    std       <$0040    set cursor position
                    ldb       ,y+       load message number from script
                    lbsr      GetMsgPtr get pointer to message text
                    leax      $04,s     point X to local string buffer
ObjStatusLoop       ldd       #$0028    string buffer is 40 chars wide
                    pshs      b,a       push buffer size
                    pshs      u         push message pointer
                    pshs      x         push destination buffer
                    lbsr      MsgTextSetup
                    leas      $06,s     release 3 pushed arguments
                    pshs      x         push formatted string pointer
                    lbsr      PrintFmtStrToScr
                    leas      $02,s     release pushed argument
                    clr       ,s        clear buffer before editing
                    ldb       #$04      max edit length = 4 chars
                    leax      ,s        point X to input buffer
                    lbsr      EditString prompt for object status input
                    lbsr      InputRedraw
                    leax      ,s        point X to entered string
                    lbsr      StrLen    measure length of entered string
                    beq       ObjStatusDone branch if empty string entered
                    lbsr      AtoI      convert ASCII input to integer
ObjStatusDone       ldx       #$0431    point to variable table
                    ldb       ,y+       load destination variable number
ObjStatusStore      abx                 index to destination variable
                    sta       ,x        store result in variable
                    leas      <$54,s    release local stack frame
                    rts
* obj.status.v command
CmdObjStatusV       leas      >-$0194,s allocate 404-byte local frame on stack
                    ldx       #$0431    point to variable table
                    ldb       ,y+       load variable number
                    abx                 index to variable
                    lda       ,x        load object number from variable
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer object address to U
                    std       >$0192,s  save object address on stack
                    lda       <$23,u    load cycle type
                    cmpa      #$00      check if normal cycling
                    bne       CheckCycleType1 branch if not normal cycle
                    leax      >StrNormalCycle,pcr normal cycle
                    bra       GotCycleStr
CheckCycleType1     cmpa      #$01      check if end-of-loop mode
                    bne       CheckCycleType2 branch if not end-of-loop
                    leax      >StrEndOfLoop,pcr end of loop
                    bra       GotCycleStr
CheckCycleType2     cmpa      #$02      check if reverse-loop mode
                    bne       DefaultCycleStr branch if none of the above
                    leax      >StrReverseLoop,pcr reverse loop
                    bra       GotCycleStr
DefaultCycleStr     leax      >StrReverseCycle,pcr reverse cycle
GotCycleStr         stx       >$0190,s  save cycle type string pointer
                    lda       <$22,u    load motion type
                    cmpa      #$00      check if normal motion
                    bne       CheckMotionType1 branch if not normal motion
                    leax      >StrNormalMotion,pcr normal motion
                    bra       GotMotionStr
CheckMotionType1    cmpa      #$01      check if wander motion
                    bne       CheckMotionType2 branch if not wander
                    leax      >StrWander,pcr wander
                    bra       GotMotionStr
CheckMotionType2    cmpa      #$02      check if follow-ego motion
                    bne       BuildMoveToStr branch if not follow (must be move-to)
                    leax      >StrFollow,pcr follow
                    bra       GotMotionStr
BuildMoveToStr      clra                clear A for word construction
                    ldb       <$28,u    load target Y position
                    pshs      b,a       push Y arg for format
                    ldb       <$27,u    load target X position
                    pshs      b,a       push X arg for format
                    leax      >StrMoveTo,pcr load "move to (%d, %d)" format string
                    pshs      x         push format string pointer
                    leax      >$0132,s  point to local string buffer
                    pshs      x         push output buffer pointer
                    lbra      stub1     format string into X
MoveToFormatDone    leas      $08,s     release 4 pushed arguments
GotMotionStr        pshs      x         push motion string pointer
                    ldx       >$0192,s  load saved object address
                    pshs      x         push object address for format
                    ldu       >$0196,s  reload object address
                    ldd       <$25,u    load animation flags (both bytes)
                    pshs      b,a       push flags
                    clra                clear A for word construction
                    ldb       <$1E,u    load step size
                    pshs      b,a       push step size
                    ldb       <$24,u    load priority
                    pshs      b,a       push priority
                    ldb       <$1D,u    load Y size
                    pshs      b,a       push Y size
                    ldb       $04,u     load Y position
                    pshs      b,a       push Y position
                    ldb       <$1C,u    load X size
                    pshs      b,a       push X size
                    ldb       $03,u     load X position
                    pshs      b,a       push X position
                    ldb       $02,u     load object number
                    pshs      b,a       push object number
                    leau      >StrObjHeader,pcr load address of object header format string
                    pshs      u         push format string pointer
                    leax      <$16,s    point to local output buffer
                    pshs      x         push output buffer pointer
                    lbsr      PrintFmtStr
                    leas      <$18,s    release all pushed arguments
                    lbsr      message_box
                    leas      >$0194,s  release local stack frame
                    rts
CmdSaveGame         inc       >$0550    set save-game-in-progress flag
                    lbsr      gfx_picbuff_update update graphics buffer before UI
                    lbsr      BooleanPoll run save/restore selection UI
                    lbsr      gfx_picbuff_update restore graphics after UI
                    clr       >$0550    clear save-game-in-progress flag
                    rts
CmdShowAgiInfo      leau      >StrAgiVersion,pcr load address of version string
                    lbsr      message_box
                    rts
CmdShowMemInfo      leas      >-$00C8,s allocate 200-byte local frame on stack
                    ldd       <$0057    load max script size
                    pshs      b,a       push max script size
                    ldd       <$0053    load current heap top
                    subd      #$0776    subtract heap base to get tables size
                    pshs      b,a       push tables size
                    ldd       <$0051    load heap pointer
                    subd      <$0053    subtract to get common size
                    pshs      b,a       push common size
                    ldd       <$0055    load heap room-0 pointer
                    subd      <$0053    subtract to get rm.0 size
                    pshs      b,a       push rm.0 size
                    ldd       <0        load heap base (direct-page variable 0)
                    subd      #$0776    subtract to get available heap size
                    pshs      b,a       push available heap size
                    ldd       <$004D    load heap max used
                    pshs      b,a       push max used
                    ldd       <$004B    load heap now used
                    pshs      b,a       push heap now used
                    ldd       <$004F    load heap size
                    pshs      b,a       push heap size
                    ldd       #$FFFF    separator value
                    pshs      b,a       push separator
                    clra                clear A for word construction
                    ldb       >$0431    load current room number (variable 0)
                    leax      >StrRoom,pcr load address of room format string
                    leau      <$12,s    point to local output buffer
                    pshs      b,a       push room number
                    pshs      x         push format string pointer
                    pshs      u         push output buffer pointer
                    lbsr      PrintFmtStr
                    leas      <$18,s    release 3 arguments (6 bytes... err, all args)
                    lbsr      message_box
                    leas      >$00C8,s  release local stack frame
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

*
*======================================================================
* CONDITION EVALUATION TABLE AND ENGINE
*   Patches the eval_table with the module load address, then evaluates
*   a boolean condition expression from a logic script.
*======================================================================
*
FixupEvalTbl        leas      -1,s      allocate one byte loop counter on stack
                    lda       #$13      load count of 19 eval table entries
FixupEvalTblLoop    sta       ,s        save loop count
                    leau      >eval_table,pcr point U to start of eval table
EvalTblLoopBody     ldd       <$002E    load Sierra module base address offset
                    addd      ,u        add to eval table entry pointer value
                    std       ,u        store relocated address back in table
                    leau      $04,u     advance to next 4-byte entry
                    dec       ,s        decrement loop counter
                    bne       EvalTblLoopBody loop until all entries relocated
                    leas      $01,s     release stack counter byte
                    rts
EvalExpr            leax      -$01,y    back up one byte to point before operand
                    stx       <$006C    save expression pointer
                    cmpa      #$12      compare to max expression type
                    bhi       EvalExprUnknown branch if unknown expression type
                    lsla                multiply expression type by 4
                    lsla                (each eval table entry is 4 bytes)
                    leax      >eval_table,pcr point X to eval dispatch table
                    jsr       [a,x]     indirect call to eval handler
                    ldb       <$0068    check trace mode flag
                    beq       EvalExprRet branch if not tracing
                    cmpb      #$01      compare trace level
                    bne       EvalExprRet branch if not single-step trace
                    pshs      y         save Y across trace display
                    sta       <$006E    save eval result
                    ldu       <$006C    restore expression pointer
                    lbsr      ScriptArgDispatch display argument in trace window
                    puls      y         restore Y
                    lda       <$006E    reload eval result
                    bra       EvalExprRet
EvalExprUnknown     tfr       a,b       transfer unknown type code to B
                    lda       #$0F      load "unknown expression type" error code
                    lbsr      ReportError
EvalExprRet         rts
                    ldb       ,y+       load variable number (var==value test)
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    lda       ,x        load variable value
                    cmpa      ,y+       compare to immediate operand
                    lbne      RetFalse  branch if not equal
                    lbra      RetTrue   var==value matched, return true
                    ldb       ,y+       load first variable number (var==var test)
                    ldx       #$0431    point to variable table
                    abx                 index to first variable
                    lda       ,x        load first variable value
                    ldb       ,y+       load second variable number, advance Y
                    ldx       #$0431    point to variable table
                    abx                 index to second variable
                    cmpa      ,x        compare first to second variable
                    lbne      RetFalse  branch if not equal
                    lbra      RetTrue   var==var matched, return true
                    ldb       ,y+       load variable number (var<value test)
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    lda       ,x        load variable value
                    cmpa      ,y+       compare to immediate operand
                    lbcc      RetFalse  branch if var >= value
                    lbra      RetTrue   var<value matched, return true
                    ldb       ,y+       load first variable number (var<var test)
                    ldx       #$0431    point to variable table
                    abx                 index to first variable
                    lda       ,x        load first variable value
                    ldb       ,y+       load second variable number
                    ldx       #$0431    point to variable table
                    abx                 index to second variable
                    cmpa      ,x        compare first to second variable
                    lbcc      RetFalse  branch if first >= second
                    lbra      RetTrue   var<var matched, return true
                    ldb       ,y+       load variable number (var>value test)
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    lda       ,x        load variable value
                    cmpa      ,y+       compare to immediate operand
                    lbls      RetFalse  branch if var <= value
                    lbra      RetTrue   var>value matched, return true
                    ldb       ,y+       load first variable number (var>var test)
                    ldx       #$0431    point to variable table
                    abx                 index to first variable
                    lda       ,x        load first variable value
                    ldb       ,y+       load second variable number
                    ldx       #$0431    point to variable table
                    abx                 index to second variable
                    cmpa      ,x        compare first to second variable
                    lbls      RetFalse  branch if first <= second
                    lbra      RetTrue   var>var matched, return true
                    lda       ,y+       load flag number (isset test)
                    lbsr      TestFlag  test if flag is set
                    lbeq      RetFalse  branch if flag not set
                    lbra      RetTrue   flag is set, return true
                    ldb       ,y+       load variable number (isset.v test)
                    ldx       #$0431    point to variable table for isset.v
                    abx                 index to the flag-number variable
                    lda       ,x        load flag result (from TestFlag above)
                    lbsr      TestFlag  test flag for isset.v (flag in variable)
                    lbeq      RetFalse  branch if flag not set
                    lbra      RetTrue   isset.v matched, return true
                    rts
                    ldb       ,y+       load object number (has-object test)
                    ldx       <$0038    load pointer to object table
                    abx                 add object offset
                    abx                 (3 bytes per object entry)
                    abx                 now pointing to object location
                    lda       #$FF      load "in room" value
                    cmpa      $02,x     compare to object's room byte
                    lbne      RetFalse  branch if object not carried
                    lbra      RetTrue   has-object matched, return true
                    ldb       $01,y     load variable number (obj.in.room test)
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    lda       ,x        load room number from variable
                    ldb       ,y++      load object number, advance Y by 2
                    ldx       <$0038    load pointer to object table
                    abx                 add object offset
                    abx                 (3 bytes per object entry)
                    abx                 now pointing to object location
                    cmpa      $02,x     compare room# to object location
                    lbne      RetFalse  branch if object not in that room
                    lbra      RetTrue   obj.in.room matched, return true
                    lda       ,y+       load string index (get-string test)
                    ldx       #$05BA    point to string storage area
                    lda       a,x       load character from string slot
                    rts
                    ldx       #$0431    point to variable table (have-key test)
                    lda       <$13,x    load key-pressed variable (var 19)
                    lbne      RetTrue   branch if key already pending
*
*======================================================================
* CONDITION PREDICATES
*   Boolean test functions called by the condition engine: have_key,
*   said, posn, obj_in_box, controller, and related helpers.
*======================================================================
*
HaveKeyPollLoop     lbsr      GetKeyEvent get next keyboard event
                    cmpa      #$FF      check for no-key sentinel
                    beq       HaveKeyPollLoop branch if no key available yet
                    tsta                test if key value is non-zero
                    lbeq      RetFalse  branch if key was zero (no real key)
                    sta       <$13,x    store key in variable 19
                    lbra      RetTrue   have-key matched, return true
                    lda       ,y+       load word count argument (said test)
                    sta       <$0072    save number of words to match
                    lda       >$015A    load parsed-word count
                    beq       SaidCheckDone branch if no words parsed
                    sta       <$0073    save parsed word count
                    lda       >$01AE    load game state flags
                    anda      #$08      test said-match flag
                    bne       SaidCheckDone branch if already matched
                    lda       >$01AE    reload flags
                    anda      #$20      test player-input flag
                    beq       SaidCheckDone branch if no input to check
                    ldx       #$0194    point to parsed-words buffer
SaidMatchLoop       lda       <$0072    load remaining words to match
                    beq       SaidCheckDone branch if all words matched (success)
                    ldb       ,y+       load first byte of word ID
                    lda       ,y+       load second byte of word ID
                    dec       <$0072    decrement remaining word count
                    cmpd      #$270F    check for "any word" wildcard ($270F)
                    bne       SaidCheckWild branch if not wildcard
                    lda       <$0072    load remaining count after wildcard
                    beq       SaidSetMatch branch if at end of word list (match)
                    lsla                multiply remaining count by 2
                    leay      a,y       skip remaining word IDs in script
                    lbra      SaidSetMatch signal match
SaidCheckWild       tst       <$0073    check if any parsed words remain
                    bne       SaidWordCompare branch if more parsed words to check
                    inc       <$0073    indicate out of parsed words (no match)
                    lbra      SaidCheckDone
SaidWordCompare     cmpd      ,x++      compare word ID to parsed word (advance X)
                    beq       SaidWordMatch branch if word matches
                    cmpd      #$0001    check for "any/rest" wildcard ($0001)
                    bne       SaidCheckDone branch if no match and not wildcard
SaidWordMatch       dec       <$0073    decrement remaining parsed word count
                    bra       SaidMatchLoop loop to match next word
SaidCheckDone       ldd       <$0072    load remaining words + remaining parsed words
                    bne       SaidNoMatch branch if unmatched words remain
SaidSetMatch        lda       >$01AE    load game state flags
                    ora       #$08      set said-match flag
                    sta       >$01AE    store updated flags
                    lbra      RetTrue   said matched, return true
SaidNoMatch         lsla                multiply remaining count by 2 for word IDs
                    leay      a,y       skip unmatched word IDs in script
                    lbra      RetFalse  said not matched, return false
                    lda       ,y+       load first arg (match.word test)
                    ldb       ,y+       load second arg
                    lbsr      MatchWord test word against vocabulary
                    rts
                    bsr       GetObjViewPtr get object X and Y (posn test)
                    sta       <$006F    save left edge X
                    sta       <$0071    save right edge X (same for point test)
                    bra       TestPosnX check the position
                    bsr       GetObjViewPtr get object's X position (posn center test)
                    sta       <$006F    save left edge X
                    lda       <$1C,u    load object width
                    lsra                halve width
                    adda      <$006F    add to get center X
                    sta       <$006F    save center X as left edge
                    sta       <$0071    save center X as right edge
                    bra       TestPosnX check the position
                    bsr       GetObjViewPtr get object's X position (posn right test)
                    adda      <$1C,u    add object width to get right edge
                    deca                subtract 1 (right edge = left + width - 1)
                    sta       <$006F    save right edge as left edge
                    sta       <$0071    save right edge
                    bra       TestPosnX check the position
                    bsr       GetObjViewPtr get object's X position (posn range test)
                    sta       <$006F    save left edge X
                    adda      <$1C,u    add object width to get right edge
                    deca                subtract 1 (right edge = left + width - 1)
                    sta       <$0071    save right edge X
                    bra       TestPosnX check the position
GetObjViewPtr       ldb       ,y+       load object number from script
                    lda       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer object address to U
                    ldd       $03,u     load object X (A) and Y (B) position
                    stb       <$0070    save Y position to temp
                    rts
TestPosnX           ldd       <$006F    load left/right X edge values
                    cmpa      ,y+       compare left edge to rect left boundary
                    bcc       TestPosnY branch if left edge >= rect left (inside or right)
                    leay      $03,y     skip remaining 3 boundary bytes
                    bra       RetFalse  object is left of rect
TestPosnY           cmpb      ,y+       compare Y to rect top boundary
                    bcc       TestPosnXRight branch if Y >= rect top (inside or below)
                    leay      $02,y     skip remaining 2 boundary bytes
                    bra       RetFalse  object is above rect
TestPosnXRight      lda       <$0071    load right X edge value
                    cmpa      ,y+       compare right edge to rect right boundary
                    bls       TestPosnYBot branch if right edge <= rect right (inside or left)
                    leay      $01,y     skip remaining 1 boundary byte
                    bra       RetFalse  object is right of rect
TestPosnYBot        cmpb      ,y+       compare Y to rect bottom boundary
                    bls       RetTrue   branch if Y <= rect bottom (inside)
                    bra       RetFalse  object is below rect
RetTrue             lda       #$01      return 1 (condition true)
                    rts
RetFalse            clra                return 0 (condition false)
                    rts
*
*======================================================================
* DRAW AND ERASE OBJECT COMMANDS
*   Handlers for the AGI draw and erase commands; place or remove an
*   animated object from the visible/priority screens.
*======================================================================
*
CmdDrawImpl         lda       ,y+       load object number from script
                    pshs      y         save script pointer across helper call
                    bsr       DrawObjHelper
                    puls      y         restore script pointer
                    rts
DrawObjHelper       leas      -$03,s    allocate 3-byte local frame on stack
                    sta       ,s        save object number
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer object address to U
                    cmpu      <$0032    compare to first valid object pointer
                    bcs       DrawObjCheckView branch if valid object index
                    lda       #$13      load "draw invalid object" error code
                    ldb       ,s        reload object number for error report
                    lbsr      ReportError
DrawObjCheckView    ldd       <$10,u    load object's view pointer
                    bne       DrawObjStart branch if view is assigned
                    lda       #$14      load "draw object without view" error code
                    lbsr      ReportError
DrawObjStart        lda       <$26,u    load object state flags
                    bita      #$01      test already-drawn flag
                    bne       DrawObjDone branch if object already visible
                    stu       $01,s     save object pointer
                    ora       #$10      set update-needed flag
                    sta       <$26,u    store updated flags
                    lbsr      FindObjPos compute object screen position
                    ldd       <$10,u    load view pointer (pic page handle)
                    std       <$12,u    save as current draw page
                    ldd       $08,u     load volume file handle
                    std       <$14,u    save as current volume handle
                    ldd       $03,u     load object X,Y position
                    std       <$1A,u    save as previous position
                    ldx       #$0548    point to water range list
                    lbsr      BlitListDraw
                    ldu       $01,s     reload object pointer
                    lda       <$26,u    load object state flags
                    ora       #$01      set drawn/visible flag
                    sta       <$26,u    store updated flags
                    lbsr      SetWaterRange
                    pshs      x         save X across MMU call
                    lda       #$1E      MMU function: swap water ranges
                    sta       <$0021    store MMU function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    ldu       $01,s     reload object pointer
                    lda       <$25,u    load animation flags
                    anda      #$EF      clear single-advance flag
                    sta       <$25,u    store updated flags
                    pshs      u         pass object pointer to MMU
                    lda       #$1B      MMU function: add to range
                    sta       <$0019    store MMU function code
                    ldx       <$0026    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
DrawObjDone         leas      $03,s     release local stack frame
                    rts
CmdEraseImpl        lda       ,y+       load object number from script
                    pshs      y         save script pointer across helper call
                    bsr       EraseObjHelper
                    puls      y         restore script pointer
                    rts
EraseObjHelper      leas      -$04,s    allocate 4-byte local frame on stack
                    sta       ,s        save object number
                    ldb       #$2B      object struct is $2B bytes wide
                    mul                 compute byte offset into object table
                    addd      <$0030    add base address of object table
                    tfr       d,u       transfer object address to U
                    cmpu      <$0032    compare to first valid object pointer
                    bcs       EraseObjCheck branch if valid object index
                    lda       #$0C      load "erase invalid object" error code
                    ldb       ,s        reload object number for error report
                    lbsr      ReportError
EraseObjCheck       lda       <$26,u    load object state flags
                    bita      #$01      test drawn/visible flag
                    beq       EraseObjDone branch if object not visible (nothing to erase)
                    stu       $01,s     save object pointer
                    ldx       #$0548    point to water range list
                    lbsr      BlitListDraw
                    ldu       $01,s     reload object pointer
                    lda       <$26,u    load object state flags
                    anda      #$10      isolate update-needed flag
                    sta       $03,s     save update flag
                    bne       EraseObjDraw branch if update flag was set (skip land blit)
                    ldx       #$054C    point to land range list
                    lbsr      BlitListDraw
                    ldu       $01,s     reload object pointer
EraseObjDraw        lda       <$26,u    load object state flags
                    anda      #$FE      clear drawn/visible flag
                    sta       <$26,u    store updated flags
                    lda       $03,s     check saved update flag
                    bne       EraseObjScan branch if update was pending (skip land swap)
                    lbsr      SetLandRange classify objects by land terrain
                    pshs      x         save X across MMU call
                    lda       #$1E      MMU function: swap land ranges
                    sta       <$0021    store MMU function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
EraseObjScan        lbsr      SetWaterRange classify objects by water terrain
                    pshs      x         save X across MMU call
                    lda       #$1E      MMU function: swap water ranges
                    sta       <$0021    store MMU function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
                    ldu       $01,s     reload object pointer
                    pshs      u         pass object pointer to MMU
                    lda       #$1B      MMU function: remove from range
                    sta       <$0019    store MMU function code
                    ldx       <$0026    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack after push
EraseObjDone        leas      $04,s     release local stack frame
                    rts

XorKeyStr           fcc       /Avis Durgan/
                    fcb       0

*
*======================================================================
* LOGIC SCRIPT DECRYPTION
*   XOR decryption of logic scripts using the "Avis Durgan" key, applied
*   on load before execution.
*======================================================================
*
XorDecrypt          leas      -$02,s    allocate 2-byte stack slot for pointer
                    stu       ,s        save end-of-buffer pointer
                    leau      >XorKeyStr,pcr point U to start of XOR key string
XorDecryptLoop      cmpx      ,s        compare X (current pos) to end pointer
                    bcc       XorDecryptDone branch if past end of buffer
                    tst       ,u        check if key pointer at null terminator
                    bne       XorDecryptWrap branch if not at end of key
                    leau      >XorKeyStr,pcr wrap key pointer back to start
XorDecryptWrap      lda       ,x        load current ciphertext byte
                    eora      ,u+       XOR with key byte, advance key pointer
                    sta       ,x+       store decrypted byte, advance data pointer
                    bra       XorDecryptLoop loop until all bytes decrypted
XorDecryptDone      leas      $02,s     release stack pointer slot
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

*
*======================================================================
* ERROR REPORTING
*   Stores the error code and parameter, formats a system error message
*   dialog, and optionally rings the terminal bell.
*======================================================================
*
ReportError         sta       $442      store error code A in error variable
ReportErrorB        stb       >$0443    store error param B in error param variable
                    lbsr      ResetHeap reset heap before error handling
                    lbsr      events_clear
                    lbsr      ResetGameTables
                    bsr       RingBell  sound first bell (error alert)
                    bsr       RingBell  sound second bell (error alert)
                    lbsr      RestoreStackFrame
ErrorDialog         leas      >-$00B1,s allocate 177-byte local frame on stack
                    lbsr      InputEditOn
                    bsr       RingBell  sound bell in dialog
                    bsr       RingBell  sound second bell in dialog
ErrorFormatMsg      leau      >StrQuitMsg2,pcr load "Press CTRL-BREAK to quit" string
                    pshs      u         push as format arg
                    leau      >StrTryAgain,pcr load "Press ENTER to try again" string
                    pshs      u         push as format arg
                    clra                clear A for word construction
                    ldb       <$009F    load error number
                    leau      >StrSysError,pcr load "System error #%u.%s%s" format string
                    leax      $04,s     point to local output buffer
                    pshs      b,a       push error number
                    pshs      u         push format string pointer
                    pshs      x         push output buffer pointer
                    lbsr      PrintFmtStr
                    leas      $0A,s     release all 5 pushed arguments
                    lbsr      message_box
                    leas      >$00B1,s  release local stack frame
                    rts
RingBell            pshs      y         save Y (path descriptor)
                    ldy       #$0002    path 2 = stderr
                    lda       #$01      write 1 byte
RingBellWrite       leax      >StrBell,pcr point X to bell character
                    os9       I$Write
                    puls      y         restore Y
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
*
*======================================================================
* PRIORITY BASELINE SETUP
*   Rebuilds the 168-entry priority lookup table based on a configurable
*   base row (used by the set_pri_base command).
*======================================================================
*
SetPriBase          leas      -$04,s    allocate 4-byte local frame on stack
                    clr       >PriBaseFlag,pcr clear priority-base-set flag
                    ldb       ,y+       load base row argument from script
                    stb       $01,s     save base row
                    ldb       #$A8      168 = total screen rows
                    subb      $01,s     compute (168 - base_row)
                    lda       #$A8      168
                    mul                 compute (168 - base_row) * 168
                    ldu       #$000A    divide by 10 (number of priority bands)
                    lbsr      UIntDivide divide A by U, quotient in U
                    stu       $02,s     save the division result (rows per band)
                    clrb                start from row 0
                    stb       ,s        save current row counter
SetPriBaseLoop      subb      $01,s     subtract base row from current row
                    bcc       SetPriBaseMul branch if current >= base (within active range)
                    ldb       #$04      default priority 4 for rows before base
                    bra       SetPriBaseStore store default priority
SetPriBaseMul       lda       #$A8      168 rows
                    mul                 multiply row offset by 168
                    ldu       $02,s     load saved rows-per-band divisor
                    lbsr      UIntDivideToD divide to get band index, return as D
                    addd      #$0005    add 5 (minimum priority = 5)
                    cmpd      #$000F    compare to max priority (15)
                    bls       SetPriBaseStore branch if within range
                    ldb       #$0F      cap at maximum priority 15
SetPriBaseStore     stb       ,x+       store priority byte, advance X to next row
                    inc       ,s        increment row counter
                    ldb       ,s        reload current row
                    cmpb      #$A8      compare to total row count (168)
                    bcs       SetPriBaseLoop loop until all rows filled
                    leas      $04,s     release local stack frame
                    rts
*
*======================================================================
* STRING AND MEMORY UTILITIES
*   Low-level string and memory helpers: StrLen, StrCopy, MemCopy,
*   StrAppend, StrCompare, AtoI, integer-to-decimal/hex formatters,
*   unsigned divide, zero-pad, and ToLower.
*======================================================================
*
StrLen              leas      -$02,s    allocate 2-byte save slot for X
                    stx       ,s        save original string pointer
StrLenLoop          lda       ,x+       load byte from string, advance X
                    bne       StrLenLoop loop until null terminator found
                    tfr       x,d       transfer end+1 pointer to D
                    ldx       ,s        reload original start pointer
                    subd      ,s        compute (end+1 - start)
                    subd      #$0001    subtract 1 (exclude null terminator)
                    leas      $02,s     release 2-byte save slot
                    rts
StrCopy             pshs      u         save destination pointer (return in X)
StrCopyLoop         lda       ,x+       load source byte, advance X
                    sta       ,u+       store to destination, advance U
                    bne       StrCopyLoop loop until null terminator copied
                    puls      x         restore start-of-dest as X (return value)
                    rts
MemCopyNull         leas      -$04,s    allocate 4-byte local frame on stack
                    std       ,s        save max-copy-count (D) on stack
                    stu       $02,s     save original destination pointer
MemCopyLoop         lda       ,x+       load source byte, advance X
                    sta       ,u+       store to destination, advance U
                    beq       MemCopyDone branch if null terminator copied
                    ldd       ,s        reload remaining count
                    subd      #$0001    decrement count
                    std       ,s        save updated count
                    bne       MemCopyLoop loop if more bytes remain
                    clr       ,u        force null terminator at destination
MemCopyDone         ldx       $02,s     reload original destination pointer into X
                    leas      $04,s     release local stack frame
                    rts
StrAppend           pshs      u         save source pointer (return dest in X)
StrAppendFind       lda       ,u+       scan forward in destination for null
                    bne       StrAppendFind loop until null terminator found
                    leau      -$01,u    back up to point at null byte
StrAppendCopy       lda       ,x+       load source byte, advance X
                    sta       ,u+       store to destination (overwrites null), advance U
                    bne       StrAppendCopy loop until null terminator copied
                    puls      x         restore start-of-source as X (return value)
                    rts
StrCompare          pshs      u,x       save register state
StrCompareLoop      lda       ,x        load byte from first string (no advance yet)
                    suba      ,u+       subtract second string byte (advance U)
                    bne       StrCompareRet branch if bytes differ
                    tst       ,x+       test first string byte for null, advance X
                    bne       StrCompareLoop loop if not at end of first string
StrCompareRet       puls      u,x       restore saved registers
                    rts
AtoI                leas      -$02,s    allocate 2-byte accumulator on stack
                    clra                clear A for accumulator init
                    sta       ,s        clear accumulated result
                    sta       $01,s     clear digit temp
AtoISkipSpace       ldb       ,x+       load byte from input, advance X
                    cmpb      #$20      check for space character
                    beq       AtoISkipSpace loop to skip leading spaces
AtoIDigitLoop       cmpb      #$30      compare to '0'
                    bcs       AtoIDone  branch if below '0' (not a digit)
                    cmpb      #$39      compare to '9'
                    bhi       AtoIDone  branch if above '9' (not a digit)
                    subb      #$30      convert ASCII digit to binary
                    stb       $01,s     save digit value
                    lda       #$0A      multiply accumulated result by 10
                    ldb       ,s        load current accumulator
                    mul                 compute accumulator * 10
                    addb      $01,s     add new digit to product
                    stb       ,s        save updated accumulator
                    ldb       ,x+       load next input byte, advance X
                    bne       AtoIDigitLoop loop if not null terminator
AtoIDone            lda       ,s        load final converted integer
                    leas      $02,s     release 2-byte accumulator
                    rts
UIntToDecStr        leax      >NumConvEnd,pcr point X to end of numeric conversion buffer
                    clr       ,x        null-terminate the buffer
UIntToDecLoop       ldu       #$000A    divide by 10 for decimal conversion
                    bsr       UIntDivide divide D by U for decimal digit
                    addb      #$30      convert remainder to ASCII digit
                    stb       ,-x       store digit left of current position
                    tfr       u,d       transfer quotient to D
                    cmpd      #$0000    check if quotient is zero
                    bhi       UIntToDecLoop loop if more digits to convert
                    rts
UIntToHexStr        leax      >NumConvEnd,pcr point X to end of numeric conversion buffer
                    clr       ,x        null-terminate the buffer
UIntToHexLoop       ldu       #$0010    divide by 16 for hex conversion
                    bsr       UIntDivide divide D by 16 for hex digit
                    addb      #$30      convert remainder to ASCII
                    cmpb      #$39      check if digit is 0-9
                    ble       UIntToHexStore branch if in '0'-'9' range
                    addb      #$07      adjust for 'A'-'F' range
UIntToHexStore      stb       ,-x       store hex digit left of current position
                    tfr       u,d       transfer quotient to D
                    cmpd      #$0000    check if quotient is zero
                    bhi       UIntToHexLoop loop if more digits to convert
                    rts
UIntDivide          leas      -$05,s    allocate 5-byte local frame on stack
                    std       ,s        save dividend (D)
                    stu       $02,s     save divisor (U)
                    lda       #$10      16 iterations for 16-bit divide
                    sta       $04,s     save iteration count
                    ldd       #$0000    clear quotient accumulator
UIntDivideLoop      lsl       $01,s     shift dividend left (LSB of dividend)
                    rol       ,s        shift dividend MSB with carry
                    rolb                roll bit into quotient LSB
                    rola                roll quotient MSB
                    cmpd      $02,s     compare partial remainder to divisor
                    bcs       UIntDivideShift branch if remainder < divisor (no subtract)
                    subd      $02,s     subtract divisor from partial remainder
                    inc       $01,s     set quotient bit (LSB of dividend was 1)
UIntDivideShift     dec       $04,s     decrement iteration count
                    bne       UIntDivideLoop loop for all 16 bits
                    ldu       ,s        load final quotient into U
                    leas      $05,s     release local stack frame
                    rts
StrZeroPad          leas      -$0B,s    allocate 11-byte local frame on stack
                    pshs      x,b       save X (dest) and B (desired width)
                    tfr       u,x       transfer source pointer to X
                    leau      $04,s     point U to local string buffer
                    lbsr      StrCopy   copy source string to local buffer
                    lbsr      StrLen    compute length of copied string
                    stb       $03,s     save source string length
                    leau      >NumZeroPad,pcr point U to zero-pad buffer
                    ldx       #$000A    fill 10 characters
                    ldb       #$30      fill value is '0'
                    lbsr      FillMem   fill 10-byte zero-pad buffer with '0'
                    puls      b
                    subb      $02,s     subtract source length from desired width
                    bpl       StrZeroPadDo branch if width > source length (need padding)
                    clrb                no padding needed
StrZeroPadDo        clr       b,u       null-terminate at the correct position
                    leax      $03,s     point X to source string copy
                    lbsr      StrAppend append source after padding zeros
                    tfr       x,u       transfer result pointer to U
                    puls      x         restore original destination X
                    leas      $0B,s     release local stack frame
                    rts
ToLower             cmpa      #$41      check if char is below 'A'
                    bcs       ToLowerRet branch if below 'A' (not uppercase)
                    cmpa      #$5A      check if char is above 'Z'
                    bhi       ToLowerRet branch if above 'Z' (not uppercase)
                    ora       #$20      set bit 5 to convert to lowercase
ToLowerRet          rts
*
*======================================================================
* RANDOM NUMBER COMMAND
*   Implements the AGI random command: generates a pseudo-random value
*   and stores it in a variable within a caller-specified range.
*======================================================================
*
CmdRandomImpl       lbsr      InitRandSeed get pseudo-random value into B
                    lda       $01,y     load range max (second arg)
                    suba      ,y++      subtract range min from max, advance Y by 2
                    inca                add 1 to get range size
                    bne       CmdRandomMod branch if range is non-zero
                    tfr       b,a       range was zero, use raw random value
                    bra       CmdRandomStore skip modulo
CmdRandomMod        lbsr      Div8      divide: A=divisor, B=dividend → B=remainder
                    adda      -$02,y    add range min to get result in range
CmdRandomStore      ldx       #$0431    point to variable table
                    ldb       ,y+       load destination variable number
                    abx                 index to destination variable
                    sta       ,x        store random result in variable
                    rts
*
*======================================================================
* BYTE SEARCH AND CASE HELPERS
*   FindByte scans a string for a target byte; StrToLower converts a
*   string to lowercase in place.
*======================================================================
*
FindByte            tst       ,x        check for null terminator at current position
                    bne       FindByteLoop branch if not null (search continues)
                    ldx       #$0000    null found, return null pointer (not found)
                    bra       FindByteRet
FindByteLoop        cmpa      ,x+       compare search byte to current, advance X
                    bne       FindByte  branch if not matching (retry from top)
                    leax      -$01,x    back up to point at the matching byte
FindByteRet         rts
StrToLower          tfr       u,x       transfer string pointer to X
StrToLowerLoop      lda       ,x        load current character
                    beq       StrToLowerDone branch if null terminator (end of string)
                    bsr       ToLower   convert character to lowercase
                    sta       ,x+       store lowercased char, advance X
                    bra       StrToLowerLoop loop for next character
StrToLowerDone      rts
*
*======================================================================
* EVENT QUEUE AND INPUT POLLING
*   Event queue push/pop, joystick and keyboard polling, key remapping,
*   and waiting for specific input events (Enter, Escape, any key).
*======================================================================
*
JoystickReadInit    lbsr      cmd_init_joy initialize joystick hardware
                    bsr       events_clear clear event queue after init
                    rts
events_clear        lbsr      clear_key_queue clear keyboard input queue
                    lbsr      reset_joy reset joystick state
                    ldx       #$0103    point to start of circular event buffer
                    stx       <$0092    set event write pointer to buffer start
                    stx       <$0094    set event read pointer to buffer start
                    rts
JoystickPoll        lbsr      PollJoystick poll joystick hardware
                    lbsr      PollKeyInput poll keyboard input
                    rts
EventPush           ldu       <$0092    load event queue write pointer
                    stb       ,u+       store event type byte, advance pointer
                    sta       ,u+       store event data byte, advance pointer
                    stu       <$0092    save updated write pointer
                    ldx       #$012B    load end-of-buffer sentinel address
                    cmpx      <$0092    compare write pointer to sentinel
                    bhi       EventPushWrap branch if write pointer within buffer
                    ldx       #$0103    wrap write pointer to buffer start
                    stx       <$0092    store wrapped write pointer
EventPushWrap       ldx       <$0092    load (possibly wrapped) write pointer
                    cmpx      <$0094    compare write to read pointer
                    bne       EventPushRet branch if not equal (buffer not full)
                    leau      -$02,u    overflow: back write pointer up one slot
                    stu       <$0092    store backed-up write pointer (discard event)
EventPushRet        rts
EventPop            ldd       <$0094    load event queue read pointer into D
                    cmpd      <$0092    compare read to write pointer
                    bne       EventPopGet branch if they differ (event available)
                    ldx       #$0000    queue empty, return null pointer
                    bra       EventPopRet
EventPopGet         ldx       #$0002    advance by 2 to consume the event entry
                    leax      d,x       add read pointer to get new read pointer
                    stx       <$0094    save updated read pointer
                    ldx       #$012B    load end-of-buffer sentinel
                    cmpx      <$0094    compare new read pointer to sentinel
                    bhi       EventPopAddr branch if within buffer (no wrap)
                    ldx       #$0103    wrap read pointer to buffer start
                    stx       <$0094    store wrapped read pointer
EventPopAddr        tfr       d,x       transfer old read pointer to X (event address)
EventPopRet         rts
WaitForEvent        leas      -$02,s    allocate 2-byte timer snapshot on stack
WaitForEventLoop    ldd       >$024A    load current cycle timer
                    std       ,s        save timer snapshot
                    bsr       EventPop  try to pop an event from queue
                    leax      ,x        test returned event pointer
                    bne       EventFound branch if event was available
WaitPollLoop        ldd       ,s        reload saved timer snapshot
                    cmpd      >$024A    compare to current timer
                    beq       WaitPollLoop loop if timer hasn't advanced
                    lbsr      JoystickPoll poll inputs to generate events
                    bra       WaitForEventLoop loop to check event queue again
EventFound          lbsr      RemapJoyToKey remap joystick fire to Enter/Esc if needed
                    leas      $02,s     release stack timer slot
                    rts
RemapKeyEvent       leax      ,x        test event pointer
                    beq       RemapKeyEventRet branch if null (no event)
                    ldb       ,x        load event type
                    cmpb      #$01      check if keyboard event
                    bne       RemapKeyEventRet branch if not keyboard event
                    ldu       #$01D8    point to key-mapping table
RemapKeyEventLoop   ldb       ,u++      load key map entry (high byte), advance U
                    beq       RemapKeyEventRet branch if end of table (no match)
                    cmpb      $01,x     compare table key code to event key
                    bne       RemapKeyEventLoop branch if not matching
                    lda       #$03      matched: set event type to "remapped key"
                    ldb       -$01,u    load corresponding remapped key code
                    std       ,x        store new event type and key in event
RemapKeyEventRet    rts
GetKeyEvent         lbsr      JoystickPoll poll joystick and keyboard
                    bsr       EventPop  pop next event from queue
                    tfr       x,d       transfer event pointer to D for test
                    leax      ,x        test if event pointer is null
                    beq       GetKeyEventRet branch if no event (return 0 in A)
                    bsr       RemapJoyToKey remap joystick fire to key if needed
                    lda       ,x        load event type
                    cmpa      #$01      check if keyboard event
                    bne       GetKeyNotFound branch if not a keyboard event
                    lda       $01,x     load key character from event
GetKeyEventRet      rts
GetKeyNotFound      lda       #$FF      no keyboard event, return sentinel
                    rts
WaitKeyNonNull      bsr       GetKeyEvent poll for a key event
                    beq       WaitKeyNonNull loop if no key yet (A==0)
                    cmpa      #$FF      compare to no-event sentinel
                    beq       WaitKeyNonNull loop if no real key event
                    rts
WaitEnterOrEsc      bsr       GetKeyEvent poll for a key event
                    tfr       a,b       save key code in B
                    lda       #$01      default return: Enter pressed (1)
                    cmpb      #$0D      check if Enter key
                    beq       WaitEnterOrEscRet branch if Enter was pressed
                    lda       #$00      return 0 for Escape pressed
                    cmpb      #$1B      check if Escape key
                    beq       WaitEnterOrEscRet branch if Escape was pressed
                    lda       #$FF      other key: return $FF (retry)
WaitEnterOrEscRet   rts
BooleanPoll         lbsr      events_clear clear all pending events
BooleanPollLoop     bsr       WaitEnterOrEsc wait for Enter or Escape
                    bmi       BooleanPollLoop branch if $FF (neither Enter nor Escape)
                    rts
RemapJoyToKey       lda       ,x        load event type
                    cmpa      #$01      check if keyboard event
                    bne       RemapJoyToKeyRet branch if not keyboard (nothing to remap)
                    lda       $01,x     load key character
                    cmpa      #$FC      check for joystick-fire (Enter) code
                    bne       RemapJoyToEsc branch if not fire button
                    lda       #$0D      remap to Enter character
                    bra       StoreRemappedKey store remapped key
RemapJoyToEsc       cmpa      #$FE      check for joystick-fire (Escape) code
                    bne       RemapJoyToKeyRet branch if not this special code
                    lda       #$1B      remap to Escape character
StoreRemappedKey    sta       $01,x     store remapped key character in event
RemapJoyToKeyRet    rts
SS_GetSttData       fcb       5,2
*
*======================================================================
* FILE I/O WRAPPERS
*   Thin wrappers around OS-9 I$Open, I$Read, I$Write, I$Delete,
*   I$Close, I$Seek, and I$GetStt that store the error code in a shared
*   variable.
*======================================================================
*
DataPathBuf         fcc       /./
DataPathEntry       fcc       /./
                    fcb       $0d,0
CreateFile          pshs      x,d       save X and D across delete call
                    bsr       DeleteFile delete any existing file first
                    clr       <$9f      clear error flag
                    puls      d,x       restore saved D and X
                    os9       I$Create
                    bcc       CreateRet branch if file created successfully
                    lbsr      OsErrorHandler
CreateRet           rts
OpenFile            clr       <$009F    clear error flag
                    os9       I$Open
                    bcc       OpenFileRet branch if file opened successfully
                    lbsr      OsErrorHandler
OpenFileRet         rts
ReadFile            clr       <$009F    clear error flag
                    os9       I$Read
                    bcc       ReadFileRet branch if read succeeded
                    lbsr      OsErrorHandler
                    ldy       #$0000    return 0 bytes read on error
ReadFileRet         tfr       y,d       transfer byte count to D (return value)
                    rts
WriteFile           clr       <$009F    clear error flag
                    os9       I$Write
                    bcc       WriteFileRet branch if write succeeded
                    lbsr      OsErrorHandler
                    ldy       #$0000    return 0 bytes written on error
WriteFileRet        tfr       y,d       transfer byte count to D (return value)
                    rts
DeleteFile          clr       <$009F    clear error flag
                    os9       I$Delete
                    bcc       DeleteFileRet branch if delete succeeded
                    lbsr      OsErrorHandler
DeleteFileRet       rts
CloseFilePath       clr       <$009F    clear error flag
                    os9       I$Close
                    bcc       CloseFilePathRet branch if close succeeded
                    lbsr      OsErrorHandler
CloseFilePathRet    rts
SeekFile            clr       <$009F    clear error flag
                    tstb                test B (seek mode flag)
                    bne       GetSttSeek branch if non-zero mode (relative seek)
                    os9       I$Seek    absolute seek
                    bcc       SeekFileRet branch if seek succeeded
SeekFileErr         lbsr      OsErrorHandler
                    ldy       #$0000    return zero position on error
                    bra       SeekFileRet
GetSttSeek          stx       <$0084    save X (high word of position)
                    stu       <$0086    save U (low word of position)
                    leau      >RemapJoyToKeyRet,pcr load address to get seek-mode byte
                    ldb       b,u       index into mode table to get GetStt code
                    os9       I$GetStt  get current file position
                    bcs       SeekFileErr branch if GetStt failed
                    pshs      a         save path number across arithmetic
                    tfr       u,d       transfer low position word to D
                    addd      <$0086    add seek offset low word
                    tfr       d,u       store result back to U
                    tfr       x,d       transfer high position word to D
                    adcb      #$00      propagate carry to B
                    adca      #$00      propagate carry to A
                    addd      <$0084    add seek offset high word
                    tfr       d,x       store result back to X
                    puls      a         restore path number
                    os9       I$Seek    seek to computed absolute position
                    bcs       SeekFileErr branch if seek failed
SeekFileRet         rts
                    clr       <$009F    clear error flag (dup path)
                    os9       I$Dup     duplicate the path
                    bcc       DupPathRet branch if dup succeeded
                    lbsr      OsErrorHandler
DupPathRet          rts
*
*======================================================================
* DISK AND DIRECTORY MANAGEMENT
*   Reads device and disk names, scans the directory for the current
*   disk, parses disk-name entries, and manages the directory path
*   descriptor.
*======================================================================
*
GetDeviceName       leas      <-$22,s   allocate 34-byte local frame on stack
                    sty       ,s        save output buffer pointer
                    clra                clear A for zeroing
                    sta       ,y        clear first byte of output buffer
                    sta       <$0077    clear device index
                    leax      >DataPathEntry,pcr point to current directory entry string
                    lbsr      OpenDirPath open directory for reading
                    bcs       GetDeviceNameClose branch if open failed
                    sta       <$0078    save directory path number
                    ldb       #$0E      GetStt SS$DevNm (device name) code
                    leax      $02,s     point to local buffer for device name
                    os9       I$GetStt  get device name
                    bcs       GetDeviceNameClose branch if GetStt failed
                    ldy       ,s        reload output buffer pointer
                    ldb       #$2F      '/' separator character
                    stb       ,y+       write leading '/'
                    ldd       ,x++      load two chars of device name, advance X
                    andb      #$7F      clear high bit from second char
                    std       ,y++      store two device name chars, advance Y
                    ldb       #$2F      '/' separator character
                    stb       ,y+       write trailing '/'
                    clr       ,y        null-terminate the device name
GetDeviceNameClose  lbsr      CloseDirPath close directory path
                    leas      <$22,s    release local stack frame
                    rts
GetDiskName         leas      -$0A,s    allocate 10-byte local frame on stack
                    leay      ,s        point Y to local disk name buffer
                    bsr       GetDeviceName get device name (e.g. "/d0/")
                    leax      $01,s     point to first char of device name (skip '/')
                    ldd       #$0002    copy at most 2 characters
                    lbsr      MemCopyNull
                    tfr       x,u       transfer pointer past copied chars to U
                    lbsr      StrToLower convert device name to lowercase
                    ldd       ,u        load two device name characters
                    subb      #$30      convert digit char to binary (e.g. '0'→0)
                    cmpa      #$64      check if first char is 'd' (for /d0/ style)
                    beq       GetDiskNameStore branch if already a digit
                    orb       #$10      set bit to distinguish drive type
GetDiskNameStore    stb       $03,u     store computed disk name byte
                    leas      $0A,s     release local stack frame
                    rts
FindCurrentDisk     leas      >-$00C2,s allocate 194-byte local frame on stack
                    stu       ,s        save caller's buffer pointer
                    clra                clear A for zeroing
                    sta       <$0077    clear directory open flag
                    leax      >$00A1,s  point to local disk entry buffer
                    sta       ,x        clear first byte of buffer
                    stx       <$0079    save disk entry buffer pointer
                    leax      >DataPathEntry,pcr point to current directory path
                    lbsr      OpenDirPath open directory for reading
                    sta       <$0078    save directory path number
                    leax      >$00A2,s  point to disk entry buffer
                    lbsr      ReadDiskEntry read first disk entry (current dir)
FindCurrentDiskLoop ldd       <$0081    load disk ID bytes 1-2
                    std       <$007B    save as target disk ID
                    lda       <$0083    load disk ID byte 3
                    sta       <$007D    save as target disk ID byte 3
                    ldx       #$0081    point to first disk entry ID
                    ldy       #$007E    point to saved original disk ID
                    lbsr      Compare3Bytes compare current to original disk ID
                    beq       FindDiskEntryFound branch if disk IDs match (found it)
                    leax      >DataPathBuf,pcr point to ".." path string
                    lbsr      ChangeDir change to parent directory
                    lbsr      CloseDirPath close current directory path
                    bcs       FindDiskEntryDone branch if change-dir failed
                    leax      >DataPathEntry,pcr point to "." path entry
                    lbsr      OpenDirPath open parent directory
                    leax      >$00A2,s  point to local entry buffer
                    bsr       ReadDiskEntry read first entry from parent
FindDiskEntryLoop   leax      >$00A2,s  point to local entry buffer
                    lda       <$0078    load directory path number
                    lbsr      ReadDirEntry read next directory entry
                    bcs       FindDiskEntryDone branch if no more entries (not found)
                    leax      <$1D,x    advance X to entry's disk ID field
                    ldy       #$007B    point to target disk ID
                    bsr       Compare3Bytes compare entry disk ID to target
                    bne       FindDiskEntryLoop branch if no match (try next entry)
                    leax      >$00A2,s  point to matched entry buffer
                    bsr       ParseDiskName parse the disk name from entry
                    bcs       FindDiskEntryDone branch if parse failed
                    bra       FindCurrentDiskLoop loop to continue searching up
FindDiskEntryFound  lbsr      CloseDirPath close directory when found
                    leay      >$00A2,s  point Y to matched disk entry
                    lbsr      GetDeviceName get device name for matched disk
                    leax      >$00A2,s  point to matched disk entry buffer
                    bsr       ParseDiskName parse disk name from entry
                    bcs       FindDiskEntryDone branch if parse failed
                    ldu       ,s        reload output buffer pointer
                    ldx       <$0079    load disk name pointer
                    lbsr      StrCopy   copy disk name to output buffer
                    lbsr      ChangeDir change to the found disk directory
FindDiskEntryDone   ldu       ,s        reload output buffer pointer
                    lbsr      StrToLower convert disk name to lowercase
                    lbsr      CloseDirPath close directory path
                    leas      >$00C2,s  release local stack frame
                    rts
ParseDiskName       os9       F$PrsNam  parse name from entry path
                    bcs       ParseDiskNameEnd branch if parse failed (carry set)
                    ldx       <$0079    load disk name write pointer
ParseDiskNameCopy   lda       ,-y       load char from end of parsed name (reverse)
                    anda      #$7F      clear high bit (end-of-name marker)
                    sta       ,-x       store char before current position
                    decb                decrement remaining char count
                    bne       ParseDiskNameCopy loop until all chars copied
                    cmpa      #$2F      check if first char is '/' separator
                    beq       ParseDiskNameRet branch if already has leading separator
                    lda       #$2F      prepend '/' separator
                    sta       ,-x       store separator before name
                    andcc     #$FE      clear carry (success)
ParseDiskNameRet    stx       <$0079    save updated write pointer
ParseDiskNameEnd    rts
ReadDiskEntry       bsr       ReadDirEntry read first directory entry
                    ldd       <$1D,x    load first entry's disk ID bytes 1-2
                    std       <$007E    save as disk ID reference
                    lda       <$1F,x    load first entry's disk ID byte 3
                    sta       <$0080    save disk ID byte 3
                    bsr       ReadDirEntry read second directory entry
                    ldd       <$1D,x    load second entry's disk ID bytes 1-2
                    std       <$0081    save as second disk ID
                    lda       <$1F,x    load second entry's disk ID byte 3
                    sta       <$0083    save second disk ID byte 3
                    rts
Compare3Bytes       ldd       ,x++      load two bytes from X, advance X
                    cmpd      ,y++      compare to two bytes from Y, advance Y
                    bne       Compare3BytesRet branch if first two bytes differ
                    lda       ,x        load third byte from X
                    cmpa      ,y        compare to third byte from Y
Compare3BytesRet    rts
OpenDirPath         lda       #$81      read-only ($81) access mode
                    lbsr      OpenFile  open directory path
                    bcs       OpenDirPathRet branch if open failed
                    inc       <$0077    increment directory-open nesting count
OpenDirPathRet      rts
ReadDirEntry        lda       <$0078    load directory path number
                    ldy       #$0020    read 32 bytes (one dir entry)
                    lbra      ReadFile  jump to ReadFile to read dir entry
CloseDirPath        lda       <$0078    load directory path number
                    lbsr      CloseFilePath close the directory path
                    bcs       CloseDirPathRet branch if close failed
                    clr       <$0077    clear directory-open nesting count
CloseDirPathRet     rts
ChangeDir           clr       <$009F    clear error flag
                    lda       #$81      read-only access mode
                    os9       I$ChgDir
                    bcc       ChangeDirRet branch if change dir succeeded
                    lbsr      OsErrorHandler
ChangeDirRet        rts
                    lda       $05,s     load open mode from stack frame
                    ldy       $02,s     load path string pointer
                    lbsr      OpenFile  open the file at path
                    bcs       OpenPathRet branch if open failed
                    ldx       $06,s     load status buffer pointer
                    bsr       GetFileStatus get file status into buffer
OpenPathRet         lda       <$009F    load error code (0 = success)
                    rts
GetFileStatus       clr       <$009F    clear error flag
                    ldb       #$0F      SS$Opt GetStt code for file status
                    ldy       #$0010    read 16 bytes of status
                    os9       I$GetStt
                    bcc       GetFileStatusRet branch if GetStt succeeded
                    bsr       OsErrorHandler
GetFileStatusRet    rts
GetFileTime         leas      <-$14,s   allocate 20-byte local time buffer on stack
                    leax      ,s        point X to the local buffer
                    bsr       GetFileStatus get file modification date/time into buffer
                    leax      $03,x     advance X to date/time fields
                    clrb                clear B for word construction
                    lda       ,x        load year field
                    suba      #$50      subtract 1980 base year (0x50 = 80)
                    lsla                shift left (year is 7 bits, packed)
                    std       <$10,s    save year word to stack
                    ldb       $01,x     load month field
                    lda       #$20      32 = shift factor for month packing
                    mul                 multiply month by 32
                    addd      <$10,s    add year offset
                    addb      $02,x     add day field
                    adca      #$00      propagate carry
                    std       <$10,s    save packed year/month/day
                    clrb                clear B for word construction
                    lda       $03,x     load hour field
                    lsla                shift hour bits up
                    lsla                (hour packing requires 2 shifts)
                    lsla                final shift for hour position
                    std       <$12,s    save hour partial word to stack
                    ldb       $04,x     load minute field
                    lda       #$20      32 = shift factor for minute packing
                    mul                 multiply minute by 32
                    addd      <$12,s    add hour offset
                    ldx       <$10,s    load packed date into X (return value)
                    leas      <$14,s    release local time buffer
                    rts
*
*======================================================================
* OS ERROR HANDLER AND OBJECT BOUNDS
*   Captures OS-9 error codes into a shared variable; FindObjPos
*   searches for a valid on-screen position for an object by trying
*   adjacent cells.
*======================================================================
*
OsErrorHandler      pshs      cc        save condition codes
                    cmpb      #$D8      check for "no such device" error
                    bne       OsErrorStore branch if not that specific error
                    lda       #$FF      remap to $FF (generic not-found)
                    clrb                clear B (set error code to 0 in store)
OsErrorStore        stb       <$009F    store error code in error variable
                    puls      cc        restore condition codes
                    rts
FindObjPos          leas      -$05,s    allocate 5-byte local frame on stack
                    stu       ,s        save object pointer
                    clra                clear search direction counter
                    sta       $03,s     init direction iteration to 0
                    inca                start with step size 1
                    sta       $02,s     init step iteration counter
                    sta       $04,s     init step remaining counter
                    lda       >$01D6    load maximum Y (horizon line)
                    cmpa      $04,u     compare to object Y priority
                    bcs       FindObjPosIter branch if below horizon (can place here)
                    ldb       <$26,u    load object state flags
                    bitb      #$08      test ignore-horizon flag
                    bne       FindObjPosIter branch if object ignores horizon
                    inca                increment priority to place above horizon
                    sta       $04,u     store adjusted priority
FindObjPosIter      lbsr      CheckObjBounds check if object fits within screen
                    tsta                test result (0 = out of bounds)
                    beq       FindObjPosDirNone branch if out of bounds
                    lbsr      CheckObjCollision check for collision with other objects
                    tsta                test result (non-zero = collision)
                    bne       FindObjPosDirNone branch if collision detected
                    pshs      u         save object pointer across MMU call
                    lda       #$03      MMU function code 3 (place object)
                    sta       <$0021    store function code
                    ldx       <$0028    load Sierra dispatch address
                    jsr       >$0701    call MMU twiddle
                    leas      $02,s     restore stack
                    ldu       ,s        reload object pointer
                    lda       <$005C    check placement result flag
                    bne       FindObjPosDone branch if placement succeeded
FindObjPosDirNone   lda       $03,s     load current search direction
                    bne       FindObjPosDirOne branch if trying non-zero direction
                    dec       $03,u     shift object up by 1 (try above)
                    dec       $04,s     decrement remaining step count
                    bne       FindObjPosIter branch if more steps in this direction
                    inc       $03,s     advance to next direction
                    lda       $02,s     load step size
                    sta       $04,s     reset step counter
                    bra       FindObjPosIter try next position
FindObjPosDirOne    cmpa      #$01      check if direction 1 (down)
                    bne       FindObjPosDirTwo branch if not direction 1
                    inc       $04,u     shift object down by 1
                    dec       $04,s     decrement remaining step count
                    bne       FindObjPosIter branch if more steps in this direction
                    inc       $03,s     advance to next direction
                    inc       $02,s     increase step size
                    lda       $02,s     load new step size
                    sta       $04,s     reset step counter
                    bra       FindObjPosIter try next position
FindObjPosDirTwo    cmpa      #$02      check if direction 2 (right)
                    bne       FindObjPosDirThree branch if not direction 2
                    inc       $03,u     shift object right by 1
                    dec       $04,s     decrement remaining step count
                    bne       FindObjPosIter branch if more steps in this direction
                    inc       $03,s     advance to next direction
                    lda       $02,s     load step size
                    sta       $04,s     reset step counter
                    bra       FindObjPosIter try next position
FindObjPosDirThree  dec       $04,u     shift object left by 1
                    dec       $04,s     decrement remaining step count
                    bne       FindObjPosIter branch if more steps in this direction
                    clr       $03,s     reset direction to 0
                    inc       $02,s     increase step size for next spiral ring
                    lda       $02,s     load new step size
                    sta       $04,s     reset step counter
                    bra       FindObjPosIter try next position
FindObjPosDone      leas      $05,s     release local stack frame
                    rts
CheckObjBounds      clra                assume out of bounds (return 0)
                    ldb       $03,u     load object X position
                    addb      <$1C,u    add object width to get right edge
                    bcs       CheckObjBoundsRet branch if right edge overflowed (off-screen)
                    cmpb      #$A0      compare right edge to screen right (160)
                    bhi       CheckObjBoundsRet branch if right edge off screen
                    ldb       $04,u     load object Y position
                    cmpb      #$A7      compare to screen bottom (167)
                    bhi       CheckObjBoundsRet branch if Y below screen
                    incb                Y+1 for height check
                    cmpb      <$1D,u    compare to object height
                    bcs       CheckObjBoundsRet branch if Y+1 < height (object too tall)
                    decb                restore Y
                    cmpb      >$01D6    compare to horizon row
                    bhi       CheckObjInBounds branch if below horizon (in bounds)
                    ldb       <$26,u    load object state flags
                    bitb      #$08      test ignore-horizon flag
                    beq       CheckObjBoundsRet branch if must observe horizon (out of bounds)
CheckObjInBounds    inca                object is in bounds: return 1
CheckObjBoundsRet   rts
FlagBitTable        fcb       $80,$40,$20,$10,8,4,2,1



*
*======================================================================
* FLAG COMMANDS
*   Implementations of the set, reset, toggle, set_v, reset_v, and
*   toggle_v AGI flag commands, plus the internal GetFlagBitAddr helper.
*======================================================================
*
CmdSetImpl          lda       ,y+       load flag number from script
                    bra       SetFlag   jump to SetFlag to set it


CmdResetImpl        lda       ,y+       load flag number from script
                    bra       ClearFlag jump to ClearFlag to clear it


CmdToggleImpl       lda       ,y+       load flag number from script
                    bra       ToggleFlag jump to ToggleFlag to toggle it

CmdSetVImpl         ldb       ,y+       load variable number from script
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    lda       ,x        load flag number from variable
                    bra       SetFlag   jump to SetFlag with flag number in A

CmdResetVImpl       ldb       ,y+       load variable number from script
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    lda       ,x        load flag number from variable
                    bra       ClearFlag jump to ClearFlag with flag number

CmdToggleVImpl      ldb       ,y+       load variable number from script
                    ldx       #$431     point to variable table
                    abx                 index to the variable
                    lda       ,x        load flag number from variable
                    bra       ToggleFlag jump to ToggleFlag with flag number

SetFlag             bsr       GetFlagBitAddr get bit mask (A) and byte address (X)
                    ora       ,x        OR bit mask into flag byte
                    sta       ,x        store updated flag byte
                    rts

ClearFlag           bsr       GetFlagBitAddr get bit mask (A) and byte address (X)
                    coma                invert bit mask to produce AND mask
                    anda      ,x        AND inverted mask to clear the bit
                    sta       ,x        store updated flag byte
                    rts

ToggleFlag          bsr       GetFlagBitAddr get bit mask (A) and byte address (X)
                    eora      ,x        XOR to toggle the flag bit
                    sta       ,x        store updated flag byte
                    rts
TestFlag            bsr       GetFlagBitAddr get bit mask (A) and byte address (X)
                    anda      ,x        AND mask with flag byte (result: 0=clear, nonzero=set)
                    rts
GetFlagBitAddr      tfr       a,b       copy flag number to B
                    leax      >FlagBitTable,pcr point X to bit-mask lookup table
                    anda      #$07      flag number mod 8 → bit index within byte
                    lda       a,x       load bit mask for this flag bit
                    lsrb                shift flag number right 3 (÷8)
                    lsrb                (second shift)
                    lsrb                → byte offset into flag table
                    ldx       #$01AE    base address of flag table
                    abx                 index to the correct flag byte
                    rts
*
*======================================================================
* FOLLOW EGO MOTION CALCULATOR
*   Computes the next direction for a follow-ego object, with wander
*   fallback when blocked and random delay between steps.
*======================================================================
*
CalcFollowDir       leas      -$05,s    allocate 5-byte local frame on stack
                    ldb       <$27,u    load follow-object's step size
                    pshs      b,a       save step size and A
                    ldx       <$0030    load ego object pointer
                    lda       <$1C,x    load ego width
                    lsra                halve width to get center offset
                    adda      $03,x     add X position to get ego center X
                    ldb       $04,x     load ego Y position
                    std       $03,s     save ego center position on stack
                    pshs      b,a       push ego center as CalcMoveDir arg
                    lda       <$1C,u    load follower width
                    lsra                halve width to get center offset
                    adda      $03,u     add X position to get follower center X
                    sta       $07,s     save follower center X
                    ldb       $04,u     load follower Y position
                    pshs      b,a       push follower position as CalcMoveDir arg
                    lbsr      CalcMoveDir compute direction toward ego
                    leas      $06,s     release CalcMoveDir arguments
                    sta       ,s        save computed direction
                    bne       FollowCheckStop branch if direction is non-zero (not yet there)
                    sta       <$21,u    arrived: stop follower (direction = 0)
                    sta       <$22,u    clear motion type (no special motion)
                    lda       <$28,u    load "follow complete" flag number
                    lbsr      SetFlag   set the follow-complete flag
                    bra       FollowRet
FollowCheckStop     lda       <$29,u    load follow delay counter
                    cmpa      #$FF      check for "wander first" sentinel
                    bne       FollowCheckWander branch if not in wander mode
                    clr       <$29,u    clear wander mode
                    bra       FollowSetDir go set the follow direction
FollowCheckWander   lda       <$25,u    load follower animation flags
                    bita      #$40      test "wander allowed" flag
                    beq       FollowDecTimer branch if not in wander mode
FollowSetWander     lbsr      InitRandSeed get random value
                    lda       #$09      random range 0-8 (9 directions)
                    lbsr      Div8      compute random direction
                    sta       <$21,u    store new random direction
                    beq       FollowSetWander loop if direction was 0 (stopped)
                    ldb       $03,s     load ego center X
                    subb      $01,s     subtract follower X to get delta X
                    bcc       FollowCalcDir branch if delta positive
                    negb                negate to get absolute delta X
FollowCalcDir       stb       $04,s     save absolute delta X
                    ldb       $04,u     load follower Y
                    subb      $02,s     subtract ego Y to get delta Y
                    bcc       FollowCalcStep branch if delta positive
                    negb                negate to get absolute delta Y
FollowCalcStep      clra                clear A for word construction
                    addb      $04,s     add delta X to delta Y (Manhattan distance)
                    adca      #$00      propagate carry
                    lsra                divide sum by 2 (A)
                    rorb                shift into B
                    incb                round up
                    stb       $04,s     save computed step distance
                    lda       <$1E,u    load follower step size
                    sta       <$29,u    save as follow timer
                    cmpa      $04,s     compare step size to distance
                    bcc       FollowRet branch if step size >= distance (no random needed)
FollowRandomStep    lbsr      InitRandSeed get random value for step delay
                    lda       $04,s     load computed distance
                    lbsr      Div8      compute random step within distance
                    cmpa      <$1E,u    compare to minimum step size
                    bcs       FollowRandomStep loop if random step too small
                    sta       <$29,u    store random step delay
                    bra       FollowRet
FollowDecTimer      lda       <$29,u    load follow delay counter
                    beq       FollowSetDir branch if counter is zero (time to move)
                    clr       <$29,u    clear counter temporarily
                    suba      <$1E,u    subtract step size from counter
                    bcs       FollowRet branch if underflowed (past time)
                    sta       <$29,u    store updated counter
                    bra       FollowRet
FollowSetDir        lda       ,s        load computed direction from stack
                    sta       <$21,u    store as follower's movement direction
FollowRet           leas      $05,s     release local stack frame
                    rts
DataSaveDiskFlag    fcb       1
SaveDiskNameBuf     fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DataSaveGameBuf     fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DataSaveGameBuf2    fcb       0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                    fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
*
*======================================================================
* SAVE AND RESTORE GAME
*   All save/restore game logic: slot-selection UI, path entry, file
*   read/write of game state, and date-based slot ordering.
*======================================================================
*
StrSave             fcc       /save/
                    fcb       0
StrRestore          fcc       /restore/
                    fcb       0
StrDescFmt          fcc       / - %s/
                    fcb       0
StrSaveDesc         fcc       /How would you like to describe this saved game?/
                    fcb       $0a,$0a,0
StrSaveDiskPrompt   fcc       /Please put your save game/
                    fcb       $0a
                    fcc       /disk in drive %s./
                    fcb       $0a,$0a
                    fcc       /Press ENTER to continue./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to not/
                    fcb       $0a
StrSaveDiskAction   fcc       /%s a game./
                    fcb       0
StrDirExample       fcc       '(For example, "/d1" or "/h0/savegame")'
                    fcb       0
StrSaveGameMenu     fcc       /         SAVE GAME/
                    fcb       $0a,$0a
                    fcc       /On which disk or in which directory do you wish to save this game?/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a,0
StrRestoreGameMenu  fcc       /        RESTORE GAME/
                    fcb       $0a,$0a
                    fcc       /On which disk or in which directory is the game that you want to restore?/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a,0
StrArrowInstr       fcc       /Use the arrow keys to move/
                    fcb       $0a
                    fcc       /     the pointer to your name./
                    fcb       $0a
                    fcc       /Then press ENTER./
                    fcb       $0a,0
StrNoDirFound       fcc       /There is no directory named:/
                    fcb       $0a
                    fcc       /%s./
                    fcb       $0a
                    fcc       /Press ENTER to try again./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to cancel./
                    fcb       0
StrNoGamesToRestore fcc       /There are no games to/
                    fcb       $0a
                    fcc       /restore in:/
                    fcb       $0a,$0a
                    fcc       /%s/
                    fcb       $0a,$0a
                    fcc       /Press ENTER to continue./
                    fcb       0

StrSaveSlotSelect   fcc       /Use the arrow keys to select the slot in which you wish to save the game. /
                    fcc       /Press ENTER to save in the slot, /
                    fcc       /CTRL-BREAK to not save a game./
                    fcb       0

StrRestoreSelect    fcc       /Use the arrow keys to select the game which you wish to restore. /
                    fcc       /Press ENTER to restore the game, /
                    fcc       /CTRL-BREAK to not restore a game./
                    fcb       0

StrDiskFull         fcc       /   Sorry, this disk is full./
                    fcb       $0a
                    fcc       /Position pointer and press ENTER/
                    fcb       $0a
                    fcc       /    to overwrite a saved game/
                    fcb       $0a
                    fcc       /or press CTRL-BREAK and try again/
                    fcb       $0a
                    fcc       /    with another disk./
                    fcb       $0a,0


StateGetInfo        leas      -$02,s    allocate two local bytes on stack
                    clr       $01,s     initialize result slot to zero
                    lda       >$05B9    load cursor-blink state flag
                    sta       ,s        save it for restore on exit
                    lbsr      InputEditOn enable text-input edit mode
                    lbsr      PushTextColor save current text color
                    lbsr      PushRowCol save current row/col position
                    ldd       #$000F    white-on-black color code
                    lbsr      text_color set text color for menus
                    ldd       $04,s     load save/restore mode byte
                    pshs      b,a       pass mode as argument
                    lbsr      GetSavePath prompt user for save directory
                    leas      $02,s     discard argument
GetInfoLoop         beq       GetInfoCleanup branch if path selection cancelled
                    ldd       $04,s     reload mode byte
                    pshs      b,a       pass mode as argument
                    lbsr      CheckSaveDisk verify save disk is present
                    leas      $02,s     discard argument
                    beq       GetInfoCleanup branch if disk check cancelled
                    ldd       $04,s     reload mode byte
                    pshs      b,a       pass mode as argument
                    lbsr      GetSaveFilename show file/slot selection menu
                    leas      $02,s     discard argument
                    sta       $01,s     store slot selection result
                    beq       GetInfoCleanup branch if selection cancelled
                    lda       $05,s     load mode byte from original args
                    cmpa      #$73      check for save mode ('s')
                    bne       GetInfoRestoreSlot branch if restore mode
                    lda       >state_name_auto,pcr load auto-name flag
                    bne       GetInfoRestoreSlot branch if auto-name active
                    leax      >DataSaveGameBuf,pcr point X to save description buffer
                    leau      >StrSaveDesc,pcr point U to "describe game" prompt
                    lbsr      EditBoxInput show description entry box
                    tsta                test if user accepted input
GetInfoAbort        bne       GetInfoRestoreSlot branch if description accepted
                    clr       $01,s     clear result (abort)
                    bra       GetInfoCleanup skip to cleanup
GetInfoRestoreSlot  leax      >DataSaveGameBuf2,pcr point to second save buffer
                    ldb       $01,s     load selected slot index
                    lbsr      BuildSaveFilePath build full save-file path
GetInfoCleanup      lbsr      PopRowCol restore saved row/col position
                    lbsr      PopTextColor restore saved text color
                    lda       ,s        reload saved cursor-blink state
                    beq       GetInfoRet skip blink restore if was off
                    lbsr      InputCursorBlink re-enable cursor blinking
GetInfoRet          lda       $01,s     load slot-selection result
                    leas      $02,s     release local stack frame
                    rts
CheckSaveDisk       leas      >-$00A5,s allocate large local frame
                    lda       #$01      initialize result to success
                    sta       ,s        store default result
                    leau      >$00A1,s  point U to disk-name buffer
                    lbsr      GetDiskName read current disk name
                    lda       >SaveDriveNum,pcr load expected save drive number
                    cmpa      >$00A4,s  compare against read drive number
                    bne       CheckSaveDiskRet branch if wrong drive
                    cmpa      #$10      check if drive < $10 (floppy range)
                    bcc       CheckSaveDiskRet branch if out of floppy range
                    lbsr      VolumesClose close any open volume handles
                    leau      >StrSave,pcr default to "save" action string
                    lda       >$00A8,s  load mode byte
                    cmpa      #$73      check for save mode ('s')
                    beq       SaveDiskDoPrompt branch to show prompt with "save"
                    leau      >StrRestore,pcr switch to "restore" action string
SaveDiskDoPrompt    pshs      u         push action string ptr
                    leau      >$00A3,s  point U to drive name in buffer
                    pshs      u         push drive name ptr
                    leau      >StrSaveDiskPrompt,pcr point to disk-swap prompt template
                    leax      $05,s     point X past the two pushed ptrs
                    pshs      u         push prompt template ptr
                    pshs      x         push format-output buffer ptr
                    lbsr      PrintFmtStr format the prompt message
                    leas      $08,s     discard four pushed arguments
                    lbsr      message_box display formatted message to user
                    sta       ,s        store user response as result
CheckSaveDiskRet    lda       ,s        load result byte
                    leas      >$00A5,s  release local frame
                    rts
GetSavePath         leas      >-$00C8,s allocate local frame for path work
                    lda       >SaveDiskNameBuf,pcr load first byte of saved disk name
                    bne       GetSavePathCheck branch if name already set
                    leau      >SaveDiskNameBuf,pcr point to disk-name buffer
                    lbsr      FindCurrentDisk discover and store current disk name
                    leas      ,s        no-op leas (align stack)
GetSavePathCheck    tst       >state_name_auto,pcr check auto-name flag
                    bne       GetSavePathDone branch if auto mode (no prompt)
GetSavePathShowMenu leau      >StrDirExample,pcr point to example path string
                    pshs      u         push example string ptr
                    leau      >StrSaveGameMenu,pcr default to save-game menu text
                    ldb       >$00CD,s  load mode byte from frame
                    cmpb      #$73      check for save mode ('s')
                    beq       GetSavePathFormat branch if save mode
                    leau      >StrRestoreGameMenu,pcr switch to restore-game menu text
GetSavePathFormat   leax      $02,s     point X to output buffer
                    pshs      u         push menu text ptr
                    pshs      x         push output buffer ptr
                    lbsr      PrintFmtStr format the menu message
                    leas      $06,s     discard three pushed arguments
                    leax      >SaveDiskNameBuf,pcr point to disk-name edit buffer
                    lbsr      EditBoxInput let user type a directory path
                    tsta                test if user accepted
                    beq       GetSavePathDone branch if cancelled
                    leau      >SaveDiskNameBuf,pcr point to entered path
                    lbsr      StrToLower normalize path to lowercase
                    pshs      u         push path ptr
                    lbsr      GetDiskInfo check if directory exists
                    leas      $02,s     discard argument
                    bne       GetSavePathDone branch if directory found
                    leau      >SaveDiskNameBuf,pcr point to failed path for message
                    pshs      u         push failed-path ptr
                    leau      >StrNoDirFound,pcr point to "no directory" template
                    leax      $02,s     point past pushed ptr
                    pshs      u         push template ptr
                    pshs      x         push output buffer ptr
                    lbsr      PrintFmtStr format the error message
                    leas      $06,s     discard three pushed arguments
                    lbsr      message_box show error to user
                    bne       GetSavePathShowMenu loop back to re-prompt if retry
GetSavePathDone     leas      >$00C8,s  release local frame
                    rts
EditBoxInput        leas      -$03,s    allocate three local bytes
                    stx       ,s        save X (input string buffer ptr)
                    ldd       #$0001    top row = 1
                    pshs      b,a       push row argument
                    ldd       #$001F    width = 31 chars
                    pshs      b,a       push width argument
                    ldd       #$0000    left column = 0
                    pshs      b,a       push column argument
                    pshs      u         push message text ptr
                    lbsr      message_box_draw draw the dialog box frame
                    leas      $08,s     discard four arguments
                    ldd       #$0000    row 0, column 0
                    pshs      b,a       push cursor position
                    lda       >$0177    load screen row offset
                    ldb       >$0176    load screen column offset
                    std       <$0040    store current cursor position
                    ldb       >$0178    load box height
                    decb                adjust to last content row
                    pshs      b,a       push row value
                    ldb       >$0176    reload column offset
                    pshs      b,a       push column value
                    lbsr      ClearTextRect clear the edit area
                    leas      $06,s     discard three arguments
                    lbsr      PushTextColor save current text color
                    lda       #$0F      white color index
                    clrb                black background
                    lbsr      text_color set edit-box text color
                    ldb       #$1F      max input length = 31
                    ldx       ,s        restore input buffer pointer
                    lbsr      EditString run line-editing input loop
                    sta       $02,s     save terminator key pressed
                    lbsr      PopTextColor restore previous text color
                    lbsr      cmd_close_window close the dialog box
                    lda       #$01      assume accepted (non-zero)
                    ldb       $02,s     load terminator key
                    cmpb      #$0D      check for Enter key
                    beq       EditBoxRet branch with A=1 if Enter
                    clra                clear A: user cancelled
EditBoxRet          ldx       ,s        reload input buffer pointer
                    leas      $03,s     release local frame
                    rts
GetSaveFilename     leas      >-$0256,s allocate large frame for slot list
                    lda       #$01      flag input-active
                    sta       >$0154    set input state flag
                    lda       #$06      category index 6
                    sta       >$0547    store category for event filter
                    ldd       #$0000    initialize D to zero
                    sta       >$024C,s  clear selected slot index
                    std       >$024E,s  clear best-date high word
                    std       >$0250,s  clear best-date low word
                    lda       >$0259,s  load mode byte from caller
                    suba      #$72      subtract 'r' (restore offset)
                    beq       GetFilenameInitY branch if restore mode (result=0)
                    lda       #$0C      save mode: start from slot 12
GetFilenameInitY    std       >$024A,s  store mode flag and slot counter
GetFilenameLoop     cmpb      #$0C      check if all 12 slots scanned
                    lbcc      GetFilenameDone branch if scan complete
                    leau      >$0252,s  point to date buffer for this slot
                    pshs      u         push date-buffer ptr
                    incb                advance slot index
                    pshs      b,a       push slot number and mode
                    ldb       >$025D,s  reload mode byte
                    lda       >$024E,s  load best date high byte
                    cmpb      #$73      check for save mode ('s')
                    bne       GetFilenameCalc branch if restore mode
                    lda       >$024F,s  load low byte of best date
GetFilenameCalc     ldb       #$20      slot entry size = 32 bytes
                    mul                 compute slot offset (A×32)
                    leau      $06,s     base of slot-data area
                    leau      d,u       advance to this slot's entry
                    pshs      u         push slot entry ptr
                    lbsr      ReadSaveSlotEntry try to read save slot
                    leas      $06,s     discard three pushed arguments
                    beq       GetFilenameIncY branch if slot is empty
                    ldb       >$0259,s  reload mode byte
                    cmpb      #$73      check for save mode ('s')
                    bne       GetFilenameUpdateRestore branch if restore mode
                    ldd       >$0252,s  load this slot's date high word
                    cmpd      >$024E,s  compare against current best
                    bhi       GetFilenameUpdateSave branch if newer (higher)
                    bcs       GetFilenameIncY branch if older, skip
                    ldd       >$0254,s  load this slot's date low word
                    cmpd      >$0250,s  compare low date word
                    bls       GetFilenameIncY skip if not better
GetFilenameUpdateSave ldd       >$0254,s  load this slot's low date word
                    std       >$0250,s  store as new best low date
                    ldd       >$0252,s  load this slot's high date word
                    std       >$024E,s  store as new best high date
                    lda       >$024B,s  load current slot index
                    sta       >$024C,s  save as best save slot
                    bra       GetFilenameIncY advance to next slot
GetFilenameUpdateRestore ldd       >$0252,s  load this slot's date high word
                    cmpd      >$024E,s  compare against best (restore)
                    bhi       GetFilenameStoreBest branch if this slot is newer
                    bcs       GetFilenameIncX branch if older, skip
                    ldd       >$0254,s  load low date word
                    cmpd      >$0250,s  compare low date
                    bls       GetFilenameIncX skip if not better
GetFilenameStoreBest ldd       >$0254,s  store best low date for restore
                    std       >$0250,s  update best low date
                    ldd       >$0252,s  store best high date for restore
                    std       >$024E,s  update best high date
                    lda       >$024A,s  load restore-mode slot tracker
                    sta       >$024C,s  save as best restore slot
GetFilenameIncX     inc       >$024A,s  advance restore slot counter
GetFilenameIncY     inc       >$024B,s  advance scan slot counter
                    ldb       >$024B,s  reload counter into B
                    lbra      GetFilenameLoop continue scanning slots
GetFilenameDone     lda       >$024A,s  load slot-count (or best-slot index)
                    bne       GetFilenameCheck branch if at least one slot found
                    lda       >state_name_auto,pcr load auto-name flag
                    bne       GetFilenameSetup branch if auto mode
                    leau      >SaveDiskNameBuf,pcr point to save path for message
                    pshs      u         push path ptr
                    leau      >StrNoGamesToRestore,pcr point to "no games" message
                    leax      >$0184,s  point to output buffer in frame
                    pshs      u         push message template ptr
                    pshs      x         push output buffer ptr
                    lbsr      PrintFmtStr format the "no games" message
                    leas      $06,s     discard three pushed arguments
                    lbsr      message_box show message to user
                    clra                return zero = cancelled
                    lbra      GetFilenameExit exit without selection
GetFilenameCheck    lda       >state_name_auto,pcr check auto-name mode
                    lbeq      GetFilenameDrawList branch to draw list if not auto
GetFilenameSetup    lda       >DataSaveDiskFlag,pcr check disk-mode flag
                    bne       GetFilenameDiskMode branch if disk mode
                    leax      >state_name_auto,pcr point to auto-name string
                    leau      >DataSaveGameBuf,pcr point to description buffer
                    lbsr      StrCopy   copy auto-name into save buffer
                    clrb                start slot search at index 0
                    stb       >$024B,s  initialize slot scan counter
GetFilenameMatchLoop cmpb      #$0C      check if all 12 slots checked
                    bcc       GetFilenameMatchSave branch if past last slot
                    leau      >DataSaveGameBuf,pcr point to name to match
                    lda       #$20      slot entry size = 32 bytes
                    mul                 compute slot offset
                    leax      $02,s     base of slot-data area
                    leax      d,x       offset to this slot's data
                    leax      $01,x     point past slot header byte
                    lbsr      StrCompare compare name against slot entry
                    tsta                test comparison result
                    lbeq      GetFilenameAccept branch if name matches a slot
                    inc       >$024B,s  advance to next slot
                    ldb       >$024B,s  reload counter
                    lbra      GetFilenameMatchLoop continue searching
GetFilenameMatchSave lda       >$0259,s  load mode byte
                    cmpa      #$73      check for save mode ('s')
                    bne       GetFilenameCheckMode branch if restore mode
                    clrb                reset slot index to 0
                    stb       >$024B,s  store scan counter
GetFilenameMatchSaveLoop cmpb      #$0C      check if all slots scanned
                    bcc       GetFilenameCheckMode branch if done
                    lda       #$20      slot size = 32 bytes
                    mul                 compute slot offset
                    leax      $02,s     base of slot data
                    leax      d,x       offset to this slot
                    ldb       ,x        load first byte of slot entry
                    lda       $01,x     load second byte (name start)
                    lbeq      GetFilenameAccept branch if slot is empty (take it)
                    inc       >$024B,s  advance to next slot
                    ldb       >$024B,s  reload counter
                    lbra      GetFilenameMatchSaveLoop continue looking for empty slot
GetFilenameCheckMode lda       >$0259,s  load mode byte
                    suba      #$72      subtract 'r'; restore mode = 0
                    lbeq      GetFilenameExit exit if restore and no match
                    bra       GetFilenameDrawList draw list for save mode
GetFilenameDiskMode leau      >$0182,s  point to drive-info buffer
                    lbsr      GetDiskName read the disk name/drive number
                    lda       >$0185,s  load drive number from buffer
                    sta       >SaveDriveNum,pcr store drive number for later check
GetFilenameDrawList ldd       #$0001    top row = 1
                    pshs      b,a       push row argument
                    ldd       #$0022    dialog width = 34
                    pshs      b,a       push width argument
                    ldb       #$05      start row offset for list
                    stb       >$0251,s  save row offset
                    addb      >$024E,s  add base row to get first row
                    pshs      b,a       push computed first row
                    ldb       >state_name_auto,pcr check auto-name mode
                    beq       GetFilenameShowPrompt branch to show normal prompt
                    leau      >StrDiskFull,pcr point to "disk full" message
                    ldb       >DataSaveDiskFlag,pcr check disk-mode flag
                    beq       GetFilenameDrawList redraw if disk mode changed
                    leau      >StrArrowInstr,pcr point to arrow-key instructions
                    bra       GetFilenameDrawList redraw with new instructions
GetFilenameShowPrompt lda       >$025F,s  load mode byte
                    leau      >StrSaveSlotSelect,pcr default to save-slot prompt
                    cmpa      #$73      check for save mode ('s')
                    beq       GetFilenameDrawItems use save-slot prompt if save mode
                    leau      >StrRestoreSelect,pcr switch to restore-select prompt
GetFilenameDrawItems pshs      u         push prompt string ptr
                    lbsr      message_box_draw draw the selection dialog
                    leas      $08,s     discard four arguments
                    lda       >$024D,s  load starting row for list
                    adda      >$0175    add screen row offset
                    sta       >$024D,s  store adjusted row
                    clra                start at slot index 0
                    sta       >DataSaveDiskFlag,pcr clear disk-mode flag
                    sta       >$024B,s  initialize display slot counter
GetFilenameListLoop cmpa      >$024A,s  check if all slots rendered
                    bcc       GetFilenameHighlight branch when all drawn
                    adda      >$024D,s  add row offset to slot index
                    ldb       >$0176    load column
                    std       <$0040    set cursor position
                    lda       >$024B,s  load current slot index
                    ldb       #$20      slot entry size = 32
                    mul                 compute entry offset
                    leax      $02,s     base of slot-data area
                    leax      d,x       offset to this slot
                    leax      $01,x     skip slot header byte
                    pshs      x         push slot-name ptr
                    leax      >StrDescFmt,pcr point to " - %s" format string
                    pshs      x         push format string ptr
                    lbsr      PrintFmtStrToScr print slot description to screen
                    leas      $04,s     discard two arguments
                    inc       >$024B,s  advance slot index
                    lda       >$024B,s  reload counter
                    lbra      GetFilenameListLoop loop for next slot
GetFilenameHighlight lda       >$024C,s  load initially selected slot
                    sta       >$024B,s  set as current highlighted slot
                    adda      >$024D,s  compute row for highlight
                    lbsr      HighlightRow highlight the selected row
GetFilenameEventLoop lbsr      WaitForEvent wait for keyboard or joystick
                    stx       ,s        save event pointer to stack
                    lda       ,x        load event type byte
                    cmpa      #$01      check for keyboard event
                    bne       GetFilenameNavKey branch if not a key event
                    lda       $01,x     load key code
                    cmpa      #$0D      check for Enter key
                    bne       GetFilenameEscKey branch if not Enter
                    lbsr      cmd_close_window close the selection dialog
                    leau      >DataSaveGameBuf,pcr point to save description buffer
                    lda       >state_name_auto,pcr load auto-name flag
                    beq       GetFilenameCopyEntry branch if not auto mode
                    leau      >state_name_auto,pcr use auto-name as destination
GetFilenameCopyEntry lda       >$024B,s  load selected slot index
                    ldb       #$20      slot entry size = 32
                    mul                 compute slot offset
                    leax      $02,s     base of slot data
                    leax      d,x       offset to selected slot
                    pshs      x         push slot ptr (for X restore)
                    leax      $01,x     skip slot header byte
                    lbsr      StrCopy   copy slot name to description buf
                    puls      x         restore slot pointer
                    bra       GetFilenameAccept proceed with accepted slot
GetFilenameEscKey   cmpa      #$1B      check for Escape key
                    bne       GetFilenameEventLoop loop if other key
                    lbsr      cmd_close_window close dialog on Escape
                    clra                return zero = cancelled
                    bra       GetFilenameExit exit
GetFilenameNavKey   cmpa      #$02      check for joystick/nav event
                    bne       GetFilenameEventLoop ignore non-nav events
                    lda       >$024D,s  load row offset
                    adda      >$024B,s  add current slot index
                    ldb       $01,x     load nav sub-code
                    cmpb      #$01      check for up-arrow
                    bne       GetFilenameNextKey branch if not up
                    lbsr      NormalRow un-highlight current row
                    lda       >$024B,s  load current slot index
                    bne       GetFilenameDecIdx branch if not at top
                    lda       >$024A,s  wrap: load slot count
GetFilenameDecIdx   deca                decrement (or wrap) index
                    sta       >$024B,s  store new selected slot
                    adda      >$024D,s  compute new row
                    lbsr      HighlightRow highlight new row
                    bra       GetFilenameEventLoop wait for next event
GetFilenameNextKey  cmpb      #$05      check for down-arrow
                    bne       GetFilenameEventLoop ignore other codes
                    lbsr      NormalRow un-highlight current row
                    lda       >$024B,s  load current slot index
                    inca                advance to next slot
                    cmpa      >$024A,s  check if past last slot
                    bne       GetFilenameWrapIdx branch if not at end
                    clra                wrap to first slot
GetFilenameWrapIdx  sta       >$024B,s  store new selected slot
                    adda      >$024D,s  compute new row
                    lbsr      HighlightRow highlight new row
                    lbra      GetFilenameEventLoop wait for next event
GetFilenameAccept   lda       ,x        load event type as return value
GetFilenameExit     clr       >$0154    clear input-active flag
                    clr       >$0547    clear event category filter
                    leas      >$0256,s  release large local frame
                    rts
ReadSaveSlotEntry   leas      <-$48,s   allocate local frame for file ops
                    ldu       <$4A,s    load ptr to slot-data struct
                    ldb       <$4D,s    load slot index
                    stb       ,u        store index in slot struct
                    leax      ,s        point X to local path buffer
                    lbsr      BuildSaveFilePath construct save-file path string
                    lda       #$01      open flag = read-only
                    lbsr      OpenFile  open the save file
                    bcs       ReadSaveSlotFail branch if open failed
                    sta       <$47,s    save file path descriptor
                    lbsr      GetFileTime read file timestamp
                    ldy       <$4E,s    load ptr to timestamp output
                    stx       ,y++      store high word of timestamp
                    std       ,y        store low word of timestamp
                    ldy       #$001F    read 31 bytes (slot description)
                    ldx       <$4A,s    load slot-data ptr
                    leax      $01,x     skip first byte of slot data
                    lda       <$47,s    load file descriptor
                    lbsr      ReadFile  read description into slot
                    ldx       #$0000    seek offset high word = 0
                    ldu       #$0024    seek offset low = 36 (header end)
                    lda       <$47,s    load file descriptor
                    ldb       #$01      seek mode = from start
                    lbsr      SeekFile  seek to version record
                    ldy       #$0007    read 7 bytes (version string)
                    leax      <$40,s    point X to local buffer
                    lda       <$47,s    load file descriptor
                    lbsr      ReadFile  read version string
                    lda       <$47,s    load file descriptor
                    lbsr      CloseFilePath close the save file
                    ldu       #$01CE    point to expected version string
                    lbsr      StrCompare check version matches
                    bne       ReadSaveSlotFail branch if version mismatch
                    lda       #$01      return success (non-zero)
                    bra       ReadSaveSlotRet skip to return
ReadSaveSlotFail    clra                return zero = slot invalid/empty
                    ldu       <$4A,s    reload slot-data ptr
                    sta       $01,u     clear description byte
ReadSaveSlotRet     leas      <$48,s    release local frame
                    rts
HighlightRow        ldb       >$0176    load current column position
                    std       <$0040    set row+col cursor position
                    lda       #$1A      highlight marker character ($1A)
                    lbsr      PutCharToWindow write highlight marker to row
                    rts
NormalRow           ldb       >$0176    load current column position
                    std       <$0040    set row+col cursor position
                    lda       #$20      space character (un-highlight)
                    lbsr      PutCharToWindow write space to clear highlight
                    rts
*
*======================================================================
* GAME INITIALIZATION
*   Loads the table-of-contents, words.tok, and object data; initializes
*   the view object array, game variable and flag tables, and the logic
*   table.
*======================================================================
*
tOC                 fcc       /toc/
                    fcb       0
WordsTok            fcc       /words.tok/
                    fcb       0
Object              fcc       /object/
                    fcb       0

InitGameState       ldd       #$e000    initial timer/state value
                    std       <$2e      store to direct-page state field
                    ldd       #$4040    MMU block pair for main RAM
                    pshs      d         push MMU argument
                    lda       #$18      MMU twiddle opcode $18
                    sta       <$0021    store twiddle code
                    ldx       <$0028    load MMU context pointer
                    jsr       >$0701    call Sierra MMU twiddle routine
                    leas      $02,s     discard MMU argument
                    lbsr      events_clear clear all pending input events
                    lbsr      LoadAllDirs load all view directories
                    lda       #$0F      white-on-black color
                    clrb                black background
                    lbsr      text_color set initial text color
                    lbsr      InputRedraw redraw the input line
                    lbsr      JoystickReadInit initialize joystick hardware
                    leau      >tOC,pcr  point to "toc" filename
                    ldd       #$0000    destination address high = 0
                    pshs      b,a       push destination arg
                    ldd       #$0089    direct-page slot $89 for toc
                    pshs      b,a       push slot arg
                    ldd       #$0000    no extra flags
                    pshs      b,a       push flags arg
                    pshs      u         push filename ptr
                    lbsr      FileLoad  load the TOC (table of contents)
                    leas      $08,s     discard four arguments
                    ldu       <$0089    load pointer to TOC data
                    clra                clear A for 16-bit use
                    ldb       ,u+       load TOC entry count, advance ptr
                    stb       >$05ED    save volume count
                    tfr       d,x       transfer count to X for loop
                    stu       <$0089    update TOC data pointer
DiskInfoLoop        ldd       <$0089    load current absolute offset
                    addd      ,u        add relative offset from entry
                    std       ,u++      write back as absolute, advance
                    leax      -$01,x    decrement entry counter
                    bne       DiskInfoLoop loop for all TOC entries
                    leau      >WordsTok,pcr point to "words.tok" filename
                    ldd       #$01AA    slot for words data high
                    pshs      b,a       push slot arg
                    ldd       #$01A8    slot for words data low
                    pshs      b,a       push slot arg
                    ldd       #$0000    no extra flags
                    pshs      b,a       push flags arg
LoadWordsLoop       pshs      u         push filename ptr
                    lbsr      FileLoad  load words.tok vocabulary file
                    leas      $08,s     discard arguments
                    lbsr      ClearLogicTable clear all loaded logic scripts
                    lbsr      list_clear clear all view list entries
                    lbsr      SoundListClear clear all sound list entries
                    lbsr      PicListClear clear all picture list entries
                    bsr       LoadObjectData load and init object data table
                    clrb                logic slot 0 = main logic
                    lbsr      AllocLoadLogic load logic script 0
                    ldd       <$004F    load saved d.pc value
                    std       <$004D    restore program counter state
                    ldd       <$0055    load saved stack pointer
                    std       <$0053    restore stack state
                    lda       >$01AF    load sound status byte
                    ora       #$40      set sound-active bit
                    sta       >$01AF    store updated sound status
                    lbsr      SoundPIASave save PIA sound registers
                    lbsr      SoundPIARestore restore PIA sound registers
                    rts
LoadObjectData      leas      -$01,s    allocate one byte for object count
                    leau      >Object,pcr point to "object" filename
                    ldx       <$0038    load object-data buffer pointer
                    beq       LoadObjectSetup branch if not yet loaded
                    leax      -$03,x    back up past 3-byte header
                    stx       <$0038    store adjusted pointer
LoadObjectSetup     ldd       #$0000    no extra flags
                    pshs      b,a       push flags arg
                    ldd       #$0038    direct-page slot for objects
                    pshs      b,a       push slot arg
                    pshs      x         push existing buffer ptr
                    pshs      u         push filename ptr
                    lbsr      FileLoad  load object file into memory
                    leas      $08,s     discard four arguments
                    ldx       <$0038    load ptr to loaded object data
                    ldd       <$0066    load byte count of object file
                    leau      d,x       point past end of data
                    lbsr      XorDecrypt decrypt the object data in place
                    ldd       <$0066    reload file size
                    subd      #$0003    subtract 3-byte header size
                    std       <$003A    store object data size
                    ldu       <$0038    reload object data ptr
                    lda       $02,u     load object count from header
                    sta       ,s        save object count on stack
                    lda       $01,u     load high byte of names offset
                    ldb       ,u        load low byte of names offset
                    leau      $03,u     skip past 3-byte header
                    stu       <$0038    store updated data pointer
                    leau      d,u       advance U to names section
                    stu       <$003C    store names pointer
                    ldu       <$0038    reload pointer table start
FixupObjPtrs        cmpu      <$003C    check if past the pointer table
                    bcc       InitViewObjs branch when all ptrs fixed up
                    lda       $01,u     load high byte of relative ptr
                    ldb       ,u        load low byte of relative ptr
                    addd      <$0038    convert relative to absolute
                    std       ,u        write back absolute pointer
                    leau      $03,u     advance to next pointer entry
                    bra       FixupObjPtrs continue fixing up pointers
InitViewObjs        inc       ,s        increment object count (add ego)
                    ldu       <$0030    load view-object array pointer
                    bne       ClearViewObjs branch if array already allocated
                    lda       ,s        load object count
                    ldb       #$2B      view-object struct size = 43 bytes
                    mul                 compute total array size
                    std       <$0034    save total size
                    lbsr      AllocDataBlock allocate view-object array
                    stu       <$0030    store array base pointer
                    ldd       <$0034    reload total size
                    leau      d,u       point past end of array
                    stu       <$0032    store end-of-array pointer
                    leau      <-$2B,u   back up to last element
                    stu       <$0036    store last-element pointer
                    ldu       <$0030    reload array base
ClearViewObjs       ldx       <$0034    load array byte count
                    clrb                fill value = 0
                    lbsr      FillMem   zero-fill the view-object array
                    clra                start at index 0
SetViewObjIdx       cmpa      ,s        check if all objects initialized
                    bcc       ClearGameTables branch when done
                    sta       $02,u     store object index in struct
                    leau      <$2B,u    advance to next view-object slot
                    inca                increment index
                    bra       SetViewObjIdx loop for all objects
ClearGameTables     ldu       #$0431    point to game variable table
                    ldx       #$0100    256 bytes to clear
                    clrb                fill value = 0
                    lbsr      FillMem   zero all game variables
                    ldu       #$01AE    point to flag table
                    ldx       #$0020    32 bytes to clear
                    lbsr      FillMem   zero all game flags
                    lbsr      ClearInputBuffer clear keyboard input buffer
                    bsr       ResetGameTables reset logic/view/sound/pic tables
                    lbsr      ClearBothRanges clear terrain range tables
                    lda       #$09      default screen rows = 9
                    sta       >$0445    set rows variable
                    lda       >$0553    load screen height setting
                    sta       >$044B    store as pic-end row
                    lda       #$29      default priority base = 41
                    sta       >$0449    set priority variable
                    lda       >$01AE    load flag byte
                    ora       #$04      set initialized flag bit
                    sta       >$01AE    store updated flags
                    clra                value = 0
                    sta       >$0240    clear room-change flag
                    sta       >$01AC    clear sound-playing flag
                    inca                value = 1
                    sta       >$0250    set ego-visible flag
                    tst       >$0172    check if graphics mode active
                    bne       InitGameStateRet skip if graphics mode
                    sta       >$0447    enable input-line display
InitGameStateRet    leas      $01,s     release one-byte local frame
                    rts
ResetGameTables     lbsr      ResetLogicTable clear all logic script entries
                    lbsr      list_clear clear all view list entries
                    lbsr      SoundListClear clear all sound list entries
                    lbsr      PicListClear clear all picture list entries
                    rts
JoystickData        fcb       0,0,0
StrJoystickMsg      fcc       /If you have a joystick, and/
                    fcb       $0a
                    fcc       /wish to use it, press its/
                    fcb       $0a
                    fcc       /button./
                    fcb       $0a
                    fcc       /If not, press CTRL-BREAK to/
                    fcb       $0a
                    fcc       /continue./
                    fcb       0

*
*======================================================================
* JOYSTICK INITIALIZATION AND POLLING
*   Prompts the player for joystick calibration, polls the joystick
*   hardware each cycle, debounces buttons, and pushes joystick events
*   onto the event queue.
*======================================================================
*
cmd_init_joy        lda       <$0098    load joystick-enabled flag
                    eora      #$01      toggle bit 0 (enable/disable)
                    sta       <$0098    store updated joystick flag
                    beq       JoyInitDone branch if joystick now disabled
                    clr       <$0099    clear last joystick direction
ShowJoyMsg          leau      >StrJoystickMsg,pcr point to joystick prompt text
                    ldd       #$0000    row=0, column=0
                    pshs      b,a       push position argument
                    ldd       #$0020    width = 32 chars
                    pshs      b,a       push width argument
                    ldd       #$0000    left column = 0
                    pshs      b,a       push column argument
                    pshs      u         push message text ptr
                    lbsr      message_box_draw draw the joystick prompt box
                    leas      $08,s     discard four arguments
                    ldb       #$00      initial button state = 0
JoyInputLoop        stb       <$0097    save button state
                    lbsr      GetKeyEvent poll for key or joystick button
                    ldb       >$0541    load current button state
                    bne       JoyBtnRelease branch if button pressed
JoyInputCheck       ldb       <$0097    reload saved button state
                    eorb      #$01      toggle to invert flag
                    cmpa      #$1B      check for Escape/CTRL-BREAK
                    bne       JoyInputLoop loop if not Escape
                    clr       <$0098    disable joystick on Escape
                    lbsr      cmd_close_window close the joystick dialog
                    bra       JoyInitDone finish initialization
JoyBtnRelease       lbsr      cmd_close_window close dialog on button press
WaitJoyRelease      lbsr      ReadJoyButton read current button state
                    lda       >$0541    load button-pressed flag
                    bne       WaitJoyRelease loop until button released
JoyInitDone         lbsr      events_clear clear any pending events
                    rts
reset_joy           clr       >$0541    clear joystick button-pressed flag
                    clr       >$0542    clear button state counter
PollJoystick        lda       <$0098    load joystick-enabled flag
                    lbeq      JoyPollRet branch if joystick disabled
                    ldb       >$0547    load event filter flag
                    beq       JoystickUpdate branch if no filter active
                    ldx       <$009C    load joystick X accumulator
                    bne       JoyPollCheck branch if X accumulator active
                    ldx       <$009A    load joystick Y accumulator
                    bne       JoyPollCheck branch if Y accumulator active
                    clra                clear A for timestamp calc
CalcJoyDelta        orcc      #$50      disable interrupts for timer read
                    addd      >$024A    add timer delta to current time
                    std       <$009C    store X-axis timestamp
                    ldd       >$0248    load current time base
                    andcc     #$AF      re-enable interrupts
                    bcc       JoyDeltaStore branch if no overflow
                    addd      #$0001    increment high word on overflow
JoyDeltaStore       std       <$009A    store Y-axis timestamp
                    bne       JoyPollCheck branch if timestamp non-zero
                    ldd       <$009C    reload X-axis timestamp
                    bne       JoyPollCheck branch if non-zero
                    inc       <$009D    increment joystick tick counter
JoyPollCheck        orcc      #$50      disable interrupts for comparison
                    ldx       >$024A    load timer high word
                    ldd       >$0248    load timer low word
                    andcc     #$AF      re-enable interrupts
                    cmpd      <$009A    compare low timer to Y timestamp
                    bhi       JoystickUpdate branch if time exceeded Y
                    cmpx      <$009C    compare high timer to X timestamp
                    bls       JoyPollEnd skip update if not yet time
JoystickUpdate      ldd       #$0000    reset X-axis accumulator
                    std       <$009A    clear Y-axis accumulator too
                    std       <$009C    clear X-axis accumulator
                    bsr       ReadJoystick read raw joystick position
                    lbsr      CheckJoyDirection convert position to direction
                    ldb       >$0154    load input-active flag
                    bne       JoyCheckBtn branch if input is active
                    ldb       >$017F    load mouse-mode flag
                    beq       JoyCheckChange branch if not mouse mode
JoyCheckBtn         tsta                test direction value
                    beq       JoyPollEnd skip if direction is 0 (center)
                    bra       JoyPushEvent push direction event
JoyCheckChange      cmpa      <$0099    compare to last direction
                    beq       JoyPollEnd skip if direction unchanged
                    ldb       >$0102    load auto-move flag
                    bne       JoyPollEnd skip if auto-move active
                    sta       <$0099    save new direction
                    cmpa      >$0437    compare to current ego direction
                    beq       JoyPollEnd skip if same direction
JoyPushEvent        ldb       #$02      event type = joystick direction
                    lbsr      EventPush push direction event to queue
JoyPollEnd          bsr       PollJoyButton poll joystick button state
JoyPollRet          rts
ReadJoystick        pshs      y         save Y register across system call
                    lda       #$00      path number 0
                    ldb       #$13      GetStt code $13 = read joystick
                    ldx       <$0096    load joystick path descriptor
                    os9       I$GetStt  read joystick position
                    tfr       x,d       transfer result X to D
                    leax      >JoystickData,pcr point to joystick-data buffer
                    sty       $01,x     store Y-axis value
                    std       ,x        store X and button bytes
                    puls      y         restore Y register
                    rts
ReadJoyButton       pshs      y         save Y register across system call
                    lda       #$00      path number 0
                    ldb       #$13      GetStt code $13 = read joystick
                    ldx       <$0096    load joystick path descriptor
                    os9       I$GetStt  read joystick button state
                    sta       >$0541    store button-pressed flag
                    puls      y         restore Y register
                    rts
PollJoyButton       bsr       ReadJoyButton read raw joystick button state
                    lda       >$0542    load button state counter
                    cmpa      #$02      check if in debounce hold state
                    bne       JoyBtnState branch if not debouncing
                    orcc      #$50      disable interrupts for timer read
                    ldx       >$024A    load timer high word
                    ldd       >$0248    load timer low word
                    andcc     #$AF      re-enable interrupts
                    cmpd      >$0543    compare low timer to hold stamp
                    bcs       JoyBtnState branch if not yet time for click
                    bhi       JoyClickEvent branch if time exceeded (click)
                    cmpx      >$0545    compare high timer
                    bcs       JoyBtnState branch if not yet time
JoyClickEvent       clr       >$0542    clear button state counter
                    lda       #$FC      event code $FC = button click
                    ldb       #$01      event type = key event
                    lbsr      EventPush push button-click event
                    bra       JoyBtnTrack continue tracking
JoyBtnState         lda       >$0542    load button state counter
                    beq       JoyBtnTrack branch if no button history
                    cmpa      #$02      check if still in debounce
                    bne       JoyBtnHold branch if in hold state
JoyBtnTrack         lda       >$0541    load current button state
                    beq       PollJoyButtonRet branch if button not pressed
                    inc       >$0542    advance button state counter
                    bra       PollJoyButtonRet done
JoyBtnHold          cmpa      #$01      check if in initial-press state
                    bne       JoyBtnUp  branch if button was released
                    lda       >$0541    load button state
                    bne       PollJoyButtonRet branch if still held (wait)
                    lda       >$01AF    load sound/misc flags
                    anda      #$80      check high-speed repeat bit
                    beq       JoyClickEvent if set, trigger immediate click
                    clra                clear A for 16-bit calc
                    ldb       >$0440    load repeat-delay variable
                    orcc      #$50      disable interrupts
                    addd      >$024A    add delay to current time high
                    std       >$0545    store click timestamp high
                    ldd       >$0248    load current time low
                    andcc     #$AF      re-enable interrupts
                    bcc       JoyBtnTimestamp branch if no overflow
                    addd      #$0001    increment high word for overflow
JoyBtnTimestamp     std       >$0543    store click timestamp low
                    inc       >$0542    advance to debounce state
                    bra       PollJoyButtonRet done
JoyBtnUp            lda       >$0541    load button state
                    bne       PollJoyButtonRet branch if still pressed
                    clr       >$0542    clear button state counter
                    lda       #$FE      event code $FE = button release
                    ldb       #$01      event type = key event
                    lbsr      EventPush push button-release event
PollJoyButtonRet    rts
CheckJoyDirection   lda       $02,x     load Y-axis (vertical) value
                    ldb       $01,x     load X-axis (horizontal) value
                    cmpa      #$25      check if Y > center+threshold
                    bls       JoyDirLow branch if not pointing up
                    lda       #$08      assume up-left (direction 8)
                    cmpb      #$16      check if X < left threshold
                    bcs       JoyDirRet return up-left if X is left
                    lda       #$02      assume up-right (direction 2)
                    cmpb      #$25      check if X > right threshold
                    bhi       JoyDirRet return up-right if X is right
                    lda       #$01      up (direction 1, center X)
                    bra       JoyDirRet return up direction
JoyDirLow           cmpa      #$16      check if Y < center-threshold
                    bcc       JoyDirHigh branch if Y in center band
                    lda       #$06      assume down-left (direction 6)
                    cmpb      #$16      check if X < left threshold
                    bcs       JoyDirRet return down-left if X is left
                    lda       #$04      assume down-right (direction 4)
                    cmpb      #$25      check if X > right threshold
                    bhi       JoyDirRet return down-right if X is right
                    lda       #$05      down (direction 5, center X)
                    bra       JoyDirRet return down direction
JoyDirHigh          lda       #$07      assume left (direction 7)
                    cmpb      #$16      check if X < left threshold
                    bcs       JoyDirRet return left
                    lda       #$03      assume right (direction 3)
                    cmpb      #$25      check if X > right threshold
                    bhi       JoyDirRet return right
                    lda       #$00      center (no direction)
JoyDirRet           rts
JoyKeyMapPrimary    fcb       $1c,$01
                    fcb       $10,$02
                    fcb       $19,$03
                    fcb       $11,$04
                    fcb       $1a,$05
                    fcb       $12,$06
                    fcb       $18,$07
                    fcb       $13,$08
                    fcb       $00,$00
JoyKeyMapSecondary  fcb       $0c,$01
                    fcb       $09,$03
                    fcb       $0a,$05
                    fcb       $08,$07
                    fcb       $00,$00

*
*======================================================================
* KEYBOARD INPUT
*   Drains the keyboard path, polls for key presses, looks up direction
*   mappings, and pushes key events onto the event queue.
*======================================================================
*
clear_key_queue     lbsr      ReadStdinByte read a byte from stdin
                    tsta                test if byte was available
                    bne       clear_key_queue loop until no more bytes
                    rts
PollKeyInput        lbsr      ReadStdinByte read next key from stdin
                    tsta                test if a key was read
                    beq       PollKeyInputRet branch if no key available
                    bsr       LookupKeyInTable look up key in joy-key map
                    tstb                test B for sign (FF = not found)
                    bmi       CheckKeyTable2 branch if not in primary table
                    ldb       #$02      event type = joystick direction
                    bra       PushKeyEvent push the mapped event
CheckKeyTable2      cmpa      #$0C      check for Ctrl-L (clear screen)
                    beq       PollKeyInputRet discard Ctrl-L silently
                    ldb       #$01      event type = keyboard key
PushKeyEvent        lbsr      EventPush push keyboard/direction event
PollKeyInputRet     rts
LookupKeyInTable    leax      >JoyKeyMapPrimary,pcr point to primary map
LookupKeyLoop       cmpa      ,x+       compare key to map entry
                    beq       LookupKeyMatch branch on match
                    ldb       ,x+       load direction byte (skip it)
                    bne       LookupKeyLoop loop if not end of table
                    ldb       >$0154    load input-active flag
                    beq       LookupKeyNoMatch branch if not active input
                    leax      >JoyKeyMapSecondary,pcr try secondary key map
LookupKeyLoop2      cmpa      ,x+       compare key to secondary entry
                    beq       LookupKeyMatch branch on match
                    ldb       ,x+       skip direction byte
                    bne       LookupKeyLoop2 loop if not end of table
LookupKeyNoMatch    ldb       #$FF      signal not found ($FF)
                    bra       LookupKeyRet return not-found
LookupKeyMatch      lda       ,x        load mapped direction value
                    clrb                clear B: match found
LookupKeyRet        rts
LogicTableData      fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0
                    fcb       0,0

*
*======================================================================
* LOGIC TABLE MANAGEMENT
*   Initialises, resets, and searches the fixed-size table of loaded
*   logic scripts; each slot holds a logic number, data pointer, and
*   script pointer.
*======================================================================
*
ClearLogicTable     leax      >LogicTableData,pcr point to logic table
                    ldd       #$0000    zero value
                    std       ,x        clear first two bytes (head ptr)
                    rts
ResetLogicTable     leay      >LogicTableData,pcr point to logic table head
                    ldy       ,y        load first entry pointer
                    beq       ResetLogicTableRet branch if table is empty
                    ldd       #$0000    zero value
                    std       ,y        clear head of first entry
ResetLogicTableRet  rts
FindLogicSlot       leau      >LogicTableData,pcr start search at table head
FindLogicSlotLoop   stu       <$0064    save current slot pointer
                    ldu       ,u        follow next-pointer chain
                    beq       FindLogicSlotRet branch at end of list
                    cmpb      $02,u     compare logic number to slot
                    bne       FindLogicSlotLoop continue if not a match
FindLogicSlotRet    rts
*
*======================================================================
* LOGIC LOADING
*   Implements load_logics and load_logics_v: allocates a heap node,
*   loads and optionally decrypts the script from a volume file, and
*   registers it in the logic table.
*======================================================================
*
cmd_load_logics     ldb       ,y+       load logic number from script
                    bsr       LoadLogicNum load and allocate the logic
                    rts
cmd_load_logics_v   ldb       ,y+       load variable number from script
                    ldx       #$0431    point to variable table base
                    abx                 index to the variable
                    ldb       ,x        load logic number from variable
                    bsr       LoadLogicNum load and allocate the logic
                    rts
LoadLogicNum        leas      -$01,s    allocate one byte for logic num
                    stb       ,s        save logic number
                    lda       #$00      push-script flag = 0
                    lbsr      PushScript push current script state
                    ldb       ,s        reload logic number
                    bsr       AllocLoadLogic allocate and load the logic
                    leas      $01,s     release local byte
                    rts
AllocLoadLogic      leas      -$07,s    allocate local frame
                    stb       ,s        save logic number
                    bsr       FindLogicSlot search for existing slot
                    cmpu      #$0000    check if slot already loaded
                    bne       AllocLoadLogicRet branch if already in memory
                    ldd       <$000A    load current heap end
                    std       $03,s     save heap end for restore
                    lbsr      ClearBothRanges clear terrain ranges
                    ldd       #$000C    alloc size = 12 bytes per slot
                    lbsr      AllocDataBlock allocate a logic slot entry
                    ldx       <$0064    load prev-slot pointer
                    stu       ,x        link new slot into list
                    ldd       #$0000    zero value
                    std       ,u        clear next-pointer in new slot
                    ldb       ,s        reload logic number
                    stb       $02,u     store logic number in slot
                    stu       $01,s     save slot ptr for later
                    lbsr      FetchLogic fetch logic from volume file
                    ldx       #$0000    seek type = start
                    lbsr      OpenVolFile open the volume file
                    beq       AllocLoadLogicEnd branch if open failed
                    ldx       $01,s     reload slot pointer
                    std       $04,x     store volume file descriptor
                    leau      $02,u     advance past descriptor bytes
                    stu       $06,x     store data pointer
                    stu       $08,x     store scan-start pointer
                    ldb       -$02,u    load high byte of message offset
                    lda       -$01,u    load low byte of message offset
                    leau      d,u       advance to messages section
                    lda       ,u+       load number of messages
                    stu       $0A,x     store message-table pointer
                    sta       $03,x     store message count
                    beq       AllocLoadLogicEnd branch if no messages
                    lda       <$009E    load decrypt-messages flag
                    beq       AllocLoadLogicEnd branch if decryption disabled
                    ldd       <$0062    save current logic context
                    std       $05,s     save to local frame
                    stx       <$0062    set new logic as current
                    clrb                message index = 0
                    lbsr      GetMsgPtr get pointer to first message
                    clra                clear A for 16-bit calc
                    ldb       $03,x     load message count
                    ldx       $0A,x     load message-table pointer
                    addd      #$0001    add 1 (for null terminator)
                    lslb                multiply by 2 (word ptrs)
                    rola                rotate into A
                    leax      d,x       advance X past pointer table
                    lbsr      XorDecrypt decrypt message strings
                    ldd       $05,s     restore saved logic context
                    std       <$0062    write back current logic ptr
AllocLoadLogicEnd   lbsr      SwapObjRanges swap object range tables
                    ldd       $03,s     reload saved heap end
                    lbsr      SetLogicPage set MMU page for logic data
                    ldu       $01,s     reload slot pointer
AllocLoadLogicRet   leas      $07,s     release local frame
                    rts
*
*======================================================================
* LOGIC EXECUTION ENGINE
*   Implements call, call_v, set_scan_start, reset_scan_start, and the
*   ExecLogic bytecode interpreter loop that dispatches commands and
*   evaluates conditions.
*======================================================================
*
cmd_call            leas      -$02,s    allocate two bytes for Y save
                    ldb       ,y+       load logic number from script
                    sty       ,s        save current script pointer Y
                    bsr       ExecLogic execute the called logic
                    leay      ,y        test Y for null (end of logic)
                    beq       CmdCallRet branch if logic returned null
                    ldy       ,s        restore caller's Y pointer
CmdCallRet          leas      $02,s     release local frame
                    rts
cmd_call_v          leas      -$02,s    allocate two bytes for Y save
                    ldb       ,y+       load variable number from script
                    ldx       #$0431    point to variable table
                    abx                 index to the variable
                    ldb       ,x        load logic number from variable
                    sty       ,s        save current script Y pointer
                    bsr       ExecLogic execute the logic by variable
                    leay      ,y        test Y for null
                    beq       CmdCallVRet branch if returned null
                    ldy       ,s        restore caller's Y pointer
CmdCallVRet         leas      $02,s     release local frame
                    rts
ExecLogic           leas      -$0A,s    allocate local execution frame
                    stb       ,s        save logic number to execute
                    ldd       <$0062    load current logic context ptr
                    std       $01,s     save for restore on return
                    lda       #$01      was-pre-loaded flag = true
                    sta       $03,s     store pre-loaded flag
                    ldb       ,s        reload logic number
                    lbsr      FindLogicSlot search for already-loaded slot
                    stu       <$0062    set as current logic context
                    beq       ExecLogicLoad branch if not found (must load)
                    ldd       $04,u     load volume page for this logic
                    lbsr      SetLogicPage set MMU page for execution
                    bra       ExecLogicRun start execution
ExecLogicLoad       ldd       <$0064    load last-slot pointer
                    std       $04,s     save for cleanup on return
                    ldb       ,s        reload logic number
                    lbsr      AllocLoadLogic allocate and load the logic
                    stu       <$0062    set new slot as current context
                    stu       $06,s     save new slot pointer
                    lda       $04,u     load volume page
                    ldu       $06,u     load data pointer
                    leau      -$02,u    back up to priority header
                    lbsr      CalcPriAddr compute priority address
                    stu       $08,s     save priority address
                    clr       $03,s     clear pre-loaded flag
ExecLogicRun        lda       <$0068    load re-exec state flag
                    beq       ExecLogicRetState branch if not re-executing
                    cmpa      #$02      check for re-exec state 2
                    bne       ExecLogicRetState branch if other state
                    lda       #$01      reset to state 1
                    sta       <$0068    store updated state
ExecLogicRetState   lda       ,s        load logic number
                    bne       ExecLogicRetCheck branch if not logic 0
                    lda       #$01      set room-init flag
                    sta       <$0069    store init flag
ExecLogicRetCheck   lbsr      ExecLogicScript run the logic script bytecodes
                    lda       $03,s     check was-pre-loaded flag
                    bne       ExecLogicRestore branch if was pre-loaded
                    ldd       #$0000    zero value
                    ldx       $04,s     reload cleanup slot pointer
                    std       ,x        unlink slot from list
                    lbsr      ClearBothRanges clear terrain ranges
                    ldd       $08,s     reload saved priority address
                    std       <$004F    restore heap pointer
                    ldd       $06,s     reload saved slot pointer
                    std       <$0055    restore stack state
                    lbsr      SwapObjRanges swap range tables back
ExecLogicRestore    ldu       $01,s     reload saved context pointer
                    stu       <$0062    restore previous logic context
                    beq       ExecLogicRet branch if context was null
                    ldd       $04,u     load page for restored context
                    lbsr      SetLogicPage restore MMU page mapping
ExecLogicRet        leas      $0A,s     release local execution frame
                    rts
cmd_set_scan_start  ldx       <$0062    load current logic slot pointer
                    sty       $08,x     store Y as new scan-start pointer
                    rts
cmd_reset_scan_start ldx       <$0062    load current logic slot pointer
                    ldd       $06,x     load saved start-of-script ptr
                    std       $08,x     reset scan pointer to start
                    rts
BuildLogicList      leau      >LogicTableData,pcr point to logic table head
                    ldx       #$0554    point to output list buffer
BuildLogicListLoop  lda       $02,u     load logic number from slot
                    sta       ,x        store number in output list
                    ldd       $08,u     load scan-position pointer
                    subd      $06,u     compute offset from start
                    std       $01,x     store offset in list entry
                    leax      $03,x     advance to next list entry
                    ldu       ,u        follow next-pointer in table
                    bne       BuildLogicListLoop loop while more slots
                    lda       #$FF      end-of-list sentinel
                    sta       ,x        write sentinel
                    tfr       x,d       transfer end ptr to D
                    subd      #$0553    compute list byte count
                    tfr       d,x       return count in X
                    rts
SeekLogicInList     ldx       #$0554    point to logic scan-offset list
SeekLogicListLoop   lda       ,x        load logic number from list
                    cmpa      #$FF      check for end-of-list sentinel
                    beq       SeekLogicListRet branch at end of list
                    cmpa      $02,u     compare to slot's logic number
                    beq       SeekLogicFound branch on match
                    leax      $03,x     advance to next list entry
                    bra       SeekLogicListLoop continue searching
SeekLogicFound      ldd       $06,u     load start-of-script pointer
                    addd      $01,x     add saved offset to start
                    std       $08,u     restore scan pointer position
SeekLogicListRet    rts
StrOutOfMemory      fcc       /Out of %s memory./
                    fcb       $0a
StrWantHave         fcc       /Want: %d, Have: %d/
                    fcb       0

StrHeap             fcc       /heap/
                    fcb       0

StrCommon           fcc       /common/
                    fcb       0

*
*======================================================================
* HEAP MEMORY MANAGEMENT
*   AllocHeap and AllocDataBlock carve fixed-size blocks from the shared
*   data arena; UpdateFreeSpace recomputes the free-memory variable.
*======================================================================
*
AllocHeap           leas      -$34,s    allocate large local frame
                    std       ,s        save requested heap size
                    ldd       <$4f      load current heap pointer
                    tfr       d,u       save current heap ptr in U
                    addd      ,s        add requested size
                    bhs       AllocHeapOk branch if no overflow
AllocHeapFull       ldd       #$FFFF    compute available space
                    subd      <$004F    subtract current heap ptr
                    addd      #$0001    round up by one
                    pshs      b,a       push available size
AllocHeapFailMsg    ldd       $02,s     load requested size
                    pshs      b,a       push requested size
                    leax      >StrHeap,pcr point to "heap" type string
                    bra       ShowOutOfMemMsg show out-of-memory error
AllocHeapOk         std       <$004F    store new heap pointer
                    lbsr      UpdateFreeSpace update free-space display
                    ldd       <$004F    reload new heap end
                    cmpd      <$004B    compare to high-water mark
                    bls       AllocHeapRet skip if not a new record
                    std       <$004B    update high-water mark
AllocHeapRet        leas      <$34,s    release local frame
                    rts
AllocDataBlock      leas      <-$34,s   allocate local frame
                    std       ,s        save requested block size
                    ldd       <0        load stack bottom limit
                    subd      <$0055    subtract current data top
                    cmpd      ,s        compare to requested size
                    bcc       AllocDataBlockOk branch if enough space
                    pshs      b,a       push available space
                    ldd       $02,s     load requested size
                    pshs      b,a       push requested size
AllocDataBlockFail  leax      >StrCommon,pcr point to "common" type string
ShowOutOfMemMsg     pshs      x         push memory-type string ptr
                    leax      >StrOutOfMemory,pcr point to error message template
                    leau      $08,s     point to output buffer in frame
                    pshs      x         push template ptr
                    pshs      u         push output buffer ptr
                    lbsr      PrintFmtStr format the out-of-memory message
                    leas      $0A,s     discard arguments
                    lbsr      message_box display error to user
                    lda       #$03      fatal error code
                    sta       <$0009    signal fatal abort
                    ldx       <$0022    load module exit vector
                    jsr       >$0701    call exit via MMU twiddle
AllocDataBlockOk    ldd       <$0055    load current data-block top
                    tfr       d,u       save start address in U
                    addd      ,s        add requested size
                    std       <$0055    update data-block top pointer
                    cmpd      <$0051    compare to high-water mark
                    bls       AllocDataBlockRet skip if not a new record
                    std       <$0051    update high-water mark
AllocDataBlockRet   leas      <$34,s    release local frame
                    rts
ResetHeap           lbsr      ResetObjRanges reset object range tables
                    ldd       <$004D    load saved heap base
                    std       <$004F    restore heap pointer
                    bsr       UpdateFreeSpace update free-space counter
                    ldd       <$0053    load saved data-block base
                    std       <$0055    restore data-block pointer
                    rts
UpdateFreeSpace     ldd       #$FFFF    compute free space = $FFFF minus ptr
                    subd      <$004F    subtract current heap pointer
                    sta       >$0439    store high byte of free space
                    rts
CalcPriAddr         suba      <$005F    subtract priority base row offset
                    ldb       #$20      bytes per priority strip = 32
                    mul                 A×32 = byte offset into strip
                    exg       b,a       swap bytes (shift left 8)
                    subd      #$2000    subtract $2000 for final addr
                    leau      d,u       advance U by computed offset
                    rts
*
*======================================================================
* PRIORITY COORDINATE CALCULATION
*   Converts a screen Y coordinate to a priority value and maps a view's
*   logic page into the address space.
*======================================================================
*
CalcPriCoord        tfr       u,d       transfer priority address to D
                    anda      #$1F      isolate column within strip
                    adda      #$20      add $20 base column
                    exg       d,u       swap D and U
                    lsra                shift right (divide by 2)
                    lsra                shift right
                    lsra                shift right
                    lsra                shift right
                    lsra                shift right (divide by 32)
                    adda      <$005F    add priority base row to result
                    tfr       a,b       copy row to B
                    incb                increment for 1-based row
                    rts
SetLogicPage        cmpa      <$000A    check if page already set
                    beq       SetLogicPageRet skip if no change needed
                    orcc      #$50      disable interrupts during switch
                    std       <$000A    save new page number
                    lda       <$0042    load current MMU shadow byte
                    sta       >$FFA9    write to MMU slot 9
                    ldx       <$0043    load MMU control register ptr
                    lda       <$000A    load new page high byte
                    sta       ,x        set MMU slot high
                    stb       $02,x     set MMU slot low
                    std       >$FFA9    commit page change to MMU
                    andcc     #$AF      re-enable interrupts
SetLogicPageRet     rts
MenuExtraFlag       fcb       1
MenuItemCurrent     fcb       0,0
MenuCurrent         fcb       0,0
MenuItemNum         fcb       0
MenuItemMaxLen      fcb       0
MenuHead            fcb       0,0
MenuCurWidth        fcb       0
MenuItemRow         fcb       0
MenuItemWidth       fcb       0
MenuItemCol         fcb       0
MenuItemHeight      fcb       0
MenuSubmitted       fcb       0
*
*======================================================================
* MENU SYSTEM — BUILD PHASE
*   Implements set_menu, set_menu_item, and submit_menu: allocates
*   linked-list nodes for menus and items, calculates geometry, and
*   finalises the menu structure.
*======================================================================
*
cmd_set_menu        leas      -$04,s    allocate four local bytes
                    ldb       ,y+       load message number from script
                    lbsr      GetMsgPtr get pointer to menu-title message
                    stu       ,s        save title message pointer
                    ldu       <$0062    load current logic context
                    ldd       $04,u     load volume page for logic
                    std       $02,s     save page for later
                    lda       >MenuSubmitted,pcr check if menu already submitted
                    bne       SetMenuItemReturn skip if menu locked
                    ldd       #$0010    allocate 16 bytes per menu entry
                    lbsr      AllocDataBlock allocate new menu entry
                    ldd       >MenuHead,pcr load head of menu linked list
                    bne       SetMenuAppend branch if list non-empty
                    stu       >MenuHead,pcr store as first menu entry
                    lda       #$01      initial column = 1
                    sta       >MenuCurWidth,pcr set running column counter
                    bra       SetMenuLink link the entry
SetMenuAppend       ldx       >MenuCurrent,pcr load current (last) menu entry
                    stu       ,x        link new entry after current
                    stx       $02,u     link back to previous
                    ldd       $0B,x     check item list pointer
                    bne       SetMenuLink branch if items already set
                    sta       $0A,x     store active flag in prev entry
SetMenuLink         ldx       >MenuHead,pcr load menu head pointer
                    stx       ,u        wrap new entry to point to head
                    stu       $02,x     point head's back-link to new
                    stu       >MenuCurrent,pcr update current-entry pointer
                    ldd       #$0000    zero value
                    std       $0B,u     clear item-list pointer
                    sta       $08,u     clear item count
                    sta       $0F,u     clear visible-items count
                    lda       >MenuCurWidth,pcr load current column offset
                    sta       $09,u     store column in entry
                    lda       #$01      item number = 1 (first)
                    sta       $0A,u     store enabled flag
                    ldx       ,s        load title message pointer
                    stx       $04,u     store title ptr in entry
                    ldd       $02,s     load saved volume page
                    std       $06,u     store page in entry
                    lbsr      StrLen    measure title string length
                    incb                add 1 for separator space
                    addb      >MenuCurWidth,pcr add to running column width
                    stb       >MenuCurWidth,pcr update column counter
                    ldd       #$0000    zero item-current pointer
                    std       >MenuItemCurrent,pcr clear item-current
                    lda       #$01      first item number = 1
                    sta       >MenuItemNum,pcr set item-number counter
SetMenuItemReturn   leas      $04,s     release local frame
                    rts
cmd_set_menu_item   leas      -$05,s    allocate five local bytes
                    ldb       ,y+       load message number from script
                    lbsr      GetMsgPtr get pointer to item-label message
                    stu       ,s        save label pointer
                    ldu       <$0062    load current logic context
                    ldd       $04,u     load volume page for logic
                    std       $02,s     save page for later
                    lda       ,y+       load item action code from script
                    sta       $04,s     save action code
                    lda       >MenuSubmitted,pcr check if menu locked
                    bne       SetMenuItemRet skip if locked
                    ldd       #$000C    allocate 12 bytes per item
                    lbsr      AllocDataBlock allocate menu-item entry
                    ldx       >MenuItemCurrent,pcr load current item pointer
                    bne       SetMenuItemAppend branch if item list exists
                    ldx       >MenuCurrent,pcr load current menu entry
                    stu       $0D,x     store item as tail of list
                    stu       $0B,x     store item as head of list
                    stu       $02,u     point item back to itself
                    bra       SetMenuItemLink link into menu
SetMenuItemAppend   stu       ,x        link new item after current
                    stx       $02,u     link back to previous
                    ldx       >MenuCurrent,pcr load current menu entry
SetMenuItemLink     ldx       $0B,x     load head-of-item-list ptr
                    stx       ,u        wrap new item to head
                    stu       $02,x     point head's back-link to new
                    stu       >MenuItemCurrent,pcr update item-current pointer
                    ldx       ,s        load label message pointer
                    stx       $04,u     store label ptr in item
                    ldd       $02,s     load saved volume page
                    std       $06,u     store page in item
                    lda       >MenuItemNum,pcr load current item count
                    inc       >MenuItemNum,pcr increment item count
                    cmpa      #$01      check if this is first item
                    bne       SetMenuItemNumChk branch if not first
                    lbsr      StrLen    measure item-label length
                    negb                negate for subtraction
                    addb      #$27      compute available width (39-len)
                    ldx       >MenuCurrent,pcr load current menu entry
                    cmpb      $09,x     compare to column offset
                    bls       SetMenuItemMaxLen branch if not wider
                    ldb       $09,x     use column offset as max
SetMenuItemMaxLen   stb       >MenuItemMaxLen,pcr store max item label length
SetMenuItemNumChk   ldd       >MenuItemNum,pcr load current item number
                    std       $08,u     store item number in entry
                    lda       #$01      default enabled flag = on
                    sta       $0A,u     store enabled flag
                    lda       $04,s     load saved action code
                    sta       $0B,u     store action code in item
                    ldx       >MenuCurrent,pcr load current menu entry
                    inc       $0F,x     increment item count in menu
SetMenuItemRet      leas      $05,s     release local frame
                    rts
cmd_submit_menu     ldu       >MenuCurrent,pcr load current (last) menu entry
                    ldd       $0B,u     check if item-list pointer set
                    bne       SubmitMenuFinalize branch if items already linked
                    sta       $0A,u     store active flag in last entry
SubmitMenuFinalize  ldd       <$0055    save current data-block pointer
                    std       <$0053    as menu-state base
                    ldu       >MenuHead,pcr load head of menu list
                    stu       >MenuCurrent,pcr reset current to head
                    ldd       $0B,u     load head's item-list pointer
                    std       >MenuItemCurrent,pcr set item-current to first item
                    lda       #$01      menu-submitted flag = true
                    sta       >MenuSubmitted,pcr lock the menu structure
                    rts
cmd_enable_item     lda       ,y+       load item action code from script
                    ldb       #$01      enable flag = 1
                    bsr       SetItemEnable set item to enabled
                    rts
EnableItemLoop      ldu       >MenuHead,pcr load menu head pointer
                    beq       EnableItemRet branch if no menus
EnableItemScan      lda       $0A,u     load menu enabled flag
                    beq       EnableItemNext skip if menu is disabled
                    ldx       $0B,u     load head of item list
EnableItemInner     lda       #$01      enable flag
                    sta       $0A,x     mark item as enabled
                    ldx       ,x        follow next-item pointer
                    cmpx      $0B,u     check if wrapped to head
                    bne       EnableItemInner continue until all items done
EnableItemNext      ldu       ,u        advance to next menu entry
                    cmpu      >MenuHead,pcr check if wrapped to head
                    bne       EnableItemScan continue scanning menus
EnableItemRet       rts
cmd_disable_item    lda       ,y+       load item action code from script
                    ldb       #$00      enable flag = 0
                    bsr       SetItemEnable set item to disabled
                    rts
SetItemEnable       leas      -$02,s    allocate two bytes for D
                    std       ,s        save action code and flag
                    ldu       >MenuHead,pcr load head of menu list
SetItemEnableLoop   lda       $0A,u     check menu enabled flag
                    beq       SetItemEnableNext skip if menu disabled
                    ldx       $0B,u     load head of this menu's items
                    ldd       ,s        load action code and flag
SetItemEnableInner  cmpa      $0B,x     compare action code to item's
                    bne       SetItemEnableMatch branch if action code matches
                    stb       $0A,x     update enabled flag in item
SetItemEnableMatch  ldx       ,x        follow next-item pointer
                    cmpx      $0B,u     check if wrapped to list head
                    bne       SetItemEnableInner continue through all items
SetItemEnableNext   ldu       ,u        advance to next menu entry
                    cmpu      >MenuHead,pcr check if back at menu head
                    bne       SetItemEnableLoop continue through all menus
                    leas      $02,s     release two-byte local frame
                    rts
*
*======================================================================
* MENU SYSTEM — INPUT AND DRAW
*   Implements menu_input and the interactive menu event loop; draws the
*   menu bar and items with highlight, and handles keyboard/joystick
*   navigation.
*======================================================================
*
cmd_menu_input      lda       >$01AF    load misc-flags byte
                    anda      #$02      isolate menu-input-allowed bit
                    beq       MenuInputRet branch if menu input disabled
                    lda       #$01      enable flag = true
                    sta       >$05AE    set menu-input-active flag
MenuInputRet        rts
cmd_show_menu       ldb       ,y+       load show-menu flag from script
                    stb       >MenuExtraFlag,pcr store as menu-extra flag
                    rts
DrawMenuBar         leas      -$04,s    allocate four local bytes
                    lda       >MenuExtraFlag,pcr load menu-extra flag
                    lbeq      MenuInputExit branch if flag not set
                    lbsr      PushRowCol save current row/col
                    lbsr      PushTextColor save current text color
                    ldd       #$000F    white-on-black color
                    lbsr      ClearTextLine clear the menu bar row
                    ldu       >MenuHead,pcr load head of menu list
DrawMenuBarLoop     stu       ,s        save current menu entry ptr
                    ldx       ,s        reload as X for drawing
                    lbsr      DrawMenuItemNormal draw this menu title normal
                    ldu       ,s        reload current menu ptr
                    ldu       ,u        follow to next menu entry
                    cmpu      >MenuHead,pcr check if wrapped to head
                    bne       DrawMenuBarLoop loop for all menu titles
                    ldd       >MenuItemCurrent,pcr load current item pointer
                    std       $02,s     save to local frame
                    ldu       >MenuCurrent,pcr load current menu pointer
                    stu       ,s        save to local frame
                    lbsr      DrawMenuItem draw selected item highlighted
                    lda       #$01      input-active flag
                    sta       >$0154    set input capture mode
                    lda       #$03      event category = menu nav
                    sta       >$0547    set event filter
MenuInputEventLoop  lbsr      WaitForEvent wait for key or joystick event
                    lda       ,x        load event type
                    cmpa      #$01      check for keyboard event
                    bne       MenuNavEvent branch if not keyboard
                    lda       $01,x     load key code
                    cmpa      #$0D      check for Enter key
                    bne       MenuEscCheck branch if not Enter
                    ldu       $02,s     load current item pointer
                    lda       $0A,u     load item enabled flag
                    beq       MenuInputEventLoop skip if item disabled
                    lda       $0B,u     load item action code
                    ldb       #$03      event type = menu selection
                    lbsr      EventPush push menu-selection event
                    bra       MenuInputAccept exit menu mode
MenuEscCheck        cmpa      #$1B      check for Escape key
                    lbne      MenuNavUpdate treat non-Esc as nav update
MenuInputAccept     ldu       ,s        load current menu entry
                    ldx       $02,s     load current item pointer
                    lbsr      EraseMenuItem erase the highlighted item
                    clr       >$0547    clear event filter
                    lbsr      PopTextColor restore text color
                    lbsr      PopRowCol restore row/col
                    lda       >$0246    load status-line flag
                    beq       MenuInputHideStatus branch if no status line
                    lbsr      StatusLineWrite redraw the status line
                    lbra      MenuInputExit exit menu mode
MenuInputHideStatus ldd       #$0000    clear color (hide status)
                    lbsr      ClearTextLine clear the text line
                    lbra      MenuInputExit exit menu mode
MenuNavEvent        cmpa      #$02      check for joystick/nav event
                    lbne      MenuNavUpdate ignore non-nav events
                    lda       $01,x     load nav direction code
                    cmpa      #$01      check for up (direction 1)
                    bne       MenuNavDown branch if not up
                    ldx       $02,s     load current item pointer
                    lbsr      DrawMenuItemNormal draw current item normal
                    ldx       $02,s     reload current item
                    ldx       $02,x     follow prev-item pointer
                    stx       $02,s     update current item
                    lbsr      DrawMenuItemHighlight highlight new current item
                    lbra      MenuNavUpdate update menu state
MenuNavDown         cmpa      #$02      check for down (direction 2)
                    bne       MenuNavRight branch if not down
                    ldx       $02,s     load current item pointer
                    lbsr      DrawMenuItemNormal draw current item normal
                    ldu       ,s        load current menu pointer
                    ldx       $0B,u     load head of item list
                    stx       $02,s     wrap to head item
                    lbsr      DrawMenuItemHighlight highlight new current item
                    lbra      MenuNavUpdate update menu state
MenuNavRight        cmpa      #$03      check for right (direction 3)
                    bne       MenuNavLeft branch if not right
                    ldu       ,s        load current menu pointer
                    ldx       $02,s     load current item pointer
                    lbsr      EraseMenuItem erase current item dropdown
                    ldu       ,s        load current menu pointer
MenuNavRightScan    ldu       ,u        follow next-menu pointer
                    lda       $0A,u     check if menu has items
                    beq       MenuNavRightScan skip empty menus (scan right)
                    stu       ,s        save new current menu pointer
                    ldx       $0D,u     load tail item of new menu
                    stx       $02,s     set as current item
                    lbsr      DrawMenuItem draw new menu with dropdown
                    lbra      MenuNavUpdate update menu state
MenuNavLeft         cmpa      #$04      check for left (direction 4)
                    bne       MenuNavUp branch if not left
                    ldx       $02,s     load current item pointer
                    lbsr      DrawMenuItemNormal draw current item normal
                    ldu       ,s        load current menu pointer
                    ldx       $0B,u     load head of item list
                    ldx       $02,x     follow next-item pointer from head
                    stx       $02,s     set as current item
                    lbsr      DrawMenuItemHighlight highlight new current item
                    bra       MenuNavUpdate update menu state
MenuNavUp           cmpa      #$05      check for up (direction 5)
                    bne       MenuNavPrevLeft branch if not up
                    ldx       $02,s     load current item pointer
                    lbsr      DrawMenuItemNormal draw current item normal
                    ldx       $02,s     reload current item pointer
                    ldx       ,x        follow next-item pointer (wrap up)
                    stx       $02,s     update current item
                    lbsr      DrawMenuItemHighlight highlight new current item
                    bra       MenuNavUpdate update menu state
MenuNavPrevLeft     cmpa      #$06      check for prev-left (direction 6)
                    bne       MenuNavNextRight branch if not prev-left
                    ldu       ,s        load current menu pointer
                    ldx       $02,s     load current item pointer
                    lbsr      EraseMenuItem erase current dropdown
                    ldu       >MenuHead,pcr load menu-list head
                    ldu       $02,u     load next ptr from head (wrap left)
                    stu       ,s        set wrapped menu as current
                    ldx       $0D,u     load tail item of new menu
                    stx       $02,s     set tail as current item
                    lbsr      DrawMenuItem draw wrapped menu with dropdown
                    bra       MenuNavUpdate update menu state
MenuNavNextRight    cmpa      #$07      check for next-right (direction 7)
                    bne       MenuNavHome branch if not next-right
                    ldu       ,s        load current menu pointer
                    ldx       $02,s     load current item pointer
                    lbsr      EraseMenuItem erase current item dropdown
                    ldu       ,s        reload current menu pointer
MenuNavNextRightScan ldu       $02,u     follow next-menu pointer
                    lda       $0A,u     check if menu has items
                    beq       MenuNavNextRightScan skip empty menus (scan right)
                    stu       ,s        save new current menu pointer
                    ldx       $0D,u     load tail item of new menu
                    stx       $02,s     set as current item
                    lbsr      DrawMenuItem draw new menu with dropdown
                    bra       MenuNavUpdate update menu state
MenuNavHome         cmpa      #$08      check for home (8)
                    bne       MenuNavUpdate ignore if not home
                    ldu       ,s        load current menu pointer
                    ldx       $02,s     load current item pointer
                    lbsr      EraseMenuItem erase current item dropdown
                    ldu       >MenuHead,pcr load menu head
                    stu       ,s        set as new current menu
                    ldx       $0D,u     load tail of item list
                    stx       $02,s     set tail as current item
                    lbsr      DrawMenuItem draw home menu with dropdown
MenuNavUpdate       ldd       ,s        load current menu pointer
                    std       >MenuCurrent,pcr save as menu-current
                    ldd       $02,s     load current item pointer
                    std       >MenuItemCurrent,pcr save as item-current
                    lbra      MenuInputEventLoop wait for next event
MenuInputExit       lda       #$00      clear flags on exit
                    sta       >$0154    clear input-capture flag
                    sta       >$05AE    clear menu-input-active flag
                    sta       >$0547    clear event filter
                    leas      $04,s     release local frame
                    rts
DrawMenuItem        leas      -$04,s    allocate four local bytes
                    stu       ,s        save current menu entry ptr
                    ldx       ,s        reload as X for highlight call
                    bsr       DrawMenuItemHighlight highlight current menu title
                    ldu       ,s        reload menu entry pointer
                    lbsr      CalcMenuItemGeometry compute dropdown item positions
                    ldd       #$000F    white-on-black color
                    pshs      b,a       push color argument
                    ldd       >MenuItemRow,pcr load computed item row
                    pshs      b,a       push row argument
                    ldd       >MenuItemCol,pcr load computed item column
                    pshs      b,a       push column argument
                    lda       #$0C      MMU twiddle opcode $0C = open window
                    sta       <$0019    store twiddle code
                    ldx       <$0026    load window context pointer
                    jsr       >$0701    call Sierra window-open routine
                    leas      $06,s     discard three pushed arguments
                    ldu       ,s        reload menu entry pointer
                    ldx       $0B,u     load head of item list
DrawMenuItemLoop    stx       $02,s     save current item pointer
                    cmpx      $0D,u     check if this is the tail item
                    beq       DrawMenuItemCurrent branch if current = tail
                    bsr       DrawMenuItemNormal draw this item normally
                    bra       DrawMenuItemNext advance to next item
DrawMenuItemCurrent bsr       DrawMenuItemHighlight draw tail item highlighted
DrawMenuItemNext    ldx       $02,s     reload current item pointer
                    ldx       ,x        follow next-item pointer
                    ldu       ,s        reload menu entry pointer
                    cmpx      $0B,u     check if wrapped to head
                    bne       DrawMenuItemLoop loop until all items drawn
                    leas      $04,s     release local frame
                    rts
EraseMenuItem       stx       $0D,u     store X as tail of item list
                    tfr       u,x       transfer menu entry ptr to X
                    bsr       DrawMenuItemNormal draw menu title back to normal
                    ldd       >MenuItemRow,pcr load item dropdown row
                    pshs      b,a       push row argument
                    ldd       >MenuItemCol,pcr load item dropdown column
                    pshs      b,a       push column argument
                    lda       #$03      MMU twiddle opcode $03 = close window
                    sta       <$0019    store twiddle code
                    ldx       <$0026    load window context pointer
                    jsr       >$0701    call Sierra window-close routine
                    leas      $04,s     discard two arguments
                    rts
DrawMenuItemHighlight ldd       $08,x     load item screen position
                    std       <$0040    set cursor position
                    ldd       #$0F00    color = white fg, black bg
                    lbsr      text_color set highlighted text color
                    lda       $0A,x     load item enabled flag
                    bne       DrawMenuItemHiText branch if enabled
                    lda       #$0F      set dim-text attribute
                    sta       <$0045    apply dim attribute
DrawMenuItemHiText  pshs      x         save item pointer
                    ldd       $06,x     load logic page for item text
                    lbsr      SetLogicPage set MMU page for text access
                    puls      x         restore item pointer
                    ldd       $04,x     load pointer to item label text
                    pshs      b,a       push text pointer
                    lbsr      PrintFmtStrToScr print item label to screen
                    leas      $02,s     discard text pointer
                    clr       <$0045    clear dim-text attribute
                    rts
DrawMenuItemNormal  ldd       $08,x     load item screen position
                    std       <$0040    set cursor position
                    ldd       #$000F    color = normal (black fg, white bg)
                    lbsr      text_color set normal text color
                    lda       $0A,x     load item enabled flag
                    bne       DrawMenuItemNormText branch if enabled
                    lda       #$0F      set dim-text attribute
                    sta       <$0045    apply dim attribute
DrawMenuItemNormText pshs      x         save item pointer
                    ldd       $06,x     load logic page for item text
                    lbsr      SetLogicPage set MMU page for text access
                    puls      x         restore item pointer
                    ldd       $04,x     load pointer to item label text
                    pshs      b,a       push text pointer
                    lbsr      PrintFmtStrToScr print item label normally
                    leas      $02,s     discard text pointer
                    clr       <$0045    clear dim-text attribute
                    rts
CalcMenuItemGeometry leas      -$01,s    allocate one byte for item count
                    lda       $0F,u     load visible-items count from menu
                    sta       ,s        save item count
                    ldb       #$08      pixels per row = 8
                    mul                 A×8 = pixel row offset
                    addb      #$10      add $10 base offset
                    stb       >MenuItemRow,pcr store computed dropdown row
                    ldu       $0B,u     load head of item list
                    ldd       $06,u     load logic page for first item
                    lbsr      SetLogicPage set MMU page for text measure
                    ldx       $04,u     load label text pointer
                    lbsr      StrLen    measure label string length
                    lda       #$04      pixels per char = 4
                    mul                 compute text pixel width
                    addb      #$08      add 8-pixel margin
                    stb       >MenuItemWidth,pcr store dropdown pixel width
                    lda       $09,u     load column position from menu
                    deca                subtract one for base-0
                    ldb       #$04      pixels per column = 4
                    mul                 compute pixel column offset
                    stb       >MenuItemCol,pcr store dropdown pixel column
                    lda       ,s        load item count
                    adda      #$02      add 2 for top/bottom border
                    suba      >$0241    subtract scroll offset
                    ldb       #$08      pixels per row = 8
                    mul                 compute total height in pixels
                    addb      #$07      add 7-pixel bottom margin
                    stb       >MenuItemHeight,pcr store dropdown pixel height
                    leas      $01,s     release one-byte local frame
                    rts
JoySpeedTable       fcb       1,$ff
                    fcb       3,$ff
                    fcb       7,$ff
                    fcb       $f,$ff

*
*======================================================================
* STDIN READER
*   Reads a single byte from the stdin path, translating OS-9 keyboard
*   input into AGI key codes.
*======================================================================
*
ReadStdinByte       leas      -$03,s    allocate three local bytes
                    sty       ,s        save Y register
                    lda       #$00      path 0 = stdin
                    ldb       #$01      GetStt code 1 = check char avail
                    os9       I$GetStt  check if char is available
                    bcs       ReadStdinByteErr branch if error (no char)
                    lda       #$00      path 0 = stdin
                    ldy       #$0001    read 1 byte
                    leax      $02,s     point X to local read buffer
                    os9       I$Read    read one byte from stdin
                    bcs       ReadStdinByteErr branch if read failed
                    lda       $02,s     load the byte we just read
                    bra       ReadStdinByteRet return with character in A
                    cmpa      #$F4      (unreachable — dead code)
                    bne       ReadStdinByteRet branch if not $F4
                    lda       <$0068    load trace-mode flag
                    bne       ReadStdinByteAlt branch if trace mode on
                    lda       >$01AF    load misc-flags byte
                    ora       #$20      set trace-active bit
                    sta       >$01AF    store updated flags
                    lbsr      TraceInit initialize trace display
                    bra       ReadStdinByteErr return error
ReadStdinByteAlt    lda       >$01AF    load misc-flags byte
                    anda      #$DF      clear trace-active bit
                    sta       >$01AF    store updated flags
                    lbsr      TraceErase erase trace display
ReadStdinByteErr    clra                return zero = no char / error
ReadStdinByteRet    ldy       ,s        restore Y register
                    leas      $03,s     release local frame
                    rts
*
*======================================================================
* MEMORY FILL
*   Fills a byte range with a constant value; used to blank screen
*   buffers and clear data areas.
*======================================================================
*
FillMem             pshs      u         save U (start ptr returned to caller)
FillMemLoop         stb       ,u+       store fill byte, advance pointer
                    leax      -$01,x    decrement byte count
                    bne       FillMemLoop loop until count is zero
                    puls      u         restore U to start of filled area
                    rts
*
*======================================================================
* PICTURE DECODING AND RENDERING
*   Decodes the Sierra AGI picture format (nibble-packed commands) and
*   renders visual and priority data into the screen buffer via the shdw
*   module.
*======================================================================
*
PicRenderSetup      lda       $02,s     load picture file descriptor
                    sta       <$00B9    save file descriptor for reads
                    ldd       $06,s     load remaining byte count
                    std       <$00A2    store bytes remaining in stream
                    lbsr      MapShdwPage map shadow page into MMU
                    ldd       #$0009    initial bit depth / state = 9
                    std       <$00A4    initialize pic decode state
                    ldd       #$0102    initial base color pair
                    std       <$00A9    store base color
                    ldd       #$0200    initial max color range
                    std       <$00B1    store max range
                    ldd       #$0000    clear to zero
                    std       <$00A6    clear current color accumulator
                    std       <$00B4    clear saved color accumulator
                    std       <$00AB    clear run color tracker
                    std       <$00BA    clear pixel bit position
                    stb       <$00B6    clear run count
                    stb       <$00A8    clear color byte A
                    stb       <$00AD    clear color byte D
                    lbsr      ReadPicChunk read first chunk from volume
                    tst       <$009F    check for stream end
                    lbne      PicRenderDone branch if no more data
                    ldx       $04,s     load output pixel buffer pointer
PicDecodeLoop       lbsr      ReadPicPixel read next encoded pixel value
                    tst       <$009F    check for stream end
                    lbne      PicRenderDone branch if stream ended
                    cmpd      #$0101    check for picture end-code
                    lbeq      PicRenderDone branch if end-of-picture
                    cmpd      #$0100    check for color-reset code
                    bne       PicDataProcess branch if normal pixel data
                    ldd       #$0009    reset bit depth to 9
                    std       <$00A4    reset decode state
                    ldd       #$0102    reset base color pair
                    std       <$00A9    reset base color
                    ldd       #$0200    reset max range
                    std       <$00B1    reset color range
                    lbsr      ReadPicPixel read reset color value
                    tst       <$009F    check for stream end
                    lbne      PicRenderDone branch if stream ended
                    std       <$00A6    store as new current color
                    std       <$00B4    store as saved color
                    stb       <$00AD    store color low byte D
                    stb       <$00A8    store color byte A
                    stb       ,x+       write color to output buffer
                    bra       PicDecodeLoop continue decoding
PicDataProcess      std       <$00A6    store current pixel data
                    std       <$00AB    save as run-color tracker
                    cmpd      <$00A9    compare to base color
                    bcs       PicDataCheck branch if below base
                    ldb       <$00A8    load color byte
                    pshs      b         save color byte
                    inc       <$00B6    increment run count
                    ldd       <$00B4    load saved color
                    std       <$00A6    restore as current color
PicDataCheck        cmpd      #$0100    check if color code >= $0100
                    bcs       PicColorStore branch if simple color (< $0100)
                    addd      <$00A6    add current to D
                    addd      <$00A6    add again (×3 for table index)
                    ldu       #$6400    point to color-decode table base
                    leau      d,u       index into table
                    ldb       $02,u     load color byte from table
                    pshs      b         push color byte
                    inc       <$00B6    increment run count
                    ldd       ,u        load color entry word
                    std       <$00A6    store as new current color
                    bra       PicDataCheck check again (multi-step decode)
PicColorStore       stb       <$00A8    store final color byte A
                    stb       <$00AD    store final color byte D
                    pshs      b         push final color byte
                    lda       <$00B6    load accumulated run count
                    inca                add one for current pixel
PicWriteLoop        puls      b         pop color byte from stack
                    stb       ,x+       write pixel to output buffer
                    deca                decrement write count
                    bne       PicWriteLoop loop until all pixels written
                    sta       <$00B6    reset run count to zero
                    ldd       <$00A9    load current base color
                    addd      <$00A9    multiply by 3 for table index
                    addd      <$00A9    (×3 total)
                    ldu       #$6400    point to color table base
                    leau      d,u       index to this color's entry
                    ldb       <$00AD    load current color byte D
                    stb       $02,u     store back in table
                    ldd       <$00B4    load saved color pair
                    std       ,u        store back in table
                    ldd       <$00A9    load base color index
                    addd      #$0001    advance to next color index
                    std       <$00A9    store new base color
                    ldu       <$00AB    load run-color tracker
                    stu       <$00B4    save as next saved color
                    cmpd      <$00B1    compare index to max range
                    lbcs      PicDecodeLoop loop if under max
                    ldb       <$00A5    load bit-shift count
                    cmpb      #$0B      check if at max shift (11)
                    lbeq      PicDecodeLoop loop if at max (no expand)
                    incb                increment bit depth
                    stb       <$00A5    store new bit depth
                    lsl       <$00B1    double the max range
                    lbra      PicDecodeLoop continue decoding
PicRenderDone       tfr       x,d       transfer output ptr to D
                    subd      $04,s     subtract start ptr to get count
                    rts
RenderPicStrip      lda       $02,s     load picture file descriptor
                    sta       <$00B9    save descriptor for reads
                    ldd       $06,s     load remaining byte count
                    std       <$00A2    store bytes remaining
                    bsr       MapShdwPage map shadow graphics page
                    clrb                clear B = 0
                    stb       <$00BC    clear high-nibble flag
                    stb       <$00B3    clear nibble-pair state
                    lbsr      ReadPicChunk read first chunk from file
                    tst       <$009F    check for stream end
                    bne       PicStripDone branch if no data
                    ldu       #$6000    start of graphics buffer
                    ldx       $04,s     load output pixel buffer ptr
PicBufCheck         cmpu      #$63FE    check if buffer nearly full
                    bcs       PicReadByte branch if buffer has room
                    stx       <$00B7    save output pointer
                    tfr       u,d       transfer buffer ptr to D
                    subd      #$6000    compute buffer offset
                    lbsr      PicBufReadWord refill buffer from file
                    tst       <$009F    check for stream end
                    bne       PicStripDone branch if done
                    ldu       #$6000    reset buffer pointer to start
                    ldx       <$00B7    restore output pointer
PicReadByte         ldb       ,u        load next byte from decode buffer
                    lda       <$00BC    load high-nibble pending flag
                    beq       PicNibbleHi branch if expecting high nibble
                    lda       <$00B3    load nibble-pair state
                    anda      #$01      check low bit of state
                    beq       PicNibbleLo branch if low nibble needed
                    andb      #$0F      extract low nibble
                    bra       PicNibbleAdv advance buffer
PicNibbleLo         lsrb                shift right to get high nibble
                    lsrb                shift right (bit 2)
                    lsrb                shift right (bit 3)
                    lsrb                high nibble now in low nibble position
PicNibbleAdv        leau      a,u       advance U by nibble-state
                    eora      #$01      toggle nibble-pair state
                    sta       <$00B3    store updated state
                    clr       <$00BC    clear high-nibble flag
                    bra       PicStorePixel store the pixel
PicNibbleHi         leau      $01,u     advance to next buffer byte
                    lda       <$00B3    load nibble-pair state
                    anda      #$01      check low bit of state
                    beq       PicNibbleSet branch if low state
                    lda       ,u        load adjacent byte for shift
                    lsla                shift left for merge
                    rolb                rotate into B
                    lsla                shift left (bit 2)
                    rolb                rotate bit into B
                    lsla                shift left (bit 3)
                    rolb                rotate bit into B
                    lsla                shift left (bit 4)
                    rolb                B now has merged nibbles
PicNibbleSet        lda       #$01      set high-nibble pending flag
                    sta       <$00BC    store flag
                    cmpb      #$F0      check for transparent code
                    beq       PicStorePixel branch to store if transparent
                    cmpb      #$F2      check for second transparent
                    beq       PicStorePixel branch to store
                    clr       <$00BC    clear pending flag for normal pixel
PicStorePixel       stb       ,x+       store pixel byte to output buffer
                    cmpb      #$FF      check for end-of-strip sentinel
                    bne       PicBufCheck loop if not at end
PicStripDone        tfr       x,d       transfer output ptr to D
                    subd      $04,s     compute bytes written
                    rts
MapShdwPage         orcc      #$50      disable interrupts for MMU access
                    lda       >$FFA9    read current MMU slot 9
                    ldb       <$0042    load shadow page number
                    stb       >$FFA9    map shadow page to slot 9
                    ldx       <$0043    load MMU control ptr
                    ldb       <$005F    load base priority page
                    addb      #$08      advance 8 pages into shadow
                    stb       $04,x     update MMU slot 4
                    stb       >$FFAB    write to MMU hardware
                    sta       >$FFA9    restore original slot 9
                    andcc     #$AF      re-enable interrupts
                    rts
ReadPicPixel        stx       <$00B7    save X across buffer reads
                    ldd       <$00BA    load current bit position
                    cmpd      #$1FF0    check if near buffer end
                    bcs       ReadPicPixelInner branch if enough bits remain
                    lsra                shift right for buffer offset
                    rorb                rotate into B (div by 2)
                    lsra                shift right again (div by 4)
                    rorb                rotate into B
                    lsra                shift right (div by 8 = byte offset)
                    rorb                D = byte offset in decode buffer
                    bsr       PicBufReadWord refill buffer, advance stream
                    tst       <$009F    check for stream end
                    bne       PicPixelRet branch if done
                    clra                clear A
                    ldb       <$00BB    load low 3 bits of position
                    andb      #$07      mask off upper bits
                    std       <$00BA    store new bit position
ReadPicPixelInner   ldu       <$00A4    load decode state (color index offset)
                    leau      d,u       advance by bit position
                    lsra                convert bit pos to byte offset (/2)
                    rorb                rotate into B
                    lsra                shift right (/4)
                    rorb                rotate into B
                    lsra                shift right (/8 = byte index)
                    rorb                D = byte offset in decode buffer
                    ldx       #$6000    base of decode buffer
                    leax      d,x       index to position
                    lda       $01,x     load second byte at position
                    ldb       ,x        load first byte at position
                    std       <$00AE    store pixel word
                    ldb       $02,x     load third byte
                    stb       <$00B0    store third byte
                    ldb       <$00BB    load bit sub-position
                    stu       <$00BA    store bit position (from U)
                    andb      #$07      mask to 0-7
                    beq       PicPixelMask branch if no shift needed
PicShiftLoop        lsr       <$00B0    right-shift the three-byte window
                    ror       <$00AE    rotate through middle byte
                    ror       <$00AF    rotate into low byte
                    decb                decrement shift count
                    bne       PicShiftLoop loop until aligned
PicPixelMask        ldb       <$00A5    load current bit-depth
                    subb      #$09      subtract base depth (9)
                    lslb                multiply by 2 for table index
                    leax      >JoySpeedTable,pcr point to bit-mask table
                    abx                 index to entry for this depth
                    ldd       <$00AE    load extracted pixel word
                    anda      ,x        mask high byte with table
                    andb      $01,x     mask low byte with table
PicPixelRet         ldx       <$00B7    restore X
                    rts
PicBufReadWord      ldu       #$6000    base of decode buffer
                    ldu       d,u       load word at offset D
                    stu       >$6000    store at buffer start
                    subd      #$0400    subtract buffer size
                    negb                negate low byte for read count
                    lbsr      ReadPicChunk read more data into buffer
                    rts
ReadPicChunk        ldx       #$6000    compute read address in decode buffer
                    abx                 add offset B to base
                    negb                negate B = bytes needed to fill
                    sex                 sign-extend B to D (word count)
                    addd      #$0400    add buffer size for total available
                    std       <$00A0    store computed read-count
                    ldd       <$00A2    load remaining bytes in stream
                    beq       ReadPicChunkRet branch if no more data
                    cmpd      <$00A0    compare remaining to read-count
                    bcs       ReadPicChunkFull branch if not enough data left
                    subd      <$00A0    subtract read count from remaining
                    std       <$00A2    update remaining byte count
                    ldd       <$00A0    reload actual bytes to read
                    bra       ReadPicChunkRead proceed to read
ReadPicChunkFull    ldu       #$0000    zero value
                    stu       <$00A2    mark stream as exhausted
ReadPicChunkRead    tfr       d,y       transfer byte count to Y
                    lda       <$00B9    load file descriptor
                    lbsr      ReadFile  read D bytes from file into X
ReadPicChunkRet     rts
gfx_picbuff_update  tst       >$0550    check if gfx-update-needed flag set
                    beq       GfxUpdateBlit branch if no shadow update needed
                    lda       #$00      MMU twiddle opcode $00 = shadow copy
                    sta       <$0021    store twiddle opcode
                    ldx       <$0028    load shadow copy context ptr
                    jsr       >$0701    execute shadow-page copy
*
*======================================================================
* SCREEN BLIT
*   Triggers a full-screen blit from the shadow buffer to the display by
*   calling the scrn module's update routine.
*======================================================================
*
GfxUpdateBlit       ldd       #$A8A0    blit destination row/col
                    pshs      b,a       push destination argument
                    ldd       #$00A7    blit source descriptor
                    pshs      b,a       push source argument
                    lda       #$00      MMU twiddle opcode $00 = blit
                    sta       <$0019    store twiddle opcode
                    ldx       <$0026    load blit context pointer
                    jsr       >$0701    execute screen blit
                    leas      $04,s     discard two arguments
                    rts
*
*======================================================================
* OBJECT MOTION COMMANDS
*   Implements move_obj, move_obj_v, follow_ego, wander, normal_motion,
*   stop_motion, start_motion, step_size, step_time, set_dir, get_dir,
*   program_control, and player_control.
*======================================================================
*
cmd_move_obj        lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43 bytes
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    lda       #$03      motion type = move-to-position
                    sta       <$22,u    set object motion type
                    lda       ,y+       load target X position
                    sta       <$27,u    store target X
                    lda       ,y+       load target Y position
                    sta       <$28,u    store target Y
                    lda       <$1E,u    load current step size
                    sta       <$29,u    save step size as move speed
                    lda       ,y+       load optional step-size override
                    beq       MoveObjDir branch if zero (no override)
                    sta       <$1E,u    store new step size
MoveObjDir          lda       ,y+       load completion-flag variable
                    sta       <$2A,u    store flag variable index
                    lbsr      ClearFlag clear the completion flag
                    lda       <$26,u    load object control flags
                    ora       #$10      set position-update-needed bit
                    sta       <$26,u    store updated flags
                    cmpu      <$0030    check if this is ego object
                    bne       MoveObjDone branch if not ego
                    clr       >$0250    hide ego during move
MoveObjDone         lbsr      SetObjMotion recalculate initial direction
                    rts
cmd_move_obj_v      lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    lda       #$03      motion type = move-to-position
                    sta       <$22,u    set object motion type
                    ldb       ,y+       load X-variable number
                    ldx       #$0431    point to variable table
                    abx                 index to X-variable
                    lda       ,x        load target X from variable
                    sta       <$27,u    store target X
                    ldb       ,y+       load Y-variable number
                    ldx       #$0431    point to variable table
                    abx                 index to Y-variable
                    lda       ,x        load target Y from variable
                    sta       <$28,u    store target Y
                    lda       <$1E,u    load current step size
                    sta       <$29,u    save as move speed
                    ldb       ,y+       load step-size variable number
                    ldx       #$0431    point to variable table
                    abx                 index to step-size variable
                    lda       ,x        load step size from variable
                    beq       MoveObjVDir branch if zero (no override)
                    sta       <$1E,u    store new step size
MoveObjVDir         lda       ,y+       load completion-flag variable index
                    sta       <$2A,u    store flag variable index
                    lbsr      ClearFlag clear the completion flag
                    lda       <$26,u    load object control flags
                    ora       #$10      set position-update-needed bit
                    sta       <$26,u    store updated flags
                    cmpu      <$0030    check if this is ego object
                    bne       MoveObjVDone branch if not ego
                    clr       >$0250    hide ego during move
MoveObjVDone        lbsr      SetObjMotion recalculate initial direction
                    rts
cmd_follow_ego      lda       ,y+       load follower object number
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to follower object
                    lda       #$02      motion type = follow-ego
                    sta       <$22,u    set object motion type
                    lda       <$1E,u    load current step size
                    sta       <$27,u    store as follow step (default)
                    lda       ,y+       load optional step-size override
                    cmpa      <$1E,u    compare to current step
                    bls       FollowEgoSpeed branch if not larger
                    sta       <$27,u    use larger value as step size
FollowEgoSpeed      lda       ,y+       load completion-flag variable index
                    sta       <$28,u    store flag variable index
                    lbsr      ClearFlag clear the completion flag
                    lda       #$FF      distance = $FF (always follow)
                    sta       <$29,u    store initial distance marker
                    lda       <$26,u    load object control flags
                    ora       #$10      set position-update-needed bit
                    sta       <$26,u    store updated flags
                    rts
cmd_wander          lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    lda       #$01      motion type = wander
                    sta       <$22,u    set wander motion type
                    lda       <$26,u    load object control flags
                    ora       #$10      set position-update-needed bit
                    sta       <$26,u    store updated flags
                    cmpu      <$0030    check if this is ego
                    bne       WanderDone branch if not ego
                    clr       >$0250    hide ego while wandering
WanderDone          rts
cmd_normal_motion   lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    lda       #$00      motion type = normal (user-controlled)
                    sta       <$22,u    clear motion type
                    rts
cmd_stop_motion     lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    lda       #$00      motion type = stopped
                    sta       <$22,u    clear motion type
                    clra                zero direction
                    sta       <$21,u    stop object movement direction
                    cmpu      <$0030    check if this is ego
                    bne       StopMotionDone branch if not ego
                    sta       >$0437    clear ego-direction variable
                    sta       >$0250    hide ego (stopped)
StopMotionDone      rts
cmd_start_motion    lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    lda       #$00      motion type = normal
                    sta       <$22,u    clear motion type
                    cmpu      <$0030    check if this is ego
                    bne       StartMotionDone branch if not ego
                    clr       >$0437    clear ego-direction variable
                    lda       #$01      show flag = visible
                    sta       >$0250    make ego visible again
StartMotionDone     rts

cmd_step_size_v     lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    ldb       ,y+       load step-size variable number
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       ,x        load step size from variable
                    sta       <$1E,u    store as object step size
                    rts

cmd_step_time       lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    ldb       ,y+       load step-time variable number
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       ,x        load step time from variable
                    sta       ,u        store as step-time counter
                    sta       $01,u     store as step-time reset value
                    rts

cmd_set_dir         lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    ldb       ,y+       load direction-variable number
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       ,x        load direction from variable
                    sta       <$21,u    store as object motion direction
                    rts

cmd_get_dir         lda       ,y+       load object number from script
                    ldb       #$2B      view-object struct size = 43
                    mul                 compute object offset
                    addd      <$0030    add view-object array base
                    tfr       d,u       point U to object struct
                    ldb       ,y+       load output-variable number
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       <$21,u    load current object direction
                    sta       ,x        store direction in variable
                    rts

cmd_program_control clr       >$0250    hide ego (program controls ego)
                    rts

cmd_player_control  lda       #$01      show ego (player controls ego)
                    sta       >$0250    make ego visible again
                    ldu       <$0030    load ego object pointer
                    lda       #$00      motion type = normal
                    sta       <$22,u    clear ego motion type
                    rts
x_dir_mult          fcb       0,0
                    fcb       1,1
                    fcb       1,0
                    fcb       $ff,$ff
                    fcb       $ff
y_dir_mult          fcb       0
                    fcb       $ff,$ff
                    fcb       0,1
                    fcb       1,1
                    fcb       0,$ff

*
*======================================================================
* PER-OBJECT MOVEMENT UPDATE
*   Each cycle: moves all active objects one step in their current
*   direction, applies step-size, clamps to screen bounds, checks
*   horizon and border hits, and updates the direction variable.
*======================================================================
*
UpdateAllMotion     leas      -$0B,s    allocate 11-byte per-object frame
                    clra                clear A = 0
                    sta       >$0433    clear ego-boundary hit flag
                    sta       >$0435    clear object-boundary flag
                    sta       >$0436    clear object-boundary-dir flag
                    ldu       <$0030    load view-object array pointer
UpdateObjsLoop      cmpu      <$0032    check if past end of object array
                    lbcc      UpdateAllObjsRet branch when all objects done
                    lda       <$26,u    load object control flags
                    anda      #$51      mask: animated+visible+update bits
                    cmpa      #$51      check if all three bits set
                    lbne      UpdateObjsNext skip if not fully active
                    lda       $01,u     load step-time counter
                    beq       UpdateObjCycle branch if counter expired
                    deca                decrement counter
                    beq       UpdateObjCycle branch if just reached zero
                    sta       $01,u     store decremented counter
                    lbra      UpdateObjsNext not time yet, skip to next
UpdateObjCycle      lda       ,u        load step-time reset value
                    sta       $01,u     reload counter from reset value
                    clra                clear boundary-hit code
                    sta       $02,s     clear local boundary-hit slot
                    ldb       <$1E,u    load object step size
                    std       $09,s     save step size (clear A, set B)
                    ldb       $03,u     load current X position (byte)
                    std       $03,s     save X in local frame (clr A, B=X)
                    stb       $07,s     save X low byte separately
                    ldb       $04,u     load current Y position
                    std       $05,s     save Y in local frame (clr A, B=Y)
                    stb       $08,s     save Y low byte separately
                    lda       <$25,u    load object status flags
                    bita      #$04      check "ignore-blocks" flag
                    bne       ClampObjXLeft branch if ignoring blocks
                    leax      >x_dir_mult,pcr point to X-direction table
                    lda       <$21,u    load current motion direction
                    lda       a,x       look up X delta for direction
                    beq       UpdateObjY branch if X delta is zero
                    bpl       UpdateObjXPlus branch if positive X delta
                    ldd       $03,s     load current X (16-bit)
                    subd      $09,s     subtract step size
                    std       $03,s     store new X
                    bra       UpdateObjY update Y too
UpdateObjXPlus      ldd       $03,s     load current X
                    addd      $09,s     add step size
                    std       $03,s     store new X
UpdateObjY          leax      >y_dir_mult,pcr point to Y-direction table
                    lda       <$21,u    load current motion direction
                    lda       a,x       look up Y delta for direction
                    beq       ClampObjXLeft branch if Y delta is zero
                    bpl       UpdateObjYPlus branch if positive Y delta
                    ldd       $05,s     load current Y (16-bit)
                    subd      $09,s     subtract step size
                    std       $05,s     store new Y
                    bra       ClampObjXLeft clamp to screen bounds
UpdateObjYPlus      ldd       $05,s     load current Y
                    addd      $09,s     add step size
                    std       $05,s     store new Y
ClampObjXLeft       ldd       #$0000    left boundary = X < 0
                    cmpd      $03,s     compare new X to 0
                    ble       ClampObjXRight branch if X >= 0 (no left clamp)
                    std       $03,s     clamp X to 0
                    lda       #$04      boundary code = left
                    sta       $02,s     set left-boundary hit
                    bra       ClampObjYTop check Y bounds
ClampObjXRight      ldb       <$1C,u    load object width
                    negb                negate width
                    lda       #$FF      sign-extend to 16-bit
                    addd      #$00A0    right limit = $A0 - width
                    cmpd      $03,s     compare new X to limit
                    bge       ClampObjYTop branch if X <= limit
                    std       $03,s     clamp X to right limit
                    lda       #$02      boundary code = right
                    sta       $02,s     set right-boundary hit
ClampObjYTop        clra                clear A for 16-bit Y check
                    ldb       <$1D,u    load object height
                    decb                height - 1
                    cmpd      $05,s     compare new Y to top limit
                    ble       ClampObjYBot branch if Y >= top
                    std       $05,s     clamp Y to top
                    lda       #$01      boundary code = top
                    sta       $02,s     set top-boundary hit
                    bra       ApplyObjPosition apply position
ClampObjYBot        ldd       #$00A7    bottom boundary = Y > $A7
                    cmpd      $05,s     compare new Y to bottom
                    bge       CheckObjPriority branch if Y <= $A7
                    std       $05,s     clamp Y to bottom
                    lda       #$03      boundary code = bottom
                    sta       $02,s     set bottom-boundary hit
                    bra       ApplyObjPosition apply position
CheckObjPriority    lda       <$26,u    load object control flags
                    bita      #$08      check fixed-priority flag
                    bne       ApplyObjPosition skip if priority is fixed
                    lda       >$01D6    load priority-override value
                    cmpa      $06,s     compare to saved priority
                    bls       ApplyObjPosition branch if no change needed
                    inca                increment priority
                    sta       $06,s     store new priority
                    lda       #$01      set boundary-hit code
                    sta       $02,s     store boundary code
ApplyObjPosition    lda       $04,s     load X high byte
                    ldb       $06,s     load priority/Y
                    std       $03,u     store new position in object
                    lbsr      CheckObjCollision check for collision with others
                    tsta                test collision result
                    bne       ObjHitRestore branch if collision detected
                    stu       ,s        save U for MMU call
                    pshs      u         push U for restoration
                    lda       #$03      MMU twiddle opcode $03 = update
                    sta       <$0021    store twiddle code
                    ldx       <$0028    load update context pointer
                    jsr       >$0701    call Sierra update-position routine
                    leas      $02,s     discard pushed U
                    ldu       ,s        restore object pointer
                    lda       <$005C    load position-accept flag
                    bne       CheckObjBoundary branch if position accepted
ObjHitRestore       ldd       $07,s     load saved original X+Y
                    std       $03,u     restore original position
                    clr       $02,s     clear boundary-hit code
                    lbsr      FindObjPos reposition object safely
CheckObjBoundary    lda       $02,s     load boundary-hit code
                    beq       UpdateObjFlags branch if no boundary hit
                    ldb       $02,u     load object number
                    bne       ObjBoundaryHit branch if not ego
                    sta       >$0433    store ego boundary direction
                    bra       CheckMoveTarget check if move-target reached
ObjBoundaryHit      stb       >$0435    store object number that hit
                    sta       >$0436    store boundary direction
CheckMoveTarget     lda       <$22,u    load motion type
                    cmpa      #$03      check for move-to-position
                    bne       UpdateObjFlags skip if not move-to
                    lbsr      ObjMoveReached check if target position reached
UpdateObjFlags      lda       <$25,u    load status flags
                    anda      #$FB      clear collision-flags bit
                    sta       <$25,u    store cleaned status
UpdateObjsNext      leau      <$2B,u    advance to next object struct
                    lbra      UpdateObjsLoop loop for all objects
UpdateAllObjsRet    leas      $0B,s     release local frame
                    rts
MoveTableData       fcb       8,1,2,7,0,3,6,5,4
*
*======================================================================
* OBJECT MOTION HELPERS
*   SetObjMotion recalculates an object's direction toward its target;
*   ObjMoveReached checks arrival; CalcMoveDir and CalcAxisDir compute
*   the 8-way direction from delta X/Y.
*======================================================================
*
SetObjMotion        ldb       $1e,u     load object step size
                    pshs      b,a       push step size argument
                    ldd       <$27,u    load move target X and Y
                    pshs      b,a       push target position
                    ldd       $03,u     load current position X and Y
                    pshs      b,a       push current position
                    lbsr      CalcMoveDir compute direction toward target
                    leas      $06,s     discard three arguments
                    cmpu      <$0030    check if this is ego object
                    bne       SetObjMotionStore branch if not ego
                    sta       >$0437    update ego direction variable
SetObjMotionStore   sta       <$21,u    store computed direction in object
                    bne       SetObjMotionRet branch if direction is non-zero
                    bsr       ObjMoveReached target reached, signal completion
SetObjMotionRet     rts
ObjMoveReached      lda       <$29,u    load saved step size (from move setup)
                    sta       <$1E,u    restore step size to object
                    lda       <$2A,u    load completion-flag variable index
                    lbsr      SetFlag   set the completion flag
                    lda       #$00      motion type = stopped
                    sta       <$22,u    clear motion type
                    cmpu      <$0030    check if this is ego
                    bne       ObjMoveReachedRet branch if not ego
                    lda       #$01      visible flag = true
                    sta       >$0250    show ego again
                    clr       >$0437    clear ego direction variable
ObjMoveReachedRet   rts
CalcMoveDir         leas      -$03,s    allocate three local bytes
                    clra                clear A = 0
                    sta       $09,s     clear computed direction slot
                    ldb       $05,s     load target Y from args
                    std       ,s        save target Y
                    ldb       $07,s     load current Y from args
                    subd      ,s        compute Y delta (cur - target)
                    pshs      b,a       push Y delta
                    ldd       $0B,s     load step size
                    pshs      b,a       push step size
                    lbsr      CalcAxisDir compute Y-axis direction (0=same,1=pos,2=neg)
                    leas      $04,s     discard two arguments
                    sta       $02,s     save Y-axis direction (row index)
                    clra                clear A for X calc
                    sta       $05,s     clear X-comparison slot
                    ldb       $08,s     load current X from args
                    subd      $05,s     compute X delta
                    pshs      b,a       push X delta
                    ldd       $0B,s     load step size
                    pshs      b,a       push step size
                    lbsr      CalcAxisDir compute X-axis direction
                    leas      $04,s     discard two arguments
                    leax      >MoveTableData,pcr point to direction lookup table
                    ldb       #$03      table stride = 3 (per Y-dir group)
                    mul                 A × 3 = row offset
                    addb      $02,s     add X-axis direction index
                    lda       b,x       load final direction from table
                    leas      $03,s     release local frame
                    rts
CalcAxisDir         ldd       #$0000    compute negative of arg: -delta
                    subd      $02,s     subtract arg gives -arg in D
                    cmpd      $04,s     compare -delta to step size
                    blt       CalcAxisDirNeg branch if within negative range
                    clra                direction = 0 (at target)
                    bra       CalcAxisDirRet return zero direction
CalcAxisDirNeg      ldd       $02,s     load delta again
                    cmpd      $04,s     compare delta to step size
                    bgt       CalcAxisDirPos branch if positive delta
                    lda       #$02      direction = 2 (negative)
                    bra       CalcAxisDirRet return negative direction
CalcAxisDirPos      lda       #$01      direction = 1 (positive)
CalcAxisDirRet      rts
*
*======================================================================
* NEW ROOM COMMAND
*   Implements new_room and new_room_v: unloads the current room's
*   non-common logics and views, resets per-room object state, sets ego
*   position at the entry border, and triggers room logic 0.
*======================================================================
*
cmd_new_room        lda       ,y        load room number from script
                    bsr       NewRoomSetup set up the new room
                    rts
cmd_new_room_v      ldb       ,y        load variable number from script
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       ,x        load room number from variable
                    bsr       NewRoomSetup set up the new room
                    rts
NewRoomSetup        leas      -$01,s    allocate one byte for room num
                    sta       ,s        save new room number
                    lbsr      ResetHeap reset heap to baseline
                    lbsr      events_clear clear all pending events
                    lbsr      InitScriptBuf initialize script buffer
                    lda       #$01      room-change-in-progress flag
                    sta       >$05B1    set new-room flag
                    ldu       <$0030    load view-object array pointer
NewRoomObjLoop      cmpu      <$0032    check if past end of array
                    bcc       NewRoomObjsDone branch when all objects done
                    lda       <$26,u    load object control flags
                    anda      #$BE      clear animated + cycling bits
                    ora       #$10      set position-update bit
                    sta       <$26,u    store updated flags
                    ldd       #$0000    zero value
                    sta       <$25,u    clear object status flags
                    std       <$10,u    clear loop/cel fields
                    std       $06,u     clear priority/position hi
                    std       <$16,u    clear block/range fields
                    inca                value = 1
                    sta       <$1E,u    set step size = 1
                    sta       <$1F,u    set step counter = 1
                    sta       <$20,u    set cycle time = 1
                    sta       $01,u     set cycle counter = 1
                    sta       ,u        set step-time reset = 1
                    leau      <$2B,u    advance to next object struct
                    bra       NewRoomObjLoop continue for all objects
NewRoomObjsDone     lbsr      ResetGameTables reset all game tables
                    clra                zero value
                    sta       >$01AC    clear sound-playing flag
                    sta       >$0435    clear object-boundary flag
                    sta       >$0436    clear object-boundary-dir flag
                    inca                value = 1
                    sta       >$0250    show ego
                    lda       #$24      default priority base = 36
                    sta       >$01D6    set priority-override
                    lda       >$0431    load previous room number
                    sta       >$0432    save as last-room variable
                    ldb       ,s        load new room number
                    stb       >$0431    store as current-room variable
                    lbsr      LoadLogicNum load the new room's logic
                    ldb       <$006A    load init-logic flag
                    beq       NewRoomLoadView branch if no init logic
                    lbsr      AllocLoadLogic load and exec init logic
NewRoomLoadView     ldu       <$0030    load ego object pointer
                    lda       $05,u     load ego's loop number
                    sta       >$0441    store for view setup
                    lda       >$0433    load ego entry-side (from boundary)
                    beq       NewRoomFlagSetup branch if entry side = 0 (top)
                    cmpa      #$01      check entry from top
                    bne       NewRoomEgoDir2 branch if not from top
                    lda       #$A7      bottom of screen = $A7
                    sta       $04,u     place ego at bottom
                    bra       NewRoomEgoDirDone done positioning
NewRoomEgoDir2      cmpa      #$02      check entry from right
                    bne       NewRoomEgoDir3 branch if not from right
                    lda       #$00      left edge = 0
                    sta       $03,u     place ego at left
                    bra       NewRoomEgoDirDone done positioning
NewRoomEgoDir3      cmpa      #$03      check entry from bottom
                    bne       NewRoomEgoDir4 branch if not from bottom
                    lda       #$25      top of walking area
                    sta       $04,u     place ego near top
                    bra       NewRoomEgoDirDone done positioning
NewRoomEgoDir4      cmpa      #$04      check entry from left
                    bne       NewRoomEgoDirDone branch if unknown direction
                    lda       #$A0      right edge = $A0
                    suba      <$1C,u    subtract ego width
                    sta       $03,u     place ego at right edge
NewRoomEgoDirDone   clr       >$0433    clear boundary direction variable
NewRoomFlagSetup    lda       >$01AE    load initialized-flag byte
                    ora       #$04      set room-initialized bit
                    sta       >$01AE    store updated flags
                    lbsr      ClearInputBuffer clear keyboard input buffer
                    lbsr      StatusLineWrite redraw the status line
                    lbsr      InputRedraw redraw the input line
                    ldy       #$0000    Y = 0 = no further exec
                    leas      $01,s     release one-byte local frame
                    rts
*
*======================================================================
* INVENTORY / OBJECT POSSESSION
*   Implements get, get_v, drop, put, put_v, and get_room_v: sets the
*   room field of an object struct to move it to/from the player's
*   inventory.
*======================================================================
*
cmd_get             bsr       GetObjPtr get pointer to object struct
                    lda       #$FF      room = $FF = carried by player
                    sta       $02,u     set object room to $FF (in inventory)
                    rts
cmd_get_v           bsr       GetObjPtrV get pointer via variable number
                    lda       #$FF      room = $FF = carried
                    sta       $02,u     set object room to $FF
                    rts
cmd_drop            bsr       GetObjPtr get pointer to object struct
                    lda       #$00      room = 0 = dropped (not carried)
                    sta       $02,u     clear object room (drop)
                    rts
GetObjPtr           ldx       <$0038    load object-data base pointer
                    ldb       ,y+       load object number from script
                    abx                 index × 1 into table (offset)
                    abx                 index × 2
                    abx                 index × 3 (3 bytes per ptr)
                    tfr       x,u       transfer calculated ptr to U
                    cmpu      <$003C    check if within valid range
                    bcs       GetObjPtrRet branch if valid
                    lda       #$17      error code $17 = bad object
                    ldb       -$01,y    load object number for message
                    lbsr      ReportError report the error
GetObjPtrRet        rts
GetObjPtrV          ldb       ,y+       load variable number from script
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    ldb       ,x        load object number from variable
                    ldx       <$0038    load object-data base pointer
                    abx                 index × 1
                    abx                 index × 2
                    abx                 index × 3 (3 bytes per ptr)
                    tfr       x,u       transfer calculated ptr to U
                    cmpu      <$003C    check if within valid range
                    bcs       GetObjPtrVRet branch if valid
                    lda       #$17      error code $17 = bad object
                    ldb       -$01,y    load object number for message
                    lbsr      ReportError report the error
GetObjPtrVRet       rts
cmd_put             bsr       GetObjPtr get pointer to object struct
                    ldb       ,y+       load room-variable number from script
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       ,x        load destination room from variable
                    sta       $02,u     store room number in object
                    rts
cmd_put_v           bsr       GetObjPtrV get pointer via variable number
                    ldb       ,y+       load room-variable number
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       ,x        load destination room from variable
                    sta       $02,u     store room number in object
                    rts
cmd_get_room_v      bsr       GetObjPtrV get pointer via variable number
                    ldb       ,y+       load destination-variable number
                    ldx       #$0431    point to variable table
                    abx                 index to variable
                    lda       $02,u     load object's current room
                    sta       ,x        store room number in variable
                    rts
PriBaseFlag         fcb       1
*
*======================================================================
* DRAW LIST AND VIEW OBJECT SCAN
*   Maintains the ordered draw list of visible objects (BlitListDraw,
*   ProcessDrawList), scans view objects to compute per-object priority
*   (ScanViewObjs), and inserts entries by priority (InsertPriList).
*======================================================================
*
BlitListDraw        leas      -2,s      allocate two bytes for X save
                    stx       ,s        save draw-list pointer X
                    pshs      x         push X for MMU call
                    lda       #$1B      MMU twiddle opcode $1B = blit list
                    sta       <$0021    store twiddle code
                    ldx       <$0028    load blit context pointer
                    jsr       >$0701    execute blit list
                    leas      $02,s     discard pushed X
                    ldx       ,s        restore draw-list pointer
                    bsr       ProcessDrawList process all draw-list entries
                    leas      $02,s     release two-byte local frame
                    rts
ProcessDrawList     ldu       ,x        load first draw-list entry
                    beq       ProcessDrawListRet branch if list is empty
                    ldd       #$0000    zero value
                    std       ,x        clear draw-list head ptr
                    std       $02,x     clear tail ptr
                    tfr       u,x       transfer first entry to X
ProcessDrawListLoop stx       <$0055    save current entry as data-block top
                    ldu       $0A,x     load priority address from entry
                    lda       $0C,x     load page number from entry
                    lbsr      CalcPriAddr compute priority buffer address
                    stu       <$004F    store as new heap pointer
                    ldx       ,x        follow next-entry pointer
                    bne       ProcessDrawListLoop loop while more entries
ProcessDrawListRet  rts
ScanViewObjs        leas      >-$00C8,s allocate large local frame
                    stu       ,s        save callback function pointer
                    stx       $02,s     save draw-list head pointer
                    ldu       <$0030    load view-object array pointer
                    clr       $04,s     clear object counter
ScanViewObjsLoop    cmpu      <$0032    check if past end of array
                    bcc       ScanViewObjsSort branch to sort when all scanned
                    jsr       [,s]      call caller's filter function
                    tsta                test if object should be drawn
                    beq       ScanViewObjsNext skip if not included
                    leax      $05,s     point to object-pointer array
                    lda       $04,s     load current object count
                    lsla                multiply by 2 (word index)
                    stu       a,x       store object pointer in array
                    ldb       $04,u     load object's priority value
                    lda       <$26,u    load object control flags
                    bita      #$04      check fixed-priority flag
                    beq       ScanViewObjsPriStore branch if priority is computed
                    lda       >PriBaseFlag,pcr load priority-base flag
                    beq       ScanViewObjsPriCalc branch if not base mode
                    lda       <$24,u    load object Y position
                    suba      #$05      subtract bottom margin
                    ldb       #$0C      priority bands per strip
                    mul                 compute priority band
                    addb      #$30      add base priority offset
                    bra       ScanViewObjsPriStore store computed priority
ScanViewObjsPriCalc clrb                start priority at 0
                    lda       <$24,u    load object Y position
                    beq       ScanViewObjsPriStore branch if Y = 0 (top)
                    ldx       #$05ED    point to priority table
                    ldb       #$A8      start at bottom row
ScanViewObjsPriLoop cmpa      b,x       compare Y to this priority row
                    bhi       ScanViewObjsPriStore branch if Y below this band
                    decb                try next (higher) band
                    bne       ScanViewObjsPriLoop loop while rows remain
ScanViewObjsPriStore leax      >$0085,s  point to priority array in frame
                    lda       $04,s     load current object count
                    stb       a,x       store priority at count index
                    inc       $04,s     increment object count
ScanViewObjsNext    leau      <$2B,u    advance to next object struct
                    bra       ScanViewObjsLoop loop for all objects
ScanViewObjsSort    clra                start outer loop at index 0
ScanViewObjsSortOuter sta       >$00C5,s  save outer loop index
                    cmpa      $04,s     check if index >= object count
                    bcc       ScanViewObjsRet branch when sort complete
                    leax      >$0085,s  point to priority array
                    lda       #$FF      initialize current minimum = $FF
                    sta       >$00C7,s  store initial min value
                    clra                inner loop index = 0
ScanViewObjsSortInner cmpa      $04,s     check if inner done
                    bcc       ScanViewObjsSortStore branch to store when done
                    ldb       a,x       load priority at index A
                    cmpb      >$00C7,s  compare to current minimum
                    bcc       ScanViewObjsSortNext branch if not less
                    sta       >$00C6,s  save index of new minimum
                    stb       >$00C7,s  save new minimum priority
ScanViewObjsSortNext inca                advance inner index
                    bra       ScanViewObjsSortInner continue inner loop
ScanViewObjsSortStore lda       #$FF      mark minimum slot as used
                    ldb       >$00C6,s  load index of minimum
                    sta       b,x       mark that slot with $FF
                    leau      $05,s     point to object-pointer array
                    lslb                multiply index by 2
                    ldx       b,u       load the object pointer at index
                    ldu       $02,s     load draw-list head pointer
                    bsr       InsertPriList insert object into priority list
                    lda       >$00C5,s  reload outer loop index
                    inca                advance to next slot
                    bra       ScanViewObjsSortOuter continue sort
ScanViewObjsRet     ldx       $02,s     reload draw-list head pointer
                    leas      >$00C8,s  release large local frame
                    rts
InsertPriList       leas      -$02,s    allocate two bytes for list ptr
                    stu       ,s        save draw-list head pointer
                    lbsr      AllocViewEntry allocate a new view-entry node
                    ldx       ,s        reload draw-list head pointer
                    ldx       ,x        load current first entry
                    stx       ,u        link new node's next to old first
                    beq       InsertPriListHead branch if list was empty
                    stu       $02,x     update old first's back-link
InsertPriListHead   ldx       ,s        reload draw-list head pointer
                    stu       ,x        set new node as first entry
                    ldd       $02,x     load tail pointer from head
                    bne       InsertPriListRet branch if tail already set
                    stu       $02,x     set new node as tail too
InsertPriListRet    leas      $02,s     release two-byte local frame
                    rts

SortObjsBuf         fcb       0,0
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
SortObjsPtr         fcb       0,0
PunctChars1         fcc       / ,.?!();:[]{}/
                    fcb       0
PunctChars2         fcc       /'`-"/
                    fcb       0

*
*======================================================================
* INPUT PARSING — SENTENCE TOKENIZER
*   Splits the player's raw input into whitespace-delimited tokens,
*   strips punctuation, and stores the token array for dictionary
*   lookup.
*======================================================================
*
ParseSentence       leas      -$07,s    allocate seven local bytes
                    stx       ,s        save pointer to sentence string
                    clrb                fill value = 0
                    ldu       #$0180    start of noun-table area
                    ldx       #$0014    20 bytes
                    lbsr      FillMem   clear noun table
                    ldu       #$0194    start of word-id table
                    ldx       #$0014    20 bytes
                    lbsr      FillMem   clear word-id table
                    ldu       ,s        reload sentence pointer
                    lbsr      TokenizeString tokenize the input sentence
                    clr       $02,s     clear word index
ParseWordLoop       leau      >SortObjsBuf,pcr point to tokenized word buffer
                    stu       >SortObjsPtr,pcr save buffer pointer
                    ldd       <$000A    load current heap top
                    std       $05,s     save for SetLogicPage restore
                    ldd       >$01AA    load words.tok logic page
                    lbsr      SetLogicPage map words.tok into MMU
ParseWordLoopTop    lda       ,u        load first char of current word
                    beq       ParseSentenceDone branch if end-of-input
                    lda       $02,s     load current word index
                    cmpa      #$0A      check if past 10-word limit
                    bcc       ParseSentenceDone branch if too many words
                    lbsr      LookupWord look up word in vocabulary
                    std       $03,s     save word-id pair
                    beq       ParseWordContinue branch if word not found
                    bpl       ParseWordMinus branch if word is an article/link
                    ldx       #$0180    point to noun-table
                    ldb       $02,s     load current word index
                    abx                 index × 1
                    abx                 index × 2 (word = 2 bytes each)
                    stu       ,x        store word pointer in noun-table
                    incb                increment word count
                    stb       >$015A    update parsed-word-count variable
                    stb       >$043A    update word-count game variable
                    lda       >$01AE    load AGI flags byte
                    ora       #$20      set word-found flag
                    sta       >$01AE    store updated flags
                    bra       ParseSentenceStore save page and done
ParseWordMinus      ldb       $02,s     load word index
                    ldx       #$0194    point to word-id table
                    abx                 index × 1
                    abx                 index × 2 (each entry = 2 bytes)
                    ldd       $03,s     load word id pair
                    std       ,x        store word id in table
                    ldb       $02,s     reload word index
                    ldx       #$0180    point to noun table
                    abx                 index × 1
                    abx                 index × 2
                    ldd       >SortObjsPtr,pcr load current token pointer
                    std       ,x        store token pointer in noun-table
                    inc       $02,s     advance to next word slot
ParseWordContinue   stu       >SortObjsPtr,pcr update token scan pointer
                    bra       ParseWordLoopTop process next word
ParseSentenceDone   lda       $02,s     load final word count
                    beq       ParseSentenceStore branch if no words found
                    sta       >$015A    store parsed-word-count variable
                    lda       >$01AE    load AGI flags byte
                    ora       #$20      set word-found flag
                    sta       >$01AE    store updated flags
ParseSentenceStore  ldd       $05,s     reload saved logic-page info
                    lbsr      SetLogicPage restore previous MMU page
                    leas      $07,s     release local frame
                    rts

cmd_parse           lda       >$01AE    load AGI flags byte
                    anda      #$DF      clear word-found flag
                    sta       >$01AE    store cleared flag
                    lda       >$01AE    reload flags
                    anda      #$F7      clear ego-adjacent flag
                    sta       >$01AE    store cleared flag
                    lda       ,y+       load string-number from script
                    cmpa      #$0C      check if valid string index (< 12)
                    bcc       CmdParseRet branch if out of range
                    ldb       #$28      each string entry = 40 bytes
                    mul                 compute string offset
                    ldx       #$0251    base of string table
                    leax      d,x       index to this string
                    lbsr      ParseSentence parse the string as input
CmdParseRet         rts

TokenizeString      leas      -$02,s    allocate output-pointer slot
                    leax      >SortObjsBuf,pcr point to tokenize output buffer
                    stx       ,s        save output pointer on stack
TokenizeLoop        lda       ,u+       load next input character
                    beq       TokenizeDone done if null terminator
                    leax      >PunctChars1,pcr point to punctuation set 1
                    lbsr      FindByte  check if char is punctuation
                    bne       TokenizeLoop skip if found (discard punct)
                    leax      >PunctChars2,pcr point to punctuation set 2
                    lbsr      FindByte  check second punct set
                    bne       TokenizeLoop skip if found (discard)
                    bra       TokenizeStoreChar non-punct: store it
TokenizeCharLoop    leax      >PunctChars1,pcr point to punct set 1
                    lbsr      FindByte  check if char is punctuation
                    bne       TokenizeAddSpace if punct: insert space first
                    leax      >PunctChars2,pcr point to punct set 2
                    lbsr      FindByte  check second punct set
                    bne       TokenizeNextChar if punct: skip char
TokenizeStoreChar   ldx       ,s        load output pointer
                    sta       ,x+       store character to output
                    stx       ,s        update output pointer
TokenizeNextChar    lda       ,u+       load next input character
                    bne       TokenizeCharLoop loop if not null terminator
                    bra       TokenizeDone null: finish up
TokenizeAddSpace    lda       #$20      space character
                    ldx       ,s        load output pointer
                    sta       ,x+       write space to output
                    stx       ,s        update output pointer
                    bra       TokenizeLoop continue scanning
TokenizeDone        leax      >SortObjsBuf,pcr point to output buffer start
                    cmpx      ,s        compare to end-of-output ptr
                    bcc       TokenizeTerminate skip trim if empty
                    ldx       ,s        load end-of-output pointer
                    lda       -$01,x    look at last character written
                    cmpa      #$20      check if trailing space
                    bne       TokenizeTerminate no trailing space: done
                    leax      -$01,x    back up to overwrite space
                    stx       ,s        update end-of-output pointer
TokenizeTerminate   clr       [,s]      null-terminate the output
                    leas      $02,s     release local frame
                    rts

*
*======================================================================
* INPUT PARSING — WORD DICTIONARY LOOKUP
*   Searches the words.tok trie for each input token and returns its
*   AGI word ID; StripLastWord removes unknown tokens from the parsed
*   list.
*======================================================================
*
LookupWord          leas      -$06,s    ; allocate 6-byte local frame
                    ldd       #$FFFF
                    std       ,s        ; init word-ID slot to not-found
                    ldd       #$0000
                    std       $02,s     ; init post-word pointer to null
                    lda       ,u        ; load first character of input word
                    lbsr      ToLower   ; normalize to lowercase
                    cmpa      #$61
                    bcs       LookupNotAlpha ; branch if below 'a'
                    cmpa      #$7A
                    bls       LookupAlphaNext ; branch if 'a'..'z'
LookupNotAlpha      lbsr      StripLastWord ; remove non-alpha word from input
                    lbra      LookupWordRet
LookupAlphaNext     ldb       $01,u     ; load second input character
                    cmpb      #$20
                    beq       LookupSingleWord ; branch if followed by space (single char word)
                    cmpb      #$00
                    bne       LookupAlphaSearch ; branch if more chars follow
LookupSingleWord    cmpa      #$61
                    beq       LookupSingleFound ; 'a' alone is a known word
                    cmpa      #$69
                    bne       LookupAlphaSearch ; 'i' alone is also a known word
LookupSingleFound   clrb
                    stb       ,s        ; store word-ID low byte (0)
                    stb       $01,s     ; store word-ID high byte (0)
                    leax      $01,u     ; point past first character
                    stx       $02,s     ; save post-word pointer
                    ldb       ,x+       ; fetch delimiter after single char
                    cmpb      #$20
                    bne       LookupAlphaSearch ; if not space, still search trie
                    stx       $02,s     ; update pointer past delimiter
LookupAlphaSearch   suba      #$61      ; convert 'a'..'z' to 0..25
                    lsla                ; multiply by 2 for word table index
                    ldx       >$01A8    ; load pointer to per-letter trie table
                    ldd       a,x       ; fetch offset for this letter
                    beq       LookupNotAlpha ; no entries for this letter
                    leax      d,x       ; point X to trie node for letter
                    clr       $04,s     ; clear input character position counter
LookupWordOuter     lda       $04,s     ; load current input char index
                    cmpa      ,x+       ; compare against trie node word index
                    bhi       LookupWordNotFound ; past all candidates, no match
                    bne       LookupCharMiss ; wrong position, skip this node
LookupCharMatch     lda       ,x        ; load trie character (with flags)
                    anda      #$7F      ; strip high bit (word-end flag)
                    sta       $05,s     ; save masked char
                    lda       ,u        ; load next input character
                    lbsr      ToLower   ; normalize to lowercase
                    eora      #$7F      ; XOR for inverted comparison
                    cmpa      $05,s     ; compare against trie char
                    bne       LookupCharMiss ; mismatch, skip node
                    leau      $01,u     ; advance input pointer
                    inc       $04,s     ; increment character position
                    lda       ,x        ; reload trie char with flags
                    anda      #$80      ; test word-end flag
                    beq       LookupCharNext ; not end of trie word yet
                    lda       ,u        ; check what follows in input
                    cmpa      #$00
                    beq       LookupWordFound ; end of input = complete match
                    cmpa      #$20
                    bne       LookupSkipWord ; not space/end, partial match only
LookupWordFound     ldd       $01,x     ; load word ID from trie node
                    std       ,s        ; store matched word ID
                    stu       $02,s     ; save pointer at end of word
                    lda       ,u        ; check character after matched word
                    cmpa      #$00
                    beq       LookupWordRet ; end of input, done
                    tfr       u,d       ; copy pointer to D
                    addd      #$0001    ; advance past delimiter
                    std       $02,s     ; update post-word pointer
                    bra       LookupSkipWord ; continue scanning
LookupCharNext      leax      $01,x     ; advance to next trie byte
                    bra       LookupCharMatch ; check next character
LookupCharMiss      lda       ,u        ; check remaining input
                    cmpa      #$00
                    beq       LookupWordNotFound ; no more input, no match
LookupSkipWord      lda       ,x+       ; read trie chars until end-of-word
                    bpl       LookupSkipWord ; high bit clear = continue skipping
                    leax      $02,x     ; skip word-ID bytes
                    cmpa      #$00
                    bne       LookupWordOuter ; more nodes at same level
LookupWordNotFound  ldu       $02,s     ; restore best partial pointer
                    lbeq      LookupNotAlpha ; if null, strip invalid word
                    lda       ,u        ; check char at partial pointer
                    beq       LookupWordRet ; end of input, return partial
                    clr       -$01,u    ; null-terminate at boundary
LookupWordRet       ldd       ,s        ; load word ID result
                    leas      $06,s     ; release local frame
                    rts

StripLastWord       ldu       >SortObjsPtr,pcr ; load pointer to current input string
                    tfr       u,x       ; copy to X for scanning
StripLastWordLoop   lda       ,x+       ; read next character
                    beq       StripLastWordRet ; end of string, done
                    cmpa      #$20
                    bne       StripLastWordLoop ; keep scanning until space
                    clr       -$01,x    ; null-terminate before the space
StripLastWordRet    rts

*
*======================================================================
* ADD TO PIC COMMAND
*   Overlays a view cel onto the priority/visual picture buffers at a
*   specified position — used for static picture decorations.
*======================================================================
*
cmd_add_to_pic      ldu       #$05B2    ; point to add-to-pic parameter block
                    lda       ,y+       ; fetch view number from script
                    sta       ,u        ; store view number
                    lda       ,y+       ; fetch loop number from script
                    sta       $01,u     ; store loop number
                    lda       ,y+       ; fetch cel number from script
                    sta       $02,u     ; store cel number
                    ldd       ,y++      ; fetch X,Y position from script
                    std       $03,u     ; store X,Y
                    lda       $01,y     ; fetch priority from script
                    lsla                ; shift priority nibble up (bit 1)
                    lsla                ; shift left (bit 2)
                    lsla                ; shift left (bit 3)
                    lsla                ; priority now in high nibble of A
                    ora       ,y++      ; merge with control nibble
                    sta       $05,u     ; store combined priority/control byte
                    bsr       AddToPicImpl ; call implementation
                    rts

cmd_add_to_pic_v    ldu       #$05B2    ; point to add-to-pic parameter block
                    ldx       #$0431    ; point to variable table base
                    clra                ; zero high byte for D indexing
                    ldb       ,y+       ; fetch view var index
                    ldb       d,x       ; dereference variable
                    stb       ,u        ; store view number
                    ldb       ,y+       ; fetch loop var index
                    ldb       d,x       ; dereference variable
                    stb       $01,u     ; store loop number
                    ldb       ,y+       ; fetch cel var index
                    ldb       d,x       ; dereference variable
                    stb       $02,u     ; store cel number
                    ldb       ,y+       ; fetch X var index
                    ldb       d,x       ; dereference variable
                    stb       $03,u     ; store X position
                    ldb       ,y+       ; fetch Y var index
                    ldb       d,x       ; dereference variable
                    stb       $04,u     ; store Y position
                    ldb       ,y+       ; fetch control var index
                    ldb       d,x       ; dereference variable
                    stb       $05,u     ; store control byte
                    ldb       ,y+       ; fetch priority var index
                    ldb       d,x       ; dereference variable
                    lslb                ; shift priority nibble up (bit 3)
                    lslb                ; shift priority nibble up (bit 2)
                    lslb                ; shift priority nibble up (bit 1)
                    lslb                ; priority now in high nibble of B
                    orb       $05,u     ; merge with existing control
                    stb       $05,u     ; store combined byte
                    bsr       AddToPicImpl ; call implementation
                    rts

AddToPicImpl        leas      -$02,s    ; save 2 bytes on stack
                    ldd       <$000A    ; load current logic page
                    std       ,s        ; save logic page for restore
                    lda       #$05
                    clrb                ; D = $0500 (script type: add-to-pic)
                    lbsr      PushScript ; push script type $0500
                    ldx       #$05B2    ; point to parameter block
                    ldd       ,x
                    lbsr      PushScript ; push view/loop bytes
                    ldd       $02,x
                    lbsr      PushScript ; push cel/X bytes
                    ldd       $04,x
                    lbsr      PushScript ; push Y/priority bytes
                    ldu       <$0036    ; load ego object pointer
                    ldb       $02,x     ; get cel number
                    stb       $0E,u     ; set object cel
                    ldb       $01,x     ; get loop number
                    stb       $0A,u     ; set object loop
                    ldb       ,x        ; get view number
                    lbsr      SetViewForObj ; configure view for object
                    ldd       <$10,u    ; get current position
                    std       <$12,u    ; save as previous position
                    ldd       $08,u     ; get object dimensions
                    std       <$14,u    ; save dimensions
                    ldx       #$05B2    ; point back to parameter block
                    ldd       $03,x     ; get X,Y parameters
                    std       $03,u     ; set object position
                    std       <$1A,u    ; set object destination
                    lda       #$02
                    ldb       #$0C
                    std       <$25,u    ; set motion type and step
                    lda       #$0F
                    sta       <$24,u    ; set object flags
                    lbsr      FindObjPos ; calculate object position
                    ldx       #$05B2    ; point to parameter block
                    lda       $05,x     ; get priority/control byte
                    anda      #$0F      ; isolate priority nibble
                    bne       AddToPicColor ; if non-zero, use as priority
                    lda       #$08
                    sta       <$26,u    ; default priority band 8
AddToPicColor       lda       $05,x     ; reload priority/control byte
                    sta       <$24,u    ; store as object priority
                    lbsr      ClearBothRanges ; clear visual and priority ranges
                    ldd       <$0036    ; load ego object pointer
                    pshs      b,a       ; save ego pointer on stack
                    lda       #$0F
                    sta       <$0021    ; set MMU page for visual draw
                    ldx       <$0028    ; load visual draw routine pointer
                    jsr       >$0701    ; call MMU twiddle draw
                    leas      $02,s     ; pop saved pointer
                    lbsr      SwapObjRanges ; swap visual/priority ranges
                    ldd       <$0036    ; reload ego object pointer
                    pshs      b,a       ; save ego pointer on stack
                    lda       #$1B
                    sta       <$0019    ; set MMU page for priority draw
                    ldx       <$0026    ; load priority draw routine pointer
                    jsr       >$0701    ; call MMU twiddle draw
                    leas      $02,s     ; pop saved pointer
                    ldd       ,s        ; reload saved logic page
                    lbsr      SetLogicPage ; restore logic page
                    leas      $02,s     ; release local frame
                    rts

PicListBuf          fcb       0,0,0,0,0,0,0
PicListPtr          fdb       0

*
*======================================================================
* PICTURE LIST MANAGEMENT
*   Maintains the linked list of loaded pictures; implements load_pic,
*   draw_pic, overlay_pic, show_pic, and discard_pic commands.
*======================================================================
*
PicListClear        leau      $3776,pcr ; point to PicListBuf (PC-relative)
                    ldd       #0
                    std       ,u        ; clear first two bytes of pic list
                    rts

pic_find            leau      >PicListBuf,pcr ; start at head of pic list
PicFindLoop         stu       >PicListPtr,pcr ; save pointer to previous node
                    ldu       ,u        ; follow next pointer
                    beq       PicFindRet ; end of list, not found
                    cmpb      $02,u     ; compare pic number against this node
                    bne       PicFindLoop ; mismatch, continue scan
PicFindRet          rts

cmd_load_pic        ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch variable index from script
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get pic number
                    bsr       LoadPicImpl ; load the picture
                    rts

LoadPicImpl         leas      -$05,s    ; allocate 5-byte local frame
                    stb       ,s        ; save pic number
                    bsr       pic_find  ; search pic list for this number
                    cmpu      #$0000
                    bne       LoadPicRet ; already loaded, nothing to do
                    ldd       <$000A    ; save current logic page
                    std       $03,s
                    lbsr      ClearBothRanges ; clear visual and priority ranges
                    lda       #$02
                    ldb       ,s        ; reload pic number
                    lbsr      PushScript ; push load-pic script entry
                    leau      >PicListBuf,pcr ; point to pic list head
                    ldx       >PicListPtr,pcr ; get insertion point
                    beq       LoadPicStore ; list empty, store at head
                    ldd       #$0007
                    lbsr      AllocDataBlock ; allocate 7-byte pic list node
                    stu       ,x        ; link new node into list
                    ldd       #$0000
                    std       ,u        ; clear next pointer of new node
LoadPicStore        ldb       ,s        ; reload pic number
                    stb       $02,u     ; store pic number in node
                    stu       $01,s     ; save node pointer
                    lbsr      FetchPicture ; fetch picture data from volume
                    ldx       #$0000
                    lbsr      OpenVolFile ; open volume file for pic data
                    beq       LoadPicDone ; no data returned
                    ldx       $01,s     ; reload node pointer
                    std       $05,x     ; store volume data size
                    stu       $03,x     ; store volume data pointer
LoadPicDone         lbsr      SwapObjRanges ; swap visual/priority ranges back
                    ldd       $03,s     ; reload saved logic page
                    lbsr      SetLogicPage ; restore logic page
                    ldu       $01,s     ; reload node pointer
LoadPicRet          leas      $05,s     ; release local frame
                    rts

cmd_draw_pic        ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch variable index from script
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get pic number
                    bsr       DrawPicImpl ; draw the picture
                    rts

DrawPicImpl         leas      -$01,s    ; save one byte on stack
                    stb       ,s        ; save pic number
                    stb       >$0240    ; store as current pic number
                    lbsr      pic_find  ; search pic list for this number
                    cmpu      #$0000
                    bne       DrawPicFind ; found it
                    lda       #$12
                    ldb       ,s        ; reload pic number
                    lbsr      ReportError ; report "pic not loaded" error
DrawPicFind         ldd       $03,u     ; get pic volume data pointer
                    std       >$0551    ; store pic data pointer
                    pshs      u         ; save pic list node pointer
                    lda       #$04
                    ldb       $02,s     ; reload pic number
                    lbsr      PushScript ; push draw-pic script entry
                    lbsr      ClearBothRanges ; clear both rendering ranges
                    lda       #$06
                    sta       <$0021    ; set MMU page for pic render
                    ldx       <$0028    ; load pic render routine pointer
                    jsr       >$0701    ; call MMU twiddle render
                    leas      $02,s     ; pop node pointer
                    lbsr      SwapObjRanges ; swap visual/priority ranges
                    clr       >$0100    ; clear pic-drawn flag
                    leas      $01,s     ; release local frame
                    rts

cmd_overlay_pic     ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch variable index from script
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get pic number
                    bsr       pic_overlay ; overlay the picture
                    rts

pic_overlay         leas      -$01,s    ; save one byte on stack
                    stb       ,s        ; save pic number
                    stb       >$0240    ; store as current pic number
                    lbsr      pic_find  ; search pic list for this number
                    cmpu      #$0000
                    bne       OverlayPicRender ; found it
                    lda       #$12
                    ldb       ,s        ; reload pic number
                    lbsr      ReportError ; report "pic not loaded" error
OverlayPicRender    ldd       $03,u     ; get pic volume data pointer
                    std       >$0551    ; store pic data pointer
                    pshs      u         ; save pic list node pointer
                    lda       #$08
                    ldb       $02,s     ; reload pic number
                    lbsr      PushScript
                    lbsr      ClearBothRanges
                    lda       #$09
                    sta       <$0021    ; set MMU page for overlay render
                    ldx       <$0028    ; load overlay render routine pointer
                    jsr       >$0701    ; call MMU twiddle render
                    leas      $02,s     ; pop node pointer
                    lbsr      SwapObjRanges ; swap visual/priority ranges
                    lbsr      UpdateObjSegments ; update object segment data
                    clr       >$0100    ; clear pic-drawn flag
                    leas      $01,s     ; release local frame
                    rts

cmd_show_pic        lda       >$01AF    ; load display flags
                    anda      #$FE      ; clear input-active bit
                    sta       >$01AF    ; store updated flags
                    lbsr      cmd_close_window ; close any open text window
                    lbsr      gfx_picbuff_update ; blit render buffer to screen
                    lda       #$01
                    sta       >$0100    ; mark pic as shown
                    rts

cmd_discard_pic     ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch variable index from script
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get pic number
                    bsr       DiscardPicImpl ; discard the picture
                    rts

DiscardPicImpl      leas      -$03,s    ; allocate 3-byte local frame
                    stb       ,s        ; save pic number
                    lbsr      pic_find  ; find pic in list
                    ldb       ,s        ; reload pic number
                    cmpu      #$0000
                    bne       DiscardPicFound ; found it
                    lda       #$15
                    lbsr      ReportError ; report "pic not loaded" error
DiscardPicFound     stu       $01,s     ; save pic list node pointer
                    lda       #$06
                    ldb       ,s        ; reload pic number
                    lbsr      PushScript ; push discard-pic script entry
                    ldu       >PicListPtr,pcr ; get predecessor node pointer
                    ldd       #$0000
                    std       ,u        ; unlink node from list
                    lbsr      ClearBothRanges ; clear rendering ranges
                    ldu       $01,s     ; reload discarded node pointer
                    stu       <$0055    ; store for free-space calc
                    lda       $05,u     ; get size field from node
                    ldu       $03,u     ; get data pointer from node
                    lbsr      CalcPriAddr ; calculate priority address
                    stu       <$004F    ; store priority address
                    lbsr      SwapObjRanges ; swap ranges to restore state
                    lbsr      UpdateFreeSpace ; update free memory counter
                    leas      $03,s     ; release local frame
                    rts

*
*======================================================================
* OBJECT POSITION COMMANDS
*   Implements position, position_v, get_position, reposition (relative
*   move), reposition_to, and reposition_to_v.
*======================================================================
*
cmd_position        lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    ldd       ,y++      ; fetch X,Y from script
                    std       $03,u     ; set object position
                    std       <$1A,u    ; set destination to same
                    rts

cmd_position_v      lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch X var index
                    abx                 ; index into variable table
                    lda       ,x        ; dereference X variable
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch Y var index
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference Y variable
                    std       $03,u     ; set object position X,Y
                    std       <$1A,u    ; set destination to same
                    rts

cmd_get_position    lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch X result var index
                    abx                 ; index into variable table
                    lda       $03,u     ; get object X position
                    sta       ,x        ; store into X variable
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch Y result var index
                    abx                 ; index into variable table
                    lda       $04,u     ; get object Y position
                    sta       ,x        ; store into Y variable
                    rts

cmd_reposition      leas      -$02,s    ; allocate 2-byte local frame
                    lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$25,u    ; load motion flags
                    ora       #$04      ; set reposition-in-progress flag
                    sta       <$25,u    ; store updated flags
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch dX var index
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference dX variable (signed)
                    sex                 ; sign-extend B to D
                    std       ,s        ; save signed delta X
                    clra                ; zero A for unsigned add
                    ldb       $03,u     ; get current X position
                    addd      ,s        ; add signed delta
                    bpl       ReposXDone ; result positive, ok
                    clrb                ; clamp to zero
ReposXDone          stb       $03,u     ; store new X position
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch dY var index
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference dY variable (signed)
                    sex                 ; sign-extend B to D
                    std       ,s        ; save signed delta Y
                    clra                ; zero A for unsigned add
                    ldb       $04,u     ; get current Y position
                    addd      ,s        ; add signed delta
                    bpl       ReposYDone ; result positive, ok
                    clrb                ; clamp to zero
ReposYDone          stb       $04,u     ; store new Y position
                    lbsr      FindObjPos ; recalculate object bounds
                    leas      $02,s     ; release local frame
                    rts

cmd_reposition_to   lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    ldd       ,y++      ; fetch absolute X,Y from script
                    std       $03,u     ; set object position
                    lda       <$25,u    ; load motion flags
                    ora       #$04      ; set reposition flag
                    sta       <$25,u    ; store updated flags
                    lbsr      FindObjPos ; recalculate object bounds
                    rts

cmd_reposition_to_v lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch X var index
                    abx                 ; index into variable table
                    lda       ,x        ; dereference X variable
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch Y var index
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference Y variable
                    std       $03,u     ; set object position
                    lda       <$25,u    ; load motion flags
                    ora       #$04      ; set reposition flag
                    sta       <$25,u    ; store updated flags
                    lbsr      FindObjPos ; recalculate object bounds
                    rts

*
*======================================================================
* OBJECT TERRAIN RESTRICTION COMMANDS
*   Implements obj_on_water, obj_on_land, and obj_on_anything to set
*   terrain constraints for an object.
*======================================================================
*
cmd_obj_on_water    lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$25,u    ; load constraint flags
                    ora       #$01      ; set water-only flag
                    sta       <$25,u    ; store updated flags
                    rts

cmd_obj_on_land     lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$25,u    ; load constraint flags
                    ora       #$08      ; set land-only flag
                    sta       <$25,u    ; store updated flags
                    rts

cmd_obj_on_anything lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$25,u    ; load constraint flags
                    anda      #$F6      ; clear water/land constraint bits
                    sta       <$25,u    ; store updated flags
                    rts

*
*======================================================================
* HORIZON COMMANDS
*   Implements set_horizon, ignore_horizon, and observe_horizon to
*   control whether objects are confined above the horizon line.
*======================================================================
*
cmd_set_horizon     lda       ,y+       ; fetch horizon value from script
                    sta       >$01D6    ; store as current horizon Y
                    rts

cmd_ignore_horizon  lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$26,u    ; load boundary flags
                    ora       #$08      ; set ignore-horizon flag
                    sta       <$26,u    ; store updated flags
                    rts

cmd_observe_horizon lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$26,u    ; load boundary flags
                    anda      #$F7      ; clear ignore-horizon flag
                    sta       <$26,u    ; store updated flags
                    rts

StrMsgTooVerbose    fcc       /Message too verbose:/
                    fcb       $0a,$0a
                    fcc       /"%s..."/
                    fcb       $0a,$0a
                    fcc       /Press CTRL-BREAK to continue./
                    fcb       0

PrintAtRow          fcb       $ff
PrintAtCol          fcb       $ff
PrintAtHeight       fcb       $ff

*
*======================================================================
* PRINT AND MESSAGE BOX
*   Implements print, print_v, print_at, print_at_v, and the full
*   message_box / message_box_draw pipeline that word-wraps text and
*   displays it in a pop-up window.
*======================================================================
*
cmd_print           ldb       ,y+       ; fetch message number from script
                    lbsr      GetMsgPtr ; get pointer to message text
                    bsr       message_box ; display message box
                    rts
cmd_print_v         ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch variable index from script
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get message number
                    lbsr      GetMsgPtr ; get pointer to message text
                    bsr       message_box ; display message box
                    rts
cmd_print_at        ldb       ,y+       ; fetch message number from script
                    bsr       SetPrintAtImpl ; set position and print
                    rts
cmd_print_at_v      ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch variable index from script
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get message number
                    bsr       SetPrintAtImpl ; set position and print
                    rts

SetPrintAtImpl      lda       ,y+       ; fetch column from script
                    sta       >PrintAtCol,pcr ; store print column
                    lda       ,y+       ; fetch row from script
                    sta       >PrintAtRow,pcr ; store print row
                    lda       ,y+       ; fetch height from script
                    bne       SetPrintAtHeight ; non-zero = use given height
                    lda       #$1E      ; default height = 30
SetPrintAtHeight    sta       >PrintAtHeight,pcr ; store box height
                    lbsr      GetMsgPtr ; get pointer to message text
                    bsr       message_box ; display message box
                    ldd       #$FFFF
                    sta       >PrintAtHeight,pcr ; reset height to $FF (unset)
                    std       >PrintAtRow,pcr ; reset row/col to $FFFF (unset)
SetPrintAtRet       rts

message_box         leas      -$05,s    ; allocate 5-byte local frame
                    ldd       #$0000
                    pshs      b,a       ; push padding word
                    ldd       #$0000
                    pshs      b,a       ; push padding word
                    ldd       #$0000
                    pshs      b,a       ; push padding word
                    pshs      u         ; push message pointer
                    lbsr      message_box_draw ; draw the message box
                    leas      $08,s     ; release draw parameters
MsgBoxCheckPrint    lda       >$01AF    ; load display flags
                    anda      #$01      ; test print-only flag
                    beq       MsgBoxGetInput ; not print-only, get input
                    lda       >$01AF    ; reload display flags
                    anda      #$FE      ; clear print-only flag
                    sta       >$01AF    ; store updated flags
                    lda       #$01      ; return success
                    bra       MsgBoxRet
MsgBoxGetInput      lda       >$0446    ; load auto-advance timer variable
                    bne       MsgBoxTimedWait ; non-zero = timed display
                    lda       #$01
                    sta       ,s        ; set "accepted" flag
                    lbsr      BooleanPoll ; wait for user keypress
                    cmpa      #$01
                    beq       MsgBoxClose ; confirmed, close
                    clra                ; clear accepted flag (user rejected)
                    sta       ,s        ; clear accepted flag
                    bra       MsgBoxClose
MsgBoxTimedWait     ldb       #$0A      ; multiply timer by 10
                    mul                 ; A*10 → D (tick count)
                    orcc      #$50      ; disable interrupts for tick read
                    addd      >$024A    ; add to current tick low word
                    std       $03,s     ; save target tick low word
                    ldd       >$0248    ; load current tick high word
                    andcc     #$AF      ; re-enable interrupts
                    bcc       MsgBoxTimerSet ; no carry into high word
                    addd      #$0001    ; propagate carry
MsgBoxTimerSet      std       $01,s     ; save target tick high word
MsgBoxWaitLoop      ldd       $01,s     ; load target high word
                    cmpd      >$0248    ; compare to current high word
                    blt       MsgBoxClose ; time expired
                    bgt       MsgBoxWaitKey ; time not yet reached
                    ldd       $03,s     ; load target low word
                    cmpd      >$024A    ; compare to current low word
                    bls       MsgBoxClose ; time expired
MsgBoxWaitKey       lbsr      WaitEnterOrEsc ; check for keypress
                    tsta                ; test result
                    bmi       MsgBoxWaitLoop ; negative = no key, keep waiting
MsgBoxClose         lbsr      cmd_close_window ; close the message window
                    lda       ,s        ; load accepted/dismissed flag
MsgBoxRet           leas      $05,s     ; release local frame
                    rts

message_box_draw    leas      >-$02BC,s ; allocate large local text buffer
                    lbsr      cmd_close_window ; close any existing window
                    lbsr      PushTextColor ; save current text color
                    lbsr      PushRowCol ; save current cursor row/col
                    clra                ; A = 0 (high byte of color word)
                    ldb       #$0F
                    lbsr      text_color ; set text color to white on black
                    ldb       >PrintAtHeight,pcr ; get requested box height
                    cmpb      #$FF
                    bne       MsgBoxSetHeight ; explicit height given
                    tst       >$02C3,s  ; test stored height
                    bne       MsgBoxSetupDraw ; already set, proceed
                    ldb       #$1E
                    stb       >$02C3,s  ; default height = 30 rows
                    bra       MsgBoxSetupDraw
MsgBoxSetHeight     lda       >PrintAtHeight,pcr ; load explicit height
                    sta       >$02C3,s  ; store in local buffer
MsgBoxSetupDraw     leax      ,s        ; X = pointer to local text buffer
                    ldd       >$02C2,s  ; load message params high word
                    pshs      b,a       ; push for MsgTextSetup
                    ldd       >$02C0,s  ; load message params low word
                    pshs      b,a       ; push for MsgTextSetup
                    pshs      x         ; push buffer pointer
                    lbsr      MsgTextSetup ; format message text into buffer
                    leas      $06,s     ; pop MsgTextSetup args
                    tst       >$02C5,s  ; test print-at flag
                    beq       MsgBoxSkipPrintAt ; no explicit position
                    lda       >$02C3,s  ; load row count
                    sta       >$0159    ; store for layout
                    lda       >$02C1,s  ; load column count
                    beq       MsgBoxSkipPrintAt ; zero = auto-position
                    sta       >$015B    ; store column count for layout
MsgBoxSkipPrintAt   lda       #$13      ; max allowed column count = 19
                    cmpa      >$015B
                    bcc       MsgBoxHeightOk ; fits within screen width
                    ldx       >$02BE,s  ; load message pointer
                    lda       <$14,x    ; save original length byte
                    clr       <$14,x    ; truncate message
                    pshs      x,a       ; save pointer and length
                    leau      >StrMsgTooVerbose,pcr ; point to "too verbose" format string
                    leax      >$025B,s  ; X = position in text buffer
                    ldd       >$02C1,s  ; load column count
                    pshs      b,a       ; push for PrintFmtStr
                    pshs      u         ; push format string pointer
                    pshs      x         ; push output buffer pointer
                    lbsr      PrintFmtStr ; format truncation message
                    leas      $06,s     ; pop PrintFmtStr args
                    puls      x,a       ; restore message pointer and length
                    sta       <$14,x    ; restore original length byte
                    stu       >$02BE,s  ; update message pointer
                    bra       MsgBoxSetupDraw ; redo layout with truncated text
MsgBoxHeightOk      lda       >$015B    ; load column count (width in chars)
                    ldb       #$08
                    mul                 ; A*8 = pixel width
                    addb      #$0A      ; add border pixels
                    stb       >$017B    ; store box pixel width
                    lda       >$0159    ; load row count (height in chars)
                    ldb       #$04
                    mul                 ; A*4 = pixel height
                    addb      #$0A      ; add border pixels
                    stb       >$017C    ; store box pixel height
                    lda       >PrintAtCol,pcr ; load requested column
                    bpl       MsgBoxColCalc ; explicit column given
                    lda       #$13      ; screen width in chars = 19
                    suba      >$015B    ; subtract box width
                    lsra                ; divide by 2 to center
                    adda      #$01      ; add margin
MsgBoxColCalc       adda      >$0241    ; add scroll offset
                    sta       >$0175    ; store box left column
                    adda      >$015B    ; add box width
                    deca                ; subtract 1
                    sta       >$0177    ; store box right column
                    lda       >PrintAtRow,pcr ; load requested row
                    bpl       MsgBoxRowCalc ; explicit row given
                    lda       #$28      ; screen height in rows = 40
                    suba      >$0159    ; subtract box height
                    lsra                ; divide by 2 to center
MsgBoxRowCalc       sta       >$0176    ; store box top row
                    sta       >$017A    ; store for cursor restore
                    adda      >$0159    ; add box height
                    sta       >$0178    ; store box bottom row
                    lda       >$0175    ; load box left column
                    ldb       >$0176    ; load box top row
                    std       <$0040    ; store box origin
                    lda       #$04
                    mul                 ; A*4 = pixel X offset
                    subb      #$05      ; subtract border
                    stb       >$017D    ; store pixel X for draw
                    lda       >$0177    ; load box right column
                    inca                ; include right border
                    suba      >$0241    ; subtract scroll offset
                    ldb       #$08
                    mul                 ; A*8 = pixel width
                    addb      #$04      ; add border
                    stb       >$017E    ; store pixel width for draw
                    ldd       #$040F    ; color $04, border $0F
                    pshs      b,a       ; push for draw call
                    ldd       >$017B    ; load box pixel dimensions
                    pshs      b,a       ; push for draw call
                    ldd       >$017D    ; load box pixel position
                    pshs      b,a       ; push for draw call
                    lda       #$0C
                    sta       <$0019    ; set MMU page for box draw
                    ldx       <$0026    ; load box draw routine pointer
                    jsr       >$0701    ; call MMU twiddle draw box
                    leas      $06,s     ; pop draw args
                    lda       #$01
                    sta       >$017F    ; mark window as open
                    leax      ,s        ; X = text buffer pointer
                    pshs      x         ; push buffer pointer
                    lbsr      PrintFmtStrToScr ; render formatted text to screen
                    leas      $02,s     ; pop buffer pointer
                    clr       >$017A    ; clear top-row save
                    lbsr      PopRowCol ; restore cursor row/col
                    lbsr      PopTextColor ; restore text color
                    leas      >$02BC,s  ; release text buffer
                    rts

cmd_close_window    tst       >$017F    ; test window-open flag
                    beq       CloseWindowRet ; no window open
                    ldd       >$017B    ; load window pixel dimensions
                    pshs      b,a       ; push for erase call
                    ldd       >$017D    ; load window pixel position
                    pshs      b,a       ; push for erase call
                    lda       #$03
                    sta       <$0019    ; set MMU page for window erase
                    ldx       <$0026    ; load window erase routine pointer
                    jsr       >$0701    ; call MMU twiddle erase
                    leas      $04,s     ; pop erase args
                    clr       >$017F    ; clear window-open flag
CloseWindowRet      rts

MsgTextSetup        ldd       #$0000    ; zero
                    sta       >$015B    ; clear column count
                    sta       >$0157    ; clear char count
                    sta       >$0159    ; clear line count
                    std       >$0155    ; clear word-wrap pointer
                    lda       $07,s     ; get max width from caller
                    sta       >$0158    ; store max chars per line
                    ldu       $04,s     ; get string pointer from caller
                    beq       MsgTextSetupNoStr ; null pointer = no string
                    ldd       $02,s     ; get output buffer pointer
                    pshs      b,a       ; push for FormatStr
                    pshs      u         ; push string pointer
                    lbsr      FormatStr ; format string into buffer
                    leas      $04,s     ; pop FormatStr args
                    clr       ,u        ; null-terminate formatted output
                    lbsr      IncrLineCount ; count final line
MsgTextSetupNoStr   ldx       $02,s     ; return output buffer pointer
                    rts

FormatStr           leas      -$02,s    ; allocate 2-byte local frame
                    pshs      x         ; save X (output buffer pointer)
                    ldx       $06,s     ; get input string pointer
                    ldu       $08,s     ; get output buffer pointer
                    tst       ,x        ; test if input is empty
                    lbeq      FormatStrDone ; null string, nothing to do
                    lda       >$015B    ; check current line count
                    cmpa      #$13      ; max lines = 19
                    lbhi      FormatStrDone ; too many lines, stop
FormatStrLoop       lda       >$0157    ; load current char count on line
                    cmpa      >$0158    ; compare to max per line
                    lbcc      FormatStrWordWrap ; overflow, do word wrap
                    lda       ,x        ; load next character
                    lbeq      FormatStrDone ; end of string
                    cmpa      >$0101    ; check for literal-next prefix
                    bne       FormatStrCheckEsc ; not literal, check for escape
                    tst       ,x+       ; consume literal-next byte
                    bra       FormatStrStoreChar ; store next char literally
FormatStrCheckEsc   cmpa      #$25      ; check for '%' escape prefix
                    beq       FormatStrEscape ; handle escape sequence
                    cmpa      #$0A      ; check for newline
                    bne       FormatStrCheckNl
                    lbsr      IncrLineCount ; count this line
                    bra       FormatStrCopyChar ; copy newline to output
FormatStrCheckNl    cmpa      #$20      ; check for space (word break point)
                    bne       FormatStrStoreChar
                    stu       >$0155    ; save current output pointer as word-wrap point
FormatStrStoreChar  inc       >$0157    ; increment char count on line
FormatStrCopyChar   lda       ,x+       ; copy char from input
                    sta       ,u+       ; to output buffer
                    bra       FormatStrLoop
FormatStrEscape     ldd       ,x++      ; read format code byte and advance X
                    cmpb      #$77
                    beq       FormatStrEscapeW ; %w = window width
                    cmpb      #$73
                    beq       FormatStrEscapeS ; %s = save-game string
                    cmpb      #$6D
                    beq       FormatStrEscapeM ; %m = message reference
                    cmpb      #$67
                    beq       FormatStrEscapeG ; %g = global message
                    cmpb      #$76
                    lbeq      FormatStrEscapeV ; %v = variable value
                    cmpb      #$6F
                    bne       FormatStrLoop ; unknown escape, skip
                    stu       $08,s     ; save output pointer
                    lbsr      ParseDecStr ; parse decimal index from input
                    clra                ; A = 0 (high byte of variable index)
                    ldu       #$0431    ; point to variable table
                    lda       d,u       ; dereference variable for object num
                    ldb       #$03
                    mul                 ; A*3 = object struct index
                    addd      #$0000    ; (identity — align offset)
                    ldu       <$0038    ; load object name pointer table
                    ldu       d,u       ; dereference object name pointer
                    lbra      FormatStrEscapeRec ; copy object name to output
FormatStrEscapeW    stu       $08,s     ; save output pointer
                    lbsr      ParseDecStr ; parse decimal index
                    decb                ; adjust to 0-based
                    bmi       FormatStrLoop ; negative, skip
                    cmpb      >$015A    ; compare to window count
                    bcc       FormatStrLoop ; out of range, skip
                    lslb                ; multiply by 2 for word table
                    ldu       #$0180    ; point to window table
                    leau      [b,u]     ; indirect load window pointer
                    lbra      FormatStrEscapeRec ; copy window string to output
FormatStrEscapeS    stu       $08,s     ; save output pointer
                    lbsr      ParseDecStr ; parse save slot index
                    lda       #$28      ; size of save name entry = 40
                    mul                 ; A*40 = slot offset
                    addd      #$0251    ; add save name table base
                    tfr       d,u       ; U = pointer to save slot name
                    bra       FormatStrEscapeRec ; copy name to output
FormatStrEscapeM    stu       $08,s     ; save output pointer
                    lbsr      ParseDecStr ; parse message number
                    lbsr      GetMsgPtr ; get pointer to message
                    cmpu      #$0000
                    lbeq      FormatStrLoop ; message not found, skip
                    bra       FormatStrEscapeRec ; copy message to output
FormatStrEscapeG    stu       $08,s     ; save output pointer
                    ldd       <$0062    ; save current logic pointer
                    std       $02,s
                    clrb                ; B = 0 (find slot by number 0 = search)
                    lbsr      FindLogicSlot ; find logic slot
                    stu       <$0062    ; update current logic pointer
                    ldd       $04,u     ; get logic page
                    lbsr      SetLogicPage ; switch to logic page
                    lbsr      ParseDecStr ; parse message number
                    lbsr      GetMsgPtr ; get pointer to message
                    cmpu      #$0000
                    beq       FormatStrEscapeGRet ; message not found
                    ldd       $08,s     ; reload output pointer
                    pshs      b,a       ; push for recursive FormatStr
                    pshs      u         ; push message pointer
                    lbsr      FormatStr ; recursively format message
                    leas      $04,s     ; pop recursive FormatStr args
FormatStrEscapeGRet ldu       $02,s     ; restore saved logic pointer
                    stu       <$0062
                    ldd       $04,u     ; get saved logic page
                    lbsr      SetLogicPage ; restore logic page
                    ldu       $08,s     ; restore output pointer
                    lbra      FormatStrLoop ; continue format loop
FormatStrEscapeV    stu       $08,s     ; save output pointer
                    lbsr      ParseDecStr ; parse variable index
                    ldu       #$0431    ; point to variable table
                    clra                ; A = 0 (high byte of variable index)
                    ldb       d,u       ; dereference variable to get value
                    pshs      x         ; save input pointer
                    lbsr      UIntToDecStr ; convert byte to decimal string
                    tfr       x,u       ; U = output decimal string
                    puls      x         ; restore input pointer
                    lda       ,x        ; check next char in format
                    cmpa      #$7C      ; '|' = zero-pad specifier?
                    bne       FormatStrEscapeRec ; no, just copy number
                    leax      $01,x     ; skip '|'
                    lbsr      ParseDecStr ; parse pad width
                    lbsr      StrZeroPad ; zero-pad to width
FormatStrEscapeRec  ldd       $08,s     ; reload output pointer
                    pshs      b,a       ; push output pointer for FormatStr
                    pshs      u         ; push string pointer
                    lbsr      FormatStr ; recursively format substitution string
                    leas      $04,s     ; pop FormatStr args
                    stu       $08,s     ; update output pointer
                    lbra      FormatStrLoop ; continue main format loop
FormatStrWordWrap   ldd       >$0155    ; load saved word-wrap point
                    bne       FormatStrWordWrapMove ; have a wrap point, move word
                    lda       #$0A
                    sta       ,u+       ; insert newline in output
                    stu       $08,s     ; update output pointer
                    lbsr      IncrLineCount ; count new line
                    lbra      FormatStrLoop ; continue
FormatStrWordWrapMove clr       ,u        ; null-terminate at current pos
                    tfr       u,d       ; D = current output pointer
                    subd      >$0155    ; subtract wrap point = chars since last space
                    negb                ; negate to get count of chars to move back
                    addb      >$0157    ; subtract from current char count
                    stb       >$0157    ; store adjusted char count
                    lbsr      IncrLineCount ; count wrapped line
                    pshs      x         ; save input pointer
                    ldx       >$0155    ; load word-wrap output position
                    lda       #$0A
                    sta       ,x+       ; overwrite space with newline
FormatStrSkipSpaces lda       ,x+       ; skip spaces after newline
                    cmpa      #$20
                    beq       FormatStrSkipSpaces ; keep skipping
                    leax      -$01,x    ; back up one (non-space char)
                    ldu       >$0155    ; reload wrap point
                    leau      $01,u     ; advance past newline
                    lbsr      StrCopy   ; copy remainder to new position
                    ldd       #$0000
                    std       >$0155    ; clear wrap point
FormatStrCountChars lda       ,x+       ; scan moved text to count chars
                    beq       FormatStrCountRet ; end of moved text
                    inc       >$0157    ; count character
                    bra       FormatStrCountChars
FormatStrCountRet   leau      -$01,x    ; point U to last char
                    stu       $0A,s     ; update output pointer
                    puls      x         ; restore input pointer
                    lbra      FormatStrLoop
FormatStrDone       puls      x         ; restore output buffer pointer
                    leas      $02,s     ; release local frame
                    rts

GetMsgPtr           leas      -$01,s    ; save one byte on stack
                    ldu       <$0062    ; load current logic pointer
                    cmpb      $03,u     ; compare message num to count
                    bls       GetMsgPtrFound ; valid message number
                    ldd       #$0000
                    tfr       d,u       ; return null pointer (not found)
                    bra       GetMsgPtrRet
GetMsgPtrFound      ldu       $0A,u     ; load logic's message pointer table
                    stb       ,s        ; save message number
                    clra                ; A = 0 (high byte for word shift)
                    lslb                ; multiply by 2 for word offset
                    rola                ; rotate carry into A (16-bit shift)
                    ldd       d,u       ; load message offset from table
                    bne       GetMsgPtrRet ; non-zero offset = valid
                    ldb       ,s        ; reload message number
                    lda       #$0E
                    lbsr      ReportError ; report "message not found" error
GetMsgPtrRet        exg       a,b       ; swap to make D = offset word
                    leau      d,u       ; U = base + offset = message pointer
                    leas      $01,s     ; release local frame
                    rts

*
*======================================================================
* TEXT DISPLAY COMMANDS
*   Implements display and display_v: formats a message and renders it
*   to a fixed row/col position on the text screen without a message box.
*======================================================================
*
cmd_display         leas      >-$03E8,s ; allocate 1000-byte text buffer
                    lbsr      PushRowCol ; save current cursor position
                    ldd       ,y++      ; fetch row,col from script
                    std       <$0040    ; store as cursor position
                    ldb       ,y+       ; fetch message number from script
                    bsr       GetMsgPtr ; get pointer to message text
                    leax      ,s        ; X = text buffer pointer
                    ldd       #$0028
                    pshs      b,a       ; push max width = 40
                    pshs      u         ; push message pointer
                    pshs      x         ; push buffer pointer
                    lbsr      MsgTextSetup ; format message into buffer
                    leas      $06,s     ; pop MsgTextSetup args
                    leax      ,s        ; X = text buffer pointer
                    pshs      x         ; push for PrintFmtStrToScr
                    lbsr      PrintFmtStrToScr ; render to screen at row/col
                    leas      $02,s     ; pop buffer pointer
                    lbsr      PopRowCol ; restore cursor position
                    leas      >$03E8,s  ; release text buffer
                    rts

cmd_display_v       leas      >-$03E8,s ; allocate 1000-byte text buffer
                    lbsr      PushRowCol ; save current cursor position
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch row var index
                    abx                 ; index into variable table
                    lda       ,x        ; dereference row variable
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch col var index
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference col variable
                    std       <$0040    ; store row,col as cursor position
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch message var index
                    abx                 ; index into variable table
                    ldb       ,x        ; dereference to get message number
                    bsr       GetMsgPtr ; get pointer to message text
                    leax      ,s        ; X = text buffer pointer
                    ldd       #$0028
                    pshs      b,a       ; push max width = 40
                    pshs      u         ; push message pointer
                    pshs      x         ; push buffer pointer
                    lbsr      MsgTextSetup ; format message into buffer
                    leas      $06,s     ; pop MsgTextSetup args
                    leax      ,s        ; X = text buffer pointer
                    pshs      x         ; push for PrintFmtStrToScr
                    lbsr      PrintFmtStrToScr ; render to screen at row/col
                    leas      $02,s     ; pop buffer pointer
                    lbsr      PopRowCol ; restore cursor position
                    leas      >$03E8,s  ; release text buffer
                    rts

*
*======================================================================
* FORMAT STRING ENGINE
*   ParseDecStr parses inline decimal numbers; PrintFmtStr and
*   PrintFmtStrToScr implement printf-style formatting (%s, %d, %u,
*   %x, %c) used throughout the message and status display code.
*======================================================================
*
ParseDecStr         clrb                ; start with value 0
ParseDecStrLoop     lda       ,x        ; peek at next char
                    cmpa      #$30
                    bcs       ParseDecStrRet ; below '0', done
                    cmpa      #$39
                    bhi       ParseDecStrRet ; above '9', done
                    lda       #$0A
                    mul                 ; multiply current value by 10
                    subb      #$30      ; subtract ASCII '0'
                    addb      ,x+       ; add digit and advance X
                    bra       ParseDecStrLoop ; continue
ParseDecStrRet      rts
IncrLineCount       inc       >$015B    ; increment line count
                    lda       >$0157    ; get current line's char count
                    clr       >$0157    ; reset char count for next line
                    cmpa      >$0159    ; compare to max line width seen
                    bls       IncrLineCountRet ; not wider
                    sta       >$0159    ; update max line width
IncrLineCountRet    rts
PrintFmtOutPtr      fcb       0,0
PrintFmtDrawFlag    fcb       0
PrintFmtHasText     fcb       0
PrintFmtBasePtr     fcb       0,0

PrintFmtStr         clr       >PrintFmtDrawFlag,pcr ; format-only mode (no draw)
                    ldd       $02,s     ; get output buffer pointer
                    std       >PrintFmtOutPtr,pcr ; initialize output pointer
                    ldx       $04,s     ; get format string pointer
                    leau      $06,s     ; U = args pointer (past format ptr)
                    bsr       PrintFmtLoop ; process format string
                    ldu       $02,s     ; return output buffer pointer
                    rts

PrintFmtStrToScr    leas      <-$2A,s   ; allocate 42-byte line buffer
                    clr       >PrintFmtHasText,pcr ; clear has-text flag
                    lda       #$01
                    sta       >PrintFmtDrawFlag,pcr ; draw mode (output to screen)
                    leax      ,s        ; X = line buffer pointer
                    stx       >PrintFmtBasePtr,pcr ; save base of line buffer
                    stx       >PrintFmtOutPtr,pcr ; initialize output pointer
                    ldx       <$2C,s    ; get format string pointer from caller
                    leau      <$2E,s    ; U = args pointer
                    bsr       PrintFmtLoop ; process format string
                    leas      <$2A,s    ; release line buffer
                    rts

PrintFmtLoop        lda       ,x+       ; load next format char
                    beq       PrintFmtOutputChar ; null = end, flush it
                    cmpa      #$25      ; check for '%' format specifier
                    beq       PrintFmtEscS ; handle format escape
                    bsr       PrintFmtOutputChar ; emit literal char
                    bra       PrintFmtLoop
PrintFmtEscS        lda       ,x+       ; load format type char
                    cmpa      #$73
                    bne       PrintFmtEscD ; not '%s'
                    ldd       ,u++      ; fetch string pointer from args
                    pshs      u,x       ; save U and X
                    bra       PrintFmtStrEmit ; emit string
PrintFmtEscD        cmpa      #$64
                    bne       PrintFmtEscUX ; not '%d'
                    tst       ,u        ; test sign of next arg
                    bpl       PrintFmtEscU ; positive, treat as unsigned
                    lda       #$2D
                    bsr       PrintFmtOutputChar ; emit '-' for negative
                    ldd       #$0000
                    subd      ,u++      ; negate: 0 - arg
                    pshs      u,x       ; save U and X
                    lbsr      UIntToDecStr ; convert to decimal string
                    tfr       x,d       ; D = pointer to decimal string
                    bra       PrintFmtStrEmit
PrintFmtEscUX       cmpa      #$75
                    beq       PrintFmtEscU ; '%u' = unsigned decimal
                    cmpa      #$78
                    bne       PrintFmtEscC ; not '%x'
                    ldd       ,u++      ; fetch unsigned arg
                    pshs      u,x       ; save U and X
                    lbsr      UIntToHexStr ; convert to hex string
                    tfr       x,d       ; D = pointer to hex string
                    bra       PrintFmtStrEmit
PrintFmtEscU        ldd       ,u++      ; fetch unsigned arg
                    pshs      u,x       ; save U and X
                    lbsr      UIntToDecStr ; convert to decimal string
                    tfr       x,d       ; D = pointer to decimal string
                    bra       PrintFmtStrEmit
PrintFmtEscC        cmpa      #$63
                    bne       PrintFmtEscOther ; not '%c'
                    ldd       ,u++      ; fetch character value from args
                    bsr       PrintFmtOutputChar ; emit character
                    bra       PrintFmtLoop
PrintFmtEscOther    leax      -$01,x    ; back up to format type char
                    lda       -$01,x    ; reload '%' char
                    bsr       PrintFmtOutputChar ; emit '%' literally
                    bra       PrintFmtLoop
PrintFmtStrEmit     tfr       d,x       ; X = pointer to converted string
PrintFmtStrEmitLoop lda       ,x+       ; load next char of converted string
                    lbne      PrintFmtStrEmitChar ; non-null, emit it
                    puls      u,x       ; restore U and X
                    lbra      PrintFmtLoop ; continue format loop
PrintFmtStrEmitChar bsr       PrintFmtOutputChar ; emit string character
                    bra       PrintFmtStrEmitLoop
PrintFmtOutputChar  pshs      u,x       ; save U and X
                    ldu       >PrintFmtOutPtr,pcr ; load current output pointer
                    sta       ,u+       ; store character and advance
                    stu       >PrintFmtOutPtr,pcr ; save updated pointer
                    tst       >PrintFmtDrawFlag,pcr ; check if in draw mode
                    beq       PrintFmtOutputCharRet ; format-only, done
                    tsta                ; test character value
                    beq       PrintFmtFlushLine ; null = flush
                    cmpa      #$0A
                    beq       PrintFmtFlushLine ; newline = flush
                    cmpa      #$0D
                    beq       PrintFmtFlushLine ; CR = flush
                    lda       #$01
                    sta       >PrintFmtHasText,pcr ; mark line has content
                    bra       PrintFmtOutputCharRet
PrintFmtFlushLine   tst       >PrintFmtHasText,pcr ; any text to flush?
                    beq       PrintFmtPostFlush ; no text, skip draw
                    clr       ,-u       ; null-terminate at output
                    pshs      a         ; save delimiter char
                    ldd       >PrintFmtBasePtr,pcr ; load line buffer base
                    pshs      b,a       ; push for draw call
                    lda       #$0F
                    sta       <$0019    ; set MMU page for text draw
                    ldx       <$0026    ; load text draw routine pointer
                    jsr       >$0701    ; call MMU twiddle draw text
                    leas      $02,s     ; pop draw arg
                    clra                ; A = 0 (false: no pending text)
                    sta       >PrintFmtHasText,pcr ; clear has-text flag
                    puls      a         ; restore delimiter char
PrintFmtPostFlush   tsta                ; test delimiter
                    beq       PrintFmtResetOutPtr ; null = just reset pointer
                    lbsr      PutCharToWindow ; output newline/CR to window
PrintFmtResetOutPtr ldu       >PrintFmtBasePtr,pcr ; reload line buffer base
                    stu       >PrintFmtOutPtr,pcr ; reset output pointer to base
PrintFmtOutputCharRet puls      u,x       ; restore U and X
                    rts

*
*======================================================================
* PRIORITY COMMANDS
*   Implements set_priority, release_priority, get_priority, and
*   set_priority_v to fix or release an object's draw priority.
*======================================================================
*
cmd_set_priority    lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$26,u    ; load priority flags
                    ora       #$04      ; set fixed-priority flag
                    sta       <$26,u    ; store updated flags
                    lda       ,y+       ; fetch priority value from script
                    sta       <$24,u    ; store object priority
                    rts

cmd_release_priority lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$26,u    ; load priority flags
                    anda      #$FB      ; clear fixed-priority flag
                    sta       <$26,u    ; store updated flags
                    rts

cmd_get_priority    lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$24,u    ; get object's current priority
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch result var index
                    abx                 ; index into variable table
                    sta       ,x        ; store priority into variable
                    rts

cmd_set_priority_v  lda       ,y+       ; fetch object number from script
                    ldb       #$2B
                    mul                 ; multiply A*$2B for object array offset
                    addd      <$0030    ; add object table base
                    tfr       d,u       ; U = pointer to object struct
                    lda       <$26,u    ; load priority flags
                    ora       #$04      ; set fixed-priority flag
                    sta       <$26,u    ; store updated flags
                    ldx       #$0431    ; point to variable table
                    ldb       ,y+       ; fetch priority var index
                    abx                 ; index into variable table
                    lda       ,x        ; dereference priority variable
                    sta       <$24,u    ; store object priority
                    rts

*
*======================================================================
* RANDOM SEED AND GAME RESTART
*   InitRandSeed seeds the LCG random generator from the system clock;
*   cmd_restart_game reloads the initial logic, resets all state, and
*   optionally prompts the player before restarting.
*======================================================================
*
InitRandSeed        leas      -$09,s    ; allocate 9-byte local frame (F$Time buf)
                    clr       ,s        ; clear seed-loaded flag
                    ldd       <$008B    ; load current random seed
                    bne       ComputeRand ; seed already set, skip init
                    leax      $03,s     ; X = time buffer pointer
                    os9       F$Time    ; get current time
                    ldd       $07,s     ; get seconds field from time buffer
                    addd      $05,s     ; add minutes field
                    addd      $03,s     ; add hours field
                    orb       #$01      ; ensure seed is odd
                    std       <$008B    ; store as random seed
ComputeRand         lda       #$4D      ; LCG multiplier low byte
                    mul                 ; A * seed_high → D
                    std       $01,s     ; save partial product
                    ldb       <$008B    ; load seed low byte
                    lda       #$4D      ; LCG multiplier
                    mul                 ; A * seed_low → D
                    addd      ,s        ; add partial product
                    std       ,s        ; save combined product
                    lda       #$7C      ; LCG additive constant high
                    ldb       <$008C    ; load seed high byte
                    mul                 ; A * seed_high → D
                    addd      ,s        ; add to combined product
                    std       ,s        ; save LCG result
                    ldd       $01,s     ; load high word of result
                    addd      #$0001    ; increment (LCG constant = 1)
                    std       <$008B    ; store as new seed
                    eorb      <$008B    ; XOR with seed for result byte
                    leas      $09,s     ; release local frame
                    rts

StrRestartGame      fcc       /Press ENTER to start a new/
                    fcb       $0a
                    fcc       /game./
                    fcb       $0a,$0a
                    fcc       /Press CTRL-BREAK to continue/
                    fcb       $0a
                    fcc       /with this game./
                    fcb       0

cmd_restart_game    leas      -$01,s    ; save one byte for state flag
                    lbsr      InputEditOn ; enable input editing mode
                    lda       >$01B0    ; load game state flags
                    anda      #$80      ; test auto-restart flag
                    bne       RestartGameWithSave ; auto-restart, skip prompt
                    leau      >StrRestartGame,pcr ; point to restart prompt string
                    lbsr      message_box ; display restart confirmation
                    beq       RestartGameDone ; user cancelled
RestartGameWithSave lbsr      cmd_cancel_line ; cancel any pending input
                    lda       >$01AF    ; load display flags
                    anda      #$40      ; isolate score-display flag
RestartGameReload   sta       ,s        ; save score flag
                    lbsr      ResetHeap ; free all allocated memory
                    lbsr      LoadObjectData ; reload initial object data
                    lbsr      VolumesClose ; close all open volume files
                    lda       >$01AE    ; load game control flags
                    ora       #$02      ; set room-change flag
                    sta       >$01AE    ; store updated flags
                    lda       ,s        ; reload score flag
RestartGameSetFlags beq       RestartGameReset ; no score display, reset
                    lda       >$01AF    ; reload display flags
RestartGameSetScore ora       #$40      ; set score-display flag
                    sta       >$01AF    ; store updated flags
RestartGameReset    orcc      #$50      ; disable interrupts for timer reset
                    ldd       #$0000
                    std       >$0248    ; clear tick high word
                    std       >$024A    ; clear tick low word
                    andcc     #$AF      ; re-enable interrupts
                    ldb       <$006A    ; load initial logic number
                    beq       RestartGameLoadLogic ; zero = skip load
                    lbsr      AllocLoadLogic ; load initial logic script
RestartGameLoadLogic lbsr      EnableItemLoop ; re-enable all menu items
                    ldy       #$0000    ; reset script instruction pointer
RestartGameDone     lbsr      InputCursorBlink ; restore cursor blink state
                    leas      $01,s     ; release local frame
                    rts

StrRestoreGameMsg   fcc       /About to restore the game/
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
StrCantOpenFile     fcc       /Can't open file:/
                    fcb       $0a
                    fcc       /%s/
                    fcb       0
StrRestoreErr       fcc       /Error in restoring game./
                    fcb       $0a
                    fcc       /Press ENTER to quit./
                    fcb       $0a,0
StrContinueCancel   fcc       /Press ENTER to continue./
                    fcb       $0a
                    fcc       /Press CTRL-BREAK to cancel./
                    fcb       0
SaveFilePathNum     fcb       0

cmd_restore_game    leas      >-$00FD,s ; allocate 253-byte local frame
                    sty       ,s        ; save script instruction pointer
                    lda       #$01
                    sta       >$0102    ; set restore-in-progress flag
                    lda       >$0101    ; save current input state
                    sta       $02,s
                    lda       #$40
                    sta       >$0101    ; set input mode for restore
RestoreGameLoop     ldd       #$0072
                    pshs      b,a       ; push max save name length
                    lbsr      StateGetInfo ; get save slot selection from user
                    leas      $02,s     ; pop arg
                    tsta                ; test result
                    lbeq      rest_end  ; user cancelled
                    lda       >state_name_auto,pcr ; check auto-restore flag
                    bne       RestoreGameOpenFile ; auto = skip confirmation
                    leau      >StrContinueCancel,pcr ; "continue/cancel" button text
                    pshs      u         ; push button text
RestoreGameGetDesc  leau      >DataSaveGameBuf2,pcr ; point to save file path
RestoreGameShowMsg  pshs      u         ; push file path for format
                    leau      >DataSaveGameBuf,pcr ; point to save description
                    pshs      u         ; push description for format
                    leax      >StrRestoreGameMsg,pcr ; point to format string
                    leau      $09,s     ; point to args on stack
                    pshs      x         ; push format string
                    pshs      u         ; push args pointer
                    lbsr      PrintFmtStr ; format restore confirmation message
                    leas      $0A,s     ; pop format args
                    ldd       #$0000
                    pshs      b,a       ; push row=0 for message_box_draw
                    ldd       #$0023
                    pshs      b,a       ; push height=$23
                    ldd       #$0000
                    pshs      b,a       ; push col=0
                    pshs      u         ; push formatted message pointer
                    lbsr      message_box_draw ; draw confirmation dialog
                    leas      $08,s     ; pop message_box_draw args
                    lbsr      BooleanPoll ; wait for user response
                    cmpa      #$00      ; user pressed cancel?
                    lbeq      rest_end  ; user cancelled, done
RestoreGameOpenFile lda       #$01      ; open for read
                    leax      >DataSaveGameBuf2,pcr ; point to save file path
                    lbsr      OpenFile  ; open the save file
                    bcc       RestoreGameReadData ; opened ok
                    leau      >DataSaveGameBuf2,pcr ; point to file path for error msg
                    pshs      u         ; push file path
                    leau      >DataSaveGameBuf,pcr ; point to description
                    pshs      u         ; push description
                    leax      >StrCantOpenFile,pcr ; "Can't open file" format string
                    leau      $07,s     ; point to args
                    pshs      x         ; push format string
                    pshs      u         ; push args
                    lbsr      PrintFmtStr ; format error message
                    leas      $08,s     ; pop args
                    lbsr      message_box ; display error
                    lbra      rest_end
RestoreGameReadData sta       >SaveFilePathNum,pcr ; save file path number
                    clrb                ; B = 0 (high byte of seek offset)
                    ldx       #$0000    ; seek offset high word = 0
                    ldu       #$001F    ; seek to byte 31 (data start)
                    lbsr      SeekFile  ; seek to data start (offset $1F)
                    ldd       #$01AC
                    pshs      b,a       ; push count $01AC
                    lbsr      RestoreReadBlock ; read variable/flag block
                    leas      $02,s     ; pop count
                    beq       RestoreGameReadErr ; read failed
                    ldd       <$0030    ; get object table pointer
                    pshs      b,a       ; push for block read
                    lbsr      RestoreReadBlock ; read object data block
                    leas      $02,s     ; pop arg
                    beq       RestoreGameReadErr ; read failed
                    ldd       <$0038    ; get view object table pointer
                    pshs      b,a       ; push for block read
                    lbsr      RestoreReadBlock ; read view object block
                    leas      $02,s     ; pop arg
                    beq       RestoreGameReadErr ; read failed
                    ldx       <$0038    ; load view object table base
                    ldd       <$003A    ; get view object table size
                    leau      d,x       ; U = end of view object table
                    lbsr      XorDecrypt ; decrypt view object data
                    ldd       >$05AF    ; get logic table size
                    pshs      b,a       ; push for block read
                    lbsr      RestoreReadBlock ; read logic table block
                    leas      $02,s     ; pop arg
                    beq       RestoreGameReadErr ; read failed
                    ldd       #$0554    ; misc state block size = $554 bytes
                    pshs      b,a       ; push for block read
                    lbsr      RestoreReadBlock ; read misc state block
                    leas      $02,s     ; pop arg
                    bne       RestoreGameReadOk ; read ok, continue
RestoreGameReadErr  lda       >SaveFilePathNum,pcr ; get path number
                    lbsr      CloseFilePath ; close file
                    leau      >StrRestoreErr,pcr ; point to error message
                    lbsr      message_box ; display "error restoring"
                    lda       #$03      ; exit code 3 = fatal error
                    sta       <$0009    ; set quit-on-exit flag
                    ldx       <$0022    ; load exit routine pointer
                    jsr       >$0701    ; call exit via MMU twiddle
RestoreGameReadOk   lda       >SaveFilePathNum,pcr ; get path number
                    lbsr      CloseFilePath ; close save file
                    lda       >$0553    ; get saved score
                    sta       >$044B    ; restore score variable
                    lbsr      RestoreGameTables ; restore all game tables from save
                    lbsr      ClearInputBuffer ; clear keyboard input buffer
                    lda       >$01AF    ; load display flags
                    ora       #$08      ; set redraw-needed flag
                    sta       >$01AF    ; store updated flags
                    lbsr      VolumesClose ; close all volume files
                    ldd       #$0000
                    std       ,s        ; clear script pointer
                    lbsr      EnableItemLoop ; re-enable all menu items
rest_end            lbsr      cmd_close_window ; close any open message box
                    lda       $02,s     ; restore saved input state
                    sta       >$0101    ; write back input state
                    clr       >$0102    ; clear restore-in-progress flag
                    ldy       ,s        ; restore script instruction pointer
                    leas      >$00FD,s  ; release local frame
                    rts

RestoreReadBlock    leas      -$02,s    ; save 2 bytes on stack (byte count)
                    lda       >SaveFilePathNum,pcr ; get open file path number
                    leax      ,s        ; X = local stack buffer
                    ldy       #$0002    ; read 2 bytes (size word)
                    lbsr      ReadFile  ; read 2-byte block size
                    cmpd      #$0002    ; did we get exactly 2 bytes?
                    bne       RestoreReadBlockFail ; didn't read 2 bytes
                    ldy       ,x        ; Y = block size from file
                    sty       ,s        ; save expected size on stack
                    lda       >SaveFilePathNum,pcr ; get file path number
                    ldx       $04,s     ; get destination buffer pointer
                    lbsr      ReadFile  ; read block data
                    cmpy      ,s        ; compare bytes read to expected
                    bne       RestoreReadBlockFail ; size mismatch
                    lda       #$01      ; success
                    bra       RestoreReadBlockRet
RestoreReadBlockFail clra                ; failure
RestoreReadBlockRet leas      $02,s     ; release local frame
                    rts

RestoreGameTables   leas      >-$0206,s ; allocate 518-byte script replay buffer
                    leax      $06,s     ; X = start of script replay area
                    stx       $04,s     ; save script area pointer
                    lbsr      ResetGameTables ; reset all game state tables
                    clr       >$05B1    ; clear restore-complete flag
                    ldu       <$0030    ; load object table base
RestoreGameObjLoop  cmpu      <$0032    ; compare to object table end
                    bcc       RestoreGameObjDone ; past end, done
                    ldd       <$25,u    ; load object flags
                    ldx       $04,s     ; load script area write pointer
                    std       ,x++      ; save object flags to script area
                    stx       $04,s     ; update write pointer
                    bitb      #$40      ; test view-loaded flag
                    beq       RestoreGameObjNext ; not loaded, skip
                    andb      #$FE      ; clear draw-needed flag
                    orb       #$10      ; set needs-init flag
                    stb       <$26,u    ; update object flags
RestoreGameObjNext  leau      <$2B,u    ; advance to next object struct
                    bra       RestoreGameObjLoop
RestoreGameObjDone  lbsr      ClearBothRanges ; clear all rendering ranges
                    lbsr      ResetHeap ; reset heap to empty
                    clr       >$0100    ; clear pic-drawn flag
                    lbsr      ResetScriptPtrs ; reset script stack pointers
RestoreGameHeapLoop lbsr      PopScript ; pop next script entry
                    cmpu      #$0000
                    beq       RestoreGameHeapDone ; no more entries
                    ldd       ,u        ; load script type word
                    cmpa      #$00      ; script type 0 = logic?
                    bne       RestoreHeapType1 ; type 0 = logic
                    lbsr      AllocLoadLogic ; load logic (B = logic num)
                    lbsr      SeekLogicInList ; find in logic list
                    bra       RestoreGameHeapLoop
RestoreHeapType1    cmpa      #$01
                    bne       RestoreHeapType2 ; type 1 = view
                    lda       #$01
                    lbsr      view_load ; load view (B = view num)
                    bra       RestoreGameHeapLoop
RestoreHeapType2    cmpa      #$02
                    bne       RestoreHeapType3 ; type 2 = pic (load)
                    lbsr      LoadPicImpl ; load pic (B = pic num)
                    bra       RestoreGameHeapLoop
RestoreHeapType3    cmpa      #$03
                    bne       RestoreHeapType4 ; type 3 = sound
                    lbsr      LoadSoundData ; load sound (B = sound num)
                    bra       RestoreGameHeapLoop
RestoreHeapType4    cmpa      #$04
                    bne       RestoreHeapType5 ; type 4 = pic (draw)
                    lbsr      DrawPicImpl ; draw pic (B = pic num)
                    bra       RestoreGameHeapLoop
RestoreHeapType5    cmpa      #$05
                    bne       RestoreHeapType6 ; type 5 = add-to-pic
                    lbsr      PopScript ; pop second entry (view/loop params)
                    ldd       ,u        ; load view/loop word
                    ldx       #$05B2    ; point to add-to-pic param block
                    std       ,x        ; store view/loop
                    lbsr      PopScript ; pop third entry (cel/X params)
                    ldd       ,u
                    std       $02,x     ; store cel/X
                    lbsr      PopScript ; pop fourth entry (Y/priority params)
                    ldd       ,u
                    std       $04,x     ; store Y/priority
                    lbsr      AddToPicImpl ; execute add-to-pic
                    bra       RestoreGameHeapLoop
RestoreHeapType6    cmpa      #$06
                    bne       RestoreHeapType7 ; type 6 = discard pic
                    lbsr      DiscardPicImpl ; discard pic (B = pic num)
                    bra       RestoreGameHeapLoop
RestoreHeapType7    cmpa      #$07
                    bne       RestoreHeapType8 ; type 7 = discard view
                    lbsr      DiscardViewHelper ; discard view (B = view num)
                    bra       RestoreGameHeapLoop
RestoreHeapType8    cmpa      #$08
                    bne       RestoreGameHeapLoop ; type 8 = overlay pic
                    lbsr      pic_overlay ; overlay pic (B = pic num)
                    bra       RestoreGameHeapLoop
RestoreGameHeapDone lda       #$01
                    sta       >$05B1    ; set restore-complete flag
                    ldu       <$0032    ; load object table end pointer
RestoreGameViewLoop leau      <-$2B,u   ; back up to previous object
                    cmpu      <$0030    ; compare to object table base
                    bcs       RestoreGameViewDone ; below base, done
                    ldx       $04,s     ; load script replay read pointer
                    ldd       ,--x      ; read saved object flags (pre-decrement)
                    stx       $04,s     ; update read pointer
                    std       ,s        ; save flags on stack
                    stu       $02,s     ; save object pointer
                    ldb       $05,u     ; get view number for this object
                    lbsr      view_find ; find view in list
                    leax      ,x        ; transfer X to itself (NOP - test zero)
                    beq       RestoreGameViewCheck ; view not found, skip setup
                    ldb       $05,u     ; reload view number
                    lbsr      SetViewForObj ; configure view data for object
RestoreGameViewCheck ldd       ,s        ; reload saved flags
                    bitb      #$40      ; test view-loaded flag
                    beq       RestoreGameViewLoop ; not loaded, skip
                    bitb      #$01      ; test draw-needed flag
                    beq       RestoreGameViewNext ; not needed, skip draw
                    lda       $02,u     ; get object number from struct
                    lbsr      DrawObjHelper ; draw object to render buffer
                    ldu       $02,s     ; restore object pointer
                    lda       <$22,u    ; get motion type
                    cmpa      #$02      ; motion type 2 = move-to-point
                    bne       RestoreGameViewFlags ; not move-to-point
                    lda       #$FF
                    sta       <$29,u    ; mark destination reached
RestoreGameViewFlags ldd       ,s        ; reload saved flags
                    bitb      #$10      ; test stop-update flag
                    bne       RestoreGameViewNext ; flagged, skip
                    lbsr      StopUpdateHelper ; stop object motion update
                    ldu       $02,s     ; restore object pointer
                    ldd       ,s        ; reload saved flags
RestoreGameViewNext std       <$25,u    ; restore object flags from save
                    bra       RestoreGameViewLoop ; process previous object
RestoreGameViewDone lbsr      InputEditOn ; enable input editing
                    lbsr      cmd_cancel_line ; clear pending input
                    lbsr      gfx_picbuff_update ; blit render buffer to screen
                    lda       #$01
                    sta       >$0100    ; mark pic as shown
                    lbsr      StatusLineWrite ; redraw status line
                    lbsr      InputRedraw ; redraw input line
                    leas      >$0206,s  ; release local frame
                    rts

*
*======================================================================
* VIEW ENTRY ALLOCATION
*   Allocates a render-buffer node for a view object and calculates its
*   priority coordinate; used by draw_obj and show_obj to place sprites
*   on screen.
*======================================================================
*
AllocViewEntry      ldd       #$000E    ; allocate 14-byte view entry node
                    lbsr      AllocDataBlock
                    ldd       #$0000
                    std       ,u        ; clear next pointer
                    std       $02,u     ; clear prev pointer
                    stx       $04,u     ; store view object pointer
                    stu       <$16,x    ; link view entry into object
                    ldd       <$1C,x    ; get cel dimensions word
                    std       $08,u     ; store in view entry
                    ldd       $03,x     ; get loop/cel flags
                    bita      #$01      ; test odd-height flag
                    beq       AllocViewEntrySize ; even height, skip
                    deca                ; adjust height
                    inc       $08,u     ; update cel height in entry
AllocViewEntrySize  subb      <$1D,x    ; subtract cel width
                    incb                ; add 1
                    std       $06,u     ; store width and height in entry
                    ldd       $08,u     ; reload dimensions
                    bita      #$01      ; test odd-width flag
                    beq       AllocViewEntryAlloc ; even, proceed
                    inca                ; round up height
                    sta       $08,u     ; update height
AllocViewEntryAlloc mul                 ; A*B = total pixels
                    tfr       u,x       ; X = view entry pointer
                    lbsr      AllocHeap ; allocate pixel buffer
                    lbsr      CalcPriCoord ; calculate priority coordinate
                    std       $0C,x     ; store priority coord in entry
                    stu       $0A,x     ; store pixel buffer pointer
                    tfr       x,u       ; U = view entry pointer
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
cmd_set_simple      lda       ,y+       ; fetch save slot index from script
                    ldb       #$28      ; size of save name entry = 40
                    mul                 ; A*40 = slot offset
                    ldx       #$251     ; save name table base
                    leax      d,x       ; X = pointer to this slot's name
                    leau      >state_name_auto,pcr ; point to auto-save name
                    ldd       #$001F    ; copy 31 bytes
                    lbsr      MemCopyNull ; copy auto name to slot
                    rts

cmd_save_game       leas      >-$00FE,s ; allocate 254-byte local frame
                    sty       ,s        ; save script instruction pointer
                    clr       $02,s     ; clear XOR-applied flag
                    lda       #$01
                    sta       >$0102    ; set save-in-progress flag
                    lda       >$0101    ; save current input state
                    sta       $03,s
                    lda       #$40      ; input mode: save game active
                    sta       >$0101    ; set input mode for save
                    ldd       #$0073
                    pshs      b,a       ; push max save name length
SaveGameLoop        lbsr      StateGetInfo ; get save slot from user
                    leas      $02,s     ; pop arg
                    tsta                ; test result
                    lbeq      SaveGameDone ; user cancelled
SaveGameCheck       lda       >state_name_auto,pcr ; check auto-save flag
                    bne       SaveGameCreateFile ; auto = skip confirmation
SaveGameShowMsg     leau      >StrContinueCancel,pcr ; "continue/cancel" button text
                    pshs      u         ; push button text
                    leau      >DataSaveGameBuf2,pcr ; point to save file path
                    pshs      u         ; push file path
                    leau      >DataSaveGameBuf,pcr ; point to save description
                    pshs      u         ; push description
                    leax      >StrSaveGameMsg,pcr ; point to format string
                    leau      $0A,s     ; point to args on stack
                    pshs      x         ; push format string
                    pshs      u         ; push args
                    lbsr      PrintFmtStr ; format save confirmation message
                    leas      $0A,s     ; pop format args
                    ldd       #$0000    ; row = 0 (top of screen)
                    pshs      b,a       ; push row=0
                    ldd       #$0023    ; height = $23 (dialog box height)
                    pshs      b,a       ; push height=$23
                    ldd       #$0000    ; column = 0 (left edge)
                    pshs      b,a       ; push col=0
                    pshs      u         ; push formatted message pointer
                    lbsr      message_box_draw ; draw save confirmation dialog
                    leas      $08,s     ; pop args
                    lbsr      BooleanPoll ; wait for user response
                    cmpa      #$00      ; user pressed cancel?
                    lbeq      SaveGameDone ; user cancelled
SaveGameCreateFile  lda       #$02      ; create mode
                    ldb       #$03      ; attributes
                    leax      >DataSaveGameBuf2,pcr ; point to save file path
                    lbsr      CreateFile ; create the save file
                    bcc       SaveGameWriteData ; created ok
                    leau      >SaveDiskNameBuf,pcr ; point to directory name
                    pshs      u         ; push directory name
                    leax      >StrDirFullMsg,pcr ; "directory is full" format
                    leau      $06,s     ; point to args
                    pshs      x         ; push format string
                    pshs      u         ; push args
                    lbsr      PrintFmtStr ; format error message
                    leas      $06,s     ; pop args
                    lbsr      message_box ; display error
                    lbra      SaveGameDone
SaveGameWriteData   sta       >SaveFileHandle,pcr ; save file path number
                    leax      >DataSaveGameBuf,pcr ; point to save description
                    ldy       #$001F    ; write 31 bytes
                    lbsr      WriteFile ; write save description header
                    cmpd      #$001F
                    bne       SaveGameWriteErr ; write failed
                    ldd       #$0385    ; size of variable/flag block
                    pshs      b,a       ; push size
                    ldd       #$01AC    ; pointer to variable/flag block
                    pshs      b,a       ; push pointer
                    lbsr      SaveWriteBlock ; write block with size prefix
                    leas      $04,s     ; pop args
                    beq       SaveGameWriteErr ; write failed
                    ldd       <$0034    ; get object table end
                    pshs      b,a       ; push end pointer
                    ldd       <$0030    ; get object table base
                    pshs      b,a       ; push base pointer
                    lbsr      SaveWriteBlock ; write object data block
                    leas      $04,s
                    beq       SaveGameWriteErr ; write failed
                    inc       $02,s     ; set XOR-applied flag
                    ldx       <$0038    ; load view object table base
                    ldd       <$003A    ; get view object table size
                    leau      d,x       ; U = end of view table
                    lbsr      XorDecrypt ; encrypt view object data
                    ldd       <$003A    ; get size
                    pshs      b,a       ; push size
                    ldd       <$0038    ; get base pointer
                    pshs      b,a       ; push pointer
                    lbsr      SaveWriteBlock ; write view object block
                    leas      $04,s
                    beq       SaveGameWriteErr ; write failed
                    lda       >$0245    ; get logic count
                    ldb       #$02
                    mul                 ; A*2 = logic table byte count
                    pshs      b,a       ; push count
                    ldd       >$05AF    ; get logic table pointer
                    pshs      b,a       ; push pointer
                    lbsr      SaveWriteBlock ; write logic table block
                    leas      $04,s
                    beq       SaveGameWriteErr ; write failed
                    lbsr      BuildLogicList ; build logic list for save
                    pshs      x         ; push logic list pointer
                    ldd       #$0554
                    pshs      b,a       ; push misc state block size
                    lbsr      SaveWriteBlock ; write misc state block
                    leas      $04,s
                    bne       SaveGameWriteOk ; write ok
SaveGameWriteErr    lda       >SaveFileHandle,pcr ; get file path number
                    lbsr      CloseFilePath ; close save file
                    leax      >DataSaveGameBuf2,pcr ; point to save file path
                    lbsr      DeleteFile ; delete incomplete save file
                    leau      >StrDiskFullMsg,pcr ; "disk is full" message
                    lbsr      message_box ; display error
                    bra       SaveGameDone
SaveGameWriteOk     lda       >SaveFileHandle,pcr ; get file path number
                    lbsr      CloseFilePath ; close save file
SaveGameDone        lda       $02,s     ; check XOR-applied flag
                    beq       SaveGameXorDone ; not applied, skip
                    ldx       <$0038    ; load view object table base
                    ldd       <$003A    ; get size
                    leau      d,x       ; U = end of view table
                    lbsr      XorDecrypt ; decrypt back to original
SaveGameXorDone     lbsr      cmd_close_window ; close any open message box
                    lda       $03,s     ; restore saved input state
                    sta       >$0101
                    clr       >$0102    ; clear save-in-progress flag
                    ldy       ,s        ; restore script instruction pointer
                    leas      >$00FE,s  ; release local frame
                    rts

SaveWriteBlock      lda       >SaveFileHandle,pcr ; get save file path number
                    leax      $04,s     ; X = pointer to size word on stack
                    ldy       #$0002    ; write 2-byte size prefix
                    lbsr      WriteFile ; write block size
                    cmpd      #$0002
                    bne       SaveWriteBlockFail ; didn't write 2 bytes
                    lda       >SaveFileHandle,pcr ; reload file path number
                    ldx       $02,s     ; get data pointer from stack
                    ldy       $04,s     ; get byte count from stack
                    lbsr      WriteFile ; write block data
                    cmpd      $04,s     ; compare bytes written to count
                    bne       SaveWriteBlockFail ; count mismatch
                    lda       #$01      ; success
                    bra       SaveWriteBlockRet
SaveWriteBlockFail  clra                ; failure
SaveWriteBlockRet   rts

SaveDriveNum        fcb       0
StrSaveFmtFile      fcc       /%s%s%ssg.%d/
                    fcb       0

BuildSaveFilePath   leas      -5,s      ; allocate 5-byte local frame
                    stx       ,s        ; save output buffer pointer
                    stb       2,s       ; save slot number
                    ldd       #0
                    std       3,s       ; clear slash and padding
                    leax      $1801,pcr ; point to saved directory path
                    lbsr      StrLen    ; get length of path
                    decb                ; point to last char
                    leax      b,x       ; X = last char of path
                    lda       #$2F      ; '/' separator
                    cmpa      ,-x       ; check if path ends with '/'
                    beq       BuildSaveFilePathFmt ; already has separator
                    sta       $03,s     ; store '/' as separator
BuildSaveFilePathFmt clra                ; zero high byte for slot number
                    ldb       $02,s     ; reload slot number
                    pshs      b,a       ; push slot number for format
                    ldd       #$01CE    ; point to save name table entry
                    pshs      b,a       ; push save name pointer
                    leax      $07,s     ; X = saved directory path pointer
                    pshs      x         ; push directory path
                    leax      >SaveDiskNameBuf,pcr ; point to disk name buffer
                    pshs      x         ; push disk name
                    leax      >StrSaveFmtFile,pcr ; "%s%s%ssg.%d" format string
                    ldu       $08,s     ; U = output buffer pointer
                    pshs      x         ; push format string
                    pshs      u         ; push output buffer
                    lbsr      PrintFmtStr ; format: "diskname/dir/sg.N"
                    leas      $0C,s     ; pop format args
                    lbsr      StrToLower ; convert filename to lowercase
                    tfr       u,x       ; X = output buffer pointer
                    leas      $05,s     ; release local frame
                    rts
GetDiskInfo         leas      <-$45,s   ; allocate 69-byte local frame
                    clr       ,s        ; clear disk-found flag
                    leau      ,s        ; U = pointer to local buffer
                    lbsr      FindCurrentDisk ; find and identify current disk
                    ldx       <$47,s    ; load saved directory handle
                    lbsr      ChangeDir ; change to save directory
                    bcs       GetDiskInfoFail ; failed to change dir
                    clr       <$40,s    ; clear disk name buffer
                    leau      <$40,s    ; U = disk name buffer
                    lbsr      GetDiskName ; read disk name into buffer
GetDiskInfoFound    ldb       <$43,s    ; get drive number from buffer
                    stb       >SaveDriveNum,pcr ; store current save drive number
                    lda       #$01      ; success
                    bra       GetDiskInfoRet
GetDiskInfoFail     clra                ; failure
GetDiskInfoRet      sta       <$44,s    ; store result flag
                    leax      ,s        ; X = local buffer (has saved dir)
                    lbsr      ChangeDir ; restore previous directory
                    lda       <$44,s    ; reload result flag
                    leas      <$45,s    ; release local frame
                    rts

*
*======================================================================
* LOGIC SCRIPT EXECUTOR
*   Runs a compiled AGI logic script from its bytecode start, handling
*   if/else blocks, jump offsets, and dispatching each command opcode.
*======================================================================
*
ExecLogicScript     leas      -$02,s    ; allocate 2-byte local frame (if-state)
                    ldy       <$0062    ; load current logic pointer
                    ldd       $04,y     ; get logic page from logic slot
                    lbsr      SetLogicPage ; switch to logic's page
                    ldy       $08,y     ; load pointer to logic bytecode
ExecScriptLoop      ldb       ,y+       ; fetch next opcode
ExecScriptCheck     tstb                ; test opcode
                    beq       ExecScriptDone ; opcode $00 = end of script
                    cmpb      #$FF
                    beq       ExecScriptIf ; opcode $FF = if block
                    cmpb      #$FE
                    bne       ExecScriptCmd ; not a jump
ExecScriptJump      ldb       ,y+       ; fetch jump offset high byte
                    lda       ,y+       ; fetch jump offset low byte
                    leay      d,y       ; apply offset to Y
                    bra       ExecScriptLoop
ExecScriptCmd       lbsr      DispatchCmd ; dispatch command opcode
                    leay      ,y        ; test Y (dispatch result)
                    bne       ExecScriptCheck ; non-null = more to process
ExecScriptDone      bra       ExecLogicScriptRet
ExecScriptIf        ldd       #$0000
                    std       ,s        ; clear if-state (not-flag, depth)
ExecScriptIfLoop    lda       ,y+       ; fetch condition byte
                    cmpa      #$FC
                    bhi       ExecScriptIfHi ; $FD/$FE/$FF are control bytes
                    bne       ExecScriptEvalExpr ; non-$FC = condition to evaluate
                    lda       ,s        ; load not-flag
                    bne       ExecScriptSkipBlock ; not-flag set = skip block
                    inc       ,s        ; set not-flag
                    bra       ExecScriptIfLoop
ExecScriptIfHi      cmpa      #$FF
                    bne       ExecScriptIfFD ; not $FF
                    leay      $02,y     ; skip 2-byte jump target
                    bra       ExecScriptLoop ; return to main loop
ExecScriptIfFD      cmpa      #$FD
                    bne       ExecScriptEvalExpr ; not $FD
                    lda       $01,s     ; load NOT-accumulator
                    eora      #$01      ; toggle NOT flag
                    sta       $01,s     ; store updated NOT flag
                    bra       ExecScriptIfLoop
ExecScriptEvalExpr  lbsr      EvalExpr  ; evaluate condition expression
                    eora      $01,s     ; XOR with NOT flag
                    clr       $01,s     ; clear NOT flag for next use
                    tsta                ; test result
                    bne       ExecScriptTrueBlock ; condition true
                    lda       ,s        ; load not-flag
                    bne       ExecScriptIfLoop ; not-flag still set
ExecScriptSkipBlock clr       ,s        ; clear not-flag
ExecScriptSkipLoop  lda       ,y+       ; scan through skipped block
                    cmpa      #$FF
                    beq       ExecScriptJump ; $FF = end of if block (with jump)
                    cmpa      #$FC
                    bcc       ExecScriptSkipLoop ; $FC/$FD/$FE = control bytes, skip
                    bsr       ExecScriptExecCmd ; execute command (to skip args)
                    bra       ExecScriptSkipLoop
ExecScriptTrueBlock lda       ,s        ; load not-flag
                    beq       ExecScriptIfLoop ; not set, execute block
                    clr       ,s        ; clear not-flag
ExecScriptTrueLoop  lda       ,y+       ; fetch next byte in true block
                    cmpa      #$FC
                    bhi       ExecScriptTrueLoop ; $FD/$FE/$FF = skip
                    beq       ExecScriptIfLoop ; $FC = end of if block
                    bsr       ExecScriptExecCmd ; execute command
                    bra       ExecScriptTrueLoop
ExecScriptExecCmd   cmpa      #$0E
                    bne       ExecScriptExecCmdImpl ; not cmd $0E (return)
                    lda       ,y+       ; fetch return target offset
                    lsla                ; multiply by 2
                    leay      a,y       ; apply offset
                    rts

ExecScriptExecCmdImpl lsla                ; multiply cmd by 2
                    lsla                ; multiply by 2 again (*4)
                    adda      #$02      ; add 2 for command dispatch table base
                    leax      >eval_table,pcr ; point to command dispatch table
                    lda       a,x       ; load relative offset for this command
                    leay      a,y       ; advance Y past command arguments
                    rts
ExecLogicScriptRet  leas      $02,s     ; release if-state local frame
                    rts

PaletteData         fcb       $00       composite
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

                    fcb       $00       rgb
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

*
*======================================================================
* SCREEN AND TEXT CONFIGURATION
*   Switches between text and graphics screen modes, sets palette
*   colors, and manages text/graphics screen attributes.
*======================================================================
*
cmd_text_screen     lbsr      InputEditOn ; enable input editing mode
                    lda       #1
                    sta       $5EC      ; set text-screen mode flag
                    lda       #$15
                    sta       <$0019    ; set MMU page for text mode switch
                    ldx       <$0026    ; load text mode routine pointer
                    jsr       >$0701    ; call MMU twiddle text mode
                    rts

cmd_graphics        lbsr      InputEditOn ; enable input editing mode
                    lbsr      SetGraphicsMode ; switch to graphics mode
                    rts

cmd_clear_lines     ldb       $02,y     ; fetch line count from script
                    pshs      b,a       ; push for ClearTextRows
                    ldb       $01,y     ; fetch end line from script
                    pshs      b,a       ; push for ClearTextRows
                    ldb       ,y        ; fetch start line from script
                    pshs      b,a       ; push for ClearTextRows
                    lbsr      ClearTextRows ; clear rows start..end
                    leas      $06,s     ; pop args
                    leay      $03,y     ; advance past 3 script args
                    rts

* clear text rect (fixed)
cmd_clear_text_rect ldb       $04,y     ; fetch color from script
                    pshs      b,a       ; push color
                    ldb       $03,y     ; fetch row count from script
                    lda       $02,y     ; fetch bottom row from script
                    pshs      b,a       ; push row count and bottom row
                    ldb       $01,y     ; fetch right column from script
                    lda       ,y        ; fetch top row from script
                    pshs      b,a       ; push right column and top row
                    lbsr      ClearTextRect ; clear the specified text rectangle
                    leas      $06,s     ; pop three pushed argument pairs
                    leay      $05,y     ; advance past 5 script args
                    rts

                    fcb       0,0,0,0   * to keep same code length

cmd_set_text_attribute ldd       ,y++      ; fetch foreground/background color pair
                    bsr       text_color ; set text colors
                    rts

text_color          anda      #$0F      ; isolate foreground color nibble
                    sta       >$024C    ; store foreground color
                    lsla                ; shift foreground to high nibble (bit 3)
                    lsla                ; shift left (bit 2)
                    lsla                ; shift left (bit 1)
                    lsla                ; foreground now in high nibble of A
                    ora       >$024C    ; OR with stored foreground (packed nibbles)
                    sta       >$024C    ; store packed foreground color byte
                    andb      #$0F      ; isolate background color nibble
                    stb       >$024D    ; store background color
                    lslb                ; shift background to high nibble (bit 3)
                    lslb                ; shift left (bit 2)
                    lslb                ; shift left (bit 1)
                    lslb                ; background now in high nibble of B
                    orb       >$024D    ; OR with stored background (packed nibbles)
                    stb       >$024D    ; store packed background color byte
                    rts

SetGraphicsMode     lda       #$00
                    sta       >$05EC    ; clear text-screen flag
                    lda       #$09
                    sta       <$0019    ; set MMU page for graphics mode
                    ldx       <$0026    ; load graphics mode routine pointer
                    jsr       >$0701    ; call MMU twiddle graphics mode
                    lbsr      StatusLineWrite ; redraw status line
                    lbsr      InputRedraw ; redraw input line
                    rts

cmd_config_screen   lda       ,y        ; fetch scroll-X offset (peek)
                    sta       >$0241    ; store scroll offset
                    adda      #$15      ; add to get right edge column
                    sta       >$023F    ; store right edge
                    lda       ,y+       ; consume scroll-X and advance
                    ldb       #$08
                    mul                 ; A*8 = pixel width per column
                    lda       #$A0      ; $A0 = number of pixel columns
                    mul                 ; calculate screen stride
                    std       <$002C    ; store screen line stride
                    lda       ,y+       ; fetch monitor type from script
                    sta       >$01D7    ; store monitor type
                    lda       ,y+       ; fetch display flags from script
                    sta       >$0247    ; store display flags
                    rts

cmd_toggle_monitor  leas      -$04,s    ; allocate 4-byte local frame
                    pshs      y         ; save script pointer
                    leax      >PaletteData,pcr ; point to palette table
                    ldb       >$0553    ; get current monitor mode
                    eorb      #$01      ; toggle between composite and RGB
                    stb       >$0553    ; store new mode
                    lda       #$10      ; 16 entries per palette
                    mul                 ; A*16 = palette offset
                    abx                 ; X = pointer to selected palette
                    lda       #$1B
                    sta       $02,s     ; ESC char for palette command
                    lda       #$31
                    sta       $03,s     ; '1' palette command byte
                    clra                ; A = 0 (initial color index)
                    sta       $04,s     ; color index start = 0
                    ldy       #$0004    ; path number 4 (screen)
PaletteWriteLoop    ldb       ,x+       ; fetch palette entry
                    stb       $05,s     ; store for write
                    pshs      x         ; save palette pointer
                    lda       #$01      ; write 1 byte
                    leax      $04,s     ; X = pointer to color byte
                    os9       I$Write   ; write palette command byte
                    bcs       PaletteWriteRet ; write failed
                    puls      x         ; restore palette pointer
                    inc       $04,s     ; increment color index
                    lda       $04,s     ; load color index
                    cmpa      #$10      ; compare to 16 (all colors)
                    bcs       PaletteWriteLoop ; not done, continue
PaletteWriteRet     puls      y         ; restore script pointer
                    leas      $04,s     ; release local frame
                    rts

*
*======================================================================
* TEXT COLOR STACK AND SCRIPT BUFFER
*   PushTextColor and PopTextColor maintain a small color stack so
*   nested message boxes can restore the previous text color; the
*   script-buffer routines (InitScriptBuf, PushScript, PopScript,
*   ResetScriptPtrs, cmd_script_size, cmd_push_script, cmd_pop_script)
*   manage a circular replay buffer for input-echo scripting.
*======================================================================
*
PushTextColor       ldb       >$0171    ; get current color stack depth
                    cmpb      #$05
                    bcc       PushTextColorRet ; stack full (5 entries)
                    ldx       #$015C    ; point to color stack base
                    lslb                ; multiply depth by 2
                    abx                 ; index to current top
                    ldd       >$024C    ; load current text color pair
                    std       ,x        ; save to color stack
                    inc       >$0171    ; increment stack depth
PushTextColorRet    rts

PopTextColor        ldb       >$0171    ; get current color stack depth
                    ble       PopTextColorRet ; stack empty
                    decb                ; decrement depth
                    stb       >$0171    ; store new depth
                    ldx       #$015C    ; point to color stack base
                    lslb                ; multiply depth by 2
                    ldd       b,x       ; load saved color pair from stack
                    std       >$024C    ; restore text color pair
PopTextColorRet     rts

ScriptWritePtr      fdb       0
ScriptReadPtr       fdb       0

InitScriptBuf       ldu       >$05AF    ; load script buffer pointer
                    bne       InitScriptBufRet ; already allocated
                    lda       >$0245    ; get script slot count
                    beq       InitScriptBufRet ; zero slots, nothing to do
                    ldb       #$02
                    mul                 ; A*2 = total bytes needed
                    lbsr      AllocDataBlock ; allocate script buffer
                    stu       >$05AF    ; store script buffer pointer
                    ldd       <$0055    ; get heap free pointer
                    std       <$0053    ; save as script buffer end
InitScriptBufRet    stu       >ScriptWritePtr,pcr ; init write pointer to buffer start
                    clr       >$0244    ; clear script slot count
                    rts

PushScript          leas      -$02,s    ; save 2 bytes on stack
                    std       ,s        ; save value to push
                    lda       >$01AE    ; load game control flags
                    anda      #$01      ; test restore-in-progress flag
                    bne       PushScriptRet ; during restore, skip actual push
                    lda       >$05B1    ; load restore-complete flag
                    beq       PushScriptUpdate ; not complete, just update pointer
                    clra                ; A = 0 (high byte for 16-bit shift)
                    ldb       >$0245    ; get max script entries
                    lslb                ; multiply by 2
                    rola                ; 16-bit shift: D = max*2
                    addd      >$05AF    ; add buffer base = end of buffer
                    cmpd      >ScriptWritePtr,pcr ; compare to write pointer
                    bhi       PushScriptStore ; space available
                    lda       #$0B
                    ldb       <$0058    ; get current logic number
                    lbsr      ReportError ; report "script overflow" error
PushScriptStore     ldu       >ScriptWritePtr,pcr ; load write pointer
                    ldd       ,s        ; reload value to push
                    std       ,u++      ; store and advance write pointer
                    stu       >ScriptWritePtr,pcr ; update write pointer
                    inc       >$0244    ; increment slot count
PushScriptUpdate    ldd       >ScriptWritePtr,pcr ; load current write pointer
                    subd      >$05AF    ; subtract buffer base = used bytes
                    cmpd      <$0057    ; compare to max used
                    bls       PushScriptRet ; not a new high-water mark
                    std       <$0057    ; update high-water mark
PushScriptRet       leas      $02,s     ; release local frame
                    rts

ResetScriptPtrs     ldd       >$05AF    ; load script buffer pointer
                    std       >ScriptReadPtr,pcr ; reset read pointer to start
                    lda       >$0244    ; get current slot count
                    ldb       #$02
                    mul                 ; A*2 = bytes used by saved entries
                    addd      >$05AF    ; add buffer base
                    std       >ScriptWritePtr,pcr ; set write pointer to end of saved data
                    rts

PopScript           ldu       #$0000    ; default return null
                    ldd       >ScriptReadPtr,pcr ; load current read pointer
                    cmpd      >ScriptWritePtr,pcr ; compare to write pointer
                    bcc       PopScriptRet ; read >= write, buffer empty
                    tfr       d,u       ; U = pointer to current entry
                    addd      #$0002    ; advance read pointer by 2
                    std       >ScriptReadPtr,pcr ; store updated read pointer
PopScriptRet        rts

cmd_script_size     lda       ,y+       ; fetch script slot count from script
                    sta       >$0245    ; store new script size
                    lbsr      ClearBothRanges ; clear rendering ranges
                    lbsr      InitScriptBuf ; initialize script buffer
                    lbsr      SwapObjRanges ; swap ranges back
                    rts
cmd_push_script     lda       >$0244    ; get current script slot count
                    sta       >$0243    ; save as checkpoint
                    rts

cmd_pop_script      clra                ; zero high byte
                    ldb       >$0243    ; get saved checkpoint count
                    stb       >$0244    ; restore script slot count
                    lslb                ; multiply by 2
                    rola                ; 16-bit shift: D = checkpoint*2
                    addd      >$05AF    ; add buffer base
                    std       >ScriptWritePtr,pcr ; restore write pointer to checkpoint
                    rts

*
*======================================================================
* TEXT WINDOW OUTPUT
*   PutCharToWindow writes a character to the current text window with
*   word-wrap and scroll; PushRowCol/PopRowCol save and restore the
*   cursor position; ClearTextLine, ClearTextRows, DrawTextRect, and
*   ClearTextRect erase regions of the text screen.
*======================================================================
*
PutCharToWindow     leas      -$02,s    ; allocate 2-byte local frame
                    pshs      u,x       ; save U and X
                    leau      $04,s     ; U = cursor position pointer
                    tsta                ; test character
                    beq       PutCharRet ; null = done
                    cmpa      #$08      ; check for backspace
                    bne       PutCharCheckCR
                    dec       <$0041    ; decrement column
                    bpl       PutCharBackspace ; still on same row
                    lda       #$00
                    sta       <$0041    ; clamp column to 0
                    lda       <$0040    ; load current row
                    cmpa      #$15      ; compare to top of window
                    bls       PutCharBackspace ; at top, can't go up
                    deca                ; go up one row
                    sta       <$0040    ; store new row
                    lda       #$27
                    sta       <$0041    ; set column to end of row (39)
PutCharBackspace    ldd       #$2000    ; space character + clear attr
                    std       ,u        ; store space at cursor
                    pshs      u         ; push cursor pointer
                    lda       #$0F
                    sta       <$0019    ; set MMU page for char write
                    ldx       <$0026    ; load char write routine pointer
                    jsr       >$0701    ; call MMU twiddle write char
                    leas      $02,s     ; pop cursor pointer
                    dec       <$0041    ; move cursor back one more
                    bra       PutCharRet
PutCharCheckCR      cmpa      #$0D
                    beq       PutCharNewLine ; CR = newline
                    cmpa      #$0A
                    bne       PutCharNormal ; not LF
PutCharNewLine      lda       <$0040    ; load current row
                    cmpa      #$17      ; compare to max row (23)
                    bcc       PutCharSetCol ; at bottom, don't scroll
                    inca                ; advance to next row
                    sta       <$0040    ; store new row
PutCharSetCol       lda       >$017A    ; get saved top-of-window column
                    sta       <$0041    ; restore column to window start
                    bra       PutCharRet
PutCharNormal       clrb                ; attribute byte = 0
                    cmpa      #$7F      ; check for delete/invalid
                    bls       PutCharWriteScr ; printable, write it
                    ldd       #$2000    ; replace with space
PutCharWriteScr     std       ,u        ; store char+attr at cursor
                    pshs      u         ; push cursor pointer
                    lda       #$0F
                    sta       <$0019    ; set MMU page for char write
                    ldx       <$0026    ; load char write routine pointer
                    jsr       >$0701    ; call MMU twiddle write char
                    leas      $02,s     ; pop cursor pointer
                    lda       <$0041    ; load current column
                    cmpa      #$27      ; compare to max column (39)
                    bls       PutCharRet ; within window, done
                    lda       #$0D      ; wrap: emit CR for newline
                    bsr       PutCharToWindow ; recursive newline
PutCharRet          puls      u,x       ; restore U and X
                    leas      $02,s     ; release local frame
                    rts

PushRowCol          ldb       >$0166    ; get current row/col stack depth
                    cmpb      #$05
                    bcc       PushRowColRet ; stack full (5 entries)
                    ldx       #$0167    ; point to row/col stack base
                    lslb                ; multiply depth by 2
                    abx                 ; index to current top
                    ldd       <$0040    ; load current row/col
                    std       ,x        ; save to stack
                    inc       >$0166    ; increment stack depth
PushRowColRet       rts

PopRowCol           ldb       >$0166    ; get current row/col stack depth
                    ble       PopRowColRet ; stack empty
                    decb                ; decrement depth
                    stb       >$0166    ; store new depth
                    ldx       #$0167    ; point to row/col stack base
                    lslb                ; multiply depth by 2
                    ldd       b,x       ; load saved row/col from stack
                    std       <$0040    ; restore cursor row/col
PopRowColRet        rts

ClearTextLine       pshs      b,a       ; save A (row number)
                    tfr       a,b       ; copy row to B
                    pshs      b,a       ; push row as both args
                    pshs      b,a       ; push row as start row
                    lbsr      ClearTextRows ; clear one row
                    leas      $06,s     ; pop args
                    rts

ClearTextRows       ldb       $07,s     ; get row count from caller
                    pshs      b,a       ; push count
                    lda       $07,s     ; get start row from caller
                    ldb       #$27      ; right column = 39
                    pshs      b,a       ; push row + right col
                    lda       $07,s     ; get start row from caller
                    ldb       #$00      ; left column = 0
                    pshs      b,a       ; push row + left col
                    lbsr      ClearTextRect ; clear specified rows
                    leas      $06,s     ; pop args
                    rts

DrawTextRect        leas      <-$2A,s   ; allocate 42-byte local frame
                    lda       #$17      ; max row = 23
                    cmpa      <$2D,s    ; compare to top row arg
                    lbcs      DrawTextRectRet ; start row out of range
                    cmpa      <$2F,s    ; compare to bottom row arg
                    bcc       DrawTextRectClipRow ; in range
                    sta       <$2F,s    ; clip bottom to max row
                    inca                ; +1 for inclusive row count
                    suba      <$2D,s    ; row count = clipped bottom - top + 1
                    cmpa      <$37,s    ; compare to requested row count
                    bcc       DrawTextRectClipRow ; count ok
                    sta       <$37,s    ; clip row count
DrawTextRectClipRow ldb       <$37,s    ; load row count
                    beq       DrawTextRectDoRows ; zero rows, check fill
                    negb                ; negate
                    incb                ; +1 = 1's complement + 1
                    addb      <$2F,s    ; add bottom row
                    subb      <$2D,s    ; subtract top row
                    bhi       DrawTextRectFill ; positive = fill needed
                    clr       <$37,s    ; clear row count (no fill)
                    bra       DrawTextRectDoRows
DrawTextRectFill    lda       <$37,s    ; load row count
                    pshs      b,a       ; push fill params
                    lda       <$37,s    ; reload row count
                    ldb       <$35,s    ; get width
                    pshs      b,a       ; push width
                    ldb       <$31,s    ; get start column
                    pshs      b,a       ; push start column
                    lda       #$12
                    sta       <$0019    ; set MMU page for fill
                    ldx       <$0026    ; load fill routine pointer
                    jsr       >$0701    ; call MMU twiddle fill
                    leas      $06,s     ; pop fill args
DrawTextRectDoRows  lda       <$35,s    ; load right column
                    inca                ; add 1
                    suba      <$33,s    ; subtract left column = width
                    leau      ,s        ; U = local frame buffer
                    ldb       #$20      ; space character
DrawTextRectFillLoop stb       ,u+       ; fill buffer with spaces
                    deca                ; decrement count
                    bne       DrawTextRectFillLoop ; continue fill
                    sta       ,u        ; null-terminate buffer
                    ldd       >$024C    ; save current text color
                    pshs      b,a       ; push saved color
                    ldb       <$33,s    ; get left column for color
                    lbsr      text_color ; set text color from param
                    lda       <$39,s    ; check row counter
                    bne       DrawTextRectRowNext ; not first row
                    lda       <$2F,s    ; load top row
                    sta       <$0040    ; set current row
                    nega                ; negate top row
                    adda      <$31,s    ; add total rows
                    inca                ; row count = rows - top + 1
                    sta       <$39,s    ; initialize row counter
                    bra       DrawTextRectWriteRow
DrawTextRectRowNext nega                ; negate current row counter
                    adda      <$31,s    ; compute next row
                    inca                ; +1 for 0-based row indexing
                    sta       <$0040    ; advance current row
DrawTextRectWriteRow lda       <$35,s    ; load right column
                    sta       <$0041    ; set current column to right edge
                    leau      $02,s     ; point to text buffer
                    pshs      u         ; push buffer pointer
                    lda       #$0F
                    sta       <$0019    ; set MMU page for text write
                    ldx       <$0026    ; load text write routine pointer
                    jsr       >$0701    ; call MMU twiddle write text
                    leas      $02,s     ; pop buffer pointer
                    inc       <$0040    ; advance to next row
                    dec       <$39,s    ; decrement row counter
                    bne       DrawTextRectWriteRow ; more rows to write
                    puls      b,a       ; restore saved text color
                    std       >$024C    ; restore text color pair
DrawTextRectRet     leas      <$2A,s    ; release local frame
                    rts

ClearTextRect       ldd       <$0040    ; save current cursor row/col
                    pshs      b,a       ; push saved cursor
                    ldd       #$0000    ; color = 0 (black on black)
                    pshs      b,a       ; push color
                    ldb       $09,s     ; get row count from caller
                    pshs      b,a       ; push row count
                    ldb       $09,s     ; get bottom row from caller
                    pshs      b,a       ; push bottom row
                    ldb       $0F,s     ; get right column from caller
                    pshs      b,a       ; push right column
                    ldb       $0E,s     ; get left column from caller
                    pshs      b,a       ; push left column
                    ldb       $0E,s     ; get top row from caller
                    pshs      b,a       ; push top row
                    lbsr      DrawTextRect ; draw black rectangle to clear
                    leas      $0C,s     ; pop DrawTextRect args
                    puls      b,a       ; restore saved cursor
                    std       <$0040    ; restore cursor row/col
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

*
*======================================================================
* VOLUME FILE ACCESS
*   OpenVolFile, FindVol, ShowInsertDiskMsg, ShowWrongDiskMsg,
*   ReadDiskVol, VolumesClose, and FileLoad manage multi-disk volume
*   files: locating the correct disk/side, prompting the player to
*   swap disks, reading compressed or raw resource data, and closing
*   open volume handles.
*======================================================================
*
OpenVolFile         leas      -6,s      ; allocate 6-byte local frame
                    std       ,s        ; save D (resource descriptor)
                    stu       $02,s     ; save U (resource pointer)
                    stx       $04,s     ; save X (resource index)
OpenVolFileLoop     bsr       FindVol   ; find volume file for resource
                    cmpu      #$0000
OpenVolFileCheckResult bne       OpenVolFileRet ; found it
                    lda       >VolWrongDisk,pcr ; check wrong-disk error count
                    cmpa      #$05
                    beq       OpenVolFileRet ; too many retries
                    ldd       ,s        ; reload resource descriptor
OpenVolFileRetry    lbsr      SetLogicPage ; set logic page for retry
                    ldu       $02,s     ; reload resource pointer
                    ldx       $04,s     ; reload resource index
OpenVolFileNextPage bra       OpenVolFileLoop ; retry
OpenVolFileRet      leas      $06,s     ; release local frame
                    rts
FindVol             leas      <-$12,s   ; allocate 18-byte local frame
                    stu       ,s        ; save U (resource pointer)
                    stx       $02,s     ; save X (resource index)
                    pshs      y         ; save Y (script pointer)
                    ldu       <$004F    ; load volume file handle table
                    stu       $06,s     ; save handle table pointer
                    lda       >$0531    ; load current volume file handle
                    cmpa      #$FF
                    bne       FindVolGotHandle ; handle valid, skip disk load
                    ldd       >VolDiskInfoPtr,pcr ; load current disk info pointer
                    bne       FindVolLoadDisk ; already have disk info
                    ldx       [>$0089]  ; indirect load disk info table
                    stx       >VolDiskInfoPtr,pcr ; save disk info pointer
                    ldd       ,x        ; load disk/side number
                    cmpd      #$0101    ; check if disk 1 side 1
                    beq       FindVolLoadDisk ; on correct disk
                    clrb                ; B = 0 (disk 1 = volume 0)
                    lbsr      ShowInsertDiskMsg ; prompt user to insert disk 1
FindVolLoadDisk     lbsr      ReadDiskVol ; open volume file from disk
FindVolGotHandle    ldu       $02,s     ; reload resource index pointer
                    lda       ,u        ; load resource type byte
                    lsra                ; extract volume number from upper nibble
                    lsra                ; shift right (bit 2)
                    lsra                ; shift right (bit 3)
                    lsra                ; upper nibble now in low nibble
                    sta       $08,s     ; save target volume number
                    ldx       #$0531    ; point to volume handle table
                    ldb       a,x       ; load handle for target volume
                    cmpb      #$FF
                    bne       FindVolCheckHandle ; handle valid
                    lbsr      VolumesClose ; close all volumes
                    ldb       $08,s     ; reload target volume number
                    beq       FindVolDefaultDisk ; vol 0 = default disk
                    cmpb      >$05ED    ; compare to max disk count
                    bls       FindVolLoadDiskInfo ; within range
FindVolDefaultDisk  ldb       >VolMaxDisk,pcr ; use max disk number
                    stb       $08,s     ; store as target
FindVolLoadDiskInfo decb                ; convert to 0-based index
                    lslb                ; multiply by 2 for pointer table
                    ldx       <$0089    ; load disk info pointer table
                    ldx       b,x       ; dereference to get disk info
                    stx       >VolDiskInfoPtr,pcr ; save disk info pointer
                    ldd       ,x        ; load disk number and side
                    cmpa      >VolCurDisk,pcr ; compare to current disk
                    bne       FindVolWrongDisk ; wrong disk
                    cmpb      >VolCurSide,pcr ; compare to current side
                    beq       FindVolLoadSide ; correct side
FindVolWrongDisk    lda       #$01
                    sta       >VolWrongDisk,pcr ; set wrong-disk flag
                    ldb       $08,s     ; reload target volume number
                    lbsr      ShowInsertDiskMsg ; prompt user to insert correct disk
FindVolLoadSide     lbsr      ReadDiskVol ; open volume file from disk
                    lbra      FindVolFail ; (fall through to failure path)
FindVolCheckHandle  stb       >VolFileIdx,pcr ; save volume file handle
                    clra                ; A = 0 (high byte for D register)
                    ldb       ,u        ; load resource byte again
                    andb      #$0F      ; isolate offset within volume (low nibble)
                    tfr       d,x       ; X = resource file offset
                    ldu       $01,u     ; load resource index pointer
                    lda       >VolFileIdx,pcr ; reload file handle
                    clrb                ; B = 0 (high byte of seek offset)
                    lbsr      SeekFile  ; seek to resource within volume
                    bcs       FindVolReadErr ; seek failed
                    lda       >VolFileIdx,pcr ; reload file handle
                    leax      $09,s     ; X = local header buffer
                    ldy       #$0007    ; read 7 bytes
                    lbsr      ReadFile  ; read volume file header
                    bcs       FindVolReadErr ; read failed
                    cmpd      #$0007
                    beq       FindVolVerifyHdr ; got full header
FindVolReadErr      lbsr      ErrorDialog ; show I/O error dialog
                    lbne      FindVolFail ; user said quit
                    lda       #$03
                    sta       <$0009    ; set exit flag
                    ldx       <$0022    ; load exit routine pointer
                    jsr       >$0701    ; call MMU twiddle exit
FindVolVerifyHdr    ldd       $09,s     ; load header magic bytes
                    cmpd      #$1234    ; check Sierra volume magic
                    bne       FindVolWrongSide ; wrong magic = wrong disk/side
                    lda       $0B,s     ; load volume number from header
                    anda      #$0F      ; isolate volume nibble
                    cmpa      $08,s     ; compare to target volume
                    beq       FindVolGoodHdr ; correct volume
FindVolWrongSide    lbsr      VolumesClose ; close wrong volume
                    lda       #$01
                    sta       >VolWrongDisk,pcr ; set wrong-disk flag
                    ldb       $08,s     ; reload target volume number
                    lbsr      ShowWrongDiskMsg ; prompt user with wrong-disk message
                    tsta                ; test result
                    bne       FindVolRetryDisk ; user wants to retry
                    lda       #$03
                    sta       <$0009    ; set exit flag
                    ldx       <$0022    ; load exit routine pointer
                    jsr       >$0701    ; call MMU twiddle exit
FindVolRetryDisk    lbsr      ReadDiskVol ; reload disk volume after user swap
                    lbra      FindVolFail
FindVolGoodHdr      ldb       $0C,s     ; load resource size low word
                    lda       $0D,s     ; (resource size high byte)
                    std       <$0066    ; store resource size
                    ldb       $0E,s     ; load compressed size low word
                    lda       $0F,s
                    std       <$12,s    ; store compressed size
                    ldu       $04,s     ; load allocated buffer pointer
                    bne       FindVolReadData ; already have buffer
                    lda       >$05B8    ; check available memory flag
                    beq       FindVolAllocMem ; no check needed
                    lbsr      UpdateFreeSpace ; update free memory count
                    cmpd      <$0066    ; compare free to resource size
                    bcc       FindVolAllocMem ; enough memory
                    lda       #$05
                    sta       >VolWrongDisk,pcr ; signal out-of-memory condition
                    bra       FindVolFail
FindVolAllocMem     ldd       <$0066    ; load resource size
                    lbsr      AllocHeap ; allocate buffer for resource
                    lbsr      CalcPriCoord ; calculate priority coordinate
                    stu       $04,s     ; save buffer pointer
                    std       <$10,s    ; save coord
                    lbsr      SetLogicPage ; set logic page for resource
FindVolReadData     lda       $0B,s     ; load compression flags byte
                    anda      #$80      ; test pic-strip compression flag
                    beq       FindVolDirectRead ; not pic strip
                    ldd       <$12,s    ; load compressed size
                    pshs      b,a       ; push for RenderPicStrip
                    ldd       $06,s     ; load handle table
                    pshs      b,a       ; push handle table
                    ldd       >VolFileIdx,pcr ; load file handle
                    pshs      b,a       ; push file handle
                    lbsr      RenderPicStrip ; decode pic strip data
                    leas      $06,s     ; pop args
                    bra       FindVolRet2
FindVolDirectRead   ldd       <$12,s    ; load compressed size
                    cmpd      <$0066    ; compare to resource size
                    bne       FindVolCompressed ; sizes differ = LZW compressed
                    lda       #$01
                    sta       <$009E    ; set direct-read flag
                    lda       >VolFileIdx,pcr ; load file handle
                    ldx       $04,s     ; load buffer pointer
                    ldy       <$0066    ; load byte count
                    lbsr      ReadFile  ; read resource directly
                    bra       FindVolRet2
FindVolCompressed   clr       <$009E    ; clear direct-read flag
                    pshs      b,a       ; push compressed size
                    ldd       $06,s     ; load handle table
                    pshs      b,a       ; push handle table
                    ldd       >VolFileIdx,pcr ; load file handle
                    pshs      b,a       ; push file handle
                    lbsr      PicRenderSetup ; decode LZW-compressed resource
                    leas      $06,s     ; pop args
FindVolRet2         tst       <$009F    ; test read-error flag
                    lbne      FindVolReadErr ; error occurred
                    ldu       $04,s     ; load buffer pointer
                    cmpd      <$0066    ; compare bytes read to resource size
                    beq       FindVolRet ; full resource read
                    lbra      FindVolReadErr ; short read = error
FindVolFail         ldd       $06,s     ; reload handle table pointer
                    std       <$004F    ; restore handle table
                    ldu       #$0000    ; return null (not found)
FindVolRet          ldd       <$10,s    ; load saved coord
                    puls      y         ; restore script pointer
                    leas      <$12,s    ; release local frame
                    rts

ShowInsertDiskMsg   leas      <-$64,s   ; allocate 100-byte message buffer
                    leau      ,s        ; U = buffer pointer
                    pshs      b,a       ; push volume args (disk, side)
                    pshs      u         ; push buffer pointer
                    lbsr      FormatInsertDiskMsg ; format "insert disk N side M" message
                    leas      $04,s     ; pop args
                    lbsr      message_box ; display insert disk dialog
                    leas      <$64,s    ; release message buffer
                    rts

FormatInsertDiskMsg ldx       >VolDiskInfoPtr,pcr ; load current disk info pointer
                    clra                ; zero high byte
                    ldb       $05,s     ; get requested disk number
                    beq       FormatInsertDiskMsgBody ; zero = use current info
                    cmpb      >$05ED    ; compare to disk count
                    bhi       FormatInsertDiskMsgBody ; out of range, use current
                    stb       >VolMaxDisk,pcr ; update max disk seen
                    decb                ; convert to 0-based index
                    lslb                ; multiply by 2 for pointer table
                    ldx       <$0089    ; load disk info pointer table
                    ldx       b,x       ; dereference to target disk info
FormatInsertDiskMsgBody ldb       $01,x     ; get side number from disk info
                    pshs      b,a       ; push side for format
                    ldb       ,x        ; get disk number from disk info
                    pshs      b,a       ; push disk number for format
                    leax      >StrInsertDiskMsg,pcr ; default: "insert disk N, side M"
                    cmpb      >VolCurDisk,pcr ; is this the current disk?
                    bne       FormatInsertDiskMsgRet ; no, use insert message
                    ldb       $01,x     ; load side number
                    cmpb      >VolCurSide,pcr ; is this the current side?
                    beq       FormatInsertDiskMsgRet ; yes, shouldn't happen
                    leax      >StrTurnOverDisk,pcr ; use "turn over disk" message
FormatInsertDiskMsgRet ldu       $06,s     ; load output buffer pointer
                    pshs      x         ; push format string
                    pshs      u         ; push output buffer
                    lbsr      PrintFmtStr ; format the disk message
                    leas      $08,s     ; pop args
                    rts

ShowWrongDiskMsg    leas      >-$012C,s ; allocate 300-byte message buffer
                    pshs      b,a       ; push volume args (disk, side)
                    lbsr      RingBell  ; ring bell to alert user
                    leau      $02,s     ; U = message buffer
                    pshs      u         ; push buffer for FormatInsertDiskMsg
                    lbsr      FormatInsertDiskMsg ; format "insert disk" message
                    leas      $04,s     ; pop args
                    leau      >StrQuitMsg2,pcr ; "quit/retry" button text
                    pshs      u         ; push button text
                    leau      $02,s     ; U = formatted insert message
                    pshs      u         ; push insert message
                    leau      >StrWrongDisk,pcr ; "wrong disk" prefix string
                    pshs      u         ; push wrong disk string
                    leax      >StrVolumeFmt,pcr ; "%s%s" format string
                    leau      <$6A,s    ; U = combined format args
                    pshs      x         ; push format string
                    pshs      u         ; push args
                    lbsr      PrintFmtStr ; format "wrong disk, insert X" message
                    leas      $0A,s     ; pop format args
                    lbsr      message_box ; display wrong disk dialog
                    leas      >$012C,s  ; release message buffer
                    rts

ReadDiskVol         leas      -$0D,s    ; allocate 13-byte local frame
                    ldx       >VolDiskInfoPtr,pcr ; point to disk info table
                    leax      $02,x     ; skip to entry list offset
                    ldb       ,x        ; load first disk/entry byte
ReadDiskVolName     clra                ; clear A for format arg
                    stx       ,s        ; save current entry pointer
                    andb      #$7F      ; strip high bit (end-of-list flag)
                    stb       $02,s     ; save disk number
                    leax      >StrVolumeName,pcr ; load "Volume N:" format string
                    leau      $03,s     ; output buffer on stack
                    pshs      b,a       ; push disk number argument
                    pshs      x         ; push format string
                    pshs      u         ; push output buffer
                    lbsr      PrintFmtStr ; format volume name string
                    leas      $06,s     ; discard PrintFmtStr args
ReadDiskVolOpen     lda       #$01      ; open mode = read-only
                    leax      $03,s     ; point to formatted name
                    lbsr      OpenFile  ; try to open the volume file
                    bcc       ReadDiskVolStore ; branch if opened successfully
                    tstb                ; check error code
                    bne       ReadDiskVolRetry ; retry if non-zero error
                    clr       >VolCurDisk,pcr ; clear current disk on fatal error
                    bra       ReadDiskVolRet ; return without storing handle
ReadDiskVolRetry    lbsr      ErrorDialog ; show error dialog to user
                    cmpa      #$00      ; check user response
                    bne       ReadDiskVolOpen ; retry open if user said yes
                    lda       #$03      ; function code for quit
                    sta       <$0009    ; store in MMU twiddle arg
                    ldx       <$0022    ; load quit handler address
                    jsr       >$0701    ; invoke via MMU twiddle
ReadDiskVolStore    ldu       #$0531    ; point to volume handle table
                    ldb       $02,s     ; disk number
                    sta       b,u       ; store open handle at slot
                    ldx       ,s        ; restore entry pointer
                    ldb       ,x+       ; read next byte, advance pointer
                    bmi       ReadDiskVolSetDisk ; high bit set = last entry
                    ldb       ,x        ; peek at next entry byte
                    bra       ReadDiskVolName ; process next volume name
ReadDiskVolSetDisk  ldx       >VolDiskInfoPtr,pcr ; reload disk info base
                    ldd       ,x        ; load disk ID word
                    std       >VolCurDisk,pcr ; record as current disk
ReadDiskVolRet      leas      $0D,s     ; release local frame
                    rts

VolumesClose        leas      -$01,s    ; allocate 1-byte counter
                    clrb                ; start at handle slot 0
                    ldx       #$0531    ; point to volume handle table
VolumesCloseLoop    cmpb      #$0F      ; past last slot?
                    bhi       VolumesCloseDone ; branch if all slots checked
                    stb       ,s        ; save current slot index
                    lda       ,x        ; read handle at this slot
                    cmpa      #$FF      ; already closed (invalid)?
                    beq       VolumesCloseNext ; skip if already closed
                    lbsr      CloseFilePath ; close the open file
                    lda       #$FF      ; mark slot as closed
VolumesCloseNext    sta       ,x+       ; store marker and advance
                    ldb       ,s        ; restore slot index
                    incb                ; next slot
                    bra       VolumesCloseLoop ; continue loop
VolumesCloseDone    leas      $01,s     ; release counter
                    rts

FileLoad            leas      <-$65,s   ; allocate 101-byte local frame
                    pshs      y         ; save logic script pointer
FileLoadOpen        lda       #$01      ; open mode = read-only
                    ldx       <$69,s    ; load file path pointer
                    lbsr      OpenFile  ; try to open the file
                    bcc       FileLoadGetSize ; branch if opened ok
                    lda       #$40      ; error attribute flag
                    sta       >$0101    ; set error state
                    leau      >StrQuitMsg2,pcr ; "Quit" button string
                    pshs      u         ; push it
                    leau      >StrTryAgain,pcr ; "Try Again" button string
                    pshs      u         ; push it
                    ldd       <$6D,s    ; resource number args
                    pshs      b,a       ; push resource args
                    leax      >StrCantFindVol,pcr ; "Can't find volume N" format
                    leau      $09,s     ; output buffer on stack
                    pshs      x         ; push format string
                    pshs      u         ; push output buffer
                    lbsr      PrintFmtStr ; format error message
                    leas      $0A,s     ; discard PrintFmtStr args
                    lbsr      message_box ; show "try again" dialog
                    bne       FileLoadOpen ; retry if user chose try again
                    lda       #$03      ; function code for quit
                    sta       <$0009    ; store in MMU twiddle arg
                    ldx       <$0022    ; load quit handler address
                    jsr       >$0701    ; invoke via MMU twiddle
FileLoadGetSize     sta       $02,s     ; save file handle
                    ldu       #$0000    ; seek offset = 0
                    tfr       u,x       ; clear X as well
                    ldb       #$02      ; seek mode = end
                    lbsr      SeekFile  ; seek to end to get size
                    stu       <$0066    ; save file size
                    ldu       #$0000    ; seek offset = 0
                    clrb                ; seek mode = begin
                    lbsr      SeekFile  ; seek back to start
                    ldx       <$6B,s    ; check destination pointer
                    bne       FileLoadRead ; if provided, skip allocation
                    ldd       <$0066    ; file size
                    ldu       <$6F,s    ; extra allocation pointer
                    beq       FileLoadAllocData ; if null, do plain allocation
                    lbsr      AllocHeap ; allocate on heap
                    lbsr      CalcPriCoord ; compute priority coordinates
                    stu       [<$6D,s]  ; store pointer through indirect
                    std       [<$6F,s]  ; store size through indirect
                    lbsr      SetLogicPage ; set logic page
                    bra       FileLoadSetPtr ; go set destination pointer
FileLoadAllocData   lbsr      AllocDataBlock ; plain data block allocation
                    stu       [<$6D,s]  ; store allocated pointer
FileLoadSetPtr      tfr       u,x       ; X = destination buffer
FileLoadRead        lda       $02,s     ; restore file handle
                    ldy       <$0066    ; Y = byte count
                    lbsr      ReadFile  ; read file data
                    cmpd      <$0066    ; compare bytes read to expected
                    beq       FileLoadClose ; branch if all bytes read
                    lbsr      ErrorDialog ; show error dialog
                    cmpb      #$00      ; check user response
                    bne       FileLoadClose ; close if user gave up
                    lda       #$03      ; function code for quit
                    sta       <$0009    ; store in MMU twiddle arg
                    ldx       <$0022    ; load quit handler address
                    jsr       >$0701    ; invoke via MMU twiddle
FileLoadClose       lda       $02,s     ; restore file handle
                    lbsr      CloseFilePath ; close the file
                    puls      y         ; restore logic script pointer
                    leas      <$65,s    ; release local frame
                    rts

StrLogics           fcc       /Logics/
                    fcb       0
StrView             fcc       /View/
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
StrSidDir           fcc       /sidDir/
                    fcb       0
StrSidSnd           fcc       /sidSnd/
                    fcb       0
StrSidDev           fcc       "/sid"
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

*
*======================================================================
* RESOURCE DIRECTORY LOOKUP
*   LoadAllDirs loads the logic, view, picture, and sound directory
*   files at startup; CheckResPtr validates a directory entry;
*   FetchLogic, FetchView, FetchPicture, and FetchSound locate a
*   resource in the volume file; ResNotFoundErr reports a missing
*   resource to the player.
*======================================================================
*
LoadAllDirs         leau      >LogDirPage,pcr ; address of logic dir page word
                    pshs      u         ; push page-out pointer
                    leau      >LogDirPtr,pcr ; address of logic dir pointer
                    leax      >StrLogDir,pcr ; "logDir" filename
                    pshs      u         ; push dir pointer
                    ldd       #$0000    ; no extra allocation
                    pshs      b,a       ; push extra args
                    pshs      x         ; push filename
                    lbsr      FileLoad  ; load logic directory
                    leas      $08,s     ; discard args
                    leau      >PicDirPage,pcr ; address of pic dir page word
                    pshs      u         ; push page-out pointer
                    leau      >PicDirPtr,pcr ; address of pic dir pointer
                    leax      >StrPicDir,pcr ; "picDir" filename
                    pshs      u         ; push dir pointer
                    ldd       #$0000    ; no extra allocation
                    pshs      b,a       ; push extra args
                    pshs      x         ; push filename
                    lbsr      FileLoad  ; load picture directory
                    leas      $08,s     ; discard args
                    leau      >ViewDirPage,pcr ; address of view dir page word
                    pshs      u         ; push page-out pointer
                    leau      >ViewDirPtr,pcr ; address of view dir pointer
                    leax      >StrViewDir,pcr ; "viewDir" filename
                    pshs      u         ; push dir pointer
LoadViewDirCall     ldd       #$0000    ; no extra allocation
                    pshs      b,a       ; push extra args
                    pshs      x         ; push filename
                    lbsr      FileLoad  ; load view directory
                    leas      $08,s     ; discard args
LoadSndDirCall      leau      >SndDirPage,pcr ; address of sound dir page word
                    pshs      u         ; push page-out pointer
                    leau      >SndDirPtr,pcr ; address of sound dir pointer
                    leax      >StrSndDir,pcr ; "sndDir" filename
                    pshs      u         ; push dir pointer
                    ldd       #$0000    ; no extra allocation
                    pshs      b,a       ; push extra args
                    pshs      x         ; push filename
                    lbsr      FileLoad  ; load sound directory
                    leas      $08,s     ; discard args
                    lbra      SidStartupInit ; XSID Phase 2: probe + load sidDir/sidSnd
*                   (SidStartupInit's rts returns to LoadAllDirs caller)

CheckResPtr         lda       ,u        ; load first byte of dir entry
                    cmpa      #$FF      ; is entry invalid?
                    bne       CheckResPtrRet ; return non-zero if valid
                    ldd       $01,u     ; load next two bytes
                    cmpd      #$FFFF    ; all 0xFF = not present
                    bne       CheckResPtrRet ; return non-zero if valid
                    ldu       #$0000    ; clear U to signal not found
CheckResPtrRet      rts

FetchLogic          leas      -$01,s    ; allocate 1-byte local
                    stb       ,s        ; save logic number
                    ldd       >LogDirPage,pcr ; get logic dir page
                    lbsr      SetLogicPage ; switch to logic page
                    lda       ,s        ; restore logic number
                    ldb       #$03      ; 3 bytes per dir entry
                    mul                 ; offset = number × 3
                    ldu       >LogDirPtr,pcr ; base of logic directory
                    leau      d,u       ; point to this entry
                    bsr       CheckResPtr ; check if entry is valid
                    bne       FetchLogicRet ; return if found
                    leax      >StrLogics,pcr ; "Logics" type name
                    ldb       ,s        ; logic number for error
                    lbsr      ResNotFoundErr ; report "resource not found"
FetchLogicRet       ldd       >LogDirPage,pcr ; restore original page
                    leas      $01,s     ; release local
                    rts

FetchView           leas      -$01,s    ; allocate 1-byte local
                    stb       ,s        ; save view number
                    ldd       >ViewDirPage,pcr ; get view dir page
                    lbsr      SetLogicPage ; switch to view page
                    lda       ,s        ; restore view number
                    ldb       #$03      ; 3 bytes per dir entry
                    mul                 ; offset = number × 3
                    ldu       >ViewDirPtr,pcr ; base of view directory
                    leau      d,u       ; point to this entry
                    bsr       CheckResPtr ; check if entry is valid
                    bne       FetchViewRet ; return if found
                    leax      >StrView,pcr ; "View" type name
                    ldb       ,s        ; view number for error
                    bsr       ResNotFoundErr ; report "resource not found"
FetchViewRet        ldd       >ViewDirPage,pcr ; restore original page
                    leas      $01,s     ; release local
                    rts

FetchPicture        leas      -$01,s    ; allocate 1-byte local
                    stb       ,s        ; save picture number
                    ldd       >PicDirPage,pcr ; get picture dir page
                    lbsr      SetLogicPage ; switch to pic page
                    lda       ,s        ; restore picture number
                    ldb       #$03      ; 3 bytes per dir entry
                    mul                 ; offset = number × 3
                    ldu       >PicDirPtr,pcr ; base of picture directory
                    leau      d,u       ; point to this entry
                    bsr       CheckResPtr ; check if entry is valid
                    bne       FetchPictureRet ; return if found
                    leax      >StrPicture,pcr ; "Picture" type name
                    ldb       ,s        ; picture number for error
                    bsr       ResNotFoundErr ; report "resource not found"
FetchPictureRet     ldd       >PicDirPage,pcr ; restore original page
                    leas      $01,s     ; release local
                    rts

FetchSound          leas      -$01,s    ; allocate 1-byte local
                    stb       ,s        ; save sound number
                    ldd       >SndDirPage,pcr ; get sound dir page
                    lbsr      SetLogicPage ; switch to sound page
                    lda       ,s        ; restore sound number
                    ldb       #$03      ; 3 bytes per dir entry
                    mul                 ; offset = number × 3
                    ldu       >SndDirPtr,pcr ; base of sound directory
                    leau      d,u       ; point to this entry
                    lbsr      CheckResPtr ; check if entry is valid
                    bne       FetchSoundRet ; return if found
                    leax      >StrSoundName,pcr ; "Sound" type name
                    ldb       ,s        ; sound number for error
                    bsr       ResNotFoundErr ; report "resource not found"
FetchSoundRet       ldd       >SndDirPage,pcr ; restore original page
                    leas      $01,s     ; release local
                    rts

ResNotFoundErr      leas      <-$64,s   ; allocate 100-byte message buffer
                    clra                ; clear A for resource number
                    pshs      b,a       ; push resource number arg
                    pshs      x         ; push type name string
                    leax      >StrResNotFound,pcr ; "%s #%d not found." format
                    leau      $04,s     ; output buffer on stack
                    pshs      x         ; push format string
                    pshs      u         ; push output buffer
                    lbsr      PrintFmtStr ; format error message
                    leas      $08,s     ; discard args
                    lbsr      message_box ; show error dialog
                    lda       #$03      ; function code for quit
                    sta       <$0009    ; store in MMU twiddle arg
                    ldx       <$0022    ; load quit handler address
                    jsr       >$0701    ; invoke via MMU twiddle (quit)
                    leas      <$64,s    ; release buffer
                    rts

SoundScratchBuf     fcb       0,0
                    fcb       0,0

GetStackFrame       leau      >GetStackFrame,pcr ; point U at own code start
                    ldd       ,s        ; capture return address
                    pshu      s,b,a     ; push S, return addr onto U stack
                    rts
RestoreStackFrame   leau      >SoundScratchBuf,pcr ; point U at scratch buffer
                    pulu      s,b,a     ; restore S and return addr from U
                    std       ,s        ; restore return address to stack
                    rts

StrNotNow           fcc       /Not now./
                    fcb       0

cmd_show_obj_v      ldx       #$0431    ; base of variable table
                    ldb       ,y+       ; fetch variable index
                    abx                 ; point to variable
                    ldb       ,x        ; dereference variable (view number)
                    bsr       obj_show  ; show the object view
                    rts

cmd_show_obj        ldb       ,y+       ; fetch view number directly
                    bsr       obj_show  ; show the object view
                    rts
obj_show            leas      <-$36,s   ; allocate 54-byte local frame
                    stb       $02,s     ; save view number
                    clra                ; A = 0
                    sta       >$05B1    ; clear full-screen draw flag
                    sta       $04,s     ; clear "allocated view" flag
                    sta       $03,s     ; clear "freed" flag
                    lbsr      view_find ; search view list for this view
                    leax      ,x        ; test X (result)
                    beq       ObjShowLoadView ; branch if not in cache
                    stx       $05,s     ; save view node pointer
                    inc       $04,s     ; mark view as already loaded
                    bra       ObjShowSetup ; proceed to setup
ObjShowLoadView     lda       #$01      ; set temp-load flag
                    sta       >$05B8    ; signal view is being loaded
                    clra                ; A = 0 (no special flags)
                    ldb       $02,s     ; view number to load
                    lbsr      view_load ; load the view resource
                    clr       >$05B8    ; clear temp-load flag
                    stu       $05,s     ; save loaded view node pointer
                    bne       ObjShowSetup ; branch if load succeeded
                    leau      >StrNotNow,pcr ; "Not now." message
                    lbsr      message_box ; show cannot-load message
                    lbra      ObjShowDone ; skip display
ObjShowSetup        ldd       <$000A    ; current logic page
                    std       <$34,s    ; save for restore later
                    ldu       $05,s     ; view node pointer
                    ldd       $05,u     ; view dimensions
                    leau      $07,s     ; scratch object struct area
                    std       $08,u     ; store dimensions
                    clra                ; A = 0
                    sta       $0A,u     ; clear loop index
                    sta       $0E,u     ; clear cel index
                    ldb       $02,s     ; view number
                    lbsr      SetViewForObj ; bind view data to object
                    ldd       <$10,u    ; cel data pointer
                    std       <$12,u    ; copy to working pointer
                    lda       #$9F      ; screen width limit
                    suba      <$1C,u    ; subtract cel width
                    lsra                ; halve to center horizontally
                    ldb       #$A7      ; center Y coordinate
                    std       $03,u     ; store centered (X,Y) position
                    std       <$1A,u    ; store in object position field
                    lda       #$0F      ; priority 15
                    sta       <$24,u    ; set priority
                    lda       <$26,u    ; load flags
                    ora       #$04      ; set fixed-position flag
                    sta       <$26,u    ; store updated flags
                    lda       #$FF      ; invalid/unset value
                    sta       $02,u     ; mark control byte as unset
                    ldd       <$1C,u    ; cel dimensions (width, height)
                    mul                 ; compute pixel area (w × h)
                    addd      #$000E    ; add 14-byte node overhead
                    std       <$32,s    ; save required size
                    lbsr      UpdateFreeSpace ; get available free memory
                    cmpd      <$32,s    ; enough space for view node?
                    bcs       ObjShowDisplay ; branch if not enough (skip alloc)
                    inc       $03,s     ; mark that we allocated a node
                    tfr       u,x       ; X = object struct pointer
                    lbsr      AllocViewEntry ; allocate a view entry node
                    stu       ,s        ; save allocated node pointer
                    pshs      u         ; push it for MMU call
                    lda       #$15      ; function: draw object (sprite)
                    sta       <$0021    ; MMU twiddle function code
                    ldx       <$0028    ; MMU twiddle draw handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $02,s     ; discard pushed arg
                    leau      $07,s     ; restore object struct pointer
                    pshs      u         ; push it for MMU call
                    lda       #$0C      ; function: render priority/background
                    sta       <$0021    ; MMU twiddle function code
                    ldx       <$0028    ; MMU twiddle handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $02,s     ; discard pushed arg
                    leau      $07,s     ; restore object struct pointer
                    pshs      u         ; push it for MMU call
                    lda       #$1B      ; function: draw object to screen
                    sta       <$0019    ; MMU twiddle function code
                    ldx       <$0026    ; MMU twiddle handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $02,s     ; discard pushed arg
ObjShowDisplay      ldu       $05,s     ; view node pointer
                    ldu       $03,u     ; get embedded data pointer
                    ldb       $03,u     ; string offset within data
                    lda       $04,u     ; string column offset
                    leau      d,u       ; advance to description string
                    lbsr      message_box ; show description in message box
                    lda       $03,s     ; check if we allocated a node
                    beq       ObjShowRestore ; skip free if no allocation
                    ldu       ,s        ; get allocated node pointer
                    pshs      u         ; push for MMU call
                    lda       #$12      ; function: erase object
                    sta       <$0021    ; MMU twiddle function code
                    ldx       <$0028    ; MMU twiddle handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $02,s     ; discard pushed arg
                    leau      $07,s     ; restore object struct pointer
                    pshs      u         ; push for MMU call
                    lda       #$1B      ; function: redraw background
                    sta       <$0019    ; MMU twiddle function code
                    ldx       <$0026    ; MMU twiddle handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $02,s     ; discard pushed arg
                    ldx       ,s        ; get allocated node
                    lda       $0C,x     ; node logic page
                    ldu       $0A,x     ; node data pointer
                    lbsr      CalcPriAddr ; compute priority address
                    stu       <$004F    ; store priority pointer
                    stx       <$0055    ; store node pointer
ObjShowRestore      ldd       <$34,s    ; saved logic page
                    lbsr      SetLogicPage ; restore original logic page
                    lda       $04,s     ; was view already loaded?
                    bne       ObjShowDone ; skip discard if pre-loaded
                    ldb       $02,s     ; view number
                    lbsr      DiscardViewHelper ; free the temporarily loaded view
ObjShowDone         lda       #$01      ; restore full-screen draw flag
                    sta       >$05B1    ; signal draw-all needed
                    leas      <$36,s    ; release local frame
                    rts

SoundScratch9       fcb       0,0,0,0,0,0,0,0,0
SoundListPtr        fcb       0,0
SoundPIA1Ctrl       fcb       0
SoundPIA2Ctrl       fcb       0
SoundEnableReg      fcb       0

* XSID extension: detection state for the CoCo X-SID cart in MPI slot 1.
*   0     = not yet probed (will probe on first PlaySound call)
*   $01   = present and verified -> PlaySound routes voice 1 to SID
*   $FF   = absent / probe failed -> PlaySound uses original DAC code
SidPresent          fcb       0

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

* XSID extension: SID voice-1 frequency-register values, one per note,
* parallel to the half-period entries at the top of NoteFreqTable.
* Generated to match the same audible frequency that the original
* DAC bit-bang loop produces for each note, computed assuming the
* MAME coco_xsid stock 1 MHz clock.  Pitch is only approximate (the
* DAC loop's actual frequency depends on exact CPU clock rate), but
* well within musical tolerance for Phase 1.
*   freq_reg = audible_hz * 16777216 / 1_000_000
*   audible_hz = cpu_hz / (54 + 14 * half_period)   (cpu_hz = 894886)
* 61 entries, 16-bit each = 122 bytes.
SidFreqTable        fdb       $0230               ; n000 hp=$0778 ~   33 Hz
                    fdb       $0251               ; n001 hp=$070C ~   35 Hz
                    fdb       $0274               ; n002 hp=$06A8 ~   37 Hz
                    fdb       $0299               ; n003 hp=$0648 ~   40 Hz
                    fdb       $02C2               ; n004 hp=$05EC ~   42 Hz
                    fdb       $02EB               ; n005 hp=$0598 ~   45 Hz
                    fdb       $0317               ; n006 hp=$0548 ~   47 Hz
                    fdb       $0346               ; n007 hp=$04FC ~   50 Hz
                    fdb       $0378               ; n008 hp=$04B4 ~   53 Hz
                    fdb       $03AD               ; n009 hp=$0470 ~   56 Hz
                    fdb       $03E5               ; n010 hp=$0430 ~   59 Hz
                    fdb       $0420               ; n011 hp=$03F4 ~   63 Hz
                    fdb       $045D               ; n012 hp=$03BC ~   67 Hz
                    fdb       $04A0               ; n013 hp=$0386 ~   71 Hz
                    fdb       $04E5               ; n014 hp=$0354 ~   75 Hz
                    fdb       $052F               ; n015 hp=$0324 ~   79 Hz
                    fdb       $0580               ; n016 hp=$02F6 ~   84 Hz
                    fdb       $05D2               ; n017 hp=$02CC ~   89 Hz
                    fdb       $0629               ; n018 hp=$02A4 ~   94 Hz
                    fdb       $0687               ; n019 hp=$027E ~  100 Hz
                    fdb       $06EA               ; n020 hp=$025A ~  106 Hz
                    fdb       $0753               ; n021 hp=$0238 ~  112 Hz
                    fdb       $07C2               ; n022 hp=$0218 ~  118 Hz
                    fdb       $0837               ; n023 hp=$01FA ~  125 Hz
                    fdb       $08B2               ; n024 hp=$01DE ~  133 Hz
                    fdb       $093B               ; n025 hp=$01C2 ~  141 Hz
                    fdb       $09BF               ; n026 hp=$01AA ~  149 Hz
                    fdb       $0A52               ; n027 hp=$0192 ~  157 Hz
                    fdb       $0AF8               ; n028 hp=$017A ~  167 Hz
                    fdb       $0B94               ; n029 hp=$0166 ~  177 Hz
                    fdb       $0C41               ; n030 hp=$0152 ~  187 Hz
                    fdb       $0D04               ; n031 hp=$013E ~  199 Hz
                    fdb       $0DC9               ; n032 hp=$012C ~  210 Hz
                    fdb       $0E8D               ; n033 hp=$011C ~  222 Hz
                    fdb       $0F69               ; n034 hp=$010C ~  235 Hz
                    fdb       $105F               ; n035 hp=$00FC ~  250 Hz
                    fdb       $1152               ; n036 hp=$00EE ~  264 Hz
                    fdb       $123A               ; n037 hp=$00E2 ~  278 Hz
                    fdb       $1368               ; n038 hp=$00D4 ~  296 Hz
                    fdb       $148D               ; n039 hp=$00C8 ~  314 Hz
                    fdb       $159C               ; n040 hp=$00BE ~  330 Hz
                    fdb       $1709               ; n041 hp=$00B2 ~  351 Hz
                    fdb       $1860               ; n042 hp=$00A8 ~  372 Hz
                    fdb       $1A35               ; n043 hp=$009C ~  400 Hz
                    fdb       $1B3A               ; n044 hp=$0096 ~  415 Hz
                    fdb       $1CB8               ; n045 hp=$008E ~  438 Hz
                    fdb       $1E63               ; n046 hp=$0086 ~  464 Hz
                    fdb       $2042               ; n047 hp=$007E ~  492 Hz
                    fdb       $21D2               ; n048 hp=$0078 ~  516 Hz
                    fdb       $2428               ; n049 hp=$0070 ~  552 Hz
                    fdb       $2622               ; n050 hp=$006A ~  582 Hz
                    fdb       $2856               ; n051 hp=$0064 ~  615 Hz
                    fdb       $2ACF               ; n052 hp=$005E ~  653 Hz
                    fdb       $2CA2               ; n053 hp=$005A ~  681 Hz
                    fdb       $2FAE               ; n054 hp=$0054 ~  728 Hz
                    fdb       $31F4               ; n055 hp=$0050 ~  762 Hz
                    fdb       $3475               ; n056 hp=$004C ~  800 Hz
                    fdb       $38B8               ; n057 hp=$0046 ~  865 Hz
                    fdb       $3BF7               ; n058 hp=$0042 ~  915 Hz
                    fdb       $3F9C               ; n059 hp=$003E ~  971 Hz
                    fdb       $419A               ; n060 hp=$003C ~ 1001 Hz
                    fdb       $FFFF               ; n061 hp=$0002 ~10913 Hz
                    fdb       $FFFF               ; n062 hp=$0002 ~10913 Hz
                    fdb       $FFFF               ; n063 hp=$0002 ~10913 Hz
                    fdb       $FFFF               ; n064 hp=$0003 ~ 9322 Hz
                    fdb       $FFFF               ; n065 hp=$0003 ~ 9322 Hz
                    fdb       $FFFF               ; n066 hp=$0003 ~ 9322 Hz
                    fdb       $FFFF               ; n067 hp=$0003 ~ 9322 Hz
                    fdb       $FFFF               ; n068 hp=$0003 ~ 9322 Hz
                    fdb       $FFFF               ; n069 hp=$0003 ~ 9322 Hz
                    fdb       $FFFF               ; n070 hp=$0004 ~ 8135 Hz
                    fdb       $FFFF               ; n071 hp=$0004 ~ 8135 Hz
                    fdb       $FFFF               ; n072 hp=$0004 ~ 8135 Hz
                    fdb       $FFFF               ; n073 hp=$0004 ~ 8135 Hz
                    fdb       $FFFF               ; n074 hp=$0005 ~ 7217 Hz
                    fdb       $FFFF               ; n075 hp=$0005 ~ 7217 Hz
                    fdb       $FFFF               ; n076 hp=$0005 ~ 7217 Hz
                    fdb       $FFFF               ; n077 hp=$0005 ~ 7217 Hz
                    fdb       $FFFF               ; n078 hp=$0006 ~ 6485 Hz
                    fdb       $FFFF               ; n079 hp=$0006 ~ 6485 Hz
                    fdb       $FFFF               ; n080 hp=$0006 ~ 6485 Hz
                    fdb       $FFFF               ; n081 hp=$0007 ~ 5887 Hz
                    fdb       $FFFF               ; n082 hp=$0007 ~ 5887 Hz
                    fdb       $FFFF               ; n083 hp=$0008 ~ 5391 Hz
                    fdb       $FFFF               ; n084 hp=$0008 ~ 5391 Hz
                    fdb       $FFFF               ; n085 hp=$0009 ~ 4972 Hz
                    fdb       $FFFF               ; n086 hp=$0009 ~ 4972 Hz
                    fdb       $FFFF               ; n087 hp=$000A ~ 4613 Hz
                    fdb       $FFFF               ; n088 hp=$000A ~ 4613 Hz
                    fdb       $FFFF               ; n089 hp=$000B ~ 4302 Hz
                    fdb       $FFFF               ; n090 hp=$000C ~ 4031 Hz
                    fdb       $FFFF               ; n091 hp=$000C ~ 4031 Hz
                    fdb       $F881               ; n092 hp=$000D ~ 3792 Hz
                    fdb       $EA97               ; n093 hp=$000E ~ 3580 Hz
                    fdb       $EA97               ; n094 hp=$000E ~ 3580 Hz
                    fdb       $DE26               ; n095 hp=$000F ~ 3390 Hz
                    fdb       $D2F6               ; n096 hp=$0010 ~ 3219 Hz
                    fdb       $C8D9               ; n097 hp=$0011 ~ 3065 Hz
                    fdb       $BFA8               ; n098 hp=$0012 ~ 2924 Hz
                    fdb       $B746               ; n099 hp=$0013 ~ 2797 Hz
                    fdb       $AF97               ; n100 hp=$0014 ~ 2679 Hz
                    fdb       $A887               ; n101 hp=$0015 ~ 2572 Hz
                    fdb       $9BFA               ; n102 hp=$0017 ~ 2380 Hz
                    fdb       $912B               ; n103 hp=$0019 ~ 2215 Hz
                    fdb       $8C4E               ; n104 hp=$001A ~ 2141 Hz
                    fdb       $87C2               ; n105 hp=$001B ~ 2071 Hz
                    fdb       $7F7E               ; n106 hp=$001D ~ 1945 Hz
                    fdb       $7BBA               ; n107 hp=$001E ~ 1888 Hz
                    fdb       $74D4               ; n108 hp=$0020 ~ 1783 Hz
                    fdb       $6EA8               ; n109 hp=$0022 ~ 1688 Hz
                    fdb       $691A               ; n110 hp=$0024 ~ 1604 Hz
                    fdb       $6415               ; n111 hp=$0026 ~ 1527 Hz
                    fdb       $5F84               ; n112 hp=$0028 ~ 1457 Hz
                    fdb       $5967               ; n113 hp=$002B ~ 1364 Hz
                    fdb       $55BE               ; n114 hp=$002D ~ 1308 Hz
                    fdb       $50C8               ; n115 hp=$0030 ~ 1233 Hz
                    fdb       $4C5D               ; n116 hp=$0033 ~ 1165 Hz
                    fdb       $49AD               ; n117 hp=$0035 ~ 1124 Hz
                    fdb       $44D6               ; n118 hp=$0039 ~ 1050 Hz
                    fdb       $4097               ; n119 hp=$003D ~  986 Hz
                    fdb       $3DBC               ; n120 hp=$0040 ~  942 Hz
                    fdb       $3BF7               ; n121 hp=$0042 ~  915 Hz

MonthDayTable       fcb       0
                    fcb       $1f,$1c
                    fcb       $1f,$1e
                    fcb       $1f,$1e
                    fcb       $1f,$1f
                    fcb       $1e,$1f
                    fcb       $1e,$1f

*
*======================================================================
* SOUND PLAYBACK
*   Manages the sound list, implements cmd_load_sound and cmd_sound
*   to schedule playback, drives the tone generator through PIA
*   hardware (PlaySound), and saves/restores PIA state around sound
*   output (SoundPIASave, SoundPIARestore).
*======================================================================
*
SoundListClear      leau      SoundScratch9,pcr ; point to sound list head
                    ldd       #0        ; null link word
                    std       ,u        ; clear head pointer (empty list)
                    rts

SoundListFind       leau      >SoundScratch9,pcr ; start from list head
SoundListFindLoop   stu       >SoundListPtr,pcr ; remember previous node
                    ldu       ,u        ; follow next link
                    beq       SoundListFindRet ; end of list = not found
                    cmpb      $02,u     ; compare sound number at node
                    bne       SoundListFindLoop ; loop if no match
SoundListFindRet    rts

cmd_load_sound      ldb       ,y+       ; fetch sound resource number
                    bsr       LoadSoundData ; load the sound
                    rts

LoadSoundData       leas      -$05,s    ; allocate 5-byte local frame
                    stb       ,s        ; save sound number
                    bsr       SoundListFind ; check if sound is already loaded
                    cmpu      #$0000    ; was it found?
                    bne       LoadSoundRet ; skip if already in list
                    ldd       <$000A    ; current logic page
                    std       $03,s     ; save for restore
                    lbsr      ClearBothRanges ; clear object motion ranges
                    lda       #$03      ; script type for sound load
                    ldb       ,s        ; sound number
                    lbsr      PushScript ; record in script replay buffer
                    leau      >SoundScratch9,pcr ; list head node
                    ldx       >SoundListPtr,pcr ; previous-node pointer
                    beq       LoadSoundAlloc ; branch if list was empty
                    ldd       #$0009    ; allocate 9-byte sound node
                    lbsr      AllocDataBlock ; allocate node memory
                    stu       ,x        ; link new node at previous tail
                    ldd       #$0000    ; null next-pointer
                    std       ,u        ; clear new node's link
LoadSoundAlloc      ldb       ,s        ; sound number
                    stb       $02,u     ; store number in node
                    stu       $01,s     ; save node pointer
                    lbsr      FetchSound ; look up sound in directory
                    ldx       #$0000    ; no preferred volume
                    lbsr      OpenVolFile ; open the volume file
                    beq       LoadSoundDone ; skip if not found
                    ldx       $01,s     ; sound node pointer
                    std       $05,x     ; store volume file info
                    stu       $03,x     ; store data pointer
                    std       $07,x     ; store size
LoadSoundDone       lbsr      SwapObjRanges ; restore object ranges
                    ldd       $03,s     ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    ldu       $01,s     ; sound node pointer
LoadSoundRet        leas      $05,s     ; release local frame
                    rts

cmd_sound           leas      -$0B,s    ; allocate 11-byte local frame (time struct)
                    ldb       ,y+       ; fetch sound number
                    stb       ,s        ; save sound number
                    lbsr      SoundListFind ; search sound list
                    cmpu      #$0000    ; found?
                    bne       SoundCheckFlags ; branch if found
                    lda       #$09      ; error code for sound not loaded
                    ldb       ,s        ; sound number
                    lbsr      ReportError ; report error
SoundCheckFlags     lda       >$01AF    ; game flags byte
                    anda      #$40      ; test sound-enabled bit
                    lbeq      SoundSetFlagDone ; skip play if sound disabled
                    lda       >$0172    ; check silent flag
                    lbne      SoundSetFlagDone ; skip play if silenced
                    ldd       <$000A    ; current logic page
                    std       $03,s     ; save page for restore
                    stu       $01,s     ; save sound node pointer
                    ldd       $05,u     ; sound data page info
                    lbsr      SetLogicPage ; switch to sound data page
                    leax      $05,s     ; point X at time struct buffer
                    os9       F$Time    ; get current system time
                    ldu       $01,s     ; restore sound node pointer
                    lbsr      PlaySound ; play the sound (returns duration in D)
                    cmpd      #$0000    ; any elapsed time returned?
                    lbeq      TimeRestorePage ; skip time update if zero
                    pshs      b,a       ; save elapsed time
                    addb      $0C,s     ; add seconds field
                    bcc       TimeSecCarry ; branch if no second overflow
                    inca                ; carry into minutes
TimeSecCarry        ldu       #$003C    ; 60 seconds per minute
                    lbsr      UIntDivide ; divide to get minute carry
                    stb       $0C,s     ; store updated seconds
                    tfr       u,d       ; D = minute carry
                    cmpd      #$0000    ; any minutes to add?
                    beq       TimeSetSys ; skip if none
                    addb      $0B,s     ; add to minutes field
                    bcc       TimeMinCarry ; branch if no minute overflow
                    inca                ; carry into hours
TimeMinCarry        ldu       #$003C    ; 60 minutes per hour
                    lbsr      UIntDivide ; divide to get hour carry
                    stb       $0B,s     ; store updated minutes
                    tfr       u,d       ; D = hour carry
                    tstb                ; any hours to add?
                    beq       TimeSetSys ; skip if none
                    addb      $0A,s     ; add to hours field
                    lda       #$17      ; 24 hours per day
                    lbsr      Div8      ; divide to get day carry
                    sta       $0A,s     ; store updated hours
                    tstb                ; any days to add?
                    beq       TimeSetSys ; skip if none
                    inc       $09,s     ; increment day of month
                    ldd       $08,s     ; load month and year
                    leax      >MonthDayTable,pcr ; days-per-month table
                    cmpb      a,x       ; past end of month?
                    bls       TimeSetSys ; branch if still in month
                    ldb       a,x       ; days in this month
                    cmpa      #$02      ; is it February?
                    bne       TimeDayIncr ; branch if not Feb
                    ldb       $07,s     ; year value
                    beq       TimeDayIncr ; not a leap year
                    bitb      #$03      ; leap year check (divisible by 4)
                    bne       TimeDayIncr ; not divisible by 4
                    ldb       $09,s     ; current day
                    cmpb      #$1D      ; day 29?
                    beq       TimeSetSys ; allow Feb 29 on leap year
TimeDayIncr         ldb       #$01      ; reset to day 1
                    stb       $09,s     ; store day = 1
                    inca                ; advance month
                    cmpa      #$0C      ; past December?
                    bls       TimeMonthAdv ; branch if still in year
                    stb       $08,s     ; month = 1
                    inc       $07,s     ; increment year
                    bra       TimeSetSys ; apply to system
TimeMonthAdv        sta       $08,s     ; store updated month
TimeSetSys          leax      $07,s     ; point to updated time struct
                    os9       F$STime   ; set system time
                    puls      b,a       ; restore elapsed time
                    addb      >$043C    ; add to timer seconds field
                    bcc       TimeSec2Carry ; branch if no overflow
                    inca                ; carry into timer minutes
TimeSec2Carry       ldu       #$003C    ; 60 seconds per minute
                    lbsr      UIntDivide ; divide to get carry
                    stb       >$043C    ; store timer seconds
                    tfr       u,d       ; D = minute carry
                    cmpd      #$0000    ; any minutes?
                    beq       TimeRestorePage ; skip if none
                    addb      >$043D    ; add to timer minutes field
                    bcc       TimeMin2Carry ; branch if no overflow
                    inca                ; carry into hours
TimeMin2Carry       ldu       #$003C    ; 60 minutes per hour
                    lbsr      UIntDivide ; divide to get carry
                    stb       >$043D    ; store timer minutes
                    tfr       u,d       ; D = hour carry
                    tstb                ; any hours?
                    beq       TimeRestorePage ; skip if none
                    addb      >$043E    ; add to timer hours
                    lda       #$17      ; 24 hours per day
                    lbsr      Div8      ; get day carry in B
                    sta       >$043E    ; store timer hours
                    tstb                ; any day overflow?
                    beq       TimeRestorePage ; skip if none
                    inc       >$043F    ; increment timer day counter
TimeRestorePage     ldd       $03,s     ; saved logic page
                    lbsr      SetLogicPage ; restore logic page
SoundSetFlagDone    lda       ,y+       ; fetch flag number to set
                    lbsr      SetFlag   ; set the completion flag
                    leas      $0B,s     ; release local frame
                    rts

PlaySound           pshs      y,u       ; save logic script ptr + sound node U
                    ldb       2,u       ; XSID Phase 2: capture sound# from node
                    stb       >SidCurSound,pcr
* XSID extension: probe for X-SID on first PlaySound call.
*   SidPresent = $00  not yet probed (initial state in .fcb)
*   SidPresent = $01  probed and X-SID present  -> use SID, mute DAC
*   SidPresent = $FF  probed and X-SID absent   -> fall through to
*                                                  original DAC path
* On systems without X-SID (or even without MPI), this branch leaves
* SoundPIASave's DAC setup intact and the original PlaySoundLoop +
* PlaySoundWaveHigh DAC bit-bang runs unchanged.
                    lda       >SidPresent,pcr
                    bne       PlaySoundProbed   ; already probed
                    lbsr      SidProbe          ; first call: probe
                    lda       >SidPresent,pcr   ; reload result
PlaySoundProbed     cmpa      #$01              ; SID actually present?
                    bne       PlaySoundNoSid    ; no -> pure DAC Phase 0 path
* SID present: attempt Phase 2 polyphonic playback first.
* SidPlayDispatch checks SidDir for a matching stream; if found, loads
* and plays it (blocking with IRQs enabled), then returns CC.C=0.
* If no poly stream available, returns CC.C=1 and we fall through to
* the Phase 1 SID-driven mono path.
                    ldb       >SidCurSound,pcr
                    lbsr      SidPlayDispatch
                    bcs       PlaySoundSidMono  ; no poly -> Phase 1 mono+SID
* Polyphonic stream played to completion. Return D=0 to skip
* cmd_sound's elapsed-time advance (IRQs ran during poly play, OS
* clock already advanced naturally).
                    ldd       #$0000
                    puls      u,y,pc

PlaySoundNoSid      ldu       2,s       ; reload node ptr (U was at offset 2 after pshs y,u)
                    ldu       $03,u     ; follow pointer to sound data
                    clrb                ; B = 0 (initial silence)
                    lbsr      SoundPIASave ; configure PIA for sound output
                    bra       PlaySoundLoop ; original DAC bit-bang path

PlaySoundSidMono    ldu       2,s       ; reload node ptr (U was at offset 2 after pshs y,u)
                    ldu       $03,u     ; follow pointer to sound data
                    clrb                ; B = 0 (initial silence)
                    lbsr      SoundPIASave ; configure PIA for sound output
                    lda       >$FF23            ; SID present: mute DAC so the
                    anda      #$F7              ; bit-bang loop's $FF20 toggles
                    sta       >$FF23            ; can't bleed into the speaker
                    lbsr      SidSetupVoice1    ; master vol + v1 ADSR
PlaySoundLoop       ldb       ,u+       ; read note byte (0xFF = end)
                    cmpb      #$FF      ; end of sound?
                    beq       PlaySoundEnd ; branch to finish
                    lslb                ; double B for freq table index
                    lda       ,u+       ; read amplitude byte
                    ora       #2        ; force RS-232 line high
                    sta       >$FF20    ; write amplitude to PIA DAC
                    ldy       ,u++      ; load duration in Y
                    leax      >NoteFreqTable,pcr ; base of frequency table
                    abx                 ; index to this note's frequency
                    ldd       ,x        ; load half-period count
                    std       <$008E    ; store half-period in DP
                    leax      >$007A,x  ; offset to wave-count table
                    ldd       ,x        ; load wave-count entry
                    std       <$0090    ; store wave count in DP
                    lbsr      SidGateForNote ; XSID: drive SID v1 for this note
* The RS-232 line is now masked and forced high.
* Therefore $FF20 can't be tested for $00 but we can test the actual
* data stream. RG
*         tst   $FF20	old
                    tst       -3,u      new
                    beq       PlaySoundWaveLow ; branch if low amplitude (silent)
PlaySoundWaveHigh   ldx       <$0090    ; wave repetition count
PlaySoundHighLoop   ldd       <$008E    ; half-period delay
PlaySoundHighDelay  subd      #$0001    ; count down delay
                    bne       PlaySoundHighDelay ; loop until delay elapsed
*         com   $FF20
                    lda       $ff20     patch RG
                    coma                ; invert DAC output (toggle wave)
                    ora       #2        ; keep RS-232 line high
                    sta       $ff20     ; write toggled value
                    leax      -1,x      ; decrement wave count
                    bne       PlaySoundHighLoop ; loop for all waves
                    leay      -$01,y    ; decrement duration counter
                    bne       PlaySoundWaveHigh ; loop for full duration
                    bra       PlaySoundLoop ; next note (legato - no gate off)
PlaySoundWaveLow    ldx       <$0090    ; wave repetition count
PlaySoundLowLoop    ldd       <$008E    ; half-period delay
PlaySoundLowDelay   subd      #$0001    ; count down delay
                    bne       PlaySoundLowDelay ; loop until delay elapsed
* This is a meaningless test and must be here to balance cycles. RG
                    tst       >$FF20    ; cycle-balance test (no-op)
                    leax      -$01,x    ; decrement wave count
                    bne       PlaySoundLowLoop ; loop for all waves
                    leay      -$01,y    ; decrement duration counter
                    bne       PlaySoundWaveLow ; loop for full duration
                    bra       PlaySoundLoop ; next note (legato - no gate off)
PlaySoundEnd        lbsr      SidStopVoice ; XSID: release SID v1 at song end
                    lbsr      SoundPIARestore ; restore PIA to pre-sound state
                    ldd       ,u        ; load elapsed time word
                    puls      u,y,pc    ; restore U+Y from pshs y,u and return

*Sound on
* RS-232 toggle change. RG

SoundPIASave        orcc      #IntMasks ; disable interrupts during sound
*        clr   $FF20		this would trash the RS-232 line while zeroing the DAC
                    lda       #2        patch RG
                    sta       $ff20     ; set DAC to zero (RS-232 safe)
                    lda       >$FF01    save PIA setting
                    sta       >SoundPIA1Ctrl,pcr ; save PIA1 control byte
                    anda      #$F7      set MUX to 0
                    sta       >$FF01    ; write MUX=0 to PIA1
                    lda       >$FF03    save PIA setting
                    sta       >SoundPIA2Ctrl,pcr ; save PIA2 control byte
                    anda      #$F7      set MUX to 0
                    sta       >$FF03    DAC now selected
                    lda       >$FF23    save Sound setting
                    sta       >SoundEnableReg,pcr ; save sound-enable register
                    ora       #$08      turn sound on
                    sta       >$FF23    ; enable sound output
                    rts

*Sound off
* RS-232 toggle change. RG
SoundPIARestore     lda       >SoundPIA1Ctrl,pcr get saved PIA HSYNC setting
                    sta       >$FF01    restore it
                    lda       >SoundPIA2Ctrl,pcr get saved PIA VSYNC setting
                    sta       >$FF03    restore it
                    lda       >SoundEnableReg,pcr get Sound setting (presumably off)
                    sta       >$FF23    restore it
                    lda       #2        patch RG
                    sta       $FF20     ; reset DAC to RS-232-safe value
                    lda       $FF02     ; clear PIA1 interrupt latch
                    lda       $FF22     ; clear PIA2 interrupt latch
                    andcc     #$AF      ; re-enable interrupts
                    rts

************************************************************************
* XSID extension: CoCo X-SID (MOS 8580) playback support.
*
* The X-SID lives in an MPI slot.  Software routes the SCS bus to it
* by writing $30 to $FF7F (bits 0-1 = SCS slot-1, bits 4-5 = CTS slot-4
* so the FDC ROM stays accessible).  Default routing is restored with
* $FF.  While SCS is pointed at the SID, an FDC IRQ that reads FDC
* status at $FF48 would instead hit the SID, so every SID register
* burst is wrapped in an interrupt-masked critical section.  The SID
* sustains the tone autonomously between bursts, so we keep the bursts
* very brief and let interrupts run freely the rest of the time.
*
* Register cheat-sheet (offsets from $FF40, MOS6581/8580):
*   v1 freq lo/hi   $00 / $01
*   v1 ctrl         $04   bit 0=GATE, bit 4=triangle, 5=saw, 6=pulse, 7=noise
*   v1 attack/decay $05   high nibble=A, low nibble=D
*   v1 sustain/rel  $06   high nibble=S, low nibble=R
*   v3 freq lo/hi   $0E / $0F
*   v3 ctrl/AD/SR   $12 / $13 / $14
*   OSC3 readback   $1B
*   ENV3 readback   $1C
*   filter cut lo/hi$15 / $16
*   res/filt sel    $17
*   mode + master   $18   low nibble = master volume 0-15
************************************************************************

************************************************************************
* SidProbe - detect whether the X-SID is reachable through MPI slot 1.
*   Strategy (ENV3 envelope-readback detection):
*     1. Mask IRQs, select MPI slot 1, zero all 25 SID write registers.
*     2. Read ENV3 ($FF5C).  On a real SID it must be 0 (we just zeroed
*        every register and the envelope hasn't been gated).  Anything
*        else (floating bus = $FF, junk = non-zero) means no SID.
*     3. Set master volume max, gate voice 3 with A=0 (fastest attack)
*        and S=$F at a mid-range frequency.
*     4. Spin ~22 ms (>> 2 ms attack time) for envelope to climb to peak.
*     5. Re-read ENV3.  Must be >= $80 (envelope at or near peak).
*        $00 or low values mean no SID is driving the bus.
*     6. Cache result in SidPresent:  $01 = present, $FF = absent.
*     7. Zero registers again to silence v3, restore MPI routing.
*   Cost: ~25 ms of busy-loop on first PlaySound call only.
*   Caveat: on a CoCo3 *without* MPI (FDC card directly in cart slot),
*           the $FF40-$FF5F writes during step 1 land on the FDC, which
*           briefly disturbs disk-controller state (the final $FF48 = $00
*           = "restore" command moves the head to track 0 - benign but
*           audible if heads aren't already there).  The probe still
*           correctly detects absence and falls back to the DAC path.
*   Clobbers: A, B, X, Y.
************************************************************************
SidProbe            pshs      cc,a,b,x,y
                    orcc      #IntMasks
                    lda       #$30                ; SCS=slot1, CTS=slot4
                    sta       >$FF7F

* Zero all 25 SID write registers ($FF40-$FF58).  Wipes any power-on
* noise so the readback in step 2 has a known starting state.
                    ldx       #$FF40
                    ldb       #25
SidProbeZero1       clr       ,x+
                    decb
                    bne       SidProbeZero1

* Step 2: after zeroing, ENV3 must be 0 on a real SID.
                    lda       >$FF5C
                    bne       SidProbeAbsent      ; non-zero = no SID

* Step 3: set up voice 3 to ramp envelope to peak instantly.
                    lda       #$0F                ; master vol max so ENV3
                    sta       >$FF58              ; readback isn't masked
                    clr       >$FF53              ; v3 AD: A=0 (fastest), D=0
                    lda       #$F0                ; v3 SR: S=15 (peak), R=0
                    sta       >$FF54
                    lda       #$D6                ; v3 freq lo (~440 Hz)
                    sta       >$FF4E
                    lda       #$1C                ; v3 freq hi
                    sta       >$FF4F
                    lda       #$11                ; v3 ctrl: triangle + gate
                    sta       >$FF52

* Step 4: spin ~22 ms (4096 iterations * ~5 cycles @ 0.89 MHz).
                    ldx       #$1000
SidProbeSpin        leax      -1,x
                    bne       SidProbeSpin

* Step 5: ENV3 must now be near peak (>= $80).  Anything less means
* either the SID isn't really there or the bus is returning garbage.
                    lda       >$FF5C
                    cmpa      #$80
                    blo       SidProbeAbsent

* Step 6: present.
                    lda       #$01
                    bra       SidProbeDone
SidProbeAbsent      lda       #$FF
SidProbeDone        sta       >SidPresent,pcr

* Step 7: cleanup.  Zero registers again to silence v3 (envelope was
* gated above) and restore the default MPI routing so the FDC sees a
* normal $FF7F state when interrupts re-enable.
                    ldx       #$FF40
                    ldb       #25
SidProbeZero2       clr       ,x+
                    decb
                    bne       SidProbeZero2

                    lda       #$FF                ; restore default MPI routing
                    sta       >$FF7F
                    puls      cc,a,b,x,y,pc

************************************************************************
* SidSetupVoice1 - one-time per PlaySound call: set master volume and
*   voice-1 envelope parameters.  Called only when SidPresent = 1.
*   Clobbers nothing (saves CC + A).
************************************************************************
SidSetupVoice1      pshs      cc,a
                    lda       >SidPresent,pcr
                    cmpa      #$01                ; no-op if SID absent
                    bne       SidSetupV1Out
                    orcc      #IntMasks
                    lda       #$30
                    sta       >$FF7F
                    lda       #$0F                ; master volume max, no filter
                    sta       >$FF58
                    lda       #$00                ; v1 AD: A=0, D=0 (no decay
                    sta       >$FF45              ; ramp - stay at peak)
                    lda       #$F0                ; v1 SR: S=15 (peak), R=0
                    sta       >$FF46              ; (matches DAC's constant-
                                                  ;  amplitude square wave)
                    clr       >$FF44              ; v1 ctrl=0 (no waveform yet)
                    lda       #$FF
                    sta       >$FF7F
SidSetupV1Out       puls      cc,a,pc

************************************************************************
* SidGateForNote - called inside the PlaySound loop right after the
*   half-period and wave-count have been looked up.  If SID is present,
*   gates voice 1 to this note's pitch (using SidFreqTable indexed by
*   B = note*2), or gates off if the note byte at -3,u is 0 (silent).
*   No-op if SidPresent != 1.
*   Inputs: B = note*2 (caller did lslb before this call).
*           U = stream pointer (3 bytes past the note byte).
*   Preserves: all registers (saves CC + A + B + X).
************************************************************************
SidGateForNote      pshs      cc,a,b,x
                    lda       >SidPresent,pcr
                    cmpa      #$01                ; no-op if SID absent
                    bne       SidGateOut
                    tst       -3,u                ; amp == 0 -> hold previous note
                    beq       SidGateOut          ; (mimic original DAC behavior:
                                                  ;  silence by holding last state,
                                                  ;  not by gate-off or mute)
                    ldb       -4,u                ; recover original note index
                    cmpb      #$FF                ; defensive: end byte
                    beq       SidGateOut
                    cmpb      #121                ; clamp to table size (122 entries)
                    bls       SidGateN_OK
                    ldb       #121
SidGateN_OK         orcc      #IntMasks
                    lda       #$30
                    sta       >$FF7F
* Waveform decision: noise ($81) for very-high SFX notes, triangle
* ($11) otherwise.  Music tops out around note 60; SFX uses 60-121.
* Threshold 100 keeps mid-range tonal SFX (whistles, beeps) on
* triangle while routing the percussive top of the table to noise.
* Sustain is left at SidSetupVoice1's $F0 (peak) - per-note amp
* scaling sounded too quiet because the music's amp byte is ~$30.
                    pshs      b                   ; save note index
                    lslb                          ; doubled for fdb table
                    leax      >SidFreqTable,pcr
                    abx
                    ldd       ,x                  ; A=hi, B=lo
                    sta       >$FF41              ; v1 freq hi (write hi FIRST per
                                                  ; SID convention - minimizes
                                                  ; mid-cycle oscillator glitch)
                    stb       >$FF40              ; v1 freq lo
                    puls      b                   ; restore note index
                    lda       #$11                ; default: triangle + gate
                    cmpb      #100                ; high-SFX threshold
                    blo       SidGateN_Wav        ; below -> keep triangle
                    lda       #$81                ; noise + gate (idempotent if
                                                  ; already $81 -> no retrigger)
SidGateN_Wav        sta       >$FF44
                    lda       #$FF
                    sta       >$FF7F
SidGateOut          puls      cc,a,b,x,pc

************************************************************************
* SidStopVoice - gate voice 1 off (envelope enters release phase).
*   Called at PlaySoundEnd.  No-op if SidPresent != $01.
*   Preserves: all registers (saves CC + A).
************************************************************************
SidStopVoice        pshs      cc,a
                    lda       >SidPresent,pcr
                    cmpa      #$01                ; no-op if SID absent
                    bne       SidStopOut
                    orcc      #IntMasks
                    lda       #$30
                    sta       >$FF7F
                    lda       #$10                ; triangle, gate=0
                    sta       >$FF44
                    lda       #$FF
                    sta       >$FF7F
SidStopOut          puls      cc,a,pc

************************************************************************
* XSID Phase 2: polyphonic 3-voice playback
*
* Adds a parallel playback path that consumes pre-extracted sidDir/sidSnd
* sidecar files (built by tools/agi_sid_extract.py from the upstream PC
* AGI sound resources).  Each on-disk sound# may have a polyphonic SID
* stream; if so, this path plays it via 60 Hz F$Sleep ticks and three
* voices.  If not, the engine falls through to the Phase 1 mono SID path
* (or Phase 0 DAC bit-bang on non-SID systems).
*
* Memory layout: SidDirBuf (404 bytes = 101 entries x 4 BE bytes) plus
* three per-voice ring buffers (SidV1Buf=768, SidV2Buf=768, SidV3Buf=512;
* total 2 KB) are statically reserved in the module body.  Total mnln
* size is constrained to under ~29.5 KB by an empirical Sierra MMU
* loader cliff (see checkpoint 014).
*
* Phase 2.5 streaming model: the polyphonic stream is NOT pre-loaded.
* Instead each voice's bytes are streamed in via I$Read on demand into
* its per-voice ring buffer.  This removes the prior 2 KB / 8 KB
* whole-stream-must-fit cap and lets title music (5-12 KB) play
* polyphonic without a per-stream memory ceiling.
*
* Per-game sidDir sizes are NOT fixed at 404 bytes - each game's SNDDIR
* dictates a slot count (SQ2=70, KQ3=40, SQ0=101, ...).  The engine
* handles this by accepting any read length up to 404 bytes; the
* statically zeroed SidDirBuf leaves unread entries at length=0 which
* SidLookup interprets as "absent".
************************************************************************

SidDirSize          equ       404                 ; 101 max-slot entries x 4 BE bytes
SidMaxStream        equ       16384               ; matches /sid driver SidBufSize
SidChunkSize        equ       512                 ; chunked-write transfer unit
* XSID Phase D (chunked-write): /sid driver SetStt/GetStt codes
SS.SidPrep          equ       $93                 ; reset+set total length (was SS.SidLoad)
SS.SidStart         equ       $94                 ; begin playback
SS.SidStop          equ       $95                 ; halt playback
SS.SidActv          equ       $96                 ; query active state
SS.SidWrite         equ       $97                 ; F$Move one chunk into driver buffer

* --------------------------------------------------------------------
* SidStartupInit
*   Called once from end of LoadAllDirs.  Probes for X-SID and, if
*   present, loads sidDir + opens sidSnd persistently.  Silent on
*   absence/failure (engine falls back to mono).
* --------------------------------------------------------------------
SidStartupInit      lbsr      SidProbe
                    lda       >SidPresent,pcr
                    cmpa      #$01
                    bne       SSI_Done
                    lbsr      SidLoadDirAndOpen
SSI_Done            rts

* --------------------------------------------------------------------
* SidLoadDirAndOpen
*   Opens sidDir read-only, slurps 404 bytes into SidDirBuf, closes
*   sidDir, then opens sidSnd read-only and stashes the path number
*   in SidSndPath.  Uses raw OS9 syscalls (NOT the OpenFile/ReadFile
*   wrappers) so missing files are silent — disks without sidcar
*   files just skip poly support without user-visible error.
*   Sets SidLoaded = $01 on success, $FF on failure.
* --------------------------------------------------------------------
SidLoadDirAndOpen   lda       >SidLoaded,pcr
                    bne       SLDO_Already        ; already attempted
                    lda       #$01                ; read mode
                    leax      >StrSidDir,pcr
                    os9       I$Open
                    bcs       SLDO_Fail           ; no sidDir on this disk
                    pshs      a                   ; save path number
                    leax      >SidDirBuf,pcr
                    ldy       #SidDirSize
                    os9       I$Read              ; Y = bytes read
                    puls      a                   ; restore path
                    pshs      cc                  ; save read status
                    os9       I$Close             ; close sidDir
                    puls      cc
                    bcs       SLDO_Fail
                    cmpy      #4                  ; at least one entry?
                    blo       SLDO_Fail           ; (entries are 4 BE bytes each;
                                                  ;  short reads are OK because
                                                  ;  SidDirBuf is statically zeroed
                                                  ;  and SidLookup treats length=0
                                                  ;  as absent.  Per-game slot
                                                  ;  counts vary: SQ0=101, SQ2=70,
                                                  ;  KQ3=40, etc.)
                    lda       #$01                ; read mode
                    leax      >StrSidSnd,pcr
                    os9       I$Open
                    bcs       SLDO_Fail
                    sta       >SidSndPath,pcr     ; persistent path
* XSID Phase D: open /sid driver (non-fatal if absent -> falls
* back to user-mode mono+SID path on PlaySound).
                    lda       #UPDAT.
                    leax      >StrSidDev,pcr
                    os9       I$Open
                    bcs       SLDO_NoSidDev
                    sta       >SidDevPath,pcr
SLDO_NoSidDev
                    lda       #$01
                    sta       >SidLoaded,pcr
SLDO_Already        rts
SLDO_Fail           lda       #$FF
                    sta       >SidLoaded,pcr
                    rts

* --------------------------------------------------------------------
* SidLookup
*   Input:  B = sound number (0..100)
*   Output: CC.C = 0 if present (X = byte offset in sidSnd,
*                                 Y = byte length to read)
*           CC.C = 1 if absent or oversize
*   Clobbers: A, B, X, Y
* --------------------------------------------------------------------
SidLookup           pshs      b
                    lda       >SidLoaded,pcr
                    cmpa      #$01
                    bne       SLU_Absent
                    ldb       ,s                  ; reload sound#
                    cmpb      #101
                    bhs       SLU_Absent
                    clra
                    aslb
                    rola
                    aslb
                    rola                          ; D = sound# * 4
                    leax      >SidDirBuf,pcr
                    leax      d,x                 ; X = entry ptr
                    ldy       2,x                 ; Y = length (BE word)
                    beq       SLU_Absent
                    cmpy      #SidMaxStream       ; sanity (16-bit file offset)
                    bhi       SLU_Absent
                    cmpy      #9                  ; need header + >=1 data byte
                    blo       SLU_Absent
                    ldd       ,x                  ; D = offset (BE word)
                    cmpd      #$FFFF              ; absent marker?
                    beq       SLU_Absent
                    tfr       d,x                 ; X = offset
                    puls      b
                    andcc     #$FE                ; CC.C = 0 success
                    rts
SLU_Absent          puls      b
                    orcc      #$01                ; CC.C = 1
                    rts

* --------------------------------------------------------------------
* SidPlayDispatch
*   Input:  B = sound number
*   Output: CC.C = 0 if polyphonic stream played to completion
*           CC.C = 1 if no poly stream available (caller falls back)
*   This is the integration point from PlaySound.
* --------------------------------------------------------------------
SidPlayDispatch     pshs      a,x,y,u
                    lbsr      SidLookup
                    bcs       SPD_Miss
                    lbsr      SidPlayPoly         ; X=file offset, Y=length
                    bcs       SPD_Miss
                    puls      a,x,y,u
                    andcc     #$FE
                    rts
SPD_Miss            puls      a,x,y,u
                    orcc      #$01
                    rts

* --------------------------------------------------------------------
* SidPlayPoly  (XSID Phase D — /sid driver client, chunked-write)
*   Inputs:  X = file offset of stream within sidSnd
*            Y = total stream length in bytes
*   Output:  CC.C = 0 stream played to completion via /sid driver
*            CC.C = 1 init failed (caller falls back to mono+SID)
*
*   Tells the driver to allocate (SS.SidPrep), seeks sidSnd to the
*   requested offset, streams the data into the driver in 512-byte
*   chunks via I$Read into SidChunkBuf + SS.SidWrite, kicks playback
*   with SS.SidStart, and polls SS.SidActv with F$Sleep until the
*   driver auto-stops.
*
*   The 3-voice ring-buffer engine and per-voice state structs that
*   previously lived in this module are GONE -- that work is now done
*   in IRQ context by sidirq.dr (loaded via OS9Boot).  The previous
*   one-shot F$Mem path was replaced because F$Mem-grown buffers can
*   collide with sierra.asm's manually-poked task-1 MMU slots and
*   corrupt mnln's own code; see the sidirq.asm header comment.
* --------------------------------------------------------------------
SidPlayPoly         pshs      a,b,x,y,u
* Stack frame after pshs (S+0..S+7):
*    0,s = a, 1,s = b
*    2,s = x_hi (stream offset hi)
*    3,s = x_lo
*    4,s = y_hi (stream length hi)
*    5,s = y_lo
*    6,s = u_hi
*    7,s = u_lo

* --- Driver must have been opened at startup ---
                    lda       >SidDevPath,pcr
                    cmpa      #$FF
                    lbeq      SPP_Fail

* --- Stream must fit driver buffer and carry at least a header ---
                    ldd       4,s                 ; length
                    cmpd      #SidMaxStream
                    lbhi      SPP_Fail
                    cmpd      #9                  ; driver requires hdr+>=1 byte
                    lblo      SPP_Fail

* --- Tell driver the total length; resets WritePos=0 ---
                    ldy       4,s                 ; R$Y = stream length
                    lda       >SidDevPath,pcr
                    ldb       #SS.SidPrep
                    os9       I$SetStt
                    lbcs      SPP_Fail

* --- Seek sidSnd to start of this stream ---
                    ldx       2,s                 ; X = file offset
                    tfr       x,u                 ; U = offset low
                    ldx       #$0000              ; X = offset high
                    clrb                          ; absolute seek
                    lda       >SidSndPath,pcr
                    os9       I$Seek
                    lbcs      SPP_StopErr

* --- Chunked read/write loop ---
*   Push remaining = stream_length onto the stack.  All access to the
*   original a,b,x,y,u frame shifts by +2 while the loop runs (so the
*   length is at 6,s instead of 4,s, etc).  After the loop the extra
*   word is popped to restore the original frame for the existing
*   poll-and-exit code below.
                    ldd       4,s                 ; D = total length
                    pshs      d                   ; [,s] = remaining

SPP_ChunkLoop       ldd       ,s                  ; D = remaining bytes still to push
                    lbeq      SPP_AllWritten
                    cmpd      #SidChunkSize
                    bls       SPP_ChunkOK         ; remaining <= chunk size
                    ldd       #SidChunkSize
SPP_ChunkOK         tfr       d,y                 ; Y = bytes to read this iteration
                    leax      >SidChunkBuf,pcr    ; X = read destination
                    lda       >SidSndPath,pcr
                    os9       I$Read
                    lbcs      SPP_ChunkErr
                    cmpy      #0
                    lbeq      SPP_ChunkErr        ; EOF before total bytes consumed

* Y = actual bytes read (may be < requested for a short read).
* Push that many bytes into the driver via SS.SidWrite.  The driver
* does NOT modify the caller's R$Y, so Y is still valid afterward.
                    leax      >SidChunkBuf,pcr    ; R$X = src in caller task
                    lda       >SidDevPath,pcr
                    ldb       #SS.SidWrite
                    os9       I$SetStt
                    lbcs      SPP_ChunkErr

* Update remaining -= Y (=bytes actually written this iteration).
                    pshs      y                   ; [,s] = count, [2,s] = remaining
                    ldd       2,s                 ; D = remaining
                    subd      ,s                  ; D = remaining - count
                    std       2,s                 ; updated remaining
                    leas      2,s                 ; pop count
                    bra       SPP_ChunkLoop

SPP_ChunkErr        leas      2,s                 ; pop remaining
                    lbra      SPP_StopErr

SPP_AllWritten      leas      2,s                 ; pop remaining; original frame restored

* --- Start playback ---
                    lda       >SidDevPath,pcr
                    ldb       #SS.SidStart
                    os9       I$SetStt
                    bcs       SPP_StopErr

* --- Poll SS.SidActv until LoadState != 2 ---
* Bound the wait so a buggy driver or runaway stream can't hang the
* engine.  $1200 polls * 83 ms = ~404 s (6.7 min), comfortably above
* the longest known SQ0 cue (~116 s).
                    ldx       #$1200              ; max-polls counter
                    pshs      x
SPP_Poll            ldx       #$0006              ; ~83 ms per poll
                    os9       F$Sleep
                    lda       >SidDevPath,pcr
                    ldb       #SS.SidActv
                    os9       I$GetStt
                    bcs       SPP_PollErr
                    cmpx      #$0002              ; still playing?
                    bne       SPP_PollOK
                    ldx       ,s
                    leax      -1,x
                    stx       ,s
                    bne       SPP_Poll
* Timeout: force stop and report failure to caller.
                    leas      2,s
                    bra       SPP_StopErr
SPP_PollErr         leas      2,s
                    bra       SPP_StopErr
SPP_PollOK          leas      2,s
                    puls      a,b,x,y,u
                    andcc     #$FE
                    rts

* On any failure after SS.SidPrep succeeded, ask driver to stop before
* returning failure so mono+SID fallback doesn't fight stale driver
* state.  SS.SidStop is a safe no-op when not currently playing.
SPP_StopErr         lda       >SidDevPath,pcr
                    ldb       #SS.SidStop
                    os9       I$SetStt
SPP_Fail            puls      a,b,x,y,u
                    orcc      #$01
                    rts


* --------------------------------------------------------------------
* XSID Phase 2.5 streaming state and buffers
*   Placed at the end of the SID code block, well away from
*   SidPresent (line ~9332), to avoid the lwasm PCR-offset
*   regression observed in Phase 1.
*
*   Per-voice 12-byte state struct layout (matches code's offset usage):
*     +0  FilePos    fdb   ; next file byte to read (16-bit, BE word)
*     +2  FileEnd    fdb   ; one past last file byte for this voice
*     +4  Ptr        fdb   ; next byte to consume in ring buffer
*     +6  Avail      fdb   ; bytes still available starting at Ptr
*     +8  Tick       fdb   ; ticks remaining in current note
*     +10 MaskBit    fcb   ; SidVoiceMask bit (1, 2, or 4)
*     +11 SidOff     fcb   ; offset added to $FF40 (0, 7, or 14)
* --------------------------------------------------------------------
SidLoaded           fcb       0                   ; 0=uninit, 1=ready, $FF=fail
SidCurSound         fcb       0                   ; sound# captured at PlaySound
SidSndPath          fcb       0                   ; persistent sidSnd path number
SidDevPath          fcb       $FF                 ; /sid path ($FF=not open -> mono fallback)

SidDirBuf           fill      0,SidDirSize        ; 101 entries x 4 BE bytes (max)
SidChunkBuf         fill      0,SidChunkSize      ; per-chunk read buffer for SS.SidWrite


StrNothing          fcc       /nothing/
                    fcb       0
StrYouAreCarrying   fcc       /You are carrying:/
                    fcb       0
StrEnterToSelect    fcc       'ENTER to select / CTRL-BREAK to cancel'
                    fcb       0
StrPressKeyReturn   fcc       /Press a key to return to the game/
                    fcb       0
StrScoreFmt         fcc       /Score:%d of %d  /
                    fcb       0
StrSoundFmt         fcc       /Sound: %s/
                    fcb       0
                    fcb       0,0,0
StrOn               fcc       /on /
                    fcb       0

StrOff              fcc       /off/
                    fcb       0

*
*======================================================================
* INVENTORY AND STATUS LINE
*   cmd_status displays the full inventory screen (InventoryDraw,
*   InventoryListDraw, InventoryMoveCursor); StatusLineWrite updates
*   the score/sound status bar; cmd_status_line_on/off toggle it.
*======================================================================
*
cmd_status          lbsr      InputEditOn ; ensure cursor is not shown
                    lbsr      PushTextColor ; save current text color
                    clra                ; foreground = black
                    ldb       #$0F      ; background = bright white
                    lbsr      text_color ; set inventory text colors
CmdStatusTextMode   lbsr      cmd_text_screen ; switch to text mode
                    bsr       InventoryDraw ; display and run inventory screen
                    lbsr      PopTextColor ; restore previous text color
                    lbsr      SetGraphicsMode ; switch back to graphics mode
                    rts

InventoryDraw       leas      >-$0105,s ; allocate 261-byte local frame
                    lda       #$02      ; column 2 = right-column start
                    sta       ,s        ; initialize column counter
InventoryDrawInit   leax      $04,s     ; X = item list buffer start
                    stx       $02,s     ; save current item pointer
                    stx       >$00FE,s  ; save default selected item
                    ldu       <$0038    ; U = base of object array
                    clra                ; item counter = 0
                    sta       $01,s     ; clear row counter
InventoryItemLoop   sta       >$0100,s  ; save current item index
                    stu       >$0101,s  ; save object pointer
                    cmpu      <$003C    ; past end of objects?
                    bcc       InventoryCheckEmpty ; branch if done scanning
                    ldb       $02,u     ; get object room number
                    cmpb      #$FF      ; in inventory ($FF)?
                    bne       InventoryItemAdvance ; skip if not in inventory
                    sta       ,x        ; store item index in list entry
                    cmpa      >$044A    ; is this the selected item?
                    bne       InventoryItemSetup ; branch if not selected
                    stx       >$00FE,s  ; mark as currently highlighted
InventoryItemSetup  ldd       ,u        ; object name pointer
                    std       $01,x     ; store name pointer in entry
                    lda       ,s        ; column counter
                    sta       $03,x     ; store column in entry
                    ldb       $01,s     ; row counter
                    bitb      #$01      ; odd row?
                    bne       InventoryItemFormat ; branch if odd (right column)
                    lda       #$01      ; row offset for left column
                    sta       $04,x     ; store column-1 offset
                    bra       InventoryItemNext ; proceed to next item
InventoryItemFormat inca                ; increment column counter
                    sta       ,s        ; update column counter
                    stx       $02,s     ; update current item pointer
                    ldx       $01,x     ; get item name pointer
                    lbsr      StrLen    ; get length of name string
                    ldx       $02,s     ; restore item pointer
                    negb                ; negate length
                    addb      #$27      ; 39 - length = right-column tab
                    stb       $04,x     ; store column offset
                    ldb       $01,s     ; restore row counter
InventoryItemNext   incb                ; next row
                    stb       $01,s     ; update row counter
                    leax      $05,x     ; advance item list pointer
InventoryItemAdvance leau      $03,u     ; advance to next object (3 bytes each)
                    lda       >$0100,s  ; restore item index
                    inca                ; increment index
                    bra       InventoryItemLoop ; process next object
InventoryCheckEmpty lda       $01,s     ; row count
                    bne       InventoryDisplayItems ; branch if any items found
                    sta       ,x        ; store zero item index
                    leau      >StrNothing,pcr ; "nothing" string
                    stu       $01,x     ; store as item name
                    lda       ,s        ; column counter
                    sta       $03,x     ; store column
                    lda       #$10      ; column offset 16
                    sta       $04,x     ; store offset
                    leax      $05,x     ; advance list pointer
InventoryDisplayItems leax      -$05,x    ; back up to last entry
                    stx       >$0103,s  ; save last entry pointer
                    pshs      x         ; push last entry
                    leax      $06,s     ; X = item list start
                    pshs      x         ; push first entry
                    ldx       >$0102,s  ; load selected entry pointer
                    stx       $06,s     ; save as cursor
                    pshs      x         ; push selected entry
                    lbsr      InventoryListDraw ; draw the inventory list
                    leas      $06,s     ; discard args
InventoryWaitKey    lbsr      WaitForEvent ; wait for player input
                    lda       >$01AF    ; game flags byte
                    anda      #$04      ; test menu/keyboard-active bit
                    beq       InventoryExit ; exit if input disabled
                    ldd       ,x        ; event type and value
                    cmpa      #$01      ; keyboard event?
                    bne       InventoryCheckJoy ; branch if not keyboard
                    cmpb      #$0D      ; Enter key?
                    bne       InventoryCheckEsc ; branch if not Enter
                    ldx       $02,s     ; currently selected entry
                    lda       ,x        ; item index at that entry
                    sta       >$044A    ; store as selected item
                    bra       InventoryExit ; exit with selection
InventoryCheckEsc   cmpb      #$1B      ; Escape key?
                    bne       InventoryWaitKey ; loop if not Escape
                    lda       #$FF      ; invalid = no selection
                    sta       >$044A    ; clear selection
                    bra       InventoryExit ; exit without selection
InventoryCheckJoy   cmpa      #$02      ; joystick event?
                    bne       InventoryWaitKey ; loop if unrecognized
                    leax      $04,s     ; item list start
                    pshs      x         ; push list start
                    pshs      b,a       ; push joystick event data
                    ldd       $06,s     ; current selected entry
                    pshs      b,a       ; push cursor
                    ldd       >$0109,s  ; last entry pointer
                    pshs      b,a       ; push last entry
                    lbsr      InventoryMoveCursor ; move cursor per joystick
                    leas      $08,s     ; discard args
                    stx       $02,s     ; update cursor position
                    bra       InventoryWaitKey ; continue loop
InventoryExit       clra                ; clear A
                    sta       >$0154    ; clear input-mode flag
                    sta       >$0547    ; clear cursor-visible flag
                    leas      >$0105,s  ; release local frame
                    rts

InventoryListDraw   leas      -$04,s    ; allocate 4-byte local frame
                    lda       #$00      ; row = 0
                    ldb       #$0B      ; column = 11
                    std       <$0040    ; set cursor to row 0, col 11
                    leau      >StrYouAreCarrying,pcr ; "You are carrying:" header
                    pshs      u         ; push header string
                    lbsr      PrintFmtStrToScr ; print header
                    leas      $02,s     ; discard arg
                    ldx       $08,s     ; X = first item entry
InventoryListLoop   stx       ,s        ; save current entry pointer
                    cmpx      $0A,s     ; past last entry?
                    bhi       InventoryListDone ; branch if past end
                    ldd       $03,x     ; row and column for this item
                    std       <$0040    ; set cursor position
                    clra                ; foreground = black
                    ldb       #$0F      ; background = white
                    std       $02,s     ; default (normal) colors
                    cmpx      $06,s     ; is this the highlighted entry?
                    bne       InventoryListHighlight ; branch if not
                    lda       >$01AF    ; game flags byte
                    anda      #$04      ; check keyboard-active bit
                    beq       InventoryListHighlight ; skip highlight if inactive
                    lda       #$0F      ; foreground = white
                    clrb                ; background = black (inverted)
                    std       $02,s     ; store highlight colors
InventoryListHighlight ldd       $02,s     ; load display colors
                    lbsr      text_color ; apply text color
                    ldx       ,s        ; restore entry pointer
                    ldx       $01,x     ; get item name pointer
                    pshs      x         ; push name string
                    lbsr      PrintFmtStrToScr ; print item name
                    leas      $02,s     ; discard arg
                    ldx       ,s        ; restore entry pointer
                    leax      $05,x     ; advance to next entry
                    bra       InventoryListLoop ; process next item
InventoryListDone   clra                ; foreground = black
                    ldb       #$0F      ; background = white
                    lbsr      text_color ; restore normal text color
                    lda       >$01AF    ; game flags byte
                    anda      #$04      ; check keyboard-active bit
                    beq       InventoryListFooter ; branch if keyboard inactive
                    lda       #$01      ; set input-mode flag
                    sta       >$0154    ; mark input active
                    lda       #$03      ; set cursor-visible flag
                    sta       >$0547    ; enable cursor blink
                    lda       #$17      ; row 23 (last text row)
                    ldb       #$01      ; column 1
                    std       <$0040    ; position cursor at bottom-left
                    leax      >StrEnterToSelect,pcr ; "ENTER to select..." prompt
                    bra       InventoryListFooterPrint ; print it
InventoryListFooter lda       #$17      ; row 23
                    ldb       #$04      ; column 4
                    std       <$0040    ; position cursor
                    leax      >StrPressKeyReturn,pcr ; "Press a key..." prompt
InventoryListFooterPrint pshs      x         ; push prompt string
                    lbsr      PrintFmtStrToScr ; print footer prompt
                    leas      $02,s     ; discard arg
                    leas      $04,s     ; release local frame
                    rts

InventoryMoveCursor ldu       $04,s     ; U = item list start pointer
                    tfr       u,x       ; X = current position (default)
                    lda       $07,s     ; joystick direction code
                    cmpa      #$01      ; up?
                    bne       InventoryMoveDown ; branch if not up
                    leax      -$0A,x    ; move back 2 entries (10 bytes)
                    bra       InventoryMoveCheck ; validate position
InventoryMoveDown   cmpa      #$03      ; down?
                    bne       InventoryMovePageDown ; branch if not down
                    leax      $05,x     ; move forward 1 entry (5 bytes)
                    bra       InventoryMoveCheck ; validate position
InventoryMovePageDown cmpa      #$05      ; page down?
                    bne       InventoryMovePageUp ; branch if not page-down
                    leax      $0A,x     ; move forward 2 entries
                    bra       InventoryMoveCheck ; validate position
InventoryMovePageUp cmpa      #$07      ; page up?
                    bne       InventoryMoveRet ; ignore other directions
                    leax      -$05,x    ; move back 1 entry
InventoryMoveCheck  cmpx      $08,s     ; before first entry?
                    bcs       InventoryMoveClamp ; clamp if too low
                    cmpx      $02,s     ; past last entry?
                    bls       InventoryMoveSwap ; valid position — swap highlight
InventoryMoveClamp  tfr       u,x       ; revert to original position
                    bra       InventoryMoveRet ; return unchanged
InventoryMoveSwap   pshs      x         ; push new selected entry
                    pshs      u         ; push old selected entry
                    lbsr      InventorySwapHighlight ; swap highlight between entries
                    leas      $04,s     ; discard args
InventoryMoveRet    rts

InventorySwapHighlight lda       #$0F      ; foreground = white
                    clrb                ; background = black (highlight)
                    lbsr      text_color ; set highlight color
                    ldu       $04,s     ; old (de-selected) entry
                    ldd       $03,u     ; row and column for old entry
                    std       <$0040    ; position cursor
                    ldd       $01,u     ; name pointer for old entry
                    pshs      b,a       ; push name string
                    lbsr      PrintFmtStrToScr ; redraw old item (highlighted)
                    leas      $02,s     ; discard arg
                    clra                ; foreground = black
                    ldb       #$0F      ; background = white (normal)
                    lbsr      text_color ; restore normal color
                    ldu       $02,s     ; new (selected) entry
                    ldd       $03,u     ; row and column for new entry
                    std       <$0040    ; position cursor
                    ldd       $01,u     ; name pointer for new entry
                    pshs      b,a       ; push name string
                    lbsr      PrintFmtStrToScr ; draw new item (normal)
                    leas      $02,s     ; discard arg
                    ldx       $04,s     ; return new selected entry in X
                    rts

StatusLineWrite     lda       >$0246    ; status-line-enabled flag
                    beq       StatusLineWriteRet ; skip if status line is off
                    lbsr      PushRowCol ; save current cursor position
                    lbsr      PushTextColor ; save current text color
                    lda       >$0247    ; status line row number
                    ldb       #$0F      ; full-width clear (color 15)
                    lbsr      ClearTextLine ; erase the status line
                    clra                ; foreground = black
                    ldb       #$0F      ; background = white
                    lbsr      text_color ; set status line colors
                    lda       >$0247    ; status line row
                    ldb       #$01      ; column 1
                    std       <$0040    ; position cursor for score
                    clra                ; A = 0 (high byte for score)
                    ldb       >$0438    ; current score value
                    pshs      b,a       ; push score arg
                    ldb       >$0434    ; max score value
                    leax      >StrScoreFmt,pcr ; "Score:%d of %d  " format
                    pshs      b,a       ; push max score arg
                    pshs      x         ; push format string
                    lbsr      PrintFmtStrToScr ; print score display
                    leas      $06,s     ; discard args
                    ldb       #$1E      ; column 30 (sound label position)
                    stb       <$0041    ; set cursor column
                    leau      >StrOff,pcr ; assume "off" for sound status
                    lda       >$01AF    ; game flags byte
                    anda      #$40      ; test sound-enabled bit
                    beq       StatusLineSoundLabel ; branch if sound disabled
                    lda       >$0172    ; check silent flag
                    bne       StatusLineSoundLabel ; branch if silenced
                    leau      >StrOn,pcr ; sound is actually on
StatusLineSoundLabel leax      >StrSoundFmt,pcr ; "Sound: %s" format
                    pshs      u         ; push on/off string
                    pshs      x         ; push format string
                    lbsr      PrintFmtStrToScr ; print sound status
                    leas      $04,s     ; discard args
                    lbsr      PopTextColor ; restore text color
                    lbsr      PopRowCol ; restore cursor position
StatusLineWriteRet  rts

cmd_status_line_on  lda       #$01      ; enabled flag
                    sta       >$0246    ; enable status line
                    bsr       StatusLineWrite ; draw status line now
                    rts

cmd_status_line_off clr       >$0246    ; disable status line
                    lda       >$0247    ; status line row
                    clrb                ; column 0
                    lbsr      ClearTextLine ; erase the status line
                    rts

StrPunctuation      fcc       / .,;:'!-/
                    fcb       0

*
*======================================================================
* STRING INPUT AND EDITING
*   cmd_get_string prompts the player for a text string and calls
*   EditString to handle character-by-character input with backspace
*   and Escape support; cmd_set_string copies a literal string into a
*   slot; cmd_word_to_string copies a parsed word into a string slot.
*======================================================================
*
cmd_get_string      leas      >-$0197,s ; allocate 407-byte local frame
                    lda       >$05B9    ; current cursor-blink state
                    sta       ,s        ; save cursor state
                    lbsr      PushRowCol ; save cursor position
                    lbsr      InputEditOn ; ensure cursor is erased
                    lda       ,y+       ; fetch string slot index
                    ldb       #$28      ; 40 chars per slot
                    mul                 ; offset = slot × 40
                    ldx       #$0251    ; base of string table
                    leax      d,x       ; point to this string slot
                    stx       $01,s     ; save string destination pointer
                    lda       ,y+       ; fetch string attribute number
                    sta       $05,s     ; save attribute
GetStringReadArgs   ldd       ,y++      ; fetch row and column
                    std       $03,s     ; save cursor position
                    lda       ,y+       ; fetch maximum string length
                    inca                ; add 1 to include null terminator
                    cmpa      #$28      ; longer than 40 chars?
                    bls       GetStringMaxLen ; branch if within limit
                    lda       #$28      ; clamp to 40 characters
GetStringMaxLen     sta       >$0196,s  ; store max length
                    clr       ,x        ; clear target string slot
                    ldd       $03,s     ; get cursor row/col
                    cmpa      #$18      ; row >= 24 (off-screen)?
GetStringCheckRow   bcc       GetStringShowMsg ; don't move cursor if off-screen
                    std       <$0040    ; move cursor to prompt position
GetStringShowMsg    ldb       $05,s     ; string attribute number
                    lbsr      GetMsgPtr ; get message text pointer
                    leax      $06,s     ; X = local format buffer
                    ldd       #$0028    ; max 40 chars
                    pshs      b,a       ; push max length
                    pshs      u         ; push message text pointer
                    pshs      x         ; push output buffer
                    lbsr      MsgTextSetup ; prepare message text
                    leas      $06,s     ; discard args
                    pshs      x         ; push formatted prompt
                    lbsr      PrintFmtStrToScr ; print prompt to screen
                    leas      $02,s     ; discard arg
                    ldb       >$0196,s  ; max input length
                    ldx       $01,s     ; destination string buffer
                    bsr       EditString ; run string editor
                    lbsr      PopRowCol ; restore cursor position
                    lda       ,s        ; saved cursor-blink state
                    beq       GetStringDone ; skip blink restore if was off
                    lbsr      InputCursorBlink ; restore cursor blink
GetStringDone       leas      >$0197,s  ; release local frame
                    rts

cmd_set_string      lda       ,y+       ; fetch destination string slot
                    ldb       #$28      ; 40 chars per slot
                    mul                 ; offset = slot × 40
                    ldx       #$0251    ; base of string table
                    leax      d,x       ; point to destination slot
                    ldb       ,y+       ; fetch source message number
                    lbsr      GetMsgPtr ; get message text pointer in U
                    exg       u,x       ; X=msg ptr, U=dest slot
                    ldd       #$0028    ; max 40 chars
                    lbsr      MemCopyNull ; copy message text into string slot
                    rts

cmd_word_to_string  lda       ,y+       ; fetch destination string slot
                    ldb       #$28      ; 40 chars per slot
                    mul                 ; offset = slot × 40
                    ldu       #$0251    ; base of string table
                    leau      d,u       ; point to destination slot
                    ldb       ,y+       ; fetch vocabulary word index
                    lslb                ; double B for 2-byte pointer index
                    ldx       #$0180    ; base of word-string pointer table
                    ldx       b,x       ; dereference to get word string
                    ldd       #$0028    ; max 40 chars
                    lbsr      MemCopyNull ; copy word into string slot
                    rts

EditString          leas      <-$2F,s   ; allocate 47-byte local frame
                    stx       ,s        ; save target string pointer
                    cmpb      #$28      ; max length > 40?
                    bls       EditStringInit ; clamp if over limit
                    ldb       #$28      ; cap at 40 characters
EditStringInit      leax      $06,s     ; X = local edit buffer
                    abx                 ; X = end of allowed input
                    stx       $04,s     ; save end-of-buffer pointer
                    clra                ; A = 0 (null terminator)
                    ldx       ,s        ; target string pointer
                    leau      $07,s     ; local edit buffer
                    lbsr      MemCopyNull ; copy existing string into buffer
                    lbsr      StrLen    ; get current string length
                    beq       EditStringCalcPos ; skip echo if empty
                    pshs      x         ; push string to echo
                    lbsr      PrintFmtStrToScr ; echo existing content
                    leas      $02,s     ; discard arg
                    leax      $07,s     ; base of edit buffer
                    lbsr      StrLen    ; re-measure string
                    abx                 ; X = current end of string
EditStringCalcPos   stx       $02,s     ; save current edit position
                    lbsr      InputCursorBlink ; show input cursor
EditStringWait      lbsr      WaitKeyNonNull ; wait for keypress
                    sta       $06,s     ; save key pressed
                    lbsr      InputEditOn ; erase cursor before processing
                    lda       $06,s     ; restore key
                    cmpa      #$08      ; backspace?
                    bne       EditStringCtrlC ; branch if not backspace
EditStringBackspace leau      $07,s     ; base of edit buffer
                    cmpu      $02,s     ; at start (nothing to delete)?
                    bcc       EditStringContinue ; skip if already at start
                    ldu       $02,s     ; current edit position
                    leau      -$01,u    ; back up one character
                    stu       $02,s     ; update position
                    lbsr      PutCharToWindow ; erase char from screen
                    lda       #$08      ; backspace value
                    cmpa      $06,s     ; was original key backspace?
                    beq       EditStringContinue ; done if it was
                    bra       EditStringBackspace ; clear again for Ctrl-C
EditStringCtrlC     cmpa      #$03      ; Ctrl-C?
                    bne       EditStringEnter ; branch if not Ctrl-C
                    lda       #$08      ; treat as repeated backspace
                    bra       EditStringBackspace ; clear all characters
EditStringEnter     cmpa      #$0D      ; Enter key?
                    bne       EditStringEsc ; branch if not Enter
                    ldu       $02,s     ; current edit position
                    clr       ,u        ; null-terminate the string
                    leax      $07,s     ; base of edit buffer
                    ldu       ,s        ; target string pointer
                    lbsr      StrCopy   ; copy edited string to target
                    bra       EditStringDone ; finished
EditStringEsc       cmpa      #$1B      ; Escape key?
                    beq       EditStringDone ; discard edit and exit
                    ldu       $02,s     ; current edit position
                    cmpu      $04,s     ; at max length?
                    bcc       EditStringContinue ; ignore char if buffer full
                    sta       ,u+       ; store character, advance position
                    stu       $02,s     ; update position
                    lbsr      PutCharToWindow ; echo character to screen
EditStringContinue  lbsr      InputCursorBlink ; show cursor again
                    bra       EditStringWait ; wait for next key
EditStringDone      lda       $06,s     ; last key pressed (Enter or Esc)
                    leas      <$2F,s    ; release local frame
                    rts

*
*======================================================================
* WORD MATCHING
*   cmd_set_game_id stores the game identifier string; MatchWord
*   compares two normalized words for equality; NormWord converts a
*   raw input token to lowercase with leading/trailing whitespace
*   stripped, ready for dictionary comparison.
*======================================================================
*
cmd_set_game_id     ldb       ,y+       ; fetch message number
                    lbsr      GetMsgPtr ; get game ID string pointer
                    tfr       u,x       ; X = source string
                    ldu       #$01CE    ; destination: game ID buffer
                    ldd       #$0007    ; copy up to 7 chars
                    lbsr      MemCopyNull ; copy game ID string
                    rts

MatchWord           leas      <-$53,s   ; allocate 83-byte local frame
                    stb       ,s        ; save word index (1 = word2)
                    leau      $01,s     ; first normalized word buffer
                    bsr       NormWord  ; normalize first input word
                    lda       ,s        ; second word index
                    leau      <$2A,s    ; second normalized word buffer
                    bsr       NormWord  ; normalize second input word
                    leau      $01,s     ; start of first word
                    leax      <$2A,s    ; start of second word
MatchWordLoop       lda       ,u+       ; read char from first word
                    beq       MatchWordFound ; null = end of first word
                    cmpa      ,x+       ; compare with second word char
                    beq       MatchWordLoop ; loop if chars match
                    bra       MatchWordNoMatch ; mismatch
MatchWordFound      lda       #$01      ; match result = true
                    ldb       ,x        ; remaining char in second word
                    beq       MatchWordRet ; both at null = full match
MatchWordNoMatch    clra                ; match result = false
MatchWordRet        leas      <$53,s    ; release local frame
                    rts

NormWord            leas      -$02,s    ; allocate 2-byte local frame
                    stu       ,s        ; save output buffer pointer
                    ldb       #$28      ; 40 chars per slot
                    mul                 ; offset = slot index × 40
                    ldu       #$0251    ; base of string table
                    leau      d,u       ; point to input string slot
NormWordLoop        lda       ,u+       ; read char from input
                    beq       NormWordNull ; stop at null terminator
                    leax      >StrPunctuation,pcr ; punctuation character set
                    lbsr      FindByte  ; check if char is punctuation
                    bne       NormWordLoop ; skip punctuation characters
                    lbsr      ToLower   ; convert letter to lowercase
                    ldx       ,s        ; output buffer pointer
                    sta       ,x+       ; store normalized char
                    stx       ,s        ; update output pointer
                    bra       NormWordLoop ; process next char
NormWordNull        ldx       ,s        ; output pointer at end
                    clr       ,x        ; null-terminate normalized word
                    leas      $02,s     ; release local frame
                    rts

*
*======================================================================
* TRACE AND DEBUG COMMANDS
*   cmd_hide_mouse and cmd_shake_screen are stubs for PC-specific
*   features; cmd_trace_on, TraceInit, cmd_trace_info, and TraceErase
*   implement the AGI logic-step trace display; ScriptDispatch and
*   ScriptDisplayLine replay recorded script output for debugging.
*======================================================================
*
cmd_hide_mouse      lda       ,y+       ; consume 2 args (ignored)
                    lda       ,y+       ; consume second arg (ignored)
cmd_set_upper_left  lda       ,y+       ; consume 1 arg (ignored)
cmd_shake_screen    lda       ,y+       ; consume 1 arg (ignored)
NoopCmdsRet         rts
StrTraceSep         fcc       /==========/
                    fcc       /================/
                    fcb       0
StrTraceNumNum      fcc       /%d: %d/
                    fcb       0
StrTraceNumStr      fcc       /%d: %s/
                    fcb       0
StrTraceColon       fcc       / :%c/
                    fcb       0
StrTraceNum         fcc       /%d/
                    fcb       0
StrReturn           fcc       /return/
                    fcb       0
TraceArgMode        fcb       0
TraceLineOff        fcb       1
TraceNumLines       fcb       $f
TraceWinHeight      fcb       0
TraceWinBg          fcb       0
TraceWinCol         fcb       0
TraceWinWidth       fcb       0
TraceWinPixH        fcb       0
TraceWinLastCol     fcb       0
TraceTopRow         fcb       0
TraceBottomRow      fcb       0

cmd_trace_on        lda       <$68      ; trace-active flag
                    bne       TraceOnRet ; skip if already active
                    bsr       TraceInit ; initialize trace window
TraceOnRet          rts
TraceInit           lda       <$0068    ; re-check trace flag
TraceInitCheck      bne       TraceInitRet ; already initialized
                    lda       >$01AF    ; game flags byte
                    anda      #$20      ; test trace-permitted bit
                    beq       TraceInitRet ; don't init if not permitted
                    lda       #$01      ; set trace-active flag
                    sta       <$0068    ; mark trace as running
                    lda       >$0241    ; current text screen height
                    inca                ; +1 for status line
                    adda      >TraceLineOff,pcr ; add configured line offset
                    sta       >TraceTopRow,pcr ; compute top row of trace window
                    adda      >TraceNumLines,pcr ; add number of trace lines
                    deca                ; -1 (inclusive)
                    sta       >TraceBottomRow,pcr ; compute bottom row
                    lda       #$02      ; start at column 2
                    sta       >TraceWinCol,pcr ; save left column
                    adda      #$23      ; + 35 columns
                    sta       >TraceWinLastCol,pcr ; save right column
                    lda       >TraceWinCol,pcr ; reload left column
                    ldb       #$04      ; 4 pixels per char column
                    mul                 ; compute pixel offset
                    subb      #$05      ; adjust for border
                    stb       >TraceWinWidth,pcr ; store window width in pixels
                    lda       >TraceBottomRow,pcr ; bottom row
                    ldb       #$08      ; 8 pixels per text row
                    mul                 ; compute pixel Y
                    addb      #$05      ; adjust for border
                    stb       >TraceWinPixH,pcr ; store pixel height
                    lda       >TraceNumLines,pcr ; number of trace lines
                    ldb       #$08      ; 8 pixels per line
                    mul                 ; compute raw height
                    addb      #$0A      ; add border padding
                    stb       >TraceWinHeight,pcr ; store window height
                    ldb       #$9A      ; background color (light grey)
                    stb       >TraceWinBg,pcr ; store background color
                    ldd       #$040F    ; (row=4, col=15) — window position
                    pshs      b,a       ; push window position
                    ldd       >TraceWinHeight,pcr ; window height
                    pshs      b,a       ; push height
                    ldd       >TraceWinWidth,pcr ; window width
                    pshs      b,a       ; push width
                    lda       #$0C      ; function: create trace window
                    sta       <$0019    ; MMU twiddle function code
                    ldx       <$0026    ; MMU twiddle handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $06,s     ; discard pushed args
TraceInitRet        rts

cmd_trace_info      lda       ,y+       ; fetch logic number for trace
                    sta       <$006A    ; save logic number to trace
                    lda       ,y+       ; fetch line offset
                    sta       >TraceLineOff,pcr ; save trace line offset
                    lda       ,y+       ; fetch number of visible lines
                    cmpa      #$02      ; minimum is 2
                    bcc       TraceInfoSetLines ; branch if >= 2
                    lda       #$02      ; clamp to minimum of 2
TraceInfoSetLines   sta       >TraceNumLines,pcr ; store visible line count
                    rts
TraceErase          lda       <$0068    ; trace-active flag
                    beq       TraceEraseRet ; skip if not active
                    clr       <$0068    ; clear trace-active flag
                    ldd       >TraceWinHeight,pcr ; window height
                    pshs      b,a       ; push height
                    ldd       >TraceWinWidth,pcr ; window width
                    pshs      b,a       ; push width
                    lda       #$03      ; function: destroy trace window
                    sta       <$0019    ; MMU twiddle function code
                    ldx       <$0026    ; MMU twiddle handler
                    jsr       >$0701    ; invoke via MMU twiddle
                    leas      $04,s     ; discard pushed args
TraceEraseRet       rts

ScriptDispatch      leas      -$02,s    ; allocate 2-byte local frame
                    stb       $01,s     ; save command byte
                    clr       >TraceArgMode,pcr ; reset argument display mode
                    leax      >CmdTableStart,pcr ; command dispatch table
                    ldd       #$FFFF    ; -1 (no message index)
                    pshs      b,a       ; push message index
                    ldd       #$0000    ; 0 (no arg table)
                    pshs      b,a       ; push arg count
                    pshs      y         ; push current script pointer
                    pshs      x         ; push dispatch table
                    ldd       $08,s     ; script base address
                    pshs      b,a       ; push script base
                    lbsr      ScriptDisplayLine ; display current script line in trace
                    leas      $0A,s     ; discard all args
                    ldb       $01,s     ; restore command byte
                    leas      $02,s     ; release local frame
                    rts

ScriptArgDispatch   leas      -$03,s    ; allocate 3-byte local frame
                    sta       $02,s     ; save arg index
                    lda       #$01      ; default: word-mode args
                    ldb       ,u+       ; fetch arg count from bytecode
                    stb       $01,s     ; save arg count
                    cmpb      #$0E      ; 14 args = variable mode?
                    beq       TraceInfoSetMode ; branch to set mode
                    clra                ; else byte-mode args
TraceInfoSetMode    sta       >TraceArgMode,pcr ; set argument display mode
                    leax      >eval_table,pcr ; eval dispatch table
                    ldd       $02,s     ; arg index
                    pshs      b,a       ; push arg index
                    ldd       #$00DC    ; eval table size
                    pshs      b,a       ; push table size
                    pshs      u         ; push arg pointer
                    pshs      x         ; push eval table
                    ldd       $08,s     ; script base address
                    pshs      b,a       ; push script base
                    lbsr      ScriptDisplayLine ; display trace line
                    leas      $0A,s     ; discard args
                    leas      $03,s     ; release local frame
                    rts

ScriptDisplayLine   leas      -$04,s    ; allocate 4-byte local frame
                    clr       $06,s     ; clear separator-needed flag
                    lda       $07,s     ; fetch arg count
                    ldb       #$04      ; 4 bytes per dispatch table entry
                    mul                 ; compute table offset
                    addd      $08,s     ; add table base address
                    std       $08,s     ; update to entry address
                    lbsr      PushRowCol ; save cursor position
                    lbsr      PushTextColor ; save text color
                    ldd       #$000F    ; white on black
                    lbsr      text_color ; set trace text color
                    lbsr      TraceDrawWindow ; scroll trace window up one line
                    lda       <$0069    ; separator-request flag
                    beq       ScriptDisplayContent ; branch if no separator needed
                    clr       <$0069    ; clear separator request
                    leax      >StrTraceSep,pcr ; "==========" separator string
                    pshs      x         ; push separator
                    lbsr      PrintFmtStrToScr ; print separator line
                    leas      $02,s     ; discard arg
                    lbsr      TraceDrawWindow ; scroll again for separator
ScriptDisplayContent ldy       <$0062    ; current logic script pointer
                    sty       ,s        ; save script pointer
                    ldb       <$006A    ; traced logic number
                    beq       ScriptDisplayNumNum ; 0 = display as number:number
                    lbsr      FindLogicSlot ; find logic's slot number
                    cmpu      #$0000    ; logic found?
                    bne       ScriptDisplayNumStr ; branch if logic has a name
ScriptDisplayNumNum ldu       $06,s     ; arg table pointer
                    clra                ; high byte = 0
                    ldb       $02,y     ; current script offset
                    leax      >StrTraceNumNum,pcr ; "%d: %d" format
                    bra       ScriptDisplayPrint ; print it
ScriptDisplayNumStr stu       <$0062    ; store found logic pointer
                    leau      >StrReturn,pcr ; default message = "return"
                    ldb       $07,s     ; message count arg
                    beq       ScriptDisplayNumStrMsg ; 0 = use "return"
                    addb      $0D,s     ; add message base offset
                    lbsr      GetMsgPtr ; get message text pointer
ScriptDisplayNumStrMsg clra                ; high byte = 0
                    ldb       $02,y     ; current script offset
                    leax      >StrTraceNumStr,pcr ; "%d: %s" format
                    ldy       ,s        ; restore script pointer
                    sty       <$0062    ; restore current logic pointer
ScriptDisplayPrint  pshs      u         ; push message arg
                    pshs      b,a       ; push number arg
                    pshs      x         ; push format string
                    lbsr      PrintFmtStrToScr ; print trace line header
                    leas      $06,s     ; discard args
                    ldd       $0A,s     ; arg count and mode
                    pshs      b,a       ; push for TraceLineDraw
                    ldd       $0A,s     ; arg pointer
                    pshs      b,a       ; push arg pointer
                    lbsr      TraceLineDraw ; draw argument list
                    leas      $04,s     ; discard args
                    ldb       $0E,s     ; opcode/type byte
                    bmi       ScriptDisplayWait ; negative = wait unconditionally
                    lda       >TraceBottomRow,pcr ; bottom row of trace window
                    ldb       >TraceWinLastCol,pcr ; rightmost column
                    subb      #$02      ; back up 2 chars for label
                    std       <$0040    ; position cursor for label
                    lda       #$54      ; 'T' for True branch
                    ldb       $0E,s     ; opcode byte
                    bne       ScriptDisplayCmd ; branch if non-zero (a condition)
                    lda       #$46      ; 'F' for False branch (cmd opcode 0)
ScriptDisplayCmd    pshs      b,a       ; push label chars
                    leax      >StrTraceColon,pcr ; " :%c" format
                    pshs      b,a       ; push label again
                    pshs      x         ; push format string
                    lbsr      PrintFmtStrToScr ; print label
                    leas      $06,s     ; discard args
                    ldd       >$024A    ; current event timestamp
                    std       $02,s     ; save as wait baseline
ScriptDisplayWait   lda       <$0068    ; trace-active flag
                    beq       ScriptDisplayDone ; skip wait if trace is off
                    lbsr      EventPop  ; check for pending event
                    leax      ,x        ; test X (event pointer)
                    beq       ScriptDisplayWaitKey ; no event — check for input
                    lda       ,x        ; event type
                    cmpa      #$01      ; keyboard event?
                    beq       ScriptDisplayPlusKey ; check for '+' key
ScriptDisplayWaitKey ldd       $02,s     ; wait baseline
                    cmpd      >$024A    ; timestamp changed?
                    beq       ScriptDisplayWaitKey ; spin-wait for time change
                    lbsr      JoystickPoll ; poll for joystick input
                    ldd       >$024A    ; capture new timestamp
                    std       $02,s     ; update baseline
                    bra       ScriptDisplayWait ; continue wait loop
ScriptDisplayPlusKey lda       $01,x     ; keycode
                    cmpa      #$2B      ; '+' key (step-through)?
                    bne       ScriptDisplayDone ; other key = stop trace
                    lda       #$02      ; trace mode = step
                    sta       <$0068    ; update trace mode
ScriptDisplayDone   lbsr      PopRowCol ; restore cursor position
                    lbsr      PopTextColor ; restore text color
                    leas      $04,s     ; release local frame
                    rts

TraceLineDraw       leas      -$06,s    ; allocate 6-byte local frame
                    lbsr      PushRowCol ; save cursor position
                    ldu       $08,s     ; fetch arg table pointer
                    ldx       $0A,s     ; fetch arg data pointer
                    lda       $02,u     ; fetch arg count from table
                    ldb       >TraceArgMode,pcr ; current arg display mode
                    beq       TraceLineArg ; 0 = byte mode, skip word fetch
                    lda       ,x+       ; fetch word high byte
                    stx       $0A,s     ; advance arg pointer
TraceLineArg        ldb       $03,u     ; fetch arg type flags
                    std       ,s        ; save count and type
                    lda       #$28      ; '(' open paren
                    lbsr      PutCharToWindow ; print opening paren
                    lda       ,s        ; arg count
                    beq       TraceLineCloseParen ; skip if no args
                    clr       $02,s     ; arg index = 0
TraceLineArgLoop    ldb       $02,s     ; current arg index
                    ldu       $0A,s     ; arg data pointer
                    lbsr      TraceArgFetch ; fetch argument value in D
                    leax      >StrTraceNum,pcr ; "%d" format
                    pshs      b,a       ; push arg value
                    pshs      x         ; push format
                    lbsr      PrintFmtStrToScr ; print arg
                    leas      $04,s     ; discard args
                    ldb       $02,s     ; current arg index
                    incb                ; next arg
                    cmpb      ,s        ; past last arg?
                    bcc       TraceLineCloseParen ; branch if done
                    stb       $02,s     ; update arg index
                    lda       #$2C      ; ',' separator
                    lbsr      PutCharToWindow ; print comma
                    bra       TraceLineArgLoop ; next argument
TraceLineCloseParen lda       #$29      ; ')' close paren
                    lbsr      PutCharToWindow ; print closing paren
                    ldb       $01,s     ; secondary arg count
                    beq       TraceLineArgs2 ; skip if no secondary args
                    lbsr      TraceDrawWindow ; scroll for secondary args
TraceLineArgs2      lbsr      PopRowCol ; restore cursor
                    ldb       $01,s     ; secondary arg count
                    beq       TraceLineDrawRet ; skip if no secondary args
                    lda       #$28      ; '(' for second arg list
                    lbsr      PutCharToWindow ; print open paren
                    lda       #$80      ; initial bit mask for flag selection
                    clr       $02,s     ; arg index = 0
TraceLineArg2Loop   sta       $03,s     ; save current mask
                    ldb       $02,s     ; current arg index
                    ldu       $0A,s     ; arg data pointer
                    lbsr      TraceArgFetch ; fetch arg value in D
                    std       $04,s     ; save fetched value
                    lda       $01,s     ; secondary flag byte
                    anda      $03,s     ; test against current mask
                    beq       TraceLineArg2Print ; zero mask bit = raw value
                    ldx       #$0431    ; variable table base
                    abx                 ; index to variable
                    ldb       ,x        ; read variable value
                    clra                ; zero-extend to word
                    std       $04,s     ; override with variable value
TraceLineArg2Print  leax      >StrTraceNum,pcr ; "%d" format
                    ldd       $04,s     ; arg value
                    pshs      b,a       ; push value
                    pshs      x         ; push format
                    lbsr      PrintFmtStrToScr ; print value
                    leas      $04,s     ; discard args
                    ldb       $02,s     ; current arg index
                    incb                ; next arg
                    cmpb      ,s        ; past last?
                    bcc       TraceLineArg2Paren ; branch if done
                    stb       $02,s     ; update index
                    lda       #$2C      ; ',' separator
                    lbsr      PutCharToWindow ; print comma
                    lda       $03,s     ; current mask
                    lsra                ; shift mask right
                    bra       TraceLineArg2Loop ; next arg
TraceLineArg2Paren  lda       #$29      ; ')' close paren
                    lbsr      PutCharToWindow ; print closing paren
TraceLineDrawRet    leas      $06,s     ; release local frame
                    rts

TraceArgFetch       lda       >TraceArgMode,pcr ; check argument mode
                    bne       TraceArgFetchWord ; non-zero = word mode
                    clra                ; high byte = 0 (byte mode)
                    ldb       b,u       ; fetch byte at index B from U
                    bra       TraceArgFetchRet ; return value in D
TraceArgFetchWord   lslb                ; double index for word offset
                    leau      b,u       ; advance to indexed word
                    ldb       ,u+       ; fetch high byte
                    lda       ,u        ; fetch low byte (swapped for big-endian)
TraceArgFetchRet    rts

TraceDrawWindow     ldd       #$0001    ; scroll amount = 1 line
                    pshs      b,a       ; push scroll count
                    ldb       >TraceWinLastCol,pcr ; right column of trace window
                    pshs      b,a       ; push right col
                    ldb       >TraceWinCol,pcr ; left column of trace window
                    pshs      b,a       ; push left col
                    ldd       #$000F    ; color: white on black
                    pshs      b,a       ; push color
                    ldb       >TraceBottomRow,pcr ; bottom row of trace window
                    pshs      b,a       ; push bottom row
                    ldb       >TraceTopRow,pcr ; top row of trace window
                    pshs      b,a       ; push top row
                    lbsr      DrawTextRect ; scroll trace window content
                    leas      $0C,s     ; discard all pushed args
                    lda       >TraceBottomRow,pcr ; position cursor at bottom row
                    ldb       >TraceWinCol,pcr ; left column
                    std       <$0040    ; set cursor to new empty line
                    rts

InputBufLen         fcb       0
InputBuf            fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0
                    fcb       0,0,0,0,0

*
*======================================================================
* CYCLE EVENT LOOP AND INPUT PROCESSING
*   EventLoop drives each AGI game cycle: polls keyboard and joystick,
*   dispatches events to InputProcess, and blits the display; the
*   input editing commands (cmd_cancel_line, cmd_echo_line, input_echo,
*   InputCursorBlink, InputEditOn, cmd_prevent_input, cmd_accept_input,
*   cmd_set_cursor_char, InputRedraw) manage the text-input line at
*   the bottom of the screen.
*======================================================================
*
EventLoop           clra                ; clear A
                    sta       >$0444    ; clear pending keystroke
                    sta       >$043A    ; clear keyboard state
                    lda       >$05AE    ; menu-bar-active flag
                    beq       EventLoopCheck ; skip menu draw if not active
                    lbsr      DrawMenuBar ; redraw menu bar
EventLoopCheck      lbsr      EventPop  ; pop next event from queue
                    lbsr      RemapKeyEvent ; remap key if needed
                    leax      ,x        ; test X (event pointer)
                    beq       EventLoopDone ; no event — done
                    ldd       ,x        ; load event type and value
                    cmpa      #$01      ; keyboard event?
                    bne       EventLoopJoy ; branch if not keyboard
                    stb       >$0444    ; store raw keycode
                    lda       >$01D5    ; input-accept flag
                    beq       EventLoopCheck ; skip if input not accepted
                    bsr       InputProcess ; process keyboard input
                    bra       EventLoopCheck ; check for more events
EventLoopJoy        cmpa      #$02      ; joystick event?
                    bne       EventLoopKey ; branch if not joystick
                    ldu       <$0030    ; current active object
                    cmpb      <$21,u    ; same joystick position as before?
                    bne       EventLoopJoyStore ; branch if position changed
                    clrb                ; clear delta if same
EventLoopJoyStore   stb       >$0437    ; store joystick position
                    lda       >$0250    ; joystick-object flag
                    beq       EventLoopCheck ; skip if no object bound to joy
                    lda       #$00      ; clear joystick-bound state
                    sta       <$22,u    ; clear object joystick field
                    bra       EventLoopCheck ; continue event loop
EventLoopKey        ldu       #$05BA    ; key-pressed table base
                    lda       #$01      ; mark key as pressed
                    sta       b,u       ; store flag at key index
                    bra       EventLoopCheck ; continue event loop
EventLoopDone       rts

InputProcess        leas      -$02,s    ; allocate 2-byte local frame
                    stb       ,s        ; save keycode
                    ldx       #$0251    ; base of string table
                    lbsr      StrLen    ; get current input string length
                    negb                ; negate length
                    addb      #$28      ; 40 - len = chars remaining
                    lda       >$01AD    ; cursor-char flag
                    beq       InputCheckLen ; skip -1 adjustment if no cursor
                    decb                ; reserve 1 char for cursor
InputCheckLen       cmpb      >$0449    ; compare to max input length
                    bls       InputDispatch ; cap at configured maximum
                    ldb       >$0449    ; use max configured length
InputDispatch       stb       $01,s     ; save available space
                    lbsr      InputEditOn ; ensure cursor is erased
                    lda       ,s        ; restore keycode
                    cmpa      #$0A      ; Ctrl-J (line feed)?
                    beq       InputProcessDone ; ignore
                    cmpa      #$0D      ; Enter key?
                    bne       InputBackspace ; branch if not Enter
                    lda       >InputBufLen,pcr ; current input length
                    beq       InputProcessDone ; nothing to submit
                    ldx       #$012B    ; parsed input buffer
                    leau      >InputBuf,pcr ; raw input buffer
                    lbsr      StrCopy   ; copy raw input to parsed buffer
                    ldx       #$012B    ; parsed input buffer
                    lbsr      ParseSentence ; parse the input sentence
                    clra                ; clear input length
                    sta       >InputBufLen,pcr ; reset input counter
                    ldx       #$012B    ; parsed buffer
                    sta       ,x        ; null-terminate parsed buffer
                    lbsr      InputRedraw ; redraw input line (now empty)
                    bra       InputProcessDone ; done
InputBackspace      cmpa      #$08      ; Backspace?
                    bne       InputAddChar ; branch if not backspace
                    lda       >InputBufLen,pcr ; current length
                    beq       InputProcessDone ; nothing to delete
                    deca                ; decrement length
                    sta       >InputBufLen,pcr ; update length
                    ldu       #$012B    ; input display buffer
                    clr       a,u       ; null out deleted char
                    lda       ,s        ; restore key for backspace display
                    lbsr      PutCharToWindow ; show backspace on screen
                    bra       InputProcessDone ; done
InputAddChar        ldb       >InputBufLen,pcr ; current length
                    cmpb      $01,s     ; at maximum length?
                    bcc       InputProcessDone ; ignore if full
                    lda       ,s        ; restore keycode
                    beq       InputProcessDone ; ignore null character
                    ldu       #$012B    ; input display buffer
                    sta       b,u       ; store char at current position
                    incb                ; increment length
                    stb       >InputBufLen,pcr ; update length
                    clr       b,u       ; null-terminate buffer
                    lbsr      PutCharToWindow ; echo char to screen
InputProcessDone    bsr       InputCursorBlink ; update cursor visibility
                    leas      $02,s     ; release local frame
                    rts

cmd_cancel_line     lda       >InputBufLen,pcr ; any input to cancel?
                    beq       CancelLineRet ; done if already empty
                    ldb       #$08      ; backspace key code
                    lbsr      InputProcess ; delete one character
                    bra       cmd_cancel_line ; repeat until empty
CancelLineRet       rts

cmd_echo_line       lda       >$01D5    ; input-accept flag
                    beq       EchoLineRet ; skip if input not accepted
                    bsr       input_echo ; echo InputBuf to display
EchoLineRet         rts

input_echo          leax      >InputBuf,pcr ; raw input buffer
                    lbsr      StrLen    ; get length of raw input
                    cmpb      >InputBufLen,pcr ; compare to tracked display length
                    bls       InputEchoRet ; skip if display already up to date
                    bsr       InputEditOn ; erase cursor before editing
InputEchoLoop       ldb       >InputBufLen,pcr ; current display length
                    ldu       #$012B    ; input display buffer
                    leax      >InputBuf,pcr ; raw input buffer
                    lda       b,x       ; get char at current position
                    sta       b,u       ; mirror to display buffer
                    beq       InputEchoRedraw ; null = end of input to echo
                    incb                ; advance position
                    stb       >InputBufLen,pcr ; update display length
                    lbsr      PutCharToWindow ; echo char to screen
                    bra       InputEchoLoop ; echo next char
InputEchoRedraw     bsr       InputCursorBlink ; show cursor
InputEchoRet        rts

InputCursorBlink    lda       >$05B9    ; cursor-blink-state flag
                    bne       InputCursorBlinkRet ; skip if cursor already shown
                    com       >$05B9    ; toggle flag to shown state
                    lda       >$01AD    ; cursor character (0 = no cursor)
                    beq       InputCursorBlinkRet ; skip if no cursor char
                    lbsr      PutCharToWindow ; draw cursor char
InputCursorBlinkRet rts

InputEditOn         lda       >$05B9    ; cursor-blink-state flag
                    beq       InputEditOnRet ; skip if cursor already hidden
                    com       >$05B9    ; toggle flag to hidden state
                    lda       >$01AD    ; cursor character
                    beq       InputEditOnRet ; skip if no cursor char
                    lda       #$08      ; backspace to erase cursor
                    lbsr      PutCharToWindow ; erase cursor from screen
InputEditOnRet      rts

cmd_prevent_input   bsr       InputEditOn ; erase cursor
                    lda       >$01D7    ; input row
                    clrb                ; column 0
                    stb       >$01D5    ; disable input acceptance
                    lbsr      ClearTextLine ; clear input line
                    rts

cmd_accept_input    lda       #$01      ; enable flag
                    sta       >$01D5    ; enable input acceptance
                    bsr       InputRedraw ; redraw input prompt and buffer
                    rts

cmd_set_cursor_char ldb       ,y+       ; fetch message number
                    lbsr      GetMsgPtr ; get cursor char string pointer
                    lda       ,u        ; first char of message = cursor
                    sta       >$01AD    ; store as cursor character
                    rts

InputRedraw         leas      <-$50,s   ; allocate 80-byte local frame
                    lda       >$01D5    ; input-accept flag
                    beq       InputRedrawRet ; skip if input not accepted
                    bsr       InputEditOn ; erase cursor before redraw
                    lda       >$01D7    ; input row
                    ldb       >$024D    ; input max column
                    lbsr      ClearTextLine ; clear the input line
                    lda       >$01D7    ; input row
                    clrb                ; column 0
                    std       <$0040    ; position cursor at start of line
                    ldx       #$0251    ; string table base (prompt string)
                    leau      ,s        ; local format buffer
                    ldd       #$0028    ; max 40 chars
                    pshs      b,a       ; push max length
                    pshs      x         ; push source string
                    pshs      u         ; push output buffer
                    lbsr      MsgTextSetup ; format prompt string
                    leas      $06,s     ; discard args
                    pshs      x         ; push formatted prompt
                    lbsr      PrintFmtStrToScr ; print prompt text
                    leas      $02,s     ; discard arg
                    ldd       #$012B    ; input display buffer address
                    pshs      b,a       ; push as pointer
                    lbsr      PrintFmtStrToScr ; print current input content
                    leas      $02,s     ; discard arg
                    lbsr      InputCursorBlink ; restore cursor
InputRedrawRet      leas      <$50,s    ; release local frame
                    rts

*
*======================================================================
* ARITHMETIC AND VARIABLE COMMANDS
*   Implements the full set of AGI variable arithmetic commands:
*   increment, decrement, assignn, assignv, addn, addv, subn, subv,
*   and indirect variants, plus multn, multv, divn, divv, and the
*   Div8 unsigned 8-bit divide helper.
*======================================================================
*
cmd_increment       ldb       ,y+       ; fetch variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    lda       ,x        ; load current value
                    inca                ; increment
                    beq       IncrSkip  ; skip store if wrapped to 0 (255)
                    sta       ,x        ; store incremented value
IncrSkip            rts

cmd_decrement       ldb       ,y+       ; fetch variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    lda       ,x        ; load current value
                    beq       DecrSkip  ; skip if already 0
                    deca                ; decrement
                    sta       ,x        ; store decremented value
DecrSkip            rts

cmd_assignn         ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    lda       ,y+       ; fetch immediate value
                    abx                 ; point to destination variable
                    sta       ,x        ; store value into variable
                    rts

cmd_assignv         ldb       $01,y     ; fetch source variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to source variable
                    lda       ,x        ; read source value
                    ldb       ,y++      ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to destination variable
                    sta       ,x        ; store source value into destination
                    rts

cmd_addn            ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    lda       ,x        ; load current value
                    adda      ,y+       ; add immediate value
                    sta       ,x        ; store result
                    rts

cmd_addv            ldb       $01,y     ; fetch source variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to source variable
                    lda       ,x        ; read source value
                    ldb       ,y++      ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to destination variable
                    adda      ,x        ; add source to destination
                    sta       ,x        ; store result
                    rts

cmd_subn            ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    lda       ,x        ; load current value
                    suba      ,y+       ; subtract immediate
                    sta       ,x        ; store result
                    rts

cmd_subv            ldb       $01,y     ; fetch source variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to source variable
                    lda       ,x        ; read source value
                    nega                ; negate source
                    ldb       ,y++      ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to destination variable
                    adda      ,x        ; add negated source to destination
                    sta       ,x        ; store result (destination - source)
                    rts

cmd_lindirectv      ldb       $01,y     ; fetch value variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to value variable
                    lda       ,x        ; read value
                    ldb       ,y++      ; fetch index variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to index variable
                    ldb       ,x        ; dereference index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to indexed variable
                    sta       ,x        ; store value via indirect
                    rts

cmd_lindirectn      lda       $01,y     ; fetch immediate value
                    ldb       ,y++      ; fetch index variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to index variable
                    ldb       ,x        ; dereference index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to indexed variable
                    sta       ,x        ; store immediate via indirect
                    rts

cmd_rindirect       ldb       $01,y     ; fetch index variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to index variable
                    ldb       ,x        ; dereference index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to indexed variable
                    lda       ,x        ; read value via indirect
                    ldb       ,y++      ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to destination variable
                    sta       ,x        ; store value into destination
                    rts

cmd_multn           ldx       #$0431    ; variable table base
                    ldb       ,y+       ; fetch destination variable index
                    abx                 ; point to variable
                    lda       ,x        ; load variable value
                    ldb       ,y+       ; fetch immediate multiplier
                    mul                 ; multiply A × B → D
                    stb       ,x        ; store low byte of result
                    rts

cmd_multv           ldb       $01,y     ; fetch multiplier variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to multiplier variable
                    lda       ,x        ; read multiplier
                    ldb       ,y++      ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to destination variable
                    ldb       ,x        ; read destination value
                    mul                 ; multiply A × B → D
                    stb       ,x        ; store low byte of result
                    rts

cmd_divn            ldx       #$0431    ; variable table base
                    ldb       ,y+       ; fetch destination variable index
                    abx                 ; point to variable
                    ldb       ,x        ; load variable value (dividend)
                    lda       ,y+       ; fetch immediate divisor
                    bsr       Div8      ; divide B ÷ A → B (quotient)
                    stb       ,x        ; store quotient
                    rts

cmd_divv            ldb       $01,y     ; fetch dividend variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to dividend variable
                    lda       ,x        ; read dividend
                    ldb       ,y++      ; fetch divisor variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to divisor variable
                    ldb       ,x        ; read divisor
                    bsr       Div8      ; divide B ÷ A → B (quotient)
                    stb       ,x        ; store quotient
                    rts

Div8                sta       <$0088    ; save divisor
                    lda       #$08      ; 8 bits to shift
                    sta       <$008D    ; save bit counter
                    clra                ; A = 0 (accumulator for quotient)
Div8Loop            lslb                ; shift dividend left
                    rola                ; rotate carry into accumulator
                    cmpa      <$0088    ; accumulator >= divisor?
                    bcs       Div8Next  ; branch if not
                    suba      <$0088    ; subtract divisor
                    incb                ; set quotient bit
Div8Next            dec       <$008D    ; decrement bit counter
                    bne       Div8Loop  ; loop for all 8 bits
                    rts

*
*======================================================================
* VIEW MANAGEMENT
*   Maintains the view linked list (list_struct, view_find); loads
*   view resources (cmd_load_view, view_load); sets the view, loop,
*   and cel for an animated object (cmd_set_view, SetViewForObj,
*   cmd_set_loop, SetLoopHelper, cmd_set_cel, SetCelHelper); queries
*   current state (cmd_last_cel, cmd_current_*); and discards views
*   from memory (cmd_discard_view, DiscardViewHelper).
*======================================================================
*
list_struct         fcb       0,0
                    fcb       0,0
                    fcb       0,0,0
ListLastNode        fcb       0,0

list_clear          leau      list_struct,pcr ; point to view list head node
                    ldd       #0        ; null link word
                    std       ,u        ; clear head pointer (empty list)
                    rts

view_find           leax      >list_struct,pcr ; start from view list head
ViewFindLoop        stx       >ListLastNode,pcr ; remember previous node pointer
                    ldx       ,x        ; follow next link
                    beq       ViewFindRet ; end of list = not found
                    cmpb      $02,x     ; view number matches?
                    bne       ViewFindLoop ; loop if not a match
ViewFindRet         rts

cmd_load_view       lda       #$00      ; A = 0 (no forced-reload flag)
                    ldb       ,y+       ; fetch view number
                    bsr       view_load ; load the view resource
                    rts

cmd_load_view_v     lda       #$00      ; A = 0 (no forced-reload flag)
                    ldb       ,y+       ; fetch variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    ldb       ,x        ; dereference variable (view number)
                    bsr       view_load ; load the view resource
                    rts

view_load           leas      -$06,s    ; allocate 6-byte local frame
                    std       ,s        ; save A:B (flags:view number)
                    bsr       view_find ; search view list for this view
                    leax      ,x        ; test X (result)
                    beq       ViewLoadCreate ; branch if not in cache
                    ldb       ,s        ; check forced-reload flag
                    bne       ViewLoadCreate ; force reload if flag set
                    tfr       x,u       ; U = found view node
                    bra       ViewLoadRet ; return existing node
ViewLoadCreate      stx       $02,s     ; save existing node (or null)
                    ldd       <$000A    ; current logic page
                    std       $04,s     ; save for restore
                    lbsr      ClearBothRanges ; clear object motion ranges
                    ldu       $02,s     ; check existing node
                    bne       ViewLoadFetch ; use existing if present
                    lda       #$01      ; script type for view load
                    ldb       $01,s     ; view number
                    lbsr      PushScript ; record in script replay buffer
                    ldd       #$0007    ; 7-byte view node size
                    lbsr      AllocDataBlock ; allocate new view node
                    stu       $02,s     ; save new node pointer
                    ldx       >ListLastNode,pcr ; previous list node
                    stu       ,x        ; link new node at list tail
                    ldd       #$0000    ; null link word
                    std       ,u        ; clear next pointer
                    std       $03,u     ; clear data pointer
                    ldb       $01,s     ; view number
                    stb       $02,u     ; store view number in node
ViewLoadFetch       ldb       $02,u     ; view number from node
                    lbsr      FetchView ; look up view directory entry
                    ldx       $02,s     ; view node pointer
                    ldx       $03,x     ; get volume handle from node
                    lbsr      OpenVolFile ; open the volume file for data
                    beq       ViewLoadDone ; branch if not found
                    ldx       $02,s     ; view node pointer
                    std       $05,x     ; store vol file size info
                    stu       $03,x     ; store data pointer
ViewLoadDone        lbsr      SwapObjRanges ; restore object ranges
                    ldd       $04,s     ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    ldu       $02,s     ; view node pointer
ViewLoadRet         leas      $06,s     ; release local frame
                    rts

cmd_set_view        leas      -$02,s    ; allocate 2-byte page save area
                    ldd       <$000A    ; current logic page
                    std       ,s        ; save page for restore
                    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    ldb       ,y+       ; fetch view number
                    bsr       SetViewForObj ; bind view to object
                    ldd       ,s        ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $02,s     ; release local frame
                    rts

cmd_set_view_v      leas      -$02,s    ; allocate 2-byte page save area
                    ldd       <$000A    ; current logic page
                    std       ,s        ; save page for restore
                    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    ldb       ,y+       ; fetch view variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    ldb       ,x        ; dereference variable (view number)
                    bsr       SetViewForObj ; bind view to object
                    ldd       ,s        ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $02,s     ; release local frame
                    rts

SetViewForObj       lbsr      view_find ; search view list for view B
                    leax      ,x        ; test X (result)
                    bne       SetViewData ; branch if view found
                    lda       #$03      ; error: view not loaded
                    lbsr      ReportError ; report error
SetViewData         stb       $05,u     ; store view number in object
                    ldd       $05,x     ; view resource size/page
                    std       $08,u     ; store in object
                    ldx       $03,x     ; view data pointer
                    stx       $06,u     ; store in object
                    lbsr      SetLogicPage ; switch to view's page
                    ldx       $06,u     ; reload view data pointer
                    lda       $02,x     ; number of loops in view
                    sta       $0B,u     ; store loop count in object
                    ldb       $0A,u     ; current loop index
                    cmpb      $0B,u     ; current loop still valid?
                    bcs       SetViewRet ; branch if valid
                    clrb                ; reset to loop 0
SetViewRet          bsr       SetLoopHelper ; apply loop selection
                    rts

cmd_set_loop        leas      -$02,s    ; allocate 2-byte page save area
                    ldd       <$000A    ; current logic page
                    std       ,s        ; save page for restore
                    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    ldb       ,y+       ; fetch loop index
                    bsr       SetLoopHelper ; apply loop selection
                    ldd       ,s        ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $02,s     ; release local frame
                    rts

cmd_set_loop_v      leas      -$02,s    ; allocate 2-byte page save area
                    ldd       <$000A    ; current logic page
                    std       ,s        ; save page for restore
                    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    ldb       ,y+       ; fetch loop variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    ldb       ,x        ; dereference variable (loop index)
                    bsr       SetLoopHelper ; apply loop selection
                    ldd       ,s        ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $02,s     ; release local frame
                    rts

SetLoopHelper       leas      -$01,s    ; allocate 1-byte error save
                    ldx       $06,u     ; view data pointer
                    bne       SetLoopFound ; branch if view data exists
                    ldb       #$06      ; error: no view loaded
                    bra       SetLoopErr ; report error
SetLoopFound        cmpb      $0B,u     ; loop index < loop count?
                    bcs       SetLoopData ; branch if valid
                    ldb       #$05      ; error: loop out of range
SetLoopErr          stb       ,s        ; save error code
                    tfr       u,d       ; D = object pointer
                    subd      <$0030    ; compute object index
                    lda       ,s        ; load error code
                    lbsr      ReportError ; report error
SetLoopData         stb       $0A,u     ; store loop index in object
                    ldd       $08,u     ; view page info
                    lbsr      SetLogicPage ; switch to view page
                    ldb       $0A,u     ; loop index
                    lslb                ; × 2 for pointer table index
                    addb      #$06      ; offset past view header
                    ldx       $06,u     ; view data pointer
                    lda       b,x       ; high byte of loop entry pointer
                    decb                ; previous byte
                    ldb       b,x       ; low byte of loop entry pointer
                    leax      d,x       ; X = loop entry pointer
                    stx       $0C,u     ; store loop pointer in object
                    lda       ,x        ; number of cels in loop
                    sta       $0F,u     ; store cel count
                    ldb       $0E,u     ; current cel index
                    cmpb      $0F,u     ; cel still valid?
                    bcs       SetLoopRet ; branch if valid
                    clrb                ; reset to cel 0
SetLoopRet          bsr       SetCelHelper ; apply cel selection
                    leas      $01,s     ; release local frame
                    rts

cmd_set_cel         leas      -$02,s    ; allocate 2-byte page save area
                    ldd       <$000A    ; current logic page
                    std       ,s        ; save page for restore
                    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    ldb       ,y+       ; fetch cel index
                    bsr       SetCelHelper ; apply cel selection
                    ldd       ,s        ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $02,s     ; release local frame
                    rts

cmd_set_cel_v       leas      -$02,s    ; allocate 2-byte page save area
                    ldd       <$000A    ; current logic page
                    std       ,s        ; save page for restore
                    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    ldb       ,y+       ; fetch cel variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    ldb       ,x        ; dereference variable (cel index)
                    bsr       SetCelHelper ; apply cel selection
                    ldd       ,s        ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $02,s     ; release local frame
                    rts

SetCelHelper        leas      -$01,s    ; allocate 1-byte error save
                    ldx       $06,u     ; view data pointer
                    bne       SetCelFound ; branch if view data exists
                    ldb       #$0A      ; error: no view loaded
                    bra       SetCelErr ; report error
SetCelFound         cmpb      $0F,u     ; cel index < cel count?
                    bcs       SetCelData ; branch if valid
                    ldb       #$08      ; error: cel out of range
SetCelErr           stb       ,s        ; save error code
                    tfr       u,d       ; D = object pointer
                    subd      <$0030    ; compute object index
                    lda       ,s        ; error code
                    lbsr      ReportError ; report error
SetCelData          stb       $0E,u     ; store cel index in object
                    ldd       $08,u     ; view page info
                    lbsr      SetLogicPage ; switch to view page
                    ldb       $0E,u     ; cel index
                    lslb                ; × 2 for pointer table index
                    addb      #$02      ; offset past loop header
                    ldx       $0C,u     ; loop data pointer
                    lda       b,x       ; high byte of cel pointer
                    decb                ; previous byte
                    ldb       b,x       ; low byte of cel pointer
                    leax      d,x       ; X = cel data pointer
                    stx       <$10,u    ; store cel pointer in object
                    ldd       ,x        ; cel dimensions (width, height)
                    std       <$1C,u    ; store in object dimension fields
                    adda      $03,u     ; add X position to check clip
                    cmpa      #$A0      ; would exceed right edge?
                    bls       SetCelWidthClip ; branch if fits
                    lda       <$25,u    ; load object flags
                    ora       #$04      ; set clip flag
                    sta       <$25,u    ; store updated flags
                    lda       #$A0      ; screen right edge
                    suba      <$1C,u    ; compute clipped X position
                    sta       $03,u     ; store clipped X
SetCelWidthClip     decb                ; height - 1 (bottom row offset)
                    cmpb      $04,u     ; would exceed bottom?
                    bls       SetCelRet ; branch if fits
                    lda       <$25,u    ; load object flags
                    ora       #$04      ; set clip flag
                    sta       <$25,u    ; store updated flags
                    stb       $04,u     ; store clipped height
                    cmpb      >$01D6    ; compare to global height limit
                    bhi       SetCelRet ; branch if over limit
                    lda       <$26,u    ; load more object flags
                    bita      #$08      ; check height-locked flag
                    bne       SetCelRet ; branch if locked
                    ldb       >$01D6    ; global max height
                    incb                ; +1 for inclusive
                    stb       $04,u     ; store height-bounded value
SetCelRet           leas      $01,s     ; release local frame
                    rts

cmd_last_cel        lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    lda       $0F,u     ; get cel count
                    deca                ; last cel index = count - 1
                    ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    sta       ,x        ; store last cel index
                    rts

cmd_current_cel     lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    lda       $0E,u     ; get current cel index
                    ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    sta       ,x        ; store current cel index
                    rts

cmd_current_loop    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    lda       $0A,u     ; get current loop index
                    ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    sta       ,x        ; store current loop index
                    rts

cmd_current_view    lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    lda       $05,u     ; get current view number
                    ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    sta       ,x        ; store current view number
                    rts

cmd_number_of_loops lda       ,y+       ; fetch object number
                    ldb       #$2B      ; 43 bytes per object struct
                    mul                 ; offset = obj × 43
                    addd      <$0030    ; add object array base
                    tfr       d,u       ; U = object struct pointer
                    lda       $0B,u     ; get total loop count
                    ldb       ,y+       ; fetch destination variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    sta       ,x        ; store loop count
                    rts

cmd_discard_view    ldb       ,y+       ; fetch view number
                    bsr       DiscardViewHelper ; discard the view
                    rts

cmd_discard_view_v  ldb       ,y+       ; fetch variable index
                    ldx       #$0431    ; variable table base
                    abx                 ; point to variable
                    ldb       ,x        ; dereference variable (view number)
                    bsr       DiscardViewHelper ; discard the view
                    rts

DiscardViewHelper   leas      -$05,s    ; allocate 5-byte local frame
                    stb       ,s        ; save view number
                    lbsr      view_find ; search view list for this view
                    leax      ,x        ; test X (result)
                    bne       DiscardViewDoFree ; branch if found
                    lda       #$01      ; error: view not loaded
                    ldb       ,s        ; view number
                    lbsr      ReportError ; report error
DiscardViewDoFree   stx       $01,s     ; save view node pointer
                    ldd       <$000A    ; current logic page
                    std       $03,s     ; save for restore
                    lda       #$07      ; script type for view discard
                    ldb       ,s        ; view number
                    lbsr      PushScript ; record in script replay buffer
                    ldu       >ListLastNode,pcr ; previous list node
                    ldd       #$0000    ; null link word
                    std       ,u        ; unlink discarded node from list
                    lbsr      ClearBothRanges ; clear object motion ranges
                    ldx       $01,s     ; view node pointer
                    ldu       $03,x     ; view data pointer
                    lda       $05,x     ; view page
                    lbsr      CalcPriAddr ; compute priority address
                    stu       <$004F    ; store priority pointer
                    stx       <$0055    ; store node pointer
                    lbsr      SwapObjRanges ; restore object ranges
                    lbsr      UpdateFreeSpace ; update free memory accounting
                    ldd       $03,s     ; saved logic page
                    lbsr      SetLogicPage ; restore page
                    leas      $05,s     ; release local frame
                    rts

*
*======================================================================
* OBJECT ANIMATION STEP
*   ObjAnimStep advances a view object's cel each animation tick,
*   handles loop direction reversal at the last cel, fires the end-
*   of-loop flag, and dispatches the cycle-type (normal, end-of-loop,
*   reverse-loop) to update the object's loop/cel counters.
*======================================================================
*
ObjAnimStep         lda       <$27,u    ; cel animation delay counter
                    beq       AnimStepRoll ; zero = time to advance cel
                    dec       <$27,u    ; decrement delay
                    lda       <$25,u    ; object flags
                    bita      #$40      ; random animation flag set?
                    beq       AnimStepRet ; skip random if not set
AnimStepRoll        lbsr      InitRandSeed ; seed/advance random generator
                    lda       #$09      ; range: 0-8 (9 possible values)
                    lbsr      Div8      ; random modulo: B = random % 9
                    sta       <$21,u    ; store random direction in object
                    cmpu      <$0030    ; is this the ego object?
                    bne       AnimStepCheckDelay ; branch if not ego
                    sta       >$0437    ; set ego direction variable
AnimStepCheckDelay  lda       <$27,u    ; reload delay counter
AnimStepDelayLoop   cmpa      #$06      ; delay >= 6?
                    bcc       AnimStepRet ; return if delay is already high
                    lbsr      InitRandSeed ; advance random state
                    lda       #$33      ; range: 0-50 (51 values)
                    lbsr      Div8      ; random modulo
                    sta       <$27,u    ; store new random delay
                    bra       AnimStepDelayLoop ; check if high enough
AnimStepRet         rts

SetPriBaseStub      ldx       #$05ee    * regX will now point to the priority table
                    lbra      SetPriBase * back to the original code

UIntDivideToD       lbsr      UIntDivide ; call unsigned divide routine
                    tfr       u,d       ; move quotient from U to D
                    rts

* Patch stub to have "format string" return string in X
* without altering code length in "move to (x,y)"
stub1               lbsr      PrintFmtStr ; call format string routine
                    tfr       u,x       ; move result pointer to X
                    lbra      MoveToFormatDone ; continue move-to processing

                    fcb       0,0,0,0,0,0,0,0
StrModName          fcc       /mnln/
                    fcb       0

                    emod
eom                 equ       *
                    end
