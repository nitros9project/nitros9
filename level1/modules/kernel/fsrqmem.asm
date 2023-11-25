                    ifeq      Level-1

;;; F$SRqMem
;;;
;;; Allocate one or more pages of memory.
;;;
;;; Entry:  D = The number of bytes to allocate.
;;;
;;; Exit:   D = The number of bytes allocated.
;;;         U = The address of the newly allocated area.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$SRqMem allocates contiguous memory from the system in 256 byte pages. There are 256 of these 256 byte pages
;;; in the entire address space. It returns memory from the top of the system RAM map down, and rounds the size
;;; request to the next 256 byte page boundary.

**************************************************
* F$SRqMem - Level 1 implementation
*
FSRqMem             ldd       R$D,u               get memory allocation size requested from the caller's D
                    addd      #$00FF              round it up to nearest 256 byte page (e.g. $1FF = $2FE)
                    clrb                          just keep # of pages (e.g. $2FE = $200)
                    std       R$D,u               save rounded version back to caller's D
* Start searching from the top of free memory allocation bitmap down, searching for 'D' contiguous bits
                    ldx       <D.FMBM+2           get the pointer to the end of the free memory allocation bitmap
                    ldd       #$01FF              A = $01 (RAM IN USE flag), B = $FF ("first free 256 byte page")
                    pshs      b,a                 save the values on stack
_stk1A@             set       0                   bit flag indicating RAM IN USE
_stk1B@             set       1                   offset to first free 256 byte page (assuming enough memory is found)
_stk1L@             set       2                   length of stack
                    bra       top@                start the search
loop@               dec       _stk1B@,s           decrement "first free 256 byte page" value on stack
                    ldb       _stk1B@,s           and load it into B
nextbit@            lsl       _stk1A@,s           shift left: bit 7 of _stk1A goes in carry, 0 goes in bit 0 of _stk1A
                    bcc       checkbit@           branch if high bit in _stk1A was 0
                    rol       _stk1A@,s           put set carry in bit 0, put MSB of bit (1) in carry
top@                leax      -1,x                backup into free memory bitmap
                    cmpx      <D.FMBM             did we move past the beginning?
                    bcs       doalloc@            branch if so (carry set if X < D.FMBM)
checkbit@           lda       ,x                  get byte in current location of free memory allocation bitmap
                    anda      _stk1A@,s           AND with mask on stack
                    bne       loop@               branch if not 0, meaning there are bits set in A (pages allocated) so continue searching
                    dec       _stk1B@,s           decrement "first free 256 byte page" value on stack
                    subb      _stk1B@,s           subtract "first free 256 byte page" value on stack from B
                    cmpb      R$A,u               compare B to the requested number of pages in caller's A (may set carry)
                    rora                          shift carry into A's bit 7, and bit 0 of A into carry (saves carry bit in bit 7 of A)
                    addb      _stk1B@,s           add back "first free 256 byte page" value on stack to B
                    rola                          roll A's bit 7 into carry, and carry into A's bit 0 (restores original carry)
                    bcs       nextbit@            branch if the carry is set
                    ldb       _stk1B@,s           get the contiguous free memory bit count
                    clra                          clear A
                    incb                          increment B
doalloc@            leas      _stk1L@,s           recover stack from earlier push
                    bcs       ex@                 branch if error
                    ldx       <D.FMBM             else get pointer to start of free memory bitmap
                    tfr       d,y                 put D (number of first bit to set) into Y
                    ldb       R$A,u               get MSB into B (this will be bit count)
                    clra                          clear A; D now holds number of bits to set
                    exg       d,y                 swap D and Y so that parameters are correct
* X = address of allocation bitmap
* D = Number of first bit to set
* Y = Bit count (number of bits to set)
                    bsr       AllocBit            call into F$AllBit to allocate Y bits starting at bit D in the table X
                    exg       a,b                 swap A and B
                    std       R$U,u               put allocated address into caller's U
okex                clra                          clear carry
                    rts                           return to the caller
ex@                 comb                          set carry
                    ldb       #E$MemFul           indicate memory is full
                    rts                           return to the caller

