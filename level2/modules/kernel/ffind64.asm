**************************************************
* System Call: F$Find64
*
* Function: Find a 64 byte memory block
*
* Input:  X = Address of page table
*         A = Block number
*
* Output: Y = Address of block
*
* Error:  CC = C bit set; B = error code
*
FFind64             ldx       R$X,u               Get block tbl ptr
                    lda       R$A,u               get path block #
* Find a empty path block
                    beq       L0A70               None, return error
                    clrb                          calculate address
                    ifne      H6309
                    lsrd                          (Divide by 4)
                    lsrd
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    endc
                    lda       a,x                 is that block allocated?
                    tfr       d,x                 Move addr to X
                    beq       L0A70               no, return error
                    tst       ,x                  this the page table?
                    bne       L0A71               no, we can use this one
L0A70               coma                          set carry & return
                    rts
L0A71               stx       R$Y,u               save address of block
                    rts                           return


**************************************************
* System Call: F$All64
*
* Function: Allocate a 64 byte memory block
*
* Input:  X = Address of page table (0 if page table hasn't been allocated)
*
* Output: A = Block number
*         X = Address of page table
*         Y = Address of block
*
* Error:  CC = C bit set; B = error code
*
*
FAll64              ldx       R$X,u               get base address of page table
                    bne       L0A7F               it's been allocated, skip ahead
                    bsr       L0A89               allocate the page
                    bcs       L0A88               error allocating, return
                    stx       ,x                  save base address in page table
                    stx       R$X,u               save base address to caller's X
L0A7F               bsr       L0A9F               find a empty spot in path table
                    bcs       L0A88               couldn't find one, return error
                    sta       R$A,u               save block #
                    sty       R$Y,u               save address of block
L0A88               rts                           return

* Allocate a new base page
* Exit: X=Ptr to newly allocated 256 byte page
L0A89               pshs      u                   preserve register stack pointer
                    ifne      H6309
                    ldq       #$01000100          get block size (1 for SRqMem & 1 for TFM)
                    else
                    ldd       #$0100
                    endc
                    os9       F$SRqMem            request mem for it
                    leax      ,u                  point to it
                    ldu       ,s                  restore register stack pointer
                    stx       ,s                  save pointer to new page on stack
                    bcs       L0A9E               error on allocate, return
* Clear freshly allocated page to 0's
                    ifne      H6309
                    leay      TFMNull,pc          point to NULL byte
                    tfm       y,x+
                    else
                    clrb
AllLoop             clr       ,x+
                    decb
                    bne       AllLoop
                    endc
L0A9E               puls      x,pc

                    ifne      H6309
TFMNull             fcb       0                   used to clear memory
                    endc

* Search page table for a free 64 byte block
* Entry: X=Ptr to base page (the one with the 64 entry page index)
L0A9F               pshs      x,u                 preserve base page & register stack ptrs
                    clra                          Index entry #=0
* Main search loop
L0AA2               pshs      a                   Save which index entry we are checking
                    clrb                          Set position within page we are checking to 0
                    lda       a,x                 Is the current index entry used?
                    beq       L0AB4               no, skip ahead
                    tfr       d,y                 Yes, Move ptr to 256 byte block to Y
                    clra                          Clear offset for 64 byte blocks to 0
L0AAC               tst       d,y                 Is this 64 byte block allocated?
                    beq       L0AB6               No, skip ahead
                    addb      #$40                Yes, point to next 64 byte block in page
                    bcc       L0AAC               If not done checking entire page, keep going

* Index entry has a totally unused 256 byte page
L0AB4               orcc      #Carry              Set flag (didn't find one)
L0AB6               leay      d,y
                    puls      a                   Get which index entry we were checking
                    bcc       L0AE1               If we found a blank entry, go allocate it
                    inca                          Didn't, move to next index entry
                    cmpa      #64                 Done entire index?
                    blo       L0AA2               no, keep looking

                    clra                          Yes, clear out to first entry
L0AC2               tst       a,x                 Is this one used?
                    beq       L0AD0               No, skip ahead
                    inca                          Increment index entry #
                    cmpa      #64                 Done entire index?
                    blo       L0AC2               No, continue looking

                    comb                          Done all of them, exit with Path table full error
                    ldb       #E$PthFul
                    puls      x,u,pc
* Found empty page
L0AD0               pshs      x,a                 Preserve index ptr & index entry #
                    bsr       L0A89               Allocate & clear out new 256 byte page
                    bcs       L0AF0               If error,exit
                    leay      ,x                  Point Y to start of new page
                    tfr       x,d                 Also copy to D
                    tfr       a,b                 Page # into B
                    puls      x,a                 Get back index ptr & index entry #
                    stb       a,x                 Save page # in proper index entry
                    clrb                          D=index entry #*256

* D = Block Address
L0AE1               equ       *
                    ifne      H6309
                    lsld                          ???Calculate 256 byte page #?
                    lsld
                    tfr       y,u                 U=Ptr to start of new page
                    ldw       #$3f                Clear out the 64 byte block we are using
                    leax      TFMNull,pc
                    tfm       x,u+
                    else
                    aslb
                    rola
                    aslb
                    rola
                    ldb       #$3f
ClrIt               clr       b,y
                    decb
                    bne       ClrIt
                    endc
                    sta       ,y                  Save 256 byte page # as 1st byte of block
                    puls      x,u,pc

L0AF0               leas      3,s
                    puls      x,u,pc


**************************************************
* System Call: F$Ret64
*
* Function: Deallocate a 64 byte memory block
*
* Input:  X = Address of page table
*         A = Block number
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FRet64              lda       R$A,u
                    ldx       R$X,u
                    pshs      u,y,x,d
                    clrb
                    tsta
                    beq       L0B22
                    ifne      H6309
                    lsrd                          (Divide by 4)
                    lsrd
                    else
                    lsra
                    rorb
                    lsra
                    rorb
                    endc
                    pshs      a
                    lda       a,x
                    beq       L0B20
                    tfr       d,y
                    clr       ,y
                    clrb
                    tfr       d,u
                    clra
L0B10               tst       d,u
                    bne       L0B20
                    addb      #$40
                    bne       L0B10
                    inca
                    os9       F$SRtMem
                    lda       ,s
                    clr       a,x
L0B20               clr       ,s+
L0B22               puls      pc,u,y,x,d
