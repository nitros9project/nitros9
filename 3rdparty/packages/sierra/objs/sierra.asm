********************************************************************
* sierra - Sierra AGI game setup module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/01/31  Paul W. Zibaila
* Disassembly of original distribution and merged in comments from
* disasm dated 1992.
*
*   1      2003/03/10  Boisy G. Pitre
* Monitor type bug now fixed.
*
*   2      2012/01/05  Robert Gault
* Converted raw reads of $FFA0-$FFAF to a routine that gets images
* from the system. Now works with 2 or 8Meg systems. Unfortunately
* it was necessary to make buffers within the code rather than data
* area because it was safer given data was shared with other modules.
*
* Simplified some other routines.
*
* Annotated by /annotate-asm (Claude Code) 2026-05-12:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction
* Annotated by /annotate-asm (Claude Code) 2026-05-14:
*   - Renamed data-area variables (mtf173→MultitaskFlagCopy, scr174→HiResScrnNum, etc.)
*   - Fixed module description (removed KQ3-specific title — module is game-generic)
*   - Added ====== section headers throughout code body

* I/O path definitions
StdIn               equ       0
StdOut              equ       1
StdErr              equ       2

                    nam       sierra
                    ttl       Sierra AGI game setup module

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
DataAreaSize        rmb       2         stack ptr − $04FF = data area size
MmuBlk2Orig         rmb       1         original MMU block # mapped at $4000–$5FFF
MmuBlk3Orig         rmb       1         original MMU block # mapped at $6000–$7FFF
ScrStartAddr        rmb       2         hi-res screen start address (physical)
ScrEndAddr          rmb       2         hi-res screen end address
MmuSaveTmp          rmb       1         MMU block # scratch slot
MmuBlkSierra        rmb       1         MMU block # Sierra module occupies
MmuTask1Blk0        rmb       1         task-1 DAT slot 0 ($0000–$1FFF)
MmuTask1Blk1        rmb       1         task-1 DAT slot 1 ($2000–$3FFF)
MmuTask1Blk2        rmb       1         task-1 DAT slot 2 ($4000–$5FFF)
MmuTask1Blk3        rmb       1         task-1 DAT slot 3 ($6000–$7FFF)
MmuTask1Blk4        rmb       1         task-1 DAT slot 4 ($8000–$9FFF)
MmuTask1Blk5        rmb       1         task-1 DAT slot 5 ($A000–$BFFF)
MmuTask1Blk6        rmb       1         task-1 DAT slot 6 ($E000–$FFFF)
MmuInitFlag         rmb       3         MMU init flag (1 byte + 2 pad)
ScrStart2           rmb       2         second hi-res screen start reference
ScrEnd2             rmb       2         second hi-res screen end reference
ScrEndPad           rmb       4         pad after second screen addresses
BlkMapLow           rmb       2         low task-1 MMU block pair for mapping
BlkMapHigh          rmb       4         high task-1 MMU block pairs for mapping
BlockRef            rmb       2         block reference pair (2-byte value)
MnlnRemap           rmb       2         mnln remap value holder
ScrnRemap           rmb       2         scrn remap value holder
ShdwRemap           rmb       2         shdw remap value holder
CallerSp            rmb       2         saves stack pointer of caller to MmuSwitch
HiResBase           rmb       2         hi-res screen base address
EntryTable          rmb       16        MnLn entry vector table pointer + pad
TickCountHi         rmb       1         game tick counter high byte
TickCountLo         rmb       2         game tick counter low byte + pad
Reserved41          rmb       1         pad byte at $41
SierraPdBlk         rmb       1         MMU block # of Sierra's process descriptor
Sierra2ndBlk        rmb       2         ptr to Sierra's 2nd block in DAT image
PaletteFlag         rmb       1         flag after color table sets
ScrAddrHi           rmb       2         hi-res screen address high word
TickAccum           rmb       2         tick accumulator (20 ticks = 1 second)
IrqCountdown        rmb       5         VIRQ countdown byte + 4 pad
GameState4F         rmb       4         game state 4-byte field at $004F
InitParam53         rmb       2         game init word at $53 (init $06CE)
InitParam55         rmb       10        game init words at $55–$5E (init $06CE)
PathTable           rmb       163       module name/path table
GamePausedFlag      rmb       112       game paused flag + game data [$102–$171]
MultitaskFlagCopy   rmb       1         multitasking flag copied from startup parms
HiResScrnNum        rmb       1         allocated hi-res screen number
GameStateBuf        rmb       212       game state buffer [$175–$248]
GameTimerB3         rmb       1         32-bit game timer byte 3 (MSB)
GameTimerB2         rmb       1         32-bit game timer byte 2
GameTimerB1         rmb       1         32-bit game timer byte 1
GameTimerB0         rmb       497       32-bit game timer byte 0 (LSB) + pad
TimeOfDay           rmb       245       time-of-day: seconds, minutes, hours, days
VolHandleTable      rmb       16        vol_handle_table (pointer to file structures)
VolTablePad         rmb       15        pad after vol handle table
GivenPicPtr         rmb       2         given_pic_data (pointer)
DisplayType         rmb       1         display_type
GameDataBuf         rmb       154       general game data buffer
                    rmb       169       padding before SigIntercept/MmuSwitch slots
int5EE              rmb       107       slot for SigIntercept routine copy [$696–$700]
sub659              rmb       117       slot for MmuSwitch routine copy [$701–$775]
u0xxx               rmb       6281      remaining data area [$776–$1FFE]
size                equ       .

* ====== Module Header ======
name                fcs       /sierra/
                    fcb       edition

* ====== Dispatch Table: Entry and Exit Vectors ======
start               equ       *
EntryDispatch       lbra      InitEntry branch to entry process params
ExitDispatch        lbra      ExitDispEntry agi_exit() branch to clean up routines


*                   Multi-tasking flag (0=No multitask, 1=multitask)
MultitaskFlag       fcb       $00       we store a value here
*                   the "old self modifying code" trick


* ====== Static String Constants ======
* Text strings think this was probably an Info thing
CopyrightStr        fcc       'AGI (c) copyright 1988 SIERRA On-Line'
                    fcc       'CoCo3 version by Chris Iden'
                    fcb       $00
Infosz              equ       *-CopyrightStr


* Useage text string
UsageStr            fcc       'Usage: Sierra -Rgb -Multitasking'
                    fcb       C$CR
