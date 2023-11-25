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

               nam       krn
               ttl       NitrOS-9 Level 2 Kernel

               ifp1      
               use       defsfile
               endc      

* defines for customizations
Revision       set       9                   module revision
Edition        set       19                  module Edition
Where          equ       $F000               absolute address of where Kernel starts in memory

               mod       eom,MName,Systm,ReEnt+Revision,entry,0

MName          fcs       /Krn/
               fcb       Edition



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
DisSize        equ       *-DisTable
* ^
* Code using 'SubSiz', below, assumes that SubStrt follows on directly after
* the end of DisTable. Therefore, DO NOT ADD ADD ANYTHING BETWEEN THESE 2 LABELS
* v
LowSub         equ       $0160               start of low memory subroutines
SubStrt        equ       *
* D.Flip0 - switch to system task 0
R.Flip0        equ       *
               ifne      H6309
               aim       #$FE,<D.TINIT       map type 0
               lde       <D.TINIT            another 2 bytes saved if GRFDRV does: tfr cc,e
               ste       >DAT.Task           and we can use A here, instead of E
               else      
               pshs      a
               lda       <D.TINIT            Get value from shadow
               ifne      mc09
               anda      #$BF                force TR=0
               sta       <D.TINIT            Update shadow
               sta       >MMUADR             Update MMU
               else      
               anda      #$FE                force TR=0
               sta       <D.TINIT
               sta       >DAT.Task
               endc      
               puls      a
               endc      
               clr       <D.SSTskN
               tfr       x,s
               tfr       a,cc
               rts       
SubSiz         equ       *-SubStrt
* ^
* Code around L0065, below, assumes that Vectors follows on directly after
* the end of R.Flip0. Therefore, DO NOT ADD ADD ANYTHING BETWEEN THESE 2 LABELS
* v
* Interrupt service routine
Vectors        jmp       [<-(D.SWI3-D.XSWI3),x] (-$10) (Jmp to 2ndary vector)

               ifne      mc09
CPUVect        fdb       SWI3VCT+Where       SWI3  at $FFF2
               fdb       SWI2VCT+Where       SWI2  at $FFF4
               fdb       FIRQVCT+Where       FIRQ  at $FFF6
               fdb       IRQVCT+Where        IRQ   at $FFF8
               fdb       SWIVCT+Where        SWI   at $FFFA
               fdb       NMIVCT+Where        NMI   at $FFFC
               fdb       $0000+Where         RESET at $FFFE
               endc      

* [NAC HACK 2016Dec07] to do a real reset on Multicomp09 need first to
* disable the MMU and re-enable the ROM. Maybe implement a little blob
* of code to do that? Otherwise, implement some kind of crash/dump.

* Initialize the system block (the lowest 8Kbytes of memory)
* rel.asm has cleared the DP already, so start at address $100.
entry          equ       *
               ifne      H6309
               ldq       #$01001f00          start address to clear & # bytes to clear
               leay      <entry+2,pc         point to a 0
               tfm       y,d+
               std       <D.CCStk            set pointer to top of global memory to $2000
               lda       #$01                set task user table to $0100
               else      
               ldx       #$100               start address
               ldy       #$2000-$100         bytes to clear
               clra      
               clrb      
L001C          std       ,x++                clear it 16-bits at a time
               leay      -2,y
               bne       L001C
               stx       <D.CCStk            Set pointer to top of global memory to $2000
               inca                          D = $0100
               endc      

* Set up system variables in DP
               std       <D.Tasks            set Task Structure pointer to $0100
               addb      #$20
               std       <D.TskIPt           set Task image table pointer to $0120
               clrb      

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

               inca                          set memory block map start pointer
               std       <D.BlkMap           to $0200

               inca                          set system service dispatch table pointer
               std       <D.SysDis           to 0x300
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

* Initialize interrupt vector tables in DP by moving pointer data down from DisTable

               ifne      mc09
* Brett's ccbkrn identified this as a bug in the original code..
* which has not been fixed. Should be easy to demonstrate which is
* correct..
               leay      DisTable,pcr        point to table of absolute vector addresses
               else      
               leay      <DisTable,pcr       point to table of absolute vector addresses
               endc      
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

