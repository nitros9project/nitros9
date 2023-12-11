********************************************************************
* Krn - NitrOS-9 Level 1 Kernel
*
* $Id$
*
* This is how the memory map looks after the kernel has initialized:
*
*     $0000----> ==================================
*               |                                  |
*               |                                  |
*  $0020-$0111  |  System Globals (D.FMBM-D.XNMI)  |
*               |                                  |
*               |                                  |
*     $0200---->|==================================|
*               |        Free Memory Bitmap        |
*  $0200-$021F  |     (1 bit = 256 byte page)      |
*               |----------------------------------|
*  $0220-$0221  |      IOMan I/O Call Pointer      |
*               |----------------------------------|
*               |      System Dispatch Table       |
*  $0222-$0291  |     (Room for 56 addresses)      |
*               |----------------------------------|
*  $0292-$02FF  |       User Dispatch Table        |
*               |     (Room for 56 addresses)      |
*     $0300---->|==================================|
*               |                                  |
*               |                                  |
*  $0300-$03FF  |     Module Directory Entries     |
*               |      (Room for 64 entries)       |
*               |                                  |
*     $0400---->|==================================|
*               |                                  |
*  $0400-$04FF  |           System Stack           |
*               |                                  |
*     $0500---->|==================================|
*               |                                  |
*               |                                  |
*               |                                  |
*  $0500-$08FF  |    Screen Memory (Atari Only)    |
*               |                                  |
*               |                                  |
*               |                                  |
*     $0900---->|==================================|
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  14      1985/??/??
* From Tandy OS-9 Level One VR 02.00.00
*
*  15      2002/07/21  Boisy G. Pitre
* Module validation consists only of module header parity check.
* CRC check is not done unless D.CRC is set to 1, which is NOT the
* default case.  By default, D.CRC is set to 0, thus there is no
* CRC checking.  Speeds up module loads quite a bit. The Init module
* has a bit in a compatibility byte that can turn on/off CRC checking
*
*  15r1    2003/12/09  Boisy G. Pitre
* Kernel no longer scans for modules in I/O space.  Also, F$PrsNam now
* allows _ and 0-9 as first chars of a filename.
*
*  15r1    2004/05/23  Boisy G. Pitre
* Renamed to 'krn'
*
*  16      2004/05/23  Boisy G. Pitre
* Added changes for Atari port

                    nam       krn
                    ttl       NitrOS-9 Level 1 Kernel

                    use       defsfile

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       16

ModTop              mod       eom,name,tylg,atrv,OS9Cold,size

size                equ       .

name                fcs       /Krn/
                    fcb       edition

**************************
* Kernel entry point
*
* Entry (Foenix Port):
*     X = The starting address of the bootfile.
*     Y = The size of the bootfile in bytes.
OS9Cold             equ       *
                    ifne      f256
*>>>>>>>>>> F256 PORT
* In RAM mode, the F256 memory map looks like this:
*    $0000-$1FFF - RAM at $000000-$001FFF
*    $2000-$3FFF - RAM at $002000-$003FFF
*    $4000-$5FFF - RAM at $004000-$005FFF
*    $6000-$7FFF - RAM at $006000-$007FFF
*    $8000-$9FFF - RAM at $008000-$009FFF
*    $A000-$BFFF - RAM at $00A000-$00BFFF
*    $C000-$DFFF - RAM at $00C000-$00DFFF
*    $E000-$FFFF - RAM at $00E000-$00FFFF
* F256-specific initialization to get the F256 to a sane state.
                    orcc      #IntMasks           mask interrupts
                    lds       #$500               set the system stack
                    pshs      x,y                 save the bootfile pointer and size
                    ldd       #$FF00              A = 255, B = 0
                    tfr       b,dp                transfer to DP
                    sta       INT_MASK_0          mask all set 0 interrupts
                    sta       INT_MASK_1          mask all set 1 interrupts
                    sta       INT_PENDING_0       clear any pending set 0 interrupts
                    sta       INT_PENDING_1       clear any pending set 0 interrupts
*<<<<<<<<<< F256 PORT
                    endc

* Clear out system globals from $0000-$0400.
                    ldx       #$0000              start clearing memory at $0000
                    ldy       #$0400              get the number of bytes to clear
                    clra                          clear A
                    clrb                          clear B (D now $0000)
