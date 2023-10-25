********************************************************************
* OS9Gen - OS-9 bootfile generator
*
* $Id$
*
*  -e = extended boot (fragmented)
*  -q=<path> = quick gen .. set sector zero pointing to <path>
*  -r = remove pointer to boot file (does not delete file)
*  -s = single drive option
*  -t=<boottrack> = boot track file to use
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   9      ????/??/??
* From OS-9 Level Two Vr. 2.00.01.
*
*  10      2003/06/28  Boisy G. Pitre
* Added -t= option, fixed bug in single disk swap routine if key
* besides 'C' was pressed, minor optimizations.
*
*  l0r2    2003/07/24  Boisy G. Pitre
* Fixed bug introduced in V03.01.03 where os9gen wouldn't write boot
* track on DS disks.
*
*  11      2005/10/10  Boisy G. Pitre
* Added -e option to create fragmented bootfiles.
*
*  12      2006/05/09  Christopher R. Hawks
* Weren't clearing -e option, so all os9boot files were extended.
*
*  13      2011/09/13  Robert Gault
* A flexible buffer is now used to hold the FAT map.
* The boot file name is now copied into the data space for which
* 160 bytes are reserved. F$Mem trashes parameter space.
* DD.BIT can now be used to obtain a reasonably sized FAT with large drives.
* Added error message if not enough room for bit map.
* Replace sectbuff with bitmbuff for all FAT (DD.MAP) work.
* Moved common code in ABMClear & ABMSet to subroutine.
*
* 14       2011/09/16 Robert Gault
* Corrected a typo which occured when committing code. Exit of Initcalc had
* ABM3 in wrong place. Also included C$CR in file name copy.
*
*         2011/09/18 Robert Gault
* Cleaned up code and removed multiple calculations of shift divisor by
* calculating it once and storing it in data.
* Corrected sector count calculation to include partial clusters.

                    nam       OS9Gen
                    ttl       OS-9 bootfile generator

* Disassembled 02/07/06 13:11:11 by Disasm v1.6 (C) 1988 by RML

*Needed for stand alone compile
*LEVEL    equ   2

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0
DOHD                set       1                   allow bootfile creation on HD

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

                    org       0
btfname             rmb       2
btflag              rmb       1
qfname              rmb       2
qflag               rmb       1
rflag               rmb       1
statptr             rmb       2
bfpath              rmb       1
devpath             rmb       1
parmpath            rmb       1
u0005               rmb       1                   Needed?
u0006               rmb       2
ddbt                rmb       3
ddbtsz              rmb       2
u000D               rmb       2
u000F               rmb       2
u0011               rmb       2
u0013               rmb       2
u0015               rmb       2
u0017               rmb       7
devopts             rmb       20
bfdlsn              rmb       3
u0035               rmb       9
u003E               rmb       2
eflag               rmb       1
sngldrv             rmb       1
bootdev             rmb       32
btshift             rmb       2
bitflag             rmb       1
lsn0                rmb       26
btfstr              rmb       160
u007B               rmb       2
u007D               rmb       1
sectbuff            rmb       1024
u047E               rmb       16
u048E               rmb       1
u048F               rmb       7
u0496               rmb       7018

bitmbuf             equ       .
size                equ       .

name                fcs       /OS9Gen/
                    fcb       edition

                    ifne      DOHELP
HelpMsg             fcb       C$LF
                    fcc       "Use (CAUTION): OS9Gen </devname> <opts>"
                    fcb       C$LF
                    fcc       " ..reads (std input) pathnames until EOF,"
                    fcb       C$LF
                    fcc       "   merging paths into New OS9Boot file."
                    fcb       C$LF
                    fcc       " -e = extended boot (fragmented)"
                    fcb       C$LF
                    fcc       " -s = single drive operation"
                    fcb       C$LF
                    fcc       " -t=boottrack = set boot track file"
                    fcb       C$LF,C$CR
                    endc
                    fcc       "Can't find: "
ErrWrit             fcb       C$LF
                    fcc       "Error writing kernel track"
                    fcb       C$CR
