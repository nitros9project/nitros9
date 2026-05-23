********************************************************************
* krn - NitrOS-9 Level 2 Kernel
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

                  ifp1
                    use       defsfile  ; include source file defsfile
                  ENDC

* defines for customizations
Revision            set       9         ; module revision
Edition             set       19        ; module Edition
Where               equ       $F000     ; absolute address of where Kernel starts in memory

                    mod       eom,MName,Systm,ReEnt+Revision,entry,0 ; define OS-9 module header

MName               fcs       /Krn/
                    fcb       Edition   ; define byte value(s) Edition



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
* ^
* Code using 'SubSiz', below, assumes that SubStrt follows on directly after
* the end of DisTable. Therefore, DO NOT ADD ADD ANYTHING BETWEEN THESE 2 LABELS
* v
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
                    lda       <D.TINIT  ; get value from shadow
                  IFNE    mc09    ; begin conditional assembly for mc09
                    anda      #$BF      ; force TR=0
                    sta       <D.TINIT  ; update shadow
                    sta       >MMUADR   ; update MMU
                  ELSE
                    anda      #$FE      ; force TR=0
                    sta       <D.TINIT  ; store A at <D.TINIT
                    sta       >DAT.Task ; store A at >DAT.Task
                  ENDC
                    puls      a         ; restore a from the stack
                  ENDC
                    clr       <D.SSTskN ; clear <D.SSTskN
                    tfr       x,s       ; transfer register value x,s
                    tfr       a,cc      ; transfer register value a,cc
                    rts                 ; return to caller
SubSiz              equ       *-SubStrt ; define assembler symbol SubSiz
* ^
* Code around L0065, below, assumes that Vectors follows on directly after
* the end of R.Flip0. Therefore, DO NOT ADD ADD ANYTHING BETWEEN THESE 2 LABELS
* v
* Interrupt service routine
Vectors             jmp       [<-(D.SWI3-D.XSWI3),x] ; (-$10) (Jmp to 2ndary vector)

                  IFNE    mc09    ; begin conditional assembly for mc09
CPUVect             fdb       SWI3VCT+Where ; sWI3  at $FFF2
                    fdb       SWI2VCT+Where ; sWI2  at $FFF4
                    fdb       FIRQVCT+Where ; fIRQ  at $FFF6
                    fdb       IRQVCT+Where ; iRQ   at $FFF8
                    fdb       SWIVCT+Where ; sWI   at $FFFA
                    fdb       NMIVCT+Where ; nMI   at $FFFC
                    fdb       $0000+Where ; rESET at $FFFE
                  ENDC

* [NAC HACK 2016Dec07] to do a real reset on Multicomp09 need first to
* disable the MMU and re-enable the ROM. Maybe implement a little blob
* of code to do that? Otherwise, implement some kind of crash/dump.

* Initialize the system block (the lowest 8Kbytes of memory)
* rel.asm has cleared the DP already, so start at address $100.
entry               equ       *         ; define assembler symbol entry
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldq       #$01001f00 ; start address to clear & # bytes to clear
                    leay      <entry+2,pc ; point to a 0
                    tfm       y,d+      ; transfer memory block using y,d+
                    std       <D.CCStk  ; set pointer to top of global memory to $2000
                    lda       #$01      ; set task user table to $0100
                  ELSE
                    ldx       #$100     ; start address
                    ldy       #$2000-$100 ; bytes to clear
                    clra                ; clear A
                    clrb                ; clear B
L001C               std       ,x++      ; clear it 16-bits at a time
                    leay      -2,y      ; compute -2,y into Y
                    bne       L001C     ; branch if zero is clear to L001C
                    stx       <D.CCStk  ; set pointer to top of global memory to $2000
                    inca                ; D = $0100
                  ENDC

* Set up system variables in DP
                    std       <D.Tasks  ; set Task Structure pointer to $0100
                    addb      #$20      ; add #$20 to B
                    std       <D.TskIPt ; set Task image table pointer to $0120
                    clrb                ; clear B