loop@               std       ,x++                save off at X and increment
                    leay      -2,y                decrement counter
                    bne       loop@               continue if not zero

* Set up the system globals area.
                    inca                          D = $100
                    inca                          D = $200
                    std       <D.FMBM             $200 = start of the free memory bitmap
                    addb      #$20                D = $220
                    std       <D.FMBM+2           $220 = end of the free memory bitmap
                    addb      #$02                D = $222
                    std       <D.SysDis           $222 = address of the system dispatch table
                    addb      #$70                D = $292
                    std       <D.UsrDis           $292 = address of the user dispatch table
                    clrb                          D = $200
                    inca                          D = $300
                    std       <D.ModDir           $300 = module directory starting address
                    stx       <D.ModDir+2         X = $400 = module directory ending address

* This routine checks for RAM by writing a pattern at an address
* then reading it back for validation. It may not be needed, so it's
* conditionalized.
                    ifne      CHECK_FOR_VALID_RAM
*>>>>>>>>>> CHECK_FOR_VALID_RAM
                    ifne      f256
*>>>>>>>>>> F256 PORT
                    ldx       ,s                  get start of bootfile
*<<<<<<<<<< F256 PORT
                    else
*>>>>>>>>>> NOT(F256 PORT)
* Check for valid RAM starting at $400
                    ldx       #Bt.Start           end at bootfile start
*<<<<<<<<<< NOT(F256 PORT)
                    endc
                    pshs      x                   save it on the stack
ChkRAM              leay      ,x                  point Y to X ($400)
                    ldd       ,y                  store org contents in D
                    ldx       #$00FF              set X to pattern to write
                    stx       ,y                  write pattern to ,Y
                    cmpx      ,y                  same as what we wrote?
                    bne       EndOfRAM@           nope, not RAM here!
                    ldx       #$FF00              try different pattern
                    stx       ,y                  write it to ,Y
                    cmpx      ,y                  same as what we wrote?
                    bne       EndOfRAM@           nope, not RAM here!
                    std       ,y                  else restore org contents
                    leax      >$0100,y            check top of next 256 block
                    cmpx      ,s                  stop short kernel
                    bcs       ChkRAM              branch if not done
                    leay      ,x                  point Y to X (end of RAM)
EndOfRAM@           leax      ,y                  X = end of RAM
                    leas      2,s
*<<<<<<<<<< CHECK_FOR_VALID_RAM
                    else
*>>>>>>>>>> NOT(CHECK_FOR_VALID_RAM)
                    ifne      f256
*>>>>>>>>>> F256 PORT
* NOTE: Krn must be the FIRST module in the bootlist.
                    puls      x                   get bootfile start
                    tfr       x,d                 transfer it to D
                    addd      ,s++                add the bootfile length to D
                    std       <D.BTHI             save as the bootfile high marker
                    stx       <D.BTLO             and x as the bootfile low marker
*<<<<<<<<<< F256 PORT
                    else
*>>>>>>>>>> NOT(F256 PORT)
* Check for valid RAM starting at $400
                    ldx       #Bt.Start           end at bootfile start
*<<<<<<<<<< NOT(F256 PORT)
*<<<<<<<<<< NOT(CHECK_FOR_VALID_RAM)
                    endc
                    endc
                    stx       <D.MLIM             save off as the memory limit

                    ifne      f256
*>>>>>>>>>> F256 PORT
* X = top of Krn, so start searching for modules there.
*<<<<<<<<<< F256 PORT
                    endc

* Copy vector code over to D.XSWI3 ($0100).
                    pshs      x                   save off X
                    leax      >VectCode,pcr       point X to vector code
                    ldy       #D.XSWI3            point Y to vector base in low RAM
                    ldb       #VectCSz            get size of vector code in B
loop@               lda       ,x+                 get source byte
                    sta       ,y+                 save in destination
                    decb                          decrement counter
                    bne       loop@               branch if not done
                    puls      x                   recover the saved RAM upper limit

* Atari has bootfile already in memory
                    ifne      atari
*>>>>>>>>>> ATARI LIBER809 PORT
* Flag that we've booted and that Boot Low starts appropriately.
                    ldy       #$D000              Atari: I/O is at $D000-$D7FF
                    inc       <D.Boot
                    stx       <D.BTLO
                    ldx       #$FFFF
                    stx       <D.BTHI
