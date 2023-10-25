********************************************************************
* Backup - Make a backup copy of a disk
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   8      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*   9      2005/05/03  Robert Gault
* Folded in a new option F to permit a .dsk image file to be used
* instead of dev1. Full path or local file can be used. There is
* still a comparison of LSN0 to make sure that a disk actually has
* been formatted for the correct number of sides and tracks.
*
*  10      2008/11/12 Robert Gault
* Removed what seemed unnecessary Close and reOpen lines.
* Relocated verification turn off routine.
* Preservation of new disk ID is now possible per Gene's idea.
* SAVEID is a switch to select save/no_save of ID on destination disk.
* Copy and Verification start at LSN1 since LSN0 gets checked several times anyway.

;;; backup
;;;
;;; Syntax: backup [opts] <devname1> <devname2>
;;; Function: Copies all data from one disk to another.
;;; Parameters:
;;;     devname1  The drive containing the disk files you want to back up.
;;;     devname2  The drive containing the disk to which you want to transfer the files.
;;;     opts      One or more of the following options.
;;; Options:
;;;      e        Cancels the backup if a read error occurs.
;;;      S        Backup a diskette using only one drive.
;;;      -v       Don't verify the data written to the destination diskette.
;;;      #nK      Increase to n the amount of memory that backup uses.
;;;
;;; Notes
;;;
;;; backup performs a sector by sector copy, ignoring file structures. In all cases, the devices specified must have the same format (size, density, and so forth)
;;; and the destination disk must not have defective sectors.
;;; If you omit both device names, the system assumes you are copying from /DO to /D1. If you omit only the second device
;;; name, OS-9 performs a single-drive backup on the specified drive.
;;; The following demonstrates a complete backup of /DO to /D1. In the example, the diskette in Drive /D1 is a formatted diskette with the name MYDISK. Scratched, which appears in one of the following messages, means erased. You type:
;;;
;;;      backup [ENTER]
;;;
;;; The screen display and your input are:
;;;
;;;      Ready to backup from /dd to /d1 ?: [Y]
;;;      MYDISK
;;;       is being scratched
;;;      OK?: [Y]
;;;      Sectors copied: $0276
;;;      Verify pass
;;;      Sectors verified: $0276
;;;
;;; Following is an example of a single-drive back up. backup reads a portion of the source diskette (the diskette you are copying) into memory. It then prompts you to remove the source diskette and put the destination diskette (the
;;; diskette receiving the copy) into the drive.
;;; After backup writes to the destination diskette, remove the destination diskette and put the source diskette back
;;; into the drive. Continue swapping as prompted until backup copies the entire diskette.
;;; Giving backup as much memory as possible means you have to make fewer diskette exchanges. If enough free memory is available, you can assign up to 56 kilobytes for the backup operation. An Error 207 means that your computer does not have the specified
;;;
;;;      backup /dO #32k [ENTER]
;;;

                    nam       Backup
                    ttl       Make a backup copy of a disk

* Disassembled 02/04/03 23:08:04 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       1
* Default 0 means do not save destination disk ID. 1 means save it. RG
SAVEID              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       10

                    mod       eom,name,tylg,atrv,start,size