********************************************************************
* The memory block map is a data structure that is used to manage
* physical memory. Physical memory is assigned in 8Kbyte "blocks".
* 256 bytes are reserved for the map and so the maximum physical
* memory size is 256*8Kbyte=2Mbyte. D.BlkMap is a pointer to the
* start of the map (set to $0200, below). D.BlkMap+2 is a pointer
* to the end of the map. Rather than simply setting it to $0300,
* the end pointer is set by the memory sizing routine at L0111.
* (Presumably) this makes it faster to search for unused pages
* and also acts as the mechanism to avoid assigning non-existent
* memory. A value of 0 indicates an unused block and since the
* system block has been initialised to 0 (above) every block starts
* off marked as unused. Initial reservation of blocks occurs
* below, after the memory sizing.
* See "Level 2 flags" in os9.d for other byte values.

                    inca                ; set memory block map start pointer
                    std       <D.BlkMap ; to $0200

                    inca                ; set system service dispatch table pointer
                    std       <D.SysDis ; to 0x300
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

* Initialize interrupt vector tables in DP by moving pointer data down from DisTable

                  IFNE    mc09    ; begin conditional assembly for mc09
* Brett's ccbkrn identified this as a bug in the original code..
* which has not been fixed. Should be easy to demonstrate which is
* correct..
                    leay      DisTable,pcr ; point to table of absolute vector addresses
                  ELSE
                    leay      <DisTable,pcr ; point to table of absolute vector addresses
                  ENDC
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

* Initialize D.Flip0 routine in low memory by copying lump of code down from R.Flip0.
* ASSUME: Y left pointing to R.Flip0 by previous copy loop.

                    ldu       #LowSub   ; somewhere in block 0 that's never modified
                    stu       <D.Flip0  ; switch to system task 0
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

* Initialize secondary interrupt vectors to all point to Vectors for now
* ASSUME: Y left pointing to Vectors by previous copy loop
                    tfr       y,u       ; move the pointer to a faster register
L0065               stu       ,x++      ; set all IRQ vectors to go to Vectors for now
                    cmpx      #D.NMI    ; compare X with #D.NMI
                    bls       L0065     ; branch if unsigned result is lower or same to L0065

                  IFNE    mc09    ; begin conditional assembly for mc09
* Initialize CPU vectors
                    leay      CPUVect,pcr ; data source
                    ldx       #$FFF2    ; data destination
                    ldb       #14       ; 7 vectors to copy
L0067               lda       ,y+       ; load A from ,y+
                    sta       ,x+       ; store A at ,x+
                    decb                ; decrement B
                    bne       L0067     ; branch if zero is clear to L0067
                  ENDC

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

                    lda       #'K       ; debug: signal that we are in Kernel
                    jsr       <D.BtBug  ; call routine at <D.BtBug

                    leax      >S.Flip1,pc ; setup change to task 1 vector
                    stx       <D.Flip1  ; store X at <D.Flip1

* Setup System calls
                    leay      >SysCalls,pc ; load y with address of table, below
                    lbsr      SysSvc    ; copy table below into dispatch table

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

********************************************************************
* The DAT image is a data structure that is used to indicate which
* Dynamic Address Translator (DAT) mapping registers are in use.

* [NAC HACK 2016Dec06] future: I should be able to make this 7 if not 8..
* DAT.BlCt-ROMCount-RAMCount = 8 - 1 - 1 = 6
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

********************************************************************
* The system memory map is a data structure that is used to manage
* the 64Kbyte CPU address space. D.SysMem is a pointer to the start
* of the map (set to $0900, above) and the map is a fixed size of
* 256 bytes. Each byte in the map represents one 256-byte "page"
* (256 entries of 256 bytes is 64Kbytes). A value of 0 indicates
* an unused page and since the system block has been initialised
* to 0 (above) every page starts off marked as unused.
* See "Level 2 flags" in os9.d for other byte values.

* Update the system memory map to reserve the area used for
* global memory.
                    ldx       <D.SysMem ; get system memory map pointer
                    ldb       <D.CCStk  ; get MSB of top of CC memory
* X indexes the system memory map.
* B represents the number of 256-byte pages available.
* Walk through the map changing the corresponding elements
* from 0 (the initialisation value) to 1 (indicating 'used'). Higher
* entries in the map remain as 0 (indicating 'unused').
L0104               inc       ,x+       ; mark it as used
                    decb                ; done?
                    bne       L0104     ; no, go back till done

