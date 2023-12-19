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
*
*  13r6    2019/10/30  Bill Nobel, from discussions with L. Curtis Boyle
* Added I$ModDsc call (modify device descriptor in system memory) BN/LCB

                    nam       IOMan
                    ttl       NitrOS-9 Level 2 I/O Manager module

* Disassembled 02/04/29 23:10:07 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $06
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
                    IFNE      H6309
                    asld
                    ELSE
                    lslb                          multiply by 2
                    rola
                    ENDC
                    addd      2,s                 add to size of device table
                    os9       F$SRqMem            allocate memory
                    bcs       Crash               branch if error
* clear allocated mem
                    leax      ,u                  point to memory
                    IFNE      H6309
                    leay      <TheZero,pcr
                    tfr       d,w
                    tfm       y,x+
                    ELSE
ClrLoop             clr       ,x+                 clear a byte
                    subd      #$0001              done?
                    bne       ClrLoop             no, keep going
                    ENDC
                    stu       <D.DevTbl           save pointer to device table
                    IFNE      H6309
                    puls      x,d
                    addr      u,x
                    stx       <D.PolTbl
                    addr      d,x
                    stx       <D.CLTb
                    ELSE
                    ldd       ,s++                get pointer to device table
                    std       <D.CLTb             save to globals temporarily
                    ldd       ,s++                get size of device table
                    leax      d,u                 point x to the end of device table
                    stx       <D.PolTbl           save to globals
                    ldd       <D.CLTb             get VIRQ table size
                    leax      d,x                 add it to end of device table
                    stx       <D.CLTb             and save VIRQ table address
                    ENDC
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
                    IFGT      Level-1
                    jmp       <D.Crash
                    ELSE
                    jmp       [>$FFFE]
                    ENDC

******************************
*
* System service routine vector table
*
IOCalls             fcb       $7F                 Special for User I/O calls (see UsrIODis table)?
                    fdb       UsrIO-*-2
                    fcb       F$Load              User & System
                    fdb       FLoad-*-2
                    IFGT      Level-1
                    fcb       I$Detach            User & System
                    fdb       IDetach0-*-2
                    ENDC
                    fcb       F$PErr              User & System
                    fdb       FPErr-*-2
                    fcb       F$IOQu+$80          System ONLY
                    fdb       FIOQu-*-2
                    fcb       $FF                 Special for System I/O calls (see SysIODis table)?
                    fdb       SysIO-*-2
                    fcb       F$IRQ+$80           System ONLY
                    fdb       FIRQ-*-2
                    fcb       F$IODel+$80         System ONLY
                    fdb       FIODel-*-2
                    IFGT      Level-1
                    fcb       F$NMLink            User & System
                    fdb       FNMLink-*-2
                    fcb       F$NMLoad            User & System
                    fdb       FNMLoad-*-2
                    ENDC
                    fcb       $80                 End of F$SSvc table marker

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

                    IFNE      H6309
TheZero             fcb       $00
                    ENDC

UsrIODis            fdb       IAttach-UsrIODis
                    fdb       IDetach-UsrIODis
                    fdb       UIDup-UsrIODis
                    fdb       IUsrCall-UsrIODis   Create (User)
                    fdb       IUsrCall-UsrIODis   Open (User)
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
                    fdb       UIModDsc-UsrIODis

SysIODis            fdb       IAttach-SysIODis
                    fdb       IDetach-SysIODis
                    fdb       SIDup-SysIODis
                    fdb       ISysCall-SysIODis   Create (System)
                    fdb       ISysCall-SysIODis   Open (System)
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
                    fdb       SIModDsc-SysIODis   New system call designed by LCB/BN, implemented by BN

* Entry to User and System I/O dispatch table
* B = I/O system call code (shifted to base 0, and *2 since 2 bytes per jump table entry)
UsrIO               leax      <UsrIODis,pcr
                    bra       IODsptch

SysIO               leax      <SysIODis,pcr
IODsptch            cmpb      #(I$ModDsc-$80)*2   compare with last I/O call
                    bhi       L00F9               branch if greater
                    IFNE      H6309
                    ldw       b,x
                    lsrb
                    jmp       w,x
                    ELSE
                    pshs      d
                    ldd       b,x
                    leax      d,x
                    puls      d
                    lsrb
                    jmp       ,x
                    ENDC

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

                    IFGT      Level-1
* I$ModDsc
* LCB NOTE: FOR B=IF NEGATIVE VALUE, MAYBE READ EXISTING BYTES?
*  (in case we want to restore original settings that can not be accessed
*  via GetStat calls like SS.Opt)
* Entry (these are the callers registers, pointed to by U on entry here):
*   X=Ptr to name of module to modify (Can be hi bit or CR terminated)
*   B=# of bytes to change
*   U=Ptr to (B) # of 2 byte blocks:
*     byte 0 is the offset into the descriptor to change
*     byte 1 is the byte to write to that offset
* Exit Parameters:
*   CC clear if no errors, and header parity/CRC on descriptor updated
*   CC set if error, B has error code. Some possible results:
*     B=216 Path name not found (module not found)
*     B=187 Illegal argument (tried to modify bytes either before IT.DTP/IT.DVC or beyond length of descriptor)
*       A=offset that was out of range (which byte pair had the error, not offset itself)
* It is up to the calling process to make sure they know the file size and right offsets.
* Offsets below IT.DVC ($12) will be deemed illegal, as well as any past the end of the
* descriptor (they can specify CRC bytes; they will get overwritten anyways).

* offsets on pre-allocated stack for I$ModDsc
                    org       0
MDTmpCtr            rmb       1                   Tmp ctr variable
MDSrcTsk            rmb       1                   Callers task #
MDTmpTsk            rmb       1                   Temp task # (for module being modified)
MDChgCnt            rmb       1                   # of byte pairs to change (max 127)
MDPDscPt            rmb       2                   Callers Process Descriptor ptr
MDRegPtr            rmb       2                   Callers register stack ptr
MDMDirPt            rmb       2                   Module directory entry ptr
MDModOff            rmb       2                   Module offset (from module directory)
MDPairSc            rmb       2                   Pointer in caller's task that byte pairs are at (Callers R$U)
MDModSiz            rmb       2                   Module size
MDTmpSiz            equ       .-MDTmpCtr          Size of fixed temp vars
MDBytPrs            rmb       1                   Byte pairs start here (variable length)

* I$ModDsc - System process entry point
SIModDsc            ldx       <D.SysPrc           Get ptr to System process descriptor
                    fcb       $8c                 Skip two bytes (cmpx immediate opcode)
* I$ModDsc - User process entry point
UIModDsc            ldx       <D.Proc             get pointer to user's process descriptor
                    ldb       R$B,u               Get # of byte pairs
                    bpl       imod001             <=127 is legal, go ahead
                    comb
                    ldb       #E$IllArg           >127 is illegal argument error (May change to read flag later?)
                    rts

imod001             negb                          Make negative number
                    sex                           16 bit
                    lslb                          *2
                    rola
                    subd      #MDTmpSiz           subtract size of fixed temp vars as well
                    leas      d,s                 Allocate temp vars on stack
                    stu       MDRegPtr,s          Save copy of callers register stack ptr
                    stx       MDPDscPt,s          Save copy of callers process descriptor ptr
                    ldd       R$U,u               Get callers ptr to byte pairs
                    std       MDPairSc,s          Save it
                    ldb       R$B,u               Get # of byte pairs again
                    stb       MDChgCnt,s          Save copy for reinitializing counter
                    lda       P$Task,x            Get callers task #
                    sta       MDSrcTsk,s          Save copy
                    leay      P$DATImg,x          Point to DAT image of process
                    lda       #Devic+Objct        We only allow Device Descriptors with this call
                    ldx       R$X,u               Get ptr to module name from caller
                    os9       F$FModul            Go find the descriptor in the module directory (into U)
                    bcc       imod002             If no error on link, go do the call
* Entry: B=error code, CC has carry set if error, carry clear if not
imodexit            pshs      cc,b,x              Save error code & error flag, reserve room for stack offset calc
                    ldb       MDChgCnt+4,s        Get # of byte pairs
                    sex                           Make 16 bit
                    addd      #MDTmpSiz           Add fixed temp var size as well
                    std       2,s                 Save on stack
                    puls      x                   Restore CC and B into X
                    puls      d                   Get Stack size offset
                    leas      d,s                 Deallocate stack
                    tfr       x,d                 Move error to D
                    tfr       a,cc                and restore CC
                    rts

* Entry: U=module dir entry ptr for device descriptor we are modifying (MD$* structure).
* Make the temp DAT img here (see below with D.TskIPt) so that we can get the proper M$DTyp
* byte from the actual module, no matter if it's mapped in system RAM or not at this point
imod002             stu       MDMDirPt,s          Save ptr to module's module directory entry
                    os9       F$ResTsk            Reserve a temp task for the module's DAT image (in B)
                    stb       MDTmpTsk,s          Save temp task #
                    lslb                          2 bytes/task table entry
                    ldy       MD$MPDAT,u          Get DAT img ptr for module
                    ldx       <D.TskIPt           Point to task image table
                    abx                           Point to our new entry
                    sty       ,x                  Save as DAT IMG ptr for new task
                    lsrb                          B=temp task #
                    ldx       MD$MPtr,u           Get ptr to device dsc module itself
                    stx       MDModOff,s          Save copy while we have it
