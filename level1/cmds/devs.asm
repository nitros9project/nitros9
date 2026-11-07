********************************************************************
* devs - Show device table entries
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* Original version.
*
*   3      ????/??/??  Alan DeKok
* Reworked.
*
*   3      2003/01/07  Boisy G. Pitre
* Renamed to devs ala OS-9/68K, reworked.
*
*   4      2026/09/27  Mark Murray
* Added -a to also list every device descriptor module in memory.

                    nam       devs
                    ttl       Show device table entries

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

MaxEnts             set       64                  maximmum entries we display

                    org       0
memstrt             rmb       2
outptr              rmb       2
counter             rmb       1
narrow              rmb       1
curdte              rmb       2
ddevtbl             rmb       2                   device table pointer
devcount            rmb       1
descptr             rmb       2
numbytes            rmb       1
allflag             rmb       1                   nonzero for -a
mdcur               rmb       2                   current module directory entry
mdend               rmb       2                   end of the module directory
lnbuff              rmb       80
                    ifgt      Level-1
datimg              rmb       4
mdsys               rmb       2                   system address of the module directory
datptr              rmb       2                   local copy of the module's DAT image
modptr              rmb       2                   module address within its DAT image
devtbcpy            rmb       MaxEnts*DEVSIZ
descrip             rmb       256
syspdesc            rmb       P$Size
mdbuf               rmb       4096                copy of the module directory
                    endc
stack               rmb       200
size                equ       .

name                fcs       /devs/
                    fcb       edition

Header1             fcc       /Device Table at: /
x12Len              equ       *-Header1
NHeader             fcc       /Dv Desc  Drvr   Stat  File  Usr/
                    fcb       C$CR
NHeaderL            equ       *-NHeader
NHeader2            fcc       /Nm Port  Name    Mem  Mgr   Cnt/
                    fcb       C$CR
NHeader2L           equ       *-NHeader2
NUndln              fcc       /-------  -----------  ----  ---/
                    fcb       C$CR
NUndlnL             equ       *-NUndln
Header              fcc       /Device Desc  Driver Static  File    Usr/
                    fcb       C$CR
HeaderL             equ       *-Header
Header2             fcc       /Name   Port  Name      Mem  Manager Cnt/
                    fcb       C$CR
Header2L            equ       *-Header2
Undln               fcc       /-----------  -------------  ------- ---/
MyCR                fcb       C$CR
UndlnL              equ       *-Undln
AHeader             fcc       /Device Desc  Driver   File     Link/
                    fcb       C$CR
AHeaderL            equ       *-AHeader
AHeader2            fcc       /Name   Port  Name     Manager  Cnt/
                    fcb       C$CR
AHeader2L           equ       *-AHeader2
AUndln              fcc       /-----------  -------- -------  ----/
                    fcb       C$CR
AUndlnL             equ       *-AUndln
NAHeader            fcc       /Dv Desc  Drvr   File   Lnk/
                    fcb       C$CR
NAHeaderL           equ       *-NAHeader
NAHeader2           fcc       /Nm Port  Name   Mgr    Cnt/
                    fcb       C$CR
NAHeader2L          equ       *-NAHeader2
NAUndln             fcc       /-------  ------ ------ ---/
                    fcb       C$CR
NAUndlnL            equ       *-NAUndln
Init                fcs       /Init/

start               ldd       ,x                  get parameter bytes
                    cmpd      #$2D3F              -?
                    lbeq      Help
                    clr       <allflag            assume the device table only
                    andb      #$DF                make the option letter upper case
                    cmpd      #$2D41              -a?
                    bne       noall               branch if not
                    inc       <allflag            else list every descriptor too
noall               lda       #MaxEnts            get maximum entries we support
                    sta       <devcount           and save as count
                    leax      Init,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    bcs       Exit
                    lda       <DevCnt,u           get device count
                    os9       F$UnLink            unlink module
                    puls      u                   restore static pointer
                    cmpa      <devcount           is table same or larger than our default?
                    bge       cont                branch if so
                    sta       <devcount           else store smaller count
cont                stu       <memstrt
                    clr       <narrow             assume wide
                    lda       #$01
                    ldb       #SS.ScSiz
                    os9       I$GetStt
                    bcs       cont2
                    cmpx      #HeaderL+1
                    bge       cont2
                    sta       <narrow
