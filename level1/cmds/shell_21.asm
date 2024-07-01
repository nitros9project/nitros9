********************************************************************
* Shell - NitrOS-9 command line interpreter
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  21      ????/??/??
* Original Tandy/Microware version.
*
*  21/2    2003/01/22  Boisy Pitre
* CHD no longer sets WRITE. permission.
*
*  22      2010/01/19  Boisy Pitre
* Added code to honor S$HUP signal and exit when received to support
* networking.

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       22

                    mod       eom,name,tylg,atrv,start,size

                    org       0
stdinpath           rmb       1         ??
stdoutpath          rmb       1         ??
stderrpath          rmb       1         ??         
xtrastack           rmb       1         additional stack size (in 256 byte pages) when forking a program (e.g. #4k or #4)
progptr             rmb       2         the program pointer to fork
parmlen             rmb       2         the parameter length of the program to fork
parmptr             rmb       2         the parameter pointer of the program to fork
u000A               rmb       2
u000C               rmb       1
nestcount           rmb       1         counter of nested parentheses for new shell marker
kbdsignl            rmb       1
immflag             rmb       1         1 = shell is immortal and won't exit; 0 = normal shell
u0010               rmb       1         ??
u0011               rmb       1         ??
suppressintro       rmb       1         1 = suppress the introductory text; 0 = don't suppress it
echoflag            rmb       1         1 = echo commands to standard output; 0 = don't echo
noxflag             rmb       1         1 = exit shell script on error; 0 = continue processing
setprid             rmb       1         ID for setting priority
devnambuf           rmb       72        input device name buffer
modheader           rmb       18        buffer used to read in module header
u0070               rmb       143
u00FF               rmb       313
stack               rmb       200
size                equ       .
name                equ       *

shellname           fcs       /Shell/
                    fcb       edition

ModulTbl            fcb       Prgrm+PCode
                    fcs       "PascalS"
                    fcb       Sbrtn+CblCode
                    fcs       "RunC"
                    fcb       Sbrtn+ICode
                    fcs       "RunB"
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    fcb       $00
                    
Intro               fcb       C$LF
                    fcc       "Shell"
                    fcb       C$CR
DefPrmpt            fcb       C$LF
OS9Prmpt            fcc       "OS9:"
OS9PrmL             equ       *-OS9Prmpt
DefPrmL             equ       *-DefPrmpt

IcptRtn             stb       <kbdsignl
* +++ BGP added for Hang Up
                    cmpb      #S$HUP
                    lbeq      exit
* +++
                    rti

* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point absolute address
*  CC = F=0, I=0, others undefined
start               leas      -$05,s          reserve some space on the stack
                    pshs      y,x,b,a         push registers
                    ldb       #u0070-1        prepare to clear variables
                    lbsr      ClearAtU        clear them
* Install signal handler                    
                    leax      <IcptRtn,pcr                  point to signal handler
                    os9       F$Icpt    install it
                    puls      x,b,a     recover all but Y earlier pushed
                    std       <parmlen  save the parameter length
                    beq       noparms@  branch if empty
                    lbsr      ParseCmdLine     start parsing the command line
                    bcs       ExitShellWithErr exit if there was an error
                    tst       <u000C
                    bne       ExitShell        exit shell if so
noparms@            lds       ,s++             get Y off stack pushed earlier (end of parameter area)
* OPT: do leax after bne
ProcLine            leax      <Intro,pcr       point to intro string
                    tst       <suppressintro   do we suppress showing the intro?
                    bne       ReadCmdLoop      yes, don't show prompt, just go read a command
                    bsr       WriteLin         else show it
                    bcs       Exit             branch if error
ShowPrompt          leax      <DefPrmpt,pcr    point to the prompt
                    ldy       #DefPrmL         load its length
chkintro@           tst       <suppressintro   do we suppress showing the intro?
                    bne       ReadCmdLoop      yes, don't show prompt
                    bsr       WritLin2         else show it
ReadCmdLoop         clra                       A = standard input
                    leax      <u0070,u         point to read buffer
                    ldy       #200             load our maximum read length
                    os9       I$ReadLn         read from the standard input
                    bcc       procinput@            branch if ok
                    cmpb      #E$EOF           did we get an EOF error?
                    beq       ExitWithEOF      handle it if so
chkimm@             tst       <immflag is this shell immortal?
                    bne       showerr@     branch if so
                    tst       <noxflag  is exit with error flag set?
                    bne       ExitShellWithErr of so, exit with error
showerr@            os9       F$PErr           print the error
                    bra       ShowPrompt            and continue reading
procinput@          cmpy      #$0001           is the input length > 1
                    bhi       testecho@            yes, process the command
                    leax      >OS9Prmpt,pcr    else return was pressed by itself; load OS-9 prompt string
                    ldy       #OS9PrmL         and load OS-9 prompt length
                    bra       chkintro@            show if needed
testecho@           tst       <echoflag echo flag set?
                    beq       parse@ branch if not
                    bsr       WriteLin else echo the command line
parse@              lbsr      ParseCmdLine parse the command line
                    bcc       ShowPrompt show prompt if no error
                    tstb error code?
                    bne       chkimm@ branch if not zero
                    bra       ShowPrompt else show prompt

eofmsg              fcc       "eof"
                    fcb       C$CR

* Shell Exit Routines
*
* This code handles exiting the shell in different scenarios.
* Note, immortal shells don't exit.
ExitWithEOF         tst       <suppressintro                do we suppress?
                    bne       ExitShell                     branch if so
                    leax      <eofmsg,pcr                   else point to EOF message
                    bsr       WriteLin                      and write it out
ExitShell           clrb                                    clear the error code
ExitShellWithErr    lda       <immflag                      are we immortal?
                    lbne      L0331                         branch if so
Exit                os9       F$Exit                        else exit

WriteLin            ldy       #80      load length
WritLin2            lda       #$02                load standard error
                    os9       I$WritLn            write the line
                    rts                 return

* I=...
Immortal            lbsr      L03B3
                    lbcs      L02ED
                    pshs      x         save X
                    ldb       #SS.DevNm
                    leax      <devnambuf,u                  point to device name buffer
                    lda       #PDELIM                       get path delimiter
                    sta       ,x+       save it and move X to next position
                    clra                          stdin
                    os9       I$GetStt            get device name
                    puls      x         restore X
                    lbcs      L02ED     branch if error
                    inc       <immflag            increment the immortal flag
                    inc       <u0010    increment ??
                    lbsr      L02ED
                    clr       <u0010 clear ??
                    rts                 return

* Match table for internal commands.
InternalCmds        fdb       Comment-*
                    fcs       "*"
                    fdb       Wait-*
                    fcs       "W"
                    fdb       Chd-*
                    fcs       "CHD"
                    fdb       Chx-*
                    fcs       "CHX"
                    fdb       Ex-*
                    fcs       "EX"
                    fdb       Kill-*
                    fcs       "KILL"
                    fdb       X-*
                    fcs       "X"
                    fdb       NOX-*
                    fcs       "-X"
                    fdb       Prompt-*
                    fcs       "P"
                    fdb       NoPrompt-*
                    fcs       "-P"
                    fdb       Echo-*
                    fcs       "T"
                    fdb       NoEcho-*
                    fcs       "-T"
                    fdb       SetPr-*
                    fcs       "SETPR"
                    fdb       Immortal-*
                    fcs       "I="
                    fdb       NextCmd-*
                    fcs       ";"
                    fdb       $0000
                    
ShellChars          fdb       Pipe-*
                    fcs       "!"
                    fdb       NextCmd2-*
                    fcs       ";"
                    fdb       Backgrnd-*
                    fcs       "&"
                    fdb       Return-*
                    fcb       C$CR+$80
                    
Redirects           fdb       AllRedir-*
                    fcs       "<>>>"
                    fdb       IERedir-*
                    fcs       "<>>"
                    fdb       IORedir-*
                    fcs       "<>"
                    fdb       OERedir-*
                    fcs       ">>>"
                    fdb       ErrRedir-*
                    fcs       ">>"
                    fdb       InRedir-*
                    fcs       "<"
                    fdb       OutRedir-*
                    fcs       ">"
                    fdb       StkSize-*
                    fcs       "#"
                    fdb       $0000

L0169               fcb       C$CR
                    fcc       "()"
                    fcb       $ff
                    
CRConst             fcb       C$CR
                    fcc       "!#&;<>"
                    fcb       $ff

* Clear from U to U+B
ClearAtU            clr       b,u       clear the location at B,U
                    decb                decrement B
                    bpl       ClearAtU     branch if >= 0
                    rts                 return

* Parse commands on the command line                    
ParseCmdLine           ldb       #kbdsignl start from the keyboard signal variable down
                    bsr       ClearAtU  and clear to start of variables
L017F               clr       <xtrastack clear optional stack value
                    clr       <kbdsignl clear the keyboard signal
                    leay      >InternalCmds,pcr point to the internal commands table
                    lbsr      DoParse parse the command line
                    bcs       L01DE branch if there was an error
                    cmpa      #C$CR     is the character a carraige return?
                    beq       L01DE     branch if so
                    sta       <u000C    else save the character
                    cmpa      #'(       open parenthesis? (start of new shell)
                    bne       L01BA     branch if not
                    leay      >shellname,pcr point to shell name
                    sty       <progptr    save the pointer
                    leax      $01,x     advance to the next character
                    stx       <parmptr    store that pointer as the parameter pointer
l0@                 inc       <nestcount    increment the new shell nest count
l1@                 leay      <L0169,pcr
                    bsr       L0227
                    cmpa      #'(       open parenthesis?
                    beq       l0@       if so, branch to nest count
                    cmpa      #')       close parenthesis?
                    bne       L01D6      branch if not
                    dec       <nestcount decrement the new shell nest count
                    bne       l1@       continue if we are still in inner shell
                    lda       #C$CR      get carriage return
                    sta       -$01,x    terminate the line
                    bra       L01BE
L01BA               bsr       L01E1
                    bcs       L01DE
L01BE               leay      <CRConst,pcr
                    bsr       L0227
                    tfr       x,d       transfer the start of the parameter from X to D
                    subd      <parmptr subtract the parameter pointer
                    std       <parmlen  and save the parameter length
                    leax      -$01,x
                    leay      >ShellChars,pcr
                    bsr       DoParse
                    bcs       L01DE
                    ldy       <progptr
L01D6               lbne      WTF
                    cmpa      #C$CR
                    bne       L017F
L01DE               lbra      L02ED

* Process command
*
* Entry: X = program on command line to execute.
L01E1               stx       <progptr  save X to program pointer
                    bsr       ParseName parse the command name
                    bcs       ex@ branch if there was an error
l@                  bsr       ParseName parse again
                    bcc       l@ and keep going until error
                    leay      >Redirects,pcr point to redirect table
                    bsr       DoParse attempt to match
                    stx       <parmptr save the parameter pointer
ex@                 rts return

* Parse the program name on the command line.
*
* Entry: X = Name to parse.
ParseName           os9       F$PrsNam  parse the name
                    bcc       ex1@      branch if carry clear
                    lda       ,x+       else get character at A
                    cmpa      #C$PERD   is it a period?
                    bne       badex@    branch if not
                    cmpa      ,x+       is it the same as the next character?
                    beq       ex2@      branch if so
                    leay      -1,x    else point Y to the previous character
ex1@                leax      ,y        copy Y to X
ex2@                clra                clear carry
                    rts                 return
badex@              comb                set carry
                    leax      -1,x    back up X one character
                    ldb       #E$BPNam  return a bad pathname
                    rts                 return

* Parse the entire command line.
*
* Entry: X = The location on the command line to parse.                    
*        Y = The location of the match table.
DoParse             bsr       SkipCnsc  skip consecutive characters at X
                    pshs      y         save off match table on stack
                    bsr       L0264     attempt to match
                    bcs       ex@       branch if no match
                    ldd       ,y        else we have a match; recover the processing routine pointer
                    jsr       d,y       call the routine
                    puls      y         recover Y
                    bcc       DoParse   if no error, continue parsing
                    rts                 else return
ex@                 clra                clear carry
                    lda       ,x        load character at X into A
                    puls      pc,y      return
                    
l0@                 puls      y         restore Y
L0227               pshs      y         save Y
                    lda       ,x+       get character at X
L022B               tst       ,y        test against character in table
                    bmi       l0@       branch if high bit set
                    cmpa      #'"       quote?
                    bne       L023B     branch if not
l@                  lda       ,x+       else get next character
                    cmpa      #'"       ending quote?
                    bne       l@        branch if not
                    lda       ,x+       get character at X and increment X
L023B               cmpa      ,y+       test against character in table entry and increment Y
                    bne       L022B     branch if no match
                    puls      pc,y      else return

* Skip over consecutive whitespace OR non-whitespace characters greater than carriage return
*
* Entry: X = Address of the first character to start the evaluation.
*
* Exit: X = Address of the first non-consecutive character.
SkipCnsc            pshs      x         save registers
                    lda       ,x+       get the character at X
                    cmpa      #C$SPAC   is it a space?
                    beq       clean@    branch if so
                    cmpa      #C$COMA   is it a comma?
                    beq       clean@    branch if so
                    leax      >CRConst,pcr point to carriage return
l@                  cmpa      ,x+       compare character to it
                    bhi       l@        branch if higher
                    puls      pc,x      grab X and return
clean@              leas      $02,s     clean the stack
                    lda       #C$SPAC   load A with space
l1@                 cmpa      ,x+       is it the next character as well?
                    beq       l1@       branch if so
                    leax      -1,x    else back up
NextCmd             andcc     #^Carry   clear the carry    
                    rts                 return                     
* X = Address of the source string.
* Y = Address of the string to match.                    
L0264               pshs      y,x       save registers
                    leay      2,y       advance past the entry pointer
L0268               ldx       ,s        recover X on the stack
L026A               lda       ,x+    get the character at X and increment X
                    cmpa      #'a    is it 'a'?
                    bcs       L0272  branch if lower than
                    suba      #$20   make uppercase
L0272               eora      ,y+    XOR with the character at Y and increment Y
                    lsla shift A left (move high bit of A into carry)
                    bne       L0286 branch if not zero
                    bcc       L026A branch if carry clear
                    lda       -1,y get the previous character
                    cmpa      #$C1 compare against ??
                    bcs       L0283 branch if carry set
                    bsr       SkipCnsc skip consecutive characters
                    bcs       L0286 branch if carry set
L0283               clra clear carry
                    puls      pc,y,b,a pull registers and return
L0286               leay      -1,y back up one
l0@                  lda       ,y+ get character
                    bpl       l0@ keep going until we get passed hi-bit char
                    sty       2,s save pointer to next entry
                    ldd       ,y++ get value at Y into D
                    bne       L0268 branch if not zero
                    comb else set carry
                    puls      pc,y,x and return

* Process the EXIT command
*
* TODO: check of no parameters so we can bypass F$Chain and just call F$Exit.
Ex                  lbsr      L01E1     process the argument as a command
                    clra                set A to standard input
                    bsr       procpath@ process standard input
                    bsr       incpath@  process standard output
                    bsr       incpath@  process standard error
                    bsr       Comment   go to end of the line
                    leax      1,x       go past end of line
                    tfr       x,d       transfer to D
                    subd      <parmptr  subtract parameter pointer
                    std       <parmlen  store as parameter length
                    leas      >u00FF,u  point S to area in our stack
                    lbsr      ExecPrep prepare for chaining
                    os9       F$Chain   chain the program
                    lbra      ExitShellWithErr     branch if error
incpath@            inca                increment the path number
procpath@           pshs      a         push the path number
                    bra       L0313     go process the path number

* Change directory
Chx                 lda       #DIR.+EXEC. set to "dir + exec"
                    bra       l@        go change the directory
* Removed WRITE. requirement (some devices are read only)
Chd                 lda       #DIR.+READ.         note write mode!!
l@                  os9       I$ChgDir  go change the directory
                    rts                 return

* Prompt on/off routine
*
* Exit: A = prompt flag
Prompt              clra                set to "don't suppress"
                    bra       n@        go save the flag state
NoPrompt            lda       #$01      set to "suppress"
n@                  sta       <suppressintro save the flag state
                    rts                 return

* Echo on/off routine
*
* Exit: A = echo flag
Echo                lda       #$01      set to "echo commands"
                    bra       n@        go save the flag state
NoEcho              clra                set to "don't echo commands"
n@                  sta       <echoflag save the flag state
                    rts                 return

* Exit script with error on/off routine
*
* Exit: A = exit with error flag
X                   lda       #$01      set to "exit with error"
                    bra       n@        go save the flag state
NOX                 clra                set to "don't exit with error"
n@                  sta       <noxflag  save the flag state
                    rts                 return

* Search for CR in string pointed to by X
* '*' Comment lines come here
*
* Exit:  A = C$CR                    
*       CC = Equal set
Comment             lda       #C$CR     load A with CR
l@                  cmpa      ,x+       is A and the character at X the same?
                    bne       l@        branch if not
                    cmpa      ,-x       set EQUAL flag in carry
                    rts                 return
                    
L02E7               pshs      b,a,cc    save registers
                    lda       #$01      start with standard output
                    bra       s@                    
L02ED               pshs      b,a,cc    save registers
                    lda       #$02      get number of paths
s@                  sta       <u0011    save the path count
                    clra                start at path 0
l@                  bsr       L02FF     go close (possibly dupe) paths
                    inca                increment path
                    cmpa      <u0011    are we at last one yet?
                    bls       l@        continue if lower or same
                    ror       ,s+       else shift CC on stack, placing hi bit into CC
                    puls      pc,b,a    return

* Entry: A = path number.                    
L02FF               pshs      a         save path number
                    tst       <u0010    test ??
                    bmi       L031B     if hi-bit set, close path
                    bne       L0313     if 0<u0019<128, get changed path # & close
                    tst       a,u       check 'real' path number from our variables
                    beq       L031E     branch if 0
                    os9       I$Close   close the current path
                    lda       a,u       get the 'real' path number
                    os9       I$Dup     duplicate it
L0313               ldb       ,s        get the passed path number
                    lda       b,u       get the real path number from our variables
                    beq       L031E     branch if 0
                    clr       b,u       else clear the variable
L031B               os9       I$Close   and close the path
L031E               puls      pc,a      return

SayWhat             fcc       "WHAT?"
                    fcb       C$CR

WTF                 bsr       L02ED     close 3 standard paths (possibly dupe)
                    leax      <SayWhat,pcr                  point to WTF value
                    lbsr      WriteLin                      write it out
                    clrb                clear the error flag
                    coma                set the carry
                    rts                 return

L0331               inc       <u0010    increment ??
                    bsr       L02ED    do path closings (possibly dupings)
                    lda       #$FF     set flag to just close raw paths
                    sta       <u0010    save to ??
                    bsr       L02E7    go close standard input and standard error
                    leax      <devnambuf,u                  point to the device name buffer
                    bsr       L03BC
                    lbcs      Exit      exit completely if there's an error
                    lda       #$02
                    bsr       L02FF
                    lbsr      L03DC
                    clr       <u0010    clear ??
                    lbra      ProcLine
InRedir             ldd       #$0001
                    bra       L036E
ErrRedir            ldd       #$020D
                    stb       -$02,x
                    bra       L035E

OutRedir            lda       #$01      A = standard output
L035E               ldb       #$02
                    bra       L036E                    
* Entry: A = path
*        B = file mode
*        X = path
L0362               tst       a,u       duped path exists?
                    bne       WTF       yes... show WTF?
                    pshs      b,a       else save A/B on the stack
                    tst       <u0010    test ??
                    bmi       L0386
                    bra       L0378
L036E               tst       a,u       is this path mode set?
                    bne       WTF       yes... WTF?
                    pshs      b,a       else save A/B on the stack
                    ldb       #C$CR     get the carriage return
                    stb       -$01,x    and terminate the line
L0378               os9       I$Dup     duplicate the standard path in A
                    bcs       L03A8     branch if there was an error
                    ldb       ,s        get the path into B
                    sta       b,u       save the duplicated path in the variable
                    lda       ,s        get the path into A
                    os9       I$Close   close the old path
L0386               lda       1,s       get file mode on stack
                    bmi       L0391     branch if directory bit is set
                    ldb       ,s        get path off stack into B
                    bsr       ChkStdSntx
                    tsta                test the file mode in A
                    bpl       L0398     branch if not a directory
L0391               anda      #%00001111 mask out all but the lower 4 bits
                    os9       I$Dup     duplicate the path in A
                    bra       L03A6     branch
L0398               bita      #WRITE.   is the write flag set?
                    bne       L03A1     branch if so
                    os9       I$Open    else open the file
                    bra       L03A6     and continue
L03A1               ldb       #PREAD.+READ.+WRITE. load the file mode
                    os9       I$Create  create the file
L03A6               stb       1,s       save it to B on the stack
L03A8               puls      pc,b,a  pull registers and return

L03AA               clra          A = standard input
L03AB               ldb       #$03 B = ??
                    bra       L0362

AllRedir            lda       #C$CR     load A with carriage return
L03B1               sta       -$04,x    terminate prior to "<>>>"
L03B3               bsr       L03BC
                    bcc       L03DC
L03B7               rts

IORedir             lda       #C$CR     load A with carriage return
                    sta       -$02,x    terminate prior to "<>"
L03BC               bsr       L03AA
                    bcs       L03B7
                    ldd       #$01*256+$80    standard output in A and hi bit in B
                    bra       L0362
                    
IERedir             lda       #C$CR     load A with carriage return
                    sta       -$03,x    terminate prior to "<>>"
                    bsr       L03AA
                    bcs       L03B7
                    ldd       #$02*256+$80    standard error in A and hi bit in B
                    bra       L0362
                    
OERedir             lda       #C$CR     load A with carriage return
                    sta       -$03,x    terminate prior to ">>>"
                    lda       #$01      offset to standard output variable
                    bsr       L03AB
                    bcs       L03B7
L03DC               ldd       #$02*256+DIR.+READ.    standard error in A and directory + read bit in B
                    bra       L0362
          
* Check if /0, /1, or /2 syntax is being used.
*
* Entry: B = path (0, 1, or 2)
*        X = pointer to characters to parse.
ChkStdSntx          pshs      x,b,a     save registers
                    ldd       ,x++                          get next two characters
                    cmpd      #'/*256+'0                    /0 (redirect standard input)?
                    bcs       ex@      branch if lower (not /0, /1, or /2)
                    cmpd      #'/*256+'2                    /2 (redirect standard error)?
                    bhi       ex@      not higher (not /0, /1, or /2)
                    pshs      x,b,a    save registers
                    lbsr      SkipCnsc skip characters after /0, /1, of /2
                    puls      x,b,a    restore registers
                    bcs       ex@      branch if carry set
                    andb      #3 mask out all but std/std/stderr
                    cmpb      1,s  same as what was passed?
                    bne       L0404 branch if not
                    ldb       1,s else get path
                    ldb       b,u and load mode in our variables
L0404               orb       #$80
                    stb       ,s save it on A in stack
                    puls      b,a
                    leas      $02,s clean stack
                    rts return
ex@                 puls      pc,x,b,a return

StkSize             ldb       #C$CR     load A with carriage return
                    stb       -1,x      store it at -1,x
                    ldb       <xtrastack  get the additional stack value
                    lbne      WTF       branch if not zero (already set)
                    lbsr      ASC2Int   else convert ASCII to integer
                    eora      #'K       XOR with K character
                    anda      #$DF      and make uppercase
                    bne       L042C     branch if this character isn't K; B is the number of pages
                    leax      $01,x     else B is the number of kilobytes
                    lda       #$04      multiply * 4 to get kilobytes
                    mul                 multiply
                    tsta                is A = 0?
                    lbne      WTF       branch if not
L042C               stb       <xtrastack save the additional stack value
                    lbra      SkipCnsc  go skip the next set of consecutive characters at X

Return              leax      -$01,x
                    lbsr      L04CA
                    bra       L043B

NextCmd2            lbsr      L04C6
L043B               bcs       L044E
                    lbsr      L02ED
                    bsr       L045F
L0442               bcs       L044E
                    lbsr      SkipCnsc
                    cmpa      #$0D
                    bne       L044D
                    leas      $04,s
L044D               clrb
L044E               lbra      L02ED

Backgrnd            bsr       L04C6
                    bcs       L044E
                    bsr       L044E
                    ldb       #$26
                    lbsr      L0597
                    bra       L0442

* Wait for a child process to die.
Wait                clra                clear A so that we don't call F$Send later
L045F               pshs      a         save the process ID on the stack
DoWait             os9       F$Wait    wait for the child
                    tst       <kbdsignl has a key been pressed?
                    beq       L0479     branch if not
                    ldb       <kbdsignl get the signal
                    cmpb      #S$Abort  is it the abort signal?
                    bne       L0491     branch if not
                    lda       ,s        else get process ID on stack
                    beq       L0491     branch if zero
                    os9       F$Send    send the signal
                    clr       ,s        clear the process ID on the stack
                    bra       DoWait     go back and wait again
L0479               bcs       L0495     branch if an error occurred
                    cmpa      ,s        is the process ID the same as on the stack?
                    beq       L0491     branch if so
                    tst       ,s        is the process ID on the stack zero?
                    beq       L0486     branch if so
                    tstb                is B = 0?
                    beq       DoWait    if so, go back and wait again
L0486               pshs      b         save ??
                    bsr       L044E
                    ldb       #'-
                    lbsr      L0597
                    puls      b
L0491               tstb
                    beq       L0495
                    coma
L0495               puls      pc,a

* Prepare to fork or chain a program.
* 
* This call loads the registers to prepare to call F$Fork or F$Chain.
ExecPrep            lda       #Prgrm+Objct forking a program
                    ldb       <xtrastack get the extra stack value
                    ldx       <progptr    get the pointer to program to fork
                    ldy       <parmlen  get the parameter length
                    ldu       <parmptr    get the parameter pointer
                    rts

* Load and launch a module.
*
* Entry: X = The path to the module to load and execute.                    
LoadNLaunch         lda       #EXEC.    load with the execution bit
                    os9       I$Open    open the file
                    bcs       L0500     branch if error
                    leax      <modheader,u  point to module header buffer
                    ldy       #M$Mode   read up to M$Mode bytes (to see if this an OS-9 module)
                    os9       I$Read    read the data
                    pshs      b,cc      save registers
                    os9       I$Close   close the file
                    puls      b,cc      restore registers (ignore any error)
                    lbcs      L0561     branch if the read failed
                    lda       M$Type,x  get the type of the module in A
                    ldy       M$Mem,x   get the memory requirements for the module in Y
                    bra       DetermineMod     determine the module type
L04C6               lda       #C$CR     load carriage return
                    sta       -1,x    terminate the line
L04CA               pshs      u,y,x save registers
                    clra clear type/language so we link any type of module
                    ldx       <progptr  get the program pointer
                    ifgt      Level-1
                    os9       F$NMLink  link the module
                    else
                    pshs      u save U
                    os9       F$Link link to the module
                    puls      u restore U
                    endc
                    bcs       LoadNLaunch  if error, load it
                    ldx       <progptr else get the program pointer again
                    ifgt      Level-1
                    os9       F$UnLoad  unload it
                    else
                    pshs      a,b,x,y,u  save registers
                    os9       F$Link    link to it
                    os9       F$UnLink unlink it
                    os9       F$UnLink and unlink it again
                    puls      a,b,x,y,u restore registers
                    endc
* Entry: X = first few bytes of module data                    
DetermineMod        cmpa      #Prgrm+Objct                  program?
                    beq       L0527                         branch if so
                    sty       <u000A    
                    leax      >ModulTbl,pcr                point to the module table
l0@                 tst       ,x                            end of table?
                    ifgt      Level-1
                    beq       badlang@                      branch if so
                    else
                    lbeq      badlang@                      branch if so
                    endc
                    cmpa      ,x+                           does type/lang byte match?
                    beq       match@                        branch if so
l@                  tst       ,x+                           else skip over the runtime module name
                    bpl       l@                            until we encounter hi-bit set
                    bra       l0@                           and test next entry
match@              ldd       <parmptr  get the parameter pointer
                    subd      <progptr subtract the program pointer
                    addd      <parmlen add the parameter length
                    std       <parmlen and store it
                    ldd       <progptr get the program pointer
                    std       <parmptr store it as the parameter pointer
                    bra       L0525                    
L0500               ldx       <parmlen get the parameter length
                    leax      $05,x add 5 to it
                    stx       <parmlen save the parameter length
                    ldx       <progptr get the program pointer
                    ldu       $04,s
                    lbsr      InRedir
                    bcs       L0561
                    ldu       <parmptr
                    ldd       #'X*256+C$SPAC
                    std       ,--u
                    ldd       #'P*256+C$SPAC
                    std       ,--u
                    ldb       #'-
                    stb       ,-u
                    stu       <parmptr    save parameter pointer
                    leax      >shellname,pcr point to shell name
L0525               stx       <progptr store in the program pointer
L0527               ldx       <progptr get the program pointer
                    lda       #Prgrm+Objct load the module/type
                    ifgt      Level-1
                    os9       F$NMLink link to the module
                    else
                    pshs      u  save U
                    os9       F$Link link to the module
                    tfr       u,y transfer the module pointer to Y
                    puls      u restore U
                    endc
                    bcc       L0535 branch if no error
                    ifgt      Level-1
                    os9       F$NMLoad else attempt to load the module
                    else
                    pshs      u save U
                    os9       F$Load attempt to load the module
                    tfr       u,y transfer the module pointer to Y
                    puls      u restore U
                    endc
                    bcs       L0561 branch if there was an error
L0535
                    ifeq      Level-1
                    ldy       M$Mem,y get the memory requirements for the module in Y
                    endc
                    tst       <xtrastack was there any extra stack added? (e.g. #4k)
                    bne       L0542 branch if so
                    tfr       y,d else just transfer the memory requrements to D
                    addd      <u000A add ??
                    addd      #$00FF round up to the next page
                    sta       <xtrastack and save it to the extra stack value
L0542               lbsr      ExecPrep
                    os9       F$Fork   fork the module
                    pshs      b,a,cc save off registers
                    bcs       L0552 branch if there was an error
                    ldx       #$0001 sleep for a tick
                    os9       F$Sleep do it
L0552               lda       #Prgrm+Objct load the module/type
                    ldx       <progptr get the program pointer
                    clr       <progptr then clear it
                    clr       <progptr+1
                    ifgt      Level-1
                    os9       F$UnLoad unload the module
                    else
                    os9       F$Link link the module
                    os9       F$UnLink unlink it
                    os9       F$UnLink unlink it again
                    endc
                    puls      pc,u,y,x,b,a,cc restore registers and return
badlang@            ldb       #E$NEMod  non-existent module
L0561               coma                set carry
                    puls      pc,u,y,x  pull registers and return

PipeName            fcc       "/pipe"
                    fcb       C$CR

Pipe                pshs      x         save X
                    leax      <PipeName,pcr                 point to the pipe device name
                    ldd       #$01*256+READ.+WRITE.         standard output in A plus read and write bit in B
                    lbsr      L0362    
                    puls      x         restore X
                    bcs       ex@       branch if error
                    lbsr      L04C6
                    bcs       ex@
                    lda       ,u        get the input path
                    bne       L0589     branch if not empty
                    os9       I$Dup     duplicate the path
                    bcs       ex@       branch if error
                    sta       ,u        save the path
L0589               clra                load A with standard input
                    os9       I$Close   close it
                    lda       #$01      load A with standard output
                    os9       I$Dup     duplicate it
                    lda       #$01      load A with standard output 
                    lbra      L02FF
L0597               pshs      y,x,b,a   save registers
                    pshs      y,x,b     save registers (use 5 bytes on stack for building an ASCII number)
                    leax      1,s       point X to X on stack
                    ldb       #'0-1     load B with the ASCII '0 - 1
L059F               incb                increment the counter in B
                    suba      #100      subtract 100
                    bcc       L059F     continue until carry is set
                    stb       ,x+       save the hundreds count at X
                    ldb       #'9+1     load B with the ASCII '9 + 1
L05A8               decb                decrement the counter in B
                    adda      #10       add 10 to A
                    bcc       L05A8     contine until the carry is set
                    stb       ,x+       save the tens count at X
                    adda      #'0       make it an ASCII digit
                    ldb       #C$CR     and load B with the carriage return
                    std       ,x        store it at X
                    leax      ,s        point to the stack
                    lbsr      WriteLin  write the line
                    leas      5,s       recover the stack used to build the ASCII number
                    puls      pc,y,x,b,a pull registers and return
* Kill a process
Kill                bsr       ASC2Int   convert the first parameter to an integer (process ID)
                    cmpb      #$02                compare against the first user process ID
                    bls       L05E7               branch if lower or same
                    tfr       b,a                 else transfer process ID to A
                    ldb       #S$Kill             load B with kill signal
                    os9       F$Send              and send to process in A
ex@                 rts                 return
*
* Entry: X = ASCII representation of number
* Exit : B = decimal value of ASCII number
ASC2Int             clrb                clear B
l@                  lda       ,x+       get character at X
                    suba      #$30      subtract ASCII 0
                    cmpa      #$09      compare against 9
                    bhi       nondigit@ branch if higher (not a digit)
                    pshs      a         else save A
                    lda       #10       load multiplicand
                    mul                 multiply
                    addb      ,s+       add the pushed value
                    bcc       l@        branch if carry clear
nondigit@           lda       ,-x       get previous character
                    bcs       L05E5     branch if carry set
                    tstb                is B = 0?
                    bne       ex@       branch if not
L05E5               leas      2,s       else eat the return value on the stack
L05E7               lbra      WTF       we can't parse

* Set Priority
*
* Parse the command's parameters (e.g. setpr 3 128)
SetPr               bsr       ASC2Int            convert the first parameter to an integer (process ID)
                    stb       <setprid           save it
                    lbsr      SkipCnsc           skip consecutive characters
                    bsr       ASC2Int            convert the next parameter to an integer (priority)
                    lda       <setprid           load A with process ID
                    os9       F$SPrior           set the priority
                    rts                          return

                    emod
eom                 equ       *
                    end