Usgsz               equ       *-UsageStr


* ====== InitEntry: Startup — Parse Command Line Arguments ======
InitEntry           tfr       s,d       save stack ptr / start of param ptr into d
*
                    subd      #$04FF    start of stack/end of data mem ptr
                    std       <DataAreaSize store this value in user var
                    bsr       ArgParseLoop branch to input processer routine

PostArgInit         lbsr      SetupModule relay call to InitDataArea

MainInit            ldd       <DataAreaSize load the data pointer
                    beq       ExitNow   if it is zero we have a problem
*         ldd   >$FFA9     ??? MMU task 1 block 1 ???
                    lbsr      mmuini2   get MMU values $FFA8-$FFAF
                    ldd       mmubuf+9,pcr load task-1 MMU block entry (9th byte)
                    std       <MmuTask1Blk0 save the task 1 block one value
                    lda       #$00      clear a to zero
                    sta       <MmuInitFlag save that value
                    ldx       <MnlnRemap set up to jump to mnln and go for it
                    jsr       sub659    code at MmuSwitch plays with mmu blocks
                    rts                 return after game exits via MmuSwitch

* Process any command line args
* See F$Fork description 8-15 for entry conditions

ArgParseLoop        lda       ,x+       get next char after name string
                    cmpa      #C$CR     is it a CR?
                    beq       ArgsDone  yes exit from routine
                    cmpa      #$2D      is it a dash '-
                    bne       ArgParseLoop not a dash go look again

                    lda       ,x+       was as dash get the next char
                    ora       #$20      apply mask to lower case
                    cmpa      #$72      is it a 'r ?
                    beq       HandleOptRgb yep go set up for RGB monitor
                    cmpa      #$6D      is it an 'm ?
                    beq       HandleOptMulti if so go store a flag and continue

*  We've found something other than Mm or Rr after a dash
*  write usage message and Exit program

                    lda       #StdOut   load path std out
                    leax      >UsageStr,pcr load address of message
                    ldy       #Usgsz    $0021  load the size of the message
                    os9       I$WritLn  write it
                    clrb                clear the error code (unneeded branch to ExitOk)
                    bra       ExitNow   and branch to exit!

* found a "-r"
HandleOptRgb        pshs      x         save x-reg since set stat call uses it
                    lda       #StdOut   $01  set the path number
                    ldb       #SS.Montr code #$92 sets the monitor type
                    ldx       #RGB      monitor type code $0001
                    os9       I$SetStt  set it up
                    puls      x         fetch our x back assumes call doesn't fail
                    bra       ArgParseLoop go process the rest of the parms

* found an "-m"
HandleOptMulti      lda       #$01      we have found a -m and load a flag
                    sta       >MultitaskFlag,pcr and stow it in our code area  (SELF MODIFYING)
                    bra       ArgParseLoop check for next param

ArgsDone            rts                 return


* ====== ExitDispEntry: Clean Up and Exit ======
*  This is just a relay call to L0336
agi_exit
ExitDispEntry       lbsr      ShutdownFull call full shutdown sequence

ExitOk              clrb                clear error code (success)
ExitNow             os9       F$Exit    time to check out


* ====== Static Data: Color Tables, MMU Slots, and Module Name Strings ======
* same sequence of bytes at L454C in mnln

ColorTable          fcb       $00       composite
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

* The disassembly gets confused here with text and the nulls
*  according to the partial disassembly I recieved these hold
*  Original MMU block image of second and third blocks of SIERRA
*  MORE SELF MODIFYING CODE

SierraMmuBlk2       fdb       $0000     Orig MMU block image of 2nd blk of sierra
SierraMmuBlk3       fdb       $0000     Orig MMU block image of 3nd blk of sierra

* Name strings of other modules to load.

ShdwModName         fcc       'Shdw'
                    fcb       C$CR

ScrnModName         fcc       'Scrn'
                    fcb       C$CR

MnlnModName         fcc       'MnLn'
                    fcb       C$CR


* Internal variables for self modifying code
EchoSave            fcb       $00       Echo
EofSave             fcb       $00       EOF
IntSave             fcb       $00       INTerupt
QuitSave            fcb       $00       Quit
MonTypeSave         fcb       $00       Monitor type Coco set to when Sierra ran


* ====== SetupModule / ShutdownFull: Setup and Shutdown Orchestration ======
* L011A called by PostArgInit
SetupModule         lbsr      InitDataArea Clears data area, sets up vars and saves montype
                    lbsr      mmuini1   get MMU values $FFA0-$FFA7
                    lbsr      SetupProcMap Change our process image to dupe block 0 to 1-2
CopySubroutines     lbsr      CopySubsToData copies two subs to data area so others can use them

                    lbsr      SetupVirq load intercept routine and open /VI and allocate Ram
                    bcs       CleanupVirq if errors occured  close VIRQ device

                    lbsr      LoadModules NMLoads the three other modules and sets up vals
                    bcs       CleanupMods problems then unload them

                    lbsr      SetupScreen go set up screens
                    bcs       ShutdownFull problems deallocate them
                    rts                 return to InitEntry

* clean up and shut down
agi_shutdown
ShutdownFull        lbsr      RestoreScreen go deallocate hi res screens
CleanupMods         lbsr      UnloadAllMods unloads the three other modules
CleanupVirq         lbsr      CloseVirqPath Close VIRQ device
                    lbsr      RestoreMmu restore the MMU blocks
                    rts                 return to caller

* ====== InitDataArea: Clear and Initialize Sierra Data Area ======
* at this point DataAreaSize contains the value of s on entry minus $04FF
* which should be the size of our initialized data
* so we don't over write it but clear the rest of the data area

InitDataArea        ldx       #$0002    Init data area from 2-end with 0's
                    ldd       #$0000    zero value to fill data area
ClearLoop           std       ,x++      write zero word and advance pointer
                    cmpx      <DataAreaSize should have the value $04FF
                    bcs       ClearLoop appears this zeros out memory somewhere