MemErr              fcb       C$LF
                    fcc       "Not enough memory for bit map"
                    fcb       C$CR
TrkErr              fcb       C$LF
                    fcc       "Can't read data"
                    fcb       C$CR
                    ifeq      DOHD
HDGen               fcb       C$LF
                    fcc       "Error - cannot gen to hard disk"
                    fcb       C$CR
                    endc
                    ifgt      Level-1
CantRel             fcb       C$LF
                    fcc       "Error - can't link to Rel module"
                    fcb       C$CR
                    endc
CarRet              fcb       C$CR
TheBell             fcb       C$BELL
TWarn               fcb       C$LF
                    fcc       "Warning - file(s) present"
                    fcb       C$LF
                    fcc       "on track "
                    ifeq      Bt.Track-34
                    fcc       "34"
                    else
                    fcc       "??"
                    endc
                    fcc       " - this track"
                    fcb       C$LF
                    fcc       "not rewritten."
                    fcb       C$CR
BootFrag            fcb       C$LF
                    fcc       "Error - OS9Boot file fragmented"
                    fcb       C$CR
                    ifne      0
BadTkMsg            fcc       "Error - Boot track file must be 4608 bytes"
                    fcb       C$CR
BadTkMsgL           equ       *-BadTkMsg
                    endc
Source              fcc       "Ready SOURCE,      hit C to continue: "
SourceL             equ       *-Source
Destin              fcc       "Ready DESTINATION, hit C to continue: "
DestinL             equ       *-Destin
Rename              fcc       "RENAME "
TempBoot            fcc       "TempBoot "
                    fcb       $FF
OS9Boot             fcc       "OS9Boot"
                    fcb       C$CR
                    fcb       $FF
                    ifgt      Level-1
TheRel              fcc       "Rel"
                    fcb       $FF
                    endc

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

start               clrb
                    stb       <btflag             assume no -t specified
                    stb       <u0005
                    stb       <sngldrv            assume multi-drive
                    stb       <eflag              assume not extended bootfile
                    stu       <statptr            save statics pointer
                    leas      >u047E,u            point stack pointer to u047e
                    pshs      u
                    tfr       y,d                 copy pointer to top of our mem in D
                    subd      ,s++                D = Y-u047e = 7039
                    subd      #u047E              D = 5889 = $1701 What is it? R.G.
                    clrb
                    std       <u0011
                    lda       #PDELIM
                    cmpa      ,x                  first char of device name a path delimiter?
                    lbne      BadName             branch if not (bad name)
                    os9       F$PrsNam            else parse name
                    lbcs      ShowHelp            branch if error
                    lda       #PDELIM
                    cmpa      ,y
                    lbeq      BadName
                    pshs      b,a
parseopt            lda       ,y+                 get next character
                    cmpa      #'-                 dash?
                    beq       parsein             branch if so
                    cmpa      #C$CR               end of line?
                    beq       getdev              branch if so
                    bra       parseopt            else continue to parse options
parsein             ldd       ,y+                 get two chars after -
                    cmpa      #C$CR               end of line?
                    beq       getdev              branch if so
                    cmpa      #C$SPAC             space?
                    beq       parseopt            yes, look for next char
                    anda      #$DF                else make value in A uppercase
                    cmpa      #'R                 is it R?
                    beq       remboot             branch if so
                    cmpa      #'S                 is it S?
                    beq       onedrive            branch if so
                    cmpa      #'E                 is it E
                    beq       extend              branch if so
                    cmpd      #81*256+61          does D = 'Q='
                    beq       quick
                    cmpd      #84*256+61          does D = 'T='
                    lbne      SoftExit
                    leay      1,y                 point past =
*         sty   <btfname	save pointer to boottrack filename R.G.
                    sta       <btflag
                    pshs      x                   copy btfname into data space
                    leax      btfstr,u            making room to expand the data space R.G.
                    stx       btfname,u
