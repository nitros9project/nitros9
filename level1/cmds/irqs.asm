********************************************************************
* irqs - Show interrupt polling table
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??  Kevin Darling
* Created.
*
*   2      ????/??/??  Gene Heskett
* Modified.
*
*   3      2003/01/07  Boisy G. Pitre
* Streamlined and fixed problems.

                    nam       irqs
                    ttl       Show interrupt polling table

                    ifp1
                    use       defsfile
                    endc

rev                 set       $00
edition             set       3

MaxDEnts            set       32                  max device entries we will display
MaxPEnts            set       32                  max polling entries we will display

                    mod       emod,name,prgrm+objct,reent+rev,start,endmem

                    org       0
usaver              rmb       2
narrow              rmb       1
polcount            rmb       1                   number of polling entries in polling table
devcount            rmb       1                   number of device entries in device table
datptr              rmb       2                   pointer to DAT image in system proc descriptor
notuse              rmb       2
outptr              rmb       2                   points to next available char in buffer
counter             rmb       1
devptr              rmb       2
tblptr              rmb       2
dpvars              rmb       9
rptbuf              rmb       80
ddevtbl             rmb       2                   copy of D.DevTbl in globals
dpoltbl             rmb       2                   copy of D.PolTbl in globals
                    ifgt      Level-1
poltable            rmb       32*POLSIZ
devtable            rmb       32*DEVSIZ
modulep             rmb       256
syspdesc            rmb       P$Size
                    endc
sstack              rmb       200
endmem              equ       .

name                fcs       "irqs"
                    fcb       edition

PollHdr             fcc       "Polling Table at: "
PollHdrL            equ       *-PollHdr
Device              fcc       " Device Table at: "
DeviceL             equ       *-Device
NTopline            fcc       " Device    Drvr   IRQ   Flip"
                    fcb       C$CR
NToplineL           equ       *-NTopline
NLine2              fcc       "Port Mem   Name   Vect  Mask Pr"
                    fcb       C$CR
NLine2L             equ       *-NLine2
NLine3              fcc       "---- ----  -----------  ---- --"
                    fcb       C$CR
NLine3L             equ       *-NLine3
Topline             fcc       " Device    Driver  IRQ   Flip     "
                    fcb       C$CR
ToplineL            equ       *-Topline
Line2               fcc       "Port Mem   Name  Vector  &Mask Pty"
                    fcb       C$CR
Line2L              equ       *-Line2
Line3               fcc       "---- ----  ------------  ----- ---"
crtn                fcb       C$CR
Line3L              equ       *-Line3
Init                fcs       /Init/

start               stu       <usaver             at 0000 in direct page
* First things first: get Polling Table and Device Table counts in the
* Init module
                    lda       #MaxDEnts           get max dev ents
                    sta       <devcount
                    lda       #MaxPEnts           get max poll ents
                    sta       <polcount
                    clra                          module type/lang byte
                    leax      Init,pcr            point to name
                    os9       F$Link              link to it
                    bcs       errexit             branch if error
                    ldd       PollCnt,u           get poll count in A, dev count in B
                    os9       F$UnLink            unlink it
                    ldu       <usaver
                    cmpa      <polcount           is actual size greater or equal than our max?
                    bge       chkdev              branch if so
                    sta       <polcount
chkdev              cmpb      <devcount           is actual size greater or equal than our max?
                    bge       cont                branch if so
                    stb       <devcount
cont                clr       <narrow
                    lda       #$01
                    ldb       #SS.ScSiz
                    os9       I$GetStt
                    bcs       cont2
                    cmpx      #Line3L+1
                    bge       cont2
                    sta       <narrow             we're narrow
