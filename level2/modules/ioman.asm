********************************************************************
* IOMan - NitrOS-9 Level 2 I/O Manager module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??  ???
* NitrOS-9 2.00 distribution.
*
*  13      2002/04/30  Boisy G. Pitre
* Fixed a long-standing bug in IOMan where the I$Detach routine would
* deallocate the V$STAT area.  This is because the V$USRS offset on the
* stack, where the temporary device table entry was being built, contained
* zero.  I$Detach wouldn't bother to do a lookup to see if it should
* release the memory if this value was zero, so we now force I$Detach to
* do the lookup no matter the V$USRS value.
*
*  13r2    2002/12/31  Boisy G. Pitre
* Made more source changes, found discrepancy in value of POLSIZ in
* certain areas, fixed. Also added 6809 conditional code for future
* integration into OS-9 Level Two.
*
*  13r3    2003/03/04  Boisy G. Pitre
* Conditionalized out Level 3 code.
*
*  13r4    2003/04/09  Boisy G. Pitre
* Fixed bug where wrong address was being put in V$STAT when driver's
* INIT routine was called.
*
*  13r5    2004/07/12  Boisy G. Pitre
* Fixed bug where device descriptor wasn't being unlinked when V$USRS > 0
* due to the value in X not being loaded.

                    nam       IOMan
                    ttl       NitrOS-9 Level 2 I/O Manager module

* Disassembled 02/04/29 23:10:07 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $05
edition             set       13

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

name                fcs       /IOMan/
                    fcb       edition

start               ldx       <D.Init             get pointer to init module
                    lda       DevCnt,x            get number of entries in device table
                    ldb       #DEVSIZ             get size of each entry
                    mul                           calculate size needed for device table
                    pshs      d                   preserve it
                    lda       PollCnt,x           get number of entries in polling table
                    ldb       #POLSIZ             get size of each entry
                    mul                           calculate size needed for polling table
                    pshs      d                   preserve it
                    ifne      H6309
                    asld
                    else
                    lslb                          multiply by 2
                    rola
                    endc
                    addd      $02,s               add to size of device table
                    os9       F$SRqMem            allocate memory
                    bcs       Crash               branch if error
* clear allocated mem
                    leax      ,u                  point to memory
                    ifne      H6309
                    leay      <TheZero,pcr
                    tfr       d,w
                    tfm       y,x+
                    else
ClrLoop             clr       ,x+                 clear a byte
                    subd      #$0001              done?
                    bne       ClrLoop             no, keep going
                    endc
                    stu       <D.DevTbl           save pointer to device table
                    ifne      H6309
                    puls      x,d
                    addr      u,x
                    stx       <D.PolTbl
                    addr      d,x
                    stx       <D.CLTb
                    else
                    ldd       ,s++                get pointer to device table
                    std       <D.CLTb             save to globals temporarily
                    ldd       ,s++                get size of device table
                    leax      d,u                 point x to the end of device table
                    stx       <D.PolTbl           save to globals
                    ldd       <D.CLTb             get VIRQ table size
                    leax      d,x                 add it to end of device table
                    stx       <D.CLTb             and save VIRQ table address
                    endc
                    ldx       <D.PthDBT           get address of path desc table
                    os9       F$All64             split it into 64 byte chunks
                    bcs       Crash               branch if error
                    stx       <D.PthDBT           save pointer back
                    os9       F$Ret64
                    leax      >IRQPoll,pcr        point to polling routine
                    stx       <D.Poll             save the vector address
                    leay      <IOCalls,pcr        point to service vector table
                    os9       F$SSvc              set up calls
                    rts                           and return to system

******************************
*
* Fatal error Crash the system
*
Crash
                    ifgt      Level-1
                    jmp       <D.Crash
                    else
                    jmp       [>$FFFE]
                    endc

******************************
*
* System service routine vector table
*
IOCalls             fcb       $7F
                    fdb       UsrIO-*-2
                    fcb       F$Load
                    fdb       FLoad-*-2
                    ifgt      Level-1
                    fcb       I$Detach
                    fdb       IDetach0-*-2
                    endc
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
                    ifgt      Level-1
                    fcb       F$NMLink
                    fdb       FNMLink-*-2
                    fcb       F$NMLoad
                    fdb       FNMLoad-*-2
                    endc
                    fcb       $80

******************************
*
* Check device status service call?
*
* Entry: U = Callers register stack pointer
*
FIODel              ldx       R$X,u               get address of module
                    ldu       <D.Init             get pointer to init module
                    ldb       DevCnt,u            get device count
                    ldu       <D.DevTbl           get pointer to device table
L0086               ldy       V$DESC,u            descriptor exists?
                    beq       L0097               no, move to next device
                    cmpx      V$DESC,u            device match?
                    beq       L009E               no, move to next device
                    cmpx      V$DRIV,u            driver match?
                    beq       L009E               yes, return module busy
                    cmpx      V$FMGR,u            fmgr match?
                    beq       L009E               yes, return module busy
L0097               leau      DEVSIZ,u            move to next dev entry
                    decb                          done them all?
                    bne       L0086               no, keep going
                    clrb                          clear carry
L009D               rts                           and return
L009E               comb                          else set carry
                    ldb       #E$ModBsy           submit error
                    rts                           and return

                    ifne      H6309
TheZero             fcb       $00
                    endc

UsrIODis            fdb       IAttach-UsrIODis
                    fdb       IDetach-UsrIODis
                    fdb       UIDup-UsrIODis
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
IODsptch            cmpb      #I$DeletX-$70       compare with last I/O call
                    bhi       L00F9               branch if greater
                    ifne      H6309
                    ldw       b,x
                    lsrb
                    jmp       w,x
                    else
                    pshs      d
                    ldd       b,x
                    leax      d,x
                    puls      d
                    lsrb
                    jmp       ,x
                    endc

******************************
*
* Unknown service code error handler
*
L00F9               comb
                    ldb       #E$UnkSvc
                    rts

VDRIV               equ       $00                 \
VSTAT               equ       $02                 |
VDESC               equ       $04                 |--- Temporary device table entry
VFMGR               equ       $06                 |
VUSRS               equ       $08                 /
DRVENT              equ       $09
FMENT               equ       $0B
AMODE               equ       $0D
HWPG                equ       $0E
HWPORT              equ       $0F
CURDTE              equ       $11
DATBYT1             equ       $13
DATBYT2             equ       $15
ODPROC              equ       $17
CALLREGS            equ       $19
RETERR              equ       $1A
EOSTACK             equ       $1B

