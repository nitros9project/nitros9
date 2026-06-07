********************************************************************
* krnp2 - NitrOS-9 Level 1 Kernel Part 2
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  11      2013/05/29  Boisy G. Pitre
* F$Debug now incorporated, allows for reboot.

                    nam       krnp2
                    ttl       NitrOS-9 Level 1 Kernel Part 2

                    use       defsfile  ; include source file defsfile

tylg                set       Systm+Objct ; define assembler symbol
atrv                set       ReEnt+rev ; define assembler symbol
rev                 set       $00       ; define assembler symbol
edition             set       11        ; define assembler symbol

                    mod       eom,name,tylg,atrv,start,size ; define OS-9 module header

size                equ       .         ; define assembler symbol

name                fcs       /KrnP2/
                    fcb       edition   ; define byte value(s) edition

SvcTbl              fcb       $7F       ; define byte value(s) $7F
                    fdb       IOCall-*-2 ; define word value(s) IOCall-*-2
                    fcb       F$Unlink  ; define byte value(s) F$Unlink
                    fdb       FUnlink-*-2 ; define word value(s) FUnlink-*-2
                    fcb       F$Wait    ; define byte value(s) F$Wait
                    fdb       FWait-*-2 ; define word value(s) FWait-*-2
                    fcb       F$Exit    ; define byte value(s) F$Exit
                    fdb       FExit-*-2 ; define word value(s) FExit-*-2
                    fcb       F$Mem     ; define byte value(s) F$Mem
                    fdb       FMem-*-2  ; define word value(s) FMem-*-2
                    fcb       F$Send    ; define byte value(s) F$Send
                    fdb       FSend-*-2 ; define word value(s) FSend-*-2
                    fcb       F$Sleep   ; define byte value(s) F$Sleep
                    fdb       FSleep-*-2 ; define word value(s) FSleep-*-2
                    fcb       F$Icpt    ; define byte value(s) F$Icpt
                    fdb       FIcpt-*-2 ; define word value(s) FIcpt-*-2
                    fcb       F$ID      ; define byte value(s) F$ID
                    fdb       FID-*-2   ; define word value(s) FID-*-2
                    fcb       F$SPrior  ; define byte value(s) F$SPrior
                    fdb       FSPrior-*-2 ; define word value(s) FSPrior-*-2
                    fcb       F$SSwi    ; define byte value(s) F$SSwi
                    fdb       FSSwi-*-2 ; define word value(s) FSSwi-*-2
                    fcb       F$STime   ; define byte value(s) F$STime
                    fdb       FSTime-*-2 ; define word value(s) FSTime-*-2
                    fcb       F$Find64+$80 ; define byte value(s) F$Find64+$80
                    fdb       FFind64-*-2 ; define word value(s) FFind64-*-2
                    fcb       F$All64+$80 ; define byte value(s) F$All64+$80
                    fdb       FAll64-*-2 ; define word value(s) FAll64-*-2
                    fcb       F$Ret64+$80 ; define byte value(s) F$Ret64+$80
                    fdb       FRet64-*-2 ; define word value(s) FRet64-*-2
                  IFNE    UseFDebug ; begin conditional assembly for UseFDebug
                    fcb       F$Debug   ; define byte value(s) F$Debug
                    fdb       FDebug-*-2 ; define word value(s) FDebug-*-2
                  ENDC

                    fcb       $80       ; define byte value(s) $80

start               equ       *         ; define assembler symbol
* Install system calls.
                    leay      SvcTbl,pcr ; point to the system call table
                    os9       F$SSvc    ; install the system calls
* Allocate a process descriptor for the initial process.
                    ldx       <D.PrcDBT ; get process descriptor table in X
                    os9       F$All64   ; allocate a new 64 byte page
                    bcs       FatalErr  ; failed to allocate
                    stx       <D.PrcDBT ; save off
                    sty       <D.Proc   ; save off new process descriptor pointer
                    tfr       s,d       ; transfer the stack pointer to D
                    deca                ; set address to 1 minus stack's MSB
                    ldb       #$01      ; set page count to 1 (256 bytes)
                    std       P$ADDR,y  ; save off in P$ADDR and P$PagCnt
                    lda       #SysState ; get system state flag
                    sta       P$State,y ; set the state in the process descriptor
                    ldu       <D.Init   ; get init module address in U

* ChdDir should identify system device, result in a call to IOCall which links and
* initializes IOMan. This could fail if IOMan is not loaded.
                    bsr       ChdDir    ; attempt to change directories
                    bcc       open@     ; success
* Maybe we failed because we didn't have all the modules we needed? Load and
* validate the boot file and then try again.
                    lbsr      LoadBoot  ; else attempt to load bootfile
                    bsr       ChdDir    ; then try to change directories again
open@               bsr       OpenCons  ; try to open the console
                    bcc       ChainProg ; branch if successful

