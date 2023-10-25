********************************************************************
* IOMan - OS-9 Level One V2 I/O Manager module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  11      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00
*
*  12      2002/05/11  Boisy G. Pitre
* I/O Queue sort bug and I$Attach static storage premature deallocation
* bug fixed.

                    nam       IOMan
                    ttl       OS-9 Level One V2 I/O Manager module

                    ifp1
                    use       defsfile
;         use   scfdefs
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
* edition 11 = Stock OS-9 Level One Vr. 2.00 IOMan
* edition 12 = IO Queue sort bug fixed, IAttach bug fixed
edition             equ       12

                    mod       eom,name,tylg,atrv,IOManEnt,size

size                equ       .

name                fcs       /IOMan/
                    fcb       edition

* IOMan is called from OS9p2
IOManEnt            equ       *
* allocate device and polling tables
                    ldx       <D.Init             get pointer to init module
                    lda       PollCnt,x           grab number of polling entries
                    ldb       #POLSIZ             and size per entry
                    mul                           D = size of all entries in bytes
                    pshs      b,a                 save off
                    lda       DevCnt,x            get device table count in init mod
                    ldb       #DEVSIZ             get size per dev table entry
                    mul                           D = size of all entires in bytes
                    pshs      b,a                 save off
                    addd      2,s                 add devsize to polsiz
                    addd      #$0018              add in ???
                    addd      #$00FF              bring up to next page
                    clrb
                    os9       F$SRqMem            ask for the memory
                    bcs       Crash               crash if we can't get it
* clear allocated mem
                    leax      ,u                  point to dev table
L0033               clr       ,x+
                    subd      #$0001
                    bhi       L0033
                    stu       <D.PolTbl           U = pointer to polling table
                    ldd       ,s++                get dev table size
                    leax      d,u                 point X past polling table to dev table
                    stx       <D.DevTbl           save off X to system vars
                    addd      ,s++                grab poll table size
                    leax      d,u
                    stx       <D.CLTB
                    ldx       <D.PthDBT
                    os9       F$All64
                    bcs       Crash
                    stx       <D.PthDBT
                    os9       F$Ret64
                    leax      >DPoll,pcr          get address of IRQ poll routine
                    stx       <D.Poll             save in statics
* install I/O system calls
                    leay      <IOCalls,pcr        point to I/O calls
                    os9       F$SSvc              install them
                    rts                           return to OS9p2

Crash               jmp       [>$FFFE]

IOCalls             fcb       $7F
                    fdb       UsrIO-*-2

                    fcb       F$Load
                    fdb       FLoad-*-2

                    fcb       F$PErr
                    fdb       FPErr-*-2

                    fcb       F$IOQu+$80
                    fdb       FIOQu-*-2

                    fcb       $FF
                    fdb       SysIO-*-2

                    fcb       F$IRQ+$80
                    fdb       FIRQ-*-2

                    fcb       F$IODel+$80
                    fdb       FIODel-*-2

                    fcb       $80

FIODel              ldx       R$X,u
                    ldu       <D.Init
                    ldb       DevCnt,u            get device count
                    ldu       <D.DevTbl
L0083               ldy       V$DESC,u
                    beq       L0094
                    cmpx      V$DESC,u
                    beq       L009B
                    cmpx      V$DRIV,u
                    beq       L009B
                    cmpx      V$FMGR,u
                    beq       L009B
L0094               leau      DEVSIZ,u
                    decb
                    bne       L0083
                    clrb
                    rts
L009B               comb
                    ldb       #E$ModBsy
                    rts

UsrIODis            fdb       IAttach-UsrIODis
                    fdb       IDetach-UsrIODis
                    fdb       IDup-UsrIODis
                    fdb       IUsrCall-UsrIODis
                    fdb       IUsrCall-UsrIODis
                    fdb       IMakDir-UsrIODis
                    fdb       IChgDir-UsrIODis
                    fdb       IDelete-UsrIODis
                    fdb       UISeek-UsrIODis
                    fdb       UIRead-UsrIODis
                    fdb       UIWrite-UsrIODis
                    fdb       UIRead-UsrIODis
                    fdb       UIWrite-UsrIODis
                    fdb       UIGetStt-UsrIODis
                    fdb       UISeek-UsrIODis
                    fdb       UIClose-UsrIODis
                    fdb       IDeletX-UsrIODis

