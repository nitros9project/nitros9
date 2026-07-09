                    ifp1
                    use       defsfile
                    endc

********************************************************************
* IOMan - OS-9 I/O Manager module
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
*
* Pre-merge baseline: edition=12  M$Revs=$80 (rev=0)  size=$070A  md5=8f90cbb5c41ea378735f33701bd33db5
* Post-merge:         edition=13  M$Revs=$86 (rev=6)  size=$070D  md5=07a883d84f5663a89bb045437b4d054c
*
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
*
*          2026/06/17  Codex
* Annotated source and normalized comments.
*
* Pre-merge baseline: edition=13  M$Revs=$86 (rev=6)  size=$0A25  md5=99355bc3c404bf5653784e78c86917a1
* Post-merge:         edition=13  M$Revs=$86 (rev=6)  size=$0A25  md5=99355bc3c404bf5653784e78c86917a1 (unchanged)

                    nam       IOMan
                    ttl       OS-9 I/O Manager module

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $06
edition             set       13

                    mod       eom,name,tylg,atrv,IOManEnt,size

u0000               rmb       0
size                equ       .

name                fcs       /IOMan/
                    fcb       edition

                    IFEQ      Level-1
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
                    leax      >IRQPoll,pcr          get address of IRQ poll routine
                    stx       <D.Poll             save in statics
* install I/O system calls
                    leay      <IOCalls,pcr        point to I/O calls
                    os9       F$SSvc              install them
                    rts                           return to OS9p2

                    ELSE
IOManEnt            ldx       <D.Init   ; get pointer to init module
                    lda       DevCnt,x  ; get number of entries in device table
                    ldb       #DEVSIZ   ; get size of each entry
                    mul                 ; calculate size needed for device table
                    pshs      d         ; preserve it
                    lda       PollCnt,x ; get number of entries in polling table
                    ldb       #POLSIZ   ; get size of each entry
                    mul                 ; calculate size needed for polling table
                    pshs      d         ; preserve it
                  IFNE    H6309
                    asld                ; double polling table byte count for VIRQ table space
                  ELSE
                    lslb                ; multiply by 2
                    rola                ; finish 16-bit multiply-by-two for polling table space
                  ENDC
                    addd      2,s       ; add to size of device table
                    os9       F$SRqMem  ; allocate memory
                    bcs       Crash     ; branch if error
* clear allocated mem
                    leax      ,u        ; point to memory
                  IFNE    H6309
                    leay      <TheZero,pcr ; point Y at source zero byte
                    tfr       d,w       ; copy allocation size into W transfer count
                    tfm       y,x+      ; clear allocated I/O tables with zero fill
                  ELSE
ClrLoop             clr       ,x+       ; clear a byte
                    subd      #$0001    ; done?
                    bne       ClrLoop   ; no, keep going
                  ENDC
                    stu       <D.DevTbl ; save pointer to device table
                  IFNE    H6309
                    puls      x,d       ; recover polling and device table sizes
                    addr      u,x       ; compute start of polling table after device table
                    stx       <D.PolTbl ; save polling table base
                    addr      d,x       ; compute start of VIRQ client table
                    stx       <D.CLTb   ; save VIRQ client table base
                  ELSE
                    ldd       ,s++      ; get pointer to device table
                    std       <D.CLTb   ; save to globals temporarily
                    ldd       ,s++      ; get size of device table
                    leax      d,u       ; point x to the end of device table
                    stx       <D.PolTbl ; save to globals
                    ldd       <D.CLTb   ; get VIRQ table size
                    leax      d,x       ; add it to end of device table
                    stx       <D.CLTb   ; and save VIRQ table address
                  ENDC
                    ldx       <D.PthDBT ; get address of path desc table
                    os9       F$All64   ; split it into 64 byte chunks
                    bcs       Crash     ; branch if error
                    stx       <D.PthDBT ; save pointer back
                    os9       F$Ret64   ; release the extra 64-byte block after table initialization
                    leax      >IRQPoll,pcr ; point to polling routine
                    stx       <D.Poll   ; save the vector address
                    leay      <IOCalls,pcr ; point to service vector table
                    os9       F$SSvc    ; set up calls
                    rts                 ; and return to system

******************************
*
* Fatal error Crash the system
*
                    ENDC

Crash
                  IFGT    Level-1
                    jmp       <D.Crash  ; vector fatal error through system crash handler
                  ELSE
                    jmp       [>$FFFE]  ; fall through reset vector on Level 1 fatal error
                  ENDC

******************************
*
* System service routine vector table
*
IOCalls             fcb       $7F       ; special for User I/O calls (see UsrIODis table)?
                    fdb       UsrIO-*-2
                    fcb       F$Load    ; user & System
                    fdb       FLoad-*-2
                  IFGT    Level-1
                    fcb       I$Detach  ; user & System
                    fdb       IDetach0-*-2
                  ENDC
                    fcb       F$PErr    ; user & System
                    fdb       FPErr-*-2
                    fcb       F$IOQu+$80 ; system ONLY
                    fdb       FIOQu-*-2
                    fcb       $FF       ; special for System I/O calls (see SysIODis table)?
                    fdb       SysIO-*-2
                    fcb       F$IRQ+$80 ; system ONLY
                    fdb       FIRQ-*-2
                    fcb       F$IODel+$80 ; system ONLY
                    fdb       FIODel-*-2
                  IFGT    Level-1
                    fcb       F$NMLink  ; user & System
                    fdb       FNMLink-*-2
                    fcb       F$NMLoad  ; user & System
                    fdb       FNMLoad-*-2
                  ENDC
                    fcb       $80       ; end of F$SSvc table marker

******************************
*
* Check device status service call?
*
* Entry: U = Callers register stack pointer
*
FIODel              ldx       R$X,u     ; get address of module
                    ldu       <D.Init   ; get pointer to init module
                    ldb       DevCnt,u  ; get device count
                    ldu       <D.DevTbl ; get pointer to device table
CheckModuleBusyLoop ldy       V$DESC,u  ; descriptor exists?
                    beq       NextModuleBusyEntry ; no, move to next device
                    cmpx      V$DESC,u  ; device match?
                    beq       ModuleBusyError ; no, move to next device
                    cmpx      V$DRIV,u  ; driver match?
                    beq       ModuleBusyError ; yes, return module busy
                    cmpx      V$FMGR,u  ; fmgr match?
                    beq       ModuleBusyError ; yes, return module busy
NextModuleBusyEntry leau      DEVSIZ,u  ; move to next dev entry
                    decb                ; done them all?
                    bne       CheckModuleBusyLoop ; no, keep going
                    clrb                ; clear carry
ModuleNotBusyReturn rts                 ; and return

ModuleBusyError     comb                ; else set carry
                    ldb       #E$ModBsy ; submit error
                    rts                 ; and return

                  IFNE    H6309
TheZero             fcb       $00
                  ENDC

UsrIODis            fdb       IAttach-UsrIODis
                    fdb       IDetach-UsrIODis
                    fdb       UIDup-UsrIODis
                    fdb       IUsrCall-UsrIODis ; create (User)
                    fdb       IUsrCall-UsrIODis ; open (User)
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
                  IFGT    Level-1
                    fdb       UIModDsc-UsrIODis
                  ENDC

SysIODis            fdb       IAttach-SysIODis
                    fdb       IDetach-SysIODis
                    fdb       SIDup-SysIODis
                    fdb       ISysCall-SysIODis ; create (System)
                    fdb       ISysCall-SysIODis ; open (System)
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
                  IFGT    Level-1
                    fdb       SIModDsc-SysIODis ; new system call designed by LCB/BN, implemented by BN
                  ENDC

* Entry to User and System I/O dispatch table
* B = I/O system call code (shifted to base 0, and *2 since 2 bytes per jump table entry)
UsrIO               leax      <UsrIODis,pcr ; select user I/O dispatch table
                    bra       IODsptch  ; use common I/O dispatch logic

SysIO               leax      <SysIODis,pcr ; select system I/O dispatch table
                  IFGT    Level-1
IODsptch            cmpb      #(I$ModDsc-$80)*2 ; compare with last I/O call
                    bhi       UnknownServiceError ; branch if greater
                  IFNE    H6309
                    ldw       b,x       ; load signed dispatch-table displacement
                    lsrb                ; restore service index from word offset
                    jmp       w,x       ; jump through computed service entry
                  ELSE
                    pshs      d         ; preserve original service code
                    ldd       b,x       ; load signed dispatch-table displacement
                    leax      d,x       ; convert displacement into absolute target
                    puls      d         ; restore original service code
                    lsrb                ; restore service index from word offset
                    jmp       ,x        ; jump through computed service entry
                  ENDC
                  ELSE
IODsptch            cmpb      #I$DeletX ; compare with last I/O call
                    bhi       UnknownServiceError ; branch if greater
                    pshs      b         ; preserve original service code
                    lslb                ; convert service code to dispatch-table offset
                    ldd       b,x       ; load signed dispatch-table displacement
                    leax      d,x       ; convert displacement into absolute target
                    puls      b         ; restore original service code
                    jmp       ,x        ; jump through computed service entry
                  ENDC

******************************
*
* Unknown service code error handler
*
UnknownServiceError comb                ; set carry for unknown service error
                    ldb       #E$UnkSvc ; return unknown service code
                    rts                 ; return to caller with error

VDRIV               equ       $00       ; \
VSTAT               equ       $02       ; |
VDESC               equ       $04       ; |--- temporary device table entry
VFMGR               equ       $06       ; |
VUSRS               equ       $08       ; /
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

                  IFGT    Level-1
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
MDTmpCtr            rmb       1         ; tmp ctr variable
MDSrcTsk            rmb       1         ; callers task #
MDTmpTsk            rmb       1         ; temp task # (for module being modified)
MDChgCnt            rmb       1         ; # of byte pairs to change (max 127)
MDPDscPt            rmb       2         ; callers Process Descriptor ptr
MDRegPtr            rmb       2         ; callers register stack ptr
MDMDirPt            rmb       2         ; module directory entry ptr
MDModOff            rmb       2         ; module offset (from module directory)
MDPairSc            rmb       2         ; pointer in caller's task that byte pairs are at (Callers R$U)
MDModSiz            rmb       2         ; module size
MDTmpSiz            equ       .-MDTmpCtr ; size of fixed temp vars
MDBytPrs            rmb       1         ; byte pairs start here (variable length)

* I$ModDsc - System process entry point
SIModDsc            ldx       <D.SysPrc ; get ptr to System process descriptor
                    fcb       $8c       ; skip two bytes (cmpx immediate opcode)
* I$ModDsc - User process entry point
UIModDsc            ldx       <D.Proc   ; get pointer to user's process descriptor
                    ldb       R$B,u     ; get # of byte pairs
                    bpl       imod001   ; <=127 is legal, go ahead
                    comb                ; set carry for illegal argument error
                    ldb       #E$IllArg ; >127 is illegal argument error (May change to read flag later?)
                    rts                 ; return with byte count error

imod001             negb                ; make negative number
                    sex                 ; sign-extend negative byte-pair count
                    lslb                ; scale pair count by two bytes per pair
                    rola                ; propagate scaled count into high byte
                    subd      #MDTmpSiz ; subtract size of fixed temp vars as well
                    leas      d,s       ; allocate temp vars on stack
                    stu       MDRegPtr,s ; save copy of callers register stack ptr
                    stx       MDPDscPt,s ; save copy of callers process descriptor ptr
                    ldd       R$U,u     ; get callers ptr to byte pairs
                    std       MDPairSc,s ; save it
                    ldb       R$B,u     ; get # of byte pairs again
                    stb       MDChgCnt,s ; save copy for reinitializing counter
                    lda       P$Task,x  ; get callers task #
                    sta       MDSrcTsk,s ; save copy
                    leay      P$DATImg,x ; point to DAT image of process
                    lda       #Devic+Objct ; we only allow Device Descriptors with this call
                    ldx       R$X,u     ; get ptr to module name from caller
                    os9       F$FModul  ; go find the descriptor in the module directory (into U)
                    bcc       imod002   ; if no error on link, go do the call
* Entry: B=error code, CC has carry set if error, carry clear if not
imodexit            pshs      cc,b,x    ; save error code & error flag, reserve room for stack offset calc
                    ldb       MDChgCnt+4,s ; get # of byte pairs
                    sex                 ; make 16 bit
                    addd      #MDTmpSiz ; add fixed temp var size as well
                    std       2,s       ; save on stack
                    puls      x         ; restore CC and B into X
                    puls      d         ; get Stack size offset
                    leas      d,s       ; deallocate stack
                    tfr       x,d       ; move error to D
                    tfr       a,cc      ; and restore CC
                    rts

