********************************************************************
* Attr - Modify file attributes
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  11      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*  12      2005/11/23	CRH
* Now uses SS.FD to read and write the FD sector

;;; attr
;;;
;;; Syntax:	attr <filename> [permission]
;;; Function: Examine or change a file's security permissions.
;;; Parameters:
;;;     filename    The name of the file to examine or change.
;;;     permission  One or more file attributes to apply.
;;; Options:
;;;     -d   Changes a file directory file to not a non-directory file.
;;;      s   The file is not single-user and can serve only one user at a time.
;;;      r   Only the owner can read the file.
;;;      w   Only the owner can write to the file.
;;;      e   Only the owner can execute the file.
;;;     pr   Anyone can read the file.
;;;     pw   Anyone can write to the file.
;;;     pe   Anyone can execute the file.
;;;     -a   Don't display attributes when modifying.
;;;
;;; Notes
;;;
;;; Type the command name followed by the name of the file you want to change. Next, type a list of the permissions
;;; to turn on or off. Turn a permission on by typing its abbreviation or off by typing its abbreviation preceded
;;; by a dash. attr has no effect on permissions you don't specify.
;;;
;;; If you don't specify any permissions, attr displays the file's current attributes. You can't change the
;;; attributes of a file you don't own. User 0 can change the attributes of any file in the system.
;;;
;;; Use attr to change a directory into a file after deleting all the directory's files. You can't change a
;;; file to a directory with attr. Use makdir instead.
;;;
;;; Examples
;;;
;;;  To remove public read and write permission from the file myfile, type:
;;;
;;;      attr myfile -pr -pw [ENTER]
;;;
;;; To give read, write, and execute permission to everyone for the file myfile, type:
;;;
;;;      attr myfile r we pr pw pe [ENTER]
;;;
;;; To display the current permissions of the file datalog, type:
;;;
;;;      attr datalog [ENTER]


                    nam       Attr
                    ttl       Modify file attributes

* Disassembled 98/09/11 11:44:51 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

fpath               rmb       1                   file path
parmptr             rmb       2                   parameter pointer
cmdperms            rmb       2                   pointer to options after filename on command line
onOrOff             rmb       1                   0 = turn ON options, !0 = turn OFF options
showem              rmb       1                   0 = don't display attributes after setting, !0 = show 'em!
pathopts            rmb       PD.OPT
dirent              rmb       DIR.SZ
                    rmb       DIR.SZ
fdesc               rmb       FD.SEG
attrbuf             rmb       260
stack               rmb       200
size                equ       .

name                fcs       /Attr/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$LF
                    fcc       "Use: Attr <pathname> {[-]<opts>}"
                    fcb       C$LF
                    fcc       " opts: -d s r w e pr pw pe -a"
                    fcb       C$CR
                    endc
NotOwner            fcb       C$LF
                    fcc       "You do not own that file."
                    fcb       C$CR
UseMkDir            fcb       C$LF
                    fcc       "Use Makdir to create a directory"
                    fcb       C$CR
DirNtEmt            fcb       C$LF
                    fcc       "ERROR; the directory is not empty"
                    fcb       C$CR
Attrs               fcc       "dsewrewr"
                    fcb       $FF

start               stx       <parmptr            save param ptr
                    clr       <showem             clear show flag
                    com       <showem             then complent (assume user wants to show)
* Open file at X as file
                    clra
                    lda       #WRITE.             need write to change attrs
                    os9       I$Open              open file on command line
                    bcc       L00D9               branch if ok
* If error, try to open without write permissions
                    ldx       <parmptr            get saved param ptr
                    clra
                    os9       I$Open
                    bcc       L00D9               branch if ok
* If error, try to open as directory with read/write permissions
                    ldx       <parmptr            get saved param ptr
                    lda       #DIR.+UPDAT.        load perms
                    os9       I$Open              open as directory
                    bcc       L00D9               branch if ok
