;;; F$All64
;;;
;;; Allocate a 64 byte block of memory.
;;;
;;; Entry:  X = The base address of the page table; 0 = allocate the page table.
;;;
;;; Exit:   A = The block number of the allocated 64 byte block.
;;;         X = The base address of the page table.
;;;         Y = The address of the block.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; F$All64 allocates a 64 byte block of memory by splitting 256 byte pages into four 64 byte blocks.
;;; The kernel uses the first 64 bytes of the base page as a page table. The page table holds up to 64
;;; MSB (most significant byte) references to allocated 256 byte pages.
;;;
;;; If you call F$All64 with X set to zero, F$All64 allocates a new base page and the first 64 byte memory block.
;;;
;;; Whenever a new 256 byte page is needed, F$All64 calls F$SRqMem to allocate 256 bytes of memory.
;;;
;;; The first byte of each block contains the block number, so only the remaining 63 bytes are usable.
;;; Routines using F$All64 shouldn't alter this first byte.
;;; 
;;; The following diagram shows how 64 byte blocks might be allocated in two 256 byte pages located at $3000 ad
;;; $3600, respectively:
;;;
;;;                 -------------------------
;;; Base Page -->  | $30/$36     | $30       |
;;;  $3000         | Page Table  |           |
;;;                | 64 bytes    | 64 bytes  |
;;;                |------------ ------------|
;;;                | $30         | $30       |
;;;                | 64 bytes    | 64 bytes  |
;;;                 -------------------------
;;;
;;;                 -------------------------
;;; Next Page -->  | $36         | $36       |
;;;  $3600         | 64 bytes    | 64 bytes  |
;;;                |-------------------------|
;;;                | $36         |           |
;;;                | 64 bytes    | 64 bytes  |
;;;                 -------------------------
;;;
;;; In this example, the first 256 byte page at $3000 is the base page. All four of its 64 byte blocks are allocated
;;; with the first block acting as the page table. Its first two bytes are $30 and $36 which are the MSBs of the addresses
;;; of the allocated pages.
;;; The next 256 byte page at $3600 has three of its four 64 byte blocks allocated and one remaining free. The first byte
;;; of each of the allocated 64 byte blocks contains the MSB of the 256 byte address of its block.

FAll64         ldx       R$X,u               get base address of page table
               bne       notempty@           branch if not empty
               bsr       Alloc256Bytes       otherwise allocate memory for a new page table
               bcs       ex@                 exit if error
               stx       ,x                  save off address of page table in newly allocated page
               stx       R$X,u               and in caller's X
notempty@      bsr       Alloc64Bytes        find a free 64 byte block to allocate
               bcs       ex@                 branch if error
               sta       R$A,u               save the block number to caller's A
               sty       R$Y,u               and the address to the caller's Y
ex@            rts                           return to caller  

* Allocate a 256 byte page from system RAM
*
* Exit:  D = 0
*        X = The address of a newly allocated and cleared 256 bytes of RAM.
*       CC = Carry flag clear to indicate success.
*
* Error:  B = A non-zero error code.
*        CC = Carry flag set to indicate error.
Alloc256Bytes  pshs      u                   save off caller's registers
               ldd       #256                we want to allocate 256 bytes
               os9       F$SRqMem            request from system memory
               leax      ,u                  point X to start of newly allocated area
               puls      u                   and recover U saved earlier
               bcs       ex@                 branch if error
* clear out the newly allocated area
               clra                          A = 0 (used to for clearing byte)
               clrb                          B = 0 (used for 256 loop counter)
loop@          sta       d,x                 clear byte at ,X
               incb                          count loop up
               bne       loop@               branch not zero (more to clear)
ex@            rts                           return to caller

* Walk the 64 byte page table to allocate a 64 byte block of memory.
*
* Entry: X = The base address of the page table.
*
* Exit:  A = The allocated block number.
*        Y = The address of the allocated 64 byte block.
Alloc64Bytes   pshs      u,x                 save caller's regs and base address of page table
               clra                          A = 0
searchnext@    pshs      a                   save on stack
               clrb                          B = 0
               lda       a,x                 get byte at page table from index A; D now is address
               beq       pagefree@           branch if zero (no page allocated)
               tfr       d,y                 else put D in Y
               clra                          clear A
checkpage@     tst       d,y                 is this 64 byte page available?
               beq       pagefree2@          branch if it is
               addb      #64                 else add block size of 64 to B
               bcc       checkpage@          and go check next block if B < 256
pagefree@      orcc      #Carry              set carry flag to indicate this page is free and can be allocated
pagefree2@     leay      d,y                 point Y to the free 64 byte block
               puls      a                   recover A from stack
               bcc       mark2@              branch if no page allocated (carry set earlier)
               inca                          increment A
               cmpa      #64                 at 64?
               bcs       searchnext@         branch if less than 64
               clra                          A = 0
testnext@      tst       a,x                 test value at A,X
               beq       mark@               branch if 0
               inca                          increment A
               cmpa      #64                 at 64?
               bcs       testnext@           branch if less than
               ldb       #E$PthFul           otherwise the path table is full (all 64 bytes hold MSB addresses)
               coma                          set carry
               bra       ex1@                return to caller
mark@          pshs      x,a                 save X (address of page table) and A (current offset in page table)
               bsr       Alloc256Bytes       go allocate 256 bytes
               bcs       ex2@                branch if error
               leay      ,x                  point Y to the newly allocated 256 bytes
               tfr       x,d                 put X into D
               tfr       a,b                 put MSB of address into B
               puls      x,a                 recover X and A saved earlier
               stb       a,x                 store MSB of address (B) into location in 64 byte page table
               clrb                          B = 0
mark2@         lslb                          multiply D times 2
               rola                          then...
               lslb                          multiply D times 2 again (D = D*4)
               rola                          A now holds MSB of address of the 256 byte page that this 64 byte block is in
               ldb       #64-1               get block size minus 1 (clear remaining 63 bytes)
loop@          clr       b,y                 clear the byte in the block
               decb                          decrement b
               bne       loop@               continue if more to clear
               sta       ,y                  save MSB of block address in first byte of 64 byte block
ex1@           puls      pc,u,x              pull registers and return
ex2@           leas      3,s                 recover stack
               puls      pc,u,x              pull registers and return