* Initialize D.Flip0 routine in low memory by copying lump of code down from R.Flip0.
* ASSUME: Y left pointing to R.Flip0 by previous copy loop.

               ldu       #LowSub             somewhere in block 0 that's never modified
               stu       <D.Flip0            switch to system task 0
               ifne      H6309
               ldf       #SubSiz             size of it
               tfm       y+,u+               copy it over
               else      
               ldb       #SubSiz
Loop2          lda       ,y+                 load a byte from source
               sta       ,u+                 and save to destination
               decb                          bump counter
               bne       Loop2               loop if not done
               endc      

* Initialize secondary interrupt vectors to all point to Vectors for now
* ASSUME: Y left pointing to Vectors by previous copy loop
               tfr       y,u                 move the pointer to a faster register
L0065          stu       ,x++                Set all IRQ vectors to go to Vectors for now
               cmpx      #D.NMI
               bls       L0065

               ifne      mc09
* Initialize CPU vectors
               leay      CPUVect,pcr         Data source
               ldx       #$FFF2              Data destination
               ldb       #14                 7 vectors to copy
L0067          lda       ,y+
               sta       ,x+
               decb      
               bne       L0067
               endc      

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

               lda       #'K                 debug: signal that we are in Kernel
               jsr       <D.BtBug

               leax      >S.Flip1,pc         Setup change to task 1 vector
               stx       <D.Flip1

* Setup System calls
               leay      >SysCalls,pc        load y with address of table, below
               lbsr      SysSvc              copy table below into dispatch table

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

********************************************************************
* The DAT image is a data structure that is used to indicate which
* Dynamic Address Translator (DAT) mapping registers are in use.

* [NAC HACK 2016Dec06] future: I should be able to make this 7 if not 8..
* DAT.BlCt-ROMCount-RAMCount = 8 - 1 - 1 = 6
               lda       #$06                initialize the rest of the blocks to be free
               ldu       #DAT.Free
L00EF          stu       ,x++                store free "flag"
               deca                          bump counter
               bne       L00EF               loop if not done

               ldu       #KrnBlk             Block where the kernel will live
               stu       ,x

               ldx       <D.Tasks            Point to task user table
               inc       ,x                  mark first 2 in use (system & GrfDrv)
               inc       1,x

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
               ldx       <D.SysMem           Get system memory map pointer
               ldb       <D.CCStk            Get MSB of top of CC memory
* X indexes the system memory map.
* B represents the number of 256-byte pages available.
* Walk through the map changing the corresponding elements
* from 0 (the initialisation value) to 1 (indicating 'used'). Higher
* entries in the map remain as 0 (indicating 'unused').
L0104          inc       ,x+                 Mark it as used
               decb                          Done?
               bne       L0104               No, go back till done

********************************************************************
* Deduce how many 8Kbyte blocks of physical memory are available and
* update the memory block map end pointer (D.BlkMap+2) accordingly
               ldx       <D.BlkMap           get ptr to 8k block map
               inc       <KrnBlk,x           mark block holding kernel as used
               ifne      mc09
               inc       <$00,x              mark block $00 as used (global memory)
* For mc09 memory size is 512Kbyte or 1MByte. For now, hard-wire
* the memory size to 512Kbyte.
               ldd       #$0240
               else      
* This memory sizing routine uses location at X (D.BlkMap) as
* a scratch location. At exit, it leaves this location at 1 which
* has the (until now) undocumented side-effect of marking block 0
* as used. It is essential that this is done because that block
* does need to be reserved; it's used for global memory.
               ifne      H6309
               ldq       #$00080100          e=Marker, D=Block # to check
L0111          asld                          get next block #
               stb       >DAT.Regs+5         Map block into block 6 of my task
               ste       >-$6000,x           save marker to that block
               cmpe      ,x                  did it ghost to block 0?
               bne       L0111               No, keep going till ghost is found
               stb       <D.MemSz            Save # 8k mem blocks that exist
               addr      x,d                 add number of blocks to block map start
               else      
               ldd       #$0008
L0111          aslb      
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
               endc      
               std       <D.BlkMap+2         save memory block map end pointer

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
               bitb      #%00110000          block above 128K-256K?
               beq       L0170               yes, no need to mark block map
               tstb                          2 meg?
               beq       L0170               yes, skip this