********************************************************************
* Deduce how many 8Kbyte blocks of physical memory are available and
* update the memory block map end pointer (D.BlkMap+2) accordingly
                    ldx       <D.BlkMap ; get ptr to 8k block map
                    inc       <KrnBlk,x ; mark block holding kernel as used
                  IFNE    mc09    ; begin conditional assembly for mc09
                    inc       <$00,x    ; mark block $00 as used (global memory)
* For mc09 memory size is 512Kbyte or 1MByte. For now, hard-wire
* the memory size to 512Kbyte.
                    ldd       #$0240    ; load D from #$0240
                  ELSE
* This memory sizing routine uses location at X (D.BlkMap) as
* a scratch location. At exit, it leaves this location at 1 which
* has the (until now) undocumented side-effect of marking block 0
* as used. It is essential that this is done because that block
* does need to be reserved; it's used for global memory.
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
                  ENDC
                    std       <D.BlkMap+2 ; save memory block map end pointer

********************************************************************
* Initial reservation of blocks in the memory block map. Code above
* reserved one block (block 0) for global memory and one block
* (usually block $3F) for krn.
*
* At this point, the value of D indicates the memory size:
* $0210 - 128k  ( 16, 8KByte blocks)
* $0220 - 256k  ( 32, 8KByte blocks)
* $0240 - 512k  ( 64, 8KByte blocks)
* $0280 - 1024k (128, 8KByte blocks)
* $0300 - 2048k (256, 8KByte blocks)
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

* ASSUME: however we got here, B=0
L0170               ldx       #Bt.Start ; start address of the boot track in memory
                    lda       #18       ; size of the boot track is $1800

* Verify the modules in the boot track and update/build a module index
                    lbsr      I.VBlock  ; call local routine I.VBlock
                    bsr       L01D2     ; go mark system map

* See if init module is in memory already
L01B0               leax      <init,pc  ; point to 'Init' module name
                    bsr       link      ; try & link it
                    bcc       L01BF     ; no error, go on
L01B8               os9       F$Boot    ; error linking init, try & load boot file
                    bcc       L01B0     ; got it, try init again
                    bra       L01CE     ; error, re-booting do D.Crash

* So far, so good. Save pointer to init module and execute krnp2
L01BF               stu       <D.Init   ; save init module pointer
                    lda       Feature1,u ; get feature byte #1 from init module
                    bita      #CRCOn    ; cRC feature on?
                    beq       ShowI     ; if not, continue
                    inc       <D.CRC    ; else inc. CRC flag

ShowI               lda       #'i       ; debug: signal that we found the init module
                    jsr       <D.BtBug  ; call routine at <D.BtBug

L01C1               leax      <krnp2,pc ; point to its name
                    bsr       link      ; try to link it
                    bcc       L01D0     ; it worked, execute it
                    os9       F$Boot    ; it doesn't exist try re-booting
                    bcc       L01C1     ; no error's, let's try to link it again
L01CE               jmp       <D.Crash  ; obviously can't do it, crash machine
L01D0               jmp       ,y        ; execute krnp2

* Update the system memory map to reserve the area used by the kernel
L01D2               ldx       <D.SysMem ; get system memory map pointer
                    ldd       #NotRAM*256+(Bt.Start/256) ; B = MSB of start of the boot
                    abx                 ; point to Bt.Start - start of boot track
                    comb                ; we have $FF-$ED pages to mark as inUse
                    sta       b,x       ; mark I/O as not RAM
L01DF               lda       #RAMinUse ; get inUse flag
L01E1               sta       ,x+       ; mark this page
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
                    fdb       FFreeLB-*-2 ; define word value(s) FFreeLB-*-2
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
                  IFNE    mc09    ; begin conditional assembly for mc09
                    orcc      #IntMasks ; shutdown interupts while we do this

                    lda       #5        ; load A from #5
                    bsr       prepmmu   ; select block 5

                    lda       1,u       ; get first block
                    ldb       3,u       ; get a second just in case of overlap

                    sta       >MMUDAT   ; set value for block 5

                    lda       #6        ; load A from #6
                    bsr       prepmmu   ; select block 6

                    stb       >MMUDAT   ; set value for block 6

                    ldb       #R$Size   ; load B from #R$Size
