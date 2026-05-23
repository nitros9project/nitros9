********************************************************************
* krn - NitrOS-9 Level 2 Kernel
*
* $Id: krn.asm,v 1.29 2010/05/20 16:35:47 boisy Exp $
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  19r6    2002/08/21  Boisy G. Pitre
* Assembles to the os9p1 module that works on my NitrOS-9 system.
*
*  19r7    2002/09/26  Boisy G. Pitre
* Added check for CRC feature bit in init module
*
*  19r8    2003/09/22  Boisy G. Pitre
* Back-ported to OS-9 Level Two.
*
*  19r8    2004/05/22  Boisy G. Pitre
* Renamed to 'krn'
*
*  19r9    2004/07/12  Boisy G. Pitre
* F$SRqMem now properly scans the DAT images of the system to update
* the D.SysMem map.

                    nam       krn
                    ttl       NitrOS-9 Level 2 Kernel

                    use       defsfile  ; include source file defsfile

* defines for customizations
Revision            set       9         ; module revision
Edition             set       19        ; module Edition
Where               equ       $F000     ; absolute address of where Kernel starts in memory

                    mod       eom,MName,Systm,ReEnt+Revision,entry,0 ; define OS-9 module header

                    *         CCB       Change: module name changes to CCBKrn
MName               fcs       /CCBKrn/
                    fcb       Edition   ; define byte value(s) Edition

                    *         CCB       Change: added a automagic "fill" directive
                    *         between   the end of the kernel module, proper, and the fe page code
                    *         see       way down. Manually refilling the empty space after each
                    *         code      change was a pain and error prone.  BG

* FILL - all unused bytes are now here
*       fcc     /www.nitros9.org /
*       fcc     /www.nitros9.org /
*       fcc     /www.ni/
*       fcc     /w/
*       fcc     /w/
*       fcc     /w/
*       IFNE    H6309
*       fcc     /www.nitros9.org /
*       fcc     /www.nitros9.org /
*       fcc     /www/
*       ELSE
*       fcc     /www.nit/
*       ENDC

* Might as well have this here as just past the end of Kernel...
DisTable
                    fdb       L0CD2+Where ; d.Clock absolute address at the start
                    fdb       XSWI3+Where ; d.XSWI3
                    fdb       XSWI2+Where ; d.XSWI2
                    fdb       D.Crash   ; d.XFIRQ crash on an FIRQ
                    fdb       XIRQ+Where ; d.XIRQ
                    fdb       XSWI+Where ; d.XSWI
                    fdb       D.Crash   ; d.XNMI crash on an NMI
                    fdb       $0055     ; d.ErrRst ??? Not used as far as I can tell
                    fdb       Sys.Vec+Where ; initial Kernel system call vector
DisSize             equ       *-DisTable ; define assembler symbol DisSize
* DO NOT ADD ANYTHING BETWEEN THESE 2 TABLES: see code using 'SubSiz', below
LowSub              equ       $0160     ; start of low memory subroutines
SubStrt             equ       *         ; define assembler symbol SubStrt
* D.Flip0 - switch to system task 0
R.Flip0             equ       *         ; define assembler symbol R.Flip0
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #$FE,<D.TINIT ; map type 0
                    lde       <D.TINIT  ; another 2 bytes saved if GRFDRV does: tfr cc,e
                    ste       >DAT.Task ; and we can use A here, instead of E
                  ELSE
                    pshs      a         ; save a on the stack
                    lda       <D.TINIT  ; load A from <D.TINIT
                    anda      #$FE      ; force TR=0
                    sta       <D.TINIT  ; store A at <D.TINIT
                    sta       >DAT.Task ; store A at >DAT.Task
                    puls      a         ; restore a from the stack
                  ENDC
                    clr       <D.SSTskN ; clear <D.SSTskN
                    tfr       x,s       ; transfer register value x,s
                    tfr       a,cc      ; transfer register value a,cc
                    rts                 ; return to caller
SubSiz              equ       *-SubStrt ; define assembler symbol SubSiz
* Don't add any code here: See L0065, below.
* Interrupt service routine
Vectors             jmp       [<-(D.SWI3-D.XSWI3),x] ; (-$10) (Jmp to 2ndary vector)

* Let's start by initializing system page
entry               equ       *         ; define assembler symbol entry
                    *         CCB       Addition - save stacked OS9Boot size and make a dummy kernel printer
                    pulu      d         ; pull boot file size from CoCoBoot and
                    std       <D.BtSz   ; save to direct page for later use
                    inc       <D.Boot   ; mark boot attempted flag
                    inc       <D.Speed  ; mark high speed
                    lds       #$1fff    ; reset system stack (s/b 0x2000 ?!?!)
                    lda       #$7e      ; put code in DP so rest of kernel can
                    sta       <D.BtBug  ; call kernel printing routine
                    leax      BtDebug,pc ; compute BtDebug,pc into X
                    stx       <D.BtBug+1 ; store X at <D.BtBug+1
                    sta       <D.Crash  ; and do the same with the kernel crash
                    leax      Crash,pc  ; code
                    stx       <D.Crash+1 ; store X at <D.Crash+1
                    bra       CCBEND    ; jump over new kprint & crash routines

                    *         This      is a kernel print routine
                    *         This      is added to replace the same routine found in "rel.asm"
                    *         so        we get debug output.
                    *         Takes     A - charactor to print
                    *         modifies  - nothing
BtDebug             pshs      cc,d,x    ; save the register
                    orcc      #IntMasks ; turn IRQ's off
                    ldb       #$3b      ; block to map in
                    stb       >DAT.Regs ; map the boot screen into block 0
                    ldx       >$0002    ; where to put the bytes
                    sta       ,x+       ; put the character on-screen
                    stx       >$0002    ; save updated address
                    clr       >DAT.Regs ; map block 0 in again
                    puls      cc,d,x,pc ; restore and return
                    *         This      routine just prints "!" and loops forever
Crash               lda       #'!       ; print a "!"
                    jsr       <D.BtBug  ; call routine at <D.BtBug
e                   bra       e         ; loop forever
CCBEND
                    *         end       of CCB Addition

                    *         This      code clears the rest of the low block
                    *         rel.asm/cocoboot has cleared the DP already.
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldq       #$01001f00 ; start address to clear & # bytes to clear
                    leay      <entry+2,pc ; point to a 0
                    tfm       y,d+      ; transfer memory block using y,d+
                    std       <D.CCStk  ; set pointer to top of global memory to $2000
                    lda       #$01      ; set task user table to $0100
                  ELSE
                    ldx       #$100     ; load X from #$100
                    ldy       #$2000-$100 ; load Y from #$2000-$100
                    clra                ; clear A
                    clrb                ; clear B
