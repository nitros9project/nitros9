********************************************************************
* WCreate - Create a window
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   3      ????/??/??
* Original Tandy/Microware version.
*
* Annotated by /6809-annotate (Claude Code) 2026-05-12:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction

                    nam       WCreate
                    ttl       Create a window

* Disassembled 98/09/11 18:26:55 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

CmdEsc              rmb       2
ScreenType          rmb       1
WinParams           rmb       7
newtype             rmb       1
winpath             rmb       1
PrevPath            rmb       1
zflag               rmb       1
LineBuf             rmb       480
size                equ       .

name                fcs       /WCreate/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$CR
                    fcb       C$LF
                    fcc       "WCreate <windpath> [-s=stype] xpos ypos width height fcol bcol [bord]"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "Use: Create a new window"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "Options: -s=stype  place the window on a new screen, must also"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "                   include the border color."
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "         -z        receive commands from standard input"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "         -?        receive help message"
                    fcb       C$CR
                    fcb       C$LF
                    endc

CurOn               fdb       $1B21

start               clr       <zflag              clear zflag; not in -z stdin mode
                    clra                          clear A; will complement to $FF
                    coma                          complement to $FF (unset path marker)
                    sta       <PrevPath           initialize PrevPath to $FF (none set)
                    lbsr      skipspc             skip spaces
                    lda       ,x                  get next character
                    cmpa      #PDELIM             path delimiter?
                    bne       CheckOption               not a path delimiter
                    bsr       parseSkip           process window path from command line
                    bra       Exit                exit after direct path processing
CheckOption               cmpa      #'-           check if argument is an option flag
                    lbne      ShowHelp            not an option; show help and exit
                    leax      1,x                 advance X past the dash
                    lda       ,x+                 load option letter, advance X
                    ifne      DOHELP
                    cmpa      #'?
                    lbeq      ShowHelp
                    endc
                    cmpa      #'z                 check for lowercase -z option
                    beq       SetZflag            branch if -z option matched
                    cmpa      #'Z                 check for uppercase -Z option
                    lbne      ShowHelp            unknown option; show help and exit
SetZflag               lda       #$01             load 1 to set zflag
                    sta       <zflag              enable stdin command-read mode
ReadLineLoop               clra                   clear path num; stdin is path 0
                    leax      LineBuf,u           point X at input line buffer
                    ldy       #80                 max line length for I$ReadLn
                    os9       I$ReadLn
                    bcs       ReadErr             branch on read error
                    lda       ,x                  load first char of line
                    cmpa      #$2A                check if line starts with * (comment)
                    beq       SetZflag            skip comment line; re-read next
                    lbsr      skipspc             skip spaces
                    lda       ,x                  peek at first non-space char
                    cmpa      #C$CR               check if line is empty (only CR)
                    beq       DoneReading         empty line signals end of commands
                    bsr       parseWinCmd         process one window creation command
                    bcs       Exit                exit if command processing failed
                    bra       ReadLineLoop        loop to process next command line
ReadErr               cmpb      #E$EOF            check for end-of-file error
                    bne       Exit                exit with error if not EOF
DoneReading               lda       #$01          path 1 = standard output
                    lbsr      cursoron            turn on text cursor
                    lda       <PrevPath           load PrevPath; negative means unset
                    bmi       ExitOk              $FF means no prev path; exit clean
                    os9       I$Close
                    bcs       Exit                exit if close failed
ExitOk              clrb                          clear error code (success)
Exit                os9       F$Exit

parseSkip               lbsr      skipspc             skip spaces
parseWinCmd               clr       <newtype      clear screen-type flag (no -s yet)
                    clr       <ScreenType         clear screen type parameter
                    lda       ,x                  get character at X
                    cmpa      #PDELIM             pathlist delimiter?
                    lbne      Exiting             not a window path; exit with error
                    lda       #UPDAT.             set update mode for I$Open
                    pshs      u,x,a               save registers across I$Attach
                    leax      1,x                 point past pathlist delimiter
                    os9       I$Attach            attach device
                    puls      u,x,a               restore registers after I$Attach
                    lbcs      cmdReturn               return if I$Attach failed
                    os9       I$Open              open device
                    bcs       cmdReturn               return if I$Open failed
                    sta       <winpath            save path
                    lbsr      skipspc             skip spaces
                    lda       ,x+                 load next char, advance X
                    cmpa      #'-                 check for option flag
                    bne       Get6                no option; parse 6 window params
                    lda       ,x+                 load option letter, advance X
                    cmpa      #'s                 check for -s (lowercase)
                    beq       gotScreenOpt        branch if -s option
                    cmpa      #'S                 check for -S (uppercase)
                    bne       Exiting             unrecognized option; exit with error