* Skip over non-spaces and non-CRs
SkipNon             lda       ,y+
                    cmpa      #C$CR
                    beq       getdev2             we must recover regX
                    cmpa      #C$SPAC
                    beq       parseopt2           ""
                    sta       ,x+
                    bra       SkipNon
getdev2             sta       ,x                  this was added in rev 14 to correct an oversight R.G.
                    puls      x
                    bra       getdev
parseopt2           puls      x
                    bra       parseopt
remboot             inc       <rflag              remove bootfile reference from LSN0 flag
                    bra       parsein
onedrive            inc       <sngldrv            set single drive flag
                    bra       parsein
extend              inc       <eflag              set extended boot flag
                    bra       parsein
quick               leay      1,y                 point past =
                    sty       <qfname             save pointer to quick filename
                    sta       <qflag
getdev              puls      b,a
                    leay      <bootdev,u          point to boot device
L0239               sta       ,y+
                    lda       ,x+
                    decb
                    bpl       L0239
                    sty       <u003E
                    ldd       #PENTIR*256+C$SPAC
                    std       ,y++
                    lbsr      GetDest
                    leax      <bootdev,u
                    lda       #UPDAT.
                    os9       I$Open
                    sta       <devpath
                    lbcs      ShowHelp
                    leax      <devopts,u
                    clrb
*         ldb   #SS.Opt
                    os9       I$GetStt
                    lbcs      Bye

                    ifeq      DOHD

* If destination drive is hard disk, don't allow
                    leax      devopts,u
                    lda       <(PD.TYP-PD.OPT)+devopts,u get type byte
                    bpl       L0276               branch if not hard drive
                    clrb
                    leax      >HDGen,pcr          else tell user can't do hard drive
                    lbra      WritExit

                    endc

L0276               ldx       <u003E
                    leay      >TempBoot,pcr
                    lda       #PDELIM
L027E               sta       ,x+
                    lda       ,y+
                    bpl       L027E
* Copy OS9Boot string to buffer
                    leay      >OS9Boot,pcr
L0288               lda       ,y+
                    sta       ,x+
                    bpl       L0288
                    tfr       x,d
                    leax      <bootdev,u
                    pshs      x
                    subd      ,s++
                    std       <u000D
                    ldd       #WRITE.*256+(READ.+WRITE.)
*         lda   #WRITE.
*         ldb   #READ.+WRITE.
                    os9       I$Create
                    sta       <bfpath
                    lbcs      Bye
                    ldx       #$0000              upper 16 bits are zero
                    stx       <u0006
                    ldu       #$3000
                    ldb       #SS.Size
                    os9       I$SetStt            set size of newly created file
                    lbcs      Bye                 branch if error
                    ldu       <statptr            retrieve static pointer
                    bsr       L032F

* Read Bootlist file, line by line
ReadBLst            leax      sectbuff,u
                    ldy       #256
                    clra                          standard input
                    os9       I$ReadLn            read line
                    bcs       L0312               branch if error
                    lda       ,x                  else get byte in A
                    ldb       #E$EOF              and EOF error in B
                    cmpa      #C$CR               CR?
                    beq       L0312               branch if so
                    cmpa      #'*                 comment?
                    beq       ReadBLst            continue reading if so
                    lda       #READ.              else use read perms
                    os9       I$Open              open file at X (line we read)
                    bcs       L031A               branch if error
                    sta       <parmpath           save path
L02DD               ldx       <u0015
                    ldd       <u0011
                    subd      <u0013
                    tfr       d,y
                    lda       <parmpath
                    os9       I$Read
                    bcc       L02F9
                    cmpb      #E$EOF
                    lbne      Bye
                    os9       I$Close
                    clr       <parmpath
                    bra       ReadBLst
L02F9               tfr       y,d
                    leax      d,x
                    stx       <u0015
                    addd      <u0013
                    std       <u0013
                    cmpd      <u0011
                    bcs       L030C
                    bsr       L032B
                    bcs       L0328
L030C               tst       <parmpath
                    bne       L02DD
                    bra       ReadBLst
L0312               cmpb      #E$EOF              end of file?
                    bne       L0328               branch if not
                    bsr       L033D
                    bra       L0377