*<<<<<<<<<< ATARI LIBER809 PORT
                    else
                    ifne      corsham
*>>>>>>>>>> CORSHAM PORT
                    ldx       #Bt.Start
                    ldy       #Bt.Start+Bt.Size-1
*<<<<<<<<<< CORSHAM PORT
                    else
                    ifne      f256
*>>>>>>>>>> F256 PORT
                    ldy       #MappedIOStart      stop short of I/O area
*<<<<<<<<<< F256 PORT
                    else
*>>>>>>>>>> NOT(ATARI LIBER809PORT | CORSHAM PORT | F256 PORT)
                    ldy       #Bt.Start+Bt.Size
*<<<<<<<<<< NOT(ATARI LIBER809PORT | CORSHAM PORT | F256 PORT)
                    endc
                    endc
                    endc

                    lbsr      ValMods

* Some platforms don't have contiguous RAM in the 64K address space due to "holes"
* for areas such as I/O. For these platforms, we have to perform a separate
* module scan to look for modules after those holes.
                    ifne      atari
* Atari: look for more modules at $D800-$F3FF.
*>>>>>>>>>> ATARI LIBER809 PORT
* The next three lines reset the low memory and boot start areas so that we can use
* free RAM above $8000. This code works because we just validated modules above and
* the first module found above $8000 is the start of the bootfile.
                    ldx       <D.ModDir           get the pointer to the module diretory
                    ldx       ,x                  get the pointer to the first module entry
                    stx       <D.MLIM             store its address as the low memory limit
                    stx       <D.BTLO             and the bootfile low memory start
                    ldx       #$D800              point to the area past I/O
                    ldy       #$F400              and up to this
                    lbsr      ValMods             validate mods here
*<<<<<<<<<< ATARI LIBER809 PORT
                    endc

* Copy vectors to system globals.
                    leay      >Vectors,pcr        point Y to vectors
                    leax      >ModTop,pcr         point X to top of the kernel
                    pshs      x                   save off
                    ldx       #D.SWI3             point X to vectors in system globals
copy@               ldd       ,y++                get vector bytes
                    addd      ,s                  add the kernel's module address
                    std       ,x++                save off in system globals
                    cmpx      #D.NMI              at the end?
                    bls       copy@               branch if not
                    leas      2,s                 restore stack

* Fill in more system globals.
                    leax      >URtoSs,pcr         get address of user to system state routine
                    stx       <D.URtoSs           store it in system globals
                    leax      >UsrIRQ,pcr         get user state IRQ routine
                    stx       <D.UsrIRQ           store it in system globals
                    leax      >UsrSvc,pcr         get the user state service routine
                    stx       <D.UsrSvc           store it in system globals
                    leax      >SysIRQ,pcr         get the system state IRQ routine
                    stx       <D.SysIRQ           store it in system globals
                    stx       <D.SvcIRQ           and the IRQ sevice vector
                    leax      >SysSvc,pcr         get the system state service routine
                    stx       <D.SysSvc           store it in system globals
                    stx       <D.SWI2             and in the SWI2 vector
                    leax      >Poll,pcr           get the default polling routine
                    stx       <D.Poll             store it in system globals
                    leax      >Clock,pcr          get the default tick generator routine
                    stx       <D.Clock            store it in system globals
                    stx       <D.AltIRQ           and in the alternate IRQ vector

* Install system calls.
                    leay      >SysTbl,pcr         get the system call table address
                    lbsr      InstallSvc          and install it

* Setup the free memory bitmap.
* This area of the kernel is highly platform-dependent.
*
* The free memory bitmap has the following structure:
*   bit 7 of 0,x corresponds to page 0, bit 6 to page 1 etc.
*   bit 7 of 1,x corresponds to page 8, bit 6 to page 9 etc.
                    ldx       <D.FMBM             get free memory bitmap in X
                    ifne      atari
*>>>>>>>>>> ATARI LIBER809 PORT
* Atari needs $0000-$08FF and $D000-$D7FF reserved.
                    ldb       #%11111111
                    stb       ,x                  mark $0000-$07FF as allocated
                    stb       $1A,x               mark $D000-$D7FF I/O area as allocated
                    ldb       #%10000000
                    stb       1,x                 mark $0800-$08FF as allocated
*<<<<<<<<<< ATARI LIBER809 PORT
                    else
                    ifne      corsham