L001C               std       ,x++      ; store D at ,x++
                    leay      -2,y      ; compute -2,y into Y
                    bne       L001C     ; branch if zero is clear to L001C
                    stx       <D.CCStk  ; set pointer to top of global memory to $2000
                    inca                ; D = $0100
                  ENDC

* Setup system direct page variables
                    std       <D.Tasks  ; set Task Structure pointer to 0x100
                    addb      #$20      ; set Task image table pointer to $0120
                    std       <D.TskIPt ; store D at <D.TskIPt
                    clrb                ; set memory block map pointer to $0200
                    inca                ; increment A
                    std       <D.BlkMap ; store D at <D.BlkMap
                    addb      #$40      ; set second block map pointer to $0240
                    std       <D.BlkMap+2 ; store D at <D.BlkMap+2
                    clrb                ; set system service dispatch table
                    inca                ; pointer to 0x300
                    std       <D.SysDis ; store D at <D.SysDis
                    inca                ; set user dispatch table pointer to $0400
                    std       <D.UsrDis ; store D at <D.UsrDis
                    inca                ; set process descriptor block pointer to $0500
                    std       <D.PrcDBT ; store D at <D.PrcDBT
                    inca                ; set system process descriptor pointer to $0600
                    std       <D.SysPrc ; store D at <D.SysPrc
                    std       <D.Proc   ; set user process descriptor pointer to $0600
                    adda      #$02      ; set stack pointer to $0800
                    tfr       d,s       ; transfer register value d,s
                    inca                ; set system stack base pointer to $0900
                    std       <D.SysStk ; store D at <D.SysStk
                    std       <D.SysMem ; set system memory map ptr $0900
                    inca                ; set module directory start ptr to $0a00
                    std       <D.ModDir ; store D at <D.ModDir
                    std       <D.ModEnd ; set module directory end ptr to $0a00
                    adda      #$06      ; set secondary module directory start to $1000
                    std       <D.ModDir+2 ; store D at <D.ModDir+2
                    std       <D.ModDAT ; set module directory DAT pointer to $1000
                    std       <D.CCMem  ; set pointer to beginning of global memory to $1000
* In following line, CRC=ON if it is STA <D.CRC, CRC=OFF if it is a STB <D.CRC
                    stb       <D.CRC    ; set CRC checking flag to off

* Initialize interrupt vector tables, move pointer data down to DP
* CCB Change:
* this line was an error?
*       leay    <DisTable,pcr
                    leay      DisTable,pcr ; point to table of absolute vector addresses
*
*
                    ldx       #D.Clock  ; where to put it in memory
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldf       #DisSize  ; size of the table - E=0 from TFM, above
                    tfm       y+,x+     ; move it over
                  ELSE
                    ldb       #DisSize  ; load B from #DisSize
l@
                    lda       ,y+       ; load a byte from source
                    sta       ,x+       ; store a byte to dest
                    decb                ; bump counter
                    bne       l@        ; loop if we're not done
                  ENDC

* initialize D.Flip0 routine in low memory, move function down to low
* memory.
* Y=ptr to R.Flip0 already
*         leay  >R.Flip0,pc
                    ldu       #LowSub   ; move to 0x160
                    stu       <D.Flip0  ; store fuction pointer to DP area
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldf       #SubSiz   ; size of it
                    tfm       y+,u+     ; copy it over
                  ELSE
                    ldb       #SubSiz   ; load B from #SubSiz
Loop2               lda       ,y+       ; load a byte from source
                    sta       ,u+       ; and save to destination
                    decb                ; bump counter
                    bne       Loop2     ; loop if not done
                  ENDC

*         leau   <Vectors,pc   point to vector
* fill in the secondard interrupt vectors to all point to
                    tfr       y,u       ; move the pointer to a faster register
L0065               stu       ,x++      ; set all IRQ vectors to go to Vectors for now
                    cmpx      #D.NMI    ; compare X with #D.NMI
                    bls       L0065     ; branch if unsigned result is lower or same to L0065

* Initialize user interupt vectors
                    ldx       <D.XSWI2  ; get SWI2 (os9 command) service routine pointer
                    stx       <D.UsrSvc ; save it as user service routine pointer
                    ldx       <D.XIRQ   ; get IRQ service routine pointer
                    stx       <D.UsrIRQ ; save it as user IRQ routine pointer

                    leax      >SysCall,pc ; setup System service routine entry vector
                    stx       <D.SysSvc ; store X at <D.SysSvc
                    stx       <D.XSWI2  ; store X at <D.XSWI2

                    leax      >S.SysIRQ,pc ; setup system IRQ service vector
                    stx       <D.SysIRQ ; store X at <D.SysIRQ
                    stx       <D.XIRQ   ; store X at <D.XIRQ

                    leax      >S.SvcIRQ,pc ; setup in system IRQ service vector
                    stx       <D.SvcIRQ ; store X at <D.SvcIRQ
                    leax      >S.Poll,pc ; setup interrupt polling vector
                    stx       <D.Poll   ; oRCC #$01;RTS
                    leax      >S.AltIRQ,pc ; setup alternate IRQ vector: pts to an RTS
                    stx       <D.AltIRQ ; store X at <D.AltIRQ

                    lda       #'K       ; --- in Kernel
                    jsr       <D.BtBug  ; ---

                    leax      >S.Flip1,pc ; setup change to task 1 vector
                    stx       <D.Flip1  ; store X at <D.Flip1

* Setup System calls
                    leay      >SysCalls,pc ; load y with address of table, below
                    lbsr      InstallSvc ; copy table below into dispatch table

* Initialize system process descriptor
                    ldu       <D.PrcDBT ; get process table pointer
                    ldx       <D.SysPrc ; get system process pointer

* These overlap because it is quicker than trying to strip hi byte from X
                    stx       ,u        ; save it as first process in table
                    stx       1,u       ; save it as the second as well
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #$01,P$ID,x ; set process ID to 1 (inited to 0)
                    oim       #SysState,P$State,x ; set to system state (inited to 0)
                  ELSE
                    ldd       #$01*256+SysState ; load D from #$01*256+SysState
                    sta       P$ID,x    ; set PID to 1
                    stb       P$State,x ; set state to system (*NOT* zero )
                  ENDC
                    clra                ; set System task as task #0
                    sta       <D.SysTsk ; store A at <D.SysTsk
                    sta       P$Task,x  ; store A at P$Task,x
                    coma                ; setup its priority & age ($FF)
                    sta       P$Prior,x ; store A at P$Prior,x
                    sta       P$Age,x   ; store A at P$Age,x
                    leax      <P$DATImg,x ; point to DAT image
                    stx       <D.SysDAT ; save it as a pointer in DP
