********************************************************************
* krn - NitrOS-9 Level 2 Kernel
*
* $Id$
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
*
*  19r10   2019/11/15-2019/12/26  L. Curtis Boyle
* Optimized register stack copies on 6809 in 4 spots (Loop5, RtiLoop, Looper
*   & Loop4)
*   Saves over 70 cycles per system call that switches between user &
*   system states
* Changed F$Move to use D.IRQTmp to eliminate some TFR's, and changed it so
*   pshs cc/puls cc replace with orc #IntMask/andcc ^#IntMasks (faster)
* Also changed it to pulu routine again (for >64 byte copies, 14 cycles
*   faster per 8 bytes copied)
* Shrunk 6309 code by 1 byte in F$VModul
* 6309-Removed 2 BRN's from F$LDAXY, as they were not 2.01 source, and
*   don't appear to useful since F$LDDDXY does the same type of MMU mapping
*   without delays.
* Moved F$CpyMem from KrnP2, which allows shortcut bsr calls to F$Move,etc. Much,
*   much faster. (6809)

*  20r00   2023/10/17  Boisy Gene Pitre
* Ported to the Foenix F256.

                    nam       krn
                    ttl       NitrOS-9 Level 2 Kernel

                    ifp1
                    use       defsfile
                    endc

* defines for customizations
Revision            set       00                  module revision
Edition             set       20                  module Edition

* The absolute address of where Kernel starts in memory.
                    ifne      f256
Where               equ       $EE00               F256
                    else
Where               equ       $F000               CoCo 3
                    endc

                    mod       eom,MName,Systm,ReEnt+Revision,entry,0

MName               fcs       /Krn/
                    fcb       Edition

* FILL - all unused bytes are now here
                    ifne      H6309
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www/
                    else
                    ifne      f256
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org /
                    fcc       /www.nitros9.org/
                    else
                    fcc       /www.nitr/
                    endc
                    endc

* The dispatch table.
* The kernel copies this to low RAM starting at D.Clock.
DisTable            fdb       L0CD2+Where         D.Clock absolute address at the start
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
* D.Flip0 - switch to system task 0.
R.Flip0             equ       *
                    ifne      H6309
                    aim       #$FE,<D.TINIT       map type 0
                    lde       <D.TINIT            another 2 bytes saved if GrfDrv does: tfr cc,e
                    ste       >DAT.Task           and we can use A here, instead of E
                    else
                    pshs      a                   save off A
                    lda       <D.TINIT            get the value from the shadow register
                    anda      #$FE                force the task register to 0
                    sta       <D.TINIT            save it back to the shadow register
                    sta       >DAT.Task           and to the DAT hardware
                    puls      a                   recover A
                    endc
                    clr       <D.SSTskN           clear the system task number
                    tfr       x,s                 transfer X to the stack
                    tfr       a,cc                and A to CC
                    rts
* Don't add any code here: See L0065, below.
SubSiz              equ       *-SubStrt
* Interrupt service routine
Vectors             jmp       [<-(D.SWI3-D.XSWI3),x] (-$10) (Jmp to 2ndary vector)

*>>>>>>>>>> F256 PORT
                    ifne      f256
* F256 crash code dumps the registers at the shadow RAM page in $FDXX and
* then loops forever
CrashCode
* Dump the registers.
                    orcc      #IntMasks           mask interrupts
                    pshs      u                   save U
                    ldu       #$20                point to where registers will go
                    pshu      x,s,pc              save X, S, PC (X just a placeholder)
                    pshu      cc,dp,d,x,y         push the rest of the registers
                    puls      d                   get U on the stack into D
                    std       8,u                 store it in the "hole" created earlier
                    ldd       #$DEAD              get a marker value so we can visually see the crash when dumping
                    pshu      d                   push it
* Copy state of MMU registers.
                    ldx       #MMU_MEM_CTRL       get the address of the MMU registers
                    ldy       #0                  point to the crash dump area
loop@               ldd       ,x++                get two source bytes
                    std       ,y++                and save them
                    cmpx      #$FFB0              are we at the end of the MMU register space?
                    blt       loop@               branch if not
* Branch forever.
forever@            bra       forever@            simply branch forever
                    endc
*<<<<<<<<<< F256 PORT

* The Kernel entry point.
entry               equ       *
* Initialize the system block (the lowest 8KB of memory).
*>>>>>>>>>> F256 PORT
                    ifne      f256
* F256-specific initialization to get the F256 to a sane state.
                    orcc      #IntMasks           mask interrupts
                    stx       $2000               stash pointer to bootfile in memory
                    sty       $2002               stash size of bootfile
                    ldd       #$FF00              A = $FF, B = $00
                    tfr       b,dp                transfer 0 to direct page
                    sta       INT_MASK_0          A = $FF; mask all set 0 interrupts
                    sta       INT_MASK_1          A = $FF; mask all set 1 interrupts
                    sta       INT_PENDING_0       A = $FF; clear any pending set 0 interrupts
                    sta       INT_PENDING_1       A = $FF; clear any pending set 1 interrupts
* Set up DAT registers. Here, B = 0
                    ldx       #DAT.Regs           point X to the DAT registers
loop@               stb       ,x+                 write 8K bank to DAT to bank register
                    incb                          increment B
                    cmpb      #8                  are we done?
                    bne       loop@               branch if not

* The F256 allows for both $FDXX and $FFFX to be held constant regardless of the
* state of the MMU DAT registers. This feature is turned on by two bits that
* expose internal RAM of those areas.
* When the kernel loads in RAM, we must copy $FDXX into this internal RAM by
* flipping bit 0 in the I/O control register back and forth.
                    ldx       #$FD00              point to the shadow RAM area
                    ldb       MMU_IO_CTRL         get the control byte
l@                  andb      #~%00000001         clear the FDXX bit to disable shadow RAM
                    stb       MMU_IO_CTRL         turn off the FDXX internal RAM bit
                    lda       ,x                  get the source byte
                    orb       #%00000011          set the FDXX bit to enable shadow RAM (also turn on FFFX  bit)
                    stb       MMU_IO_CTRL         turn on the FDXX internal RAM bit
                    sta       ,x+                 save byte to internal RAM
                    cmpx      #$FE00              are we at the end yet?
                    bne       l@                  branch if not