*>>>>>>>>>> CORSHAM PORT
* Corsham needs $0000-$04FF and $E000-$EFFF reserved.
                    ldb       #%11111000
                    stb       ,x                  mark $0000-$04FF as allocated
                    ldb       #%11111111
                    stb       $1C,x               mark $E000-$E7FF I/O area as allocated
                    stb       $1D,x               mark $E800-$EFFF I/O area as allocated
*<<<<<<<<<< CORSHAM PORT
                    else
*>>>>>>>>>> NOT(ATARI LIBER809PORT | CORSHAM PORT)
* All other ports need $0000-$04FF reserved.
                    ldb       #%11111000
                    stb       ,x                  mark $0000-$04FF as allocated
*<<<<<<<<<< NOT(ATARI LIBER809PORT | CORSHAM PORT)
                    endc
                    endc

* Exclude high memory as defined (earlier) by D.MLIM.
                    clra                          A = 0
                    ldb       <D.MLIM             B = upper byte of 16 bit memory limit
                    negb                          negate B
                    tfr       d,y                 transfer D to Y (Y = the number of bits to set)
                    negb                          negate B (D = the number of the first bit to set)
                    lbsr      AllocBit            call into F$AllBit to allocate bits

* Link to init module.
                    lda       #Systm+0            we want a system module
                    leax      >InitNam,pcr        point to the configuration module name
                    os9       F$Link              link to it
                    lbcs      OS9Cold             if error, restart kernel
                    stu       <D.Init             else store it in system globals
                    lda       Feature1,u          get feature byte 1
                    bita      #CRCOn              is CRC checking on?
                    beq       continue@           branch if not (already cleared earlier)
                    inc       <D.CRC              else turn on CRC checking
continue@

* Jump into krnp2 here
                    leax      >P2Nam,pcr          point X to name of kernel part 2 module
                    lda       #Systm+Objct        it should be System+Object code type/language
                    os9       F$Link              link to it
                    lbcs      OS9Cold             branch out if error (catastrophic)
                    jmp       ,y                  else jump to code entry point in part 2 module

SWI3                pshs      pc,x,b              save off registers
                    ldb       #P$SWI3             get P$SWI3
                    bra       FixSWI              save it off in process descriptor
SWI2                pshs      pc,x,b              save off registers again
                    ldb       #P$SWI2             get P$SWI2
                    bra       FixSWI              save it off in process descriptor
SVCNMI              jmp       [>D.NMI]            jump to address in D.NMI
DUMMY               rti                           return from interrupt
SVCIRQ              jmp       [>D.SvcIRQ]         jump to service IRQ address
SWI                 pshs      pc,x,b              save off registers
                    ldb       #P$SWI              get P$SWI
FixSWI              ldx       >D.Proc             get process descriptor
                    ldx       b,x                 get SWI entry
                    stx       3,s                 put in PC on stack
                    puls      pc,x,b              restore registers and return

* User state interrupt service routine entry.
UsrIRQ              leay      <DoIRQPoll,pcr      point to the default IRQ polling routine
* Transition from user to system state.
URtoSs              clra                          clear A
                    tfr       a,dp                and transfer to the direct page
                    ldx       <D.Proc             get current process desc
* The system state service routine address moves into the D.SWI2 vector.
* That way, if a system call is made while we are in system state,
* D.SWI2 is vectored to the system state service routine.
                    ldd       <D.SysSvc           get system state system call vector
                    std       <D.SWI2             store in D.SWI2
* The same comment above applies to the IRQ service vector.
                    ldd       <D.SysIRQ           get system IRQ vector
                    std       <D.SvcIRQ           store in D.SvcIRQ
                    leau      ,s                  point U to S
                    stu       P$SP,x              and save in process P$SP
                    lda       P$State,x           get state field in proc desc
                    ora       #SysState           mark process to be in system state
                    sta       P$State,x           store it
                    jmp       ,y                  jump to the polling routine

DoIRQPoll           jsr       [>D.Poll]           call the interrupt polling routine
                    bcc       go@                 branch if carry clear
                    ldb       ,s                  get the CC on the stack
                    orb       #IRQMask            mask IRQs
                    stb       ,s                  and save it back
go@                 lbra      ActivateProc        go activate the process