cont2               leax      >MyCR,pcr
                    ldy       #$0001
                    os9       I$WritLn            output a CR
                    lbcs      Exit
                    leax      >Header1,pcr        dump out header
                    ldy       #x12Len
                    os9       I$Write
                    lbcs      Exit
                    ifgt      Level-1
                    lda       #$01
                    leax      >syspdesc,u
                    os9       F$GPrDsc            get system process descriptor
                    bcs       Exit
                    leax      <P$DATImg,x
                    stx       <datimg             save address of system's DAT image
                    endc
                    bra       L00D3

ClnExit             clrb
Exit                os9       F$Exit

L00D3               equ       *
                    ifgt      Level-1
                    ldu       <memstrt
                    leau      <ddevtbl,u
                    ldd       <datimg
                    ldx       #D.DevTbl           I/O device table
                    ldy       #$0002              size of the pointer
                    os9       F$CpyMem
                    lbcs      Exit
                    ldu       <memstrt
                    ldd       <ddevtbl
                    else
                    ldd       >D.DevTbl
                    std       <ddevtbl
                    endc
                    leay      <lnbuff,u
                    sty       <outptr
                    lbsr      HexWord             output D as hex word
                    lbsr      PrintBuf

                    lda       #$01
                    leax      >MyCR,pcr           dump out another CR
                    ldy       #$0001
                    os9       I$WritLn
                    lbcs      Exit

                    leax      >Header,pcr
                    ldy       #HeaderL
                    tst       <narrow
                    beq       branch1
                    leax      >NHeader,pcr
                    ldy       #NHeaderL
branch1             os9       I$WritLn
                    lbcs      Exit

                    leax      >Header2,pcr
                    ldy       #Header2L
                    tst       <narrow
                    beq       branch2
                    leax      >NHeader2,pcr
                    ldy       #NHeader2L
branch2             os9       I$WritLn
                    lbcs      Exit
                    leax      >Undln,pcr
                    ldy       #UndlnL
                    tst       <narrow
                    beq       branch3
                    leax      >NUndln,pcr
                    ldy       #NUndlnL
branch3             os9       I$WritLn
                    lbcs      Exit

                    ifgt      Level-1
                    ldu       <memstrt
                    lda       <devcount
                    ldb       #DEVSIZ
                    mul
                    tfr       d,y
                    leau      >devtbcpy,u
                    ldx       <ddevtbl
                    ldd       <datimg
                    os9       F$CpyMem            copy the device table over
                    lbcs      Exit
                    stu       <curdte             save pointer to start of DevTbl
                    else
                    ldd       <ddevtbl
                    std       <curdte
                    endc
                    ldb       <devcount
                    stb       <counter            total number of entries to get

L0155               bsr       L0165
                    dec       <counter
                    lbeq      Done                if done them all, finish up

                    ldx       <curdte             get current pointer
                    leax      DEVSIZ,x            go to the next one
                    stx       <curdte             save the pointer again
                    bra       L0155               and loop back

L0165               ldu       <memstrt            get static pointer
                    leay      <lnbuff,u           point to line buffer
                    sty       <outptr             save as ptr
                    lda       #C$SPAC             space
                    ldb       #5                  assume this length
                    tst       <narrow             are we narrow?
                    beq       L0171               branch if not
                    ldb       #3                  else load new size
L0171               sta       ,y+                 save spaces
                    decb
                    bne       L0171

                    ldx       <curdte             get the current pointer
                    ldx       V$DESC,x            descriptor?
                    bne       L017D               if exists, go do it
                    rts                           otherwise exit

L017D               equ       *
                    ifgt      Level-1
                    pshs      u
                    leau      >descrip,u          to another buffer
                    ldd       <datimg             system DAT image
                    ldy       #256
                    os9       F$CpyMem
                    puls      u
                    lbcs      Exit

                    leax      >descrip,u          point to the start of the buffer
                    else
                    stx       <descptr            save descriptor pointer
                    endc
                    ldd       M$Name,x            pointer to the name
                    leax      d,x
                    lda       #5                  assume this size
                    tst       <narrow             are we narrow?
                    beq       branch4             branch if not
                    lda       #3                  else get new size
branch4             bsr       Str2Buf             dump out the first few bytes of the name

                    ifgt      Level-1
                    leax      >descrip,u
                    else
                    ldx       <descptr
                    endc
                    tst       <narrow
                    bne       skip1
                    lda       M$Port,x            port address of the device
                    lbsr      HexByte
                    ldy       <outptr
                    leay      -1,y
                    sty       <outptr
