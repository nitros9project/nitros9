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

                    use       defsfile

* defines for customizations
Revision            set       9                   module revision
Edition             set       19                  module Edition
Where               equ       $F000               absolute address of where Kernel starts in memory

                    mod       eom,MName,Systm,ReEnt+Revision,entry,0

                    *         CCB                 Change: module name changes to CCBKrn
MName               fcs       /CCBKrn/
                    fcb       Edition

                    *         CCB                 Change: added a automagic "fill" directive
                    *         between             the end of the kernel module, proper, and the fe page code
                    *         see                 way down. Manually refilling the empty space after each
                    *         code                change was a pain and error prone.  BG

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
                    fdb       L0CD2+Where         D.Clock absolute address at the start
                    fdb       XSWI3+Where         D.XSWI3
                    fdb       XSWI2+Where         D.XSWI2
                    fdb       D.Crash             D.XFIRQ crash on an FIRQ
                    fdb       XIRQ+Where          D.XIRQ
                    fdb       XSWI+Where          D.XSWI
                    fdb       D.Crash             D.XNMI crash on an NMI
                    fdb       $0055               D.ErrRst ??? Not used as far as I can tell
                    fdb       Sys.Vec+Where       Initial Kernel system call vector
DisSize             equ       *-DisTable
* DO NOT ADD ANYTHING BETWEEN THESE 2 TABLES: see code using 'SubSiz', below
LowSub              equ       $0160               start of low memory subroutines
SubStrt             equ       *
* D.Flip0 - switch to system task 0
R.Flip0             equ       *
                    ifne      H6309
                    aim       #$FE,<D.TINIT       map type 0
                    lde       <D.TINIT            another 2 bytes saved if GRFDRV does: tfr cc,e
                    ste       >DAT.Task           and we can use A here, instead of E
                    else
                    pshs      a
                    lda       <D.TINIT
                    anda      #$FE                force TR=0
                    sta       <D.TINIT
                    sta       >DAT.Task
                    puls      a
                    endc
                    clr       <D.SSTskN
                    tfr       x,s
                    tfr       a,cc
                    rts
SubSiz              equ       *-SubStrt
* Don't add any code here: See L0065, below.
* Interrupt service routine
Vectors             jmp       [<-(D.SWI3-D.XSWI3),x] (-$10) (Jmp to 2ndary vector)

* Let's start by initializing system page
entry               equ       *
                    *         CCB                 Addition - save stacked OS9Boot size and make a dummy kernel printer
                    pulu      d                   pull boot file size from CoCoBoot and
                    std       <D.BtSz             save to direct page for later use
                    inc       <D.Boot             mark boot attempted flag
                    inc       <D.Speed            mark high speed
                    lds       #$1fff              reset system stack (s/b 0x2000 ?!?!)
                    lda       #$7e                put code in DP so rest of kernel can
                    sta       <D.BtBug            call kernel printing routine
                    leax      BtDebug,pc
                    stx       <D.BtBug+1
                    sta       <D.Crash            and do the same with the kernel crash
                    leax      Crash,pc            code
                    stx       <D.Crash+1
                    bra       CCBEND              jump over new kprint & crash routines

                    *         This                is a kernel print routine
                    *         This                is added to replace the same routine found in "rel.asm"
                    *         so                  we get debug output.
                    *         Takes               A - charactor to print
                    *         modifies            - nothing
BtDebug             pshs      cc,d,x              save the register
                    orcc      #IntMasks           turn IRQ's off
                    ldb       #$3b                block to map in
                    stb       >DAT.Regs           map the boot screen into block 0
                    ldx       >$0002              where to put the bytes
                    sta       ,x+                 put the character on-screen
                    stx       >$0002              save updated address
                    clr       >DAT.Regs           map block 0 in again
                    puls      cc,d,x,pc           restore and return
                    *         This                routine just prints "!" and loops forever
Crash               lda       #'!                 print a "!"
                    jsr       <D.BtBug
e                   bra       e                   loop forever
CCBEND
                    *         end                 of CCB Addition

                    *         This                code clears the rest of the low block
                    *         rel.asm/cocoboot    has cleared the DP already.
                    ifne      H6309
                    ldq       #$01001f00          start address to clear & # bytes to clear
                    leay      <entry+2,pc         point to a 0
                    tfm       y,d+
                    std       <D.CCStk            set pointer to top of global memory to $2000
                    lda       #$01                set task user table to $0100
                    else
                    ldx       #$100
                    ldy       #$2000-$100
                    clra
                    clrb
L001C               std       ,x++
                    leay      -2,y
                    bne       L001C
                    stx       <D.CCStk            Set pointer to top of global memory to $2000
                    inca                          D = $0100
                    endc