* Maybe we were able to get this far without needing anything from the boot file, but now
* we need it for the console device.
                    lbsr      LoadBoot  ; else attempt to load bootfile
                    bsr       OpenCons  ; try to open the console again
                    bcc       ChainProg ; branch if carry is clear to ChainProg
forever@            bra       forever@  ; branch unconditionally to forever@

* Hmm. No check for success. Probably should "bcs fatalerr" here?

ChainProg           ldd       InitStr,u ; get the offset to the 'GO' program from the Init module
                    leax      d,u       ; point X to the address of the name
                    lda       #Objct    ; object code
                    clrb                ; no optional data area needed
                    ldy       #$0000    ; no parameter area needed
                    os9       F$Chain   ; chain to it
FatalErr            jmp       [$FFFE]   ; jump to the RESET vector

* Change the directory.
* Entry: U = The address of the Init module.
ChdDir              clrb                ; clear carry
                    ldd       <SysStr,u ; get system device
                    beq       ex@       ; branch if none - carry still clear
                    leax      d,u       ; address of the path list
                    lda       #READ.+EXEC. ; access mode
                    os9       I$ChgDir  ; change directory to it
ex@                 rts                 ; carry set -> error

* Open the console device.
* Entry: U = The address of the Init module
OpenCons            clrb                ; clear B
                    ldd       <StdStr,u ; get the offset to the console device in the Init module
                    leax      d,u       ; point X to the address of the name
                    lda       #UPDAT.   ; open for update
                    os9       I$Open    ; open it
                    bcs       ex@       ; branch if error
                    ldx       <D.Proc   ; get process descriptor
                    sta       P$Path+0,x ; save path to console to stdin...
                    os9       I$Dup     ; duplicate it
                    sta       P$Path+1,x ; ...stdout
                    os9       I$Dup     ; duplicate it
                    sta       P$Path+2,x ; ...and stderr
ex@                 rts                 ; return to the caller


                    use       funlink.asm ; include source file funlink.asm
                    use       fwait.asm ; include source file fwait.asm
                    use       fexit.asm ; include source file fexit.asm
                    use       fmem.asm  ; include source file fmem.asm
                    use       fsend.asm ; include source file fsend.asm
                    use       fsleep.asm ; include source file fsleep.asm
                    use       ficpt.asm ; include source file ficpt.asm
                    use       fsprior.asm ; include source file fsprior.asm
                    use       fid.asm   ; include source file fid.asm
                    use       fsswi.asm ; include source file fsswi.asm
                    use       fstime.asm ; include source file fstime.asm
                    use       ffind64.asm ; include source file ffind64.asm
                    use       fall64.asm ; include source file fall64.asm
                    use       fret64.asm ; include source file fret64.asm
                    use       iocall.asm ; include source file iocall.asm


* Attempt to load bootfile and validate the modules it contains.
*
* Entry: U = The address of the Init module.
*
* Exit:
*
* CC Carry set on Error
LoadBoot            pshs      u         ; save off the init module address
                    comb                ; set the carry in anticipation of any errors
                    tst       <D.Boot   ; already booted?
                    bne       JmpBtEr   ; yep, return to caller...
                    inc       <D.Boot   ; else set boot flag
                    ldd       <BootStr,u ; get pointer to boot str
                    beq       JmpBtEr   ; if none, return to caller
                    leax      d,u       ; X = ptr to boot mod name
                    lda       #Systm+Objct ; it's a system/object module
                    os9       F$Link    ; link
                    bcs       JmpBtEr   ; return if error
                    jsr       ,y        ; ...else jsr into boot module
* D = Size of the loaded bootfile.
* X = Address of the loaded bootfile.
                    bcs       JmpBtEr   ; return if error
                    stx       <D.MLIM   ; else save off to the memory low limit
                    stx       <D.BTLO   ; and the bootfile low address
                    leau      d,x       ; advance 'D' bytes
                    stu       <D.BTHI   ; and save the bootfile high address
* Search through bootfile and validate modules.
ValBoot             ldd       ,x        ; grab the first two bytes
                    cmpd      #M$ID12   ; are they the module sync bytes?
                    bne       ValBoot1  ; branch if not
                    os9       F$VModul  ; else validate the module
                    bcs       ValBoot1  ; and branch if error
                    ldd       M$Size,x  ; get module size
                    leax      d,x       ; move X to next module
                    bra       ValBoot2  ; verify that we're not in the kernel area
ValBoot1            leax      1,x       ; advance one byte
ValBoot2            cmpx      <D.BTHI   ; are we less that the high mark of the bootfile?
                    bcs       ValBoot   ; branch if we are
JmpBtEr             puls      pc,u      ; retore register and return to caller


                  IFNE    UseFDebug ; begin conditional assembly for UseFDebug
                    use       fdebug.asm ; include source file fdebug.asm
                  ENDC

                    emod
eom                 equ       *         ; define assembler symbol