* System state interrupt service routine entry
SysIRQ              clra                          clear A
                    tfr       a,dp                and transfer it to the direct page
                    jsr       [>D.Poll]           call the vectored IRQ polling routine
                    bcc       ex@                 branch if carry is clear
                    ldb       ,s                  get the CC on the stack
                    orb       #IRQMask            mask IRQs
                    stb       ,s                  and save it back
ex@                 rti                           return from interrupt

* This is the default interrupt polling routine -- it does nothing.
Poll                comb
                    rts

* Here is the default clock routine which performs process queue management.
Clock               ldx       <D.SProcQ           get pointer to sleeping proc queue
                    beq       decslice@           branch if no process sleeping
                    lda       P$State,x           get state of that process
                    bita      #TimSleep           timed sleep?
                    beq       decslice@           branch if clear
                    ldu       P$SP,x              else get process stack pointer
                    ldd       R$X,u               get the value of the process X reg
                    subd      #$0001              subtract one from it
                    std       R$X,u               and store it back
                    bne       decslice@           branch if not zero (still will sleep)
nextqentry@         ldu       P$Queue,x           get process current queue pointer
                    bsr       SFAProc             activate the process
                    leax      ,u                  point to the queue
                    beq       saveit@             branch if empty
                    lda       P$State,x           get process state byte
                    bita      #TimSleep           bit set?
                    beq       saveit@             branch if not
                    ldu       P$SP,x              get process stack pointer
                    ldd       R$X,u               then get process X register
                    beq       nextqentry@         branch if zero
saveit@             stx       <D.SProcQ           save in the sleep queue
decslice@           dec       <D.Slice            decrement slice
                    bne       ex@                 if not 0, exit ISR
                    lda       <D.TSlice           else get default time slice
                    sta       <D.Slice            and save it as slice
                    ldx       <D.Proc             get proc desc of current proc
                    beq       ex@                 if none, exit ISR
                    lda       P$State,x           get process state
                    ora       #TimOut             set timeout bit
                    sta       P$State,x           and store back
                    bpl       gosys@              branch if not system state
ex@                 rti                           return from the interrupt
gosys@              leay      >ActivateProc,pcr   point Y to activate process routine
                    bra       URtoSs              go to system state

                    use       faproc.asm

* User state system call entry point.
*
* All system calls made from user state go through this code.
UsrSvc              leay      <MakeSysCall,pcr    point Y to make system call routine
                    orcc      #IntMasks           mask interrupts
                    lbra      URtoSs              go to system state

MakeSysCall         andcc     #^IntMasks          unmask interrupts
                    ldy       <D.UsrDis           get pointer to user system call dispatch table
                    bsr       DoSysCall           go do the system call
ActivateProc        ldx       <D.Proc             get current proc desc
                    beq       FNProc              branch to FNProc if none
                    orcc      #IntMasks           mask interrupts
                    ldb       P$State,x           get state value in proc desc
                    andb      #^SysState          turn off system state flag
                    stb       P$State,x           save state value
                    bitb      #TimOut             timeout bit set?
                    beq       CheckState          branch if not
                    andb      #^TimOut            else turn off bit
                    stb       P$State,x           in state value
                    bsr       SFAProc
                    bra       FNProc              next process

* System state system call entry point.
*
* All system calls made from system state go through this code.
SysSvc              clra                          A = 0
                    tfr       a,dp                set direct page to 0
                    leau      ,s                  point U to SP
                    ldy       <D.SysDis           get system state dispatch table ptr
                    bsr       DoSysCall           perform the system call
                    rti                           return

* This is the common system call entry point for user and system state.
*
* Entry: Y = The dispatch table (user or system).
*        U = The caller's register pointer.
DoSysCall           pshs      u                   save off caller's register pointer
                    ldx       R$PC,u              point X to PC
                    ldb       ,x+                 get func code at X
                    stx       R$PC,u              restore updated PC
                    lslb                          high bit set?
                    bcc       nonio@              branch if not (non I/O call)
                    rorb                          else restore B (its an I/O call)
                    ldx       -2,y                grab IOMan vector
                    beq       callexit@           just exit if IOMan vector is empty
                    bra       execcall@           make system call
nonio@              cmpb      #$37*2              non-IO call; are we in safe are?
                    bcc       callerr@            branch if not (unknown service)
                    ldx       b,y                 X = address of system call
                    beq       callerr@            if nil, unknown service
