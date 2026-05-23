**************************************************
* System Call: F$AllImg
*
* Function: Allocate image RAM blocks
*
* Input:  A = Starting block number
*         B = Number of blocks
*         X = Process descriptor pointer
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FAllImg             ldd       R$D,u     ; get starting block # & # of blocks
                    ldx       R$X,u     ; get process descriptor pointer
* 6309 NOTE: IF W IS USED HERE, TRY TO PRESERVE IT AS F$SRQMEM WILL
*   PROBABLY END UP USING IT
* Entry point from F$SRqMem
FAllimgTarget       pshs      d,x,y,u   ; save d,x,y,u on the stack
                    lsla                ; start MMU block #*2 (2 bytes/DAT entry)
                    leay      P$DATImg,x ; point to DAT img in process descriptor
                    leay      a,y       ; point to specific block # we want
                    clra                ; clear A
                    tfr       d,x       ; X=# of blocks
                    ldu       <D.BlkMap ; get memory block map ptr
                    pshs      d,x,y,u   ; save regs
FAllimgDATBlock     ldd       ,y++      ; get DAT for current block
                    cmpd      #DAT.Free ; is it free?
                    beq       FAllimgDropTotalBlocksNeeded ; yes, skip ahead
                    lda       d,u       ; no, get the memory block block type
                    cmpa      #RAMinUse ; rAM already in use?
                    puls      d         ; get # of blocks to allocate back
                    bne       FAllimgWeCouldntAllocateMemoryFull ; not RAM in use, skip ahead
                  IFNE    H6309   ; begin conditional assembly for H6309
                    decd      ;         drop                # of blocks needed
                  ELSE
                    subd      #$0001    ; drop # of blocks needed
                  ENDC
                    pshs      d         ; save as new # of blocks still needed
FAllimgDropTotalBlocksNeeded leax      -1,x      ; drop total # of blocks needed
                    bne       FAllimgDATBlock ; still more, keep checking
                    ldx       ,s++      ; get # of blocks still needed
                    beq       FAllimgSome ; none, skip ahead
FAllimgFlagMMUBlockFullMemory lda       ,u+       ; get flag byte for next MMU block in full memory map
                    bne       FAllimgHaveWeHitEndFull ; not free, skip ahead
                    leax      -1,x      ; free, drop total # of blocks needed
                    beq       FAllimgSome ; no more left, skip ahead
FAllimgHaveWeHitEndFull cmpu      <D.BlkMap+2 ; have we hit the end of the full memory map?
                    blo       FAllimgFlagMMUBlockFullMemory ; no, keep checking
FAllimgWeCouldntAllocateMemoryFull ldb       #E$MemFul ; yes, we couldn't allocate, mem full error
                    leas      6,s       ; eat stack
                    stb       1,s       ; save error # on stack to pull off as B
                    comb                ; update processor state
                    puls      d,x,y,u,pc ; restore regs, exit with mem full error

* Found enough RAM for allocation request
FAllimgSome         puls      x,y,u     ; restore some regs
FAllimgDATImageBlock ldd       ,y++      ; get DAT image for current 8K block
                    cmpd      #DAT.Free ; is it marked as free?
                    bne       FAllimgDecBlocksLeftAssign ; no, skip ahead
FAllimgMemoryMapFlagMMUBlock lda       ,u+       ; yes, get memory map flag for MMU block
                    bne       FAllimgMemoryMapFlagMMUBlock ; already allocated in some way, look for free one
                    inc       ,-u       ; was unused; set to RAMinUse
                    tfr       u,d       ; move ptr to just allocated block to D
                    subd      <D.BlkMap ; subtract start of main memory map ptr
                    std       -2,y      ; save MMU block # into DAT block
FAllimgDecBlocksLeftAssign leax      -1,x      ; dec # blocks left to assign
                    bne       FAllimgDATImageBlock ; keep going until all are allocated
                    ldx       2,s       ; get process descriptor ptr back
                  IFNE    H6309   ; begin conditional assembly for H6309
                    oim       #ImgChg,P$State,x ; flag DAT IMG change for system
                  ELSE
                    lda       P$State,x ; flag DAT IMG change for system
                    ora       #ImgChg   ; merge #ImgChg into A
                    sta       P$State,x ; store A at P$State,x
                  ENDC
                    clrb                ; no error, restore regs & return
                    puls      d,x,y,u,pc ; restore d,x,y,u,pc from the stack