* actually, since block 0 is tfm'd to be zero, we can skip the next 2 lines
                  IFNE    H6309   ; begin conditional assembly for H6309
                    clrd                ; clear D
                  ELSE
                    clra                ; clear A
                    clrb                ; clear B
                  ENDC
                    std       ,x++      ; initialize 1st block to 0 (for this DP)

* Dat.BlCt-ROMCount-RAMCount
                    lda       #$06      ; initialize the rest of the blocks to be free
                    ldu       #DAT.Free ; load U from #DAT.Free
L00EF               stu       ,x++      ; store free "flag"
                    deca                ; bump counter
                    bne       L00EF     ; loop if not done

                    ldu       #KrnBlk   ; block where the kernel will live
                    stu       ,x        ; store U at ,x

                    ldx       <D.Tasks  ; point to task user table
                    inc       ,x        ; mark first 2 in use (system & GrfDrv)
                    inc       1,x       ; increment 1,x

* Setup system memory map
                    ldx       <D.SysMem ; get system memory map pointer
                    ldb       <D.CCStk  ; get MSB of top of CC memory
L0104               inc       ,x+       ; mark it as used
                    decb                ; done?
                    bne       L0104     ; no, go back till done

* Calculate memory size
                    *         CCB       Comment:
                    *         This      code only modifies 2 bytes in the x0 blocks (x=doesn't cares)
                    *         which     at worst will be our DP. Should not effect CCB's prior load of
                    *         OS9Boot   it can only be loaded into block x1 through x6 and 3f so
                    *         we        should be safe.
                    ldx       <D.BlkMap ; get ptr to 8k block map
                    inc       <KrnBlk,x ; mark block holding kernel as used
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldq       #$00080100 ; e=Marker, D=Block # to check
L0111               asld                ; get next block #
                    stb       >DAT.Regs+5 ; map block into block 6 of my task
                    ste       >-$6000,x ; save marker to that block
                    cmpe      ,x        ; did it ghost to block 0?
                    bne       L0111     ; no, keep going till ghost is found
                    stb       <D.MemSz  ; save # 8k mem blocks that exist
                    addr      x,d       ; add number of blocks to block map start
                  ELSE
                    ldd       #$0008    ; load D from #$0008
L0111               aslb                ; update processor state
                    rola                ; shift or rotate and update condition codes
                    stb       >DAT.Regs+5 ; store B at >DAT.Regs+5
                    pshs      a         ; save a on the stack
                    lda       #$01      ; load A from #$01
                    sta       >-$6000,x ; store A at >-$6000,x
                    cmpa      ,x        ; compare A with ,x
                    puls      a         ; restore a from the stack
                    bne       L0111     ; branch if zero is clear to L0111
                    stb       <D.MemSz  ; store B at <D.MemSz
                    pshs      x         ; save x on the stack
                    addd      ,s++      ; add ,s++ to D
                  ENDC
                    std       <D.BlkMap+2 ; save block map end pointer

* [D] at this point will contain 1 of the following:
* $0210 - 128k
* $0220 - 256k
* $0240 - 512k
* $0280 - 1024k
* $0300 - 2048k
                    bitb      #%00110000 ; block above 128K-256K?
                    beq       L0170     ; yes, no need to mark block map
                    tstb                ; 2 meg?
                    beq       L0170     ; yes, skip this
* Mark blocks from 128k-256K to block $3F as NOT RAM
                    abx                 ; add maximum block number to block map start
                    leax      -1,x      ; skip good blocks that are RAM
                    lda       #NotRAM   ; not RAM flag
                    subb      #$3F      ; calculate # blocks to mark as not RAM
L0127               sta       ,x+       ; mark them all
                    decb                ; decrement B
                    bne       L0127     ; branch if zero is clear to L0127

L0170
* CCB - Commented out next two line. we don't have REL or BOOT, so the verify will be only
* for the memory taken by KRN itself... f000 to ff00
*       ldx     #Bt.Start       start address of the boot track in memory
*       lda     #$12            size of the boot track: B=$00 from L0127 loop, above
* CCB Addtion - change 2 lines above to:
*       ldx     #Where          start address of KRN in memory
*       ldd     #$f00           size of KRN: B is already 0, A = F, Size=15 sectors (max)
* end of CCB Addtion
*       lbsr    I.VBlock        go verify it
*       bsr     L01D2           go mark system map
* CCB Change - I'm commenting out this whole section, and replacing it
                  IFEQ    1       ; begin conditional assembly for 1
* See if init module is in memory already
L01B0               leax      <init,pc  ; point to 'Init' module name
                    bsr       link      ; try & link it
                    bcc       L01BF     ; no error, go on
L01B8               os9       F$Boot    ; error linking init, try & load boot file
                    bcc       L01B0     ; got it, try init again
                    bra       L01CE     ; error, re-booting do D.Crash
L01BF               stu       <D.Init   ; save init module pointer
                    lda       Feature1,u ; get feature byte #1 from init module
                    bita      #CRCOn    ; cRC feature on?
                    beq       ShowI     ; if not, continue
                    inc       <D.CRC    ; else inc. CRC flag
ShowI               lda       #'i       ; found init module
                    jsr       <D.BtBug  ; call routine at <D.BtBug

L01C1               leax      <krnp2,pc ; point to it's name
                    bsr       link      ; try to link it
                    bcc       L01D0     ; it worked, execute it
                    os9       F$Boot    ; it doesn't exist try re-booting
                    bcc       L01C1     ; no error's, let's try to link it again
L01CE               jmp       <D.Crash  ; obviously can't do it, crash machine
L01D0               jmp       ,y        ; execute krnp2
                  ENDC

* CCB we'll replace above with this:
                    ldd       <D.BtSz   ; get the size of OS9Boot file
                    addd      #$fff     ; add size of krn and round to higher size
                    clrb                ; clear B
                    pshs      d         ; save on stack
                    os9       F$SRqMem  ; get memory - U is our starting address
                    stu       <D.BtPtr  ; save this just incase something uses it
                    tfr       u,x       ; setup x for vblock
                    puls      d         ; setup d for vblock with stacked size
                    lbsr      I.VBlock  ; verify OS9Boot
                    *         this      was copied from f$boot
                    *         I         dont know why we need to do this.  Wouldn't
                    *         f$srqmem  do this for us?!?!  But the system won't boot without.
                    ldx       <D.SysDAT ; get system DAT pointer
                    ldb       $0D,x     ; get highest allocated block number
                    incb                ; allocate block 0, too
                    ldx       <D.BlkMap ; point to the memory block map
                    bsr       L01DF     ; and go mark the blocks as used
                    *         end       of copy from f$boot
                    leax      <init,pc  ; point to 'Init' module name
                    bsr       link      ; try & link it
L01BF               stu       <D.Init   ; save init module pointer
                    lda       Feature1,u ; get feature byte #1 from init module
                    bita      #CRCOn    ; cRC feature on?
*       beq     ShowI           if not, continue
                    inc       <D.CRC    ; else inc. CRC flag
ShowI               lda       #'i       ; found init module
                    jsr       <D.BtBug  ; call routine at <D.BtBug
L01C1               leax      <krnp2,pc ; point to it's name
                    bsr       link      ; try to link it
*e      bra     e
L01D0               jmp       ,y        ; execute krnp2


* CCB - End of change


* Mark kernel in system memory map as used memory (256 byte blocks)
* L01D2 ldx     <D.SysMem       Get system mem ptr
*       * CCB Change - only mark KRN as used (BOOT and REL don't exist)
*       ldd     #NotRAM*256+(Bt.Start/256)      B = MSB of start of the boot
*       ldd     #NotRam*256+(Where/256)         B = MSB of start of REL
                    *         CCB       Change end
*       abx                     point to Bt.Start - start of boot track
*       comb                    we have $FF-$ED pages to mark as used
*       sta     b,x             Mark I/O as not RAM

* Mark kernel and boot file in system memory as used - there is no
* reason this is a routine anymore - only one place calls it, but
* some speghetti is here... one of the IRQ routines "borrows" this rts.
L01DF               lda       #RAMinUse ; get in use flag
L01E1               sta       ,x+       ; save it
                    decb                ; done?
                    bne       L01E1     ; no, keep going
                    ldx       <D.BlkMap ; get pointer to start of block map
                    sta       <KrnBlk,x ; mark kernel block as RAMinUse, instead of ModInBlk
S.AltIRQ            rts                 ; return

* Link module pointed to by X
link                lda       #Systm    ; attempt to link system module
                    os9       F$Link    ; call OS-9 service F$Link
                    rts                 ; return to caller

init                fcs       'Init'
krnp2               fcs       'krnp2'

* Service vector call pointers
SysCalls            fcb       F$Link    ; define byte value(s) F$Link
                    fdb       FLink-*-2 ; define word value(s) FLink-*-2
                    fcb       F$PrsNam  ; define byte value(s) F$PrsNam
                    fdb       FPrsNam-*-2 ; define word value(s) FPrsNam-*-2
                    fcb       F$CmpNam  ; define byte value(s) F$CmpNam
                    fdb       FCmpNam-*-2 ; define word value(s) FCmpNam-*-2
                    fcb       F$CmpNam+SysState ; define byte value(s) F$CmpNam+SysState
                    fdb       FSCmpNam-*-2 ; define word value(s) FSCmpNam-*-2
                    fcb       F$CRC     ; define byte value(s) F$CRC
                    fdb       FCRC-*-2  ; define word value(s) FCRC-*-2
                    fcb       F$SRqMem+SysState ; define byte value(s) F$SRqMem+SysState
                    fdb       FSRqMem-*-2 ; define word value(s) FSRqMem-*-2
                    fcb       F$SRtMem+SysState ; define byte value(s) F$SRtMem+SysState
                    fdb       FSRtMem-*-2 ; define word value(s) FSRtMem-*-2
                    fcb       F$AProc+SysState ; define byte value(s) F$AProc+SysState
                    fdb       FAProc-*-2 ; define word value(s) FAProc-*-2
                    fcb       F$NProc+SysState ; define byte value(s) F$NProc+SysState
                    fdb       FNProc-*-2 ; define word value(s) FNProc-*-2
                    fcb       F$VModul+SysState ; define byte value(s) F$VModul+SysState
                    fdb       FVModul-*-2 ; define word value(s) FVModul-*-2
                    fcb       F$SSvc+SysState ; define byte value(s) F$SSvc+SysState
                    fdb       FSSvc-*-2 ; define word value(s) FSSvc-*-2
                    fcb       F$SLink+SysState ; define byte value(s) F$SLink+SysState
                    fdb       FSLink-*-2 ; define word value(s) FSLink-*-2
                    fcb       F$Boot+SysState ; define byte value(s) F$Boot+SysState
                    fdb       FBoot-*-2 ; define word value(s) FBoot-*-2
                    fcb       F$BtMem+SysState ; define byte value(s) F$BtMem+SysState
                    fdb       FSRqMem-*-2 ; define word value(s) FSRqMem-*-2
                  IFNE    H6309   ; begin conditional assembly for H6309
                    fcb       F$CpyMem  ; define byte value(s) F$CpyMem
                    fdb       FCpyMem-*-2 ; define word value(s) FCpyMem-*-2
                  ENDC
                    fcb       F$Move+SysState ; define byte value(s) F$Move+SysState
                    fdb       FMove-*-2 ; define word value(s) FMove-*-2
                    fcb       F$AllImg+SysState ; define byte value(s) F$AllImg+SysState
                    fdb       FAllImg-*-2 ; define word value(s) FAllImg-*-2
                    fcb       F$SetImg+SysState ; define byte value(s) F$SetImg+SysState
                    fdb       FSetImg-*-2 ; define word value(s) FSetImg-*-2
                    fcb       F$FreeLB+SysState ; define byte value(s) F$FreeLB+SysState
                    fdb       FSFreeLB-*-2 ; define word value(s) FSFreeLB-*-2
                    fcb       F$FreeHB+SysState ; define byte value(s) F$FreeHB+SysState
                    fdb       FFreeHB-*-2 ; define word value(s) FFreeHB-*-2
                    fcb       F$AllTsk+SysState ; define byte value(s) F$AllTsk+SysState
                    fdb       FAllTsk-*-2 ; define word value(s) FAllTsk-*-2
                    fcb       F$DelTsk+SysState ; define byte value(s) F$DelTsk+SysState
                    fdb       FDelTsk-*-2 ; define word value(s) FDelTsk-*-2
                    fcb       F$SetTsk+SysState ; define byte value(s) F$SetTsk+SysState
                    fdb       FSetTsk-*-2 ; define word value(s) FSetTsk-*-2
                    fcb       F$ResTsk+SysState ; define byte value(s) F$ResTsk+SysState
                    fdb       FResTsk-*-2 ; define word value(s) FResTsk-*-2
                    fcb       F$RelTsk+SysState ; define byte value(s) F$RelTsk+SysState
                    fdb       FRelTsk-*-2 ; define word value(s) FRelTsk-*-2
                    fcb       F$DATLog+SysState ; define byte value(s) F$DATLog+SysState
                    fdb       FDATLog-*-2 ; define word value(s) FDATLog-*-2
                    fcb       F$LDAXY+SysState ; define byte value(s) F$LDAXY+SysState
                    fdb       FLDAXY-*-2 ; define word value(s) FLDAXY-*-2
                    fcb       F$LDDDXY+SysState ; define byte value(s) F$LDDDXY+SysState
                    fdb       FLDDDXY-*-2 ; define word value(s) FLDDDXY-*-2
                    fcb       F$LDABX+SysState ; define byte value(s) F$LDABX+SysState
                    fdb       FLDABX-*-2 ; define word value(s) FLDABX-*-2
                    fcb       F$STABX+SysState ; define byte value(s) F$STABX+SysState
                    fdb       FSTABX-*-2 ; define word value(s) FSTABX-*-2
                    fcb       F$ELink+SysState ; define byte value(s) F$ELink+SysState
                    fdb       FELink-*-2 ; define word value(s) FELink-*-2
                    fcb       F$FModul+SysState ; define byte value(s) F$FModul+SysState
                    fdb       FFModul-*-2 ; define word value(s) FFModul-*-2
                    fcb       F$VBlock+SysState ; define byte value(s) F$VBlock+SysState
                    fdb       FVBlock-*-2 ; define word value(s) FVBlock-*-2
                  IFNE    H6309   ; begin conditional assembly for H6309
                    fcb       F$DelRAM  ; define byte value(s) F$DelRAM
                    fdb       FDelRAM-*-2 ; define word value(s) FDelRAM-*-2
                  ENDC
                    fcb       $80       ; define byte value(s) $80

* SWI3 vector entry
XSWI3               lda       #P$SWI3   ; point to SWI3 vector
                    fcb       $8C       ; skip 2 bytes

* SWI vector entry
XSWI                lda       #P$SWI    ; point to SWI vector
                    ldx       <D.Proc   ; get process pointer
                    ldu       a,x       ; user defined SWI[x]?
                    beq       L028E     ; no, go get option byte
GoUser              lbra      L0E5E     ; yes, go call users's routine

* SWI2 vector entry
XSWI2               ldx       <D.Proc   ; get current process descriptor
                    ldu       P$SWI2,x  ; any SWI vector?
                    bne       GoUser    ; yes, go execute it

* Process software interupts from a user state
* Entry: X=Process descriptor pointer of process that made system call
*        U=Register stack pointer
L028E               ldu       <D.SysSvc ; set system call processor to system side
                    stu       <D.XSWI2  ; store U at <D.XSWI2
                    ldu       <D.SysIRQ ; do the same thing for IRQ's
                    stu       <D.XIRQ   ; store U at <D.XIRQ
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #SysState,P$State,x ; mark process as in system state
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    ora       #SysState ; merge #SysState into A
                    sta       P$State,x ; store A at P$State,x
                  ENDC
* copy register stack to process descriptor
                    sts       P$SP,x    ; save stack pointer
                    leas      (P$Stack-R$Size),x ; point S to register stack destination

                  IFNE    H6309   ; begin conditional assembly for H6309
                    leau      R$Size-1,s ; point to last byte of destination register stack
                    leay      -1,y      ; point to caller's register stack in $FEE1
                    ldw       #R$Size   ; size of the register stack
                    tfm       y-,u-     ; transfer memory block using y-,u-
                    leau      ,s        ; needed because the TFM is u-, not -u (post, not pre)
                  ELSE
* Note!  R$Size MUST BE an EVEN number of bytes for this to work!
                    leau      R$Size,s  ; point to last byte of destination register stack
                    lda       #R$Size/2 ; load A from #R$Size/2
Loop3               ldx       ,--y      ; load X from ,--y
                    stx       ,--u      ; store X at ,--u
                    deca                ; decrement A
                    bne       Loop3     ; branch if zero is clear to Loop3
                  ENDC
                    andcc     #^IntMasks ; clear condition-code bits using #^IntMasks
* B=function code already from calling process: DON'T USE IT!
                    ldx       R$PC,u    ; get where PC was from process
                    leax      1,x       ; move PC past option
                    stx       R$PC,u    ; save updated PC to process
* execute function call
                    ldy       <D.UsrDis ; get user dispatch table pointer
                    lbsr      L033B     ; go execute option
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^IntMasks,R$CC,u ; clear interrupt flags in caller's CC
                  ELSE
                    lda       R$CC,u    ; load A from R$CC,u
                    anda      #^IntMasks ; mask A with #^IntMasks
                    sta       R$CC,u    ; store A at R$CC,u
                  ENDC
                    ldx       <D.Proc   ; get current process ptr
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #^(SysState+TimOut),P$State,x ; clear system & timeout flags
                  ELSE
                    lda       P$State,x ; load A from P$State,x
                    anda      #^(SysState+TimOut) ; mask A with #^(SysState+TimOut)
                    sta       P$State,x ; store A at P$State,x
                  ENDC

* Check for image change now, which lets stuff like F$MapBlk and F$ClrBlk
* do the short-circuit thing, too.  Adds about 20 cycles to each system call.
                    lbsr      TstImg    ; it doesn't hurt to call this twice
                    lda       P$State,x ; get current state of the process
                    ora       <P$Signal,x ; is there a pending signal?
                    sta       <D.Quick  ; save quick return flag
                    beq       AllClr    ; if nothing's have changed, do full checks

DoFull              bsr       L02DA     ; move the stack frame back to user state
                    lbra      L0D80     ; go back to the process

* add ldu P$SP,x, etc...
AllClr              equ       *         ; define assembler symbol AllClr
                  IFNE    H6309   ; begin conditional assembly for H6309
                    inc       <D.QCnt   ; increment <D.QCnt
                    aim       #$1F,<D.QCnt ; apply immediate bit operation #$1F,<D.QCnt
                    beq       DoFull    ; every 32 system calls, do the full check
                    ldw       #R$Size   ; --- size of the register stack
                    ldy       #Where+SWIStack ; --- to stack at top of memory
                    orcc      #IntMasks ; set condition-code bits using #IntMasks
                    tfm       u+,y+     ; --- move the stack to the top of memory
                  ELSE
                    lda       <D.QCnt   ; load A from <D.QCnt
                    inca                ; increment A
                    anda      #$1F      ; mask A with #$1F
                    sta       <D.QCnt   ; store A at <D.QCnt
                    beq       DoFull    ; branch if zero is set to DoFull
                    ldb       #R$Size   ; load B from #R$Size
                    ldy       #Where+SWIStack ; load Y from #Where+SWIStack
                    orcc      #IntMasks ; set condition-code bits using #IntMasks
Loop4               lda       ,u+       ; load A from ,u+
                    sta       ,y+       ; store A at ,y+
                    decb                ; decrement B
                    bne       Loop4     ; branch if zero is clear to Loop4
                  ENDC
                    lbra      BackTo1   ; otherwise simply return to the user

* Copy register stack from user to system
* Entry: U=Ptr to Register stack in process dsc
L02CB               pshs      cc,x,y,u  ; preserve registers
                    ldb       P$Task,x  ; get task #
                    ldx       P$SP,x    ; get stack pointer
                    lbsr      L0BF3     ; calculate block offset (only affects A&X)
                    leax      -$6000,x  ; adjust pointer to where memory map will be
                    bra       L02E9     ; go copy it

* Copy register stack from system to user
* Entry: U=Ptr to Register stack in process dsc
L02DA               pshs      cc,x,y,u  ; preserve registers
                    ldb       P$Task,x  ; get task # of destination
                    ldx       P$SP,x    ; get stack pointer
                    lbsr      L0BF3     ; calculate block offset (only affects A&X)
                    leax      -$6000,x  ; adjust pointer to where memory map will be
                    exg       x,y       ; swap pointers & copy
* Copy a register stack
* Entry: X=Source
*        Y=Destination
*        A=Offset into DAT image of stack
*        B=Task #
L02E9               leau      a,u       ; point to block # of where stack is
                    lda       1,u       ; get first block
                    ldb       3,u       ; get a second just in case of overlap
                    orcc      #IntMasks ; shutdown interupts while we do this
                    std       >DAT.Regs+5 ; map blocks in
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       #R$Size   ; get size of register stack
                    tfm       x+,y+     ; copy it
                  ELSE
                    ldb       #R$Size   ; load B from #R$Size
Loop5               lda       ,x+       ; load A from ,x+
                    sta       ,y+       ; store A at ,y+
                    decb                ; decrement B
                    bne       Loop5     ; branch if zero is clear to Loop5
                  ENDC
                    ldx       <D.SysDAT ; remap the blocks we took out
                    lda       $0B,x     ; load A from $0B,x
                    ldb       $0D,x     ; load B from $0D,x
                    std       >DAT.Regs+5 ; store D at >DAT.Regs+5
                    puls      cc,x,y,u,pc ; restore & return

* Process software interupts from system state
* Entry: U=Register stack pointer
SysCall             leau      ,s        ; get pointer to register stack
                    lda       <D.SSTskN ; get system task # (0=SYSTEM, 1=GRFDRV)
                    clr       <D.SSTskN ; force to System Process
                    pshs      a         ; save the system task number
                    lda       ,u        ; restore callers CC register (R$CC=$00)
                    tfr       a,cc      ; make it current
                    ldx       R$PC,u    ; get my caller's PC register
                    leax      1,x       ; move PC to next position
                    stx       R$PC,u    ; save my caller's updated PC register
                    ldy       <D.SysDis ; get system dispatch table pointer
                    bsr       L033B     ; execute system call
                    puls      a         ; restore system state task number
                    lbra      L0E2B     ; return to process

* Entry: X = system call vector to jump to
Sys.Vec             jmp       ,x        ; execute service call

* Execute system call
* Entry: B=Function call #
*        Y=Function dispatch table pointer (D.SysDis or D.UsrDis)
L033B
                    lslb                ; is it a I/O call? (Also multiplys by 2 for offset)
                    bcc       L0345     ; no, go get normal vector
* Execute I/O system calls
                    ldx       IOEntry,y ; get IOMan vector
* Execute the system call
L034F               pshs      u         ; preserve register stack pointer
                    jsr       [D.SysVec] ; perform a vectored system call
                    puls      u         ; restore pointer
L0355               tfr       cc,a      ; move CC to A for stack update
                    bcc       L035B     ; go update it if no error from call
                    stb       R$B,u     ; save error code to caller's B
L035B               ldb       R$CC,u    ; get callers CC, R$CC=$00
                  IFNE    H6309   ; begin conditional assembly for H6309
                    andd      #$2FD0    ; [A]=H,N,Z,V,C [B]=E,F,I
                    orr       b,a       merge them together
                  ELSE
                    anda      #$2F      ; [A]=H,N,Z,V,C
                    andb      #$D0      ; [B]=E,F,I
                    pshs      b         ; save b on the stack
                    ora       ,s+       ; merge ,s+ into A
                  ENDC
                    sta       R$CC,u    ; return it to caller, R$CC=$00
                    rts                 ; return to caller

* Execute regular system calls
L0345
                    clra                ; clear MSB of offset
                    ldx       d,y       ; get vector to call
                    bne       L034F     ; it's initialized, go execute it
                    comb                ; set carry for error
                    ldb       #E$UnkSvc ; get error code
                    bra       L0355     ; return with it

                    use       fssvc.asm ; include source file fssvc.asm

                    use       flink.asm ; include source file flink.asm

                    use       fvmodul.asm ; include source file fvmodul.asm

                    use       ffmodul.asm ; include source file ffmodul.asm

                    use       fprsnam.asm ; include source file fprsnam.asm

                    use       fcmpnam.asm ; include source file fcmpnam.asm

                    use       ccbfsrqmem.asm ; include source file ccbfsrqmem.asm

*         use   fallram.asm


                  IFNE    H6309   ; begin conditional assembly for H6309
                    use       fdelram.asm ; include source file fdelram.asm
                  ENDC

                    use       fallimg.asm ; include source file fallimg.asm

                    use       ffreehb.asm ; include source file ffreehb.asm

                    use       fdatlog.asm ; include source file fdatlog.asm

                    use       fld.asm   ; include source file fld.asm

                  IFNE    H6309   ; begin conditional assembly for H6309
                    use       fcpymem.asm ; include source file fcpymem.asm
                  ENDC

                    use       fmove.asm ; include source file fmove.asm

                    use       fldabx.asm ; include source file fldabx.asm

                    use       falltsk.asm ; include source file falltsk.asm

                    use       faproc.asm ; include source file faproc.asm

* System IRQ service routine
XIRQ                ldx       <D.Proc   ; get current process pointer
                    sts       P$SP,x    ; save the stack pointer
                    lds       <D.SysStk ; get system stack pointer
                    ldd       <D.SysSvc ; set system service routine to current
                    std       <D.XSWI2  ; store D at <D.XSWI2
                    ldd       <D.SysIRQ ; set system IRQ routine to current
                    std       <D.XIRQ   ; store D at <D.XIRQ
                    jsr       [>D.SvcIRQ] ; execute irq service
                    bcc       L0D5B     ; branch if carry is clear to L0D5B

                    ldx       <D.Proc   ; get current process pointer
                    ldb       P$Task,x  ; load B from P$Task,x
                    ldx       P$SP,x    ; get it's stack pointer

                    pshs      u,d,cc    ; save some registers
                    leau      ,s        ; point to a 'caller register stack'
                    lbsr      L0C40     ; do a LDB 0,X in task B
                    puls      u,d,cc    ; and now A ( R$A,U ) = the CC we want

                    ora       #IntMasks ; disable it's IRQ's
                    lbsr      L0C28     ; save it back
L0D5B               orcc      #IntMasks ; shut down IRQ's
                    ldx       <D.Proc   ; get current process pointer
                    tst       <D.QIRQ   ; was it a clock IRQ?
                    lbne      L0DF7     ; if not, do a quick return

                    lda       P$State,x ; get it's state
                    bita      #TimOut   ; is it timed out?
                    bne       L0D7C     ; yes, wake it up
* Update active process queue
                    ldu       #(D.AProcQ-P$Queue) ; point to active process queue
                    ldb       #Suspend  ; get suspend flag
L0D6A               ldu       P$Queue,u ; get a active process pointer
                    beq       L0D78     ; branch if zero is set to L0D78
                    bitb      P$State,u ; is it suspended?
                    bne       L0D6A     ; yes, go to next one in chain
                    ldb       P$Prior,x ; get current process priority
                    cmpb      P$Prior,u ; do we bump this one?
                    blo       L0D7C     ; branch if unsigned result is lower to L0D7C

L0D78               ldu       P$SP,x    ; load U from P$SP,x
                    bra       L0DB9     ; branch unconditionally to L0DB9

L0D7C               anda      #^TimOut  ; mask A with #^TimOut
                    sta       P$State,x ; store A at P$State,x

L0D80               equ       *         ; define assembler symbol L0D80
L0D83               bsr       L0D11     ; activate next process

                    use       ccbfnproc.asm ; include source file ccbfnproc.asm

* The following routines must appear no earlier than $E00 when assembled, as
* they have to always be in the vector RAM page ($FE00-$FEFF)

* CCB: this code (after pad) start assembling *before* 0xfe00, it's too big to
* fit into the memory as stated above!!!!

PAD                 fill      $00,($0df1-*) ; fill memory to ensure the above happens
* Default routine for D.SysIRQ
S.SysIRQ
                    lda       <D.SSTskN ; get current task's GIME task # (0 or 1)
                    beq       FastIRQ   ; use super-fast version for system state
                    clr       <D.SSTskN ; clear out memory copy (task 0)
                    jsr       [>D.SvcIRQ] ; (Normally routine in Clock calling D.Poll)
                    inc       <D.SSTskN ; save task # for system state
                    lda       #1        ; task 1
                    ora       <D.TINIT  ; merge task bit's into Shadow version
                    sta       <D.TINIT  ; update shadow
                    sta       >DAT.Task ; save to GIME as well & return
                    bra       DoneIRQ   ; check for error and exit

FastIRQ             jsr       [>D.SvcIRQ] ; (Normally routine in Clock calling D.Poll)
DoneIRQ             bcc       L0E28     ; no error on IRQ, exit
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #IntMasks,0,s ; setup RTI to shut interrupts off again
                  ELSE
                    lda       ,s        ; load A from ,s
                    ora       #IntMasks ; merge #IntMasks into A
                    sta       ,s        ; store A at ,s
                  ENDC
L0E28               rti                 ; return from interrupt

* return from a system call
L0E29               clra                ; force System task # to 0 (non-GRDRV)
L0E2B               ldx       <D.SysPrc ; get system process dsc. ptr
                    lbsr      TstImg    ; check image, and F$SetTsk (PRESERVES A)
                    orcc      #IntMasks ; shut interrupts off
                    sta       <D.SSTskN ; save task # for system state
                    beq       Fst2      ; if task 0, skip subroutine
                    ora       <D.TINIT  ; merge task bit's into Shadow version
                    sta       <D.TINIT  ; update shadow
                    sta       >DAT.Task ; save to GIME as well & return
Fst2                leas      ,u        ; stack ptr=U & return
                    rti                 ; return from interrupt

* Switch to new process, X=Process descriptor pointer, U=Stack pointer
L0E4C               equ       *         ; define assembler symbol L0E4C
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #$01,<D.TINIT ; switch GIME shadow to user state
                    lda       <D.TINIT  ; load A from <D.TINIT
                  ELSE
                    lda       <D.TINIT  ; load A from <D.TINIT
                    ora       #$01      ; merge #$01 into A
                    sta       <D.TINIT  ; store A at <D.TINIT
                  ENDC
                    sta       >DAT.Task ; save it to GIME
                    leas      ,y        ; point to new stack
                    tstb                ; is the stack at SWISTACK?
                    bne       MyRTI     ; no, we're doing a system-state rti

                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldf       #R$Size   ; e=0 from call to L0E8D before
                    ldu       #Where+SWIStack ; point to the stack
                    tfm       u+,y+     ; move the stack from top of memory to user memory
                  ELSE
                    ldb       #R$Size   ; load B from #R$Size
                    ldu       #Where+SWIStack ; point to the stack
RtiLoop             lda       ,u+       ; load A from ,u+
                    sta       ,y+       ; store A at ,y+
                    decb                ; decrement B
                    bne       RtiLoop   ; branch if zero is clear to RtiLoop
                  ENDC
MyRTI               rti                 ; return from IRQ


* Execute routine in task 1 pointed to by U
* comes from user requested SWI vectors
L0E5E               equ       *         ; define assembler symbol L0E5E
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #$01,<D.TINIT ; switch GIME shadow to user state
                    ldb       <D.TINIT  ; load B from <D.TINIT
                  ELSE
                    ldb       <D.TINIT  ; load B from <D.TINIT
                    orb       #$01      ; merge #$01 into B
                    stb       <D.TINIT  ; store B at <D.TINIT
                  ENDC
                    stb       >DAT.Task ; store B at >DAT.Task
                    jmp       ,u        ; transfer control to ,u

* Flip to task 1 (used by GRF/WINDInt to switch to GRFDRV) (pointed to
*  by <D.Flip1). All regs are already preserved on stack for the RTI
S.Flip1             ldb       #2        ; get Task image entry numberx2 for Grfdrv (task 1)
                    bsr       L0E8D     ; copy over the DAT image
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #$01,<D.TINIT ; apply immediate bit operation #$01,<D.TINIT
                    lda       <D.TINIT  ; get copy of GIME Task side
                  ELSE
                    lda       <D.TINIT  ; load A from <D.TINIT
                    ora       #$01      ; merge #$01 into A
                    sta       <D.TINIT  ; store A at <D.TINIT
                  ENDC
                    sta       >DAT.Task ; save it to GIME register
                    inc       <D.SSTskN ; increment system state task number
                    rti                 ; return

* Setup MMU in task 1, B=Task # to swap to, shifted left 1 bit
L0E8D               cmpb      <D.Task1N ; are we going back to the same task
                    beq       L0EA3     ; without the DAT image changing?
                    stb       <D.Task1N ; nope, save current task in map type 1
                    ldx       #DAT.Regs+8 ; get MMU start register for process's
                    ldu       <D.TskIPt ; get task image pointer table
                    ldu       b,u       ; get address of DAT image
L0E93               leau      1,u       ; point to actual MMU block
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lde       #4        ; get # banks/2 for task
                  ELSE
                    lda       #4        ; load A from #4
                    pshs      a         ; save a on the stack
                  ENDC
L0E9B               lda       ,u++      ; get a bank
                    ldb       ,u++      ; and next one
                    std       ,x++      ; save it to MMU
                  IFNE    H6309   ; begin conditional assembly for H6309
                    dece                ; done?
                  ELSE
                    dec       ,s        ; decrement ,s
                  ENDC
                    bne       L0E9B     ; no, keep going
                  IFEQ    H6309   ; begin conditional assembly for H6309
                    leas      1,s       ; adjust stack pointer by 1,s
                  ENDC
L0EA3               rts                 ; return

* Execute FIRQ vector (called from $FEF4)
FIRQVCT             ldx       #D.FIRQ   ; get DP offset of vector
                    bra       L0EB8     ; go execute it

* Execute IRQ vector (called from $FEF7)
IRQVCT              orcc      #IntMasks ; disasble IRQ's
                    ldx       #D.IRQ    ; get DP offset of vector

* Execute interrupt vector, B=DP Vector offset
L0EB8               clra                ; (faster than CLR >$xxxx)
                    sta       >DAT.Task ; force to Task 0 (system state)
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       0,dp      ; setup DP
                  ELSE
                    tfr       a,dp      ; transfer register value a,dp
                  ENDC
MapGrf              equ       *         ; define assembler symbol MapGrf
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #$FE,<D.TINIT ; switch GIME shadow to system state
                    lda       <D.TINIT  ; set GIME again just in case timer is used
                  ELSE
                    lda       <D.TINIT  ; load A from <D.TINIT
                    anda      #$FE      ; mask A with #$FE
                    sta       <D.TINIT  ; store A at <D.TINIT
                  ENDC
MapT0               sta       >DAT.Task ; store A at >DAT.Task
                    jmp       [,x]      ; execute it

* Execute SWI3 vector (called from $FEEE)
SWI3VCT             orcc      #IntMasks ; disable IRQ's
                    ldx       #D.SWI3   ; get DP offset of vector
                    bra       SWICall   ; go execute it

* Execute SWI2 vector (called from $FEF1)
SWI2VCT             orcc      #IntMasks ; disasble IRQ's
                    ldx       #D.SWI2   ; get DP offset of vector

* This routine is called from an SWI, SWI2, or SWI3
* saves 1 cycle on system-system calls
* saves about 200 cycles (calls to I.LDABX and L029E) on grfdrv-system,
*  or user-system calls.
SWICall             ldb       [R$PC,s]  ; get callcode of the system call
* NOTE: Alan DeKok claims that this is BAD.  It crashed Colin McKay's
* CoCo 3.  Instead, we should do a clra/sta >DAT.Task.
*         clr   >DAT.Task       go to map type 1
                    clra                ; clear A
                    sta       >DAT.Task ; store A at >DAT.Task
* set DP to zero
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       0,dp      ; transfer register value 0,dp
                  ELSE
                    tfr       a,dp      ; transfer register value a,dp
                  ENDC

* These lines add a total of 81 addition cycles to each SWI(2,3) call,
* and 36 bytes+12 for R$Size in the constant page at $FExx
*  It takes no more time for a SWI(2,3) from system state than previously,
* ... and adds 14 cycles to each SWI(2,3) call from grfdrv... not a problem.
* For processes that re-vector SWI, SWI3, it adds 81 cycles.  BUT SWI(3)
* CANNOT be vectored to L0EBF cause the user SWI service routine has been
* changed
                    lda       <D.TINIT  ; get map type flag
                    bita      #$01      ; check it without changing it

* Change to LBEQ R.SysSvc to avoid JMP [,X]
* and add R.SysSvc STA >DAT.Task ???
                    beq       MapT0     ; in map 0: restore hardware and do system service
                    tst       <D.SSTskN ; get system state 0,1
                    bne       MapGrf    ; if in grfdrv, go to map 0 and do system service

* the preceding few lines are necessary, as all SWI's still pass thru
* here before being vectored to the system service routine... which
* doesn't copy the stack from user state.
                    sta       >DAT.Task ; go to map type X again to get user's stack
* a byte less, a cycle more than ldy #$FEED-R$Size, or ldy #$F000+SWIStack
                    leay      <SWIStack,pc ; where to put the register stack: to $FEDF
                    tfr       s,u       ; get a copy of where the stack is
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       #R$Size   ; get the size of the stack
                    tfm       u+,y+     ; move the stack to the top of memory
                  ELSE
                    pshs      b         ; save b on the stack
                    ldb       #R$Size   ; load B from #R$Size
Looper              lda       ,u+       ; load A from ,u+
                    sta       ,y+       ; store A at ,y+
                    decb                ; decrement B
                    bne       Looper    ; branch if zero is clear to Looper
                    puls      b         ; restore b from the stack
                  ENDC
                    bra       L0EB8     ; and go from map type 1 to map type 0

* Execute SWI vector (called from $FEFA)
SWIVCT              ldx       #D.SWI    ; get DP offset of vector
                    bra       SWICall   ; go execute it

* Execute NMI vector (called from $FEFD)
NMIVCT              ldx       #D.NMI    ; get DP offset of vector
                    bra       L0EB8     ; go execute it

* The end of the kernel module is here
                    emod
eom                 equ       *         ; define assembler symbol eom

* What follows after the kernel module is the register stack, starting
* at $FEDD (6309) or $FEDF (6809).  This register stack area is used by
* the kernel to save the caller's registers in the $FEXX area of memory
* because it doesn't* get "switched out" no matter the contents of the
* MMU registers.
SWIStack
                    fcc       /REGISTER STACK/    same # bytes as R$Size for 6809
                  IFNE    H6309   ; begin conditional assembly for H6309
                    fcc       /63/                if 6309, add two more spaces
                  ENDC

                    fcb       $55       ; d.ErrRst

* This list of addresses ends up at $FEEE after the kernel track is loaded
* into memory.  All interrupts come through the 6809 vectors at $FFF0-$FFFE
* and get directed to here.  From here, the BRA takes CPU control to the
* various handlers in the kernel.
                    bra       SWI3VCT   ; sWI3 vector comes here
                    nop       ; no operation placeholder
                    bra       SWI2VCT   ; sWI2 vector comes here
                    nop       ; no operation placeholder
                    bra       FIRQVCT   ; fIRQ vector comes here
                    nop       ; no operation placeholder
                    bra       IRQVCT    ; iRQ vector comes here
                    nop       ; no operation placeholder
                    bra       SWIVCT    ; sWI vector comes here
                    nop       ; no operation placeholder
                    bra       NMIVCT    ; nMI vector comes here
                    nop       ; no operation placeholder

                    end
