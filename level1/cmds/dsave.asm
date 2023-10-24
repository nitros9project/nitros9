********************************************************************
* dsave - Multi-file copy utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/01/11  Boisy G. Pitre
* Rewrote in assembly language.
*
*   1r1    2003/12/11  Boisy G. Pitre
* Fixed -b option so that it prepends device name in front of os9boot
* filename.  Also fixed -b= option to work as well.
*
*   2r0    2005/11/26  Boisy G. Pitre
* Added -t and -n options, ala OS-9/68K.

                    nam       dsave
                    ttl       Multi-file copy utility

                    ifp1
                    use       defsfile
                    endc

* Here are some tweakable options
DOHELP              set       0                   1 = include help info
INDENTSZ            set       2                   number of spaces to indent when -i is used
STACKSZ             set       1024                estimated stack size in bytes
PARMSZ              set       256                 estimated parameter size in bytes

* Module header definitions
tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

* Your utility's static storage vars go here
                    org       0
* These vars are used by the base template and shouldn't be removed
parmptr             rmb       2                   pointer to our command line params
bufptr              rmb       2                   pointer to user expandable buffer
bufsiz              rmb       2                   size of user expandable buffer
* These vars are used for this example, it will probably change for you
dirlevel            rmb       1                   current directory level (0 = top)
*doexec   rmb   1	execute flag
errcode             rmb       1                   error code storage
plistcnt            rmb       1                   command line pathlist count
doboot              rmb       1
indent              rmb       1
onelevel            rmb       1
nomakdir            rmb       1
noload              rmb       1                   don't load copy/cmp
notmode             rmb       1
rewrite             rmb       1
cpymemsz            rmb       1
doverify            rmb       1
dstpath             rmb       2                   pointer to second (optional) pathlist on cmd line
lineptr             rmb       2
sopt                rmb       1
ddbt                rmb       3                   copy of source disk's DD.BT from LSN0
* vars for pwd integrated code
fildes              rmb       1
srcptr              rmb       2
dotdotfd            rmb       3                   LSN of ..
dotfd               rmb       3                   LSN of .
ddcopy              rmb       3
bbuff               rmb       64                  -b= buffer
dentry              rmb       DIR.SZ*2
srcpath             rmb       128
buffend             rmb       1
pathext             rmb       256                 extended part of source pathlist
devname             rmb       32
cleartop            equ       .                   everything up to here gets cleared at start
direntbf            rmb       DIR.SZ
* Next is a user adjustable buffer with # modifier on command line.
* Some utilities won't need this flexibility, some will.
* Currently set up to be larger for Level 2 than Level 1
* Note: this buffer must come just before the stack
linebuff            rmb       256
                    ifgt      Level-1
bigbuff             rmb       8*1024              8K default buffer for Level 2
                    else
bigbuff             rmb       512                 512 byte default buffer for Level 1
                    endc
* Finally the stack for any PSHS/PULS/BSR/LBSRs that we might do
                    rmb       STACKSZ+PARMSZ
size                equ       .

* The utility name and edition goes here
name                fcs       /dsave/
                    fcb       edition

* Place constant strings here
                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc

UnkOpt              fcc       /unknown option: /
UnkOptL             equ       *-UnkOpt

ShlEko              fcc       "t"
CR                  fcb       C$CR

Chd                 fcc       "chd"
                    fcb       C$CR

MakDir              fcc       "makdir"
                    fcb       C$CR

Cmp                 fcc       "cmp"
                    fcb       C$CR

TMode               fcc       "tmode"
                    fcb       C$CR
TPause              fcc       ".1 pau=1"
                    fcb       C$CR
TNoPause            fcc       ".1 pau=0"
                    fcb       C$CR

Load                fcc       "load"
                    fcb       C$CR

Unlink              fcc       "unlink"
                    fcb       C$CR

Copy                fcc       "copy"
                    fcb       C$CR

OS9Gen              fcc       "os9gen"
                    fcb       C$CR