L031A               pshs      b
                    leax      sectbuff,u
                    ldy       #256
                    lda       #$02                standard error
                    os9       I$WritLn            write
L0328               lbra      Bye
L032B               bsr       L033D
                    bcs       L033C
L032F               lbsr      GetSrc
                    clra
                    clrb
                    std       <u0013
                    leax      >u047E,u
                    stx       <u0015
L033C               rts
L033D               lbsr      GetDest
                    ldd       <u0013
                    beq       L033C
                    tst       <sngldrv            single drive?
                    beq       L0361               branch if not
                    lda       <devpath
                    ldx       #$0000
                    ldu       #$0000
                    os9       I$Seek              seek to LSN0
                    ldu       <statptr            +BGP+ added
                    bcs       L033C
                    leax      sectbuff,u
                    ldy       #256
                    os9       I$Read              read LSN0
                    bcs       L033C
                    lbsr      FShift
                    sty       btshift,u           save divisor value R.G.
L0361               lda       <bfpath             get bootfile path in A
                    leax      >u047E,u
                    ldy       <u0013
                    os9       I$Write
                    bcs       L033C
                    tfr       y,d
                    addd      <u0006
                    std       <u0006
                    clrb
                    rts
L0377               leax      <devopts,u
                    clrb
*         ldb   #SS.Opt
                    lda       <bfpath
                    os9       I$GetStt
                    lbcs      Bye
                    lda       <bfpath             get bootfile path
                    ldx       #$0000
                    ldu       <u0006
                    ldb       #SS.Size            set bootfile size
                    os9       I$SetStt
                    lbcs      Bye
                    ldu       <statptr
                    os9       I$Close
                    lbcs      ShowHelp

                    tst       <eflag              extended boot option used?
                    bne       nonfrag             yes, don't check for fragmented file

                    ldx       <bfdlsn,u           load X/U with LSN of bootfile fd sector
                    lda       <bfdlsn+2,u
                    clrb                          round off to sector boundary
                    tfr       d,u
                    lda       <devpath            get path to raw device
                    os9       I$Seek              seek
                    ldu       <statptr
                    lbcs      Bye
                    leax      >u047E,u            point to buffer
                    ldy       #256                read one sector
                    os9       I$Read              do it!
                    lbcs      Bye
                    ldd       >u047E+(FD.SEG+FDSL.S+FDSL.B),u
                    lbne      ItsFragd            if not zero, file is fragmented
nonfrag             lda       <devpath            get the device path
                    ldx       #$0000
                    ldu       #DD.BT
                    os9       I$Seek              seek to DD.BT in LSN0
                    ldu       <statptr
                    lbcs      Bye
                    leax      ddbt,u              point to our internal ddbt copy in statics
                    ldy       #DD.DAT-DD.BT       we want DD.BT and DD.BTSZ into ddbt,u
                    os9       I$Read              so read bootstrap sector and bootfile size
                    lbcs      Bye                 branch if error
                    ldd       <ddbtsz             get DD.BTSZ in D
                    beq       L040D               branch if zero
                    ldx       <u003E
                    leay      >OS9Boot,pcr
                    lda       #PDELIM
L03F3               sta       ,x+
                    lda       ,y+
                    bpl       L03F3
                    leax      <bootdev,u
                    os9       I$Delete            delete the os9boot file
                    ldx       <u003E
                    leay      >TempBoot,pcr       point to "tempboot" name
                    lda       #PDELIM
L0407               sta       ,x+
                    lda       ,y+
                    bpl       L0407               copy it into buffer
L040D               tst       <sngldrv
                    beq       L042E
                    clra
                    leax      >Rename,pcr
                    os9       F$Link
                    bcc       L0428
                    lbsr      GetSrc
                    os9       F$Load
                    lbcs      Bye
                    lbsr      GetDest
L0428               tfr       u,d
                    ldu       <statptr
                    std       u000F,u
