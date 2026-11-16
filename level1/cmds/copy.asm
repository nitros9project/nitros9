********************************************************************
* Copy - File copy utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   9      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*  10      ????/??/??  Ron Lammardo
* Reworked.
*
*  11      2003/01/11  Boisy G. Pitre
* Added useful options, made more robust.
*
*  12      2026/11/16  Mark Murray
* Added -d to copy a directory and everything in it.

;;; copy
;;;
;;; Syntax: copy <path1> <path2> [-s]
;;; Function: Copy a file from one location to another.
;;; Parameters:
;;;      pathlist1    The pathlist of the file to copy.
;;;      pathlist2    The destination pathlist of the copied file.
;;;
;;; Notes
;;;
;;; This command copies data from the first file or device specified to the second. The
;;; first file or device must already exist, the second file is automatically created if
;;; the second path is a file on a mass storage device. Data may be of any type and is NOT
;;; modified in any way as it is copied.
;;;
;;; Data is transferred using large block reads and writes until end-of-file occurs on
;;; the input path. Because block transfers are used, normal output processing of data
;;; doesn't occur on character-oriented devices such as terminals, printers, etc.
;;; Therefore, the `list` command is preferred over `copy` when a file consisting of text is
;;; to be sent to a terminal or printer.
;;;
;;; The -s option causes `copy` to perform a single drive copy operation. The second
;;; pathlist must be a full pathlist if using -s. `copy` reads a portion of the source
;;; disk into memory; you remove the source disk and place the destination disk into the
;;; drive, enter a "C" whereupon `copy` writes on the destination disk. This process
;;; continues until the entire file is copied.
;;; Use the shell’s alternate memory size modifier to give a large memory space to
;;; increase speed and reduce the number of media exchanges required for single drive copies.
;;;
;;; Examples
;;;
;;; To copy a file using 15K of buffer space:
;;;
;;;      `copy file1 file2 #15k`
;;;
;;; To copy a file named `news` to a file named `messages`:
;;;
;;;      `copy /d1/joe/news /D0/peter/messages`
;;;
;; To copy the console to the printer:
;;;
;;;      `copy /term /p`
;;;
;;; To copy a file from a disk on the same drive to another disk:
;;;
;;;      ```copy /d0/cat /d0/animals/cat -s #32k
;;;      Ready DESTINATION, hit C to continue: c
;;;      Ready SOURCE, hit C to continue: c
;;;      Ready DESTINATION, hit C to continue:c```

                    nam       Copy
                    ttl       File copy utility

                    ifp1
                    use       defsfile
                    use       readdir.d
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

STACKSZ             equ       128                 estimated stack size
PARMSZ              equ       256                 estimated parameter size
DDIRBSIZ            equ       64                  destination directory buffer size
PATHMAX             equ       256                 longest pathlist -d builds
TREESTK             equ       640                 stack the -d tree walk takes from the copy buffer
TREEMRG             equ       128                 stack a level needs below its frame
FRAMESZ             equ       9                   bytes of stack TreeLevel keeps for each level

                    org       0
rdbufptr            rmb       2
parmptr             rmb       2
srcpath             rmb       1
dstpath             rmb       1
devtyp              rmb       1
bufsiz              rmb       2
srcflsiz            rmb       4
abortflg            rmb       1
quiet               rmb       1
single              rmb       1
rewrite             rmb       1
filecnt             rmb       1
srccnt              rmb       1
srcmode             rmb       1
wopt                rmb       1
vopt                rmb       1
srcfname            rmb       2
dstfptr             rmb       2
wfileptr            rmb       2
wfilelen            rmb       2
lstfopen            rmb       2                   pointer to name of last file attempted open
lstfopln            rmb       2                   length of last file atteppted open
srcattr             rmb       1
writemsb            rmb       2
writelsb            rmb       2
treeopt             rmb       1                   nonzero when -d was given
lasterr             rmb       1                   last error reported by -d
tattr               rmb       1                   attributes for the next directory made
cfsp                rmb       2                   stack pointer on entry to CopyFile
stklim              rmb       2                   lowest stack pointer the tree walk allows
srcend              rmb       2                   address of the carriage return ending srcbuf
dstend              rmb       2                   address of the carriage return ending dstbuf
argptr              rmb       2                   next command line argument for -d
wdirend             rmb       2                   end of the -w directory in wdest
fdbufcpy            rmb       16
optbuf              rmb       32
wdest               rmb       DDIRBSIZ            portion after '-w='
                    rmb       DDIRBSIZ            additional space
srcbuf              rmb       PATHMAX             source pathlist for -d
dstbuf              rmb       PATHMAX             destination pathlist for -d
record              rmb       RD.Size             directory entry for -d
* Note: copy buffer must come just before the stack
vfybuff             rmb       256                 verify buffer
                    ifgt      Level-1
copybuff            rmb       8*1024              8K default buffer for Level 2
                    else
copybuff            rmb       512+TREESTK         512 byte default buffer for Level 1, and room for -d
                    endc
                    rmb       STACKSZ+PARMSZ
size                equ       .

name                fcs       /Copy/
                    fcb       edition

SrcPmpt             fcc       /Ready SOURCE, hit C to continue: /
SrcPmptL            equ       *-SrcPmpt
DstPmpt             fcc       /Ready DESTINATION, hit C to continue: /
DstPmptL            equ       *-DstPmpt
CrRtn               fcb       C$CR
                    ifne      DOHELP