gotScreenOpt               lda       ,x+          load char after option letter
                    cmpa      #'=                 check for required = separator
                    bne       Exiting             no =; bad syntax, exit with error
                    leay      ScreenType,u        point Y at screen type storage
                    lbsr      asc2num             convert ASCII screen type to binary
                    bcs       Exiting             exit if number conversion failed
                    inc       <newtype            mark -s option as given
                    ldb       #$07                get 7 numbers (last one is border)
                    bra       parseArgLoop        parse all 7 window arguments
Get6                leay      WinParams,u         point Y at window params buffer
                    ldb       #$06                get 6 numbers
                    leax      -1,x                back up X (undo advance past char)
parseArgLoop               bsr       asc2num      convert next ASCII arg to binary
                    bcs       Exiting             exit if argument conversion failed
                    decb                          decrement remaining arg count
                    bne       parseArgLoop        loop until all args parsed
                    leax      ,u                  point X at CmdEsc buffer start
                    lda       #$1B                ESC byte (CoCo3 window command prefix)
                    sta       ,x                  write ESC to CmdEsc[0]
                    lda       #$20                window create command byte
                    sta       1,x                 write $20 to CmdEsc[1]
                    tst       <newtype            check if -s option was given
                    beq       setNoScreenLen      branch for 9-byte write (no screen)
                    ldy       #$000A              10 bytes: ESC+$20+ScreenType+7 params
                    bra       writeWinCmd         go write the 10-byte command
setNoScreenLen               ldy       #$0009     9 bytes: ESC+$20+6 params (no screen)
writeWinCmd               lda       <winpath      load window path for I$Write
                    os9       I$Write
                    bcs       cmdReturn           return if I$Write failed
                    tst       <zflag              check if in -z stdin mode
                    beq       closeWinPath        not -z; close new path immediately
                    tst       <newtype            check if -s (new screen) was used
                    beq       closeWinPath        same screen; close path and return
                    tst       <PrevPath           check if a previous window is open
                    bpl       enableWinCursor     prev path valid; enable its cursor
                    lda       #$01                path 1 = standard output
                    bsr       cursoron            turn on text cursor
enableWinCursor               lda       <winpath  load new window path number
                    bsr       cursoron            turn on text cursor
                    bcs       cmdReturn           return if cursor enable failed
                    tst       <PrevPath           check if there is a path to close
                    bmi       savePrevPath        $FF: no prev path; just save new one
                    lda       <PrevPath           load old path number to close
                    os9       I$Close
savePrevPath               lda       <winpath     load new window path
                    sta       <PrevPath           save as active window path
                    bra       cmdReturn           return success
closeWinPath               lda       <winpath     load window path to close
                    os9       I$Close
cmdReturn               rts                       return to caller

cursoron            leax      >CurOn,pcr          load address of cursor-on sequence
                    ldy       #$0002              length = 2 bytes ($1B $21)
                    os9       I$Write
                    rts                           return to caller

skipspc             lda       ,x+                 load char and advance X
                    cmpa      #C$SPAC             check if it is a space
                    beq       skipspc             loop while spaces found
                    leax      -1,x                back up X to first non-space
                    rts                           return to caller

Exiting             leas      $02,s               discard return addr (unwind bsr caller)
ShowHelp            equ       *
                    ifne      DOHELP
                    lda       #$01
                    leax      >HelpMsg,pcr
                    ldy       #$0133
                    os9       I$Write
                    endc
                    lbra      ExitOk              exit cleanly with clrb

* Entry: X = address of ASCII string to convert
*        Y = location to store byte
* Exit:  B = converted value
asc2num             pshs      b                   save caller's B register
                    clrb                          zero result accumulator
                    stb       ,y                  initialize result at Y to zero
digitLoop               lda       ,x+             load next char, advance X
                    cmpa      #'0                 check if char is below '0'
                    blt       endOfNum            not a digit; end of number
                    cmpa      #'9                 check if char is above '9'
                    bhi       endOfNum            not a digit; end of number
                    suba      #'0                 convert ASCII digit to binary value
                    pshs      a                   save digit value on stack
                    lda       #10                 load multiplier (decimal 10)
                    ldb       ,y                  load current accumulated value
                    mul                           D = accumulated × 10
                    addb      ,s+                 add digit, pop stack
                    stb       ,y                  store updated accumulated value
                    bvs       numErr              branch if value overflowed
                    bra       digitLoop           loop for next digit
endOfNum               cmpa      #C$CR            check for carriage return terminator
                    beq       numOk               CR is valid terminator
                    cmpa      #C$SPAC             check for space terminator
                    bsr       skipspc             skip spaces
                    bra       numOk               treat non-CR terminator as valid
                    bne       numErr              (unreachable; follows bra above)
numErr               comb                         set carry flag (signal error)
                    bra       asc2numRet          return with error
numOk               clrb                          clear error flag (success)
                    leay      $01,y               advance Y to next result slot
asc2numRet               puls      pc,b           restore B and return

                    emod
eom                 equ       *
                    end