L042E               lda       #$01
                    clrb
                    leax      >Rename,pcr
                    ldy       <u000D
                    leau      <bootdev,u
                    os9       F$Fork              fork rename tempboot os9gen
                    lbcs      Bye
                    os9       F$Wait
                    lbcs      Bye
                    tstb
                    lbne      Bye
                    tst       <sngldrv
                    beq       L045F
                    ldu       <statptr
                    ldd       u000F,u
                    tfr       d,u
                    os9       F$UnLink
                    lbcs      Bye
L045F               ldu       <statptr
                    tst       <eflag              extended boot?
                    beq       oldstyle            branch if not
                    lda       <bfdlsn,u           get LSN of fdsect
                    stb       <ddbt               save in DD.BT
                    ldd       <bfdlsn+1,u
                    std       <ddbt+1             save in DD.BT+1
                    clr       <ddbtsz             clear out DD.BTSZ
                    clr       <ddbtsz+1           since DD.BT points to FD
                    bra       around
oldstyle            ldb       >u048E,u            get size of file bits 23-16
                    stb       <ddbt               savein DD.BT
                    ldd       >u048F,u
                    std       <ddbt+1             save in DD.BT+1
                    ldd       <u0006              get size of file bits 15-0
                    std       <ddbtsz             save in DD.BTSZ
around              ldx       #$0000
                    ldu       #DD.BT
                    lda       <devpath
                    os9       I$Seek              seek to DD.BT in LSN0
                    ldu       <statptr
                    lbcs      Bye
                    leax      ddbt,u              point X to modified DD.BT and DD.BTSZ
                    ldy       #DD.DAT-DD.BT       write it out
                    os9       I$Write
                    lbcs      Bye
                    pshs      u
                    clra
                    clrb
                    tfr       d,x
                    tfr       d,u
                    lda       <devpath
                    os9       I$Seek              seek to LSN0
                    lbcs      Bye
                    puls      u
                    leax      <lsn0,u
                    ldy       #DD.DAT
                    lda       <devpath
                    os9       I$Read              read first part of LSN0
                    lbcs      Bye
                    ldd       #$0001
                    lbsr      Seek2LSN
*        leax  sectbuff,u		R.G. Expand memory to hold buffer
                    ldd       <lsn0+DD.MAP,u
                    addd      #bitmbuf+256        expand memory by DD.MAP+256 bytes
                    os9       F$Mem
                    leax      MemErr,pcr
                    lbcs      WritExit
                    tfr       y,s                 relocate stack

*        leax  sectbuff,u
                    leax      bitmbuf,u
                    ldy       <lsn0+DD.MAP,u      get number of bytes in device's bitmap
                    lda       <devpath
                    os9       I$Read              read the FAT into the bitmbuf
                    leax      TrkErr,pcr
                    lbcs      WritExit

* if boot track is on track zero (i.e. Dragon) skip bitmap check/update
                    ifne      Bt.Track
                    ldd       #Bt.Track*256+Bt.Sec boot track (regD=$2200 for CoCo)
                    ldy       #$0004              four bits
                    lbsr      ABMClear            this should test for clear not clear it
                    bcc       L0520
                    ldd       #Bt.Track*256+Bt.Sec read boot track, as it was not clear
                    lbsr      Seek2LSN            seek to it
                    leax      <u0017,u
                    ldy       #$0007
                    lda       <devpath
                    os9       I$Read              read first seven bytes of boot track
                    lbcs      Bye
                    leax      <u0017,u
                    ldd       ,x
                    cmpd      #256*'O+'S          is this an OS-9 boot track
                    lbne      WarnUser            go if not
*         cmpb  #'O
*         lbne  WarnUser
*         cmpb  #'S
*         lbne  WarnUser
                    lda       $04,x
                    cmpa      #$12                also check for NOP
                    beq       L0512
                    ldd       #Bt.Track*256+Bt.Sec+15 boot track, sector 16
* boldly assume Bt.Sec is nowhere higher than 3 !
                    ldy       #$0003-Bt.Sec       sectors 16-18
                    lbsr      ABMClear
                    lbcs      WarnUser