* The bit for FFFX is also on now. Copy the known Level 2 vectors.
                    ldx       #$FFF2              load the vector destination
                    ldd       #$FDEE              start at the first vector value
l@                  std       ,x++                store the vector value in the destination
                    cmpx      #$0000              are we done?
                    beq       done@               branch if so
                    addd      #$0003              else add 3
                    bra       l@                  and do again
done@               ldx       #$0000              start clearing at this address
                    ldy       #$2000              for this many bytes
*<<<<<<<<<< F256 PORT
                    else
* REL has cleared page 0 already, so start at address $100.
                    ifne      H6309
                    ldq       #$01001f00          start address to clear & # bytes to clear
                    leay      <entry+2,pc         point to a 0
                    tfm       y,d+
                    std       <D.CCStk            set pointer to top of global memory to $2000
                    lda       #$01                set task user table to $0100
                    else
                    ldx       #$100               start clearing at this address
                    ldy       #$2000-$100         for this many bytes
                    endc
                    endc

                    clra                          set D
                    clrb                          to $0000
l@                  std       ,x++                now clear memory 16 bits at a time
                    leay      -2,y                decrement the counter
                    bne       l@                  and continue until done
                    stx       <D.CCStk            set pointer to top of global memory to $2000
                    inca                          set D to $0100

*>>>>>>>>>> F256 PORT
* Use <D.Crash to store a crash routine that we can use for debugging.
                    ifne      f256
                    pshs      b                   save B onto the stack
                    ldb       #$7E                get the JMP instruction op-code
                    stb       <D.Crash            and save it at D.Crash
                    leax      CrashCode,pcr       then get the address of the crash code
                    stx       <D.Crash+1          and store it at D.Crash+1
* F256 doesn't use D.BtBug. We put an RTS here just in case it's called somewhere.
                    ldb       #$39                put RTS instruction
                    stb       <D.BtBug            in D.BtBug since we don't use it
                    puls      b                   recover B from the stack
                    endc
*<<<<<<<<<< F256 PORT

* Set up system variables in DP
                    std       <D.Tasks            set the task structure pointer to $0100
                    addb      #$20                D is now $0120
                    std       <D.TskIPt           set the task image table pointer
                    clrb                          D is now $0100

********************************************************************
* The memory block map is a data structure that kernel uses to manage
* physical memory. Physical memory is assigned in 8KB "blocks".
* Kernel reserves 256 bytes for this map; therefore, the maximum physical
* memory size is 256*8KB=2MB.
* D.BlkMap is a pointer to the start of the map (set to $0200, below).
* D.BlkMap+2 is a pointer to the end of the map.
* Rather than simply setting it to $0300, the memory sizing routine sets
* the end pointer.
* Presumably, this makes it faster to search for unused pages, and also acts
* as a mechanism to avoid assigning non-existent memory. A value of 0 indicates
* an unused block. Since the system block is initialized to $0000 above, every
* block starts off marked as unused. The initial reservation of blocks occurs
* below, after the memory sizing.
* See "Level 2 flags" in os9.d for other byte values.

                    inca                          D is now $0200
                    std       <D.BlkMap           save this as the block map pointer
                    addb      #$40                D is now $0240
                    std       <D.BlkMap+2         save this as the end map pointer
                    clrb                          D is now $0200
                    inca                          D is now $0300
                    std       <D.SysDis           set the system service dispatch table pointer
                    inca                          D is now $0400
                    std       <D.UsrDis           set the user dispatch table pointer
                    inca                          D is now $0500
                    std       <D.PrcDBT           set the process descriptor block pointer
                    inca                          D is now $0600
                    std       <D.SysPrc           set the system process descriptor pointer
                    std       <D.Proc             set the user process descriptor pointer
                    adda      #$02                D is now $0800
                    tfr       d,s                 set the stack pointer
                    inca                          D is now $0900
                    std       <D.SysStk           set the system stack base pointer
                    std       <D.SysMem           set the system memory map pointer
                    inca                          D is now $0A00
                    std       <D.ModDir           set the module directory start pointer
                    std       <D.ModEnd           set the module directory end pointer
                    adda      #$06                D is now $1000
                    std       <D.ModDir+2         set the secondary module directory start pointer
                    std       <D.ModDAT           set the module directory DAT pointer
                    std       <D.CCMem            set the start of global memory pointer
* In following line, CRC=ON if it is STA <D.CRC, CRC=OFF if it is a STB <D.CRC
                    stb       <D.CRC              set the CRC checking flag to off

*>>>>>>>>>> F256 PORT
                    ifne      f256
                    ldx       $2000               get pointer to bootfile in memory stashed earlier
                    stx       <D.BtPtr            save it in globals
                    ldx       $2002               get bootfile size stashed earlier
                    stx       <D.BtSz             save it in globals
                    endc
*<<<<<<<<<< F256 PORT

* Initialize the interrupt vector tables, and move pointer data down to page 0.
*>>>>>>>>>> F256 PORT
                    ifne      f256
                    leay      >DisTable,pcr       point to the table of absolute vector addresses
                    else
*<<<<<<<<<< F256 PORT
                    leay      <DisTable,pcr       point to the table of absolute vector addresses
                    endc
                    ldx       #D.Clock            and get the address to put it in memory
                    ifne      H6309
                    ldf       #DisSize            get the size of the table; E=0 from TFM, above
                    tfm       y+,x+               move it over
                    else
                    ldb       #DisSize            get the size of the table
l@                  lda       ,y+                 load a byte from the source
                    sta       ,x+                 store a byte to the destination
                    decb                          bump up the counter
                    bne       l@                  loop if we're not done
                    endc

* Initialize D.Flip0 routine in low memory by copying the lump of code down from R.Flip0.
* ASSUME: Y is left pointing to R.Flip0 by the previous copy loop.
                    ldu       #LowSub             somewhere in block 0 that's never modified
                    stu       <D.Flip0            switch to system task 0
                    ifne      H6309
                    ldf       #SubSiz             get the code size to copy
                    tfm       y+,u+               then copy it over
                    else
                    ldb       #SubSiz             get the code size to copy
l@                  lda       ,y+                 load a byte from the source
                    sta       ,u+                 store a byte to the destination
                    decb                          bump up the countercounter
                    bne       l@                  loop if not done
                    endc

* Initialize secondary interrupt vectors to all point to vectors for now.
* ASSUME: Y is left pointing to vectors by the previous copy loop.
                    leau      ,y                  move the pointer to a faster register