SysIODis            fdb       IAttach-SysIODis
                    fdb       IDetach-SysIODis
                    fdb       SIDup-SysIODis
                    fdb       ISysCall-SysIODis
                    fdb       ISysCall-SysIODis
                    fdb       IMakDir-SysIODis
                    fdb       IChgDir-SysIODis
                    fdb       IDelete-SysIODis
                    fdb       SISeek-SysIODis
                    fdb       SIRead-SysIODis
                    fdb       SIWrite-SysIODis
                    fdb       SIRead-SysIODis
                    fdb       SIWrite-SysIODis
                    fdb       SIGetStt-SysIODis
                    fdb       SISeek-SysIODis
                    fdb       SIClose-SysIODis
                    fdb       IDeletX-SysIODis


* Entry to User and System I/O dispatch table
* B = I/O system call code
UsrIO               leax      <UsrIODis,pcr
                    bra       IODsptch
SysIO               leax      <SysIODis,pcr
IODsptch            cmpb      #I$DeletX           compare with last I/O call
                    bhi       L00FA               branch if greater
                    pshs      b
                    lslb                          multiply by 2
                    ldd       b,x                 offset
                    leax      d,x                 get address of routine
                    puls      b
                    jmp       ,x                  jump to it!
L00FA               comb                          we get here if illegal I/O code
                    ldb       #E$UnkSvc
                    rts

IAttach             ldb       #$11
L0100               clr       ,-s
                    decb
                    bpl       L0100
                    stu       <$10,s              caller regs
                    lda       R$A,u
                    sta       $09,s               device mode
                    ldx       R$X,u
                    lda       #Devic+0
                    os9       F$Link              link to device desc.
                    bcs       L0139
                    stu       $04,s               address of mod hdr
                    ldy       <$10,s              get caller regs
                    stx       R$X,y               save updated ptr
                    ldd       M$Port+1,u          get port addr
                    std       $0C,s               save on stack
                    ldd       M$PDev,u            get driver name
                    leax      d,u                 point X to driver name
                    lda       #Drivr+0
                    os9       F$Link              link to driver
                    bcs       L0139
                    stu       ,s                  save driver addr on stack
                    ldu       $04,s               get addr of dev desc.
                    ldd       M$FMgr,u            get file mgr name
                    leax      d,u                 point X to fmgr name
                    lda       #FlMgr+0
                    os9       F$Link              link to fmgr
L0139               bcc       L0149
* error on attach, so detach
L013B               stb       <$11,s              save fmgr addr on stack
                    leau      ,s                  point U to S
                    os9       I$Detach
                    leas      <$11,s              clean up stack
                    comb
                    puls      pc,b                return to caller
L0149               stu       $06,s               save fmgr addr
                    ldx       <D.Init
                    ldb       DevCnt,x
                    lda       DevCnt,x
                    ldu       D.DevTbl
L0153               ldx       V$DESC,u            get desc addr
                    beq       L0188
                    cmpx      $04,s               same?
                    bne       L016E               branch if not
                    ldx       V$STAT,u            get stat
                    bne       L016C               branch if zero
                    pshs      a
                    lda       V$USRS,u            get user count
                    beq       L0168
                    os9       F$IOQu
L0168               puls      a
                    bra       L0153
L016C               stu       $0E,s               save dev entry on stack
L016E               ldx       V$DESC,u            get dev desc ptr
                    ldy       M$Port+1,x
                    cmpy      $0C,s               compare to port addr on stack
                    bne       L0188
                    ldx       V$DRIV,u
                    cmpx      ,s                  compare to driver addr on stack
                    bne       L0188
                    ldx       V$STAT,u            get static
                    stx       $02,s               save static on stack
                    tst       V$USRS,u            test user count
                    beq       L0188               branch if zero
                    sta       $0A,s               store on stack
L0188               leau      DEVSIZ,u            go to next entry
                    decb                          decrement count
                    bne       L0153               go back to loop if not zero
                    ldu       $0E,s               get dev entry off stack
                    lbne      L01E6
                    ldu       D.DevTbl
L0195               ldx       V$DESC,u            get dev desc ptr
                    beq       L01A6               branch if zero
                    leau      DEVSIZ,u
                    deca
                    bne       L0195               continue loop
                    ldb       #E$DevOvf           device table overflow
                    bra       L013B
L01A2               ldb       #E$BMode            bad mode
                    bra       L013B
