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