OS9Boot             fcs       "OS9Boot"

DotDot              fcc       "."
Dot                 fcc       "."
                    fcb       C$CR

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
                    leax      cleartop,u          point to end of area to zero out
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
                    subd      #STACKSZ+PARMSZ     subtract out our stack/param size
                    std       <bufsiz             size of our buffer

* At this point we have determined our buffer space and saved pointers
* for later use.  Now we will parse the command line for options that
* begin with a dash.
* Note that X will NOT point to a space, but to either a CR (if no
* parameters were passed) or the first non-space character of the
* parameter.
* Here we merely grab the byte at X into A and test for end of line,
* exiting if so.  Utilities that don't require arguments should
* comment out the following three lines.
                    lda       ,x                  get first char
                    cmpa      #C$CR               CR?
                    lbeq      ShowHelp            if so, no parameters... show help and exit
GetChar             lda       ,x+                 get next character on cmd line
                    cmpa      #C$CR               CR?
                    lbeq      DoDSave             if so, do whatever this utility does
                    cmpa      #'-                 is it an option?
                    beq       GetDash             if so, process it
                    inc       <plistcnt           else must be a non-option argument (file)
                    lbsr      SkipNSpc            move past the argument
ChkDash             lbsr      SkipSpcs            and any following spaces
                    bra       GetChar             start processing again
GetDash             lda       #C$SPAC             get a space char
                    sta       -1,x                and wipe out the dash from the cmd line
GetDash2            ldd       ,x+                 load option char and char following
                    ora       #$20                make lowercase
IsItB               cmpa      #'b                 is it this option?
                    bne       IsItE               branch if not
                    sta       <doboot
                    pshs      x                   save for later
                    cmpb      #'=                 = follows?
                    beq       DoEqual
* -b alone, copy default bootfile name to bbuff
* first, get device name
                    lda       #DIR.+READ.
                    leax      dot,pcr
                    os9       I$Open
                    lbcs      Exit
                    leax      >bbuff,u
                    ldb       #PDELIM
                    stb       ,x+
                    ldb       #SS.DevNm
                    os9       I$GetStt
                    lbcs      Exit
                    os9       I$Close
                    os9       F$PrsNam
                    lbcs      Exit
                    lda       -1,y
                    anda      #$7F                wipe out hi bit
                    sta       -1,y
                    lda       #PDELIM
                    sta       ,y+
                    leax      OS9Boot,pcr
                    lbsr      StrCpy
                    lda       #C$CR
                    sta       ,y
                    bra       IsItBEx
DoEqual             leax      1,x                 move X past '='
                    leay      bbuff,u             point to buffer
                    lbsr      ParmCpy             copy parameter from X to Y
                    lda       #C$CR
                    sta       ,y
                    lda       #C$SPAC
IsItBLp             sta       ,-x
                    cmpx      ,s
                    bne       IsItBLp
                    clrb                          so FixCmdLn will not look for more opts
IsItBEx             puls      x
                    bra       FixCmdLn
IsItE               equ       *
*         cmpa  #'e		is it this option?
*         bne   IsItI		branch if not
*         sta   <doexec
*         bra   FixCmdLn
IsItI               cmpa      #'i                 is it this option?
                    bne       IsItL               branch if not
                    sta       <indent
                    bra       FixCmdLn
IsItL               cmpa      #'l                 is it this option?
                    bne       IsItM               branch if not
                    sta       <onelevel
                    bra       FixCmdLn
IsItM               cmpa      #'m                 is it this option?
                    bne       IsItR               branch if not
                    sta       <nomakdir
                    bra       FixCmdLn
IsItR               cmpa      #'r                 is it this option?
                    bne       IsItT               branch if not
                    sta       <rewrite
                    bra       FixCmdLn
IsItT               cmpa      #'t                 is it this option?
                    bne       IsItN               branch if not
                    sta       <notmode
                    bra       FixCmdLn
