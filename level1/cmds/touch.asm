********************************************************************
* Touch - Changes last modification date/time
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      2003/01/11  Boisy G. Pitre
* Rewrote touch from scratch, made almost 90% smaller than C version
* found in the OS-9 Development System.

                    nam       Touch
                    ttl       Changes last modification date/time

                    ifp1
                    use       defsfile
                    endc

* Here are some tweakable options
DOHELP              set       0                   1 = include help info
STACKSZ             set       128                 estimated stack size
PARMSZ              set       256                 estimated parameter size
ZOPTSIZ             set       64                  max size of -z option's parameter

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

* Your utility's static storage vars go here
                    org       0
parmptr             rmb       2                   pointer to our command line params
bufptr              rmb       2                   pointer to user expandable buffer
bufsiz              rmb       2                   size of user expandable buffer
* What follows are utility specific options
nocreate            rmb       1
quiterr             rmb       1
filemode            rmb       1
filecnt             rmb       1
zoptflg             rmb       1                   1 = this option has been processed once already
zpath               rmb       1                   path to -z file
cleartop            equ       .                   everything up to here gets cleared at start
zopt                rmb       ZOPTSIZ             buffer for what follows after -c=
* Next is a user adjustable buffer with # modifier on command line.
* Some utilities won't need this, some will.
* Currently set up to be larger for Level 2 than Level 1
* Note: this buffer must come just before the stack
                    ifgt      Level-1
bigbuff             rmb       8*1024              8K default buffer for Level 2
                    else
bigbuff             rmb       512                 512 byte default buffer for Level 1
                    endc
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /Touch/
                    fcb       edition

* Place constant strings here
                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcc       /Use: Touch [<opts>] <path> [<path>] [<opts>]/
                    fcb       C$LF
                    fcc       /  -c = don't create files/
                    fcb       C$LF
                    fcc       /  -q = don't quit on error/
                    fcb       C$LF
                    fcc       /  -x = search execution directory/
                    fcb       C$LF
                    fcc       /  -z = get files from standard input/
                    fcb       C$LF
                    fcc       /  -z=<file> get files from <file>/
                    fcb       C$LF
CR                  fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc
UnkOpt              fcc       /unknown option: /
UnkOptL             equ       *-UnkOpt
CantTch             fcc       /can't touch "/
CantTchL            equ       *-CantTch
EndCant             fcc       /" - /
EndCantL            equ       *-EndCant

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
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined

* The start of the program is here.
* Before any command line processing is done, we clear out
* our static memory from U to cleartop, then determine the
* size of our data area (minus the stack).
start               pshs      u,x                 save registers for later
                    leax      <cleartop,u         point to end of area to zero out
                    ifne      H6309
                    subr      u,x                 subtract U from X
                    tfr       x,w                 and put X in W
                    clr       ,-s                 put a zero on the stack
                    tfm       s,u+                and use TFM to clear starting at U
                    leas      1,s                 clean up the stack
                    else
                    pshs      x                   save end pointer on stack
clrnxt              clr       ,u+                 clear out
                    cmpu      ,s                  done?
                    bne       clrnxt              branch if not
                    leas      2,s                 else clear stack
                    endc
                    puls      x,u                 and restore our earlier saved registers
                    leay      bigbuff,u           point Y to copy buffer offset in U
                    stx       <parmptr            save parameter pointer
                    sty       <bufptr             save pointer to buffer
                    tfr       s,d                 place top of stack in D
                    ifne      H6309
                    subr      y,d
                    else
                    pshs      y                   save Y on stack
                    subd      ,s++                get size of space between copybuf and X
                    endc
                    subd      #STACKSZ+PARMSZ     subtract out our stack
                    std       <bufsiz             size of our buffer

* At this point we have determined our buffer space and saved pointers
* for later use.  Now we will parse the command line for options that
* begin with -
                    lda       ,x
                    cmpa      #C$CR               CR?
                    lbeq      ShowHelp            if so, no parameters... show help and exit
GetChar             lda       ,x+                 get next character on cmd line
                    cmpa      #C$CR               CR?
                    lbeq      DoTouch             if so, do whatever this utility does
                    cmpa      #'-                 is it an option?
                    beq       GetDash             if so, process it
                    inc       <filecnt            else must be a non-option argument (file)
                    lbsr      SkipNSpc            move past the argument