L01A6               ldx       $02,s               get static storage off stack
                    lbne      L01DD
                    stu       $0E,s               save off dev entry on stack
                    ldx       ,s                  get driver addr off stack
                    ldd       M$Mem,x             get memory requirement
                    addd      #$00FF              round up to next page
                    clrb
                    os9       F$SRqMem
                    lbcs      L013B
                    stu       $02,s               save off on stack
L01BF               clr       ,u+                 clear static mem
                    subd      #$0001
                    bhi       L01BF
                    ldd       $0C,s               get port addr off stack
                    ldu       $02,s               get static storage ptr
                    clr       V.PAGE,u
                    std       V.PORT,u            save addr
                    ldy       $04,s               get dev desc addr
                    ldx       ,s                  get driver addr
                    ldd       M$Exec,x            get driver exec
                    jsr       d,x                 call Init routine
                    lbcs      L013B
                    ldu       $0E,s               get dev entry
L01DD               ldb       #$08                copy 8 bytes from stack to dev entry
L01DF               lda       b,s
                    sta       b,u
                    decb
                    bpl       L01DF
L01E6               ldx       V$DESC,u            get dev desc
                    ldb       M$Revs,x
                    lda       $09,s               get device mode off stack
                    anda      M$Mode,x            AND mode with desc mode
                    ldx       V$DRIV,u            get driver ptr
                    anda      M$Mode,x            AND mode with driver mode
                    cmpa      $09,s               compare with passed mode
                    lbne      L01A2               branch if error
                    inc       V$USRS,u            else inc user count of dev entry
                    bne       L01FE               branch if not overflow from 255->0
                    dec       V$USRS,u            else dec
L01FE               ldx       <$10,s              get caller regs
                    stu       R$U,x
                    leas      <$12,s              restore stack
                    clrb
                    rts

IDetach             ldu       R$U,u
                    ldx       V$DESC,u
                    ifeq      edition-11
* Note:  the following lines constitute a bug that can, in certain
*        circumstances, wipe out a device's static storage out from
*        underneath it.
                    ldb       V$USRS,u            get user count
                    bne       L0218               branch if not zero
                    pshs      u,b
                    ldu       V$STAT,u
                    pshs      u
                    bra       L0254
                    else
                    tst       V$USRS,u
                    beq       IDetach2
                    endc
L0218               lda       #255
                    cmpa      V$USRS,u            255 users?
                    lbeq      L0283               branch if so
                    dec       V$USRS,u            else dec user count
                    lbne      L0271               branch if dec not 0
IDetach2
                    ldx       <D.Init
                    ldb       DevCnt,x
                    pshs      u,b
                    ldx       V$STAT,u
                    clr       V$STAT,u
                    clr       V$STAT+1,u
                    ldy       <D.DevTbl
L0235               cmpx      V$STAT,y
                    beq       L0267
                    leay      DEVSIZ,y
                    decb
                    bne       L0235
                    ldy       <D.Proc
                    ldb       P$ID,y
                    stb       V$USRS,u
                    ldy       V$DESC,u
                    ldu       V$DRIV,u
                    exg       x,u                 X pts to driver, U pts to static
                    ldd       M$Exec,x
                    leax      d,x
                    pshs      u
                    jsr       $0F,x               call term routine
L0254               puls      u
                    ldx       1,s                 get U from stack (dev entry to detach)
                    ldx       V$DRIV,x
                    ldd       M$Mem,x             get memory requirements
                    addd      #$00FF              round up to next page
                    clrb
                    os9       F$SRtMem            return mem
                    ldx       1,s                 get U from stack (dev entry to detach)
                    ldx       V$DESC,x            get dev desc ptr
L0267               puls      u,b                 get U,B
                    ldx       V$DESC,u
                    clr       V$DESC,u
                    clr       V$DESC+1,u
                    clr       V$USRS,u
L0271               ldy       V$DRIV,u
                    ldu       V$FMGR,u
                    os9       F$UnLink            unlink file manager
                    leau      ,y
                    os9       F$UnLink            unlink driver
                    leau      ,x
                    os9       F$UnLink            unlink descriptor
L0283               lbsr      L04D9
                    clrb
                    rts

* user state I$Dup
IDup                bsr       FindPath            look for a free path
                    bcs       IDupRTS             branch if error
                    pshs      x,a                 else save of
                    lda       R$A,u               get path to dup
                    lda       a,x                 point to path to dup
                    bsr       L02A1
                    bcs       L029D
                    puls      x,b
                    stb       R$A,u               save off new path to caller's A
                    sta       b,x
                    rts