skip1               ldd       M$Port+1,x
                    lbsr      HexWord
                    lbsr      Space
*         IFGT  Level-1
*         leax  >descrip,u
*         ELSE
*         ldx   <descptr
*         ENDC
                    ldd       M$PDev,x            device driver name offset
                    leax      d,x
                    lda       #9
                    tst       <narrow
                    beq       branch5
                    lda       #7
branch5             bsr       Str2Buf             dump out bytes of the driver name
                    ldx       <curdte
                    ldd       V$STAT,x
                    lbsr      HexWord
                    lbsr      Space
                    ifgt      Level-1
                    leax      >descrip,u
                    else
                    ldx       <descptr
                    endc
                    ldd       M$FMGr,x            file manager name offset
                    leax      d,x                 point to it
                    lda       #9
                    tst       <narrow
                    beq       branch6
                    lda       #7
branch6             bsr       Str2Buf             dump out bytes of the file manager's name
                    ldx       <curdte
                    lda       V$USRS,x            use count
                    lbsr      HexByte             print it
                    ldx       <outptr
                    leax      -1,x
                    bra       L01E8

Done                tst       <allflag            list every descriptor too?
                    lbeq      ClnExit             branch if not
                    lbsr      ListAll             else list them
                    lbra      ClnExit

PrintBuf            ldx       <outptr
L01E8               lda       #C$CR               save a CR in memory
                    sta       ,x
                    ldu       <memstrt
                    leax      <lnbuff,u           to the buffer
                    ldy       #80                 80 characters max.
                    lda       #1
                    os9       I$WritLn            dump the buffer out
                    lbcs      Exit
                    rts

* Entry:
*    A = number of bytes to write buffer
*    X = ptr to string to write to buffer
Str2Buf             sta       <numbytes           dump out A bytes at X
                    clrb
                    bra       L0207

L0204               lbsr      Put2Buf
L0207               incb                          increment B
                    cmpb      <numbytes           equal to number of bytes?
                    bcc       NSpaces             branch if so
                    lda       ,x+                 else get byte at X
                    bpl       L0204               branch if hi bit clear
                    anda      #$7F                else clear it
                    lbsr      Put2Buf             dump it out
                    cmpb      <numbytes           compare against num bytes
                    bcc       L0221               branch if equal

* Fill the rest with spaces
NSpaces             lbsr      Space
                    incb
                    cmpb      <numbytes
                    bcs       NSpaces
L0221               rts

HexWord             pshs      b
                    bsr       MakeHex
                    puls      a
HexByte             bsr       MakeHex
Space               lda       #C$SPAC             output a space
                    bra       Put2Buf

MakeHex             tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       L0238
                    tfr       b,a
L0238               anda      #$0F                get the number
                    cmpa      #$0A                >10?
                    bcs       L0240               no, make it a number
                    adda      #$07                if so, make it A-F
L0240               adda      #$30
* Entry: A = char to put in buffer
Put2Buf             pshs      x                   save X
                    ldx       <outptr             get buffer pointer
                    sta       ,x+                 store char and in X
                    stx       <outptr             save new outptr
                    puls      pc,x                and return

* ListAll - list every device descriptor module in the module directory,
* attached or not, with its link count (nonzero while it is in use)
ListAll             ldu       <memstrt            get static pointer
                    lda       #$01                to standard output
                    leax      >MyCR,pcr           separate it from the device table
                    ldy       #$0001
                    os9       I$WritLn
                    lbcs      Exit
                    leax      >AHeader,pcr
                    ldy       #AHeaderL
                    tst       <narrow
                    beq       abranch1
                    leax      >NAHeader,pcr
                    ldy       #NAHeaderL
abranch1            os9       I$WritLn
                    lbcs      Exit
                    leax      >AHeader2,pcr
                    ldy       #AHeader2L
                    tst       <narrow
                    beq       abranch2
                    leax      >NAHeader2,pcr
                    ldy       #NAHeader2L
abranch2            os9       I$WritLn
                    lbcs      Exit
                    leax      >AUndln,pcr
                    ldy       #AUndlnL
                    tst       <narrow
                    beq       abranch3
                    leax      >NAUndln,pcr
                    ldy       #NAUndlnL