;;; F$SRtMem
;;;
;;; Return one or more pages of memory to the free memory pool.
;;;
;;; Entry:  D = The number of bytes to return.
;;;         U = The address of the memory to return.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$SRtMem returns memory allocated by F$SRqMem to the system.

FSRtMem             ldd       R$D,u               get the memory allocation size requested from the caller's D
                    addd      #$00FF              round it up to nearest 256 byte page (e.g. $1FF = $2FE)
                    tfr       a,b                 put MSB into B
                    clra                          now D reflects number of 256 byte pages to return
                    tfr       d,y                 put the 16 bit page count into Y
                    ldd       R$U,u               get the address of memory to free from the caller's U
                    beq       okex                if user passed 0, ignore
                    tstb                          check for B = 0 (it should!)
                    beq       returnmem@          it does... return it to the system
                    comb                          the user has passed B<>0 for the address
                    ldb       #E$BPAddr           the error is bad page address
                    rts                           return to the caller
returnmem@          exg       a,b                 swap A/B
                    ldx       <D.FMBM             get pointer to free memory bitmap
                    bra       DelBit              call into F$DelBit to delete bits

                    else

**************************************************
* F$SRqMem - Level 2 implementation
*
* CoCo 3 note: Memory is allocated from the top of the system RAM map downwards.
* rel/boot/krn also reside in this area, and are loaded from $ED00-$FFFF.
* Since this area is always allocated, we start searching for free pages from page
* $EC downward.
*
* F$SRqMem also updates the system memory map according to 8K DAT blocks. If an
* empty block is found, this routine re-does the 32 entries in the SMAP table to
* indicate that they are free.

FSRqMem             ldd       R$D,u               get the memory allocation size requested
                    addd      #$00FF              round it up to the nearest 256 byte page (e.g. $1FF = $2FE)
                    clrb                          just keep the number of pages (and the starting 8K block number, e.g. $2FE = $200)
                    std       R$D,u               save the rounded up version back to the user's D
                    pshs      d                   reserve a byte and put 0 byte on stack

* IMPORTANT!!!
* The following code was put in some time back to fix a problem.  That problem was not documented
* so I cannot recall why this code was in place.  What it appears to do is reset the system page
* memory map based upon the state of the system DAT image.
* This code really slows down F$SRqMem and since that system call is used quite often in the system,
* I am commenting it out in the hopes that I can remember what the hell I put it in for. -- Boisy
                    ifeq      1
                    ldy       <D.SysMem           get ptr to SMAP table
* This loop updates the SMAP table if anything can be marked as unused
L082F               ldx       <D.SysDAT           get pointer to system DAT block list
                    lslb                          adjust block offset for 2 bytes/entry
                    ldd       b,x                 get block type/# from system DAT
                    cmpd      #DAT.Free           Unused block?
                    beq       L0847               yes, mark it free in SMAP table
                    ldx       <D.BlkMap           No, get ptr to MMAP table
                    lda       d,x                 Get block marker for 2 meg mem map
                    cmpa      #RAMinUse           Is it in use (not free, ROM or used by module)?
                    bne       L0848               No, mark it as type it is in SMAP table
                    leay      32,y                Yes, move to next block in pages
                    bra       L084F               move to next block & try again
* Free RAM:
L0847               clra                          Byte to fill system page map with (0=Not in use)
* NOT! RAMinUse:
                    ifne      H6309
L0848               sta       ,s                  Put it on stack
                    ldw       #$0020              Get size of 8K block in pages
                    tfm       s,y+                Mark entire block's worth of pages with A
                    else
L0848               ldb       #32                 count = 32 pages
L084A               sta       ,y+                 mark the RAM
                    decb
                    bne       L084A
                    endc
L084F               inc       1,s                 Bump up to next block to check
                    ldb       1,s                 Get it
                    cmpb      #DAT.BlCt           Done whole 64k system space?
                    blo       L082F               no, keep checking
                    endc


* Now we can actually attempt to allocate the system RAM requested
* NOTE: Opt for CoCo/TC9 OS9 ONLY: skip last 256 - Bt.Start pages since
* they are: Kernel (REL/BOOT/KRN - 17 pages), vector RAM & I/O (2 pages)
* (Already permanently marked @ L01D2)
* At the start, Y is pointing to the end of the SMAP table+1
                    ldx       <D.SysMem           get the starting address of the system free memory map
                    ifne      f256