IsItN               cmpa      #'n                 is it this option?
                    bne       IsItS               branch if not
                    sta       <noload
                    bra       FixCmdLn
IsItS               cmpa      #'s                 is it this option?
                    bne       IsItV               branch if not
* add code to parse memsize
                    pshs      x
                    lbsr      ASC2Byte
                    stb       <sopt
                    lda       #C$SPAC
SpcNext             sta       ,-x                 erase everything after -s
                    cmpx      ,s
                    bne       SpcNext
                    puls      x
                    clrb
                    bra       FixCmdLn
IsItV               cmpa      #'v                 is it this option?
                    bne       BadOpt              branch if not
                    sta       <doverify
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
DoDSave             dec       <plistcnt           we should have only one path on cmdline
                    lbne      ShowHelp            if not, exit with error
                    ldx       <parmptr            get our parameter pointer off stack
                    lbsr      SkipSpcs            skip any leading spaces
                    stx       <dstpath            save dest path
                    lbsr      SkipNSpc
                    lda       #C$CR
                    sta       ,x+

* Here we have src and possibly destination pathlist.  Now we can
* start processing the dsave
                    leax      linebuff,u
                    stx       <lineptr            reset line buffer pointer

* Get entire pathlist to working directory
                    lbsr      pwd
* Open source device as raw and obtain 24 bit LSN to bootfile
*         ldd   #$400D		@ + CR
*         pshs  d		save on stack
*         leax  ,s		point X to stack
*         lda   #READ.		read mode
*         os9   I$Open		open
*         puls  x		clean stack
*         lbcs  Exit		branch if error
*         pshs  a		save path
*         ldx   #0000
*         tfr   u,y
*         ldu   #DD.BT
*         os9   I$Seek		seek to DD.BT in LSN0
*         tfr   y,u
*         lbcs  Exit
*         leax  ddbt,u		point to buffer
*         ldy   #3		read 3 bytes at DD.BT
*         os9   I$Read
*         lbcs  Exit		exit of error
*         puls  a		get path on stack
*         os9   I$Close		and close it

* Do dsave "pre" commands
                    lbsr      DoEcho
                    ldx       <dstpath            point to source path
                    lbsr      DoChd               chd to it
                    lbsr      DoPauseOff
                    lbsr      DoLoadCopy
                    tst       <doverify
                    beq       PreRecurse
                    lbsr      DoLoadCmp

* Steps in processing files:
*    0. Open path to '.'
*    1. Read next directory entry
*    2. if directory encountered:
*       a. chd entry
*       b. bsr step 0
*       c. chd ..
*    3. if eof, goto step 6
*    4. copy file to dest
*    5. goto 1
*    6. Close path to source dir

PreRecurse
                    leay      buffend,u
                    bsr       CopyDir

* Do dsave "post" commands
                    tst       <doverify
                    beq       PostRecurse
                    lbsr      DoUnlinkCmp
PostRecurse
                    lbsr      DoUnlinkCopy
                    lbsr      DoPauseOn

                    lbra      ExitOk

CopyDir             ldx       <srcptr
                    lda       #DIR.+READ.         permissions as DIR.
                    os9       I$Open              open directory
                    lbcs      CopyRts             branch if error
                    ldb       #PDELIM
                    stb       ,y+
                    pshs      y
                    pshs      a                   save path to .
                    pshs      x,u                 save regs
                    ldx       #$0000
                    ldu       #DIR.SZ*2           seek past two dir entries
                    os9       I$Seek              skip over . and .. entries of this dir
                    puls      x,u                 get saved regs
                    bcs       Copy2Ex             branch if error
FileLoop            lda       ,s                  get path to . on stack
                    ldy       #DIR.SZ             get size of directory entry
                    leax      direntbf,u          point to directory entry buffer
                    os9       I$Read              read directory entry
                    bcs       Copy2Ex             branch if error
                    tst       ,x                  first byte at x...  is it zero?
                    beq       FileLoop            yep, empty dir entry
                    ldy       1,s                 get Y on stack
                    lbsr      StrCpy
                    lda       #C$CR
                    sta       ,y
                    ldx       <srcptr
                    lda       #DIR.+READ.         open as directory
                    os9       I$Open              open it
                    bcs       ItsAFile            if error, it's not a dir
                    os9       I$Close             close it