srcpath             rmb       1                   path of source disk
dstpath             rmb       1                   path of destination disk
u0002               rmb       2
u0004               rmb       5
u0009               rmb       1
errabrt             rmb       1                   abort if read error flag (1 = abort, 0 = don't)
pmptsng             rmb       1                   single disk copy prompt flag (1 = prompt for single, 0 = don't)
dontvfy             rmb       1                   don't verify backup (1 = Don't!, 0 = do)
fileflg             rmb       1                   0 = disk, 1 = file (.dsk) to disk; RG
noprompt            rmb       1                   0 = prompt user, 1 = do not prompt user
srcerr              rmb       1                   source disk error code on I$Read
curlsn              rmb       3                   current 24-bit LSN counter used while backing up
sctbuf              rmb       2                   sector buffer pointer
numpages            rmb       1                   number of 256 byte pages we can use for backup buffer
pagcntr             rmb       1                   256 byte page counter (for backup buffer)
dstdev              rmb       32
optbuf              rmb       32                  SS/GS OPT buffer
bufptr              rmb       2                   buffer pointer
strbuf              rmb       424                 buffer
stack               rmb       80
* Important, the next two lines MUST STAY TOGETHER because of assumptions
* about their location in the code.
dstlsn0             rmb       256
srclsn0             rmb       256
backbuff            rmb       14*256              reserve pages for backup buffer
size                equ       .

name                fcs       /Backup/
                    fcb       edition

defparms            fcc       "/d0 /d1"
                    fcb       C$CR
                    ifne      DOHELP
* Added F option; RG
HelpMsg             fcb       C$LF
                    fcc       "Use: Backup [e] [f] [s] [-v]"
                    fcb       C$LF
                    fcc       "            [/dev1 [/dev2]]"
                    fcb       C$LF
                    fcc       "  e - abort if read error"
                    fcb       C$LF
                    fcc       "  f - replace dev1 with .dsk image file"
                    fcb       C$LF
                    fcc       "  p - do not prompt user"
                    fcb       C$LF
                    fcc       "  s - single drive prompts"
                    fcb       C$LF
                    fcc       " -v - inhibit verify pass"
                    endc
L00A0               fcb       $80+C$CR
L00A1               fcc       "Ready to backup from"
L00B5               fcb       $80+C$SPAC
to                  fcs       " to "
ok                  fcc       "Ok"
ask                 fcs       " ?: "
rdysrc              fcs       "Ready Source, hit a key: "
rdydst              fcs       "Ready Destination, hit a key: "
L00F7               fcs       "Sector $"
sctscpd             fcs       "Sectors   copied: $"
vfypass             fcb       C$LF
                    fcc       "Verify pass"
                    fcb       $80+C$CR
sctvfd              fcs       "Sectors verified: $"
scratch             fcb       C$LF
                    fcc       " is being scratched"
                    fcb       $80+C$CR
notsame             fcc       "Disks not formatted identically"
                    fcb       C$LF
bkabort             fcc       "Backup Aborted"
                    fcb       $80+C$CR

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
start               leas      >stack,u            move stack pointer to here
                    pshs      b,a                 save parameter area size
                    pshs      u                   save lowest addr
                    tfr       y,d                 move top of parameter area to Y
                    subd      ,s++                D=Y-U
                    subd      #backbuff-stack
* A = number of 256 byte pages that are available for backup buffer
                    sta       <numpages
                    clr       <pmptsng
                    clr       <fileflg
                    clr       <errabrt
                    clr       <dontvfy
                    clr       <srcerr
                    leay      <strbuf,u           get address of our buffer
                    sty       <bufptr             and save its pointer here
                    ldd       ,s++                get parameter length
                    beq       L01E3               if parameter length is 0, use defaults
L0199               ldd       ,x+                 get two bytes of command line prompt
                    cmpa      #C$SPAC             space?
                    beq       L0199               continue if so
                    cmpa      #C$COMA             comma?
                    beq       L0199               continue if so
                    eora      #'E                 check for "abort if read error" flag
                    anda      #$DF                mask it
                    bne       Chk4P               branch if not option
                    cmpb      #'0
                    bcc       Chk4P               branch if char after option is > $30
                    inc       <errabrt            else set flag
                    bra       L0199               and continue parsing
Chk4P               lda       -$01,x              load A with prev char and backup X one byte
                    eora      #'P                 check for "do not prompt user" flag
                    anda      #$DF                mask it
                    bne       Chk4S               branch if not option
                    inc       <noprompt
                    bra       L0199
Chk4S               lda       -$01,x              load A with prev char and backup X one byte
                    eora      #'S                 check for "single drive prompts" flag
                    anda      #$DF                mask it
                    bne       Chkimg              branch if not option
                    cmpb      #'0
                    bcc       L01C1               branch if char after option is > $30
                    inc       <pmptsng            else set flag
                    bra       L0199               and continue parsing
* New routine to check for new option F; RG
Chkimg              lda       -1,x                get prev char
                    eora      #'F                 test for disk image to drive
                    anda      #$DF
                    bne       L01C1
                    cmpb      #'0
                    bcc       L01C1
                    inc       <fileflg            update flag
                    bra       L0199               keep reading
* End of new routine
L01C1               ldd       -$01,x              load A with prev char and backup X one byte
                    cmpa      #'-                 dash?
                    bne       L01D7               branch if not
                    eorb      #'V
                    andb      #$DF
                    bne       L01D7
                    ldd       ,x+
                    cmpb      #'0
                    bcc       L01D7
                    inc       <dontvfy
                    bra       L0199
L01D7               lda       ,-x
                    tst       <fileflg            don't look for / if image file, take anything; RG
                    bne       L01E7
                    cmpa      #PDELIM             path delimiter?
                    beq       L01E7               branch if so
                    cmpa      #C$CR               carriage return?
                    lbne      ShowHelp            if not, show some help
L01E3               leax      >defparms,pcr
L01E7               leay      >L00A1,pcr          ready to backup
                    lbsr      L044B               ready message
                    ldy       <bufptr
                    sty       <u0002
                    tst       <fileflg            don't use F$PrsNam if an image file;RG
                    bne       L01F7a
                    lbsr      L043A               parse name
                    bra       L01F7
L01F7a              lbsr      getnm               look for space or comma if file instead of device; RG
L01F7               lda       ,x+
                    cmpa      #C$SPAC
                    beq       L01F7
                    cmpa      #C$COMA
                    beq       L01F7
                    cmpa      #C$CR
                    bne       L020B
                    inc       <pmptsng
                    ldx       <u0002
                    lda       ,x+
L020B               cmpa      #PDELIM             path delimiter?
                    lbne      ShowHelp            if not, show some help
                    leax      -$01,x
                    leay      >to,pcr             "to"
                    lbsr      L044B               print
                    ldy       <bufptr
                    sty       <u0004
                    lbsr      L043A               parse path
                    leay      >ask,pcr
                    lbsr      getkey
                    comb
                    eora      #'Y
                    anda      #$DF
                    lbne      exit
                    tst       <fileflg
                    bne       L0238b              if file instead of device don't add @
                    ldx       <u0002
                    ldd       #'@*256+C$SPAC
L0238               cmpb      ,x+
                    bne       L0238
                    std       -$01,x
L0238b              ldx       <u0002
                    lda       #READ.
                    os9       I$Open              open source device (the one we're backing up)
                    bcs       L027C               branch if error
* Relocated since Close Open is removed. RG
                    sta       <srcpath            save path to source
                    leax      >srclsn0,u
                    ldy       #256
                    os9       I$Read              read LSN 0 of source
                    bcs       L027C
                    ldx       <u0004
                    leay      <dstdev,u
L0267               ldb       ,x+
                    stb       ,y+
                    cmpb      #C$SPAC
                    bne       L0267
                    ldd       #'@*256+C$SPAC
                    std       -$01,y
                    leax      <dstdev,u
                    lda       #READ.+WRITE.
                    os9       I$Open              open destination device (the one we're writing to)
L027C               lbcs      L03AF
                    sta       <dstpath            save destination path
* Relocated so that Close Open can be removed. RG
                    leax      <optbuf,u
                    ldb       #SS.OPT
                    os9       I$GetStt
                    ldb       #$01
                    stb       PD.VFY,x            turn off verify
                    ldb       #SS.OPT
                    os9       I$SetStt
                    lbcs      L03AF
*
                    clr       <curlsn
                    clr       <curlsn+1
                    clr       <curlsn+2
* This starts copy routine at LSN1 instead of LSN0. RG
                    inc       <curlsn+2
                    lbsr      L0419
                    lda       <dstpath            get destination path
                    leax      >dstlsn0,u
                    ldy       #256
                    os9       I$Read              read LSN0 of destination
                    pshs      u,x
                    ldx       #$0000
                    leau      ,x
                    os9       I$Seek              reseek to start of disk
                    puls      u,x
                    bcs       L027C               branch if error
                    ldd       >256,x              check for source/dest disk having same number of sectors
                    cmpd      ,x
                    bne       DsksNOk             branch if different
                    ldb       >$0102,x
                    cmpb      $02,x
                    beq       DsksOk
DsksNOk             leay      >notsame,pcr
                    lbra      L03B6
DsksOk              leax      >dstlsn0,u          X now points to source LSN0
                    lda       #$BF
                    sta       <DD.OPT,x
                    leay      <DD.NAM,x
                    lbsr      L044B
                    leay      >scratch,pcr
                    lbsr      L0456
                    leay      >ok,pcr
                    lbsr      getkey              get a key from the stdin
                    comb
                    eora      #'Y
                    anda      #$DF
                    lbne      exit                exit if not ok to scratch
                    lda       <dstpath            get destination path
                    leax      >srclsn0,u          get src LSN0 read earlier
                    ifne      SAVEID
* New routine to preserved destination disk ID. Gene's idea. RG
                    pshs      d
                    leay      >dstlsn0,u
                    ldd       <DD.DSK,y
                    std       <DD.DSK,x
                    puls      d
                    endif
*
                    ldy       #256
                    os9       I$Write             write it to destination
                    lbcs      L03AF
                    pshs      u
                    ldx       #$0000
                    leau      ,x
                    os9       I$Seek              seek to LSN0
                    puls      u
                    lbcs      L03AF               added Feb 8, 2008 BGP
                    leax      >srclsn0,u
                    os9       I$Read
                    lbcs      L03AF
copyloop            leay      >rdysrc,pcr
                    lbsr      doprompt            possibly show "ready source" message
                    lda       <numpages
                    sta       <pagcntr
                    leax      >dstlsn0,u
                    lbsr      L0403
                    lbsr      L0419
                    ldd       <sctbuf
                    leax      >dstlsn0,u
                    stx       <sctbuf
                    subd      <sctbuf
                    beq       L035C
                    tfr       d,y
                    lda       <dstpath
* DriveWire Note: backup /x1 /d1 returns error 247 at this I$Write!
                    os9       I$Write
                    bcs       L03AF
L035C               lda       <srcerr
                    cmpa      #E$EOF
                    bne       copyloop
                    leay      >sctscpd,pcr
                    lbsr      L0470
                    tst       <dontvfy
                    bne       exit
* Verification code
                    leay      >vfypass,pcr
                    lbsr      L0456
                    lda       <dstpath
                    sta       <srcpath            save newly acquired path number
                    pshs      u
                    ldx       #$0000
                    leau      1,x
                    os9       I$Seek              seek to LSN0
                    puls      u
                    clr       <curlsn
                    clr       <curlsn+1
                    clr       <curlsn+2
                    clr       <srcerr
L0396               lda       <numpages
                    sta       <pagcntr
                    leax      >dstlsn0,u
                    lbsr      L0403
                    lda       <srcerr
                    cmpa      #E$EOF
                    bne       L0396
                    leay      >sctvfd,pcr
                    lbsr      L0470
                    bra       exit
L03AF               os9       F$PErr
                    leay      >bkabort,pcr
L03B6               lbsr      L0456
                    comb
exit                ldb       #$00
                    os9       F$Exit
L03BF               ldy       #256
                    lda       <srcpath
                    os9       I$Read
                    bcc       L03DC
                    stb       <srcerr
                    cmpb      #E$EOF
                    beq       L040D
                    lbsr      L046C
                    ldb       <srcerr
                    tst       <errabrt
                    bne       L03AF
                    os9       F$PErr
L03DC               ldd       <curlsn+1           get lower 16 bits of current LSN
                    addd      #$0001              increment
                    std       <curlsn+1           and save back
                    bcc       L03E7               branch if no carry
                    inc       <curlsn             else increment bits 23-16 of LSN
L03E7               tst       <srcerr
                    beq       L03FD
                    pshs      u
                    ldx       <curlsn             get curlsn in X
                    tfr       b,a                 put bits 7-0 of LSN into bits 15-8
                    clrb                          and clear B
                    tfr       d,u                 transfer to U
                    lda       <srcpath
                    os9       I$Seek
                    puls      u
                    clr       <srcerr
L03FD               ldx       <sctbuf
                    leax      >256,x
L0403               stx       <sctbuf
                    lda       <pagcntr
                    suba      #$01
                    sta       <pagcntr
                    bcc       L03BF
L040D               rts

ShowHelp            equ       *
                    ifne      DOHELP
                    leax      <strbuf,u           get address of buffer
                    stx       <bufptr             store as current buffer pointer
                    leay      >HelpMsg,pcr        point to help message data
                    lbra      L03B6
                    else
                    bra       exit
                    endc
L0419               leay      >rdydst,pcr
doprompt            tst       <pmptsng            single disk backup prompt?
                    beq       L0439               if not, just return
getkey              bsr       L0456
                    pshs      y,x,b,a
                    leax      ,s
                    ldy       #$0001
                    clra
                    os9       I$Read              read byte from stdin
                    leay      >L00A0,pcr
                    bsr       L0456
                    puls      y,x,b,a
                    anda      #$7F                clear hi bit
L0439               rts
* New routine needed as F$PrsNam will stop at the second "/";RG
getnm               pshs      x                   skip to end of file name;RG
                    ldb       #-1
gtnm2               lda       ,x+
                    incb
                    cmpa      #C$SPAC
                    beq       gtnm3
                    cmpa      #C$COMA
                    bne       gtnm2
gtnm3               puls      x
                    bra       L0443
* End of new routine;RG
L043A               pshs      x
                    os9       F$PrsNam
                    puls      x
                    bcs       ShowHelp
L0443               lda       ,x+
                    bsr       L04A5
                    decb
                    bpl       L0443
                    rts

L044B               lda       ,y                  get char at Y
                    anda      #$7F                strip off hi bit
                    bsr       L04A5
                    lda       ,y+
                    bpl       L044B
L0455               rts
L0456               bsr       L044B
                    pshs      y,x,a
                    ldd       <bufptr
                    leax      <strbuf,u
                    stx       <bufptr
                    subd      <bufptr
                    tfr       d,y
                    lda       #$02
                    os9       I$WritLn
                    puls      pc,y,x,a
L046C               leay      >L00F7,pcr
L0470               bsr       L044B
                    lda       <curlsn
                    bsr       L0486
                    inc       <u0009
                    lda       <curlsn+1
                    bsr       L0488
                    lda       <curlsn+2
                    bsr       L0488
                    leay      >L00B5,pcr
                    bra       L0456
L0486               clr       <u0009
L0488               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L0494
                    puls      a
                    anda      #$0F
L0494               tsta
                    beq       L0499
                    sta       <u0009
L0499               tst       <u0009
                    beq       L0455
                    adda      #$30
                    cmpa      #$39
                    bls       L04A5
                    adda      #$07
L04A5               pshs      x                   save X on stack
                    ldx       <bufptr             load 'next' ptr
                    sta       ,x+                 save A at location and inc ptr
                    stx       <bufptr             save 'next' ptr
                    puls      pc,x

                    emod
eom                 equ       *
                    end