* Mark blocks from 128k-256K to block $3F as NOT RAM
               abx                           add maximum block number to block map start
               leax      -1,x                Skip good blocks that are RAM
               lda       #NotRAM             Not RAM flag
               subb      #$3F                Calculate # blocks to mark as not RAM
L0127          sta       ,x+                 Mark them all
               decb      
               bne       L0127

* ASSUME: however we got here, B=0
L0170          ldx       #Bt.Start           start address of the boot track in memory
               lda       #18                 size of the boot track is $1800

* Verify the modules in the boot track and update/build a module index
               lbsr      I.VBlock
               bsr       L01D2               go mark system map

* See if init module is in memory already
L01B0          leax      <init,pc            point to 'Init' module name
               bsr       link                try & link it
               bcc       L01BF               no error, go on
L01B8          os9       F$Boot              error linking init, try & load boot file
               bcc       L01B0               got it, try init again
               bra       L01CE               error, re-booting do D.Crash

* So far, so good. Save pointer to init module and execute krnp2
L01BF          stu       <D.Init             Save init module pointer
               lda       Feature1,u          Get feature byte #1 from init module
               bita      #CRCOn              CRC feature on?
               beq       ShowI               if not, continue
               inc       <D.CRC              else inc. CRC flag

ShowI          lda       #'i                 debug: signal that we found the init module
               jsr       <D.BtBug

L01C1          leax      <krnp2,pc           Point to its name
               bsr       link                Try to link it
               bcc       L01D0               It worked, execute it
               os9       F$Boot              It doesn't exist try re-booting
               bcc       L01C1               No error's, let's try to link it again
L01CE          jmp       <D.Crash            obviously can't do it, crash machine
L01D0          jmp       ,y                  execute krnp2

* Update the system memory map to reserve the area used by the kernel
L01D2          ldx       <D.SysMem           Get system memory map pointer
               ldd       #NotRAM*256+(Bt.Start/256) B = MSB of start of the boot
               abx                           point to Bt.Start - start of boot track
               comb                          we have $FF-$ED pages to mark as inUse
               sta       b,x                 Mark I/O as not RAM
L01DF          lda       #RAMinUse           get inUse flag
L01E1          sta       ,x+                 mark this page
               decb                          done?
               bne       L01E1               no, keep going
               ldx       <D.BlkMap           get pointer to start of block map
               sta       <KrnBlk,x           mark kernel block as RAMinUse, instead of ModInBlk
S.AltIRQ       rts                           return

* Link module pointed to by X
link           lda       #Systm              Attempt to link system module
               os9       F$Link
               rts       

init           fcs       'Init'
krnp2          fcs       'krnp2'

* Service vector call pointers
SysCalls       fcb       F$Link
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
               fdb       FFreeLB-*-2
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
XSWI3          lda       #P$SWI3             point to SWI3 vector
               fcb       $8C                 skip 2 bytes

* SWI vector entry
XSWI           lda       #P$SWI              point to SWI vector
               ldx       <D.Proc             get process pointer
               ldu       a,x                 user defined SWI[x]?
               beq       L028E               no, go get option byte
GoUser         lbra      L0E5E               Yes, go call users's routine

* SWI2 vector entry
XSWI2          ldx       <D.Proc             get current process descriptor
               ldu       P$SWI2,x            any SWI vector?
               bne       GoUser              yes, go execute it

* Process software interupts from a user state
* Entry: X=Process descriptor pointer of process that made system call
*        U=Register stack pointer
L028E          ldu       <D.SysSvc           set system call processor to system side
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
Loop3          ldx       ,--y
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

DoFull         bsr       L02DA               move the stack frame back to user state
               lbra      L0D80               go back to the process

* add ldu P$SP,x, etc...
AllClr         equ       *
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
Loop4          lda       ,u+
               sta       ,y+
               decb      
               bne       Loop4
               endc      
               lbra      BackTo1             otherwise simply return to the user

* Copy register stack from user to system
* Entry: U=Ptr to Register stack in process dsc
L02CB          pshs      cc,x,y,u            preserve registers
               ldb       P$Task,x            get task #
               ldx       P$SP,x              get stack pointer
               lbsr      L0BF3               calculate block offset (only affects A&X)
               leax      -$6000,x            adjust pointer to where memory map will be
               bra       L02E9               go copy it

