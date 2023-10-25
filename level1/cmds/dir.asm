********************************************************************
* Dir - Show directory
*
* $Id$
*
* This dir initially started from the dir command that came with
* the OS-9 Level Two package, then incorporated Glenside's Y2K
* fix.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  10      1999/05/11  Boisy G. Pitre
* Incorporated Glenside Y2K fixes.
*
*  11      2003/01/14  Boisy G. Pitre
* Made option handling more flexible, now they must be preceeded
* by a dash.
*
*  11      2003/01/14  Boisy G. Pitre
* Made option handling more flexible, now they must be preceeded
* by a dash.
*
*  11r1    2005/04/19  Boisy G. Pitre
* Made column width code more robust.
*
*  12      2005/11/22  Boisy G. Pitre
* -e option now uses SS.FDInf for portability to other file managers

;;; dir
;;;
;;; Syntax:	dir [<opts>] [<path>]
;;; Usage:	Displays formatted list of the file names in a directory
;;; Parameters:
;;;     -e  extended directory listing
;;;     -x  execution directory

                    nam       Dir
                    ttl       Show directory

* Disassembled 99/04/11 16:36:40 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

                    org       0
nextdir             rmb       2
dircount            rmb       1
dirpath             rmb       1
extended            rmb       1
addmode             rmb       1                   additional mode
u0006               rmb       2
colwidth            rmb       1
lastcol             rmb       1
narrow              rmb       1
bufptr              rmb       2
date                rmb       3
time                rmb       3
dent                rmb       DIR.SZ
fdsect              rmb       FD.Creat-FD.ATT
linebuff            rmb       530
size                equ       .

colsize             equ       16

name                fcs       /Dir/
                    fcb       edition

DirOf               fcb       C$LF
                    fcs       " Directory of "
Dot                 fcc       "."
                    fcb       C$CR
WHeader             fcb       C$CR,C$LF
                    fcc       "Owner  Last modified   Attributes Sector Bytecount Name"
                    fcb       C$CR,C$LF
                    fcc       "----- ---------------- ---------- ------ --------- ----"
                    fcb       C$CR,C$LF
WHeaderL            equ       *-WHeader
NHeader             fcb       C$CR,C$LF
                    fcc       "Modified on  Owner   Name"
                    fcb       C$CR,C$LF
                    fcc       "  Attr     Sector     Size"
                    fcb       C$CR,C$LF
                    fcc       "==============================="
                    fcb       C$CR
                    fcb       C$LF
NHeaderL            equ       *-NHeader

start               leay      <linebuff,u         get ptr to line buffer
                    sty       <bufptr             and save it
                    clr       <addmode
                    clr       <extended
                    clr       <narrow
                    clr       <dircount
                    pshs      y,x,b,a
                    ldd       #$01*256+SS.ScSiz   standard output and screen size call
                    os9       I$GetStt            get it
                    bcc       L0120               branch if gotten
                    ldx       #80
L0120               tfr       x,d
                    cmpb      #51
                    bgt       higher
                    inc       <narrow
                    lda       #10
                    fcb       $8C
higher              lda       #16
                    pshs      a
                    subb      ,s+
                    std       <colwidth           save new column width and last column
                    puls      y,x,b,a
                    pshs      x                   save start of command line
                    lbsr      GetOpts             parse for options
                    puls      x                   get start of command line
                    lbsr      SkipSpcs            skip any spaces
                    cmpa      #C$CR               any dir names?
                    bne       opendir             branch if so
                    leax      >Dot,pcr            else assume dot
opendir             stx       <nextdir
                    lda       #DIR.+READ.
                    ora       <addmode
                    pshs      x,a                 preserve mode, dir name
                    os9       I$Open
                    sta       <dirpath
                    puls      x,a                 get mode, dir name
                    lbcs      L0268
                    os9       I$ChgDir            change to dir
                    lbcs      L0268               branch if error
                    pshs      x                   X now points just past name
                    leay      >DirOf,pcr          point to "Dir of..."
                    lbsr      PutStr              put it in buffer
                    ldx       <nextdir            point to directory we are processing