abranch3            os9       I$WritLn
                    lbcs      Exit

                    ifgt      Level-1
                    leax      >mdbuf,u            copy the module directory here
                    pshs      u
                    os9       F$GModDr
                    sty       <mdend              end of the local copy
                    stu       <mdsys              where it lives in the system map
                    puls      u
                    leax      >mdbuf,u
                    else
                    ldx       >D.ModDir           start of the module directory
                    ldd       >D.ModDir+2         and its end
                    std       <mdend
                    endc
                    stx       <mdcur
ALoop               ldx       <mdcur              get the current entry
                    cmpx      <mdend              past the end?
                    bhs       AExit               yes, done
                    ifgt      Level-1
                    ldd       MD$MPDAT,x          module's DAT image
                    beq       ANext               skip an unused slot
                    subd      <mdsys              offset into the module directory
                    leay      >mdbuf,u            to the same place in our copy
                    leay      d,y
                    sty       <datptr
                    ldd       MD$MPtr,x           module address within that image
                    std       <modptr
                    ldy       #M$Port+3           just the header first
                    bsr       CopyMod
                    bcs       ANext               unreadable: skip it
                    leax      >descrip,u
                    lda       M$Type,x            module type
                    anda      #TypeMask
                    cmpa      #Devic              a device descriptor?
                    bne       ANext               no, skip it
                    ldd       M$Size,x            now the whole module
                    cmpd      #256                bigger than our buffer?
                    bls       ASize               no
                    ldd       #256                else take what fits
ASize               tfr       d,y
                    bsr       CopyMod
                    bcs       ANext
                    ldx       <mdcur
                    ldb       MD$Link+1,x         link count (low byte of the word)
                    leax      >descrip,u          the descriptor copy
                    else
                    ldy       MD$MPtr,x           module address
                    beq       ANext               skip an unused slot
                    lda       M$Type,y            module type
                    anda      #TypeMask
                    cmpa      #Devic              a device descriptor?
                    bne       ANext               no, skip it
                    ldb       MD$Link,x           link count (one byte at level one)
                    tfr       y,x                 the descriptor itself
                    endc
                    bsr       PrtDesc
ANext               ldx       <mdcur
                    leax      MD$ESize,x          next entry
                    stx       <mdcur
                    bra       ALoop
AExit               rts

                    ifgt      Level-1
* CopyMod - copy Y bytes of the current module into descrip
CopyMod             ldd       <datptr             module's DAT image
                    ldx       <modptr             module address within it
                    pshs      u
                    leau      >descrip,u
                    os9       F$CpyMem
                    puls      u,pc
                    endc

* PrtDesc - print one descriptor line
* Entry: X = descriptor, B = link count
PrtDesc             pshs      b                   save the link count
                    stx       <descptr
                    leay      <lnbuff,u           point to line buffer
                    sty       <outptr
                    ldd       M$Name,x            pointer to the name
                    leax      d,x
                    lda       #5                  assume this size
                    tst       <narrow
                    beq       pbranch1
                    lda       #3
pbranch1            lbsr      Str2Buf             the name
                    ldx       <descptr
                    tst       <narrow
                    bne       pskip1
                    lda       M$Port,x            port address of the device
                    lbsr      HexByte
                    ldy       <outptr
                    leay      -1,y
                    sty       <outptr
pskip1              ldd       M$Port+1,x
                    lbsr      HexWord
                    lbsr      Space
                    ldd       M$PDev,x            device driver name offset
                    leax      d,x
                    lda       #9
                    tst       <narrow
                    beq       pbranch2
                    lda       #7
pbranch2            lbsr      Str2Buf             the driver name
                    ldx       <descptr
                    ldd       M$FMGr,x            file manager name offset
                    leax      d,x
                    lda       #9
                    tst       <narrow
                    beq       pbranch3
                    lda       #7
pbranch3            lbsr      Str2Buf             the file manager name
                    puls      a                   link count
                    lbsr      HexByte
                    ldx       <outptr
                    leax      -1,x
                    lbra      L01E8

Help                lda       #1                  to STDOUT
                    leax      HMsg,pcr
                    ldy       #HLen
                    os9       I$Write
                    clrb
                    os9       F$Exit

HMsg                fcc       /devs: show devices in device table/
                    fdb       C$CR,C$LF
                    fcc       /  -a  also list every device descriptor in memory/
                    fdb       C$CR,C$LF
HLen                equ       *-HMsg

                    emod
eom                 equ       *
                    end