* Under OS-9 Level 2 for the F256, the entire bootfile is loaded into RAM by FEU.
* There is no F$Boot. Because of this, we start searching for free memory at the
* very end of the system free memory map.
                    leay      256,x               point Y to very end of system free memory map
                    else
                    leay      Bt.Start/256,x      point Y to starting page where the bootfile was loaded
                    endc
                    ldb       #32                 skip block 0: it's always full
                    abx                           update X to point to the starting place to search for
L0857               ldb       R$A,u               get the number of 256 byte pages requested
* Loop from the end of the system free memory map) to look for the number continuous pages requested
L0859               equ       *
                    ifne      H6309
                    cmpr      x,y                 do we still have any system RAM left to try?
                    else
                    pshs      x                   save X
                    cmpy      ,s++                compare Y to X
                    endc
                    bhi       L0863               if Y (end) is higher than X (start), continue looking
                    comb                          else set the carry
                    ldb       #E$NoRAM            load the "no system RAM" error
                    bra       L0894               and branch to return

L0863               lda       ,-y                 get the page marker (starting at the end of the system free memory map)
                    bne       L0857               branch if it's not zero (the page is allocated, so test the next lower one)
                    decb                          found 1 page, decrement the number of pages we need to allocate
                    bne       L0859               branch if we still more pages needed to see if we can get more
                    sty       ,s                  here, we've found all of the free contiguous pages, so save the pointer
                    lda       1,s                 get the LSB of the pointer
                    lsra                          A = A / 2
                    lsra                          A = A / 4
                    lsra                          A = A / 8
                    lsra                          A = A / 16
                    lsra                          A = A / 32 to obtain the starting 8KB block number
                    ldb       1,s                 get the LSB of the pointer
                    andb      #%00011111          keep the offset within the 8KB block
                    addb      R$A,u               add the number of pages requested
                    addb      #$1F                round up to the nearest 8KB block
                    lsrb                          B = B / 2
                    lsrb                          B = B / 4
                    lsrb                          B = B / 8
                    lsrb                          B = B / 16
                    lsrb                          Divide by 32 to obtain the ending 8KB block number
                    ldx       <D.SysPrc           get the pointer to the system process descriptor
**************************
* The following code addresses a bug where the call into F$AllImg could fail if the number of blocks
* in B was 2, thereby crossing an 8KB boundary. The specific case that surfaced this was early on
* the kernel's bootstrap. A was 4 and B was 2, and the kernel had slots 0, 5, 6, and 7 assigned to
* 8KB blocks. Because B was 2, F$AllImg was asked to allocate 8KB blocks for slots 4 and 5. Since
* slot 5 was already holding an 8KB block, F$AllImg returned an error and this call failed, causing
* the kernel to crash.
* The following code checks the system's DAT image in the process descriptor to ensure that the
* slots that it's asking to obtain 8KB blocks for are indeed available; if not, it decrements the
* number of blocks to request in B.
* Boisy - 10/27/23
                    pshs      d,x                 save registers
                    leax      P$DATImg,x          point into the DAT image of the process descriptor
l@                  ldb       ,s                  get the starting block
                    decb                          decrement it since we're adding the number next
                    addb      1,s                 add the number of blocks
                    lslb                          A = A * 2
                    ldd       b,x                 get the entry in the DAT image
                    cmpd      #DAT.Free           is it free?
                    beq       ok@                 branch if so
                    dec       ,s                  else decrement starting block
                    bne       l@                  and go try next
ok@                 puls      d,x                 recover registers
**************************
                    lbsr      L09BE               allocate an image with our start/end block numbers
                    bcs       L0894               branch if we couldn't do it
                    ldb       R$A,u               else get the number of requested pages
*         lda   #RAMinUse    Get SMAP in use flag
*L088A    sta   ,y+          Mark all the pages requested as In Use
L088A               inc       ,y+                 since RAMinUse is 1, we can save space by INC'ing from 0->1
                    decb                          decrement the counter
                    bne       L088A               continue if not at 0
                    lda       1,s                 get the MSB of the pointer to the start of the newly allocated system RAM
                    std       R$U,u               save to the caller's U
                    clrb                          clear the error code and carry