L029D               puls      pc,x,a

* system state I$Dup
SIDup               lda       R$A,u
L02A1               lbsr      FindPDsc            find path descriptor
                    bcs       IDupRTS             exit if error
                    inc       PD.CNT,y            else increment path count
IDupRTS             rts


* Find next free path position in current proc
* Exit:	X = Ptr to proc's path table
*	A = Free path number (valid if carry clear)
*
FindPath            ldx       <D.Proc             get ptr to current proc desc
                    leax      <P$PATH,x           point X to proc's path table
                    clra                          start from 0
L02AF               tst       a,x                 this path free?
                    beq       L02BC               branch if so...
                    inca                          else try next path...
                    cmpa      #NumPaths           are we at the end?
                    bcs       L02AF               branch if not
                    comb                          else path table is full
                    ldb       #E$PthFul
                    rts
L02BC               andcc     #^Carry
                    rts

IUsrCall            bsr       FindPath
                    bcs       L02D1
                    pshs      u,x,a
                    bsr       ISysCall
                    puls      u,x,a
                    bcs       L02D1
                    ldb       R$A,u
                    stb       a,x
                    sta       R$A,u
L02D1               rts

ISysCall            pshs      b
                    ldb       R$A,u
                    bsr       L0349
                    bcs       L02E6
                    puls      b
                    lbsr      CallFMgr
                    bcs       L02F5
                    lda       PD.PD,y
                    sta       R$A,u
                    rts
L02E6               puls      pc,a

* make directory
IMakDir             pshs      b
                    ldb       #DIR.+WRITE.
L02EC               bsr       L0349
                    bcs       L02E6
                    puls      b
                    lbsr      CallFMgr
L02F5               pshs      b,cc
                    ldu       PD.DEV,y
                    os9       I$Detach
                    lda       PD.PD,y
                    ldx       <D.PthDBT
                    os9       F$Ret64
                    puls      pc,b,cc

* change directory
IChgDir             pshs      b
                    ldb       R$A,u
                    orb       #DIR.
                    bsr       L0349
                    bcs       L02E6
                    puls      b
                    lbsr      CallFMgr
                    bcs       L02F5
                    ldu       <D.Proc
                    ldb       PD.MOD,y
                    bitb      #PWRIT.+PREAD.+UPDAT.
                    beq       L0329
                    ldx       PD.DEV,y
                    stx       <P$DIO,u
                    inc       V$USRS,x
                    bne       L0329
                    dec       V$USRS,x
L0329               bitb      #PEXEC.+EXEC.
                    beq       L0338
                    ldx       PD.DEV,y
                    stx       <P$DIO+6,u
                    inc       V$USRS,x
                    bne       L0338
                    dec       V$USRS,x
L0338               clrb
                    bra       L02F5

IDelete             pshs      b
                    ldb       #$02
                    bra       L02EC

IDeletX             ldb       #$87
                    pshs      b
                    ldb       $01,u
                    bra       L02EC

* create path descriptor and initialize
* Entry:
*   B  = path mode
L0349               pshs      u
                    ldx       <D.PthDBT
                    os9       F$All64
                    bcs       L03A8
                    inc       PD.CNT,y
                    stb       PD.MOD,y
                    ldx       R$X,u
L0358               lda       ,x+
                    cmpa      #$20
                    beq       L0358
                    leax      -1,x
                    stx       R$X,u
                    ldb       PD.MOD,y
                    cmpa      #PDELIM
                    beq       L037E
                    ldx       <D.Proc
                    bitb      #PEXEC.+EXEC.
                    beq       L0373
                    ldx       <P$DIO+6,x
                    bra       L0376
L0373               ldx       <P$DIO,x
L0376               beq       L03AA
                    ldx       V$DESC,x
                    ldd       M$Name,x
                    leax      d,x
L037E               pshs      y
                    os9       F$PrsNam
                    puls      y
                    bcs       L03AA
                    lda       PD.MOD,y
                    os9       I$Attach
                    stu       PD.DEV,y
                    bcs       L03AC
                    ldx       V$DESC,u
                    leax      <M$Opt,x
                    ldb       ,x+
                    leau      <PD.DTP,y
                    cmpb      #$20
                    bls       L03A4
                    ldb       #$1F
L03A0               lda       ,x+
                    sta       ,u+
L03A4               decb
                    bpl       L03A0
                    clrb