* Copy register stack from system to user
* Entry: U=Ptr to Register stack in process dsc
L02DA          pshs      cc,x,y,u            preserve registers
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
L02E9          leau      a,u                 point to block # of where stack is
               ifne      mc09
               orcc      #IntMasks           shutdown interupts while we do this

               lda       #5
               bsr       prepmmu             Select block 5

               lda       1,u                 get first block
               ldb       3,u                 get a second just in case of overlap

               sta       >MMUDAT             Set value for block 5

               lda       #6
               bsr       prepmmu             Select block 6

               stb       >MMUDAT             Set value for block 6

               ldb       #R$Size
Loop5          lda       ,x+
               sta       ,y+
               decb      
               bne       Loop5
               ldx       <D.SysDAT           remap the blocks we took out

               lda       #5
               bsr       prepmmu             Select block 5

               lda       $0B,x
               ldb       $0D,x

               sta       >MMUDAT             Restore value for block 5
               lda       #6
               bsr       prepmmu             Select block 6

               stb       >MMUDAT             Restore value for block 6
               else      
               lda       1,u                 get first block
               ldb       3,u                 get a second just in case of overlap
               orcc      #IntMasks           shutdown interupts while we do this
               std       >DAT.Regs+5         map blocks in
               ifne      H6309
               ldw       #R$Size             get size of register stack
               tfm       x+,y+               copy it
               else      
               ldb       #R$Size
Loop5          lda       ,x+
               sta       ,y+
               decb      
               bne       Loop5
               endc      
               ldx       <D.SysDAT           remap the blocks we took out
               lda       $0B,x
               ldb       $0D,x
               std       >DAT.Regs+5
               endif     
               puls      cc,x,y,u,pc         restore & return

               ifne      mc09
* A holds the MMU register we want to select. Merge in
* the stored value and write the result to MMUADR. This is
* a desperate attempt to save a few bytes..
prepmmu                  
               ora       <D.TINIT            Merge with current MMU mask
               sta       >MMUADR             Select block
               rts       
               endif     


* Process software interupts from system state
* Entry: U=Register stack pointer
SysCall        leau      ,s                  get pointer to register stack
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
Sys.Vec        jmp       ,x                  execute service call

* Execute system call
* Entry: B=Function call #
*        Y=Function dispatch table pointer (D.SysDis or D.UsrDis)
L033B                    
               lslb                          is it a I/O call? (Also multiplys by 2 for offset)
               bcc       L0345               no, go get normal vector
* Execute I/O system calls
               ldx       IOEntry,y           get IOMan vector
* Execute the system call
L034F          pshs      u                   preserve register stack pointer
               jsr       [D.SysVec]          perform a vectored system call
               puls      u                   restore pointer
L0355          tfr       cc,a                move CC to A for stack update
               bcc       L035B               go update it if no error from call
               stb       R$B,u               save error code to caller's B
L035B          ldb       R$CC,u              get callers CC, R$CC=$00
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

               use       fsrqmem.asm

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
XIRQ           ldx       <D.Proc             get current process pointer
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
L0D5B          orcc      #IntMasks           shut down IRQ's
               ldx       <D.Proc             get current process pointer
               tst       <D.QIRQ             was it a clock IRQ?
               lbne      L0DF7               if not, do a quick return

               lda       P$State,x           Get it's state
               bita      #TimOut             Is it timed out?
               bne       L0D7C               yes, wake it up
* Update active process queue
               ldu       #(D.AProcQ-P$Queue) point to active process queue
               ldb       #Suspend            get suspend flag
L0D6A          ldu       P$Queue,u           get a active process pointer
               beq       L0D78
               bitb      P$State,u           is it suspended?
               bne       L0D6A               yes, go to next one in chain
               ldb       P$Prior,x           get current process priority
               cmpb      P$Prior,u           do we bump this one?
               blo       L0D7C

L0D78          ldu       P$SP,x
               bra       L0DB9

L0D7C          anda      #^TimOut
               sta       P$State,x

L0D80          equ       *
L0D83          bsr       L0D11               activate next process

               use       fnproc.asm

* The following routines must appear no earlier than $E00 when assembled, as
* they have to always be in the vector RAM pages ($FE00-$FEFF)

               ifne      mc09