* Here, we know that the file we just opened and closed was a directory
ItsADir
                    tst       <onelevel           do we ignore dirs?
                    bne       FileLoop            branch if so
                    pshs      y
                    ldx       3,s
                    lbsr      DoMakDir            makdir it
                    bcc       ItsADir2
                    os9       F$PErr
ItsADir2            ldx       3,s
                    lbsr      DoChd
                    bcs       FileLoop            if error, ignore dir
                    inc       <dirlevel
                    puls      y
                    bsr       CopyDir
                    leax      DotDot,pcr
                    lbsr      DoChd
                    dec       <dirlevel
                    bra       FileLoop

* Here, we know that the file we just opened and closed was NOT a directory
ItsAFile            tst       <dirlevel           are we at root level?
                    bne       ItsAFile2           no, don't even do os9boot test
                    ldx       1,s                 else get ptr to current filename
                    lbsr      BootCmp             is it os9boot?
                    bcs       ItsAFile2           no, copy away!
                    tst       <doboot             -b option specified?
                    beq       FileLoop            nope, ignore bootfile

* Here we have a file named OS9Boot in the top level directory
* We must os9gen the sucker
                    lbsr      BuildOS9Gen
                    bra       FileLoop

ItsAFile2
                    ldx       1,s
                    lbsr      BuildCopy
                    tst       <doverify           verify on?
                    beq       FileLoop            branch if not
                    ldx       1,s
                    lbsr      BuildCmp
                    bra       FileLoop
Copy2Ex             puls      a                   get path to .
                    os9       I$Close             close path
CopyEx              leas      2,s
CopyRts             rts

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #INDENTSZ           std error
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
                    cmpa      #C$CR
                    beq       StrLenEx
                    leay      1,y
                    bra       StrLenLp
StrLenEx            puls      a,pc

* This routine copies a string of text from X to Y until
* a CR or hi bit char is encountered
*
* Entry:
*   X = ptr to src string
*   Y = ptr to dest string
* Exit:
*   D = number of bytes copied
*   X = ptr to char past src string
*   Y = ptr to char past dest string
StrCpy              pshs      u
                    ldu       #$0000
CopyFnLp            lda       ,x+
                    tfr       a,b
                    anda      #$7F
                    cmpa      #C$CR
                    ble       CopyFnEx
                    sta       ,y+
                    leau      1,u
                    tstb
                    bpl       CopyFnLp
CopyFnEx            tfr       u,d
                    puls      u,pc

* Works like StrCpy, but stops if a space is encountered
ParmCpy             pshs      u
                    ldu       #$0000
ParmFnLp            lda       ,x+
                    tfr       a,b
                    anda      #$7F
                    cmpa      #C$SPAC
                    ble       ParmFnEx
                    sta       ,y+
                    leau      1,u
                    tstb
                    bpl       ParmFnLp
ParmFnEx            tfr       u,d
                    puls      u,pc

* Compare two filenames to see if they match
* X = filename to compare against OS9boot
BootCmp             pshs      y,x
                    lbsr      StrLen              get length of passed filename
                    puls      x                   get pointer to passed filename
                    tfr       y,d
                    leay      OS9Boot,pcr
                    os9       F$CmpNam
                    puls      y,pc

MakeUp              cmpa      #'a
                    blt       MakeUpEx
                    cmpa      #'z
                    bgt       MakeUpEx
                    anda      #$DF                make uppercase
MakeUpEx            rts

StrHCpy             pshs      u
                    ldu       #$0000