HlpMsg              fcb       C$LF
                    fcc       /Use: Copy [<opts>] <srcpath> [<dstpath>] [<opts>]/
                    fcb       C$LF
                    fcc       /  -a = abort on error/
                    fcb       C$LF
                    fcc       /  -d = copy directories and everything in them/
                    fcb       C$LF
                    fcc       /  -p = don't print files copied (use with -w)/
                    fcb       C$LF
                    fcc       /  -r = rewrite destination/
                    fcb       C$LF
                    fcc       /  -s = single drive copy/
                    fcb       C$LF
                    fcc       /  -v = verify the copy/
                    fcb       C$LF
                    fcc       /  -w=<dir> = copy to <dir>/
                    fcb       C$LF
                    fcc       /  -x = copy from exec dir/
                    fcb       C$CR
HlpMsgL             equ       *-HlpMsg
                    endc
PLIncmp             fcc       /copy: destination must be complete pathlist/
                    fcb       C$CR
TooMany             fcc       /copy: must specify output directory if more than 2 files/
                    fcb       C$CR
Copying             fcc       /copying /
CopyingL            equ       *-Copying
CopyTo              fcc       / to /
CopyToL             equ       *-CopyTo
Cont                fcc       !Continue (y/n) ?!
ContL               equ       *-Cont
CantCpy             fcc       /copy: can't open /
CantCpyL            equ       *-CantCpy
SpcDsh              fcc       / - /
SpcDshL             equ       *-SpcDsh

*   +-----------------+  <--  Y          (highest address)
*   !                 !
*   !   Parameter     !
*   !     Area        !
*   !                 !
*   +-----------------+  <-- X, SP
*   !                 !
*   !                 !
*   !   Data Area     !
*   !                 !
*   !                 !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined

start               pshs      u,x
                    leax      <wdest,u
                    pshs      x
clrnxt              clr       ,u+
                    cmpu      ,s
                    bne       clrnxt
                    leas      2,s
                    puls      x,u
                    leay      copybuff,u          point Y to copy buffer offset in U
                    stx       <parmptr            save parameter pointer
                    sty       <rdbufptr           save pointer to buffer
                    tfr       s,d                 place top of stack in D
                    pshs      y                   save Y on stack
                    subd      ,s++                get size of space between copybuf and X
                    subd      #STACKSZ+PARMSZ     subtract out our stack
                    std       <bufsiz             size of our buffer
                    lbsr      SkipSpcs            move past any spaces on command line
                    cmpa      #C$CR               CR?
                    lbeq      ShowHelp            if so, show help
GetNChr             lda       ,x+
                    cmpa      #C$CR               CR?
                    lbeq      CpyFiles            branch if so
                    cmpa      #'-                 option?
                    beq       GetDash
                    inc       <filecnt            must be a file
                    lbsr      SkipNSpc            else go past non-spaces
ChkDash             lbsr      SkipSpcs            and any following spaces
                    bra       GetNChr             and check for Cr
GetDash             lda       #C$SPAC
                    sta       -1,x
GetDash2            ldd       ,x+                 load option char and char following
                    anda      #$5F
                    cmpa      #'S                 single drive copy?
                    bne       IsItA               branch if not
                    inc       <single
                    lbra      FixCmdLn
IsItA               cmpa      #'A                 abort option?
                    bne       IsItD               branch if not
                    inc       <abortflg
                    lbra      FixCmdLn
IsItD               cmpa      #'D                 directory tree option?
                    bne       IsItP               branch if not
                    inc       <treeopt
                    lbra      FixCmdLn
IsItP               cmpa      #'P                 supress output?
                    bne       IsItV               branch if not
                    inc       <quiet
                    bra       FixCmdLn
IsItV               cmpa      #'V                 supress output?
                    bne       IsItX               branch if not
                    inc       <vopt
                    bra       FixCmdLn
IsItX               cmpa      #'X                 execution dir?
                    bne       IsItW               branch if not
                    lda       #EXEC.              else get EXEC.
                    sta       <srcmode            and save as source mode
                    bra       FixCmdLn
IsItW               cmpa      #'W                 directory specification?
                    bne       IsItR               branch if not
                    tst       <wopt               already specified?
                    bne       BadOpt              show help if so
                    cmpb      #'=                 2nd char =?
                    bne       BadOpt              show help if not
                    inc       <wopt               else tag wopt as specified
                    ldb       #C$SPAC             get space
                    stb       -$01,x              write over w
                    stb       ,x+                 and = sign, inc X to dest dir
* check for valid char after -w=
                    lda       ,x
                    cmpa      #C$SPAC
                    lbeq      ShowHelp
                    cmpa      #C$COMA
                    lbeq      ShowHelp
                    cmpa      #C$CR
                    lbeq      ShowHelp
                    leay      <wdest,u            point Y to parameber buffer
                    sty       <dstfptr            save pointer to destination file
                    tfr       y,d                 transfer Y to D
                    addd      #DDIRBSIZ           add size
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
                    lda       #PDELIM             get pathlist delimiter
                    sta       -$01,y              save slash at end (for building path later)
                    sty       <wfileptr           save pointer for -w pathlist file copying
                    leas      $02,s               kill stack
                    lbra      ChkDash
L035D               leas      $02,s
                    ldb       #$BF                else buffer size too small
                    orcc      #Carry
                    lbra      Exit
IsItR               cmpa      #'R                 rewrite?
                    bne       BadOpt              branch if not
                    inc       <rewrite
FixCmdLn            lda       #C$SPAC             get space
                    sta       -$01,x              and wipe out option character
                    cmpb      #'0
                    lblt      ChkDash             start dash option processing again
                    lbra      GetDash             possibly another option following?

BadOpt              puls      x
                    lbra      ShowHelp