* initialize some variables
                    lda       >MultitaskFlag,pcr multitasking flag from startup parms
                    sta       >MultitaskFlagCopy store multitask flag in data area

                    ldd       #$0776    why twice
                    std       <InitParam53 initialize game parameter at $53
                    std       <InitParam55 initialize game parameter at $55

                    lda       #$5C      load constant for game state init
                    sta       >$0101    store game state byte at $0101

                    lda       #$17      load constant for game state init
                    sta       >$01D7    store game state byte at $01D7

                    lda       #$0F      load constant for game state init
                    sta       >$023E    store game state byte at $023E

                    ldd       #$0000    zero value for game state word
                    std       <GameState4F clear game state field at $004F

*  get current montype
*  GetStat Function Code $92
*          Allocates and maps high res screen
*          into application address space
* entry:
*       a -> path number
*       b -> function code $92 (SS.Montr)
*
* exit:
*       x -> monitor type
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
                    lda       #StdOut   $01 path number
                    ldb       #SS.Montr monitor type code (not listed for getstat $92
                    os9       I$GetStt  make the call
                    tfr       x,d       save in d appears he expects montype returned
                    stb       >MonTypeSave,pcr trim it to a byte and save it
                    andb      #$01      mask out mono type only RGB or COMP
                    stb       >$0553    save that value off as display_type

*  set current montype
*  SetStat Function Code $92
*          Allocates and maps high res screen
*          into application address space
* entry:
*       a -> path number
*       b -> function code $92 (SS.Montr)
*       x -> momitor type
*            0 = color composite
*            1 = analog RGB
*            2 = monochrome composite
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
                    ldx       #RGB      $0001 set type to RGB again as in L00C2
                    lda       #StdOut   $01 set the path
                    ldb       #SS.Montr Monitor type code $92
                    os9       I$SetStt  make the call

* initialize more variables

                    lda       #$32      load game state constant
                    sta       >$0245    store game state byte at $0245

                    ldd       #$6000    This is the start of high res screen memory
                    std       <ScrAddrHi store hi-res screen start address

                    lda       #$15      load game state constant
                    sta       >$0247    store game state byte at $0247

                    lda       #$FF      Init 15 bytes at VolHandleTable to $FF
                    sta       $05EE
                    ldb       #$10
                    ldx       #$0531

* Fill routine-one byte pattern
* Entry: A=Byte to fill with
*        B=# bytes to fill
*        X=Start address of fill

FillBytes           sta       ,x+       store fill byte and advance pointer
                    decb                decrement byte count
                    bne       FillBytes loop until count reaches zero
                    rts                 return from FillBytes/InitDataArea

* ====== DisableKbdInt: Save and Suppress Keyboard Signals ======
*  Raw disassembly of followin code
*L01AF    orcc  #$50
*         ldx   #$0002
*         stx   <u0022
*         lda   >$FFAF
*         sta   <u0008
*         clr   >$FFA9
*         ldd   >$2050
*         anda  #$1F
*         addd  #$2043
*         std   <u0043
*         ldb   >$2050
*         andb  #$E0
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         ldx   #$FFA0
*         lda   b,x
*         sta   <u0042
*         sta   >$FFA9
*         ldx   <u0043
*         ldd   -$01,x
*         std   >L0102,pcr
*         ldd   $01,x
*         std   >L0104,pcr
*         ldd   -$03,x
*         std   -$01,x
*         std   $01,x
*         tfr   b,a
*         std   >$FFA9
*         std   <u0002
*         andcc #$AF
*         rts