L0894               puls      u,pc                return (U is changed after it exits)


**************************************************
* F$SRtMem - Level 2 implementation
*
FSRtMem             ldd       R$D,u               get the number of pages to free up
                    beq       L08F2               branch if the caller passed 0 (nothing to free!)
                    addd      #$00FF              else round up the value to nearest page
                    ldb       R$U+1,u             get the LSB of the address
                    beq       L08A6               it's a even page, so skip ahead
                    comb                          else set the carry
                    ldb       #E$BPAddr           load the "bad page address" error number
                    rts                           return

L08A6               ldb       R$U,u               get the MSB of the page address
                    beq       L08F2               branc if it's 0 (not a legal page)
                    ldx       <D.SysMem           get the pointer to the system free memory map
                    abx                           set the pointer into the map
L08AD               equ       *
                    ifne      H6309
                    aim       #^RAMinUse,,x+      clear the "RAM in use" bit
                    else
                    ldb       ,x                  get the page byte
                    andb      #^RAMinUse          clear the "RAM in use" bit
                    stb       ,x+                 save the page byte back and increment the index register
                    endc
                    deca                          decrement the counter
                    bne       L08AD               branch if not done
* Scan the DAT image to find the memory blocks to free up.
                    ldx       <D.SysDAT           get the pointer to the system DAT image
                    ifne      H6309
                    lde       #DAT.BlCt           get the number of blocks to check
                    else
                    ldy       #DAT.BlCt           get the number of blocks to check
                    endc
L08BC               ldd       ,x                  get the block image
                    cmpd      #DAT.Free           is it already free?
                    beq       L08EC               yes, skip to the next one
                    ldu       <D.BlkMap           else get the pointer to the MMU block map
                    lda       d,u                 get the allocation flag for this block: 16-bit offset
                    cmpa      #RAMinUse           is it being used?
                    bne       L08EC               no, move to the next block
                    tfr       x,d                 else transfer the pointer to D
                    subd      <D.SysDAT           set D to the offset in the system DAT image
                    lslb                          B = B * 2
                    lslb                          B = B * 4
                    lslb                          B = B * 8
                    lslb                          B = B * 16
                    ldu       <D.SysMem           get the pointer to the system map
                    ifne      H6309
                    addr      d,u                 point to the offset in the system free memory map
* Check if we can remove the entire memory block from system map
                    ldf       #16                 get the number of pages per block / 2
L08DA               ldd       ,u++                are either of these 2 pages allocated?
                    else
                    leau      d,u                 point to the offset in the system free memory map
                    ldb       #32                 set the counter
L08DA               lda       ,u+                 are either of these 2 pages allocated?
                    endc
                    bne       L08EC               yes, we can't free this block, so skip to next one
                    ifne      H6309
                    decf                          have we checked all pages?
                    else
                    decb                          decrement the counter
                    endc
                    bne       L08DA               no, keep looking
                    ldd       ,x                  else get the block number into B; it could be >$80
                    ldu       <D.BlkMap           point to the allocation table
                    ifne      H6309
                    sta       d,u                 clear the block using the 16-bit offset
                    else
                    clr       d,u                 clear the block using the 16-bit offset
                    endc
                    ldd       #DAT.Free           get the free block marker
                    std       ,x                  save it into the DAT image
L08EC               leax      2,x                 move to the next DAT block
                    ifne      H6309
                    dece                          are we done?
                    else
                    leay      -1,y                are we done?
                    endc
                    bne       L08BC               branch if not
L08F2               clrb                          clear the error code and carry
L08F3               rts                           return


;;; F$Boot
;;;
;;; Load the bootfile into system memory.
;;;
;;; Entry:  None.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;

FBoot
                    ifne      f256
                    rts                           the F256 port doesn't use F$Boot
                    else
                    lda       #'t                 tried to boot
                    jsr       <D.BtBug
                    coma                          Set boot flag
                    lda       <D.Boot             we booted once before?
                    bne       L08F3               Yes, return
                    inc       <D.Boot             Set boot flag
                    ldx       <D.Init             Get ptr to init module if it exists
                    beq       L0908               it doesn't, point to boot name
                    ldd       <BootStr,x          Get offset to text
                    beq       L0908               Doesn't exist, get hard coded text
                    leax      d,x                 Adjust X to point to boot module
                    bra       L090C               Try & link to module