* Copied nicer automatic padding from ccbkrn
* CCB: this code (after pad) start assembling *before* 0xfe00, it's too big to
* fit into the memory as stated above!!!!

PAD            fill      $00,($0dfc-*)       fill memory to ensure the above happens
               else      
PAD            fill      $00,($0df1-*)       fill memory to ensure the above happens
               endc      


* Default routine for D.SysIRQ
S.SysIRQ                 
               lda       <D.SSTskN           Get current task's GIME task # (0 or 1)
               beq       FastIRQ             Use super-fast version for system state
               clr       <D.SSTskN           Clear out memory copy (task 0)
               jsr       [>D.SvcIRQ]         (Normally routine in Clock calling D.Poll)
               inc       <D.SSTskN           Save task # for system state
               ifne      mc09
               lda       #$40                mc09 MMU Task 1
               ora       <D.TINIT            Merge task bit into Shadow version
               sta       <D.TINIT            Update shadow
               sta       >MMUADR             Save to MMU as well
               else      
               lda       #1                  Task 1
               ora       <D.TINIT            Merge task bit into Shadow version
               sta       <D.TINIT            Update shadow
               sta       >DAT.Task           Save to GIME as well
               endc      
               bra       DoneIRQ             Check for error and exit

FastIRQ        jsr       [>D.SvcIRQ]         (Normally routine in Clock calling D.Poll)
DoneIRQ        bcc       L0E28               No error on IRQ, exit
               ifne      H6309
               oim       #IntMasks,0,s       Setup RTI to shut interrupts off again
               else      
               lda       ,s
               ora       #IntMasks
               sta       ,s
               endc      
L0E28          rti       

* return from a system call
L0E29          clra                          Force System task # to 0 (non-GRDRV)
L0E2B          ldx       <D.SysPrc           Get system process dsc. ptr
               lbsr      TstImg              check image, and F$SetTsk (PRESERVES A)
               orcc      #IntMasks           Shut interrupts off
               sta       <D.SSTskN           Save task # for system state
               beq       Fst2                If task 0, we're done
               ifne      mc09
               lda       #$40                [NAC HACK 2016Dec07] hope only 1 bit means anything..
               ora       <D.TINIT            Merge task bit into Shadow version
               sta       <D.TINIT            Update shadow
               sta       >MMUADR             Save to MMU
               else      
               ora       <D.TINIT            Merge task bit into Shadow version
               sta       <D.TINIT            Update shadow
               sta       >DAT.Task           Save to GIME as well
               endc      
Fst2           leas      ,u                  Stack ptr=U & return
               rti       

* Switch to new process, X=Process descriptor pointer, U=Stack pointer
L0E4C          equ       *
               ifne      H6309
               oim       #$01,<D.TINIT       switch GIME shadow to user state
               lda       <D.TINIT
               else      
               lda       <D.TINIT
               ifne      mc09
               ora       #$40
               else      
               ora       #$01
               endc      
               sta       <D.TINIT
               endc      
               ifne      mc09
               sta       >MMUADR             save it to MMU
               else      
               sta       >DAT.Task           save it to GIME
               endc      
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
RtiLoop        lda       ,u+
               sta       ,y+
               decb      
               bne       RtiLoop
               endc      
MyRTI          rti                           return from IRQ


* Execute routine in task 1 pointed to by U
* comes from user requested SWI vectors
L0E5E          equ       *
               ifne      H6309
               oim       #$01,<D.TINIT       switch GIME shadow to user state
               ldb       <D.TINIT
               else      
               ldb       <D.TINIT
               ifne      mc09
               orb       #$40
               else      
               orb       #$01
               endc      
               stb       <D.TINIT
               endc      
               ifne      mc09
               stb       >MMUADR
               else      
               stb       >DAT.Task
               endc      
               jmp       ,u

* Flip to task 1 (used by GRF/WINDInt to switch to GRFDRV) (pointed to
*  by <D.Flip1). All regs are already preserved on stack for the RTI
S.Flip1        ldb       #2                  get Task image entry numberx2 for Grfdrv (task 1)
               bsr       L0E8D               copy over the DAT image
               ifne      H6309
               oim       #$01,<D.TINIT
               lda       <D.TINIT            get copy of GIME Task side
               else      
               lda       <D.TINIT
               ifne      mc09
               ora       #$40                force TR=1 in mc09 MMU
               else      
               ora       #$01                force TR=1
               endc      
               sta       <D.TINIT
               endc      
               ifne      mc09
               sta       >MMUADR             save it to MMU register
               else      
               sta       >DAT.Task           save it to GIME register
               endc      
               inc       <D.SSTskN           increment system state task number
               rti                           return

