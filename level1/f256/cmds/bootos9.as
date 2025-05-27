********************************************************************
* bootos9 - OS-9 bootstrap utility for the Foenix F256
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2023/11/03  Boisy Gene Pitre
* This is the start of a booter that searches for an OS-9 bootfile.
*
*          2024/06/28  Boisy Gene Pitre
* Converted into a stand-alone command line utility.

                    section   bss
bootpath            rmb       80        the bootfile's absolute path
diskpath            rmb       1         path to disk
krnentry            rmb       2         address of kernel entry point
bootaddr            rmb       2         bootfile load address
bootsize            rmb       2         bootfile size in bytes
bootpages           rmb       1         # of 256-byte pages to accommodate the bootfile
bootblocks          rmb       1         # of 8K blocks to accommodate the bootfile
startblock          rmb       1         the starting block number to load the bootfile into
sectorbuffer        rmb       256       holds sectors read from disk
stack               rmb       200
                    endsect

                    section   code

PrintModeFailure    lbsr      PRINTS
                    fcc       "Can't boot in RAM mode."
                    fcb       C$CR,0
                    rts

PrintSearch         lbsr      PRINTS
                    fcc       "Searching for "
                    fcb       0
                    leax      bootpath,u
                    lbsr      PUTS
                    ldb       #'.
                    lbra      PUTC

**********************************************************
* Entry Point
*
* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   B = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined
*
* The start of the program is here.
**********************************************************
__start
* Determine whether we're in RAM or FLASH mode -- we can't boot in RAM mode.
                    lda       MMU_SLOT_7 get MMU slot 7
                    cmpa      #$07      is it 7? (indicates that we're running from RAM)
                    beq       ram@      branch if so
* We're in FLASH mode... continue.
                    decb                decrement parameter length
                    beq       ex@       if no parameter, just exit
* Copy the parameter.
                    leay      bootpath,u
l@                  lda       ,x+
                    sta       ,y+
                    decb
                    bne       l@
                    clr       ,y
                    leax      bootpath,u
* Perform boot.
                    bsr       BootOS9   attempt to boot...
                    bcs       ex@       branch if error
                    jmp       ,x        else jump and boot OS-9, never to return!
ram@                bsr       PrintModeFailure print that we can't boot in RAM mode
ex@                 os9       F$Exit    exit

* Boot OS-9
*
* Entry: X = The pointer to the path of the bootfile to load.
*
* Exit:  X = The address to jump to if no error.
*       CC = carry clear indicating no error; or set indicating error.
BootOS9             bsr       PrintSearch print the message
                    leax      bootpath,u point to the boot pathlist
                    lda       #READ.    open the file in read mode
                    os9       I$Open    open it
                    bcc       FoundIt   branch if found
print_and_bye
                    pshs      b,cc
                    lbsr      PUTCR     put a CR
                    puls      b,cc
                    cmpb      #E$PNNF   is it a pathname not found error?
                    lbeq      PrintPathNotFound yes, go print
                    cmpb      #E$MNF    is it a module (kernel) not found error?
                    lbeq      PrintKrnNotFound yes, go print
                    cmpb      #E$Unit   is it a unit (device) error?
                    lbeq      PrintDeviceError yes, go print
                    cmpb      #E$NotRdy is it a not ready error?
                    lbeq      PrintNotReadyError yes, go print
                    cmpb      #E$Read   is it a read error?
                    lbeq      PrintReadError yes, go print
                    cmpb      #E$Sect   is it a bad sector error?
                    lbeq      PrintBadSectorError yes, go print
ret                 rts                 return

* Get the bootfile size.
*
* A = path to the file
FoundIt             sta       diskpath,u save the file path number
                    lbsr      PUTCR     put a CR
                    lbsr      PrintFound print the message

GetSize             lda       diskpath,u get the file path number
                    ldb       #SS.Size  we want the file size
                    pshs      u         save the static storage pointer
                    os9       I$GetStt  get the file size
                    tfr       u,x       we only want the lower 16 bits
                    puls      u         recover the static storage pointer
                    bcs       print_and_bye if error, leave
                    stx       bootsize,u else save the bootfile size for later

* Compute starting address in 64K address space
                    pshs      x         save the bootfile size
                    ldd       #$FE00    load D with end of where bootfile can go + 1
                    subd      ,s++      compute the bootfile starting address in memory
                    clrb                round down to the nearest 256 byte page
                    std       bootaddr,u save that

* Pull contents of bootfile into RAM.
*
* diskpath,u = path to bootfile on device
* bootsize,u = size of bootfile
                    ldd       bootsize,u get the bootfile size
                    addd      #$00FF    round up D to the nearest 256 bytes
                    sta       bootpages,u and save # of 256 byte pages