L0512               clra
                    ldb       <lsn0+DD.TKS,u      get number of sectors in D
                    IFNE      Bt.Sec
                    subb      #Bt.Sec
                    ENDC
                    tfr       d,y
                    ldd       #Bt.Track*256+Bt.Sec boot track
                    lbsr      ABMSet
                    bra       L0531
L0520               ldd       #Bt.Track*256+Bt.Sec+4 boot track
                    ldy       #$000E-Bt.Sec       sectors 5-18
                    lbsr      ABMClear            test rest of track
                    lbcs      WarnUser
                    bra       L0512

* Write altered map back to disk
L0531
                    ldd       #$0001
                    lbsr      Seek2LSN
*         leax  sectbuff,u
                    leax      bitmbuf,u
                    ldy       <lsn0+DD.MAP,u      get number of bytes in device's bitmap
                    lda       <devpath
                    os9       I$Write             write out the bitmap
                    lbcs      Bye
                    ENDC

* Code added to write alternate boottrack file
* BGP - 2003/06/26
                    tst       <btflag
                    beq       BTMem               get boot track from memory
                    lbsr      GetSrc
                    ldx       btfname,u
                    lda       #READ.
                    os9       I$Open
                    lbcs      Bye

                    ifne      0
* Determine if the size of the file is 4608 bytes
* Note, this assumes 18 sectors per track and 256
* bytes per sector.
                    ldb       #SS.Size
                    os9       I$GetStt            get size
                    tfr       u,y                 put lower 16 bytes of file size in Y
                    ldu       <statptr
                    lbcs      Bye                 branch if error
                    cmpx      #$0000              correct size?
                    bne       BadBTrak            branch if not
                    cmpy      #$1200              correct size?
                    beq       ReadBTrk            branch if not

BadBTrak            leax      BadTkMsg,pcr
                    ldy       #BadTkMsgL
                    lda       #$02
                    os9       I$WritLn
                    lbra      Bye
                    else
                    ldy       #$1200
                    endc


* Read in boot track file
* Y = proper boottrack size
ReadBTrk            leax      u0496,u             point to sector buffer
                    os9       I$Read              read sector buffer
                    lbcs      Bye
                    os9       I$Close             close path to boot track
                    lbsr      GetDest
                    ldd       #Bt.Track*256+Bt.Sec boot track
                    lbsr      Seek2LSN
                    bra       WrBTrack



BTMem
                    ifgt      Level-1

* OS-9 Level Two: Link to Rel, which brings in boot code
                    pshs      u
                    lda       #Systm+Objct        we want to link to a system object
                    leax      >TheRel,pcr         point to REL name
                    os9       F$Link              link to it
                    lbcs      L0724               branch if error
                    tfr       u,d
                    puls      u
                    subd      #$0006
                    std       u007B,u
                    lda       #$E0
                    anda      u007B,u
                    ora       #$1E
                    ldb       #$FF
                    subd      u007B,u
                    addd      #$0001
                    tfr       d,y
                    ldd       #Bt.Track*256+Bt.Sec boot track
                    lbsr      Seek2LSN
                    ldx       u007B,u

                    else

* OS-9 Level One: Write out boot track data
                    ldd       #Bt.Track*256+Bt.Sec
                    lbsr      Seek2LSN
                    ldx       #Bt.Start
                    ldy       #Bt.Size

                    endc

WrBTrack
                    lda       <devpath
                    os9       I$Write
                    lbcs      WriteErr
                    os9       I$Close
                    lbcs      Bye
                    clrb
                    lbra      Bye

* Convert Track/Sector to absolute LSN
* Entry: A = track, B = sector
* Returns in D
AbsLSN              pshs      b
                    ldb       <lsn0+DD.FMT,u      get format byte
                    andb      #FMT.SIDE           test sides bit
                    beq       AbsLSN1             branch if 1
                    ldb       #$02                else 2 sides
                    fcb       $8C                 skip next two bytes