ChkDash             lbsr      SkipSpcs            and any following spaces
                    bra       GetChar             start processing again
GetDash             lda       #C$SPAC             get a space char
                    sta       -1,x                and wipe out the dash from the cmd line
GetDash2            ldd       ,x+                 load option char and char following
                    ora       #$20                make lowercase
IsItC               cmpa      #'c                 is it this option?
                    bne       IsItQ               branch if not
                    sta       <nocreate
                    lbra      FixCmdLn
IsItQ               cmpa      #'q                 is it this option?
                    bne       IsItX               branch if not
                    inc       <quiterr
                    lbra      FixCmdLn
IsItX               cmpa      #'x                 is it this option?
                    bne       IsItZ               branch if not
                    lda       #EXEC.
                    sta       <filemode
                    bra       FixCmdLn
IsItZ               cmpa      #'z                 is it this option?
                    bne       BadOpt              branch if not
                    tst       <zoptflg            was this option already specified?
                    bne       BadOpt              show help if so
                    sta       <zoptflg            else tag this option as parsed
                    cmpb      #'=                 2nd char =?
                    bne       FixCmdLn
GetZFile            ldb       #C$SPAC             get space
                    stb       -$01,x              write over c
                    stb       ,x+                 and = sign, inc X to dest dir
* check for valid char after -z=
                    lda       ,x
                    cmpa      #C$SPAC
                    lbeq      ShowHelp
                    cmpa      #C$COMA
                    lbeq      ShowHelp
                    cmpa      #C$CR
                    lbeq      ShowHelp
                    leay      <zopt,u             point Y to parameber buffer
                    tfr       y,d                 transfer Y to D
                    addd      #ZOPTSIZ
                    pshs      b,a                 save updated ptr value
                    ldb       #C$SPAC             get space
L0339               lda       ,x                  get byte at X
                    stb       ,x+                 store space at X and inc
                    sta       ,y+                 save loaded byte at Y and inc
                    cmpy      ,s                  are we at end?
                    beq       L035D               branch if so (buffer too small)
                    cmpa      #C$SPAC             else is char in A a space?
                    beq       L0350               branch if so
                    cmpa      #C$COMA             coma?
                    beq       L0350               branch if so
                    cmpa      #C$CR               cr?
                    bne       L0339               get next byte if not
L0350               leax      -1,x
                    sta       ,x                  restore previous A
                    leas      $02,s               kill stack
* attempt to open a path to the file
                    pshs      x
                    leax      <zopt,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      Exit
                    sta       <zpath
                    puls      x
                    lbra      ChkDash
L035D               leas      $02,s
                    ldb       #$BF                else buffer size too small
                    orcc      #Carry
                    lbra      Exit
FixCmdLn            lda       #C$SPAC             get space
                    sta       -$01,x              and wipe out option character
                    cmpb      #'0
                    lblt      ChkDash             start dash option processing again
                    lbra      GetDash             possibly another option following?

* We branch here if we encounter an unknown option character
* A = bad option character
BadOpt              leax      UnkOpt,pcr
                    ldy       #UnkOptL
                    ldb       #C$CR
                    pshs      d                   save bad option and CR on stack
                    lda       #$02                stderr
                    os9       I$Write
                    leax      ,s                  point X at option char on stack
                    os9       I$WritLn            print option and CR
                    puls      d                   clean up stack
                    lbra      ShowHelp


* At this point options are processed.
* We load X with our parameter pointer and go down the command line
* looking at each file to process (options have been wiped out with
* spaces)
*
* Note, the following two instructions may not be needed, depending on
* if your utility requires a non-option on the command line.
DoTouch             tst       <zoptflg            -z specified?
                    beq       DoFiles             no, do any files on command line
ReadZ               lda       <zpath
                    ldy       #80
                    os9       I$ReadLn
                    lbsr      SkipSpcs
                    cmpa      #C$CR
                    beq       ClosEx
                    bcs       TestErr
                    bsr       ProcFile
                    bra       ReadZ
TestErr             cmpb      #E$EOF
                    lbne      Exit
                    tsta
                    lbeq      ExitOk