* One last time, try open as directory only
                    ldx       <parmptr            get param ptr
                    lda       #DIR.               load different perms
                    os9       I$Open              try one more time
                    bcs       L0114               branch if error
L00D9               sta       <fpath              save off path
                    stx       <cmdperms           save updated parameter ptr
                    leax      pathopts,u          point X to buffer
                    ldb       #SS.Opt             load with status code
                    os9       I$GetStt            get status
                    bcs       L0114               branch if error
                    clrb
                    lda       ,x                  get path type
                    cmpa      #DT.RBF             check if RBF path
                    lbne      ShowHelp            branch if not
                    lda       <fpath              get path in A
                    ldb       #SS.FD              we want a file descriptor sector
                    leax      fdesc,u             point to buffer
                    ldy       #FD.SEG             get the size
                    os9       I$GetStt            get it!
L0114               bcs       ShowHelp            branch if error
                    os9       F$ID                get ID
                    cmpy      #$0000              super user?
                    beq       L014B               branch if so
                    cmpy      <fdesc+FD.OWN,u     is user same as file's owner?
                    bne       NoPerm              branch if not
L014B               ldx       <cmdperms           point to perms on cmd line
                    lbsr      ProcOpt             process an option
                    bcs       ShowAttrs           just show attributes
* Loop that processes multiple options on the command line
ProcOpts            lbsr      ProcOpt
                    bcc       ProcOpts
                    clrb
                    lda       ,x                  get next character on command line
                    cmpa      #C$CR               carriage return?
                    bne       ShowHelp            if not, show help.
                    lda       <fpath              else get file path
                    ldb       #SS.FD              set my file descriptor
                    leax      fdesc,u             point to file desc
                    ldy       #1                  only 1 byte
                    os9       I$SetStt            write out new attributes
                    bcs       ShowHelp            branch if error
                    lda       <fpath              get file path
                    os9       I$Close             close file
                    bcs       ShowHelp            branch if error
                    ldb       <showem
                    beq       Exit
ShowAttrs
                    ldb       <fdesc,u            get attribute byte from file descriptor
                    leax      >Attrs,pcr          point to attributes
                    leay      <attrbuf,u          attribute print buffer
                    lda       ,x+                 get next attribute byte
L0197               lslb                          move bit 7 into carry
                    bcs       L019C               branch bit 7 was set
                    lda       #'-                 print "-" to indicate attribute is off
L019C               sta       ,y+                 and save off to Y
                    lda       ,x+                 get next character at X
                    bpl       L0197               if hi-bit not set, do again
                    lda       #C$CR               get carriage return
                    sta       ,y+                 store it in buffer
                    leax      <attrbuf,u          point to buffer
                    clrb                          clear B
                    bra       PrintAndExit        print
ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HelpMsg,pcr
                    else
                    clrb
                    bra       Exit
                    endc

* Print what's at X to stderr then bail out
PrintAndExit
                    pshs      b                   save error code
                    lda       #2                  write to stderr
                    ldy       #256                up to 256 bytes
                    os9       I$WritLn            write line
                    comb                          set carry
                    puls      b                   recover error code
Exit                os9       F$Exit              and exit

NoPerm              clrb
                    leax      >NotOwner,pcr
                    bra       PrintAndExit

* Admonish the user to use Makdir to turn directory bit on
UseMakdir
                    leax      >UseMkDir,pcr
                    clrb
                    bra       PrintAndExit

* Go through a directory and verify that it's empty.
* If directory isn't empty, this routine eventually calls F$Exit
* and only returns to the caller IF the directory is empty.
VerifyDirEmpty
                    pshs      u,y,x               save off registers
                    lda       <fpath              get the file path
                    ldx       #$0000
                    ldu       #DIR.SZ*2           get size of .. and . entries
                    os9       I$Seek              seek past them
                    ldu       $04,s               get U off stack
                    bcs       Exit                branch if I$Seek caused error
