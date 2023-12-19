********************************************************************
* krnp2 - NitrOS-9 Level 2 Kernel Part 2
*
* $Id$
*
* Copyright (c) 1982 Microware Corporation
*
* Modified for 6309 Native mode by:
*
* Bill Nobel, L. Curtis Boyle & Wes Gale - Gale Force Enterprises
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*
* 17.2   08/02/92 - Active in 6309 Native mode, No apparent bugs (BN)
*                 - Optimized F$Fork (BN)
*                 - Optimized F$Chain (BN)
* 18.4   92/12/15 - Cut initial memory allocation routine - unnecessary
* 18.5   93/01/18 - Fixed bug in F$Sleep (LCB)
*                 - Optimized F$All64 to use tfm (BN)
* NitrOS9 V1.09 - Move & optimized F$CpyMem to OS9P1
* V1.10  93/05/23 - Slight opt to UnLink
* V1.11  93/07/26 - Slight opt in F$Icpt
*                 - Slight opt in F$Wait alarm clearing
*                 - Slight opt to speed up path table full errors
*                 - Changed LBEQ to BEQ in F$Unlink
* V1.16  93/09/03 - Moved F$SUser to OS9P1 (WG)
*        93/09/08 - Moved F$SUser back to OS9P2 for room in OS9P1 (LCB)
*        93/09/10 - F$Find64 (L0A50) - Took out BSR to L0A5C, merged routine
*                   in (only called from here), and took out PSHS/PULS D
*                   Also modified error structure a bit to shorten it
*        93/10/06 - Added conditional assembly to skip Network I/O ptrs since
*                   Coco network never released by Tandy/Microware (in F$Fork)
*                 - @ GotNProc (in F$Fork), saved 1 byte/cycle when inheriting
*                   User # & priority
*                 - Changed routine @ L01FB to use U instead of Y (slightly
*                   smaller & slightly faster), and also used CLRB with STB
*                   instead of CLR for clearing DAT block #'s (F$UnLink)
*        93/12/17 - Moved F$CRCMod code here to give some room in OS9P1
*        94/05/15 - Attempted opts in Unlink: Changed usage of W to D @ L0185
*                   and L0198 and L01B5, also optimized L017C to eliminate a
*                   branch (speeds up module dir search by 3 cycles/module
*                   checked)
*                 - Changed BRA L032F @ L02EC (AllProc error) to RTS
*                 - Changed BRA L0629 @ L05DF to RTS
*                 - Changed L066A & L067B from BRA L06F4 to PULS CC,A,Y,U,PC
*                   (F$Send errors)
*                 - Changed L0A2B from BRA L0A4F to RTS (F$UnLoad error)
*                 - Changed L0C53 & L0C81 BRA L0C93 to CLRB/RTS (F$GCMDir)
* -- Alan DeKok
*        94/10/28 - added boot debug calls
*                 - Changed code at ~L0D47 to allow F$Fork/F$Chain of Obj6309
*        94/10/30 - Added error checking on F$Fork of CC3Go
*                 - Minor mods to F$SSWI call
*                 - Minor mods to F$STime
*                 - Changed F$GModDr to BRA to similar code in F$GBlkMp
*
*  18r6  Back-ported to OS-9 Level Two from NitrOS-9 Level Two
*
*  18r7    2004/06/18  Boisy G. Pitre
* Kernel no longer attempts a reboot when failing to open term device, but
* crashes upon error.
*
*  19      2013/05/29  Boisy G. Pitre
* F$Debug now incorporated, allows for reboot.
*
*  20      2019/12/08-25  L. Curtis Boyle
* Krn/KrnP2 6809: Moved F$CpyMem code back into KRN, and direct calls to Move,
*   ala 6309 version (several times faster)
* 6809: Optimized F$Chain- speed up copying Process descriptor data (saves
*    saves 750 cycles)
* 6809: Optimized F$AllPrc- speed up clearing Process descriptor data (saves
*    350 cycles
* 6809/6309: Shrunk/sped up REBOOT copy code loop

                    nam       krnp2
                    ttl       NitrOS-9 Level 2 Kernel Part 2

** If Network I/O ptrs are disabled, F$Fork runs 72 cycles faster
Network             equ       0                   Set to 1 to enable network I/O ptrs

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

TC9                 set       false               "true" use TC-9 6309 trap vector
Edition             equ       20
Revision            equ       0

                    mod       eom,MName,Systm,ReEnt+Revision,krnp2,$0100

MName               fcs       /KrnP2/
                    fcb       Edition

                    ifeq      TC9-1
* Entry: None
* Exit : Process killed & register dump produced for user
Trap                bitmd     #%01000000          illegal instruction?
                    bne       BadIns              yes, go process
                    bitmd     #%10000000          division by 0?
                    bne       Div0                yes, go process
                    jmp       [<D.XSWI]           act as if nothing happened

* Process illegal instruction trap
BadIns              bsr       SetProc             move the register stack here
                    ldb       #18                 get error code for F$Exit
                    bra       TrapDone

* Process division by 0 trap
Div0                bsr       SetProc             move the register stack
                    ldb       #45                 get error code for F$Exit
* Return to system after the trap
* Entry: B=Error code
*        U=Pointer to register stack
TrapDone            stb       R$B,u               save the error code to register stack for F$Exit
                    lbra      FExit               enter F$Exit directly

* Set process to system state & copy register stack for trap processing
SetProc             ldd       <D.SysSvc           set system call processor to system side
                    std       <D.XSWI2
                    ldd       <D.SysIRQ           do the same thing for IRQ's
                    std       <D.XIRQ
                    ldx       <D.Proc             get current process pointer
                    ifne      H6309
                    oim       #SysState,P$State,x mark process as system state
                    else
                    ldb       P$State,x
                    orb       #SysState
                    stb       P$State,x
                    endc
* copy register stack to process descriptor
                    sts       P$SP,x              save stack pointer
                    leas      (P$Stack-R$Size),x  point S to register stack destination
                    andcc     #^IntMasks          force interrupts back on
                    leau      ,s                  point to destination register stack
                    ldb       P$Task,x            get task # of destination
                    ldx       P$SP,x              get the user/system stack pointer
                    pshs      b                   preserve task for a moment
                    tfr       x,d                 copy it for easier calcs
                    bita      #%11100000          offset above block 0?
                    beq       done                yes, no calc needed get out
                    anda      #%00011111          make it a offset within a block
                    tfr       d,x                 copy new offset
                    lsra                          make A an offset into DAT image
                    lsra
                    lsra
                    lsra
done                puls      b                   restore task #
                    leax      -$6000,x            make it a pointer to where I'll map the block
                    tfr       u,y
                    pshs      cc,u                preserve IRQ status & dest pointer
                    ldu       <D.TskIPt
                    lslb                          adjust task # to fit table
                    ldu       b,u                 get the DAT image pointer
                    leau      a,u                 point to the blocks needed
                    lda       1,u                 get 1st block
                    ldb       3,u                 get a second in case of overlap
                    orcc      #IntMasks           shut IRQ's down
                    std       >DAT.Regs+5         map in the blocks
                    ifne      H6309
                    ldw       #R$Size             get size of register stack
                    tfm       x+,y+               move 'em to process descriptor
                    else
                    ldb       #R$Size
Uday                lda       ,x+
                    sta       ,y+
                    decb
                    bne       Uday
                    endc
                    ldx       <D.SysDAT           get the system DAT image pointer
                    lda       $0B,x               get the original blocks
                    ldb       $0D,x
                    std       >DAT.Regs+5         map 'em back in
                    puls      cc,u,pc             restore IRQ's, register stack pointer & return
                    endc

krnp2               lda       #'2                 debug: signal that we made it into krnp2
                    jsr       <D.BtBug
                    ifne      H6309
                    leay      <SvcTab,pc          install system calls
                    else
                    leay      SvcTab,pc           install system calls
                    endc
                    os9       F$SSvc
                    ifeq      TC9-1
                    leax      Trap,pc
                    stx       <D.SWI
                    endc
* Change to default directory
L003A               ldu       <D.Init             get init module pointer
                    ldd       SysStr,u            get pointer to system device name (usually '/DD')
                    beq       L004F               don't exist, open std device
                    leax      d,u                 point to name
                    lda       #'x                 debug: signal that we tried chd'ing
                    jsr       <D.BtBug
                    lda       #(EXEC.+READ.)      get file mode
                    os9       I$ChgDir            change to it
                    bcc       L004F               went ok, go on
                    os9       F$Boot              try & load boot file
                    bcc       L003A               go try again
L004F               ldu       <D.Init             get init module pointer
                    ldd       <StdStr,u           point to default device (usually '/Term')
                    beq       L0077               don't exist go do OS9P3
                    leax      d,u                 point to it
                    lda       #'o                 debug: signal that we tried opening output window
                    jsr       <D.BtBug
                    lda       #UPDAT.             get file mode
                    os9       I$Open              open path to it
                    bcc       L0066               went ok, save path #
* LCB - not sure why this is remarked out and replaced with NOP's?
*         os9    F$Boot      try & re-boot
* nop
* nop
* nop
*         bcc    L004F       go try again
* nop
* nop
                    bra       L009B               crash machine

L0066               ldx       <D.Proc             get current process pointer
                    sta       <P$Path,x           save stdin path
                    os9       I$Dup               dupe it
                    sta       <P$Path+1,x         save stdout path
                    os9       I$Dup               dupe it again
                    sta       <P$Path+2,x         save stderr path
L0077               leax      <L0096,pc           point to 'krnp3'
                    lda       #Systm              get type
                    os9       F$Link              try to link
                    bcs       L0083               not there, go on
                    jsr       ,y                  execute it
* Execute module listed in Init module
L0083               ldu       <D.Init             get init module pointer
                    ldd       InitStr,u           get offset to name of first module
                    leax      d,u                 point to it
                    lda       #'C                 debug: signal that we tried to go to SysGo
                    jsr       <D.BtBug
                    lda       #Objct              get module type
                    clrb                          get mem size
                    ifne      H6309
                    tfr       0,y                 Get parameter size
                    else
                    ldy       #$0000
                    endc
                    os9       F$Fork              fork it
                    bcs       L009B               if error, crash the system
L0093               os9       F$NProc             let it take over

L0096               fcs       /krnp3/

L009B               jmp       <D.Crash

svctab              fcb       F$UnLink
                    fdb       FUnLink-*-2
                    fcb       F$AllRAM
                    fdb       FAllRAM-*-2
                    fcb       F$AlHRAM+SysState
                    fdb       FAlHRAM-*-2
                    fcb       F$Fork
                    fdb       FFork-*-2
                    fcb       F$Wait
                    fdb       FWait-*-2
                    fcb       F$Chain
                    fdb       FChain-*-2
                    fcb       F$Exit
                    fdb       FExit-*-2
                    fcb       F$Mem
                    fdb       FMem-*-2
                    fcb       F$Send
                    fdb       FSend-*-2
                    fcb       F$Icpt
                    fdb       FIcpt-*-2
                    fcb       F$Sleep
                    fdb       FSleep-*-2
                    fcb       F$SPrior
                    fdb       FSPrior-*-2
                    fcb       F$ID
                    fdb       FID-*-2
                    fcb       F$SSWI
                    fdb       FSSWI-*-2
                    fcb       F$STime
                    fdb       FSTime-*-2
                    fcb       F$SchBit
                    fdb       FSchBit-*-2
                    fcb       F$SchBit+SysState
                    fdb       FSSchBit-*-2
                    fcb       F$AllBit
                    fdb       FAllBit-*-2
                    fcb       F$AllBit+SysState
                    fdb       FSAllBit-*-2
                    fcb       F$DelBit
                    fdb       FDelBit-*-2
                    fcb       F$DelBit+SysState
                    fdb       FSDelBit-*-2
                    fcb       F$GPrDsc
                    fdb       FGPrDsc-*-2
                    fcb       F$GBlkMp
                    fdb       FGBlkMp-*-2
                    fcb       F$GModDr
                    fdb       FGModDr-*-2
                    IFEQ      H6309+F256
                    fcb       F$DelRAM
                    fdb       FDelRAM-*-2
                    ENDC
                    fcb       F$SUser             Added back here for room in OS9p1
                    fdb       FSUser-*-2
                    fcb       F$UnLoad
                    fdb       FUnLoad-*-2
                    fcb       F$Find64+$80
                    fdb       FFind64-*-2
                    fcb       F$All64+$80
                    fdb       FAll64-*-2
                    fcb       F$Ret64+$80
                    fdb       FRet64-*-2
                    fcb       F$GProcP+$80
                    fdb       FGProcP-*-2
                    fcb       F$DelImg+$80
                    fdb       FDelImg-*-2
                    fcb       F$AllPrc+$80
                    fdb       FAllPrc-*-2
                    fcb       F$DelPrc+$80
                    fdb       FDelPrc-*-2
                    fcb       F$MapBlk
                    fdb       FMapBlk-*-2
                    fcb       F$ClrBlk
                    fdb       FClrBlk-*-2
                    fcb       F$GCMDir+$80
                    fdb       FGCMDir-*-2
                    fcb       F$Debug
                    fdb       FDebug-*-2
                    fcb       F$CRCMod            new system call to change module CRC calcs on/off
                    fdb       FCRCMod-*-2
                    fcb       $7f
                    fdb       GetIOMan-*-2
                    fcb       $80

                    use       fcrcmod.asm

* Link & execute IOMan
* Entry: None
* Exit : I/O handling installed & ready for use
GetIOMan            pshs      d,x,y,u             preserve regs
                    bsr       LnkIOMan            link to ioman
                    bcc       GotIOMan            no errors, go on
                    os9       F$Boot              re-load boot file
                    bcs       IOManErr            error loading, return
                    bsr       LnkIOMan            link to ioman
                    bcs       IOManErr            error, save it & return
GotIOMan            jsr       ,y                  execute IOMan's init routine
                    puls      d,x,y,u             restore registers
                    jmp       [IOEntry,y]         Execute I/O vector

IOManErr            stb       1,s                 save error if any
                    puls      d,x,y,u,pc          restore & return

* Link to IOMan
* Entry: None
* Exit : U=Pointer to IOMan module header
*        Y=Pointer to IOMan entry point
LnkIOMan            leax      <IOMan,pc           point to name
                    lda       #(Systm+Objct)      get type
                    os9       F$Link              link it
                    rts                           return

IOMan               fcs       /IOMan/

                    use       funlink.asm

                    use       ffork.asm

                    use       fallprc.asm

                    use       fchain.asm

                    use       fexit.asm

                    use       fmem.asm

                    use       fsend.asm

                    use       ficpt.asm

                    use       fsleep.asm

                    use       fallram.asm

                    use       fsprior.asm

                    use       fid.asm

                    ifeq      H6309+F256
                    use       fdelram.asm
                    endc

                    use       fsswi.asm

                    use       fstime.asm

                    use       fallbit.asm

                    use       fgprdsc.asm

                    use       fgblkmp.asm

                    use       fgmoddr.asm

                    use       fsuser.asm

                    use       funload.asm

                    use       ffind64.asm

                    use       fgprocp.asm

                    use       fdelimg.asm

                    use       fmapblk.asm

                    use       fclrblk.asm

                    use       fgcmdir.asm

                    use       fdebug.asm

                    emod
eom                 equ       *
                    end