* Setup MMU in task 1, B=Task # to swap to, shifted left 1 bit
L0E8D          cmpb      <D.Task1N           are we going back to the same task
               beq       L0EA3               without the DAT image changing?
               stb       <D.Task1N           nope, save current task in map type 1
               ifne      mc09
               ldu       <D.TskIPt           get task image pointer table
               ldu       b,u                 get address of DAT image

               lda       <D.TINIT
               adda      #8                  1st MMU value for process's mappings

* COME HERE FROM FALLTSK
* Update 8 MMU mappings.
* A = MMUADR value for 1st MMU register to update
* U = address of DAT image to update into MMU
L0E93          ldb       #8                  number of MMU mappings to set
               pshs      b                   squirrel it away
               leau      1,u                 point to actual MMU block for 1st mapping

L0E9B          ldb       ,u++                get a bank, point to next bank
               std       >MMUADR             save it to MMU
               inca                          next mapsel value
               dec       ,s
               bne       L0E9B               no, keep going
               leas      1,s                 done. Tidy up the stack
               else      
               ldx       #DAT.Regs+8         get MMU start register for process's
               ldu       <D.TskIPt           get task image pointer table
               ldu       b,u                 get address of DAT image
* COME HERE FROM FALLTSK
* Update 8 MMU mappings.
* X = address of 1st DAT MMU register to update
* U = address of DAT image to update into MMU
L0E93          leau      1,u                 point to actual MMU block
               ifne      H6309
               lde       #4                  get # banks/2 for task
               else      
               lda       #4
               pshs      a
               endc      
L0E9B          lda       ,u++                get a bank
               ldb       ,u++                and next one
               std       ,x++                Save it to MMU
               ifne      H6309
               dece                          done?
               else      
               dec       ,s
               endc      
               bne       L0E9B               no, keep going
               ifeq      H6309
               leas      1,s                 done. Tidy up the stack
               endc      
               endc      
L0EA3          rts                           return

* Execute FIRQ vector (called from $FEF4)
FIRQVCT        ldx       #D.FIRQ             get DP offset of vector
               bra       L0EB8               go execute it

* Execute IRQ vector (called from $FEF7)
IRQVCT         orcc      #IntMasks           disable IRQ's
               ldx       #D.IRQ              get DP offset of vector

* Execute interrupt vector, B=DP Vector offset
               ifne      mc09
L0EB8          lda       #$a0                [NAC HACK 2016Dec08] add equates..
               sta       >MMUADR             Force to System State (Task 0)
               clra      
               tfr       a,dp                ASSUME: A=0 from earlier
MapGrf         equ       *                   come here from elsewhere, too.
               lda       <D.TINIT
               anda      #$BF                force TR=0 in mc09 MMU shadow
               sta       <D.TINIT
MapT0          sta       >MMUADR             come here from elsewhere, too.
               jmp       [,x]                execute it
               else      
* Execute interrupt vector, B=DP Vector offset
L0EB8          clra                          (faster than CLR >$xxxx)
               sta       >DAT.Task           Force to Task 0 (system state)
               ifne      H6309
               tfr       0,dp                setup DP
               else      
               tfr       a,dp                ASSUME: A=0 from earlier
               endc      
MapGrf         equ       *                   come here from elsewhere, too.
               ifne      H6309
               aim       #$FE,<D.TINIT       switch GIME shadow to system state
               lda       <D.TINIT            set GIME again just in case timer is used
               else      
               lda       <D.TINIT
               anda      #$FE
               sta       <D.TINIT
               endc      
MapT0          sta       >DAT.Task           come here from elsewhere, too.
               jmp       [,x]                execute it
               endc      



* Execute SWI3 vector (called from $FEEE)
SWI3VCT        orcc      #IntMasks           disable IRQ's
               ldx       #D.SWI3             get DP offset of vector
               bra       SWICall             go execute it