l@                  stu       ,x++                set all IRQ vectors to go to vectors for now
                    cmpx      #D.NMI              are we at the end?
                    bls       l@                  branch if not

* Initialize user interrupt vectors.
                    ldx       <D.XSWI2            get the SWI2 (os9 command) service routine pointer
                    stx       <D.UsrSvc           save it as the user service routine pointer
                    ldx       <D.XIRQ             get the IRQ service routine pointer
                    stx       <D.UsrIRQ           save it as the user IRQ routine pointer
                    leax      >SysCall,pc         get the system state call entry point
                    stx       <D.SysSvc           store it in the system state service routine vector
                    stx       <D.XSWI2            and in the cross-SWI2 vector
                    leax      >S.SysIRQ,pc        get the system state IRQ entry point
                    stx       <D.SysIRQ           store it in the system state IRQ service routine vector
                    stx       <D.XIRQ             and in the cross-IRQ vctor
                    leax      >S.SvcIRQ,pc        get the user state IRQ entry point
                    stx       <D.SvcIRQ           store it in the user state RIQ service routine vector
                    leax      >S.Poll,pc          get the IRQ polling routine entry point
                    stx       <D.Poll             and store it in the IRQ polling routine vector
                    leax      >S.AltIRQ,pc        get the alternate IRQ entry point
                    stx       <D.AltIRQ           and store it in the alternate IRQ polling routine vector
                    ifeq      f256
                    lda       #'K                 debug: signal that we are in Kernel
                    jsr       <D.BtBug            ---
                    endc
                    leax      >S.Flip1,pc         get the "flip 1" entry point
                    stx       <D.Flip1            and store it in the "flip 1" vector
* Setup system calls.
                    leay      >SysCalls,pc        point to the system call address table
                    lbsr      InstallSvc          and perform the installation
* Initialize the system process descriptor.
                    ldu       <D.PrcDBT           get the process table pointer
                    ldx       <D.SysPrc           and the system process pointer
* These overlap because it is quicker than trying to strip the high byte from X.
                    stx       ,u                  save it as the first process in table
                    stx       1,u                 save it as the second as well
                    ifne      H6309
                    oim       #$01,P$ID,x         set process ID to 1 (inited to 0)
                    oim       #SysState,P$State,x set to system state (inited to 0)
                    else
                    ldd       #$01*256+SysState   get the PID and system state flags
                    sta       P$ID,x              set the PID
                    stb       P$State,x           set state to system
                    endc
                    clra                          A = 0
                    sta       <D.SysTsk           set the system task as task #0
                    sta       P$Task,x            and in the system process descriptor
                    coma                          set up the priority & age ($FF)
                    sta       P$Prior,x           set the priority
                    sta       P$Age,x             and the age
                    leax      <P$DATImg,x         point to the DAT image
                    stx       <D.SysDAT           save it as a pointer in page 0
                    ifne      H6309
* actually, since block 0 is tfm'd to be zero, we can skip the next 2 lines
                    clrd                          D = 0
                    else
                    clra                          A = 0
                    clrb                          B = 0
                    endc
                    std       ,x++                initialize the first block to 0 (for this DP)

********************************************************************
* The DAT image is a data structure that indicates which
* Dynamic Address Translator (DAT) mapping registers are in use.
*>>>>>>>>>> F256 PORT
* Dat.BlCt-ROMCount-RAMCount = 8 - 1 = 7
                    ifne      f256
                    lda       #$07                initialize all rest of the blocks to be free
                    else
*<<<<<<<<<< F256 PORT
* Dat.BlCt-ROMCount-RAMCount = 8 - 1 - 1 = 6
                    lda       #$06                initialize the rest of the blocks to be free
                    endc
                    ldu       #DAT.Free           load the free marker
l@                  stu       ,x++                store it
                    deca                          bump up the counter
                    bne       l@                  loop if not done

* F256: we call F$SRqMem later on the entire bootfile which includes krn starting
* at Bt.Start. So we DON'T mark the kernel block as allocated in our DAT image.
                    ifeq      f256
                    ldu       #KrnBlk             get the block where the kernel resides
                    stu       ,x                  and save it in the last 8K slot
                    endc

                    ldx       <D.Tasks            point to the task user table
                    inc       ,x                  mark the 1st entry as used (system)
                    inc       1,x                 mark the 2nd entry as used (GrfDrv)

********************************************************************
* The system memory map is a data structure that manages the
* 64KB of CPU address space. D.SysMem points to the start of the
* (set to $0900, above). The map is a fixed size of 256 bytes. Each
* byte in the map represents one 256-byte "page" (256 entries of 256
* bytes is 64KB). A value of 0 indicates an unused page, and since the
* system block has been initialized to 0 above, every page starts off
* marked as unused.
* See "Level 2 flags" in os9.d for other byte values.

* Update the system memory map to reserve the area used for global memory.
                    ldx       <D.SysMem           get the system memory map pointer
                    ldb       <D.CCStk            get the MSB of the top of kernel memory
* X indexes the system memory map.
* B represents the number of 256-byte pages available.
* Walk through the map, changing the corresponding elements from 0
* (the initialization value) to 1 (indicating 'used'). Higher
* entries in the map remain as 0 (indicating 'unused').
L0104               inc       ,x+                 mark it as used
                    decb                          done?
                    bne       L0104               no, go back till done

*>>>>>>>>>> F256 PORT
                    ifne      f256
* We already know we have 512K of RAM, so we won't go through a memory
* sizing check.
                    ldx       <D.BlkMap           get the pointer to 8KB block map
                    ldd       #$0140              A = 1, B = $40 (512K of RAM)
                    sta       ,x                  mark block 0 as allocated
                    inca                          D = $240 (512K)
                    std       <D.BlkMap+2         save the newly computed memory block map end pointer