L03A8               puls      pc,u
L03AA               ldb       #E$BPNam
L03AC               pshs      b
                    lda       ,y
                    ldx       <D.PthDBT
                    os9       F$Ret64
                    puls      b
                    coma
                    bra       L03A8
L03BA               lda       $01,u
                    cmpa      #$10
                    bcc       L03CB
                    ldx       <D.Proc
                    leax      <$26,x
                    andcc     #^Carry
                    lda       a,x
                    bne       L03CE
L03CB               comb
                    ldb       #E$BPNum
L03CE               rts

UISeek              bsr       L03BA
                    bcc       GetPDsc
                    rts

SISeek              lda       R$A,u
GetPDsc             bsr       FindPDsc
                    lbcc      CallFMgr
                    rts

UIRead              bsr       L03BA
                    bcc       L03E4
                    rts

SIRead              lda       R$A,u
L03E4               pshs      b
                    ldb       #$05
L03E8               bsr       FindPDsc
                    bcs       L040B
                    bitb      $01,y
                    beq       L0409
                    ldd       R$Y,u
                    beq       L03F8
                    addd      R$X,u
                    bcs       L03FD
L03F8               puls      b
                    lbra      CallFMgr
L03FD               ldb       #$F4
                    lda       ,s
                    bita      #$02
                    beq       L040B
                    ldb       #$F5
                    bra       L040B
L0409               ldb       #E$BMode
L040B               com       ,s+
                    rts

UIWrite             bsr       L03BA
                    bcc       L0415
                    rts

SIWrite             lda       R$A,u
L0415               pshs      b
                    ldb       #$02
                    bra       L03E8


* Find path descriptor of path passed in A
* Entry:
*	A = path to find
* Exit:
*	Y  = addr of path desc (if no error)
FindPDsc            pshs      x
                    ldx       <D.PthDBT
                    os9       F$Find64
                    puls      x
                    lbcs      L03CB
L0428               rts

UIGetStt            lbsr      L03BA
                    bcc       L0431
                    rts

SIGetStt            lda       R$A,u
L0431               pshs      b,a
                    lda       R$B,u
                    sta       1,s                 place in B on stack
                    puls      a                   get A
                    bsr       GetPDsc
                    puls      a                   A holds func code
                    pshs      b,cc
                    ldb       <PD.DTP,y
                    cmpb      #DT.NFM
                    beq       L044D
                    tsta                          test func code
                    beq       GSOpt
                    cmpa      #SS.DevNm
                    beq       GSDevNm
L044D               puls      pc,b,cc
GSOpt               leax      <PD.DTP,y
L0452               ldy       R$X,u
                    ldb       #32
L0457               lda       ,x+                 copy 32 bytes from X to Y
                    sta       ,y+
                    decb
                    bne       L0457
                    leas      2,s                 fix stack
                    clrb
                    rts
* get device name
GSDevNm             ldx       PD.DEV,y
                    ldx       V$DESC,x
                    ldd       M$Name,x
                    leax      d,x
                    bra       L0452

UIClose             lbsr      L03BA
                    bcs       L0428
                    pshs      b
                    ldb       R$A,u
                    clr       b,x
                    puls      b
                    bra       L047D

SIClose             lda       R$A,u
L047D               bsr       FindPDsc
                    bcs       L0428
                    dec       PD.CNT,y
                    tst       PD.CPR,y
                    bne       L0489
                    bsr       CallFMgr
L0489               tst       PD.CNT,y
                    bne       L0428
                    lbra      L02F5

L0490               os9       F$IOQu
                    comb
                    ldb       <P$Signal,x
                    bne       L04A4
L0499               ldx       <D.Proc
                    ldb       P$ID,x
                    clra
                    lda       PD.CPR,y
                    bne       L0490
                    stb       PD.CPR,y
L04A4               rts

* B = entry point into FMgr
* Y = path desc
CallFMgr            pshs      u,y,x,b
                    bsr       L0499
                    bcs       L04C1
                    stu       PD.RGS,y
                    lda       <PD.DTP,y
                    ldx       PD.DEV,y
                    ldx       V$FMGR,x
                    ldd       M$Exec,x
                    leax      d,x
                    ldb       ,s
                    subb      #$83                subtract offset from B
                    lda       #$03                size of one entry
                    mul                           compute
                    jsr       d,x                 branch into file manager