* Entry: U=module header pointer
IAttach             equ       *
                    ifne      H6309
                    ldw       #EOSTACK            get stack count
                    leas      <-EOSTACK,s         make stack
                    leax      <TheZero,pcr        point at zero
                    tfr       s,y                 move S to Y
                    tfm       x,y+                and transfer 0 to stack
                    else
                    ldb       #EOSTACK-1          get stack count - 1
IALoop              clr       ,-s                 clear each byte
                    decb                          decrement
                    bpl       IALoop              and branch until = 0
                    endc
                    stu       <CALLREGS,s         save caller regs
                    lda       R$A,u               access mode
                    sta       AMODE,s             save on stack
                    ifgt      Level-1
                    ldx       <D.Proc             get curr proc desc
                    stx       <ODPROC,s           save on stack
                    leay      <P$DATImg,x         point to DAT img of curr proc
                    ldx       <D.SysPrc           get sys proc
                    stx       <D.Proc             make sys proc current proc
                    endc
                    ldx       R$X,u               get caller's X
                    lda       #Devic+0            link to device desc
                    ifgt      Level-1
                    os9       F$SLink             link to it
                    else
                    os9       F$Link              link to it
                    endc
                    bcs       L0155               branch if error
                    stu       VDESC,s             save dev desc ptr
                    ldy       <CALLREGS,s         get caller regs
                    stx       R$X,y               save updated X
                    lda       M$Port,u            get hw page
                    sta       HWPG,s              save onto stack
                    ldd       M$Port+1,u          get hw addr
                    std       HWPORT,s            save onto stack
                    ifne      H6309
                    ldx       M$PDev,u            get driver name ptr
                    addr      u,x                 add U to X
                    else
                    ldd       M$PDev,u            get driver name ptr
                    leax      d,u                 add D to U and put in X
                    endc
                    lda       #Drivr+0            driver
                    os9       F$Link              link to driver
                    bcs       L0155               branch if error
                    stu       VDRIV,s             else save addr save on stack
                    sty       DRVENT,s            save entry point on stack
                    ldu       VDESC,s             get desc ptr
                    ifne      H6309
                    ldx       M$FMgr,u            get fm name
                    addr      u,x                 add U to X
                    else
                    ldd       M$FMgr,u            get fm name
                    leax      d,u                 add D to U and put in X
                    endc
                    lda       #FlMgr+0            link to fm
                    os9       F$Link              link to it!
L0155
                    ifgt      Level-1
                    ldx       <ODPROC,s           get caller's proc desc
                    stx       <D.Proc             restore orig proc desc
                    endc
                    bcc       L016A               branch if not error
* Error on attach, so detach
L015C               stb       <RETERR,s           save off error code
                    leau      VDRIV,s             point U to device table entry
                    os9       I$Detach            detach
                    leas      <RETERR,s           adjust stack
                    comb                          set carry
                    puls      pc,b                exit
L016A               stu       VFMGR,s             save off fm module ptr
                    sty       FMENT,s             save off fm entry point
                    ldx       <D.Init             get D.Init
                    ldb       DevCnt,x            get device entry count
                    ifne      H6309
                    tfr       b,f
                    else
                    tfr       b,a
                    endc
                    ldu       <D.DevTbl           get device table pointer
L0177               ldx       V$DESC,u            get dev desc ptr
                    beq       L01B4               branch if empty
                    cmpx      VDESC,s             same as dev desc being attached?
                    bne       L0196               branch if not
                    ldx       V$STAT,u            get driver static
                    bne       L0191               branch if zero
                    ifne      H6309
                    lde       V$USRS,u            get user count
                    beq       L0177               branch if zero
                    else
                    pshs      a                   save off A
                    lda       V$USRS,u            get user count
                    beq       L0188               branch if zero
                    endc
                    pshs      u,b
                    lbsr      FIOQu2              call F$IOQu directly
                    puls      u,b
                    ifeq      H6309
L0188               puls      a                   pull A from stack
                    endc
                    bra       L0177
L0191               stu       <CURDTE,s           save current dev table ptr
                    ldx       V$DESC,u            get dev desc ptr
L0196               ldy       M$Port+1,x          get hw addr
                    cmpy      HWPORT,s            same as dev entry on stack?
                    bne       L01B4               branch if not
                    ifne      H6309
                    lde       M$Port,x            get hw port
                    cmpe      HWPG,s              same as dev entry on stack?
                    else
                    ldy       M$Port,x            get hw port
                    cmpy      HWPG,s              same as dev entry on stack?
                    endc
                    bne       L01B4               branch if not
                    ldx       V$DRIV,u            get driver ptr
                    cmpx      VDRIV,s             same as dev entry on stack?
                    bne       L01B4               branch if not
* A match between device table entries has occurred
                    ldx       V$STAT,u            get driver static
                    stx       VSTAT,s             save off in our statics
                    tst       V$USRS,u            any users for this device
                    beq       L01B4               branch if not
                    ifeq      H6309
                    sta       HWPG,s
                    endc
L01B4               leau      DEVSIZ,u            advance to the next device entry
                    decb
                    bne       L0177
                    ldu       <CURDTE,s           get curr dev entry ptr
                    lbne      L0264               branch if not zero
                    ldu       <D.DevTbl
                    ifne      H6309
                    tfr       f,a
                    endc
L01C4               ldx       V$DESC,u            get desc ptr
                    beq       L01DD               branch if zero
                    leau      DEVSIZ,u            move to next dev table entry
                    deca
                    bne       L01C4
                    ldb       #E$DevOvf           dev table overflow
                    bra       L015C

L01D1
                    ifne      H6309
                    lsrd                          /2
                    lsrd                          /4
                    lsrd                          /8
                    lsrd                          /16
                    lsrd                          /32
                    else
                    lsra
                    rorb                          /2
                    lsra
                    rorb                          /4
                    lsra
                    rorb                          /8
                    lsra
                    rorb                          /16
                    lsra
                    rorb                          /32
                    endc
                    clra
                    rts

L01DD               ldx       VSTAT,s             get static storage off stack
                    bne       L0259               branch if already alloced
                    stu       <CURDTE,s           else store off ptr to dev table entry
                    ldx       VDRIV,s             get ptr to driver
                    ldd       M$Mem,x             get driver storage req
                    os9       F$SRqMem            allocate memory
                    lbcs      L015C               branch if error
                    stu       VSTAT,s             save newly alloc'ed driver static storage ptr
                    ifne      H6309
                    leay      VSTAT+1,s           point to zero byte
                    tfr       d,w                 tfr count to w counter
                    tfm       y,u+                clear driver static storage
                    else