execcall@           jsr       ,x                  jsr into system call
callexit@           puls      u                   recover caller's registers
                    tfr       cc,a                get CC into A
                    bcc       FixCC               branch if no error
                    stb       R$B,u               store error code
FixCC               ldb       R$CC,u              get caller's CC
                    andb      #^(Negative+Zero+TwosOvfl+Carry) turn off these flags
                    stb       R$CC,u              save to caller's CC
                    anda      #Negative+Zero+TwosOvfl+Carry turn off these flags
                    ora       R$CC,u              OR with caller's CC
                    sta       R$CC,u              and saved to caller's CC
                    rts                           return
callerr@            comb                          set carry for error state
                    ldb       #E$UnkSvc           unknown service
                    bra       callexit@           perform exit

                    use       fnproc.asm
                    use       flink.asm
                    use       fvmodul.asm
                    use       fcrc.asm
                    use       ffork.asm
                    use       fchain.asm
                    use       fsrqmem.asm
                    use       fallbit.asm
                    use       fprsnam.asm
                    use       fcmpnam.asm
                    use       fssvc.asm

* Validate modules in memory.
*
* Entry: X = The address to start searching.
*        Y = The address to stop (actually stops at Y-1).
ValMods             pshs      y                   save off Y
loop@               lbsr      ValMod              go validate module
                    bcs       ValErr              branch if error
                    ldd       M$Size,x            get size of module into D
                    leax      d,x                 point X past module
                    bra       valcheck            go check if we're at end
ValErr              cmpb      #E$KwnMod           did the validation check show a known module?
                    beq       ex@                 branch if so
                    leax      1,x                 else advance X by one byte
valcheck            cmpx      ,s                  check if we're at end
                    bcs       loop@               branch if not
ex@                 puls      y,pc                restore Y and return

* This vector code that the kernel copies to low RAM ($0100).
VectCode            bra       SWI3Jmp             $0100
                    nop
                    bra       SWI2Jmp             $0103
                    nop
                    bra       SWIJmp              $0106
                    nop
                    bra       NMIJmp              $0109
                    nop
                    bra       IRQJmp              $010C
                    nop
                    bra       FIRQJmp             $010F
SWI3Jmp             jmp       [>D.SWI3]
SWI2Jmp             jmp       [>D.SWI2]
SWIJmp              jmp       [>D.SWI]
NMIJmp              jmp       [>D.NMI]
IRQJmp              jmp       [>D.IRQ]
FIRQJmp             jmp       [>D.FIRQ]
VectCSz             equ       *-VectCode


* The system call table.
SysTbl              fcb       F$Link
                    fdb       FLink-*-2
                    fcb       F$Fork
                    fdb       FFork-*-2
                    fcb       F$Chain
                    fdb       FChain-*-2
                    fcb       F$Chain+SysState
                    fdb       SFChain-*-2
                    fcb       F$PrsNam
                    fdb       FPrsNam-*-2
                    fcb       F$CmpNam
                    fdb       FCmpNam-*-2
                    fcb       F$SchBit
                    fdb       FSchBit-*-2
                    fcb       F$AllBit
                    fdb       FAllBit-*-2
                    fcb       F$DelBit
                    fdb       FDelBit-*-2
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
                    fcb       F$SSvc
                    fdb       FSSvc-*-2
                    fcb       $80

InitNam             fcs       /Init/

P2Nam               fcs       /krnp2/

EOMTop              equ       *

                    ifeq      corsham+f256
*>>>>>>>>>> NOT(CORSHAM PORT | F256 PORT)
                    emod
eom                 equ       *
*<<<<<<<<<< NOT(CORSHAM PORT | F256 PORT)
                    endc

Vectors		        fdb	       SWI3		SWI3
                    fdb	       SWI2		SWI2
                    fdb	       DUMMY		FIRQ
                    fdb	       SVCIRQ		IRQ
                    fdb	       SWI		SWI
                    fdb	       SVCNMI		NMI

                    ifne      atari
*>>>>>>>>>> ATARI LIBER809 PORT
                    fdb       $F3FE-(*-OS9Cold)
*<<<<<<<<<< ATARI LIBER809 PORT
                    endc
                    
                    ifne      corsham+f256
*>>>>>>>>>> CORSHAM PORT | F256 PORT
                    emod
eom                 equ       *
*<<<<<<<<<< CORSHAM PORT | F256 PORT
                    endc
EOMSize             equ       *-EOMTop

                    end