* Execute SWI2 vector (called from $FEF1)
SWI2VCT        orcc      #IntMasks           disasble IRQ's
               ldx       #D.SWI2             get DP offset of vector

* This routine is called from an SWI, SWI2, or SWI3
* saves 1 cycle on system-system calls
* saves about 200 cycles (calls to I.LDABX and L029E) on grfdrv-system,
*  or user-system calls.
SWICall        ldb       [R$PC,s]            get callcode of the system call
               ifne      mc09
* [NAC HACK 2016Dec08] confused? it says, "go to map type 1" but
* it is setting a 0.
               lda       #$a0                [NAC HACK 2016Dec08] add equates..
               sta       >MMUADR             Force to System State (Task 0)
               clra      
               else      
* NOTE: Alan DeKok claims that this is BAD.  It crashed Colin McKay's
* CoCo 3.  Instead, we should do a clra/sta >DAT.Task.
*         clr   >DAT.Task       go to map type 1
               clra      
               sta       >DAT.Task
               endc      
* set DP to zero
               ifne      H6309
               tfr       0,dp
               else      
               tfr       a,dp                ASSUME: A=0 from earlier
               endc      

* These lines add a total of 81 addition cycles to each SWI(2,3) call,
* and 36 bytes+12 for R$Size in the constant page at $FExx
*  It takes no more time for a SWI(2,3) from system state than previously,
* ... and adds 14 cycles to each SWI(2,3) call from grfdrv... not a problem.
* For processes that re-vector SWI, SWI3, it adds 81 cycles.  BUT SWI(3)
* CANNOT be vectored to L0EBF cause the user SWI service routine has been
* changed
               lda       <D.TINIT            get map type flag
               ifne      mc09
               bita      #$40                check it without changing it in mc09 MMU
               else      
               bita      #$01                check it without changing it
               endc      

* Change to LBEQ R.SysSvc to avoid JMP [,X]
* and add R.SysSvc STA >DAT.Task ???
               beq       MapT0               in map 0: restore hardware and do system service
               tst       <D.SSTskN           get system state 0,1
               bne       MapGrf              if in grfdrv, go to map 0 and do system service

* the preceding few lines are necessary, as all SWI's still pass thru
* here before being vectored to the system service routine... which
* doesn't copy the stack from user state.
               ifne      mc09
               sta       >MMUADR             go to map type X again to get user's stack
               else      
               sta       >DAT.Task           go to map type X again to get user's stack
               endc      
* a byte less, a cycle more than ldy #$FEED-R$Size, or ldy #$F000+SWIStack
               leay      <SWIStack,pc        where to put the register stack: to $FEDF
               tfr       s,u                 get a copy of where the stack is
               ifne      H6309
               ldw       #R$Size             get the size of the stack
               tfm       u+,y+               move the stack to the top of memory
               else      
               pshs      b
               ldb       #R$Size
Looper         lda       ,u+
               sta       ,y+
               decb      
               bne       Looper
               puls      b
               endc      
               bra       L0EB8               and go from map type 1 to map type 0

* Execute SWI vector (called from $FEFA)
SWIVCT         ldx       #D.SWI              get DP offset of vector
               bra       SWICall             go execute it

* Execute NMI vector (called from $FEFD)
NMIVCT         ldx       #D.NMI              get DP offset of vector
               bra       L0EB8               go execute it

* The end of the kernel module is here
               emod      
eom            equ       *

* What follows after the kernel module is the register stack, starting
* at $FEDD (6309) or $FEDF (6809).  This register stack area is used by
* the kernel to save the caller's registers in the $FEXX area of memory
* because it doesn't get "switched out" no matter the contents of the
* MMU registers.
SWIStack                 
               fcc       /REGISTER STACK/    same # bytes as R$Size for 6809
               ifne      H6309
               fcc       /63/                if 6309, add two more bytes of space
               endc      

               fcb       $55                 D.ErrRst

               ifne      mc09
* For Multicomp09, the processor vectors are in RAM so they can be loaded
* with the service addresses directly, instead of requiring another indirection
* The vectors are set up by a data table copy of CPUVect
               else      
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
               endc      

* The final byte (eg the NOP after bra NMIVCT) should be at offset $EFF
* and will end up at address $FEFF in physical memory. If any code above
* is changed, you must inspect the listing and adjust the addresses at
* the label PAD.
               end       
