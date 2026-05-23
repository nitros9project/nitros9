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
FFind64             ldx       R$X,u     ; get block tbl ptr
                    lda       R$A,u     ; get path block #
* Find a empty path block
                    beq       L0A70     ; none, return error
                    clrb                ; calculate address
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lsrd                ; (Divide by 4)
                    lsrd                ; shift or rotate and update condition codes
                  ELSE
                    lsra                ; shift or rotate and update condition codes
                    rorb                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    rorb                ; shift or rotate and update condition codes
                  ENDC
                    lda       a,x       ; is that block allocated?
                    tfr       d,x       ; move addr to X
                    beq       L0A70     ; no, return error
                    tst       ,x        ; this the page table?
                    bne       L0A71     ; no, we can use this one
L0A70               coma                ; set carry & return
                    rts                 ; return to caller
L0A71               stx       R$Y,u     ; save address of block
                    rts                 ; return


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
FAll64              ldx       R$X,u     ; get base address of page table
                    bne       L0A7F     ; it's been allocated, skip ahead
                    bsr       L0A89     ; allocate the page
                    bcs       L0A88     ; error allocating, return
                    stx       ,x        ; save base address in page table
                    stx       R$X,u     ; save base address to caller's X
L0A7F               bsr       L0A9F     ; find a empty spot in path table
                    bcs       L0A88     ; couldn't find one, return error
                    sta       R$A,u     ; save block #
                    sty       R$Y,u     ; save address of block
L0A88               rts                 ; return

* Allocate a new base page
* Exit: X=Ptr to newly allocated 256 byte page
L0A89               pshs      u         ; preserve register stack pointer
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldq       #$01000100 ; get block size (1 for SRqMem & 1 for TFM)
                  ELSE
                    ldd       #$0100    ; load D from #$0100
                  ENDC
                    os9       F$SRqMem  ; request mem for it
                    leax      ,u        ; point to it
                    ldu       ,s        ; restore register stack pointer
                    stx       ,s        ; save pointer to new page on stack
                    bcs       L0A9E     ; error on allocate, return
* Clear freshly allocated page to 0's
                  IFNE    H6309   ; begin conditional assembly for H6309
                    leay      TFMNull,pc ; point to NULL byte
                    tfm       y,x+      ; transfer memory block using y,x+
                  ELSE
                    clrb                ; clear B
AllLoop             clr       ,x+       ; clear ,x+
                    decb                ; decrement B
                    bne       AllLoop   ; branch if zero is clear to AllLoop
                  ENDC
L0A9E               puls      x,pc      ; restore x,pc from the stack

                  IFNE    H6309   ; begin conditional assembly for H6309
TFMNull             fcb       0         ; used to clear memory
                  ENDC

* Search page table for a free 64 byte block
* Entry: X=Ptr to base page (the one with the 64 entry page index)
L0A9F               pshs      x,u       ; preserve base page & register stack ptrs
                    clra                ; index entry #=0
* Main search loop
L0AA2               pshs      a         ; save which index entry we are checking
                    clrb                ; set position within page we are checking to 0
                    lda       a,x       ; is the current index entry used?
                    beq       L0AB4     ; no, skip ahead
                    tfr       d,y       ; yes, Move ptr to 256 byte block to Y
                    clra                ; clear offset for 64 byte blocks to 0
L0AAC               tst       d,y       ; is this 64 byte block allocated?
                    beq       L0AB6     ; no, skip ahead
                    addb      #$40      ; yes, point to next 64 byte block in page
                    bcc       L0AAC     ; if not done checking entire page, keep going

* Index entry has a totally unused 256 byte page
L0AB4               orcc      #Carry    ; set flag (didn't find one)
L0AB6               leay      d,y       ; compute d,y into Y
                    puls      a         ; get which index entry we were checking
                    bcc       L0AE1     ; if we found a blank entry, go allocate it
                    inca                ; didn't, move to next index entry
                    cmpa      #64       ; done entire index?
                    blo       L0AA2     ; no, keep looking

                    clra                ; yes, clear out to first entry