cont2               leax      >crtn,pcr
                    ldy       #$0001
                    os9       I$WritLn            write a carriage return
                    bcs       errexit
                    leax      >PollHdr,pc
                    ldy       #PollHdrL
                    os9       I$Write             write polling table header
                    bcs       errexit
                    ifgt      Level-1
                    lda       #$01                process ID #1 - system process
                    leax      syspdesc,u          point to buffer
                    os9       F$GPrDsc            get a copy of it
                    bcs       errexit
                    leax      P$DatImg,x          point to DAT image
                    stx       <datptr             save off pointer for later
                    endc
                    bra       z00C5
okexit              clrb
errexit             os9       F$Exit
z00C5               leay      rptbuf,u
                    sty       <outptr
                    ifgt      Level-1
                    leau      ddevtbl,u
                    ldd       <datptr             get ptr P$datimg
                    ldx       #D.DevTbl
                    ldy       #$0004              include D.Poltbl 4 bytes to copy
                    os9       F$CpyMem            get the two globals
                    bcs       errexit
                    ldu       <usaver             restore u
                    else
                    ldd       >D.DevTbl
                    std       <ddevtbl
                    ldd       >D.PolTbl
                    std       <dpoltbl
                    endc
                    ldd       <dpoltbl
                    lbsr      OutHex              cnvrt 4 dgts of poll tbl addr
                    lbsr      z01B1               output poll tbl address in ASCII
* troubleshooting printout
                    leax      >Device,pcr
                    ldy       #DeviceL
                    lda       #1
                    os9       I$Write
                    leax      rptbuf,u
                    stx       <outptr
                    ldd       <ddevtbl
                    lbsr      OutHex
                    lbsr      z01B1
* to here
                    lda       #1
                    leax      >crtn,pcr           stick another \n on it
                    ldy       #$0001
                    os9       I$WritLn
                    bcs       errexit
                    leax      >Topline,pcr
                    ldy       #ToplineL
                    tst       <narrow
                    beq       branch1
                    leax      >NTopline,pcr
                    ldy       #NToplineL
branch1             os9       I$WritLn
                    bcs       errexit
                    leax      >Line2,pcr
                    ldy       #Line2L
                    tst       <narrow
                    beq       branch2
                    leax      >NLine2,pcr
                    ldy       #NLine2L
branch2             os9       I$WritLn
                    bcs       errexit
                    leax      >Line3,pcr
                    ldy       #Line3L
                    tst       <narrow
                    beq       branch3
                    leax      >NLine3,pcr
                    ldy       #NLine3L
branch3             os9       I$WritLn
                    lbcs      errexit
                    ifgt      Level-1
* Copy polling table
                    lda       <polcount
                    ldb       #POLSIZ
                    mul
                    tfr       d,y
                    ldx       <dpoltbl
                    ldd       <datptr
                    leau      poltable,u
                    os9       F$CpyMem
                    ldu       <usaver
                    lbcs      errexit
* Copy device table
                    lda       <devcount
                    ldb       #DEVSIZ
                    mul
                    tfr       d,y
                    ldx       <ddevtbl
                    ldd       <datptr
                    leau      devtable,u
                    os9       F$CpyMem
                    ldu       <usaver
                    lbcs      errexit
                    endc

* Go through IRQ polling table until we find a non-empty slot or the end
                    ldb       <polcount           get polling count
                    stb       <counter            save off in our counter variable
                    ifgt      Level-1
                    leax      poltable,u          point X to polling table we copied
                    else
                    ldx       <dpoltbl
                    endc
z0165               ldd       Q$STAT,x            get static pointer
                    beq       z016B               branch if empty
                    bsr       ShowIRQ             else process it
z016B               dec       <counter            decrement couunter
                    lbeq      okexit              exit if end
                    leax      POLSIZ,x            else advance X
                    bra       z0165               and get some more