HCpyFnLp            lda       ,x+
                    beq       HCpyFnEx
                    tfr       a,b
                    anda      #$7F                strip out possible hi bit
                    sta       ,y+
                    leau      1,u
                    tstb                          test copy of byte in B
                    bpl       HCpyFnLp            if hi bit not set, keep going
*         clr   ,y+		add null byte at end
HCpyFnEx            tfr       u,d
                    puls      u,pc

* This routine skip over spaces
*
* Entry:
*   X = ptr to data to parse
* Exit:
*   X = ptr to first non-whitespace char
*   A = non-whitespace char
SkipSpcs            lda       ,x+
                    cmpa      #C$SPAC
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
                    cmpa      #C$CR
                    bne       SkipNSpc
EatOut              leax      -1,x
                    rts


* Entry: X = directory to make
DoMakDir
                    tst       <nomakdir           do we do the makdir?
                    bne       Ret                 branch if not
                    pshs      x
                    leax      MakDir,pcr
                    bsr       CopyCmd
                    ldx       ,s
                    bsr       CopyParm
                    bsr       WriteIt
                    puls      x
*         tst   <doexec			are we executing?
*         beq   Ret			if not, just return
*         lda   #DIR.+PREAD.+PEXEC.+EXEC.+UPDAT.
*         os9   I$MakDir
                    rts

* Entry: X = path to chd to
DoChd
                    pshs      x
                    leax      Chd,pcr
                    bsr       CopyCmd
                    ldx       ,s
                    bsr       CopyParm
                    bsr       WriteIt
                    puls      x
*         tst   <doexec			are we executing?
*         beq   Ret			if not, just return
*         lda   #DIR.+READ.
*         os9   I$ChgDir
*         bcc   Ret
*         os9   F$PErr
Ret                 rts

WriteIt             ldy       #1024
                    lda       #1
                    os9       I$WritLn
Rts                 rts

DoEcho              equ       *
*         tst   <doexec			are we executing?
*         bne   Rts			if so, ignore this shell command
                    leax      ShlEko,pcr          else point to shell echo command
                    bra       WriteIt

* Copy command into linebuff and put space after it
* Entry: X = pointer to command to copy to linebuff
CopyCmd             leay      linebuff,u          and point Y to line buffer
* Do level indention if specified
                    tst       <indent
                    beq       CopyCmd3
                    lda       <dirlevel
                    beq       CopyCmd3
                    ldb       #$02
                    mul
                    lda       #C$SPAC
CopyCmd2            sta       ,y+
                    decb
                    bne       CopyCmd2
CopyCmd3            lbsr      StrCpy              copy command
                    lda       #C$SPAC             get space
                    sta       ,y+                 and store it after command in buff
                    rts

DoPauseOn
                    tst       <notmode            do we do the tmode?
                    bne       CPRts
                    leax      TMode,pcr
                    bsr       CopyCmd
                    leax      TPause,pcr          get pause command
                    bsr       CopyParm
                    bra       WriteIt
*         bra   ExecCmd

* Copy parameters into linebuff and put CR after it, then write it out to stdout
CopyParm            lbsr      StrCpy              copy it
                    lda       #C$CR
                    sta       ,y+                 and store CR after command in buff
                    leax      linebuff,u
CPRts               rts

* Entry: X = command to execute, with parameters
*ExecCmd  tst   <doexec
*         beq   CPRts
*         lbsr  SkipSpcs		skip any leading spaces at X
*         tfr   x,y		transfer command ptr to Y temporarily
*         lbsr  SkipNSpc		skip command
*         clr   ,x+		clear white space char and move X
*         pshs  u		save our statics
*         tfr   x,u		move paramter pointer to Y
*         tfr   y,x		move command ptr from Y back to X
*         ldy   #256
*         clra
*         os9   F$Fork
*         os9   F$Wait
*         bcc   ExecRTS
*         os9   F$PErr
*ExecRTS  puls  u,pc

DoPauseOff
                    tst       <notmode            do we do the tmode?
                    bne       CPRts
                    leax      TMode,pcr
                    bsr       CopyCmd
                    leax      TNoPause,pcr
                    bsr       CopyParm
                    lbra      WriteIt