L0AC2               tst       a,x       ; is this one used?
                    beq       L0AD0     ; no, skip ahead
                    inca                ; increment index entry #
                    cmpa      #64       ; done entire index?
                    blo       L0AC2     ; no, continue looking

                    comb                ; done all of them, exit with Path table full error
                    ldb       #E$PthFul ; load B from #E$PthFul
                    puls      x,u,pc    ; restore x,u,pc from the stack
* Found empty page
L0AD0               pshs      x,a       ; preserve index ptr & index entry #
                    bsr       L0A89     ; allocate & clear out new 256 byte page
                    bcs       L0AF0     ; if error,exit
                    leay      ,x        ; point Y to start of new page
                    tfr       x,d       ; also copy to D
                    tfr       a,b       ; page # into B
                    puls      x,a       ; get back index ptr & index entry #
                    stb       a,x       ; save page # in proper index entry
                    clrb                ; D=index entry #*256

* D = Block Address
L0AE1               equ       *         ; define assembler symbol L0AE1
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lsld                ; ???Calculate 256 byte page #?
                    lsld                ; shift or rotate and update condition codes
                    tfr       y,u       ; U=Ptr to start of new page
                    ldw       #$3f      ; clear out the 64 byte block we are using
                    leax      TFMNull,pc ; compute TFMNull,pc into X
                    tfm       x,u+      ; transfer memory block using x,u+
                  ELSE
                    aslb                ; update processor state
                    rola                ; shift or rotate and update condition codes
                    aslb                ; update processor state
                    rola                ; shift or rotate and update condition codes
                    ldb       #$3f      ; load B from #$3f
ClrIt               clr       b,y       ; clear b,y
                    decb                ; decrement B
                    bne       ClrIt     ; branch if zero is clear to ClrIt
                  ENDC
                    sta       ,y        ; save 256 byte page # as 1st byte of block
                    puls      x,u,pc    ; restore x,u,pc from the stack

L0AF0               leas      3,s       ; adjust stack pointer by 3,s
                    puls      x,u,pc    ; restore x,u,pc from the stack


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
FRet64              lda       R$A,u     ; load A from R$A,u
                    ldx       R$X,u     ; load X from R$X,u
                    pshs      u,y,x,d   ; save u,y,x,d on the stack
                    clrb                ; clear B
                    tsta                ; test A and update condition codes
                    beq       L0B22     ; branch if zero is set to L0B22
                  IFNE    H6309   ; begin conditional assembly for H6309
                    lsrd                ; (Divide by 4)
                    lsrd                ; shift or rotate and update condition codes
                  ELSE
                    lsra                ; shift or rotate and update condition codes
                    rorb                ; shift or rotate and update condition codes
                    lsra                ; shift or rotate and update condition codes
                    rorb                ; shift or rotate and update condition codes
                  ENDC
                    pshs      a         ; save a on the stack
                    lda       a,x       ; load A from a,x
                    beq       L0B20     ; branch if zero is set to L0B20
                    tfr       d,y       ; transfer register value d,y
                    clr       ,y        ; clear ,y
                    clrb                ; clear B
                    tfr       d,u       ; transfer register value d,u
                    clra                ; clear A
L0B10               tst       d,u       ; test d,u and update condition codes
                    bne       L0B20     ; branch if zero is clear to L0B20
                    addb      #$40      ; add #$40 to B
                    bne       L0B10     ; branch if zero is clear to L0B10
                    inca                ; increment A
                    os9       F$SRtMem  ; call OS-9 service F$SRtMem
                    lda       ,s        ; load A from ,s
                    clr       a,x       ; clear a,x
L0B20               clr       ,s+       ; clear ,s+
L0B22               puls      pc,u,y,x,d ; restore pc,u,y,x,d from the stack