boot                fcs       /Boot/

L0908               leax      <boot,pcr
* Link to module and execute
L090C               lda       #Systm+Objct
                    os9       F$Link
                    bcs       L08F3               return with error.
                    lda       #'b                 calling boot
                    jsr       <D.BtBug
                    jsr       ,y                  load boot file
                    bcs       L08F3
                    std       <D.BtSz             save boot file size
                    stx       <D.BtPtr            save start pointer of bootfile
                    lda       #'b                 boot returns OK
                    jsr       <D.BtBug

* added for IOMan system memory extentions
                    ifne      H6309
                    ldd       M$Name,x            grab the name offset
                    ldd       d,x                 find the first 2 bytes of the first module
                    cmpd      #$4E69              'Ni' ? (NitrOS9 module?)
                    bne       not.ext             no, not system memory extensions
                    ldd       M$Exec,x            grab the execution ptr
                    jmp       d,x                 and go execute the system memory extension module
                    endc

not.ext             ldd       <D.BtSz
                    bsr       I.VBlock            internal verify block routine
                    ldx       <D.SysDAT           get system DAT pointer
                    ldb       $0D,x               get highest allocated block number
                    incb                          allocate block 0, too
                    ldx       <D.BlkMap           point to the memory block map
                    lbra      L01DF               and go mark the blocks as used.
                    endc

;;; F$VBlock
;;;
;;; Validate a block of memory for modules.
;;;
;;; Entry:  D = The size of the block to verify.
;;;         X = The address to start the verification.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;

FVBlock             ldd       R$D,u               get the size of the block to verify
                    ldx       R$X,u               get the start address to verify
I.VBlock            leau      d,x                 point to the end of the block
                    tfr       x,d                 transfer the start of the block to D
                    anda      #%11100000          mask out all but the block number bits
                    clrb                          D is now the block number
                    pshs      d,u                 save the starting block and the ending block
                    lsra                          A = A / 2
                    lsra                          A = A / 4
                    lsra                          A = A / 8
                    lsra                          A = A / 16: the logical block * 2
                    ldy       <D.SysDAT           get the pointer to the system DAT image
                    leay      a,y                 point Y to the offset into the block
L092D               ldd       M$ID,x              get the module ID signature
                    cmpd      #M$ID12             is it a valid module ID?
                    bne       L0954               no, keep looking
                    ldd       M$Name,x            else get the name offset pointer
                    pshs      x                   save the address of the module header onto the stack
                    leax      d,x                 point X to the name in the module
name.prt            lda       ,x+                 get the character of the name
                    jsr       <D.BtBug            print it out
                    bpl       name.prt            keep printing the character until we've reached the last one
                    lda       #C$SPAC             get a space
                    jsr       <D.BtBug            and print it out
                    puls      x                   retrieve the address of the module header
                    tfr       x,d                 transfer it to D
                    subd      ,s                  subtract the starting block address from the module address
                    tfr       d,x                 X now holds the offset into the block of the module
                    tfr       y,d                 Y holds the offset into the block
                    os9       F$VModul            validate the module
                    pshs      b                   save B
                    ldd       1,s                 get the starting address
                    leax      d,x                 move X past it
                    puls      b                   restore B
                    bcc       L094E               branch if the validation succeeded
                    cmpb      #E$KwnMod           else an error occurred; is it the "known module" error?
                    bne       L0954               no, assume a case of mistaken identity and continue
L094E               ldd       M$Size,x            else get the module size
                    leax      d,x                 and step over it
                    fcb       $8C                 skip the next 2 bytes (continue at L0956)
L0954               leax      1,x                 move to the next byte
L0956               cmpx      2,s                 have we gone through the whole bootfile?
                    bcs       L092D               no, keep looking
                    leas      4,s                 else recover the stack
                    clrb                          clear the error code and carry
                    rts                           return

                    endc