L0161               lda       ,x+                 get char
                    lbsr      PutNBuf             put in buffer
                    cmpx      ,s                  at end of char string?
                    bcs       L0161               branch if not
                    leas      $02,s               else clean  up stack
                    lbsr      PutSpace            and put a space
                    lbsr      PutSpace            and another one
                    leax      date,u              point to date buffer
                    os9       F$Time              get current time
                    leax      <time,u             point to time
                    lbsr      ShowDate            show it
                    lbsr      CRnWrite
                    tst       <extended
                    beq       L01B3
                    tst       <narrow
                    bne       L01A6
                    leax      >WHeader,pcr
                    ldy       #WHeaderL
                    bra       L01AE
L01A6               leax      >NHeader,pcr
                    ldy       #NHeaderL
L01AE               lda       #$01
                    os9       I$Write
L01B3               lda       <dirpath
                    ldx       #$0000
                    pshs      u
                    ldu       #DIR.SZ*2
                    os9       I$Seek
                    puls      u
                    lbra      L0253
L01C5               tst       <dent
                    lbeq      L0253
                    tst       <extended
                    bne       L01E8
                    leay      <dent,u
                    lbsr      PutStr
L01D5               lbsr      PutSpace
                    ldb       <bufptr+1
                    subb      #64
                    cmpb      <lastcol
                    bhi       L022C
L01E0               subb      <colwidth
                    bhi       L01E0
                    bne       L01D5
                    bra       L0253
L01E8
* Use SS.FDInf to get the file descriptor sector
                    pshs      u
                    lda       <dent+DIR.FD
                    ldb       #FD.Creat-FD.ATT
                    tfr       d,y
                    leax      <fdsect,u
                    lda       <dirpath
                    ldb       #SS.FDInf
                    ldu       <dent+DIR.FD+1
                    os9       I$GetStt
                    puls      u
                    bcs       L0268               branch if SS.FDInf fails
                    tst       <narrow             are we on a narrow screen?
                    bne       L0231               branch if so

* Wide extended output
                    ldd       <fdsect+FD.OWN
                    clr       <u0006
                    bsr       L0274
                    lbsr      PutSpace
                    lbsr      L030B
                    lbsr      PutSpace
                    lbsr      L02D3
                    lbsr      PutSpace
                    lbsr      PutSpace
                    bsr       L026E
                    bsr       L0280
                    leay      <dent,u
                    lbsr      PutStr
L022C               lbsr      CRnWrite
                    bra       L0253

* Narrow extended output
L0231               lbsr      L030B
                    ldd       <fdsect+FD.OWN
                    clr       <u0006
                    bsr       L0274
                    bsr       PutSpace
                    leay      <dent,u
                    lbsr      PutStr
                    lbsr      CRnWrite
                    lbsr      L02D3
                    bsr       PutSpace
                    bsr       PutSpace
                    bsr       L026E
                    bsr       L0280
                    lbsr      CRnWrite
L0253               leax      <dent,u
                    ldy       #DIR.SZ
                    lda       <dirpath
                    os9       I$Read
                    lbcc      L01C5
                    cmpb      #E$EOF
                    bne       L0268
                    clrb
L0268               lbsr      CRnWrite
Exit                os9       F$Exit
L026E               lda       <dent+DIR.FD
                    bsr       L0298
                    ldd       <dent+DIR.FD+1
L0274               bsr       L029A
                    tfr       b,a
                    bsr       L028E
                    inc       <u0006
                    bsr       L029C
                    bra       PutSpace
L0280               ldd       <fdsect+FD.SIZ
                    bsr       L0298
                    tfr       b,a
                    bsr       L029A
                    bsr       PutSpace
                    ldd       <fdsect+FD.SIZ+2
                    bra       L0274
L028E               pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L029E
                    puls      pc,a
L0298               clr       <u0006
L029A               bsr       L028E
L029C               anda      #$0F
L029E               tsta
                    beq       L02A3
                    sta       <u0006
L02A3               tst       <u0006
                    bne       L02AB
                    lda       #C$SPAC
                    bra       PutNBuf
L02AB               adda      #'0
                    cmpa      #'9
                    bls       PutNBuf
                    adda      #$07
                    bra       PutNBuf
PutSpace            lda       #C$SPAC

* Entry: A = char to put in buffer
PutNBuf             pshs      x                   save caller's X
                    ldx       <bufptr             get buffer next pointer
                    cmpx      #$0090              past end?
                    bne       PutOk               branch if not
                    bsr       WriteBuf
                    ldx       <bufptr             get pointer