*         bra   AbsLSN2
AbsLSN1             ldb       #$01                1 side
AbsLSN2             mul                           multiply sides times track
                    lda       <lsn0+DD.TKS,u      get device tracks
                    mul                           multiply by (sides * track)
                    addb      ,s+                 add in sector
*         addb  ,s		add in sector
                    adca      #$00
*         leas  $01,s
                    rts

* Determine bit shift from DD.BIT R.G.
* Return shift in regY needed for division
FShift              pshs      d
                    ldd       lsn0+DD.BIT,u       get sectors per cluster
                    ldy       #-1
* This finds number of bit shifts for DD.BIT R.G.
SF1                 lsra
                    rorb
                    leay      1,y
                    cmpd      #0
                    bne       SF1
                    puls      d,pc


* Returns bit in bitmap corresponding to LSN in regA
* X=bitmap buffer, on exit X points to bitmap byte of our LSN
L05AA
* We need to divide by DD.BITx8 R.G.
                    pshs      y,d
                    ldy       btshift,u
                    cmpy      #0
                    beq       GBB3
* Divide LSN by DD.BIT R.G.
GBB2                lsra
                    rorb
                    leay      -1,y
                    bne       GBB2
GBB3                stb       ,s                  save lsb
                    andb      #7                  Make sure offset within table
                    stb       1,s                 save table mask
                    ldy       #3
* Now regY is the number of right shifts required for 8 R.G.
                    ldb       ,s                  recover the lsb
GBB4                lsra
                    rorb
                    leay      -1,y
                    bne       GBB4
* Now regD is the byte number in the FAT
                    leax      d,x                 point regX at the byte
                    puls      d
                    leay      <BitTable,pcr       Point to bit table
                    lda       b,y                 Get bit from table
                    puls      pc,y                Restore regY and return

BitTable            fcb       $80,$40,$20,$10,$08,$04,$02,$01 Bitmap bit table

* Common routine used by ABMSet & ABMClear  R.G.
* Enter: see ABMSet & ABMClear
* Exit: regY=divisor, regD=LSN
Initcalc            bsr       AbsLSN              convert A:B to LSN
                    leax      bitmbuf,u
                    bsr       L05AA               getbitmapbit
                    pshs      d,y
                    ldy       btshift             R.G. code to include DD.BIT
                    cmpy      #0
                    bne       ABM2
                    puls      d,y,pc
ABM2                ldd       2,s                 recover regY sector count
                    clr       bitflag,u
* Divide sector count by DD.BIT
ABMlp               lsra
                    rorb
                    bcc       ABMlp2
                    inc       bitflag,u           mark carry over
ABMlp2              leay      -1,y
                    bne       ABMlp
                    tst       bitflag,u
                    beq       ABMnz
                    incb                          include partial cluster
ABMnz               tfr       d,y                 regY has been divided by DD.BIT
                    ldd       ,s                  recover content
                    leas      4,s                 clean stack
ABM3                rts


* Clear bits in the allocation bitmap
* Entry: A = Track, B = Sector, Y = number of bits to clear
ABMClear            pshs      x,y,b,a
                    bsr       Initcalc
* Back to older code
                    sta       ,-s                 save map bit
                    bmi       L05EA               go if bit #7
L05D3               lda       ,x                  get byte in bitmap
                    sta       u007D,u
L05D9               anda      ,s                  test byte on stack
                    bne       L0616               go if already set
                    leay      -1,y                next bit to test
                    beq       L0612
                    lda       u007D,u
                    lsr       ,s
                    bcc       L05D9
                    leax      $01,x
L05EA               lda       #$FF
                    sta       ,s
                    bra       L05FA
L05F0               lda       ,x
                    anda      ,s
                    bne       L0616
                    leax      $01,x
                    leay      -$08,y
L05FA               cmpy      #$0008
                    bhi       L05F0
                    beq       L060C
                    lda       ,s
L0604               lsra
                    leay      -$01,y
                    bne       L0604
                    coma
                    sta       ,s
L060C               lda       ,x
                    anda      ,s
                    bne       L0616
L0612               andcc     #^Carry
                    bra       L0618