Loop2               clr       ,u+                 clear newly alloc'ed mem
                    subd      #$0001
                    bhi       Loop2
                    endc
* Code here appears to be for Level III?
                    ifgt      Level-2
                    ldd       HWPG,s              get hwpage and upper addr
                    bsr       L01D1
                    std       <DATBYT2,s          save off
                    ldu       #$0000
                    tfr       u,y
                    stu       <DATBYT1,s
                    ldx       <D.SysDAT           get system mem map ptr
L0209               ldd       ,x++
                    cmpd      <DATBYT2,s
                    beq       L023B
                    cmpd      #DAT.Free
                    bne       L021D
                    sty       <DATBYT1,s
                    leau      -$02,x
L021D               leay      >$2000,y
                    bne       L0209
                    ldb       #E$NoRAM
                    ifne      H6309
                    cmpr      0,u
                    else
                    cmpu      #$0000
                    endc
                    lbeq      L015C
                    ldd       <DATBYT2,s
                    std       ,u
                    ldx       <D.SysPrc
                    ifne      H6309
                    oim       #ImgChg,P$State,x
                    else
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    endc
                    os9       F$ID
                    bra       L023F
L023B               sty       <DATBYT1,s
                    endc
L023F               ldd       HWPORT,s
                    ifgt      Level-2
                    anda      #$1F
                    addd      <DATBYT1,s
                    endc
                    ldu       VSTAT,s             load U with static storage of drvr
                    clr       V.PAGE,u            clear page byte
                    std       V.PORT,u            save port address
                    ldy       VDESC,s             load Y with desc ptr
                    jsr       [<DRVENT,s]         call driver init routine
                    lbcs      L015C               branch if error
                    ldu       <CURDTE,s
L0259
                    ifne      H6309
                    ldw       #DEVSIZ
                    tfr       s,x
                    tfm       x+,u+
                    leau      -DEVSIZ,u
                    else
                    ldb       #DEVSIZ-1           size of device table - 1
LilLoop             lda       b,s                 get from src
                    sta       b,u                 save in dest
                    decb
                    bpl       LilLoop
                    endc
* Here, U points to Device Table
L0264               ldx       V$DESC,u            get desc ptr in X
                    ldb       M$Revs,x            get revs
                    lda       AMODE,s             get access mode byte passed in A
                    anda      M$Mode,x            and with MODE byte in desc.
                    ldx       V$DRIV,u            X points to driver module
                    anda      M$Mode,x            AND with mode byte in driver
                    cmpa      AMODE,s             same as passed mode?
                    beq       L0279               if so, ok
                    ldb       #E$BMode            else bad mode
                    lbra      L015C               and return
L0279               inc       V$USRS,u            else inc user count
                    bne       L027F               if not zero, continue
                    dec       V$USRS,u            else bump back to 255
L027F               ldx       <CALLREGS,s
                    stu       R$U,x
                    leas      <EOSTACK,s
                    clrb
                    rts

IDetach             ldu       R$U,u
                    ldx       V$DESC,u            this was incorrectly commented out in 13r4!!
*** BUG FIX
* The following two lines fix a long-standing bug in IOMan where
* the I$Detach routine would deallocate the V$STAT area.  This is
* because the V$USRS offset on the stack, where the temporary
* device table entry was being built, contained 0.  I$Detach wouldn't
* bother to do a lookup to see if it should release the memory if
* this value was zero, so here force I$Detach to do the lookup no
* matter the V$USRS value
* BGP 04/30/2002
                    tst       V$USRS,u
                    beq       IDetach2
*** BUG FIX
L0297               lda       #$FF
                    cmpa      V$USRS,u
                    lbeq      L0351
                    dec       V$USRS,u
                    lbne      L0335
IDetach2
                    ldx       <D.Init
                    ldb       DevCnt,x
                    pshs      u,b
                    ldx       V$STAT,u
                    clr       V$STAT,u
                    clr       V$STAT+1,u
                    ldy       <D.DevTbl
L02B4               cmpx      V$STAT,y
                    beq       L032B
                    leay      DEVSIZ,y
                    decb
                    bne       L02B4
                    ldy       <D.Proc
                    ldb       P$ID,y
                    stb       V$USRS,u
                    ldy       V$DESC,u
                    ifgt      LEVEL-1
                    ldu       V$DRIVEX,u
                    exg       x,u
                    pshs      u
                    jsr       $0F,x
                    puls      u
                    else
                    ldu       V$DRIV,u
                    exg       x,u                 X pts to driver, U pts to static
                    ldd       M$Exec,x
                    leax      d,x
                    pshs      u
                    jsr       $0F,x
                    puls      u
                    endc
                    ldx       $01,s               get ptr to dev table
                    ldx       V$DRIV,x            load X with driver addr
                    ldd       M$Mem,x             get static storage size
                    addd      #$00FF              round up one page
                    clrb                          clear lo byte
                    os9       F$SRtMem            return mem

* Code here appears to be for Level III?
                    ifgt      Level-2
                    ldx       $01,s               get old U on stack
                    ldx       V$DESC,x
                    ldd       M$Port,x
                    beq       L032B
                    lbsr      L01D1
                    cmpb      #$3F
                    beq       L032B
                    tfr       d,y
                    ifne      H6309
                    ldf       ,s
                    endc
                    ldu       <D.DevTbl
L02F4               cmpu      $01,s
                    beq       L0309
                    ldx       V$DESC,u
                    beq       L0309
                    ldd       M$Port,x
                    beq       L0309
                    lbsr      L01D1
                    ifne      H6309
                    cmpr      y,d
                    else
                    pshs      y
                    cmpd      ,s++
                    endc
                    beq       L032B
L0309               leau      DEVSIZ,u
                    ifne      H6309
                    decf
                    else
                    dec       ,s
                    endc
                    bne       L02F4
                    ldx       <D.SysPrc
                    ldu       <D.SysDAT
                    ifne      H6309
                    ldf       #$08
                    else
                    ldb       #$08
                    pshs      b
                    endc
L0316               ldd       ,u++
                    ifne      H6309
                    cmpr      y,d
                    else
                    pshs      y
                    cmpd      ,s++
                    endc
                    beq       L0323
                    ifne      H6309
                    decf
                    else
                    dec       ,s
                    endc
                    bne       L0316
                    ifeq      H6309
                    leas      1,s
                    endc
                    bra       L032B