* A = the number of 256 byte pages needed to hold the bootfile.
* Determine how many 8KB blocks we need.
                    tfr       a,b       copy A to B
shift@              lsra                A = A / 2
                    lsra                A = A / 2
                    lsra                A = A / 2
                    lsra                A = A / 2
                    lsra                A = A / 2
                    andb      #%00011111 mask out bits 7-5
                    beq       cont@     branch if zero
                    inca                else increment A
* A = the number of 8KB blocks we need to hold the bootfile.
cont@               sta       bootblocks,u save the 8KB block count
                    lda       #$8       start with 8 8K blocks (64K)
                    suba      bootblocks,u subtract the number of 8KB blocks needed
                    stb       startblock,u
                    ldd       bootsize,u get the bootfile size in D
                    ldy       bootaddr,u and the bootfile starting address in Y
l@                  pshs      d,y       save them
                    lda       diskpath,u get the bootfile path number
                    ldb       #READ.    we want to read
                    ldy       #256      256 bytes
                    leax      sectorbuffer,u into this buffer
                    os9       I$Read    read it
                    bcs       err@      branch if we have an error
                    ldb       #'.       indicate we read a sector
                    lbsr      PUTC      by putting the character on the screen
                    leax      sectorbuffer,u reload X with the buffer pointer (needed?)
                    ldy       2,s       get the address to copy to
                    lbsr      MMUCopy   perform the copy of the sector
skip@               leay      256,y     move Y up to the next location
                    sty       2,s       and save it back on the stack
                    puls      d,y       recover the registers
                    subd      #256      decrement the counter
                    cmpd      #$0000    are we at the end?
                    bgt       l@        no, continue
                    ldx       bootaddr,u copying is done; get the bootfile starting address
                    lbsr      DetermineKernel and determine what kind of kernel (if any)
                    lbcs      print_and_bye if carry set, no kernel was found, so return
                    stx       krnentry,u else X contains the kernel entry point; save it
                    lbra      ExecBoot  then go boot into OS-9
err@                leas      4,s       recover the stack
                    lbra      print_and_bye and return

* At this point, the bootfile is loaded into RAM.
* Identify which OS-9 bootfile it is:
*  - Level 1: Krn is first module at start of bootfile
*  - Level 2: Krn is last module and located at $EE00
*
* Entry: X = The starting address of the bootfile in memory.
*
* Exit:  X = The entry point of the kernel.
*        CC = Carry clear indicating a kernel was found.
*
* Error: CC = Carry set indicating no kernel found.
DetermineKernel
                    pshs      cc        preserve the interrupt mask
                    orcc      #IntMasks then mask interrupts
* The Level 2 kernel is always at $EE00.
CheckLevel2         lda       $FFA8+MMU_COPY_BLOCK get the MMU slot value
                    pshs      a         save it
                    lda       #$07      we'll look at page 7 for the Level 2 kernel
                    sta       $FFA8+MMU_COPY_BLOCK switch the MMU so that $E000-$FFFF appears at the check slot
                    ldx       #$EE00    the Level 2 kernel should start here
                    ldd       -(7-MMU_COPY_BLOCK)*$2000,x load the two bytes at the test address
                    cmpd      #$87CD    OS-9 module sync bytes?
                    bne       CheckLevel1 nope, go check for a Level 1 kernel
                    ldd       -(7-MMU_COPY_BLOCK)*$2000+9,x get the entry point offset
                    leax      d,x       add it to the kernel module start
                    bra       okex@     and return
* The Level 1 kernel always starts at the beginning of the bootfile.
CheckLevel1         lda       bootaddr,u get the starting page of the bootfile in memory
                    lsra                A = A / 2
                    lsra                A = A / 4
                    lsra                A = A / 8
                    lsra                A = A / 16
                    lsra                A = A / 32
                    sta       $FFA8+MMU_COPY_BLOCK switch the MMU so that the start of the bootfile appears at the check slot
                    lda       bootaddr,u get the starting page of the bootfile in memory
                    anda      #%00011111 to compute offset in the 8KB block
                    clrb
                    ldx       #(MMU_COPY_BLOCK)*$2000 load the two bytes at the starting address
                    leax      d,x       point to kernel
                    ldd       ,x        load first two bytes
                    cmpd      #$87CD    OS-9 module sync bytes?
                    bne       badex@    nope, give up
                    ldd       9,x
                    ldx       bootaddr,u
                    leax      d,x
                    bra       okex@