L0616               orcc      #Carry
L0618               leas      $01,s
                    puls      pc,y,x,b,a

* Set bits in the allocation bitmap
* Entry: A = Track, B = Sector, Y = number of bits to set
ABMSet              pshs      y,x,b,a
                    lbsr      Initcalc
* Back to old code
                    sta       ,-s
                    bmi       L063A
                    lda       ,x
L062C               ora       ,s
                    leay      -$01,y
                    beq       L0658
                    lsr       ,s
                    bcc       L062C
                    sta       ,x
                    leax      $01,x
L063A               lda       #$FF
                    bra       L0644
L063E               sta       ,x
                    leax      $01,x
                    leay      -$08,y
L0644               cmpy      #$0008
                    bhi       L063E
                    beq       L0658
L064C               lsra
                    leay      -$01,y
                    bne       L064C
                    coma
                    sta       ,s
                    lda       ,x
                    ora       ,s
L0658               sta       ,x
                    leas      $01,s
                    puls      pc,y,x,b,a

Seek2LSN            pshs      u,y,x,b,a
                    lbsr      AbsLSN
                    pshs      a
                    tfr       b,a
                    clrb
                    tfr       d,u
                    puls      b
                    clra
                    tfr       d,x
                    lda       <devpath
                    os9       I$Seek
                    lbcs      WriteErr
                    puls      pc,u,y,x,b,a

                    clra
                    clrb
                    tfr       d,x
                    tfr       d,u
                    lda       <devpath
                    os9       I$Seek
                    leax      <lsn0,u
                    ldy       #DD.DAT
                    lda       <devpath
                    os9       I$Write
                    bcs       Bye
                    rts

* Routine to write various error messages then exiting
WriteErr            leax      >ErrWrit,pcr
                    bra       WritExit
BadName             ldb       #E$BPNam
ShowHelp            equ       *
                    ifne      DOHELP
                    leax      >HelpMsg,pcr
                    else
                    clrb
                    bra       Bye
                    endc
WritExit            pshs      b
                    lda       #$02
                    ldy       #256
                    os9       I$WritLn
                    puls      b
Bye                 os9       F$Exit

* Source/Destination Disk Switch Routine
GetSrc              pshs      u,y,x,b,a
                    clra
                    bra       TstSingl
GetDest             pshs      u,y,x,b,a
                    lda       #$01
TstSingl            tst       <sngldrv
                    beq       L06FD
AskUser             pshs      a
AskUser2            tsta
                    bne       Ask4Dst
Ask4Src             leax      >Source,pcr
                    ldy       #SourceL
                    bra       L06D4
Ask4Dst             leax      >Destin,pcr
                    ldy       #DestinL
L06D4               bsr       DoWrite
                    leax      ,-s
                    ldy       #$0001
                    lda       #$02                read from stderr
                    os9       I$Read              read one char
                    lda       ,s+
                    eora      #'C
                    anda      #$DF
                    beq       L06F9               branch if it's a C
                    leax      >TheBell,pcr
                    ldy       #$0001
                    bsr       DoWrite             else ring the error bell
                    bsr       WriteCR
* BUG FIX:  in certain cases, puls a was being done twice.
                    lda       ,s                  ++
*         puls  a		--
                    bra       AskUser2            ++
*         bne   AskUser		--
L06F9               bsr       WriteCR
                    puls      a
L06FD               puls      pc,u,y,x,b,a

DoWrite             lda       #$01
                    os9       I$WritLn
                    rts

WriteCR             pshs      y,x,a
                    lda       #$01
                    leax      >CarRet,pcr
                    ldy       #80
                    os9       I$WritLn
                    puls      pc,y,x,a

ItsFragd            leax      >BootFrag,pcr
SoftExit            ldb       #$01
                    bra       WritExit

WarnUser            leax      >TWarn,pcr
                    bra       SoftExit

                    ifgt      Level-1
L0724               leax      >CantRel,pcr
                    lbra      WritExit
                    endc

                    emod
eom                 equ       *
                    end