L0323
                    ifeq      H6309
                    leas      1,s
                    endc
                    ldd       #DAT.Free
                    std       -$02,u
                    ifne      H6309
                    oim       #ImgChg,P$State,x
                    else
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    endc
                    endc

L032B               puls      u,b
                    ldx       V$DESC,u            get descriptor in X
                    clr       V$DESC,u            clear out descriptor
                    clr       V$DESC+1,u
                    clr       V$USRS,u            and users
L0335
                    ifgt      Level-1
                    ifne      H6309
                    ldw       <D.Proc
                    else
                    ldd       <D.Proc             get curr process
                    pshs      d                   save it
                    endc
                    ldd       <D.SysPrc           make system the current process
                    std       <D.Proc
                    endc
                    ldy       V$DRIV,u            get file manager module address
                    ldu       V$FMGR,u            get driver module address
                    os9       F$UnLink            unlink file manager
                    leau      ,y                  point to driver
                    os9       F$UnLink            unlink driver
                    leau      ,x                  point to descriptor
                    os9       F$UnLink            unlink it
                    ifgt      Level-1
                    ifne      H6309
                    stw       <D.Proc
                    else
                    puls      d                   restore current process
                    std       <D.Proc
                    endc
                    endc
L0351               lbsr      L0595
                    clrb
                    rts

* User State I$Dup
UIDup               bsr       LocFrPth            look for a free path
                    bcs       L0376               branch if error
                    pshs      x,a                 else save off
                    lda       R$A,u               get path to dup
                    lda       a,x                 point to path to dup
                    bsr       L036F
                    bcs       L036B
                    puls      x,b
                    stb       R$A,u               save off new path to caller's A
                    sta       b,x
                    rts
L036B               puls      pc,x,a

* System State I$Dup
SIDup               lda       R$A,u
L036F               lbsr      GetPDesc            find path descriptor
                    bcs       L0376               exit if error
                    inc       PD.CNT,y            else increment path descriptor
L0376               rts

* Find next free path position in current proc
* Exit: X = Ptr to proc's path table
*       A = Free path number (valid if carry clear)
*
LocFrPth            ldx       <D.Proc             get ptr to current proc desc
                    leax      <P$Path,x           point X to proc's path table
                    clra                          start from 0
L037D               tst       a,x                 this path free?
                    beq       L038A               branch if so...
                    inca                          ...else try next path
                    cmpa      #Numpaths           are we at the end?
                    bcs       L037D               branch if not
                    comb                          else path table is full
                    ldb       #E$PthFul
                    rts
L038A               andcc     #^Carry
                    rts

IUsrCall            bsr       LocFrPth
                    bcs       L039F
                    pshs      u,x,a
                    bsr       ISysCall
                    puls      u,x,a
                    bcs       L039F
                    ldb       R$A,u
                    stb       a,x
                    sta       R$A,u
L039F               rts

ISysCall            pshs      b
                    ldb       R$A,u
                    bsr       AllcPDsc
                    bcs       L03B4
                    puls      b
                    lbsr      CallFMgr
                    bcs       L03C3
                    lda       PD.PD,y
                    sta       R$A,u
                    rts
L03B4               puls      pc,a

* Make Directory
IMakDir             pshs      b
                    ldb       #DIR.+WRITE.
L03BA               bsr       AllcPDsc
                    bcs       L03B4
                    puls      b
                    lbsr      CallFMgr
L03C3               pshs      b,cc
                    ldu       PD.DEV,y
                    os9       I$Detach
                    lda       PD.PD,y
                    ldx       <D.PthDBT
                    os9       F$Ret64
                    puls      pc,b,cc

* Change Directory
IChgDir             pshs      b
                    ldb       R$A,u
                    orb       #DIR.
                    bsr       AllcPDsc
                    bcs       L03B4
                    puls      b
                    lbsr      CallFMgr
                    bcs       L03C3
                    ldu       <D.Proc
                    ifne      H6309
                    tim       #PWRIT.+PREAD.+UPDAT.,PD.MOD,y
                    else
                    ldb       PD.MOD,y
                    bitb      #PWRIT.+PREAD.+UPDAT.
                    endc
                    beq       IChgExec
                    ldx       PD.DEV,y
                    stx       <P$DIO,u
                    inc       V$USRS,x
                    bne       IChgExec
                    dec       V$USRS,x
IChgExec
                    ifne      H6309
                    tim       #PEXEC.+EXEC.,PD.MOD,y
                    else
                    bitb      #PEXEC.+EXEC.
                    endc
                    beq       L0406
                    ldx       PD.DEV,y
                    stx       <P$DIO+6,u
                    inc       V$USRS,x
                    bne       L0406
                    dec       V$USRS,x
L0406               clrb
                    bra       L03C3

IDelete             pshs      b
                    ldb       #WRITE.
                    bra       L03BA

IDeletX             ldb       #7                  Delete offset in file manager
                    pshs      b
                    ldb       R$A,u
                    bra       L03BA

* Allocate path descriptor
* Entry:
*    B = mode
AllcPDsc
                    ldx       <D.Proc             get pointer to curr proc in X
                    pshs      u,x                 save U/X
                    ldx       <D.PthDBT           get ptr to path desc base table
                    os9       F$All64             allocate 64 byte page
                    bcs       L0484               branch if error
                    inc       PD.CNT,y            set path count
                    stb       PD.MOD,y            save mode byte
                    ifgt      Level-1
                    ldx       <D.Proc             get curr proc desc
                    ldb       P$Task,x            get task #
                    endc
                    ldx       R$X,u               X points to pathlist
L042C
                    ifgt      Level-1
                    os9       F$LDABX             get byte at X
                    leax      1,x                 move to next
                    else
                    lda       ,x+
                    endc
                    cmpa      #C$SPAC             space?
                    beq       L042C               continue if so
                    leax      -1,x                else back up
                    stx       R$X,u               save updated pointer
                    cmpa      #PDELIM             leading slash?
                    beq       L0459               yep...
                    ldx       <D.Proc             else get curr proc
                    ifne      H6309
                    tim       #EXEC.,PD.MOD,y
                    else
                    ldb       PD.MOD,y            get mode byte
                    bitb      #EXEC.              exec. dir relative?
                    endc
                    beq       L0449               nope...
                    ldx       <P$DIO+6,x          else get dev entry for exec path
                    bra       L044C               and branch