PutOk               sta       ,x+                 save A
                    stx       <bufptr             and update pointer
                    puls      pc,x                return

PermMask            fcc       "dsewrewr"
                    fcb       $FF

L02D3               ldb       <fdsect+FD.ATT
                    leax      <PermMask,pcr
                    lda       ,x+
L02DA               lslb
                    bcs       L02DF
                    lda       #'-
L02DF               bsr       PutNBuf
                    lda       ,x+
                    bpl       L02DA
                    rts

* Put hi-bit terminated string at Y into line buffer
PutStr              lda       ,y                  get char in A from Y
                    anda      #$7F                strip off hi-bit
                    bsr       PutNBuf             put in buffer
                    lda       ,y+                 get char again
                    bpl       PutStr              if hi-bit not set, continue
                    rts

WriteBuf            pshs      y,x,b,a
                    bra       DoWrite
CRnWrite            pshs      y,x,b,a
                    lda       #C$CR
                    bsr       PutNBuf
DoWrite             leax      <linebuff,u
                    stx       <bufptr
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,y,x,b,a
L030B               leax      <fdsect+FD.DAT,u
L030E               bsr       L0338
                    bsr       L0324
                    bsr       L0324
                    bsr       PutSpace
                    bsr       Byte2ASC
                    tst       <narrow
                    beq       L0320
                    bsr       Byte2ASC
                    bra       PutSpace
L0320               bsr       DoColon
                    bra       PutSpace
L0324               lda       #'/
                    bra       L0334

ShowDate            tst       <narrow             are we on a narrow screen?
                    bne       ShowTime            branch if we are
                    leax      date,u              else point to date buffer
                    bra       L030E               and show date and time
ShowTime            bsr       Byte2ASC            show hours
DoColon             lda       #':                 put up colon
L0334               bsr       PutNBuf             put in buffer
                    bra       Byte2ASC            show minutes

L0338               lda       #'.+128
                    ldb       ,x
L033C               inca
                    subb      #100
                    bcc       L033C
                    stb       ,x
                    tfr       a,b
                    tst       <narrow
                    bne       L034B
                    bsr       L035F
L034B               ldb       ,x+
                    bra       L035F

* Get byte at X and put ASCII value in buffer
Byte2ASC            ldb       ,x+
                    lda       #$2F
L0353               inca
                    subb      #100
                    bcc       L0353
                    cmpa      #'0
                    beq       L035F
                    lbsr      PutNBuf
L035F               lda       #$3A
L0361               deca
                    addb      #10
                    bcc       L0361
                    lbsr      PutNBuf
                    tfr       b,a
                    adda      #'0
                    lbra      PutNBuf

* Entry: X = ptr to line to start parsing
GetOpts             lda       ,x+                 get next char on cmd line
                    cmpa      #C$CR               CR?
                    beq       L039A               yep, return
                    cmpa      #'-                 option?
                    beq       GetDash             branch if not
* Must be dir name, skip
                    inc       <dircount
                    bsr       SkipNSpc            skip spaces
ChkDash             bsr       SkipSpcs            skip spaces
                    bra       GetOpts             and resart parsing
L039A               rts

GetDash             lda       #C$SPAC
                    sta       -1,x
GetDash2            ldd       ,x+
                    ora       #$20                make lowercase
IsItE               cmpa      #'e                 extended dir?
                    bne       IsItX
                    sta       <extended
                    bra       FixCmdLn
IsItX               cmpa      #'x
                    beq       ItIsX
                    ldb       #E$IllArg
                    lbra      Exit                bad option, just exit
ItIsX               lda       #EXEC.
                    sta       <addmode
FixCmdLn            lda       #C$SPAC
                    sta       -1,x
                    cmpb      #'0
                    lblt      ChkDash
                    bra       GetDash

SkipSpcs            lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipSpcs
                    leax      -1,x
                    rts

SkipNSpc            lda       ,x+
                    cmpa      #C$SPAC
                    beq       SkipNRTS
                    cmpa      #C$CR
                    bne       SkipNSpc
SkipNRTS            leax      -1,x
                    rts

                    emod
eom                 equ       *
                    end
