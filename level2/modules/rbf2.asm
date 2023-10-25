********************************************************************
* RBF - Random Block File Manager
*
* $Id$
*
* Modified for 6309 Native mode by Bill Nobel, L. Curtis Boyle & Wes Gale
*
* This also contains the patch for un-deleting files
*
* Undocumented SetStt/GetStt calls:
*
*     GetStt:
*         SS.FD ($0F) - Returns a file descriptor
*                          Entry: R$A=Path #
*                                 R$B=SS.FD ($0F)
*                                 R$X=Pointer to a 256 byte buffer
*                                 R$Y=# bytes of FD required
*         SS.FDInf ($20) - Directly reads a file descriptor from anywhere
*                          on drive.
*                          Entry: R$A=Path #
*                                 R$B=SS.FDInf ($20)
*                                 R$X=Pointer to a 256 byte buffer
*                                 R$Y= MSB - Length of read
*                                      LSB - MSB of logical sector #
*                                 R$U= LSW of logical sector #
*     SetStt:
*         SS.FD ($0F) - Writes a file descriptor
*                          Entry: R$A=Path #
*                                 R$B=SS.FD ($0F)
*                                 R$X=Pointer to a maximum 256 byte buffer
*                                 R$Y=# bytes of FD to write
*         SS.Ticks ($10) - Set # ticks to wait for record lock release
*                          Entry: R$A=Path #
*                                 R$B=SS.Ticks ($10)
*                                 R$X=# Ticks to wait
*         SS.Lock ($11) - Force Lock/Release of a file.
*                         Locks from current position to a specified size
*                          Entry: R$A=Path #
*                                 R$B=SS.Lock ($11)
*                                 R$X=LSW of end byte position
*                                 R$U=MSW of end byte position
*         SS.Attr ($1C) - Allows changing of file/directory attributes
*                         If changing directory attribute it scans to
*                         see if directory is empty.
*                          Entry: R$A=Path #
*                                 R$B=SS.Attr ($1C)
*                                 R$X= LSB - File attributes
*         SS.RsBit ($1E) - Reserve bitmap sector (doesn't allocate)
*                          Locks the bitmap sector from other programs
*                          so they cannot allocate in it.
*                          Useful when working in allocation map.
*                          Entry: R$A=Path #
*                                 R$B=SS.RsBit ($1E)
*                                 R$X= LSB - Sector # of bitmap
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* ???    Started putting in comments from buggy 1.09    ??? 93/09/19
*        code
* ???    Fixed WP error bug on file delete              ??? 93/09/19
*        Fixed FD read error bug in delete
* ???    Fixed long overdue LHA bug                     ??? 94/07/15
*        Modified M$Exec driver calls @ L11EB to use
*        V$DRIVEX
* ???    Changed L11EB to just PSHS/PULS A,X,PC         ??? 94/07/27
*        instead of D,X,PC (saves 2 cycles per
*        driver call)
*        Changed BRA L12C6 @ L128E to PULS PC,U,X
* ???    NitrOS-9 2.00 distribution                     ??? ??/??/??
*  35    Fixed FD.SEG bug                               GH  ??/??/??
*        Folded RBF 30 comments into this version       BGP 03/04/21
*  36    Fix for LSN0 DD.TOT=0 lockout problem          RVH 03/05/01

                    nam       RBF
                    ttl       Random Block File Manager

                    ifp1
                    use       defsfile
                    endc

rev                 set       $01
ty                  set       FlMgr
                    ifne      H6309
lg                  set       Obj6309
                    else
lg                  set       Objct
                    endc
tylg                set       ty+lg
atrv                set       ReEnt+rev
edition             set       36

                    org       $00
size                equ       .

                    mod       eom,name,tylg,atrv,start,size

name                fcs       /RBF/
                    fcb       edition

*L0012    fcb   DRVMEM		(inlined RBF36)


****************************
*
* Main entry point for RBF
*
* Entry: Y = Path descriptor pointer
*        U = Register stack pointer

start               bra       Create
                    nop
                    lbra      Open
                    lbra      MakDir
                    lbra      ChgDir
                    lbra      Delete
                    lbra      Seek
                    lbra      Read
                    lbra      Write
                    lbra      ReadLn
                    lbra      WriteLn
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Close


*
* I$Create Entry Point
*
* Entry: A = access mode desired
*        B = file attributes
*        X = address of the pathlist
*
* Exit:  A = pathnum
*        X = last byte of pathlist address
*
* Error: CC Carry set
*        B = errcode
*
Create              pshs      y                   Preserve path desc ptr
                    leas      -$05,s              Make 5 byte buffer on stack
                    ifne      H6309
                    aim       #^DIR.,R$B,u
                    else
                    lda       R$B,u               force directory bit off
                    anda      #^DIR.
                    sta       R$B,u
                    endc
                    lbsr      FindFile            try & find it in directory
                    bcs       Creat47             branch if doesn't exist

* File already exists
                    ldb       #E$CEF              else exists error
Creat47             cmpb      #E$PNNF             not found?
                    bne       Creat7E

* File doesn't exist, create it
                    cmpa      #PDELIM             full path?
                    beq       Creat7E             yes, return
                    pshs      x                   preserve filename pointer
                    ldx       PD.RGS,y            get register stack pointer
                    stu       R$X,x               save updated pathname pointer
* These 4 did have < in front, made 3 byte cmnds but some are 2!
                    ldb       PD.SBP,y            get physical sector # of segment list
                    ldx       PD.SBP+1,y
                    lda       PD.SSZ,y            get size of segment list in bytes
                    ldu       PD.SSZ+1,y
                    pshs      u,x,b,a             preserve it all
                    ldx       PD.RGS,y            get register stack pointer
* Calculate default file size, if enabled
* This sets D to 0 if bit 5 of R$A is NOT set.  If bit 5 of R$A is set
* when called, register Y will contain a default file size
                    lda       R$A,x               get file mode (read/write/update)
                    clrb
                    anda      #PEXEC.             bit 5 set?
                    beq       Creat6E             no, skip ahead
                    ldd       R$Y,x               get default file size
* account for FD sector, I think.
* changed from addd #1, bcc, ldd #$FFFF.
* The INCD gets D=$0000 (and CC.Z set) if it overflows from $FFFF->$0000
* then if it's zero, a DECD forces it to be $FFFF
Creat6E             addd      #1                  above 64k in size? (bug fix, thanks Gene K.)
                    bcc       Creat75             no, skip ahead: changed from BCC
                    ldd       #$FFFF              force it to 64k
Creat75             lbsr      FatScan             find the space in the allocation map
                    bcc       Creat83             got it, skip ahead
                    leas      6,s                 purge segment sizes from stack
* and fall through to routine which returns with an error.

Creat7C             leas      2,s                 purge user's pathname pointer
Creat7E             leas      5,s                 purge local data
                    lbra      ErMemRtn            return with error

* Create the file
Creat83             std       $0B,s               save segment size
                    ldb       PD.SBP,y            save segment physical sector # in path desc.
                    ldx       PD.SBP+1,y          starting LSN
                    stb       $08,s               on stack too
                    stx       $09,s
                    puls      u,x,b,a             restore segment physical sector # & sizes
                    stb       PD.SBP,y            save it as current
                    stx       PD.SBP+1,y
                    sta       PD.SSZ,y
                    stu       PD.SSZ+1,y
* Find empty slot in directory sector for new file
                    ifne      H6309
                    ldq       PD.DCP,y            get directory entry pointer for new file
                    stq       PD.CP,y             save it as current file pointer
                    else
                    ldd       PD.DCP,y
                    std       PD.CP,y
                    ldd       PD.DCP+2,y
                    std       PD.CP+2,y
                    endc
                    lbsr      L0957               move entry into sector buffer
                    bcs       CreatB5
CreatAC             tst       ,x                  file exist here already?
                    beq       CreatC7             no, found empty slot, skip ahead
                    lbsr      L0942               point to next entry
                    bcc       CreatAC             try again
CreatB5             cmpb      #E$EOF              end of directory?
                    bne       Creat7C             no, return error
* Create the directory entry for new file
                    ldd       #DIR.SZ             get size of directory entry
                    lbsr      Writ599             add it to size of directory
                    bcs       Creat7C             out of alloc?
                    lbsr      MDir263             set file size in file descriptor
                    lbsr      L0957               read in a directory sector
CreatC7             leau      ,x                  point to directory entry
                    lbsr      Creat169            clear it out
                    puls      x                   restore pathname pointer
                    os9       F$PrsNam            parse it to get filename
                    bcs       Creat7E
                    cmpb      #29                 length of name right size?
                    bls       CreatD9             yes, skip ahead
                    ldb       #29                 else force it to 29 chars
CreatD9             clra                          move length to Y
                    tfr       d,y
                    lbsr      Writ5CB             move name of file to directory entry
                    tfr       y,d                 move length of name to D
                    ldy       $05,s               restore PDpointer
                    decb                          subtract 1 off length
                    ifne      H6309
                    oim       #$80,b,u            set high bit on last char of name
                    else
                    lda       b,u
                    ora       #$80
                    sta       b,u
                    endc
                    ldb       ,s                  get logical sector # of file desc
                    ldx       $01,s
                    stb       DIR.FD,u            save it into directory entry
                    stx       DIR.FD+1,u
                    lbsr      L1205               flush sector to disk
                    bcs       Creat151
* Setup file descriptor
                    ldu       PD.BUF,y            get sector buffer pointer
                    bsr       Creat170            clear it out
                    lda       #FDBUF              get file descriptor in buffer flag
                    sta       PD.SMF,y            save it as current sector buffer state
                    ldx       PD.RGS,y            get register stack pointer
                    lda       R$B,x               get file attributes
                    sta       FD.ATT,u            save it as current attributes
                    ldx       <D.Proc             get process pointer
                    ldd       P$User,x            get user #
                    std       FD.OWN,u            save creation user
                    lbsr      L02D1               place date & time into file descriptor
                    ldd       FD.DAT,u            get date last modified
                    std       FD.Creat,u          save it as creation date (since we just made it)
                    ldb       FD.DAT+2,u
                    stb       FD.Creat+2,u
                    ldb       #$01                get link count
                    stb       FD.LNK,u
                    ldd       3,s                 get segment size in sectors
                    ifne      H6309
                    decd      is                  it 1?
                    else
                    subd      #$0001
                    endc
                    beq       Creat131            yes, skip ahead
                    leax      FD.SEG,u            point to the start of the segment list
                    std       FDSL.B,x            save segment size
                    ldd       1,s                 get LSW of physical sector # of seg start
                    addd      #1                  we need to carry below, fr the adcb! (bug fix, thanks Gene K.)
                    std       FDSL.A+1,x          save LSW
                    ldb       ,s                  get MSB of physical sector # of segment start
                    adcb      #$00                need carry status of addd above
                    stb       FDSL.A,x            save MSB
Creat131            ldb       ,s                  get p hysical sector # of segment start
                    ldx       1,s
                    lbsr      L1207               flush file descriptor to disk
                    bcs       Creat151
                    lbsr      L0A90               sort out any ocnflict for this sector
                    stb       PD.FD,y             save file descriptor physical sector # to pd
                    stx       PD.FD+1,y
                    lbsr      L0A2A               update file/record lock for this sector
                    leas      $05,s               purge sector buffer from stack
                    ldx       PD.Exten,y          get path extension pointer
                    lda       #EofLock            set the file to EOF lock
                    sta       PE.Lock,x
                    bra       Open1CC
* Error on fD write to disk
Creat151            puls      u,x,a               restore segment start & size
                    sta       PD.SBP,y            put it into path descriptor
                    stx       PD.SBP+1,y
                    clr       PD.SSZ,y
                    stu       PD.SSZ+1,y
                    pshs      b                   save error code
                    lbsr      ClrFBits
                    puls      b                   restore error code
RtnMemry            lbra      ErMemRtn            return with error

* Clear out directory entry
* Entry: U = Directory entry pointer
Creat169
                    ifne      H6309
                    ldw       #DIR.SZ             get size of directory entry (name & LSN of FD)
                    else
                    ldd       #DIR.SZ             A = 0 so clear loop passes once +BGP+
                    endc
                    bra       Creat174            clear it out

* Clear out sector buffer
* Entry: U = Sector buffer pointer
Creat170
                    ifne      H6309
                    ldw       #$0100              get size of sector buffer
                    else
                    clrb
                    endc
                    lbsr      SSBits              +BGP+
Creat174            pshs      u,x                 preserve regs
                    ifne      H6309
                    leax      <Creat170+3,pcr     point to NULL byte
CreatL              tfm       x,u+                clear buffer
                    deca                          +BGP+
                    bpl       CreatL              +BGP+
                    else
l1                  clr       ,u+
                    decb
                    bne       l1
                    deca                          +BGP+
                    bpl       l1                  +BGP+
                    endc
                    puls      pc,u,x              restore & return


*
* I$Open Entry Point
*
* Entry: A = access mode desired
*        X = address of the pathlist
*
* Exit:  A = pathnum
*        X = last byte of pathlist address
*
* Error: CC Carry set
*        B = errcode
*
Open                pshs      y                   preserve path descriptor pointer
                    lbsr      FindFile            try & find the file in current directory
                    bcs       RtnMemry            couldn't find it, return error
                    ldu       PD.RGS,y            get register stack pointer
                    stx       R$X,u               save updated pathname pointer
                    ldd       PD.FD+1,y           do we have a file descriptor?
                    bne       Open1BB
                    lda       PD.FD,y
                    bne       Open1BB             yes, skip ahead
* File descriptor doesn't exist
                    ldb       PD.MOD,y            get current file mode
                    andb      #DIR.               is it a directory?
                    lbne      Clos29D             yes, return not accessible eror
                    std       PD.SBP,y            set segment physical start to 0
                    sta       PD.SBP+2,y
                    std       PD.SBL,y            do logical as well
                    sta       PD.SBL+2,y
                    ldx       PD.DTB,y            get pointer to drive table
                    lda       DD.TOT+2,x          get total # sectors on drive
* resave nonzero DD.TOT here and recopy
OpenFix             equ       *
                    std       PD.SIZ+2,y          copy it to file size (B=0)
                    sta       PD.SSZ+2,y          copy it to segment size as well
                    ldd       DD.TOT,x
                    std       PD.SIZ,y
                    std       PD.SSZ,y
* BUG FIX: handle special case of DD.TOT=0 in LSN0 which blocks
* all subsequent accesses.  NOTE: since we can only access LSN0
* for any non-zero value, set DD.TOT=1 to avoid NOT READY error.
                    bne       OpenRet             MSW nonzero, OK
                    lda       DD.TOT+2,x          MSW=0, check LSB
                    bne       OpenRet             LSB nonzero, OK
                    inca                          DD.TOT=0, make it 1
                    sta       DD.TOT+2,x          fix drive table
                    bra       OpenFix             and resave (B=0)
OpenRet             puls      pc,y                restore & return

Open1BB             lda       PD.MOD,y            get file mode
                    lbsr      ChkAttrs            can user access file?
                    bcs       RtnMemry            no, return no permission error
                    bita      #WRITE.             open for write?
                    beq       Open1CC             no, skip ahead
                    lbsr      L02D1               update last date modified to current
                    lbsr      L11FD               update file descriptor on disk
Open1CC             puls      y                   restore path descriptor pointer

* Update the path descriptor from the FD sector pointed to by U
Open1CE
                    ifne      H6309
                    clrd                          get a 16 bit zero value
                    else
                    clra
                    clrb
                    endc
                    std       PD.CP+2,y           set seek pointer to start of file
                    std       PD.CP,y
                    std       PD.SBL,y            set segment start
                    sta       PD.SBL+2,y
                    sta       PD.SSZ,y            set segment size
                    lda       FD.ATT,u            get file attributes
                    sta       PD.ATT,y            put it into path descriptor
                    ldd       FD.SEG,u            get the file's segment start sector #
                    std       PD.SBP,y
                    lda       FD.SEG+2,u
                    sta       PD.SBP+2,y
                    ldd       FD.SEG+FDSL.B,u
                    std       PD.SSZ+1,y
* ldq   FD.SIZ,u
                    ldd       FD.SIZ,u            get file size
                    ldx       FD.SIZ+2,u
                    ldu       PD.Exten,y          get path extension pointer
                    cmpu      PE.Confl,u          head of the conflict tree?
                    beq       Open209             yes, skip ahead
                    ldu       PE.Confl,u          get the conflicting path ext. pointer
                    ldu       PE.PDptr,u          get back pointer to the PD of conflicting process
* ldq PD.SIZ,u
                    ldd       PD.SIZ,u            get his size instead
                    ldx       PD.SIZ+2,u
* stq PD.SIZ,y
Open209             std       PD.SIZ,y            set file size in path descriptor of caller
                    stx       PD.SIZ+2,y
                    clr       PD.SMF,y            clear the state flags
                    rts                           return


*
* I$MakDir Entry Point
*
* Entry: X = address of the pathlist
*
* Exit:  X = last byte of pathlist address
*
* Error: CC Carry set
*        B = errcode
*
MakDir              lbsr      Create              create a file descriptor
                    bcs       MDir261             problem, return error
                    lda       PD.ATT,y            get attributes
                    ora       #SHARE.             set shareable bit
                    lbsr      ChkAttrs            can user access directory?
                    bcs       MDir261             no, return error
                    ldd       #DIR.SZ*2           get default directory size (for '.' & '..')
                    std       PD.SIZ+2,y          save it in path descriptor (MSW set to 0)
                    bsr       MDir273             write out file descriptor
                    bcs       MDir261             error, return
                    lbsr      L0C6F
                    bcs       MDir261
                    lbsr      RdFlDscr            read in file descriptor
                    ldu       PD.BUF,y            get pointer to file descriptor
                    ifne      H6309
                    oim       #DIR.,FD.ATT,u      set directory bit in attributes
                    else
                    lda       FD.ATT,u
                    ora       #DIR.
                    sta       FD.ATT,u
                    endc
                    bsr       MDir266
                    bcs       MDir261
                    lbsr      Creat170            clear out sector
                    ldd       #$2EAE              get directory entry name for current & parent dir
                    std       ,u                  save parent name
                    stb       DIR.SZ,u            save current name
* This is smaller and faster than the old method
*         ldq   PD.DFD-1,y	get directory FD pointer into low 24-bits of Q
*         clra			make sure high byte is zero
*         stq   DIR.FD-1,u	save in the dir: '.' and '..' have <28 char names
                    lda       PD.DFD,y
                    sta       DIR.FD,u
                    ldd       PD.DFD+1,y
                    std       DIR.FD+1,u
*         ldq   PD.FD-1,y	get current FD into lower 24-bits of Q
*         clra			ensure high byte is zero
*         stq   DIR.SZ+DIR.FD-1,u	save in the directory
                    lda       PD.FD,y
                    sta       DIR.SZ+DIR.FD,u
                    ldd       PD.FD+1,y
                    std       DIR.SZ+DIR.FD+1,u

                    lbsr      L1205               flush new directory ssector to disk
MDir261             bra       Rt100Mem            return to system all ok

* Set new file size in file descriptor
* Entry: None
* Exit : New file size set in file descriptor on disk
MDir263             lbsr      RdFlDscr            read in file descriptor
MDir266             ldx       PD.BUF,y            get sector pointer
                    ifne      H6309
                    ldq       PD.SIZ,y            get current file size
                    stq       FD.SIZ,x            save it in file descriptor
                    else
                    ldd       PD.SIZ,y
                    std       FD.SIZ,x
                    ldd       PD.SIZ+2,y
                    std       FD.SIZ+2,x
                    endc
                    clr       PD.SMF,y            clear state flags
MDir273             lbra      L11FD


*
* I$Close Entry Point
*
* Entry: A = path number
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
Close               clra
                    tst       PD.CNT,y            any open paths?
                    bne       Clos29C             yes, return
                    lbsr      L1237               flush current sector of needed
                    bcs       Rt100Mem            error, skip ahead
                    ldb       PD.MOD,y            get access mode
                    bitb      #WRITE.             is it write?
                    beq       Rt100Mem            no, skip ahead
                    ldd       PD.FD,y
                    bne       Clos290
                    lda       PD.FD+2,y
                    beq       Rt100Mem
Clos290             bsr       MDir263             set new file size in file descriptor
                    lbsr      Gst5E5              reached EOF?
                    bcc       Rt100Mem            no, skip ahead
                    lbsr      L0EFE
                    bra       Rt100Mem            skip ahead
Clos29C             rts                           return
* Return file not accessible error
Clos29D             ldb       #E$FNA
ErMemRtn            coma
Clos2A0             puls      y

* Generalized return to system
Rt100Mem            pshs      b,cc                preserve error status
                    ldu       PD.BUF,y            get sector buffer pointer
                    beq       RtMem2CF            none, skip ahead
                    lbsr      SSize               +BGP+
*         ldd   #$0100		get size of sector buffer -BGP-
                    os9       F$SRtMem            return the memory to system
                    ldx       PD.Exten,y          get path extension pointer
                    beq       RtMem2CF            none, return
                    lbsr      L0A90               scan conflict list?
                    lda       PE.PE,x             return path extension to system
                    ldx       <D.PthDBT
                    os9       F$Ret64
RtMem2CF            puls      pc,b,cc             restore error status & return

* Place date & time into file descriptor
L02D1               lbsr      RdFlDscr            read in file descriptor sector
                    ldu       PD.BUF,y            get pointer to it
                    lda       FD.LNK,u            get link count
                    ldx       <D.Proc             get current process pointer
                    pshs      x,a                 preserve 'em
                    ldx       <D.SysPrc           switch to system process descriptor
                    stx       <D.Proc
                    leax      FD.DAT,u            point to date last modified
                    os9       F$Time              put currenttime there
* Gene Heskett's STUPID "LDA #$01, STA $00FF,u" CRAP went here. DAMN DAMN DAMN
* He's NEVER getting the RBF source again!
                    puls      x,a                 restore link count & current process
                    stx       <D.Proc
                    sta       FD.LNK,u
                    rts                           return


*
* I$ChgDir Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ChgDir              pshs      y                   preserve path descriptor pointer
                    ifne      H6309
                    oim       #$80,PD.MOD,y       ensure the directory bit is set
                    else
                    lda       PD.MOD,y
                    ora       #$80
                    sta       PD.MOD,y
                    endc
                    lbsr      Open                go open the directory
                    bcs       Clos2A0             exit on error
                    ldx       <D.Proc             get current process pointer
                    ldu       PD.FD+1,y           get LSW of file descriptor sector #
                    ldb       PD.MOD,y            get current file mode
                    bitb      #UPDAT.             read or write mode?
                    beq       CD30D               no, skip ahead
* Change current data dir
                    ldb       PD.FD,y
                    stb       P$DIO+3,x
                    stu       P$DIO+4,x
CD30D               ldb       PD.MOD,y            get current file mode
                    bitb      #EXEC.              is it execution dir?
                    beq       CD31C               no, skip ahead
* Change current execution directory
                    ldb       PD.FD,y
                    stb       P$DIO+9,x
                    stu       P$DIO+10,x
CD31C               clrb                          clear errors
                    bra       Clos2A0             return to system


*
* I$Delete Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
* NOTE: Bug for write protected disk has been fixed - 93/09/19
*
Delete              pshs      y                   preserve path descriptor pointer
                    lbsr      FindFile            does the file exist?
                    bcs       Clos2A0             no, return error
                    ldd       PD.FD+1,y           do we have a file descriptor?
                    bne       Del332              yes, skip ahead
                    tst       PD.FD,y
                    ifne      H6309
                    beq       Clos29D             no, return not accessible error
                    else
                    lbeq      Clos29D
                    endc
Del332              lda       #SHARE.+WRITE.      get attributes to check
                    lbsr      ChkAttrs            can user delete ths file?
                    lbcs      Clos2A0             no, return error
                    ldu       PD.RGS,y            get registered stack pointer
                    stx       R$X,u               save updated pathname pointer
                    lbsr      RdFlDscr            read in file descriptor
* BUG FIX: Below used to read 'lbcs L03D4' which expects the file descriptor
*          sector # & a temporary buffer to be stored on the stack but it
*          isn't there yet.  Restored back to RBF 28 error handling
*         lbcs  L02B2		error, return to system (FD read error fix)
                    lbcs      Del3D4              error, rturn to system (FD read error fix)
                    ldx       PD.BUF,y            get pointer to the file descriptor
                    dec       FD.LNK,x            decrement link count
                    beq       Del358              down to zero, delete the file descriptor
                    lbsr      L11FD               write updated file descriptor
                    pshs      u,x,b
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       $03,s
                    bra       Del39F


* Return Sector Size bits
* Entry:
*    Y = path desc ptr
* Exit:
*    A = sector size (0 = 256, 1 = 512, 2 = 1024, 3 = 2048)
SSBits              lda       PD.TYP,y            get type byte
                    anda      #TYP.SSM            mask out non-sector size bits
                    lsra                          shift bits into place
                    rts


* Sector Size mask table
SSTable             fcb       $01,$02,$04,$08


* Return Sector Size
* Entry:
*    Y = path desc ptr
* Exit:
*    D = sector size (256, 512, 1024, 2048)
SSize               pshs      x
                    leax      SSTable,pc
                    bsr       SSBits
                    lda       a,x
                    clrb
                    puls      x,pc


* RBF30 start
Del358              ldb       PD.FD,y             get LSN of file descriptor
                    ldx       PD.FD+1,y
                    pshs      u,x,b               preserve 'em
                    bsr       SSize               +BGP+
*         ldd   #$0100		allocate a temporary sector buffer -BGP-
                    os9       F$SRqMem
                    bcc       Del36C              got it, skip ahead
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    bra       Del37A              return with eror

Del36C              stu       $03,s               save pointer to sector buffer
                    ldx       PD.BUF,y
                    ifne      H6309
                    ldw       #$0100
DelCpy              tfm       x+,u+               copy the sector
                    deca                          +BGP+
                    bne       DelCpy              +BGP+
                    else
                    clrb
                    pshs      a                   +BGP+
DelLoop             lda       ,x+
                    sta       ,u+
                    decb
                    bne       DelLoop
                    dec       ,s                  +BGP+
                    bne       DelLoop             +BGP+
                    puls      a                   +BGP+
                    endc
                    ldd       $03,s
Del37A              std       $03,s               save buffer pointer to U on stack
* Start back into RBF28 code again
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       PD.SIZ,y            set file size to zero
                    std       PD.SIZ+2,y
                    lbsr      L0EFE               set the file size to PD.SIZ
                    bcs       Del3EF
                    ldb       PD.FD,y             grab file descriptor sector number
                    ldx       PD.FD+1,y
                    stb       PD.SBP,y            copy it to the segment beginning sector number
                    stx       PD.SBP+1,y
                    ldx       PD.BUF,y            point to the buffer
* RBF34
* LDD $13,X    : FD.SEG+3, grab the size of the FIRST segment of the file
* addd #$0001
* THEN std PD.SSZ+1,y
*
* Why?  RBF automatically makes the FIRST SEGMENT of the file fill the rest
* of the cluster that was allocated for the file descriptor.
* Why not LDX PD.DTB,y  LDD DD.BIT,x  ???
*
* Gene H: My problem with this fix from rbf28 is in proving to me
* $13,x is the correct location to read! I can't seem to find
* the defines to match the $13,x address.
*         ldd   FD.SEG+FDSL.B,x	grab the size of the first segment
                    ldd       <$13,x              this code is REQUIRED for multiple
                    ifne      H6309
                    incd                          sector/cluster operation, don't remove!
                    else
                    addd      #$0001              sector cluster operation, DO NOT REMOVE!
                    endc
                    std       PD.SSZ+1,y
                    lbsr      ClrFBits            delete a segment
Del39F              bcs       Del3EF
                    lbsr      L1237               flush the sector
                    lbsr      L0A90
                    lda       PD.DFD,y
                    sta       PD.FD,y
                    ldd       PD.DFD+1,y
                    std       PD.FD+1,y
                    lbsr      RdFlDscr            get the file descriptor
                    bcs       Del3EF
                    lbsr      L0A2A
                    ldu       PD.BUF,y
                    lbsr      Open1CE             update PD entries from FD entries
                    ifne      H6309
                    ldq       PD.DCP,y            get current directory entry pointer
                    stq       PD.CP,y             save it as current pointer
                    else
                    ldd       PD.DCP,y
                    std       PD.CP,y
                    ldd       PD.DCP+2,y
                    std       PD.CP+2,y
                    endc
                    lbsr      L0957               read in the directory sector
                    bcs       Del3EF
                    clr       ,x                  clear first byte of filename in directory entry
                    lbsr      L1205               flush the sector to disk
* RBF30 start
Del3D4              ldu       $03,s               get temporary sector buffer pointer
* the patch at Del3EF-3F9 munged the stack for this one - GH
                    beq       Del3F9              none allocated, return to process
                    ldb       ,s                  get the old file descriptor logical sector #
                    ldx       $01,s
                    stb       PD.FD,y             put it back into path descriptor
                    stx       PD.FD+1,y
                    ldx       PD.BUF,y            get current sector buffer pointer
                    stx       1,s                 save it a sec
                    stu       PD.BUF,y            put original sector pointer into path descriptor
                    lbsr      L11FD               write the old file descriptor to disk
                    ldu       1,s                 get temporary sector pointer
                    stu       PD.BUF,y            save it as current
Del3EF              pshs      b,cc                preserve rror status & code if any (WP bug fix - raises stack offsets+2)
                    ldu       $05,s               get temporary sector buffer pointer (this was a 3)
                    beq       Del3F5              didn't allocate one, skip ahead (different, new label! no mem to return)
                    lbsr      SSize               +BGP+
*         ldd   #$0100		get size of it -BGP-
                    os9       F$SRtMem            return the memory back to the system
Del3F5              puls      b,cc                restore error status & code (WP bug fix)
Del3F9              leas      5,s                 purge stack
* Start back into RBF28 code
                    lbra      Clos2A0             return to system


*
* I$Seek Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
Seek                ldb       PD.SMF,y            get state flags
                    bitb      #SINBUF             do we have a sector in buffer?
                    beq       Seek417             no, skip ahead
                    lda       R$X+1,u             calculate if we need a new sector
                    ldb       R$U,u
                    subd      PD.CP+1,y
                    bne       Seek412
                    lda       R$X,u
                    sbca      PD.CP,y
                    beq       Seek41B             no need to get another sector, skip ahead
Seek412             lbsr      L1237               flush the current sector to disk
                    bcs       Seek41F
Seek417             ldd       R$X,u               get & set new file pointer
                    std       PD.CP,y
Seek41B             ldd       R$U,u
                    std       PD.CP+2,y
Seek41F             rts                           return


*
* I$ReadLn Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
ReadLn              bsr       RdLn463             check if record locked for amount to be read
                    beq       RdLn446             zero bytes to read, return
                    bsr       RdLn447
                    pshs      u,y,x,b,a
                    exg       x,u
                    ifne      H6309
                    tfr       0,y                 smaller, same speed as LDY #$0000
                    else
                    ldy       #$0000
                    endc
                    lda       #$0D                a carriage return
RdLn430             leay      1,y                 go up one byte
                    cmpa      ,x+                 is it a CR?
                    beq       RdLn439             yes, we're done
                    decb                          count down
                    bne       RdLn430             until done one sector, at least
RdLn439             ldx       6,s                 get old U
                    bsr       RdLn49B             move bytes from the system to user
                    sty       $0A,s               save Y on-stack, above calling routine????
                    puls      u,y,x,b,a           restore registers
                    ldd       $02,s               get old saved Y from above
*         addr  d,x
                    leax      d,x                 point to how many bytes we've read
RdLn446             rts                           and exit

RdLn447             lbsr      Read4D3             do reading, calling this routine back again
                    leax      -1,x                back up a byte
                    lbsr      L097F               get a byte from another task (F$LDABX)
                    cmpa      #$0D                is it a CR?
                    beq       RdLn459             yes, skip ahead
                    ldd       $02,s               check data saved on-stack???
                    bne       Read4D9             if not zero, skip ahead
RdLn459             ldu       PD.RGS,y            grab caller's register stack
                    ldd       R$Y,u               get number of bytes to read
                    subd      $02,s               take out data read last sector??
                    std       R$Y,u               save as data bytes to read
                    bra       Read4C0             skip ahead

* Calculate if read will be record locked with another process
* Entry: U=Register stack pointer
RdLn463             ldd       R$Y,u               get requested read length
                    lbsr      L0B0C               record locked with somebody else?
                    bcs       RdLn497             yes, return deadlock error
                    ldd       R$Y,u               get requested read length
                    bsr       RdLn473             calculate if we will have an EOF error
                    bcs       RdLn497             we did, return error
                    std       R$Y,u               save # bytes available
                    rts                           return

* Calculate if read length will overrun file length
* Entry: D=Requested # bytes to read from file
* Exit : D=# bytes available
RdLn473             pshs      d                   preserve length
                    ifne      H6309
                    ldq       PD.SIZ,y            get current file size
                    subw      PD.CP+2,y           subtract off LSW of current byte pointer
                    tfr       w,x                 save it in the old register
                    sbcd      PD.CP,y             subtract off current byte pointer
                    else
                    ldd       PD.SIZ+2,y
                    subd      PD.CP+2,y
                    tfr       d,x
                    ldd       PD.SIZ,y
                    sbcb      PD.CP+1,y
                    sbca      PD.CP,y
                    endc
                    bcs       RdLn494             it will overrun, return EOF error
                    bne       RdLn491             some bytes left, return OK
                    tstb
                    bne       RdLn491
                    cmpx      ,s                  do we have enough bytes?
                    bhs       RdLn491             yes, return OK
                    stx       ,s                  save # bytes available
                    beq       RdLn494             it's 0, return EOF error
RdLn491             clrb                          clear error status
                    puls      pc,b,a              retrieve # bytes & return
* Return EOF error
RdLn494             comb                          set carry for error
                    ldb       #E$EOF              get error code
RdLn497             leas      $02,s               purge length off stack
                    bra       Read4C5             return

* Move bytes from system to user
* Entry: X=Source pointer
*        Y=Byte count
*        U=Destination pointer
RdLn49B             pshs      x
                    ldx       <D.Proc             get current process pointer
                    lda       <D.SysTsk           get source task #
                    ldb       P$Task,x            get destination task #
                    puls      x
                    os9       F$Move              move 'em
                    rts                           return


*
* I$Read Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
Read                bsr       RdLn463             record locked?
                    beq       Read4BB             no, allow it
                    bsr       Read4BC             do reading
Read4AF             pshs      u,y,x,b,a           save data on the stack
                    exg       x,u
                    tfr       d,y
                    bsr       RdLn49B             move bytes from system to user
                    puls      u,y,x,b,a           restore registers
*         addr  d,x
                    leax      d,x                 point to end of data copied?
Read4BB             rts

Read4BC             bsr       Read4D3             do some reading/writing
                    bne       Read4D9             not done, continue
Read4C0             clrb
Read4C1             leas      -2,s                clear out crap on the stack
Read4C3             leas      $0A,s
* Error processor for read & write
Read4C5             pshs      b,cc                preserve error status
                    lda       PD.MOD,y            get file mode
                    bita      #WRITE.             was it write?
                    bne       Read4D0             yes, return
                    lbsr      L0B02               clear lock status, and send signals
Read4D0             puls      b,cc,pc             restore & return

* do reading/writing
Read4D3             ldd       R$X,u               get caller's buffer pointer
                    ldx       R$Y,u               get length of read
                    pshs      x,b,a               preserve 'em
Read4D9             lda       PD.SMF,y            get stat flags
                    bita      #SINBUF             sector in buffer/
                    bne       Read4F9             yes, read it
                    tst       PD.CP+3,y           read pointer on even sector?
                    bne       Read4F4             no, skip ahead
                    tst       $02,s               MSB of length have anything?
                    beq       Read4F4             no, skip ahead
                    leax      >Writ571,pcr        WritLn or ReadLn?
                    cmpx      $06,s               check the stack
                    bne       Read4F4             skipahead
                    lbsr      L1098               find a segment
                    bra       Read4F7

Read4F4             lbsr      L1256
Read4F7             bcs       Read4C1
Read4F9             ldu       PD.BUF,y            get sector buffer pointer
                    clra
                    ldb       PD.CP+3,y
*         addr  d,u
                    leau      d,u                 point to offset within the buffer
                    negb                          get D=number of byte left to read in the sector?
                    sbca      #$FF                not quite sure what this is...
                    ldx       ,s                  grab caller's buffer pointer
                    cmpd      $02,s               check bytes left in sector against number to read
                    bls       Read50C             lower, OK
                    ldd       $02,s               grab number of bytes to read
Read50C             pshs      b,a                 save
                    jsr       [$08,s]             call our calling routine!
                    stx       $02,s               save new address to write to on-stack
                    ifne      H6309
                    aim       #^BufBusy,PD.SMF,y
                    else
                    ldb       PD.SMF,y
                    andb      #^BufBusy
                    stb       PD.SMF,y
                    endc
                    ldb       $01,s               get LSB of bytes read
                    addb      PD.CP+3,y           add it to current pointer
                    stb       PD.CP+3,y           save new file position
                    bne       Read530             didn't grab whole sector, skip ahead
                    lbsr      L1237               flush the sector
                    inc       PD.CP+2,y           add
                    bne       Read52E
                    inc       PD.CP+1,y
                    bne       Read52E
                    inc       PD.CP,y
Read52E             bcs       Read4C3
Read530             ldd       $04,s               grab number of bytes to read/write
                    subd      ,s++                take out number we've read/written
                    std       $02,s               save on-stack
                    jmp       [$04,s]             go back to calling routine with D,X on-stack


*
* I$WritLn Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
WriteLn             pshs      y                   save PD pointer
                    clrb
                    ldy       R$Y,u               grab size of data to write
                    beq       WtLn55E             exit if none
                    ldx       <D.Proc             get process descriptor pointer
                    ldb       P$Task,x            grab task number
                    ldx       R$X,u               and where to get data from
* ATD: Could make this quite a bit larger, and probably faster, by doing the
* PipeMan-style copy 32 bytes onto the stack via F$Move, and check that.
* Doing F$LDABX for a lot of data is _really_ slow.  PipeMan test indicate
* that it could probably double in speed...
WtLn547             leay      -$01,y              back up one byte
                    beq       WtLn55E             if done, exit
                    os9       F$LDABX             grab one byte from the user
                    leax      $01,x               go up a byte
                    cmpa      #$0D                is it a CR?
                    bne       WtLn547             no, keep it up until done
                    tfr       y,d                 get number of bytes left
                    nega                          \
* a negd was tried here, but may have caused runaway writes>64k
                    negb                          /	invert it
                    sbca      #$00
                    addd      R$Y,u               add to bytes to write
                    std       R$Y,u               save new number of bytes to write
WtLn55E             puls      y                   restore PD pointer, and fall through to Write


*
* I$Write Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
Write               ldd       R$Y,u               get size of write
                    lbsr      L0B0C               wait for I/O lock
                    bcs       Writ598             error, return
                    ldd       R$Y,u               get size again
                    beq       Writ597             zero, nothing to write so return
                    bsr       Writ599             expand the file if needed
                    bcs       Writ598             error on expand, return
                    bsr       Writ582
Writ571             pshs      y,b,a
                    tfr       d,y
                    bsr       Writ5CB
                    puls      y,b,a
                    leax      d,x
                    ifne      H6309
                    oim       #(BUFMOD!SINBUF),PD.SMF,y
                    else
                    pshs      a
                    lda       PD.SMF,y
                    ora       #(BUFMOD!SINBUF)
                    sta       PD.SMF,y
                    puls      a
                    endc
                    rts

Writ582             lbsr      Read4D3             go read stuff
                    lbne      Read4D9
                    leas      $08,s               skip stuff on stack
                    ldy       PD.Exten,y
                    lda       #$01
                    lbsr      L0AD1
                    ldy       PE.PDptr,y
Writ597             clrb
Writ598             rts

* Add bytes to current file position with file length extension
* Entry: D=# bytes to add
Writ599             addd      PD.CP+2,y           add length to LSW of current pointer
                    tfr       d,x                 copy it
                    ldd       PD.CP,y             get MSW
                    ifne      H6309
                    adcd      #0                  add in any carry from above
                    else
                    adcb      #0
                    adca      #0
                    endc
Writ5A3             cmpd      PD.SIZ,y            MSW past eof?
                    bcs       Writ597             no, return
                    bhi       Writ5AF             yes, add a sector
                    cmpx      PD.SIZ+2,y          LSW past eof?
                    bls       Writ597             no, return
Writ5AF             pshs      u                   preserve U
                    ldu       PD.SIZ+2,y          get LSW of current size
                    stx       PD.SIZ+2,y          save new size
                    ldx       PD.SIZ,y            get MSW of new size
                    std       PD.SIZ,y            save new size
* ATD: L0C6F looks like it already saves U and X, so saving them here is
* unnecessary.
                    pshs      u,x                 preserve old size
                    lbsr      L0C6F               allocate new size of file
                    puls      u,x                 restore old size
                    bcc       Writ5C9             no error from allocate, return
                    stx       PD.SIZ,y            put old size back
                    stu       PD.SIZ+2,y
Writ5C9             puls      pc,u                restore U & return

* Move bytes from user to system
* Entry: X=Source pointer
*        Y=Byte count
*        U=Destination pointer
Writ5CB             pshs      x
                    ldx       <D.Proc             get source task #
                    lda       P$Task,x
                    ldb       <D.SysTsk           get destination task #
                    puls      x
                    os9       F$Move              move 'em
                    rts                           return


*
* I$GetStat Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
GetStat             ldb       R$B,u               get function code
                    beq       Gst5FF              it's SS.Opt, go process

* SS.Opt
* Entry A=path number
*       B=$00
*       X=address to put 32 byte packet
                    cmpb      #SS.EOF             EOF check?
                    bne       Gst5EB              no, skip ahead
                    clr       R$B,u               default to no EOF
Gst5E5              clra                          get length & clear carry
                    ldb       #$01
                    lbra      RdLn473             go calculate EOF status & return

* SS.Ready
* check for data avail on dev
* Entry A=path number
*       B=$01
Gst5EB              cmpb      #SS.Ready           is it SS.Ready?
                    bne       Gst5F2              no, keep checking
                    clr       R$B,u               always mark no data ready
                    rts

* SS.SIZ
* Entry A=path num
*       B=$02
* Exit  X=msw of files size
*       U=lsw of files size
Gst5F2              cmpb      #SS.Size            is it SS.Size?
                    bne       Gst600              no, keep checking
                    ifne      H6309
* faster and smaller than 2 LDD's, PD.SIZ+2 >$0F, so we can't use short n,R
                    ldq       PD.SIZ,y            get current file size
Gst5F8              std       R$X,u               save to the user
                    stw       R$U,u               save LSW
                    else
                    ldd       PD.SIZ,y
                    std       R$X,u
                    ldd       PD.SIZ+2,y
                    std       R$U,u
                    endc
Gst5FF              rts                           return

* SS.Pos
* Entry A=path num
*       B=$05
* Exit  X=msw of pos
*       U=lsw of pos
Gst600              cmpb      #SS.Pos             is it SS.Pos?
                    bne       Gst60D              no, keep checking
                    ifne      H6309
* use 2 LDD, STD, same size as ldq/std/stw, PD.CP+2 <$0F, we can use short n,R
                    ldq       PD.CP,y             get current file pointer
                    bra       Gst5F8
                    else
                    ldd       PD.CP,y             get current file pointer
                    std       R$X,u               save MSW
                    ldd       PD.CP+2,y           get current file pointer
                    std       R$U,u               save LSW
                    rts
                    endc

* Getstt(SS.FD)
* Entry: R$A = Path #
*        R$B = SS.FD ($0F)
*        R$X = ptr to 256 byte buffer
*        R$Y = # of bytes of FD required
Gst60D              cmpb      #SS.FD              is it SS.FD?
                    bne       Gst627              no, keep checking
                    lbsr      RdFlDscr            go get file descriptor
                    bcs       Gst5FF              exit on error
                    ldu       PD.RGS,y            get register stack pointer
                    ldd       R$Y,u               get # bytesof FD he wants
                    tsta                          legal value?
                    beq       Gst620              yes, skip ahead
                    ldd       #$0100              get max size of FD
Gst620              ldx       R$X,u               get pointer
                    ldu       PD.BUF,y            get pointer to FD
                    lbra      Read4AF             move it to user space

* Getstt(SS.FDInf)
* Entry: R$A = Path #
*        R$B = SS.FDInf ($20)
*        R$X = ptr to 256 byte buffer
*        R$Y = msb - Length of read
*              lsb - MSB of LSN
*        R$U = LSW of LSN
Gst627              cmpb      #SS.FDInf           SS.FDInf?
                    bne       Gst640              no, let driver handle it
                    lbsr      L1237               check for sector flush
                    bcs       Gst5FF
                    ldb       R$Y,u               get MSB of sector #
                    ldx       R$U,u               get LSW of sector #
                    lbsr      L113A               read the sector
                    bcs       Gst5FF              error, return
                    ldu       PD.RGS,y            get register stack pointer
                    ldd       R$Y,u               get length of data to move
                    clra                          clear MSB
                    bra       Gst620              move it to user

* Let driver handle the rest
Gst640              lda       #D$GSTA             get getstat function offset
                    lbra      L113C               send it to driver


*
* I$SetStat Entry Point
*
* Entry:
*
* Exit:
*
* Error: CC Carry set
*        B = errcode
*
SetStat             ldb       R$B,u               get function code
* TODO: remove next line since SS.Opt is 0
                    cmpb      #SS.Opt
                    bne       Sst659              not SS.Opt, skip ahead
                    ldx       R$X,u               get pointer to option packet
                    leax      $02,x               skip device type and drive #
                    leau      PD.STP,y            get pointer to start of data
                    ldy       #(PD.TFM-PD.STP)    get # bytes to move (not including PD.TFM)
                    lbra      Writ5CB             move 'em & return

* SS.Size
Sst659              cmpb      #SS.Size            is it SS.Size?
                    bne       Sst69B
                    ldd       PD.FD+1,y           is there a file descriptor?
                    bne       Sst669
                    tst       PD.FD,y
                    lbeq      Sst7A8              no, return error
Sst669              lda       PD.MOD,y            get file mode
                    bita      #WRITE.             is it write?
                    beq       Sst697              no, return error
                    ldd       R$X,u               get MSW of new size
                    ldx       R$U,u               get LSW of new size
                    cmpd      PD.SIZ,y
                    bcs       Sst682
                    bne       Sst67F
                    cmpx      PD.SIZ+2,y
                    bcs       Sst682
* New size is larger
Sst67F              lbra      Writ5A3             add new size to file
* New size is smaller
Sst682              std       PD.SIZ,y
                    stx       PD.SIZ+2,y
                    ldd       PD.CP,y
                    ldx       PD.CP+2,y
                    pshs      x,b,a
                    lbsr      L0EFE               delete from end of the file
                    puls      u,x
                    stx       PD.CP,y             restore current position
                    stu       PD.CP+2,y
                    rts
* Return bad mode error
Sst697              comb                          set carry
                    ldb       #E$BMode            get bad mod error
Sst69A              rts                           return

* SetStt(SS.FD) #$0F - returns FD to disk
* Entry: R$A = Path #
*        R$B = SS.FD ($0F)
*        R$X = ptr to 256 byte buffer
*        R$Y = # bytes to write
Sst69B              cmpb      #SS.FD              is it SS.FD?
                    bne       Sst6D9              no, keep checking
                    lda       PD.MOD,y
                    bita      #WRITE.             is it write mode?
                    beq       Sst697              no, return bad mode error
                    lbsr      RdFlDscr            read in file descriptor
                    bcs       Sst69A              error, return
                    pshs      y                   preserve path descriptor pointer
                    ldx       R$X,u               get pointer to caller's buffer
                    ldu       PD.BUF,y            get pointer to FD
                    ldy       <D.Proc             get current process pointer
                    ldd       P$User,y            get user #
                    bne       Sst6BC              not super user, skip ahead
* Change owner of file
                    ldd       #$0102              get offset & # of bytes to move
                    bsr       Sst6CB
* Change date last modified
Sst6BC              ldd       #$0305
                    bsr       Sst6CB
* Change creation date
                    ldd       #$0D03
                    bsr       Sst6CB
                    puls      y
                    lbra      L11FD
* Offset into FD sector
* Entry: A=# bytes to offset
*        B=# bytes to put
Sst6CB              pshs      u,x
                    leax      a,x
                    leau      a,u
                    clra
                    tfr       d,y
                    lbsr      Writ5CB
                    puls      pc,u,x

Sst6D9              cmpb      #SS.Lock            is it SS.Lock?
                    bne       Sst6F8              no, keep checking
                    ldd       R$U,u               get MSW of size
                    ldx       R$X,u               get LSW of size
                    cmpx      #$FFFF              lock whole file?
                    bne       Sst6F5              no, skip ahead
                    cmpx      R$U,u
                    bne       Sst6F5              after this line, we're SURE that D=$FFFF
                    ldu       PD.Exten,y
                    ifne      H6309
                    oim       #FileLock,PE.Lock,u
                    else
                    lda       PE.Lock,u
                    ora       #FileLock
                    sta       PE.Lock,u
                    endc
* ATD: This next line is unnecessary after the check done, above
                    lda       #$FF                ?? if X=$FFFF, then D=$FFFF too.
Sst6F5              lbra      L0B1B

* SS.Ticks
Sst6F8              cmpb      #SS.Ticks           is it SS.Ticks?
                    bne       Sst705              no, keep checking
                    ldd       R$X,u               get # of ticks
                    ldx       PD.Exten,y          put it into path extension
                    std       PE.TmOut,x
                    rts                           return

* SS.RsBit
Sst705              cmpb      #SS.RsBit           reserve bitmap sector?
                    bne       Sst715              no, keep checking
                    ldx       PD.DTB,y            get drive table pointer
                    lda       R$X+1,u             get sector #
                    sta       V.ResBit,x          put it into drive table
                    clr       V.MapSct,x          clear mapped sector
Sst714              rts                           return

* SS.Attr
Sst715              cmpb      #SS.Attr            is it SS.Attr?
                    bne       Sst784              no, keep checking
                    lbsr      RdFlDscr            get the file descriptor from drive
                    bcs       Sst714              error, return
                    ldx       <D.Proc             get pointer to current process
* Note, should'nt this be lda?  User number is 8 bits, not 16
                    ldd       P$User,x            get user number
                    beq       Sst72A              it's super user, skip ahead
                    ldx       PD.BUF,y            get pointer to FD
                    cmpd      FD.OWN,x            user # match owner of file?
                    bne       Sst780              no, return not accessible error
Sst72A              lda       R$X+1,u             get attributes from caller
                    tfr       a,b                 copy it
                    ldu       PD.BUF,y            get pointer to FD
                    eorb      FD.ATT,u            directory bit set?
                    bpl       Sst77B              no, save new attributes & return
                    tsta                          is user setting directory bit?
                    bmi       Sst764              yes, return directory not empty error
* Directory attributes changing, check if it's root dir
                    ldx       PD.DTB,y            get pointer to drive table
                    ldd       DD.DIR,x            get MSW of sector # to root directory
                    cmpd      PD.FD,y             match current FD sector #?
                    bne       Sst749              no, skip ahead
                    ldb       DD.DIR+2,x          get LSB of sector # to root directory
                    cmpb      PD.FD+2,y           match current FD sector #?
                    beq       Sst780              yes, return not accessible error
* Scan directory to see if there's any files and/or directories
Sst749              ldb       PD.CP,y             get current directory entry pointer
                    ldx       PD.CP+1,y
                    pshs      x,b                 preserve it
* ATD: there should be a CLRD here
                    std       PD.CP,y             ??? This code doesn't look correct...
* ATD: should be DIR.SZ*2: so we skip '..' and '.'
                    ldb       #DIR.SZ
                    std       PD.CP+2,y
Sst755              lbsr      L0942               move to next filename in directory
                    bcs       Sst768              error in read, check for EOF
                    tst       ,x                  filename exist?
                    beq       Sst755              no, keep looking
                    puls      x,b                 restore current pointer
                    stb       PD.CP,y
                    stx       PD.CP+1,y
* Report directory not empty error
Sst764              ldb       #E$DNE              get directory not empty error
                    bra       Sst782              return
Sst768              puls      x,a                 restore current pointer
                    sta       PD.CP,y
                    stx       PD.CP+1,y
                    cmpb      #E$EOF              at the end of directory?
                    bne       Sst782              no, some other error
                    lbsr      RdFlDscr            get file descriptor from drive
                    ldu       PD.BUF,y            get sector pointer
                    ldx       PD.RGS,y            get register stack pointer
                    lda       R$X+1,x             get attributes
Sst77B              sta       FD.ATT,u            set 'em
                    lbra      L11FD               write FD to disk & return
* Return file not accessible
Sst780              ldb       #E$FNA              get file not accessible error
Sst782              coma                          set carry
                    rts                           return

* SetStt(SS.FSig)
Sst784              cmpb      #SS.FSig            SS.FSig send signal on write
                    bne       Sst7A3
                    lda       PD.ATT,y
                    bita      #SHARE.
                    lbne      L0A8B
                    ldx       PD.Exten,y
                    lda       R$X+1,u
                    sta       PE.SigSg,x
                    ldu       <D.Proc
                    lda       P$ID,u              was <P$ID,u
                    sta       PE.SigID,x
                    clrb
                    rts

Sst7A3              lda       #D$PSTA             call the driver SetStt routine
                    lbra      L113C

Sst7A8              comb
                    ldb       #E$UnkSvc           unknown service request
Sst7AB              rts


* Find a file in current data/execution directory
* Called by Create/Open & Delete
*
* Entry: U=caller's stack reg. ptr
*        Y=Path dsc. ptr
FindFile
                    lbsr      SSize               +BGP+
*         ldd   #$0100		get size of sector -BGP-
* Note, following line is stb PD.SMF,y in v30!
                    stb       PD.FST,y            clear state flags??
                    os9       F$SRqMem            request a 256 byte sector buffer
                    bcs       Sst7AB              couldn't get memory, return with error
                    stu       PD.BUF,y            save ptr to sector buffer
                    leau      ,y                  point U to path descriptor
                    ldx       <D.PthDBT           get ptr to path escriptor block tables
                    os9       F$All64             allocate path descriptor
                    exg       y,u                 exchange pointers
                    bcs       Sst7AB              couldn't get path descriptor, return error
                    stu       PD.Exten,y          save pointer to path extension
                    clr       PE.SigID,u          clear send signal proc. ID
                    sty       PE.PDptr,u          save back pointer to path descriptor
                    stu       PE.Wait,u           init waiting extension to myself
                    ldx       PD.RGS,y            get register stack pointer
                    ldx       R$X,x               get pointer to pathname
                    pshs      u,y,x
                    leas      -$04,s              make a buffer
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    sta       PD.FD,y             init file descriptor logical sector #
                    std       PD.FD+1,y
                    std       PD.DSK,y            init disk ID
                    lbsr      L097F               get a byte from caller's X
                    sta       ,s                  save it
                    cmpa      #PDELIM             is it a device?
                    bne       Sst7FB              no, skip ahead
                    lbsr      GtDvcNam            go parse it
                    sta       ,s                  save last character
                    lbcs      L090D               error in parse, return
                    leax      ,y                  point X to last character
                    ldy       $06,s               get path descriptor pointer
                    bra       Sst81E              skip ahead
Sst7FB              anda      #$7F                strip high bit
                    cmpa      #PENTIR             entire device flag?
                    beq       Sst81E              yes, go process
                    lda       #PDELIM             place delimiter as last char
                    sta       ,s
                    leax      -$01,x              bump path pointer back 1
                    lda       PD.MOD,y            get file mode
                    ldu       <D.Proc             get pointer to current process
                    leau      P$DIO,u             point to default data directory FD sector #
                    bita      #EXEC.              does he want execution dir?
                    beq       Sst814              no, skip ahead
                    leau      $06,u               point to execution dir
Sst814              ldb       $03,u               get LSB of logical sector # of FD to dir
                    stb       PD.FD,y             put it in path descriptor
                    ldd       $04,u               get MSW of logical sector # of FD to dir
                    std       PD.FD+1,y
Sst81E              ldu       PD.DEV,y            get pointer to device table
                    stu       PD.DVT,y            copy it for user
                    lda       PD.DRV,y            get drive #
                    ldb       #DRVMEM             get sizeof drive tables
* confusion reigns supreme here - NO MORE!
* The data stored at L0012 *IS* the drive table sizeof.
* MY question is why this RBF constant is stored as a variable.
* Why would it need to be changed, and by who?
                    mul                           calculate offset into drive tables
                    addd      V$STAT,u            add start of static memory
                    addd      #DRVBEG             add offset to drive tables
                    std       PD.DTB,y            save pointer to drive table
                    lda       ,s                  get character back
                    anda      #$7F                strip high bit
                    cmpa      #PENTIR             was it entire flag?
                    bne       Sst83F              no, keep going
                    leax      $01,x               move to next character
                    bra       Sst861              go on

Sst83F              lbsr      L1110               read in LSN0
                    lbcs      L0915               error, return
                    ldu       PD.BUF,y            get sector buffer pointer from the read-in sector

* otherwise use the pointer from PD.DTB
                    ldd       DD.DSK,u            get disk ID
                    std       PD.DSK,y            put it in path descriptor
                    ldd       PD.FD+1,y           does it have a file descriptor?
                    bne       Sst861              yes, skip ahead
                    lda       PD.FD,y
                    bne       Sst861
                    lda       DD.DIR,u            get LSN of root directory
                    sta       PD.FD,y             put it in path descriptor
                    ldd       DD.DIR+1,u
                    std       PD.FD+1,y
Sst861              stx       $04,s               save pointer to pathname
                    stx       $08,s

Sst865              lbsr      L1237               flush sector buffer
                    lbcs      L0915               error, exit
                    lda       ,s                  get last character of pathname
                    anda      #$7F                mask off high bit
                    cmpa      #PENTIR             entire device flag?
                    beq       Sst87B              yes, skip ahead
                    lbsr      RdFlDscr            read in file descriptor
                    lbcs      L0915               error, return
Sst87B              lbsr      L0A2A               check if directory is busy
                    lda       ,s
                    cmpa      #PDELIM             was the trailing character a slash?
                    bne       L08EF               no, skip ahead
                    clr       $02,s
                    clr       $03,s
                    lda       PD.MOD,y            get file mode
                    ora       #DIR.               mask in directory bit
                    lbsr      ChkAttrs            can user access directory?
                    bcs       L090D               no, return
                    lbsr      Open1CE             setup path descriptor & start scan
                    ldx       $08,s               get pathname pointer
                    leax      $01,x               bump to next character
                    lbsr      GtDvcNam            check for valid name
                    std       ,s                  save length of name
                    stx       $04,s               save updated name pointer
                    sty       $08,s
                    ldy       $06,s               get path descriptor pointer
                    bcs       L090D               error in pathname, return
                    pshs      u,y
                    ldu       PD.Exten,y          get pointer to path extension
                    leau      PE.FilNm,u          point to filename buffer
                    clra                          clear MSB of name length
                    tfr       d,y                 move it to Y
                    lbsr      Writ5CB             move filename to temp area
                    puls      u,y
                    lbsr      L0957               read in a directory sector
                    bra       L08C1

* Scan diretory for name
L08BC               bsr       L0918               get file descriptor
                    ifne      H6309
L08BE               bsr       L0942               get next directory entry from drive
                    else
L08BE               lbsr      L0942
                    endc
L08C1               bcs       L090D               error,
                    tst       ,x                  filename exists?
                    beq       L08BC               no, get next entry
                    clra
                    ldb       $01,s
                    exg       x,y
                    ldx       PD.Exten,x          get path extension pointer
                    leax      PE.FilNm,x          point to user's filename
                    lbsr      L09BF               compare the names
                    ldx       $06,s               get pointer to path descriptor
                    exg       x,y
                    bcs       L08BE               names don't match, skip to next
                    bsr       L0926               cop this DIR file descriptor to path descriptor
                    lda       DIR.FD,x
                    sta       PD.FD,y
                    ldd       DIR.FD+1,x
                    std       PD.FD+1,y
                    lbsr      L0A90               check record lock?
                    lbra      Sst865              go try again

L08EF               ldx       $08,s
                    tsta                          last character?
                    bmi       L08FC               yes, skip ahead
                    os9       F$PrsNam            parse the name
                    leax      ,y                  go to the next part of the name
                    ldy       $06,s
L08FC               stx       $04,s
                    clra
L08FF               lda       ,s
                    leas      $04,s
                    pshs      b,a,cc
                    ifne      H6309
                    aim       #^BufBusy,PD.SMF,y
                    else
                    lda       PD.SMF,y
                    anda      #^BufBusy
                    sta       PD.SMF,y
                    endc
                    puls      pc,u,y,x,b,a,cc

L090D               cmpb      #E$EOF
                    bne       L0915
                    bsr       L0918
                    ldb       #E$PNNF
L0915               coma
                    bra       L08FF

L0918               pshs      d
                    lda       $04,s
                    cmpa      #PDELIM
                    beq       L0940
                    ldd       $06,s
                    bne       L0940
                    bra       L0928               fewer clock cycles
L0926               pshs      d
L0928               stx       $06,s
                    lda       PD.FD,y
                    sta       PD.DFD,y
                    ldd       PD.FD+1,y
                    std       PD.DFD+1,y
                    ifne      H6309
                    ldq       PD.CP,y
                    stq       PD.DCP,y
                    else
                    ldd       PD.CP,y
                    std       PD.DCP,y
                    ldd       PD.CP+2,y
                    std       PD.DCP+2,y
                    endc
L0940               puls      pc,b,a

* Move to next directory entry
* BGP - Sector Size issue needs to be resolved here
L0942               ldb       PD.CP+3,y           get current byte pointer
                    addb      #DIR.SZ             add in diretory entry size
                    stb       PD.CP+3,y           save it back
                    bcc       L0957               didn't wrap, skip ahead (need new sector)
                    lbsr      L1237               check for sector flush
                    inc       PD.CP+2,y
                    bne       L0957
                    inc       PD.CP+1,y
                    bne       L0957
                    inc       PD.CP,y
L0957               ldd       #DIR.SZ             get directory entry size
                    lbsr      RdLn473             end of directory?
                    bcs       L097E               yes, return
                    ldd       #DIR.SZ             get directory entry size
                    lbsr      L0B0C
                    bcs       L097E               yes, return
                    lda       PD.SMF,y            get state flags
                    bita      #SINBUF             sector in buffer?
                    bne       L0977               yes, skip ahead
                    lbsr      L1098
                    bcs       L097E
                    lbsr      L1256
                    bcs       L097E
L0977               ldb       PD.CP+3,y           get offset into sector
                    lda       PD.BUF,y            get MSB of sector buffer pointer
                    tfr       d,x                 move it to X
                    clrb                          clear error status
L097E               rts                           return

* Get a byte from other task
L097F               pshs      u,x,b
                    ldu       <D.Proc
                    ldb       P$Task,u
                    os9       F$LDABX
                    puls      pc,u,x,b

GtDvcNam            os9       F$PrsNam            parse the filename
                    pshs      x                   preserve pointer to name
                    bcc       L09B7               no error, check name length & return
                    clrb                          clear a counter flag
L0992               pshs      a                   preserve last character
                    anda      #$7F                clear high bit of last character
                    cmpa      #'.                 is it current data directory?
                    puls      a                   restore last character
                    bne       L09AD               no, skip ahead
                    incb                          flag it's a dir
                    leax      1,x
                    tsta                          is it the last character of pathname?
                    bmi       L09AD               yes, skip ahead
                    bsr       L097F               get next character
                    cmpb      #$03                third character of DIR?
                    bcs       L0992               no, try again
                    lda       #PDELIM
                    decb
                    leax      -3,x
L09AD               tstb
                    bne       L09B5
L09B0               comb
                    ldb       #E$BPNam
                    puls      pc,x

L09B5               leay      ,x
L09B7               cmpb      #DIR.FD-DIR.NM      past maximum size of name?
                    bhi       L09B0               yes, return error
                    andcc     #^Carry             clear error status
                    puls      pc,x                return

* Check for a match of 2 names
* Entry: Y=Pointer to high bit terminated string #1
*        X=Pointer to string #2
*        B=Length of string #1
L09BF               pshs      y,x,b,a
L09C1               lda       ,y+                 get a byte from #2
                    bmi       L09D1               last one, skip ahead
                    decb                          done length?
                    beq       L09CE               yes, return no match
                    eora      ,x+
                    anda      #$DF                match from #1?
                    beq       L09C1               yes, check next char
L09CE               comb                          set carry
                    puls      pc,y,x,b,a          return

L09D1               decb                          decrement length
                    bne       L09CE               not done, return no match
                    eora      ,x
                    anda      #$5F
                    bne       L09CE
                    clrb                          clear carry for match
                    puls      pc,y,x,b,a

* Check if user can access file/directory
* Entry: A=Attributes of file/directory to check
* Exit : Carry set - User cannot access otherwise clear
ChkAttrs            tfr       a,b                 copy attributes
                    anda      #(EXEC.!UPDAT.)     keep only file related junk
                    andb      #(DIR.!SHARE.)      ...and directory related junk
                    pshs      x,b,a               preserve
                    lbsr      RdFlDscr            get file descriptor
                    bcs       L0A0C               error, return
                    ldu       PD.BUF,y            get pointer to FD
                    ldx       <D.Proc             get current process pointer
                    ldd       P$User,x            get user #
                    beq       L09F5               super user, skp ahead
                    cmpd      FD.OWN,u            match owner of file?
L09F5               puls      a                   restore owner attributes
                    beq       L09FC               got owner, skip ahead
                    lsla                          shift attributes to public area
                    lsla
                    lsla
L09FC               ora       ,s                  merge with directory bits
                    anda      #^SHARE.            strip off shareable bit
                    pshs      a                   save it
                    ora       #DIR.               set directory bit
                    anda      FD.ATT,u            keep only bits we want from attributes
                    cmpa      ,s                  can he access it?
                    beq       L0A15               yes, check directory bits
                    ldb       #E$FNA              get error code
L0A0C               leas      $02,s               purge attributes from stack
                    coma                          set carry
                    puls      pc,x                restore & return

L0A11               ldb       #E$Share,s          get shareable file error
                    bra       L0A0C               return

L0A15               ldb       1,s                 get directory bits
                    orb       FD.ATT,u            mask in with current
                    bitb      #SHARE.             shareable bit set?
                    beq       L0A28               no, return
                    ldx       PD.Exten,y          get path extension
                    cmpx      PE.Confl,x          conflicting with anyone?
                    bne       L0A11               yes, return error
                    lda       #FileLock
                    sta       PE.Lock,x
L0A28               puls      pc,x,b,a


L0A2A               pshs      u,y,x
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       PD.CP,y             init current byte pointer
                    std       PD.CP+2,y           smaller than STQ
                    sta       PD.SSZ,y            init segment size
                    std       PD.SSZ+1,y
                    ldb       PD.FD,y             get current FD sector #
                    ldx       PD.FD+1,y
                    pshs      x,b                 preserve it
                    ldu       PD.DTB,y            get drive table pointer
                    ldy       PD.Exten,y          get drive extension pointer
                    sty       PE.Confl,y          make it conflict with myself
                    leau      DD.SIZ,u            point to local data
                    bra       L0A51
* Sort file conflict list???
L0A4F               ldu       V.FileHd-DD.SIZ,u
L0A51               ldx       V.FileHd-DD.SIZ,u   get open file list extension pointer
                    beq       L0A7F               none, skip return
                    ldx       PE.PDptr,x          get pointer to its path descriptor
                    ldd       PD.FD,x             get the file descriptor LSN
                    cmpd      ,s                  sector lower than mine?
                    bcs       L0A4F               yes, skip to next
                    bhi       L0A7F               no, return
                    ldb       PD.FD+2,x
                    cmpb      2,s
                    blo       L0A4F               yes, skip to next
                    bhi       L0A7F               no, return
                    ldx       PD.Exten,x          get the path extension pointer
                    ifne      H6309
                    tim       #FileLock,PE.Lock,y entire file locked?
                    else
                    ldb       PE.Lock,y
                    bitb      #FileLock
                    endc
                    bne       L0A8B               yes, return error
                    sty       PE.NxFil,y          terminate list with pointer to myself
                    ldd       PE.Confl,x
                    std       PE.Confl,y
                    sty       PE.Confl,x
                    bra       L0A86

L0A7F               ldx       PE.NxFil,u
                    stx       PE.NxFil,y
                    sty       PE.NxFil,u

L0A86               clrb
L0A87               leas      $03,s
                    puls      pc,u,y,x

L0A8B               comb
                    ldb       #E$Share
                    bra       L0A87

L0A90               pshs      u,y,x,b,a
                    ldu       PD.DTB,y
                    leau      DD.SIZ,u
                    ldx       PD.Exten,y
                    leay      ,x
                    bsr       L0ACF
                    bra       L0AA5
L0AA1               ldx       PE.Confl,x
                    beq       L0ACA
L0AA5               cmpy      PE.Confl,x
                    bne       L0AA1
                    ldd       PE.Confl,y
                    std       PE.Confl,x
                    bra       L0AB2
L0AB0               ldu       PE.NxFil,u
L0AB2               ldd       PE.NxFil,u
                    beq       L0ACA               end of list, store end & return
                    cmpy      PE.NxFil,u          find myself/
                    bne       L0AB0               no, keep looking
                    ldx       PE.NxFil,y          get next in line from me
                    cmpy      PE.Confl,y          end of conflict list?
                    beq       L0AC8               yes, skip ahead
                    ldx       PE.Confl,y          get conflicting path extension
                    ldd       PE.NxFil,y          get next in line from me
                    std       PE.NxFil,x          save it into conflicting extension
L0AC8               stx       PE.NxFil,u          save conflicting extension as next
L0ACA               sty       PE.Confl,y
                    puls      pc,u,y,x,b,a

L0ACF               lda       #(EofLock!FileLock!RcdLock) get all types of lockout flags
L0AD1               pshs      u,y,x,b,a
                    bita      PE.Lock,y           anything locked?
                    beq       L0AE0               no, skip ahead
                    coma                          invert lock bits
                    anda      PE.Lock,y           clear 'em
                    sta       PE.Lock,y           save 'em
                    bita      #FileLock           is whole file locked?
                    bne       L0AFD               yes, return
L0AE0               leau      ,y
L0AE2               ldx       PE.Wait,u
                    cmpy      PE.Wait,u
                    beq       L0AFA
                    stu       PE.Wait,u
                    leau      ,x
                    lda       PE.Owner,u
                    ldb       #S$Wake
                    os9       F$Send
                    bra       L0AE2
L0AFA               stu       PE.Wait,u
L0AFD               puls      pc,u,y,x,b,a

L0AFF               comb
                    ldb       #E$Share
L0B02               pshs      y,b,cc
                    ldy       PD.Exten,y
                    bsr       L0ACF
                    puls      pc,y,b,cc

L0B0C               equ       *
                    ifne      H6309
                    tfr       0,x
                    else
                    ldx       #$0000
                    endc
                    bra       L0B1B

L0B11               ldu       PD.Exten,y
                    lda       PE.Req,u
                    sta       PE.Lock,u
                    bra       L0B1D

* Entry: D=LSW of byte position
*        X=
*        Y=Path descriptor pointer
*        U=
L0B1B               pshs      u,y,x,b,a           preserve regs
L0B1D               ldu       PD.Exten,y          get pointer to path extension
                    lda       PE.Lock,u           get lockout status
                    sta       PE.Req,u            preserve it
                    lda       ,s                  get
                    bsr       L0B9F               lock the record
                    bcc       L0B9D
                    ldu       <D.Proc             get current proces pointer
                    lda       PE.Owner,x          get owner ID of locked segment
L0B30               os9       F$GProcP            get a pointer to it
                    bcs       L0B42               no process left, skip ahead
                    lda       P$DeadLk,y          get dominant proc ID
                    beq       L0B42               none, skip ahead
                    cmpa      P$ID,u              same as current?
                    bne       L0B30               no, try again (walks down the process tree)
                    ldb       #E$DeadLk           get deadlock error code
                    bra       L0B9A               set carry & return

L0B42               lda       PE.Owner,x          get owner of this segment
                    sta       P$DeadLk,u          save as the dominant deadlock process
                    ldy       4,s                 get path descriptor pointer
                    ifne      H6309
                    aim       #^BufBusy,PD.SMF,y
                    else
                    lda       PD.SMF,y
                    anda      #^BufBusy
                    sta       PD.SMF,y
                    endc
                    ldu       PD.Exten,y          get the path extension
                    ldd       PE.Wait,x
                    stu       PE.Wait,x
                    std       PE.Wait,u
                    lbsr      L0C56
                    ldx       PE.TmOut,u          get timeout time to wait for release of segment
                    os9       F$Sleep             delay a bit
                    pshs      x                   preserve time slept
                    leax      ,u                  point X to path extension
                    bra       L0B6F               skip ahead

L0B6C               ldx       PE.Wait,x
L0B6F               cmpu      PE.Wait,x
                    bne       L0B6C
                    ldd       PE.Wait,u
                    std       PE.Wait,x
                    stu       PE.Wait,u
                    puls      x                   restore time slept
                    ldu       <D.Proc
                    clr       P$DeadLk,u
                    lbsr      L1053
                    bcs       L0B9A
                    leax      ,x                  X=0?
                    bne       L0B11               no,
                    ldu       PD.Exten,y          get pointer to extension
                    ldx       PE.TmOut,u          get timeout time
                    lbeq      L0B11               zero, go try again
                    ldb       #E$Lock             get lock error code
L0B9A               coma                          set carry
                    stb       $01,s               save error code
L0B9D               puls      pc,u,y,x,b,a

L0B9F
                    ifne      H6309
                    tstd                          std -$02,s only to set cc.flags? 4 cycles to 1!
                    else
                    cmpd      #$0000
                    endc
                    bne       L0BAA
                    cmpx      #$0000              the leax may be buggy
                    lbeq      L0B02
L0BAA               bsr       L0BC2
                    lbcs      L0AFF
                    pshs      u,y,x
                    ldy       PD.Exten,y
                    lda       #$01
                    lbsr      L0AD1
                    ora       PE.Lock,y
                    sta       PE.Lock,y
                    clrb
                    puls      pc,u,y,x

L0BC2               pshs      u,y,b,a
                    leau      ,y
                    ldy       PD.Exten,y
                    subd      #$0001              NOT a DECD: does't set CC.C
                    bcc       L0BD1
                    leax      -1,x
L0BD1               addd      PD.CP+2,u
                    exg       d,x
                    ifne      H6309
                    adcd      PD.CP,u             oughta do same - GH
                    else
                    adcb      PD.CP+1,u
                    adca      PD.CP,u
                    endc
                    bcc       L0BE0
                    ldx       #$FFFF
                    tfr       x,d
L0BE0               std       PE.HiLck,y
                    stx       PE.HiLck+2,y
                    cmpd      PD.SIZ,u
                    bcs       L0BF8
                    bhi       L0BF0
                    cmpx      PD.SIZ+2,u
                    bcs       L0BF8
L0BF0               equ       *
                    ifne      H6309
                    oim       #EofLock,PE.Lock,y
                    else
                    lda       PE.Lock,y
                    ora       #EofLock
                    sta       PE.Lock,y
                    endc
                    bra       L0C01
L0BF8               lda       #EofLock
                    bita      PE.Lock,y
                    beq       L0C01
                    lbsr      L0AD1
L0C01               equ       *
                    ifne      H6309
                    ldq       PD.CP,u
                    stq       PE.LoLck,y
                    else
                    ldd       PD.CP,u
                    std       PE.LoLck,y
                    ldd       PD.CP+2,u
                    std       PE.LoLck+2,y
                    endc
                    lda       PD.CPR,u
                    sta       PE.Owner,y
                    leax      ,y
L0C10               cmpy      PE.Confl,x
                    beq       L0C54
                    ldx       PE.Confl,x
                    ldb       PE.Owner,y
                    cmpb      PE.Owner,x
                    beq       L0C10
                    lda       PE.Lock,x
                    beq       L0C10
                    ora       PE.Lock,y
                    bita      #FileLock           either path locked?
                    bne       L0C53               yes, skip ahead
                    lda       PE.Lock,x
                    anda      PE.Lock,y
                    bita      #EofLock            both at eof?
                    bne       L0C53
                    ldd       PE.LoLck,x
                    cmpd      PE.HiLck,y
                    bhi       L0C10
                    bcs       L0C43
                    ldd       PE.LoLck+2,x
                    cmpd      PE.HiLck+2,y
                    bhi       L0C10
                    beq       L0C53
L0C43               ldd       PE.HiLck,x
                    cmpd      PE.LoLck,y
                    bcs       L0C10
                    bhi       L0C53
                    ldd       PE.HiLck+2,x
                    cmpd      PE.LoLck+2,y
                    bcs       L0C10
L0C53               comb
L0C54               puls      pc,u,y,b,a

L0C56               pshs      y,x,b,a
                    ldx       <D.Proc
                    lda       P$IOQN,x            get I/O queue next ptr
                    beq       L0C6C               none, exit
                    clr       P$IOQN,x            set to none
                    ldb       #S$Wake
                    os9       F$Send              wake up
                    os9       F$GProcP            get process descriptor pointer
                    clr       P$IOQP,y            clear its I/O queue previous pointer
L0C6C               clrb
                    puls      pc,y,x,b,a

L0C6F               pshs      u,x
L0C71               bsr       L0CD1
                    bne       L0C81
                    cmpx      PD.SSZ+1,y
                    bcs       L0CC8
                    bne       L0C81
                    lda       PD.SIZ+3,y
                    beq       L0CC8
L0C81               lbsr      RdFlDscr
                    bcs       L0CC5
                    ldx       PD.CP,y
                    ldu       PD.CP+2,y           grab current position
                    pshs      u,x                 save it
                    ifne      H6309
                    ldq       PD.SIZ,y            go to the end of the file
                    stq       PD.CP,y
                    else
                    ldd       PD.SIZ,y
                    std       PD.CP,y
                    ldd       PD.SIZ+2,y
                    std       PD.CP+2,y
                    endc
                    lbsr      L10B2               search ???
                    puls      u,x                 restore current position
                    stx       PD.CP,y             and save back in PD again
                    stu       PD.CP+2,y
                    bcc       L0CC8
                    cmpb      #E$NES              non-existing segment error?
                    bne       L0CC5
                    bsr       L0CD1
                    bne       L0CB1
                    tst       PD.SIZ+3,y
                    beq       L0CB4
                    leax      1,x
                    bne       L0CB4
L0CB1               ldx       #$FFFF
L0CB4               tfr       x,d
                    tsta
                    bne       L0CC1
                    cmpb      PD.SAS,y
                    bcc       L0CC1
                    ldb       PD.SAS,y
L0CC1               bsr       L0D07               go do something...
                    bcc       L0C71
L0CC5               coma
                    puls      pc,u,x

L0CC8               lbsr      L1098
                    bcs       L0CC5
                    bsr       L0CDF
                    puls      pc,u,x

L0CD1               ldd       PD.SIZ+1,y
                    subd      PD.SBL+1,y
                    tfr       d,x
                    ldb       PD.SIZ,y
                    sbcb      PD.SBL,y
                    rts

L0CDF               clra
                    ldb       #$02
                    pshs      u,x
                    ldu       PD.Exten,y
                    bra       L0CFD

L0CE9               ldu       PE.PDptr,u
                    ldx       PD.SIZ,y            don't do LDQ/STQ, as A and B are used below
                    stx       PD.SIZ,u
                    ldx       PD.SIZ+2,y
                    stx       PD.SIZ+2,u
                    bitb      PD.MOD,y
                    beq       L0CFA
                    inca
L0CFA               ldu       PD.Exten,u
L0CFD               ldu       PE.Confl,u
                    cmpy      PE.PDptr,u
                    bne       L0CE9
                    tsta
                    puls      pc,u,x

* Update a file descriptor
L0D07               pshs      u,x
                    lbsr      FatScan             search and allocate D sectors
                    bcs       L0D4E               exit on error
                    lbsr      RdFlDscr            read a FD from disk
                    bcs       L0D4E               exit on error
                    ldu       PD.BUF,y            grab the buffer pointer
                    ifne      H6309
                    clrd
                    tfr       d,w
                    stq       FD.SIZ,u            set the file size to zero
                    else
                    clra
                    clrb
                    std       FD.SIZ,u
                    std       FD.SIZ+2,u
                    endc
                    leax      FD.SEG,u            point to the segment size
                    ldd       FDSL.B,x            grab the segment size
                    beq       L0D96               exit if zero
                    ldd       PD.BUF,y            grab the buffer pointer
                    inca                          point to the end of it

* Following 3 lines support larger sector sizes that
* allow the segment list to extend beyond 48 entries.
*         pshs  a
*         lbsr  SSBits
*         adda  ,s+

                    pshs      d                   save on-stack
                    bra       L0D36               skip ahead

L0D29               clrb
                    ldd       -$02,x              grab previous segment sector size
                    beq       L0D4A               zero: exit
* Add in checks to see if this segment's LSN is $00000000?
                    addd      FD.SIZ+1,u          add sector size to total file size
                    std       FD.SIZ+1,u
                    bcc       L0D36
                    inc       FD.SIZ,u            increment file size if 24-bit overflow
L0D36               leax      FDSL.S,x            go up one segment in the FD
                    cmpx      ,s                  done yet?
                    bcs       L0D29               no, continue
* or do check for last segment LSN0, size 1 here?
                    lbsr      ClrFBits            delete a segment?
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    sta       PD.SSZ,y            segment size is zero
                    std       PD.SSZ+1,y
                    comb
                    ldb       #E$SLF              segment list full error

L0D4A               leas      2,s                 remove pointer to end of PD.BUF from the stack
                    leax      -FDSL.S,x           back up a segment
L0D4E               bcs       L0DB3
                    ldd       -4,x
                    addd      -2,x
                    pshs      b,a
                    ldb       -5,x
                    adcb      #$00
                    cmpb      PD.SBP,y
                    puls      d
                    bne       L0D96
                    cmpd      PD.SBP+1,y
                    bne       L0D96
                    ldu       PD.DTB,y
                    ldd       DD.BIT,u
                    ldu       PD.BUF,y
                    subd      #1
                    coma
                    comb                          comd is prolly wrong reg order!
                    pshs      d
                    ldd       -$05,x
                    ifne      H6309
                    eord      PD.SBP,y
                    lsrd
                    lsrd
                    lsrd
                    andd      ,s++
                    tstd
                    else
                    eora      PD.SBP,y
                    eorb      PD.SBP+1,y
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    anda      ,s+
                    andb      ,s+
                    cmpd      #$0000
                    endc
                    bne       L0D96
                    ldd       -2,x
                    addd      PD.SSZ+1,y
                    bcs       L0D96
                    std       -2,x
                    bra       L0DA5

L0D96               ldd       PD.SBP,y
                    std       ,x
                    lda       PD.SBP+2,y
                    sta       2,x
                    ldd       PD.SSZ+1,y
                    std       3,x
L0DA5               ldd       FD.SIZ+1,u
                    addd      PD.SSZ+1,y
                    std       FD.SIZ+1,u
                    bcc       L0DB0
                    inc       FD.SIZ,u

L0DB0               lbsr      L11FD               flush a FD sector tothe disk
L0DB3               puls      pc,u,x

* Search the allocation bitmap for a number of free sectors
* Entry: D = number of sectors to look for
*        Y = PD pointer
* 0,S  = number of clusters to allocate
* 2,S  = DD.BIT  number of sectors per cluster
* 4,S  = DD.MAP  number of bytes in the allocation bitmap
* 6,S  = V.MapSCT lowest reasonable bitmap sector number (current bitmap sect)
* 7,S  = sector number of the largest contiguous free bits found
* 8,S  = number of contiguous free bits found
* 10,s = bit offset into the sector of the found contiguous bits
* 10,s = also  DD.BIT  number of sectors per cluster
* 12,S = number of sectors to search for  (D from the calling routine)
* 16,S = PD pointer (Y from the calling routine)
FatScan             pshs      u,y,x,b,a
                    ldb       #$0C
L0DB9               clr       ,-s                 reserve 12 bytes of junk on-stack
                    decb
                    bne       L0DB9
                    ldx       PD.DTB,y
                    ldd       DD.MAP,x            number of bytes in allocation bitmap
                    std       4,s
                    ldd       DD.BIT,x            number of sectors per cluster
                    std       2,s
                    std       10,s
                    ldx       PD.DEV,y            get pointer to device table entry
                    ldx       V$DESC,x            point to descriptor
                    leax      M$DTyp,x            get device type
                    subd      #1
                    addb      IT.SAS-M$DTyp,x     add in one sector allocation size
                    adca      #0                  make it 16-bit
                    bra       L0DDD               default to greater of SAS or DD.BIT

L0DDB               equ       *
                    ifne      H6309
                    lsrd                          shift D to the right
                    else
                    lsra
                    rorb
                    endc
L0DDD               lsr       $0A,s               shift DD.BIT to the right
                    ror       $0B,s
                    bcc       L0DDB               loop until carry is set
                    std       ,s                  D = number of clusters to allocate
                    ldd       2,s                 get old DD.BIT
                    std       $0A,s               save on-stack again
                    subd      #$0001
                    addd      $0C,s               add in to the number of sectors we're asked to
                    bcc       L0DF7               allocate
                    ldd       #$FFFF              if larger than 64K sectors, default to 64K
                    bra       L0DF7               skip ahead

L0DF5               equ       *
                    ifne      H6309
                    lsrd                          shift number of sectors to allocate
                    else
                    lsra
                    rorb
                    endc
L0DF7               lsr       $0A,s
                    ror       $0B,s
                    bcc       L0DF5               loop, and continue
* ATD: remove this code for HD's, to allow >2048 cluster segments???
* It may be easier to read in the FD, and COMPACT it by looking for
* LSN+SIZE=next segment LSN.  But that would take 48*(30?) clock cycles,
* which is a lot of time... but maybe not compared to F$All/F$Sch, and
* the sector read/writes...
                    cmpa      #8                  at least 256*8 bits to allocate?
                    bcs       L0E04               number of clusters is OK, skip ahead
                    ldd       #$0800              force one sector of clusters max. to be allocated
L0E04               std       $0C,s               save as the number of clusters to allocate
                    lbsr      L1036               make us the current user of the allocation bitmap
                    lbcs      L0EF2               exit on error
                    ldx       PD.DTB,y            get drive table
                    ldd       V.DiskID,x          and old disk ID
                    cmpd      DD.DSK,x            check against the current disk ID
                    bne       L0E26               if not the same, make us the current disk ID
                    lda       V.BMapSz,x          same allocation bitmap size?
                    cmpa      DD.MAP,x
                    bne       L0E26               no, skip ahead
                    ldb       V.MapSct,x          another check
                    cmpb      DD.MAP,x
                    bcs       L0E34

L0E26               ldd       DD.DSK,x            get current disk ID
                    std       V.DiskID,x          make us the disk to use
                    lda       DD.MAP,x            grab number of sectors in allocation bitmap
                    sta       V.BMapSz,x          save for later
                    clrb
                    stb       V.MapSct,x          make this zero for now
L0E34               incb                          account for LSN0
                    stb       6,s                 lowest reasonable bitmap sector number
* ATD: Is this line necessary?  All calls to L0E34 set up X already
                    ldx       PD.DTB,y            get drive table pointer again
                    cmpb      V.ResBit,x          check B against reserved bitmap sector
                    beq       L0E70               same, skip ahead
                    lbsr      L1091               go read in a bitmap sector
                    lbcs      L0EF2
                    ldb       6,s                 grab copy of V.MapSCT again
                    cmpb      4,s                 check against number of sectors in allocation bitmap
                    bls       L0E51               lower, continue
                    clra                          if at end of the allocation bitmap,
                    ldb       5,s                 don't search it all, but just to the end of the
                    bra       L0E54               last sector in the allocation bitmap

* ATD: This the routine that we would fix to cache a compressed version
* of the allocation bitmap.  i.e. largest group of contiguous free sectors,
* where 255 == 256 by definition. At 1 byte/sector, max. 256 sectors in the
* allocation bitmap, max. 256 bytes.  The search should be a LOT faster then,
* as we'll only have to search memory and not read in all those sectors.
* If we're really daring, we could build the new FD without reading the
* allocation bitmap _at_all_, and just use a 'best-fit' algorithm on the
* cached version, and update the bitmap later.
* RBF doesn't do any other search bit calls, so this is the routine.
L0E51               ldd       #$0100
L0E54               ldx       PD.BUF,y            where to start searching
                    leau      d,x                 where to stop searching
                    ldy       $0C,s               number of bits to find
* ATD: force it to be less than 1 sector here...
                    ifne      H6309
                    clrd                          at starting bit number 0
                    else
                    clra
                    clrb
                    endc
                    os9       F$SchBit
                    bcc       L0E9D               found bits
                    cmpy      8,s                 check number of found bits against our maximum
                    bls       L0E70               smaller, skip ahead
                    sty       8,s                 save as new maximum
                    std       $0A,s               save starting bit number
                    lda       6,s                 grab current sector
                    sta       7,s                 save for later
L0E70               ldy       <$10,s              grab old PD pointer
                    ldb       6,s                 grab current bitmap sector number
                    cmpb      4,s                 check against highest sector number of bitmap
                    bcs       L0E81               we're OK, skip ahead
                    bhi       L0E80               we're too high, skip ahead
                    tst       5,s                 check bytes in the sector
                    bne       L0E81               not zero: skip ahead
L0E80               clrb
L0E81               ldx       PD.DTB,y            get drive table pointer again
                    cmpb      V.MapSct,x          check against lowest reasonable bitmap sector
                    bne       L0E34               ifnot the same, continue

                    ldb       7,s                 grab sector number of largest block found
                    beq       L0EF0               zero, exit with E$Full error
                    cmpb      6,s                 is it the current sector?
                    beq       L0E96               yes, skip ahead
                    stb       6,s                 make it the current sector
                    lbsr      L1091               go read the sector in from disk

L0E96               ldx       PD.BUF,y            point to the sector in the buffer
                    ldd       $0A,s               grab starting bit number
                    ldy       8,s                 and number of bits to allocate
L0E9D               std       $0A,s               save starting bit number
                    sty       8,s                 and number of bits to allocate
                    os9       F$AllBit            go allocate the bits
                    ldy       $10,s               grab the PD pointer again
                    ldb       $06,s               and the sector number
                    lbsr      L1069               write it out to disk
                    bcs       L0EF2               exit on error
* ATD: add check for segments left to allocate, if we've allocated
* one entire sector's worth???
* What about special-purpose code to read the allocation bitmap byte by byte
* and do it that way?  I dunno...
* Have some routine inside L0DB5 call another routine which allocates segments
* one sector at a time... have a check: got one sector?
* ATD: We'll probably have to add in allocation bitmap caching for this
* to work properly....
                    ldx       PD.DTB,y            drive table pointer
                    lda       6,s                 current sector
                    deca                          decreemnt
                    sta       V.MapSct,x          AHA! Last searched sector for later use
                    clrb
                    lsla                          move high bit of A into CC.C
                    rolb                          move CC.C into B
                    lsla                          etc.
                    rolb                          cannot do a ROLD, as that would be LSB, ROLA
                    lsla                          i.e. move the 3 high bits of A into low bits of B
                    rolb                          and shift A by 3
                    stb       PD.SBP,y            save segment beginning physical sector number
                    ora       $0A,s               OR in with the start bit number
                    ldb       $0B,s               grab LSB of starting bit number
                    ldx       8,s                 and number of free sectors found
* ATD: Is this next line really necessary?
                    ldy       $10,s               get PD pointer
                    std       PD.SBP+1,y          save low 2 bytes of segment beginning physical SN
                    stx       PD.SSZ+1,y          and segment size in clusters
                    ldd       2,s                 grab number of sectors per cluster
                    bra       L0EE6

L0ED7               lsl       PD.SBP+2,y          shift physical sector numberup
                    rol       PD.SBP+1,y          to LSN, to account for cluster size
                    rol       PD.SBP,y
                    lsl       PD.SSZ+2,y
                    rol       PD.SSZ+1,y          shift segment cluster size to sector size
L0EE6
                    ifne      H6309
                    lsrd
                    else
                    lsra
                    rorb
                    endc
                    bcc       L0ED7

                    clrb                          no errors
                    ldd       PD.SSZ+1,y          number of sectors allocated
                    bra       L0EFA               and return to the user

L0EF0               ldb       #E$Full
L0EF2               ldy       $10,s               get old Y off of the stack
                    lbsr      L1070               return allocation bitmap?
                    coma
L0EFA               leas      $0E,s               skip 12-byte buffer, and D
                    puls      pc,u,y,x

* Set the size of a file to PD.SIZ, where PD.SIZ is SMALLER than the
* current size of the file.
L0EFE               clra                          clear the carry
* This code ensures that directories are never shrunk in size.
                    lda       PD.MOD,y            access mode
                    bita      #DIR.               directory?
                    bne       L0F6F               yes (bit set), exit immediately
                    ifne      H6309
                    ldq       PD.SIZ,y            grab size of the file
                    stq       PD.CP,y             make it the current position
                    else
                    ldd       PD.SIZ,y
                    std       PD.CP,y
                    ldd       PD.SIZ+2,y
                    std       PD.CP+2,y
                    endc
                    ldd       #$FFFF
                    tfr       d,x
                    lbsr      L0B1B
                    bcs       L0F6E
                    lbsr      L0CDF
                    bne       L0F6F               exit
                    lbsr      L10B2               find a segment
                    bcc       L0F26
                    cmpb      #E$NES              non-existing segment error
                    bra       L0F67

L0F26               ldd       PD.SBL+1,y          not quite sure what's going on here...
                    subd      PD.CP+1,y
                    addd      PD.SSZ+1,y
                    tst       PD.CP+3,y           on a sector boundary?
                    beq       L0F35               yes, skip ahead
                    ifne      H6309
                    decd      ok                  here, carry NOT used below
                    else
                    subd      #$0001
                    endc
L0F35               pshs      d
                    ldu       PD.DTB,y            number of sectors per cluster
                    ldd       DD.BIT,u
                    ifne      H6309
                    decd
                    comd
                    andd      ,s++
                    else
                    subd      #$0001
                    coma
                    comb
                    anda      ,s+
                    andb      ,s+
                    endc
                    ldu       PD.SSZ+1,y
                    std       PD.SSZ+1,y
                    beq       L0F69
                    tfr       u,d
                    subd      PD.SSZ+1,y
                    pshs      x,b,a
                    addd      PD.SBP+1,y
                    std       PD.SBP+1,y
                    bcc       L0F5F
                    inc       PD.SBP,y
L0F5F               bsr       ClrFBits            delete a segment
                    bcc       L0F70
                    leas      4,s
                    cmpb      #E$IBA              illegal block address

L0F67               bne       L0F6E
L0F69               lbsr      RdFlDscr
                    bcc       L0F79
L0F6E               coma
L0F6F               rts

L0F70               lbsr      RdFlDscr
                    bcs       L0FC9
                    puls      x,b,a
                    std       FDSL.B,x
L0F79               ldu       PD.BUF,y
                    ifne      H6309
                    ldq       PD.SIZ,y            grab file size from the PD
                    stq       FD.SIZ,u            save in the FD file size
                    else
                    ldd       PD.SIZ,y
                    std       FD.SIZ,u
                    ldd       PD.SIZ+2,y
                    std       FD.SIZ+2,u
                    endc
                    tfr       x,d
                    clrb
                    inca
                    leax      FDSL.S,x            go to the next segment
                    pshs      x,b,a
                    bra       L0FB4
L0F8E               ldd       -2,x
                    beq       L0FC1
                    std       PD.SSZ+1,y
                    ldd       -FDSL.S,x           grab stuff from the last segment
                    std       PD.SBP,y
                    lda       -FDSL.B,x
                    sta       PD.SBP+2,y          save sector beginning physical sector number
                    bsr       ClrFBits            delete a segment
                    bcs       L0FC9
                    stx       2,s
                    lbsr      RdFlDscr
                    bcs       L0FC9
                    ldx       2,s
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       -$05,x              clear out the segment
                    sta       -$03,x
                    std       -$02,x
L0FB4               lbsr      L11FD
                    bcs       L0FC9
                    ldx       2,s
                    leax      FDSL.S,x            go to the next segment
                    cmpx      ,s
                    bcs       L0F8E               if not done, do another
L0FC1               equ       *
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    sta       PD.SSZ,y
                    std       PD.SSZ+1,y          segment size is zero
L0FC9               leas      4,s
                    rts

* de-allocate a segment
ClrFBits            pshs      u,y,x,a             get device table pointer
                    ldx       PD.DTB,y

* ATD: Added next few lines to ENSURE that LSN0 and the allocation bitmap
* are NEVER marked as de-allocated in the allocation bitmap
*         ldd   PD.SBP,y     grab beginning segment physical LSN
*         bne   L0FD0        skip next code if too high
*         ldd   DD.MAP,x     get number of bytes in allocation bitmap
*         addd  #$01FF       add 1 for LSN0, round up a sector: A=lowest LSN
*         cmpa  PD.SBP+2,y   check LSN0 + DD.MAP against LSN to deallocate
*         blo   L0FD0        if PD.SBP is higher than LSN0 + DD.MAP, allow it
*         ldb   #E$IBA       illegal block address: can't deallocate LSN0
*         bra   L1033        or the allocation bitmap sectors from the bitmap!

                    ldd       DD.BIT,x
                    ifne      H6309
                    decd
                    else
                    subd      #$0001
                    endc
                    addd      PD.SBP+1,y
                    std       PD.SBP+1,y
                    ldd       DD.BIT,x
                    bcc       L0FF4
                    inc       PD.SBP,y
                    bra       L0FF4

L0FE5               lsr       PD.SBP,y            convert sector number to cluster number
                    ror       PD.SBP+1,y
                    ror       PD.SBP+2,y
                    lsr       PD.SSZ+1,y
                    ror       PD.SSZ+2,y
L0FF4               equ       *
                    ifne      H6309
                    lsrd
                    else
                    lsra
                    rorb
                    endc
                    bcc       L0FE5

                    clrb
                    ldd       PD.SSZ+1,y
                    beq       L1034
                    ldd       PD.SBP,y
                    ifne      H6309
                    lsrd
                    lsrd
                    lsrd                          get cluster byte number into D
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    endc
                    tfr       b,a
                    ldb       #E$IBA
                    cmpa      DD.MAP,x            is the LSN too high: mapped outside of the bitmap?
                    bhi       L1033               yes, error out
                    inca
                    sta       ,s
L1012               bsr       L1036               flush the sector, and OWN the bitmap
                    bcs       L1012
                    ldb       ,s                  grab the sector number
                    bsr       L1091               go read a sector fro the allocation bitmap
                    bcs       L1033
                    ldx       PD.BUF,y            where to start
                    ldd       PD.SBP+1,y          bit offset to delete
* ATD: keep deleting sectors until we're done!
                    anda      #$07                make sure it's within the current sector
* ATD: fix segment sizes!
                    ldy       PD.SSZ+1,y          number of clusters to deallocate
                    os9       F$DelBit            go delete them (no error possible)
                    ldy       3,s
                    ldb       ,s                  grab bitmap sector number again
                    bsr       L1069               go write it out
                    bcc       L1034               xit on error
L1033               coma
L1034               puls      pc,u,y,x,a

L1036               lbsr      L1237               flush the sector to disk
                    bra       L1043               skip ahead

L103B               lbsr      L0C56               wakeup the process
                    os9       F$IOQu              queue the process
                    bsr       L1053               check for process wakeup
L1043               bcs       L1052               error, return
                    ldx       PD.DTB,y            get drive table ptr
                    lda       V.BMB,x             bitmap sector
                    bne       L103B               if set, continue
                    lda       PD.CPR,y            get our process number
                    sta       V.BMB,x             make us the current user of the bitmap
L1052               rts

* Wait for process to wakeup
L1053               ldu       <D.Proc             get current process pointer
                    ldb       P$Signal,u          get pending signal
                    cmpb      #S$Wake             is it what we're looking for?
                    bls       L1060               yes, skip ahead
                    cmpb      #S$Intrpt           is it a keyboard interrupt/
                    bls       L1067               no, return error [B]=Error code
L1060               clra                          clear error status
                    ifne      H6309
                    tim       #Condem,P$State,u   is process dead?
                    else
                    lda       P$State,u
                    bita      #Condem
                    endc
                    beq       L1068               no, skip ahead
L1067               coma                          flag error
L1068               rts                           return

* Write a file allocation bitmap sector
* Entry: B=Logical sector #
L1069               clra                          clear MSB of LSW to logical sector #
                    tfr       d,x                 move it to proper register
                    clrb                          clear MSB of logical sector #
                    lbsr      L1207               flush the sector to drive
L1070               pshs      cc                  preserve error status from write
                    ldx       PD.DTB,y            get drive table pointer
                    lda       PD.CPR,y            get the current process using it
                    cmpa      V.BMB,x             same as process using the bit-map sector?
                    bne       L108F               no, return
                    clr       V.BMB,x             clear the use flag
                    ldx       <D.Proc             get current process pointer
                    lda       P$IOQN,x            get next process in line for sector
                    beq       L108F               none, return
                    lbsr      L0C56               wake up the process
                    ldx       #1                  sleep for balance of tick
                    os9       F$Sleep
L108F               puls      pc,cc               restore error status & return

* Read a sector from file allocation bit map
* Entry: B=Logical sector #
L1091               clra                          clear MSB of LSW to logical sector #
                    tfr       d,x                 move to proper register
                    clrb                          clear MSB of logical sector #
                    lbra      L113A               go read the sector

* Entry: Y=Path descriptor pointer
L1098               ldd       PD.CP+1,y
                    subd      PD.SBL+1,y
                    tfr       d,x
                    ldb       PD.CP,y
                    sbcb      PD.SBL,y
                    cmpb      PD.SSZ,y
                    bcs       L10B0
                    bhi       L10B2               yes, scan the segment list
                    cmpx      PD.SSZ+1,y
                    bcc       L10B2
L10B0               clrb
L10B1               rts

* Scan file segment list to get proper segment based on current byte position
* in the file.  Once found it will be placed in the path descriptor
* Entry: None
L10B2               pshs      u                   preserve
                    bsr       RdFlDscr            get the file descriptor
                    bcs       L110E               error, return
                    ifne      H6309               init the start point of search in path descriptor
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       PD.SBL,y
                    stb       PD.SBL+2,y
                    ldu       PD.BUF,y            get sector buffer pointer
                    leax      FD.SEG,u            point to segment list
                    lda       PD.BUF,y            get MSB of sector buffer pointer
                    ldb       #$FC                get size of segment table
                    pshs      b,a                 save as table end pointer
* Scan segment list for the proper segment
L10CB               ldd       FDSL.B,x            get segment size in sectors
                    beq       L10F0               last one, exit with non existing segment error
                    addd      PD.SBL+1,y          add to segment start LSN
                    tfr       d,u                 copy it
                    ldb       PD.SBL,y
                    adcb      #0
                    cmpb      PD.CP,y             this the segment we want?
                    bhi       L10FD               yes, move the segment start & size to descriptor
                    bne       L10E4               no, save this segment & keep looking
                    cmpu      PD.CP+1,y
                    bhi       L10FD
L10E4               stb       PD.SBL,y
                    stu       PD.SBL+1,y
                    leax      FDSL.S,x            move to next segment
                    cmpx      ,s                  done?
                    bcs       L10CB               no, keep going

* Return Non-Existing segment error
L10F0               equ       *
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    sta       PD.SSZ,y            zero out the segment
                    std       PD.SSZ+1,y
                    comb                          set the carry
                    ldb       #E$NES              non-existing segment
                    bra       L110C               return

* Move segment to path descriptor
L10FD               ldd       FDSL.A,x            get start physical sector #
                    std       PD.SBP,y            put it in path descriptor
                    lda       FDSL.A+2,x
                    sta       PD.SBP+2,y
                    ldd       FDSL.B,x            get segment size
                    std       PD.SSZ+1,y          put it in path descriptor
L110C               leas      2,s
L110E               puls      pc,u

* Read LSN0 from drive
* Entry: Y=Path descriptor pointer
L1110               pshs      x,b                 preserve regs used
                    lbsr      L1237               flush sector buffer
                    bcs       L111F               error, return
                    clrb                          get LSN
                    ldx       #$0000
                    bsr       L113A               read the sector
                    bcc       L1121               no error, return
L111F               stb       ,s                  save error code
L1121               puls      pc,x,b              restore & return

* Read a file descriptor from disk
* Entry: Y=Path descriptor pointer
RdFlDscr
                    ifne      H6309
                    tim       #FDBUF,PD.SMF,y     FD already here?
                    else
                    ldb       PD.SMF,y
                    bitb      #FDBUF
                    endc
                    bne       L10B0               yes, return no error
                    lbsr      L1237               flush any sector here
                    bcs       L10B1               error, return
                    ifne      H6309
                    oim       #FDBUF,PD.SMF,y
                    else
                    lda       PD.SMF,y
                    ora       #FDBUF
                    sta       PD.SMF,y
                    endc
                    ldb       PD.FD,y             get MSB of logical sector
                    ldx       PD.FD+1,y           get LSW of logical sector
L113A               lda       #D$READ             get read offset
* Send command to device driver
* Entry: A=Driver Command offset
*        B=MSB of logical sector #
*        X=LSW of logical sector #
*        Y=Path descriptor pointer
L113C               pshs      u,y,x,b,a           preserve it all
                    ifne      H6309
                    oim       #InDriver,PD.SMF,y  flag we're in ddriver
                    else
                    lda       PD.SMF,y
                    ora       #InDriver
                    sta       PD.SMF,y
                    endc
                    ldx       <D.Proc             get current process pointer
                    lda       P$Prior,x           get its priority
                    tfr       a,b                 copy it
                    addb      #3                  add 3 to it
                    bcc       L1150               didn't wrap, skip ahead
                    ldb       #$FF                force it to max
L1150               stb       P$Prior,x           save priority
                    stb       P$Age,x             asage too
                    ldx       PD.Exten,y          get path extension pointer
                    sta       PE.Prior,x          save original priority there
                    ldu       PD.DEV,y            get device table pointer
                    ldu       V$STAT,u            get static mem pointer
                    bra       L1166               go execute driver
* Wait for device
L1160               lbsr      L0C56               wakeup waiting process
                    os9       F$IOQu              queue device
* Device ready, send command
L1166               lda       V.BUSY,u            driver already busy?
                    bne       L1160               yes, queue it
                    lda       PD.CPR,y            get current process #
                    sta       V.BUSY,u            save it as busy
                    ldd       ,s                  get command & logical sector from stack
                    ldx       2,s
                    pshs      u                   save static mem
                    bsr       L11EB               send it to driver
                    puls      u                   restore static mem
                    ldy       4,s                 get path descriptor pointer
                    pshs      cc                  preserve driver error status
                    bcc       L1181               no error, skip ahead
                    stb       2,s                 save driver's error code
L1181               equ       *
                    ifne      H6309
                    aim       #^InDriver,PD.SMF,y clear in driver flag
                    else
                    lda       PD.SMF,y
                    anda      #^InDriver
                    sta       PD.SMF,y
                    endc
                    clr       V.BUSY,u
                    ldx       PD.Exten,y
                    lda       PE.Prior,x
                    ldx       <D.Proc
                    sta       P$Prior,x
******
* this code is in v31 only
                    lda       ,s                  get driver error status
                    bita      #Carry              was there an error?
                    bne       L11CB               yes, return with it
                    lda       1,s                 get the driver command
                    cmpa      #D$WRIT             was it write sector?
                    bne       L11CB               no, return
                    pshs      u,y,x               preserve regs
                    ldy       PD.Exten,y
                    leau      ,y
L11A7               ldx       PE.Confl,u
                    cmpy      PE.Confl,u
                    beq       L11C9
                    leau      ,x

* Check for signal on data write
                    lda       PE.SigID,u          anything to send signal to?
                    beq       L11A7               no, skip to next in chain
                    ldx       <D.Proc             get current process
                    cmpa      P$ID,x
                    beq       L11A7
                    clr       PE.SigID,u
                    ldb       PE.SigSg,u
                    os9       F$Send
                    bra       L11A7

L11C9               puls      u,y,x
L11CB               lda       P$IOQN,x            any process waiting?
                    beq       L11E9               no, return
                    lda       $01,y
                    bita      #$04
                    bne       L11E9
                    ldx       PD.DTB,y            get driver table pointer
                    lda       PD.CPR,y            get current process ID
                    cmpa      V.BMB,x             same as bitmap use process?
                    beq       L11E9               yes, return
                    lbsr      L0C56
                    ldx       #1                  sleep for balance of tick
                    os9       F$Sleep
L11E9               puls      pc,u,y,x,b,a,cc     restore & return

* Execute device driver
* Entry: A=Driver command offset
*        B=MSB of logical sector #
*        X=LSW of logical sector #
*        Y=Path descriptor pointer
*        U=Static memory pointer
L11EB               pshs      pc,x,b,a
                    ldx       $03,y
                    ldd       ,x
                    ldx       ,x
                    addd      $09,x
                    addb      ,s
                    adca      #$00
                    std       $04,s
                    puls      pc,x,b,a

* Write file descriptor to disk
* Entry: Y=Path descriptor pointer
L11FD               ldb       PD.FD,y             get MSB of LSN
                    ldx       PD.FD+1,y           get LSW of LSn
                    bra       L1207               send it to disk


* Flush sector buffer to disk
* Entry: Y=Path descriptor pointer
L1205               bsr       L1220               calulate LSN
L1207               lda       #D$WRIT             get driver write offset
                    pshs      x,b,a               preserve that & LSN
                    ldd       PD.DSK,y            get disk ID of this sector
                    beq       L1216               nothing, send it to driver
                    ldx       PD.DTB,y            get drive table pointer
                    cmpd      DD.DSK,x            match ID from drive?
L1216               puls      x,b,a               restore regs
                    lbeq      L113C               ID matches, send data to driver
                    comb                          set carry
                    ldb       #E$DIDC             get ID change error code
                    rts                           return

* Calculate logical sector # of current sector in buffer
* Exit : B=MSB of logical sector #
*        X=LSW of logical sector #
L1220               ldd       PD.CP+1,y           get current logical sector loaded
                    subd      PD.SBL+1,y          subtract it from segment list LSN
                    tfr       d,x                 copy answer
                    ldb       PD.CP,y             get MSB of byte position
                    sbcb      PD.SBL,y            subtract it from segment start
                    exg       d,x
                    addd      PD.SBP+1,y          add in physical segment sector #
                    exg       d,x
                    adcb      PD.SBP,y            now the MSB
                    rts                           return

* Check if sector buffer needs to be flushed to disk
* Entry: Y=Path descriptor pointer
L1237               clrb                          clear carry
                    pshs      u,x                 preserve regs
                    ldb       PD.SMF,y            get state flags
                    andb      #(BufBusy!FDBUF!SINBUF) anything in buffer?
                    beq       L1254               no, return
                    tfr       b,a                 duplicate flags
                    eorb      PD.SMF,y            clear them
                    stb       PD.SMF,y            save 'em
                    andb      #BUFMOD             has buffer been modified?
                    beq       L1254               no, return
                    eorb      PD.SMF,y            clear that bit
                    stb       PD.SMF,y            save it
                    bita      #SINBUF             is there even a sector in buffer?
                    beq       L1254               no, return
                    bsr       L1205               flush the sector to drive
L1254               puls      pc,u,x              restore & return

L1256               pshs      u,x
                    lbsr      L1098
                    bcs       L12C6
                    bsr       L1237
                    bcs       L12C6
L1261               ldb       PD.CP,y
                    ldu       PD.CP+1,y
                    leax      ,y
                    ldy       PD.Exten,y
L126B               ldx       PD.Exten,x
                    cmpy      PE.Confl,x
                    beq       L12B5
                    ldx       PE.Confl,x
                    ldx       PE.PDptr,x
                    cmpu      PD.CP+1,x
                    bne       L126B
                    cmpb      PD.CP,x
                    bne       L126B
                    lda       PD.SMF,x
                    bita      #SINBUF
                    beq       L126B
                    bita      #InDriver
                    bne       L128E
                    bita      #BufBusy
                    beq       L12A0
L128E               lda       PD.CPR,x
                    ldy       PE.PDptr,y
                    lbsr      L0C56
                    os9       F$IOQu
                    lbsr      L1053
                    bcc       L1261
                    puls      u,x,pc

L12A0               ldy       PE.PDptr,y
                    ldd       PD.BUF,x
                    ldu       PD.BUF,y
                    std       PD.BUF,y
                    stu       PD.BUF,x
                    lda       PD.SMF,x            \ careful, don't use oim here
                    ora       #BufBusy            >takes state from x and
                    sta       PD.SMF,y            / stores to y, is infamous "lha" bug
                    clr       PD.SMF,x
                    puls      pc,u,x

L12B5               ldy       PE.PDptr,y
                    lbsr      L1220
                    lbsr      L113A
                    bcs       L12C6
                    ifne      H6309
                    oim       #(BufBusy!SINBUF),PD.SMF,y
                    else
                    pshs      a
                    lda       PD.SMF,y
                    ora       #(BufBusy!SINBUF)
                    sta       PD.SMF,y
                    puls      a
                    endc
L12C6               puls      pc,u,x

                    emod
eom                 equ       *
                    end