L0449               ldx       <P$DIO,x            get dev entry for data path
L044C               beq       L0489               branch if empty
                    ifgt      Level-1
                    ldd       <D.SysPrc           get system proc ptr
                    std       <D.Proc             get curr proc
                    endc
                    ldx       V$DESC,x            get descriptor pointer
                    ldd       M$Name,x            get name offset
                    ifne      H6309
                    addr      d,x
                    else
                    leax      d,x                 point X to name in descriptor
                    endc
L0459               pshs      y                   save off path desc ptr in Y
                    os9       F$PrsNam            parse it
                    puls      y                   restore path desc ptr
                    bcs       L0489               branch if error
                    lda       PD.MOD,y            get mode byte
                    os9       I$Attach            attach to device
                    stu       PD.DEV,y            save dev tbl entry
                    bcs       L048B               branch if error
                    ldx       V$DESC,u            else get descriptor pointer
* copy options from dev desc to path desc
                    leax      <M$Opt,x            point to opts in desc
                    ifne      H6309
                    ldf       ,x+
                    leau      <PD.OPT,y
                    cmpf      #PD.OPT
                    bcs       L047E
                    ldf       #$20
L047E               clre
                    tfm       x+,u+
                    else
                    ldb       ,x+                 get options count
                    leau      <PD.OPT,y
                    cmpb      #PD.OPT
                    bls       L03E5
                    ldb       #PD.OPT-1
KeepLoop            lda       ,x+
                    sta       ,u+
L03E5               decb
                    bpl       KeepLoop
                    endc
                    clrb
L0484               puls      u,x
                    ifgt      Level-1
                    stx       <D.Proc
                    endc
                    rts

L0489               ldb       #E$BPNam
L048B               pshs      b
                    lda       ,y
                    ldx       <D.PthDBT
                    os9       F$Ret64
                    puls      b
                    coma
                    bra       L0484

UISeek              bsr       S2UPath             get user path #
                    bcc       GtPDClFM            get PD, call FM
                    rts

SISeek              lda       R$A,u
GtPDClFM            bsr       GetPDesc
                    ifne      H6309
                    bcc       CallFMgr
                    else
                    lbcc      CallFMgr
                    endc
                    rts

L04A5               ldb       #E$Read
                    ifne      H6309
                    tim       #WRITE.,,s
                    else
                    lda       ,s
                    bita      #WRITE.
                    endc
                    beq       L04B2
                    ldb       #E$Write
                    bra       L04B2

L04B0               ldb       #E$BMode
L04B2               com       ,s+
                    rts

UIRead              bsr       S2UPath             get user path #
                    bcc       L04E3
                    rts

UIWrite             bsr       S2UPath
                    bcc       L04C1
                    rts

SIWrite             lda       R$A,u
L04C1               pshs      b
                    ldb       #WRITE.
                    bra       L04E7

* get path descriptor
* Passed:    A = path number
* Returned:  Y = address of path desc for path num
GetPDesc            ldx       <D.PthDBT
                    os9       F$Find64
                    bcs       L04DD
                    rts

* System to User Path routine
*
* Returns:
*   A = user path #
*   X = path table in path desc. of current proc.
S2UPath             lda       R$A,u
                    cmpa      #Numpaths
                    bcc       L04DD               illegal path number
                    ldx       <D.Proc
                    adda      #P$PATH
                    lda       a,x
                    bne       L04E0
L04DD               comb
                    ldb       #E$BPNum
L04E0               rts

SIRead              lda       R$A,u               get user path
L04E3               pshs      b
                    ldb       #EXEC.+READ.
L04E7               bsr       GetPDesc            get path descriptor from path in A
                    bcs       L04B2               branch if error
                    bitb      PD.MOD,y            test bits against mode in path desc
                    beq       L04B0               branch if no corresponding bits
                    ldd       R$Y,u               else get count from user
                    beq       L051C               branch if zero count
                    addd      R$X,u               else update buffer pointer with size
                    bcs       L04A5               branch if carry set
                    ifgt      Level-1
                    ifne      H6309
                    decd
                    else
                    subd      #$0001              subtract 1 from count
                    endc
                    lsra                          / 2
                    lsra                          / 4
                    lsra                          / 8
                    lsra                          / 16
                    lsra                          / 32
                    ldb       R$X,u               get address of buffer to hold read data
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    ldx       <D.Proc
                    leax      <P$DATImg,x
                    abx
                    lsrb
                    ifne      H6309
                    subr      b,a
                    tfr       a,e
                    else
                    pshs      b
                    suba      ,s
                    sta       ,s
                    endc
L0510               ldd       ,x++
                    cmpd      #DAT.Free
                    ifne      H6309
                    beq       L04A5
                    dece
                    else
                    bne       L051X
                    puls      a
                    bra       L04A5
L051X               dec       ,s
                    endc
                    bpl       L0510
                    ifeq      H6309
                    puls      a
                    endc
                    endc
L051C               puls      b

CallFMgr            equ       *
                    subb      #$03
                    pshs      u,y,x
                    ldx       <D.Proc
L0524
                    ifne      H6309
                    lde       $05,y
                    else
                    tst       PD.CPR,y
                    endc
                    bne       L054B
                    lda       P$ID,x
                    sta       PD.CPR,y
                    stu       PD.RGS,y
                    ldx       PD.DEV,y
                    ifgt      Level-1
                    ldx       V$FMGREX,x          get file manager address
                    else
                    ldx       V$FMGR,x
                    ldd       M$Exec,x
                    leax      d,x
                    endc
                    lda       #$03                length of lbra instruction
                    mul
                    jsr       b,x                 enter jump table at point computed from B
L0538               pshs      b,cc                preserve return status (C,B) from call
                    bsr       L0595
                    ldy       $04,s               get Y off stack
                    ldx       <D.Proc
                    lda       P$ID,x
                    cmpa      PD.CPR,y
                    bne       L0549               clean up and return
                    clr       PD.CPR,y            path descriptor of currrent process
L0549               puls      pc,u,y,x,b,cc       return.. with return status in C, B.
L054B               pshs      u,y,x,b
                    lbsr      FIOQu2
                    puls      u,y,x,b
                    coma
                    lda       <P$Signal,x
                    beq       L0524
                    tfr       a,b
                    bra       L0538               go back

UIGetStt            lbsr      S2UPath             get usr path #
                    ldx       <D.Proc
                    bcc       L0568
                    rts

SIGetStt            lda       R$A,u
                    ifgt      Level-1
                    ldx       <D.SysPrc
                    endc