L04C1               pshs      b,cc
                    bsr       L04D9
                    ldy       $05,s               get path desc off stack
                    lda       <PD.DTP,y
                    ldx       <D.Proc
                    lda       P$ID,x
                    cmpa      PD.CPR,y
                    bne       L04D5
                    clr       PD.CPR,y
L04D5               puls      b,cc
                    puls      pc,u,y,x,a

L04D9               pshs      y,x
                    ldy       <D.Proc
                    lda       <P$IOQN,y
                    beq       L04F3
                    clr       <P$IOQN,y
                    ldb       #S$Wake
                    os9       F$Send
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    clr       <P$IOQP,y
L04F3               clrb
                    puls      pc,y,x

* IRQ install routine
FIRQ                ldx       R$X,u
                    ldb       ,x                  B = flip byte
                    ldx       1,x                 X = mask/priority
                    clra
                    pshs      cc
                    pshs      x,b
                    ldx       <D.Init
                    ldb       PollCnt,x
                    ldx       <D.PolTbl
                    ldy       R$X,u
                    beq       RmvIRQEn
                    tst       1,s                 mask byte
                    beq       L0572
                    decb                          dec poll table count
                    lda       #POLSIZ
                    mul
                    leax      d,x                 point to last entry in table
                    lda       Q$MASK,x
                    bne       L0572
                    orcc      #FIRQMask+IRQMask
L051C               ldb       2,s                 get priority byte
                    cmpb      -1,x                compare with prev entry's prior
                    bcs       L052F
                    ldb       #POLSIZ             else copy prev entry
L0524               lda       ,-x
                    sta       POLSIZ,x
                    decb
                    bne       L0524
                    cmpx      <D.PolTbl
                    bhi       L051C
L052F               ldd       R$D,u               get dev stat reg
                    std       Q$POLL,x            save it
                    ldd       ,s++                get flip/mask
                    sta       Q$FLIP,x            save flip
                    stb       Q$MASK,x            save mask
                    ldb       ,s+                 get priority
                    stb       Q$PRTY,x            save priority
                    ldd       R$Y,u               get IRQ svc addr
                    std       Q$SERV,x            save
                    ldd       R$U,u               get IRQ svc mem ptr
                    std       Q$STAT,x            save
                    puls      pc,cc
* remove IRQ poll entry
RmvIRQEn            leas      4,s                 clean stack
                    ldy       R$U,u
L054C               cmpy      Q$STAT,x
                    beq       L0558
                    leax      POLSIZ,x
                    decb
                    bne       L054C
                    clrb
                    rts
L0558               pshs      b,cc
                    orcc      #FIRQMask+IRQMask
                    bra       L0565
L055E               ldb       POLSIZ,x
                    stb       ,x+
                    deca
                    bne       L055E
L0565               lda       #POLSIZ
                    dec       1,s                 dec count
                    bne       L055E
L056B               clr       ,x+
                    deca
                    bne       L056B
                    puls      pc,a,cc
L0572               leas      4,s                 clean stack
L0574               comb
                    ldb       #E$Poll
                    rts

* IRQ polling routine
DPoll               ldy       <D.PolTbl
                    ldx       <D.Init
                    ldb       PollCnt,x
                    bra       L0586
L0581               leay      POLSIZ,y
                    decb
                    beq       L0574
L0586               lda       [Q$POLL,y]
                    eora      Q$FLIP,y
                    bita      Q$MASK,y
                    beq       L0581
                    ldu       Q$STAT,y
                    pshs      y,b
                    jsr       [<Q$SERV,y]
                    puls      y,b
                    bcs       L0581
                    rts

* load a module
FLoad               pshs      u
                    ldx       R$X,u
                    bsr       L05BC
                    bcs       L05BA
                    inc       $02,u               increment link count
                    ldy       ,u                  get mod header addr
                    ldu       ,s                  get caller regs
                    stx       R$X,u
                    sty       R$U,u
                    lda       M$Type,y
                    ldb       M$Revs,y
                    std       R$D,u
                    ldd       M$Exec,y
                    leax      d,y
                    stx       R$Y,u
L05BA               puls      pc,u

L05BC               lda       #EXEC.
                    os9       I$Open
                    bcs       L0632
                    leas      -$0A,s              make room on stack
                    ldu       #$0000
                    pshs      u,y,x
                    sta       6,s                 save path
L05CC               ldd       4,s                 get U (caller regs) from stack
                    bne       L05D2
                    stu       4,s