* Entry: B=Temp task #
*        U=Module dir entry ptr
*        X=Ptr to device dsc module (in it's own task)
imod005             leax      M$Size,x            Point to module size
                    os9       F$LDABX             Get high byte of size
                    sta       MDModSiz,s          Save it
                    leax      1,x                 Point to low byte of size
                    os9       F$LDABX             Get it
                    sta       MDModSiz+1,s        Save it
                    leay      MDBytPrs,s          Point to where we are copying byte pair buffer to on stack
                    ldb       MDChgCnt,s          Get # byte pairs back
                    stb       MDTmpCtr,s          Save as counter
                    ldx       MDPairSc,s          Get ptr to callers byte pair list
                    ldb       MDSrcTsk,s          Get callers Task #
* Copy patch byte pairs from caller to stack
PtchCpLp            os9       F$LDABX             Get offset byte from caller
                    cmpa      #IT.DTP             Is it past module header?
                    bhi       imod010             Yes, see if within end range of what we are allowed to modify
imodIlAg            ldb       #E$IllArg           No, illegal argument (tried to modify header)
                    coma
                    bra       imodexit

* Entry: X=offset into callers task we are copying from
*        Y=ptr to current 2 byte offset/new value pair on temp stack
*        U=Callers register stack ptr
*        A=current offset (0-127)
imod010             cmpa      #IT.BDC             Past maximum part of descriptor we are allowed to change?
                    bhi       imodIlAg            Yes, exit with illegal argument error
                    sta       1,y                 Save byte offset to change
                    leax      1,x                 Point to new value
                    os9       F$LDABX             Get new value byte from caller
                    sta       ,y++                Save it as well (stack has ,s=new value, 1,s=offset)
                    leax      1,x                 Bump up to next pair
                    dec       MDTmpCtr,s          Dec # of bytes to change counter
                    bne       PtchCpLp            Still more, keep copying the change pairs over to stack
* We now have all byte pairs copied onto stack. Now, use the temp task pointing to the
* DAT image for the module that we are modifying
                    ldb       MDChgCnt,s          Get # byte pairs back
                    stb       MDTmpCtr,s          Save as counter
                    leay      MDBytPrs,s          Point to start of byte pairs on stack
WrPtchLp            ldd       ,y++                Get new value/offset pair
                    ldx       MDModOff,s          Get dest module ptr (in temp task)
                    abx                           Point X to byte offset in dest module
                    ldb       MDTmpTsk,s          get temp task #
                    os9       F$STABX             Save byte A into module
                    dec       MDTmpCtr,s          Dec # of pairs left
                    bne       WrPtchLp            Do until all of them done.
* All bytes should be patched. Now, update CRC 1 byte at a time
* NOTE: F$CRC uses D.Proc, but since we are calling it here from the system process
*, we need to temporarily swap the system process ptr in D.Proc's place.
                    ldx       <D.SysPrc           Get system process descriptor ptr (we are calling from)
                    stx       <D.Proc             Save for F$CRC to use (we have original process dsc ptr at MDPDscPt,s
                    ldd       #$FFFF              Init CRC on stack
                    pshs      d
                    pshs      d                   Also init place holder for byte we are adding to CRC
                    leau      1,s                 Point to running CRC
                    ldd       MDModSiz+4,s        Get module size
                    subd      #3                  minus 3 CRC bytes
                    pshs      d                   Save as counter (using new stack entry since 2 byte #)
                    ldy       #1                  Always updating 1 byte/time
                    ldx       MDModOff+6,s        Get dest module ptr (in temp task)
CRCLp               ldb       MDTmpTsk+6,s        Get temp task #
                    os9       F$LDABX             Get byte
                    sta       2,s                 Save it
                    pshs      x                   Save src ptr
                    leax      2+2,s               Point to byte we got from module
                    os9       F$CRC               Update CRC with new byte
                    puls      x                   Get src ptr back
                    leax      1,x                 Point to next byte
                    ldd       ,s                  Drop # of bytes left by 1
                    subd      #1
                    std       ,s
                    bne       CRCLp               Keep going until done
* Copy original caller's process ptr back (if it wasn't system)
                    ldd       MDPDscPt+6,s        Get original caller's process desc ptr back
                    cmpd      <D.SysPrc           Was it system process?
                    beq       YesSystm            Yes, leave D.Proc alone
                    std       <D.Proc             No, save user's process descriptor ptr back
* Finally, copy new CRC over old (X pointing to CRC within task)
YesSystm            ldb       MDTmpTsk+6,s        Get temp task #
                    lda       #3                  3 byte in CRC
                    sta       ,s                  Save ctr
CRCSavLp            lda       ,u+                 Get CRC byte
                    coma                          Final CRC is complimented first
                    os9       F$STABX             Save in module
                    leax      1,x
                    dec       ,s                  Do until all 3 bytes copied
                    bne       CRCSavLp
* Finally, F$RelTsk our temp task, clean up stack and return without error
                    ldb       MDTmpTsk+6,s        Get temp task #
                    os9       F$RelTsk            Release it
                    ldb       MDChgCnt+6,s        Get original # of byte pairs
                    clra                          D=# of pairs *2
                    lslb
                    addd      #6+MDTmpSiz         Add fixed temp var size + 6 bytes we used for CRC stuff
                    leas      d,s                 Eat stack & return with no error
                    clrb
                    rts
                    ENDC

* Entry: U=module header pointer
IAttach             equ       *
                    IFNE      H6309
                    ldw       #EOSTACK            get stack count
                    leas      <-EOSTACK,s         make stack
                    leax      TheZero,pcr         point at zero
                    tfr       s,y                 move S to Y
                    tfm       x,y+                and transfer 0 to stack
                    ELSE
                    ldb       #EOSTACK-1          get stack count - 1
IALoop              clr       ,-s                 clear each byte
                    decb                          decrement
                    bpl       IALoop              and branch until = 0
                    ENDC
                    stu       <CALLREGS,s         save caller regs
                    lda       R$A,u               access mode
                    sta       AMODE,s             save on stack
                    IFGT      Level-1
                    ldx       <D.Proc             get curr proc desc
                    stx       <ODPROC,s           save on stack
                    leay      <P$DATImg,x         point to DAT img of curr proc
                    ldx       <D.SysPrc           get sys proc
                    stx       <D.Proc             make sys proc current proc
                    ENDC
                    ldx       R$X,u               get caller's X
                    lda       #Devic+0            link to device desc
                    IFGT      Level-1
                    os9       F$SLink             link to it
                    ELSE
                    os9       F$Link              link to it
                    ENDC
                    bcs       L0155               branch if error
                    stu       VDESC,s             save dev desc ptr
                    ldy       <CALLREGS,s         get caller regs
                    stx       R$X,y               save updated X
                    lda       M$Port,u            get hw page
                    sta       HWPG,s              save onto stack
                    ldd       M$Port+1,u          get hw addr
                    std       HWPORT,s            save onto stack
                    IFNE      H6309
                    ldx       M$PDev,u            get driver name ptr
                    addr      u,x                 add U to X
                    ELSE
                    ldd       M$PDev,u            get driver name ptr
                    leax      d,u                 add D to U and put in X
                    ENDC
                    lda       #Drivr+0            driver
                    os9       F$Link              link to driver
                    bcs       L0155               branch if error
                    stu       VDRIV,s             else save addr save on stack
                    sty       DRVENT,s            save entry point on stack
                    ldu       VDESC,s             get desc ptr
                    IFNE      H6309
                    ldx       M$FMgr,u            get fm name
                    addr      u,x                 add U to X
                    ELSE
                    ldd       M$FMgr,u            get fm name
                    leax      d,u                 add D to U and put in X
                    ENDC
                    lda       #FlMgr+0            link to fm
                    os9       F$Link              link to it!
L0155
                    IFGT      Level-1
                    ldx       <ODPROC,s           get caller's proc desc
                    stx       <D.Proc             restore orig proc desc
                    ENDC
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
                    IFNE      H6309
                    tfr       b,f
                    ELSE
                    tfr       b,a
                    ENDC
                    ldu       <D.DevTbl           get device table pointer
L0177               ldx       V$DESC,u            get dev desc ptr
                    beq       L01B4               branch if empty
                    cmpx      VDESC,s             same as dev desc being attached?
                    bne       L0196               branch if not
                    ldx       V$STAT,u            get driver static
                    bne       L0191               branch if zero
                    IFNE      H6309
                    lde       V$USRS,u            get user count
                    beq       L0177               If none,
                    ELSE
                    pshs      a                   save off A
                    lda       V$USRS,u            get user count
                    beq       L0188               branch if zero
                    ENDC
                    pshs      u,b
                    lbsr      FIOQu2              call F$IOQu directly
                    puls      u,b
                    IFEQ      H6309
L0188               puls      a                   pull A from stack
                    ENDC
                    bra       L0177

L0191               stu       <CURDTE,s           save current dev table ptr
                    ldx       V$DESC,u            get dev desc ptr
L0196               ldy       M$Port+1,x          get hw addr
                    cmpy      HWPORT,s            same as dev entry on stack?
                    bne       L01B4               branch if not
                    IFNE      H6309
                    lde       M$Port,x            get hw port
                    cmpe      HWPG,s              same as dev entry on stack?
                    ELSE
                    ldy       M$Port,x            get hw port
                    cmpy      HWPG,s              same as dev entry on stack?
                    ENDC
                    bne       L01B4               branch if not
                    ldx       V$DRIV,u            get driver ptr
                    cmpx      VDRIV,s             same as dev entry on stack?
                    bne       L01B4               branch if not
* A match between device table entries has occurred
                    ldx       V$STAT,u            get driver static
                    stx       VSTAT,s             save off in our statics
                    tst       V$USRS,u            any users for this device
                    beq       L01B4               branch if not
                    IFEQ      H6309
                    sta       HWPG,s
                    ENDC
L01B4               leau      DEVSIZ,u            advance to the next device entry
                    decb
                    bne       L0177
                    ldu       <CURDTE,s           get curr dev entry ptr
                    bne       L0264               branch if not zero
                    ldu       <D.DevTbl
                    IFNE      H6309
                    tfr       f,a
                    ENDC
L01C4               ldx       V$DESC,u            get desc ptr
                    beq       L01DD               branch if zero
                    leau      DEVSIZ,u            move to next dev table entry
                    deca
                    bne       L01C4
                    ldb       #E$DevOvf           dev table overflow
                    bra       L015C

L01D1
                    IFNE      H6309
                    lsrd                          /2
                    lsrd                          /4
                    lsrd                          /8
                    lsrd                          /16
                    lsrd                          /32
                    ELSE
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
                    ENDC
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
                    IFNE      H6309
                    leay      VSTAT+1,s           point to zero byte
                    tfr       d,w                 tfr count to w counter
                    tfm       y,u+                clear driver static storage
                    ELSE
Loop2               clr       ,u+                 clear newly alloc'ed mem
                    subd      #$0001
                    bhi       Loop2
                    ENDC
* Code here appears to be for Level III?
                    IFGT      Level-2
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
                    leau      -2,x
L021D               leay      >$2000,y
                    bne       L0209
                    ldb       #E$NoRAM
                    IFNE      H6309
                    cmpr      0,u
                    ELSE
                    cmpu      #$0000
                    ENDC
                    lbeq      L015C
                    ldd       <DATBYT2,s
                    std       ,u
                    ldx       <D.SysPrc
                    IFNE      H6309
                    oim       #ImgChg,P$State,x
                    ELSE
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    ENDC
                    os9       F$ID
                    bra       L023F

L023B               sty       <DATBYT1,s
                    ENDC
L023F               ldd       HWPORT,s
                    IFGT      Level-2
                    anda      #$1F
                    addd      <DATBYT1,s
                    ENDC
                    ldu       VSTAT,s             load U with static storage of drvr
                    clr       V.PAGE,u            clear page byte
                    std       V.PORT,u            save port address
                    ldy       VDESC,s             load Y with desc ptr
                    jsr       [<DRVENT,s]         call driver init routine
                    lbcs      L015C               branch if error
                    ldu       <CURDTE,s
L0259
                    IFNE      H6309
                    ldw       #DEVSIZ
                    tfr       s,x
                    tfm       x+,u+
                    leau      -DEVSIZ,u
                    ELSE
                    ldb       #DEVSIZ-1           size of device table - 1
LilLoop             lda       b,s                 get from src
                    sta       b,u                 save in dest
                    decb
                    bpl       LilLoop
                    ENDC
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
                    beq       L0351
                    dec       V$USRS,u
                    bne       L0335
IDetach2            ldx       <D.Init
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
                    IFGT      Level-1
                    ldu       V$DRIVEX,u
                    exg       x,u                 X pts to driver, U pts to static
                    pshs      u
                    jsr       D$TERM,x            $F,x Call Terminate routine in driver
                    puls      u
                    ELSE
                    ldu       V$DRIV,u
                    exg       x,u                 X pts to driver, U pts to static
                    ldd       M$Exec,x
                    leax      d,x
                    pshs      u
                    jsr       D$TERM,x            $F,x Call Terminate routine in driver
                    puls      u
                    ENDC
                    ldx       1,s                 get ptr to dev table
                    ldx       V$DRIV,x            load X with driver addr
                    ldd       M$Mem,x             get static storage size
                    addd      #$00FF              round up one page
                    clrb                          clear lo byte
                    os9       F$SRtMem            return mem
* Code here appears to be for Level III?
                    IFGT      Level-2
                    ldx       $01,s               get old U on stack (Ptr to our device table entry)
                    ldx       V$DESC,x            Get ptr to device descriptor
                    ldd       M$Port,x            Get ptr to hardware port
                    beq       L032B               None, abort
                    lbsr      L01D1
                    cmpb      #$3F
                    beq       L032B
                    tfr       d,y
                    IFNE      H6309
                    ldf       ,s
                    ENDC
                    ldu       <D.DevTbl
L02F4               cmpu      $01,s
                    beq       L0309
                    ldx       V$DESC,u
                    beq       L0309
                    ldd       M$Port,x
                    beq       L0309
                    lbsr      L01D1
                    IFNE      H6309
                    cmpr      y,d
                    ELSE
                    pshs      y
                    cmpd      ,s++
                    ENDC
                    beq       L032B
L0309               leau      DEVSIZ,u
                    IFNE      H6309
                    decf
                    ELSE
                    dec       ,s
                    ENDC
                    bne       L02F4
                    ldx       <D.SysPrc
                    ldu       <D.SysDAT
                    IFNE      H6309
                    ldf       #$08
                    ELSE
                    ldb       #$08
                    pshs      b
                    ENDC
L0316               ldd       ,u++
                    IFNE      H6309
                    cmpr      y,d
                    ELSE
                    pshs      y
                    cmpd      ,s++
                    ENDC
                    beq       L0323
                    IFNE      H6309
                    decf
                    ELSE
                    dec       ,s
                    ENDC
                    bne       L0316
                    IFEQ      H6309
                    leas      1,s
                    ENDC
                    bra       L032B
L0323
                    IFEQ      H6309
                    leas      1,s
                    ENDC
                    ldd       #DAT.Free
                    std       -$02,u
                    IFNE      H6309
                    oim       #ImgChg,P$State,x
                    ELSE
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                    ENDC
                    ENDC

L032B               puls      u,b
                    ldx       V$DESC,u            get descriptor in X
                    clr       V$DESC,u            clear out descriptor
                    clr       V$DESC+1,u
                    clr       V$USRS,u            and users
L0335
                    IFGT      Level-1
                    IFNE      H6309
                    ldw       <D.Proc             get cur process dsc ptr
                    ELSE
                    ldd       <D.Proc             get cur process dsc ptr
                    pshs      d                   save it
                    ENDC
                    ldd       <D.SysPrc           make system the current process
                    std       <D.Proc
                    ENDC
                    ldy       V$DRIV,u            get driver module address
                    ldu       V$FMGR,u            get file manager module address
                    os9       F$UnLink            unlink file manager
                    leau      ,y                  point to driver
                    os9       F$UnLink            unlink driver
                    leau      ,x                  point to descriptor
                    os9       F$UnLink            unlink it
                    IFGT      Level-1
                    IFNE      H6309
                    stw       <D.Proc             restore current process
                    ELSE
                    puls      d                   restore current process
                    std       <D.Proc
                    ENDC
                    ENDC
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
*    Carry set if path table in process descriptor is full
LocFrPth            ldx       <D.Proc             get ptr to current proc desc
                    leax      <P$Path,x           point X to proc's path table
                    clra                          start from 0
L037D               tst       a,x                 this path free?
                    beq       L038A               Yes, exit with that path #
                    inca                          No, try next
                    cmpa      #NumPaths           are we at the end?
                    blo       L037D               No, try that one
                    comb                          else path table is full
                    ldb       #E$PthFul
                    rts

L038A               andcc     #^Carry
                    rts

* Open/Create from User process
IUsrCall            bsr       LocFrPth            Get next free path # for process
                    bcs       L039F               No free ones, return with error
                    pshs      u,x,a               Save regs
                    bsr       ISysCall            Process I/O call (Open or Create)
                    puls      u,x,a               Restore regs
                    bcs       L039F               If there was an error, return with it
                    ldb       R$A,u
                    stb       a,x
                    sta       R$A,u
L039F               rts

* Open/Create from System
ISysCall            pshs      b                   Save B
                    ldb       R$A,u               Get access mode
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
                    IFNE      H6309
                    tim       #PWRIT.+PREAD.+UPDAT.,PD.MOD,y
                    ELSE
                    ldb       PD.MOD,y
                    bitb      #PWRIT.+PREAD.+UPDAT.
                    ENDC
                    beq       IChgExec
                    ldx       PD.DEV,y            Get our device table entry ptr
                    stx       <P$DIO,u            Save as I/O ptr in process dsc.
                    inc       V$USRS,x            Bump up # of users
                    bne       IChgExec            If we max out at 255, leave at 255
                    dec       V$USRS,x
IChgExec
                    IFNE      H6309
                    tim       #PEXEC.+EXEC.,PD.MOD,y
                    ELSE
                    bitb      #PEXEC.+EXEC.
                    ENDC
                    beq       L0406               Not Exec dir, exit w/o error
                    ldx       PD.DEV,y            Get our device table entry ptr
                    stx       <P$DIO+6,u          Save as Exec dir I/O Ptr in process dsc.
                    inc       V$USRS,x            Bump up # of users
                    bne       L0406               If we max out at 255, leave at 255
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
AllcPDsc            ldx       <D.Proc             get pointer to curr proc in X
                    pshs      u,x                 save U/X
                    ldx       <D.PthDBT           get ptr to path desc base table
                    os9       F$All64             allocate 64 byte page
                    bcs       L0484               branch if error
                    inc       PD.CNT,y            set path count
                    stb       PD.MOD,y            save mode byte
                    IFGT      Level-1
                    ldx       <D.Proc             get curr proc desc
                    ldb       P$Task,x            get task #
                    ENDC
                    ldx       R$X,u               X points to pathlist
L042C
                    IFGT      Level-1
                    os9       F$LDABX             get byte from pathlist
                    leax      1,x                 move to next
                    ELSE
                    lda       ,x+                 Get byte from pathlist
                    ENDC
                    cmpa      #C$SPAC             space?
                    beq       L042C               continue if so
                    leax      -1,x                else back up
                    stx       R$X,u               save updated pointer
                    cmpa      #PDELIM             leading slash?
                    beq       L0459               yep...
                    ldx       <D.Proc             else get curr proc
                    IFNE      H6309
                    tim       #EXEC.,PD.MOD,y     Exec Dir set in mode byte?
                    ELSE
                    ldb       PD.MOD,y            get mode byte
                    bitb      #EXEC.              exec. dir relative?
                    ENDC
                    beq       L0449               nope...
                    ldx       <P$DIO+6,x          else get dev entry for exec path
                    bra       L044C               and branch

L0449               ldx       <P$DIO,x            get dev entry for data path
L044C               beq       L0489               branch if empty
                    IFGT      Level-1
                    ldd       <D.SysPrc           get system proc ptr
                    std       <D.Proc             Make current process
                    ENDC
                    ldx       V$DESC,x            get descriptor pointer
                    ldd       M$Name,x            get name offset
                    IFNE      H6309
                    addr      d,x                 point X to name in descriptor
                    ELSE
                    leax      d,x                 point X to name in descriptor
                    ENDC
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
                    IFNE      H6309
                    ldf       ,x+                 Get options count
                    leau      <PD.OPT,y           Point to Options section of path dsc
                    cmpf      #$20                Past max size we can fit in path dsc?
* LCB - Slight bug fix - was blo, so would miss 32nd byte (if used)
                    bls       L047E               No, copy the amount we need
                    ldf       #$20                Yes, will copy max of 32 bytes
L047E               clre
                    tfm       x+,u+
                    ELSE
                    ldb       ,x+                 get options count
                    leau      <PD.OPT,y           Point to Options section of path dsc
* LCB 6809 note: Should be 2 cycles faster per byte copied (so up to 64 cycles faster)
                    cmpb      #$20                Past max size we can fit in path dsc?
                    bls       StartCpy            No, copy the amount we need
                    ldb       #$20                Yes, will copy max of 32 bytes
StartCpy            decb                          Adjust so we do right range
KeepLoop            lda       b,x                 Get byte from device dsc
                    sta       b,u                 Save in path dsc
                    decb                          Done all of them?
                    bpl       KeepLoop            Copy till done
                    ENDC
                    clrb
L0484               puls      u,x                 Restore regs
                    IFGT      Level-1
                    stx       <D.Proc             Restore current process ptr
                    ENDC
                    rts

L0489               ldb       #E$BPNam            Bad pathname error
L048B               pshs      b                   Save error code
                    lda       ,y
                    ldx       <D.PthDBT
                    os9       F$Ret64             Return the 64 bytes of path dsc mem to system
                    puls      b                   Restore error # & return with it
                    coma
                    bra       L0484

UISeek              bsr       S2UPath             get user path #
                    bcc       GtPDClFM            get PD, call FM
                    rts

SISeek              lda       R$A,u               Get path #
GtPDClFM            bsr       GetPDesc            Get path descriptor
                    IFNE      H6309
                    bcc       CallFMgr            No error, call file manager
                    ELSE
                    lbcc      CallFMgr            No error, call file manager
                    ENDC
                    rts

L04A5               ldb       #E$Read             Default to Read error
                    IFNE      H6309
                    tim       #WRITE.,,s          Was this a Write call?
                    ELSE
                    lda       ,s                  Was this a Write call?
                    bita      #WRITE.
                    ENDC
                    beq       L04B2               No, exit with Read error
                    ldb       #E$Write            Yes, exit with Write error
                    bra       L04B2

L04B0               ldb       #E$BMode
L04B2               com       ,s+                 Eat temp stack, exit with error in B
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
GetPDesc            ldx       <D.PthDBT           Get path descriptor block table ptr
                    os9       F$Find64            Get address of path descriptor
                    bcs       L04DD               Error, exit with Bad Path Number
                    rts

* System to User Path routine
* Exit:
*   A = user path #
*   X = path table in path desc. of current proc.
S2UPath             lda       R$A,u               Get local path # from user (0-15 max)
                    cmpa      #NumPaths           Beyond maximum allowed per process?
                    bhs       L04DD               Yes, illegal path number
                    ldx       <D.Proc             Get caller's process dsc ptr
                    adda      #P$Path             Add offset to local path #'s in descriptor
                    lda       a,x                 Get local path #
                    bne       L04E0               There is one, return
L04DD               comb                          Path asked for is not defined; Bad Path Number error
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
                    IFGT      Level-1
                    IFNE      H6309
                    decd      subtract            1 from count
                    ELSE
                    subd      #$0001              subtract 1 from count
                    ENDC
                    lsra                          / 2
                    lsra                          / 4
                    lsra                          / 8
                    lsra                          / 16
                    lsra                          / 32
                    ldb       R$X,u               get address of buffer to hold read data
                    lsrb                          Divide by 16
                    lsrb
                    lsrb
                    lsrb
                    ldx       <D.Proc             Get caller's process dsc ptr
                    leax      <P$DATImg,x         Point to process' DAT IMG
                    abx                           Point to MMU block within image we will read into
                    lsrb                          Divide by 2 more
                    IFNE      H6309
                    subr      b,a
                    tfr       a,e
                    ELSE
                    pshs      b
                    suba      ,s
                    sta       ,s
                    ENDC
L0510               ldd       ,x++                Get DAT marker for MMU RAM block
                    cmpd      #DAT.Free           Free block?
                    IFNE      H6309
                    beq       L04A5               Yes, exit with error
                    dece                          No, check next MMU block until we have checked all we need
                    ELSE
                    bne       L051X               No, process
                    puls      a                   Yes, eat temp stack
                    bra       L04A5               and exit with error

L051X               dec       ,s                  No, check next MMU block until we have checked all we need
                    ENDC
                    bpl       L0510
                    IFEQ      H6309
                    puls      a                   Eat temp ctr
                    ENDC
                    ENDC
L051C               puls      b                   Restore B
CallFMgr            subb      #$03
                    pshs      u,y,x               Save regs (Y=path dsc ptr)
                    ldx       <D.Proc             Get caller's process dsc. ptr
L0524
                    IFNE      H6309
                    lde       PD.CPR,y            Is their a current process using this path?
                    ELSE
                    tst       PD.CPR,y            Is their a current process using this path?
                    ENDC
                    bne       L054B               Yes, skip ahead
                    lda       P$ID,x              No, get process id# of current process
                    sta       PD.CPR,y            Save it as current process using this path
                    stu       PD.RGS,y            Save register stack ptr for current process in this path
                    ldx       PD.DEV,y            Get ptr to device table entry address for this path
                    IFGT      Level-1
                    ldx       V$FMGREX,x          get file manager execution (branch table) address
                    ELSE
                    ldx       V$FMGR,x            Get file manager address
                    ldd       M$Exec,x            Get it's offset to it's execution (branch table)
                    leax      d,x                 Point to it
                    ENDC
                    lda       #3                  length of lbra instruction (size of each entry in branch table)
                    mul                           Calc offset to specific file manager function we are calling
                    jsr       b,x                 Call file manager function
L0538               pshs      b,cc                preserve return status (C,B) from call
                    bsr       L0595               Wake up next process in I/O Queue
                    ldy       $04,s               get Y off stack
                    ldx       <D.Proc             Get current process dsc ptr
                    lda       P$ID,x              Get process id #
                    cmpa      PD.CPR,y            Same as current process # using this path descriptor?
                    bne       L0549               No, clean up and return
                    clr       PD.CPR,y            Yes, clear out current process # in path descriptor
L0549               puls      pc,u,y,x,b,cc       return.. with return status in C, B.

* A process is already using current path
L054B               pshs      u,y,x,b             Save regs
                    lbsr      FIOQu2              Insert process # in A into I/O Queue
                    puls      u,y,x,b             Get regs back
                    coma
                    lda       <P$Signal,x         Get any impending signal
                    beq       L0524               None, loop back
                    tfr       a,b                 Move signal code to B
                    bra       L0538               go back and wake next process in queue

UIGetStt            lbsr      S2UPath             get usr path #
                    ldx       <D.Proc             Get current process dsc. ptr
                    bcc       L0568               If no error getting user path#, go process
                    rts

SIGetStt            lda       R$A,u               Get path
                    IFGT      Level-1
                    ldx       <D.SysPrc           Get system process ptr
                    ENDC
L0568               pshs      x,d                 Save regs
                    lda       R$B,u               get func code
                    sta       1,s                 place on stack in B
                    puls      a                   get path off stack
                    lbsr      GtPDClFM            Get process Descriptor and call file manager
                    puls      x,a                 get func code in A, sys proc in X
                    pshs      u,y,b,cc            Save regs (and status/error from GtPDClFM
                    tsta                          SS.Opt?
                    beq       SSOpt               Yes, go do
                    cmpa      #SS.DevNm           Get device name?
                    beq       SSDevNm             Yes, go do
                    puls      pc,u,y,b,cc         Any other call, restore regs & return

SSOpt               equ       *
                    IFGT      Level-1
                    lda       <D.SysTsk           Get system task #
                    ldb       P$Task,x            Get user task #
                    ENDC
                    leax      <PD.OPT,y           Point to options in path dsc.
SSCopy              ldy       #PD.OPT             Offset to PD.Opt
                    ldu       R$X,u               Get callers address to receive Opt packet
                    IFGT      Level-1
                    os9       F$Move              Move data to caller
                    ELSE
Looper              lda       ,x+                 Copy data to caller
                    sta       ,u+
                    decb
                    bne       Looper
                    ENDC
                    leas      $2,s                Eat temp stack
                    clrb                          No error, restore regs & return
                    puls      pc,u,y

* Update I/O Queue linked list pointers and wake up next process in I/O Queue
* LCB 6809/6309 note: Since both routines that call this do their own B/Carry
*   handling, remove the CLRB from L05AC
L0595               pshs      y                   Save reg
                    ldy       <D.Proc             get current process ptr
                    lda       <P$IOQN,y           get ID# of next process in I/O queue
                    beq       L05AC               There is none, return
                    clr       <P$IOQN,y           else clear it
                    ldb       #S$Wake             wake signal
                    os9       F$Send              wake up the process that was next in the IO Queue
                    IFGT      Level-1
                    os9       F$GProcP            Get copy of process descriptor
                    ELSE
                    ldx       <D.PrcDBT           Get ptr to Process descriptor block table
                    os9       F$Find64            Find path descriptor address for queued process
                    ENDC
                    clr       P$IOQP,y            Clear it's previous queued process #
L05AC               clrb
                    puls      pc,y                Restore Y & return

SSDevNm
                    IFGT      Level-1
                    lda       <D.SysTsk           Get System process task #
                    ldb       P$Task,x            Get caller's task #
                    ENDC
                    IFEQ      H6309
                    pshs      d                   Save task #'s
                    ENDC
                    ldx       PD.DEV,y            Get path's device table entry address
                    ldx       V$DESC,x            Get ptr to device descriptor
                    IFNE      H6309
                    ldw       M$Name,x            Get offset to descriptor's name
                    addr      w,x                 Point to name of descriptor
                    ELSE
                    ldd       M$Name,x            Get offset to descriptor's name
                    leax      d,x                 Point to name of descriptor
                    puls      d                   Get the two task #'s back
                    ENDC
                    bra       SSCopy              Move name to caller and return

UIClose             lbsr      S2UPath             get user path #
                    bcs       L05CE               If error, exit with it
                    IFNE      H6309
                    lde       R$A,u               Get path # from caller
                    adde      #P$Path             Add offset to paths in process dsc
                    clr       e,x                 zero path entry
                    ELSE
                    pshs      b                   Save reg
                    ldb       R$A,u               Get path # from caller
                    addb      #P$Path             Add offset to paths in process dsc
                    clr       b,x                 Zero path entry
                    puls      b                   Restore reg
                    ENDC
                    bra       L05D1               Finish I$Close

L05CE               rts

SIClose             lda       R$A,u               Get callers path #
L05D1               lbsr      GetPDesc            Get path dsc
                    bcs       L05CE               If error, return with it
                    dec       PD.CNT,y            Dec # of open paths
                    tst       PD.CPR,y            Is there a process currently accessing this path?
                    bne       L05DF               yes, skip ahead
                    lbsr      CallFMgr            Call CLOSE in the file manager
L05DF               tst       PD.CNT,y            How many open paths now?
                    bne       L05CE               Still some left, return
                    lbra      L03C3               None, Detach the device and return 64 byte path dsc mem to system

* F$IRQ - Add or remove IRQ device from IRQ polling table
FIRQ                ldx       R$X,u               get ptr to IRQ packet
                    ldb       ,x                  B = flip byte
                    ldx       $01,x               X = mask/priority
                    clra
                    pshs      cc                  Save CC with carry clear
                    pshs      x,b                 Save flip, mask, priority bytes
                    ldx       <D.Init             Get ptr to Init module
                    ldb       PollCnt,x           Get max # of entries in IRQ polling table
                    ldx       <D.PolTbl           Get ptr to I/O polling table
                    ldy       R$X,u               Get packet address (or remove device) from caller
                    beq       L0634               X=0 means remove device, go remove it
                    tst       $01,s               test mask byte
                    beq       L0662               No bits to trigger, exit with polling table full error
                    decb                          dec poll table count
                    lda       #POLSIZ             Calc offset to last possible entry in I/O table
                    mul
                    IFNE      H6309
                    addr      d,x                 point to last entry in table
                    ELSE
                    leax      d,x                 point to last entry in table
                    ENDC
                    lda       Q$MASK,x            Get Mask byte
                    bne       L0662               If any bits set (keep when masked), skip ahead
                    orcc      #IntMasks           Shut off IRQ's
L060D               ldb       $02,s               get priority byte
                    cmpb      -(POLSIZ-Q$PRTY),x  compare with prev entry's priority
                    blo       L0620               If lower, skip ahead
                    ldb       #POLSIZ             If our priority is higher or same, B=last entry #
L0615               lda       ,-x                 Copy previous entry to next entry
                    sta       POLSIZ,x
                    decb                          Until done entire entry
                    bne       L0615
                    cmpx      <D.PolTbl           Are we now pointing to the first entry?
                    bhi       L060D               Not yet, keep shifting entries down until at start or higher priority
* Insert new entry
L0620               ldd       R$D,u               get dev stat reg address
                    std       Q$POLL,x            save in polling table
                    ldd       ,s++                get flip/mask
                    std       Q$FLIP,x            save in polling table
                    ldb       ,s+                 get priority
                    stb       Q$PRTY,x            Save in polling table
                    IFNE      H6309
                    ldq       R$Y,u               Get IRQ service routine address & IRQ Static storage ptr
                    stq       Q$SERV,x            Save them in polling table
                    ELSE
                    ldd       R$Y,u               get IRQ svc addr
                    std       Q$SERV,x            Save in polling table
                    ldd       R$U,u               get IRQ static storage ptr
                    std       Q$STAT,x            Save in polling table
                    ENDC
                    puls      pc,cc               No error, turn interrupts back on & return

* Search for device to remove from IRQ polling table
L0634               leas      4,s                 clean stack
                    ldy       R$U,u               Get ptr to service routine's static mem ptr
L0639               cmpy      Q$STAT,x            Same as static mem ptr we are currently checking against?
                    beq       L0645               Yes, found the one to remove (static is unique to each device)
                    leax      POLSIZ,x            Point to next entry
                    decb                          Are we done all entries?
                    bne       L0639               No, keep looking for match
                    clrb                          Done all of them, no match, return w/o error
                    rts

* Remove device from polling table
                    IFNE      H6309
L0645               orcc      #IntMasks           Shut off IRQ's
                    decb                          Dec polling table entry #
                    beq       L0654               If we are at start, go zero out first entry
                    lda       #POLSIZ             Otherwise, calc size of all remaining entries combined
                    mul
                    tfr       d,w                 That is size to move
                    leay      POLSIZ,x            Point to next entry
                    tfm       y+,x+               Block copy them all up one entry position
L0654               ldw       #POLSIZ             Clear out our old entry
                    clr       ,-s
                    tfm       s,x+
                    leas      $01,s               Eat temp stack
                    andcc     #^IntMasks          Turn IRQ's on & return
                    rts
                    ELSE
L0645               pshs      b,cc                Save polling table entry # & IRQ status
                    orcc      #IntMasks           Shut off IRQ's
                    bra       L0565

* Move prev poll entry up one
L055E               ldb       POLSIZ,x            Point to our entry+1
                    stb       ,x+                 copy to our entry
                    deca                          Copy whole polling table entry
                    bne       L055E               Unti; dpme
L0565               lda       #POLSIZ             Polling table entry size
                    dec       1,s                 dec count
                    bne       L055E               Still more to copy, go do
L056B               clr       ,x+                 Clear out current entry
                    deca
                    bne       L056B
                    puls      pc,a,cc             Eat temp ctr, turn IRQ's back on & return
                    ENDC

L0662               leas      $04,s               Eat temp stack
L0664               comb                          Exit with Polling Table Full error
                    ldb       #E$Poll
                    rts

***************************
* Device polling routine (Pointed to by <D.Poll)
* Entry: None
* NOTE: Could slightly speed up (by 6 cycles) by putting PollCnt from INIT module into
*   an unused DP location, so that we can replace LDX <D.Init/ldb PollCnt,x with ldb <xxxx
*   unless X needs to keep pointing at Init
IRQPoll             ldy       <D.PolTbl           get pointer to polling table
                    ldx       <D.Init             get pointer to init module
                    ldb       PollCnt,x           get number of entries in table
L066F               lda       [Q$POLL,y]          get device's status register
                    eora      Q$FLIP,y            Invert any status bits to 1's for mask that are needed
                    bita      Q$MASK,y            Any IRQ status bits set?
                    bne       L067E               yes, likely source of IRQ, go process
L0677               leay      POLSIZ,y            else move to next entry
                    decb                          done checking all entries?
                    bne       L066F               no, try next one
                    bra       L0664               IRQ we received not in polling table, exit with Polling Table Full error

* Found source
L067E               ldu       Q$STAT,y            get device static storage
                    pshs      y,b                 preserve device # & poll address
                    jsr       [<Q$SERV,y]         execute service routine
                    puls      y,b                 restore device # & poll address
                    bcs       L0677               go to next device if error
                    rts                           return

                    IFGT      Level-1
FNMLoad             pshs      u                   save caller's regs ptr
                    ldx       R$X,u               Get ptr to module name
                    lbsr      LoadMod             Load module (allocates fake proc desc)
                    bcs       L06E2               Error, restore U and return with it
                    ldy       ,s                  get caller's regs ptr in Y
                    stx       R$X,y               Save ptr to end of module name+1 back to caller
                    ldy       ,u
                    ldx       $04,u
                    ldd       #$0006
                    os9       F$LDDDXY
                    leay      ,u
                    puls      u
                    bra       L06BF

FNMLink             ldx       <D.Proc             Get ptr to current process descriptor
                    leay      <P$DATImg,x         Point to its DAT image
                    pshs      u                   Preserve callers register stack ptr
                    ldx       R$X,u               Get ptr to module name to link
                    lda       R$A,u               Get type/language byte (each nibble that is 0=wildcard/don't care)
                    os9       F$FModul            Find module in module directory
                    bcs       L06E2               Could not find, exit with error
                    leay      ,u                  Point Y to module directory entry ptr
                    puls      u                   Get caller's register stack ptr back
                    stx       R$X,u               Save updated name ptr (pointing to end of name+1)
L06BF               std       R$A,u               Save type/language (A) & Attribute/Revision (B)
                    ldx       MD$Link,y           get link count
                    beq       L06C9               If 0, go bump it to 1
                    bitb      #ReEnt              At least 1, is it reentrant?
                    beq       L06DF               No, single user and in use, exit with module busy error
L06C9               leax      1,x                 increment module link count
                    beq       L06CF               If it wraps 65535 to 0, leave at 65535
                    stx       MD$Link,y           else save new link count
L06CF               ldx       MD$MPtr,y           get module pointer in X
                    ldy       MD$MPDAT,y          get module DAT image ptr
                    ldd       #$000B              Offset for either M$Mem (for driver or program) or M$PDev (for descriptor)
                    os9       F$LDDDXY            Get M$Mem (stack size requirement) or M$PDev (offset to device driver name)
                    bcs       L06DE               Error, exit with it
                    std       R$Y,u               Save memory requirement into callers Y & return
L06DE               rts

L06DF               comb                          Exit with Module Busy error
                    ldb       #E$ModBsy
L06E2               puls      pc,u
                    ENDC

FLoad
                    IFGT      Level-1
                    pshs      u                   place caller's reg ptr on stack
                    ldx       R$X,u               get pathname to load
                    bsr       LoadMod             allocate a process descriptor
                    bcs       L070F               exit if error
                    puls      y                   get caller's reg ptr into Y
L06EE               pshs      y                   preserve y
                    stx       R$X,y               save updated pathlist
                    ldy       ,u                  get DAT image pointer
                    ldx       $04,u               get offset within DAT image
                    ldd       #M$Type             Offset for type/lanugage & attrib/revision
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

                    ELSE
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
                    ENDC

                    IFGT      Level-1
IDetach0            pshs      u                   save off regs ptr
                    ldx       R$X,u               get ptr to device name
                    bsr       LoadMod
                    bcs       L0729
                    puls      y
                    ldd       <D.Proc             Get ptr to current process descriptor
                    pshs      y,d
                    ldd       R$U,y
                    std       <D.Proc
                    bsr       L06EE
                    puls      x
                    stx       <D.Proc
L0729               puls      pc,u
                    ENDC

* Load module from file
* Entry: X = pathlist to file containing module(s)
* A fake process descriptor is created, then the file is
* opened and validated into memory.
LoadMod
                    IFGT      Level-1
* Level 2 - load a module
                    os9       F$AllPrc            allocate proc desc
                    bcc       L0731               No error, continue with Load
                    rts                           Error; return with it

* Stack after setup in first lines below is:
* 0-1,s   = $0000
* 2-3,s   = $0000
* 4-5,s   = Current proc dsc ptr
* 6,s     = path to module file
* 7,s     = 0
* 17-18,s = Save of D
* 19-20,s = Ptr to module name (or just past it if successful open)
* 21-22,s = temp proc dsc ptr
* 23-24,s = $0000 on init
L0731               leay      ,u                  point Y at newly allocated mem
                    ldu       #$0000
                    pshs      u,y,x,d             Save regs
                    leas      <-17,s              make 17 byte temp buffer on stack
                    clr       7,s
                    stu       ,s                  save $0000
                    stu       2,s                 save $0000
                    ldu       <D.Proc             get current proc desc ptr
                    stu       $04,s               save onto stack
                    clr       $06,s
                    lda       P$Prior,u           Copy priority from current proc to temp proc
                    sta       P$Prior,y
                    sta       P$Age,y             and save as age in temp proc
                    lda       #EXEC.              from exec dir
                    os9       I$Open              open it
                    lbcs      L07E1               branch if error
                    sta       6,s                 else save path
                    stx       <19,s               put updated pathlist in X on stack (end of pathname+1)
                    ldx       <21,s               get temp proc desc ptr back
                    os9       F$AllTsk            allocate task
                    bcs       L07E1               Error, go deal with it
                    stx       <D.Proc             Make temp proc the current proc
L0765               ldx       <21,s               get temp proc desc ptr back
                    lda       P$Prior,x           get priority
                    adda      #$08                add eight
                    bhs       L0770               If that hasn't wrapped 255, use that value for temp task priority
                    lda       #$FF                Wrapped, force to 255
L0770               sta       P$Prior,x           Save new bumped up priority
                    sta       P$Age,x             and age
                    ldd       #$0009
                    ldx       2,s
                    lbsr      L0866
                    bcs       L07E1
                    ldu       <21,s               Get temp proc dsc ptr
                    lda       P$Task,u            Get source task #
                    ldb       <D.SysTsk           Destination task # is system task
                    leau      8,s                 Point to where we are copying to
                    pshs      x                   Save X
                    ldx       4,s                 Point to where we are copying from
                    os9       F$Move              Copy Y bytes from source to dest
                    puls      x                   Restore X
                    ldd       M$ID,u              Get Module ID check byte ($87CD)
                    cmpd      #M$ID12             Does it match what it is supposed to be?
                    bne       L07DF               No, exit with Bad Module ID error
                    ldd       M$Size,u            Get module size
                    subd      #M$IDSize           Subtract header size
                    lbsr      L0866
                    bcs       L07E1
                    ldx       4,s
                    lda       P$Prior,x           Get priority of calling process
                    ldy       <$15,s              get new proc desc ptr
                    sta       P$Prior,y           Duplicate priority in new process
                    sta       P$Age,y             And set as current age (for queueing)
                    leay      <P$DATImg,y         Point to the DAT image for new process
                    tfr       y,d                 Move ptr to D
                    ldx       2,s
                    os9       F$VModul            Validate the module (checks header parity & CRC)
                    bcc       L07C0               No error, continue
                    cmpb      #E$KwnMod           Incorrect module CRC error?
                    beq       L07C6               Yes, skip ahead
                    bra       L07E1               All other errors skip ahead

L07C0               ldd       2,s
                    addd      $A,s
                    std       2,s
* U = mod dir entry
L07C6               ldd       <$17,s
                    bne       L0765
                    ldd       MD$MPtr,u           Get module ptr from module directory entry
                    std       <$11,s              Save it
                    ldd       [MD$MPDAT,u]        Get block 0 DAT setting
                    std       <$17,s              Save it
                    ldd       MD$Link,u           Get Module link count from module directory
                    IFNE      H6309
                    incd                          Increase link count
                    ELSE
                    addd      #$0001              Increase link count
                    ENDC
                    beq       L0765               If wrapped to 0, don't update it
                    std       MD$Link,u           Save increased link count
                    bra       L0765

L07DF               ldb       #E$BMID             Illegal Module Header error
L07E1               stb       7,s
                    ldd       4,s                 Get process desc ptr
                    beq       L07E9               If none, don't change current one
                    std       <D.Proc             Save as current process desc ptr
L07E9               lda       6,s                 Get path used for Load
                    beq       L07F0               If none, skip ahead
                    os9       I$Close             close path to file
L07F0               ldd       2,s                 Get mem requirement of some sort
                    addd      #$1FFF              Round up to even 8K boundary
                    lsra                          Divide by 32 (for MMU block # in process space)
                    lsra
                    lsra
                    lsra
                    lsra
                    sta       2,s                 Save it
                    ldb       ,s
                    beq       L081D
                    lsrb                          Divide by 32 (for MMU block # in process space?)
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    subb      2,s                 Subtract previous calc, to get # of 8K blocks we are returning to system
                    beq       L081D
                    ldx       <$15,s              Get our temp process descriptor ptr
                    leax      <P$DATImg,x         Point to DAT IMG within it
                    lsla                          * 2 since bytes per DAT IMG block entry # (2 bytes each)
                    leax      a,x                 Calculate offset
                    leax      1,x                 Point to next byte
                    ldu       <D.BlkMap           U=ptr to memory block map ptr (what 8K blocks are used, up to 2 MB)
L0816               lda       ,x++                Get MMU Block # from process descriptor
                    clr       a,u                 Flag the block as free in main memory block map
                    decb                          Are we done freeing all the blocks?
                    bne       L0816               No, keep going until done
L081D               ldx       <$15,s              Get our temp process descriptor ptr back
                    lda       P$ID,x              Get process ID #
                    os9       F$DelPrc            Delete the temporary process we used to Load
                    ldd       <$17,s
                    bne       L0832
                    ldb       $07,s
                    stb       <$12,s
                    comb
                    bra       L0861

L0832               ldu       <D.ModDir           Get ptr to module directory
                    ldx       <$11,s              Get ptr to module
                    ldd       <$17,s              Get block #0
                    leau      -MD$ESize,u         Init current entry ptr to -1 for loop
L083C               leau      MD$ESize,u          Point to next module directory entry
                    cmpu      <D.ModEnd           Have we hit end of module directory?
                    blo       L084B               No, skip ahead
                    comb                          Didn't find module
                    ldb       #E$MNF              Module not found error
                    stb       <$12,s
                    bra       L0861

L084B               cmpx      MD$MPtr,u           Is current module dir entry ptr same as temp one we made?
                    bne       L083C               No, skip to next entry
                    cmpd      [MD$MPDAT,u]        Yes, is the MMU block mapped into block 0 of this entry same as temp one we made?
                    bne       L083C               No, skip to next entry
                    ldd       MD$Link,u           yes, Get link counter
                    beq       L085D               Already 0, skip ahead
                    subd      #$0001              <>0, dec by 1
                    std       MD$Link,u           Save back to module directory entry
L085D               stu       <$17,s              Save ptr to module directory entry we found match in
                    clrb                          flag no error
L0861               leas      <$11,s              Eat temp stack
                    puls      pc,u,y,x,d          Restore regs & return

L0866               pshs      y,x,d
                    addd      2,s
                    std       4,s
                    cmpd      8,s
                    bls       L08C2
                    addd      #$1FFF              Round up to even 8K
                    lsra                          /32 to calculate block # within 64K process space
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      #$07                Is it in the last 8K block?
                    bhi       L08A4               Yes, Process Memory Full error
                    ldb       8,s                 Get block # we save earlier
                    lsrb                          /32 to calculate block # within 64k process space
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    IFNE      H6309
                    subr      b,a                 Calc start block # within 64k process space
                    lslb                          *2 for 2 bytes/per entry in DAT image
                    exg       b,a
                    ELSE
                    pshs      b
                    exg       b,a
                    subb      ,s+                 Calc start block # within 64k process space
                    lsla                          *2 for 2 bytes/per entry in DAT image
                    ENDC
                    ldu       <$1D,s              Get ptr to our temp process descriptor
                    leau      <P$DATImg,u         Point to DAT Image within it
                    leau      a,u                 Point to specific MMU block entry within it
                    clra
                    IFNE      H6309
                    tfr       b,f                 # of 8K blocks we will need to allocate in our process
                    ELSE
                    tfr       d,x                 # of 8K blocks we will need to allocate in our process
                    ENDC
                    ldy       <D.BlkMap           Get ptr to main memory block table
                    clrb                          D=0 now (DAT IMG block #)
L0899               tst       ,y+                 Scan main memory block until we find unused entry
                    beq       L08A9               Found unallocated block, skip ahead
L089D               equ       *
                    IFNE      H6309
                    incd                          Bump up DAT IMG MMU Block #
                    ELSE
                    addd      #$0001
                    ENDC
                    cmpy      <D.BlkMap+2         Have we hit end of memory block map?
                    bne       L0899               No, keep checking.
L08A4               comb                          Couldn't find free RAM, exit with Process RAM full
                    ldb       #E$MemFul
                    bra       L08CC

* unused MMU block found
L08A9               inc       -1,y                Flag unused block as RAM IN USE
                    std       ,u++                Save block # in process' DAT IMG
                    IFNE      H6309
                    lde       8,s
                    adde      #$20                ? I think add 8K (high byte) to ???
                    ste       8,s
                    decf                          Dec # of 8K blocks left we need to allocate for temp process
                    ELSE
                    pshs      a
                    lda       9,s
                    adda      #$20                ? I think add 8K (high byte) to ???
                    sta       9,s
                    puls      a
                    leax      -1,x                Dec # of 8K blocks left we need to allocate for temp process
                    ENDC
                    bne       L089D               Still more blocks to allocate, keep going
                    ldx       <$1D,s              Get ptr to our temp process descriptor
                    os9       F$SetTsk            Set the DAT registers to what the process DAT image says
                    bcs       L08CC               If error, exit with it
* We have memory allocated in our temp process to load the module, so now load it
L08C2               lda       $0E,s               Get temp file path #
                    ldx       2,s                 Get Ptr to buffer we are reading into
                    ldy       ,s                  Get size of buffer to read
                    os9       I$Read              Read it in & return
L08CC               leas      4,s
                    puls      pc,x

                    ELSE
* Level 1 load module
* Entry: X=Ptr to module name to load
* Temp 10 byte stack (starts @ 6,s since x,y,u saved on stack right after temp buffer allocated):
* 6,s=path # to module file
* 7-15,s=9 byte buffer for module header
L05BC               lda       #EXEC.              We want executable modules only
                    os9       I$Open              Open the module
                    bcs       L0632               Error, return with it
                    leas      -10,s               Temp buffer on stack
                    ldu       #$0000
                    pshs      u,y,x               Save regs
                    sta       6,s                 save path
L05CC               ldd       4,s                 get ptr to callers registers
                    bne       L05D2               There is a ptr, skip ahead
                    stu       4,s                 Save 0 on stack
L05D2               lda       6,s                 get path
                    leax      7,s                 point to place on stack
                    ldy       #M$IDSize           read module header from file
                    os9       I$Read
                    bcs       L061E               Error; close file & report error
                    ldd       ,x                  Get 1st 2 bytes of module
                    cmpd      #M$ID12             Proper module header ID code?
                    bne       L061C               No, report Illegal Module header
                    ldd       9,s                 get module size from module header
                    os9       F$SRqMem            Request that much RAM from system
                    bcs       L061E               Couldn't, close file & report error
                    ldb       #M$IDSize           Copy module header to our newly allocated memory
L05F0               lda       ,x+
                    sta       ,u+
                    decb
                    bne       L05F0
                    lda       6,s                 Get file path
                    leax      ,u                  Point X to our new memory,just past module header
                    ldu       9,s                 Get module size
                    leay      -M$IDSize,u         We already read header, so subtract size of header
                    os9       I$Read              Read the rest of the module
                    leax      -M$IDSize,x         Point to start of entire module
                    bcs       L060B               If there was an error
                    os9       F$VModul            Validate the module header & CRC
                    bcc       L05CC               No error, see if more modules specified?
L060B               pshs      u,b                 Error with Read, save regs
                    leau      ,x                  Point U at memory allocated
                    ldd       M$Size,x            Size of memory we allocated
                    os9       F$SRtMem            Return mem to system
                    puls      u,b                 Get regs back
                    cmpb      #E$KwnMod           Was a module with this name already loaded?
                    beq       L05CC               Yes, skip to check next one (if any)
                    bra       L061E               Any other error, close file & report error

L061C               ldb       #E$BMID             Illegal module header error
L061E               puls      u,y,x               Restore regs
                    lda       ,s                  get file path #
                    stb       ,s                  save error code
                    os9       I$Close             close the file
                    ldb       ,s                  Get error code back
                    leas      10,s                clear up stack
                    cmpu      #$0000
                    bne       L0632
                    coma
L0632               rts

                    ENDC

********************************
*
* F$PErr System call entry point
*
* Entry: U = Register stack pointer
*

ErrHead             fcc       /ERROR #/
ErrNum              equ       *-ErrHead
                    fcb       $2F,$3A,$30         Inited dummy data set up to generate decimal error code
                    fcb       C$CR
ErrMessL            equ       *-ErrHead

FPErr               ldx       <D.Proc             get current process pointer
                    lda       <P$Path+2,x         get stderr path
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
L08F3               inc       ErrNum,s            Inc hundreds digit
                    subb      #100                Sub 100 from error #
                    bcc       L08F3               Didn't wrap, do another 100
L08F9               dec       ErrNum+1,s          Drop 10's digit
                    addb      #10                 Add 10
                    bcc       L08F9               Didn't wrap, keep doing 10's
                    addb      #$30                ASCII-fy the 1's digit
                    stb       ErrNum+2,s          Save 1's digit
                    IFGT      Level-1
* Level 2/3
                    ldx       <D.Proc             get current process pointer
                    ldu       P$SP,x              get process' stack pointer
                    leau      -ErrMessL,u         put a buffer in it to hold error message
                    lda       <D.SysTsk           get system task number
                    ldb       P$Task,x            get task number of process
                    leax      ,s                  point to error text
                    ldy       #ErrMessL           get length of text
L0913               os9       F$Move              Copy error message into process' buffer (on it's stack)
                    leax      ,u                  Point to the moved text
                    ldu       <D.Proc             get current process pointer
                    lda       <P$Path+2,u         get it's error path number
                    os9       I$WritLn            write the text
                    leas      ErrMessL,s          purge the temp error string buffer
                    ELSE
* Level 1
* 6809/6309 - This ldx is useless - X is immediately reloaded, and U gets D.Proc
*         ldx   <D.Proc        Get process descriptor
                    leax      ,s                  point to error message
                    ldu       <D.Proc             Get ptr to process descriptor
                    lda       <P$Path+2,u         Get Error path #
                    os9       I$WritLn            write message
                    leas      ErrMessL,s          fix up stack
                    ENDC
L0922               rts                           return

* F$IOQu - entry point for system call (insert process # in A into current
*  processes I/O Queue, and puts 'A' to sleep
* Entry: U=Callers register stack ptr
* Note: This is a linked list (with each process descriptor containing process #'s
*   for both the next entry (P$IOQN) and the previous entry (P$IOQP).
FIOQu
                    IFNE      H6309
                    lde       R$A,u               Get process # we are inserting ourself into it's IO Queue
                    ENDC
* F$IOQu - entry point for direct call from within IOMAN
FIOQu2              ldy       <D.Proc             Get current process descriptor
                    IFNE      H6309
                    clrf                          I think W=process descriptor ptr?
                    ENDC
L092B               lda       <P$IOQN,y           Get next I/O Queue link #
                    beq       L094F               None, skip ahead
                    IFNE      H6309
                    cmpr      e,a                 Same process # as requested?
                    ELSE
                    cmpa      R$A,u               Same process # as requested?
                    ENDC
                    bne       L094A               No, skip ahead
                    IFNE      H6309
                    stf       <P$IOQN,y           Yes, clear I/O Queue next link
                    ELSE
                    clr       <P$IOQN,y           Yes, clear I/O Queue next link
                    ENDC
                    IFGT      Level-1
                    os9       F$GProcP            Get ptr to process descriptor for process # in A
                    ELSE
                    ldx       <D.PrcDBT           Get ptr to Process Descriptor Block table
                    os9       F$Find64            Get the ptr to 64 byte process descriptor for level 1 (into Y)
                    ENDC
                    bcs       L0922               Error, return with it
                    IFNE      H6309
                    stf       P$IOQP,y            Save in previous I/O Queue
                    ELSE
                    clr       P$IOQP,y            Save in previous I/O Queue
                    ENDC
                    ldb       #S$Wake             Send a wake signal to process # in A
                    os9       F$Send
                    ldu       <D.Proc             Get current process descriptor ptr
                    bra       L0958
L094A
                    IFGT      Level-1
                    os9       F$GProcP            Get process descriptor ptr
                    ELSE
                    ldx       <D.PrcDBT           Get ptr to process descriptor block table
                    os9       F$Find64            Find our particular ptr
                    ENDC
                    bcc       L092B               No error, continue updating linked list
L094F
                    IFNE      H6309
                    tfr       e,a                 A=process #
                    ELSE
                    lda       R$A,u               A=process #
                    ENDC
                    ldu       <D.Proc             Get current process dsc ptr into U
                    IFGT      Level-1
                    os9       F$GProcP            Get process descriptor ptr
                    ELSE
                    ldx       <D.PrcDBT           Get process descriptor block table ptr
                    os9       F$Find64            Get process descriptor ptr
                    ENDC
                    bcs       L09B1               If error, skip ahead
L0958               leax      ,y                  Point X to process descriptor
                    lda       <P$IOQN,y           Get I/O Queue process # for next one in linked list
                    beq       L097A               None (end of list), skip ahead
                    IFGT      Level-1
                    os9       F$GProcP            Get process descriptor ptr to next process in linked list
                    ELSE
                    ldx       <D.PrcDBT           Get process descriptor block table ptr
                    os9       F$Find64            Get process descriptor ptr to next process in linked list
                    ENDC
                    bcs       L09B1               Error, skip ahead
                    ldb       P$Age,u             Get I/O queue age in current process
                    cmpb      P$Age,y             Compare with age of process that we are checking against
                    bls       L0958               If <=, don't change anything, continue down linked list
                    ldb       ,u                  Get P$ID (process ID #)
                    stb       <P$IOQN,x           Save as next in linked list in current process descriptor
                    ldb       ,x                  Get P$ID (process ID #) from current process descriptor
                    stb       P$IOQP,u            Save as I/O Queue Previous link in linked list
                    IFNE      H6309
                    stf       P$IOQP,y            Clear out previous link in other process descriptor
                    ELSE
                    clr       P$IOQP,y            Clear out previous link in other process descriptor
                    ENDC
                    exg       y,u                 Swap process descriptor pointers
                    bra       L0958               Keep updating linked list

L097A               lda       ,u                  Get P$ID (process ID #) for U process descriptor
                    sta       <P$IOQN,y           Save as I/O Queue Next entry in Y process descriptor
                    lda       ,y                  Get P$ID (process #) from Y process descriptor
                    sta       P$IOQP,u            Save as I/O Queue Previous entry in U process descriptor
                    ldx       #$0000              Sleep remainder of tick
                    os9       F$Sleep
                    ldu       <D.Proc
                    lda       P$IOQP,u
                    beq       L09B1
                    IFGT      Level-1
                    os9       F$GProcP            Get process descriptor ptr to next process in linked list
                    ELSE
                    ldx       <D.PrcDBT           Get process descriptor block table ptr
                    os9       F$Find64            Get process descriptor ptr to next process in linked list
                    ENDC
                    bcs       L09AE
                    lda       <P$IOQN,y
                    beq       L09AE
                    lda       <P$IOQN,u
                    sta       <P$IOQN,y
                    beq       L09AE
                    IFNE      H6309
                    stf       <P$IOQN,u
                    ELSE
                    clr       <P$IOQN,u
                    ENDC
                    IFGT      Level-1
                    os9       F$GProcP
                    ELSE
                    ldx       <D.PrcDBT
                    os9       F$Find64
                    ENDC
                    bcs       L09AE
                    lda       P$IOQP,u
                    sta       P$IOQP,y
L09AE
                    IFNE      H6309
                    stf       P$IOQP,u
                    ELSE
                    clr       P$IOQP,u
                    ENDC
L09B1               rts

                    emod
eom                 equ       *
                    end