ClosEx              os9       I$Close             close path to -z= file
                    lbra      ExitOk

DoFiles             tst       <filecnt            we should have at least one file on cmdline
                    lbeq      ShowHelp            if not, exit with error
                    ldx       <parmptr            get our parameter pointer off stack
DoLoop              lbsr      SkipSpcs            skip any leading spaces
                    cmpa      #C$CR               end of parameters?
                    beq       ExitOk              if so, end the utility
                    pshs      x                   save pointer to arg
                    bsr       ProcFile            process file at X
                    puls      x                   get arg pointer
                    lbsr      SkipNSpc            skip the argument we just processed
                    bra       DoLoop

* This routine processes one file at a time.
* Entry: X = ptr to argument on the command line.
* On exit, X can point to the argument or past it.
* Note that there are NO leading spaces.
* They have been skipped by the caller.
* The following code just echos the command line argument, followed
* by a carriage return.
ProcFile
                    lda       #WRITE.
                    ora       <filemode
                    pshs      x
                    os9       I$Open
                    puls      x
                    bcc       CloseIt
                    ora       #DIR.
                    pshs      x
                    os9       I$Open
                    puls      x
                    bcc       CloseIt
* open failed... should we do create?
                    tst       <nocreate
                    beq       DoCreate
ChkQuit             bsr       CantTouch
                    tst       <quiterr
                    beq       ExitOK
                    bra       ProcRTS
DoCreate            ldb       #PREAD.+UPDAT.
                    pshs      x
                    os9       I$Create
                    puls      x
                    bcs       ChkQuit
CloseIt             os9       I$Close
ProcRTS             rts

CantTouch
                    pshs      x,b                 save pointer to file and error code
                    leax      CantTch,pcr
                    lda       #$02
                    ldy       #CantTchL
                    os9       I$Write
                    ldx       1,s
                    pshs      x
                    bsr       StrLen
                    puls      x
                    os9       I$Write
                    leax      EndCant,pcr
                    ldy       #EndCantL
                    os9       I$Write
                    puls      b
                    os9       F$PErr
                    puls      x,pc

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #$02                std error
                    os9       I$WritLn            write it
                    endc
ExitOk              clrb                          clear carry
Exit                os9       F$Exit              and exit

* This routine counts the number of non-whitespace characters
* starting at X
*
* Entry:
*   X = ptr to string (space, comma or CR terminated)
* Exit:
*   Y = length of string
*   X = ptr to byte after string
StrLen              pshs      a
                    ldy       #$0000
StrLenLp            lda       ,x+
                    cmpa      #C$SPAC
                    beq       StrLenEx
                    cmpa      #C$COMA
                    beq       StrLenEx
                    cmpa      #C$CR
                    beq       StrLenEx
                    leay      1,y
                    bra       StrLenLp
StrLenEx            puls      a,pc

* This routine copies a string of text from X to Y until
* a whitespace character or CR is encountered
*
* Entry:
*   X = ptr to src string
*   Y = ptr to dest string
* Exit:
*   D = number of bytes copied
*   X = ptr to byte after original string
*   Y = ptr to byte after copied string
StrCpy              pshs      u
                    ldu       #$0000
CopyFnLp            lda       ,x+
                    cmpa      #C$SPAC
                    beq       CopyFnEx
                    cmpa      #C$COMA
                    beq       CopyFnEx
                    cmpa      #C$CR
                    beq       CopyFnEx
                    sta       ,y+
                    leau      1,u
                    bra       CopyFnLp
CopyFnEx            tfr       u,d
                    puls      u,pc

* This routine skip over spaces and commas
*
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first non-whitespace char
*   A = non-whitespace char
SkipSpcs            lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipSpcs
                    cmpa      #C$COMA
                    beq       SkipSpcs
                    leax      -1,x
                    rts

* This routine skips over everything but spaces, commas and CRs
*
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first whitespace char
*   A = whitespace char
SkipNSpc            lda       ,x+
                    cmpa      #C$SPAC
                    beq       EatOut
                    cmpa      #C$COMA
                    beq       EatOut
                    cmpa      #C$CR
                    bne       SkipNSpc
EatOut              leax      -1,x
                    rts

                    emod
eom                 equ       *
                    end