badex@
                    puls      b         recover the MMU slot saved earlier
                    stb       $FFA8+MMU_COPY_BLOCK and put it back in the hardware
                    ldb       ,s        get the CC saved earlier
                    orb       #Carry    set the carry to indicate no kernel found
ex@                 stb       ,s        save it back
                    ldb       #E$MNF    return "module not found" error
                    puls      cc,pc     recover and return
okex@               puls      b         recover the MMU slot saved earlier
                    stb       $FFA8+MMU_COPY_BLOCK and put it back in the hardware
                    ldb       ,s        get the CC saved earlier
                    andb      #^Carry   clear the carry to indicate we found the kernel
                    bra       ex@       return


* Now we need to relocate at a safe address, set up the MMU,
* and jump into the kernel.
RELOC_ADDR          equ       $600
ExecBoot            orcc      #IntMasks mask interrupts
                    pshs      u         save the statics pointer
                    leax      RelocStart,pcr point to the code to relocate
                    ldy       #RELOC_ADDR and the destination address
                    ldu       #RelocSize get the number of bytes to copy
l@                  lda       ,x+       get the source byte
                    sta       ,y+       and store it in the destination
                    leau      -1,u      decrement the counter
                    cmpu      #$0000    are we finished?
                    bne       l@        branch if not
                    puls      u         recover the statics pointer
                    jmp       RELOC_ADDR and jump to the relocated area

* This code sets up the MMU and jumps to the kernel's entry point.
* Interrupts should be masked before getting here.
RelocStart
* Set up the MMU so that it's ready for the kernel.
                    clrb
                    ldx       #$FFA8    point to the hardware MMU
l@                  stb       ,x+       store the MMU page
                    incb                increment it
                    cmpb      #8        are we done?
                    bne       l@        branch if not
                    ldx       bootaddr,u get the bootfile starting address
                    ldy       bootsize,u and the bootfile size
                    ldu       krnentry,u get the kernel entry point address
                    jmp       ,u        jump into the kernel
RelocSize           equ       *-RelocStart

* Copy 256 bytes from X to Y
*
* Entry: X = 256 bytes to copy from.
*        Y = Address in 64K address space to copy to.
*
* Exit:  X = X + 256
MMU_COPY_BLOCK      equ       1
MMUCopy             pshs      cc,y,u    save registers
                    lda       $FFA8+MMU_COPY_BLOCK get the MMU slot value
                    pshs      a         save it
* compute block and offset of destination
                    tfr       y,d       move the destination address into D
                    bsr       Page2Block get the 8KB block (0-7)
                    orcc      #IntMasks mask interrupts
                    stb       $FFA8+MMU_COPY_BLOCK map in the block
                    clrb                clear the LSB
                    addd      #MMU_COPY_BLOCK*$2000 add in the block base address
                    tfr       d,y       move the address into Y
                    ldu       #256      set the counter
l@                  ldd       ,x++      read bytes from source
                    std       ,y++      and write to destination
                    leau      -2,u      decrement the counter
                    cmpu      #$0000    are we done?
                    bne       l@        branch if not
                    puls      a         recover original slot value
                    sta       $FFA8+MMU_COPY_BLOCK and save it back to MMU
                    puls      y,u,cc,pc return

* Compute 8KB block based on A
*
* Entry: A = 256 byte page in 64K memory
*
* Exit:  A = The offset in the block.
*        B = 8KB block that maps to the page.
Page2Block          tfr       a,b       copy A to b
                    lsrb                B = B / 2
                    lsrb                B = B / 2
                    lsrb                B = B / 2
                    lsrb                B = B / 2
                    lsrb                B = B / 2
                    anda      #%00011111 A = offset in block
                    rts                 return

PrintDeviceError    lbsr      PRINTS
                    fcc       "The device has an error."
                    fcb       C$CR,0
                    bra       badex

PrintNotReadyError  lbsr      PRINTS
                    fcc       "The device isn't ready or available."
                    fcb       C$CR,0
                    bra       badex

PrintBadSectorError lbsr      PRINTS
                    fcc       "A sector error occurred."
                    fcb       C$CR,0
badex               orcc      #Carry
                    rts

PrintReadError      lbsr      PRINTS
                    fcc       "A read error occurred."
                    fcb       C$CR,0
                    bra       badex

PrintKrnNotFound    lbsr      PRINTS
                    fcc       "Can't locate the kernel in the bootfile."
                    fcb       C$CR,0
                    bra       badex

PrintPathNotFound   leax      bootpath,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       " not found."
                    fcb       C$CR,0
                    bra       badex
                    
PrintFound          leax      bootpath,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       " found."
                    fcb       C$CR
                    fcc       "Loading sector"
                    fcb       0
                    rts

                    endsect   0