L05D2               lda       6,s                 get path
                    leax      7,s                 point to place on stack
                    ldy       #M$IDSize           read M$IDSize bytes
                    os9       I$Read
                    bcs       L061E
                    ldd       ,x
                    cmpd      #M$ID12
                    bne       L061C
                    ldd       $09,s               get module size
                    os9       F$SRqMem            allocate mem
                    bcs       L061E
                    ldb       #M$IDSize
L05F0               lda       ,x+                 copy over first M$IDSize bytes
                    sta       ,u+
                    decb
                    bne       L05F0
                    lda       $06,s               get path
                    leax      ,u                  point X at updated U
                    ldu       $09,s               get module size
                    leay      -M$IDSize,u         subtract count
                    os9       I$Read
                    leax      -M$IDSize,x
                    bcs       L060B
                    os9       F$VModul            validate module
                    bcc       L05CC
L060B               pshs      u,b
                    leau      ,x                  point U at memory allocated
                    ldd       M$Size,x
                    os9       F$SRtMem            return mem
                    puls      u,b
                    cmpb      #E$KwnMod
                    beq       L05CC
                    bra       L061E
L061C               ldb       #E$BMID
L061E               puls      u,y,x
                    lda       ,s                  get path
                    stb       ,s                  save error code
                    os9       I$Close             close path
                    ldb       ,s
                    leas      $0A,s               clear up stack
                    cmpu      #$0000
                    bne       L0632
                    coma
L0632               rts


ErrHead             fcc       /ERROR #/
ErrNum              equ       *-ErrHead
                    fcb       $2F,$3A,$30,C$CR
ErrLen              equ       *-ErrHead

FPErr               ldx       <D.Proc
                    lda       <P$PATH+2,x         get stderr path
                    beq       L0674
                    leas      -ErrLen,s           make room on stack
* copy error message to stack
                    leax      <ErrHead,pcr
                    leay      ,s
L064C               lda       ,x+
                    sta       ,y+
                    cmpa      #C$CR
                    bne       L064C
                    ldb       R$B,u               get error #
L0656               inc       ErrNum+0,s
                    subb      #$64
                    bcc       L0656
L065C               dec       ErrNum+1,s
                    addb      #$0A
                    bcc       L065C
                    addb      #$30
                    stb       ErrNum+2,s
                    ldx       <D.Proc
                    leax      ,s                  point to error message
                    ldu       <D.Proc
                    lda       <P$PATH+2,u
                    os9       I$WritLn            write message
                    leas      ErrLen,s            fix up stack
L0674               rts

FIOQu               ldy       <D.Proc
L0678               lda       <P$IOQN,y
                    beq       L06A0
                    cmpa      R$A,u
                    bne       L0699
                    clr       <P$IOQN,y
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    lbcs      L070F
                    clr       <P$IOQP,y
                    ldb       #S$Wake
                    os9       F$Send
                    ldu       <D.Proc
                    bra       L06AB
L0699               ldx       <D.PrcDBT
                    os9       F$Find64
                    bcc       L0678
L06A0               lda       R$A,u
                    ldu       <D.Proc
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    bcs       L070F
L06AB               leax      ,y                  X = proc desc
                    lda       <P$IOQN,y
                    beq       L06D1
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    bcs       L070F
                    ldb       P$Age,u

                    ifeq      edition-11

* Note:  the following line is a bug
                    cmpd      P$Age,y

                    else

                    cmpb      P$Age,y

                    endc

                    bls       L06AB
                    ldb       ,u
                    stb       <P$IOQN,x
                    ldb       P$ID,x
                    stb       <P$IOQP,u
                    clr       <P$IOQP,y
                    exg       y,u
                    bra       L06AB
L06D1               lda       P$ID,u
                    sta       <P$IOQN,y
                    lda       P$ID,y
                    sta       <P$IOQP,u
                    ldx       #$0000
                    os9       F$Sleep
                    ldu       <D.Proc
                    lda       <P$IOQP,u
                    beq       L070C
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    bcs       L070C
                    lda       <P$IOQN,y
                    beq       L070C
                    lda       <P$IOQN,u
                    sta       <P$IOQN,y
                    beq       L070C
                    clr       <P$IOQN,u
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    bcs       L070C
                    lda       <P$IOQP,u
                    sta       <P$IOQP,y
L070C               clr       <P$IOQP,u
L070F               rts

                    emod
eom                 equ       *
                    end