Loop5               lda       ,x+       ; load A from ,x+
                    sta       ,y+       ; store A at ,y+
                    decb                ; decrement B
                    bne       Loop5     ; branch if zero is clear to Loop5
                    ldx       <D.SysDAT ; remap the blocks we took out

                    lda       #5        ; load A from #5
                    bsr       prepmmu   ; select block 5

                    lda       $0B,x     ; load A from $0B,x
                    ldb       $0D,x     ; load B from $0D,x

                    sta       >MMUDAT   ; restore value for block 5
                    lda       #6        ; load A from #6
                    bsr       prepmmu   ; select block 6

                    stb       >MMUDAT   ; restore value for block 6
                  ELSE
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
                    endif
                    puls      cc,x,y,u,pc ; restore & return

                  IFNE    mc09    ; begin conditional assembly for mc09
* A holds the MMU register we want to select. Merge in
* the stored value and write the result to MMUADR. This is
* a desperate attempt to save a few bytes..
prepmmu
                    ora       <D.TINIT  ; merge with current MMU mask
                    sta       >MMUADR   ; select block
                    rts                 ; return to caller
                    endif


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

                    use       fsrqmem.asm ; include source file fsrqmem.asm

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

                    use       fnproc.asm ; include source file fnproc.asm

* The following routines must appear no earlier than $E00 when assembled, as
* they have to always be in the vector RAM pages ($FE00-$FEFF)

                  IFNE    mc09    ; begin conditional assembly for mc09
* Copied nicer automatic padding from ccbkrn
* CCB: this code (after pad) start assembling *before* 0xfe00, it's too big to
* fit into the memory as stated above!!!!

PAD                 fill      $00,($0dfc-*) ; fill memory to ensure the above happens
                  ELSE
PAD                 fill      $00,($0df1-*) ; fill memory to ensure the above happens
                  ENDC


* Default routine for D.SysIRQ
S.SysIRQ
                    lda       <D.SSTskN ; get current task's GIME task # (0 or 1)
                    beq       FastIRQ   ; use super-fast version for system state
                    clr       <D.SSTskN ; clear out memory copy (task 0)
                    jsr       [>D.SvcIRQ] ; (Normally routine in Clock calling D.Poll)
                    inc       <D.SSTskN ; save task # for system state
                  IFNE    mc09    ; begin conditional assembly for mc09
                    lda       #$40      ; mc09 MMU Task 1
                    ora       <D.TINIT  ; merge task bit into Shadow version
                    sta       <D.TINIT  ; update shadow
                    sta       >MMUADR   ; save to MMU as well
                  ELSE
                    lda       #1        ; task 1
                    ora       <D.TINIT  ; merge task bit into Shadow version
                    sta       <D.TINIT  ; update shadow
                    sta       >DAT.Task ; save to GIME as well
                  ENDC
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
                    beq       Fst2      ; if task 0, we're done
                  IFNE    mc09    ; begin conditional assembly for mc09
                    lda       #$40      ; [NAC HACK 2016Dec07] hope only 1 bit means anything..
                    ora       <D.TINIT  ; merge task bit into Shadow version
                    sta       <D.TINIT  ; update shadow
                    sta       >MMUADR   ; save to MMU
                  ELSE
                    ora       <D.TINIT  ; merge task bit into Shadow version
                    sta       <D.TINIT  ; update shadow
                    sta       >DAT.Task ; save to GIME as well
                  ENDC
Fst2                leas      ,u        ; stack ptr=U & return
                    rti                 ; return from interrupt