L0568               pshs      x,b,a
                    lda       R$B,u               get func code
                    sta       $01,s               place on stack in B
                    puls      a                   get path off stack
                    lbsr      GtPDClFM
                    puls      x,a                 get func code in A, sys proc in X
                    pshs      u,y,b,cc
                    tsta                          SS.Opt?
                    beq       SSOpt
                    cmpa      #SS.DevNm           Get device name?
                    beq       SSDevNm
                    puls      pc,u,y,b,cc

SSOpt               equ       *
                    ifgt      Level-1
                    lda       <D.SysTsk
                    ldb       P$Task,x
                    endc
                    leax      <PD.OPT,y
SSCopy              ldy       #PD.OPT
                    ldu       R$X,u
                    ifgt      Level-1
                    os9       F$Move
                    else
Looper              lda       ,x+
                    sta       ,u+
                    decb
                    bne       Looper
                    endc
                    leas      $2,s
                    clrb
                    puls      pc,u,y

L0595               pshs      y
                    ldy       <D.Proc             get current process
                    lda       <P$IOQN,y           get ID of next process in I/O queue
                    beq       L05AC               branch if none
                    clr       <P$IOQN,y           else clear it
                    ldb       #S$Wake             get wake signal
                    os9       F$Send              wake up process ID in A with signal in B
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    clr       P$IOQP,y
L05AC               clrb
                    puls      pc,y

SSDevNm
                    ifgt      Level-1
                    lda       <D.SysTsk
                    ldb       P$Task,x
                    endc
                    ifeq      H6309
                    pshs      d
                    endc
                    ldx       PD.DEV,y
                    ldx       V$DESC,x
                    ifne      H6309
                    ldw       M$Name,x
                    addr      w,x
                    else
                    ldd       M$Name,x
                    leax      d,x
                    puls      d
                    endc
                    bra       SSCopy

UIClose             lbsr      S2UPath             get user path #
                    bcs       L05CE
                    ifne      H6309
                    lde       R$A,u
                    adde      #$30
                    clr       e,x                 zero path entry
                    else
                    pshs      b
                    ldb       R$A,u
                    addb      #P$PATH
                    clr       b,x
                    puls      b
                    endc
                    bra       L05D1
L05CE               rts

SIClose             lda       R$A,u
L05D1               lbsr      GetPDesc
                    bcs       L05CE
                    dec       PD.CNT,y
                    tst       PD.CPR,y
                    bne       L05DF
                    lbsr      CallFMgr
L05DF               tst       PD.CNT,y
                    bne       L05CE
                    lbra      L03C3

FIRQ                ldx       R$X,u               get ptr to IRQ packet
                    ldb       ,x                  B = flip byte
                    ldx       $01,x               X = mask/priority
                    clra
                    pshs      cc
                    pshs      x,b
                    ldx       <D.Init
                    ldb       PollCnt,x
                    ldx       <D.PolTbl
                    ldy       R$X,u
                    beq       L0634
                    tst       $01,s               test mask byte
                    beq       L0662
                    decb                          dec poll table count
                    lda       #POLSIZ
                    mul
                    ifne      H6309
                    addr      d,x
                    else
                    leax      d,x                 point to last entry in table
                    endc
                    lda       Q$MASK,x
                    bne       L0662
                    orcc      #IntMasks
L060D               ldb       $02,s               get priority byte
                    cmpb      -(POLSIZ-Q$PRTY),x  compare with prev entry's prior
                    bcs       L0620
                    ldb       #POLSIZ
L0615               lda       ,-x
                    sta       POLSIZ,x
                    decb
                    bne       L0615
                    cmpx      <D.PolTbl
                    bhi       L060D
L0620               ldd       R$D,u               get dev stat reg
                    std       Q$POLL,x            save it
                    ldd       ,s++                get flip/mask
                    std       Q$FLIP,x            save it
                    ldb       ,s+                 get priority
                    stb       Q$PRTY,x
                    ifne      H6309
                    ldq       R$Y,u
                    stq       Q$SERV,x
                    else
                    ldd       R$Y,u               get IRQ svc addr
                    std       Q$SERV,x            save
                    ldd       R$U,u               get IRQ svc mem ptr
                    std       Q$STAT,x            save
                    endc
                    puls      pc,cc
* Remove the ISR
L0634               leas      $04,s               clean stack
                    ldy       R$U,u
L0639               cmpy      Q$STAT,x
                    beq       L0645
                    leax      POLSIZ,x
                    decb
                    bne       L0639
                    clrb
                    rts
                    ifne      H6309
L0645               orcc      #IntMasks
                    decb
                    beq       L0654
                    lda       #POLSIZ
                    mul
                    tfr       d,w
                    leay      POLSIZ,x
                    tfm       y+,x+
L0654               ldw       #POLSIZ
                    clr       ,-s
                    tfm       s,x+
                    leas      $01,s
                    andcc     #^IntMasks
                    rts
                    else
L0645               pshs      b,cc
                    orcc      #IntMasks
                    bra       L0565

* Move prev poll entry up one
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
                    endc

L0662               leas      $04,s
L0664               comb
                    ldb       #E$Poll
                    rts

***************************
*
* Device polling routine
*
* Entry: None
*

IRQPoll             ldy       <D.PolTbl           get pointer to polling table
                    ldx       <D.Init             get pointer to init module
                    ldb       PollCnt,x           get number of entries in table
L066F               lda       [Q$POLL,y]          get device's status register
                    eora      Q$FLIP,y            flip it
                    bita      Q$MASK,y            origin of IRQ?
                    bne       L067E               yes, branch
L0677               leay      POLSIZ,y            else move to next entry
                    decb                          done?
                    bne       L066F               no, get next one
                    bra       L0664               else branch
L067E               ldu       Q$STAT,y            get device static storage
                    pshs      y,b                 preserve device # & poll address
                    jsr       [<Q$SERV,y]         execute service routine
                    puls      y,b                 restore device # & poll address
                    bcs       L0677               go to next device if error
                    rts                           return

                    ifgt      Level-1
FNMLoad             pshs      u                   save caller's regs ptr
                    ldx       R$X,u
                    lbsr      LoadMod             allocate proc desc
                    bcs       L06E2
                    ldy       ,s                  put caller's regs ptr in Y
                    stx       R$X,y
                    ldy       ,u
                    ldx       $04,u
                    ldd       #$0006
                    os9       F$LDDDXY
                    leay      ,u
                    puls      u
                    bra       L06BF