* Setup system direct page variables
                    std       <D.Tasks            set Task Structure pointer to 0x100
                    addb      #$20                set Task image table pointer to $0120
                    std       <D.TskIPt
                    clrb                          set memory block map pointer to $0200
                    inca
                    std       <D.BlkMap
                    addb      #$40                set second block map pointer to $0240
                    std       <D.BlkMap+2
                    clrb                          set system service dispatch table
                    inca                          pointer to 0x300
                    std       <D.SysDis
                    inca                          set user dispatch table pointer to $0400
                    std       <D.UsrDis
                    inca                          set process descriptor block pointer to $0500
                    std       <D.PrcDBT
                    inca                          set system process descriptor pointer to $0600
                    std       <D.SysPrc
                    std       <D.Proc             set user process descriptor pointer to $0600
                    adda      #$02                set stack pointer to $0800
                    tfr       d,s
                    inca                          set system stack base pointer to $0900
                    std       <D.SysStk
                    std       <D.SysMem           set system memory map ptr $0900
                    inca                          set module directory start ptr to $0a00
                    std       <D.ModDir
                    std       <D.ModEnd           set module directory end ptr to $0a00
                    adda      #$06                set secondary module directory start to $1000
                    std       <D.ModDir+2
                    std       <D.ModDAT           set module directory DAT pointer to $1000
                    std       <D.CCMem            set pointer to beginning of global memory to $1000
* In following line, CRC=ON if it is STA <D.CRC, CRC=OFF if it is a STB <D.CRC
                    stb       <D.CRC              set CRC checking flag to off

* Initialize interrupt vector tables, move pointer data down to DP
* CCB Change:
* this line was an error?
*       leay    <DisTable,pcr
                    leay      DisTable,pcr        point to table of absolute vector addresses
*
*
                    ldx       #D.Clock            where to put it in memory
                    ifne      H6309
                    ldf       #DisSize            size of the table - E=0 from TFM, above
                    tfm       y+,x+               move it over
                    else
                    ldb       #DisSize
l@
                    lda       ,y+                 load a byte from source
                    sta       ,x+                 store a byte to dest
                    decb                          bump counter
                    bne       l@                  loop if we're not done
                    endc

* initialize D.Flip0 routine in low memory, move function down to low
* memory.
* Y=ptr to R.Flip0 already
*         leay  >R.Flip0,pc
                    ldu       #LowSub             move to 0x160
                    stu       <D.Flip0            store fuction pointer to DP area
                    ifne      H6309
                    ldf       #SubSiz             size of it
                    tfm       y+,u+               copy it over
                    else
                    ldb       #SubSiz
Loop2               lda       ,y+                 load a byte from source
                    sta       ,u+                 and save to destination
                    decb                          bump counter
                    bne       Loop2               loop if not done
                    endc

*         leau   <Vectors,pc   point to vector
* fill in the secondard interrupt vectors to all point to
                    tfr       y,u                 move the pointer to a faster register
L0065               stu       ,x++                Set all IRQ vectors to go to Vectors for now
                    cmpx      #D.NMI
                    bls       L0065

* Initialize user interupt vectors
                    ldx       <D.XSWI2            Get SWI2 (os9 command) service routine pointer
                    stx       <D.UsrSvc           Save it as user service routine pointer
                    ldx       <D.XIRQ             Get IRQ service routine pointer
                    stx       <D.UsrIRQ           Save it as user IRQ routine pointer

                    leax      >SysCall,pc         Setup System service routine entry vector
                    stx       <D.SysSvc
                    stx       <D.XSWI2

                    leax      >S.SysIRQ,pc        Setup system IRQ service vector
                    stx       <D.SysIRQ
                    stx       <D.XIRQ

                    leax      >S.SvcIRQ,pc        Setup in system IRQ service vector
                    stx       <D.SvcIRQ
                    leax      >S.Poll,pc          Setup interrupt polling vector
                    stx       <D.Poll             ORCC #$01;RTS
                    leax      >S.AltIRQ,pc        Setup alternate IRQ vector: pts to an RTS
                    stx       <D.AltIRQ

                    lda       #'K                 --- in Kernel
                    jsr       <D.BtBug            ---

                    leax      >S.Flip1,pc         Setup change to task 1 vector
                    stx       <D.Flip1

* Setup System calls
                    leay      >SysCalls,pc        load y with address of table, below
                    lbsr      InstallSvc          copy table below into dispatch table

* Initialize system process descriptor
                    ldu       <D.PrcDBT           get process table pointer
                    ldx       <D.SysPrc           get system process pointer

* These overlap because it is quicker than trying to strip hi byte from X
                    stx       ,u                  save it as first process in table
                    stx       1,u                 save it as the second as well
                    ifne      H6309
                    oim       #$01,P$ID,x         Set process ID to 1 (inited to 0)
                    oim       #SysState,P$State,x Set to system state (inited to 0)
                    else
                    ldd       #$01*256+SysState
                    sta       P$ID,x              set PID to 1
                    stb       P$State,x           set state to system (*NOT* zero )
                    endc
                    clra                          set System task as task #0
                    sta       <D.SysTsk
                    sta       P$Task,x
                    coma                          Setup its priority & age ($FF)
                    sta       P$Prior,x
                    sta       P$Age,x
                    leax      <P$DATImg,x         point to DAT image
                    stx       <D.SysDAT           save it as a pointer in DP
* actually, since block 0 is tfm'd to be zero, we can skip the next 2 lines
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       ,x++                initialize 1st block to 0 (for this DP)

* Dat.BlCt-ROMCount-RAMCount
                    lda       #$06                initialize the rest of the blocks to be free
                    ldu       #DAT.Free
