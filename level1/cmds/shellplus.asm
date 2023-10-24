********************************************************************
* Shellplus - Enhanced shell for NitrOS-9
*
* Modified by L. Curtis Boyle from original 2.2 disassembly
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  21      ????/??/??
* Original Tandy/Microware version.
*
*  22/2    ????/??/??
* History and numerous features added.
*
*  23      2010/01/19  Boisy G. Pitre
* Added code to honor S$HUP signal and exit when received to support
* networking.

                    nam       Shell
                    ttl       Enhanced shell for NitrOS-9

* Disassembled 93/04/15 14:58:18 by Disasm v1.6 (C) 1988 by RML
* Signals: Signals 2 & 3 are assigned new keys to handle forward/backward
* command history. Signal $B (11) is the signal sent out on a key being ready
* for normal command processing

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       23

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       1                   Path # for standard input
u0001               rmb       1                   Path # for standard output
u0002               rmb       1                   Path # for standard error
u0003               rmb       1                   # of 256 byte pages of data mem for frked module
u0004               rmb       2                   Temp ptr (current parse ptr, mem module ptr,etc)
u0006               rmb       2                   Size of current group
u0008               rmb       2                   Pointer to start of current group (past '(')
u000A               rmb       2
u000C               rmb       1                   Current char. being processed in command parser
u000D               rmb       1                   # of command groups [ '()' groupings ]
u000E               rmb       1                   unprocessed signal # (0=none waiting)
u000F               rmb       1                   ??? Flag of some sort
u0010               rmb       2                   ??? (ptr to some module name)
u0012               rmb       1                   Current working DIR path #
u0013               rmb       1                   Flag to kill parent process (1=Kill parent)
u0014               rmb       1                   Flag: If set, a result must not be 0 ???
u0015               rmb       1
u0016               rmb       1
u0017               rmb       1
u0018               rmb       1                   Immortal shell (0=NO)
* A clearing routine only does u0000 to u0018
u0019               rmb       1
u001A               rmb       2
u001C               rmb       1                   Shell logging on flag (0=OFF)
u001D               rmb       1                   Shell prompting (0=ON)
u001E               rmb       1                   Echo input (0=OFF)
u001F               rmb       1                   Variable expansion (0=ON)
u0020               rmb       1                   Kill shell on error (0=OFF)
u0021               rmb       1                   Process # to set priority on
u0022               rmb       1                   Priority to set (0=don't change) (ours or fork)
u0023               rmb       2
u0025               rmb       2                   End of data mem ptr (top of stack)
u0027               rmb       1
u0028               rmb       1
u0029               rmb       1
u002A               rmb       2
u002C               rmb       2
u002E               rmb       1
u002F               rmb       1
u0030               rmb       1
u0031               rmb       1
u0032               rmb       2
u0034               rmb       3
u0037               rmb       1                   Flag: 0=Data dir .PWD invalid, 1=valid
u0038               rmb       1                   Flag: 0=Exec dir .PXD invalid, 1=valid
u0039               rmb       1
u003A               rmb       1
u003B               rmb       2
u003D               rmb       1
u003E               rmb       2
u0040               rmb       2                   Ptr to start of filename (vs. pathname) ('/')
* Shell prompt flag
u0042               rmb       1                   Current working dir path already done flag
u0043               rmb       1
u0044               rmb       1
u0045               rmb       1                   ??? <>0 means looking for GOTO label?
u0046               rmb       1                   Flag: 1=GOTO label found?
u0047               rmb       1                   Error code from ReadLn or signal
u0048               rmb       2                   Ptr to 1st char after redirection symbols
u004A               rmb       2                   Ptr to text message
u004C               rmb       2                   Size of text message
u004E               rmb       1
u004F               rmb       1                   0=no pathname in parm line, else IS pathname
u0050               rmb       2
u0052               rmb       2                   Current expanded buffer size (max=2048)
u0054               rmb       2                   Ptr to current char in wildcard filename we are
*                               checking
u0056               rmb       2                   Ptr to current pos in expanded buffer
u0058               rmb       2                   Pointer to end of GOTO label name
u005A               rmb       2                   User ID # from F$ID call
u005C               rmb       1
u005D               rmb       1
u005E               rmb       1                   Device type: 0=SCF (keyboard),1=RBF (Scriptfile)
u005F               rmb       1
u0060               rmb       1                   Data module linked flag: 1= Yes
u0061               rmb       2                   Ptr to data module name
u0063               rmb       2                   Ptr to intercept routines data mem
u0065               rmb       2                   Execution address of linked module
u0067               rmb       2                   Start address of module
u0069               rmb       2
u006B               rmb       1                   Flag: 0=No module to unlink, <>0 module to unlink
u006C               rmb       1
u006D               rmb       1                   Start of device name buffer (start with '/')
u006E               rmb       71                  Actual device name
u00B5               rmb       20                  Start of another device name buffer ('/')
u00C9               rmb       13
u00D6               rmb       13                  Standard module header info (M$ID-M$Mem)
u00E3               rmb       5                   Module name string (reserves 64 chars)
u00E8               rmb       3
u00EB               rmb       4
u00EF               rmb       10                  Temp buffer (many uses)
u00F9               rmb       6
u00FF               rmb       37                  Place to point SP when CHAINing
u0124               rmb       81                  Temporary buffer (used for several things)
u0175               rmb       119                 Part of temp buffer for ReadLn (200 chars total)
u01EC               rmb       2                   Least sig. 2 digits of process # (ASCII format)
u01EE               rmb       1
u01EF               rmb       2                   Holding area for 2 digit ASCII conversions
* Shell prompt parsing flags
u01F1               rmb       1                   Process ID # already done flag
u01F2               rmb       1                   Standard output device name already done flag
u01F3               rmb       1                   Quoting on flag in shell prompt string parsing
u01F4               rmb       1                   Date already done flag
u01F5               rmb       1                   Time already done flag
u01F6               rmb       1                   Date OR time already done flag
u01F7               rmb       2                   Size of expanded shell prompt
u01F9               rmb       25                  Current shell prompt string
u0212               rmb       1                   Lead in Line feed for expanded shell prompt
u0213               rmb       199                 Expanded shell prompt
u02DA               rmb       6                   Date/time packet
u02E0               rmb       8                   Date string
u02E8               rmb       1                   Space separating date & time (for shell init)
u02E9               rmb       9                   Time string (and CR)
u02F2               rmb       131
u0375               rmb       131
u03F8               rmb       29
u0415               rmb       2
u0417               rmb       1
u0418               rmb       400                 Intercept routines memory area (not used)
u05A8               rmb       810                 Shell variables (user?)
u08D2               rmb       810                 Shell variables (shell sub?)
u0BFC               rmb       80
u0C4C               rmb       81                  Copy of GOTO label name
u0C9D               rmb       32                  DIR Entry buffer
u0CBD               rmb       32                  Shell logging filename (append mode '+')
u0CDD               rmb       400                 PATH=Buffer (each entry CR terminated)
u0E6D               rmb       2048                Fully expanded filenames buffer (for wildcards)
* Actually,this next block appears to be generic buffers for various functions
u166D               rmb       80                  Process descriptor copies go here (512 bytes)
u16BD               rmb       1
u16BE               rmb       80
u170E               rmb       238
u17FC               rmb       10
u1806               rmb       2                   ??? Ptr to end of shell history buffers
u1808               rmb       2                   Ptr to where next history entry will go
u180A               rmb       2                   Ptr to start of shell history buffers
u180C               rmb       1                   # of lines in history buffer (1-(u180C))
u180D               rmb       1                   Current line # in history buffer
u180E               rmb       1                   Original keyboard terminate char
u180F               rmb       1                   Original keyboard interrupt char
u1810               rmb       1
u1811               rmb       1                   Original end of line NUL count
u1812               rmb       1                   Flag to indicate if we have to restore PD.OPT
u1813               rmb       2
u1815               rmb       808                 Shell history copies start here
u1B3D               rmb       963                 Local stack space, etc.
size                equ       .
name                equ       *
L000D               fcs       /Shell/
                    fcb       edition
L0013               fcb       Prgrm+PCode
                    fcs       'PascalS'
                    fcb       Sbrtn+CblCode
                    fcs       'RunC'
                    fcb       Sbrtn+ICode
L0021               fcs       'RunB'
                    fcb       $00,$00,$00,$00,$00,$00,$00,$00,$00
L002E               fcb       C$LF
                    fcc       'Shell+ v2.2a '
L003C               fcb       $00
L003D               fcc       '{@|#}$:                 '
L0055               fcc       '+++START+++'
                    fcb       C$CR
L0061               fcc       '+++END+++'
                    fcb       C$CR
* Intercept routine
L006B               stb       <u000E              Save signal code & return
* +++ BGP added for Hang Up
* +++ Note we are exiting even if shell is immortal!
                    cmpb      #S$HUP
                    lbeq      exit
* +++
                    rti

start               leas      -5,s                Make 5 byte buffer on stack
                    pshs      y,x,d               Save Top/bottom of param area, and size of area
                    leax      >u1815,u            Pointer to start of history buffer area
                    stx       >u1808,u            Save ptr to where next history entry goes
                    stx       >u180A,u            Save ptr to start of history buffers
                    leax      >$0328,x            Setup up another pointer (end of history area?)
                    stx       >u1806,u            Save it
                    clr       >u1812,u            Clear flag that we have to restore PD.OPT
                    clr       >u180D,u            Current line # of history buffer=0
                    clr       >u180C,u            # lines in history buffer=0
                    ldx       2,s                 Get back top of data area ptr
                    ldb       #$FF                255 bytes to clear
                    lbsr      L0412               Go clear direct page
                    sts       <u0025              Save current stack ptr
                    stu       <u0027              Save Data mem ptr (0)
                    leax      >u0418,u            Point to intercept routines memory area
                    stx       <u0063              Save a copy of it
                    leax      <L006B,pc           Point to intercept routine
                    os9       F$Icpt              Setup the intercept routine
                    lbsr      L16A6               Get user #, and make 2 digit ASCII ver. @ 1EC
                    lbsr      L1674               Make shell logging pathname @ CBD
                    leax      <L003D,pc           Point to default shell prompt string
                    lbsr      CmdPEq              Go create shell prompt string & prompt itself
                    leax      >u05A8,u            Point to start of shell variables
                    ldd       #C$CR*256+20        Carriage return (blank entries) & all 20 of them
L009C               sta       ,x                  Mark shell variable as blank
                    leax      <81,x               Point to next entry (81 bytes/entry)
                    decb                          Do until all 20 are done (user & shell sub)
                    bne       L009C
                    sta       >u0CDD,u            Init 1st 2 entries of PATH= buffer to CR's
                    sta       >u0CDD+1,u
                    puls      x,d                 Get parameter ptr & parameter size
                    std       <u0006              Save size of parameter area
                    beq       L00BF               If no parameters, skip ahead
                    lbsr      L041B               Pre-Parse parameters passed to this shell
                    lbcs      L01FA               Error, go handle it
                    tst       <u000C              Any char being processed in parser?
                    lbne      L01F9               Yes, skip ahead
L00BF               lbsr      L0225               Release any keyboard/mouse signals & get PD.OPT
                    inc       <u006C              ??? Set flag
                    lds       ,s++                Since parameters parsed, point SP to top of mem
                    sts       <u0025              Save end of data mem ptr (top of stack)
                    stu       <u0027              Save start of data mem ptr
L00CC               leax      >L002E,pc           Point to Shellplus v2.2 message
                    tst       <u001D              Shell prompting turned on?
                    bne       L00EA               No, skip ahead
                    ldy       #$000E              Length of message
                    lda       #$01                Standard out
                    os9       I$Write             Write it
                    lbcs      L0200               If error writing, terminate Shellplus
                    bsr       L00FB               Go create date & time strings
                    lbsr      L021B               Write out date & time
                    lbcs      L0200               If error writing, terminate Shellplus
L00EA               clra
                    sta       <u005C
                    leax      >L0055,pc           Point to '+++START+++' for shell logging
                    lbsr      L07E7               Go deal with logging if necessary
                    tst       <u001D              Shell prompting turn on?
                    bne       L0120               No, skip ahead
                    bra       L010D               Yes, do something else first

L00FB               clr       >u01F6,u            Clear date or time done flag
                    lbsr      L0B3B               Create current date & time strings
                    lda       #C$SPAC             Put in a space to separate date & time
                    sta       >u02E8,u
                    leax      >u02E0,u            Point to start of date buffer
                    rts

* Shell just booted goes here
L010D               lbsr      L09F7               Update expanded shell prompt if needed
                    leax      >u0212,u            Point to expanded shell prompt
                    ldy       >u01F7,u            Get size of expanded shell prompt
L0119               tst       <u001D              Shell prompting on?
                    bne       L0120               No, continue on
                    lbsr      L021F               Print shell prompt to standard error
* Shell already booted goes here
L0120               clra
                    leax      >u0124,u            Point to an input line of some sort
                    tst       <u006B              Any module linked?
                    beq       L015B               No, continue on
                    ldy       <u0065              Yes, get Execution address of linked module
                    cmpy      <u0069              ???
                    lbhs      L01F0
                    ldb       #200                LDW #200/PSHS X/TFM Y+,X+
                    pshs      x                   Copy temporary buffer to [<u0065]
L0137               lda       ,y+
                    sta       ,x+
                    decb
                    beq       L014E               Whole buffer copied, skip ahead
                    cmpy      <u0069              But don't go past here
                    bhs       L0147
                    cmpa      #C$CR               Also, stop on carriage return
                    bne       L0137
L0147               sty       <u0065              Save new start address
                    puls      x                   Restore ptr to u0124
                    bra       L01B9               Skip ahead

L014E               lda       ,y+
                    cmpy      <u0069
                    bhs       L0147
                    cmpa      #C$CR
                    bne       L014E
                    bra       L0147

L015B               tst       <u005E              We reading from script file?
                    bne       L017F               Yes, skip ahead
                    ldd       #SS.Relea           Std input path/release keyboard+mouse signals
                    os9       I$SetStt            Release any keyboard signals
                    lbsr      L18DB               Go modify signals 2&3 to use up/down arrows,
*                               set up to re-enable Kybd signals
L016A               clr       <u000E              Clear out last signal received
                    os9       I$SetStt            Re-set up SS.SSig
* NOTE: This BRA L0177 is required for type-ahead to work
                    bra       L0177               Go check for history-related signals

* DOESN'T SEEM TO GET BACK TO HERE WHEN ABORT BUG APPEARS
L0171               ldx       #$0000              Sleep until signal is received
                    os9       F$Sleep
L0177               lbra      L191C               Go check for history signals (PD.QUT & PD.INT)
* Signal received is not PD.QUT or PD.INT goes here
L017B               cmpb      #$0B                Key pressed signal?
                    bne       L0171               No, ignore signal & go to sleep again
* Keyboard input received signal goes here
L017F               leax      >u0124,u            Point to temp buffer to hold line
                    clra                          Std Input
                    ldy       #200                Maximum 200 char. input
                    lbra      L193E               Go read the rest of line as ReadLn

* Comes here after line or signal received & processed
* NOTE: IF LINE RECEIVED, PD.QUT & PD.INT ARE BACK TO NORMAL VALUES
L018B               bcc       L01B9               If no errors, skip ahead
                    cmpb      #E$EOF              <ESC> key in ReadLn?
                    beq       L01F0               Yes, skip ahead

L0191               lds       <u0025              Get top of stack ptr
                    ldu       <u0027              Get back ptr to DP
                    stb       <u0047              Save error code
                    tst       <u0046              GOTO label active?
                    bne       L01A4               Yes, go print error message
                    tst       <u0018              Is this shell immortal?
                    bne       L01A4               Yes, go print error message
                    tst       <u0020              Kill shell on error?
                    bne       L01FA               Yes, go do that

L01A4               os9       F$PErr              Print the error message
                    tst       <u0046              GOTO label active?
                    lbeq      L010D               No, go print shell prompt/process next line
                    clr       <u0046              Clear GOTO label flag
                    leax      >u0C4C,u            Point to copy of GOTO label name
                    lbsr      CmdGOTO             Go process GOTO line
                    lbra      L010D               Go print shell prompt/process next line

* No error received on line
L01B9               cmpy      #$0001              Just 1 char read (just a CR)?
                    bhi       L01CE               No, go parse parameters
                    lbsr      L09F7               Go update date/time & expanded shell prompt
                    leax      >u0213,u            Point to expanded shell prompt
                    ldy       >u01F7,u            Get size of expanded shell prompt
                    lbra      L0119               Go print shell prompt & get next line from user

* No errors-got input line, and there is something in it
L01CE               lbsr      L041B               Go parse parameters?
                    pshs      cc                  Save flags
                    tst       <u0045
                    bne       L01D9
                    clr       <u0047              Clear error/signal code from ReadLn
L01D9               puls      cc                  Restore flags
                    lbcc      L010D               If no error from parse, do prompts & read again
                    tstb                          If a 0 error, do prompts & read again
                    lbeq      L010D
                    tst       <u0045              ??? Do we care about errors?
                    bne       L0191               No, go handle error
                    stb       <u0047              Save error/signal code
                    bra       L0191               Go handle error

L01EC               fcc       'eof'
                    fcb       C$CR

* <ESC> received
L01F0               tst       <u001D              Shell prompting on?
L01F2               bne       L01F9               No, skip printing 'eof' to screen
                    leax      <L01EC,pc           Point to 'eof' string
                    bsr       L021B               Write it out to std error
L01F9               clrb                          No error flag
* Possible shell error - Process
L01FA               lda       <u0018              Is this shell immortal?
                    lbne      L0BDA               Yes, go close or dupe paths
* Shell not immortal, exit routine in here
L0200               pshs      u,b,cc              Preserve regs
                    tst       <u006B              Shellsub module to unlink?
                    beq       L020B               No, skip ahead
                    ldu       <u0067              Yes, get ptr to module
                    os9       F$UnLink            Unlink it
L020B               puls      u,b,cc              Restore U, error # & flags
* EX with no module name (or non-existant one) go here
L020D               pshs      b,cc                Save error # & flags
                    leax      >L0061,pc           Point to '+++END+++' string
                    lbsr      L07E7               Close log file if one is open, restore ID #
                    puls      b,cc                Restore error # & flags
exit                os9       F$Exit              Terminate shellplus

L021B               ldy       #80                 Write up to 80 chars or CR
L021F               lda       #$02                Std error path
                    os9       I$WritLn            Write message out & return
                    rts

L0225               pshs      y,x,d               Preserve regs
                    ldd       #SS.Relea           Std In & Release keyboard & mouse signals
                    os9       I$SetStt
                    bcc       L0233               No error, continue
                    lda       #$01                Couldn't release keyboard/mouse signals flag
                    bra       L0241

L0233               leax      >u0124,u            Point to buffer for current path options
                    clra
                    clrb                          CHANGE TO CLRB
                    os9       I$GetStt            Get std input path options
                    lda       >u0124,u            Get Device type (0 (SCF) usually)

L0241               sta       <u005E              Save device type (1=SS.Relea failed)
                    puls      pc,y,x,d            Restore regs & return

* R= command (redirect specific paths)
CmdREq              lda       ,x                  Get char from input line
                    cmpa      #'<                 Is it input path?
                    beq       L0251               Yes, skip ahead
                    cmpa      #'>                 Is it an output/error path?
                    lbne      L0BCF               No, print 'WHAT?'
L0251               pshs      x                   Preserve ptr to 1st redirection symbol
                    leay      >L03CF,pc           Point to modifier symbol table
                    lbsr      L092A               Go to command line parser
                    lbcs      L0BCF               Error, print 'WHAT?'
                    ldd       ,y                  Get table offset
                    jsr       d,y                 Call appropriate subroutine
                    stx       <u0048              Save ptr to source after redirection symbols
                    puls      x                   Restore ptr to redirection symbols
                    lbcs      L0B96               If error in subroutine, close paths & return

L026A               lda       ,x+                 Get 1st char again
                    cmpa      #'<                 Input path?
                    beq       L026A               Yes, skip to next
                    cmpa      #'>                 Output or Error path?
                    beq       L026A               Yes, skip to next
                    cmpa      #'-                 Overwrite old file?
                    beq       L026A               Yes, skip to next
                    cmpa      #'+                 Append to old file?
                    beq       L026A               Yes, skip to next
                    leax      -1,x                Point to non-redirect char
                    bsr       L02A3               Make name buffer, release signals,parse modifiers
                    clrb                          Start path # 0
L0281               pshs      b                   Save on stack
                    lda       b,u                 Get special path #
                    beq       L028A               None, skip ahead
                    os9       I$Close             Close the path
L028A               puls      b                   Get path # back
                    clr       b,u                 Clear out entry
                    incb                          Next path #
                    cmpb      #$03                Done the 3 standard paths yet?
                    blo       L0281               No, keep doing until all done
                    ldx       <u0048              Get ptr to redirected dev/file name & return
                    rts
* Z= command (immortal shell setting, but kill parent process)
CmdZEq              inc       <u0013              Flag we want to kill parent
* I= command (immortal shell setting)
CmdIEq              lbsr      L0CD2
                    lbcs      L0B96
                    bsr       L02A3
                    bra       L02D4

* Create device name buffer @ u006D, Write NUL to std out, parse special
* chars: # @ @+hibit $ ( ), Release any keyboard/mouse signals
L02A3               pshs      x                   Prsrve ptr to file/dev name we're redirecting to
                    ldb       #SS.DevNm           Get device name call code
                    leax      <u006D,u            Point to buffer for path names
                    lda       #'/                 Preload '/' for device names
                    sta       ,x+
                    clra                          Standard input path
                    os9       I$GetStt            Get the current device name
                    puls      x                   Get back ptr to file/dev name for redirection
                    lbcs      L0B96               Error on GetStt, shut down paths & exit
                    ldy       #$0001              One char to write
                    pshs      x                   Prsrve ptr to file/dev name we're redirecting to
                    leax      >L003C,pc           Point to a NUL
                    lda       #1                  Std out
                    os9       I$Write             Write the NUL out
                    puls      x                   Restore Devname ptr
                    lbcs      L0B96               Error on Write, shut down paths & exit
                    lbsr      L0A04               Do normal parsing - includes #,@,$e0,$,(,)
                    lbsr      L0225               Release signals
                    rts

L02D4               inc       <u0018              Set 'immortal shell' flag
                    inc       <u0019              ??? (flag used by L0B96 routine)
                    lbsr      L0B96
                    clr       <u0019
                    tst       <u0013              Do we want to kill the parent process?
                    beq       L02FC
                    ifeq      Level-1
                    ldx       <D.Proc
                    else
                    os9       F$ID                Get our process ID # into A
                    pshs      x                   Preserve X
                    leax      >u166D,u            Point to process descriptor buffer
                    os9       F$GPrDsc            Get our process descriptor
                    endc
                    lda       P$PID,x             Get our parents process #
                    ifgt      Level-1
                    puls      x                   Restore X
                    endc
                    beq       L02A3               If parent's process # is 0 (system), skip back
                    clrb                          S$Kill signal code
                    os9       F$Send              Send it to parent
                    lbcs      L0191               If error sending signal, go to error routine
L02FC               clrb                          No error
                    stb       <u0013              Clear 'kill parent' flag
                    rts

* Command list
CmdList             fdb       L0B87-*
                    fcs       '*'
                    fdb       CmdW-*
                    fcs       'W'
                    fdb       CmdCHD-*
                    fcs       'CHD'
                    fdb       CmdCHX-*
                    fcs       'CHX'
                    fdb       CmdCLS-*
                    fcs       'CLS'
                    fdb       CmdCHD-*
                    fcs       'CD'
                    fdb       CmdCHX-*
                    fcs       'CX'
                    fdb       CmdEX-*
                    fcs       'EX'
                    fdb       CmdKill-*
                    fcs       'KILL'
                    fdb       CmdX-*
                    fcs       'X'
                    fdb       CmdNX-*
                    fcs       '-X'
                    fdb       CmdPEq-*
                    fcs       'P='
                    fdb       CmdP-*
                    fcs       'P'
                    fdb       CmdNP-*
                    fcs       '-P'
                    fdb       CmdT-*
                    fcs       'T'
                    fdb       CmdNT-*
                    fcs       '-T'
                    fdb       CmdSETPR-*
                    fcs       'SETPR'
                    fdb       CmdIEq-*
                    fcs       'I='
                    fdb       CmdREq-*
                    fcs       'R='
                    fdb       CmdZEq-*
                    fcs       'Z='
                    fdb       CmdSEMI-*
                    fcs       ';'
                    fdb       CmdPWD-*
                    fcs       '.PWD'
                    fdb       CmdPXD-*
                    fcs       '.PXD'
                    fdb       CmdMEq-*
                    fcs       'M='
                    fdb       CmdVAR-*
                    fcs       'VAR.'
                    fdb       CmdV-*
                    fcs       'V'
                    fdb       CmdNV-*
                    fcs       '-V'
                    fdb       CmdPATHEq-*
                    fcs       'PATH='
                    fdb       CmdPAUSE-*
                    fcs       'PAUSE'
                    fdb       CmdINC-*
                    fcs       'INC.'
                    fdb       CmdDEC-*
                    fcs       'DEC.'
                    fdb       CmdIF-*
                    fcs       'IF'
                    fdb       CmdTHEN-*
                    fcs       'THEN'
                    fdb       CmdELSE-*
                    fcs       'ELSE'
                    fdb       CmdTHEN-*
                    fcs       'FI'
                    fdb       CmdTHEN-*
                    fcs       'ENDIF'
                    fdb       CmdCLRIF-*
                    fcs       'CLRIF'
                    fdb       CmdGOTO-*
L03AC               fcs       'GOTO'
                    fdb       CmdONERR-*
                    fcs       'ONERR'
                    fdb       CmdL-*
                    fcs       'L'
                    fdb       CmdNL-*
                    fcs       '-L'
                    fdb       CmdSTARTUP-*
                    fcs       'S.T.A.R.T.U.P'
                    fdb       $0000
L03CF               fdb       CmdPIPE-*
                    fcs       '!'
                    fdb       CmdPIPE-*
                    fcs       '|'
                    fdb       CmdSEMIC-*
                    fcs       ';'
                    fdb       CmdAmp-*
                    fcs       '&'
                    fdb       CmdCR-*
                    fcb       $80+C$CR
L03DE               fdb       CmdIOE-*
                    fcs       '<>>>'
                    fdb       CmdIE-*
                    fcs       '<>>'
                    fdb       CmdIO-*
                    fcs       '<>'
                    fdb       CmdOE-*
                    fcs       '>>>'
                    fdb       CmdErr-*
                    fcs       '>>'
                    fdb       CmdIn-*
                    fcs       '<'
                    fdb       CmdOut-*
                    fcs       '>'
                    fdb       CmdMem-*
                    fcs       '#'
                    fdb       CmdCaret-*
                    fcs       '^'
                    fdb       $0000               End of table marker

L0404               fcb       C$CR
                    fcc       '()'
                    fcb       $ff
L0408               fcb       C$CR
                    fcc       '!#&;<>^|'
                    fcb       $ff

* Subroutine: Clears B bytes of memory to NUL's starting @ U
L0412               pshs      u                   Clear memory
L0414               clr       ,u+
                    decb
L0417               bne       L0414
L0419               puls      pc,u

* Pre-Parse parameters passed to this shell. Will copy from parm area to
*   buffer area at u0166D, checking for raw mode access allowability if needed
* Will also
* Entry: X=ptr to parm area
L041B               ldb       #$18                # of bytes to clear in DP
L041D               bsr       L0412               Go clear from <u0000 to <u0018 (immortal off)
                    tst       <u006C              ??? (If shell is initing, it's 0)
                    lbeq      L04CE               Shell just initializing, skip ahead
                    leay      >u17FC,u            Point to end of buffer marker
                    pshs      y                   Save ptr on stack
                    leay      >u166D,u            Point to buffer for process descriptor
L042F               bsr       L0486               Copy next char (check for '@', possibly eat)
                    cmpa      #C$CR               CR?
                    beq       L04A8               Yes, force CR into ,y & process line from start
                    cmpy      ,s                  At end of buffer?
                    beq       L04A8               Yes, force CR, process line from start
                    tst       <u001F              Variable expansion on?
                    bne       L042F               No, check next char
                    cmpa      #'%                 Is it a '%' (shell variable)?
                    bne       L042F               No, do next character
                    leay      -1,y                Back up destination ptr to where '%' is
                    pshs      x                   Save current position in parms
                    lda       ,x                  Get 1st char of shell variable nam
                    cmpa      #'*                 Shell variable for last error code received?
                    beq       L049D               Yes,replace shell var with contents of shell var
                    leax      >u05A8,u            Point to user shell variable contents table
                    cmpa      #'%                 2nd '%'= shellsub variable
                    bne       L0460               No, just user, go process
                    puls      x                   Get back parm ptr
                    leax      1,x                 Skip over 2nd '%'
                    lda       ,x                  Get shellsub variable #
                    pshs      x                   Save parm ptr
                    leax      >u08D2,u            Point to shellsub variable contents table
* Entry: A=ASCII 0-9 for either shell or shellsub variable #
L0460               cmpa      #'9                 ASCII numeric?
                    bhi       L0470               No, skip ahead
                    cmpa      #'0
                    blo       L0470
                    suba      #$30                Yes, bump down to binary equivalent
                    ldb       #81                 Point to proper variable entry within var table
                    mul
                    leax      d,x
                    incb                          ??? Used in TSTB below
L0470               bsr       L0486               Copy char from var table to pre-parse buffer
                    cmpy      2,s                 Hit end of pre-parse buffer?
                    beq       L04A6               Yes, force CR at end of it, do full parse
                    cmpa      #C$CR               End of variable?
                    bne       L0470               No, keep copying characters
                    leay      -1,y                Knock ptr back one (to where CR is)
                    puls      x                   Get current parm ptr back
                    tstb                          ??? flag to skip a byte in parm or not
                    beq       L042F               Don't skip
L0482               leax      1,x                 Skip to next byte in parm line
                    bra       L042F               Continue pre-parse

* Copy char from parm area to command line buffer - if '@', eat if user is
*   not super-user (#0)
* Entry: X=ptr to current pos. in original parm buffer
*        Y=ptr to current pos. in new, pre-parsed buffer
L0486               lda       ,x+                 Get char from parms
                    cmpa      #'@                 Raw mode request?
                    bne       L049A               Skip ahead if not (SHOULD BE BNE)
L048C               pshs      y,a                 Preserve regs
                    os9       F$ID                Get user ID #
                    cmpy      #$0000              Is it 0 (superuser)? (should be leay ,y)
                    puls      y,a                 Restore regs
                    beq       L049A               Yes, allow char thru
                    rts                           Otherwise eat it

L049A               sta       ,y+                 Save char & return
                    rts

* Shell variable '%* (for last error code) requested
* Put contents of shell var. into pre-parsed command line buffer
L049D               puls      x                   Get back parm ptr
                    lbsr      L168A               Put error code into preparse buffer
                    leay      3,y                 Skip over error code space we just added
                    bra       L0482               Skip over shell varname, continue preparse

L04A6               leas      2,s                 Eat stack
L04A8               lda       #C$CR               Force CR as last char in buffer
                    sta       ,y
                    puls      y
                    leax      >u166D,u            Point to start of pre-parse buffer again
L04B2               bra       L04CE               Start real parse

L04B4               fcb       C$LF
                    fcc       'Expanded line too long'
                    fcb       C$CR
L04CC               fcc       '.'
L04CD               fcb       C$CR

* Parse command line buffer - already pre-parsed (user 0 RAW mode checks &
*   shell/shellsub variable expansion is already done)
* Entry: X=Ptr to pre-parsed command line buffer
L04CE               lda       ,x                  Get 1st char from parameter area
                    cmpa      #'*                 Is it a comment?
                    beq       L04DE               Yes, skip ahead
                    cmpa      #':                 Is it a wildcard on/off?
                    bne       L04DA               No, skip ahead
                    leax      1,x                 Bump ptr past it
L04DA               cmpa      #':                 Is it a wildcard off?
* FOLLOWING LINE: BEQ means wildcarding default off, BNE = on
                    beq       L04F0               No, go process wildcarding
* No wildcard processing
L04DE               leay      >u0E6D,u            Point Y to expanded buffer
                    lbsr      L1320               Copy param area to buffer area until 1st CR
                    leax      >u0E6D,u            Point X to expanded (wildcard) buffer
                    ldy       #$0800              Max. size of expanded buffer (2048 bytes)
                    lbra      L079B               Process line without wildcards

* Wild carding processor
* Entry: X=ptr to current position in pre-parsed parm line
* 1st, set up error msg for if buffer gets full
L04F0               leay      >L04B4,pc           Point to 'Expanded line too long'
                    sty       <u004A              Save it
                    ldy       #$0018              Get size of text
                    sty       <u004C              Save it too
                    leay      >L04CD,pc           Point to CR
                    sty       <u0048              Save ptr
                    sts       <u0050              Save stack ptr
                    leay      >u0E6D,u            Point to fully expanded buffer (2k max)
                    sty       <u0056              Save it
                    clra
                    clrb
                    sta       <u0012              No current working DIR path
                    sta       <u004F              Flag no pathname in parm area
                    std       <u0052              Expanded buffer size=0 bytes
                    bra       L0520               Enter main loop for wildcards

L051D               lbsr      L06FB               Special shell chars handling
L0520               lbsr      L0746               Check for special chars (wildcard or shell)
                    bcc       L051D               Special shell char process
* Wildcard char found
                    pshs      x                   Save current pre-parsed parm ptr
                    bsr       L0549               Check from that point for '/' or special char
                    ldx       ,s                  Get previous parm ptr back
                    bcc       L0557               No '/' found, open current dir '.'
* Found '/' (part of path) - keep looking for last '/' for filename (not
*   pathname) portion
L052D               bsr       L0549               Check for special char or '/' again
                    bcc       L0535               No '/', skip ahead
                    stx       <u0040              Save latest ptr to '/' in parm line found so far
                    bra       L052D               See if any more sub-paths

* Found one or more '/' path dividers in current parm line.
* Entry: <u0040 - contains the last '/' found
L0535               inc       <u004F              Flag that their IS a pathname from parm line
L0538               ldx       <u0040              Get last level of path ptr
                    puls      y                   Get original parm ptr
                    sty       <u0040              Save it
                    pshs      x                   Save filename ptr on stack
                    lda       #C$SPAC             Save space over '/' after pathname
                    sta       -1,x                (before filename)
                    tfr       y,x                 Move original parm ptr to X
                    bra       L055E               Open dir path

* Parse from current position in pre-parsed parm line until shell special
*   char, or '/' found (path)
* Entry: X=ptr to current pos in pre-parsed parm line
* Exit: Carry clear if special shell char found
*       Carry set if '/' found
*       X=ptr to found char+1
L0549               clrb
                    lda       ,x+                 Get next char
                    lbsr      L05D3               See if shell special char
                    beq       L0556               Yes, return
                    cmpa      #'/                 No, is it a slash (path start)?
                    bne       L0549               No, Keep checking for / or special char
                    comb
L0556               rts

* No '/' found in parm line at all
L0557               clr       <u004F              Flag no pathname from parm line
                    leax      >L04CC,pc           Point to '.'
* Entry: X=ptr to pathname to directory
*        0-1,s = Ptr to filename spec we are looking for in this directory
L055E               lda       #DIR.+READ.         Open directory in READ mode
                    os9       I$Open
                    lbcs      L0776               Error, skip ahead
                    sta       <u0012              Save current DIR path
                    puls      x                   Get back ptr to filename (not pathname)
                    lbsr      L0746               Check for special shell char or wildcard
                    lbcc      L06E3               Special shell char found, ??????
L0572               lda       ,x+                 Get next char from filename
                    cmpa      #C$CR               End of user specified filename (CR)?
                    lbeq      L0789               Yes, close DIR and proceed
                    cmpa      #',                 Comma?
                    beq       L0572               Yes, skip it
                    cmpa      #C$SPAC             Space?
                    beq       L0572               Yes, skip it
                    leax      -1,x                Other char, point to it.
                    stx       <u0054              Save ptr to it
                    lda       <u0012              Get DIR path #
                    pshs      u                   Preserve u
                    ldx       #$0000              Skip '.' and '..' dir entries
                    ldu       #$0040
                    os9       I$Seek
                    lbcs      L0776               Error, skip ahead
                    puls      u                   Restore u
L0599               leax      >u0C9D,u            Point to dir entry buffer
                    pshs      x                   Save ptr
                    lda       <u0012              Get Current dir path #
                    ldy       #$0020              Read 1 file entry
                    os9       I$Read
                    lbcs      L06BD               Error, skip ahead
                    puls      y                   Restore pointer to dir filename buffer
                    lda       ,y                  Get 1st char of entry
                    tsta                          Is it a deleted file?
                    beq       L0599               Yes, skip it
                    ldx       <u0054              Get ptr to current char in expanded filename bfr
                    bsr       L05EF               Check wildcard spec against this filename
                    bcs       L0599               No match, skip to next file in DIR
                    tst       <u004F              Was a pathname specified?
                    beq       L05CA               No, skip ahead
                    ldx       <u0040              Yes,get ptr to end of pathname/start of filename
                    lbsr      L06FB               Check for wildcard stuff there
                    ldx       <u0056              Get current pos in expanded buffer
                    lda       #'/                 Save '/' there (to separate path & filename)
                    sta       -1,x
L05CA               leax      >u0C9D,u            Point to start of matched DIR entry filename
                    lbsr      L06FB               Copy filename over, handling quoted chars, etc.
                    bra       L0599               On to next DIR entry

* Check if shell 'special' char. (except wildcards & shell var)
* non-wildcard char in current byte of pre-parsed parm buffer
* Entry: X=ptr to next char in parms buffer
*        A=current char in parms buffer
* Exit: BEQ if shell special char found, BNE if just regular char
*        A=char we were checking
L05D3               pshs      x                   Save parms buffer ptr
                    cmpa      #'(                 Group start char?
                    beq       L05ED               Yes, skip ahead
                    cmpa      #')                 Group end char?
                    beq       L05ED               Yes, skip ahead
                    cmpa      #C$SPAC             Space?
                    beq       L05ED               Yes, skip ahead
                    cmpa      #',                 Comma?
                    beq       L05ED               Yes, skip ahead
                    leax      >L0408,pc           Table of other special chars
L05E9               cmpa      ,x+                 Found match or end of table?
                    bhi       L05E9               No, keep checking (or fall through if not found)
L05ED               puls      pc,x                Exit with BEQ/BNE flag set

* IF wildcards were detected in preparsing, filename compares happen here
* Entry: X=ptr to current char in user's pre-parse parm line
*        Y=ptr to start of current DIR entry filename
* Exit: Carry set if no match
*       Carry clear if match
L05EF               ldd       ,x+                 Get 2 chars (NOTE: PTR UP BY ONLY 1!)
L05F1               cmpa      #'*                 1st char a * (multi-char wildcard)?
                    beq       L064C               Yes, go handle it
                    cmpa      #'?                 Question mark (single char wildcard)?
                    beq       L0638               Yes, go handle it
                    cmpa      #'[                 Start of ranged wildcard?
                    lbeq      L068B               Yes, go handle it
                    bsr       L05D3               Not wildcard, check for special shell chars
                    beq       L062B               It is a special shell char, skip ahead
                    bsr       L0631               Just regular char, force uppercase
                    pshs      a                   Save char
                    bsr       L062D               Force uppercase on DIR filename char
                    eora      ,s+                 Same char as last parm char?
                    bne       L062B               No, exit with carry set
L060D               lda       ,y+                 Re-get char from DIR filename
                    bpl       L05EF               Not on last char yet, check next char from parm
                    ldd       ,x                  At end of DIR filename, grab 2 chars from parm
                    bsr       L05D3               Check 1st char against special shell chars
                    beq       L0621               Found one, skip ahead
                    cmpa      #'*                 Multi-char wildcard char?
                    bne       L062B               No, no match, exit with carry set
                    tfr       b,a                 1st char from parm is '*', check 2nd char for
                    bsr       L05D3               special shell chars
                    bne       L062B               None found, no match, exit with carry set
L0621               lda       -1,y                Special char, get last char from DIR filename
L0623               anda      #$7F                Strip 'end of filename' bit flag
                    ldb       #C$SPAC             Space char
                    std       -1,y                Save 'fixed' last char & space
                    clrb                          Flag match
                    rts

L062B               comb                          Flag no match
                    rts

* Force char to uppercase
L062D               lda       ,y                  Get char
                    anda      #$7F                Strip hi-bit
L0631               cmpa      #'A                 Need to force uppercase?
                    blo       L0637               No, exit
                    anda      #$DF                Yes, force to uppercase
L0637               rts

* '?' single char wildcard found
L0638               cmpb      #'*                 Is next char a multi-char wildcard?
                    beq       L060D               Yes, process as if just '*'
                    cmpb      #',                 2nd char '-' or greater?
                    bhi       L060D               Yes, process normally
                    lda       ,y+                 Get next char from DIR filename
                    bpl       L062B               Not end of filename, Flag no match
                    bra       L0623               Save hibit stripped char & space, flag match

L0646               lda       ,y+                 Get next char from DIR filename
                    bpl       L0646               Hunt for end of DIR filename
                    bra       L0623               Found it, fix hibit and add space to DIR entry

* '*' multi-char wildcard found
L064C               lda       ,x+                 Get next char after '*' from parm buffer
                    bsr       L05D3               Check for shell special char
                    beq       L0646               Found one, check if end of DIR filename
                    cmpa      #'?                 Single char wildcard next?
                    beq       L067F               Yes, Process
                    cmpa      #'[                 Start of Ranged wildcard next?
                    beq       L067F               Yes, process
                    bsr       L0631               Force char to uppercase
                    pshs      a                   Save it
L065E               bsr       L062D               Get next char from DIR filename, force uppercase
                    eora      ,s+                 Same char?
                    beq       L066E               Yes, possible resync after '*'
L0664               leas      -1,s                Make room on stack
                    lda       ,y+                 Re-get un-modified char from DIR filename
                    bpl       L065E               Not end of filename, try next char
                    leas      1,s                 Found end of filename, eat temp stack
                    bra       L062B               Flag no match
* Above loop @ L0664/L065E uses sneaky stack stuff

* Found possible resync char match after '*'
L066E               leas      -1,s                Make room on stack
                    pshs      y,x                 Preserve both DIR & parm ptrs
                    bsr       L060D               Attempt normal matching using this resync
                    puls      y,x                 Restore ptrs
                    leas      1,s                 Eat temp stack
                    bcs       L0664               No, resync did not work, look for next resync
                    rts                           worked, exit with carry clear

L067B               lda       ,y+                 Get next char in DIR
                    bmi       L062B               Last char, flag no match
* '?' found after '*' in parm buffer
L067F               pshs      y,x                 Preserve both DIR and parm buffer ptrs
                    ldd       -1,x                Get previous & current parm chars
                    lbsr      L05F1               Do normal sub-parsing from here
                    puls      y,x                 Restore ptrs
                    bcs       L067B               No match, go to next char in DIR and attemp resync
                    rts                           Matched, exit with match

* Ranged wildcard here
* Entry: X=ptr to 1st char in parm buffer AFTER '['
L068B               ldd       ,x+                 Get 1st 2 chars of range sub-string from parm bfr
                    bsr       L0631               Force uppercase on 1st char
                    exg       b,a                 Force uppercase on 2nd char
                    bsr       L0631
                    exg       b,a
                    cmpa      #']                 Is 1st char a close range check char?
                    beq       L062B               Yes, flag no match for '[]'
                    cmpa      #'-                 Range separator char?
                    beq       L06A7               Yes, need to get end of range
* Special case for [x] - acts as if just normal char (no range or wildcard)
                    sta       <u00EF              No, save start of range char
                    bsr       L062D               Get char from DIR filename, force uppercase
                    eora      <u00EF              Match only range char?
                    beq       L06B4               Yes, skip to next char now
* Special case for [xyz] - one of these chars must match
                    bra       L068B               No, see if more single chars to try matching

* Actual range - need to get end of range char
* Entry: B=high char of range
*        <u00EF - current char (within range) we are checking against
L06A7               inc       <u00EF              Bump up start char's ascii value
                    cmpb      <u00EF              Hit end of range yet?
                    beq       L068B               Yes, try next char
                    lbsr      L062D               Force char in A to uppercase
                    eora      <u00EF              equal to current range check char?
                    bne       L06A7               No, try next char in range
L06B4               ldd       ,x+                 Get next 2 chars from pathname
                    cmpa      #']                 End of range?
                    bne       L06B4               No, check next char
                    lbra      L060D               End of range specifier, process normally

* Error reading from current DIR
L06BD               cmpb      #E$EOF              End of file error?
                    lbne      L0776               No, fatal error, leave
                    ldx       <u0054              Get ptr to current char in wildcard filename
                    lda       -1,x                Get last char processed
                    bsr       L0714               Add it to new expanded buffer
L06C9               lda       ,x+                 Get next char, inc ptr
                    stx       <u0054              Save updated pointer
                    cmpa      #C$CR               CR?
                    lbeq      L0789               Yes, append CR to expanded buffer, we are done
                    lbsr      L05D3               See if special shell char
                    bne       L06C9               Just regular char, go to next one
                    pshs      x                   Save current ptr to wildcard filename
                    ldx       <u0056              Get current ptr in expanded buffer
                    sta       -1,x                Save that char overtop last char written
                    puls      x                   Get wildcard ptr back
                    bra       L06EA               Close dir path, go back into loop

* If special shell char found right after OPEN of DIR path
* Entry: X=ptr to filename (not pathname) - but with special char
L06E3               bsr       L06FB               Process special shell char copying
                    bsr       L072F               Close DIR path
                    lbra      L051D               More processing

L06EA               bsr       L072F               Close DIR path
                    lbra      L0520               Go back to main wildcard processing loop

* This chunk (6EF-6F9) is for copying '\x' when x is NOT a wildcard char
L06EF               lda       ,x+                 Get quoted char
                    bsr       L0739               Check if it is [, * or ?
                    beq       L06F9               Yes, add that char to expanded buffer by itself
                    leax      -2,x                No, bump ptr back to '\'
                    lda       ,x+                 Get '\' char
L06F9               bsr       L0714               Append that to output buffer
* Special shell chars found goes here
* This part copies filename from [,x] to expanded buffer, handling quoted
*   wildcard chars, and ending on CR or special shell char
L06FB               lda       ,x+                 Get char
                    cmpa      #'\                 Backslash (for quoted char)?
                    beq       L06EF               Yes, go get quoted char
                    cmpa      #C$CR               Is it the end of the filename?
                    beq       L0789               Yes, append CR to expanded line, we are done
                    bsr       L073D               Is it '?' or '*'
                    beq       L0714               Yes, add that char to expanded buffer
                    lbsr      L05D3               Check if shell special char
                    beq       L0714               Yes, add to expanded buffer, return from there
                    bsr       L0714               No, add to expanded buffer, stay in this loop
                    bra       L06FB

* Add char to expanded line buffer
* Entry: A=char to append to expanded line buffer
*        <u0056=Current position in expanded line buffer
*        <u0052=Current size of expanded line buffer
* Exit: <u0056 & <u0052 updated
L0714               pshs      x,a                 Preserve regs
                    ldx       <u0056              Get current pos in expanded buffer
                    sta       ,x+                 Save char
                    stx       <u0056              Save updated expanded buffer ptr
                    ldd       <u0052              Get expanded buffer size
                    addd      #$0001              Increase by 1
                    cmpd      #2048               Is it full yet?
                    bhi       L0773               Yes, exit with expanded line too long error
                    std       <u0052              No, save new size
                    puls      pc,x,a              Restore regs & return

* Close DIR path
L072F               lda       <u0012              Get DIR path #
                    beq       L0738               If none, exit
                    os9       I$Close             Close the path
                    clr       <u0012              Clear DIR path # to none
L0738               rts

* Wildcard checks
* Entry: A=char to check
* Exit: BEQ if any of the 3 wildcard chars, or BNE if not
L0739               cmpa      #'[                 Range wildcard?
                    beq       L0745
L073D               cmpa      #'?                 Single char wildcard?
                    beq       L0745
                    cmpa      #'*                 Multi-char wildcard?
                    beq       L0745
L0745               rts

* Parse for next wildcard or special shell char in pre-parsed parm line
* Entry: X=current pos in pre-parse parm line
* Exit: X=Same as entry
*   IF WILDCARD CHAR FOUND:
*       B=# chars to next wildcard/special char
*       A=special char found
*       Carry bit set
*   IF SPECIAL SHELL CHAR FOUND
*       B=0
*       Carry bit clear
*       A=special char found:  CR ( ) , space ! # & ; < > ^ |
L0746               pshs      x                   Save current parm ptr
                    bra       L0752               Parse for wildcard or special shell chars

L074A               lda       ,x+                 Get char from parms
                    bsr       L0739               Do wildcard char check
                    beq       L0752               If wildcard char, skip over it & continue
                    leax      -1,x                not wildcard char, bump back to char after \
L0752               lda       ,x+                 Get char from parms
                    cmpa      #'\                 Wildcard quote char (do not expand next)?
                    beq       L074A               Yes, handle it
                    lbsr      L05D3               No, check for other special shell chars
                    beq       L0770               Found one, skip ahead
                    bsr       L0739               Check for wildcard char
                    bne       L0752               None, skip to next char
* One of the 3 wildcard chars found, process
                    pshs      a                   Save char
                    tfr       x,d                 Move parm ptr to D
                    subd      1,s                 Calc distance since last wildcard/special char
                    subd      #$0001              -1
                    puls      a                   B=distance between wild/special chars
                    orcc      #Carry              Set Carry Flag
                    puls      pc,x                Exit with original parm ptr in X

* Exit with B=0, Carry clear and A=special char found (which ends current
*   'chunk' being checked... can included CR)
L0770               clrb                          Clear carry, exit
                    puls      pc,x

* Expanded buffer full error
L0773               comb
                    ldb       #E$BufSiz
L0776               pshs      b,cc                Preserve error code
                    bsr       L072F               Close DIR path (if we had one)
                    ldx       <u004A              Print text message (usually error msg)
                    ldy       <u004C
                    lda       #$02
                    os9       I$WritLn
                    puls      b,cc
                    lbra      L0191               Exit with error

L0789               lda       #C$CR               Append CR to expanded filenames buffer
                    bsr       L0714
                    ldy       <u0052              Get expanded buffer size
                    leax      >u0E6D,u            Point to start of expanded buffer
                    bsr       L072F               Close DIR path
                    lds       <u0050              Get back original stack ptr
* At this point, expanded buffer is complete and ready to go (either through
*  wildcard routine, or by simply copying the original parm buffer from user)

* Main entry point for non-wildcard filename search/match
* Entry: X=Ptr to start of expanded buffer
L079B               tst       <u001E              Echo required?
                    beq       L07A2               No, skip ahead
                    lbsr      L021F               Print out user entered parm line to std err
L07A2               tst       <u0043              2=FALSE,0=TRUE, 1=??? (check current IF status,
                    beq       L07B0               if any. If TRUE flag set, skip ahead)
                    lbsr      L0F69               Do checks for IF type statements
                    tsta                          Find match?
                    lbpl      L0F1D               Yes, process IF type statement
L07AE               clrb                          No error & return
                    rts

* If current IF type statement has result TRUE
L07B0               tst       <u0045              ??? (Are we looking for a label for GOTO?)
                    beq       L07E3               No, skip ahead
                    lda       ,x+                 Get char from buffer
                    cmpa      #'*                 Comment line?
                    bne       L07AE               No, exit without error
                    lbsr      L091F               Yes, get ptr to first non-space char into X
                    leay      >u0124,u            Point to temp buffer
                    lbsr      L100B               Copy label from X to Y
                    lda       ,x                  Get 1st char of label
                    cmpa      #'\                 '*\'? (Which means cancel impending GOTO)
                    beq       L07DB               Yes, cancel GOTO
                    leax      >u0BFC,u            No, point to 80 byte buffer (GOTO label holder?)
                    clra                          default char to check against=NUL
L07CF               cmpa      #C$CR               End of label?
                    beq       L07DB               Yes, cancel GOTO search
                    lda       ,x+                 Get next char from buffer
                    cmpa      ,y+                 Is it the label we are looking for?
                    beq       L07CF               Keep checking till done
                    bra       L07AE               No match, clear carry & return

* Cancelling GOTO search
L07DB               clr       <u0045              Flag we are NOT looking for label for GOTO
                    clrb
                    leas      2,s                 Eat stack
                    lbra      L010D               Reprint shell prompt, process from scratch

L07E3               bsr       L07E7
                    bra       L083A

L07E7               pshs      x
                    tst       <u006C
                    beq       L0832
                    tst       <u005C
                    bne       L07F5
                    tst       <u001C
                    beq       L0832
L07F5               lda       ,x
                    cmpa      #'*
                    beq       L0832
                    ifgt      Level-1
                    ldy       #$0000              Force temporarily to super-user
                    os9       F$SUser
                    endc
                    leax      >u0CBD,u
                    ldd       #$0203
                    lbsr      L0C79
                    bcs       L0832
                    lbsr      L00FB
                    lda       #$20
                    sta       <$11,x
                    ldy       #$0012
                    lda       <u0012
                    os9       I$Write
                    bcs       L082D
                    ldx       ,s
                    ldy       #$0800
                    lda       <u0012
                    os9       I$WritLn
L082D               lda       <u0012
                    os9       I$Close
L0832
                    ifgt      Level-1
                    ldy       <u005A              Get original user # back
                    os9       F$SUser             Change user # to original
                    endc
                    puls      pc,x

* Parse input line
* Entry : X=Ptr to current char in line buffer
L083A               clra
                    sta       <u0022              Flag we don't change priority for forked process
                    sta       <u0003              Clear out # pages of data mem for forked process
                    sta       <u000E              Clear out signal code
                    leay      >CmdList,pc         Point to main command list
                    lbsr      L08D1               Parse keywords from list
                    bcs       L08A0               Keyword found but generated error, done line
                    cmpa      #C$CR               Is 1st non-keyword char a carriage return?
                    beq       L08A0               Yes, done line
                    sta       <u000C              Save non-keyword char
                    cmpa      #'(                 Is it a 'start command group' char?
                    bne       L087B               No, try next
                    leay      >L000D,pc           Point to 'Shell'
                    sty       <u0004              Save pointer to program to fork?
                    leax      1,x                 Bump ptr past '('
                    stx       <u0008              Save updated ptr
L0860               inc       <u000D              Bump up # of command groups
L0862               leay      >L0404,pc           Point to command group symbols to parse
                    lbsr      L08E9               Hunt down EOL, or '(' or ')' (skip quoted text)
                    cmpa      #'(                 Another group start?
                    beq       L0860               Yes, bump up # of command groups & continue
                    cmpa      #')                 Group end?
                    bne       L0898               No, skip ahead (to print WHAT?)
                    dec       <u000D              Bump down # of command groups
                    bne       L0862               Still more groups, continue parsing for them
                    lda       #C$CR               Append CR at end of command line
                    sta       -1,x
                    bra       L087F               Check for modifiers

L087B               bsr       L08A3               Check for valid path,  do '<>', '#', '^' if needed
                    bcs       L08A0               No valid path found, skip ahead
* Found valid pathname
L087F               leay      >L0408,pc           Point to modifiers table
                    bsr       L08E9               Go parse for them
                    tfr       x,d                 Move ')' ptr to D for SUB
                    subd      <u0008              Calculate size from 1st '(' to ')'
                    std       <u0006              Save size of group (could also be pathname-modifier)
                    leax      -1,x
                    leay      >L03CF,pc           Point to modifier branch table
                    bsr       L08D1               Go execute modifier routine
                    bcs       L08A0               If error in modifier routine, exit
                    ldy       <u0004              Get ptr to first char we started at
L0898               lbne      L0BCF               Not proper, print 'WHAT?'
                    cmpa      #C$CR               Last char a carriage return?
                    bne       L083A               No, start parsing again at current position
L08A0               lbra      L0B96               Done processing line, continue

* Entry: X=Ptr to text to check for valid device name (including '.' & '..')
* Exit: Carry set if not a valid device name
* Carry clear if there was
* <u0004 = Ptr to first char where we started at
* <u0008 = Ptr to end of redirection/mem size/priority setting chars (if found)
L08A3               stx       <u0004              Save ptr to current char in input line
                    bsr       L08B6               Check for valid device name
                    bcs       L08B5               None found, return
* Found valid device name
L08A9               bsr       L08B6               Eat rest of valid pathlist
                    bcc       L08A9               Keep going until we are done pathlist
                    leay      >L03DE,pc           Point to Command list starting at '<>>>'
                    bsr       L08D1               Call any redirection, mem size or priority routines
                    stx       <u0008              Save ptr to where we are now (end of current set)
L08B5               rts

L08B6               os9       F$PrsNam            Valid OS9 device name?
                    bcc       L08C7               Yes, point X to it & return
                    lda       ,x+                 Not valid, get first char
                    cmpa      #'.                 Is it a period?
                    bne       L08CB               No, bad path name
                    cmpa      ,x+                 Is it a double period?
                    beq       L08C9               Yes, leave src ptr pointing to name after '..'
                    leay      -1,x                If single, bump ptr to name after '.'
L08C7               leax      ,y                  Point X to pathname in source
L08C9               clra                          No error & return
                    rts

L08CB               comb                          Error flag
                    leax      -1,x                Bump source ptr back
                    ldb       #E$BPNam            Bad Path Name error & return
                    rts
* Entry: Y=ptr to command list (CmdList)
L08D1               bsr       L0907               Go find 1st non-space char
                    pshs      y                   Save command list ptr
                    bsr       L092A               Parse for keyword or special char
                    bcs       L08E2               If no keyword found, skip ahead
                    ldd       ,y                  Keyword found, get offset
                    jsr       d,y                 Go execute routine for command found
                    puls      y                   Restore command list ptr
                    bcc       L08D1               No error, continue parsing for keywords
                    rts                           Subroutine had error, return with it
L08E2               clra                          No error
                    lda       ,x                  Get character (not in command list)
                    puls      pc,y                Restore command list ptr & return

* Start searching at beginning of current command list
* For looking for single character modifiers
L08E7               puls      y
L08E9               pshs      y                   Preserve command list ptr
                    lda       ,x+                 Get next char from command line
L08ED               tst       ,y                  Check current char in command list
                    bmi       L08E7               If done list, start over at beginning
                    cmpa      #'"                 Is it quotes?
                    bne       L0901               No, skip ahead
L08F5               lda       ,x+                 Get next char from command line
                    cmpa      #C$CR               EOL?
                    beq       L0905               Yes, exit with A being CR
                    cmpa      #'"                 Is it another set of quotes?
                    bne       L08F5               No, keep looking for it (or EOL)
                    lda       ,x+                 Get char after 2nd quotes
L0901               cmpa      ,y+                 Is it the current command char we are checking?
                    bne       L08ED               No, try next
L0905               puls      pc,y                Yes, exit with A containing it

* Entry: Y=ptr to command list
L0907               pshs      x                   Preserve X
                    lda       ,x+                 Get char from line entered by user
                    cmpa      #C$SPAC             Is it a space?
                    beq       L091D               Yes, skip ahead
                    cmpa      #',                 Is it a comma?
                    beq       L091D               Yes, skip ahead
                    leax      >L0408,pc           Point to single character modifiers
L0917               cmpa      ,x+                 Found a match?
                    bhi       L0917               No, try next until list is done
                    puls      pc,x                Found it, restore X to point to it & return

L091D               leas      2,s                 Eat X off the stack
L091F               lda       #C$SPAC             Get space character
L0921               cmpa      ,x+                 Keep searching until non-space char is found
                    beq       L0921
                    leax      -1,x                Point to 1st non-space char
* ; (1st pass) comes here
CmdSEMI             andcc     #^Carry             No carry & return
                    rts
* Command line parser
L092A               pshs      y,x                 Preserve command table ptr & input line ptr
                    leay      2,y                 Skip first offset
L092E               ldx       ,s                  Get input line ptr
L0930               lda       ,x+                 Get char from input line
                    lbsr      L0F0C               Convert char to uppercase if lowercases
                    eora      ,y+                 Check for a match
                    lsla
                    bne       L0951               No match, skip to next keyword in table
                    bcc       L0930               Keep checking until end of keyword (high bit set)
                    lda       -$01,y              Get command table char again
                    cmpa      #'|+$80             '|' (with high bit set)?
                    beq       L094E               Yes, exit with carry clear
                    cmpa      #'^+$80             '^' (with high bit set)?
                    beq       L094E               Yes, exit with carry clear
                    cmpa      #'A+$80             Any of the other special modifiers with high bit?
                    blo       L094E               Yes, exit with carry clear
                    bsr       L0907               Eat spaces until first non-space char
                    bcs       L0951               If special char (!|#,etc.), skip ahead
L094E               clra
                    puls      pc,y,d

L0951               leay      -1,y                Bump search ptr back
L0953               lda       ,y+                 Get char again
                    bpl       L0953               Keep getting them until end of keyword
                    sty       2,s                 Save ptr to next offset on stack
                    ldd       ,y++                Get offset
                    bne       L092E               If not at end of table, keep searching
                    comb                          End of table, command not found error
                    puls      pc,y,x

L0961               fcc       'startup'
                    fcb       C$CR

* Create child shell to run 'startup' file
CmdSTARTUP
                    pshs      u,y,x               Preserve regs
                    leax      L000D,pc            Point to 'shell' (module name)
                    leau      L0961,pc            Point to 'startup' (parameter for 'shell')
                    ldy       #$0008              Size of 'startup<CR>'
                    ifgt      Level-1
                    ldd       #$111F              Program+Objct / 7.5K data area
                    else
                    ldd       #$1102              Program+Objct / 512 byte data area
                    endc
                    os9       F$Fork              Fork a shell to run the startup file
                    bcs       L0983               Couldn't fork, exit
                    os9       F$Wait              Wait until 'startup' is done
L0983               puls      u,y,x               Restore regs
                    clrb                          No error & return
                    rts

* EX command
CmdEX               lbsr      L08A3               Go check for valid device name (module)
                    bcs       L09AB               If none, exit
                    clra                          Std in path
                    bsr       L09B0               Go close it
                    bsr       L09AF               Go close Std out
                    bsr       L09AF               Go close Std Err
                    lbsr      L0B87               Go find the end of the input line
                    leax      1,x                 Bump ptr to 1 past CR
                    tfr       x,d                 Move ptr to D
                    subd      <u0008              Calculate size of current command group
                    std       <u0006              Save it
                    lbsr      L130A               Point to module to chain&get its parm size, etc.
                    leas      >u00FF,u            Point stack to end of DP
                    os9       F$Chain             Chain to the new program
                    lbra      L01FA               Couldn't, go here
L09AB               clrb                          No error
                    lbra      L020D               Close logging file (if any) and exit ShellPlus

L09AF               inca                          Inc path #
L09B0               pshs      a                   Save path #
                    lbra      L0BBC               close path if it is open
* CHX & CX commands
CmdCHX              clr       <u0038
                    lda       #DIR.+EXEC.
                    os9       I$ChgDir
                    rts
* CHD & CD commands
CmdCHD              lda       #DIR.+READ.         (bug fix, originally opened in UPDATE)
                    os9       I$ChgDir            Change the directory
                    bcs       L09CE               Error, exit with it
                    clr       <u0037              Flag .pwd entry as invalid
                    tst       <u0042              WAS ,U
                    beq       L09CE
                    bsr       L0A04               Go update shell expanded prompt if needed
L09CE               rts
* L command - Logging ON
CmdL                lda       #$01
                    bra       L09D4
* -L command - Logging OFF
CmdNL               clra
L09D4               sta       <u001C
                    rts
* P command - Prompting ON
CmdP                clra
                    bra       L09DC
* -P command - Prompting OFF
CmdNP               lda       #$01
L09DC               sta       <u001D
                    rts
* T command - Echo input ON
CmdT                lda       #$01
                    bra       L09E4
* -T command - Echo input OFF
CmdNT               clra
L09E4               sta       <u001E
                    rts
* V command - Turn variable expansion ON
CmdV                clra
                    bra       L09EC
* -V command - Turn variable expansion OFF
CmdNV               lda       #$01
L09EC               sta       <u001F
                    rts
* X command - Kill Shell when error occurs ON
CmdX                lda       #$01
                    bra       L09F4
* -X command - Kill Shell when error occurs OFF
CmdNX               clra
L09F4               sta       <u0020
                    rts

L09F7               tst       >u01F4,u            Date already done?
                    bne       L0A04               Yes, skip ahead
                    tst       >u01F5,u            Time already done?
                    bne       L0A04               Yes, skip ahead
                    rts                           If neither, we don't need to change prompt?
L0A04               pshs      y,x                 Preserve regs
                    bra       L0A64               Go update shell expanded prompt if needed

* Make shell prompt string the default one
L0A08               puls      y                   Restore Y
                    pshs      x                   Preserve X
                    leax      >L003D,pc           Point to default prompt string
                    bsr       CmdPEq              Put that into working shell prompt string
                    puls      pc,x                Restore X & return

* P= (prompt set) command
* Make shell prompt string (default or user-specified)
* Entry: X=ptr to source of new shell prompt string
CmdPEq              pshs      y                   Preserve Y
                    leay      >u01F9,u            Point to working prompt text buffer
                    ldd       #C$LF*256+22        Line feed & max count for prompt string+1
                    sta       ,y+                 Save LF as first char
                    bsr       L0A25               Go copy prompt string (& parse quotes)
                    bra       L0A5E               Go see if we need to override with default

L0A25               clr       >u01F3,u            Clear quotes in progress flag
L0A29               lda       ,x+                 Get char from default shell prompt
                    cmpa      #'"                 Is it a quotes?
                    bne       L0A3F               No, skip ahead
                    leax      1,x                 Yes, bump ptr up 2 past quotes
                    tst       >u01F3,u            We processing quotes already?
                    bne       L0A59               Yes, we are done then
                    inc       >u01F3,u            Set processing quotes flag
                    leax      -1,x                Set ptr back to char just after quotes
                    bra       L0A29               Check next char

L0A3F               cmpa      #C$CR               Carriage return?
                    beq       L0A59               Yes, we are done then
                    cmpa      #C$SPAC             Space?
                    beq       L0A4B               Yes, skip ahead
                    cmpa      #';                 Semi-colon?
                    bne       L0A51               No, skip ahead
* Semi-colon or space found
L0A4B               tst       >u01F3,u            We quoting at the moment?
                    beq       L0A59               No, we are done
L0A51               tstb                          Char count down to 0?
                    beq       L0A29               Yes, continue parsing (but eating them)
                    decb                          Dec max char counter
                    sta       ,y+                 Save literal char into current copy
                    bra       L0A29               continue parsing

L0A59               clr       ,y                  Append NUL to indicate end of string
                    leax      -1,x                Bump source ptr back to last char & return
                    rts

L0A5E               cmpb      #22                 Did the user do a no-length prompt?
                    beq       L0A08               Yes, go override with default prompt
                    pshs      x                   Preserve ptr to last char of source prompt

* Create expanded shell prompt from shell prompt string
L0A64               leay      >u01F9,u            Point to shell prompt string
                    leax      >u0212,u            Point to expanded prompt buffer
                    pshs      x                   Preserve it a moment
                    clr       >u01F2,u            Output device name done already = OFF
                    clr       >u01F1,u            Process ID # done already = OFF
                    clr       >u01F4,u            Date done already = OFF
                    clr       >u01F5,u            Time done already = OFF
                    clr       >u01F6,u            Date OR time already done once = OFF
                    clr       >u0042,u            Current working dir name done already = OFF
L0A86               lda       ,y+                 Get char from shell prompt string
                    lbeq      L0B29               If end of string, exit
                    cmpa      #'#                 Process ID # wanted?
                    bne       L0AA2               No, try next
* Process ID #
                    tst       >u01F1,u            Done it already?
                    bne       L0A86               Yes, skip doing it again
                    inc       >u01F1,u            No, flag it as being done now
                    ldd       >u01EC,u            Get process # (01-99)
                    std       ,x++                Save in expanded prompt buffer
                    bra       L0A86               Continue parsing
L0AA2               cmpa      #'@                 Standard output path device name wanted?
                    beq       L0AAA               Yes, go do it
                    cmpa      #$E0                High bit version?
                    bne       L0AC7               No, try next
* Standard output path device name
L0AAA               tst       >u01F2,u            Done it already?
                    bne       L0A86               Yes, skip doing it again
                    ldd       #$01*256+SS.DevNm   Standard out/get device name
                    os9       I$GetStt            Get the device name
                    bcs       L0A86               Error, skip doing device name
                    inc       >u01F2,u            Flag it as being done now
L0ABD               lda       ,x+                 Get char from device name
                    bpl       L0ABD               Keep looking until last char (high bit set)
                    anda      #$7F                Mask out high bit
                    sta       -1,x                Save the normal char
                    bra       L0A86               Continue parsing
L0AC7               cmpa      #'$                 Current working directory wanted?
                    bne       L0AF2               No, check next
* Current working directory
                    tst       <u0042              Done it already? (WAS ,U)
                    bne       L0A86               Yes, skip doing it again
                    inc       <u0042              Flag it as being done now (WAS ,U)
                    lda       #$01
                    sta       <u003D
                    lbsr      L176D               Go figure out current working directory
                    tstb
                    bne       L0AF2
                    pshs      y                   Save prompt string ptr
                    ldy       <u002A              Get pointer to current working directory
* Copy string: Y=source string ptr, X=prompt buffer ptr
L0AE4               lda       ,y+                 Get char
                    sta       ,x+                 Save as part of shell prompt text
                    cmpa      #C$CR               Was it the end?
                    bne       L0AE4               No, keep copying
                    leax      -1,x                Bump ptr back CR
                    puls      y                   Restore source string ptr
                    bra       L0A86               Continue parsing

L0AF2               cmpa      #'(                 Current Date wanted?
                    bne       L0B0A               No, check next
* Current date
                    tst       >u01F4,u            Done it already?
                    bne       L0A86               Yes, skip doing it again
                    inc       >u01F4,u            Flag as being done now
                    bsr       L0B3B               Go get date & time
                    pshs      y                   Save shell prompt string ptr
                    leay      >u02E0,u            Point to date text
                    bra       L0AE4               Copy into expanded prompt
L0B0A               cmpa      #')                 Current Time wanted?
                    bne       L0B24               No, just store the raw ASCII char
* Current time
                    tst       >u01F5,u            Done Time already?
                    lbne      L0A86               Yes, skip doing it again
                    inc       >u01F5,u            Flag as being done now
                    bsr       L0B3B               Go get date & time
                    pshs      y                   Save shell prompt string ptr
                    leay      >u02E9,u            Point to time text
                    bra       L0AE4               Copy into expanded prompt

L0B24               sta       ,x+                 Save raw character
                    lbra      L0A86               Continue parsing

L0B29               sta       ,x                  Save NUL to mark end of prompt
                    tfr       x,d                 Move End of prompt ptr to D for subtract
                    subd      ,s++                Subtract start of prompt ptr
                    std       >u01F7,u            Save size of expanded shell prompt
                    puls      pc,y,x              Restore regs & return

* Separator table for date & time strings
L0B35               fcc       '//'
                    fcb       C$CR
                    fcc       '::'
                    fcb       C$CR

* Get current date (2E0-2E8) & time (2E9-2EF)
L0B3B               pshs      y,x                 Preserve shell prompt string & shell prompt ptrs
                    tst       >u01F6,u            Have we already been here before?
                    bne       L0B75               Yes, both date & time strings already done
                    inc       >u01F6,u            Flag we have been here now
                    leax      >u02DA,u            Point to date/time packet buffer
                    os9       F$Time              Get the date/time packet
                    leay      >u02E0,u            Point to where date string goes
                    clrb                          Offset into separator table to first '/'
L0B54               lda       ,x+                 Get byte from time packet
                    bsr       L0B77               Convert to ASCII
                    pshs      b                   Preserve offset into separator table
                    ldd       >u01EF,u            Get ASCII version of byte
                    std       ,y++                Save into date/string buffers
                    puls      b                   Restore offset into separator table
                    pshs      y                   Preserve date/string buffer ptr
                    leay      >L0B35,pc           Point to separator's table
                    lda       b,y                 Get current separator
                    puls      y                   Restore date/string buffer ptr
                    sta       ,y+                 Save separator into date/string buffer
                    incb                          Point to next separator
                    cmpb      #6                  On last one?
                    bne       L0B54               No, continue converting
L0B75               puls      pc,y,x              Restore prompt & buffer ptrs & return

L0B77               pshs      y,x,d               Preserve regs
                    leay      >L0B80,pc           Point to routine to copy ASCII digits
                    lbra      L16B9               Go convert byte to ASCII equivalent

L0B80               ldd       $04,s               Copy 2 digit ASCII # to 1EF
                    std       >u01EF,u
                    rts

* Searches for CR in string pointed to by X
* '*' Comment lines come here
L0B87               lda       #C$CR               We want to find the CR
L0B89               cmpa      ,x+                 Found it yet?
                    bne       L0B89               No, keep looking
                    cmpa      ,-x                 Set up flags & return
                    rts

L0B90               pshs      d,cc                Preserve regs
                    lda       #$01                Only do std in & out (not error)
                    bra       L0B9A

* Any errors from any of the CmdList subroutines go here
* If child process had error/status code it goes here (u005D cleared,B=Status
* code)
L0B96               pshs      d,cc                Preserve error code, flags & A
                    lda       #$02                # of paths to do
L0B9A               sta       <u001A              Save it
                    clra                          Start at path 0
L0B9D               bsr       L0BA8               Go close (possibly dupe) paths
                    inca                          Next path #
                    cmpa      <u001A              Done up to last one yet?
                    bls       L0B9D               No, do next one
* POSSIBLY COULD BE PULS PC,D,CC
                    ror       ,s+                 Eat CC but shift Carry bit into Carry
                    puls      pc,d                Restore error code & A & return

L0BA8               pshs      a                   Save path #
                    tst       <u0019
                    bmi       L0BC4               If high bit set, close path
                    bne       L0BBC               If 0<u0019<128, get changed path # & close
                    tst       a,u                 Check 'real' path # from DP
                    beq       L0BC7               If 0, return
                    os9       I$Close             Otherwise, close current path #
                    lda       a,u                 Get 'real' path #
                    os9       I$Dup               Dupe it

* Close path # on stack, if it is open
L0BBC               ldb       ,s                  Get path # from stack
                    lda       b,u                 Get real path # from DP
                    beq       L0BC7               If none, exit
                    clr       b,u                 Clear out path #
L0BC4               os9       I$Close             Close the path
L0BC7               puls      pc,a                Exit

L0BC9               fcc       'WHAT?'
                    fcb       C$CR

L0BCF               bsr       L0B96               Close 3 std paths (possibly dupe)
                    leax      <L0BC9,pc           Point to 'WHAT?'
                    lbsr      L021B               Write it out std err
                    clrb
                    coma
                    rts

L0BDA               inc       <u0019              ???
                    bsr       L0B96               Do path closings (possibly dupings)
                    lda       #$FF                Set flag to just close raw paths
                    sta       <u0019
                    bsr       L0B90               Go close std in & std err
                    leax      <u006D,u            Point to device name buffer
                    lbsr      L0CDB
                    lbcs      L0200
                    lda       #$02
                    bsr       L0BA8
                    lbsr      L0CFF
                    clr       <u0019
                    lbra      L00CC
* < processing
CmdIn               ldd       #$0001
                    orb       <u000F
                    bra       L0C1A
* >> processing
CmdErr              ldd       #$020D
                    stb       -$02,x
                    bra       L0C0A
* > processing
CmdOut              lda       #$01
L0C0A               ldb       #$02
                    bra       L0C1A
* if from z= or i=, A=0, B=3
L0C0E               tst       a,u                 Test duped path?
                    bne       L0BCF               There is one, print 'WHAT' & close paths & return
                    pshs      d                   Save path # & B
                    tst       <u0019
                    bmi       L0C34
                    bra       L0C24

L0C1A               tst       a,u
                    bne       L0BCF
                    pshs      d
                    ldb       #C$CR
                    stb       -$01,x

L0C24               os9       I$Dup               Create duplicate of the standard path
                    lbcs      L0CBE               Couldn't create dupe,
                    ldb       ,s
                    sta       b,u
                    lda       ,s
                    os9       I$Close

L0C34               lda       1,s                 Get B
                    bmi       L0C40
                    ldb       ,s
                    lbsr      L0D05
                    tsta
                    bpl       L0C47
L0C40               anda      #$0F
                    os9       I$Dup
                    bra       L0CBE
L0C47               ldb       #$0B
                    bita      #$02
                    bne       L0C7B
                    pshs      a
                    ldd       ,x
                    andb      #$5F
                    cmpd      #$2F57              Is it '/W'
                    puls      a
                    bne       L0C74
                    ora       #$02
                    os9       I$Open
                    bcs       L0CBE
                    pshs      x
                    leax      >L003C,pc
                    ldy       #$0001
                    clra
                    os9       I$Write
                    puls      x
                    bra       L0CBE
L0C74               os9       I$Open
                    bra       L0CBE
L0C79               pshs      d
L0C7B               stb       <u004E
                    ldb       ,x
                    cmpb      #$2B
                    bne       L0C96
                    leax      $01,x
                    os9       I$Open
                    bcs       L0CB1
                    pshs      u,x
                    ldb       #SS.Size
                    os9       I$GetStt
                    os9       I$Seek
                    bra       L0CA8
L0C96               cmpb      #'-
                    bne       L0CB9
                    leax      1,x
                    os9       I$Open
                    bcs       L0CB1               Error opening
                    pshs      u,x
                    ldx       #$0000
                    tfr       x,u
L0CA8               ldb       #SS.Size            Init size of file to 0 bytes
                    os9       I$SetStt
                    puls      u,x
                    bra       L0CBE
L0CB1               cmpb      #E$PNNF             Error 216 (path name not found)?
                    beq       L0CB9               Yes, create the file
                    orcc      #Carry              Otherwise, set error flag
                    bra       L0CBE
L0CB9               ldb       <u004E              Get file attributes
                    os9       I$Create

L0CBE               sta       <u0012              Save path # (or one we tried to duplicate?)
                    stb       1,s                 Save possible error code?
                    lda       #$00                DO NOT CHANGE-NEED TO PRESERVE CARRY
                    sta       <u000F
                    puls      pc,d                Restore regs & return
L0CC8               ldd       #$0003              Std in & ???
                    lbra      L0C0E
* <>>> processing
CmdIOE              lda       #C$CR
                    sta       -$04,x
* i= & z= both come here right off the bat
L0CD2               bsr       L0CDB
                    bcc       L0CFF
L0CD6               rts
* <> processing
CmdIO               lda       #C$CR
                    sta       -$02,x

L0CDB               bsr       L0CC8
                    bcs       L0CD6
                    ldd       #$0180
                    lbra      L0C0E
* <>> processing
CmdIE               lda       #C$CR
                    sta       -$03,x
                    bsr       L0CC8
                    bcs       L0CD6
                    ldd       #$0280
                    lbra      L0C0E
* >>> processing
CmdOE               lda       #C$CR
                    sta       -$03,x
                    ldd       #$0102
                    lbsr      L0C0E
                    bcs       L0CD6
L0CFF               ldd       #$0281
                    lbra      L0C0E
L0D05               pshs      x,d
                    ldd       ,x++
                    cmpd      #$2F30
                    bcs       L0D2F
                    cmpd      #$2F32
                    bhi       L0D2F
                    pshs      x,d
                    lbsr      L0907
                    puls      x,d
                    bcs       L0D2F
                    andb      #$03
                    cmpb      1,s
                    bne       L0D31
                    ldb       b,u
L0D26               orb       #$80
                    stb       ,s
                    puls      d
                    leas      2,s
                    rts
L0D2F               puls      pc,x,d

L0D31               tst       $01,s
                    bne       L0D26
                    pshs      x
                    tfr       b,a
                    leax      >u00B5,u            Point to buffer for device name
                    ldb       #'/                 Put a slash in it
                    stb       ,x+
                    ldb       #SS.DevNm           Get the device name
                    os9       I$GetStt
                    bcs       L0D4F               Error, skip ahead
                    leax      -1,x                Reset ptr to include '/'
                    lda       #UPDAT.
                    os9       I$Open
L0D4F               puls      x                   Restore ptr to beginning (including '/')
                    leas      6,s                 Eat stack
                    lbra      L0CBE

L0D56               fcc       'TRUE '
L0D5B               fcb       C$CR
L0D5C               fcc       'FALSE'
                    fcb       C$CR

CmdIF               lda       ,x+
                    cmpa      #'[
                    bne       L0D6B
                    lbsr      L0E15
L0D6B               cmpa      #'-
                    lbne      L0E3E
                    ldb       ,x+
                    lbsr      L0E15
                    leax      -$01,x
                    tfr       b,a
                    lbsr      L0F0C               Convert char to uppercase if lower
                    cmpa      #'Y
                    bne       L0DBB
L0D81               pshs      x                   Preserve X
                    leax      >u0124,u            Point to buffer
                    ldy       #$0001              Read 1 byte from error path???
                    lda       #$02
                    os9       I$Read
                    lbcs      L0F17
                    lda       ,x                  Get the character read
                    puls      x
                    lbsr      L0F0C               Convert char to uppercase if lower
                    cmpa      #'Y                 Unless char is Y or N, re-read it
                    beq       L0DA3
                    cmpa      #'N
                    bne       L0D81
L0DA3               pshs      a                   Preserve char on stack
                    leax      >L0D5B,pc           Point to a Carriage return
                    lda       #$02                Print it to std out
                    ldy       #$0001
                    os9       I$WritLn
                    puls      a                   Restore char
                    clrb
                    cmpa      #'Y
                    beq       L0DF8               Print 'true' if it is a Y
                    bra       L0DEE               Print 'false' if it is a N

L0DBB               clrb
                    cmpa      #'F
                    beq       L0DE0
                    cmpa      #'E
                    bne       L0DC8
                    orb       #%00000100
                    bra       L0DE0

L0DC8               cmpa      #'R
                    bne       L0DD0
                    orb       #%00000001
                    bra       L0DE0

L0DD0               cmpa      #'W
                    bne       L0DD8
                    orb       #%00000010
                    bra       L0DE0

L0DD8               cmpa      #'D
                    lbne      L0F17
                    orb       #%10000000
L0DE0               tfr       b,a
                    os9       I$Open
                    bcs       L0DEE
                    os9       I$Close
                    bra       L0DF8

L0DEE               lda       #$02
                    sta       <u0043
                    leax      >L0D5C,pc           Point to 'FALSE'
                    bra       L0DFE

L0DF8               clr       <u0043
                    leax      >L0D56,pc           Point to 'TRUE'
L0DFE               tst       <u001E              Command echo on?
                    beq       CmdTHEN             No, skip ahead
                    ldy       #$0006              Print result of IF to std error
                    lda       #$02
                    os9       I$WritLn
CmdTHEN             leax      >u0124,u
                    lda       #C$CR
                    sta       ,x
                    clrb
                    rts

L0E15               lda       ,x+
                    cmpa      #C$SPAC
                    beq       L0E15
                    rts

L0E1C               cmpa      #$3D
                    bne       L0E26
                    lda       <u005F
                    ora       #$01
                    bra       L0E38

L0E26               cmpa      #'<
                    bne       L0E30
                    lda       <u005F
                    ora       #$02
                    bra       L0E38

L0E30               cmpa      #'>
                    bne       L0E3C
* X command - Kill Shell when error occurs ON
                    lda       <u005F
                    ora       #$04
L0E38               sta       <u005F
                    clra
                    rts

L0E3C               coma
                    rts

L0E3E               cmpa      #'+
                    bne       L0E46
                    inc       <u0015
                    bra       L0E48

L0E46               leax      -1,x
L0E48               clr       <u005F
                    pshs      u
                    leau      >u0124,u
                    ldb       #180                Clear out 180 bytes @ u0124
                    lbsr      L0412
                    puls      u
                    leay      >u0124,u
                    ldb       #81
L0E5D               lda       ,x+                 Copy buffer up to CR or 81 chars
                    lbsr      L0F0C               Convert char to uppercase if lower
                    sta       ,y+
                    cmpa      #C$CR
                    lbeq      L0F17
                    bsr       L0E1C
                    bcc       L0E74
                    decb
                    bne       L0E5D
                    lbra      L0F17

L0E74               negb
                    addb      #81
                    stb       <u0016
                    clra
                    sta       -$01,y
                    lda       ,x
                    bsr       L0E1C
                    bcs       L0E84
                    leax      $01,x
L0E84               leay      >u0175,u
                    ldb       #81
L0E8A               lda       ,x+
                    bsr       L0F0C               Convert char to uppercase if lower
                    sta       ,y+
                    cmpa      #C$CR
                    beq       L0E99
                    decb
                    bne       L0E8A
                    bra       L0F17

L0E99               negb
                    addb      #$51
                    stb       <u0017
                    clra
                    sta       -$01,y
                    tst       <u0015
                    beq       L0EE0
                    leax      >u166D,u
                    ldd       #$30b4              Store 180 ASCII 0's into buffer
L0EAD               sta       ,x+
                    decb
                    bne       L0EAD
                    leax      >u0124,u
                    ldb       <u0016
                    leax      b,x
                    leay      >u16BD,u
                    bsr       L0ED8
                    leax      >u0175,u
                    ldb       <u0017
                    leax      b,x
                    leay      >u170E,u
                    bsr       L0ED8
                    leax      >u166D,u
                    leay      >u16BE,u
                    bra       L0EE8

L0ED8               lda       ,-x
                    sta       ,-y
                    decb
                    bne       L0ED8
                    rts

L0EE0               leax      >u0124,u
                    leay      >u0175,u
L0EE8               ldb       #80
L0EEA               lda       ,x+
                    cmpa      ,y+
                    blo       L0EFB
                    bhi       L0F01
                    decb
                    bne       L0EEA
                    lda       <u005F
                    bita      #$01
                    bra       L0F05

L0EFB               lda       <u005F
                    bita      #$02
                    bra       L0F05

L0F01               lda       <u005F
                    bita      #$04
L0F05               lbne      L0DF8
                    lbra      L0DEE

* Convert char to uppercase if it is a letter
L0F0C               cmpa      #'a                 Lower case letter?
                    blo       L0F16               No, return
                    cmpa      #'z                 Check high range
                    bhi       L0F16               No, return
                    suba      #$20                Yes, convert to uppercase
L0F16               rts

L0F17               comb
                    ldb       #$01
                    lbra      L0191

L0F1D               cmpa      #$03
                    beq       CmdCLRIF
                    cmpa      #$02
                    bne       L0F2B
                    dec       <u0044
                    blt       CmdCLRIF
                    bra       L0F43

L0F2B               cmpa      #$01
                    bne       L0F3B
                    lda       <u0043
                    cmpa      #$02
                    bne       L0F43
                    tst       <u0044
                    beq       CmdCLRIF
                    bra       L0F43

L0F3B               inc       <u0044
                    bra       L0F43

CmdCLRIF            clr       <u0043
                    clr       <u0044
L0F43               clrb
                    rts

* Table: 7 bytes/entry:
* 1st 5 bytes is name, high bit set & NUL padded
* Byte 6 is # bytes actually used
L0F45               fcs       'IF'
                    fcb       0,0,0,2,0
                    fcs       'ELSE'
                    fcb       0,4,1
                    fcs       'ENDIF'
                    fcb       5,2
                    fcs       'FI'
                    fcb       0,0,0,2,2
                    fcs       'CLRIF'
                    fcb       5,3
                    fcb       $ff

L0F69               leay      <L0F45,pc           Point to conditionals table
L0F6D               ldb       5,y                 Get actual length of string we are checking
                    os9       F$CmpNam            Compare with string pointed to by X
                    bcs       L0F80               If they don't match, skip ahead
                    lda       6,y                 Get conditional token(?) number
                    ldb       b,x                 Get char past end of matching string
                    cmpb      #C$CR               Is it a CR?
                    beq       L0F8B               Yes, return
                    cmpb      #C$SPAC             Is it a space?
                    beq       L0F8B               Yes, return
L0F80               leay      7,y                 Point to next command in table
                    lda       ,y                  Get 1st char from this entry
                    cmpa      #$FF                End of table marker?
                    beq       L0F8B               Yes, return
* NOTE: THIS INCA SEEMS TO BE USELESS, AS F$CMPNAM DOESN'T USE A
                    inca                          No, ???
                    bra       L0F6D               Process this one

CmdELSE             lda       #$01
                    sta       <u0043
                    lbra      CmdTHEN

CmdONERR            lbsr      L0907               Go find 1st non-space char or single char modifier
                    bne       L0F9B
                    clr       <u0046
L0F8B               rts

L0F9B               leay      >L03AC,pc           Point to 'GOTO'
                    ldb       #4                  4 chars to compare
                    os9       F$CmpNam            Does it match?
                    lbcs      L0BCF               No, print 'WHAT?'
                    leax      4,x                 Yes, skip X past 'GOTO'
                    lbsr      L091F               Go find 1st non-space char past 'GOTO'
                    leay      >u0C4C,u            Point to some sort of buffer
                    lda       ,x                  Get char from GOTO label
                    cmpa      #'+                 Is label after current pos. in script file?
                    bne       L0FBB               No, skip ahead
                    sta       ,y+                 Save '+' in buffer
                    leax      1,x                 Bump up source ptr past '+'
L0FBB               bsr       L100B               Go copy label name into buffer
                    inc       <u0046              Set flag that a GOTO was found
L0FBF               lda       ,x+                 Get 1st char from user's label again
                    leay      >L0408,pc           Point to single char modifiers table
L0FC5               cmpa      ,y+                 Illegal modifier char in label name?
                    bhi       L0FC5               Not yet, check other modifiers
                    blo       L0FBF               This char ok, check rest of label name
                    leax      -1,x                Point to last char (terminator) of label name
                    stx       <u0058              Save it & return
                    rts

CmdGOTO             lda       ,x
                    cmpa      #'+
                    bne       L0FDA
                    leax      1,x
                    bra       L0FFB
L0FDA               tst       <u006B
                    beq       L0FEA
                    ldy       <u0067
                    ldd       $09,y
                    leay      d,y
                    sty       <u0065
                    bra       L0FFB
L0FEA               pshs      u,x
                    clra
                    ldx       #$0000              Seek to beginning
                    tfr       x,u
                    os9       I$Seek
                    puls      u,x
                    lbcs      L0191
L0FFB               lbsr      L091F
                    leay      >u0BFC,u
                    bsr       L100B
                    lda       #C$CR
                    sta       ,x
                    inc       <u0045
                    rts

* Copy label from X to buffer @ Y, terminate at 1st illegal char with CR
* Exit: X=ptr to start of label name from user's buffer
*       Y=ptr to start of buffer entry copy of label name
L100B               pshs      y,x                 Preserve buffer & source ptrs
                    ldb       #79                 (78 bytes to check)
L100F               decb                          Dec # chars left to check
                    beq       L1022               If done max, skip ahead
                    lda       ,x+                 Get char for label
                    sta       ,y+                 Save in buffer
                    cmpa      #'A                 Is it a letter or higher?
                    bhs       L100F               Yes, continue copying
                    cmpa      #'0                 Is it lower than a #?
                    blo       L1022               Yes, not allowed, force end of label name
                    cmpa      #'9                 Is it a #?
                    bls       L100F               Yes, that is fine
L1022               lda       #C$CR               All others illegal, force CR in buffer copy
                    sta       -1,y                Save it
                    clrb                          No error
                    puls      pc,y,x              Restore regs & return

* M= command (???)
CmdMEq              ldb       #C$CR
                    stb       -$01,x
                    tst       <u006B
                    bne       L1057
                    tst       <u006C
                    bne       L1057
                    lda       #Data               Data module type
                    pshs      u,y,x
                    os9       F$Link
                    bcs       L1055
                    stu       <u0067              Save start address of module
                    sty       <u0065              Save execution address of module
                    ldd       2,u
                    addd      <u0067
                    subd      #$0003
                    std       <u0069
                    inc       <u006B
                    puls      u,y,x
                    leax      -$01,x
                    lbra      L0907

L1055               puls      u,y,x
L1057               lbra      L0BCF

* VAR. command
CmdVAR              leay      >u05A8,u
                    lda       ,x+
                    cmpa      #'?
                    beq       L10C9
                    cmpa      #'=
                    beq       L1096
                    cmpa      #C$SPAC
                    beq       L1085
                    cmpa      #';
                    beq       L1085
                    cmpa      #'9
                    bhi       L1085
                    cmpa      #'0
                    bcs       L1085
                    suba      #$30
                    ldb       #$51                Multiply by 81 (size of each VAR entry)
                    mul
                    leay      d,y
                    lda       ,x+
                    cmpa      #'=
                    beq       L1096
L1085               leax      -$01,x
                    pshs      x
                    tfr       y,x
                    ldy       #$0051
                    lda       #$02
                    os9       I$ReadLn
                    puls      pc,x

L1096               ldb       #80
                    lbsr      L0A25
                    lda       #C$CR
                    sta       ,y
                    rts

L10A0               fcb       C$LF
                    fcc       'User Variables :'
                    fcb       C$CR

L10B2               fcb       C$LF
                    fcc       'Shell Sub Variables :'
                    fcb       C$CR

L10C9               pshs      x
                    clrb
                    leax      >L10A0,pc
                    bsr       L10DF
                    leay      >u08D2,u
                    clrb
                    leax      >L10B2,pc
                    bsr       L10DF
                    puls      pc,x

L10DF               pshs      y,b
                    lbsr      L021B
                    puls      y,b
L10E6               pshs      y,b
                    lda       #$51
                    mul
                    leay      d,y
                    leax      >u0124,u
                    ldd       #'V*256+'A
                    std       ,x++
                    ldd       #'R*256+'.
                    std       ,x++
                    lda       ,s
L10FD               adda      #$30
                    ldb       #'=
                    std       ,x++
L1103               lda       ,y+
                    sta       ,x+
                    cmpa      #C$CR
                    bne       L1103
                    leax      >u0124,u
                    ldy       #$0057
                    lda       #$01
                    os9       I$WritLn
                    puls      y,b
                    bcs       L1122
                    incb
                    cmpb      #C$LF
                    bcs       L10E6
                    rts

L1122               puls      y
                    puls      pc,x

* INC. command (increment shell variable by 1)
CmdINC              bsr       L1144
                    lbcs      L0191
                    addd      #$0001
                    bra       L113A

* DEC. command (decrement shell variable by 1)
CmdDEC              bsr       L1144
                    lbcs      L0191
                    subd      #$0001
L113A               bsr       L11A7
                    lda       #C$CR
                    sta       $05,y
                    ldx       <u0048
                    clrb
                    rts

L1144               inc       <u0014
                    leay      >u05A8,u
                    lda       ,x+
                    stx       <u0048
                    cmpa      #'0
                    bcs       L1161
                    cmpa      #'9
                    bhi       L1161
                    suba      #$30
                    ldb       #81
                    mul
                    leay      d,y
                    tfr       y,x
                    bra       L1166

L1161               leas      2,s
                    lbra      L0BCF

L1166               pshs      y
                    leas      -$05,s
                    tfr       s,y
                    clr       $03,y
                    clr       $04,y
L1170               clr       $02,y
                    lda       ,x+
                    suba      #$30
                    cmpa      #$09
                    bhi       L1195
                    pshs      a
                    lda       #10
                    ldb       $03,y
                    mul
                    std       ,y
                    lda       $04,y
                    ldb       #10
                    mul
                    addd      $01,y
                    std       $01,y
                    clra
                    puls      b
                    addd      $01,y
                    std       $03,y
                    bra       L1170

L1195               ldd       3,y
                    leas      5,s
                    puls      pc,y

* 2 byte ASCII conversion table
L119B               fdb       10000
                    fdb       1000
                    fdb       100
                    fdb       10
                    fdb       1
                    fdb       0

L11A7               pshs      y,x,d
                    pshs      b
                    leax      >L119B,pc
L11AF               pshs      d
                    ldb       #'/
                    stb       2,s
                    puls      d
L11B7               inc       ,s
                    subd      ,x
                    bcc       L11B7
                    addd      ,x++
                    pshs      d
                    ldb       $02,s
                    stb       ,y+
                    lda       $01,x
                    puls      d
                    bne       L11AF
                    puls      b
                    puls      pc,y,x,d

* PAUSE command - may display text message, and then waits for key press or
* mouse button
CmdPAUSE            ldy       #394                Write up to 394 chars of pause string
                    lda       #$02                To standard error
                    os9       I$WritLn
                    lbcs      L0191
                    tfr       y,d                 Tfr # chars written to D
                    leax      d,x                 Point X to next char after ones written
                    leax      -1,x                Point to last char written
                    pshs      x                   Save ptr
                    ldd       #$02*256+SS.SSig    Std Err/Send signal when key pressed
                    ldx       #$000A              Signal $A is the one to send
                    os9       I$SetStt
                    lbcs      L0191               Error, use main shell error handler
                    ifgt      Level-1
                    ldb       #SS.MsSig           Send signal on mouse button press
                    os9       I$SetStt
                    lbcs      L0191
                    endc
                    ldx       #$0000              Go to sleep until one of the 2 is received
                    os9       F$Sleep
                    ldb       #SS.Relea           Signal gotten, release all signals
                    os9       I$SetStt
                    clrb                          No error & return
                    puls      pc,x

* Parse PATH=, add paths to PATH buffer list
CmdPATHEq
                    pshs      x                   Preserve ptr to string after 'PATH='
                    lda       ,x                  Get 1st char
                    cmpa      #'?                 User requesting current paths?
                    beq       L1245               Yes, go do that
                    pshs      u                   Preserve U
                    leau      >u0CDD,u            Point to PATH= buffer
L1217               lda       ,x+                 Get char from user-requested path
                    cmpa      #C$SPAC             Space?
                    beq       L1217               Yes, eat spaces until 1st real char found
                    sta       ,u+                 No, save char
L121F               leay      >L0408,pc           Point to command modifier list
L1223               cmpa      ,y+                 Match char?
                    bhi       L1223               No, our char is higher, check next modifier
                    beq       L1237               Found match, skip ahead
                    lda       ,x+                 No modifier found, get next char
                    sta       ,u+                 Save in PATH buffer
                    cmpa      #C$SPAC             Was it a space?
                    bne       L121F               No, check this char vs. modifier list
                    lda       #C$CR               Yes, change to CR
                    sta       -1,u                Save CR instead (terminate 1 path entry)
                    bra       L1217               Do whole list

* NOTE: ANY modifier (not just CR, but ! # & ; < > ^ |) stops PATH=parsing
L1237               leax      -1,x                Bump ptr back to last char from user
                    stx       2,s                 Save ptr on stack over original X
                    lda       #C$CR               Get CR
                    sta       -1,u                Save CR as current path end
                    sta       ,u                  And 1 extra for parse routines
                    puls      u                   Get U back
                    puls      pc,x                Restore new X & return

L1245               leax      >u0CDD,u            Point to start of PATH=buffer
L1249               ldy       #400                Write up to 400 chars to standard out
                    lda       #$01
                    os9       I$WritLn            Print text of one path
                    lbcs      L0191               Error, go process shell error
                    tfr       y,d                 Tfr # bytes written to D
                    leax      d,x                 Offset X to end of what was printed
                    lda       ,x                  Get char from there
                    cmpa      #C$CR               CR (end of path list)?
                    bne       L1249               No, go write next path out
                    puls      x                   Restore ptr to next set of PATH=
                    leax      1,x                 Bump ptr up by 1 & return
                    rts

* ^ (set priority on the fly) command
CmdCaret            ldb       #C$CR               Plop a CR onto the end
                    stb       -$01,x
                    ldb       <u0022              Any priority already set?
                    lbne      L0BCF               Yes, print 'WHAT?'
                    lbsr      L16EB               Go calculate binary priority into B
                    stb       <u0022              Save priority to fork module with
                    lbra      L0907               Continue processing for modifiers

* # (set data memory size) command
CmdMem              ldb       #C$CR
                    stb       -1,x
                    ldb       <u0003              Already have a data mem size set?
                    lbne      L0BCF               Yes, print 'WHAT?'
                    lbsr      L16EB
                    eora      #'K
                    anda      #$DF                Force uppercase
                    bne       L1294               No 'K', just save # of 256 byte pages
                    leax      1,x
                    lda       #4                  Multiply # of K by 4 to get # pages
                    mul
                    tsta
                    lbne      L0BCF               Ended up too big, print 'WHAT?'
L1294               stb       <u0003              Save data mem size to use
                    lbra      L0907               Continue processing command line

* Carriage return processing
CmdCR               leax      -1,x
                    lbsr      L145D
                    bra       L12A3

* ; (separator) command (also called by others)
CmdSEMIC            lbsr      L1459
L12A3               bcs       L12BA
                    lbsr      L0B96               Go do the path stuff
                    tst       <u005D              Is there a module that is unlinking?
                    bne       L12AE               Yes
                    bsr       L12D2               Go wait for child process to die (A=process #)

L12AE               bcs       L12BA               If child exited with status/signal code,skip
                    lbsr      L0907               Go parse for modifiers
                    cmpa      #C$CR               Was the next non-space/comma char a CR?
                    bne       L12B9               No, skip ahead
                    leas      4,s                 Yes, eat stack
L12B9               clrb                          No error

* Child process had a signal/status code
L12BA               pshs      cc                  Preserve error status
                    clr       <u005D              ???
                    puls      cc                  Restore carry
                    lbra      L0B96               ??? Go close some paths & return?

* & (background operation) command
CmdAmp              lbsr      L1459
                    bcs       L12BA
                    bsr       L12BA
                    ldb       #$26
                    lbsr      L16B3
                    bra       L12AE

* W command - Wait for a child to die
CmdW                clra                          Clear process ID #
* Entered here if commands are separated with ';' (or '()' groups)
L12D2               pshs      a                   Save ID # of process?
L12D4               os9       F$Wait              Wait for child to die or until signal received
                    tst       <u000E              Signal received (which would be in SHELL)?
                    beq       L12EC               No, child was exited (or got signal), go process
* Shell was interrupted by signal while Waiting
                    ldb       <u000E              Get signal that we received
                    cmpb      #S$Abort            Was it a PD.QUT (<CTRL>-<E>) (quit 'W'aiting?)
                    bne       L1304               No, skip ahead
                    lda       ,s                  Get process #
                    beq       L1304               None, exit
                    os9       F$Send              Send the signal to the child as well
                    clr       ,s                  Clear process #
                    bra       L12D4               Go Wait again (until child dies)

* Child F$Exited or was aborted - eat should go here
* Entry: A=ID # of deceased child
*        B=Exit (error) code from child
L12EC               lbcs      L1308               If F$Wait exited with error, return with it
                    cmpa      ,s                  Same process # as one we were waiting for?
                    beq       L1304               Yes, exit
                    tst       ,s                  No, was there a specific process # we wanted?
                    beq       L12F9               No, skip ahead
* Child died, but not the one we were waiting for
                    tstb                          Was there an error status?
                    beq       L12D4               No, ignore dead child and wait for one we wanted
* Child died with error on exit
L12F9               pshs      b                   Preserve child's exit status code
                    bsr       L12BA               ??? Go close & re-dupe paths?
                    ldb       #'-                 Get a '-' (for a '-003' process finished msg)
                    lbsr      L16B3               Print that out
                    puls      b                   Get back exit status code

L1304               tstb                          is there an Error/signal code?
                    beq       L1308               No, exit
                    cmpb      #S$Intrpt           Yes, is it a keyboard interrupt signal?
                    beq       eatchar             Yes, eat the key
                    cmpb      #S$Abort            Keyboard abort signal?
                    bne       errexit             No, exit with unknown error/signal code

* At this point, child died from signal 2 or 3 (CTRL-C or CTRL-E). The corres-
*  ponding key is also sitting in this devices PD.BUF as the 1st char. We musts
* 1) Disable keyboard signal & eat the key from the buffer
* 2) Exit from here with Carry set & signal (2 or 3) in B
eatchar             pshs      b,x,y               Preserve signal code & regs used
                    ldd       #SS.Ready           Std in, check for data ready on device
                    os9       I$GetStt            Check it
                    bcs       NotSCF              No chars waiting on device, exit with signal
                    lda       <u0018              Is the shell immortal?
                    beq       NotSCF              No, don't try to eat the char
eat                 clra                          Standard in path
                    leas      -PD.OPT,s           Make 32 byte buffer for OPT's
                    leax      ,s                  Point X to it
                    clrb                          SS.Opt call
                    os9       I$GetStt            Get current path options
                    lda       ,x                  Get device type
                    beq       Eatkey              SCF (not script file) so go eat key
NoChar              leas      PD.OPT,s            Eat temp buffer
                    bra       NotSCF              Exit with signal code (script file got signal)

* Have to eat key: Shut echo off 1st
Eatkey              clr       4,x                 PD.EKO flag off
                    os9       I$SetStt            Shut echo off
                    ldd       #SS.Relea           Std In, Release keyboard/mouse signals
                    os9       I$SetStt            Shut signals off so we don't get stuck
                    leax      ,-s                 Make 1 byte buffer on stack
                    ldy       #1                  1 byte to read
                    os9       I$Read              Eat the char
                    leas      1,s                 eat buffer
                    ldd       #SS.SSig            Std In, send signal on key ready
                    ldx       #$B                 Signal to send
                    os9       I$SetStt            Turn keyboard signal on again
                    leax      ,s                  Point to temp buffer again
                    inc       4,x                 PD.EKO flag on
                    clra                          Std In
                    clrb                          Set Options
                    os9       I$SetStt            Turn echo back on
                    leas      PD.OPT,s            Deallocate temp buffer
                    ldb       u180D,u             Get current history line #
                    cmpb      #1                  First one?
                    bhi       Previous            No, B=previous one
                    ldb       u180C,u             Was on first, so get last
                    incb                          Adjust for dec
Previous            decb                          Point to previous one
                    lbsr      L19D3               Go get ptr to history
                    lda       ,y                  Get 1st char from previous line in history
                    sta       ,x                  Save char there
                    ldd       #SS.Fill            Fill keyboard buffer call to Std In
                    ldy       #$8001              1 char long, don't append CR
                    os9       I$SetStt            Stick that key into the keyboard buffer
NotSCF              puls      b,x,y               Restore regs (and exit status byte in B)
errexit             coma                          Yes, set carry & exit
L1308               puls      pc,a

* Level 2: If data area <4.25K, force up to 7.5K
* Exit: A=Type/language
*       X=Current source line parsing ptr (module name to chain)
*       Y=Size of parameter area
*       U=Ptr to parameter area
*       B=Size of data area
L130A               lda       #Prgrm+Objct        Module type/language
                    ldb       <u0003              Get # pages of data mem needed for forked module
                    ifgt      Level-1
                    cmpb      #$11                Is it at least 17?
                    bhs       L1316               Yes, skip ahead
                    ldb       #$1F                Otherwise, force to 7.5K minimum
                    stb       <u0003              Save it
                    endc
L1316               andcc     #^Carry             Clear carry
                    ldx       <u0004              Get mem module ptr
                    ldy       <u0006              Get size of current command group
                    ldu       <u0008              Get ptr to start of current command group
                    rts

* Copy string from X to Y until CR is hit
L1320               lda       ,x+                 Get char
                    sta       ,y+                 Save it
                    cmpa      #C$CR               Carriage return?
                    bne       L1320               No, keep copying
                    rts                           Done, return

* Attempt load in module to execute (it's not in memory)
* Entry: X=Ptr to module name
L1329               lda       #EXEC.              1st, attempt to get it from current Exec DIR
                    os9       I$Open              Attempt to open it
                    bcc       L1362               Found it, continue
* Possible search thru PATH= settings
                    inc       <u000F              ??? Set flag to indicate using PATH=
                    leax      >u0CDD,u            Point to start of PATH= list
L1336               clrb
                    lda       ,x                  Get 1st char from next PATH= line
                    cmpa      #C$CR               End of list?
                    lbeq      L1564               Yes, ???
                    leay      >u0124,u            No, point to temp buffer
                    bsr       L1320               Copy path to temp buffer until CR
                    pshs      x                   Preserve ptr to next possible path
                    lda       #'/                 Add slash since we want file from this path
                    sta       -1,y                Save at end of path in temp buffer
                    ldx       <u0004              Get ptr to module/script name we are looking for
                    bsr       L1320               Copy it into temp buffer up to CR
                    leax      >u0124,u            Point to start of full path list
                    lda       #READ.              Attempt to open file
                    os9       I$Open
                    puls      x                   Restore ptr to next possible path
                    bcs       L1336               Didn't find file there, try next path
                    leax      >u0124,u            Point to full pathlist again
                    stx       <u0004              Replace ptr to module with full pathlist ptr
L1362               leax      >u00D6,u            Point to buffer to hold beginning of file
                    ldy       #77                 77 bytes to read
                    os9       I$Read              Read it in
                    bcc       L1373               No error, skip ahead
                    cmpb      #E$EOF              Just EOF error?
                    bne       L13CE               No, something more serious, skip ahead
L1373               tst       <u000F
                    bne       L137B
                    ldb       #$04
                    stb       <u000F
L137B               pshs      a                   Save path # a sec
                    ldd       M$ID,x              Get possible module header bytes
                    cmpd      #M$ID12             Legit module header?
                    puls      a                   Restore path #
                    beq       L1396               OS9 module, skip ahead
* Not module...possible shell script?
                    os9       I$Close             Not OS9 module, close file
                    clrb
                    dec       <u000F              Dec flag
                    lbeq      L1564               If 0, skip ahead
                    inc       <u000F              If not, inc & skip ahead
                    lbra      L1564

* Seems to be OS9 module
L1396               clr       <u000F              Clear flag
                    ldy       M$Name,x            Get offset to module name
                    leax      >u00E3,u            Point X to offset $E in module
                    cmpy      #$000D              Does the name start at offset $D?
                    beq       L13C0               Yes, skip ahead
                    pshs      u                   Preserve U
                    tfr       y,u                 Move name offset to U
                    ldx       #$0000              MSW of file pos=0
                    os9       I$Seek              Go seek to that spot in file
                    puls      u                   Restore U
                    bcs       L13CE               Error seeking, go handle
                    ldy       #64                 Go read up to 64 char filename
                    leax      >u00E3,u            Point to spot to hold filename
                    os9       I$Read              Read it in
                    bcs       L13CE               Error reading, go handle
L13C0               pshs      a                   Save path #
                    os9       F$PrsNam            Parse module name
                    puls      a                   Restore path #
                    bcs       L13CE
                    cmpb      #$40
                    bhi       L1422
                    clrb
L13CE               pshs      b,cc                Preserve error status
                    os9       I$Close             Close file
                    puls      b,cc                Restore error status
                    lbcs      L162B               If error, exit with it (S/B L162C)
                    leax      >u00D6,u            Point to buffer holding 77 bytes of file
                    lda       $06,x
                    ldy       $0B,x
                    cmpa      #$40
                    bne       L1407
                    bsr       L13EF
                    lbcs      L162B
                    lbra      L14AF
L13EF               leax      >u00E3,u
                    ifgt      Level-1
                    os9       F$NMLink
                    else
                    pshs      u
                    os9       F$Link
                    puls      u
                    endc
                    bcc       L1400
                    ldx       <u0004
                    ifgt      Level-1
                    os9       F$NMLoad
                    else
                    pshs      u
                    os9       F$Load
                    puls      u
                    endc
                    bcc       L1400
                    rts
L1400               leax      >u00E3,u
                    stx       <u0004
                    rts
L1407               cmpa      #$51
                    bne       L1413
                    bsr       L13EF
                    lbcs      L162B
                    bra       L1427
L1413               cmpa      #$11
                    lbne      L14D7
                    leax      >u00E3,u
                    stx       <u0010
                    lbra      L15D7
L1422               lbsr      L08CB
                    bra       L13CE

* Call a shellsub module
L1427               clra                          Type/language byte to wildcard:any will match
                    ldx       <u0004              Get ptr to module name
                    pshs      u                   Preserve U
                    os9       F$Link              Attempt to link it in
                    puls      u                   Restore U
                    lbcs      L162B               If we couldn't link, Exit with error
                    ldx       <u0004              Get ptr to module name again
                    ifgt      Level-1
                    os9       F$UnLoad            Unlink it
                    else
                    pshs      a,b,x,y,u
                    os9       F$Link
                    os9       F$Unlink
                    os9       F$Unlink
                    puls      a,b,x,y,u
                    endc
                    lbcs      L162B               If we couldn't unlink exit with error
                    ldx       <u0008              Get ptr to current group (param ptr for shellsub)
                    ldd       <u0006              Get size of param area for shellsub
                    leau      >u08D2,u            Point to shellsub variable area
                    jsr       ,y                  Execute shellsub module
                    pshs      b,a,cc              Preserve error status & A
                    clra
                    clrb
                    std       <u0010              ? (originally pointing to E3 if type $11 module)
                    ldx       <u0004              Get shellsub module ptr
                    ifgt      Level-1
                    os9       F$UnLoad            Unlink it
                    else
                    pshs      a,b,x,y,u
                    os9       F$Link
                    os9       F$Unlink
                    os9       F$Unlink
                    puls      a,b,x,y,u
                    endc
                    std       <u0004              Clear shellsub module ptr
                    inc       <u005D              Set flag that we should wait for module to exit?
                    puls      pc,u,y,x,d,cc       restore regs & return

L1459               lda       #C$CR
                    sta       -1,x
L145D               clr       <u0060
                    pshs      u,y,x
                    ldx       <u0004              Get ptr to name
                    ldd       ,x                  Get 2 chars of name
                    andb      #$5F                Force 2nd one to uppercase
                    cmpd      #$2F57              Is it a /W?
                    bne       L1473               No, check for shellsub
                    comb                          Yes, exit with bad mode error
                    ldb       #E$BMode
                    lbra      L162B

L1473               clra                          Wildcard NMLink
                    ifgt      Level-1
                    os9       F$NMLink            Link to module
                    else
                    pshs      u
                    os9       F$Link              Link to module
                    puls      u
                    endc
                    lbcs      L1329               Error, do something
                    cmpa      #ShellSub+Objct     ShellSub module?
                    beq       L1427               Yes, go set up for it
                    ldx       <u0004              Get ptr to name back
                    ifgt      Level-1
                    os9       F$UnLoad            Drop the link count back down
                    else
                    pshs      a,b,x,y,u
                    os9       F$Link
                    os9       F$Unlink
                    os9       F$Unlink
                    puls      a,b,x,y,u
                    endc
                    pshs      y                   Save data area size
                    ldx       <u0004              Get ptr to module name again
                    leay      >L000D,pc           Point to 'Shell'
                    ldb       #$05                Size of 'Shell'
                    os9       F$CmpNam            Is the module requested Shell?
                    puls      y                   Restore data area size
                    bcs       L14A3               Not shell, skip ahead
                    ldb       5,x                 Get char right after 'shell'
                    cmpb      #C$CR               Is 'shell' the only thing on the line?
                    lbeq      L158D               Yes, skip ahead
                    cmpb      #C$SPAC             Is it a space?
                    lbeq      L158D               Yes, skip ahead
* Not Shell or Shellsub module
L14A3               cmpa      #Prgrm+Objct        ML program?
                    lbeq      L15D7               Yes, skip ahead
                    cmpa      #Data               Is it a data module?
                    bne       L14D7               No, skip ahead
                    inc       <u0060              Set flag - data module
L14AF               inc       <u0060              Bump it up
                    ldx       <u0004              Get ptr to module name
                    os9       F$PrsNam            Parse the name
                    ldy       <u0063              Get ptr to Intercept routines data mem ($418)
                    leay      $0A,y               Bump up to $422
                    sty       <u0008              Save ptr to start of current group
                    sty       <u0061              ??? Ptr to data modules name?
                    ldx       #60                 Max size of group
                    stx       <u0006              Save it
                    ldx       <u0004              Get ptr to module name
L14C8               lda       ,x+                 Copy it to buffer @ $422
                    sta       ,y+
                    decb
                    bne       L14C8
                    lda       #C$CR               Append a CR to it
                    sta       ,y+
                    clrb
                    lbra      L1564
* Not 6809 object code or data module either
L14D7               sty       <u000A              Save data area size
                    leax      >L0013,pc           Point to alternate languages table
L14DE               tst       ,x                  Is this entry active?
                    lbeq      L1629               No, exit with non-existing module error
                    cmpa      ,x+                 Same module type as we want?
                    beq       L14EE               Yes, skip ahead
L14E8               tst       ,x+                 No, eat module name
                    bpl       L14E8
                    bra       L14DE               Try next module
* Found run-time language match
L14EE               ldd       <u0008              Get ptr to start of current command group
                    subd      <u0004              Calculate size of whole group
                    addd      <u0006              Don't include size of current group
                    std       <u0006              Save remainder size
                    ldd       <u0004              Get ptr to start of sub-module
                    std       <u0008              Save it
                    pshs      y,x                 Preserve data area size & primary module ptr
                    leax      >L0021,pc           Point to 'RUNB'
                    cmpx      ,s                  Is that the run-time module we want?
                    bne       L1546               No, skip ahead
* RUNB needed - have to () & quote/commas between params
                    ldx       <u0008              Yes, get sub-module ptr?
                    leay      >u0418,u            Point to before sub-module
                    bsr       L154B               Copy buffer up to next param (or end of line)
                    beq       L1535               If it was end of line, add CR & continue
                    ldd       ,x                  Get 2 param chars
                    cmpd      #$2822              Is it '("' (RUNB variables ahead?)
                    beq       L1546               Yes, skip ahead (we won't have to add them)
                    lda       #C$SPAC             No, add ' ("'
                    sta       ,y+
                    ldd       #$2822
                    std       ,y++
L151F               bsr       L154B               Copy buffer up to next param (or end of line)
                    beq       L152E               If end of line, add '")' (close params)
                    ldd       #$222C              Add '","' (Basic09 param separators
                    std       ,y++
                    lda       #$22                2nd quote of above
                    sta       ,y+
                    bra       L151F               Keep doing for all parameters

L152E               ldd       #$2229              Add  '")' to end parameter list
                    std       ,y++
                    lda       #C$CR               Add CR
L1535               sta       ,y+
                    tfr       y,d                 Move end of param ptr to D
                    leay      >u0418,u            Point to start of param
                    sty       <u0008              Save as start ptr
                    subd      <u0008              Calculate param size
                    std       <u0006              Save it
L1546               puls      y,x                 Restore data area size & primary module ptr
                    lbra      L15D5

* Copy from X to Y until either a CR or a space char is hit
* If it finds a space, it will eat them until the next non-space char is found
L154B               lda       ,x+                 Get char
                    cmpa      #C$SPAC             Is it a space?
* Was L155B
                    beq       L1559               yes, skip ahead
                    cmpa      #C$CR               Is it the end of the line?
                    beq       L155F               Yes, bump ptr back to CR & exit
                    sta       ,y+                 Save the char
                    bra       L154B               Keep doing it

L1559               lda       ,x+                 Get char
L155B               cmpa      #C$SPAC             Is it another space?
                    beq       L1559               Yes, keep eating spaces
L155F               leax      -$01,x              Bump ptr back to either non-space or CR
                    cmpa      #C$CR               Is it a CR? & return
                    rts

* THIS CMPB / LBEQ SEEMS TO BE USELESS, AS B IS ALWAYS CLEAR COMING INTO THIS
* ROUTINE
L1564               cmpb      #E$BMode
                    lbeq      L162B
                    ldx       <u0006              Get size of current group
                    leax      5,x                 Bump it up by 5???
                    stx       <u0006              Save new size
                    tst       <u0060              Data module linked?
                    bne       L1592               Yes, skip ahead
                    ldx       <u0004              Get module name ptr
                    ldu       4,s
                    lbsr      CmdIn               Set up paths
                    lbcs      L162B               If error, exit with it
                    bra       L1592               Start up shell with '-P X PATH=(current)'

* L1581 is for sub-shells (?), L1586 for normal shells
L1581               fcc       '-P X '             Prompting off/exit on error
L1586               fcc       'PATH= '            For inheriting parent shell's paths
                    fcb       C$CR

L158D               leax      <L1586,pc           Point to 'path='
                    bra       L1595               Skip ahead

L1592               leax      <L1581,pc           Point to '-p x '
L1595               leay      >u166D,u            Point to about-to-be merged buffer
                    lbsr      L1320               Copy up until CR
                    leay      -1,y                Point to CR
                    leax      >u0CDD,u            Point to copy of current path=
* Copy all paths to buffer, changing <CR> separated ones with Spaces
L15A2               lda       ,x                  Get char
                    cmpa      #C$CR               CR?
                    beq       L15B1               Yes, don't copy this buffer
                    lbsr      L1320               Copy up until CR
                    lda       #C$SPAC             Replace CR with Space
                    sta       -1,y
                    bra       L15A2               Continue copying CR marked blocks until done
L15B1               lda       #';                 Replace final CR with ; (command separator)
                    sta       -1,y
                    tst       <u0060
                    beq       L15BE
                    ldd       #'M*256+'=          If flag set, append 'M='
                    std       ,y++
L15BE               ldx       <u0008              Get ptr to start of current group
                    lbsr      L1320               Copy up until CR
                    leax      >u166D,u            Point to merged buffer again
                    stx       <u0008              Make it the new current group start
                    tfr       y,d                 Move end buffer ptr to D
                    pshs      x                   Push merged buffer ptr for SUBD
                    subd      ,s++                Calculate size of merged buffer
                    std       <u0006              Save merged buffer size
                    leax      >L000D,pc           Point to 'shell'

L15D5               stx       <u0004              Save ptr to module name to fork
L15D7               ldx       <u0004              Get ptr to module name to fork
                    lda       #Prgrm+Objct
                    ifgt      Level-1
                    os9       F$NMLink            Get memory requirement stuff from it
                    else
                    pshs      u
                    os9       F$Link              Get memory requirement stuff from it
                    tfr       u,y
                    puls      u
                    endc
                    bcc       L15E5               Got it, continue
                    ifgt      Level-1
                    os9       F$NMLoad            Couldn't get, try loading it
                    else
                    pshs      u
                    os9       F$Load              Couldn't get, try loading it
                    tfr       u,y
                    puls      u
                    endc
                    bcs       L162B               Still couldn't get, can't fork
L15E5
                    ifeq      Level-1
                    ldy       M$Mem,y
                    endc
                    tst       <u0003              Memory size specified?
                    bne       L15F2               Yes, skip ahead
                    tfr       y,d                 No, tfr modules mem size to D
                    addd      <u000A              ??? Add to something
                    addd      #$00FF              Round up to nearest page
                    sta       <u0003              Save # of pages need for data mem
L15F2               clr       ,-s                 Clear byte on stack to store original priority
                    ldb       <u0022              Get priority we want to set new program at
                    beq       DnePrior            0=Use inherited priority, skip ahead
                    ifeq      Level-1
                    ldx       <D.Proc
                    else
                    leax      >u166D,u            Point to place to hold Process descriptor
                    os9       F$ID                Get our process #
                    os9       F$GPrDsc            Get our process descriptor
                    endc
                    ldb       P$Prior,x           Get our priority
                    stb       ,s                  Save it
                    ldb       <u0022              Get priority for new process
                    os9       F$SPrior            Set our priority so child will inherit it
DnePrior            lbsr      L130A               Go setup Fork entry registers
                    os9       F$Fork              Create the new process
                    pshs      d,cc                Preserve error (if any) & new process #
                    ldb       3,s                 Get original priority back
                    beq       L1609               Priority didn't change, ignore it
                    os9       F$ID                Get our process # into A
                    os9       F$SPrior            Reset our priority back to normal
L1609               lda       #Prgrm+Objct        Std 6809 module
                    ldx       <u0010              Get ptr to some other module name (?)
                    bne       L1611               There is one, unlink it instead
                    ldx       <u0004              Get ptr to command name
L1611
                    ifgt      Level-1
                    os9       F$UnLoad            Bump link count down back to normal?
                    else
                    pshs      a,b,x,y,u
                    os9       F$Link
                    os9       F$Unlink
                    os9       F$Unlink
                    puls      a,b,x,y,u
                    endc
                    clra
                    clrb
                    std       <u0010              Zero out other module name ptr
                    std       <u0004              Clear out ptr to main command name
                    lda       <u0060              Check if data module needs to be unlinked too
                    cmpa      #$01                Just 1 link to it?
                    bne       L1627               No, skip ahead
                    lda       #Data               Data module
                    ldx       <u0061              Get ptr to name of data module
                    ifgt      Level-1
                    os9       F$UnLoad            Bump link count down back to normal
                    else
                    pshs      a,b,x,y,u
                    os9       F$Link
                    os9       F$Unlink
                    os9       F$Unlink
                    puls      a,b,x,y,u
                    endc
L1627               puls      cc,d                Get back F$FORK error/process #
                    leas      1,s                 Eat priority byte
                    puls      pc,u,y,x            Restore regs & return

L1629               ldb       #E$NEMod            Non-existing module error
L162B               coma
                    puls      pc,u,y,x

L162E               fcc       '/pipe'
                    fcb       C$CR

CmdPIPE             pshs      x
                    leax      <L162E,pc           Point to '/pipe'
                    ldd       #$0103
                    lbsr      L0C0E
                    puls      x
                    bcs       L169E
                    lbsr      L1459
                    bcs       L169E
                    lda       ,u
                    bne       L1653
                    os9       I$Dup
                    bcs       L169E
                    sta       ,u
L1653               clra
                    os9       I$Close
                    lda       #$01
                    os9       I$Dup
                    lda       #$01
                    lbsr      L0BA8
                    lda       #$02
                    lbra      L0BA8

* Filename for shell log-append mode because of leading '+'
L1666               fcc       '+/dd/log/uxxx'
                    fcb       C$CR

* Make shell logging filename @ u0CBD,u
L1674               leax      <L1666,pc           Point to log name string (append mode)
                    leay      >u0CBD,u            Point to buffer to hold shell log name
                    lbsr      L1320               Copy name to buffer
                    leay      -4,y                Point to where 1st digit will go
                    lda       <u005A+1            Get LSB of user #?
                    pshs      y,x,d               Preserve regs
                    leay      <L1693,pc           Point to routine
                    bra       L16B9               Go convert digits & append to logname

L168A               lda       <u0047
                    pshs      y,x,d
                    leay      <L1693,pc
                    bra       L16B9

L1693               ldy       $0B,s               Get ptr to where shell log # goes
                    ldd       $03,s               Get 1st 2 digits of #
                    std       ,y++                Save in shell log pathname
                    lda       $05,s               Get last digit
                    sta       ,y                  Save it too
L169E               rts

L169F               ldd       4,s                 Get last 2 digits of process # (ASCII)
                    std       >u01EC,u            Save it & return
                    rts

L16A6               pshs      y,x,d               Preserve End of parm ctr & others
                    os9       F$ID                Get user's ID #
                    sty       <u005A              Save it
                    leay      <L169F,pc           Point to routine
                    bra       L16B9

* Set up to write out process # when forked?
L16B3               pshs      y,x,d
                    leay      >L021B,pc

* Entry: A=Process ID #
* Exit: L01EC=2 lower digits of process # in ASCII format

L16B9               pshs      y,x,b               Preserve regs
                    leax      1,s                 Point X to X value on stack
                    ldb       #$2F                Init B to start @ '0' in loop
L16BF               incb                          Bump ASCII # up
                    suba      #100                Start with 100's digit
                    bhs       L16BF               More left, keep going
                    stb       ,x+                 Save digit
                    ldb       #$3A                Init so loop starts @ ASCII '9'
L16C8               decb                          Bump ASCII # down
                    adda      #10                 Do 10's digit
                    bhs       L16C8               Still more, keep going
                    stb       ,x+                 Save 10's digit
                    adda      #$30                Bump 1's digit up to ASCII equivalent
                    ldb       #C$CR               Add carriage return
                    std       ,x                  Save overtop Y on the stack
                    leax      ,s                  Point X to B on stack
                    jsr       ,y
                    leas      5,s                 Eat stack
                    puls      pc,y,x,d            Restore other regs & return

* KILL command
CmdKill             bsr       L16EB               Go get process # to kill
                    cmpb      #2                  Trying to kill the system process or 1st shell?
                    bls       L170A               Yes, print 'WHAT?' & ignore it
                    tfr       b,a                 Move process # to proper reg
L16E5               clrb                          S$Kill signal
                    os9       F$Send              Send it to the process & return
                    rts

* Clear Screen by writing $0C to stdout
ClrByte             fcb       $0C
ClrLen              equ       *-ClrByte

CmdCLS
                    pshs      x
                    lda       #$01
                    leax      ClrByte,pcr
                    ldy       #ClrLen
                    os9       I$Write
                    puls      x,pc

* Set priority - subroutine to calculate binary version of #
* (used for both process # & priority values)
L16EB               clrb                          Initialize # for loop
L16EC               lda       ,x+                 This loop will calculate the binary version
                    suba      #$30                Of the ASCII # pointed to by X
                    cmpa      #9
                    bhi       L16FD
                    pshs      a
                    lda       #10
                    mul
                    addb      ,s+
                    bcc       L16EC               Keep going until overflows past 255
L16FD               lda       ,-x                 Get last char done
                    bcs       L1708               If #>255, eat RTS & exit with error
                    tst       <u0014              If flag is set, return
                    bne       L169E
                    tstb                          Otherwise, check if # is 0
                    bne       L169E               No, return
L1708               leas      2,s                 Yes, eat RTS address & exit with error
L170A               lbra      L0BCF               Print 'WHAT?'
* SETPR routine
CmdSETPR            bsr       L16EB               Go calculate process #
                    stb       <u0021              Save it
                    lbsr      L0907               Find next field (after commas/spaces)
                    bsr       L16EB               Go calculate priority (into B)
                    lda       <u0021              Get process #
                    os9       F$SPrior            Set it's priority & return
                    rts

L171C               fcc       'pwd: bad name in path'
                    fcb       C$CR
L1732               fcc       '.......................................'
L1759               fcc       '.'
                    fcb       C$CR
L175B               fcc       'pwd: read error'
                    fcb       C$CR

CmdPWD              clr       <u003D
L176D               pshs      y,x
                    leay      >u02F2,u
                    lda       #$81
                    tst       <u0037
                    beq       L178F
                    ldx       <u0039
                    bra       L17F7
* .PXD command
CmdPXD              clr       <u003D
                    pshs      y,x
                    leay      >u0375,u
                    lda       #$85
                    tst       <u0038
                    beq       L178F
                    ldx       <u003B
                    bra       L17F7
L178F               sta       <u0029
                    sty       <u003E
L1794               leax      >$0080,y
                    lda       #C$CR
                    sta       ,x
                    stx       <u002A
                    leax      <L1759,pc
                    stx       <u0040
                    bsr       L1801
                    lbsr      L183C
L17A9               ldd       <u002C
                    std       <u0032
                    lda       <u002E
                    sta       <u0034
                    bsr       L1828
                    beq       L17D3
                    lda       <u0012
                    os9       I$Close
                    lbcs      L188C
                    ldx       <u0040
                    leax      -$01,x
                    stx       <u0040
                    bsr       L1801
                    bsr       L183C
                    bsr       L1817
                    leax      >u03F8,u
                    lbsr      L1859
                    bra       L17A9
L17D3               lda       <u0012
                    ldb       #SS.DevNm
                    leax      >u00B5,u
                    os9       I$GetStt            Get device name
                    bsr       L1859
L17E0               lda       <u0012
                    os9       I$Close
                    ldx       <u002A
                    lda       <u0029
                    bita      #$04
                    bne       L17F3
                    inc       <u0037
                    stx       <u0039
                    bra       L17F7
L17F3               inc       <u0038
                    stx       <u003B
L17F7               ldy       #$0083
                    lda       #$01
                    clrb
                    lbra      L18A0
L1801               lda       <u0029
                    os9       I$Open
                    sta       <u0012
                    rts
L1809               lda       <u0012
                    leax      >u03F8,u
                    ldy       #$0020
                    os9       I$Read
                    rts
L1817               bsr       L1809
                    bcs       L1896
                    leax      >u0415,u
                    leay      >u0032,u
                    bsr       L1830
                    bne       L1817
                    rts
L1828               leax      >u002C,u
                    leay      >u002F,u
L1830               ldd       ,x++
                    cmpd      ,y++
                    bne       L183B
                    lda       ,x
                    cmpa      ,y
L183B               rts
L183C               bsr       L1809
                    ldd       >u0415,u
                    std       <u002F
                    lda       >u0417,u
                    sta       <u0031
                    bsr       L1809
                    ldd       >u0415,u
                    std       <u002C
                    lda       >u0417,u
                    sta       <u002E
                    rts
L1859               os9       F$PrsNam
                    bcs       L1890
                    ldx       <u002A
                    pshs      b
                    incb
                    clra
                    std       <u0032
                    tfr       x,d
                    subd      <u0032
                    cmpd      <u003E
                    bls       L1881
                    puls      b
L1871               lda       ,-y
                    anda      #$7F
                    sta       ,-x
                    decb
                    bne       L1871
                    lda       #$2F
                    sta       ,-x
                    stx       <u002A
                    rts

L1881               lda       #'*
                    sta       ,-x
                    stx       <u002A
                    leas      3,s
                    lbra      L17E0

L188C               pshs      b,cc
                    bra       L18AB

L1890               leax      >L171C,pc
                    bra       L189A

L1896               leax      >L175B,pc
L189A               leas      $02,s
                    ldd       #$02FF
L18A0               stx       <u002A
                    pshs      b,cc
                    tst       <u003D
                    bne       L18AB
                    os9       I$WritLn
L18AB               puls      b,cc
                    puls      y,x,pc

L18DB               leax      >u0124,u            Point to PD.OPT work copy area
                    clrb                          Change to CLRB
                    os9       I$GetStt            Get current PD.OPT settings
                    tst       ,x                  Check device type
                    bne       L1914               If not SCF, don't bother changing stuff
                    inc       >u1812,u            Set flag that we are changing key defs
                    ldd       <$10,x              Get PD.INT & PD.QUT chars (<CTRL>-<C> & <E>)
                    sta       >u180F,u            Save copy of PD.INT
                    stb       >u180E,u            Save copy of PD.QUT
                    ldd       #$0A0C              Reload with up & down arrows
                    std       <$10,x              Save 'em
                    lda       $06,x               Get PD.NUL count (normally 0)
                    sta       >u1811,u            Save copy
                    lda       #$05                Replace with 5
                    sta       $06,x
                    clra
                    clrb                          Reset path options to new settings
                    os9       I$SetStt            Do SS.OPT Setstat

* Non-SCF devices go here (ex. a script file would be RBF)
L1914               ldb       #SS.SSig            Send signal on data ready
                    ldx       #$000B              Signal code to send is $B
                    rts                           Do SetStt, clear <E signal copy, and go to L191C

* X still is $B from L1914
* Called when F$Sleep @ L0171 is interrupted by keyboard/mouse signal
L191C               ldb       <u000E              Get Signal code
                    clr       <u000E              Clear memory copy of signal code
                    cmpb      #S$Abort            Keyboard abort signal (<CTRL>-<E>)?
                    bne       L1928               No, check next
                    bsr       L1932               Write CR out if no history yet
                    bra       L1967               Go backwards in history

L1928               cmpb      #S$Intrpt           Keyboard interrupt signal (<CTRL>-<C>)?
                    lbne      L017B               No check for $B signal (ignore rest)
                    bsr       L1932               Write CR out if no history yet
                    bra       L1991               Go forwards in history

* Keyboard abort or Keyboard interrupt signal
L1932               tst       >u180D,u            Any history entries yet?
                    bne       L193D               Yes, exit
                    bsr       L1959               Otherwise, put CR into the buffer
                    os9       I$WritLn            Write it out to standard out
L193D               rts

L193E               os9       I$ReadLn            Read in line
                    bcc       L194E               No error, skip ahead
* NOTE: WHEN THE ABORT A SUB-FORKED PROGRAM BUG OCCURS, THE ABOVE READLN
* EXITS WITH CARRY SET & B=0 (ERROR 0)
                    cmpb      #$02                Go backward in history buffer signal?
                    beq       L1967               Yes, go process
                    cmpb      #$03                Go forward in history buffer signal?
                    beq       L1991               Yes, go process
                    lbra      L1AAA               Go to parse routine with unknown error in B
L194E               cmpy      #$0001              Just 1 char. read?
                    lbeq      L1AA3               Yes, go do normal parsing (no error)
                    lbra      L1A37               Otherwise, change chars <$0D to spaces

* Change A to be standard output???
L1959               lda       #C$CR               Carriage return
                    leax      >u0124,u            ??? Point to a buffer
                    sta       ,x                  Save CR there
                    clra                          Prepare to write the CR out to standard input
                    ldy       #$0001
                    rts
* PD.QUT (redefined to be go back 1 in history buffer)
L1967               tst       >u180C,u            Any lines in history buffer?
                    bne       L1972               Yes, go move between them
                    bsr       L1959               Otherwise, put CR into buffer
                    lbra      L1AA3               Go to normal command parse routine (no error)

L1972               ldb       >u180D,u            Get 'current' history buffer entry #
                    cmpb      #$01                On the first one?
                    bls       L1987               Yes, go wrap to end
                    cmpb      >u180C,u            Somehow point past last one?
                    bhi       L1987               Yes, bump back to last one
                    decb                          Bump to previous one
                    stb       >u180D,u            Save it as 'current' history entry #
                    bra       L19B3

L1987               ldb       >u180C,u            Get highest history entry #
                    stb       >u180D,u            Make it the current
                    bra       L19B3

* PD.INT (redefined to be go forward 1 in history buffer)
L1991               tst       >u180C,u            Any lines in history buffer?
                    bne       L199C               Yes, go move between them
                    bsr       L1959               Otherwise, put CR into buffer
                    lbra      L1AA3               Go to normal command parse routine (no error)

L199C               ldb       >u180D,u            Get current history entry #
                    cmpb      >u180C,u            Higher or same as last one?
                    bhs       L19AD               Yes, wrap to beginning
                    incb                          Bump to next one
                    stb       >u180D,u            Save it as 'current' history entry #
                    bra       L19B3

L19AD               ldb       #$01                Set history entry # to 1st one
                    stb       >u180D,u            Save as 'current' entry #
L19B3               bsr       L19D3               Go get ptr to history entry buffer we want
                    sty       >u1813,u            Save 'current' history buffer ptr
                    leax      >u0213,u            Point to expanded shell prompt
                    ldy       >u01F7,u            Get size of expanded shell prompt
                    lda       #$02                Std Err
                    os9       I$WritLn            Write out shell prompt
                    bsr       L19EA               Go Pre-load Read buffer with history entry
                    bcc       L1A0E               No error, continue
                    lbra      L1AAA               Normal parse with error

* Find history entry # we want
* Entry: B=history entry # (1-xx)
* Exit: Y=Ptr to history buffer entry we wanted
L19D3               ldy       >u180A,u            Get ptr to start of history buffers
L19D8               decb                          Bump down counter to find entry we want
                    beq       L19E9               Found it, skip ahead
L19DB               tst       ,y+                 Wrong one, search for end of one we are checking
                    beq       L19E4               Found it, skip ahead
                    lbsr      L1A97               Wrap buffer ptr if we hit end of all history
                    bra       L19DB               Keep searching for end of current entry

L19E4               lbsr      L1A97               Wrap buffer ptr if we hit end of all history
                    bra       L19D8               Go into next entry in history buffers

L19E9               rts                           Found it, leave

L19EA               leax      >u0124,u            Point to temp buffer
                    ldy       >u1813,u            Get ptr to current history buffer
                    clrb                          Set counter to 0 (size of buffer)
L19F4               lda       ,y+                 Get char from history buffer
                    beq       L1A00               Found end, continue
                    sta       ,x+                 Put it in temp buffer
                    incb                          Bump up size counter
                    lbsr      L1A97               Wrap buffer ptr if we hit end of all history
                    bra       L19F4               Continue copying into temp buffer
L1A00               clra                          D=Size of history buffer
                    decb
                    tfr       d,y                 Move to proper register
                    leax      >u0124,u            Point to buffer history copy
                    ldb       #SS.Fill            Fill it with current selected history command
                    os9       I$SetStt
                    rts

* Successfull SS.Fill of history buffer goes here
L1A0E               lda       #$01                Write copy of history buffer to std out
                    os9       I$Write
                    leax      >u0124,u            Point to current history buffer again
                    tfr       y,d                 Transfer # bytes written to D
                    lda       #C$BSP              Backspace char
L1A1B               sta       ,x+                 Fill buffer with backspaces
                    decb
                    bne       L1A1B
                    leax      >u0124,u            Write them to reset cursor to start of line
                    lda       #$01
                    os9       I$Write
                    ldd       #SS.Relea           Eat keyboard signal (SS.Fill cleared it out of
                    os9       I$SetStt            the read buffer already)
                    ldb       #SS.SSig            Setup for re-enabling it
                    ldx       #$000B              Signal Code to send on keypress=$B
                    lbra      L016A               Go re-enable signal send on keyboard/mouse input

* Put new entry into history buffers, adjusting # used, etc.)
* Entry: Y=# bytes read in ReadLn <>1
L1A37               pshs      y                   Preserve # bytes read
                    tfr       y,d                 Move to D reg
                    ldy       >u1808,u            Get ptr to where next history entry will go
                    leax      >u0124,u            Point to line entered by user
L1A44               lda       ,x+                 Get char
                    cmpa      #C$CR               Control char <$0d?
                    bhs       L1A4C               No, save the character
                    lda       #C$SPAC             Replace with space char if it is
L1A4C               sta       ,y+                 Save char into history buffer
                    bsr       L1A97               Wrap to beginning if we hit end
                    cmpy      >u180A,u            Point to entry #1?
                    bne       L1A59               No, continue
                    bsr       L1A7B               Yes, make new #1 entry & drop # of entries
L1A59               decb                          Drop # bytes left in new entry
                    bne       L1A44               Not done, continue
                    clr       ,y+                 mark end with NUL
                    bsr       L1A97               Wrap to beginning if at end
                    cmpy      >u180A,u            Pointing to entry #1?
                    bne       L1A69               No, skip ahead
                    bsr       L1A7B               Yes, make new #1 entry & drop # of entries
L1A69               inc       >u180C,u            Increase # of entries
                    sty       >u1808,u            Save ptr to where next history entry will go
                    puls      y                   Restore # bytes read
                    clra                          Point to temp buffer again
                    leax      >u0124,u
                    bra       L1AA3               Normal parse, no error

* Reset ptr to new 1st entry in history buffer
L1A7B               pshs      y                   Preserve current location in history buffer
                    ldy       >u180A,u            Point to start of 1st entry
L1A82               tst       ,y+                 End of current entry?
                    beq       L1A8A               Yes, skip ahead
                    bsr       L1A97               No, wrap if we need to
                    bra       L1A82               Keep going until we find end
L1A8A               bsr       L1A97               Wrap if we need to
                    dec       >u180C,u            Dec # lines in history buffer
                    sty       >u180A,u            Save new 'start of history' ptr
                    puls      pc,y                Restore current location & return
* If we are at end of history buffers, wrap to beginning (raw, has nothing to
*   do with entry #'s)
L1A97               cmpy      >u1806,u            Are we at end of buffer for history entries?
                    bne       L1AA2               No, continue on
                    leay      >u1815,u            Yes, reset to beginning of history buffers
L1AA2               rts

L1AA3               bsr       L1AB1               Reset std paths to normal <CTRL>-<E>/<C> settings
                    andcc     #^Carry             No error
                    lbra      L018B               Normal command processing

L1AAA               bsr       L1AB1               Reset std paths to normal <CTRL>-<E>/<C> settings
                    orcc      #Carry              Error
                    lbra      L018B               Normal command processing

* Reset all 3 standard paths' NUL counts/Keyboard Interrupt/Terminate settings
L1AB1               pshs      x,d                 Preserve regs
                    tst       >u1812,u            Check flag
                    beq       L1AD6               If 0 skip ahead
                    leas      <-PD.OPT,s          Make 32 byte buffer on stack
                    leax      ,s                  Point X to buffer
                    clrb                          CHANGE TO CLRB
                    clra                          Standard input path
                    bsr       L1AD8               Restore NUL counts, Keyboard Intrpt/Terminate
                    lda       #$01                Do same for Standard output path
                    bsr       L1AD8
                    lda       #$02                Do same for Standard Error path
                    bsr       L1AD8
                    leas      <PD.OPT,s           Eat stack buffer
                    clr       >u1812,u            Reset PD.OPT flags to 0
                    clr       >u180D,u
L1AD6               puls      pc,x,d              Restore regs & return

* Restore path options to preserved Keyboard terminate/interrupt & end of
* line NUL counts
L1AD8               pshs      a                   Preserve path #
                    os9       I$GetStt            Get current PD.OPT settings
                    lda       >u180E,u            Get copy of Keyboard terminate char
                    sta       <PD.QUT-PD.OPT,x    Save into buffered copy
                    lda       >u180F,u            Get copy of Keyboard interrupt char
                    sta       <PD.INT-PD.OPT,x    Save into buffered copy
                    lda       >u1811,u            Get copy of end of line NUL count
                    sta       $6,x                Save into buffered copy
                    puls      a                   Get path # back
                    os9       I$SetStt            Reset path options with restored values & return
                    rts

                    emod
eom                 equ       *
                    end