FNMLink             ldx       <D.Proc
                    leay      <P$DATImg,x
                    pshs      u
                    ldx       R$X,u
                    lda       R$A,u
                    os9       F$FModul
                    bcs       L06E2
                    leay      ,u
                    puls      u
                    stx       R$X,u
L06BF               std       R$A,u
                    ldx       MD$Link,y           get link count
                    beq       L06C9
                    bitb      #ReEnt              reentrant?
                    beq       L06DF               branch if so
L06C9               leax      1,x                 increment module link count
                    beq       L06CF               branch if zero
                    stx       MD$Link,y           else save new link count
L06CF               ldx       MD$MPtr,y           get module pointer in X
                    ldy       MD$MPDAT,y          get module DAT image ptr
                    ldd       #$000B
                    os9       F$LDDDXY
                    bcs       L06DE
                    std       R$Y,u
L06DE               rts
L06DF               comb
                    ldb       #E$ModBsy
L06E2               puls      pc,u
                    endc

FLoad
                    ifgt      Level-1
                    pshs      u                   place caller's reg ptr on stack
                    ldx       R$X,u               get pathname to load
                    bsr       LoadMod             allocate a process descriptor
                    bcs       L070F               exit if error
                    puls      y                   get caller's reg ptr in Y
L06EE               pshs      y                   preserve y
                    stx       R$X,y               save updated pathlist
                    ldy       ,u                  get DAT image pointer
                    ldx       $04,u               get offset within DAT image
                    ldd       #$0006              get offset to the offset
                    os9       F$LDDDXY            get language & type
                    ldx       ,s                  get caller's reg ptr in X
                    std       R$D,x               update language/type codes
                    leax      ,u
                    os9       F$ELink
                    bcs       L070F
                    ldx       ,s                  get caller's reg ptr in X
                    sty       R$Y,x
                    stu       R$U,x
L070F               puls      pc,u
                    else
                    pshs      u
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
                    endc

                    ifgt      Level-1
IDetach0            pshs      u                   save off regs ptr
                    ldx       R$X,u               get ptr to device name
                    bsr       LoadMod
                    bcs       L0729
                    puls      y
                    ldd       <D.Proc
                    pshs      y,b,a
                    ldd       R$U,y
                    std       <D.Proc
                    bsr       L06EE
                    puls      x
                    stx       <D.Proc
L0729               puls      pc,u
                    endc

* Load module from file
* Entry: X = pathlist to file containing module(s)
* A fake process descriptor is created, then the file is
* opened and validated into memory.

LoadMod
                    ifgt      Level-1
                    os9       F$AllPrc            allocate proc desc
                    bcc       L0731
                    rts
L0731               leay      ,u                  point Y at new alloced mem
                    ldu       #$0000
                    pshs      u,y,x,b,a
                    leas      <-$11,s             make a stack
                    clr       $07,s
                    stu       ,s                  save $0000
                    stu       $02,s               save $0000
                    ldu       <D.Proc             get proc desc ptr
                    stu       $04,s               save onto stack
                    clr       $06,s
                    lda       P$Prior,u           get priority
                    sta       P$Prior,y           save
                    sta       P$Age,y             and save as age
                    lda       #EXEC.              from exec dir
                    os9       I$Open              open it
                    lbcs      L07E1               branch if error
                    sta       $06,s               else save path
                    stx       <$13,s              put updated pathlist in X on stack
                    ldx       <$15,s              get proc desc in Y on stack
                    os9       F$AllTsk            allocate task
                    bcs       L07E1
                    stx       <D.Proc             save off X into curr proc
L0765               ldx       <$15,s              get proc desc in Y on stack
                    lda       P$Prior,x           get priority
                    adda      #$08                add eight
                    bcc       L0770               branch if not overflow
                    lda       #$FF                else load highest
L0770               sta       P$Prior,x           save back
                    sta       P$Age,x             and age
                    ldd       #$0009
                    ldx       $02,s
                    lbsr      L0866
                    bcs       L07E1
                    ldu       <$15,s              get proc desc in Y on stack
                    lda       P$Task,u
                    ldb       <D.SysTsk
                    leau      $08,s
                    pshs      x
                    ldx       $04,s
                    os9       F$Move
                    puls      x
                    ldd       M$ID,u
                    cmpd      #M$ID12
                    bne       L07DF
                    ldd       M$Size,u
                    subd      #M$IDSize
                    lbsr      L0866
                    bcs       L07E1
                    ldx       $04,s
                    lda       P$Prior,x
                    ldy       <$15,s              get proc desc ptr
                    sta       P$Prior,y
                    sta       P$Age,y
                    leay      <P$DATImg,y
                    tfr       y,d
                    ldx       $02,s
                    os9       F$VModul
                    bcc       L07C0
                    cmpb      #E$KwnMod
                    beq       L07C6
                    bra       L07E1
L07C0               ldd       $02,s
                    addd      $0A,s
                    std       $02,s
* U = mod dir entry
L07C6               ldd       <$17,s
                    bne       L0765
                    ldd       MD$MPtr,u
                    std       <$11,s
                    ldd       [MD$MPDAT,u]
                    std       <$17,s
                    ldd       MD$Link,u
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
                    beq       L0765
                    std       MD$Link,u
                    bra       L0765
L07DF               ldb       #E$BMID
L07E1               stb       $07,s
                    ldd       $04,s
                    beq       L07E9
                    std       <D.Proc
L07E9               lda       $06,s
                    beq       L07F0
                    os9       I$Close             close path to file
L07F0               ldd       $02,s
                    addd      #$1FFF
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       $02,s
                    ldb       ,s
                    beq       L081D
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    subb      $02,s
                    beq       L081D
                    ldx       <$15,s
                    leax      <P$DATImg,x
                    lsla
                    leax      a,x
                    leax      $01,x
                    ldu       <D.BlkMap
L0816               lda       ,x++
                    clr       a,u
                    decb
                    bne       L0816
L081D               ldx       <$15,s
                    lda       P$ID,x
                    os9       F$DelPrc
                    ldd       <$17,s
                    bne       L0832
                    ldb       $07,s
                    stb       <$12,s
                    comb
                    bra       L0861
L0832               ldu       <D.ModDir
                    ldx       <$11,s
                    ldd       <$17,s
                    leau      -MD$ESize,u
L083C               leau      MD$ESize,u
                    cmpu      <D.ModEnd
                    bcs       L084B
                    comb
                    ldb       #E$MNF
                    stb       <$12,s
                    bra       L0861