* For the F256 port, the entire bootfile is loaded into RAM by FEU, so we call
* F$SRqMem to allocate the memory we need (F$Boot would normally do this, but we
* don't use F$Boot on F256).
* Because FEU loads the bootfile into 8KB blocks starting DOWN from 7, we need
* to temporarly fake out the DAT block map to show lower blocks as allocated
* so that F$SRqMem (and F$AllImg) allocate the correct 8K blocks that contain
* the loaded bootfile.
                    ldb       <D.BtPtr            get the pointer to the bootfile
                    lsrb                          B = B / 2
                    lsrb                          B = B / 4
                    lsrb                          B = B / 8
                    lsrb                          B = B / 16
                    lsrb                          B = B / 32
                    decb
                    pshs      b                   save on the stack
                    lda       #RAMInUse           get the "RAM in use flag"
l@                  sta       b,x                 store the flag in the appropriate offset
                    decb                          decrement the counter
                    bne       l@                  branch if more
                    ldd       <D.BtSz             get the bootfile size
                    os9       F$SRqMem            allocate the needed amount of memory

                    clra                          set the "block free" flag
                    puls      b                   recover the offset we saved earlier on the stack
l@                  sta       b,x                 store the flag in the appropriate offset
                    decb                          decrement the counter
                    bne       l@                  branch if more
                    ldx       <D.BtPtr            get start address of the bootfile in memory
                    ldd       <D.BtSz             get MSB of bootfile size
                    else
*<<<<<<<<<< F256 PORT
********************************************************************
* Determine how many 8KB blocks of physical memory are available and
* update the memory block map end pointer (D.BlkMap+2) accordingly.
* This memory sizing routine uses the location at X (D.BlkMap) as
* a scratch location. At exit, it leaves this location at 1 which
* has the side-effect of marking block 0 as used. It is essential that
* this occurs, because that block needs to be reserved as it's used for
* global memory.
                    ldx       <D.BlkMap           get the pointer to 8KB block map
                    inc       <KrnBlk,x           mark the block holding kernel as used

                    ifne      H6309
                    ldq       #$00080100          E=Marker, D=Block # to check
L0111               asld                          get next block #
                    stb       >DAT.Regs+5         map block into block 6 of my task
                    ste       >-$6000,x           save marker to that block
                    cmpe      ,x                  did it ghost to block 0?
                    bne       L0111               no, keep going till ghost is found
                    stb       <D.MemSz            save # of 8KB memory blocks that exist
                    addr      x,d                 add number of blocks to block map start
                    else
                    ldd       #$0008              load the initial value
L0111               aslb                          B <= 1 (hi bit goes into carry, 0 goes into low bit)
                    rola                          A <= 1 (carry goes into low bit, hi bit goes into carry)
                    stb       >DAT.Regs+5         save B into the slot
                    pshs      a                   save A onto the stack
                    lda       #$01                get the test value
                    sta       >-$6000,x           save it in the offset value
                    cmpa      ,x                  compare against the value here
                    puls      a                   recover A
                    bne       L0111               branch if the previous comparison failed
                    stb       <D.MemSz            else we have our memory size now
                    pshs      x                   save X
                    addd      ,s++                add X into D and recover the stack
                    endc
                    std       <D.BlkMap+2         save the newly computed memory block map end pointer

********************************************************************
* Initial reservation of blocks in the memory block map. Code above
* reserved one block (block 0) for global memory and one block
* (usually block $3F) for Krn.
*
* At this point, the value of D indicates the memory size:
* $0210 = 128KB  ( 16 8KB blocks)
* $0220 = 256KB  ( 32 8KB blocks)
* $0240 = 512KB  ( 64 8KB blocks)
* $0280 = 1024KB (128 8KB blocks)
* $0300 = 2048KB (256 8KB blocks)
                    bitb      #%00110000          is the block above 128K-256K?
                    beq       L0170               yes, no need to mark block map
                    tstb                          is it 2 meg?
                    beq       L0170               yes, skip this
* Mark blocks from 128k-256K to block $3F as NOT RAM.
                    abx                           add the maximum block number to block map start address
                    leax      -1,x                skip good blocks that are RAM
                    lda       #NotRAM             load the "Not RAM" flag
                    subb      #$3F                calculate the number of blocks to mark as not RAM
l@                  sta       ,x+                 mark them all
                    decb                          are we done?
                    bne       l@                  not yet

* ASSUME: however we got here, B=0
L0170
                    ldx       #Bt.Start           start address of the boot track in memory
                    lda       #18                 size of the boot track is $1800
                    endc

* Verify the modules in the boot area and update/build a module index.
                    lbsr      I.VBlock            perform module validation
                    bsr       L01D2               then mark the system map

                    ifeq      f256
* BGP - Load bootfile and link to init. We no longer try to link to init first and then
* call F$Boot. This saves bytes.
                    os9       F$Boot              load bootfile here +BGP+
                    bcs       L01CE               error, go crash +BGP+
                    endc
                    leax      <init,pc            point to 'Init' module name
                    bsr       link                try & link it
                    bcs       L01CE               error, go crash

* BGP - Commented out the following lines since I moved F$Boot above
*                    bcc       L01BF               no error, go on
*L01B8               os9       F$Boot              error linking init, try & load boot file
*                    bcc       L01B0               got it, try init again
*                    bra       L01CE               error, re-booting do D.Crash

* So far, so good. Save the pointer to the init module and execute krnp2.
L01BF               stu       <D.Init             save the init module pointer
                    lda       Feature1,u          get feature byte #1 from the init module
                    bita      #CRCOn              is the CRC feature on?
                    beq       ShowI               if not, continue
                    inc       <D.CRC              else increment the CRC flag

ShowI
                    ifeq      f256
                    lda       #'i                 debug: signal that we found the init module
                    jsr       <D.BtBug            perform the action
                    endc

L01C1               leax      <krnp2,pc           point to krnp2's name
                    bsr       link                try to link it

* BGP - Removed the following lines as krnp2 is ALWAYS in the bootfile and F$Boot is called above.
* Also saves needed critical space since F$CpyMem is now part of krn.
*                    bcc       L01D0               branch if it worked
*                    os9       F$Boot              else it doesn't exist; try re-booting
* WARNING: the next line has the potential to infinitely loop if krnp2 is not in the
* bootfile that F$Boot loaded.
*                    bcc       L01C1               branch if no error, let's try to link it again
*

L01D0               jmp       ,y                  jump into krnp2

* BGP - This line was above L01D0 but now moved below since above lines are commented.
L01CE               jmp       <D.Crash            obviously can't do it, crash machine

* Update the system memory map to reserve the area the kernel uses.
L01D2               ldx       <D.SysMem           get the system memory map pointer
                    ifne      f256
                    lda       #NotRAM             get the "not RAM" flag
                    ldb       <D.BtPtr            and the boot pointer MSB
                    else
                    ldd       #NotRAM*256+(Bt.Start/256) B = MSB of start of the boot area
                    endc
                    abx                           point to Bt.Start - start of the boot area
                    comb                          we have $FF-$ED pages to mark as "RAM in use"
                    sta       b,x                 mark I/O as not RAM
L01DF               lda       #RAMinUse           get the "RAM in use" flag
L01E1               sta       ,x+                 mark this page
                    decb                          done?
                    bne       L01E1               no, keep going
                    ldx       <D.BlkMap           get the pointer to the start of the block map
                    sta       <KrnBlk,x           mark kernel block as "RAM in use", instead of "Module in block"
S.AltIRQ            rts                           return

* Link module pointed to by X
link                lda       #Systm              attempt to link to a system module
                    os9       F$Link              link to it
                    rts                           return

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
                    fcb       F$CpyMem
                    fdb       FCpyMem-*-2
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
                    IFNE      H6309+F256
                    fcb       F$DelRAM
                    fdb       FDelRAM-*-2
                    ENDC
                    fcb       $80

* SWI3 vector entry
XSWI3               lda       #P$SWI3             point to the SWI3 vector
                    fcb       $8C                 skip 2 bytes

* SWI vector entry
XSWI                lda       #P$SWI              point to the SWI vector
                    ldx       <D.Proc             get the current process descriptor
                    ldu       a,x                 is this a user defined SWI[x]?
                    beq       L028E               no, go get the option byte
GoUser              lbra      L0E5E               else call the users's routine

* SWI2 vector entry
XSWI2               ldx       <D.Proc             get the current process descriptor
                    ldu       P$SWI2,x            any SWI vector?
                    bne       GoUser              yes, go execute it

* Process software interrupts from a user state.
*
* Entry: X = The process descriptor pointer of process that made system call.
*        U = The register stack pointer.
L028E               ldu       <D.SysSvc           get the system call service vector
                    stu       <D.XSWI2            set the cross-SWI2 vector
                    ldu       <D.SysIRQ           get the interrupt service vector
                    stu       <D.XIRQ             set the cross-IRQ vector
                    ifne      H6309
                    oim       #SysState,P$State,x mark the process as in system state
                    else
                    lda       P$State,x           get the process' state
                    ora       #SysState           set the system state flag
                    sta       P$State,x           store it back in the process descriptor
                    endc
* Copy the register stack to the process descriptor.
                    sts       P$SP,x              save the stack pointer
                    leas      (P$Stack-R$Size),x  point S to the register stack destination
                    ifne      H6309
                    leau      R$Size-1,s          point to the last byte of the destination register stack
                    leay      -1,y                point to the caller's register stack in $FEE1
                    ldw       #R$Size             get size of the register stack
                    tfm       y-,u-               perform the transfer
                    leau      ,s                  needed because the TFM is u-, not -u (post, not pre)
                    else
* Note! R$Size MUST BE an EVEN number of bytes for this to work!
                    leau      R$Size,s            point to the last byte of the destination register stack
                    lda       #R$Size/2           get the number of words to copy in A
l@                  ldx       ,--y                get the source bytes
                    stx       ,--u                save them in the destination
                    deca                          decrement the counter
                    bne       l@                  branch until done
                    endc
                    andcc     #^IntMasks          unmask interrupts
* B = the function code already from calling process: DON'T USE IT!
                    ldx       R$PC,u              get where the program counter was from the process
                    leax      1,x                 move the program counter past the op-code
                    stx       R$PC,u              save updated the update program counter back
* Execute the system call.
                    ldy       <D.UsrDis           get the user dispatch table pointer
                    lbsr      L033B               go execute the op-code
                    ifne      H6309
                    aim       #^IntMasks,R$CC,u   unmask interrupts in the caller's CC
                    else
                    lda       R$CC,u              get the caller's CC
                    anda      #^IntMasks          unmask interrupts
                    sta       R$CC,u              and save it back
                    endc
                    ldx       <D.Proc             get the current process descriptor
                    ifne      H6309
                    aim       #^(SysState+TimOut),P$State,x turn off the system state and timeout flags
                    else
                    lda       P$State,x           get the process state
                    anda      #^(SysState+TimOut) turn off the system state and timeout flags
                    sta       P$State,x           and save it back
                    endc

* Check for image change now, which lets stuff like F$MapBlk and F$ClrBlk
* do the short-circuit thing, too. Adds about 20 cycles to each system call.
                    lbsr      TstImg              it doesn't hurt to call this twice
                    lda       P$State,x           get current state of the process
                    ora       <P$Signal,x         is there a pending signal?
                    sta       <D.Quick            save quick return flag
                    beq       AllClr              if nothing changed, do full checks

DoFull              bsr       L02DA               move the stack frame back to user state
                    lbra      L0D80               go back to the process

* add ldu P$SP,x, etc...
AllClr              equ       *
                    ifne      H6309
                    inc       <D.QCnt             increment the flag
                    aim       #$1F,<D.QCnt
                    beq       DoFull              every 32 system calls, do the full check
                    ldw       #R$Size             get the size of the register stack
                    ldy       #Where+SWIStack     and the stack at top of memory
                    orcc      #IntMasks           mask interrupts
                    tfm       u+,y+               move the stack to the top of memory
                    else
                    lda       <D.QCnt             get the flag
                    inca                          increment it
                    anda      #$1F                clear these bits
                    sta       <D.QCnt             and save it back
                    beq       DoFull              branch if zero
* NOTE: Need to preserve X here - needed for BackTo1 routine
*   (Currently in fnproc.asm). 145 cycles vs. original 213 cycles
                    ldb       #R$Size             else get the size of the register stack
                    ldy       #Where+SWIStack     and the stack at the top of memory
                    orcc      #IntMasks           mask interrupts
l@                  lda       ,u+                 get the source byte
                    sta       ,y+                 save it at the destination
                    decb                          decrement the counter
                    bne       l@                  branch if not done
                    endc
                    lbra      BackTo1             return to the user

* Copy the register stack from user to system.
*
* Entry: U = The pointer to the register stack in the process descriptor.
L02CB               pshs      cc,x,y,u            preserve registers
                    ldb       P$Task,x            get the task #
                    ldx       P$SP,x              and the stack pointer
                    lbsr      L0BF3               calculate the block offset (only affects A&X)
                    leax      -$6000,x            adjust the pointer to where the memory map will be
                    bra       L02E9               go copy it

* Copy the register stack from system to user.
*
* Entry: U = The pointer to the register stack in the process descriptor.
L02DA               pshs      cc,x,y,u            preserve registers
                    ldb       P$Task,x            get the task # of destination
                    ldx       P$SP,x              and the stack pointer
                    lbsr      L0BF3               calculate the block offset (only affects A&X)
                    leax      -$6000,x            adjust the pointer to where the memory map will be
                    exg       x,y                 swap pointers & copy

* Copy a register stack.
*
* Entry: X = The source register stack.
*        Y = The destination register stack.
*        A = The offset into the DAT image of stack.
*        B = The task number.
L02E9               leau      a,u                 point to the block number where stack is
                    lda       1,u                 get the first block
                    ldb       3,u                 get a second just in case of overlap
                    orcc      #IntMasks           shutdown interrupts while we do this
                    std       >DAT.Regs+5         map in the blocks
                    ifne      H6309
                    ldw       #R$Size             get the size of register stack
                    tfm       x+,y+               copy it
                    else
                    ldb       #R$Size/2           get the size of the register stack
l@                  ldu       ,x++                get the source bytes
                    stu       ,y++                and save them in the destination
                    decb                          decrement the counter
                    bne       l@                  branch if not done
                    endc
                    ldx       <D.SysDAT           get the system DAT pointer
                    lda       $0B,x               get the first block we took out
                    ldb       $0D,x               and the second
                    std       >DAT.Regs+5         and restore the DAT
                    puls      cc,x,y,u,pc         restore & return

* Process software interrupts from system state.
*
* Entry: U = The register stack pointer.
SysCall             leau      ,s                  get the pointer to the register stack
                    lda       <D.SSTskN           get the system task number (0 = system, 1 = GrfDrv)
                    clr       <D.SSTskN           force the system process
                    pshs      a                   save the system task number
                    lda       ,u                  restore the caller's CC register (R$CC = $00)
                    tfr       a,cc                make it current
                    ldx       R$PC,u              get my caller's PC register
                    leax      1,x                 move the PC to next position
                    stx       R$PC,u              save my caller's updated PC register
                    ldy       <D.SysDis           get the system dispatch table pointer
                    bsr       L033B               execute the system call
                    puls      a                   restore the system state task number
                    lbra      L0E2B               return to the process

* Entry: X = system call vector to jump to
Sys.Vec             jmp       ,x                  execute the service call

* Execute the system call.
*
* Entry: B = System call op-code
*        Y = System dispatch table pointer (D.SysDis or D.UsrDis)
L033B
                    lslb                          is it a I/O call? (also multiplies by 2 for offset)
                    bcc       L0345               no, go get normal vector
* Execute I/O system calls.
                    ldx       IOEntry,y           else get IOMan vector
* Execute the system call.
L034F               pshs      u                   preserve the register stack pointer
                    jsr       [D.SysVec]          perform a vectored system call
                    puls      u                   restore the pointer
L0355               tfr       cc,a                move CC to A for a stack update
                    bcc       L035B               go update it if no error from call
                    stb       R$B,u               save the error code to caller's B
L035B               ldb       R$CC,u              get the caller's CC, R$CC = $00
                    ifne      H6309
                    andd      #$2FD0              [A]=H,N,Z,V,C [B]=E,F,I
                    orr       b,a                 merge them together
                    else
                    anda      #$2F                [A]=H,N,Z,V,C
                    andb      #$D0                [B]=E,F,I
                    pshs      b                   save B on the stack
                    ora       ,s+                 OR A with it
                    endc
                    sta       R$CC,u              store it in the caller's CC, R$CC = $00
                    rts                           return

* Execute regular system calls
L0345
                    clra                          clear the MSB of the offset
                    ldx       d,y                 get the vector to call
                    bne       L034F               it's initialized, go execute it
                    comb                          set the carry for error
                    ldb       #E$UnkSvc           get the error code
                    bra       L0355               return with it

                    use       fssvc.asm

                    use       flink.asm

                    use       fvmodul.asm

                    use       ffmodul.asm

                    use       fprsnam.asm

                    use       fcmpnam.asm

                    use       fsrqmem.asm

                    IFNE      H6309+F256
                    use       fdelram.asm
                    ENDC

                    use       fallimg.asm

                    use       ffreehb.asm

                    use       fdatlog.asm

                    use       fld.asm

                    use       fcpymem.asm

                    use       fmove.asm

                    use       fldabx.asm

                    use       falltsk.asm

                    use       faproc.asm

* System IRQ service routine.
XIRQ                ldx       <D.Proc             get the current process pointer
                    sts       P$SP,x              save the stack pointer
                    lds       <D.SysStk           get the system stack pointer
                    ldd       <D.SysSvc           set the system service routine to current
                    std       <D.XSWI2            store it in the cross-SWI2 vector
                    ldd       <D.SysIRQ           set the system IRQ routine to current
                    std       <D.XIRQ             store it in the cross-IRQ vector
                    jsr       [>D.SvcIRQ]         execute interrupt service routine
                    bcc       L0D5B               branch if the routine was serviced

                    ldx       <D.Proc             get the current process pointer
                    ldb       P$Task,x            and the task of the process
                    ldx       P$SP,x              get it's stack pointer

                    pshs      u,d,cc              save some registers
                    leau      ,s                  point to a 'caller register stack'
                    lbsr      L0C40               do a LDB 0,X in task B
                    puls      u,d,cc              and now A (R$A,U) = the CC we want

                    ora       #IntMasks           disable its interrupts
                    lbsr      L0C28               save it back
L0D5B               orcc      #IntMasks           shut down interrupts
                    ldx       <D.Proc             get the current process pointer
                    tst       <D.QIRQ             was it a clock interrupt?
                    lbne      L0DF7               if not, do a quick return

                    lda       P$State,x           get its state
                    bita      #TimOut             is it timed out?
                    bne       L0D7C               yes, wake it up
* Update the active process queue.
                    ldu       #(D.AProcQ-P$Queue) point to the active process queue
                    ldb       #Suspend            get the suspend flag
L0D6A               ldu       P$Queue,u           get an active process pointer
                    beq       L0D78               branch if empty
                    bitb      P$State,u           is it suspended?
                    bne       L0D6A               yes, go to the next one in the chain
                    ldb       P$Prior,x           get the current process priority
                    cmpb      P$Prior,u           do we bump this one?
                    blo       L0D7C               branch if lower

L0D78               ldu       P$SP,x              get the stack pointer
                    bra       L0DB9               and branch

L0D7C               anda      #^TimOut            clear the timeout flag
                    sta       P$State,x           and save it to the process descriptor

L0D80               equ       *
L0D83               bsr       L0D11               activate next process

                    use       fnproc.asm

* The following routines must appear no earlier than $E00 for the CoCo 3
* (or $D00 for the F256) when assembled, as they have to always be in the
* constant RAM page ($FE00-$FEFF for CoCo 3, $FD00-$FDFF for the F256).

* The default routine for D.SysIRQ.
S.SysIRQ
                    lda       <D.SSTskN           get the current task number
                    beq       FastIRQ             use the super-fast version for system state
                    clr       <D.SSTskN           clear out the memory copy (task 0)
                    jsr       [>D.SvcIRQ]         call the routine (normally Clock calling D.Poll)
                    inc       <D.SSTskN           save the task number for system state
                    lda       #1                  get task 1
                    ora       <D.TINIT            merge the task bit into the shadow version
                    sta       <D.TINIT            update the shadow register
                    sta       >DAT.Task           save to the DAT as well
                    bra       DoneIRQ             check for error and exit

FastIRQ             jsr       [>D.SvcIRQ]         call the orutine (normally Clock calling D.Poll)
DoneIRQ             bcc       L0E28               no error on IRQ, so exit
                    ifne      H6309
                    oim       #IntMasks,0,s       setup RTI to shut interrupts off again
                    else
                    lda       ,s                  get the CC on the stack
                    ora       #IntMasks           mask interrupts
                    sta       ,s                  and store it back
                    endc
L0E28               rti                           return

* Return from a system call.
L0E29               clra                          force system task # to 0 (system)
L0E2B               ldx       <D.SysPrc           get the system process descriptor pointer
                    lbsr      TstImg              check the image, and F$SetTsk (preserves A)
                    orcc      #IntMasks           shut off interrupts
                    sta       <D.SSTskN           save the task number for system state
                    beq       Fst2                if task 0, we're done
                    ora       <D.TINIT            merge task bit into the shadow register
                    sta       <D.TINIT            update the shadow register
                    sta       >DAT.Task           save to the DAT as well
Fst2                leas      ,u                  put stack ptr into U
                    rti                           return

* Switch to a new process.
*
* Entry: X = The Process descriptor pointer.
*        U = The stack pointer.
L0E4C               equ       *
                    ifne      H6309
                    oim       #$01,<D.TINIT       switch the shadow register to task 1
                    lda       <D.TINIT            get the shadow register
                    else
                    lda       <D.TINIT            get the shadow register
                    ora       #$01                set it to task 1
                    sta       <D.TINIT            save it back
                    endc
                    sta       >DAT.Task           save it to the DAT
                    leas      ,y                  point to the new stack
                    tstb                          is the stack at SWISTACK?
                    bne       MyRTI               no, we're doing a system-state rti
                    ifne      H6309
                    ldf       #R$Size             E=0 from call to L0E8D before
                    ldu       #Where+SWIStack     point to the stack
                    tfm       u+,y+               move the stack from the top of memory to user memory
                    else
                    ldb       #R$Size/2           get the number of bytes to move
                    ldu       #Where+SWIStack     point to the stack
l@                  ldx       ,u++                get the bytes
                    stx       ,y++                and store them in the destination
                    decb                          decrement the counter
                    bne       l@                  branch if not done
                    endc
MyRTI               rti                           return from IRQ


* Execute routine in task 1 pointed to by U.
* This comes from user requested SWI vectors.
L0E5E               equ       *
                    ifne      H6309
                    oim       #$01,<D.TINIT       switch the shadow register to task 1
                    ldb       <D.TINIT            get the shadow register
                    else
                    ldb       <D.TINIT            get the shadow register
                    orb       #$01                set it to task 1
                    stb       <D.TINIT            save it back
                    endc
                    stb       >DAT.Task           save it to the DAT
                    jmp       ,u                  jump to the routine

* Flip to task 1 (used by WindInt to switch to GrfDrv) (pointed to
*  by <D.Flip1). All registers are already preserved on stack for the RTI.
S.Flip1             ldb       #2                  get the tsk image entry number x2 for Grfdrv (task 1)
                    bsr       L0E8D               copy over the DAT image
                    ifne      H6309
                    oim       #$01,<D.TINIT       switch the shadow register to task 1
                    lda       <D.TINIT            get a copy of the shadow register
                    else
                    lda       <D.TINIT            get a copy of the shadow register
                    ora       #$01                force task register to 1
                    sta       <D.TINIT            save it back
                    endc
                    sta       >DAT.Task           save it to the DAT
                    inc       <D.SSTskN           increment the system state task number
                    rti                           return

* Set up the MMU in task 1, B=Task # to swap to, shifted left 1 bit.
L0E8D               cmpb      <D.Task1N           are we going back to the same task?
                    beq       L0EA3               without the DAT image changing?
                    stb       <D.Task1N           no, save current task in map type 1
*>>>>>>>>>> F256 PORT
                    ifne      f256
                    lda       MMU_MEM_CTRL        get the memory control register
                    anda      #~EDIT_LUT          turn off all EDIT_LUT bits
                    ora       #EDIT_LUT_1         and OR with EDIT_LUT_1
                    sta       MMU_MEM_CTRL        save it back to the memory control register
                    ldx       #DAT.Regs           get the MMU start register for the process
*<<<<<<<<<< F256 PORT
                    else
                    ldx       #DAT.Regs+8         get the MMU start register for process
                    endc
                    ldu       <D.TskIPt           get the task image pointer table
                    ldu       b,u                 and the address of the DAT image
* COME HERE FROM FALLTSK
* Update 8 MMU mappings.
* X = address of 1st DAT MMU register to update
* U = address of DAT image to update into MMU
L0E93               leau      1,u                 point to the actual MMU block
                    ifne      H6309
                    lde       #4                  get the number of banks/2 for the task
                    else
                    lda       #4                  get the number of banks/2 for the task
                    pshs      a                   save A
                    endc
L0E9B               lda       ,u++                get a bank
                    ldb       ,u++                and next one
                    std       ,x++                save it to MMU
                    ifne      H6309
                    dece                          done?
                    else
                    dec       ,s                  done?
                    endc
                    bne       L0E9B               no, keep going
                    ifeq      H6309
* 6809 - 10 cyc down to 8
*                   leas      1,s                 eat temporary stack
                    puls      a,pc                eat temporary stack and return
                    endc
*>>>>>>>>>> F256 PORT
                    ifne      f256
                    clr       MMU_MEM_CTRL        clear the DAT control flags
                    endc
*<<<<<<<<<< F256 PORT
L0EA3               rts                           return

*>>>>>>>>>> F256 PORT
                    ifne      f256
CrashDump           fill      255,32
                    endc
*<<<<<<<<<< F256 PORT

* Execute FIRQ vector (called from $FEF4)
FIRQVCT             ldx       #D.FIRQ             get the DP offset of the vector
                    bra       L0EB8               go execute it

* Execute IRQ vector (called from $FEF7)
IRQVCT              orcc      #IntMasks           disable interrupts
                    ldx       #D.IRQ              get the DP offset of the vector

* Execute interrupt vector, B=DP Vector offset
L0EB8               clra                          (faster than CLR >$xxxx)
                    sta       >DAT.Task           force to task 0 (system state)
                    ifne      H6309
                    tfr       0,dp                setup the DP
                    else
                    tfr       a,dp                ASSUME: A=0 from earlier
                    endc
MapGrf              equ       *                   come here from elsewhere, too
                    ifne      H6309
                    aim       #$FE,<D.TINIT       switch the shadow register to system state
                    lda       <D.TINIT            set the DAT again just in case timer is used
                    else
                    lda       <D.TINIT            get the shadow register
                    anda      #$FE                clear the task 0 bit
                    sta       <D.TINIT            and save it back
                    endc
MapT0               sta       >DAT.Task           come here from elsewhere, too
                    jmp       [,x]                execute it

* Execute SWI3 vector (called from $FEEE).
SWI3VCT             orcc      #IntMasks           disable interrupts
                    ldx       #D.SWI3             get the DP offset of the vector
                    bra       SWICall             go execute it

* Execute SWI2 vector (called from $FEF1)
SWI2VCT             orcc      #IntMasks           disable interrupts
                    ldx       #D.SWI2             get the DP offset of the vector

* This routine is called from an SWI, SWI2, or SWI3.
* It saves 1 cycle on system state system calls.
* It saves about 200 cycles (calls to I.LDABX and L029E) on GrvDrv system
* and user state system calls.
SWICall             ldb       [R$PC,s]            get the op-code of the system call
* NOTE: Alan DeKok claims that this is BAD.  It crashed Colin McKay's
* CoCo 3.  Instead, we should do a clra/sta >DAT.Task.
*         clr   >DAT.Task       go to map type 1
                    clra                          clear A
                    sta       >DAT.Task           and save it in the DAT
                    ifne      H6309
                    tfr       0,dp                set the direct page to 0
                    else
                    tfr       a,dp                set the direct page to 0 (assume A = 0)
                    endc

* These lines add a total of 81 addition cycles to each SWI(2,3) call,
* and 36 bytes+12 for R$Size in the constant page at the constant page.
* It takes no more time for a SWI(2,3) from system state than previously,
* and adds 14 cycles to each SWI(2,3) call from grfdrv.
* For processes that re-vector SWI, SWI3, it adds 81 cycles, but SWI(3)
* CANNOT be vectored to L0EBF because the user SWI service routine has been
* changed.
                    lda       <D.TINIT            get the shadow register
                    bita      #$01                check it without changing it

* Change to LBEQ R.SysSvc to avoid JMP [,X]
* and add R.SysSvc STA >DAT.Task ???
                    beq       MapT0               in map 0; restore the hardware and do system service
                    tst       <D.SSTskN           get system state 0,1
                    bne       MapGrf              if in grfdrv, go to map 0 and do system service

* The preceding few lines are necessary, as all SWI's still pass through
* here before being vectored to the system service routine, which
* doesn't copy the stack from user state.
                    sta       >DAT.Task           go to map type X again to get the user's stack
* a byte less, a cycle more than ldy #$FEED-R$Size, or ldy #$F000+SWIStack
                    leay      <SWIStack,pc        where to put the register stack: to $DF in the constant page
                    tfr       s,u                 get a copy of where the stack is
                    ifne      H6309
                    ldw       #R$Size             get the size of the stack
                    tfm       u+,y+               move the stack to the top of memory
                    else
                    pshs      x                   save X
                    lda       #R$Size/2           move stack to top of memory (A is reset in L0EB8, no need to preserve)
l@                  ldx       ,u++                get the bytes
                    stx       ,y++                and save them
                    deca                          decrement the counter
                    bne       l@                  branch if not done
                    puls      x                   restore X
                    endc
                    bra       L0EB8               go from map type 1 to map type 0

* Execute SWI vector (called from $FEFA)
SWIVCT              ldx       #D.SWI              get the DP offset of the vector
                    bra       SWICall             go execute it

* Execute NMI vector (called from $FEFD)
NMIVCT              ldx       #D.NMI              get the DP offset of the vector
                    bra       L0EB8               go execute it

* The end of the kernel module is here
                    emod
eom                 equ       *

* What follows after the kernel module is the register stack, starting
* at $FEDD (6309), $FEDF (CoCo 3 6809), or $FDDF (F256).
* The kernel uses this register stack area to save the caller's registers in
* the constant page because it doesn't get "switched out" no matter the
* contents of the MMU registers.
                    ifne      f256
                    fdb       Where+CrashCode
                    endc

SWIStack
                    fcc       /REGISTER STACK/    same # bytes as R$Size for 6809
                    ifne      H6309
                    fcc       /63/                if 6309, add two more spaces
                    endc

                    fcb       $55                 D.ErrRst

* This list of addresses ends up at $FEEE (CoCo 3) or $FDEE (F256) after the
* kernel loads into memory.  All interrupts come through the 6809 vectors at
* $FFF0-$FFFE and get directed to here. From here, the BRA takes CPU control
* to the various handlers in the kernel.
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