*         bra   ExecCmd

DoLoadCmp
                    tst       <noload             do we load the utility?
                    bne       CPRts
                    leax      Load,pcr            point to load command
                    bsr       CopyCmd             copy it to buffer
                    leax      Cmp,pcr             point to copy command
                    bsr       CopyParm            copy it to buffer
                    lbra      WriteIt
*         bra   ExecCmd

DoUnlinkCmp
                    tst       <noload             do we load the utility?
                    bne       CPRts
                    leax      Unlink,pcr
                    lbsr      CopyCmd
                    leax      Cmp,pcr
                    bsr       CopyParm
                    lbra      WriteIt
*         bra   ExecCmd

DoLoadCopy
                    tst       <noload             do we load the utility?
                    bne       CPRts
                    leax      Load,pcr            point to load command
                    lbsr      CopyCmd             copy it to buffer
                    leax      Copy,pcr            point to copy command
                    bsr       CopyParm            copy it to buffer
                    lbra      WriteIt
*         bra   ExecCmd

DoUnlinkCopy
                    tst       <noload             do we load the utility?
                    bne       CPRts
                    leax      Unlink,pcr
                    lbsr      CopyCmd
                    leax      Copy,pcr
                    lbsr      CopyParm
                    lbra      WriteIt
*         bra   ExecCmd

BuildOS9Gen
                    pshs      x
                    leax      OS9Gen,pcr
                    lbsr      CopyCmd
                    ldx       <dstpath
                    lbsr      StrCpy              copy to buffer
* write file name, then CR
                    lda       #C$CR               get space
                    sta       ,y+                 and store it after command in buff
                    leax      linebuff,u
                    lbsr      WriteIt
                    leax      bbuff,u
                    lbsr      WriteIt
                    leax      CR,pc
                    lbsr      WriteIt
                    puls      x,pc

BuildCmp            pshs      x
                    leax      Cmp,pcr
                    lbsr      CopyCmd
                    bra       BuildCopy3

BuildCopy
                    pshs      x
                    leax      Copy,pcr
                    lbsr      CopyCmd
                    ldb       <sopt               -s option specified?
                    beq       BuildCopy2
                    lda       #'#
                    sta       ,y+
                    lbsr      Byte2ASC
                    ldd       #$4B20              K'space'
                    std       ,y++
BuildCopy2
                    tst       <rewrite
                    beq       BuildCopy3
                    ldd       #$2D72              -r
                    std       ,y++
                    lda       #C$SPAC
                    sta       ,y+
BuildCopy3
                    ldx       <srcptr             get source path from statics
                    lbsr      StrCpy              copy to buffer
                    lda       #C$SPAC             get space
                    sta       ,y+                 and store it after command in buff
                    puls      x
                    lbsr      StrCpy
                    lda       #C$CR               get space
                    sta       ,y+                 and store it after command in buff
                    leax      linebuff,u
                    lbra      WriteIt
*         lbsr  ExecCmd
*         rts

* Code to get current working directory
pwd                 leax      >buffend,u          point X to buffer
*         lda   #PDELIM			get path delimiter
*         sta   ,x			store at start of buffer
                    stx       <srcptr             store buffer pointer
                    leax      >dot,pcr            point to '.'
                    bsr       open                open directory
                    sta       <fildes             save path
                    lbsr      rdtwo               read '.' and '..' entries
                    ldd       <dotdotfd           get 24 bit LSN of ..
                    std       <ddcopy
                    lda       <dotdotfd+2
                    sta       <ddcopy+2           and save copy
L0052               bsr       AtRoot              are we at root?
                    beq       L0079               branch if so
                    leax      >dotdot,pcr         else point to '..'
                    bsr       chdir               change directory
                    lda       <fildes             get path to previous dir
                    os9       I$Close             close it
                    lbcs      Exit                branch if error
                    leax      >dot,pcr            point X to new current dir
                    bsr       open                open it
                    bsr       rdtwo               read . and .. entires of this dir
                    bsr       FindMtch            search for match
                    bsr       L00E2
                    ldd       <dotdotfd
                    std       <ddcopy
                    lda       <dotdotfd+2
                    sta       <ddcopy+2
                    bra       L0052