L084B               cmpx      MD$MPtr,u
                    bne       L083C
                    cmpd      [MD$MPDAT,u]
                    bne       L083C
                    ldd       MD$Link,u
                    beq       L085D
                    subd      #$0001
                    std       MD$Link,u
L085D               stu       <$17,s
                    clrb
L0861               leas      <$11,s
                    puls      pc,u,y,x,b,a

L0866               pshs      y,x,b,a
                    addd      $02,s
                    std       $04,s
                    cmpd      $08,s
                    bls       L08C2
                    addd      #$1FFF
                    lsra
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      #$07
                    bhi       L08A4
                    ldb       $08,s
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    ifne      H6309
                    subr      b,a
                    lslb
                    exg       b,a
                    else
                    pshs      b
                    exg       b,a
                    subb      ,s+
                    lsla
                    endc
                    ldu       <$1D,s
                    leau      <P$DATImg,u
                    leau      a,u
                    clra
                    ifne      H6309
                    tfr       b,f
                    else
                    tfr       d,x
                    endc
                    ldy       <D.BlkMap
                    clrb
L0899               tst       ,y+
                    beq       L08A9
L089D               equ       *
                    ifne      H6309
                    incd
                    else
                    addd      #$0001
                    endc
                    cmpy      <D.BlkMap+2
                    bne       L0899
L08A4               comb
                    ldb       #E$MemFul
                    bra       L08CC
L08A9               inc       -$01,y
                    std       ,u++
                    ifne      H6309
                    lde       $08,s
                    adde      #$20
                    ste       $08,s
                    decf
                    else
                    pshs      a
                    lda       $09,s
                    adda      #$20
                    sta       $09,s
                    puls      a
                    leax      -1,x
                    endc
                    bne       L089D
                    ldx       <$1D,s
                    os9       F$SetTsk
                    bcs       L08CC
L08C2               lda       $0E,s
                    ldx       $02,s
                    ldy       ,s
                    os9       I$Read
L08CC               leas      $04,s
                    puls      pc,x
                    else
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
                    endc

********************************
*
* F$PErr System call entry point
*
* Entry: U = Register stack pointer
*

ErrHead             fcc       /ERROR #/
ErrNum              equ       *-ErrHead
                    fcb       $2F,$3A,$30
                    fcb       C$CR
ErrMessL            equ       *-ErrHead

FPErr               ldx       <D.Proc             get current process pointer
                    lda       <P$PATH+2,x         get stderr path
                    beq       L0922               return if not there
                    leas      -ErrMessL,s         make room on stack
* copy error message to stack
                    leax      <ErrHead,pcr        point to error text
                    leay      ,s                  point to buffer
L08E9               lda       ,x+                 get a byte
                    sta       ,y+                 store a byte
                    cmpa      #C$CR               done?
                    bne       L08E9               no, keep going
                    ldb       R$B,u               get error #
* Convert error code to decimal
L08F3               inc       ErrNum+0,s
                    subb      #$64
                    bcc       L08F3
L08F9               dec       ErrNum+1,s
                    addb      #$0A
                    bcc       L08F9
                    addb      #$30
                    stb       ErrNum+2,s
                    ifgt      Level-1
                    ldx       <D.Proc             get current process pointer
                    ldu       P$SP,x              get the stack pointer
                    leau      -ErrMessL,u         put a buffer on it
                    lda       <D.SysTsk           get system task number
                    ldb       P$Task,x            get task number of process
                    leax      ,s                  point to error text
                    ldy       #ErrMessL           get length of text
L0913               os9       F$Move              move it to the process
                    leax      ,u                  point to the moved text
                    ldu       <D.Proc             get process pointer
                    lda       <P$PATH+2,u         get path number
                    os9       I$WritLn            write the text
                    leas      ErrMessL,s          purge the buffer
                    else
                    ldx       <D.Proc
                    leax      ,s                  point to error message
                    ldu       <D.Proc
                    lda       <P$PATH+2,u
                    os9       I$WritLn            write message
                    leas      ErrMessL,s          fix up stack
                    endc
L0922               rts                           return

FIOQu
                    ifne      H6309
                    lde       R$A,u
                    endc
FIOQu2
                    ldy       <D.Proc
                    ifne      H6309
                    clrf
                    endc
L092B               lda       <P$IOQN,y
                    beq       L094F
                    ifne      H6309
                    cmpr      e,a
                    else
                    cmpa      R$A,u
                    endc
                    bne       L094A
                    ifne      H6309
                    stf       <P$IOQN,y
                    else
                    clr       <P$IOQN,y
                    endc
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcs       L0922
                    ifne      H6309
                    stf       P$IOQP,y
                    else
                    clr       P$IOQP,y
                    endc
                    ldb       #S$Wake
                    os9       F$Send
                    ldu       <D.Proc
                    bra       L0958
L094A
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcc       L092B
L094F
                    ifne      H6309
                    tfr       e,a
                    else
                    lda       R$A,u
                    endc
                    ldu       <D.Proc
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcs       L09B1
L0958               leax      ,y
                    lda       <P$IOQN,y
                    beq       L097A
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcs       L09B1
                    ldb       P$Age,u
                    cmpb      P$Age,y             FYI, was cmpd, bug in OS-9 Level Two from Tandy
                    bls       L0958
                    ldb       ,u
                    stb       <P$IOQN,x
                    ldb       ,x
                    stb       P$IOQP,u
                    ifne      H6309
                    stf       P$IOQP,y
                    else
                    clr       P$IOQP,y
                    endc
                    exg       y,u
                    bra       L0958
L097A               lda       ,u
                    sta       <P$IOQN,y
                    lda       ,y
                    sta       P$IOQP,u
                    ldx       #$0000
                    os9       F$Sleep
                    ldu       <D.Proc
                    lda       P$IOQP,u
                    beq       L09B1
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcs       L09AE
                    lda       <P$IOQN,y
                    beq       L09AE
                    lda       <P$IOQN,u
                    sta       <P$IOQN,y
                    beq       L09AE
                    ifne      H6309
                    stf       <P$IOQN,u
                    else
                    clr       <P$IOQN,u
                    endc
                    ifgt      Level-1
                    os9       F$GProcP
                    else
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    endc
                    bcs       L09AE
                    lda       P$IOQP,u
                    sta       P$IOQP,y
L09AE
                    ifne      H6309
                    stf       P$IOQP,u
                    else
                    clr       P$IOQP,u
                    endc
L09B1               rts

                    emod
eom                 equ       *
                    end