* Here we process the IRQ polling entry at X
ShowIRQ             leay      rptbuf,u
                    sty       <outptr             reset output buffer pointer
                    ldd       Q$POLL,x
                    lbsr      OutHex              convert 2 bytes port addr->ascii
                    ldd       Q$STAT,x
                    lbsr      OutHex              convert 2 bytes memsiz->ascii
                    lbsr      OutSpace            extra space in line
                    bsr       z01CA               now do name
                    ldd       Q$SERV,x            get irq vector
                    lbsr      OutHex              convert it to ascii
                    lbsr      OutSpace            extra space
                    lda       Q$FLIP,x            get flip
                    lbsr      z0247               convert 1 byte
                    tst       <narrow
                    bne       branch4
                    lbsr      OutSpace            space
branch4             lda       Q$MASK,x            get mask
                    lbsr      z0241               convert 1 byte + space
                    tst       <narrow
                    bne       branch5
                    lbsr      OutSpace            extra space
branch5             lda       Q$PRTY,x            get priority byte
                    lbsr      z0247               convert 1 byte
z01B1               pshs      x
                    ldx       <outptr
                    lda       #C$CR               terminate this line
                    sta       ,x
                    leax      rptbuf,u            ptr to outbuff
                    ldy       #80                 max 80 chars
                    lda       #$01                stdout
                    os9       I$WritLn
                    lbcs      errexit
                    puls      x,pc

z01CA               pshs      x
                    ifgt      Level-1
                    leax      poltable,u
                    else
                    ldx       <dpoltbl
                    endc
                    ldb       <devcount
                    pshs      b
* now we make an assumption that data
* areas for the same driver will be
* in the same page of memory, so compare
* only the high bytes of the address
                    ldb       Q$STAT,x            get irq dat addr
                    ifgt      Level-1
                    leax      devtable,u          devtbl buffer
                    else
                    ldx       <ddevtbl
                    endc
z01D6               cmpb      V$STAT,x
                    beq       Match               if match, found device
                    leax      DEVSIZ,x            else inc to next tbl entry
                    dec       ,s                  and decrement coounter
                    bne       z01D6               continue if more
                    leas      $01,s               get rid of stack data
                    ldy       <outptr
                    leay      8,y                 this leaves name visible
                    sty       <outptr             until new one found
                    puls      x,pc

z01E9               ldy       <outptr
                    ldb       #08
                    lda       #C$SPAC             a space
z01EA               sta       ,y+
                    decb
                    bne       z01EA
                    sty       <outptr
                    rts

Match               puls      b                   fix stack
                    ldx       V$DRIV,x            get driver module pointer
                    beq       z01E9               branch if none
                    ifgt      Level-1
                    pshs      u
                    leau      modulep,u
                    ldd       <datptr
* hopefully the driver name is in the 1st 256 bytes
                    ldy       #256
                    os9       F$CpyMem
                    puls      u
                    lbcs      errexit
                    leax      modulep,u
                    endc
                    ldd       M$Name,x
                    leax      d,x
                    lda       #8
                    tst       <narrow
                    beq       storeit
                    lda       #7
storeit             sta       <counter
                    clrb
                    bra       z0220
z021D               bsr       z025B
z0220               incb
                    cmpb      <counter
                    bcc       z0232
                    lda       ,x+
                    bpl       z021D
                    anda      #$7F
                    bsr       z025B
                    cmpb      <counter
                    bcc       z023A
z0232               bsr       OutSpace
                    incb
                    cmpb      <counter
                    bcs       z0232
z023A               puls      x,pc

* HexCvt
* Entry:
*   D = number to convert to hex
*   X = pointer to buffer where hex string is stored
* Exit
OutHex              pshs      b                   convert to ascii
                    bsr       z0247               make 2 digits
                    puls      a
z0241               bsr       z0247               make 2 more
OutSpace            lda       #C$SPAC
                    bra       z025B
z0247               tfr       a,b
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       z0251
                    tfr       b,a
z0251               anda      #$0F
                    cmpa      #$0A
                    bcs       z0259
                    adda      #$07
z0259               adda      #$30
z025B               pshs      x
                    ldx       <outptr             get outbuf ptr
                    sta       ,x+
                    stx       <outptr
                    puls      pc,x

                    emod
emod                equ       *
                    end