L0079               lbsr      GetDevNm            get device name
                    lda       <fildes             get path
                    os9       I$Close             close
                    rts

chdir               lda       #DIR.+READ.
                    os9       I$ChgDir
                    rts

open                lda       #DIR.+READ.
                    os9       I$Open
                    rts

* Read directory entry
read32              lda       <fildes
                    leax      dentry,u
                    ldy       #DIR.SZ
                    os9       I$Read
                    rts

FindMtch            lda       <fildes             get path to current dir
                    bsr       read32              read entry
                    lbcs      pwdrts              branch if error
                    leax      dentry,u            point to entry buffer
                    leax      <DIR.FD,x           point X to FD LSN
                    leay      ddcopy,u            point Y to copy of LSN
                    bsr       attop               compare the two
                    bne       FindMtch            keep reading until we find match
                    rts

* Compare 3 bytes at X and Y
attop               ldd       ,x++
                    cmpd      ,y++
                    bne       L00C5
                    lda       ,x
                    cmpa      ,y
L00C5               rts

AtRoot              leax      dotdotfd,u          point X at .. entry
                    leay      dotfd,u             point Y at . entry
                    bsr       attop               check if we're at the top
pwdrts              rts

rdtwo               bsr       read32              * read "." from directory
                    ldd       <dentry+DIR.FD
                    std       <dotfd
                    lda       <dentry+DIR.FD+2
                    sta       <dotfd+2
                    bsr       read32              * read ".." from directory
                    ldd       <dentry+DIR.FD
                    std       <dotdotfd
                    lda       <dentry+DIR.FD+2
                    sta       <dotdotfd+2
                    rts

* Get name from directory entry
L00E2               leax      dentry,u
prsnam              os9       F$PrsNam
                    lbcs      pwdrts
                    ldx       <srcptr
L00EB               lda       ,-y
                    anda      #$7F                mask hi bit
                    sta       ,-x                 save
                    decb
                    bne       L00EB
                    lda       #PDELIM
                    sta       ,-x
                    stx       <srcptr
                    rts

GetDevNm            lda       <fildes
                    ldb       #SS.DevNm
                    leax      >devname,u
                    os9       I$GetStt
                    bsr       prsnam
                    rts


* Entry: X = ptr to ASCII number
* Exit: B = byte value of ASCII number
ASC2Byte            clrb                          clear B
ASC2BLp             lda       ,x+                 get byte from X
                    cmpa      #'0
                    blt       ASC2BEx
                    suba      #'0                 make 8 bit integer
                    cmpa      #$09                compare against 9
                    bhi       ASC2BEx             branch if greater
                    pshs      a                   else save A
                    lda       #10                 multiply by 10
                    mul                           do it
                    addb      ,s+                 add on stack
                    bcc       ASC2BLp             if overflow clear, do it again
ASC2BEx
*  leax  -1,x		load byte
                    rts                           return

* Entry: Y = address to store number
*        B = number to convert
Byte2ASC            lda       #$2F                start A out just below $30 (0)
Hundreds            inca                          inc it
                    subb      #100                subtract 100
                    bcc       Hundreds            if result >= 0, continue
                    cmpa      #'0                 zero?
                    beq       Tens                if so, don't add to buffer
                    sta       ,y+                 else save at U and inc.
Tens                lda       #$3A                start A out just above $39 (9)
TensLoop            deca                          dec it
                    addb      #10                 add 10
                    bcc       TensLoop            if carry clear, continue
                    sta       ,y+                 save 10's digit
                    addb      #'0
                    stb       ,y+                 and 1's digit
                    rts

                    emod
eom                 equ       *
                    end