L00EF               stu       ,x++                store free "flag"
                    deca                          bump counter
                    bne       L00EF               loop if not done

                    ldu       #KrnBlk             Block where the kernel will live
                    stu       ,x

                    ldx       <D.Tasks            Point to task user table
                    inc       ,x                  mark first 2 in use (system & GrfDrv)
                    inc       1,x

* Setup system memory map
                    ldx       <D.SysMem           Get system memory map pointer
                    ldb       <D.CCStk            Get MSB of top of CC memory
L0104               inc       ,x+                 Mark it as used
                    decb                          Done?
                    bne       L0104               No, go back till done

* Calculate memory size
                    *         CCB                 Comment:
                    *         This                code only modifies 2 bytes in the x0 blocks (x=doesn't cares)
                    *         which               at worst will be our DP. Should not effect CCB's prior load of
                    *         OS9Boot             it can only be loaded into block x1 through x6 and 3f so
                    *         we                  should be safe.
                    ldx       <D.BlkMap           get ptr to 8k block map
                    inc       <KrnBlk,x           mark block holding kernel as used
                    ifne      H6309
                    ldq       #$00080100          e=Marker, D=Block # to check
L0111               asld                          get next block #
                    stb       >DAT.Regs+5         Map block into block 6 of my task
                    ste       >-$6000,x           save marker to that block
                    cmpe      ,x                  did it ghost to block 0?
                    bne       L0111               No, keep going till ghost is found
                    stb       <D.MemSz            Save # 8k mem blocks that exist
                    addr      x,d                 add number of blocks to block map start
                    else
                    ldd       #$0008
L0111               aslb
                    rola
                    stb       >DAT.Regs+5
                    pshs      a
                    lda       #$01
                    sta       >-$6000,x
                    cmpa      ,x
                    puls      a
                    bne       L0111
                    stb       <D.MemSz
                    pshs      x
                    addd      ,s++
                    endc
                    std       <D.BlkMap+2         save block map end pointer

* [D] at this point will contain 1 of the following:
* $0210 - 128k
* $0220 - 256k
* $0240 - 512k
* $0280 - 1024k
* $0300 - 2048k
                    bitb      #%00110000          block above 128K-256K?
                    beq       L0170               yes, no need to mark block map
                    tstb                          2 meg?
                    beq       L0170               yes, skip this
* Mark blocks from 128k-256K to block $3F as NOT RAM
                    abx                           add maximum block number to block map start
                    leax      -1,x                Skip good blocks that are RAM
                    lda       #NotRAM             Not RAM flag
                    subb      #$3F                Calculate # blocks to mark as not RAM
L0127               sta       ,x+                 Mark them all
                    decb
                    bne       L0127

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
                    ifeq      1
* See if init module is in memory already
L01B0               leax      <init,pc            point to 'Init' module name
                    bsr       link                try & link it
                    bcc       L01BF               no error, go on
L01B8               os9       F$Boot              error linking init, try & load boot file
                    bcc       L01B0               got it, try init again
                    bra       L01CE               error, re-booting do D.Crash
L01BF               stu       <D.Init             Save init module pointer
                    lda       Feature1,u          Get feature byte #1 from init module
                    bita      #CRCOn              CRC feature on?
                    beq       ShowI               if not, continue
                    inc       <D.CRC              else inc. CRC flag
ShowI               lda       #'i                 found init module
                    jsr       <D.BtBug

L01C1               leax      <krnp2,pc           Point to it's name
                    bsr       link                Try to link it
                    bcc       L01D0               It worked, execute it
                    os9       F$Boot              It doesn't exist try re-booting
                    bcc       L01C1               No error's, let's try to link it again
L01CE               jmp       <D.Crash            obviously can't do it, crash machine
L01D0               jmp       ,y                  execute krnp2
                    endc

* CCB we'll replace above with this:
                    ldd       <D.BtSz             get the size of OS9Boot file
                    addd      #$fff               add size of krn and round to higher size
                    clrb
                    pshs      d                   save on stack
                    os9       F$SRqMem            get memory - U is our starting address
                    stu       <D.BtPtr            save this just incase something uses it
                    tfr       u,x                 setup x for vblock
                    puls      d                   setup d for vblock with stacked size
                    lbsr      I.VBlock            verify OS9Boot
                    *         this                was copied from f$boot
                    *         I                   dont know why we need to do this.  Wouldn't
                    *         f$srqmem            do this for us?!?!  But the system won't boot without.
                    ldx       <D.SysDAT           get system DAT pointer
                    ldb       $0D,x               get highest allocated block number
                    incb                          allocate block 0, too
                    ldx       <D.BlkMap           point to the memory block map
                    bsr       L01DF               and go mark the blocks as used
                    *         end                 of copy from f$boot
                    leax      <init,pc            point to 'Init' module name
                    bsr       link                try & link it
L01BF               stu       <D.Init             Save init module pointer
                    lda       Feature1,u          Get feature byte #1 from init module
                    bita      #CRCOn              CRC feature on?
*       beq     ShowI           if not, continue
                    inc       <D.CRC              else inc. CRC flag
ShowI               lda       #'i                 found init module
                    jsr       <D.BtBug
L01C1               leax      <krnp2,pc           Point to it's name
                    bsr       link                Try to link it
*e      bra     e
L01D0               jmp       ,y                  execute krnp2


* CCB - End of change


* Mark kernel in system memory map as used memory (256 byte blocks)
* L01D2 ldx     <D.SysMem       Get system mem ptr
*       * CCB Change - only mark KRN as used (BOOT and REL don't exist)
*       ldd     #NotRAM*256+(Bt.Start/256)      B = MSB of start of the boot
*       ldd     #NotRam*256+(Where/256)         B = MSB of start of REL
                    *         CCB                 Change end
*       abx                     point to Bt.Start - start of boot track
*       comb                    we have $FF-$ED pages to mark as used
*       sta     b,x             Mark I/O as not RAM

* Mark kernel and boot file in system memory as used - there is no
* reason this is a routine anymore - only one place calls it, but
* some speghetti is here... one of the IRQ routines "borrows" this rts.
L01DF               lda       #RAMinUse           get in use flag
L01E1               sta       ,x+                 save it
                    decb                          done?
                    bne       L01E1               no, keep going
                    ldx       <D.BlkMap           get pointer to start of block map
                    sta       <KrnBlk,x           mark kernel block as RAMinUse, instead of ModInBlk
S.AltIRQ            rts                           return

* Link module pointed to by X
link                lda       #Systm              Attempt to link system module
                    os9       F$Link
                    rts

init                fcs       'Init'
krnp2               fcs       'krnp2'

* Service vector call pointers
SysCalls            fcb       F$Link
                    fdb       FLink-*-2
                    fcb       F$PrsNam
                    fdb       FPrsNam-*-2
                    fcb       F$CmpNam
                    fdb       FCmpNam-*-2
                    fcb       F$CmpNam+SysState
                    fdb       FSCmpNam-*-2
                    fcb       F$CRC
                    fdb       FCRC-*-2
                    fcb       F$SRqMem+SysState
                    fdb       FSRqMem-*-2
                    fcb       F$SRtMem+SysState
                    fdb       FSRtMem-*-2
                    fcb       F$AProc+SysState
                    fdb       FAProc-*-2
                    fcb       F$NProc+SysState
                    fdb       FNProc-*-2
                    fcb       F$VModul+SysState
                    fdb       FVModul-*-2
                    fcb       F$SSvc+SysState
                    fdb       FSSvc-*-2
                    fcb       F$SLink+SysState
                    fdb       FSLink-*-2
                    fcb       F$Boot+SysState
                    fdb       FBoot-*-2
                    fcb       F$BtMem+SysState
                    fdb       FSRqMem-*-2
                    ifne      H6309
                    fcb       F$CpyMem
                    fdb       FCpyMem-*-2
                    endc
                    fcb       F$Move+SysState
                    fdb       FMove-*-2
                    fcb       F$AllImg+SysState
                    fdb       FAllImg-*-2
                    fcb       F$SetImg+SysState
                    fdb       FSetImg-*-2
                    fcb       F$FreeLB+SysState
                    fdb       FSFreeLB-*-2
                    fcb       F$FreeHB+SysState
                    fdb       FFreeHB-*-2
                    fcb       F$AllTsk+SysState
                    fdb       FAllTsk-*-2
                    fcb       F$DelTsk+SysState
                    fdb       FDelTsk-*-2
                    fcb       F$SetTsk+SysState
                    fdb       FSetTsk-*-2
                    fcb       F$ResTsk+SysState
                    fdb       FResTsk-*-2
                    fcb       F$RelTsk+SysState
                    fdb       FRelTsk-*-2
                    fcb       F$DATLog+SysState
                    fdb       FDATLog-*-2
                    fcb       F$LDAXY+SysState
                    fdb       FLDAXY-*-2
                    fcb       F$LDDDXY+SysState
                    fdb       FLDDDXY-*-2
                    fcb       F$LDABX+SysState
                    fdb       FLDABX-*-2
                    fcb       F$STABX+SysState
                    fdb       FSTABX-*-2
                    fcb       F$ELink+SysState
                    fdb       FELink-*-2
                    fcb       F$FModul+SysState
                    fdb       FFModul-*-2
                    fcb       F$VBlock+SysState
                    fdb       FVBlock-*-2
                    ifne      H6309
                    fcb       F$DelRAM
                    fdb       FDelRAM-*-2
                    endc
                    fcb       $80

* SWI3 vector entry
XSWI3               lda       #P$SWI3             point to SWI3 vector
                    fcb       $8C                 skip 2 bytes

* SWI vector entry
XSWI                lda       #P$SWI              point to SWI vector
                    ldx       <D.Proc             get process pointer
                    ldu       a,x                 user defined SWI[x]?
                    beq       L028E               no, go get option byte
GoUser              lbra      L0E5E               Yes, go call users's routine

* SWI2 vector entry
XSWI2               ldx       <D.Proc             get current process descriptor
                    ldu       P$SWI2,x            any SWI vector?
                    bne       GoUser              yes, go execute it

* Process software interupts from a user state
* Entry: X=Process descriptor pointer of process that made system call
*        U=Register stack pointer
L028E               ldu       <D.SysSvc           set system call processor to system side
                    stu       <D.XSWI2
                    ldu       <D.SysIRQ           do the same thing for IRQ's
                    stu       <D.XIRQ
                    ifne      H6309
                    oim       #SysState,P$State,x mark process as in system state
                    else
                    lda       P$State,x
                    ora       #SysState
                    sta       P$State,x
                    endc
* copy register stack to process descriptor
                    sts       P$SP,x              save stack pointer
                    leas      (P$Stack-R$Size),x  point S to register stack destination

                    ifne      H6309
                    leau      R$Size-1,s          point to last byte of destination register stack
                    leay      -1,y                point to caller's register stack in $FEE1
                    ldw       #R$Size             size of the register stack
                    tfm       y-,u-
                    leau      ,s                  needed because the TFM is u-, not -u (post, not pre)
                    else
* Note!  R$Size MUST BE an EVEN number of bytes for this to work!
                    leau      R$Size,s            point to last byte of destination register stack
                    lda       #R$Size/2
Loop3               ldx       ,--y
                    stx       ,--u
                    deca
                    bne       Loop3
                    endc
                    andcc     #^IntMasks
* B=function code already from calling process: DON'T USE IT!
                    ldx       R$PC,u              get where PC was from process
                    leax      1,x                 move PC past option
                    stx       R$PC,u              save updated PC to process
* execute function call
                    ldy       <D.UsrDis           get user dispatch table pointer
                    lbsr      L033B               go execute option
                    ifne      H6309
                    aim       #^IntMasks,R$CC,u   Clear interrupt flags in caller's CC
                    else
                    lda       R$CC,u
                    anda      #^IntMasks
                    sta       R$CC,u
                    endc
                    ldx       <D.Proc             get current process ptr
                    ifne      H6309
                    aim       #^(SysState+TimOut),P$State,x Clear system & timeout flags
                    else
                    lda       P$State,x
                    anda      #^(SysState+TimOut)
                    sta       P$State,x
                    endc

* Check for image change now, which lets stuff like F$MapBlk and F$ClrBlk
* do the short-circuit thing, too.  Adds about 20 cycles to each system call.
                    lbsr      TstImg              it doesn't hurt to call this twice
                    lda       P$State,x           get current state of the process
                    ora       <P$Signal,x         is there a pending signal?
                    sta       <D.Quick            save quick return flag
                    beq       AllClr              if nothing's have changed, do full checks

DoFull              bsr       L02DA               move the stack frame back to user state
                    lbra      L0D80               go back to the process

* add ldu P$SP,x, etc...
AllClr              equ       *
                    ifne      H6309
                    inc       <D.QCnt
                    aim       #$1F,<D.QCnt
                    beq       DoFull              every 32 system calls, do the full check
                    ldw       #R$Size             --- size of the register stack
                    ldy       #Where+SWIStack     --- to stack at top of memory
                    orcc      #IntMasks
                    tfm       u+,y+               --- move the stack to the top of memory
                    else
                    lda       <D.QCnt
                    inca
                    anda      #$1F
                    sta       <D.QCnt
                    beq       DoFull
                    ldb       #R$Size
                    ldy       #Where+SWIStack
                    orcc      #IntMasks
Loop4               lda       ,u+
                    sta       ,y+
                    decb
                    bne       Loop4
                    endc
                    lbra      BackTo1             otherwise simply return to the user

* Copy register stack from user to system
* Entry: U=Ptr to Register stack in process dsc
L02CB               pshs      cc,x,y,u            preserve registers
                    ldb       P$Task,x            get task #
                    ldx       P$SP,x              get stack pointer
                    lbsr      L0BF3               calculate block offset (only affects A&X)
                    leax      -$6000,x            adjust pointer to where memory map will be
                    bra       L02E9               go copy it

* Copy register stack from system to user
* Entry: U=Ptr to Register stack in process dsc
L02DA               pshs      cc,x,y,u            preserve registers
                    ldb       P$Task,x            get task # of destination
                    ldx       P$SP,x              get stack pointer
                    lbsr      L0BF3               calculate block offset (only affects A&X)
                    leax      -$6000,x            adjust pointer to where memory map will be
                    exg       x,y                 swap pointers & copy
* Copy a register stack
* Entry: X=Source
*        Y=Destination
*        A=Offset into DAT image of stack
*        B=Task #
L02E9               leau      a,u                 point to block # of where stack is
                    lda       1,u                 get first block
                    ldb       3,u                 get a second just in case of overlap
                    orcc      #IntMasks           shutdown interupts while we do this
                    std       >DAT.Regs+5         map blocks in
                    ifne      H6309
                    ldw       #R$Size             get size of register stack
                    tfm       x+,y+               copy it
                    else
                    ldb       #R$Size
Loop5               lda       ,x+
                    sta       ,y+
                    decb
                    bne       Loop5
                    endc
                    ldx       <D.SysDAT           remap the blocks we took out
                    lda       $0B,x
                    ldb       $0D,x
                    std       >DAT.Regs+5
                    puls      cc,x,y,u,pc         restore & return

* Process software interupts from system state
* Entry: U=Register stack pointer
SysCall             leau      ,s                  get pointer to register stack
                    lda       <D.SSTskN           Get system task # (0=SYSTEM, 1=GRFDRV)
                    clr       <D.SSTskN           Force to System Process
                    pshs      a                   Save the system task number
                    lda       ,u                  Restore callers CC register (R$CC=$00)
                    tfr       a,cc                make it current
                    ldx       R$PC,u              Get my caller's PC register
                    leax      1,x                 move PC to next position
                    stx       R$PC,u              Save my caller's updated PC register
                    ldy       <D.SysDis           get system dispatch table pointer
                    bsr       L033B               execute system call
                    puls      a                   restore system state task number
                    lbra      L0E2B               return to process

* Entry: X = system call vector to jump to
Sys.Vec             jmp       ,x                  execute service call

* Execute system call
* Entry: B=Function call #
*        Y=Function dispatch table pointer (D.SysDis or D.UsrDis)
L033B
                    lslb                          is it a I/O call? (Also multiplys by 2 for offset)
                    bcc       L0345               no, go get normal vector
* Execute I/O system calls
                    ldx       IOEntry,y           get IOMan vector
* Execute the system call
L034F               pshs      u                   preserve register stack pointer
                    jsr       [D.SysVec]          perform a vectored system call
                    puls      u                   restore pointer
L0355               tfr       cc,a                move CC to A for stack update
                    bcc       L035B               go update it if no error from call
                    stb       R$B,u               save error code to caller's B
L035B               ldb       R$CC,u              get callers CC, R$CC=$00
                    ifne      H6309
                    andd      #$2FD0              [A]=H,N,Z,V,C [B]=E,F,I
                    orr       b,a                 merge them together
                    else
                    anda      #$2F                [A]=H,N,Z,V,C
                    andb      #$D0                [B]=E,F,I
                    pshs      b
                    ora       ,s+
                    endc
                    sta       R$CC,u              return it to caller, R$CC=$00
                    rts

* Execute regular system calls
L0345
                    clra                          clear MSB of offset
                    ldx       d,y                 get vector to call
                    bne       L034F               it's initialized, go execute it
                    comb                          set carry for error
                    ldb       #E$UnkSvc           get error code
                    bra       L0355               return with it

                    use       fssvc.asm

                    use       flink.asm

                    use       fvmodul.asm

                    use       ffmodul.asm

                    use       fprsnam.asm

                    use       fcmpnam.asm

                    use       ccbfsrqmem.asm

*         use   fallram.asm


                    ifne      H6309
                    use       fdelram.asm
                    endc

                    use       fallimg.asm

                    use       ffreehb.asm

                    use       fdatlog.asm

                    use       fld.asm

                    ifne      H6309
                    use       fcpymem.asm
                    endc

                    use       fmove.asm

                    use       fldabx.asm

                    use       falltsk.asm

                    use       faproc.asm

* System IRQ service routine
XIRQ                ldx       <D.Proc             get current process pointer
                    sts       P$SP,x              save the stack pointer
                    lds       <D.SysStk           get system stack pointer
                    ldd       <D.SysSvc           set system service routine to current
                    std       <D.XSWI2
                    ldd       <D.SysIRQ           set system IRQ routine to current
                    std       <D.XIRQ
                    jsr       [>D.SvcIRQ]         execute irq service
                    bcc       L0D5B

                    ldx       <D.Proc             get current process pointer
                    ldb       P$Task,x
                    ldx       P$SP,x              get it's stack pointer

                    pshs      u,d,cc              save some registers
                    leau      ,s                  point to a 'caller register stack'
                    lbsr      L0C40               do a LDB 0,X in task B
                    puls      u,d,cc              and now A ( R$A,U ) = the CC we want

                    ora       #IntMasks           disable it's IRQ's
                    lbsr      L0C28               save it back
L0D5B               orcc      #IntMasks           shut down IRQ's
                    ldx       <D.Proc             get current process pointer
                    tst       <D.QIRQ             was it a clock IRQ?
                    lbne      L0DF7               if not, do a quick return

                    lda       P$State,x           Get it's state
                    bita      #TimOut             Is it timed out?
                    bne       L0D7C               yes, wake it up
* Update active process queue
                    ldu       #(D.AProcQ-P$Queue) point to active process queue
                    ldb       #Suspend            get suspend flag
L0D6A               ldu       P$Queue,u           get a active process pointer
                    beq       L0D78
                    bitb      P$State,u           is it suspended?
                    bne       L0D6A               yes, go to next one in chain
                    ldb       P$Prior,x           get current process priority
                    cmpb      P$Prior,u           do we bump this one?
                    blo       L0D7C

L0D78               ldu       P$SP,x
                    bra       L0DB9

L0D7C               anda      #^TimOut
                    sta       P$State,x

L0D80               equ       *
L0D83               bsr       L0D11               activate next process

                    use       ccbfnproc.asm

* The following routines must appear no earlier than $E00 when assembled, as
* they have to always be in the vector RAM page ($FE00-$FEFF)

* CCB: this code (after pad) start assembling *before* 0xfe00, it's too big to
* fit into the memory as stated above!!!!

PAD                 fill      $00,($0df1-*)       fill memory to ensure the above happens
* Default routine for D.SysIRQ
S.SysIRQ
                    lda       <D.SSTskN           Get current task's GIME task # (0 or 1)
                    beq       FastIRQ             Use super-fast version for system state
                    clr       <D.SSTskN           Clear out memory copy (task 0)
                    jsr       [>D.SvcIRQ]         (Normally routine in Clock calling D.Poll)
                    inc       <D.SSTskN           Save task # for system state
                    lda       #1                  Task 1
                    ora       <D.TINIT            Merge task bit's into Shadow version
                    sta       <D.TINIT            Update shadow
                    sta       >DAT.Task           Save to GIME as well & return
                    bra       DoneIRQ             Check for error and exit

FastIRQ             jsr       [>D.SvcIRQ]         (Normally routine in Clock calling D.Poll)
DoneIRQ             bcc       L0E28               No error on IRQ, exit
                    ifne      H6309
                    oim       #IntMasks,0,s       Setup RTI to shut interrupts off again
                    else
                    lda       ,s
                    ora       #IntMasks
                    sta       ,s
                    endc
L0E28               rti

* return from a system call
L0E29               clra                          Force System task # to 0 (non-GRDRV)
L0E2B               ldx       <D.SysPrc           Get system process dsc. ptr
                    lbsr      TstImg              check image, and F$SetTsk (PRESERVES A)
                    orcc      #IntMasks           Shut interrupts off
                    sta       <D.SSTskN           Save task # for system state
                    beq       Fst2                If task 0, skip subroutine
                    ora       <D.TINIT            Merge task bit's into Shadow version
                    sta       <D.TINIT            Update shadow
                    sta       >DAT.Task           Save to GIME as well & return
Fst2                leas      ,u                  Stack ptr=U & return
                    rti

* Switch to new process, X=Process descriptor pointer, U=Stack pointer
L0E4C               equ       *
                    ifne      H6309
                    oim       #$01,<D.TINIT       switch GIME shadow to user state
                    lda       <D.TINIT
                    else
                    lda       <D.TINIT
                    ora       #$01
                    sta       <D.TINIT
                    endc
                    sta       >DAT.Task           save it to GIME
                    leas      ,y                  point to new stack
                    tstb                          is the stack at SWISTACK?
                    bne       MyRTI               no, we're doing a system-state rti

                    ifne      H6309
                    ldf       #R$Size             E=0 from call to L0E8D before
                    ldu       #Where+SWIStack     point to the stack
                    tfm       u+,y+               move the stack from top of memory to user memory
                    else
                    ldb       #R$Size
                    ldu       #Where+SWIStack     point to the stack
RtiLoop             lda       ,u+
                    sta       ,y+
                    decb
                    bne       RtiLoop
                    endc
MyRTI               rti                           return from IRQ


* Execute routine in task 1 pointed to by U
* comes from user requested SWI vectors
L0E5E               equ       *
                    ifne      H6309
                    oim       #$01,<D.TINIT       switch GIME shadow to user state
                    ldb       <D.TINIT
                    else
                    ldb       <D.TINIT
                    orb       #$01
                    stb       <D.TINIT
                    endc
                    stb       >DAT.Task
                    jmp       ,u

* Flip to task 1 (used by GRF/WINDInt to switch to GRFDRV) (pointed to
*  by <D.Flip1). All regs are already preserved on stack for the RTI
S.Flip1             ldb       #2                  get Task image entry numberx2 for Grfdrv (task 1)
                    bsr       L0E8D               copy over the DAT image
                    ifne      H6309
                    oim       #$01,<D.TINIT
                    lda       <D.TINIT            get copy of GIME Task side
                    else
                    lda       <D.TINIT
                    ora       #$01
                    sta       <D.TINIT
                    endc
                    sta       >DAT.Task           save it to GIME register
                    inc       <D.SSTskN           increment system state task number
                    rti                           return

* Setup MMU in task 1, B=Task # to swap to, shifted left 1 bit
L0E8D               cmpb      <D.Task1N           are we going back to the same task
                    beq       L0EA3               without the DAT image changing?
                    stb       <D.Task1N           nope, save current task in map type 1
                    ldx       #DAT.Regs+8         get MMU start register for process's
                    ldu       <D.TskIPt           get task image pointer table
                    ldu       b,u                 get address of DAT image
L0E93               leau      1,u                 point to actual MMU block
                    ifne      H6309
                    lde       #4                  get # banks/2 for task
                    else
                    lda       #4
                    pshs      a
                    endc
L0E9B               lda       ,u++                get a bank
                    ldb       ,u++                and next one
                    std       ,x++                Save it to MMU
                    ifne      H6309
                    dece                          done?
                    else
                    dec       ,s
                    endc
                    bne       L0E9B               no, keep going
                    ifeq      H6309
                    leas      1,s
                    endc
L0EA3               rts                           return

* Execute FIRQ vector (called from $FEF4)
FIRQVCT             ldx       #D.FIRQ             get DP offset of vector
                    bra       L0EB8               go execute it

* Execute IRQ vector (called from $FEF7)
IRQVCT              orcc      #IntMasks           disasble IRQ's
                    ldx       #D.IRQ              get DP offset of vector

* Execute interrupt vector, B=DP Vector offset
L0EB8               clra                          (faster than CLR >$xxxx)
                    sta       >DAT.Task           Force to Task 0 (system state)
                    ifne      H6309
                    tfr       0,dp                setup DP
                    else
                    tfr       a,dp
                    endc
MapGrf              equ       *
                    ifne      H6309
                    aim       #$FE,<D.TINIT       switch GIME shadow to system state
                    lda       <D.TINIT            set GIME again just in case timer is used
                    else
                    lda       <D.TINIT
                    anda      #$FE
                    sta       <D.TINIT
                    endc
MapT0               sta       >DAT.Task
                    jmp       [,x]                execute it

* Execute SWI3 vector (called from $FEEE)
SWI3VCT             orcc      #IntMasks           disable IRQ's
                    ldx       #D.SWI3             get DP offset of vector
                    bra       SWICall             go execute it

* Execute SWI2 vector (called from $FEF1)
SWI2VCT             orcc      #IntMasks           disasble IRQ's
                    ldx       #D.SWI2             get DP offset of vector

* This routine is called from an SWI, SWI2, or SWI3
* saves 1 cycle on system-system calls
* saves about 200 cycles (calls to I.LDABX and L029E) on grfdrv-system,
*  or user-system calls.
SWICall             ldb       [R$PC,s]            get callcode of the system call
* NOTE: Alan DeKok claims that this is BAD.  It crashed Colin McKay's
* CoCo 3.  Instead, we should do a clra/sta >DAT.Task.
*         clr   >DAT.Task       go to map type 1
                    clra
                    sta       >DAT.Task
* set DP to zero
                    ifne      H6309
                    tfr       0,dp
                    else
                    tfr       a,dp
                    endc

* These lines add a total of 81 addition cycles to each SWI(2,3) call,
* and 36 bytes+12 for R$Size in the constant page at $FExx
*  It takes no more time for a SWI(2,3) from system state than previously,
* ... and adds 14 cycles to each SWI(2,3) call from grfdrv... not a problem.
* For processes that re-vector SWI, SWI3, it adds 81 cycles.  BUT SWI(3)
* CANNOT be vectored to L0EBF cause the user SWI service routine has been
* changed
                    lda       <D.TINIT            get map type flag
                    bita      #$01                check it without changing it

* Change to LBEQ R.SysSvc to avoid JMP [,X]
* and add R.SysSvc STA >DAT.Task ???
                    beq       MapT0               in map 0: restore hardware and do system service
                    tst       <D.SSTskN           get system state 0,1
                    bne       MapGrf              if in grfdrv, go to map 0 and do system service

* the preceding few lines are necessary, as all SWI's still pass thru
* here before being vectored to the system service routine... which
* doesn't copy the stack from user state.
                    sta       >DAT.Task           go to map type X again to get user's stack
* a byte less, a cycle more than ldy #$FEED-R$Size, or ldy #$F000+SWIStack
                    leay      <SWIStack,pc        where to put the register stack: to $FEDF
                    tfr       s,u                 get a copy of where the stack is
                    ifne      H6309
                    ldw       #R$Size             get the size of the stack
                    tfm       u+,y+               move the stack to the top of memory
                    else
                    pshs      b
                    ldb       #R$Size
Looper              lda       ,u+
                    sta       ,y+
                    decb
                    bne       Looper
                    puls      b
                    endc
                    bra       L0EB8               and go from map type 1 to map type 0

* Execute SWI vector (called from $FEFA)
SWIVCT              ldx       #D.SWI              get DP offset of vector
                    bra       SWICall             go execute it

* Execute NMI vector (called from $FEFD)
NMIVCT              ldx       #D.NMI              get DP offset of vector
                    bra       L0EB8               go execute it

* The end of the kernel module is here
                    emod
eom                 equ       *

* What follows after the kernel module is the register stack, starting
* at $FEDD (6309) or $FEDF (6809).  This register stack area is used by
* the kernel to save the caller's registers in the $FEXX area of memory
* because it doesn't* get "switched out" no matter the contents of the
* MMU registers.
SWIStack
                    fcc       /REGISTER STACK/    same # bytes as R$Size for 6809
                    ifne      H6309
                    fcc       /63/                if 6309, add two more spaces
                    endc

                    fcb       $55                 D.ErrRst

* This list of addresses ends up at $FEEE after the kernel track is loaded
* into memory.  All interrupts come through the 6809 vectors at $FFF0-$FFFE
* and get directed to here.  From here, the BRA takes CPU control to the
* various handlers in the kernel.
                    bra       SWI3VCT             SWI3 vector comes here
                    nop
                    bra       SWI2VCT             SWI2 vector comes here
                    nop
                    bra       FIRQVCT             FIRQ vector comes here
                    nop
                    bra       IRQVCT              IRQ vector comes here
                    nop
                    bra       SWIVCT              SWI vector comes here
                    nop
                    bra       NMIVCT              NMI vector comes here
                    nop

                    end