* Entry: U=module dir entry ptr for device descriptor we are modifying (MD$* structure).
* Make the temp DAT img here (see below with D.TskIPt) so that we can get the proper M$DTyp
* byte from the actual module, no matter if it's mapped in system RAM or not at this point
imod002             stu       MDMDirPt,s ; save ptr to module's module directory entry
                    os9       F$ResTsk  ; reserve a temp task for the module's DAT image (in B)
                    stb       MDTmpTsk,s ; save temp task #
                    lslb                ; 2 bytes/task table entry
                    ldy       MD$MPDAT,u ; get DAT img ptr for module
                    ldx       <D.TskIPt ; point to task image table
                    abx                 ; point to our new entry
                    sty       ,x        ; save as DAT IMG ptr for new task
                    lsrb                ; b=temp task #
                    ldx       MD$MPtr,u ; get ptr to device dsc module itself
                    stx       MDModOff,s ; save copy while we have it
* Entry: B=Temp task #
*        U=Module dir entry ptr
*        X=Ptr to device dsc module (in it's own task)
imod005             leax      M$Size,x  ; point to module size
                    os9       F$LDABX   ; get high byte of size
                    sta       MDModSiz,s ; save it
                    leax      1,x       ; point to low byte of size
                    os9       F$LDABX   ; get it
                    sta       MDModSiz+1,s ; save it
                    leay      MDBytPrs,s ; point to where we are copying byte pair buffer to on stack
                    ldb       MDChgCnt,s ; get # byte pairs back
                    stb       MDTmpCtr,s ; save as counter
                    ldx       MDPairSc,s ; get ptr to callers byte pair list
                    ldb       MDSrcTsk,s ; get callers Task #
* Copy patch byte pairs from caller to stack
PtchCpLp            os9       F$LDABX   ; get offset byte from caller
                    cmpa      #IT.DTP   ; is it past module header?
                    bhi       imod010   ; yes, see if within end range of what we are allowed to modify
imodIlAg            ldb       #E$IllArg ; no, illegal argument (tried to modify header)
                    coma                ; set carry for illegal descriptor offset
                    bra       imodexit  ; clean up stack and return error

* Entry: X=offset into callers task we are copying from
*        Y=ptr to current 2 byte offset/new value pair on temp stack
*        U=Callers register stack ptr
*        A=current offset (0-127)
imod010             cmpa      #IT.BDC   ; past maximum part of descriptor we are allowed to change?
                    bhi       imodIlAg  ; yes, exit with illegal argument error
                    sta       1,y       ; save byte offset to change
                    leax      1,x       ; point to new value
                    os9       F$LDABX   ; get new value byte from caller
                    sta       ,y++      ; save it as well (stack has ,s=new value, 1,s=offset)
                    leax      1,x       ; bump up to next pair
                    dec       MDTmpCtr,s ; dec # of bytes to change counter
                    bne       PtchCpLp  ; still more, keep copying the change pairs over to stack
* We now have all byte pairs copied onto stack. Now, use the temp task pointing to the
* DAT image for the module that we are modifying
                    ldb       MDChgCnt,s ; get # byte pairs back
                    stb       MDTmpCtr,s ; save as counter
                    leay      MDBytPrs,s ; point to start of byte pairs on stack
WrPtchLp            ldd       ,y++      ; get new value/offset pair
                    ldx       MDModOff,s ; get dest module ptr (in temp task)
                    abx                 ; point X to byte offset in dest module
                    ldb       MDTmpTsk,s ; get temp task #
                    os9       F$STABX   ; save byte A into module
                    dec       MDTmpCtr,s ; dec # of pairs left
                    bne       WrPtchLp  ; do until all of them done.
* All bytes should be patched. Now, update CRC 1 byte at a time
* NOTE: F$CRC uses D.Proc, but since we are calling it here from the system process
*, we need to temporarily swap the system process ptr in D.Proc's place.
                    ldx       <D.SysPrc ; get system process descriptor ptr (we are calling from)
                    stx       <D.Proc   ; save for F$CRC to use (we have original process dsc ptr at MDPDscPt,s
                    ldd       #$FFFF    ; init CRC on stack
                    pshs      d         ; push initial CRC value
                    pshs      d         ; also init place holder for byte we are adding to CRC
                    leau      1,s       ; point to running CRC
                    ldd       MDModSiz+4,s ; get module size
                    subd      #3        ; minus 3 CRC bytes
                    pshs      d         ; save as counter (using new stack entry since 2 byte #)
                    ldy       #1        ; always updating 1 byte/time
                    ldx       MDModOff+6,s ; get dest module ptr (in temp task)
CRCLp               ldb       MDTmpTsk+6,s ; get temp task #
                    os9       F$LDABX   ; get byte
                    sta       2,s       ; save it
                    pshs      x         ; save src ptr
                    leax      2+2,s     ; point to byte we got from module
                    os9       F$CRC     ; update CRC with new byte
                    puls      x         ; get src ptr back
                    leax      1,x       ; point to next byte
                    ldd       ,s        ; drop # of bytes left by 1
                    subd      #1        ; decrement remaining CRC byte count
                    std       ,s        ; store updated CRC byte count
                    bne       CRCLp     ; keep going until done
* Copy original caller's process ptr back (if it wasn't system)
                    ldd       MDPDscPt+6,s ; get original caller's process desc ptr back
                    cmpd      <D.SysPrc ; was it system process?
                    beq       YesSystm  ; yes, leave D.Proc alone
                    std       <D.Proc   ; no, save user's process descriptor ptr back
* Finally, copy new CRC over old (X pointing to CRC within task)
YesSystm            ldb       MDTmpTsk+6,s ; get temp task #
                    lda       #3        ; 3 byte in CRC
                    sta       ,s        ; save ctr
CRCSavLp            lda       ,u+       ; get CRC byte
                    coma                ; final CRC is complimented first
                    os9       F$STABX   ; save in module
                    leax      1,x       ; advance to next CRC destination byte
                    dec       ,s        ; do until all 3 bytes copied
                    bne       CRCSavLp  ; continue until all CRC bytes are stored
* Finally, F$RelTsk our temp task, clean up stack and return without error
                    ldb       MDTmpTsk+6,s ; get temp task #
                    os9       F$RelTsk  ; release it
                    ldb       MDChgCnt+6,s ; get original # of byte pairs
                    clra                ; d=# of pairs *2
                    lslb                ; convert byte-pair count to byte count
                    addd      #6+MDTmpSiz ; add fixed temp var size + 6 bytes we used for CRC stuff
                    leas      d,s       ; eat stack & return with no error
                    clrb                ; report successful descriptor update
                    rts                 ; return to caller
                  ENDC

* Entry: U=module header pointer

IAttach             equ       *
                  IFNE    H6309
                    ldw       #EOSTACK  ; get stack count
                    leas      <-EOSTACK,s ; make stack
                    leax      TheZero,pcr ; point at zero
                    tfr       s,y       ; move S to Y
                    tfm       x,y+      ; and transfer 0 to stack
                  ELSE
                    ldb       #EOSTACK-1 ; get stack count - 1
IALoop              clr       ,-s       ; clear each byte
                    decb                ; decrement
                    bpl       IALoop    ; and branch until = 0
                  ENDC
                    stu       <CALLREGS,s ; save caller regs
                    lda       R$A,u     ; access mode
                    sta       AMODE,s   ; save on stack
                  IFGT    Level-1
                    ldx       <D.Proc   ; get curr proc desc
                    stx       <ODPROC,s ; save on stack
                    leay      <P$DATImg,x ; point to DAT img of curr proc
                    ldx       <D.SysPrc ; get sys proc
                    stx       <D.Proc   ; make sys proc current proc
                  ENDC
                    ldx       R$X,u     ; get caller's X
                    lda       #Devic+0  ; link to device desc
                  IFGT    Level-1
                    os9       F$SLink   ; link to it
                  ELSE
                    os9       F$Link    ; link to it
                  ENDC
                    bcs       AttRestoreProc ; branch if error
                    stu       VDESC,s   ; save dev desc ptr
                    ldy       <CALLREGS,s ; get caller regs
                    stx       R$X,y     ; save updated X
                    lda       M$Port,u  ; get hw page
                    sta       HWPG,s    ; save onto stack
                    ldd       M$Port+1,u ; get hw addr
                    std       HWPORT,s  ; save onto stack
                  IFNE    H6309
                    ldx       M$PDev,u  ; get driver name ptr
                    addr      u,x       ; add U to X
                  ELSE
                    ldd       M$PDev,u  ; get driver name ptr
                    leax      d,u       ; add D to U and put in X
                  ENDC
                    lda       #Drivr+0  ; driver
                    os9       F$Link    ; link to driver
                    bcs       AttRestoreProc ; branch if error
                    stu       VDRIV,s   ; else save addr save on stack
                    sty       DRVENT,s  ; save entry point on stack
                    ldu       VDESC,s   ; get desc ptr
                  IFNE    H6309
                    ldx       M$FMgr,u  ; get fm name
                    addr      u,x       ; add U to X
                  ELSE
                    ldd       M$FMgr,u  ; get fm name
                    leax      d,u       ; add D to U and put in X
                  ENDC
                    lda       #FlMgr+0  ; link to fm
                    os9       F$Link    ; link to it!
AttRestoreProc
                  IFGT    Level-1
                    ldx       <ODPROC,s ; get caller's proc desc
                    stx       <D.Proc   ; restore orig proc desc
                  ENDC
                    bcc       AttFMgrLinked ; branch if not error
* Error on attach, so detach
AttachErrorDetach   stb       <RETERR,s ; save off error code
                    leau      VDRIV,s   ; point U to device table entry
                    os9       I$Detach  ; detach
                    leas      <RETERR,s ; adjust stack
                    comb                ; set carry
                    puls      pc,b      ; exit

AttFMgrLinked       stu       VFMGR,s   ; save off fm module ptr
                    sty       FMENT,s   ; save off fm entry point
                    ldx       <D.Init   ; get D.Init
                    ldb       DevCnt,x  ; get device entry count
                  IFNE    H6309
                    tfr       b,f       ; keep device count in F while B is reused
                  ELSE
                    tfr       b,a       ; keep device count in A while B is reused
                  ENDC
                    ldu       <D.DevTbl ; get device table pointer
AttScanDevTbl       ldx       V$DESC,u  ; get dev desc ptr
                    beq       AttNextDevEntry ; branch if empty
                    cmpx      VDESC,s   ; same as dev desc being attached?
                    bne       AttCmpHardware ; branch if not
                    ldx       V$STAT,u  ; get driver static
                    bne       AttSaveCurEntry ; branch if zero
                  IFNE    H6309
                    lde       V$USRS,u  ; get user count
                    beq       AttScanDevTbl ; if none,
                  ELSE
                    pshs      a         ; save off A
                    lda       V$USRS,u  ; get user count
                    beq       AttRestoreUsrCnt ; branch if zero
                  ENDC
                    pshs      u,b       ; preserve table entry pointer and scan count
                    lbsr      FIOQu2    ; call F$IOQu directly
                    puls      u,b       ; restore table entry pointer and scan count
                  IFEQ    H6309
AttRestoreUsrCnt    puls      a         ; pull A from stack
                  ENDC
                    bra       AttScanDevTbl ; resume scan after queued users are handled

AttSaveCurEntry     stu       <CURDTE,s ; save current dev table ptr
                    ldx       V$DESC,u  ; get dev desc ptr
AttCmpHardware      ldy       M$Port+1,x ; get hw addr
                    cmpy      HWPORT,s  ; same as dev entry on stack?
                    bne       AttNextDevEntry ; branch if not
                  IFNE    H6309
                    lde       M$Port,x  ; get hw port
                    cmpe      HWPG,s    ; same as dev entry on stack?
                  ELSE
                    ldy       M$Port,x  ; get hw port
                    cmpy      HWPG,s    ; same as dev entry on stack?
                  ENDC
                    bne       AttNextDevEntry ; branch if not
                    ldx       V$DRIV,u  ; get driver ptr
                    cmpx      VDRIV,s   ; same as dev entry on stack?
                    bne       AttNextDevEntry ; branch if not
* A match between device table entries has occurred
                    ldx       V$STAT,u  ; get driver static
                    stx       VSTAT,s   ; save off in our statics
                    tst       V$USRS,u  ; any users for this device
                    beq       AttNextDevEntry ; branch if not
                  IFEQ    H6309
                    sta       HWPG,s    ; preserve hardware page while matching shared static storage
                  ENDC
AttNextDevEntry     leau      DEVSIZ,u  ; advance to the next device entry
                    decb                ; decrement remaining device entries
                    bne       AttScanDevTbl ; continue scanning device table
                    ldu       <CURDTE,s ; get curr dev entry ptr
                    bne       AttachCheckModes ; branch if not zero
                    ldu       <D.DevTbl ; restart search at first device table entry
                  IFNE    H6309
                    tfr       f,a       ; restore device entry count for empty-slot scan
                  ENDC
AttachFindFreeEntry ldx       V$DESC,u  ; get desc ptr
                    beq       AttAllocStatic ; branch if zero
                    leau      DEVSIZ,u  ; move to next dev table entry
                    deca                ; decrement empty-slot scan count
                    bne       AttachFindFreeEntry ; continue until a free entry is found
                    ldb       #E$DevOvf ; dev table overflow
                    bra       AttachErrorDetach ; detach partial attachment and report overflow

CalcDatBlock
                  IFNE    H6309
                    lsrd                ; /2
                    lsrd                ; /4
                    lsrd                ; /8
                    lsrd                ; /16
                    lsrd                ; /32
                  ELSE
                    lsra
                    rorb                ; /2
                    lsra
                    rorb                ; /4
                    lsra
                    rorb                ; /8
                    lsra
                    rorb                ; /16
                    lsra
                    rorb                ; /32
                  ENDC
                    clra                ; clear high byte of calculated DAT block value
                    rts                 ; return DAT block/page calculation

AttAllocStatic      ldx       VSTAT,s   ; get static storage off stack
                    bne       AttCopyDevEntry ; branch if already alloced
                    stu       <CURDTE,s ; else store off ptr to dev table entry
                    ldx       VDRIV,s   ; get ptr to driver
                    ldd       M$Mem,x   ; get driver storage req
                    os9       F$SRqMem  ; allocate memory
                    lbcs      AttachErrorDetach ; branch if error
                    stu       VSTAT,s   ; save newly alloc'ed driver static storage ptr
                  IFNE    H6309
                    leay      VSTAT+1,s ; point to zero byte
                    tfr       d,w       ; tfr count to w counter
                    tfm       y,u+      ; clear driver static storage
                  ELSE
Loop2               clr       ,u+       ; clear newly alloc'ed mem
                    subd      #$0001    ; decrement remaining static-storage bytes
                    bhi       Loop2     ; continue until all allocated memory is clear
                  ENDC
* Code here appears to be for Level III?
                  IFGT    Level-2
                    ldd       HWPG,s    ; get hwpage and upper addr
                    bsr       CalcDatBlock ; convert hardware address to DAT block value
                    std       <DATBYT2,s ; save off
                    ldu       #$0000    ; clear candidate DAT entry pointer
                    tfr       u,y       ; start system address scan at zero
                    stu       <DATBYT1,s ; clear selected DAT address accumulator
                    ldx       <D.SysDAT ; get system mem map ptr
AttachScanSystemDat ldd       ,x++      ; read next system DAT image entry
                    cmpd      <DATBYT2,s ; compare against target hardware DAT value
                    beq       AttUseMapping ; reuse existing mapping when already present
                    cmpd      #DAT.Free ; test whether this DAT slot is free
                    bne       AttachNextDatSlot ; skip occupied DAT slots
                    sty       <DATBYT1,s ; remember system address for first free slot
                    leau      -2,x      ; remember pointer to free DAT image slot
AttachNextDatSlot   leay      >$2000,y  ; advance to next 8K logical address
                    bne       AttachScanSystemDat ; scan until logical address wraps
                    ldb       #E$NoRAM  ; prepare no RAM error if no DAT slot exists
                  IFNE    H6309
                    cmpr      0,u       ; test whether a free DAT slot was recorded
                  ELSE
                    cmpu      #$0000    ; test whether a free DAT slot was recorded
                  ENDC
                    lbeq      AttachErrorDetach ; fail attachment when no DAT slot is available
                    ldd       <DATBYT2,s ; reload hardware DAT value
                    std       ,u        ; install hardware mapping into free DAT slot
                    ldx       <D.SysPrc ; get system process descriptor
                  IFNE    H6309
                    oim       #ImgChg,P$State,x
                  ELSE
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                  ENDC
                    os9       F$ID      ; force process DAT image reload
                    bra       AttachSetupPort ; continue with mapped port address setup

AttUseMapping       sty       <DATBYT1,s ; save existing logical address for hardware page
                  ENDC
AttachSetupPort     ldd       HWPORT,s  ; reload device hardware port address
                  IFGT    Level-2
                    anda      #$1F      ; keep offset within mapped 8K page
                    addd      <DATBYT1,s ; form logical port address in system map
                  ENDC
                    ldu       VSTAT,s   ; load U with static storage of drvr
                    clr       V.PAGE,u  ; clear page byte
                    std       V.PORT,u  ; save port address
                    ldy       VDESC,s   ; load Y with desc ptr
                    jsr       [<DRVENT,s] ; call driver init routine
                    lbcs      AttachErrorDetach ; branch if error
                    ldu       <CURDTE,s ; reload selected device table entry
AttCopyDevEntry
                  IFNE    H6309
                    ldw       #DEVSIZ   ; copy one device table entry
                    tfr       s,x       ; use temporary stack entry as source
                    tfm       x+,u+     ; copy temporary entry into device table
                    leau      -DEVSIZ,u ; restore U to start of copied entry
                  ELSE
                    ldb       #DEVSIZ-1 ; size of device table - 1
LilLoop             lda       b,s       ; get from src
                    sta       b,u       ; save in dest
                    decb                ; decrement reverse copy index
                    bpl       LilLoop   ; copy until every entry byte is stored
                  ENDC
* Here, U points to Device Table
AttachCheckModes    ldx       V$DESC,u  ; get desc ptr in X
                    ldb       M$Revs,x  ; get revs
                    lda       AMODE,s   ; get access mode byte passed in A
                    anda      M$Mode,x  ; and with MODE byte in desc.
                    ldx       V$DRIV,u  ; x points to driver module
                    anda      M$Mode,x  ; aND with mode byte in driver
                    cmpa      AMODE,s   ; same as passed mode?
                    beq       AttIncUsers ; if so, ok
                    ldb       #E$BMode  ; else bad mode
                    lbra      AttachErrorDetach ; and return

AttIncUsers         inc       V$USRS,u  ; else inc user count
                    bne       AttachReturnSuccess ; if not zero, continue
                    dec       V$USRS,u  ; else bump back to 255
AttachReturnSuccess ldx       <CALLREGS,s ; reload caller register stack pointer
                    stu       R$U,x     ; return device table entry in caller's U
                    leas      <EOSTACK,s ; release temporary attach stack frame
                    clrb                ; report successful attach
                    rts                 ; return to caller


IDetach             ldu       R$U,u     ; get device table entry from caller's U
                    ldx       V$DESC,u  ; this was incorrectly commented out in 13r4!!
*** BUG FIX
* The following two lines fix a long-standing bug in IOMan where
* the I$Detach routine would deallocate the V$STAT area.  This is
* because the V$USRS offset on the stack, where the temporary
* device table entry was being built, contained 0.  I$Detach wouldn't
* bother to do a lookup to see if it should release the memory if
* this value was zero, so here force I$Detach to do the lookup no
* matter the V$USRS value
* BGP 04/30/2002
                    tst       V$USRS,u  ; force lookup when user count is zero
                    beq       IDetach2  ; perform full detach lookup path
*** BUG FIX
DetachCheckUsers    lda       #$FF      ; load saturated user-count value
                    cmpa      V$USRS,u  ; test whether user count is pinned at 255
                    beq       DetachWakeAndReturn ; leave shared device attached when count is saturated
                    dec       V$USRS,u  ; drop one user reference
                    bne       DetachUnlinkModules ; unlink modules while other users remain
IDetach2            ldx       <D.Init   ; get init module pointer
                    ldb       DevCnt,x  ; get device table entry count
                    pshs      u,b       ; save current device table entry and scan count
                    ldx       V$STAT,u  ; get static storage pointer for target device
                    clr       V$STAT,u  ; clear static pointer high byte in target entry
                    clr       V$STAT+1,u ; clear static pointer low byte in target entry
                    ldy       <D.DevTbl ; start scan at device table base
DetachFindStatic    cmpx      V$STAT,y  ; does another device entry share this static storage?
                    beq       DetachClearDev ; keep static storage if another entry uses it
                    leay      DEVSIZ,y  ; advance to next device entry
                    decb                ; decrement remaining entries
                    bne       DetachFindStatic ; continue static-storage sharing scan
                    ldy       <D.Proc   ; get current process descriptor
                    ldb       P$ID,y    ; load current process ID
                    stb       V$USRS,u  ; tag entry while driver terminate runs
                    ldy       V$DESC,u  ; load descriptor pointer for terminate call
                  IFGT    Level-1
                    ldu       V$DRIVEX,u ; load driver execution entry for Level 2
                    exg       x,u       ; x pts to driver, U pts to static
                    pshs      u         ; save static storage pointer during driver call
                    jsr       D$TERM,x  ; $f,x Call Terminate routine in driver
                    puls      u         ; restore static storage pointer
                  ELSE
                    ldu       V$DRIV,u  ; load driver module pointer
                    exg       x,u       ; x pts to driver, U pts to static
                    ldd       M$Exec,x  ; get driver execution offset
                    leax      d,x       ; point X at driver execution table
                    pshs      u         ; save static storage pointer during driver call
                    jsr       D$TERM,x  ; $f,x Call Terminate routine in driver
                    puls      u         ; restore static storage pointer
                  ENDC
                    ldx       1,s       ; get ptr to dev table
                    ldx       V$DRIV,x  ; load X with driver addr
                    ldd       M$Mem,x   ; get static storage size
                    addd      #$00FF    ; round up one page
                    clrb                ; clear lo byte
                    os9       F$SRtMem  ; return mem
* Code here appears to be for Level III?
                  IFGT    Level-2
                    ldx       $01,s     ; get old U on stack (Ptr to our device table entry)
                    ldx       V$DESC,x  ; get ptr to device descriptor
                    ldd       M$Port,x  ; get ptr to hardware port
                    beq       DetachClearDev ; none, abort
                    lbsr      CalcDatBlock ; convert hardware address to DAT block value
                    cmpb      #$3F      ; test for non-remappable DAT block
                    beq       DetachClearDev ; skip DAT release for fixed mapping
                    tfr       d,y       ; keep target DAT value in Y for comparisons
                  IFNE    H6309
                    ldf       ,s        ; restore remaining device count for 6309 scan
                  ENDC
                    ldu       <D.DevTbl ; start scan for other users of DAT mapping
DetachCheckMap      cmpu      $01,s     ; skip the device entry being detached
                    beq       DetachNextMap ; do not compare target entry against itself
                    ldx       V$DESC,u  ; get descriptor for candidate entry
                    beq       DetachNextMap ; skip empty device table entries
                    ldd       M$Port,x  ; get candidate hardware port
                    beq       DetachNextMap ; skip entries without mapped hardware port
                    lbsr      CalcDatBlock ; convert candidate port to DAT block value
                  IFNE    H6309
                    cmpr      y,d       ; compare candidate DAT block against target
                  ELSE
                    pshs      y         ; put target DAT value on stack for comparison
                    cmpd      ,s++      ; compare candidate DAT block against target
                  ENDC
                    beq       DetachClearDev ; keep mapping if another device still uses it
DetachNextMap       leau      DEVSIZ,u  ; advance to next device table entry
                  IFNE    H6309
                    decf                ; decrement remaining entries in 6309 scan
                  ELSE
                    dec       ,s        ; decrement remaining entries in 6809 scan
                  ENDC
                    bne       DetachCheckMap ; continue looking for shared DAT mapping
                    ldx       <D.SysPrc ; get system process descriptor
                    ldu       <D.SysDAT ; get system DAT image pointer
                  IFNE    H6309
                    ldf       #$08      ; scan eight system DAT entries
                  ELSE
                    ldb       #$08      ; scan eight system DAT entries
                    pshs      b         ; keep remaining DAT entry count on stack
                  ENDC
DetachScanSystemDat ldd       ,u++      ; read next system DAT image entry
                  IFNE    H6309
                    cmpr      y,d       ; compare system DAT entry to target mapping
                  ELSE
                    pshs      y         ; put target DAT value on stack for comparison
                    cmpd      ,s++      ; compare system DAT entry to target mapping
                  ENDC
                    beq       DetachFreeDatEntry ; found DAT mapping to free
                  IFNE    H6309
                    decf                ; decrement remaining DAT entries in 6309 scan
                  ELSE
                    dec       ,s        ; decrement remaining DAT entries in 6809 scan
                  ENDC
                    bne       DetachScanSystemDat ; continue scanning system DAT image
                  IFEQ    H6309
                    leas      1,s       ; discard 6809 DAT scan counter
                  ENDC
                    bra       DetachClearDev ; skip DAT release when mapping was not found
DetachFreeDatEntry
                  IFEQ    H6309
                    leas      1,s       ; discard 6809 DAT scan counter
                  ENDC
                    ldd       #DAT.Free ; prepare free-DAT marker
                    std       -$02,u    ; mark matched system DAT entry as free
                  IFNE    H6309
                    oim       #ImgChg,P$State,x
                  ELSE
                    lda       P$State,x
                    ora       #ImgChg
                    sta       P$State,x
                  ENDC
                  ENDC

DetachClearDev      puls      u,b       ; restore device entry pointer and scan count
                    ldx       V$DESC,u  ; get descriptor in X
                    clr       V$DESC,u  ; clear out descriptor
                    clr       V$DESC+1,u ; clear descriptor pointer low byte
                    clr       V$USRS,u  ; and users
DetachUnlinkModules
                  IFGT    Level-1
                  IFNE    H6309
                    ldw       <D.Proc   ; get cur process dsc ptr
                  ELSE
                    ldd       <D.Proc   ; get cur process dsc ptr
                    pshs      d         ; save it
                  ENDC
                    ldd       <D.SysPrc ; make system the current process
                    std       <D.Proc
                  ENDC
                    ldy       V$DRIV,u  ; get driver module address
                    ldu       V$FMGR,u  ; get file manager module address
                    os9       F$UnLink  ; unlink file manager
                    leau      ,y        ; point to driver
                    os9       F$UnLink  ; unlink driver
                    leau      ,x        ; point to descriptor
                    os9       F$UnLink  ; unlink it
                  IFGT    Level-1
                  IFNE    H6309
                    stw       <D.Proc   ; restore current process
                  ELSE
                    puls      d         ; restore current process
                    std       <D.Proc
                  ENDC
                  ENDC
DetachWakeAndReturn lbsr      WakeNextIOQueue ; wake next process waiting in I/O queue
                    clrb                ; report successful detach
                    rts                 ; return to caller


* User State I$Dup
UIDup               bsr       LocFrPth  ; look for a free path
                    bcs       DupReturn ; branch if error
                    pshs      x,a       ; else save off
                    lda       R$A,u     ; get path to dup
                    lda       a,x       ; point to path to dup
                    bsr       DupPathDescriptor ; resolve path descriptor and increment use count
                    bcs       DupRestoreError ; return error if source path is invalid
                    puls      x,b       ; restore process path table and new path number
                    stb       R$A,u     ; save off new path to caller's A
                    sta       b,x       ; store duplicated system path in new process slot
                    rts                 ; return duplicated user path number

DupRestoreError     puls      pc,x,a    ; restore saved registers and return error

* System State I$Dup
SIDup               lda       R$A,u     ; get system path number to duplicate
DupPathDescriptor   lbsr      GetPDesc  ; find path descriptor
                    bcs       DupReturn ; exit if error
                    inc       PD.CNT,y  ; else increment path descriptor
DupReturn           rts                 ; return with duplicate-path status

* Find next free path position in current proc
* Exit: X = Ptr to proc's path table
*       A = Free path number (valid if carry clear)
*    Carry set if path table in process descriptor is full
LocFrPth            ldx       <D.Proc   ; get ptr to current proc desc
                    leax      <P$Path,x ; point X to proc's path table
                    clra                ; start from 0
FindFreePathLoop    tst       a,x       ; this path free?
                    beq       FindFreePathFound ; yes, exit with that path #
                    inca                ; no, try next
                    cmpa      #NumPaths ; are we at the end?
                    blo       FindFreePathLoop ; no, try that one
                    comb                ; else path table is full
                    ldb       #E$PthFul ; report full path table
                    rts                 ; return with carry set

FindFreePathFound   andcc     #^Carry   ; clear carry for free path slot found
                    rts                 ; return free path number in A

* Open/Create from User process
IUsrCall            bsr       LocFrPth  ; get next free path # for process
                    bcs       UserCallReturn ; no free ones, return with error
                    pshs      u,x,a     ; save regs
                    bsr       ISysCall  ; process I/O call (Open or Create)
                    puls      u,x,a     ; restore regs
                    bcs       UserCallReturn ; if there was an error, return with it
                    ldb       R$A,u     ; get allocated system path number
                    stb       a,x       ; save system path in user path table slot
                    sta       R$A,u     ; return user-visible path number
UserCallReturn      rts                 ; return open/create status

* Open/Create from System
ISysCall            pshs      b         ; save call selector
                    ldb       R$A,u     ; get access mode
                    bsr       AllcPDsc  ; allocate and initialize path descriptor
                    bcs       RestoreCallRet ; return if descriptor allocation failed
                    puls      b         ; restore call selector
                    lbsr      CallFMgr  ; dispatch open/create to file manager
                    bcs       CleanupPathDesc ; clean up path descriptor on file manager error
                    lda       PD.PD,y   ; get system path number from descriptor
                    sta       R$A,u     ; return system path number to caller
                    rts                 ; return successful open/create

RestoreCallRet      puls      pc,a      ; discard saved call selector and return error

* Make Directory
IMakDir             pshs      b         ; save make-directory call selector
                    ldb       #DIR.+WRITE. ; force directory write mode
AllocCallFMgr       bsr       AllcPDsc  ; allocate path descriptor for directory/file operation
                    bcs       RestoreCallRet ; return if allocation failed
                    puls      b         ; restore file manager call selector
                    lbsr      CallFMgr  ; dispatch request to file manager
CleanupPathDesc     pshs      b,cc      ; preserve status while cleaning path descriptor
                    ldu       PD.DEV,y  ; get attached device table entry
                    os9       I$Detach  ; detach device used by path descriptor
                    lda       PD.PD,y   ; get path descriptor slot number
                    ldx       <D.PthDBT ; get path descriptor block table
                    os9       F$Ret64   ; release path descriptor block
                    puls      pc,b,cc   ; restore file manager status and return

* Change Directory
IChgDir             pshs      b         ; save change-directory call selector
                    ldb       R$A,u     ; get requested access mode
                    orb       #DIR.     ; force directory mode
                    bsr       AllcPDsc  ; allocate path descriptor for target directory
                    bcs       RestoreCallRet ; return if allocation failed
                    puls      b         ; restore file manager call selector
                    lbsr      CallFMgr  ; ask file manager to change directory
                    bcs       CleanupPathDesc ; clean up descriptor on error
                    ldu       <D.Proc   ; get current process descriptor
                  IFNE    H6309
                    tim       #PWRIT.+PREAD.+UPDAT.,PD.MOD,y
                  ELSE
                    ldb       PD.MOD,y  ; get path mode bits
                    bitb      #PWRIT.+PREAD.+UPDAT. ; test data-directory mode bits
                  ENDC
                    beq       IChgExec  ; skip data directory update if no data mode bits set
                    ldx       PD.DEV,y  ; get our device table entry ptr
                    stx       <P$DIO,u  ; save as I/O ptr in process dsc.
                    inc       V$USRS,x  ; bump up # of users
                    bne       IChgExec  ; if we max out at 255, leave at 255
                    dec       V$USRS,x  ; keep saturated user count at 255
IChgExec
                  IFNE    H6309
                    tim       #PEXEC.+EXEC.,PD.MOD,y
                  ELSE
                    bitb      #PEXEC.+EXEC. ; test execution-directory mode bits
                  ENDC
                    beq       ChgDirCleanupOk ; not Exec dir, exit w/o error
                    ldx       PD.DEV,y  ; get our device table entry ptr
                    stx       <P$DIO+6,u ; save as Exec dir I/O Ptr in process dsc.
                    inc       V$USRS,x  ; bump up # of users
                    bne       ChgDirCleanupOk ; if we max out at 255, leave at 255
                    dec       V$USRS,x  ; keep saturated user count at 255
ChgDirCleanupOk     clrb                ; report successful directory change
                    bra       CleanupPathDesc ; close temporary path descriptor

IDelete             pshs      b         ; save delete call selector
                    ldb       #WRITE.   ; delete requires write access
                    bra       AllocCallFMgr ; allocate descriptor and call file manager

IDeletX             ldb       #7        ; delete offset in file manager
                    pshs      b         ; save file manager delete-entry selector
                    ldb       R$A,u     ; get caller's access mode/path context
                    bra       AllocCallFMgr ; allocate descriptor and dispatch delete

* Allocate path descriptor
* Entry:
*    B = mode
AllcPDsc            ldx       <D.Proc   ; get pointer to curr proc in X
                    pshs      u,x       ; save U/X
                    ldx       <D.PthDBT ; get ptr to path desc base table
                    os9       F$All64   ; allocate 64 byte page
                    bcs       AllocPathReturn ; branch if error
                    inc       PD.CNT,y  ; set path count
                    stb       PD.MOD,y  ; save mode byte
                  IFGT    Level-1
                    ldx       <D.Proc   ; get curr proc desc
                    ldb       P$Task,x  ; get task #
                  ENDC
                    ldx       R$X,u     ; x points to pathlist
SkipPathSpaces
                  IFGT    Level-1
                    os9       F$LDABX   ; get byte from pathlist
                    leax      1,x       ; move to next
                  ELSE
                    lda       ,x+       ; get byte from pathlist
                  ENDC
                    cmpa      #C$SPAC   ; space?
                    beq       SkipPathSpaces ; continue if so
                    leax      -1,x      ; else back up
                    stx       R$X,u     ; save updated pointer
                    cmpa      #PDELIM   ; leading slash?
                    beq       ParsePathName ; yep...
                    ldx       <D.Proc   ; else get curr proc
                  IFNE    H6309
                    tim       #EXEC.,PD.MOD,y ; exec Dir set in mode byte?
                  ELSE
                    ldb       PD.MOD,y  ; get mode byte
                    bitb      #EXEC.    ; exec. dir relative?
                  ENDC
                    beq       UseDataDirectory ; nope...
                    ldx       <P$DIO+6,x ; else get dev entry for exec path
                    bra       CheckCurrentDir ; and branch

UseDataDirectory    ldx       <P$DIO,x  ; get dev entry for data path
CheckCurrentDir     beq       BadPathName ; branch if empty
                  IFGT    Level-1
                    ldd       <D.SysPrc ; get system proc ptr
                    std       <D.Proc   ; make current process
                  ENDC
                    ldx       V$DESC,x  ; get descriptor pointer
                    ldd       M$Name,x  ; get name offset
                  IFNE    H6309
                    addr      d,x       ; point X to name in descriptor
                  ELSE
                    leax      d,x       ; point X to name in descriptor
                  ENDC
ParsePathName       pshs      y         ; save off path desc ptr in Y
                    os9       F$PrsNam  ; parse it
                    puls      y         ; restore path desc ptr
                    bcs       BadPathName ; branch if error
                    lda       PD.MOD,y  ; get mode byte
                    os9       I$Attach  ; attach to device
                    stu       PD.DEV,y  ; save dev tbl entry
                    bcs       AllocPathErrClean ; branch if error
                    ldx       V$DESC,u  ; else get descriptor pointer
* copy options from dev desc to path desc
                    leax      <M$Opt,x  ; point to opts in desc
                  IFNE    H6309
                    ldf       ,x+       ; get options count
                    leau      <PD.OPT,y ; point to Options section of path dsc
                    cmpf      #$20      ; past max size we can fit in path dsc?
* LCB - Slight bug fix - was blo, so would miss 32nd byte (if used)
                    bls       CopyOptions6309 ; no, copy the amount we need
                    ldf       #$20      ; yes, will copy max of 32 bytes
CopyOptions6309     clre                ; clear high byte of options transfer count
                    tfm       x+,u+     ; copy descriptor options into path descriptor
                  ELSE
                    ldb       ,x+       ; get options count
                    leau      <PD.OPT,y ; point to Options section of path dsc
* LCB 6809 note: Should be 2 cycles faster per byte copied (so up to 64 cycles faster)
                    cmpb      #$20      ; past max size we can fit in path dsc?
                    bls       StartCpy  ; no, copy the amount we need
                    ldb       #$20      ; yes, will copy max of 32 bytes
StartCpy            decb                ; adjust so we do right range
KeepLoop            lda       b,x       ; get byte from device dsc
                    sta       b,u       ; save in path dsc
                    decb                ; done all of them?
                    bpl       KeepLoop  ; copy till done
                  ENDC
                    clrb                ; report successful path descriptor allocation
AllocPathReturn     puls      u,x       ; restore regs
                  IFGT    Level-1
                    stx       <D.Proc   ; restore current process ptr
                  ENDC
                    rts                 ; return allocation status

BadPathName         ldb       #E$BPNam  ; bad pathname error
AllocPathErrClean   pshs      b         ; save error code
                    lda       ,y        ; get path descriptor slot number
                    ldx       <D.PthDBT ; get path descriptor block table
                    os9       F$Ret64   ; return the 64 bytes of path dsc mem to system
                    puls      b         ; restore error # & return with it
                    coma                ; set carry for allocation/attach failure
                    bra       AllocPathReturn ; restore registers and return error


UISeek              bsr       S2UPath   ; get user path #
                    bcc       GtPDClFM  ; get PD, call FM
                    rts                 ; return seek status

SISeek              lda       R$A,u     ; get path #
GtPDClFM            bsr       GetPDesc  ; get path descriptor
                  IFNE    H6309
                    bcc       CallFMgr  ; no error, call file manager
                  ELSE
                    lbcc      CallFMgr  ; no error, call file manager
                  ENDC
                    rts                 ; return system seek status

ReadWriteRangeError ldb       #E$Read   ; default to Read error
                  IFNE    H6309
                    tim       #WRITE.,,s ; was this a Write call?
                  ELSE
                    lda       ,s        ; was this a Write call?
                    bita      #WRITE.   ; test whether original request was a write
                  ENDC
                    beq       ReturnStackedError ; no, exit with Read error
                    ldb       #E$Write  ; yes, exit with Write error
                    bra       ReturnStackedError ; return read/write range error

BadModeError        ldb       #E$BMode  ; report incompatible path mode
ReturnStackedError  com       ,s+       ; eat temp stack, exit with error in B
                    rts                 ; return read/write setup error

UIRead              bsr       S2UPath   ; get user path #
                    bcc       SystemReadSetup ; proceed when user path resolved
                    rts                 ; return path-number error

UIWrite             bsr       S2UPath   ; translate user write path to system path
                    bcc       SystemWriteSetup ; proceed when user path resolved
                    rts                 ; return path-number error

SIWrite             lda       R$A,u     ; get system write path number
SystemWriteSetup    pshs      b         ; save file manager call selector
                    ldb       #WRITE.   ; require write access
                    bra       ValidateRWPath ; validate descriptor and call file manager

* get path descriptor
* Passed:    A = path number
* Returned:  Y = address of path desc for path num
GetPDesc            ldx       <D.PthDBT ; get path descriptor block table ptr
                    os9       F$Find64  ; get address of path descriptor
                    bcs       BadPathNumber ; error, exit with Bad Path Number
                    rts                 ; return path descriptor lookup status

* System to User Path routine
* Exit:
*   A = user path #
*   X = path table in path desc. of current proc.
S2UPath             lda       R$A,u     ; get local path # from user (0-15 max)
                    cmpa      #NumPaths ; beyond maximum allowed per process?
                    bhs       BadPathNumber ; yes, illegal path number
                    ldx       <D.Proc   ; get caller's process dsc ptr
                    adda      #P$Path   ; add offset to local path #'s in descriptor
                    lda       a,x       ; get local path #
                    bne       PathTranslateReturn ; there is one, return
BadPathNumber       comb                ; path asked for is not defined; bad Path Number error
                    ldb       #E$BPNum  ; return bad path number error
PathTranslateReturn rts                 ; return translated path status

SIRead              lda       R$A,u     ; get user path
SystemReadSetup     pshs      b         ; save file manager call selector
                    ldb       #EXEC.+READ. ; require read or execute access
ValidateRWPath      bsr       GetPDesc  ; get path descriptor from path in A
                    bcs       ReturnStackedError ; branch if error
                    bitb      PD.MOD,y  ; test bits against mode in path desc
                    beq       BadModeError ; branch if no corresponding bits
                    ldd       R$Y,u     ; else get count from user
                    beq       FMgrDispatchCont ; branch if zero count
                    addd      R$X,u     ; else update buffer pointer with size
                    bcs       ReadWriteRangeError ; branch if carry set
                  IFGT    Level-1
                  IFNE    H6309
                    decd      subtract  ; 1 from count
                  ELSE
                    subd      #$0001    ; subtract 1 from count
                  ENDC
                    lsra                ; / 2
                    lsra                ; / 4
                    lsra                ; / 8
                    lsra                ; / 16
                    lsra                ; / 32
                    ldb       R$X,u     ; get address of buffer to hold read data
                    lsrb                ; divide by 16
                    lsrb                ; continue buffer start block calculation
                    lsrb                ; continue buffer start block calculation
                    lsrb                ; finish buffer start block calculation
                    ldx       <D.Proc   ; get caller's process dsc ptr
                    leax      <P$DATImg,x ; point to process' DAT IMG
                    abx                 ; point to MMU block within image we will read into
                    lsrb                ; divide by 2 more
                  IFNE    H6309
                    subr      b,a       ; compute number of DAT blocks touched
                    tfr       a,e       ; keep DAT block count in E for 6309 scan
                  ELSE
                    pshs      b         ; save start block for range calculation
                    suba      ,s        ; compute number of DAT blocks touched
                    sta       ,s        ; store block count for 6809 scan
                  ENDC
CheckDatBlockLoop   ldd       ,x++      ; get DAT marker for MMU RAM block
                    cmpd      #DAT.Free ; free block?
                  IFNE    H6309
                    beq       ReadWriteRangeError ; yes, exit with error
                    dece                ; no, check next MMU block until we have checked all we need
                  ELSE
                    bne       CheckNextDatBlock ; no, process
                    puls      a         ; yes, eat temp stack
                    bra       ReadWriteRangeError ; and exit with error

CheckNextDatBlock   dec       ,s        ; no, check next MMU block until we have checked all we need
                  ENDC
                    bpl       CheckDatBlockLoop ; keep checking DAT blocks through end of buffer
                  IFEQ    H6309
                    puls      a         ; eat temp ctr
                  ENDC
                  ENDC
FMgrDispatchCont    puls      b         ; restore B
                  IFEQ    Level-1
CallFMgr            subb      #$83      ; Level 1: raw I/O call code base is $83
                  ELSE
CallFMgr            subb      #$03      ; Level 2: dispatch pre-normalises to 0-based index
                  ENDC
                    pshs      u,y,x     ; save regs (Y=path dsc ptr)
                    ldx       <D.Proc   ; get caller's process dsc. ptr
WaitPathAvailable
                  IFNE    H6309
                    lde       PD.CPR,y  ; is their a current process using this path?
                  ELSE
                    tst       PD.CPR,y  ; is their a current process using this path?
                  ENDC
                    bne       QueueForPathAccess ; yes, skip ahead
                    lda       P$ID,x    ; no, get process id# of current process
                    sta       PD.CPR,y  ; save it as current process using this path
                    stu       PD.RGS,y  ; save register stack ptr for current process in this path
                    ldx       PD.DEV,y  ; get ptr to device table entry address for this path
                  IFGT    Level-1
                    ldx       V$FMGREX,x ; get file manager execution (branch table) address
                  ELSE
                    ldx       V$FMGR,x  ; get file manager address
                    ldd       M$Exec,x  ; get it's offset to it's execution (branch table)
                    leax      d,x       ; point to it
                  ENDC
                    lda       #3        ; length of lbra instruction (size of each entry in branch table)
                    mul                 ; calc offset to specific file manager function we are calling
                    jsr       b,x       ; call file manager function
FinishFMgrCall      pshs      b,cc      ; preserve return status (C,B) from call
                    bsr       WakeNextIOQueue ; wake up next process in I/O Queue
                    ldy       $04,s     ; get Y off stack
                    ldx       <D.Proc   ; get current process dsc ptr
                    lda       P$ID,x    ; get process id #
                    cmpa      PD.CPR,y  ; same as current process # using this path descriptor?
                    bne       ReturnFMgrStatus ; no, clean up and return
                    clr       PD.CPR,y  ; yes, clear out current process # in path descriptor
ReturnFMgrStatus    puls      pc,u,y,x,b,cc ; return.. with return status in C, B.

* A process is already using current path
QueueForPathAccess  pshs      u,y,x,b   ; save regs
                    lbsr      FIOQu2    ; insert process # in A into I/O Queue
                    puls      u,y,x,b   ; get regs back
                    coma                ; set carry so pending signal returns as error/status
                    lda       <P$Signal,x ; get any impending signal
                    beq       WaitPathAvailable ; none, loop back
                    tfr       a,b       ; move signal code to B
                    bra       FinishFMgrCall ; go back and wake next process in queue

UIGetStt            lbsr      S2UPath   ; get usr path #
                    ldx       <D.Proc   ; get current process dsc. ptr
                    bcc       GetStatusDispatch ; if no error getting user path#, go process
                    rts                 ; return get-status setup error

SIGetStt            lda       R$A,u     ; get path
                  IFGT    Level-1
                    ldx       <D.SysPrc ; get system process ptr
                  ENDC
GetStatusDispatch   pshs      x,d       ; save regs
                    lda       R$B,u     ; get func code
                    sta       1,s       ; place on stack in B
                    puls      a         ; get path off stack
                    lbsr      GtPDClFM  ; get process Descriptor and call file manager
                    puls      x,a       ; get func code in A, sys proc in X
                    pshs      u,y,b,cc  ; save regs (and status/error from GtPDClFM
                    tsta                ; test for SS.Opt status request
                    beq       SSOpt     ; yes, go do
                    cmpa      #SS.DevNm ; get device name?
                    beq       SSDevNm   ; yes, go do
                    puls      pc,u,y,b,cc ; any other call, restore regs & return

SSOpt               equ       *
                  IFGT    Level-1
                    lda       <D.SysTsk ; get system task #
                    ldb       P$Task,x  ; get user task #
                  ENDC
                    leax      <PD.OPT,y ; point to options in path dsc.
SSCopy              ldy       #PD.OPT   ; offset to PD.Opt
                    ldu       R$X,u     ; get callers address to receive Opt packet
                  IFGT    Level-1
                    os9       F$Move    ; move data to caller
                  ELSE
Looper              lda       ,x+       ; copy data to caller
                    sta       ,u+       ; copy option/name byte to caller buffer
                    decb                ; decrement remaining byte count
                    bne       Looper    ; continue local copy until complete
                  ENDC
                    leas      $2,s      ; eat temp stack
                    clrb                ; no error, restore regs & return
                    puls      pc,u,y    ; discard saved status and return success

* Update I/O Queue linked list pointers and wake up next process in I/O Queue
* LCB 6809/6309 note: Since both routines that call this do their own B/Carry
*   handling, remove the CLRB from WakeQueueDone
WakeNextIOQueue     pshs      y         ; save reg
                    ldy       <D.Proc   ; get current process ptr
                    lda       <P$IOQN,y ; get ID# of next process in I/O queue
                    beq       WakeQueueDone ; there is none, return
                    clr       <P$IOQN,y ; else clear it
                    ldb       #S$Wake   ; wake signal
                    os9       F$Send    ; wake up the process that was next in the IO Queue
                  IFGT    Level-1
                    os9       F$GProcP  ; get copy of process descriptor
                  ELSE
                    ldx       <D.PrcDBT ; get ptr to Process descriptor block table
                    os9       F$Find64  ; find path descriptor address for queued process
                  ENDC
                    clr       P$IOQP,y  ; clear it's previous queued process #
WakeQueueDone       clrb                ; report successful queue wake/check
                    puls      pc,y      ; restore Y & return

SSDevNm
                  IFGT    Level-1
                    lda       <D.SysTsk ; get System process task #
                    ldb       P$Task,x  ; get caller's task #
                  ENDC
                  IFEQ    H6309
                    pshs      d         ; save task #'s
                  ENDC
                    ldx       PD.DEV,y  ; get path's device table entry address
                    ldx       V$DESC,x  ; get ptr to device descriptor
                  IFNE    H6309
                    ldw       M$Name,x  ; get offset to descriptor's name
                    addr      w,x       ; point to name of descriptor
                  ELSE
                    ldd       M$Name,x  ; get offset to descriptor's name
                    leax      d,x       ; point to name of descriptor
                    puls      d         ; get the two task #'s back
                  ENDC
                    bra       SSCopy    ; move name to caller and return

UIClose             lbsr      S2UPath   ; get user path #
                    bcs       CloseReturn ; if error, exit with it
                  IFNE    H6309
                    lde       R$A,u     ; get path # from caller
                    adde      #P$Path   ; add offset to paths in process dsc
                    clr       e,x       ; zero path entry
                  ELSE
                    pshs      b         ; save reg
                    ldb       R$A,u     ; get path # from caller
                    addb      #P$Path   ; add offset to paths in process dsc
                    clr       b,x       ; zero path entry
                    puls      b         ; restore reg
                  ENDC
                    bra       CloseSystemPath ; finish I$Close

CloseReturn         rts                 ; return close status

SIClose             lda       R$A,u     ; get callers path #
CloseSystemPath     lbsr      GetPDesc  ; get path dsc
                    bcs       CloseReturn ; if error, return with it
                    dec       PD.CNT,y  ; dec # of open paths
                    tst       PD.CPR,y  ; is there a process currently accessing this path?
                    bne       CloseIfLastPath ; yes, skip ahead
                    lbsr      CallFMgr  ; call CLOSE in the file manager
CloseIfLastPath     tst       PD.CNT,y  ; how many open paths now?
                    bne       CloseReturn ; still some left, return
                    lbra      CleanupPathDesc ; none, Detach the device and return 64 byte path dsc mem to system

* F$IRQ - Add or remove IRQ device from IRQ polling table
FIRQ                ldx       R$X,u     ; get ptr to IRQ packet
                    ldb       ,x        ; b = flip byte
                    ldx       $01,x     ; x = mask/priority
                    clra                ; clear high byte before saving IRQ packet fields
                    pshs      cc        ; save CC with carry clear
                    pshs      x,b       ; save flip, mask, priority bytes
                    ldx       <D.Init   ; get ptr to Init module
                    ldb       PollCnt,x ; get max # of entries in IRQ polling table
                    ldx       <D.PolTbl ; get ptr to I/O polling table
                    ldy       R$X,u     ; get packet address (or remove device) from caller
                    beq       RemoveIrqPollEntry ; x=0 means remove device, go remove it
                    tst       $01,s     ; test mask byte
                    beq       PollTableFullClean ; no bits to trigger, exit with polling table full error
                    decb                ; dec poll table count
                    lda       #POLSIZ   ; calc offset to last possible entry in I/O table
                    mul                 ; compute offset to final polling table slot
                  IFNE    H6309
                    addr      d,x       ; point to last entry in table
                  ELSE
                    leax      d,x       ; point to last entry in table
                  ENDC
                    lda       Q$MASK,x  ; get Mask byte
                    bne       PollTableFullClean ; if any bits set (keep when masked), skip ahead
                    orcc      #IntMasks ; shut off IRQ's
FindIrqInsertSlot   ldb       $02,s     ; get priority byte
                    cmpb      -(POLSIZ-Q$PRTY),x ; compare with prev entry's priority
                    blo       InsertIrqPollEntry ; if lower, skip ahead
                    ldb       #POLSIZ   ; if our priority is higher or same, B=last entry #
ShiftPollEntryDown  lda       ,-x       ; copy previous entry to next entry
                    sta       POLSIZ,x  ; shift one byte into the following polling slot
                    decb                ; until done entire entry
                    bne       ShiftPollEntryDown ; continue shifting one polling entry
                    cmpx      <D.PolTbl ; are we now pointing to the first entry?
                    bhi       FindIrqInsertSlot ; not yet, keep shifting entries down until at start or higher priority
* Insert new entry
InsertIrqPollEntry  ldd       R$D,u     ; get dev stat reg address
                    std       Q$POLL,x  ; save in polling table
                    ldd       ,s++      ; get flip/mask
                    std       Q$FLIP,x  ; save in polling table
                    ldb       ,s+       ; get priority
                    stb       Q$PRTY,x  ; save in polling table
                  IFNE    H6309
                    ldq       R$Y,u     ; get IRQ service routine address & IRQ Static storage ptr
                    stq       Q$SERV,x  ; save them in polling table
                  ELSE
                    ldd       R$Y,u     ; get IRQ svc addr
                    std       Q$SERV,x  ; save in polling table
                    ldd       R$U,u     ; get IRQ static storage ptr
                    std       Q$STAT,x  ; save in polling table
                  ENDC
                    puls      pc,cc     ; no error, turn interrupts back on & return

* Search for device to remove from IRQ polling table
RemoveIrqPollEntry  leas      4,s       ; clean stack
                    ldy       R$U,u     ; get ptr to service routine's static mem ptr
FindIrqPollEntry    cmpy      Q$STAT,x  ; same as static mem ptr we are currently checking against?
                    beq       RemoveIrqPollFound ; yes, found the one to remove (static is unique to each device)
                    leax      POLSIZ,x  ; point to next entry
                    decb                ; are we done all entries?
                    bne       FindIrqPollEntry ; no, keep looking for match
                    clrb                ; done all of them, no match, return w/o error
                    rts                 ; return when no matching polling entry exists

* Remove device from polling table
                  IFNE    H6309
RemoveIrqPollFound  orcc      #IntMasks ; shut off IRQ's
                    decb                ; dec polling table entry #
                    beq       ClearRemovedPoll ; if we are at start, go zero out first entry
                    lda       #POLSIZ   ; otherwise, calc size of all remaining entries combined
                    mul                 ; compute byte count for remaining polling entries
                    tfr       d,w       ; that is size to move
                    leay      POLSIZ,x  ; point to next entry
                    tfm       y+,x+     ; block copy them all up one entry position
ClearRemovedPoll    ldw       #POLSIZ   ; clear out our old entry
                    clr       ,-s       ; create a zero byte for TFM clear
                    tfm       s,x+      ; clear vacated polling table entry
                    leas      $01,s     ; eat temp stack
                    andcc     #^IntMasks ; turn IRQ's on & return
                    rts                 ; return after removing polling entry
                  ELSE
RemoveIrqPollFound  pshs      b,cc      ; save polling table entry # & IRQ status
                    orcc      #IntMasks ; shut off IRQ's
                    bra       CompactPollLoop ; enter 6809 polling-table compaction loop

* Move prev poll entry up one
CompactPollByte     ldb       POLSIZ,x  ; point to our entry+1
                    stb       ,x+       ; copy to our entry
                    deca                ; copy whole polling table entry
                    bne       CompactPollByte ; unti; dpme
CompactPollLoop     lda       #POLSIZ   ; polling table entry size
                    dec       1,s       ; dec count
                    bne       CompactPollByte ; still more to copy, go do
ClearPollEntryLoop  clr       ,x+       ; clear out current entry
                    deca                ; decrement bytes left to clear
                    bne       ClearPollEntryLoop ; continue clearing vacated polling entry
                    puls      pc,a,cc   ; eat temp ctr, turn IRQ's back on & return
                  ENDC

PollTableFullClean  leas      $04,s     ; eat temp stack
PollError           comb                ; exit with Polling Table Full error
                    ldb       #E$Poll   ; return polling table full/not found error
                    rts                 ; return IRQ service error

***************************
* Device polling routine (Pointed to by <D.Poll)
* Entry: None
* NOTE: Could slightly speed up (by 6 cycles) by putting PollCnt from INIT module into
*   an unused DP location, so that we can replace LDX <D.Init/ldb PollCnt,x with ldb <xxxx
*   unless X needs to keep pointing at Init
IRQPoll             ldy       <D.PolTbl ; get pointer to polling table
                    ldx       <D.Init   ; get pointer to init module
                    ldb       PollCnt,x ; get number of entries in table
PollDeviceLoop      lda       [Q$POLL,y] ; get device's status register
                    eora      Q$FLIP,y  ; invert any status bits to 1's for mask that are needed
                    bita      Q$MASK,y  ; any IRQ status bits set?
                    bne       PollServiceDevice ; yes, likely source of IRQ, go process
PollNextDevice      leay      POLSIZ,y  ; else move to next entry
                    decb                ; done checking all entries?
                    bne       PollDeviceLoop ; no, try next one
                    bra       PollError ; iRQ we received not in polling table, exit with Polling Table Full error

* Found source
PollServiceDevice   ldu       Q$STAT,y  ; get device static storage
                    pshs      y,b       ; preserve device # & poll address
                    jsr       [<Q$SERV,y] ; execute service routine
                    puls      y,b       ; restore device # & poll address
                    bcs       PollNextDevice ; go to next device if error
                    rts                 ; return

                  IFGT    Level-1

FNMLoad             pshs      u         ; save caller's regs ptr
                    ldx       R$X,u     ; get ptr to module name
                    lbsr      LoadMod   ; load module (allocates fake proc desc)
                    bcs       RestoreCallerRet ; error, restore U and return with it
                    ldy       ,s        ; get caller's regs ptr in Y
                    stx       R$X,y     ; save ptr to end of module name+1 back to caller
                    ldy       ,u        ; get module DAT image pointer from load context
                    ldx       $04,u     ; get module offset within DAT image
                    ldd       #$0006    ; read module type through revision fields
                    os9       F$LDDDXY  ; load module header bytes from loaded module
                    leay      ,u        ; point Y at load context/module directory data
                    puls      u         ; restore caller register stack pointer
                    bra       ReturnModLinkInfo ; return link information to caller

FNMLink             ldx       <D.Proc   ; get ptr to current process descriptor
                    leay      <P$DATImg,x ; point to its DAT image
                    pshs      u         ; preserve callers register stack ptr
                    ldx       R$X,u     ; get ptr to module name to link
                    lda       R$A,u     ; get type/language byte (each nibble that is 0=wildcard/don't care)
                    os9       F$FModul  ; find module in module directory
                    bcs       RestoreCallerRet ; could not find, exit with error
                    leay      ,u        ; point Y to module directory entry ptr
                    puls      u         ; get caller's register stack ptr back
                    stx       R$X,u     ; save updated name ptr (pointing to end of name+1)
ReturnModLinkInfo   std       R$A,u     ; save type/language (A) & Attribute/Revision (B)
                    ldx       MD$Link,y ; get link count
                    beq       BumpModuleLink ; if 0, go bump it to 1
                    bitb      #ReEnt    ; at least 1, is it reentrant?
                    beq       ModuleBusy ; no, single user and in use, exit with module busy error
BumpModuleLink      leax      1,x       ; increment module link count
                    beq       ReturnModulePointer ; if it wraps 65535 to 0, leave at 65535
                    stx       MD$Link,y ; else save new link count
ReturnModulePointer ldx       MD$MPtr,y ; get module pointer in X
                    ldy       MD$MPDAT,y ; get module DAT image ptr
                    ldd       #$000B    ; offset for either M$Mem (for driver or program) or M$PDev (for descriptor)
                    os9       F$LDDDXY  ; get M$Mem (stack size requirement) or M$PDev (offset to device driver name)
                    bcs       ModuleLinkReturn ; error, exit with it
                    std       R$Y,u     ; save memory requirement into callers Y & return
ModuleLinkReturn    rts                 ; return module link status

ModuleBusy          comb                ; exit with Module Busy error
                    ldb       #E$ModBsy ; report module busy
RestoreCallerRet    puls      pc,u      ; restore caller register stack pointer and return
                  ENDC


FLoad
                  IFGT    Level-1
                    pshs      u         ; place caller's reg ptr on stack
                    ldx       R$X,u     ; get pathname to load
                    bsr       LoadMod   ; allocate a process descriptor
                    bcs       FLoadReturn ; exit if error
                    puls      y         ; get caller's reg ptr into Y
FinishLoadVals      pshs      y         ; preserve y
                    stx       R$X,y     ; save updated pathlist
                    ldy       ,u        ; get DAT image pointer
                    ldx       $04,u     ; get offset within DAT image
                    ldd       #M$Type   ; offset for type/lanugage & attrib/revision
                    os9       F$LDDDXY  ; get language & type
                    ldx       ,s        ; get caller's reg ptr in X
                    std       R$D,x     ; update language/type codes
                    leax      ,u        ; point X at loaded module context
                    os9       F$ELink   ; enter/link loaded module in module directory
                    bcs       FLoadReturn ; return if link failed
                    ldx       ,s        ; get caller's reg ptr in X
                    sty       R$Y,x     ; return module execution entry pointer
                    stu       R$U,x     ; return module pointer
FLoadReturn         puls      pc,u      ; restore caller register stack pointer and return

                  ELSE
                    pshs      u         ; save caller register stack pointer
                    ldx       R$X,u     ; get module pathname
                    bsr       Level1LoadModule ; load/link module using Level 1 path
                    bcs       Level1LoadReturn ; return if load failed
                    inc       $02,u     ; increment link count
                    ldy       ,u        ; get mod header addr
                    ldu       ,s        ; get caller regs
                    stx       R$X,u     ; return updated pathname pointer
                    sty       R$U,u     ; return loaded module pointer
                    lda       M$Type,y  ; get module type/language
                    ldb       M$Revs,y  ; get module attributes/revision
                    std       R$D,u     ; return type and attributes
                    ldd       M$Exec,y  ; get execution offset
                    leax      d,y       ; compute execution entry pointer
                    stx       R$Y,u     ; return execution entry pointer
Level1LoadReturn    puls      pc,u      ; restore caller register stack pointer and return
                  ENDC

                  IFGT    Level-1
IDetach0            pshs      u         ; save off regs ptr
                    ldx       R$X,u     ; get ptr to device name
                    bsr       LoadMod   ; load module named by caller
                    bcs       Detach0Return ; return if load failed
                    puls      y         ; restore caller register stack pointer into Y
                    ldd       <D.Proc   ; get ptr to current process descriptor
                    pshs      y,d       ; save caller registers pointer and current process
                    ldd       R$U,y     ; get caller's process descriptor pointer
                    std       <D.Proc   ; make caller's process current for load completion
                    bsr       FinishLoadVals ; finish load return values
                    puls      x         ; restore saved process descriptor
                    stx       <D.Proc   ; restore current process pointer
Detach0Return       puls      pc,u      ; restore caller register stack pointer and return
                  ENDC

* Load module from file
* Entry: X = pathlist to file containing module(s)
* A fake process descriptor is created, then the file is
* opened and validated into memory.
LoadMod
                  IFGT    Level-1
* Level 2 - load a module
                    os9       F$AllPrc  ; allocate proc desc
                    bcc       LoadModSetup ; no error, continue with Load
                    rts                 ; error; return with it

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
LoadModSetup        leay      ,u        ; point Y at newly allocated mem
                    ldu       #$0000    ; prepare zero word for stack initialization
                    pshs      u,y,x,d   ; save regs
                    leas      <-17,s    ; make 17 byte temp buffer on stack
                    clr       7,s       ; clear saved error/path byte
                    stu       ,s        ; save $0000
                    stu       2,s       ; save $0000
                    ldu       <D.Proc   ; get current proc desc ptr
                    stu       $04,s     ; save onto stack
                    clr       $06,s     ; clear saved path byte before open
                    lda       P$Prior,u ; copy priority from current proc to temp proc
                    sta       P$Prior,y ; copy caller priority into temp process
                    sta       P$Age,y   ; and save as age in temp proc
                    lda       #EXEC.    ; from exec dir
                    os9       I$Open    ; open it
                    lbcs      LoadModCleanup ; branch if error
                    sta       6,s       ; else save path
                    stx       <19,s     ; put updated pathlist in X on stack (end of pathname+1)
                    ldx       <21,s     ; get temp proc desc ptr back
                    os9       F$AllTsk  ; allocate task
                    bcs       LoadModCleanup ; error, go deal with it
                    stx       <D.Proc   ; make temp proc the current proc
LoadNextModule      ldx       <21,s     ; get temp proc desc ptr back
                    lda       P$Prior,x ; get priority
                    adda      #$08      ; add eight
                    bhs       SetLoadPriority ; if that hasn't wrapped 255, use that value for temp task priority
                    lda       #$FF      ; wrapped, force to 255
SetLoadPriority     sta       P$Prior,x ; save new bumped up priority
                    sta       P$Age,x   ; and age
                    ldd       #$0009    ; request room to read module header
                    ldx       2,s       ; get current load buffer pointer
                    lbsr      ReadIntoLoadProcess ; ensure temp process has mapped memory
                    bcs       LoadModCleanup ; clean up if allocation/read failed
                    ldu       <21,s     ; get temp proc dsc ptr
                    lda       P$Task,u  ; get source task #
                    ldb       <D.SysTsk ; destination task # is system task
                    leau      8,s       ; point to where we are copying to
                    pshs      x         ; save X
                    ldx       4,s       ; point to where we are copying from
                    os9       F$Move    ; copy Y bytes from source to dest
                    puls      x         ; restore X
                    ldd       M$ID,u    ; get Module ID check byte ($87CD)
                    cmpd      #M$ID12   ; does it match what it is supposed to be?
                    bne       BadLoadedModHdr ; no, exit with Bad Module ID error
                    ldd       M$Size,u  ; get module size
                    subd      #M$IDSize ; subtract header size
                    lbsr      ReadIntoLoadProcess ; read remaining module body into temp process
                    bcs       LoadModCleanup ; clean up if body read failed
                    ldx       4,s       ; get original caller process descriptor
                    lda       P$Prior,x ; get priority of calling process
                    ldy       <$15,s    ; get new proc desc ptr
                    sta       P$Prior,y ; duplicate priority in new process
                    sta       P$Age,y   ; and set as current age (for queueing)
                    leay      <P$DATImg,y ; point to the DAT image for new process
                    tfr       y,d       ; move ptr to D
                    ldx       2,s       ; get module start pointer for validation
                    os9       F$VModul  ; validate the module (checks header parity & CRC)
                    bcc       AdvanceLoadedModule ; no error, continue
                    cmpb      #E$KwnMod ; incorrect module CRC error?
                    beq       SaveFirstLoadMod ; yes, skip ahead
                    bra       LoadModCleanup ; all other errors skip ahead

AdvanceLoadedModule ldd       2,s       ; get current module load pointer
                    addd      $A,s      ; advance pointer by validated module size
                    std       2,s       ; save pointer for next module scan
* U = mod dir entry
SaveFirstLoadMod    ldd       <$17,s    ; test whether first module directory entry is saved
                    bne       LoadNextModule ; continue loading more modules when already saved
                    ldd       MD$MPtr,u ; get module ptr from module directory entry
                    std       <$11,s    ; save it
                    ldd       [MD$MPDAT,u] ; get block 0 DAT setting
                    std       <$17,s    ; save it
                    ldd       MD$Link,u ; get Module link count from module directory
                  IFNE    H6309
                    incd                ; increase link count
                  ELSE
                    addd      #$0001    ; increase link count
                  ENDC
                    beq       LoadNextModule ; if wrapped to 0, don't update it
                    std       MD$Link,u ; save increased link count
                    bra       LoadNextModule ; continue scanning loaded file for more modules

BadLoadedModHdr     ldb       #E$BMID   ; illegal Module Header error
LoadModCleanup      stb       7,s       ; save cleanup error code
                    ldd       4,s       ; get process desc ptr
                    beq       CloseLoadedPath ; if none, don't change current one
                    std       <D.Proc   ; save as current process desc ptr
CloseLoadedPath     lda       6,s       ; get path used for Load
                    beq       FreeTempBlocks ; if none, skip ahead
                    os9       I$Close   ; close path to file
FreeTempBlocks      ldd       2,s       ; get mem requirement of some sort
                    addd      #$1FFF    ; round up to even 8K boundary
                    lsra                ; divide by 32 (for MMU block # in process space)
                    lsra                ; continue conversion to 8K block count
                    lsra                ; continue conversion to 8K block count
                    lsra                ; continue conversion to 8K block count
                    lsra                ; finish conversion to 8K block count
                    sta       2,s       ; save it
                    ldb       ,s        ; get previous allocation high byte/count
                    beq       DeleteTempProcess ; skip block release when nothing was allocated
                    lsrb                ; divide by 32 (for MMU block # in process space?)
                    lsrb                ; continue previous block-count conversion
                    lsrb                ; continue previous block-count conversion
                    lsrb                ; continue previous block-count conversion
                    lsrb                ; finish previous block-count conversion
                    subb      2,s       ; subtract previous calc, to get # of 8K blocks we are returning to system
                    beq       DeleteTempProcess ; skip block map update when no blocks need release
                    ldx       <$15,s    ; get our temp process descriptor ptr
                    leax      <P$DATImg,x ; point to DAT IMG within it
                    lsla                ; * 2 since bytes per DAT IMG block entry # (2 bytes each)
                    leax      a,x       ; calculate offset
                    leax      1,x       ; point to next byte
                    ldu       <D.BlkMap ; u=ptr to memory block map ptr (what 8K blocks are used, up to 2 MB)
FreeTempBlockLoop   lda       ,x++      ; get MMU Block # from process descriptor
                    clr       a,u       ; flag the block as free in main memory block map
                    decb                ; are we done freeing all the blocks?
                    bne       FreeTempBlockLoop ; no, keep going until done
DeleteTempProcess   ldx       <$15,s    ; get our temp process descriptor ptr back
                    lda       P$ID,x    ; get process ID #
                    os9       F$DelPrc  ; delete the temporary process we used to Load
                    ldd       <$17,s    ; test whether any module directory entry was saved
                    bne       FindLoadedModEnt ; adjust saved module link count if one was loaded
                    ldb       $07,s     ; reload saved cleanup error code
                    stb       <$12,s    ; return error code in saved B slot
                    comb                ; set carry for load failure
                    bra       LoadModReturn ; release loader stack frame and return

FindLoadedModEnt    ldu       <D.ModDir ; get ptr to module directory
                    ldx       <$11,s    ; get ptr to module
                    ldd       <$17,s    ; get block #0
                    leau      -MD$ESize,u ; init current entry ptr to -1 for loop
ScanModuleDirectory leau      MD$ESize,u ; point to next module directory entry
                    cmpu      <D.ModEnd ; have we hit end of module directory?
                    blo       CheckModDirEntry ; no, skip ahead
                    comb                ; didn't find module
                    ldb       #E$MNF    ; module not found error
                    stb       <$12,s    ; save module-not-found error code for return
                    bra       LoadModReturn ; release loader stack frame and return

CheckModDirEntry    cmpx      MD$MPtr,u ; is current module dir entry ptr same as temp one we made?
                    bne       ScanModuleDirectory ; no, skip to next entry
                    cmpd      [MD$MPDAT,u] ; yes, is the MMU block mapped into block 0 of this entry same as temp one we made?
                    bne       ScanModuleDirectory ; no, skip to next entry
                    ldd       MD$Link,u ; yes, Get link counter
                    beq       SaveFoundModEntry ; already 0, skip ahead
                    subd      #$0001    ; <>0, dec by 1
                    std       MD$Link,u ; save back to module directory entry
SaveFoundModEntry   stu       <$17,s    ; save ptr to module directory entry we found match in
                    clrb                ; flag no error
LoadModReturn       leas      <$11,s    ; eat temp stack
                    puls      pc,u,y,x,d ; restore regs & return

ReadIntoLoadProcess pshs      y,x,d     ; save requested byte count and buffer state
                    addd      2,s       ; compute new end address after read
                    std       4,s       ; save updated end address
                    cmpd      8,s       ; compare against mapped high-water mark
                    bls       ReadModuleChunk ; read directly if existing mapping is sufficient
                    addd      #$1FFF    ; round up to even 8K
                    lsra                ; /32 to calculate block # within 64K process space
                    lsra                ; continue conversion to 8K block number
                    lsra                ; continue conversion to 8K block number
                    lsra                ; continue conversion to 8K block number
                    lsra                ; finish conversion to 8K block number
                    cmpa      #$07      ; is it in the last 8K block?
                    bhi       ProcessMemoryFull ; yes, Process Memory Full error
                    ldb       8,s       ; get block # we save earlier
                    lsrb                ; /32 to calculate block # within 64k process space
                    lsrb                ; continue old block number calculation
                    lsrb                ; continue old block number calculation
                    lsrb                ; continue old block number calculation
                    lsrb                ; finish old block number calculation
                  IFNE    H6309
                    subr      b,a       ; calc start block # within 64k process space
                    lslb                ; *2 for 2 bytes/per entry in DAT image
                    exg       b,a       ; place DAT entry offset in A and block count in B
                  ELSE
                    pshs      b         ; save previous high-water block number
                    exg       b,a       ; move new high-water block number into B
                    subb      ,s+       ; calc start block # within 64k process space
                    lsla                ; *2 for 2 bytes/per entry in DAT image
                  ENDC
                    ldu       <$1D,s    ; get ptr to our temp process descriptor
                    leau      <P$DATImg,u ; point to DAT Image within it
                    leau      a,u       ; point to specific MMU block entry within it
                    clra                ; clear high byte of DAT block number
                  IFNE    H6309
                    tfr       b,f       ; # of 8K blocks we will need to allocate in our process
                  ELSE
                    tfr       d,x       ; # of 8K blocks we will need to allocate in our process
                  ENDC
                    ldy       <D.BlkMap ; get ptr to main memory block table
                    clrb                ; d=0 now (DAT IMG block #)
FindFreeBlockLoop   tst       ,y+       ; scan main memory block until we find unused entry
                    beq       AllocateFreeBlock ; found unallocated block, skip ahead
NextMemoryBlock     equ       *
                  IFNE    H6309
                    incd                ; bump up DAT IMG MMU Block #
                  ELSE
                    addd      #$0001    ; advance to next physical DAT block number
                  ENDC
                    cmpy      <D.BlkMap+2 ; have we hit end of memory block map?
                    bne       FindFreeBlockLoop ; no, keep checking.
ProcessMemoryFull   comb                ; couldn't find free RAM, exit with Process RAM full
                    ldb       #E$MemFul ; return process memory full error
                    bra       ReadChunkReturn ; unwind helper stack and return

* unused MMU block found
AllocateFreeBlock   inc       -1,y      ; flag unused block as RAM IN USE
                    std       ,u++      ; save block # in process' DAT IMG
                  IFNE    H6309
                    lde       8,s       ; get current high-water address byte
                    adde      #$20      ; ? i think add 8K (high byte) to ???
                    ste       8,s       ; save updated high-water address byte
                    decf                ; dec # of 8K blocks left we need to allocate for temp process
                  ELSE
                    pshs      a         ; preserve DAT block high byte
                    lda       9,s       ; get current high-water address byte
                    adda      #$20      ; ? i think add 8K (high byte) to ???
                    sta       9,s       ; save updated high-water address byte
                    puls      a         ; restore DAT block high byte
                    leax      -1,x      ; dec # of 8K blocks left we need to allocate for temp process
                  ENDC
                    bne       NextMemoryBlock ; still more blocks to allocate, keep going
                    ldx       <$1D,s    ; get ptr to our temp process descriptor
                    os9       F$SetTsk  ; set the DAT registers to what the process DAT image says
                    bcs       ReadChunkReturn ; if error, exit with it
* We have memory allocated in our temp process to load the module, so now load it
ReadModuleChunk     lda       $0E,s     ; get temp file path #
                    ldx       2,s       ; get Ptr to buffer we are reading into
                    ldy       ,s        ; get size of buffer to read
                    os9       I$Read    ; read it in & return
ReadChunkReturn     leas      4,s       ; discard helper temporaries
                    puls      pc,x      ; restore X and return helper status

                  ELSE
* Level 1 load module
* Entry: X=Ptr to module name to load
* Temp 10 byte stack (starts @ 6,s since x,y,u saved on stack right after temp buffer allocated):
* 6,s=path # to module file
* 7-15,s=9 byte buffer for module header
Level1LoadModule    lda       #EXEC.    ; we want executable modules only
                    os9       I$Open    ; open the module
                    bcs       Level1LoadDone ; error, return with it
                    leas      -10,s     ; temp buffer on stack
                    ldu       #$0000    ; clear loaded-module pointer sentinel
                    pshs      u,y,x     ; save regs
                    sta       6,s       ; save path
L1ReadNextModule    ldd       4,s       ; get ptr to callers registers
                    bne       Level1ReadHeader ; there is a ptr, skip ahead
                    stu       4,s       ; save 0 on stack
Level1ReadHeader    lda       6,s       ; get path
                    leax      7,s       ; point to place on stack
                    ldy       #M$IDSize ; read module header from file
                    os9       I$Read    ; read module header into stack buffer
                    bcs       Level1LoadCleanup ; error; close file & report error
                    ldd       ,x        ; get 1st 2 bytes of module
                    cmpd      #M$ID12   ; proper module header ID code?
                    bne       BadModuleHeader ; no, report Illegal Module header
                    ldd       9,s       ; get module size from module header
                    os9       F$SRqMem  ; request that much RAM from system
                    bcs       Level1LoadCleanup ; couldn't, close file & report error
                    ldb       #M$IDSize ; copy module header to our newly allocated memory
CopyModHdrLoop      lda       ,x+       ; copy next header byte from stack buffer
                    sta       ,u+       ; store header byte in allocated module memory
                    decb                ; decrement header byte count
                    bne       CopyModHdrLoop ; continue until full header is copied
                    lda       6,s       ; get file path
                    leax      ,u        ; point X to our new memory,just past module header
                    ldu       9,s       ; get module size
                    leay      -M$IDSize,u ; we already read header, so subtract size of header
                    os9       I$Read    ; read the rest of the module
                    leax      -M$IDSize,x ; point to start of entire module
                    bcs       Level1LoadReadError ; if there was an error
                    os9       F$VModul  ; validate the module header & CRC
                    bcc       L1ReadNextModule ; no error, see if more modules specified?
Level1LoadReadError pshs      u,b       ; error with Read, save regs
                    leau      ,x        ; point U at memory allocated
                    ldd       M$Size,x  ; size of memory we allocated
                    os9       F$SRtMem  ; return mem to system
                    puls      u,b       ; get regs back
                    cmpb      #E$KwnMod ; was a module with this name already loaded?
                    beq       L1ReadNextModule ; yes, skip to check next one (if any)
                    bra       Level1LoadCleanup ; any other error, close file & report error

BadModuleHeader     ldb       #E$BMID   ; illegal module header error
Level1LoadCleanup   puls      u,y,x     ; restore regs
                    lda       ,s        ; get file path #
                    stb       ,s        ; save error code
                    os9       I$Close   ; close the file
                    ldb       ,s        ; get error code back
                    leas      10,s      ; clear up stack
                    cmpu      #$0000    ; test whether any module was loaded successfully
                    bne       Level1LoadDone ; return success if loaded-module pointer is nonzero
                    coma                ; set carry when no module was loaded
Level1LoadDone      rts                 ; return Level 1 load status

                  ENDC

********************************
*
* F$PErr System call entry point
*
* Entry: U = Register stack pointer
*


ErrHead             fcc       /ERROR #/
ErrNum              equ       *-ErrHead
                    fcb       $2F,$3A,$30 ; inited dummy data set up to generate decimal error code
                    fcb       C$CR
ErrMessL            equ       *-ErrHead

FPErr               ldx       <D.Proc   ; get current process pointer
                    lda       <P$Path+2,x ; get stderr path
                    beq       CommonReturn ; return if not there
                    leas      -ErrMessL,s ; make room on stack
* copy error message to stack
                    leax      <ErrHead,pcr ; point to error text
                    leay      ,s        ; point to buffer
CopyErrMsgLoop      lda       ,x+       ; get a byte
                    sta       ,y+       ; store a byte
                    cmpa      #C$CR     ; done?
                    bne       CopyErrMsgLoop ; no, keep going
                    ldb       R$B,u     ; get error #
* Convert error code to decimal
ConvErrHundreds     inc       ErrNum,s  ; inc hundreds digit
                    subb      #100      ; sub 100 from error #
                    bcc       ConvErrHundreds ; didn't wrap, do another 100
ConvertErrorTens    dec       ErrNum+1,s ; drop 10's digit
                    addb      #10       ; add 10
                    bcc       ConvertErrorTens ; didn't wrap, keep doing 10's
                    addb      #$30      ; aSCII-fy the 1's digit
                    stb       ErrNum+2,s ; save 1's digit
                  IFGT    Level-1
* Level 2/3
                    ldx       <D.Proc   ; get current process pointer
                    ldu       P$SP,x    ; get process' stack pointer
                    leau      -ErrMessL,u ; put a buffer in it to hold error message
                    lda       <D.SysTsk ; get system task number
                    ldb       P$Task,x  ; get task number of process
                    leax      ,s        ; point to error text
                    ldy       #ErrMessL ; get length of text
MoveErrorToProcess  os9       F$Move    ; copy error message into process' buffer (on it's stack)
                    leax      ,u        ; point to the moved text
                    ldu       <D.Proc   ; get current process pointer
                    lda       <P$Path+2,u ; get it's error path number
                    os9       I$WritLn  ; write the text
                    leas      ErrMessL,s ; purge the temp error string buffer
                  ELSE
* Level 1
* 6809/6309 - This ldx is useless - X is immediately reloaded, and U gets D.Proc
*         ldx   <D.Proc        Get process descriptor
                    leax      ,s        ; point to error message
                    ldu       <D.Proc   ; get ptr to process descriptor
                    lda       <P$Path+2,u ; get Error path #
                    os9       I$WritLn  ; write message
                    leas      ErrMessL,s ; fix up stack
                  ENDC
CommonReturn        rts                 ; return

* F$IOQu - entry point for system call (insert process # in A into current
*  processes I/O Queue, and puts 'A' to sleep
* Entry: U=Callers register stack ptr
* Note: This is a linked list (with each process descriptor containing process #'s
*   for both the next entry (P$IOQN) and the previous entry (P$IOQP).
FIOQu
                  IFNE    H6309
                    lde       R$A,u     ; get process # we are inserting ourself into it's IO Queue
                  ENDC
* F$IOQu - entry point for direct call from within IOMAN
FIOQu2              ldy       <D.Proc   ; get current process descriptor
                  IFNE    H6309
                    clrf                ; i think W=process descriptor ptr?
                  ENDC
FindQueuedProcLoop  lda       <P$IOQN,y ; get next I/O Queue link #
                    beq       InsertQueueProcess ; none, skip ahead
                  IFNE    H6309
                    cmpr      e,a       ; same process # as requested?
                  ELSE
                    cmpa      R$A,u     ; same process # as requested?
                  ENDC
                    bne       AdvanceQueueSearch ; no, skip ahead
                  IFNE    H6309
                    stf       <P$IOQN,y ; yes, clear I/O Queue next link
                  ELSE
                    clr       <P$IOQN,y ; yes, clear I/O Queue next link
                  ENDC
                  IFGT    Level-1
                    os9       F$GProcP  ; get ptr to process descriptor for process # in A
                  ELSE
                    ldx       <D.PrcDBT ; get ptr to Process Descriptor Block table
                    os9       F$Find64  ; get the ptr to 64 byte process descriptor for level 1 (into Y)
                  ENDC
                    bcs       CommonReturn ; error, return with it
                  IFNE    H6309
                    stf       P$IOQP,y  ; save in previous I/O Queue
                  ELSE
                    clr       P$IOQP,y  ; save in previous I/O Queue
                  ENDC
                    ldb       #S$Wake   ; send a wake signal to process # in A
                    os9       F$Send    ; wake the duplicate queued process
                    ldu       <D.Proc   ; get current process descriptor ptr
                    bra       QueueInsertScan ; re-enter insertion scan with current process
AdvanceQueueSearch
                  IFGT    Level-1
                    os9       F$GProcP  ; get process descriptor ptr
                  ELSE
                    ldx       <D.PrcDBT ; get ptr to process descriptor block table
                    os9       F$Find64  ; find our particular ptr
                  ENDC
                    bcc       FindQueuedProcLoop ; no error, continue updating linked list
InsertQueueProcess
                  IFNE    H6309
                    tfr       e,a       ; a=process #
                  ELSE
                    lda       R$A,u     ; a=process #
                  ENDC
                    ldu       <D.Proc   ; get current process dsc ptr into U
                  IFGT    Level-1
                    os9       F$GProcP  ; get process descriptor ptr
                  ELSE
                    ldx       <D.PrcDBT ; get process descriptor block table ptr
                    os9       F$Find64  ; get process descriptor ptr
                  ENDC
                    bcs       IOQueueReturn ; if error, skip ahead
QueueInsertScan     leax      ,y        ; point X to process descriptor
                    lda       <P$IOQN,y ; get I/O Queue process # for next one in linked list
                    beq       SleepQueuedProcess ; none (end of list), skip ahead
                  IFGT    Level-1
                    os9       F$GProcP  ; get process descriptor ptr to next process in linked list
                  ELSE
                    ldx       <D.PrcDBT ; get process descriptor block table ptr
                    os9       F$Find64  ; get process descriptor ptr to next process in linked list
                  ENDC
                    bcs       IOQueueReturn ; error, skip ahead
                    ldb       P$Age,u   ; get I/O queue age in current process
                    cmpb      P$Age,y   ; compare with age of process that we are checking against
                    bls       QueueInsertScan ; if <=, don't change anything, continue down linked list
                    ldb       ,u        ; get P$ID (process ID #)
                    stb       <P$IOQN,x ; save as next in linked list in current process descriptor
                    ldb       ,x        ; get P$ID (process ID #) from current process descriptor
                    stb       P$IOQP,u  ; save as I/O Queue Previous link in linked list
                  IFNE    H6309
                    stf       P$IOQP,y  ; clear out previous link in other process descriptor
                  ELSE
                    clr       P$IOQP,y  ; clear out previous link in other process descriptor
                  ENDC
                    exg       y,u       ; swap process descriptor pointers
                    bra       QueueInsertScan ; keep updating linked list

SleepQueuedProcess  lda       ,u        ; get P$ID (process ID #) for U process descriptor
                    sta       <P$IOQN,y ; save as I/O Queue Next entry in Y process descriptor
                    lda       ,y        ; get P$ID (process #) from Y process descriptor
                    sta       P$IOQP,u  ; save as I/O Queue Previous entry in U process descriptor
                    ldx       #$0000    ; sleep remainder of tick
                    os9       F$Sleep   ; sleep current process after queue insertion
                    ldu       <D.Proc   ; reload current process descriptor after wake
                    lda       P$IOQP,u  ; get previous queue link
                    beq       IOQueueReturn ; return if process is no longer queued
                  IFGT    Level-1
                    os9       F$GProcP  ; get process descriptor ptr to next process in linked list
                  ELSE
                    ldx       <D.PrcDBT ; get process descriptor block table ptr
                    os9       F$Find64  ; get process descriptor ptr to next process in linked list
                  ENDC
                    bcs       ClearCurQueuePrev ; clear local queue links if previous descriptor is unavailable
                    lda       <P$IOQN,y ; get previous process next link
                    beq       ClearCurQueuePrev ; skip relink if previous process has no next link
                    lda       <P$IOQN,u ; get this process next link
                    sta       <P$IOQN,y ; splice this process out of previous next link
                    beq       ClearCurQueuePrev ; skip next-process fixup if this was queue tail
                  IFNE    H6309
                    stf       <P$IOQN,u ; clear this process next link
                  ELSE
                    clr       <P$IOQN,u ; clear this process next link
                  ENDC
                  IFGT    Level-1
                    os9       F$GProcP  ; get descriptor for next queued process
                  ELSE
                    ldx       <D.PrcDBT ; get process descriptor block table
                    os9       F$Find64  ; find descriptor for next queued process
                  ENDC
                    bcs       ClearCurQueuePrev ; skip next-link fixup if descriptor lookup fails
                    lda       P$IOQP,u  ; get this process previous queue link
                    sta       P$IOQP,y  ; store it as next process previous link
ClearCurQueuePrev
                  IFNE    H6309
                    stf       P$IOQP,u  ; clear this process previous link
                  ELSE
                    clr       P$IOQP,u  ; clear this process previous link
                  ENDC
IOQueueReturn       rts                 ; return I/O queue status

                    emod
eom                 equ       *
                    end

                    ENDC