**********************************************************
* COMMENTS FROM CODE RECIEVED
* Change our process map:
*         Blocks 1-2 become duplicates of block 0 (data area...
*         changes actual MMU regs themselves &
*         changes them in our process descriptor
*
* NOTE: SHOULD CHANGE SO IT MAPS IN BLOCK 0 IN AN UNUSED BLOCK 1ST
*       TO GET PROCESS DESCRIPTOR DAT IMAGE FOR SIERRA.
*       THEN, CAN BUMP BLOCKS AROUND WITH THE ACTUAL BLOCK #
*       IN FULL 2 MB RANGE, INSTEAD OF JUST GIME 512K RANGE.

SetupProcMap        orcc      #IntMasks Shut interrupts off
                    ldx       #$0002    ???
                    stx       <BlockRef save block reference pair

*        As per above NOTE, should postpone this until we have DAT image
*        available for Sierra process

*         lda   >$FFAF         Get MMU block # SIERRA is in
                    lda       mmubuf+$0F,pcr read task-0 MMU slot 15 (Sierra's block)
                    sta       <MmuSaveTmp Save it
                    clr       >$FFA9    Map system block 0 into $2000-$3FFF
                    ldd       >D.Proc+$2000 Get SIERRA's process dsc. ptr
                    anda      #$1F      Keep non-MMU dependent address

* NOTE: OFFSET IS STUPID, SHOULD USE EVEN BYTE SO LDD'S BELOW
*       CAN USE FASTER LDD ,X INSTEAD OF OFFSET,X

                    addd      #$2000+P$DATImg+3 Set up ptr for what we want out of it
                    std       <Sierra2ndBlk Save it
                    ldb       >D.Proc+$2000 Get MSB of SIERRA's process dsc. ptr
                    andb      #$E0      Calculate which 8K block within
*                                 system task it's in
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         lsrb
                    lda       #8        hi_byte × 8 / 256 = 8K block index
                    mul                 compute MMU block offset for this address

* NOTE: HAVE TO CHANGE THIS TO GET BLOCK #'S FROM SYSTEM DAT IMAGE,
*       NOT RAW GIME REGS (TO WORK WITH >512K MACHINES)
*         ldx   #$FFA0       Point to base of System task DAT register set block 0 task 0
                    leax      mmubuf,pcr point to task-0 physical MMU block table
*         lda   b,x          Get block # that has process desc. for SIERRA
                    lda       a,x       read block # at computed offset
                    sta       <SierraPdBlk Save it
                    sta       >$FFA9    Map in block with process dsc. to $2000-$3FFF
                    ldx       <Sierra2ndBlk Get offset to 2nd 8K block in DAT map for SIERRA
                    ldd       -1,x      Get MMU block # of current 2nd 8k block in SIERRA
                    std       >SierraMmuBlk2,pc Save it
                    ldd       1,x       Get MMU block # of current 3rd 8k block in SIERRA
                    std       >SierraMmuBlk3,pc Save it
                    ldd       -3,x      Get data area block 3 from sierra (1st block)
                    std       -1,x      Move 8k data area to 2nd block
                    std       1,x       And to 3rd block
                    tfr       b,a       D=Raw MMU block # for both

* HAVE TO CHANGE TO ALLOW FOR DISTO DAT EXTENSION
                    std       >$FFA9    Map data area block into both blocks 2&3
                    std       <MmuBlk2Orig Save both block #'s
                    andcc     #^IntMasks Turn interrupts back on
                    rts                 return from SetupProcMap


* ====== CopySubsToData: Copy Runtime Subroutines to Data Area ======
* NOTE: 6809/6309 MOD: STUPID. DO LEAX, AND THEN PSHS X

* load first routine
*L01FA    leas  -2,s         Make 2 word buffer on stack
*         leax  >L054F,pc    Point to end of routine
*         stx   ,s           Save ptr
CopySubsToData      leax      MmuSwitchEnd,pcr load end-address of MmuSwitch routine
                    pshs      x         save end pointer on stack
                    leax      >MmuSwitch,pc Point to routine
*         ldu   #$0659      Point to place in data area to copy it
                    ldu       #sub659   point to data-area slot for MmuSwitch copy
CopySub1Loop        lda       ,x+       Copy routine
                    sta       ,u+       write byte to data area and advance
                    cmpx      ,s        Done whole routine yet?
                    blo       CopySub1Loop No, keep going

* get next routine interrupt intecept routine
                    leax      >CloseVirqPath,pcr point to end of routine
                    stx       ,s        save pointer
                    leax      >SigIntercept,pcr point to routine
                    ldu       #int5EE   point to place in data area to copy it
CopySub2Loop        lda       ,x+       copy routine
                    sta       ,u+       write byte to data area and advance
                    cmpx      ,s        Done whole routine yet?
                    blo       CopySub2Loop No, keep going
*         leas  $02,s        clean up stack
*         rts                return
                    puls      x,pc      restore X and return (clean stack)

* ====== LoadModules: NMLoad and Link All Three AGI Modules ======
* Called from dispatch table at L0120
* The last op in the subroutine before this one
* was a puls a,b after a puhs x and a setsatt call for process+path to VIRQ

LoadModules         tfr       b,a       don't see what's going on here
                    incb                make B one higher than A for block pair
                    std       <BlkMapLow but we save off a bunch of values

                    addd      #$0202    advance A and B by 2 for next block pair
                    std       <BlkMapHigh save high block map pair

                    addd      #$0202    advance again for task-1 slots
                    sta       <PathTable save path table index
                    std       <MmuTask1Blk2 init task-1 MMU block slots 2-3
                    std       <MmuTask1Blk4 init task-1 MMU block slots 4-5

                    ldu       #$001A    remap table offset for Shdw
                    stu       <ShdwRemap store Shdw remap offset
                    leax      >ShdwModName,pcr shdw
                    lbsr      NMLoadModule NMLoads named module
                    bcs       LoadModulesRet return on error

                    ldu       #$0012    remap table offset for Scrn
                    stu       <ScrnRemap store Scrn remap offset
                    leax      >ScrnModName,pcr scrn
                    lbsr      NMLoadModule NMLoads named module
                    bcs       LoadModulesRet return on error

                    ldu       #$000A    remap table offset for MnLn
                    stu       <MnlnRemap store MnLn remap offset
                    leax      >MnlnModName,pcr mnln
                    lbsr      NMLoadModule NMLoads named module

                    leau      >$2000,u  advance past module header to entry vectors
                    stu       <EntryTable save entry table address for MmuSwitch
LoadModulesRet      rts                 return from LoadModules

*****************************************************
*
*  Set up screens
*  SetStat Function Code $8B
*          Allocates and maps high res screen
*          into application address space
* entry:
*       a -> path number
*       b -> function code $8B (SS.AScrn)
*       x -> screen type
*            0 = 640 x 192 x 2 colors (16K)
*            1 = 320 x 192 x 4 colors (16K)
*            2 = 160 x 192 x 16 colors (16K)
*            3 = 640 x 192 x 4 colors (32K)
*            4 = 320 x 192 x 16 colors (32K)
*
* exit:
*       x -> application address space of screen
*       y -> screen number (1-3)
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*
*  Call use VDGINT allocates high res graphics for use with screens
*  updated by the process, does not clear the screens only allocates
*  See OS-9 Technical Reference 8-142 for more details
*

SetupScreen         leas      -$04,s    mamke room om stack 2 words
                    lda       #$01      Std out
                    ldb       #SS.AScrn Allocate & map in hi-res screen (VDGINT)
                    ldx       #$0004    320x192x16 screen
                    os9       I$SetStt  Map it in
                    bcs       ScreenSetupRet Error, Restore stack & exit
                    tfr       y,d       Move screen # returned to D
*         stb   >$0174      Save screen #
                    stb       >HiResScrnNum save allocated hi-res screen number

* call with application address of screen in x
* returns with values in u
                    lbsr      mmuini2   get current MMU values
                    lbsr      TwiddleAddr twiddle addresses
                    stu       <ScrStartAddr stow it two places
                    stu       <ScrStart2 also save as second screen start reference

                    leax      >$4000,x  end address ???
                    lbsr      TwiddleAddr twiddle addresses
                    stu       <ScrEndAddr stow it in two places
                    stu       <ScrEnd2  also save as second screen end reference

* TFM for 6309
                    ldu       #$D800    Clear hi-res screen to color 0
                    ldx       #$7800    Screen is from $6000 to $D800
                    ldd       #$0000    (U will end up pointing to beginning of screen)
ClearScreenLoop     std       ,--u      writes 0000 to screen address and decrements
                    leax      -2,x      decrement x loop counter
                    bne       ClearScreenLoop keep going till all of screen is cleared

*  Display a screen allocated by SS.AScrn
*  SetStat Function Code $8C
*
* entry:
*       a -> path number
*       b -> function code $8C (SS.DScrn)
*       y -> screen numbe
*            0 = text screen (32 x 16)
*            1-3 = high resolution screen
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    clra                Get screen # to display
                    ldb       >HiResScrnNum load allocated screen number
                    tfr       d,y       Y=screen # to display
                    lda       #StdOut   $01  Std out path
                    ldb       #SS.DScrn Display 320x192x16 screen
                    os9       I$SetStt  make the call
                    bcs       ScreenSetupRet bail on screen display error

                    leax      >ColorTable,pc get color table values
                    ldb       >$0553    display_type 0 = comp / 1 = rgb
                    lda       #$10      16 palette entries per color table
                    mul                 first sixteen comp, second rgb
                    abx                 add b to x reset the pointer as required


* This loads up the control sequence to set the pallete 1B 31 PRN CTN
*  PRN palette register 0 - 15, CTN color table 0 - 63
                    lda       #$1B      Escape code
                    sta       ,s        push on stack
                    lda       #$31      Palette code
                    sta       $01,s     push on stack
                    clra                make a zero palette reg value
                    sta       $02,s     push it `
                    ldy       #$0004    sets up # of bytes to write
PaletteLoop         ldb       ,x+       get value computed above for color table and bump it
                    stb       $03,s     push it
                    pshs      x         save it
                    lda       #StdOut   $01      Std Out path
                    leax      $02,s     start of data to write
                    os9       I$Write   write it
                    bcs       ScreenSetupRet error during write clean up stack and leave
                    puls      x         retrieve our x
                    inc       $02,s     this is our palette register value
                    lda       $02,s     we bumped it by one
                    cmpa      #$10      we loop 15 times to set them all
                    blo       PaletteLoop loop

                    clr       <PaletteFlag clear a flag in memory
                    lbsr      DisableKbdInt go disable keyboard interrupts
ScreenSetupRet      leas      $04,s     clean up stack
                    rts                 return


*  Raw disassembly of following section
*L02E9    leas  <-$20,s
*         lda   #$00
*         ldb   #$00
*         leax  ,s
*         os9   I$GetStt
*         bcs   L0332
*         lda   >L0115,pcr
*         ldb   $04,x
*         sta   $04,x
*         stb   >L0115,pcr
*         lda   >L0116,pcr
*         ldb   $0C,x
*         sta   $0C,x
*         stb   >L0116,pcr
*         lda   >L0117,pcr
*         ldb   <$10,x
*         sta   <$10,x
*         stb   >L0117,pcr
*         lda   >L0118,pcr
*         ldb   <$11,x
*         sta   <$11,x
*         stb   >L0118,pcr
*         lda   #$00
*         ldb   #$00
*         os9   I$SetStt
*L0332    leas  <$20,s
*         rts

* Kills the echo, eof, int and quit signals
*  get current options packet
*  GetStat Function Code $00
*          Reads the options section of the path descriptor and
*          copies it into the 32 byte area pointed to by reg X`
* entry:
*       a -> path number
*       b -> function code $00 (SS.OPT)
*       x -> address to recieve status packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

DisableKbdInt       leas      <-$20,s   Make temp buffer to hold PD.OPT data
                    lda       #StdIn    $00 Get 32 byte PD.OPT from Std In
                    ldb       #SS.OPT   $00
                    leax      ,s        point to our temp buffer
                    os9       I$GetStt  make the call
                    bcs       SetOptsDone error goto exit sub

* NOTE: make sure following lines assemble into 5 bit, not 8 bit
*       These appear to be loading the  echo EOF, INT and QUIT with
*       null values and saving the original ones back to vars
*       since L0115 - L0118 were initialized with $00

                    lda       >EchoSave,pc load saved echo value (initially 0)
                    ldb       PD.EKO-PD.OPT,x Get echo option
                    sta       PD.EKO-PD.OPT,x change echo option no echo
                    stb       >EchoSave,pc Save original echo option

                    lda       >EofSave,pc load saved EOF char value
                    ldb       PD.EOF-PD.OPT,x Change EOF char
                    sta       PD.EOF-PD.OPT,x disable EOF character
                    stb       >EofSave,pc save original EOF character

                    lda       >IntSave,pc load saved interrupt char value
                    ldb       <PD.INT-PD.OPT,x Change INTerrupt char (normally CTRL-C)
                    sta       <PD.INT-PD.OPT,x disable interrupt character
                    stb       >IntSave,pc save original interrupt character

                    lda       >QuitSave,pc load saved quit char value
                    ldb       <PD.QUT-PD.OPT,x Change QUIT char (normally CTRL-E)
                    sta       <PD.QUT-PD.OPT,x disable quit character
                    stb       >QuitSave,pc save original quit character

*  set current options packet
*  SetStat Function Code $00
*          Writes the options section of the path descriptor
*          from the 32 byte area pointed to by reg X`
* entry:
*       a -> path number
*       b -> function code $00 (SS.OPT)
*       x -> address holding the status packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

*                                x is still pointing to our temp buff
                    lda       #StdIn    $00 Set VDG screen to new options
                    ldb       #SS.OPT   $00
                    os9       I$SetStt  set them to be our new values

SetOptsDone         leas      <$20,s    Eat temp stack & return
                    rts                 return from DisableKbdInt

* ====== RestoreScreen: Return to Text Screen, Free Hi-Res Screen ======
*  raw disassembly
*L0336    leas  -$02,s
*         tst   >$0174
*         beq   L036D
*         lbsr  L02E9
*         bcs   L036D
**         lda   #$1B
*         sta   ,s
*         lda   #$30
*         sta   $01,s
*         ldy   #$0002
*         lda   #$01
*         leax  ,s
*         os9   I$Write
*         bcs   L036D
*         ldb   #$8C
*         ldy   #$0000
*         os9   I$SetStt
*         clra
*         ldb   >$0174
*         tfr   d,y
*         lda   #$01
*         ldb   #$8D
*         os9   I$SetStt
*L036D    leas  $02,s
*         rts


*  Return the screen to default text sreen and its values
*  deallocate and free memory of high res screen created

RestoreScreen       leas      -2,s      Make temp buffer to hold write data
*         tst   >$0174       Any hi-res screen # allocated?
                    tst       >HiResScrnNum any hi-res screen number allocated?
                    beq       RestoreScreenRet No, restore stack & return
                    lbsr      DisableKbdInt go change the echo,eof,int and quit settings
                    bcs       RestoreScreenRet had an error restore stack and return
                    lda       #$1B      Setup DefColr sequence in temp buffer
                    sta       ,s        store escape byte in write buffer
                    lda       #$30      Sets palettes back to default color
                    sta       1,s       store palette-reset code in buffer
                    ldy       #$0002    number of bytes to write
                    lda       #StdOut   path to write to $01
                    leax      ,s        point x a buffer
                    os9       I$Write   write
                    bcs       RestoreScreenRet we have an error clean stack and leave

*  Display a screen allocated by SS.AScrn
*  SetStat Function Code $8C
*
* entry:
*       a -> path number
*       b -> function code $8C (SS.DScrn)
*       y -> screen numbe
*            0 = text screen (32 x 16)
*            1-3 = high resolution screen
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

*                           a is still set to stdout from above
                    ldb       #SS.DScrn Display screen function code
                    ldy       #$0000    Display screen #0 (lo-res or 32x16 text)
                    os9       I$SetStt  make the call

*  Frees the memory of a screen allocated by SS.AScrn
*  SetStat Function Code $8C
*
* entry:
*       a -> path number
*       b -> function code $8D (SS.FScrn)
*       y -> screen number 1-3 = high resolution screen
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    clra                clear high byte
                    ldb       >HiResScrnNum get hi-res screen number again
                    tfr       d,y       move it to Y=screen #
                    lda       #StdOut   set the path $01
                    ldb       #SS.FSCrn Return screen memory to system
                    os9       I$SetStt  amke the call

RestoreScreenRet    leas      2,s       Eat stack & return
                    rts                 return from RestoreScreen



* ====== UnloadAllMods: Unlink All Three AGI Modules ======
*  Unload the other modules
UnloadAllMods       leax      >ShdwModName,pcr shdw name string
                    lda       #Prgrm+Objct #$11        module type
                    lbsr      UnloadMod unload it
                    leax      >ScrnModName,pcr scrn name string
                    lbsr      UnloadMod unload it
                    leax      >MnlnModName,pcr mnln name string
                    lbsr      UnloadMod unload it
                    rts                 return from UnloadAllMods

*L0388    orcc  #$50
*         lda   <u0042
*         sta   >$FFA9
*         ldx   <u0043
*         ldd   >L0104,pcr
*         std   $01,x
*         stb   >$FFAA
*         ldd   >L0102,pcr
*         std   -$01,x
*         stb   >$FFA9
*         andcc #$AF
*         clra
*         ldb   >L0119,pcr
*         andb  #$03
*         tfr   d,x
*         lda   #$01
*         ldb   #$92
*         os9   I$SetStt
*         rts
**
*L03B6    tfr   x,d
*         exg   a,b
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         pshs  b
*         ldu   #$FFA8
*         lda   b,u
*         incb
*         andb  #$07
*         ldb   b,u
*         tfr   d,u
*         puls  a
*         rts


* ====== RestoreMmu: Restore MMU to Pre-Game State ======
* Restore original MMU block numbers
RestoreMmu          orcc      #IntMasks Shut off interrupts
                    lda       <SierraPdBlk get MMU Block #
                    sta       >$FFA9    Restore original block 0 onto MMU
                    ldx       <Sierra2ndBlk reload Sierra DAT image pointer
                    ldd       >SierraMmuBlk3,pc Origanl 3rd block of MMU
                    std       1,x       restore 3rd block in Sierra's DAT map
                    stb       >$FFAA    Restore original block 1 onto MMU
                    ldd       >SierraMmuBlk2,pc Original 2nd block of MMU
                    std       -1,x      restore 2nd block in Sierra's DAT map
                    stb       >$FFA9    Restore block 0 again
                    andcc     #^IntMasks Turn interrupts back on

*  return monitor type to original value
                    clra                clear A for 16-bit monitor type in D
                    ldb       >MonTypeSave,pc Get original monitor type
                    andb      #$03      Force to only legit values
                    tfr       d,x       Move to proper register
                    lda       #StdOut   set path $01
                    ldb       #SS.Montr Restore original monitor type
                    os9       I$SetStt  make the call
                    rts                 return from RestoreMmu

* ====== TwiddleAddr: Map Logical Address to Physical Block Pair ======
* twiddles address
* called with value to be twiddled in X
* returns block # in a
*         ?????   in u
TwiddleAddr         tfr       x,d       Move address to D
*         exg   a,b          Swap MSB/LSB
*         lsrb               Divide MSB by 32 (calculate 8k block # in proc map)
*         lsrb
*         lsrb
*         lsrb
*         lsrb
*         pshs  b            Save block # in process map
*         ldu   #$FFA8       Point to start of user DAT image
*         lda   b,u
                    ldb       #8        hi_byte × 8 / 256 = 8K block index in A
                    mul                 compute block index from address high byte
                    pshs      a         save block index (0-7)
                    leau      mmubuf+8,pcr point to task-1 physical MMU block table
                    lda       a,u       get MMU value
                    ldb       ,s        reload block index from stack
                    incb                index of next adjacent block
                    andb      #$07      wrap within 8 task-1 slots
                    ldb       b,u       read physical block # of adjacent slot
                    tfr       d,u       U = both physical block numbers
                    puls      a         restore block index
                    rts                 return: A=block index, U=physical block pair



*************************************************************
*  Called from  within sub at L0229
*  entry:
*	x -> is loaded with the address of the name string to load
*       u -> contains some arbitrary value
*

NMLoadModule        leas      -$08,s    Make a little scratch on the stack
                    stu       ,s        pointer to our buffer

* Loads one or more modules from a file but does not map the module
* into user's address space F$NMLoad
* entry:
*      a -> type/language byte
*      x -> address of the path list
*           with out path list default path is current execution dir
*
* exit:
*      a -> type/language
*      b -> module revision
*      x -> address of the last byte in the pathlist + 1
*      y -> storageb requirements of the module
*
* error:
*      b  -> error code if any
*      cc -> carry set on error

                    stx       $02,s     pointer module name
                    lda       #Prgrm+Objct $11      module type
                    os9       F$NMLoad  Load it but don't map it in
                    bcs       NMLoadFail exit on error

* Links to a memory module that has the specified name, language and type
* entry:
*      a -> type/language byte
*      x -> address of the module name
*
* exit:
*      a -> type/language
*      b -> attributes/module revision
*      x -> address of the last byte in the modulename + 1
*      y -> module entry point absolute address
*      u -> module header abosolute address
*
* error:
*     cc -> set on error

                    ldx       $02,s     get our name string again
                    os9       F$Link    link it
                    bcs       NMLoadFail exit on error
                    stu       $06,s     store module header address
                    tfr       u,x       copy module header address to X
                    lbsr      mmuini2   get current MMU values
NMLoadLoop          stx       $04,s     save current module segment pointer
                    lbsr      TwiddleAddr Go twiddle with address`
                    ldx       ,s        reload buffer base pointer
                    leax      a,x       index into block map at block index A
                    exg       d,u       swap: D=module ptr, U=block pair
                    sta       ,x        store block number into map entry
                    exg       d,u       restore D=block pair, U=module ptr
                    cmpa      #$06      check if all 6 blocks mapped
                    beq       NMLoadUnlink done — unlink and clean up
                    ldx       $04,s     reload module segment pointer
                    leax      >$2000,x  advance to next 8K segment
                    bra       NMLoadLoop map next block

NMLoadUnlink        ldu       $06,s     recover module header for unlink
                    os9       F$UnLink
NMLoadFail          leas      $08,s     clean up scratch stack frame
                    rts                 return (carry set on failure)

UnloadMod           os9       F$UnLoad  Unlink a module by name
                    bcc       UnloadMod loop until unload fails (module gone)
                    clrb                clear error: expected not-found at end
                    rts                 return from UnloadMod

ViDevPath           fcc       '/VI'
ViDevPathEnd        fcb       C$CR
ViDevAddr           fdb       $0000     address of the device table entry
ViPathNum           fcb       $00       path number to device

**************************************************************
*
*   subroutine entry is L0419
*   sets up Sig Intercept
*   verifies /VI device is loaded links to it
*   and allocates ram for it
*   called from dispatch table around L0120


* Set signal intercept trap
*  entry:
*        x -> address of intercept routine
*        u -> starting adress of routines memory area
*  exit:
*       Signals sent to the process cause the intercept to be
*       called instead of the process being killed

SetupVirq           ldu       #$0000    start of Sierra memory area
                    ldx       #int5EE   Intercept rourtine copied to mem area
                    os9       F$Icpt    install the trap

* Attach to the vrt memory descriptor
* Attaches and verifies loaded the VI descriptor
* entry:
*      a -> access mode
*          0 = use any special device capabilities
*          1 = read only
*          2 = write only
*          3 = update (read and write)
*      x -> address of device name string
*
* exit:
*      x -> updated past device name
*      u -> address of device table entry
*
* error:
*      b  -> error code (if any)
*      cc -> carry set on error

                    lda       #$01      attach for read
                    leax      >ViDevPath+1,pcr skip the slash Load VI only
                    os9       I$Attach  make the call
                    bcs       SetupVirqRet didn't work exit
                    stu       >ViDevAddr,pcr did work save address

* Open a path to the device /VI
* entry:
*       a -> access mode (D S PE PW PR E W R)
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last byte if the pathlist + 1
*
* error:
*       b  -> error code(if any)
*       cc -> carry set on error
*
*                            a still contains $01 read
                    leax      >ViDevPath,pcr load with device name including /
                    os9       I$Open    make the call
                    bcs       SetupVirqRet didn't work exit
                    sta       >ViPathNum,pcr did work save path #

* Allocate process+path RAM blocks

                    ldb       #SS.ARAM  $CA function code for VIRQ
                    ldx       #$000D    request 13 RAM blocks
                    os9       I$SetStt  make the call
                    bcs       SetupVirqRet abort if allocation failed
                    pshs      x         save allocated RAM pointer

* Set process+path VIRQ KQ3
                    ldb       #SS.KSet  $C8 function code for VIRQ
                    os9       I$SetStt
                    puls      b,a       restore A and B after KSet call
SetupVirqRet        rts                 return from SetupVirq

* ====== SigIntercept / SigHandlerCore: VIRQ Timer and Game Clock ======
* Signal Intercept processing gets copied to int5EE mem slot
SigIntercept        cmpb      #$80      b gets the signal code if not $80 ignore
                    bne       SigInterceptRet $80 is user defined
                    tfr       u,d       copy U (data area ptr) into D
                    tfr       a,dp      set direct page register to data area base
                    dec       <IrqCountdown decrement IRQ countdown counter
                    bne       SigInterceptRet not yet time — return
                    bsr       SigHandlerCore call timer and game-clock handler
                    lda       #$03      reload countdown to 3 intervals
                    sta       <IrqCountdown reset IRQ countdown
SigInterceptRet     rti                 return from interrupt

SigHandlerCore      inc       >GameTimerB0,u increment low byte of 32-bit game timer
                    bne       TimerUpdate no carry — skip upper bytes
                    inc       >GameTimerB1,u propagate carry to byte 1
                    bne       TimerUpdate no carry — skip upper bytes
                    inc       >GameTimerB2,u propagate carry to byte 2
                    bne       TimerUpdate no carry — skip upper bytes
                    inc       >GameTimerB3,u propagate carry to high byte
TimerUpdate         tst       >GamePausedFlag,u check if game is paused
                    bne       TimerRet  paused — skip tick accumulation
                    inc       <TickCountLo increment low tick counter
                    bne       TickUpdate no overflow — process tick accumulator
                    inc       <TickCountHi increment high tick counter on overflow
TickUpdate          ldd       <TickAccum load tick accumulator
                    addd      #$0001    add one tick
                    std       <TickAccum save updated accumulator
                    cmpd      #$0014    check if 20 ticks elapsed (one second)
                    bcs       TimerRet  not yet — return
                    subd      #$0014    subtract 20 (one second)
                    std       <TickAccum save remainder
                    ldd       #$003C    60 = max value for seconds and minutes
                    leax      >TimeOfDay,u point to time-of-day seconds field
                    inc       ,x        increment seconds
                    cmpb      ,x        compare seconds with 60
                    bhi       TimerRet  less than 60 — done
                    sta       ,x+       reset seconds to 0, advance to minutes
                    inc       ,x        increment minutes
                    cmpb      ,x        compare minutes with 60
                    bhi       TimerRet  less than 60 — done
                    sta       ,x+       reset minutes to 0, advance to hours
                    inc       ,x        increment hours
                    ldb       #$18      24 = max hours per day
                    cmpb      ,x        compare hours with 24
                    bhi       TimerRet  less than 24 — done
                    sta       ,x+       reset hours to 0, advance to days
                    inc       ,x        increment day counter
TimerRet            rts                 return from timer handler

* ====== CloseVirqPath: Release VIRQ Device ======
* deallocates the VIRQ device
CloseVirqPath       lda       >ViPathNum,pcr load path number to /VI device
                    beq       DetachVi  no path open check for device table addr
                    ldb       #SS.KClr  $C9 Clear KQ3 VIRQ
                    os9       I$SetStt  make the call
                    ldb       #SS.DRAM  $CB deallocate the ram
                    os9       I$SetStt  make the call
                    os9       I$Close   close the path to /VI
DetachVi            ldu       >ViDevAddr,pcr load device table address for VI
                    beq       CloseVirqRet don't have one leave now
                    os9       I$Detach  else detach it
CloseVirqRet        rts                 return from CloseVirqPath

* ====== MmuSwitch: Switch Between Module MMU Address Spaces ======
*  Twiddles with MMU blocks for us
*  This sub gets copied into $0659 and executed there from this and
*  the other modules this one loads (sub659)
*
*  s and x loaded by calling routine

MmuSwitch           ldd       ,s++      load d with current stack pointer and bump it
*                         from mnln we come in with $4040
                    std       <CallerSp save the calling stack pointer in CallerSp
                    orcc      #IntMasks mask the interrupts
                    lda       <SierraPdBlk load Sierra's process descriptor block #
                    sta       ,x        x is loaded with value from ShdwRemap in mnln
                    sta       >$FFA9    task 1 block 2 x2000 - x3FFF
                    ldu       <Sierra2ndBlk point to Sierra's DAT image in process descriptor
                    lda       $06,x     get calling module's MMU block 6 entry
                    sta       MmuTask1Blk2,u save in Sierra's task-1 map slot 2
                    sta       >$FFAF    task 1 block 8 xE000 - xFFFF
                    lda       $05,x     get calling module's MMU block 5 entry
                    sta       MmuTask1Blk0,u save in Sierra's task-1 map slot 0
                    sta       >$FFAE    task 1 block 7 xC000 - xDFFF
                    lda       $04,x     get calling module's MMU block 4 entry
                    sta       MmuSaveTmp,u save to MMU scratch slot
                    sta       >$FFAD    task 1 block 6 xA000 - xBFFF
                    lda       $03,x     get calling module's MMU block 3 entry
                    sta       ScrEndAddr,u save to ScrEndAddr slot
                    sta       >$FFAC    task 1 block 5 x8000 - x9FFF
                    lda       $02,x     get calling module's MMU block 2 entry
                    sta       ScrStartAddr,u save to ScrStartAddr slot
                    sta       >$FFAB    task 1 block 4 x6000 - x7FFF
                    andcc     #^IntMasks unmask interrupts

                    lda       $07,x     get dispatch index from remap table
                    ldu       <EntryTable point to module entry vector table
                    adda      MmuTask1Blk0,u compute entry vector offset
                    jsr       a,u       dispatch to target module entry point

                    orcc      #IntMasks disable interrupts for MMU restore
                    lda       <SierraPdBlk Sierra's process descriptor block #
                    sta       >$FFA9    map Sierra's PD block into $2000
                    ldu       <Sierra2ndBlk point to Sierra's DAT image
                    lda       <MmuTask1Blk6 saved task-1 block 6 value
                    sta       MmuTask1Blk2,u restore DAT image entry for block 2
                    sta       >$FFAF    restore GIME MMU slot 7 (xE000)
                    lda       <MmuTask1Blk5 saved task-1 block 5 value
                    sta       MmuTask1Blk0,u restore DAT image entry for block 0
                    sta       >$FFAE    restore GIME MMU slot 6 (xC000)
                    lda       <MmuTask1Blk4 saved task-1 block 4 value
                    sta       MmuSaveTmp,u restore scratch slot
                    sta       >$FFAD    restore GIME MMU slot 5 (xA000)
                    lda       <MmuTask1Blk3 saved task-1 block 3 value
                    sta       ScrEndAddr,u restore ScrEndAddr slot
                    sta       >$FFAC    restore GIME MMU slot 4 (x8000)
                    lda       <MmuTask1Blk1 saved task-1 block 1 value
                    sta       MmuBlk2Orig,u restore MmuBlk2Orig slot
                    sta       >$FFAA    restore GIME MMU slot 2 (x4000)
                    lda       <MmuTask1Blk0 saved task-1 block 0 value
                    sta       ,u        restore DAT image task-1 slot 0
                    sta       >$FFA9    restore GIME MMU slot 1 (x2000)
                    andcc     #^IntMasks re-enable interrupts

                    jmp       [>$002A]  jump through CallerSp to restore caller

MmuSwitchEnd        fcb       $00,$00,$00,$00,$00,$00,$00,$00 ........
SierraNameStr       fcb       $73,$69,$65,$72,$72,$61,$00 sierra.

* ====== mmuini1 / mmuini2: Snapshot Task MMU Block Tables ======
* New routines so we don't have raw reads of the MMU bytes. RG
mmubuf              fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
gprbuf              fzb       512
* Get $FFA0-$FFA7
mmuini1             pshs      cc,x,y    save registers across system calls
                    orcc      #$50      disable interrupts
                    lda       #1        system ID#
                    leax      gprbuf,pcr point to process descriptor buffer          point to process descriptor buffer
                    os9       F$GPrDsc  get system process descriptor
                    leay      $41,x     point to its mmu block values
                    leax      mmubuf,pcr destination: task-0 MMU snapshot buffer
                    ldb       #8        copy 8 MMU block entries
m2lup               lda       ,y++      get MMU value and skip over usage
                    sta       ,x+       store block number and advance
                    decb                decrement copy count
                    bne       m2lup     loop until all 8 copied
                    puls      cc,x,y,pc restore registers and return
* Get $FFA8-$FFAF
mmuini2             pshs      cc,x,y    save registers across system calls
                    orcc      #$50      disable interrupts
                    os9       F$ID      get our ID#
                    leax      gprbuf,pcr point to process descriptor buffer
                    os9       F$GPrDsc  get our process descriptor
                    leay      $41,x     point to our mmu block values
                    leax      mmubuf+8,pcr destination: task-1 MMU snapshot buffer
                    ldb       #8        copy 8 MMU block entries
mloop               lda       ,y++      read MMU value from process descriptor
                    sta       ,x+       store block number and advance
                    decb                decrement copy count
                    bne       mloop     loop until all 8 copied
                    puls      cc,x,y,pc restore registers and return

                    emod
eom                 equ       *
                    end