* Switch to new process, X=Process descriptor pointer, U=Stack pointer
L0E4C               equ       *         ; define assembler symbol L0E4C
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #$01,<D.TINIT ; switch GIME shadow to user state
                    lda       <D.TINIT  ; load A from <D.TINIT
                  ELSE
                    lda       <D.TINIT  ; load A from <D.TINIT
                  IFNE    mc09    ; begin conditional assembly for mc09
                    ora       #$40      ; merge #$40 into A
                  ELSE
                    ora       #$01      ; merge #$01 into A
                  ENDC
                    sta       <D.TINIT  ; store A at <D.TINIT
                  ENDC
                  IFNE    mc09    ; begin conditional assembly for mc09
                    sta       >MMUADR   ; save it to MMU
                  ELSE
                    sta       >DAT.Task ; save it to GIME
                  ENDC
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
                  IFNE    mc09    ; begin conditional assembly for mc09
                    orb       #$40      ; merge #$40 into B
                  ELSE
                    orb       #$01      ; merge #$01 into B
                  ENDC
                    stb       <D.TINIT  ; store B at <D.TINIT
                  ENDC
                  IFNE    mc09    ; begin conditional assembly for mc09
                    stb       >MMUADR   ; store B at >MMUADR
                  ELSE
                    stb       >DAT.Task ; store B at >DAT.Task
                  ENDC
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
                  IFNE    mc09    ; begin conditional assembly for mc09
                    ora       #$40      ; force TR=1 in mc09 MMU
                  ELSE
                    ora       #$01      ; force TR=1
                  ENDC
                    sta       <D.TINIT  ; store A at <D.TINIT
                  ENDC
                  IFNE    mc09    ; begin conditional assembly for mc09
                    sta       >MMUADR   ; save it to MMU register
                  ELSE
                    sta       >DAT.Task ; save it to GIME register
                  ENDC
                    inc       <D.SSTskN ; increment system state task number
                    rti                 ; return

* Setup MMU in task 1, B=Task # to swap to, shifted left 1 bit
L0E8D               cmpb      <D.Task1N ; are we going back to the same task
                    beq       L0EA3     ; without the DAT image changing?
                    stb       <D.Task1N ; nope, save current task in map type 1
                  IFNE    mc09    ; begin conditional assembly for mc09
                    ldu       <D.TskIPt ; get task image pointer table
                    ldu       b,u       ; get address of DAT image

                    lda       <D.TINIT  ; load A from <D.TINIT
                    adda      #8        ; 1st MMU value for process's mappings

* COME HERE FROM FALLTSK
* Update 8 MMU mappings.
* A = MMUADR value for 1st MMU register to update
* U = address of DAT image to update into MMU
L0E93               ldb       #8        ; number of MMU mappings to set
                    pshs      b         ; squirrel it away
                    leau      1,u       ; point to actual MMU block for 1st mapping

L0E9B               ldb       ,u++      ; get a bank, point to next bank
                    std       >MMUADR   ; save it to MMU
                    inca                ; next mapsel value
                    dec       ,s        ; decrement ,s
                    bne       L0E9B     ; no, keep going
                    leas      1,s       ; done. Tidy up the stack
                  ELSE
                    ldx       #DAT.Regs+8 ; get MMU start register for process's
                    ldu       <D.TskIPt ; get task image pointer table
                    ldu       b,u       ; get address of DAT image
* COME HERE FROM FALLTSK
* Update 8 MMU mappings.
* X = address of 1st DAT MMU register to update
* U = address of DAT image to update into MMU
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
                    leas      1,s       ; done. Tidy up the stack
                  ENDC
                  ENDC
L0EA3               rts                 ; return

* Execute FIRQ vector (called from $FEF4)
FIRQVCT             ldx       #D.FIRQ   ; get DP offset of vector
                    bra       L0EB8     ; go execute it

* Execute IRQ vector (called from $FEF7)
IRQVCT              orcc      #IntMasks ; disable IRQ's
                    ldx       #D.IRQ    ; get DP offset of vector

* Execute interrupt vector, B=DP Vector offset
                  IFNE    mc09    ; begin conditional assembly for mc09
L0EB8               lda       #$a0      ; [NAC HACK 2016Dec08] add equates..
                    sta       >MMUADR   ; force to System State (Task 0)
                    clra                ; clear A
                    tfr       a,dp      ; aSSUME: A=0 from earlier
MapGrf              equ       *         ; come here from elsewhere, too.
                    lda       <D.TINIT  ; load A from <D.TINIT
                    anda      #$BF      ; force TR=0 in mc09 MMU shadow
                    sta       <D.TINIT  ; store A at <D.TINIT
MapT0               sta       >MMUADR   ; come here from elsewhere, too.
                    jmp       [,x]      ; execute it
                  ELSE