L01E0               leax      <dirent,u           point to the directory entry buffer
                    ldy       #DIR.SZ             get the size
                    os9       I$Read              read the directory entry
                    bcs       L01F7               branch if error
                    tst       ,x                  this entry empty?
                    beq       L01E0               branch if so
                    leax      >DirNtEmt,pcr       else directory is not empty.
                    clrb
                    bra       PrintAndExit
L01F7               puls      u,y,x               restore registers
                    cmpb      #E$EOF              are we at end of file?
                    bne       ShowHelp            branch if not
                    rts                           else return

* Attribute table
* Entry: Attribute byte, one or two bytes of ASCII option, and a terminator ($FF or $00)
AttrTbl             fcb       DIR.|SHARE.|READ.|WRITE.|EXEC.|PREAD.|PWRIT.|PEXEC.,'A,$FF
                    fcb       DIR.,'D,$FF
                    fcb       SHARE.,'S,$FF
                    fcb       READ.,'R,$FF
                    fcb       WRITE.,'W',$FF
                    fcb       EXEC.,'E,$FF
                    fcb       PREAD.,'P,'R,$FF
                    fcb       PWRIT.,'P,'W,$FF
                    fcb       PEXEC.,'P,'E,$FF
                    fcb       $00

* Process an option on the command line
* X = pointer to next option on commmand line
ProcOpt             clr       <onOrOff            assume options are turned on
L021F               lda       ,x+                 get next option character
                    cmpa      #C$SPAC             space?
                    beq       L021F               if so, get next character
                    cmpa      #C$COMA             comma?
                    beq       L021F               if so, get next character
                    cmpa      #'-                 dash?
                    bne       L0231               no, options will be turned on
                    com       <onOrOff            else complement so options will be turned off
                    lda       ,x+                 get next option character
L0231               leax      -1,x                back up one
                    leay      >AttrTbl,pcr        point to table
L0237               ldb       ,y+                 get attribute in B
                    pshs      y,x                 save off parameter and table option pointers
                    beq       OptErr              branch if at end of table
OptCmp              lda       ,x+                 get next character on command line
                    eora      ,y+                 XOR with option byte in table, now Y points to next option character
                    anda      #$DF                make character in A uppercase
                    beq       OptCmp              branch if character is same... match!
                    lda       -1,y                else get character at -1,Y
                    bmi       L0251               branch if hi-bit set (DIR.)
                    puls      y,x                 recover option and table pointers
L024B               lda       ,y+                 get next possible option character
                    bpl       L024B               branch if hi-bit clear
                    bra       L0237
L0251               lda       ,-x                 get previous option character
                    cmpa      #'0                 compare against printable character 0
                    bcc       OptErr              branch if higher or same
                    cmpb      #DIR.|SHARE.|READ.|WRITE.|EXEC.|PREAD.|PWRIT.|PEXEC.
                    beq       L0278
                    bitb      #$80                test directory bit set
                    beq       L0268               branch if not directory
                    tst       <onOrOff            options turning on or off?
                    lbeq      UseMakdir           branch if on
                    lbsr      VerifyDirEmpty      else verify the directory is empty (doesn't return if it isn't!)
L0268               puls      y,b,a               recover registers
                    lda       <fdesc,u            get file descriptor byte
                    eora      <onOrOff            XOR A with on/off flag
                    ora       -$01,y              OR with previous Y
                    eora      <onOrOff            XOR with on/off flag again
                    sta       <fdesc,u            store in file descriptor byte
                    clrb                          clear carry
                    rts                           and return
L0278               eorb      <onOrOff            XOR with onOrOff
                    stb       <showem             save to showem flag
                    clrb                          clear carry
                    puls      pc,y,b,a            restore registers and return
OptErr              coma                          set carry
                    puls      pc,y,x              pull registers and return

                    emod
eom                 equ       *
                    end