CopyToW             ldx       <srcfname           get ptr to next file to process
* In case the source file name has a / in it (i.e. /dd/x/y/fname),
* we go past the file and then back up to either the first / we
* encounter, or a space (be sure we don't go past parmptr)
                    lda       ,x
                    cmpa      #C$CR               carriage return?
                    lbeq      ExitOk              yep, no more files
                    lbsr      SkipNSpc            skip over filename
* X points to first char after file name (space, comma or CR)
L038B               cmpx      <parmptr            are we at start of command line?
                    beq       PlugIt2             if so, we can't go further back
                    lda       ,-x                 get byte
                    cmpa      #PDELIM             path delimiter?
                    beq       PlugIt              branch if so
                    cmpa      #C$SPAC             space?
                    beq       PlugIt              branch if so
                    cmpa      #C$COMA             comma?
                    beq       PlugIt              branch if so
                    bra       L038B               else get next char
PlugIt              leax      1,x                 go forward 1
PlugIt2             ldy       <wfileptr           get address past xxxx/ (specified by -w=)
                    lbsr      StrCpy              copy filename
                    std       <wfilelen           save file length
                    lda       #C$CR               get CR
                    sta       ,y                  and terminate
*         ldx   <wopt
*         stx   <wfileptr
                    rts

* At this point options are processed, so we need to start copying files
CpyFiles            tst       <filecnt            we should have at least one file on cmdline
                    lbeq      ShowHelp            if not, exit with error
                    tst       <treeopt            -d specified?
                    lbne      TreeMain            branch if so
                    ldx       <parmptr            get our parameter pointer off stack
                    lbsr      SkipSpcs            skip any leading spaces
                    tst       <wopt               -w specified?
                    beq       L03C5               branch if not
                    stx       <srcfname           else save start of parameter pointer as next file
                    clr       <single             no single option with -w
L03BE               bsr       CopyToW             copy file at <srcfname to -w buffer
CopyNext            lbsr      CopyFile            copy one file
                    lbcs      ShutDown            report the error
                    tst       <wopt               -w specified?
                    lbeq      ExitOk              branch if not
                    bra       L03BE               copy the next file
* This code handles single file copy (i.e. copy file1 file2)
* or a single disk copy (i.e. copy -s abc)
L03C5               lbsr      GetSDFl             else get source/destination files
                    bcc       L03D4               branch if we got both ok
                    tst       <single             is this a single drive copy?
                    lbne      PListErr            if not, user didn't specify enough files
                    lbcs      Exit                if error, exit
* test for right number of files
L03D4               lda       <filecnt            get total file count
                    cmpa      #2                  should be no more than two files
                    ble       CopyNext
ShowTooMany         leax      TooMany,pcr
                    lbsr      WrLine
                    lbra      ExitOk
* Copy the file named at <srcfname to the one named at <dstfptr. Return
* with carry set and B=error on failure, with both paths closed.
CopyFile            sts       <cfsp               save the stack for an error return
                    ldd       #$0000
                    std       <writemsb           clear writemsb/lsb
                    std       <writelsb
                    ldx       <srcfname           get file to open
                    pshs      x
                    lbsr      StrLen              get length
                    std       <lstfopln           save length
                    puls      x
                    lda       #READ.              read mode
                    ora       <srcmode            or in any additional modes (i.e. EXEC.)
                    stx       <lstfopen           save pointer to last file open var
                    os9       I$Open              open source file
                    bcc       L03FA               branch if open ok
                    cmpx      <srcfname           did open go past pathlist?
                    bne       OpenFail            branch if so
                    lbsr      SkipNSpc            else skip over failed filename
                    lbsr      SkipSpcs            and any trailing spaces
OpenFail            stx       <srcfname           save updated pathlist pointer (points to next file on cmd line)
                    lbra      CFFail
L03FA               sta       <srcpath            save source path
                    pshs      a                   save path
                    lbsr      SkipSpcs            destroy any leading spaces
                    stx       <srcfname           and save pointer to next source filename
                    lbsr      StrLen              get length
                    std       <lstfopln           save length
                    puls      a                   get path off stack
                    leax      <fdbufcpy,u         point to FD buffer
                    ldy       #FD.SEG             number of bytes
                    ldb       #SS.FD
                    os9       I$GetStt            get file's file descriptor
                    bcs       L041B               branch if error
                    tst       <single             single drive copy?
                    beq       L041B               branch if not
                    lda       [<dstfptr,u]        get first char of destination filename
                    ldb       #E$BPNam            prepare for possible error
                    cmpa      #PDELIM             path has leading slash?
                    lbne      PListErr            if not, show error
L041B               lda       <srcpath            get source path
                    leax      <optbuf,u           point to options buffer
                    clrb                          was: ldb #SS.Opt
                    os9       I$GetStt            get path options
                    lbcs      CFFail            branch if error
                    lda       ,x                  get device type
                    sta       <devtyp             save
                    ldb       #READ.+WRITE.+EXEC.+PREAD.
                    cmpa      #DT.RBF             rbf device?
                    bne       L0449               branch if not
                    pshs      u,x                 save regs
                    lda       <srcpath            get source path
                    ldb       #SS.Size
                    os9       I$GetStt            get size
                    lbcs      CFFail
                    stx       <srcflsiz           save file size
                    stu       <srcflsiz+2
                    puls      u,x                 restore regs
                    ldb       <PD.ATT-PD.OPT,x    get source file's attributes
L0449               stb       <srcattr            save
                    lda       #$01
                    lbsr      SwapDsk             check for single disk copy and prompt if necessary
L0450               ldx       <dstfptr            point to destination file
                    pshs      x
                    lbsr      StrLen              get length
                    std       <lstfopln           save length
                    puls      x
                    lda       #UPDAT.             update mode (in case we have to verify)
                    ldb       <srcattr            get source attributes
                    stx       <lstfopen
                    os9       I$Create            create file
                    bcc       L048B               branch if create ok
                    tst       <rewrite            rewrite flag set?
                    lbeq      CFFail            branch if no
                    cmpb      #E$CEF              file already exists?
                    lbne      CFFail            branch if any other error
L047A               os9       I$Delete            delete file first
                    lbcs      CFFail            branch if error
                    bra       L0450               else try opening again
L048B               sta       <dstpath            save destination path
                    ldb       <wopt               w option specified?
                    orb       <treeopt            or d option?
                    beq       GetOpts             branch if neither
                    tst       <quiet              p option specified?
                    bne       GetOpts             branch if so
                    pshs      a                   else save dest path on stack
                    leax      >Copying,pcr        else print 'Copying...'
                    ldy       #CopyingL
                    lbsr      WritSOut            write it to stdout
                    ldx       <wfileptr           get pointer to file being copied
                    ldy       <wfilelen           get file name length
                    lbsr      WritSOut            print file name
                    leax      >CopyTo,pcr         print ' to '
                    ldy       #CopyToL
                    lbsr      WritSOut            write it to stdout
                    ldx       <dstfptr            get pointer to file being copied
                    lbsr      WrLine              print file with CR
                    puls      a                   restore dest path
GetOpts             leax      <optbuf,u           point to option buffer
                    clrb                          was: ldb #SS.Opt
                    os9       I$GetStt            get options
                    lbcs      CFFail            branch if error
                    ldb       ,x                  get device type
                    cmpb      #DT.RBF             rbf?
                    bne       CopyLoop            if not rbf device, don't get file size or fd seg
L04B4               lda       <devtyp             get device type
                    cmpa      #DT.RBF             rbf?
                    bne       CopyLoop            branch if not
                    pshs      u                   save our statics ptr
                    lda       <dstpath            else get dest path
                    ldb       #SS.Size            and setstat option
                    ldx       <srcflsiz           get file size of source
                    ldu       <srcflsiz+2
                    os9       I$SetStt            and set dest file to same size
                    lbcs      CFFail            branch if error
                    puls      u                   restore U
                    lda       <dstpath            get dest path
                    leax      <fdbufcpy,u         point to file desc. buffer
                    ldy       #FD.SEG             get size
                    ldb       #SS.FD
                    os9       I$SetStt            write src fd seg to dest file
* Copy loop is here
CopyLoop            ldx       <rdbufptr           get ptr to read buffer
                    clra                          A = 0 = source prompt if needed
                    lbsr      SwapDsk             check for single disk copy and prompt if so
                    lda       <srcpath            get source path
                    ldy       <bufsiz             get buffer size
                    os9       I$Read              read it!
                    bcs       L0558               branch if error
                    lda       #$01                A = 1 = dest prompt
                    lbsr      SwapDsk             check for single disk copy and prompt if so
                    lda       <dstpath            get dest path
                    os9       I$Write             write it out!
                    lbcs      CFFail            branch if error
                    tst       <vopt               verify on?
                    beq       chkeof
                    lbsr      DoVerify
chkeof              lda       <srcpath            get source path
                    ldb       #SS.EOF
                    os9       I$GetStt            are we at end of file?
                    bcc       CopyLoop            branch if not
                    cmpb      #E$EOF              end of file error?
                    beq       L0561               branch if so
L0558               cmpb      #E$EOF              end of file rror?
                    bne       CFFail            branch if not
                    lda       #$01                prompt destination flag
                    lbsr      SwapDsk             check for single drive copy and prompt if necessary
L0561               lda       <dstpath            get destination path
                    os9       I$Close             close that file
                    bcs       CFFail            branch if error
                    clr       <dstpath            else clear dest path
                    lda       <srcpath            get source path
                    os9       I$Close             close it
                    bcs       CFFail            branch if error
                    clr       <srcpath            clear src path
                    clrb                          no error
                    rts
CFFail              lds       <cfsp               discard whatever the copy left on the stack
                    pshs      b                   save the error
                    lda       <srcpath            get source path
                    beq       CFFail2             branch if none
                    os9       I$Close             close it
CFFail2             lda       <dstpath            get dest path
                    beq       CFFail3             branch if none
                    os9       I$Close             close it
CFFail3             clr       <srcpath            clear source path
                    clr       <dstpath            and destination
                    puls      b                   restore the error
                    orcc      #Carry              return it
                    rts

* Entry: X = ptr to data to write, Y = length
WritSOut            lda       #$01                standard out
                    os9       I$Write             write it
                    rts

PListErr            leax      >PLIncmp,pcr
                    bsr       WrLine
                    bra       ExitOk

ShutDown            bsr       ShowFail            report the failure
                    tst       <wopt               -w used?
                    beq       ExitOk              branch if not
                    tst       <abortflg           abort flag set?
                    bne       ExitOk              branch if so
AskAgain            leax      >Cont,pcr           point to continue prompt
                    ldy       #ContL              get length
                    bsr       WritSOut            write
                    clra                          ADDED +BGP+
                    ldx       <rdbufptr           get pointer at readbuf
                    ldy       #$0002              2 bytes
                    os9       I$ReadLn            read form stdin
                    lda       ,x                  get byte at X
                    anda      #$5F
                    cmpa      #'Y                 user wants to continue?
                    lbeq      L03BE               branch if so
                    cmpa      #'N                 no?
                    beq       ExitOk              branch if so
                    bra       AskAgain            else ask again

* B=error. Report it against the file named at <lstfopen.
ShowFail            pshs      b                   save the error
                    leax      >CantCpy,pcr        else show can't copy error
                    ldy       #CantCpyL
                    bsr       WritSOut            write out
                    ldx       <lstfopen           show filename that failed
                    ldy       <lstfopln           get length
                    bsr       WritSOut
                    leax      >SpcDsh,pcr
                    ldy       #SpcDshL
                    bsr       WritSOut            write out
                    puls      b                   restore the error
                    os9       F$PErr              print error
                    rts

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HlpMsg,pcr         point to help message
                    ldy       #HlpMsgL            get length
                    lda       #$02                std error
                    os9       I$WritLn            write it
                    endc
ExitOk              clrb                          clear carry
Exit                os9       F$Exit              and exit

* Write line passed in X
WrLine              ldy       #PATHMAX
WrNBytes            lda       #$01
                    os9       I$WritLn
                    rts

* Prompt User for Source or Destination Disk
SwapDsk             tst       <single             single disk copy?
                    beq       NoSwap              branch if not
                    pshs      y,x
L0626               pshs      a
                    tsta
                    bne       L0635
                    leax      >SrcPmpt,pcr        point to source prompt
                    ldy       #SrcPmptL           get size
                    bra       L063D               write it and get input
L0635               leax      >DstPmpt,pcr        point to dest prompt
                    ldy       #DstPmptL           get size
L063D               bsr       WrNBytes            write it
                    leax      ,-s                 point to stack for temp buffer
                    ldy       #$0001              one byte
                    clra                          from std in
                    os9       I$Read              read byte from user
                    lda       ,s+                 get char
                    eora      #'C
                    anda      #$DF
                    beq       L0657               branch if C
                    bsr       L065E
                    puls      a
                    bne       L0626
L0657               bsr       L065E
                    puls      a
                    puls      y,x
NoSwap              rts
L065E               pshs      y,x,a
                    lda       #$01
                    leax      >CrRtn,pcr
                    ldy       #80
                    os9       I$WritLn
                    puls      pc,y,x,a

* StrLen
*
* Entry:
*   X = ptr to string (space, comma or CR terminated)
* Exit:
*   D = length of string
*   X = ptr to byte after string
StrLen              pshs      u
                    ldu       #$0000
StrLenLp            lda       ,x+
                    cmpa      #C$SPAC
                    beq       StrLenEx
                    cmpa      #C$COMA
                    beq       StrLenEx
                    cmpa      #C$CR
                    beq       StrLenEx
                    leau      1,u
                    bra       StrLenLp
StrLenEx            tfr       u,d
                    puls      u,pc

* StrCpy
*
* Entry:
*   X = ptr to src string
*   Y = ptr to dest string
* Exit:
*   D = number of bytes copied
*   X = ptr to byte after original string
*   X = ptr to byte after copied string
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

* Skip over spaces and commas
*
* Entry:
*   X = ptr to string
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

* Skip over non-spaces and non-commas
*
* Entry:
*   X = ptr to string
* Exit:
*   X = ptr to first non-whitespace char
*   A = non-whitespace char
SkipNSpc            lda       ,x+
                    cmpa      #C$SPAC
                    beq       EatOut
                    cmpa      #C$COMA
                    beq       EatOut
                    cmpa      #C$CR
                    bne       SkipNSpc
EatOut              leax      -1,x
                    rts

* Get source file in <srcfname and destination file in <dstfptr
GetSDFl             leay      <srcfname,u         point X to next file pointer
                    bsr       SrchFile            skip white spaces, look for name on cmd line
                    bcs       L067D               branch if end
                    inc       <srccnt             else increment souce count
                    leay      <dstfptr,u          point Y to destination file
                    bsr       SkipSpcs            destroy any leading spaces
                    bsr       SrchFile            skip white spaces, look for name on cmd line
L067D               rts

* Starting at X, parse for a filename, skipping leading white spaces
SrchFile            lda       ,x
                    cmpa      #C$CR               CR?
                    beq       L06A2               branch if so
                    stx       ,y                  else store X at Y
SkipFile            bsr       SkipNSpc            skip non-spaces
ParseOk             clrb                          clear B
                    rts                           return
L06A2               tst       <srccnt             any file specified?
                    bne       L06AA               branch if so
BadPName            ldb       #E$BPNam            else no source was specified
                    coma
                    rts

L06AA               ldx       <srcfname           get pointer
L06AC               lda       ,x+                 get char
                    cmpa      #C$SPAC             space?
                    beq       L06C4               branch if so
                    cmpa      #C$COMA             comma?
                    beq       L06C4               branch if so
                    cmpa      #C$CR               carriage return?
                    beq       L06C4               branch if so
                    cmpa      #PDELIM             pathlist delimiter?
                    bne       L06AC               branch if not
                    clr       <srccnt             else clear file count
                    stx       ,y                  and store
                    bra       L06AC               continue parsing
L06C4               tst       <srccnt             file count 0?
                    beq       L06D2               branch if so
                    tst       <srcmode            source mode? (exec or data dir)
                    beq       BadPName            branch if data
                    ldx       <srcfname           else get pointer
                    stx       ,y                  save
                    bra       ParseOk             branch
L06D2               lda       -$02,x
                    cmpa      #PDELIM
                    beq       BadPName
                    bra       ParseOk

* -d: copy each source, and everything in it if it is a directory. Each
* failure is reported and copying carries on, unless -a was given; the
* exit status is the last error.
TreeMain            tst       <single             single drive copy?
                    lbne      ShowHelp            -s can't be combined with -d
                    ldd       <bufsiz             get the copy buffer size
                    subd      #TREESTK            give the tree walk room for its stack
                    bhi       TreeMem             branch if a buffer is left
                    ldb       #E$NoRAM            not enough memory
                    lbra      Exit                exit with the error
TreeMem             std       <bufsiz             save the smaller buffer size
                    ldx       <wfileptr           get the end of the -w directory
                    stx       <wdirend            keep it, as the progress message uses wfileptr
                    addd      <rdbufptr           get the end of the copy buffer
                    std       <stklim             the stack must stay above it
                    ldx       <parmptr            get the command line
                    lbsr      SkipSpcs            skip any leading spaces
                    tst       <wopt               -w specified?
                    bne       TreeW               branch if so
                    lda       <filecnt            get the number of names
                    cmpa      #2                  a source and a destination?
                    lbhi      ShowTooMany         branch if there are more
                    lbne      ShowHelp            branch if there is only one
                    leay      srcbuf,u            point to the source buffer
                    lbsr      ArgCopy             copy the source name
                    sty       <srcend             save the end of the source
                    bcs       TreeSrcBad          branch if it is too long
                    leay      dstbuf,u            point to the destination buffer
                    lbsr      ArgCopy             copy the destination name
                    sty       <dstend             save the end of the destination
                    bcs       TreeDstBad          branch if it is too long
                    lbsr      CopyTree            copy the source
TreeDone            ldb       <lasterr            exit with the last error
                    lbra      Exit
TreeSrcBad          lbsr      SetSrcName          report against the source
                    bra       TreeBad
TreeDstBad          lbsr      SetDstName          report against the destination
TreeBad             lbsr      TreeFail            report the error
                    bra       TreeDone            and exit
TreeW               lda       ,x                  get the next character
                    cmpa      #C$CR               end of the command line?
                    beq       TreeDone            branch if so
                    leay      srcbuf,u            point to the source buffer
                    lbsr      ArgCopy             copy the source name
                    sty       <srcend             save the end of the source
                    stx       <argptr             save the rest of the command line
                    bcs       TreeWBad            branch if it is too long
                    lbsr      WMake               make the destination in the -w directory
                    bcs       TreeWBad            branch if that failed
                    lbsr      CopyTree            copy the source
TreeWNext           ldx       <argptr             get the rest of the command line
                    bra       TreeW               and copy the next source
TreeWBad            lbsr      SetSrcName          report against the source
                    lbsr      TreeFail            report the error
                    bra       TreeWNext           and carry on

* Copy a name from the command line at X to the buffer at Y, dropping
* trailing separators. Return Y=the carriage return ending it, X past
* it and any spaces, and carry set with B=E$BPNam if it is too long.
ArgCopy             pshs      y                   save the start of the buffer
ArgCopy2            lda       ,x                  get a character of the name
                    cmpa      #C$SPAC             end of the name?
                    beq       ArgStrip            branch if so
                    cmpa      #C$COMA             end of the name?
                    beq       ArgStrip            branch if so
                    cmpa      #C$CR               end of the name?
                    beq       ArgStrip            branch if so
                    sta       ,y+                 copy the character
                    leax      1,x                 move to the next character
                    tfr       y,d                 get the end of the copy
                    subd      ,s                  get its length
                    cmpd      #PATHMAX-1          has it filled the buffer?
                    blo       ArgCopy2            branch if not
                    lda       #C$CR               get a carriage return
                    sta       ,y                  end the name with it
                    lbsr      SkipNSpc            skip the rest of the name
                    lbsr      SkipSpcs            and any spaces after it
                    leas      2,s                 discard the start of the buffer
                    ldb       #E$BPNam            the pathlist is too long
                    orcc      #Carry              return the error
                    rts
ArgStrip            cmpy      ,s                  is the name empty?
                    beq       ArgEnd              branch if so
                    lda       -1,y                get its last character
                    cmpa      #PDELIM             is it a trailing separator?
                    bne       ArgEnd              branch if not
                    leay      -1,y                drop the separator
                    bra       ArgStrip            and look for another
ArgEnd              lda       #C$CR               get a carriage return
                    sta       ,y                  end the name with it
                    lbsr      SkipSpcs            skip any spaces after it
                    leas      2,s                 discard the start of the buffer
                    clrb                          no error
                    rts

* With -w, the destination is the -w directory followed by the last
* name of the source. A last name of only dots is refused.
WMake               ldx       <srcend             get the end of the source
                    leay      srcbuf,u            get the start of the source
                    pshs      y                   save it
WMake2              cmpx      ,s                  at the start of the source?
                    beq       WMake3              branch if so
                    lda       ,-x                 get the previous character
                    cmpa      #PDELIM             is it a separator?
                    bne       WMake2              branch if not
                    leax      1,x                 point to the last name
WMake3              leas      2,s                 discard the start of the source
                    pshs      x                   save the start of the last name
WMake4              cmpx      <srcend             has the whole last name been checked?
                    beq       WMakeBad            branch if it was empty or only dots
                    lda       ,x+                 get a character of the last name
                    cmpa      #'.                 is it a dot?
                    beq       WMake4              branch if so
                    leax      wdest,u             point to the -w directory
                    leay      dstbuf,u            point to the destination buffer
WMake5              cmpx      <wdirend            copied the whole directory?
                    beq       WMake6              branch if so
                    lda       ,x+                 get a character of it
                    sta       ,y+                 copy it
                    bra       WMake5              and the next
WMake6              puls      x                   get the start of the last name
WMake7              cmpx      <srcend             copied the whole last name?
                    beq       WMake8              branch if so
                    lda       ,x+                 get a character of it
                    sta       ,y+                 copy it
                    pshs      y                   save the end of the copy
                    leay      dstbuf+PATHMAX-1,u  get the last usable byte
                    cmpy      ,s                  has the copy reached it?
                    puls      y                   restore the end of the copy
                    bls       WMakeLong           branch if so
                    bra       WMake7              and copy the next character
WMake8              lda       #C$CR               get a carriage return
                    sta       ,y                  end the destination with it
                    sty       <dstend             save its end
                    clrb                          no error
                    rts
WMakeBad            leas      2,s                 discard the start of the last name
WMakeLong           ldb       #E$BPNam            refuse the name
                    orcc      #Carry              return the error
                    rts

* Copy the source in srcbuf to the destination in dstbuf: a file is
* copied as usual, a directory is made and everything in it copied.
CopyTree            bsr       OpenSrcDir          open the source as a directory
                    lbcs      CopyBufs            if it isn't one, copy it as a file
                    pshs      a                   save the directory path
                    leax      record,u            point to the options buffer
                    ldb       #SS.Opt             get the path options
                    os9       I$GetStt
                    ldb       #^SHARE.            default directory attributes
                    bcs       CopyTree2           use them if there are no options
                    lda       record,u            get the device type
                    cmpa      #DT.RBF             is it RBF?
                    bne       CopyTree2           use the defaults if not
                    ldb       record+PD.ATT-PD.OPT,u get the directory's attributes
CopyTree2           stb       <tattr              use them for the new directory
                    puls      a                   restore the directory path
                    bsr       MakeDst             make the destination directory
                    lbcc       TreeLevel           copy what is in it if that went well
                    pshs      b                   save the error
                    os9       I$Close             close the source directory
                    puls      b                   restore the error
                    bra       TreeFail            report it

* Open srcbuf as a directory. Return A=path.
OpenSrcDir          lda       #DIR.+READ.         open it as a directory
                    ora       <srcmode            from the execution directory with -x
                    leax      srcbuf,u            point to the source
                    os9       I$Open
                    rts

* Make the directory dstbuf with attributes <tattr; a directory that
* already exists is used as it is, anything else is an error. Preserves A.
MakeDst             pshs      a                   save A
                    leax      dstbuf,u            point to the destination
                    ldb       <tattr              get the attributes
                    os9       I$MakDir            make the directory
                    bcc       MakeDst2            branch if it went well
                    cmpb      #E$CEF              does it already exist?
                    bne       MakeDst1            report the error if not
                    lda       #DIR.+READ.         open it as a directory
                    leax      dstbuf,u            point to the destination
                    os9       I$Open              to check that it is one
                    bcs       MakeDst1            report the error if it isn't
                    os9       I$Close             close it again
                    bcc       MakeDst2            use it if that went well
MakeDst1            bsr       SetDstName          report against the destination
                    orcc      #Carry              return the error
                    puls      a,pc
MakeDst2            clrb                          no error
                    puls      a,pc

* Point <lstfopen and <lstfopln at srcbuf or dstbuf for a report.
SetSrcName          pshs      b                   save the error
                    leax      srcbuf,u            point to the source
                    ldd       <srcend             get its end
                    bra       SetName             set the name
SetDstName          pshs      b                   save the error
                    leax      dstbuf,u            point to the destination
                    ldd       <dstend             get its end
SetName             stx       <lstfopen           report against it
                    pshs      x                   save its start
                    subd      ,s++                get its length
                    std       <lstfopln           save it
                    puls      b,pc                restore the error

* B=error, reported against <lstfopen. With -a, exit with it.
TreeFail            stb       <lasterr            remember it for the exit status
                    lbsr      ShowFail            report it
                    tst       <abortflg           abort on error?
                    beq       TreeFail2           branch if not
                    ldb       <lasterr            get the error
                    lbra      Exit                and exit with it
TreeFail2           rts

* Copy the file srcbuf to dstbuf, reporting any failure.
CopyBufs            leax      srcbuf,u            point to the source
                    stx       <srcfname           copy from it
                    stx       <wfileptr           and name it in the progress message
                    ldd       <srcend             get its end
                    pshs      x                   save its start
                    subd      ,s++                get its length
                    std       <wfilelen           save it for the message
                    leax      dstbuf,u            point to the destination
                    stx       <dstfptr            copy to it
                    lbsr      CopyFile            copy the file
                    bcs       TreeFail            report it if that failed
                    rts

* A=open source directory; srcbuf and dstbuf name it and its copy. The
* directory is closed while a subdirectory is copied, so the depth of a
* tree doesn't depend on the number of free paths; on reopening, the
* entries already copied are skipped.
* Frame: 0,s=path 1,s=entries to skip 3,s=entries done 5,s=end of
* srcbuf 7,s=end of dstbuf
TreeLevel           pshs      a                   save the path
                    tfr       s,d                 get the stack pointer
                    subd      #FRAMESZ+TREEMRG    allow for this level
                    cmpd      <stklim             is there room?
                    puls      a                   restore the path
                    bhs       TreeLevel2          branch if so
                    os9       I$Close             close the directory
                    bsr       SetSrcName          report against the source
                    ldb       #E$StkOvf           the tree is too deep
                    bra       TreeFail            report it
TreeLevel2          ldx       <dstend             get the end of the destination
                    pshs      x                   save it
                    ldx       <srcend             get the end of the source
                    pshs      x                   save it
                    ldx       #0                  get a zero count
                    pshs      x                   no entries done
                    pshs      x                   no entries to skip
                    pshs      a                   save the path
TLNext              lda       ,s                  get the directory path
                    leax      record,u            point to the entry buffer
                    ldy       #RD.Size            ask for the name and the attributes
                    lbsr      ReadDirCompat       read the next entry
                    bcs       TLEnd               branch at the end or on an error
                    ldd       1,s                 are there entries to skip?
                    beq       TLUse               branch if not
                    subd      #1                  count the skipped entry
                    std       1,s                 save the count
                    bra       TLNext              and read the next entry
TLUse               ldd       3,s                 get the count of entries done
                    addd      #1                  count this one
                    std       3,s                 save the count
                    lbsr      AddNames            add its name to both paths
                    bcs       TLLong              branch if a path is too long
                    lda       record+RD.Attr,u    get the entry's attributes
                    bita      #DIR.               is it a directory?
                    bne       TLSub               branch if so
                    bsr       CopyBufs            copy the file
TLRestore           bsr       TLTrunc             remove the name from both paths
                    bra       TLNext              and read the next entry
TLLong              lbsr      SetSrcName          report against the directory
                    lbsr      TreeFail            report the error
                    bra       TLRestore           and carry on
TLSub               sta       <tattr              use its attributes for the copy
                    lda       ,s                  get the directory path
                    os9       I$Close             close it while the subdirectory is copied
                    lbsr      MakeDst             make the destination directory
                    bcs       TLSubFail           branch if that failed
                    lbsr      OpenSrcDir          open the subdirectory
                    bcs       TLSubOpen           branch if that failed
                    bsr       TreeLevel           copy what is in it
                    bra       TLReopen            and reopen this directory
TLSubOpen           lbsr      SetSrcName          report against the subdirectory
TLSubFail           lbsr      TreeFail            report the error
TLReopen            ldd       3,s                 get the count of entries done
                    std       1,s                 skip them after reopening
                    bsr       TLTrunc             remove the name from both paths
                    lbsr      OpenSrcDir          reopen this directory
                    bcs       TLOpenErr           branch if that failed
                    sta       ,s                  save the new path
                    bra       TLNext              and read the next entry
TLOpenErr           lbsr      SetSrcName          report against this directory
                    lbsr      TreeFail            report the error
                    bra       TLRet               and give up on it
TLEnd               cmpb      #E$EOF              end of the directory?
                    beq       TLClose             branch if so
                    lbsr      SetSrcName          report against this directory
                    lbsr      TreeFail            report the error
TLClose             lda       ,s                  get the directory path
                    os9       I$Close             close it
TLRet               leas      FRAMESZ,s           discard the frame
                    rts

* Remove the last name from both paths. The frame is 2 bytes deeper.
TLTrunc             lda       #C$CR               get a carriage return
                    ldx       7,s                 get the end of this directory's source
                    sta       ,x                  end the source there
                    stx       <srcend             save the end
                    ldx       9,s                 get the end of this directory's destination
                    sta       ,x                  end the destination there
                    stx       <dstend             save the end
                    rts

* Add a separator and the entry's name to srcbuf and dstbuf.
AddNames            ldd       <srcend             get the end of the source
                    leax      srcbuf+PATHMAX-RD.ID-2,u get the last place any name fits
                    pshs      x                   save it
                    cmpd      ,s++                does the name fit?
                    bhi       AddNamesBad         branch if not
                    ldd       <dstend             get the end of the destination
                    leax      dstbuf+PATHMAX-RD.ID-2,u get the last place any name fits
                    pshs      x                   save it
                    cmpd      ,s++                does the name fit?
                    bhi       AddNamesBad         branch if not
                    ldx       <srcend             add the name to the source
                    bsr       AddName
                    stx       <srcend             save the new end
                    ldx       <dstend             add the name to the destination
                    bsr       AddName
                    stx       <dstend             save the new end
                    clrb                          no error
                    rts
AddNamesBad         ldb       #E$BPNam            the pathlist is too long
                    orcc      #Carry              return the error
                    rts
AddName             leay      record+RD.Name,u    point to the entry's name
                    lda       #PDELIM             get a separator
AddName2            sta       ,x+                 add the character to the path
                    lda       ,y+                 get a character of the name
                    bpl       AddName2            branch if it isn't the last
                    anda      #$7F                clear the end of name marker
                    sta       ,x+                 add the last character
                    lda       #C$CR               get a carriage return
                    sta       ,x                  end the path with it
                    rts

DoVerify
                    pshs      u,y                 save registers
                    ldx       <writemsb           get 2 msb's of last write
                    ldu       <writelsb           get 2 lsb's of last write
                    lda       <dstpath            get out path number
                    os9       I$Seek
                    lbcs      Exit                exit on error
                    ldu       2,s                 get original u back
                    leau      copybuff,u          point to buffer start
                    ldd       ,s                  get bytes written
                    addd      <writelsb           add on to current 2 lsb positions
                    std       <writelsb           save them
                    ldd       ,s                  get bytes written
                    bcc       vfy000              skip if no carry
                    leax      1,x                 bump up 2 msb's
                    stx       <writemsb           and save them

vfy000              ldy       #$0100              chars to read for verify
                    std       ,s                  save it
                    tsta                          did we write more than 255 bytes ?
                    bne       vfy010              yes...only read 256
                    tfr       d,y                 else xfer amount we did write

vfy010              ldx       2,s                 get u register
                    leax      vfybuff,x           point to start of verify buffer
                    lda       <dstpath            get output path number
                    os9       I$Read              read a block in
                    lbcs      Exit                exit on error

vfy020              lda       ,u+                 get char from in buffer
                    cmpa      ,x+                 get char from out buffer
                    bne       snderr1             not equal...send write verfiy msg
                    leay      -1,y                decrement read count
                    bne       vfy020              if more..loop back
                    ldd       ,s                  get write count back
                    subd      #$0100              subtract verify buffer size
                    bhi       vfy000              if more left...loop back
                    puls      u,y,pc              else restore registers and return

snderr1             leax      errmsg1,pcr         address of 'write verify failed' msg
                    lbsr      WrLine              send it
                    comb                          set carry
                    ldb       #$01                set error
                    lbra      Exit                exit

errmsg1             fcb       C$BELL
                    fcc       /Error - write verification failed./
                    fcb       C$CR

                    use       ../level1/cmds/readdir-compat.asm

                    emod
eom                 equ       *
                    end
