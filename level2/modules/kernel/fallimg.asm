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
FAllImg             ldd       R$D,u               get starting block # & # of blocks
                    ldx       R$X,u               get process descriptor pointer
* 6309 NOTE: IF W IS USED HERE, TRY TO PRESERVE IT AS F$SRQMEM WILL
*   PROBABLY END UP USING IT
* Entry point from F$SRqMem
L09BE               pshs      d,x,y,u
                    lsla                          Start MMU block #*2 (2 bytes/DAT entry)
                    leay      P$DATImg,x          Point to DAT img in process descriptor
                    leay      a,y                 Point to specific block # we want
                    clra
                    tfr       d,x                 X=# of blocks
                    ldu       <D.BlkMap           Get memory block map ptr
                    pshs      d,x,y,u             Save regs
L09CD               ldd       ,y++                Get DAT for current block
                    cmpd      #DAT.Free           Is it free?
                    beq       L09E2               Yes, skip ahead
                    lda       d,u                 No, get the memory block block type
                    cmpa      #RAMinUse           RAM already in use?
                    puls      d                   Get # of blocks to allocate back
                    bne       L09F7               not RAM in use, skip ahead
                    IFNE      H6309
                    decd      Drop                # of blocks needed
                    ELSE
                    subd      #$0001              Drop # of blocks needed
                    ENDC
                    pshs      d                   Save as new # of blocks still needed
L09E2               leax      -1,x                Drop total # of blocks needed
                    bne       L09CD               Still more, keep checking
                    ldx       ,s++                Get # of blocks still needed
                    beq       L0A00               None, skip ahead
L09EA               lda       ,u+                 Get flag byte for next MMU block in full memory map
                    bne       L09F2               Not free, skip ahead
                    leax      -1,x                Free, drop total # of blocks needed
                    beq       L0A00               No more left, skip ahead
L09F2               cmpu      <D.BlkMap+2         Have we hit the end of the full memory map?
                    blo       L09EA               No, keep checking
L09F7               ldb       #E$MemFul           Yes, we couldn't allocate, mem full error
                    leas      6,s                 Eat stack
                    stb       1,s                 Save error # on stack to pull off as B
                    comb
                    puls      d,x,y,u,pc          Restore regs, exit with mem full error

* Found enough RAM for allocation request
L0A00               puls      x,y,u               Restore some regs
L0A02               ldd       ,y++                Get DAT image for current 8K block
                    cmpd      #DAT.Free           Is it marked as free?
                    bne       L0A16               No, skip ahead
L0A0A               lda       ,u+                 Yes, get memory map flag for MMU block
                    bne       L0A0A               Already allocated in some way, look for free one
                    inc       ,-u                 Was unused; set to RAMinUse
                    tfr       u,d                 Move ptr to just allocated block to D
                    subd      <D.BlkMap           Subtract start of main memory map ptr
                    std       -2,y                Save MMU block # into DAT block
L0A16               leax      -1,x                Dec # blocks left to assign
                    bne       L0A02               Keep going until all are allocated
                    ldx       2,s                 Get process descriptor ptr back
                    IFNE      H6309
                    oim       #ImgChg,P$State,x   flag DAT IMG change for system
                    ELSE
                    lda       P$State,x           flag DAT IMG change for system
                    ora       #ImgChg
                    sta       P$State,x
                    ENDC
                    clrb                          No error, restore regs & return
                    puls      d,x,y,u,pc