* Execute interrupt vector, B=DP Vector offset
L0EB8               clra                ; (faster than CLR >$xxxx)
                    sta       >DAT.Task ; force to Task 0 (system state)
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       0,dp      ; setup DP
                  ELSE
                    tfr       a,dp      ; aSSUME: A=0 from earlier
                  ENDC
MapGrf              equ       *         ; come here from elsewhere, too.
                  IFNE    H6309   ; begin conditional assembly for H6309
                    aim       #$FE,<D.TINIT ; switch GIME shadow to system state
                    lda       <D.TINIT  ; set GIME again just in case timer is used
                  ELSE
                    lda       <D.TINIT  ; load A from <D.TINIT
                    anda      #$FE      ; mask A with #$FE
                    sta       <D.TINIT  ; store A at <D.TINIT
                  ENDC
MapT0               sta       >DAT.Task ; come here from elsewhere, too.
                    jmp       [,x]      ; execute it
                  ENDC



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
                  IFNE    mc09    ; begin conditional assembly for mc09
* [NAC HACK 2016Dec08] confused? it says, "go to map type 1" but
* it is setting a 0.
                    lda       #$a0      ; [NAC HACK 2016Dec08] add equates..
                    sta       >MMUADR   ; force to System State (Task 0)
                    clra                ; clear A
                  ELSE
* NOTE: Alan DeKok claims that this is BAD.  It crashed Colin McKay's
* CoCo 3.  Instead, we should do a clra/sta >DAT.Task.
*         clr   >DAT.Task       go to map type 1
                    clra                ; clear A
                    sta       >DAT.Task ; store A at >DAT.Task
                  ENDC
* set DP to zero
                  IFNE    H6309   ; begin conditional assembly for H6309
                    tfr       0,dp      ; transfer register value 0,dp
                  ELSE
                    tfr       a,dp      ; aSSUME: A=0 from earlier
                  ENDC

* These lines add a total of 81 addition cycles to each SWI(2,3) call,
* and 36 bytes+12 for R$Size in the constant page at $FExx
*  It takes no more time for a SWI(2,3) from system state than previously,
* ... and adds 14 cycles to each SWI(2,3) call from grfdrv... not a problem.
* For processes that re-vector SWI, SWI3, it adds 81 cycles.  BUT SWI(3)
* CANNOT be vectored to L0EBF cause the user SWI service routine has been
* changed
                    lda       <D.TINIT  ; get map type flag
                  IFNE    mc09    ; begin conditional assembly for mc09
                    bita      #$40      ; check it without changing it in mc09 MMU
                  ELSE
                    bita      #$01      ; check it without changing it
                  ENDC

* Change to LBEQ R.SysSvc to avoid JMP [,X]
* and add R.SysSvc STA >DAT.Task ???
                    beq       MapT0     ; in map 0: restore hardware and do system service
                    tst       <D.SSTskN ; get system state 0,1
                    bne       MapGrf    ; if in grfdrv, go to map 0 and do system service

* the preceding few lines are necessary, as all SWI's still pass thru
* here before being vectored to the system service routine... which
* doesn't copy the stack from user state.
                  IFNE    mc09    ; begin conditional assembly for mc09
                    sta       >MMUADR   ; go to map type X again to get user's stack
                  ELSE
                    sta       >DAT.Task ; go to map type X again to get user's stack
                  ENDC
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
* because it doesn't get "switched out" no matter the contents of the
* MMU registers.
SWIStack
                    fcc       /REGISTER STACK/    same # bytes as R$Size for 6809
                  IFNE    H6309   ; begin conditional assembly for H6309
                    fcc       /63/                if 6309, add two more bytes of space
                  ENDC

                    fcb       $55       ; d.ErrRst

                  IFNE    mc09    ; begin conditional assembly for mc09
* For Multicomp09, the processor vectors are in RAM so they can be loaded
* with the service addresses directly, instead of requiring another indirection
* The vectors are set up by a data table copy of CPUVect
                  ELSE
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
                  ENDC

* The final byte (eg the NOP after bra NMIVCT) should be at offset $EFF
* and will end up at address $FEFF in physical memory. If any code above
* is changed, you must inspect the listing and adjust the addresses at
* the label PAD.
                    end
